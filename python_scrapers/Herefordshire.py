
import urllib2
import urllib
import urlparse

import datetime, time
import cgi
import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class HerefordshireParser:
    comments_email_address = "Developmentcontrol@barnsley.gov.uk"

    def __init__(self, *args):

        self.authority_name = "Herefordshire Council"
        self.authority_short_name = "Herefordshire"
        self.base_url = "http://www.herefordshire.gov.uk/gis/planListResults.aspx?pc=&address=&querytype=current&startdate=%(date)s&enddate=%(date)s&startrecord=0"
        #As we are going to the info page, we may as well pick up the comment url from there.
#        self.comment_url = "http://www.herefordshire.gov.uk/gis/planDetailCommentAddress.aspx?ApplicationId=%s" # This need the reference inserting

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        post_data = urllib.urlencode(
            (("show", "0"),
             ("Go", "GO"),
             )
            )

        # Now get the search page
        response = urllib2.urlopen(self.base_url %{"date": search_day.strftime(date_format)})

        soup = BeautifulSoup(response.read())

        if not soup.find(text=re.compile("Sorry, no matches found")):
            # There were apps for this date

            trs = soup.find("table", {"class": "gis_table"}).findAll("tr")[2:]

            for tr in trs:
                application = PlanningApplication()
                application.date_received = search_day

                application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])
                application.council_reference = tr.a.string
    #            application.comment_url = self.comment_url %(application.council_reference)

                tds = tr.findAll("td")

                application.address = tds[1].string
                application.postcode = getPostcodeFromText(application.address)

                # This just gets us an initial segment of the description.
                # We are going to have to download the info page...
                #application.description = tds[2].string.strip()

                info_response = urllib.urlopen(application.info_url)

                info_soup = BeautifulSoup(info_response.read())

                application.description = info_soup.find(text="Proposal:").findNext("td").string.strip()
                application.comment_url = urlparse.urljoin(self.base_url, info_soup.find("a", title="Link to Planning Application Comment page")['href'])

                self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HerefordshireParser()
    print parser.getResults(31,8,2008)

