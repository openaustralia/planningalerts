import urllib2
import urllib
import urlparse

import datetime, time

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class MedwayParser:
    comment_email_address = "planning.representations@medway.gov.uk"

    def __init__(self, *args):
        self.authority_name = "Medway Council"
        self.authority_short_name = "Medway"

        self.base_url = "http://www.medway.gov.uk/index/environment/planning/planapp/planonline.htm"
        self._split_base_url = urlparse.urlsplit(self.base_url)

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)
        search_date_string = search_date.strftime(date_format)

        "appstat=&decision=&appdec=&ward=&parish=&dadfrom=&dadto=&davfrom=01%2F06%2F2008&davto=02%2F06%2F2008&searchbut=Search"
        search_data = urllib.urlencode(
            [("searchtype", "1"),
             ("appstat", ""),
             ("decision", ""),
             ("appdec", ""),
             ("ward", ""),
             ("parish", ""),
             ("dadfrom", ""),
             ("dadto", ""),
             ("davfrom", search_date_string),
             ("davto", search_date_string),
             ("searchbut", "Search"),
                ]
            )

        split_search_url = self._split_base_url[:3] + (search_data, '')
        search_url = urlparse.urlunsplit(split_search_url)

        response = urllib2.urlopen(search_url)
        soup = BeautifulSoup(response.read())

        results_table = soup.find(text="Application No").parent.parent.parent
        trs = results_table.findAll("tr")[1:]

        tr_counter = 0
        
        while tr_counter < len(trs):
            tr = trs[tr_counter]

            if tr_counter % 2 == 0:
                application = PlanningApplication()
                application.date_received = search_date
                application.comment_url = self.comment_email_address

                tds = tr.findAll("td")

                application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])
                application.council_reference = tr.a.string.strip()

                application.address = tds[1].string.strip()
                application.postcode = getPostcodeFromText(application.address)

                application.description = tds[2].string.strip()

                self._results.addApplication(application)

            tr_counter += 1

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = MedwayParser()
    print parser.getResults(02,6,2008)

