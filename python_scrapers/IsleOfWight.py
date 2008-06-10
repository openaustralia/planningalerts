"""This is the planning application scraper for the Isle of Wight Council.

In order to avoid this taking far too long, we've had take a few short cuts.
In particular, we're not actually looking up the date each application is
received. Instead, we're just using the date we first scraped it."""

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

class IsleOfWightParser:
    def __init__(self, *args):

        self.authority_name = "Isle of Wight Council"
        self.authority_short_name = "Isle of Wight"
        self.base_url = "http://www.iwight.com/council/departments/planning/appsdip/PlanAppSearch.aspx?__EVENTTARGET=lnkShowAll"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self):
        # Note that we don't take the day, month and year parameters here.

        # First get the search page
        request = urllib2.Request(self.base_url)
        response = urllib2.urlopen(request)

        soup = BeautifulSoup(response.read())

        trs = soup.findAll("tr", {"class": "dbResults"})

        for tr in trs:
            application = PlanningApplication()

            tds = tr.findAll("td")

            application.council_reference = tds[0].a.contents[0].strip()
            application.address = tds[1].string.strip()
            application.postcode = getPostcodeFromText(application.address)

            application.description = tds[2].string.strip()
            application.info_url= urlparse.urljoin(self.base_url, tds[0].a['href'])

# These bits have been commented out for performance reasons. We can't afford to go to every application's details page ten times a day while it is open. Instead, we'll just set the date_received to be the scrape date. The comment url can be got by using the id in the info url
            application.date_received = datetime.datetime.today()
            
            relative_comment_url_template = "PlanAppComment.aspx?appId=%d"

            # Get the appId from the info_url

            app_id = int(cgi.parse_qs(urlparse.urlsplit(application.info_url)[3])['frmId'][0])

            application.comment_url = urlparse.urljoin(self.base_url, relative_comment_url_template %(app_id))


#             # I'm afraid we're going to have to get each info url...
#             this_app_response = urllib2.urlopen(application.info_url)
#             this_app_soup = BeautifulSoup(this_app_response.read())

#             # If there is no received date, for some reason. We'll use the publicicty date instead.
#             date_string = (this_app_soup.find("span", id="lblTrackRecievedDate") or this_app_soup.find("span", id="lblPubDate")).string
#             application.date_received = datetime.datetime(*(time.strptime(date_string, date_format)[0:6]))

#             application.comment_url = urlparse.urljoin(self.base_url, this_app_soup.find("a", id="lnkMakeComment")['href'])

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear().displayXML()

if __name__ == '__main__':
    parser = IsleOfWightParser()
    print parser.getResults(21,5,2008)

# http://www.iwight.com/council/departments/planning/appsdip/PlanAppSearch.aspx

# post data
#__EVENTTARGET=lnkShowAll&__EVENTARGUMENT=&__VIEWSTATE=dDwtMTE4MjcxOTIzNjt0PDtsPGk8Mz47PjtsPHQ8O2w8aTw4Pjs%2BO2w8dDxAMDw7Ozs7Ozs7Ozs7Pjs7Pjs%2BPjs%2BPjs%2BBr0XINUf7K2BOMRwqIJMmHvc6bY%3D&txtTCP=&txtPIN=&txtAddress=
