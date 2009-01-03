#!/usr/local/bin/python

import urllib, urllib2

import urlparse
import datetime
import re

import BeautifulSoup

import cookielib

cookie_jar = cookielib.CookieJar()


from PlanningUtils import fixNewlines, getPostcodeFromText, PlanningAuthorityResults, PlanningApplication


search_form_url_end = "DcApplication/application_searchform.aspx"
search_results_url_end = "DcApplication/application_searchresults.aspx"
comments_url_end = "DcApplication/application_comments_entryform.aspx"

def index_or_none(a_list, item):
    """
    Returns the index of item in a_list, or None, if it isn't in the list.
    """
    return a_list.count(item) and a_list.index(item)

class PublicAccessParser:
    """This is the class which parses the PublicAccess search results page.
    """

    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):
        
        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        # First download the search form (in order to get a session cookie
        search_form_request = urllib2.Request(urlparse.urljoin(self.base_url, search_form_url_end))
        search_form_response = urllib2.urlopen(search_form_request)
        
        cookie_jar.extract_cookies(search_form_response, search_form_request)

        
        # We are only doing this first search in order to get a cookie
        # The paging on the site doesn't work with cookies turned off.

        search_data1 = urllib.urlencode({"searchType":"ADV",
                                         "caseNo":"",
                                         "PPReference":"",
                                         "AltReference":"",
                                         "srchtype":"",
                                         "srchstatus":"",
                                         "srchdecision":"",
                                         "srchapstatus":"",
                                         "srchappealdecision":"",
                                         "srchwardcode":"",
                                         "srchparishcode":"",
                                         "srchagentdetails":"",
                                         "srchDateReceivedStart":"%(day)02d/%(month)02d/%(year)d" %{"day":day ,"month": month ,"year": year}, 
                                         "srchDateReceivedEnd":"%(day)02d/%(month)02d/%(year)d" %{"day":day, "month":month, "year":year} })

        if self.debug:
            print search_data1


        search_url = urlparse.urljoin(self.base_url, search_results_url_end)
        request1 = urllib2.Request(search_url, search_data1)
        cookie_jar.add_cookie_header(request1)
        response1 = urllib2.urlopen(request1)

        # This search is the one we will actually use.
        # a maximum of 100 results are returned on this site,
        # hence setting "pagesize" to 100. I doubt there will ever
        # be more than 100 in one day in PublicAccess...
        # "currentpage" = 1 gets us to the first page of results
        # (there will only be one anyway, as we are asking for 100 results...)

#http://planning.york.gov.uk/PublicAccess/tdc/DcApplication/application_searchresults.aspx?szSearchDescription=Applications%20received%20between%2022/02/2007%20and%2022/02/2007&searchType=ADV&bccaseno=&currentpage=2&pagesize=10&module=P3

        search_data2 = urllib.urlencode((("szSearchDescription","Applications received between %(day)02d/%(month)02d/%(year)d and %(day)02d/%(month)02d/%(year)d"%{"day":day ,"month": month ,"year": year}), ("searchType","ADV"), ("bccaseno",""), ("currentpage","1"), ("pagesize","100"), ("module","P3")))

        if self.debug:
            print search_data2

        # This time we want to do a get request, so add the search data into the url
        request2_url = urlparse.urljoin(self.base_url, search_results_url_end + "?" + search_data2)

        request2 = urllib2.Request(request2_url)

        # add the cookie we stored from our first search
        cookie_jar.add_cookie_header(request2)

        response2 = urllib2.urlopen(request2)

        contents = fixNewlines(response2.read())

        if self.debug:
            print contents

        soup = BeautifulSoup.BeautifulSoup(contents)

        results_table = soup.find("table", {"class": "cResultsForm"})

        # First, we work out what column each thing of interest is in from the headings
        headings = [x.string for x in results_table.findAll("th")]

        ref_col = index_or_none(headings, "Application Ref.") or \
            index_or_none(headings, "Case Number") or \
            index_or_none(headings, "Application Number")

        address_col = headings.index("Address")
        description_col = headings.index("Proposal")

        comments_url = urlparse.urljoin(self.base_url, comments_url_end)


        for tr in results_table.findAll("tr")[1:]:
            application = PlanningApplication()

            application.date_received = search_date

            tds = tr.findAll(re.compile("t[dh]"))

            application.council_reference = tds[ref_col].string.strip()
            application.address = tds[address_col].string.strip()
            application.description = tds[description_col].string.strip()

            application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])

            # We need the query string from this url to make the comments_url
            query_string = urlparse.urlsplit(application.info_url)[3]

            # This is probably slightly naughty, but I'm just going to add the querystring
            # on to the end manually
            application.comment_url = "%s?%s" %(comments_url, query_string)

            self._results.addApplication(application)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    day = 20
    month = 12
    year = 2008

    #parser = PublicAccessParser("East Northants", "East Northants", "http://publicaccesssrv.east-northamptonshire.gov.uk/PublicAccess/tdc/", True)
    #parser = PublicAccessParser("Cherwell District Council", "Cherwell", "http://cherweb.cherwell-dc.gov.uk/publicaccess/tdc/", False)
    #parser = PublicAccessParser("Hambleton District Council", "Hambleton", "http://planning.hambleton.gov.uk/publicaccess/tdc/", True)
    #parser = PublicAccessParser("Durham City Council", "Durham", "http://publicaccess.durhamcity.gov.uk/publicaccess/tdc/", True)
    #parser = PublicAccessParser("Moray Council", "Moray", "http://public.moray.gov.uk/publicaccess/tdc/", True)
#    parser = PublicAccessParser("Sheffield City Council", "Sheffield", "http://planning.sheffield.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("London Borough of Barking and Dagenham", "Barking and Dagenham", "http://paweb.barking-dagenham.gov.uk/PublicAccess/tdc/")
#    parser = PublicAccessParser("Reading Borough Council", "Reading", "http://planning.reading.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("Lancaster City Council", "Lancaster", "http://planapps.lancaster.gov.uk/PublicAccess/tdc/")
#    parser = PublicAccessParser("Harrogate Borough Council", "Harrogate", "http://publicaccess.harrogate.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("West Lancashire District Council", "West Lancashire", "http://publicaccess.westlancsdc.gov.uk/PublicAccess/tdc/")
#    parser = PublicAccessParser("Torbay Council", "Torbay", "http://www.torbay.gov.uk/publicaccess/tdc/")
    parser = PublicAccessParser("Hambleton District Council", "Hambleton", "http://planning.hambleton.gov.uk/publicaccess/tdc/")
    print parser.getResults(day, month, year)
    
