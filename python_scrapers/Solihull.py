"""
This is the screenscraper for planning apps for 
Solihull Metropolitan Borough Council.

The apps for Solihull are displayed in html pages one per week, starting on Monday. 
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

class SolihullParser:

    def __init__(self, *args):

        self.authority_name = "Solihull Metropolitan Borough Council"
        self.authority_short_name = "Solihull"
        self.base_url = "http://www.solihull.gov.uk/planning/dc/weeklist.asp?SD=%s&ward=ALL"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # What we actually need is the monday before the date searched for:
        monday_before = search_day - datetime.timedelta(search_day.weekday())

        # Now get the search page
        response = urllib2.urlopen(self.base_url %(monday_before.strftime(date_format)))
        soup = BeautifulSoup(response.read())

        result_tables = soup.findAll("table", width="98%", cellpadding="2")

        for table in result_tables:
            application = PlanningApplication()

            trs = table.findAll("tr")
	    application.council_reference = trs[0].strong.string.strip()
            relative_info_url = trs[0].a['href']
            application.info_url = urlparse.urljoin(self.base_url, relative_info_url)

            application.address = trs[1].findAll("td")[1].string.strip()
            application.postcode = getPostcodeFromText(application.address)
            application.description = trs[2].findAll("td")[1].string.strip()

	    #There's probably a prettier way to get the date, but with Python, it's easier for me to reinvent the wheel than to find an existing wheel!
	    raw_date_recv = trs[3].findAll("td")[3].string.strip().split("/")
	    #Check whether the application is on the target day. If not, discard it and move on.
	    if int(raw_date_recv[0]) != day:
	      continue
	    application.date_received = datetime.date(int(raw_date_recv[2]), int(raw_date_recv[1]), int(raw_date_recv[0]))

            try:
                relative_comment_url = trs[5].findAll("td")[1].a['href']
                application.comment_url = urlparse.urljoin(self.base_url, relative_comment_url)
            except:
                application.comment_url = "No Comment URL."

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = SolihullParser()
    #Put this in with constant numbers, copying the Barnsley example. Works for testing, but should it use the arguments for a real run?
    print parser.getResults(27,10,2008)
