#!/usr/local/bin/python

import urllib, urllib2

import urlparse
import datetime
import re

import BeautifulSoup

import cookielib

cookie_jar = cookielib.CookieJar()


from PlanningUtils import fixNewlines, getPostcodeFromText, PlanningAuthorityResults, PlanningApplication


def index_or_none(a_list, item):
    """
    Returns the index of item in a_list, or None, if it isn't in the list.
    """
    return a_list.count(item) and a_list.index(item)

class PublicAccessParser(object):
    """This is the class which parses the PublicAccess search results page.
    """

    search_form_url_end = "DcApplication/application_searchform.aspx"
    search_results_url_end = "DcApplication/application_searchresults.aspx"
    comments_url_end = "DcApplication/application_comments_entryform.aspx"

    # For some sites (Hambleton, for example) we need to leave in the empty
    # strings.
    data_template = (
            ("searchtype", "ADV"),
            ("caseNo", ""),
            ("PPReference", ""),
            ("AltReference", ""),
            ("srchtype", ""),
            ("srchstatus", ""),
            ("srchdecision", ""),
            ("srchapstatus", ""),
            ("srchappealdecision", ""),
            ("srchwardcode", ""),
            ("srchparishcode", ""),
            ("srchagentdetails", ""),
            ("srchDateReceivedStart", "%(day)02d/%(month)02d/%(year)04d"),
            ("srchDateReceivedEnd", "%(day)02d/%(month)02d/%(year)04d"),
            ("srchDateValidStart", ""),
            ("srchDateValidEnd", ""),
            ("srchDateCommitteeStart", ""),
            ("srchDateCommitteeEnd", ""),
            )

    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):
        
        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        # The object which stores our set of planning application results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

    def fetch_setting_cookie(self, url, data=None):
        request = urllib2.Request(url, data)
        cookie_jar.add_cookie_header(request)
        response = urllib2.urlopen(request)
        cookie_jar.extract_cookies(response, request)
        return response

    def get_search_page(self):
        return self.fetch_setting_cookie(urlparse.urljoin(self.base_url, self.search_form_url_end))

    def get_response_1(self, data):
        return self.fetch_setting_cookie(urlparse.urljoin(self.base_url, self.search_results_url_end), data)

#     def get_data_2(self, day, month, year):

#         search_data2 = urllib.urlencode((("szSearchDescription","Applications received between %(day)02d/%(month)02d/%(year)d and %(day)02d/%(month)02d/%(year)d"%{"day":day ,"month": month ,"year": year}), ("searchType","ADV"), ("bccaseno",""), ("currentpage","1"), ("pagesize","100"), ("module","P3")))

#         if self.debug:
#             print search_data2

#         return search_data2

#     def get_response_2(self, data):
#         # This time we want to do a get request, so add the search data into the url
#         url = urlparse.urljoin(self.base_url, self.search_results_url_end + "?" + data)
#         return self.fetch_setting_cookie(url)

    def get_data_1(self, replacement_dict):
        # It seems urllib.urlencode isn't happy with the generator here,
        # so we'd best make it a tuple...
        data_tuple = tuple(((key, value %replacement_dict) for (key, value) in self.data_template))

        data = urllib.urlencode(data_tuple)
        return data
        
    def get_replacement_dict(self, day, month, year, search_response):
        return {"day": day, 
                "month": month, 
                "year": year}
    
    def get_useful_response(self, day, month, year):
        # We're only doing this to get a cookie
        search_response = self.get_search_page()

        replacement_dict = self.get_replacement_dict(day, month, year, search_response)
        data = self.get_data_1(replacement_dict)

        return self.get_response_1(data)

    def get_contents(self, day, month, year):
        useful_response = self.get_useful_response(day, month, year)

        contents = fixNewlines(useful_response.read())

        if self.debug:
            print contents

        return contents

    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        contents = self.get_contents(day, month, year)

        soup = BeautifulSoup.BeautifulSoup(contents)

        results_table = soup.find("table", {"class": "cResultsForm"})

        # First, we work out what column each thing of interest is in from the headings
        headings = [x.string for x in results_table.findAll("th")]

        ref_col = index_or_none(headings, "Application Ref.") or \
            index_or_none(headings, "Case Number") or \
            index_or_none(headings, "Application Number")

        address_col = headings.index("Address")
        description_col = headings.index("Proposal")

        comments_url = urlparse.urljoin(self.base_url, self.comments_url_end)


        for tr in results_table.findAll("tr")[1:]:
            application = PlanningApplication()

            application.date_received = search_date

            tds = tr.findAll(re.compile("t[dh]"))

            application.council_reference = tds[ref_col].string.strip()
            application.address = tds[address_col].string.strip()
            application.description = tds[description_col].string.strip()

            application.info_url = urlparse.urljoin(self.base_url, tr.a['href'])

            # We need the query string from this url to make the comments_url
            query_string = urlparse.urlsplit(application.info_url)[3]

            # This is probably slightly naughty, but I'm just going to add the querystring
            # on to the end manually
            application.comment_url = "%s?%s" %(comments_url, query_string)

            self._results.addApplication(application)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

class HambletonParser(PublicAccessParser):
    data_template = PublicAccessParser.data_template + (("s8fid", "%(s8fid)s"),)

    def get_replacement_dict(self, day, month, year, search_response):
        replacement_dict = super(HambletonParser, self).get_replacement_dict(day, month, year, search_response)

        # We need an input s8fid from this.
        # BeautifulSoup doesn't like it, so we'll have to use a regex.
        search_contents = search_response.read()

        #<input type=hidden name="s8fid" value="112455787981" />
        s8fid_re = re.compile('<input[^>]*name="s8fid" value="(\d*)" />')

        replacement_dict["s8fid"] = s8fid_re.search(search_contents).groups()[0]

        return replacement_dict


if __name__ == '__main__':
    day = 11
    month = 6
    year = 2009

#    parser = PublicAccessParser("East Northants", "East Northants", "http://publicaccesssrv.east-northamptonshire.gov.uk/PublicAccess/tdc/", True)
#    parser = PublicAccessParser("Cherwell District Council", "Cherwell", "http://cherweb.cherwell-dc.gov.uk/publicaccess/tdc/", True)
#    parser = HambletonParser("Hambleton District Council", "Hambleton", "http://planning.hambleton.gov.uk/publicaccess/tdc/", True)
#    parser = PublicAccessParser("Durham City Council", "Durham", "http://publicaccess.durhamcity.gov.uk/publicaccess/tdc/", True)
#    parser = PublicAccessParser("Moray Council", "Moray", "http://public.moray.gov.uk/publicaccess/tdc/", True)
#    parser = PublicAccessParser("Sheffield City Council", "Sheffield", "http://planning.sheffield.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("London Borough of Barking and Dagenham", "Barking and Dagenham", "http://paweb.barking-dagenham.gov.uk/PublicAccess/tdc/")
#    parser = PublicAccessParser("Reading Borough Council", "Reading", "http://planning.reading.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("Lancaster City Council", "Lancaster", "http://planapps.lancaster.gov.uk/PublicAccess/tdc/")
#    parser = PublicAccessParser("Harrogate Borough Council", "Harrogate", "http://publicaccess.harrogate.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("West Lancashire District Council", "West Lancashire", "http://publicaccess.westlancsdc.gov.uk/PublicAccess/tdc/")
    parser = PublicAccessParser("Torbay Council", "Torbay", "http://www.torbay.gov.uk/publicaccess/tdc/")
#    parser = PublicAccessParser("Oxford City Council", "Oxford", "http://uniformpublicaccess.oxford.gov.uk/publicaccess/tdc/", debug=True)
    print parser.getResults(day, month, year)
    
