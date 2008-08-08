
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

class BrentParser:
    def __init__(self, *args):

        self.authority_name = "London Borough of Brent"
        self.authority_short_name = "Brent"
#        self.base_url = "http://www.brent.gov.uk/servlet/ep.ext?extId=101149&byPeriod=Y&st=PL&periodUnits=day&periodMultiples=14"
        self.base_url = "http://www.brent.gov.uk/servlet/ep.ext"

        self._current_application = None

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        post_data = [
            ("from", search_day.strftime(date_format)),
            ("until", search_day.strftime(date_format)),
            ("EXECUTEQUERY", "Query"),
#            ("auth", "402"),
            ("st", "PL"),
            ("periodUnits", "day"),
            ("periodMultiples", "14"),
            ("title", "Search+by+Application+Date"),
            ("instructions", "Enter+a+date+range+to+search+for+existing+applications+by+the+date+of+application.%0D%0A%3Cbr%3E%3Cbr%3E%0D%0A%3Cstrong%3ENote%3A%3C%2Fstrong%3E+Where+%27%28Applicant%27s+Description%29%27+appears+in+the+proposal%2C+the+text+may+subsequently+be+amended+when+the+application+is+checked."),
            ("byFormat", "N"),
            ("byOther1", "N"),
            ("byOther2", "N"),
            ("byOther3", "N"),
            ("byOther4", "N"),
            ("byOther5", "N"),
            ("byPostcode", "N"),
            ("byStreet", "N"),
            ("byHouseNumber", "N"),
            ("byAddress", "N"),
            ("byPeriod", "Y"),
            ("extId", "101149"), # I wonder what this is...
            ("queried", "Y"),
            ("other1Label", "Other1"),
            ("other2Label", "Other2"),
            ("other3Label", "Other3"),
            ("other4Label", "Other4"),
            ("other5Label", "Other5"),
            ("other1List", ""),
            ("other2List", ""),
            ("other3List", ""),
            ("other4List", ""),
            ("other5List", ""),
            ("periodLabel", "From"),
            ("addressLabel", "Select+Address"),
            ("print", "")
            ]

        # Now get the search page
        response = urllib2.urlopen(self.base_url, urllib.urlencode(post_data))

        soup = BeautifulSoup(response.read())

        trs = soup.find(text="Search Results").findNext("table").findAll("tr")[:-1]

        # There are six trs per application, ish

        # The first contains the case no and the application date.
        # The second contains the address
        # The third contains the description
        # The fourth contains the info page link
        # The fifth contains the comment link (or a note that comments are currently not being accepted
        # The sixth is a spacer.

        count = 0
        for tr in trs:
            count +=1

            ref = tr.find(text=re.compile("Case No:"))
            
            if ref:
                self._current_application = PlanningApplication()
                count = 1

                self._current_application.council_reference = ref.split(":")[1].strip()
                self._current_application.date_received = search_day

            if count % 6 == 2:
                self._current_application.address = tr.td.string.strip()
                self._current_application.postcode = getPostcodeFromText(self._current_application.address)
            if count % 6 == 3:
                self._current_application.description = tr.td.string.strip()
            if count % 6 == 4:
                self._current_application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])
            if count % 6 == 5:
                try:
                    self._current_application.comment_url = urlparse.urljoin(self.base_url, tr.a['href'])
                except:
                    # Comments are not currently being accepted. We'll leave this app for the moment - we'll pick it up later if they start accepting comments
                    continue
            if count % 6 == 0 and self._current_application.is_ready():
                self._results.addApplication(self._current_application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = BrentParser()
    print parser.getResults(6,8,2008)

