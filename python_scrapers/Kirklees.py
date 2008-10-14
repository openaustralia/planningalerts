import urllib2
import urllib
import urlparse

import datetime, time
import cgi

import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

search_date_format = "%d%%2F%m%%2F%Y"
received_date_format = "%d %b %Y"

class KirkleesParser:
    def __init__(self, *args):

        self.authority_name = "Kirklees Council"
        self.authority_short_name = "Kirklees"
        self.base_url = "http://www.kirklees.gov.uk/business/planning/List.asp?SrchApp=&SrchName=&SrchPostCode=&SrchStreet=&SrchDetails=&SrchLocality=&RorD=A&SrchDteFr=%(date)s&SrchDteTo=%(date)s&Submit=Search&pageNum=%(pagenum)d"
        self.comments_email_address = "planning.contactcentre@kirklees.gov.uk"
 
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        pagenum = 1

        while pagenum:
            response = urllib2.urlopen(self.base_url %{"date": search_date.strftime(search_date_format), 
                                                       "pagenum": pagenum}
                                       )
            soup = BeautifulSoup.BeautifulSoup(response.read())

            # This is not a nice way to find the results table, but I can't 
            # see anything good to use, and it works...

            # There are two trs with style attributes per app. This will find all the first ones of the pairs.
            trs = soup.find("table", border="0", cellpadding="0", cellspacing="2", width="100%", summary="").findAll("tr", style=True)[::2]

            for tr in trs:
                tds = tr.findAll("td")
                date_received = datetime.datetime.strptime(tds[3].string.strip(), received_date_format).date()

                # Stop looking through the list if we have found one which is earlier than the date searched for.
                if date_received < search_date:
                    # If we break out, then we won't want the next page
                    pagenum = None
                    break

                application = PlanningApplication()
                application.date_received = date_received

                application.council_reference = tds[0].small.string.strip()

                # The second <td> contains the address, split up with <br/>s
                application.address = ' '.join([x for x in tds[1].contents if isinstance(x, BeautifulSoup.NavigableString)])
                application.postcode = getPostcodeFromText(application.address)

                application.description = tds[2].string.strip()

                application.info_url = urlparse.urljoin(self.base_url, tr.findNext("a")['href'])
                application.comment_url = self.comments_email_address

                self._results.addApplication(application)
            else:
                # If we got through the whole list without breaking out,
                # then we'll want to get the next page.
                pagenum += 1

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = KirkleesParser()
    print parser.getResults(1,10,2008)

# TODO

