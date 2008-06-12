import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%Y%m%d"

class ForestOfDeanParser:
    def __init__(self, *args):

        self.authority_name = "Forest of Dean District Council"
        self.authority_short_name = "Forest of Dean"
        self.base_url = "http://www.fdean.gov.uk/content.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        search_data = urllib.urlencode(
            [
                ("parent_directory_id", "200"),
                ("nav", "679"),
                ("id", "13266"),
                ("RecStart", "1"),
                ("RecCount", "100"),
                ("SDate", search_date.strftime(date_format)),
                ("EDate", search_date.strftime(date_format)),
                ]
            )

        search_url = self.base_url + "?" + search_data

        response = urllib2.urlopen(search_url)
        soup = BeautifulSoup(response.read())

        results_table = soup.find("table", summary="List of planning applications that match your query")

        for tr in results_table.findAll("tr")[1:]:
            application = PlanningApplication()
            
            application.date_received = search_date
            
            tds = tr.findAll("td")

            application.council_reference = tds[0].a.string.strip()
            application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
            application.comment_url = application.info_url

            application.address = ' '.join(tds[1].string.strip().split())
            application.postcode = getPostcodeFromText(application.address)

            application.description = tds[2].string.strip()

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = ForestOfDeanParser()
    print parser.getResults(21,5,2008)

# TODO - looks like it paginates at 20
