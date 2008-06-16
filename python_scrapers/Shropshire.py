import urllib2
import urllib
import urlparse

import datetime, time
import cgi

import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class ShropshireParser:
    reference_input_name = "ApplNum"
    contact_email_name = "offemail"

    comment_url = None

    use_validated_date = False

    def _get_info_link_list(self, soup):
        return [tr.a for tr in soup.find("table", id="tbllist").findAll("tr", recursive=False)[:-1]]

    def _get_postcode(self, info_soup):
        return info_soup.find("input", {"name": "Postcode"})['value']

    def __init__(self, authority_name, authority_short_name, base_url, debug=False):
        self.debug = debug

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url
        self._split_base_url = urlparse.urlsplit(base_url)
        
        self._current_application = None
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)
        search_date_string = search_date.strftime(date_format)

        if self.use_validated_date:
            received_search_string = ""
            validated_search_string = search_date_string
        else:
            received_search_string = search_date_string
            validated_search_string = ""

        search_data = urllib.urlencode([
                ("txtAppNum", ""),
                ("txtAppName", ""),
                ("txtAppLocn", ""),
                ("txtAppPCode", ""),
                ("txtAppRecFrom", received_search_string),
                ("txtAppRecTo", received_search_string),
                ("txtAppDecFrom", ""),
                ("txtAppDecTo", ""),
                ("txtAppValFrom", validated_search_string),
                ("txtAppValTo", validated_search_string),
                ("district_drop", ""),
                ("parish_drop", ""),
                ("ward_drop", ""),
                ("ft", "yes"),
                ("submit1", "Submit"),
                ])

        split_search_url = self._split_base_url[:3] + (search_data, '')
        search_url = urlparse.urlunsplit(split_search_url)

        response = urllib2.urlopen(search_url)
        soup = BeautifulSoup(response.read())

        # Handle the case where there are no apps
        if soup.find(text=re.compile("No applications matched your query")):
            return self._results


        info_link_list = self._get_info_link_list(soup)

        for app_link in info_link_list:
            self._current_application = PlanningApplication()

            # We could get this from the info soup, but as we already know it, why bother.
            self._current_application.date_received = search_date

            self._current_application.info_url = urlparse.urljoin(self.base_url, app_link['href'])
    
            # To get the postcode we will need to download each info page
            info_response = urllib2.urlopen(self._current_application.info_url)
            info_soup = BeautifulSoup(info_response.read())

            self._current_application.council_reference = info_soup.find("input", {"name": self.reference_input_name})['value']
            self._current_application.address = info_soup.find("textarea", {"name": "Location"}).string.strip()
            self._current_application.postcode = self._get_postcode(info_soup)
                        
            self._current_application.description = info_soup.find("textarea", {"name": "Proposal"}).string.strip()

            if self.comment_url:
                self._current_application.comment_url = self.comment_url
            else:
                self._current_application.comment_url = info_soup.find("input", {"name": self.contact_email_name})['value']

            # There is an OSGB position here :-)
            self._current_application.osgb_x = info_soup.find("input", {"name": "Easting"})['value']
            self._current_application.osgb_y = info_soup.find("input", {"name": "Northing"})['value']

            self._results.addApplication(self._current_application)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


class NorthYorkshireParser(ShropshireParser):
    reference_input_name = "txtAppNum"
    contact_email_name = "contactEmail"

    comment_url = None

    # The date we give as the date_received here is actually the validated date.
    use_validated_date = True

    def _get_postcode(self, info_soup):
        return getPostcodeFromText(self._current_application.address)

    def _get_info_link_list(self, soup):
        return [div.a for div in soup.findAll("div", {"class": "listApplNum"})]


class SouthNorthamptonshireParser(ShropshireParser):
    reference_input_name = "txtAppNum"

    comment_url = "http://www.southnorthants.gov.uk/mandoforms/servlet/com.mandoforms.server.MandoformsServer?MF_XML=ApplicationComments&MF_DEVICE=HTML"

    def _get_postcode(self, info_soup):
        return getPostcodeFromText(self._current_application.address)

    def _get_info_link_list(self, soup):
        return soup.find("div", {"class": "div-content-class"}).findAll("a")

if __name__ == '__main__':
    parser = ShropshireParser("Shropshire County Council", "Shropshire", "http://planning.shropshire.gov.uk/PlanAppList.asp")
    print parser.getResults(6,6,2008)
#    parser = NorthYorkshireParser("North Yorkshire County Council", "North Yorkshire", "https://onlineplanningregister.northyorks.gov.uk/Online%20Register/PlanAppList.asp")
#    print parser.getResults(10,6,2008)
#    parser = SouthNorthamptonshireParser("South Northamptonshire Council", "South Northamptonshire", "http://snc.planning-register.co.uk/PlanAppList.asp")
#    print parser.getResults(5,6,2008)


# TODO

#1) Pagination: South Northants paginates at 25. I doubt this is a problem. Should also check out the others.
