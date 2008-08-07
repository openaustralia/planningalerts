"""
This is the screenscraper for the planning applications in Amber Valley.

We have to get the initial search page so that we can use the __VIEWSTATE
parameter.

The start and end dates have to be separated by 1 day - I presume they are
interpreting dates as a datetime at midnight...

BeautifulSoup doesn't seem to be able to cope with what comes back from the
post, so we'll use HTMLParser.

The info reference link uses javascript (typical). As far as I can see there is no way to link directly to the info page for an application, so we'll just have to link to the search page.

Bizarrely, the comment url is fine. e.g.

http://www.ambervalley.gov.uk/services/environment/landandpremises/planningtownandcountry/planningapplications/planappcommentform.htm?frm_AppNum=AVA-2008-0955&frm_SiteAddress=147+Derby+Road%0dDuffield%0dBelper%0dDerbyshire%0dDE56+4FQ%0d&frm_Proposal=Rear+single+storey+extension+and+loft+conversion

"""

import urllib2
import urllib
import urlparse

import HTMLParser

import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

#date_format = "%d/%m/%Y"

class AmberValleyParser(HTMLParser.HTMLParser):
    def __init__(self, *args):

        HTMLParser.HTMLParser.__init__(self)

        self._in_result_table = False
        self._td_count = None
        self._get_ref = False
        self._get_description = False

        self.authority_name = "Amber Valley Borough Council"
        self.authority_short_name = "Amber Valley"
        self.base_url = "http://www.ambervalley.gov.uk/AVBC/Core/TemplateHandler.aspx?NRMODE=Published&NRNODEGUID=%7bAF862CF0-5C6D-4115-9979-5956B24D12DF%7d&NRORIGINALURL=%2fservices%2fenvironment%2flandandpremises%2fplanningtownandcountry%2fplanningapplications%2fPlanningApplicationRegister%2ehtm&NRCACHEHINT=Guest#filterbottom"
        self.comment_url_template = "http://www.ambervalley.gov.uk/services/environment/landandpremises/planningtownandcountry/planningapplications/planappcommentform.htm?frm_AppNum=%(reference)s&frm_SiteAddress=%(address)s&frm_Proposal=%(description)s"

        self._current_application = None
        self._search_date = None

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def handle_starttag(self, tag, attrs):
        if tag == "table":
            for key, value in attrs:
                if key == "class" and value == "test":
                    self._current_application = PlanningApplication()
                    
                    # We can set the date_received immediately
                    self._current_application.date_received = self._search_date

                    self._in_result_table = True
                    self._td_count = 0

                    break

        elif tag == "td":
            if self._in_result_table:
                self._td_count += 1
                self._get_description = False
        elif tag == "a" and self._td_count == 1:
            self._get_ref = True

    def handle_endtag(self, tag):
        if tag == "table" and self._in_result_table:
            self._current_application.description = self._current_application.description.strip()
            self._current_application.address = ' '.join(self._current_application.address.strip().split())
            self._current_application.postcode = getPostcodeFromText(self._current_application.address)
            self._current_application.info_url = self.base_url # Can't link to the info page, due to javascript idiocy.
            self._current_application.comment_url = self.comment_url_template %{"reference": urllib.quote_plus(self._current_application.council_reference),
                                                                                "address": urllib.quote_plus(self._current_application.address),
                                                                                "description": urllib.quote_plus(self._current_application.description),
                                                                                }
            
            self._results.addApplication(self._current_application)

            self._in_result_table = False
            self._td_count = None

        if tag == "a":
            self._get_ref = False

    def handle_startendtag(self, tag, attrs):
        if tag == "br" and self._td_count == 2:
            self._get_description = True

    def handle_data(self, data):
        if self._get_ref == True:
            self._current_application.council_reference = data

        elif self._td_count == 2:
            # This td contains the address (including postcode)
            # and the description

            if self._get_description:
                # We have passed the <br />, and are looking for the description
                if not self._current_application.description:
                    self._current_application.description = data
                else:
                    self._current_application.description += data
            else:
                # We have not yet passed the <br /> and are looking for the address and postcode.
                if not self._current_application.address:
                    self._current_application.address = data
                else:
                    self._current_application.address += data


    def getResultsByDayMonthYear(self, day, month, year):
        self._search_date = search_start_date = datetime.date(year, month, day)
        search_end_date = search_start_date + datetime.timedelta(1)

        # Now get the search page
        get_response = urllib2.urlopen(self.base_url)

        soup = BeautifulSoup(get_response.read())

        form = soup.find("form", id="__aspnetForm")

        # We're going to need __VIEWSTATE for our post
        viewstate = form.find("input", {"name":"__VIEWSTATE"})['value']
        action = form['action']

        # Now we have what we need to do a POST
        
        post_url = urlparse.urljoin(self.base_url, action)

# Example post data without the __VIEWSTATE

# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AtxbAppNumber=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AtxbAddressKeyword=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstDayStart=30
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstMonthStart=Jul
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstYearStart=2008
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstDayEnd=8
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstMonthEnd=Aug
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstYearEnd=2008
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3ArblDateType=0
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstDistance=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AtxbPostcode=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstWards=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstParishes=
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AlstOrderBy=RegisterDate+DESC
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3ArblViewType=List
# MainControl%3ACustomFunctionality_ZoneMain%3AEmbeddedUserControlPlaceholderControl1%3A_ctl0%3AmyFilter%3AbtnQueryPlanApps=Lookup

        post_data = urllib.urlencode([
                ("__VIEWSTATE", viewstate),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:txbAppNumber", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:txbAddressKeyword", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstDayStart", search_start_date.day), # Using the attribute directly to avoid the leading 0
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstMonthStart", search_start_date.strftime("%b")),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstYearStart", search_start_date.strftime("%Y")),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstDayEnd", search_end_date.day), # Using the attribute directly to avoid the leading 0
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstMonthEnd", search_end_date.strftime("%b")),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstYearEnd", search_end_date.strftime("%Y")),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:rblDateType", "0"),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstDistance", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:txbPostcode", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstWards", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstParishes", ""),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:lstOrderBy", "RegisterDate DESC"),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:rblViewType", "List"),
                ("MainControl:CustomFunctionality_ZoneMain:EmbeddedUserControlPlaceholderControl1:_ctl0:myFilter:btnQueryPlanApps", "Lookup"),
                 ])

        post_response = urllib2.urlopen(post_url, post_data)
        
        self.feed(post_response.read())

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = AmberValleyParser()
    print parser.getResults(4,8,2008)

