import urllib2
import urllib
import datetime
import re

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

date_format = "%d/%m/%Y"

class WestDorsetParser:
    def __init__(self, *args):

        self.authority_name = "West Dorset District Council"
        self.authority_short_name = "West Dorset"

        self.base_url = "http://webapps.westdorset-dc.gov.uk/planningapplications/pages/applicationsearch.aspx"
        self.info_url = "http://webapps.westdorset-dc.gov.uk/planningapplications/pages/ApplicationDetails.aspx?Application=%s&Authority=West+Dorset+District+Council+"

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        get_response = urllib2.urlopen(self.base_url)
        
        get_soup = BeautifulSoup(get_response.read())

        post_data = (
            ("__VIEWSTATE", get_soup.find("input", id="__VIEWSTATE")["value"]),
#            ("QuickSearchApplicationNumber$TextBox_ApplicationNumber", ""),
#            ("QuickSearchThisWeek$DropDownList_PastWeek", ""),
#            ("DetailedSearch$TextBox_PropertyNameNumber", ""),
#            ("DetailedSearch$Textbox_StreetName", ""),
#            ("DetailedSearch$Textbox_TownVillage", ""),
#            ("DetailedSearch$Textbox_Postcode", ""),
#            ("DetailedSearch$Textbox_Parish", ""),
#            ("DetailedSearch$Textbox_ApplicantSurname", ""),
#            ("DetailedSearch$TextBox_AgentName", ""),
            ("DetailedSearch$TextBox_DateRaisedFrom", search_date.strftime(date_format)),
            ("DetailedSearch$TextBox_DateRaisedTo", search_date.strftime(date_format)),
#            ("DetailedSearch$TextBox_DecisionFrom", "dd%2Fmm%2Fyyyy"),
#            ("DetailedSearch$TextBox_DecisionTo", "dd%2Fmm%2Fyyyy"),
            ("DetailedSearch$Button_DetailedSearch", "Search"),
            ("__EVENTVALIDATION", get_soup.find("input", id="__EVENTVALIDATION")["value"]),
            )

        # The response to the GET is a redirect. We'll need to post to the new url.
        post_response = urllib2.urlopen(get_response.url, urllib.urlencode(post_data))
        post_soup = BeautifulSoup(post_response.read())

        if not post_soup.find(text = re.compile("No matching record")):
            # The first row contains headers.
            trs = post_soup.find("table", {"class": "searchresults"}).findAll("tr")[1:]

            for tr in trs:
                application = PlanningApplication()

                # We can fill the date received in straight away from the date we searched for.
                application.date_received = search_date

                tds = tr.findAll("td")

                application.council_reference = tds[0].font.string.strip()
                application.address = tds[2].font.string.strip()
                application.postcode = getPostcodeFromText(application.address)
                application.description = tds[3].font.string.strip()

                # Set the info url and the comment url to be the same - can't get to the comment
                # one directly without javascript.
                application.info_url = self.info_url %(application.council_reference)
                application.comment_url = application.info_url

                self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = WestDorsetParser()
    print parser.getResults(1,10,2008)

