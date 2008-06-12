
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

class KensingtonParser:

    def __init__(self, *args):

        self.authority_name = "The Royal Borough of Kensington and Chelsea"
        self.authority_short_name = "Kensington and Chelsea"
        self.base_url = "http://www.rbkc.gov.uk/Planning/scripts/weeklyresults.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # We want the sunday of the week being searched for.
        # (sunday is at the end of the week).
        friday = search_day - datetime.timedelta(search_day.weekday()) + datetime.timedelta(4)

        # Not using urllib.urlencode as it insists on turning the "+" into "%2B"
        post_data = "WeekEndDate=%d%%2F%d%%2F%d&order=Received+Date&submit=search" %(friday.day, friday.month, friday.year)


        # Now get the search page
        response = urllib2.urlopen(self.base_url, post_data)
        soup = BeautifulSoup(response.read())

        trs = soup.find("table", summary="Planning Application search results table").findAll("tr")[1:]

        for tr in trs:
            application = PlanningApplication()

            tds = tr.findAll("td")

            # Not sure why these are entities. We'll convert them back.
            application.council_reference = tds[0].a.contents[1].strip().replace("&#47;", "/")
            application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
            application.comment_url = application.info_url

            application.date_received = datetime.datetime(*(time.strptime(tds[1].string.strip(), date_format)[0:6]))

            application.address = tds[2].string.strip()
            application.postcode = getPostcodeFromText(application.address)

            application.description = tds[3].string.strip()

            self._results.addApplication(application)
        
        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = KensingtonParser()
    print parser.getResults(11,6,2008)

