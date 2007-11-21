#!/usr/local/bin/python

import urllib, urllib2
import HTMLParser
#from BeautifulSoup import BeautifulSoup

# Adding this to try to help Surrey Heath - Duncan 14/9/2007
import cookielib
cookie_jar = cookielib.CookieJar()
################

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

#This is to get the system key out of the info url
system_key_regex = re.compile("TheSystemkey=(\d*)", re.IGNORECASE)

class AcolnetParser(HTMLParser.HTMLParser):
    case_number_tr = None # this one can be got by the td class attribute
    reg_date_tr = None
    location_tr = None
    proposal_tr = None

    # There is no online comment facility in these, so we provide an
    # appropriate email address instead
    comments_email_address = None

    action_regex = re.compile("<form[^>]*action=\"([^\"]*ACTION=UNWRAP&RIPSESSION=[^\"]*)\"[^>]*>", re.IGNORECASE)    
    
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
            if tag == "a" and self._tr_number == self.case_number_tr:
                # this is where we get the info link and the case number
                for key, value in attrs:
                    if key == "href":
                        self._current_application.info_url = value

                        system_key = system_key_regex.search(value).groups()[0]

                        if self.comments_email_address is not None:
                            self._current_application.comment_url = self.comments_email_address
                        else:
                            self._current_application.comment_url = value.replace("PgeResultDetail", "PgeCommentForm")
                        
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


    def _getSearchResponse(self):
        # It looks like we sometimes need to do some stuff to get around a
        # javascript redirect and cookies.
        search_form_request = urllib2.Request(self.base_url)
        search_form_response = urllib2.urlopen(search_form_request)

        return search_form_response
        

    def getResultsByDayMonthYear(self, day, month, year):
        # first we fetch the search page to get ourselves some session info...
        search_form_response = self._getSearchResponse()
        
        search_form_contents = search_form_response.read()

        #outfile = open("tmpfile", "w")
        #outfile.write(search_form_contents)

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

## # Babergh up to 21/06/2007
## class BaberghParser(AcolnetParser):
##     case_number_tr = 1 # this one can be got by the td class attribute
##     reg_date_tr = 2
##     location_tr = 4
##     proposal_tr = 5

##     # It would be nice to scrape this...
##     comments_email_address = "planning.reception@babergh.gov.uk"

# Site changes to here from 22/06/2007
class BaberghParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6

    # It would be nice to scrape this...
    comments_email_address = "planning.reception@babergh.gov.uk"

class BasingstokeParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 8

    # It would be nice to scrape this...
    comments_email_address = "development.control@basingstoke.gov.uk"

class BassetlawParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "planning@bassetlaw.gov.uk"

    def _cleanupHTML(self, html):
        """There is a broken div in this page. We don't need any divs, so
        let's get rid of them all."""

        div_regex = re.compile("</?div[^>]*>", re.IGNORECASE)
        return div_regex.sub('', html)


class BridgnorthParser(AcolnetParser):
    # This site is currently down...
    #search_url = "http://www2.bridgnorth-dc.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"
    #authority_name = "Bridgenorth District Council"
    #authority_short_name = "Bridgenorth"
    
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "contactus@bridgnorth-dc.gov.uk"

class BuryParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6    

    #comments_email_address = "development.control@bury.gov.uk"

## class CanterburyParser(AcolnetParser):
##     search_url = "http://planning.canterbury.gov.uk/scripts/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

##     case_number_tr = 1 # this one can be got by the td class attribute
##     reg_date_tr = 2
##     location_tr = 4
##     proposal_tr = 5    

##     authority_name = "Canterbury City Council"
##     authority_short_name = "Canterbury"

##     comments_email_address = ""

class CarlisleParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 5
    proposal_tr = 6    

    comments_email_address = "dc@carlisle.gov.uk"

class DerbyParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "developmentcontrol@derby.gov.uk"

class CroydonParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6    

    comments_email_address = "planning.control@croydon.gov.uk"

class EastLindseyParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6    

    comments_email_address = "development.control@e-lindsey.gov.uk"

class FyldeParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "planning@fylde.gov.uk"

class HarlowParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "Planning.services@harlow.gov.uk"

class HavantParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 8    

    comments_email_address = "representations@havant.gov.uk"

class HertsmereParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "planning@hertsmere.gov.uk"

class LewishamParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

    comments_email_address = "planning@lewisham.gov.uk"
    
class NorthHertfordshireParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5    

## class MidSuffolkParser(AcolnetParser):
##     case_number_tr = 1 # this one can be got by the td class attribute
##     reg_date_tr = 2
##     location_tr = 4
##     proposal_tr = 5    

##     comments_email_address = "planning@lewisham.gov.uk"
##     #action_regex = re.compile("<FORM .*action=\"(.*ACTION=UNWRAP&RIPSESSION=[^\"]*)\"[^>]*>", re.IGNORECASE)    

class NewForestNPParser(AcolnetParser):
    # In this case there is an online comment facility at the
    # bottom of each view app page...
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

class NewForestDCParser(AcolnetParser):
    # In this case there is an online comment facility at the
    # bottom of each view app page...
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 7

class NorthWiltshireParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 7

class OldhamParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 6
    proposal_tr = 7
        
    def _cleanupHTML(self, html):
        """There is a bad table end tag in this one.
        Fix it before we start"""
        
        bad_table_end = '</table summary="Copyright">'
        good_table_end = '</table>'
        return html.replace(bad_table_end, good_table_end)

        
class RenfrewshireParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

    comments_email_address = "pt@renfrewshire.gov.uk"

class SouthBedfordshireParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 3
    location_tr = 5
    proposal_tr = 6

class SuffolkCoastalParser(AcolnetParser):
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

    comments_email_address = "d.c.admin@suffolkcoastal.gov.uk"

class GuildfordParser(AcolnetParser):
    case_number_tr = 1
    reg_date_tr = 7
    location_tr = 2
    proposal_tr = 3
    
    #http://www.guildford.gov.uk/acolnet/acolnetcgi.gov?ACTION=UNWRAP&Root=PgeSearch

class SurreyHeathParser(AcolnetParser):
    # This is not working yet.
    # _getSearchResponse is an attempt to work around
    # cookies and a javascript redirect.
    # I may have a bit more of a go at this at some point if I have time.
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

    comments_email_address = "development-control@surreyheath.gov.uk"

    def _getSearchResponse(self):
        # It looks like we sometimes need to do some stuff to get around a
        # javascript redirect and cookies.
        search_form_request = urllib2.Request(self.base_url)

        # Lying about the user-agent doesn't seem to help.
        #search_form_request.add_header("user-agent", "Mozilla/5.0 (compatible; Konqu...L/3.5.6 (like Gecko) (Kubuntu)")
        
        search_form_response = urllib2.urlopen(search_form_request)
        
        cookie_jar.extract_cookies(search_form_response, search_form_request)


        print search_form_response.geturl()
        print search_form_response.info()

        print search_form_response.read()
#        validate_url = "https://www.public.surreyheath-online.gov.uk/whalecom7cace3215643e22bb7b0b8cc97a7/whalecom0/InternalSite/Validate.asp"
#        javascript_redirect_url = urlparse.urljoin(self.base_url, "/whalecom7cace3215643e22bb7b0b8cc97a7/whalecom0/InternalSite/RedirectToOrigURL.asp?site_name=public&secure=1")

#        javascript_redirect_request = urllib2.Request(javascript_redirect_url)
#        javascript_redirect_request.add_header('Referer', validate_url)
        
#        cookie_jar.add_cookie_header(javascript_redirect_request)

#        javascript_redirect_response = urllib2.urlopen(javascript_redirect_request)
        
#        return javascript_redirect_response
    
        
if __name__ == '__main__':
    day = 22
    month = 2
    year = 2005

    # returns error 400 - bad request
    #parser = BridgenorthParser()

    # cambridgeshire is a bit different...
    # no advanced search page

    # canterbury
    # results as columns of one table

    #parser = SurreyHeathParser("Surrey Heath", "Surrey Heath", "https://www.public.surreyheath-online.gov.uk/whalecom60b1ef305f59f921/whalecom0/Scripts/PlanningPagesOnline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")

    parser = GuildfordParser("Guildford", "Guildford", "http://www.guildford.gov.uk/acolnet/acolnetcgi.gov?ACTION=UNWRAP&Root=PgeSearch")
    print parser.getResults(day, month, year)
    
