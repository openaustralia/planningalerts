#!/usr/bin/python

import cgi
import cgitb; cgitb.enable(display=0, logdir="/tmp")

import urllib, urllib2
import HTMLParser
import urlparse
import datetime, time

# This needs a page number inserting
search_url = "http://www.southoxon.gov.uk/ccm/planning/ApplicationList.jsp?PAGE=%d"

# This needs the council reference
comment_url = "https://forms.southoxon.gov.uk/ufs/ufsmain?formid=PLANNINGCOMMENT&PLNGAPPL_REFERENCE=%(reference)s"

authority_name = "South Oxfordshire District Council"
authority_short_name = "South Oxfordshire"


from PlanningUtils import fixNewlines, \
                          getPostcodeFromText, \
                          PlanningAuthorityResults, \
                          PlanningApplication

class SouthOxfordshireParser(HTMLParser.HTMLParser):
    """In this case we'll take the date, so that we can avoid doing dowloads for
    the other days in this week's file. This date should be a datetime.date object.
    """
    def __init__(self):
	HTMLParser.HTMLParser.__init__(self)

        self._requested_date = None

        # We'll keep a count of the number of tables we have seen.
        # All the interesting stuff is in table 3
        self._table_count = 0

        # While inside table 3, we'll keep a count of the number of
        # <td>s we have seen. What is in which numbered <td> is detailed below.
        # 1 reference
        # 3 place and description
        # 5 date received
        # 2 and 4 are just padding
        self._td_count = 0

        # This is just a flag to say that we are now ready to get the reference
        # from the next bit of data
        self._get_reference = False

        self._data = ''

        # this will hold the application we are currently working on.
        self._current_application = None
        
        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(authority_name, authority_short_name)

    def handle_starttag(self, tag, attrs):
        # if we see a table tag, increment the table count.
        if tag == 'table':
            self._table_count += 1
            
        # we are only interested in other tags if we are in table 3. 
        if self._table_count == 3:
            
            # If we are starting a <tr>, create a new PlanningApplication object
            # for the application currently being processed
            if tag == 'tr':
                self._current_application = PlanningApplication()

            # if we see a td, increment the <td> count.
            if tag == 'td':
                self._td_count += 1

            # if we are in the first <td>, and we see a link,
            # then it is to the info page for this applicaion.
            if tag == 'a' and self._td_count == 1:
                for key, value in attrs:
                    if key == 'href':
                        url_end = value
                        self._current_application.info_url = urlparse.urljoin(search_url,url_end)

                        # We now know that the next bit of data is the reference
                        self._get_reference = True
                        
                        # href is the only attribute we are interested in.
                        break

    def handle_endtag(self, tag):
        # There is no need to do anything unless we are in table 3.
        if self._table_count == 3:

            # The end <tr> indicates that the current application is finished.
            # Now we can fetch the info_page to get the address, postcode,
            # and description.
            # If we don't have a reference, then we are in the header row,
            # which we don't want.
            # There is no point in doing this if the date is not the requested one.
            
            if tag == 'tr' and \
                   self._current_application.council_reference is not None and \
                   self._current_application.date_received == self._requested_date:
                
                info_page_parser = SouthOxfordshireInfoURLParser()
                info_page_parser.feed(urllib2.urlopen(self._current_application.info_url).read())

                self._current_application.address = info_page_parser.address
                self._current_application.postcode = getPostcodeFromText(info_page_parser.address)
                self._current_application.description = info_page_parser.description

                # Add the current application to the results set
                self._results.addApplication(self._current_application)

            # At the end of the 5th <td>, self._data should contain
            # the received date of the application.
            if tag == 'td' and self._td_count == 5:
                app_year, app_month, app_day = tuple(time.strptime(self._data, "%d %B %Y")[:3])
                self._current_application.date_received = datetime.date(app_year, app_month, app_day)
                    
                self._data = ''
                self._td_count = 0

    def handle_data(self, data):
        # There is no need to do anything if we aren't in table 3.
        if self._table_count == 3:
            # If we are in the first <td>, and the get_reference flag is set,
            # then the next data is the reference.
            if self._td_count == 1 and self._get_reference:
                self._current_application.council_reference = data

                # The comment url can now be made, as it depends only on the reference.
                # On this site, the link to the comment page is only displayed once
                # the planning authority has decided who is handling this application
                # and has opened consultations. The link below works straight away,
                # and also works for apps for which the consultation period is over.
                # I have no idea if anything is actually done with these comments if
                # it is followed too early...
                self._current_application.comment_url = comment_url %{'reference': self._current_application.council_reference}

                # Set the get_reference flag back to False.
                self._get_reference = False

            # If we are in the 5th <td>, then we need to collect all the data together
            # before we can use it. This is actually processed in handle_endtag.
            if self._td_count == 5:
                self._data += data

    def handle_entityref( self, ref ):
        # We might have some entity_refs to clear up.
        # there is no need to bother with this if we aren't in the results table.
        if self._table_count == 3 and self._td_count == 5:
            if ref == 'nbsp':
                self._data += ' '


    def getResultsByDayMonthYear(self, day, month, year):
        """This will return an ApplicationResults object containg the
        applications for the date passed in."""

        today = datetime.date.today()
        self.requested_date = datetime.date(year, month, day)
        delta = today - self.requested_date

        # to get the correct page, we need
        # page ((days mod 7) + 1)
        page_number = delta.days/7 + 1

        response = urllib2.urlopen(search_url %page_number)

        self.feed(response.read())

        return self._results


    def getResults(self, day, month, year):
        return getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

class SouthOxfordshireInfoURLParser(HTMLParser.HTMLParser):
    """This parser is to get the description and address out of the info page
    for a South Oxfordshire application."""

    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)

        self.address = None
        self.description = None

        # These two states will be set to:
        # 0 - if we haven't yet got that bit
        # 1 - if we are currently working on it
        # 2 - if we have finished
        self._address_state = 0
        self._description_state = 0

        # We well need to know whether or not we are in a <td>
        self._in_td = False

        # This is used for collecting together date which comes in several bits.
        self._data = ''
        
    def handle_starttag(self, tag, attrs):
        # If we see the start of a <td> and we are still interested in some data
        # then set the td flag to true, and blank the data
        if tag == 'td' and (self._address_state < 2 or self._description_state < 2):
            self._in_td = True
            self._data = ''

    def handle_endtag(self, tag):
        if tag == 'td' and (self._address_state < 2 or self._description_state < 2):
            # If we are working on the description,
            # set description from _data and note that we need to work on it no more.
            if self._description_state == 1:
                self.description = self._data
                self._description_state = 2


            # If we are working on the address,
            # set address from _data and note that we need to work on it no more.
            elif self._address_state == 1:
                self.address = self._data
                self._address_state = 2

            # If we see data which says 'Descripton',
            # then set the description state to working.
            elif self._data.strip() == 'Description':
                self._description_state = 1
                
            # If we see data which says 'Location',
            # then set the addresss state to working.
            elif self._data.strip() == 'Location':
                self._address_state = 1

            # Note that we are leaving the <td>
            self._in_td = False
            
    def handle_data(self, data):
        # if we are in a td, and we are still interested in the data for something,
        # append the current bit to self._data
        if self._in_td and (self._address_state < 2 or self._description_state < 2):
            self._data += data


# TODO

# find out what time of day this is run - does it matter that
# we aren't being careful with daylight saving time etc.

# Can we check that scraped email address really is
# an email address?

if __name__ == "__main__":
    form = cgi.FieldStorage()
    day = form.getfirst('day')
    month = form.getfirst('month')
    year = form.getfirst('year')

    parser = SouthOxfordshireParser()
    

    print "Content-Type: text/xml"     # XML is following
    print
    print xml                          # print the xml
