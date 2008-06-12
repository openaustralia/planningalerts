"""
The Shetland Isles site shows applications from the last 14 days.
These are paginated into groups of ten.
"""

import urllib2
import urlparse

import datetime, time
import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

page_count_regex = re.compile("Records 1 to 10 of (\d*) Records Found")

class ShetlandParser:
    def __init__(self, *args):

        self.authority_name = "Shetland Islands Council"
        self.authority_short_name = "Shetland Islands"
        self.base_url = "http://www.shetland.gov.uk/planningcontrol/apps/apps.asp?time=14&Orderby=DESC&parish=All&Pref=&Address=&Applicant=&ApplicantBut=View&sortby=PlanRef&offset=%d"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.datetime(year, month, day)

        offset = 0

        # First get the search page
        response = urllib2.urlopen(self.base_url %(offset))
        
        contents = response.read()

        # First let's find out how many records there are (they are displayed ten per page).
        match = page_count_regex.search(contents)        
        app_count = int(match.groups()[0])

        while offset < app_count:
            if offset != 0:
                contents = urllib2.urlopen(self.base_url %(offset)).read()

            soup = BeautifulSoup(contents)
            
            # The apps are in the 5th table on the page (not a very good way to get it...)
            results_table = soup.findAll("table")[5]

            # Now we need to find the trs which contain the apps.
            # The first TR is just headers.
            # After that they alternate between containing an app and just some display graphics
            # until the third from last. After that, they contain more rubbish.

            trs = results_table.findAll("tr")[1:-2]

            for i in range(len(trs)):
                # We are only interested in the trs in even positions in the list.
                if i % 2 == 0:
                    tr = trs[i]

                    application = PlanningApplication()

                    comment_url_element = tr.find(text="comment on this planning application").parent
                    application.date_received = datetime.datetime(*(time.strptime(comment_url_element.findNext("td").string.strip(), date_format)[0:6]))

                    # If the date of this application is earlier than the date 
                    # we are searching for then don't download it.
                    # We could optimize this a bit more by not doing the later pages.

                    if application.date_received < search_date:
                        break

                    application.council_reference = tr.a.string

                    application.comment_url = urlparse.urljoin(self.base_url, comment_url_element['href'])

                    application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])

                    info_response = urllib2.urlopen(application.info_url)

                    info_soup = BeautifulSoup(info_response.read())

                    info_table = info_soup.findAll("table")[2]

                    application.description = info_table.find(text="Proposal:").findNext("td").contents[0].strip()
                    application.postcode = info_table.find(text="Postcode:").findNext("td").contents[0].strip()

                    # Now to get the address. This will be split across several tds.

                    address_start_td = info_table.find("td", rowspan="4")

                    # We need the first bit of the address from this tr
                    address_bits = [address_start_td.findNext("td").string.strip()]

                    # We will need the first td from the next three trs after this
                    for address_tr in address_start_td.findAllNext("tr")[:3]:
                        address_line = address_tr.td.string.strip()

                        if address_line:
                            address_bits.append(address_line)

                    address_bits.append(application.postcode)

                    application.address = ', '.join(address_bits)

                    self._results.addApplication(application)
                    
            offset += 10

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = ShetlandParser()

    # Note: to test this, you will need to pick a current date.
    print parser.getResults(9,6,2008)

