"""
The Weymouth and Portland site has a page with the last 28 days of apps on it,
so we'll use that.

The info and comment pages can only be accessed by POSTs, so we'll have
to give the search page, which is the best we can do.
"""

import urllib2

import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText


date_format = "%d %B %Y"

class WeymouthParser:
    def __init__(self, *args):

        self.authority_name = "Weymouth and Portland Borough Council"
        self.authority_short_name = "Weymouth and Portland"
        self.base_url = "http://www.weymouth.gov.uk/Planning/applications/newapps.asp"
        self.search_url = "http://www.weymouth.gov.uk/planning/applications/planregister.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        response = urllib2.urlopen(self.base_url)
        soup = BeautifulSoup(response.read())
        
        for details_input in soup.find("table", summary="Planning Applications Received in the last 7 days").findAll("input", alt="Planning Details"):
            application = PlanningApplication()

            first_tr = details_input.findPrevious("tr")

            other_trs = first_tr.findNextSiblings("tr", limit=8)

            application.council_reference = first_tr.find("input", {"name": "refval"})['value']
            application.address = other_trs[0].findAll("td")[1].string.strip()
            application.description = other_trs[1].findAll("td")[1].string.strip()
            application.date_received = datetime.datetime.strptime(other_trs[3].findAll("td")[1].string.strip(), date_format).date()

            # Both the info page and the comment page can only be got to
            # by a POST. The best we can do is give the url of the search page
            application.info_url = application.comment_url = self.search_url

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = WeymouthParser()
    print parser.getResults(1,8,2008)

