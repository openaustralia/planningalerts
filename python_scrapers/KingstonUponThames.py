
import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%b/%Y"

class KingstonParser:
    comments_email_address = "dc@rbk.kingston.gov.uk"

    def __init__(self, *args):
        self.authority_name = "Royal Borough of Kingston upon Thames"
        self.authority_short_name = "Kingston upon Thames"
        self.base_url = "http://maps.kingston.gov.uk/isis_main/planning/planning_summary.aspx?strWeekListType=SRCH&strRecTo=%(date)s&strRecFrom=%(date)s&strWard=ALL&strAppTyp=ALL&strWardTxt=All%%20Wards&strAppTypTxt=All%%20Application%%20Types&strStreets=ALL&strStreetsTxt=All%%20Streets&strLimit=500"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # Now get the search page
        response = urllib2.urlopen(self.base_url %{"date": search_day.strftime(date_format)})
        soup = BeautifulSoup(response.read())

        # Each app is stored in a table on it's own. 
        # These tables don't have any nice distinguishing features,
        # but they do all contain a NavigableString "Application",
        # and nothing else in the page does.
        nav_strings = soup.findAll(text="Application")
        
        for nav_string in nav_strings:
            results_table = nav_string.findPrevious("table")

            application = PlanningApplication()
            application.date_received = search_day

            application.council_reference = results_table.a.string.strip()
            application.info_url = urlparse.urljoin(self.base_url, results_table.a['href'])
            application.address = results_table.findAll("td")[7].a.string.strip()

            application.postcode = getPostcodeFromText(application.address)
            application.description = results_table.findAll("td")[-1].contents[0].strip()

            # A few applications have comment urls, but most don't.
            # When they do, they have a case officer - I don't think we can
            # work out the other urls - even if they exist.
            # Best to use the email address.
            application.comment_url = self.comments_email_address

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = KingstonParser()
    print parser.getResults(2,8,2008)

