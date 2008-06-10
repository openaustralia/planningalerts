"""
This is the screenscraper for planning apps for 
Barnsley Metropolitan Borough Council.

The apps for Barnsley are displayed in html pages one per week, starting on
monday. There is no date_received, so we'll have to use the date of the 
start of this week.

There is no comment url, so we'll use the email address.

Developmentcontrol@barnsley.gov.uk

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

class BarnsleyParser:
    comments_email_address = "Developmentcontrol@barnsley.gov.uk"

    def __init__(self, *args):

        self.authority_name = "Barnsley Metropolitan Borough Council"
        self.authority_short_name = "Barnsley"
        self.base_url = "http://applications.barnsley.gov.uk/service/development/week_compact.asp?AppDate=%s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # What we actually need is the monday before the date searched for:
        monday_before = search_day - datetime.timedelta(search_day.weekday())

        # Now get the search page
        response = urllib2.urlopen(self.base_url %(monday_before.strftime(date_format)))
        soup = BeautifulSoup(response.read())

        result_tables = soup.findAll("table", align="Center", cellpadding="3")

        for table in result_tables:
            application = PlanningApplication()

            # We can set the date received and the comment url straight away.
            application.comment_url = self.comments_email_address

            trs = table.findAll("tr")

            application.council_reference = trs[0].a.string.strip()
            relative_info_url = trs[0].a['href']

            application.info_url = urlparse.urljoin(self.base_url, relative_info_url)

            application.date_received = monday_before

            application.address = trs[1].findAll("td")[1].string.strip()
            application.postcode = getPostcodeFromText(application.address)
            application.description = trs[2].findAll("td")[1].string.strip()

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = BarnsleyParser()
    print parser.getResults(21,5,2008)

