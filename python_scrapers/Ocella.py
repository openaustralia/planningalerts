import urllib2
import urllib
import urlparse

import datetime, time

import cookielib

cookie_jar = cookielib.CookieJar()

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

search_date_format = "%d-%m-%Y" # Format used for the accepted date when searching

possible_date_formats = [search_date_format, "%d/%m/%Y"]

class CookieAddingHTTPRedirectHandler(urllib2.HTTPRedirectHandler):
    """The standard python HttpRedirectHandler doesn't add a cookie to the new request after a 302. This handler does."""
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new_request = urllib2.HTTPRedirectHandler.redirect_request(self, req, fp, code, msg, headers, newurl)
        # We need to add a cookie from the cookie_jar
        cookie_jar.add_cookie_header(new_request)

        return new_request

cookie_handling_opener = urllib2.build_opener(CookieAddingHTTPRedirectHandler())


class OcellaParser:
    received_date_format = search_date_format

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

        # These will be used to store the column numbers of the appropriate items in the results table
        self.reference_col = None
        self.address_col = None
        self.applicant_col = None
        self.description_col = None
        self.received_date_col = None
        self.accepted_date_col = None

    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        # First get the search page
        get_request = urllib2.Request(self.base_url)
        get_request.add_header('Accept', 'text/html')
        get_response = urllib2.urlopen(get_request)

        cookie_jar.extract_cookies(get_response, get_request)

        get_soup = BeautifulSoup(get_response.read())

        # We need to find where the post action goes
        action = get_soup.form['action']

        try:
            session_id = get_soup.find('input', {'name': 'p_session_id'})['value']
        except TypeError:
            # In the case of Middlesbrough, there is no session cookie, 
            # but it seems we don't need it...
            session_id = None

        # Unless we retrieve the correct form name, we will simply get the last week's applications
        submit_tag = get_soup.find('input', {'value': 'Search'}) or get_soup.find('input', {'value': 'Search for Applications'}) or get_soup.find('input', {'value': 'Submit'})
        try:
            submit_name = submit_tag['name']
            form_name = submit_name.split('.')[0]
        except TypeError:
            form_name = 'FRM_PLANNING_LIST'

# # From Breckland

# p_object_name=FRM_WEEKLY_LIST.DEFAULT.SUBMIT_TOP.01
# p_instance=1
# p_event_type=ON_CLICK
# p_user_args=
# p_session_id=53573
# p_page_url=http%3A%2F%2Fwplan01.intranet.breckland.gov.uk%3A7778%2Fportal%2Fpage%3F_pageid%3D33%2C30988%26_dad%3Dportal%26_schema%3DPORTAL
# FRM_WEEKLY_LIST.DEFAULT.START_DATE.01=02-06-2008
# FRM_WEEKLY_LIST.DEFAULT.END_DATE.01=09-06-2008
# FRM_WEEKLY_LIST.DEFAULT.PARISH.01=

        post_data = urllib.urlencode(
            [('p_object_name', form_name + '.DEFAULT.SUBMIT_TOP.01'),
             ('p_instance', '1'),
             ('p_event_type', 'ON_CLICK'),
             ('p_user_args', ''),
             ('p_session_id', session_id),
             ('p_page_url', self.base_url),
             (form_name + '.DEFAULT.AGENT.01', ''),
             (form_name + '.DEFAULT.START_DATE.01', search_date.strftime(search_date_format)),
             (form_name + '.DEFAULT.END_DATE.01', search_date.strftime(search_date_format)),
             (form_name + '.DEFAULT.PARISH.01', ''),
                ]
            )
        
        post_request = urllib2.Request(action, post_data)
        cookie_jar.add_cookie_header(post_request)

        post_request.add_header('Accept', 'text/html')
        post_request.add_header('Referer', self.base_url)

        post_response = cookie_handling_opener.open(post_request)

        post_soup = BeautifulSoup(post_response.read())

        results_table = post_soup.find("table", summary="Printing Table Headers")

        trs = results_table.findAll("tr")

        # We'll use the headings in the first tr to find out what columns the address, description, etc are in.
        ths = trs[0].findAll("th")

        th_index = 0
        for th in ths:
            th_content = th.font.string.strip()
            if th_content == 'Reference' or th_content == 'Application Ref' or th_content == 'Application Number':
                self.reference_col = th_index
            elif th_content == 'Location':
                self.address_col = th_index
            elif th_content == 'Applicant Details':
                self.applicant_col = th_index
            elif th_content == 'Proposal':
                self.description_col = th_index
            elif th_content == 'Development Description':
                self.description_col = th_index
            elif th_content == 'Received Date' or th_content == 'Date Received':
                self.received_date_col = th_index
            elif th_content == 'Accepted Date':
                self.accepted_date_col = th_index

            th_index += 1
            
        # If there is a received date, we'll use that, otherwise, we'll have to settle for the accepted date.
        self.received_date_col = self.received_date_col or self.accepted_date_col

        # We want all the trs except the first one, which is just headers, 
        # and the last, which is empty
        trs = trs[1:-1]

        for tr in trs:
            self._current_application = PlanningApplication()

            tds = tr.findAll("td")

            self._current_application.council_reference = (tds[self.reference_col].font.a or tds[self.reference_col].a.font).string.strip()

            date_string = tds[self.received_date_col]

            for possible_format in possible_date_formats:
                
                try:
                    self._current_application.date_received = datetime.datetime(*(time.strptime(tds[self.received_date_col].font.string.strip(), possible_format)[0:6]))
                except ValueError:
                    pass

            self._current_application.address = tds[self.address_col].font.string.strip()
            self._current_application.postcode = getPostcodeFromText(self._current_application.address)
            if self._current_application.postcode is None and self.applicant_col is not None:
                # won't always be accurate to do this but better than nothing (needed for Havering)
                self._current_application.postcode = getPostcodeFromText(tds[self.applicant_col].font.string.strip())
            self._current_application.description = tds[self.description_col].font.string.strip()
            # seems to be dependent on the implementation whether the URL is encoded (e.g. Great Yarmouth does this), so we cannot do anything more "standard"
            self._current_application.info_url = urlparse.urljoin(post_response.geturl(), tds[self.reference_col].a['href'].replace('&amp;','&'))

# This is what a comment url looks like
# It seems to be no problem to remove the sessionid (which is in any case blank...)
# I can't see a good way to avoid having to go to the info page to find the moduleid though.

#http://wplan01.intranet.breckland.gov.uk:7778/pls/portal/PORTAL.wwa_app_module.link?p_arg_names=_moduleid&p_arg_values=8941787057&p_arg_names=_sessionid&p_arg_values=&p_arg_names=APPLICATION_REFERENCE&p_arg_values=3PL%2F2008%2F0877%2FF

            # For the moment, we'll just use the info url, as that seems to work.
            self._current_application.comment_url = self._current_application.info_url
            
            self._results.addApplication(self._current_application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
#    parser = OcellaParser("Arun", "Arun", "http://www.arun.gov.uk/iplanning/portal/page?_pageid=33,4139&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Breckland Council", "Breckland", "http://wplan01.intranet.breckland.gov.uk:7778/portal/page?_pageid=33,30988&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Ellesmere Port", "Ellesmere Port", "http://ocella.epnbc.gov.uk/portal/page?_pageid=33,38205&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Fareham", "Fareham", "http://eocella.fareham.gov.uk/portal/page?_pageid=33,31754&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Hillingdon", "Hillingdon", "http://w09.hillingdon.gov.uk/portal/page?_pageid=33,82093&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Middlesbrough", "Middlesbrough", "http://planserv.middlesbrough.gov.uk/portal/page?_pageid=33,4178&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("North East Lincolnshire", "North East Lincolnshire", "http://planning.nelincs.gov.uk/portal/page?_pageid=33,64104&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Uttlesford", "Uttlesford", "http://planning.uttlesford.gov.uk/portal/page/portal/plan/weekly")
#    parser = OcellaParser("Bridgend", "Bridgend", "http://eplan.bridgend.gov.uk:7778/portal/page?_pageid=55,31779&_dad=portal&_schema=PORTAL")
    parser = OcellaParser("Havering", "Havering", "http://planning.havering.gov.uk/portal/page?_pageid=33,1026&_dad=portal&_schema=PORTAL")
#    parser = OcellaParser("Castle Point", "Castle Point", "http://planning.castlepoint.gov.uk/portal/page?_pageid=35,38205&_dad=portal&_schema=PORTAL")
    parser = OcellaParser("Great Yarmouth", "Great Yarmouth", "http://planning.great-yarmouth.gov.uk/portal/page/portal/plan/weekly")


    print parser.getResults(21,5,2008)

#TODO

# 1) Sort out proper comment url?
# 2) Check for pagination
# 3) Check no results case
