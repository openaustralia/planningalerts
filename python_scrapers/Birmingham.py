
import urllib2
import urllib
import urlparse

import datetime, time
import cgi
import re

from BeautifulSoup import BeautifulSoup

import cookielib
cookie_jar = cookielib.CookieJar()

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class BirminghamParser:
    comments_email_address = "planning.enquiries@birmingham.gov.uk"

    def __init__(self, *args):

        self.authority_name = "Birmingham City Council"
        self.authority_short_name = "Birmingham"

        self.get_url = "http://www.birmingham.gov.uk/GenerateContent?CONTENT_ITEM_ID=67548&CONTENT_ITEM_TYPE=0&MENU_ID=12189"
        # What a lovely intuitive URL it is.
        self.for_cookie_url = "http://www.birmingham.gov.uk/PSR/control/main"
        self.post_url = "http://www.birmingham.gov.uk/PSR/control/searchresults"
        

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # We seem to need to get this page in order to get a cookie
        for_cookie_request = urllib2.Request(self.for_cookie_url)
        for_cookie_response = urllib2.urlopen(for_cookie_request)
        cookie_jar.extract_cookies(for_cookie_response, for_cookie_request)

        post_data = [
            ("JAVASCRIPT_ENABLED", "FALSE"),
            ("txt_PSR_CurrentSearchPage", "0"),
            ("PSR_CURRENT_FORM", "psr_Application_PSRSearch_Application_Form"),
            ("txt_PSR_Application_ApplicationNumber", ""),
            ("txt_PSR_Application_Status", "awaitingDecision"),
            ("txt_PSR_Application_TypeOfApplication", ""),
            ("txt_PSR_Application_DecisionType", ""),
            ("txt_PSR_Application_District", ""),
            ("txt_PSR_Application_Ward", ""),
            ("txt_PSR_Application_Location", ""),
            ("txt_PSR_Application_Applicant", ""),
            ("txt_PSR_Application_Agent", ""),
            ("txt_PSR_Application_SearchDay", day),
            ("txt_PSR_Application_SearchMonth", month-1), # Months are counted from zero...
            ("txt_PSR_Application_SearchYear", year),
            ("txt_PSR_Application_SearchToDay", day),
            ("txt_PSR_Application_SearchToMonth", month-1), # Months are counted from zero...
            ("txt_PSR_Application_SearchToYear", year),
            ("txt_PSR_Application_SearchSortOrder", "LatestFirst"),
            ("txt_PSR_Application_ResultsSkipRows", "0"),
            ("txt_PSR_Application_ResultsPerPage", "1000"), # That should be enough to keep things on one page
            ("btn_PSR_Application_ApplicationSearch", "Search"),
            ("PSR_CURRENT_FORM", "psr_Application_PSRSearch_Appeals_Form"),
            ("txt_PSR_Appeals_ApplicationNumber", ""),
            ("txt_PSR_Appeals_Status", "awaitingDecision"),
            ("txt_PSR_Appeals_TypeOfAppeal", ""),
            ("txt_PSR_Appeals_DecisionType", ""),
            ("txt_PSR_Appeals_District", ""),
            ("txt_PSR_Appeals_Ward", ""),
            ("txt_PSR_Appeals_Location", ""),
            ("txt_PSR_Appeals_Applicant", ""),
            ("txt_PSR_Appeals_Agent", ""),
            ("txt_PSR_Appeals_SearchDay", ""),
            ("txt_PSR_Appeals_SearchMonth", ""),
            ("txt_PSR_Appeals_SearchYear", ""),
            ("txt_PSR_Appeals_SearchToDay", ""),
            ("txt_PSR_Appeals_SearchToMonth", ""),
            ("txt_PSR_Appeals_SearchToYear", ""),
            ("txt_PSR_Appeals_SearchSortOrder", "LatestFirst"),
            ("txt_PSR_Appeals_ResultsSkipRows", "0"),
            ("txt_PSR_Appeals_ResultsPerPage", "10"),
            ]


        post_request = urllib2.Request(self.post_url, urllib.urlencode(post_data))
        cookie_jar.add_cookie_header(post_request)

        post_response = urllib2.urlopen(post_request)

        soup = BeautifulSoup(post_response.read())

        result_tables = soup.findAll("table", summary=re.compile("Summary of planning application"))

        for result_table in result_tables:
            application = PlanningApplication()
            application.info_url = urlparse.urljoin(self.post_url, result_table.find(text="Application number").findNext("a")['href'])
            application.council_reference = result_table.find(text="Application number").findNext("a").string
            application.date_received = search_day
            application.address = result_table.find(text="Location").findNext("td").p.string
            application.postcode = getPostcodeFromText(application.address)
            application.description = result_table.find(text="Proposal").findNext("td").p.string.replace("&nbsp;", " ").strip()
            
            # Comment link gives an Access Denied, so we'll have to use the email
            application.comment_url = self.comments_email_address

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = BirminghamParser()
    print parser.getResults(1,8,2008)

