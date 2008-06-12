import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

class FifeParser:
    def __init__(self, *args):

        self.authority_name = "Fife Council"
        self.authority_short_name = "Fife"
        self.base_url = "http://www.fifedirect.org.uk/topics/index.cfm"

        self.comment_url = "http://www.ukplanning.com/ukp/showCaseFile.do?councilName=Fife+Council&appNumber=%s"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        search_data = urllib.urlencode(
            [("fuseaction", "planapps.list"),
             ("SUBJECTID", "104CC166-3ED1-4D22-B9F1E2FB8438478A"),
             ("src_fromdayRec", day),
             ("src_frommonthRec", month),
             ("src_fromyearRec", year),
             ("src_todayRec", day),
             ("src_tomonthRec", month),
             ("src_toyearRec", year),
             ("findroadworks", "GO"),
             ]
            )
        
        search_url = self.base_url + "?" + search_data

        response = urllib2.urlopen(search_url)
        soup = BeautifulSoup(response.read())

        results_table = soup.find("table", id="results")

        # Apart from the first tr, which contains headers, the trs come in pairs for each application

        trs = results_table.findAll("tr")[1:]

        tr_count = 0
        while tr_count < len(trs):
            tr = trs[tr_count]

            if tr_count % 2 == 0:
                application = PlanningApplication()
                application.date_received = search_date
                
                tds = tr.findAll("td")

                application.council_reference = tds[0].a.string.strip()
                application.comment_url = self.comment_url %(application.council_reference)

                application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])
                application.address = ', '.join([x.strip() for x in tds[1].findAll(text=True)])
                application.postcode = getPostcodeFromText(application.address)
            else:
                # Get rid of the "Details: " at the beginning.
                application.description = tr.td.string.strip()[9:]

                self._results.addApplication(application)

            tr_count += 1

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = FifeParser()
    print parser.getResults(21,5,2008)

# TODO

# Paginates at 50. Unlikely on a single day, so we'll worry about it later.
