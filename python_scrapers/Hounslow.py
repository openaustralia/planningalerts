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

class HounslowParser:
    def __init__(self, *args):

        self.authority_name = "London Borough of Hounslow"
        self.authority_short_name = "Hounslow"
        self.base_url = "http://planning.hounslow.gov.uk/planningv2/planning_summary.aspx?strWeekListType=SRCH&strRecTo=%(date)s&strRecFrom=%(date)s&strWard=ALL&strAppTyp=ALL&strWardTxt=All%%20Wards&strAppTypTxt=All%%20Application%%20Types&strArea=ALL&strAreaTxt=All%%20Areas&strStreet=ALL&strStreetTxt=All%%20Streets&strPC=&strLimit=500"
        # Limited to 500 cases - putting 1000 causes a default value of 50 to be used. 500 should be plenty.

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # Now get the search page
        response = urllib2.urlopen(self.base_url %{"date": search_day.strftime(date_format)})
        soup = BeautifulSoup(response.read())

        # Results are shown in a table each. The tables don't have any nice
        # attributes, but they do all contain a NavString "Application",
        # and nothing else does...
        nav_strings = soup.findAll(text="Application")

        for nav_string in nav_strings:
            result_table = nav_string.findPrevious("table")

            application = PlanningApplication()
            application.date_received = search_day

            links = result_table.findAll("a")

            # We can get OSGB coordinates from the link to streetmap
            map_qs_dict = cgi.parse_qs(urlparse.urlsplit(links[0]['href'])[3])
            
            application.osgb_x = map_qs_dict.get("x")[0]
            application.osgb_y = map_qs_dict.get("y")[0]

            application.council_reference = links[1].string.strip()
            application.info_url = urlparse.urljoin(self.base_url, links[1]['href'])
            application.comment_url = urlparse.urljoin(self.base_url, links[2]['href'])

            application.address = ' '.join(links[0].previous.strip().split())
            application.postcode = getPostcodeFromText(application.address)

            application.description = links[2].previous.strip()

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HounslowParser()
    print parser.getResults(1,8,2008)

