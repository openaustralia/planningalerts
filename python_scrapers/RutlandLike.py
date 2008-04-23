import urllib2
import urllib
import urlparse

import datetime, time
#import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

# Where the council reference fills the gap
comment_url_end = "comment.asp?%s"

#comment_regex = re.compile("Comment on this ")


class RutlandLikeParser:
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)
        date_string = search_date.strftime(date_format)
        
        search_data = urllib.urlencode({"reference": "",
                                        "undecided": "yes",
                                        "dateFrom": date_string,
                                        "dateTo": date_string,
                                        "Address": "",
                                        "validate": "true",
                                        })


        request = urllib2.Request(self.base_url, search_data)
        response = urllib2.urlopen(request)

        html =  response.read()

        soup = BeautifulSoup(html)

        tables = soup.findAll("table", {"style": "width:auto;"})

        if not tables:
            return self._results

        # We don't want the first or last tr
        trs = tables[0].findAll("tr")[1:-1]

        for tr in trs:
            app = PlanningApplication()

            tds = tr.findAll("td")

            if len(tds) == 4:
                local_info_url = tds[0].a['href']
                app.info_url = urlparse.urljoin(self.base_url, local_info_url)
                app.council_reference = tds[0].a.string

                app.address = tds[1].string
                app.postcode = getPostcodeFromText(app.address)

                app.description = tds[2].string

                app.comment_url = urlparse.urljoin(self.base_url, comment_url_end %app.council_reference)
                app.date_received = search_date

                self._results.addApplication(app)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


if __name__ == '__main__':
    parser = RutlandLikeParser("Rutland long", "Rutland", "http://www.meltononline.co.uk/planning/searchparam.asp")
    print parser.getResults(3,2,2008)

