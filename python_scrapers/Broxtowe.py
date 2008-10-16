import urllib2
import urllib
import urlparse

import datetime, time
import cgi

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class BroxtoweParser:
    def __init__(self, *args):

        self.authority_name = "Broxtowe Borough Council"
        self.authority_short_name = "Broxtowe"
        self.base_url = "http://planning.broxtowe.gov.uk"

        self.info_url = "http://planning.broxtowe.gov.uk/ApplicationDetail.aspx?RefVal=%s"


        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_day = datetime.date(year, month, day)

        # Now get the search page
        get_response = urllib2.urlopen(self.base_url)
        get_soup = BeautifulSoup(get_response.read())

        # These are the inputs with a default value
        inputs_needed = [(x['id'], x['value']) for x in get_soup.form.findAll("input", value=True, type=lambda x: x != "submit")]

        # Add the submit button
        inputs_needed.append(('cmdWeeklyList', 'Search Database'))

        # We also need to add the date we want to search for.
        # This is the friday after the date searched for.
        # At weekends this will get you the friday before, but that isn't
        # a problem as there are no apps then.
        friday = search_day + datetime.timedelta(4 - search_day.weekday())

        inputs_needed.append(("ddlWeeklyList", friday.strftime(date_format)))

        # We'd like as many results as we can get away with on one page.
        # 50 is the largest option offerend
        inputs_needed.append(("ddlResultsPerPageWeeklyList", "50"))

        post_data = dict(inputs_needed)
        post_url = get_response.url

        # In case something goes wrong here, let's break out of the loop after at most 10 passes
        passes = 0

        while True:
            passes += 1

            post_response = urllib2.urlopen(post_url, urllib.urlencode(post_data))
            post_soup = BeautifulSoup(post_response.read())

            result_tables = post_soup.table.findAll("table")

            for result_table in result_tables:
                application = PlanningApplication()

                application.address = ', '.join(result_table.findPrevious("b").string.strip().split("\r"))
                application.postcode = getPostcodeFromText(application.address)

                trs = result_table.findAll("tr")

                application.council_reference = trs[0].findAll("td")[1].string.strip()
                application.date_received = datetime.datetime.strptime(trs[1].findAll("td")[1].string.strip(), date_format).date()
                application.description = trs[3].findAll("td")[1].string.strip()

                application.info_url = self.info_url %(urllib.quote(application.council_reference))

                # In order to avoid having to do a download for every app,
                # I'm setting the comment url to be the same as the info_url.
                # There is a comment page which can be got to by pressing the button
                application.comment_url = application.info_url

                self._results.addApplication(application)

            # Which page are we on?
            page_no = int(post_soup.find("span", id="lblPageNo").b.string)
            total_pages = int(post_soup.find("span", id="lblTotalPages").b.string)

            if passes > 10 or not page_no < total_pages:
                break

            post_data = [
                ("__EVENTTARGET", "hlbNext"),
                ("__EVENTARGUMENT", ""),
                ("__VIEWSTATE", post_soup.find("input", id="__VIEWSTATE")['value']),
                ("__EVENTVALIDATION", post_soup.find("input", id="__EVENTVALIDATION")['value']),
                 ]

            post_url = urlparse.urljoin(post_response.url, post_soup.find("form")['action'])

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = BroxtoweParser()
    print parser.getResults(3,10,2008)

