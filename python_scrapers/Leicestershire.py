import urllib2
import urllib
import urlparse

import datetime
import re

import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

search_date_format = "%d%%2F%m%%2F%Y"

class LeicestershireParser:
    def __init__(self, *args):

        self.authority_name = "Leicestershire County Council"
        self.authority_short_name = "Leicestershire"
        self.base_url = "http://www.leics.gov.uk/index/environment/community_services_planning/planning_applications/index/environment/community_services_planning/planning_applications/eplanning_searchform/eplanning_resultpage.htm?sd=%(date)s&ed=%(date)s&kw=&map=f"
 
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        response = urllib2.urlopen(self.base_url %{"date": search_date.strftime(search_date_format)})
        soup = BeautifulSoup.BeautifulSoup(response.read())

        if not soup.find(text=re.compile("No Results Found")):
            
            trs = soup.findAll("table", {"class": "dataTable"})[1].findAll("tr")[1:]

            for tr in trs:
                tds = tr.findAll("td")

                application = PlanningApplication()

                # We can fill in the date received without actually looking at the data
                application.date_received = search_date

                application.council_reference = tds[0].a.string.strip()
                application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
                application.address = ', '.join([x for x in tds[1].contents 
                                                 if isinstance(x, BeautifulSoup.NavigableString)])
                application.postcode = getPostcodeFromText(application.address)
                application.description = tds[2].string.strip()

                # To get the comment link we need to fetch the info page

                info_response = urllib2.urlopen(application.info_url)
                info_soup = BeautifulSoup.BeautifulSoup(info_response.read())

                base = info_soup.base['href']

                application.comment_url = urlparse.urljoin(base,
                                                           info_soup.find("a", target="Planning Application Consultation Form")['href'])

                self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = LeicestershireParser()
    print parser.getResults(1,9,2008)


# TODO

# I suppose we should think about pagination at some point, 
# though I've not managed to find a day with more than 1 app yet...
