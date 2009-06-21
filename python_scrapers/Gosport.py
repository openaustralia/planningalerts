import urllib2
import urllib
import urlparse

import datetime, time
import cgi

import re

import cookielib

cookie_jar = cookielib.CookieJar()


from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText


from HTTPHandlers import CookieAddingHTTPRedirectHandler

cookie_handling_opener = urllib2.build_opener(CookieAddingHTTPRedirectHandler(cookie_jar))


search_date_format = "%m/%d/%Y" #That's right, the search date is US style.
info_page_date_format = "%d/%m/%Y" # and the info page is UK style

class GosportParser:
    def __init__(self, *args):

        self.authority_name = "Gosport Borough Council"
        self.authority_short_name = "Gosport"

        self.base_url = "http://www.gosport.gov.uk/gbcplanning/ApplicationSearch2.aspx"
        self.info_url = "http://www.gosport.gov.uk/gbcplanning/ApplicationDetails.aspx?ID=%s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        get_request = urllib2.Request(self.base_url)
        get_response = urllib2.urlopen(get_request)
        cookie_jar.extract_cookies(get_response, get_request)
        
        get_soup = BeautifulSoup(get_response.read())

        post_data = (
            ("__VIEWSTATE", get_soup.find("input", {"name": "__VIEWSTATE"})["value"]),
            ("pgid", get_soup.find("input", {"name": "pgid"})["value"]),
            ("action", "Search"),
#            ("ApplicationSearch21%3AtbDevAddress", ""),
#            ("ApplicationSearch21%3AtbApplicantName", ""),
#            ("ApplicationSearch21%3AtbAgentName", ""),
            ("ApplicationSearch21:tbDateSubmitted", search_date.strftime(search_date_format)),
            ("ApplicationSearch21:btnDateSubmitted", "Search"),
#            ("ApplicationSearch21%3AtbDateDetermined", ""),
            )

        
        post_request = urllib2.Request(self.base_url, urllib.urlencode(post_data))
        cookie_jar.add_cookie_header(post_request)
        post_response = cookie_handling_opener.open(post_request)

        post_soup = BeautifulSoup(post_response.read())

        # Discard the first <tr>, which contains headers
        trs = post_soup.find("table", id="SearchResults1_dgSearchResults").findAll("tr")[1:]

        for tr in trs:
            application = PlanningApplication()
            
            tds = tr.findAll("td")

            application.council_reference = tds[0].string.strip()
            application.address = tds[1].string.strip()
            application.postcode = getPostcodeFromText(application.address)
            application.description = tds[2].string.strip()

            application.date_received = datetime.datetime(*(time.strptime(tds[3].string.strip(), info_page_date_format)[0:6]))
            application.info_url = self.info_url %(application.council_reference)

            # The comment url must be accessed by a POST, so we'll just use the info url for that as well

            application.comment_url = application.info_url

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = GosportParser()
    print parser.getResults(12,6,2009)

