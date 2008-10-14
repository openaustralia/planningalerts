
import urllib2
import urllib
import urlparse

import datetime
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

search_date_format = "%d%m%y"
reg_date_format = "%d/%m/%y"

class BerwickParser:
    comments_email_address = "planning@berwick-upon-tweed.gov.uk"

    def __init__(self, *args):

        self.authority_name = "Berwick-upon-Tweed Borough Council"
        self.authority_short_name = "Berwick"
        self.base_url = "http://www.berwick-upon-tweed.gov.uk/planning/register/wl/%s.htm"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        monday_before = search_day - datetime.timedelta(search_day.weekday())

        thursday = monday_before + datetime.timedelta(3)
        if search_day.weekday() > 3: # i.e. It is friday, saturday, or sunday
            # We need to add a week
            thursday = thursday + datetime.timedelta(7)

        this_url = self.base_url %(thursday.strftime(search_date_format))
        # Now get the search page
        response = urllib2.urlopen(this_url)
        soup = BeautifulSoup(response.read())

        # Each app is stored in a table of its own. The tables don't have
        # any useful attributes, so we'll find all the NavigableString objects
        # which look like " Application Number:" and then look at the 
        #tables they are in.

        nav_strings = soup.findAll(text=" Application Number:")

        for nav_string in nav_strings:
            application = PlanningApplication()

            application.council_reference = nav_string.findNext("p").string.strip()

            result_table = nav_string.findPrevious("table")

            application.date_received = datetime.datetime.strptime(result_table.find(text=" Registration Date: ").findNext("p").contents[0].strip(), reg_date_format)

            application.osgb_x = result_table.find(text=" Easting:").findNext("p").string.strip()
            application.osgb_y = result_table.find(text=" Northing:").findNext("p").string.strip()

            application.description = result_table.find(text=" Proposed Development:").findNext("p").string.strip()
            application.address = result_table.find(text=" Location:").findNext("p").string.strip()
            application.postcode = getPostcodeFromText(application.address)

            application.info_url = this_url

            application.comment_url = self.comments_email_address

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = BerwickParser()
    print parser.getResults(21,5,2008)

