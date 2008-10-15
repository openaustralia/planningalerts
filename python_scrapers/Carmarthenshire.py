import urllib2
import urllib
import urlparse

import datetime
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

class CarmarthenshireParser:
    def __init__(self, *args):
        self.comments_email_address = "planning@carmarthenshire.gov.uk"

        self.authority_name = "Carmarthenshire County Council"
        self.authority_short_name = "Carmarthenshire"
        self.base_url = "http://www.carmarthenshire.gov.uk/CCC_APPS/eng/plannaps/CCC_PlanningApplicationsResults.asp?datemode=range&in_lo_date=%(day)s%%2F%(month)s%%2F%(year)s&in_hi_date=%(day)s%%2F%(month)s%%2F%(year)s&SUBMIT=Search"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # Now get the search page
        response = urllib2.urlopen(self.base_url %{"day": day,
                                                   "month": month,
                                                   "year": year,
                                                   })
        soup = BeautifulSoup(response.read())

        trs = soup.findAll("tr", valign="middle")

        count = 0
        for tr in trs:
            # The odd trs are just spacers
            if count % 2 == 0:
                application = PlanningApplication()

                tds = tr.findAll("td")
                
                application.date_received = search_day
                application.council_reference = tds[1].a.string
                application.address = tds[3].a.string
                application.postcode = getPostcodeFromText(application.address)
                
                # All the links in this <tr> go to the same place...
                application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])

                # Still looking for description and comment url
                
                # For the description, we'll need the info page
                info_soup = BeautifulSoup(urllib2.urlopen(application.info_url).read())

                application.description = info_soup.find(text="Description").findNext("td").findNext("td").font.string

                # While we're here, lets get the OSGB grid ref
                application.osgb_x, application.osgb_y = info_soup.find(text="Grid Reference").findNext("td").font.string.split("-")

                # We'll have to use an email address for comments
                application.comment_url = self.comments_email_address

                self._results.addApplication(application)

            count += 1

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = CarmarthenshireParser()
    print parser.getResults(8,8,2008)

