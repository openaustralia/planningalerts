import urllib2
import urllib
import urlparse

import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d%%2F%m%%2F%Y"

class MendipParser:
    def __init__(self, *args):
        self.authority_name = "Mendip District Council"
        self.authority_short_name = "Mendip"

        # The site itelf uses a search by validated date, but received date seems
        # to be there too, and to work...
        # self.base_url = "http://www.mendip.gov.uk/PODS/ApplicationSearchResults.asp?DateRecvFrom=&DateRecvTo=&DateValidFrom=%(date)s&DateValidTo=%(date)s&Search=Search"
        self.base_url = "http://www.mendip.gov.uk/PODS/ApplicationSearchResults.asp?DateRecvFrom=%(date)s&DateRecvTo=%(date)s&Search=Search"
        self.comment_url = "http://www.mendip.gov.uk/ShowForm.asp?fm_fid=107&AppNo=%(reference)s&SiteAddress=%(address)s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        search_url = self.base_url %{"date": search_date.strftime(date_format)}

        while search_url:
            response = urllib2.urlopen(search_url)
            soup = BeautifulSoup(response.read())

            if soup.find(text="No applications matched the search criteria"):
                break

            for tr in soup.find("table", summary="Application Results").tbody.findAll("tr"):
                application = PlanningApplication()
                application.date_received = search_date

                tds = tr.findAll("td")

                application.council_reference = tds[0].a.string.strip()
                application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
                application.description = tds[1].p.string.strip()
                application.address = tds[2].p.string.strip()

                application.comment_url = self.comment_url %{
                    "reference": application.council_reference,
                    "address": urllib.quote_plus(application.address),
                    }

                self._results.addApplication(application)

                next_link = soup.find("a", title="Go to the next page")
                search_url = urlparse.urljoin(self.base_url, next_link['href']) if next_link else None

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = MendipParser()
    print parser.getResults(1,10,2008)

