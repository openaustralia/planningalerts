"""
This is the scraper for Hampshire.

There appears to be no way to search by date received, so what we'll do is
go to the currently open for consultation page and just use that.

I don't think we need to worry about pagination, as there are hardly any.

"""

import urllib2
import urllib
import urlparse

import datetime, time
import cgi

import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class HampshireParser:
    def __init__(self, *args):

        self.authority_name = "Hampshire County Council"
        self.authority_short_name = "Hampshire"
        self.base_url = "http://www3.hants.gov.uk/planning/mineralsandwaste/planning-applications/applications/applications-open.htm"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        # Now get the search page
        response = urllib2.urlopen(self.base_url)
        soup = BeautifulSoup(response.read())

        trs = soup.table.table.findAll("tr", {"class": re.compile("(?:odd)|(?:even)")})


        for tr in trs:
            application = PlanningApplication()

            tds = tr.findAll("td")

            application.council_reference = tds[0].a.string.strip()
            application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
            application.address = tds[2].string.strip()
            application.postcode = getPostcodeFromText(application.address)
            application.description = tds[3].string.strip()

            # Fetch the info url in order to get the date received and the comment url

            info_response = urllib2.urlopen(application.info_url)

            info_soup = BeautifulSoup(info_response.read())

            application.date_received = datetime.datetime.strptime(info_soup.find(text=re.compile("\s*Received:\s*")).findNext("td").string.strip(), date_format).date()

            application.comment_url = urlparse.urljoin(self.base_url, info_soup.find("input", value="Comment on this application").parent['action'])


            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HampshireParser()
    print parser.getResults(21,5,2008)

