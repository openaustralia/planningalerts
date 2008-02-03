#!/usr/local/bin/python

import urllib, urllib2
import HTMLParser
import urlparse
import datetime, time

import cookielib

cookie_jar = cookielib.CookieJar()


from PlanningUtils import fixNewlines, getPostcodeFromText, PlanningAuthorityResults, PlanningApplication


search_form_url_end = "DcApplication/application_searchform.aspx"
search_results_url_end = "DcApplication/application_searchresults.aspx"
comments_url_end = "DcApplication/application_comments_entryform.aspx"

class PublicAccessParser(HTMLParser.HTMLParser):
    """This is the class which parses the PublicAccess search results page.
    """

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

        # this will change to True when we enter the table of results
        self._in_results_table = False

        # this will be set to True when we have passed the header row
        # in the results table
        self._past_header_row = False

        # this will be true when we are in a <td> in the results table
        self._in_td = False

        # For each row, this will say how many tds we have seen so far
        self._td_count = 0

        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

        # This will store the planning application we are currently working on.
        self._current_application = None

    def handle_starttag(self, tag, attrs):
	if tag == "table":
	    self.handle_start_table(attrs)
        # we are only interested in tr tags if we are in the results table
        elif self._in_results_table and tag == "tr":
	    self.handle_start_tr(attrs)
        # we are only interested in td tags if we are in the results table
	elif self._in_results_table and tag == "td":
	    self.handle_start_td(attrs)
        # we are only interested in <a> tags if we are in the 6th td in
        # the results table.
        # UPDATE: It seems that, in the case of Chiltern, we are interested in
        # td 5.
	elif self._in_td and (self._td_count == 5 or self._td_count == 6) and tag == "a":
	    self.handle_start_a(attrs)
	# If the tag is not one of these then we aren't interested

    def handle_endtag(self, tag):
        # we only need to consider end tags if we are in the results table
	if self._in_results_table:
	    if tag == "table":
		self.handle_end_table()
	    if tag == "tr":
                self.handle_end_tr()
            if tag == "td":
		self.handle_end_td()

    def handle_start_table(self, attrs):
	for attr,value in attrs:
	    if attr == "class":
		if value == "cResultsForm":
		    self._in_results_table = True
		    break

    def handle_end_table(self):
        # If we see an end table tag, then note that we have left the
        # results table. This method is only called if we are in that table.
        self._in_results_table = False
	

    def handle_start_tr(self, attrs):
	# The first tr we meet in the results table is just headers
	# We will set a flag at the end of that tr to avoid creating
        # a blank PlanningApplication
	if self._past_header_row:
	    # Create a candidate result object
	    self._current_application = PlanningApplication()
	    self._td_count = 0

    def handle_end_tr(self):
	# If we are in the results table, and not finishing the header row
        # append the current result to the results list.
	if self._past_header_row:
	    self._results.addApplication(self._current_application)
	else:
	    # The first row of the results table is headers
            # We want to do nothing until after it
	    self._past_header_row = True	
	
    def handle_start_td(self, attrs):
        # increase the td count by one
	self._td_count += 1
        
        # note that we are now in a td
	self._in_td = True

    def handle_end_td(self):
        # note that we are now not in a td
	self._in_td = False

    def handle_start_a(self, attrs):
        # this method is only getting called if we are in the
        # 6th td of a non-header row of the results table.

        # go through the attributes of the <a> looking for one
        # named 'href'
        for attr,value in attrs:
	    if attr == "href":
                # the value of this tag is a relative url.
                # parse it so we can get the query string from it
		parsed_info_url = urlparse.urlparse(value)
                
		# the 4th part of the tuple is the query string
		query_string = parsed_info_url[4]

                # join this query string to the search URL, and store this as
                # the info URL of the current planning application
		self._current_application.info_url = urlparse.urljoin(self.base_url, value)

                # Join this query string to the comments URL, and store this as
                # the comments URL of the current planning application
                comments_url = urlparse.urljoin(self.base_url, comments_url_end)
                self._current_application.comment_url = "?".join([comments_url, query_string])

		# while we're here, let's follow some links to find the postcode...
                # the postcode is in an input tag in the property page. This page
                # can be found by following the info url.
                # The newlines in the info page need fixing.
		info_file_contents = fixNewlines(urllib2.urlopen(self._current_application.info_url).read())
		
		info_file_parser = PublicAccessInfoPageParser()
		info_file_parser.feed(info_file_contents)

		property_page_url = urlparse.urljoin(self._current_application.info_url, info_file_parser.property_page_url)
		
                # the newlines in this page need fixing
		property_file_contents = fixNewlines(urllib2.urlopen(property_page_url).read())
	
		property_file_parser = PublicAccessPropertyPageParser()
		property_file_parser.feed(property_file_contents)

                # Set the postcode on the current planning application from the
                # one found on the property page
                if property_file_parser.postcode is not None:
                    self._current_application.postcode = property_file_parser.postcode
                else:
                    # If there is no postcode in here, then we'll have to make do with regexing one out of the address.
                    self._current_application.postcode = getPostcodeFromText(self._current_application.address)

                # There is no need for us to look at any more attributes.
		break
	

    def handle_data(self, data):
	if self._in_td:
            # The first td contains the reference
	    if self._td_count == 1:
	        self._current_application.council_reference = data
                
            # The second td contains the date the application was received
	    elif self._td_count == 2:
                year, month, day = time.strptime(data, "%d/%m/%Y")[:3]
                received_date = datetime.date(year, month, day)

	        self._current_application.date_received = received_date
                
            # The third td contains the address
	    elif self._td_count == 3:
		#data = data.replace("^M","\n")
	        self._current_application.address = data
                
            # The fourth td contains the description
	    elif self._td_count == 4:
	        self._current_application.description = data
	    # 5 is status - we don't need it.
	    # 6 is a button - this is where we will get our postcode,
	    # comment_url, and info_url from (when handling the <a> tag).


    def getResultsByDayMonthYear(self, day, month, year):
        # First download the search form (in order to get a session cookie
        search_form_request = urllib2.Request(urlparse.urljoin(self.base_url, search_form_url_end))
        search_form_response = urllib2.urlopen(search_form_request)
        
        cookie_jar.extract_cookies(search_form_response, search_form_request)

        
        # We are only doing this first search in order to get a cookie
        # The paging on the site doesn't work with cookies turned off.

        search_data1 = urllib.urlencode({"searchType":"ADV",
                                         "caseNo":"",
                                         "PPReference":"",
                                         "AltReference":"",
                                         "srchtype":"",
                                         "srchstatus":"",
                                         "srchdecision":"",
                                         "srchapstatus":"",
                                         "srchappealdecision":"",
                                         "srchwardcode":"",
                                         "srchparishcode":"",
                                         "srchagentdetails":"",
                                         "srchDateReceivedStart":"%(day)02d/%(month)02d/%(year)d" %{"day":day ,"month": month ,"year": year}, 
                                         "srchDateReceivedEnd":"%(day)02d/%(month)02d/%(year)d" %{"day":day, "month":month, "year":year} })

        if self.debug:
            print search_data1


        search_url = urlparse.urljoin(self.base_url, search_results_url_end)
        request1 = urllib2.Request(search_url, search_data1)
        cookie_jar.add_cookie_header(request1)
        response1 = urllib2.urlopen(request1)

        # This search is the one we will actually use.
        # a maximum of 100 results are returned on this site,
        # hence setting "pagesize" to 100. I doubt there will ever
        # be more than 100 in one day in PublicAccess...
        # "currentpage" = 1 gets us to the first page of results
        # (there will only be one anyway, as we are asking for 100 results...)

#http://planning.york.gov.uk/PublicAccess/tdc/DcApplication/application_searchresults.aspx?szSearchDescription=Applications%20received%20between%2022/02/2007%20and%2022/02/2007&searchType=ADV&bccaseno=&currentpage=2&pagesize=10&module=P3

        search_data2 = urllib.urlencode((("szSearchDescription","Applications received between %(day)02d/%(month)02d/%(year)d and %(day)02d/%(month)02d/%(year)d"%{"day":day ,"month": month ,"year": year}), ("searchType","ADV"), ("bccaseno",""), ("currentpage","1"), ("pagesize","100"), ("module","P3")))

        if self.debug:
            print search_data2

        # This time we want to do a get request, so add the search data into the url
        request2_url = urlparse.urljoin(self.base_url, search_results_url_end + "?" + search_data2)

        request2 = urllib2.Request(request2_url)

        # add the cookie we stored from our first search
        cookie_jar.add_cookie_header(request2)

        response2 = urllib2.urlopen(request2)

        contents = fixNewlines(response2.read())

        if self.debug:
            print contents

        self.feed(contents)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()




class PublicAccessInfoPageParser(HTMLParser.HTMLParser):
    """A parser to get the URL for the property details page out of the
       info page (this url is needed in order to get the postcode of the
       application.
       """

    def __init__(self):
	HTMLParser.HTMLParser.__init__(self)

	self.property_page_url = None

    def handle_starttag(self, tag, attrs):
        """The URL of the property details page is contained in an <a> tag in
        an attribute with key 'A_btnPropertyDetails'. There is some garbage on
        either side of it which we will have to clear up before storing it...

        We go through the <a> tags looking for one with an attribute with
        key 'id' and value 'A_btnPropertyDetails'. When we find it we go through
        its attributes looking for one with key 'href' - the value of this attribute
        contains the URL we want, after a bit of tidying up.

        Once we have got the URL, there is no need for us to look at any more <a> tags.
        """
	if tag == "a" and self.property_page_url is None:
            
            #print attrs
	    if attrs.count(("id","A_btnPropertyDetails")) > 0:
		for attr,value in attrs:
		    if attr == "href":
			the_link = value

			# this may have some garbage on either side of it...
			# let's strip that off

                        # If the stripping fails, take the whole link

                        # the garbage on the left is separated by whitespace.
                        # the garbage on the right is separated by a "'".
                        try:
                            self.property_page_url = the_link.split()[1].split("'")[0]
                        except IndexError:
                            self.property_page_url = the_link


class PublicAccessPropertyPageParser(HTMLParser.HTMLParser):
    """A parser to get the postcode out of the property details page."""
    def __init__(self):
	HTMLParser.HTMLParser.__init__(self)

	self.postcode = None

    def handle_starttag(self, tag, attrs):
        """The postcode is contained in an <input> tag.
        This tag has an attribute 'name' with value postcode.
        It also has an attribute 'value' with value the postcode of this application.

        We go through the input tags looking for one with an attribute with
        key 'name' and value 'postcode'. When we find one,
        we look through its attributes for one with key 'value' - we store the value of this
        attribute as self.postcode.

        Once we have the postcode, there is no need to look at any more input tags.
        """
        
	if tag == "input" and self.postcode is None:
	    if attrs.count(("name","postcode")) > 0:
		for attr,value in attrs:
		    if attr == "value":
			self.postcode = value


if __name__ == '__main__':
    day = 20
    month = 11
    year = 2007

    parser = PublicAccessParser("Chester-le-Street", "Chester-le-Street", "http://planning.chester-le-street.gov.uk/publicaccess/tdc/", True)
    print parser.getResults(day, month, year)
    
