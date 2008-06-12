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

class ShetlandParser:
    def __init__(self, *args):

        self.authority_name = "Shetland Islands Council"
        self.authority_short_name = "Shetland Islands"
        self.base_url = "http://www.shetland.gov.uk/planningcontrol/apps/apps.asp?time=14&Orderby=DESC&parish=All&Pref=&Address=&Applicant=&ApplicantBut=View&sortby=PlanRef&offset=0"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self):
        # Note that we don't take the day, month and year parameters here.

        # First get the search page
        request = urllib2.Request(self.base_url)
        response = urllib2.urlopen(request)

        soup = BeautifulSoup(response.read())

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

                application.date_received = datetime.datetime(*(time.strptime(comment_url_element.findNext("td").string.strip(), date_format)[0:6]))

                application.council_reference = tr.a.string

                comment_url_element = tr.find(text="comment on this planning application").parent
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
                

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear().displayXML()

if __name__ == '__main__':
    parser = ShetlandParser()
    print parser.getResults(21,5,2008)

# TODO: Sort out pagination
