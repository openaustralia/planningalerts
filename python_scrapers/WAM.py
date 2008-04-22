import urllib2
import urllib
import urlparse

import datetime
import time
import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

def clean_string(a_string):
    return ' '.join(' '.join(a_string.split("&nbsp;")).strip().split())

def remove_params(url):
    # Probably a bit naughty to use both urlparse and urlunsplit here,
    # but it does what we want - removing the jsessionid param
    
    parsed_url = urlparse.urlparse(url)
    params_free_url = urlparse.urlunsplit(parsed_url[:3] + parsed_url[4:])

    return params_free_url

class WAMParser:
    address_column = 2
    date_format = "%d/%b/%Y"

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

    def _get_search_data(self, year, month, day):
        timestamp = time.mktime((year, month, day, 0,0,0,0,0,0))
        
        # The parameter endDate appears to be 1000*a timestamp
        time_input = str(int(timestamp*1000))

        #http://wam.boroughofpoole.com/WAM/pas/searchApplications.do;jsessionid=BCC7DFD1C42DC210A7BE5BA616683CDE
        # areaCode=%25&sortOrder=1&endDate=1197213359015&applicationType=%25&Button=Search

        search_data = (
            ("areaCode", "%"),
            ("sortOrder", "1"),
            ("endDate", time_input),
            ("applicationType", "%"),
            ("Button", "Search"),
            )

        return search_data

    def getResultsByDayMonthYear(self, day, month, year):
        search_data_tuple = self._get_search_data(year, month, day)
        search_data = urllib.urlencode(search_data_tuple)

        response = urllib2.urlopen(self.base_url, search_data)
        
        html = response.read()

        soup = BeautifulSoup(html)

        results_table = soup.find(text=re.compile("Your search returned the following")).findNext("table")

        # FIXME - deal with the empty results case
        # FIXME - deal with later pages of results

        trs = results_table.findAll("tr")[1:]

        self._current_application = PlanningApplication()

        for tr in trs:
            try:

                tds = tr.findAll("td")

                date_received_string = tds[0].contents[0].strip()
                
                # Some day we'll be on python 2.5, and we'll be able to use the nicer version below...
                self._current_application.date_received = datetime.datetime(*(time.strptime(clean_string(date_received_string), self.date_format)[0:6]))
                #self._current_application.date_received = datetime.datetime.strptime(clean_string(date_received_string), self.date_format)

                relative_info_url = tr.a['href']
                info_url_no_params = remove_params(relative_info_url)

                #Now we join on the base url to make it absolute
                self._current_application.info_url = urlparse.urljoin(self.base_url, info_url_no_params)

                self._current_application.council_reference = tr.a.string

                address = clean_string(tds[self.address_column].string)
                self._current_application.address = address
                self._current_application.postcode = getPostcodeFromText(address)

#            self._current_application.description = clean_string(tds[self.description_column].string)

                # Fetch the info page

                info_response = urllib2.urlopen(self._current_application.info_url)

                info_html = info_response.read()
                info_soup = BeautifulSoup(info_html)

                try:
                    relative_comment_url =  info_soup.find("a", href=re.compile("createComment.do"))['href']
                    comment_url_no_params = remove_params(relative_comment_url)

                    self._current_application.comment_url = urlparse.urljoin(self.base_url, comment_url_no_params)
                except: # FIXME - specialize the except
                    if self.debug:
                        print "No comment url for %s" %(self._current_application.council_reference)
                    self._current_application.comment_url = "None"

                # Some WAM sites have the description in the results page, 
                # but since they don't all have it there, we'll get it from here...

                description_td = info_soup.find(text="Development:").findNext("td")

                # Sometimes the description is in a span in the td, sometimes it is directly there.
                self._current_application.description = (description_td.string or description_td.span.string).strip()

                self._results.addApplication(self._current_application)

            except:
                # It seems a shame to miss out on all the apps from an authority just because one breaks...
                if self._current_application.council_reference:
                    if self.debug:
                        print "Failed to add %s" %(self._current_application.council_reference)
                else:
                    if self.debug:
                        print "Failed to add an application"
            
            self._current_application = PlanningApplication()

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()



class PooleParser(WAMParser):
    address_column = 1

class BraintreeParser(WAMParser):
    date_format = "%d %b %Y"

    def _get_search_data(self, year, month, day):
        # Braintree
        # action=showWeeklyList&areaCode=%25&sortOrder=1&endDate=1203249969656&applicationType=%25&Button=Search
        search_data = WAMParser._get_search_data(self, year, month, day)
        
        return (("action", "showWeeklyList"),) + search_data
        

if __name__ == '__main__':
    #parser = WAMParser("Barking and Dagenham", "Barking and Dagenham", "http://idoxwam.lbbd.gov.uk:8081/WAM/pas/searchApplications.do", debug=True)
    #parser = BraintreeParser("Braintree", "Braintree", "http://planningapp.braintree.gov.uk/WAM1/weeklyApplications.do", debug=True)
    # Camden
    #parser = WAMParser("Castle Point", "Castle Point", "http://wam.castlepoint.gov.uk/WAM/pas/searchApplications.do", debug=True)
    #Chichester - Done as PublicAccess
    #parser = BraintreeParser("Colchester", "Colchester", "http://www.planning.colchester.gov.uk/WAM/weeklyApplications.do", debug=True)
    parser = WAMParser("East Lothian", "East Lothian", "http://www.planning.eastlothian.gov.uk/WAM/pas/searchApplications.do", debug=True)
    #parser = BraintreeParser("North Somerset", "North Somerset", "http://wam.n-somerset.gov.uk/MULTIWAM/weeklyApplications.do", debug=True)
    #parser = WAMParser("Nottingham", "Nottingham", "http://plan4.nottinghamcity.gov.uk/WAM/pas/searchApplications.do", debug=True)
    #parser = PooleParser("Poole long", "Poole", "http://wam.boroughofpoole.com/WAM/pas/searchApplications.do", debug=True)
    #parser = WAMParser("Rother long", "Rother", "http://www.planning.rother.gov.uk/WAM/pas/searchApplications.do", debug=True)
    #parser = BraintreeParser("South Gloucestershire", "South Gloucestershire", "http://planning.southglos.gov.uk/WAM/pas/WeeklyApplications.do", debug=True)
    #parser = WAMParser("South Norfolk", "South Norfolk", "http://wam.south-norfolk.gov.uk/WAM/pas/searchApplications.do", debug=True)
    #parser = BraintreeParser("Tower Hamlets", "Tower Hamlets", "http://194.201.98.213/WAM/weeklyApplications.do", debug=True)
    #parser = WAMParser("Westminster", "Westminster", "http://idocs.westminster.gov.uk:8080/WAM/search/pas/index.htm", debug=True)

    print parser.getResults(3,3,2008)

# Left to fix

# All:
# Paging
# Coping with no apps


# Barking and Dagenham - done
# Braintree - done
# Camden - also has a PlanningExplorer, which is done (so not bothering)
# Castle Point - done
# Chichester - not needed (PublicAccess site done)
# Colchester - done. like Braintree
# East Lothian - done
# North Somerset - done. like Braintree
# Nottingham - done (sometimes no comments)
# Poole - done
# Rother - done
# South Gloucestershire - done. like Braintree
# South Norfolk - Works, but no postcodes. Also, the search link here points to PlanningExplorer. I think we should assume this is the current site.
# Tower Hamlets - done. Like Braintree.
# Westminster - not done: clearly WAM underneath, but with a wrapper.

