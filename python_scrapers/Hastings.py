"""
This is the scraper for Hastings.
"""

import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class HastingsParser:
    def __init__(self, *args):

        self.authority_name = "Hastings Borough Council"
        self.authority_short_name = "Hastings"
#        self.base_url = "http://www.hastings.gov.uk/planning/view_applications.aspx"
        self.base_url = "http://www.hastings.gov.uk/planning/SearchResults.aspx"

        # Due to the idiotic design of the Hastings site, we can't give a proper info url.
        # There is a sensible URL, but it only works with a referer.
        self.info_url = "http://www.hastings.gov.uk/planning/view_applications.aspx"

        self.comment_url_template = "http://www.hastings.gov.uk/planning/planningapp_comments.aspx?appNumber=%s&syskey=%s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        post_data = urllib.urlencode((
                ("type", "app"),
                ("time", "0"),
                ))
                                     
        # Now get the search page
        response = urllib2.urlopen(self.base_url, post_data)
        soup = BeautifulSoup(response.read())

        caseno_strings = soup.findAll(text="Case No:")

        for caseno_string in caseno_strings:
            application = PlanningApplication()

            application.council_reference = caseno_string.findNext("a").string.strip()
            info_url = urlparse.urljoin(self.base_url, caseno_string.findNext("a")['href'])

            # See above for why we can't use the proper info url.
            application.info_url = self.info_url

            # In order to avoid doing a download to find the comment page, we'll
            # get the system key from this url

            syskey = cgi.parse_qs(urlparse.urlsplit(info_url)[3])['id'][0]

            application.date_received = datetime.datetime.strptime(caseno_string.findNext(text="Registration Date:").findNext("p").string.strip(), date_format).date()

            application.address = caseno_string.findNext(text="Location:").findNext("p").string.strip()
            application.postcode = getPostcodeFromText(application.address)

            application.description = caseno_string.findNext(text="Proposal:").findNext("p").string.strip()

#http://www.hastings.gov.uk/planning/planningapp_comments.aspx?appNumber=HS/FA/08/00631&syskey=95642
            application.comment_url = self.comment_url_template %(application.council_reference, syskey)

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HastingsParser()
    print parser.getResults(12,6,2009)

