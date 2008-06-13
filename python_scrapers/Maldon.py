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

class MaldonParser:
    comment_email_address = "dc.planning@maldon.gov.uk"
    info_url = "http://forms.maldon.gov.uk:8080/PlanApp/jsp/searchPlan.jsp"
    def __init__(self, *args):

        self.authority_name = "Maldon District Council"
        self.authority_short_name = "Maldon"
        self.base_url = "http://forms.maldon.gov.uk:8080/PlanApp/jsp/searchPlanApp-action.do"
        self._split_base_url = urlparse.urlsplit(self.base_url)

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)
        search_date_string = search_date.strftime(date_format)

        search_data = urllib.urlencode(
            [("RegisteredDateFrom", search_date_string),
             ("RegisteredDateTo", search_date_string),
             ]
            )

        split_search_url = self._split_base_url[:3] + (search_data, '')
        search_url = urlparse.urlunsplit(split_search_url)

        response = urllib2.urlopen(search_url)
        soup = BeautifulSoup(response.read())

        # Not a very good way of finding the table, but it works for the moment.
        results_table = soup.find("table", cellpadding="5px")

        trs = results_table.findAll("tr")[1:]

        tr_counter = 0

        while tr_counter < len(trs):
            tr = trs[tr_counter]

            if tr_counter % 2 == 0:
                application = PlanningApplication()
                application.date_received = search_date
                application.comment_url = self.comment_email_address
                
                tds = tr.findAll("td")
                
                application.council_reference = tds[0].b.string.strip()
                application.address = ' '.join(tds[2].string.split())
                application.postcode = getPostcodeFromText(application.address)


                # This is what it ought to be, but you can't get there without a sodding cookie.
                # I guess we'll have to send people to the front page
#                application.info_url = urlparse.urljoin(self.base_url, tr.find("a", title="Click here to view application details")['href'])
                application.info_url = self.info_url

            else:
                description = tr.td.string

                if tr.td.string is not None:
                    application.description = tr.td.string.strip()
                else:
                    application.description = "Description Missing"

                self._results.addApplication(application)
            
            tr_counter += 1

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = MaldonParser()
    print parser.getResults(02,6,2008)

# TODO

# 1) Check that it works ok on a no results page.
# 2) Email the council about non-linkable info page.
# 3) Email the council about missing descriptions?
