
import urllib2
import HTMLParser
import urlparse
import datetime

from PlanningUtils import getPostcodeFromText, PlanningAuthorityResults, PlanningApplication

# example url
# http://www.planning.cravendc.gov.uk/fastweb/results.asp?Scroll=1&DateReceivedStart=1%2F1%2F2007&DateReceivedEnd=1%2F7%2F2007

search_form_url_end = "results.asp?Scroll=%(scroll)d&DateReceivedStart=%(day)d%%2F%(month)d%%2F%(year)d&DateReceivedEnd=%(day)d%%2F%(month)d%%2F%(year)d"

# for testing paging
#search_form_url_end = "results.asp?Scroll=%(scroll)d&DateReceivedStart=10%%2F7%%2F2007&DateReceivedEnd=%(day)d%%2F%(month)d%%2F%(year)d"

comment_url_end = "comment.asp?AltRef=%s"
info_url_end = "detail.asp?AltRef=%s"

class FastWeb:
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):
        
        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)
        
    def getResultsByDayMonthYear(self, day, month, year):
        requested_date = datetime.date(year, month, day)

        # What we should do:

        #1) Work out if the page we get back is a results page or the search page again. The search page indicates no results for this day.

        # Assuming we have a results page:
        #2) Get the total number of results out of it. We can use this to work out how many times we need to request the page, and with what scroll numbers

        #3) Iterate over scroll numbers.

        scroll = 0
        first_time = True
        number_of_results = 0

        while first_time or scroll * 20 < number_of_results:
            scroll += 1
        
            this_search_url = search_form_url_end %{"scroll":scroll, "day":day, "month":month, "year":year}
            url = urlparse.urljoin(self.base_url, this_search_url)
            response = urllib2.urlopen(url)

            contents = response.read()

            if first_time:
                # We can now use the returned URL to tell us if there were no results.
                returned_url = response.geturl()

                # example URL of no results page
                # http://www.planning.cravendc.gov.uk/fastweb/search.asp?Results=none&
                if returned_url.count("search.asp"):
                    # We got back the search page, there were no results for this date
                    break
            
            results_page_parser = FastWebResultsPageParser(self._results, requested_date, self.base_url)
            results_page_parser.feed(contents)

            if first_time:
                number_of_results += results_page_parser.number_of_results
                
            first_time = False

        return self._results
    
    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()



# States

STARTING = 1
GOT_RESULTS_COUNT = 2
IN_RESULTS_TABLE = 3
IN_RESULTS_TABLE_TD = 4
IN_INNER_TABLE = 5
FINISHED = -1


class FastWebResultsPageParser(HTMLParser.HTMLParser):
    def __init__(self, results, requested_date, base_url):

        self.results = results

        self.requested_date = requested_date
        self.base_url = base_url


	HTMLParser.HTMLParser.__init__(self)

        # We'll use this to store the number of results returned for this search
        self.number_of_results = None

        self._state = STARTING
        self._td_count = None

        self._data_list = []

        # This will store the planning application we are currently working on.
        self._current_application = None
        
    def get_data(self, flush=True):
        data = " ".join(self._data_list)

        if flush:
            self.flush_data()
            
        return data

    def flush_data(self):
        self._data_list = []

    def handle_starttag(self, tag, attrs):
        if self._state == STARTING and tag == "input":
            self._state = GOT_RESULTS_COUNT

            # This is where the number of results returned is stored
            attr_dict = {}
            
            for attr_name, attr_value in attrs:
                attr_dict[attr_name] = attr_value
                
            if attr_dict.get("id") == "RecCount":
                self.number_of_results = int(attr_dict.get("value"))

        elif self._state == GOT_RESULTS_COUNT and tag == "table":
            self._state = IN_RESULTS_TABLE

        elif self._state == IN_RESULTS_TABLE and tag == "td":
            self._state = IN_RESULTS_TABLE_TD
        elif self._state == IN_RESULTS_TABLE_TD and tag == "table":
            self._state = IN_INNER_TABLE
            self._td_count = 0
            self._current_application = PlanningApplication()
            self._current_application.date_received = self.requested_date

        elif self._state == IN_INNER_TABLE and tag == "td":
            self._td_count += 1
            self.flush_data()

    def handle_endtag(self, tag):
        if self._state == IN_INNER_TABLE and tag == "table":
            # The next if should never be false, but it pays to be careful :-)
            if self._current_application.council_reference is not None:
                self.results.addApplication(self._current_application)
            self._state = IN_RESULTS_TABLE_TD

        elif self._state == IN_RESULTS_TABLE_TD and tag == "td":
            self._state = FINISHED
            
        elif self._state == IN_INNER_TABLE and tag == "td":
            if self._td_count == 2:
                # This data is the App No.
                council_reference = self.get_data().strip()
                self._current_application.council_reference = council_reference

                # This also gives us everything we need for the info and comment urls
                self._current_application.info_url = urlparse.urljoin(self.base_url, info_url_end %(council_reference))
                self._current_application.comment_url = urlparse.urljoin(self.base_url, comment_url_end %(council_reference))
                
            elif self._td_count == 4:
                # This data is the address
                self._current_application.address = self.get_data().strip()
                self._current_application.postcode = getPostcodeFromText(self._current_application.address)
            elif self._td_count == 7:
                # This data is the description
                self._current_application.description = self.get_data().strip()

    
    def handle_data(self, data):
        self._data_list.append(data)

        
    
# for debug purposes

#cravenparser = FastWeb("Craven District Council", "Craven", "http://www.planning.cravendc.gov.uk/fastweb/")

#eastleighparser = FastWeb("EastLeigh Borough Council", "Eastleigh", "http://www.eastleigh.gov.uk/FastWEB/")


#suttonparser = FastWeb("Sutton", "Sutton", "http://82.43.4.135/FASTWEB/")
suttonparser = FastWeb("Sutton", "Sutton", "http://213.122.180.105/FASTWEB/")
#print eastleighparser.getResults(10,8,2007)
#print cravenparser.getResults(25,12,2006)
print suttonparser.getResults(1,8,2008)

#south_lakeland_parser = FastWeb("South Lakeland", "South Lakeland", "http://www.southlakeland.gov.uk/fastweb/")

#print south_lakeland_parser.getResults(27,11,2006)

