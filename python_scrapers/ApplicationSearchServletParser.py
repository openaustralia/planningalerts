
import urllib, urllib2

import HTMLParser
import urlparse
import datetime, time


from PlanningUtils import PlanningAuthorityResults, \
                          getPostcodeFromText, \
                          PlanningApplication


# The search results list will give us reference, location, description,
# and info url of each app.

# The info page gives us the received date,
# and comment_url

class ApplicationSearchServletParser(HTMLParser.HTMLParser):
    """Parser for ApplicationSearchServlet sites.
    """


    # These indicate the column of the main table containing this
    # piece of information.
    # They should be overridden in subclasses

    #self._rows_to_ignore_at_start = None

    _reference_col_no = None
    _location_col_no = None
    _description_col_no = None
        
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):
	HTMLParser.HTMLParser.__init__(self)

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url
        self.debug = debug

        self.search_url = urlparse.urljoin(self.base_url, "portal/servlets/ApplicationSearchServlet")

        self._comment_url = urlparse.urljoin(self.base_url, "portal/servlets/PlanningComments?REFNO=%(council_reference)s")

        self._requested_date = None

        # 0 - no
        # 1 - maybe
        # 2 - yes
        # 3 - finished
        self._in_results_table = 0
        self._tr_count = 0
        self._td_count = 0
        self._data_list = []

        # this will hold the application we are currently working on.
        self._current_application = None
        
        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

    def _checkAttrsForResultsTable(self, attrs):
        raise SystemError

    def handle_starttag(self, tag, attrs):
        if self.debug:
            print tag, attrs
        if tag == "table" and self._in_results_table == 0:
            self._in_results_table = 1
            self._checkAttrsForResultsTable(attrs)
        elif tag == "tr" and self._in_results_table == 2:
            self._tr_count += 1
            self._td_count = 0
            self._data_list = []
            self._current_application = PlanningApplication()
            
        elif tag == "td" and self._in_results_table == 2:
            self._td_count += 1

        elif tag == "a" and self._in_results_table == 2 and self._td_count == self._reference_col_no:
            # The href attribute contains the link to the info page
            for (key, value) in attrs:
                if key == "href":
                    self._current_application.info_url = urlparse.urljoin(self.search_url, value)
                    
    def handle_endtag(self, tag):
        if self.debug:
            print "ending: " , tag
            
        if tag == "table" and self._in_results_table == 2:
            self._in_results_table = 3
        elif tag == "tr" and self._in_results_table == 2:
            if self._current_application.council_reference is not None:
                
                # get the received date
                #info_response = urllib2.urlopen(self._current_application.info_url)
                #info_page_parser = InfoPageParser()
                #info_page_parser.feed(info_response.read())
                self._current_application.date_received = self._requested_date#info_page_parser.date_received
                self._results.addApplication(self._current_application)
        elif tag == "td" and self._in_results_table == 2:
            if self._td_count == self._location_col_no:
                data = ' '.join(self._data_list).strip()
                self._current_application.address = data
                postcode = getPostcodeFromText(data)
                if postcode is not None:
                    self._current_application.postcode = postcode
                self._data_list = []
            elif self._td_count == self._description_col_no:
                data = ' '.join(self._data_list).strip()
                self._current_application.description = data
                self._data_list = []
        elif tag == 'a' and self._in_results_table == 2 and self._td_count == self._reference_col_no:
            data = ''.join(self._data_list).strip()
            self._current_application.council_reference = data
            self._current_application.comment_url = self._comment_url %{"council_reference": data}
            self._data_list = []

    def handle_data(self, data):
        if self.debug:
            print data
            
        if self._in_results_table == 2:
            if self._td_count == self._reference_col_no or \
                   self._td_count == self._location_col_no or \
                   self._td_count == self._description_col_no:
                self._data_list.append(data.strip())


    def getResultsByDayMonthYear(self, day, month, year):
        """This will return an ApplicationResults object containg the
        applications for the date passed in."""

        # Were going to need a datetime object for the requested date
        self._requested_date = datetime.date(year, month, day)

        required_format = "%d-%m-%Y"

        search_data = urllib.urlencode({"ReceivedDateFrom":self._requested_date.strftime(required_format),
                                        "ReceivedDateTo":self._requested_date.strftime(required_format)})
        
        search_request = urllib2.Request(self.search_url, search_data)
        search_response = urllib2.urlopen(search_request)
        search_contents = search_response.read()

        self.feed(search_contents)

        return self._results
    
    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


class CoventrySearchParser(ApplicationSearchServletParser):
    # results table spotter
    # width="100%" border="0"

    _reference_col_no = 1
    _location_col_no = 5
    _description_col_no = 8
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        
        for key, value in attrs:
            if key == 'width' and value == '100%':
                got_width = True
            elif key == 'border' and value == '0':
                got_border = True

        if got_width and got_border:
            self._in_results_table = 2
        else:
            self._in_results_table = 0



class AllerdaleSearchParser(ApplicationSearchServletParser):
    # results table spotter
#class="nis_table" summary="Table of planning applications that matched your query, showing reference number, received date, and address"

    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 4
    
    def _checkAttrsForResultsTable(self, attrs):
        got_class = False
        got_summary = False
        
        for key, value in attrs:
            if key == 'class' and value == 'nis_table':
                got_class = True
            elif key == 'summary' and value == 'Table of planning applications that matched your query, showing reference number, received date, and address':
                got_summary = True

        if got_class and got_summary:
            self._in_results_table = 2
        else:
            self._in_results_table = 0



class AlnwickSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # width="100%" class="niscontent"
    _reference_col_no = 1
    _location_col_no = 2
    _description_col_no = 7
    
    def _checkAttrsForResultsTable(self, attrs):
        got_class = False
        
        for key, value in attrs:
            if key == 'class' and value == 'niscontent':
                got_class = True

        if got_class:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class BarrowSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # width="100%" border="0"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 6
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        
        for key, value in attrs:
            if key == 'width' and value == '100%':
                got_width = True
            elif key == 'border' and value == '0':
                got_border = True

        if got_width and got_border:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class HartlepoolSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # summary="Table of planning applications that matched your query, showing reference number, received date, and address"
    _reference_col_no = 1
    _location_col_no = 2
    _description_col_no = 3
    
    def _checkAttrsForResultsTable(self, attrs):
        got_summary = False
        
        for key, value in attrs:
            if key == 'summary' and value == "Table of planning applications that matched your query, showing reference number, received date, and address":
                got_summary = True

        if got_summary:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class NorthWarksSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # table width="100%" border="0" cellspacing="0" cellpadding="0"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 4
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        got_cellspacing = False
        got_cellpadding = False
        
        for key, value in attrs:
            if key == 'width' and value == "100%":
                got_width = True
            elif key == 'border' and value == '0':
                got_border = True
            elif key == 'cellspacing' and value == '0':
                got_cellspacing = True
            elif key == 'cellpadding' and value == '0':
                got_cellpadding = True

        if got_width and got_border and got_cellspacing and got_cellpadding:
            self._in_results_table = 2
        else:
            self._in_results_table = 0

class StHelensSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # summary="Search Results List"
    _reference_col_no = 1
    _location_col_no = 2
    _description_col_no = 5
    
    def _checkAttrsForResultsTable(self, attrs):
        got_summary = False
        
        for key, value in attrs:
            if key == 'summary' and value == "Search Results List":
                got_summary = True

        if got_summary:
            self._in_results_table = 2
        else:
            self._in_results_table = 0

class EasingtonSearchParser(ApplicationSearchServletParser):
    # results table spotter
    #table width="100%" border="0" cellspacing="0" cellpadding="0"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 6
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        got_cellspacing = False
        got_cellpadding = False
        
        for key, value in attrs:
            if key == 'width' and value == "100%":
                got_width = True
            elif key == 'border' and value == '0':
                got_border = True
            elif key == 'cellspacing' and value == '0':
                got_cellspacing = True
            elif key == 'cellpadding' and value == '0':
                got_cellpadding = True

        if got_width and got_border and got_cellspacing and got_cellpadding:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class HighPeakSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # table class="data" width="95%"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 6
    
    def _checkAttrsForResultsTable(self, attrs):
        got_class = False
        got_width = False
        
        for key, value in attrs:
            if key == 'class' and value == "data":
                got_class = True
            if key == 'width' and value == "95%":
                got_width = True

        if got_class and got_width:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class WearValleySearchParser(ApplicationSearchServletParser):
    # results table spotter
    # table summary="Table of planning applications that matched your query, showing reference number, received date, and address"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 4
    
    def _checkAttrsForResultsTable(self, attrs):
        got_summary= False
        
        for key, value in attrs:
            if key == 'summary' and value == "Table of planning applications that matched your query, showing reference number, received date, and address":
                got_summary = True

        if got_summary:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class WellingboroughSearchParser(ApplicationSearchServletParser):
    # results table spotter
    #table width="100%" border="0"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 6
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        
        for key, value in attrs:
            if key == 'width' and value == "100%":
                got_width = True
            elif key == 'border' and value == "0":
                got_border = True

        if got_width and got_border:
            self._in_results_table = 2
        else:
            self._in_results_table = 0

class EalingSearchParser(ApplicationSearchServletParser):
    # results table spotter
    # table width="100%" cellspacing="0px" border="1px" cellpadding="2px" bordercolor="#FFFFFF"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 4
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_cellspacing = False
        got_border = False
        got_cellpadding = False
        got_bordercolor = False
        
        for key, value in attrs:
            if key == 'width' and value == "100%":
                got_width = True
            elif key == 'cellspacing' and value == "0px":
                got_cellspacing = True
            elif key == 'border' and value == "1px":
                got_border = True
            elif key == 'cellpadding' and value == "2px":
                got_cellpadding = True
            elif key == 'bordercolor' and value == "#FFFFFF":
                got_bordercolor = True

        if got_width and got_cellspacing and got_border and got_cellpadding and got_bordercolor:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class HaringeySearchParser(ApplicationSearchServletParser):
    # results table spotter
    # summary="Application Results"
    _reference_col_no = 1
    _location_col_no = 2
    _description_col_no = 5
    
    def _checkAttrsForResultsTable(self, attrs):
        got_summary= False
        
        for key, value in attrs:
            if key == 'summary' and value == "Application Results":
                got_summary = True

        if got_summary:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


class DenbighshireSearchParser(ApplicationSearchServletParser):
    # results table spotter
    #table width="100%" border="0"
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 5
    
    def _checkAttrsForResultsTable(self, attrs):
        got_width = False
        got_border = False
        
        for key, value in attrs:
            if key == 'width' and value == "100%":
                got_width = True
            elif key == 'border' and value == "0":
                got_border = True

        if got_width and got_border:
            self._in_results_table = 2
        else:
            self._in_results_table = 0

class RutlandParser(ApplicationSearchServletParser):
    _reference_col_no = 1
    _location_col_no = 3
    _description_col_no = 4

    def _checkAttrsForResultsTable(self, attrs):
        got_class = False
        
        for key, value in attrs:
            if key == 'class' and value == 'nis_table':
                got_class = True

        if got_class:
            self._in_results_table = 2
        else:
            self._in_results_table = 0


if __name__ == "__main__":
    #parser = CoventrySearchParser("Coventry", "Coventry", "http://planning.coventry.gov.uk")
    #parser = AllerdaleSearchParser("Allerdale", "Allerdale", "http://planning.allerdale.gov.uk")
    #parser = AlnwickSearchParser("Alnwick", "Alnwick", "http://services.castlemorpeth.gov.uk:7777")
    #parser = BarrowSearchParser("Barrow", "Barrow", "http://localportal.barrowbc.gov.uk")
    #parser = HartlepoolSearchParser("Hartlepool", "Hartlepool", "http://eforms.hartlepool.gov.uk:7777")
    #parser = NorthWarksSearchParser("North Warwickshire", "North Warks", "http://planning.northwarks.gov.uk")
    #parser = StHelensSearchParser("St Helens", "St Helens", "http://212.248.225.150:8080")
    #parser = EasingtonSearchParser("Easington", "Easington", "http://planning.easington.gov.uk")
    parser = HighPeakSearchParser("High Peak", "High Peak", "http://planning.highpeak.gov.uk")
    #parser = WearValleySearchParser("Wear Valley", "Wear Valley", "http://planning.wearvalley.gov.uk")
    #parser = WellingboroughSearchParser("Wellingborough", "Wellingborough", "http://planning.wellingborough.gov.uk")
    #parser = EalingSearchParser("Ealing", "Ealing", "http://www.pam.ealing.gov.uk")
    #parser = HaringeySearchParser("Haringey", "Haringey", "http://www.planningservices.haringey.gov.uk")
    #parser = DenbighshireSearchParser("Denbighshire", "Denbighshire", "http://planning.denbighshire.gov.uk")
    #parser = RutlandParser("Rutland County Council", "Rutland", "http://planningonline.rutland.gov.uk:7777")
    print parser.getResults(12,6,2009)
