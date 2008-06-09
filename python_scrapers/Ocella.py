import urllib2
import urllib
import urlparse

import datetime

import cookielib

cookie_jar = cookielib.CookieJar()

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d-%m-%Y"

class OcellaParser:
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

        # First get the search page
        get_request = urllib2.Request(self.base_url)
        get_response = urllib2.urlopen(get_request)

        cookie_jar.extract_cookies(get_response, get_request)

        get_soup = BeautifulSoup(get_response.read())

        # We need to find where the post action goes
        action = get_soup.form['action']
        session_id = get_soup.find('input', {'name': 'p_session_id'})['value']

        post_data = urllib.urlencode(
            [#('p_object_name', 'FRM_WEEKLY_LIST.DEFAULT.SUBMIT_TOP.01'),
             #('p_instance', '1'),
             #('p_event_type', 'ON_CLICK'),
             #('p_user_args', ''),
             ('p_session_id', session_id),
             #('p_page_url', self.base_url),
             ('FRM_WEEKLY_LIST.DEFAULT.START_DATE.01', '02-06-2008'), #search_date.strftime(date_format),
             ('FRM_WEEKLY_LIST.DEFAULT.END_DATE.01', '09-06-2008'),#search_date.strftime(date_format),
             #('FRM_WEEKLY_LIST.DEFAULT.PARISH.01', ''),
                ]
            )
        
        post_request = urllib2.Request(action, post_data)
        cookie_jar.add_cookie_header(post_request)

        post_request.add_header('Referer', self.base_url)

        post_response = urllib2.urlopen(post_request)

        import pdb;pdb.set_trace()

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

# # Mine
# p_object_name=FRM_WEEKLY_LIST.DEFAULT.SUBMIT_TOP.01
# p_user_args=
# FRM_WEEKLY_LIST.DEFAULT.START_DATE.01=21-05-2008
# FRM_WEEKLY_LIST.DEFAULT.END_DATE.01=21-05-2008
# p_session_id=53576
# p_instance=1
# p_page_url=http%3A%2F%2Fwplan01.intranet.breckland.gov.uk%3A7778%2Fportal%2Fpage%3F_pageid%3D33%2C30988%26_dad%3Dportal%26_schema%3DPORTAL
# FRM_WEEKLY_LIST.DEFAULT.PARISH.01=
# p_event_type=ON_CLICK

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


if __name__ == '__main__':
    parser = OcellaParser("Breckland Council", "Breckland", "http://wplan01.intranet.breckland.gov.uk:7778/portal/page?_pageid=33,30988&_dad=portal&_schema=PORTAL")
    print parser.getResults(21,5,2008)


