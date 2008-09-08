import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

search_date_format = "%d+%b+%Y"
received_date_format = "%d %b %Y"

class ExmoorParser:
    def __init__(self, *args):

        self.authority_name = "Exmoor National Park"
        self.authority_short_name = "Exmoor"
        self.base_url = "http://www.exmoor-nationalpark.gov.uk/planning_weekly_list.htm?weeklylist=%s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        response = urllib2.urlopen(self.base_url %(search_day.strftime(search_date_format)))
        soup = BeautifulSoup(response.read())

        # The first <tr> contains headers
        trs = soup.table.findAll("tr")[1:]

        for tr in trs:
            application = PlanningApplication()

            tds = tr.findAll("td")

            application.date_received = datetime.datetime.strptime(tds[0].string, received_date_format).date()

            application.info_url = urllib.unquote(urllib.quote_plus(urlparse.urljoin(self.base_url, tds[1].a['href'])))
            application.council_reference = tds[1].a.string.strip()
            application.address = tds[2].a.string.strip()
            application.postcode = getPostcodeFromText(application.address)

            # Now fetch the info url

            info_response = urllib.urlopen(application.info_url)
            info_soup = BeautifulSoup(info_response.read())

            application.description = info_soup.find(text="Proposal:").findNext("td").string.strip()

            try:
                application.comment_url = urlparse.urljoin(self.base_url, info_soup.find(text="Comment").parent['href'])
            except:
                application.comment_url = "No Comments"

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = ExmoorParser()
    print parser.getResults(1,8,2008)

