#!/usr/local/bin/python

import urllib, urllib2
import HTMLParser
#from BeautifulSoup import BeautifulSoup

import urlparse

import re

end_head_regex = re.compile("</head", re.IGNORECASE)

import MultipartPostHandler
# this is not mine, or part of standard python (though it should be!)
# it comes from http://pipe.scs.fsu.edu/PostHandler/MultipartPostHandler.py

from PlanningUtils import getPostcodeFromText, PlanningAuthorityResults, PlanningApplication

from datetime import date
from time import strptime


date_format = "%d/%m/%Y"
our_date = date(2007,4,25)


class AcolnetParser(HTMLParser.HTMLParser):
    case_number_tr = None # this one can be got by the td class attribute
    reg_date_tr = None
    location_tr = None
    proposal_tr = None

    # There is no online comment facility in these, so we provide an
    # appropriate email address instead
    comments_email_address = None

    
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):


        HTMLParser.HTMLParser.__init__(self)

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        self._tr_number = 0

        # This will be used to track the subtable depth
        # when we are in a results-table, in order to
        # avoid adding an application before we have got to
        # the end of the results-table
        self._subtable_depth = None

        self._in_td = False

        # This in where we store the results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

        # This will store the planning application we are currently working on.
        self._current_application = None


    def _cleanupHTML(self, html):
        """This method should be overridden in subclasses to perform site specific
        HTML cleanup."""
        return html

    def handle_starttag(self, tag, attrs):
        #print tag, attrs
                    
        if tag == "table":
            if self._current_application is None:
                # Each application is in a separate table with class "results-table"
                for key, value in attrs:
                    if key == "class" and value == "results-table":
                        #print "found results-table"
                        self._current_application = PlanningApplication()
                        self._tr_number = 0
                        self._subtable_depth = 0
                        self._current_application.comment_url = self.comments_email_address
                        break
            else:
                # We are already in a results-table, and this is the start of a subtable,
                # so increment the subtable depth.
                self._subtable_depth += 1

        elif self._current_application is not None:
            if tag == "tr" and self._subtable_depth == 0:
                self._tr_number += 1
            if tag == "td":
                self._in_td = True
                if self._tr_number == self.case_number_tr:
                    #get the reference and the info link here
                    pass
                elif self._tr_number == self.reg_date_tr:
                    #get the registration date here
                    pass
                elif self._tr_number == self.location_tr:
                    #get the address and postcode here
                    pass
                elif self._tr_number == self.proposal_tr:
                    #get the description here
                    pass
            if tag == "a" and self._tr_number == self.case_number_tr:
                # this is where we get the info link and the case number
                for key, value in attrs:
                    if key == "href":
                        self._current_application.info_url = value
                        
    def handle_data(self, data):
        # If we are in the tr which contains the case number,
        # then data is the council reference, so
        # add it to self._current_application.
        if self._in_td:
            if self._tr_number == self.case_number_tr:
                self._current_application.council_reference = data.strip()
            elif self._tr_number == self.reg_date_tr:
                # we need to make a date object out of data
                date_as_str = ''.join(data.strip().split())
                received_date = date(*strptime(date_as_str, date_format)[0:3])

                #print received_date

                self._current_application.date_received = received_date

            elif self._tr_number == self.location_tr:
                location = data.strip()

                self._current_application.address = location
                self._current_application.postcode = getPostcodeFromText(location)
            elif self._tr_number == self.proposal_tr:
                self._current_application.description = data.strip()


    def handle_endtag(self, tag):
        #print "ending: ", tag
        if tag == "table" and self._current_application is not None:
            if self._subtable_depth > 0:
                self._subtable_depth -= 1
            else:
                # We need to add the last application in the table
                if self._current_application is not None:
                    #print "adding application"
                    self._results.addApplication(self._current_application)
                    #print self._current_application
                    self._current_application = None
                    self._tr_number = None
                    self._subtable_depth = None
        elif tag == "td":
            self._in_td = False

    def getResultsByDayMonthYear(self, day, month, year):
        # first we fetch the search page to get ourselves some session info...
        search_form_response = urllib2.urlopen(self.base_url)
        search_form_contents = search_form_response.read()

        # This sometimes causes a problem in HTMLParser, so let's just get the link
        # out with a regex...

        groups = self.action_regex.search(search_form_contents).groups()

        action = groups[0] 
        #print action

        action_url = urlparse.urljoin(self.base_url, action)
        #print action_url

        our_date = date(year, month, day)
        
        search_data = {"regdate1": our_date.strftime(date_format),
                       "regdate2": our_date.strftime(date_format),
                       }
        
        opener = urllib2.build_opener(MultipartPostHandler.MultipartPostHandler)
        response = opener.open(action_url, search_data)
        results_html = response.read()

        # This is for doing site specific html cleanup
        results_html = self._cleanupHTML(results_html)

        #some javascript garbage in the header upsets HTMLParser,
        #so we'll just have the body
        just_body = "<html>" + end_head_regex.split(results_html)[-1]

        #outfile = open(self.authority_short_name + ".debug", "w")
        #outfile.write(just_body)        

        self.feed(just_body)
        
        return self._results



    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


class BaberghParser(AcolnetParser):
    #search_url = "http://planning.babergh.gov.uk/dataOnlinePlanning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

    #authority_name = "Babergh District Council"
    #authority_short_name = "Babergh"

    # It would be nice to scrape this...
    comments_email_address = "planning.reception@babergh.gov.uk"

    action_regex = re.compile("<FORM  name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" onSubmit=\"return ValidateSearch\(\)\" enctype=\"multipart/form-data\">")

class BasingstokeParser(AcolnetParser):
    #search_url = "http://planning.basingstoke.gov.uk/DCOnline2/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch"
    
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 8

    #authority_name = "Basingstoke and Deane Borough Council"
    #authority_short_name = "Basingstoke and Deane"

    # It would be nice to scrape this...
    comments_email_address = "development.control@basingstoke.gov.uk"

    action_regex = re.compile("<form id=\"frmSearch\" onSubmit=\"\"return ValidateSearch\(\)\"\" name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" enctype=\"multipart/form-data\">")

class BassetlawParser(AcolnetParser):
    #search_url =  "http://www.bassetlaw.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 5
    proposal_tr = 6    

    #authority_name = "Bassetlaw District Council"
    #authority_short_name = "Bassetlaw"

    comments_email_address = "planning@bassetlaw.gov.uk"

    action_regex = re.compile("<FORM  name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" onSubmit=\"return ValidateSearch\(\)\" enctype=\"multipart/form-data\">", re.IGNORECASE)

    def _cleanupHTML(self, html):
        """There is a broken div in this page. We don't need any divs, so
        let's get rid of them all."""

        div_regex = re.compile("</?div[^>]*>", re.IGNORECASE)
        return div_regex.sub('', html)


class BridgenorthParser(AcolnetParser):
    #search_url = "http://www2.bridgnorth-dc.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    #authority_name = "Bridgenorth District Council"
    #authority_short_name = "Bridgenorth"

    comments_email_address = "contactus@bridgnorth-dc.gov.uk"

    action_regex = re.compile("<FORM  name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" onSubmit=\"return ValidateSearch\(\)\" enctype=\"multipart/form-data\">")

class BuryParser(AcolnetParser):
    #search_url = "http://e-planning.bury.gov.uk/ePlanning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    #authority_name = "Bury Metropolitan Borough Council"
    #authority_short_name = "Bury"

    comments_email_address = "development.control@bury.gov.uk"
    action_regex = re.compile("<FORM  name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" onSubmit=\"return ValidateSearch\(\)\" enctype=\"multipart/form-data\">")

## class CanterburyParser(AcolnetParser):
##     search_url = "http://planning.canterbury.gov.uk/scripts/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

##     case_number_tr = 1 # this one can be got by the td class attribute
##     reg_date_tr = 2
##     location_tr = 4
##     proposal_tr = 5    

##     authority_name = "Canterbury City Council"
##     authority_short_name = "Canterbury"

##     comments_email_address = ""
##     action_regex = re.compile("<form id=\"frmSearch\" onSubmit=\"\"return ValidateSearch\(\)\"\" name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" enctype=\"multipart/form-data\">")

class CarlisleParser(AcolnetParser):
    #search_url = "http://planning.carlisle.gov.uk/acolnet/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 5
    proposal_tr = 6    

    #authority_name = "Carlisle City Council"
    #authority_short_name = "Carlisle"

    comments_email_address = "dc@carlisle.gov.uk"
    action_regex = re.compile("<form id=\"frmSearch\" onSubmit=\"\"return ValidateSearch\(\)\"\" name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" enctype=\"multipart/form-data\">")


class DerbyParser(AcolnetParser):
    #search_url = "http://195.224.106.204/scripts/planningpages02%5CXSLPagesDC_DERBY%5CDCWebPages/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 4
    proposal_tr = 5    

    #authority_name = "Derby City Council"
    #authority_short_name = "Derby"

    comments_email_address = "developmentcontrol@derby.gov.uk"
    action_regex = re.compile("<FORM  name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" onSubmit=\"return ValidateSearch\(\)\" enctype=\"multipart/form-data\">")

class CroydonParser(AcolnetParser):
    
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6    

    comments_email_address = "planning.control@croydon.gov.uk"
    action_regex = re.compile("<form id=\"frmSearch\" onSubmit=\"\"return ValidateSearch\(\)\"\" name=\"frmSearch\" method=\"post\" action=\"([^\"]*)\" enctype=\"multipart/form-data\">")

if __name__ == '__main__':
    day = 15
    month = 3
    year = 2007

    # working
    # parser = BasingstokeParser()
    parser = BaberghParser("Babergh District Council", "Babergh", "http://planning.babergh.gov.uk/dataOnlinePlanning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")

    # works with the divs stripped out
    #parser = BassetlawParser()

    # returns error 400 - bad request
    #parser = BridgenorthParser()

    # working
    #parser = BuryParser()

    # cambridgeshire is a bit different...
    # no advanced search page

    # canterbury
    # results as columns of one table

    # returns error 400 - bad request
    #parser = CarlisleParser()

    # working
    #parser = DerbyParser()
    
    print parser.getResults(day, month, year)
    
