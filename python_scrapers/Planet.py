import urllib2
import urllib
import urlparse

from cgi import parse_qs

import datetime

import cookielib

cookie_jar = cookielib.CookieJar()

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class PlanetParser:
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
        # What is the serviceKey for this council?
        # It's in our base url
        query_string = urlparse.urlsplit(self.base_url)[3]

        # This query string just contains the servicekey
        query_dict = parse_qs(query_string)

        service_key = query_dict['serviceKey'][0]

        # First get the form
        get_request = urllib2.Request(self.base_url)
        get_response = urllib2.urlopen(get_request)

        cookie_jar.extract_cookies(get_response, get_request)

        # We also need to get the security token
        get_soup = BeautifulSoup(get_response.read())

        security_token = get_soup.find('input', {'name': 'securityToken'})['value']

        # Now post to it
        search_date = datetime.date(year, month, day)

        search_data = urllib.urlencode(
            {
                "serviceKey":service_key,
                "securityToken": security_token,
                "STEP":"Planet_SearchCriteria",
                #X.resultCount=
                "X.pageNumber": "0",
                "X.searchCriteria_StartDate": search_date.strftime(date_format),
                "X.searchCriteria_EndDate": search_date.strftime(date_format),
                }
            )

        post_request = urllib2.Request(self.base_url, search_data)
        cookie_jar.add_cookie_header(post_request)

        post_response = urllib2.urlopen(post_request)

        post_soup = BeautifulSoup(post_response.read())

        # Now we need to find the results. We'll do this by searching for the text "Ref No" and then going forward from there. For some reason a search for the table gets the table without contents

        ref_no_text = post_soup.find(text="Ref No")

        first_tr = ref_no_text.findNext("tr")

        other_trs = first_tr.findNextSiblings()

        trs = [first_tr] + other_trs

        for tr in trs:
            self._current_application = PlanningApplication()

            # We don't need to get the date, it's the one we searched for.
            self._current_application.date_received = search_date

            tds = tr.findAll("td")

            self._current_application.council_reference = tds[0].a.string.strip()
            self._current_application.address = tds[1].string.strip()
            self._current_application.postcode = getPostcodeFromText(self._current_application.address)

            self._current_application.description = tds[2].string.strip()

            # There is no good info url, so we just give the search page.
            self._current_application.info_url = self.base_url

            # Similarly for the comment url
            self._current_application.comment_url = self.base_url
            
            self._results.addApplication(self._current_application)
            
        return self._results


# post data for worcester
# hopefully we can ignore almost all of this...

#ACTION=NEXT
#serviceKey=SysDoc-PlanetApplicationEnquiry
#serviceGeneration=
#securityToken=NTgxMjE3OTExMjA4OQ%3D%3D
#enquiry=
#STEP=Planet_SearchCriteria
#RECEIVED=
#COMMENTS=
#LAST_UPDATED=
#status=
#X.endEnquiry=
#X.resultCount=
#X.applicationNotFound=
#X.pageNumber=0
#X.searchCriteria_ApplicationReference=
#X.searchCriteria_StartDate=20%2F04%2F2008
#X.searchCriteria_EndDate=20%2F04%2F2008
#X.searchCriteria_Ward=
#X.searchCriteria_Parish=
#X.searchCriteria_Address=
#X.searchCriteria_Postcode=
#X.searchCriteria_ApplicantName=
#X.searchCriteria_AgentName=
#X.searchCriteria_UndecidedApplications=

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


if __name__ == '__main__':
#    parser = PlanetParser("Elmbridge Borough Council", "Elmbridge", "http://www2.elmbridge.gov.uk/Planet/ispforms.asp?serviceKey=SysDoc-PlanetApplicationEnquiry")
#    parser = PlanetParser("North Lincolnshire Council", "North Lincolnshire", "http://www.planning.northlincs.gov.uk/planet/ispforms.asp?ServiceKey=SysDoc-PlanetApplicationEnquiry")
#    parser = PlanetParser("Rydale District Council", "Rydale", "http://www.ryedale.gov.uk/ispforms.asp?serviceKey=SysDoc-PlanetApplicationEnquiry")
    parser = PlanetParser("Tewkesbury Borough Council", "Tewkesbury", "http://planning.tewkesbury.gov.uk/Planet/ispforms.asp?serviceKey=07WCC04163103430")
    print parser.getResults(21,5,2008)
#    parser = PlanetParser("Worcester City Council", "Worcester", "http://www.worcester.gov.uk:8080/planet/ispforms.asp?serviceKey=SysDoc-PlanetApplicationEnquiry", debug=True)

# TODO

# 1) Pagination
# 2) Work OK with no results.

# 3) Use OSGB for Tewkesbury?
