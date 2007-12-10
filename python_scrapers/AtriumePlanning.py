import urllib2
import urllib
import urlparse

import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText


info_path = "loadFullDetails.do"
comment_path = "loadRepresentation.do"

class AtriumePlanningParser:
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.info_url = urlparse.urljoin(base_url, info_path)
        self.comment_url = urlparse.urljoin(base_url, comment_path)

        self.debug = debug

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):

        # The end date for the search needs to be one day after the start
        # date - presumably the date is used as a timestamp at midnight
        search_start_date = datetime.date(year, month, day)
        search_end_date = search_start_date + datetime.timedelta(1)


        search_data = urllib.urlencode({"dayRegStart": search_start_date.strftime("%d"),
                    "monthRegStart": search_start_date.strftime("%b"),
                    "yearRegStart": search_start_date.strftime("%Y"),
                    "dayRegEnd": search_end_date.strftime("%d"),
                    "monthRegEnd": search_end_date.strftime("%b"),
                    "yearRegEnd": search_end_date.strftime("%Y"),
                    "searchType": "current",
                    "dispatch": "Search"
                    })

        response = urllib2.urlopen(self.base_url, search_data)

        html =  response.read()

        soup = BeautifulSoup(html)
        
        # Get a list of the trs in the results table
        if soup.find(text="Results"):
            
            tds = soup.find(text="Results").parent.findNext("table").findAll("td")

            for td in tds:
                if td.string:
                    if td.string.strip() == "Date Registered":
                        # We are starting a new App
                        self._current_application = PlanningApplication()

                        # 
                        day, month, year = [int(x) for x in td.findNext("td").string.split("-")]
                        self._current_application.date_received = datetime.date(year, month, day)
                        # FIXME - when python on haggis is a bit newer, 
                        #we can do the following, which is neater 
                        #(and get rid of the import of time).
                        #self._current_application.date_received = datetime.datetime.strptime(td.findNext("td").string, "%d-%m-%Y")
                    elif td.string.strip() == "Application Number":
                        self._current_application.council_reference = td.findNext("td").string
                    elif td.string.strip() == "Location":
                        location = td.findNext("td").string
                        self._current_application.address = location

                        postcode = getPostcodeFromText(location)
                        if postcode:
                            self._current_application.postcode = postcode
                    elif td.string.strip() == "Proposal":
                        self._current_application.description = td.findNext("td").string
                elif td.a and td.a.string.strip() == "View Full Details":
                    # The info url is td.a
                    messy_info_url = td.a["href"]

                    # We need to get an id out of this url
                    query_str = urlparse.urlsplit(messy_info_url)[3]

                    self._current_application.info_url = self.info_url + "?" + query_str
                    self._current_application.comment_url = self.comment_url + "?" + query_str

                    if self._current_application.is_ready():
                        self._results.addApplication(self._current_application)



        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


if __name__ == '__main__':
#    cumbria_parser = AtriumePlanningParser("Cumbria County Council", "Cumbria", "http://217.114.50.149:7778/ePlanningOPS/loadResults.do")

#    print cumbria_parser.getResults(22,11,2007)
#    lincolnshire_parser = AtriumePlanningParser("Lincolnshire County Council", "Lincolnshire", "")

#    print cumbria_parser.getResults(22,11,2007)

    #parser = AtriumePlanningParser("Dorset County Council", "Dorset", "http://www.dorsetforyou.com/ePlanning/loadResults.do")
    parser = AtriumePlanningParser("Somerset County Council", "Somerset", "http://webapp1.somerset.gov.uk/ePlanning/loadResults.do")
    print parser.getResults(1,11,2007)
