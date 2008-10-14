
import urllib2
import urllib
import urlparse

import datetime
import cgi
import re

comment_re = re.compile("Submit Comment")
mapref_re = re.compile("Map Ref")

import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

class AberdeenshireParser:
    def __init__(self, *args):

        self.authority_name = "Aberdeenshire Council"
        self.authority_short_name = "Aberdeenshire"
        self.base_url = "http://www.aberdeenshire.gov.uk/planning/apps/search.asp?startDateSearch=%(day)s%%2F%(month)s%%2F%(year)s&endDateSearch=%(day)s%%2F%(month)s%%2F%(year)s&Submit=Search"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        next = self.base_url %{"day": day,
                               "month": month,
                               "year": year,
                               }

        while next:
            
            # Now get the search page
            response = urllib2.urlopen(next)

            soup = BeautifulSoup.BeautifulSoup(response.read())

            trs = soup.table.findAll("tr")[1:] # First one is just headers

            for tr in trs:
                application = PlanningApplication()

                application.date_received = search_day
                application.council_reference = tr.a.string
                application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])
                tds = tr.findAll("td")

                application.address = ' '.join([x.replace("&nbsp;", " ").strip() for x in tds[2].contents if type(x) == BeautifulSoup.NavigableString and x.strip()])
                application.postcode = getPostcodeFromText(application.address)
                application.description = tds[4].string.replace("&nbsp;", " ").strip()

                # Get the info page in order to find the comment url
                # we could do this without a download if it wasn't for the
                # sector parameter - I wonder what that is?
                info_response = urllib2.urlopen(application.info_url)
                info_soup = BeautifulSoup.BeautifulSoup(info_response.read())

                comment_navstring = info_soup.find(text=comment_re)
                
                if comment_navstring:
                    application.comment_url = urlparse.urljoin(self.base_url, info_soup.find(text=comment_re).parent['href'])
                else:
                    application.comment_url = "No Comments"

                # While we're at it, let's get the OSGB
                application.osgb_x, application.osgb_y = [x.strip() for x in info_soup.find(text=mapref_re).findNext("a").string.strip().split(",")]

                self._results.addApplication(application)
                
            next_element = soup.find(text="next").parent

            if next_element.name == 'a':
                next = urlparse.urljoin(self.base_url, next_element['href'])
            else:
                next = None

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = AberdeenshireParser()
    print parser.getResults(7,8,2008)

