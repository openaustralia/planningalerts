
import urllib2
import urllib
import urlparse

import datetime, time
import cgi


import cookielib

cookie_jar = cookielib.CookieJar()


from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

#date_format = "%d-%m-%Y"
date_format = "%d/%m/%Y"
received_date_format = "%d %B %Y"

import re

# We're going to use this for a re.split
# A whitespace char, "of" or "at" (case independent), and then a whitespace char.
address_finder_re = re.compile("\s(?:of)|(?:at)\s", re.I)

class HaltonParser:
    def __init__(self, *args):

        self.authority_name = "Halton Borough Council"
        self.authority_short_name = "Halton"
        self.base_url = "http://www.halton.gov.uk/planningapps/index.asp"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

#CaseNo=&AgtName=&AppName=&DateApValFrom=&DateApValTo=&AdrsNo=&StName=&StTown=&DropWeekDate=28-08-2008&DropAppealStatus=0&DateAppealValFrom=&DateAppealValTo=&Action=Search

    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # It seems dates are interpreted as midnight on
        post_data = urllib.urlencode(
            [
#                ("CaseNo", ""),
#                ("AppName", ""),
                ("DateApValFrom", search_day.strftime(date_format)),
                ("DateApValTo", (search_day + datetime.timedelta(1)).strftime(date_format)),
#                ("AdrsNo", ""),
#                ("StName", ""),
#                ("StTown", ""),
                ("DropWeekDate", "0"),#search_day.strftime(date_format)),
                ("DropAppealStatus", "0"),
#                ("DateAppealValFrom", ""),
#                ("DateAppealValTo", ""),
                ("PageSize", "10"),
                ("Action", "Search"),                 
                ]
            )

        request = urllib2.Request(self.base_url, post_data)

        while request:
            # Now get the search page
            # We need to deal with cookies, since pagination depends on them.
            cookie_jar.add_cookie_header(request)
            response = urllib2.urlopen(request)

            cookie_jar.extract_cookies(response, request)

            soup = BeautifulSoup(response.read())

            # This should find us each Case on the current page.
            caseno_strings = soup.findAll(text="Case No:")

            for caseno_string in caseno_strings:
                application = PlanningApplication()

                application.council_reference = caseno_string.findNext("td").string
                application.description = caseno_string.findNext(text="Details of proposal:").findNext("td").string.strip()

                application.date_received = datetime.datetime.strptime(caseno_string.findNext(text="Date Received").findNext("td").string, received_date_format).date()

                # The address here is included in the description. We'll have to do some heuristics to try to work out where it starts.
                # As a first go, we'll try splitting the description on the last occurence of " of " or " at ".

                try:
                    application.address = re.split(address_finder_re, application.description)[-1].strip()
                except IndexError:
                    # If we can't find of or at, we'll just have the description again, it's better than nothing.
                    application.address = application.description

                # We may as well get the postcode from the description rather than the address, in case things have gone wrong
                application.postcode = getPostcodeFromText(application.description)

                application.comment_url = urlparse.urljoin(self.base_url, caseno_string.findNext("form")['action'])

                # Now what to have as info url...
                # There is no way to link to a specific app, so we'll just have the search page.
                application.info_url = self.base_url

                self._results.addApplication(application)
                
            # Now we need to find the post data for the next page, if there is any.
            # Find the form with id "formNext", if there is one
            next_form = soup.find("form", id="formNext")

            if next_form is not None:
                action = next_form['action']
            
                # The HTML is borked - the inputs are outside the form, they are all
                # in a td which follows it.
                
                inputs = next_form.findNext("td").findAll("input")
                
                post_data = urllib.urlencode([(x['name'], x['value']) for x in inputs])
                
                request = urllib2.Request(urlparse.urljoin(self.base_url, action), post_data)
            else:
                request = None


        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = HaltonParser()
    print parser.getResults(4,8,2008)

