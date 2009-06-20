import urllib2
import cgi
import urlparse
import datetime, time
import BeautifulSoup
from PlanningUtils import PlanningApplication, PlanningAuthorityResults

date_format = "%d/%m/%Y"

class CrawleyParser:
    comment_url_template = "http://www.crawley.gov.uk/stellent/idcplg?IdcService=SS_GET_PAGE&nodeId=561&pageCSS=&pAppNo=%(pAppNo)s&pAppDocName=%(pAppDocName)s"
    
    def __init__(self, *args):

        self.authority_name = "Crawley Borough Council"
        self.authority_short_name = "Crawley"
        self.base_url =   "http://www.crawley.gov.uk/stellent/idcplg?IdcService=SS_GET_PAGE&nodeId=560&is_NextRow=1&accept=yes&strCSS=null&pApplicationNo=&pProposal=&pLocation=&pPostcode=&pWard=&pDateType=received&pDayFrom=%(dayFrom)s&pMonthFrom=%(monthFrom)s&pYearFrom=%(yearFrom)s&pDayTo=%(dayTo)s&pMonthTo=%(monthTo)s&pYearTo=%(yearTo)s&submit=Search"


        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)
        #- Crawley only allows searches from-to, so:

        next = self.base_url %{
            "dayFrom": day,
            "monthFrom": month,
            "yearFrom": year,
            "dayTo": day,
            "monthTo": month,
            "yearTo": year,
            }
        # Now get the search page
        response = urllib2.urlopen(next)
        soup = BeautifulSoup.BeautifulSoup(response.read())
        
        if soup.table: #- Empty result set has no table
            trs = soup.table.findAll("tr")[1:] # First one is just headers    
            for tr in trs:    
                tds = tr.findAll("td")
                application = PlanningApplication()         
                application.council_reference = tds[0].a.contents[0].strip().replace("&#47;", "/")
                application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])

                info_qs = cgi.parse_qs(urlparse.urlsplit(application.info_url)[3])

                comment_qs = {
                  "pAppNo": application.council_reference,
                  "pAppDocName": info_qs["ssDocName"][0],
                  }
                application.comment_url = self.comment_url_template %comment_qs

                application.address = tds[1].string.strip()
                if tds[2].string: #- if postcode present, append it to the address too
                    application.postcode = tds[2].string.replace("&nbsp;", " ").strip()
                    application.address += ", " + application.postcode
                application.description = tds[3].string.strip()
                application.date_received = datetime.datetime(*(time.strptime(tds[4].string.strip(), date_format)[0:6]))
                self._results.addApplication(application)
        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = CrawleyParser()
    print parser.getResults(12,6,2008)
    
