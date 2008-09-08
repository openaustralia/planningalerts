import urllib2
import urllib
import urlparse

import datetime, time
import cgi

import BeautifulSoup

import cookielib
cookie_jar = cookielib.CookieJar()

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class EastbourneParser:
    def __init__(self, *args):

        self.authority_name = "Eastbourne Borough Council"
        self.authority_short_name = "Eastbourne"
#        self.base_url = "http://www.eastbourne.gov.uk/planningapplications/search.asp"
        self.first_url = "http://www.eastbourne.gov.uk/planningapplications/index.asp"
        self.base_url = "http://www.eastbourne.gov.uk/planningapplications/results.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # There's going to be some faffing around here. We need a cookie to say we have agreed to some T&Cs.

        # First get the search page - we'll be redirected somewhere else for not having the cookie

        first_request = urllib2.Request(self.first_url)
        first_response = urllib2.urlopen(first_request)
        cookie_jar.extract_cookies(first_response, first_request)

        first_page_soup = BeautifulSoup.BeautifulSoup(first_response.read())

        first_page_action = urlparse.urljoin(self.first_url, first_page_soup.form['action'])
        
        the_input = first_page_soup.form.input

        second_page_post_data = urllib.urlencode(
            (
                (the_input['name'], the_input['value']),
                )
            )
        
        second_request = urllib2.Request(first_page_action, second_page_post_data)
        cookie_jar.add_cookie_header(second_request)
        second_response = urllib2.urlopen(second_request)
        cookie_jar.extract_cookies(second_response, second_request)

        # Now (finally) get the search page

#ApplicationNumber=&AddressPrefix=&Postcode=&CaseOfficer=&WardMember=&DateReceivedStart=31%2F08%2F2008&DateReceivedEnd=31%2F08%2F2008&DateDecidedStart=&DateDecidedEnd=&Locality=&AgentName=&ApplicantName=&ShowDecided=&DecisionLevel=&Sort1=FullAddressPrefix&Sort2=DateReceived+DESC&Submit=Search

        post_data = urllib.urlencode(
            (
                ("ApplicationNumber", ""),
                ("AddressPrefix", ""),
                ("Postcode", ""),
                ("CaseOfficer", ""),
                ("WardMember", ""),
                ("DateReceivedStart", search_day.strftime(date_format)),
                ("DateReceivedEnd", search_day.strftime(date_format)),
                ("DateDecidedStart", ""),
                ("DateDecidedEnd", ""),
                ("Locality", ""),
                ("AgentName", ""),
                ("ApplicantName", ""),
                ("ShowDecided", ""),
                ("DecisionLevel", ""),
                ("Sort1", "FullAddressPrefix"),
                ("Sort2", "DateReceived DESC"),
                ("Submit", "Search"),
                )
            )

        search_request = urllib2.Request(self.base_url)
        cookie_jar.add_cookie_header(search_request)
        search_response = urllib2.urlopen(search_request, post_data)

        soup = BeautifulSoup.BeautifulSoup(search_response.read())

        app_no_strings = soup.findAll(text="App. No.:")

        for app_no_string in app_no_strings:
            application = PlanningApplication()
            application.date_received = search_day

            application.council_reference = app_no_string.findNext("a").string.strip()
            application.info_url = urlparse.urljoin(self.base_url, app_no_string.findNext("a")['href'])

            application.address = ' '.join([x.strip() for x in app_no_string.findNext(text="Site Address:").findNext("td").contents if type(x) == BeautifulSoup.NavigableString])
            application.postcode = getPostcodeFromText(application.address)

            application.comment_url = urlparse.urljoin(self.base_url, app_no_string.findNext(text="Comment on application").parent['href'])

            application.description = app_no_string.findNext(text="Description:").findNext("td").string.strip()

            self._results.addApplication(application)
        
        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = EastbourneParser()
    print parser.getResults(1,9,2008)



# TODO - currently paginates at 20
