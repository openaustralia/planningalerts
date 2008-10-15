"""
"""

import time

import urlparse
import pycurl
import StringIO

import datetime


from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

class CairngormsParser:
    def __init__(self, *args):
        self.authority_name = "Cairngorms National Park"
        self.authority_short_name = "Cairngorms"
        self.referer = "http://www.cairngorms.co.uk/planning/e-planning/index.php"

        self.base_url = "http://www.cairngorms.co.uk/planning/e-planning/holding.php"

        # The timestamp here looks like the number of milliseconds since 1970
        self.first_post_url = "http://www.cairngorms.co.uk/planning/e-planning/search.php?timeStamp=%d"

        self.comments_email_address = "planning@cairngorms.co.uk"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        post_data = [
            ("CNPA_ref", ""),
            ("application_number", ""),
            ("LA_id", "%"),
            ("applicant_type", "%"),
            ("applicant_name", ""),
            ("development_address", ""),
            ("agent_name", ""),
            ("status", "%"),
            ("startDay", "%02d" %day),
            ("startMonth", "%02d" %month),
            ("startYear", "%d" %year),
            ("endDay", "%02d" %day),
            ("endMonth", "%02d" %month),
            ("endYear", "%d" %year),
            ]

        first_post_data = "CNPA_ref=&application_number=&applicant_name=&development_address=&agent_name=&applicant_type=%%&LA_id=%%&status=%%&startYear=%(year)d&startMonth=%(month)02d&startDay=%(day)02d&endYear=%(year)d&endMonth=%(month)02d&endDay=%(day)02d" %{"day": day, "month": month, "year": year}

        curlobj = pycurl.Curl()
        curlobj.setopt(pycurl.FOLLOWLOCATION, True)
        curlobj.setopt(pycurl.MAXREDIRS, 10)


        # First we do a normal post, this would happen as an AJAX query 
        # from the browser and just returns the number of applications found.
        fakefile = StringIO.StringIO() 

        curlobj.setopt(pycurl.URL, self.first_post_url %(int(time.time()*1000)))
        curlobj.setopt(pycurl.POST, True)
        curlobj.setopt(pycurl.WRITEFUNCTION, fakefile.write)
        curlobj.setopt(pycurl.POSTFIELDS, first_post_data)

        curlobj.perform()

        app_count = int(fakefile.getvalue())
        fakefile.close()

        if app_count:
            # Now we do another multipart form post
            # This gives us something to use as the callback
            fakefile = StringIO.StringIO() 

            curlobj.setopt(pycurl.URL, self.base_url)
            curlobj.setopt(pycurl.HTTPPOST, post_data)
            curlobj.setopt(pycurl.WRITEFUNCTION, fakefile.write)
            curlobj.setopt(pycurl.REFERER, self.referer)
            curlobj.perform()

            soup = BeautifulSoup(fakefile.getvalue())
            # We may as well free up the memory used by fakefile
            fakefile.close()

            for tr in soup.table.findAll("tr")[1:]:
                application = PlanningApplication()
                application.date_received = search_date
                application.comment_url = self.comments_email_address

                tds = tr.findAll("td")

                application.council_reference = tds[1].string.strip()
                application.info_url = urlparse.urljoin(self.base_url, tds[0].a['href'])

                application.address = tds[2].string.strip()
                application.postcode = getPostcodeFromText(application.address)

                # We're going to need to get the info page in order to get the description
                # We can't pass a unicode string to pycurl, so we'll have to encode it.
                curlobj.setopt(pycurl.URL, application.info_url.encode())
                curlobj.setopt(pycurl.HTTPGET, True)

                # This gives us something to use as the callback
                fakefile = StringIO.StringIO() 
                curlobj.setopt(pycurl.WRITEFUNCTION, fakefile.write)

                curlobj.perform()
                info_soup = BeautifulSoup(fakefile.getvalue())
                fakefile.close()

                application.description = info_soup.find(text="Development Details").findNext("td").string.strip()
                application.osgb_x = info_soup.find(text="Grid Ref East").findNext("td").string.strip()
                application.osgb_y = info_soup.find(text="Grid Ref North").findNext("td").string.strip()

                self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = CairngormsParser()
    print parser.getResults(3,10,2008)


# TODO
# Is there pagination?
