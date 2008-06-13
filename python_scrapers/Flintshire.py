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

class FlintshireParser:
    def __init__(self, *args):

        self.authority_name = "Flintshire County Council"
        self.authority_short_name = "Flintshire"

        # I've removed some extra variables from this, it seems to be happy without them, and now doesn't need to paginate...
        self.base_url = "http://www.flintshire.gov.uk/webcont/fssplaps.nsf/vwa_Search?searchview&Query=(%%5BfrmDteAppldate%%5D%%20%%3E=%%20%(start_date)s%%20AND%%20%%5BfrmDteAppldate%%5D%%20%%3C=%%20%(end_date)s)"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        # We'll set the start date to be one day earlier in order to catch the first result on every day at some point - see TODO list
        response = urllib2.urlopen(self.base_url %{"end_date": search_date.strftime(date_format),
                                                   "start_date": (search_date - datetime.timedelta(1)).strftime(date_format)})
        soup = BeautifulSoup(response.read())

        # Each app is stored in it's own table
        result_tables = soup.findAll("table", border="1")

        # For the moment, we'll have to ignore the first result (see TODO list).
        for table in result_tables[1:]:
            application = PlanningApplication()

            # It's not clear to me why this next one isn't the string of the next sibling. This works though!
            application.council_reference = table.find(text=re.compile("Reference")).parent.findNextSibling().contents[0]

            application.address = table.find(text="Location").parent.findNextSibling().string.strip()
            application.postcode = getPostcodeFromText(application.address)

            application.info_url = urlparse.urljoin(self.base_url, table.a['href'])

            # Let's go to the info_page and get the OSGB and the date_received
            info_request = urllib2.Request(application.info_url)

            # We need to add the language header in order to get UK style dates
            info_request.add_header("Accept-Language", "en-gb,en")
            info_response = urllib2.urlopen(info_request)
            info_soup = BeautifulSoup(info_response.read())
            
            grid_reference_td = info_soup.find(text="Grid Reference").findNext("td")
            x_element = grid_reference_td.font
            
            application.osgb_x = x_element.string.strip()
            application.osgb_y = x_element.nextSibling.nextSibling.string.strip()
            
            date_string = info_soup.find(text="Date Valid").findNext("td").string.strip()

            application.date_received = datetime.datetime(*(time.strptime(date_string, date_format)[0:6]))

            application.description = table.find(text=re.compile("Description of Proposal")).parent.nextSibling.string.strip()


            # There is a link to comment from the info page, though I can't click it.
            application.comment_url = application.info_url

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = FlintshireParser()
    print parser.getResults(22,5,2008)

# TODO

# 1) Email the council about broken first result.
# This is always
# slightly broken (two </td>s for one of the <td>s and upsets beautiful
# soup.
