import urllib2
import urllib
import urlparse

import datetime

import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d%%2F%m%%2F%Y"

class CalderdaleParser:
    def __init__(self, *args):
        self.authority_name = "Calderdale Council"
        self.authority_short_name = "Calderdale"
        self.base_url = "http://www.calderdale.gov.uk/environment/planning/search-applications/planapps.jsp?status=0&date1=%(date)s&date2=%(date)s&Search=Search"
        self.info_url = "http://www.calderdale.gov.uk/environment/planning/search-applications/planapps.jsp?app=%s&Search=Search"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        next_page_url = self.base_url %{"date": search_date.strftime(date_format)}

        while next_page_url:
            try:
                response = urllib2.urlopen(next_page_url)
            except urllib2.HTTPError:
                # This is what seems to happen if there are no apps
                break

            soup = BeautifulSoup(response.read())

            next = soup.find(text="Next")
            if next:
                next_page_url = urlparse.urljoin(self.base_url, next.parent['href'])
            else:
                next_page_url = None

            # There is an <h3> for each app that we can use 
            for h3 in soup.findAll("h3", {"class": "resultsnavbar"}):
                application = PlanningApplication()

                application.date_received = search_date
                application.council_reference = h3.string.split(": ")[1]
                application.description = h3.findNext("div").find(text="Proposal:").parent.nextSibling.strip()

                application.address = ', '.join(h3.findNext("div").find(text="Address of proposal:").parent.nextSibling.strip().split("\r"))
                application.postcode = getPostcodeFromText(application.address)

                application.comment_url = urlparse.urljoin(self.base_url, h3.findNext("div").find(text=re.compile("Comment on Application")).parent['href'])

                application.info_url = self.info_url %(urllib.quote(application.council_reference))

                application.osgb_x, application.osgb_y = h3.findNext("div").find(text="Grid Reference:").parent.nextSibling.strip().split()

                self._results.addApplication(application)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


if __name__ == '__main__':
    parser = CalderdaleParser()
    print parser.getResults(1,10,2008)

# TODO

# 1) Find a better way to deal with the no apps situation.
