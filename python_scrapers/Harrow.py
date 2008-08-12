
import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

import re

location_re = re.compile("Location:")
date_received_re = re.compile("Date first received:")

date_format = "%d %b %Y"

class HarrowParser:
    def __init__(self, *args):

        self.authority_name = "London Borough of Harrow"
        self.authority_short_name = "Harrow"

        # This is a link to the last seven days applications
        # The day, month, and year arguments will be ignored.
        self.base_url = "http://www.harrow.gov.uk/www4/planning/dcweek1.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        # Now get the search page
        response = urllib2.urlopen(self.base_url)

        soup = BeautifulSoup(response.read())

        # Each application contains the nav string "Application: "
        nav_strings = soup.findAll(text="Application: ")

        for nav_string in nav_strings:
            application = PlanningApplication()

            application.council_reference = nav_string.findPrevious("tr").findAll("td", limit=2)[1].string.strip()

            application.address = nav_string.findNext(text=location_re).split(":")[1].strip()
            application.postcode = getPostcodeFromText(application.address)

            application.description = nav_string.findNext(text="Proposal: ").findNext("td").string.strip()

            application.comment_url = urlparse.urljoin(self.base_url, nav_string.findNext(text="Proposal: ").findNext("a")['href'])

            application.date_received = datetime.datetime.strptime(nav_string.findNext(text=date_received_re).split(": ")[1], date_format).date()

            # FIXME: There is no appropriate info_url for the Harrow apps. 
            # I'll put the base url for the moment, but as that is
            # a list of apps from the last 7 days that will quickly be out of date.

            application.info_url = self.base_url
            
            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HarrowParser()
    print parser.getResults(21,5,2008)

