import urllib2
import urllib
import urlparse
import cgi
import re
import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

# Date format to enter into search boxes
date_format = "%d/%m/%Y"

# Regex for getting the application code
# (needed for the comments url, when it exists)
app_code_regex = re.compile("PARAM0=(\d*)")


class PlanningExplorerParser:
    # If this authority doesn't have a comments page, 
    # then set this email_address to an address for the 
    # planning department, and it will be used in lieu of
    # a comments url.
    comments_email_address = None

    # These are the directories where the info urls, and search urls,
    # usually live underneath the base_url. 
    # If these are different for a particular
    # authority, then they can be overridden in a subclass.
    info_url_path = "MVM/Online/Generic/"
    search_url_path = "MVM/Online/PL/GeneralSearch.aspx"
    
    # This is the most common place for comments urls to live
    # The %s will be filled in with an application code
    comments_path = "MVM/Online/PL/PLComments.aspx?pk=%s"

    # Most authorities don't need the referer header on the post
    # request. If one does, override this in the subclass
    use_referer = False

    # Some authorities won't give us anything back if we use the
    # python urllib2 useragent string. In that case, override this
    # in a subclass to pretend to be firefox.
    use_firefox_user_agent = False

    # This is the most common css class of the table containing the
    # the search results. If it is different for a particular authority
    # it can be overridden in a subclass
    results_table_attrs = {"class": "ResultsTable"}

    # These are the most common column positions for the
    # council reference, the address, and the description
    # in the results table.
    # They should be overridden in subclasses if they are different
    # for a particular authority.
    reference_td_no = 0
    address_td_no = 1
    description_td_no = 2

    def _modify_response(self, response):
        """For most sites, we have managed to get all the apps on a
        single page by choosing the right parameters.
        If that hasn't been possible, override this method to get a
        new response object which has all the apps in one page.
        (See, for example, Hackney).
        """
        return response

    def _find_trs(self, results_table):
        """Normally, we just want a list of all the trs except the first one
        (which is usually a header).
        If the authority requires a different list of trs, override this method.
        """
        return results_table.findAll("tr")[1:]

    def _sanitisePostHtml(self, html):
        """This method can be overriden in subclasses if the
        html that comes back from the post request is bad, and
        needs tidying up before giving it to BeautifulSoup."""
        return html

    def _sanitiseInfoUrl(self, url):
        """If an authority has info urls which are for some reason full
        of crap (like Broadland does), then this method should be overridden
        in order to tidy them up."""
        return url

    def _getHeaders(self):
        """If the authority requires any headers for the post request,
        override this method returning a dictionary of header key to 
        header value."""
        headers = {}
        
        if self.use_firefox_user_agent:
            headers["User-Agent"] = "Mozilla/5.0 (X11; U; Linux i686; en-GB; rv:1.8.1.10) Gecko/20071126 Ubuntu/7.10 (gutsy) Firefox/2.0.0.10"

        if self.use_referer:
            headers["Referer"] = self.search_url

        return headers

    def _getPostData(self, asp_args, search_date):
        """Accepts asp_args (a tuple of key value pairs of the pesky ASP
        parameters, and search_date, a datetime.date object for the day
        we are searching for.

        This seems to be the most common set of post data which is needed
        for PlanningExplorer sites. It won't work for all of them, so
        will sometimes need to be overridden in a subclass.

        The parameter edrDateSelection is often not needed. 
        It is needed by Charnwood though, so I've left it in 
        to keep things simple.
        """
        year_month_day = search_date.timetuple()[:3]

        post_data = urllib.urlencode(asp_args + (
                ("_ctl0", "DATE_RECEIVED"),
                ("rbGroup", "_ctl5"),
                ("_ctl7_hidden", urllib.quote('<DateChooser Value="%d%%2C%d%%2C%d"><ExpandEffects></ExpandEffects></DateChooser>' %year_month_day)),
                ("_ctl8_hidden", urllib.quote('<DateChooser Value="%d%%2C%d%%2C%d"><ExpandEffects></ExpandEffects></DateChooser>' %year_month_day)),
                ("edrDateSelection", "1"),
                ("csbtnSearch", "Search"),
                ("cboNumRecs", "99999"),
                ))
        
        return post_data

    def _getPostCode(self):
        """In most cases, the postcode can be got from the address in 
        the results table. Some councils put the address there without the
        postcode. In this case we will have to go to the info page to get
        the postcode. This should be done by overriding this method with
        one that parses the info page."""

        return getPostcodeFromText(self._current_application.address)
        
    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):

        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.search_url = urlparse.urljoin(base_url, self.search_url_path)
        self.info_url_base = urlparse.urljoin(self.base_url, self.info_url_path)
    
        self.debug = debug

        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

    def getResultsByDayMonthYear(self, day, month, year):
        search_date = datetime.date(year, month, day)

        # First do a get, to get some state
        get_request = urllib2.Request(self.search_url)
        get_response = urllib2.urlopen(get_request)

        html = get_response.read()

        # We need to find those ASP parameters such as __VIEWSTATE
        # so we can use them in the next POST
        asp_args_regex = re.compile('<input[^>]*name=\"(__[A-Z]*)\"[^>]*value=\"([^\"]*)\"[^>]*>')

        # re.findall gets us a list of key value pairs.
        # We want to concatenate it with a tuple, so we must
        # make it a tuple
        asp_args = tuple(re.findall(asp_args_regex, html))

        # The post data needs to be different for different councils
        # so we have a method on each council's scraper to make it.
        post_data = self._getPostData(asp_args, search_date)
        
        headers = self._getHeaders()

        request = urllib2.Request(self.search_url, post_data, headers)

        post_response = urllib2.urlopen(request)

        # We have actually been returned here by an http302 object
        # moved, and the response called post_response is really a get.

        # In some cases, we can't get the page size set high
        # until now. In that case, override _modify_response
        # so that we get back a response with all the apps on one page.
        # We pass in headers so that any
        post_response = self._modify_response(post_response)

        html = self._sanitisePostHtml(post_response.read())

        soup = BeautifulSoup(html)

        results_table = soup.find("table", attrs=self.results_table_attrs)

        # If there is no results table, then there were no apps on that day.
        if results_table:
            trs = self._find_trs(results_table)

            self._current_application = None

            # The first tr is just titles, cycle through the trs after that
            for tr in trs:
                self._current_application = PlanningApplication()

                # There is no need to search for the date_received, it's what
                # we searched for            
                self._current_application.date_received = search_date

                tds = tr.findAll("td")

                for td_no in range(len(tds)):
                    if td_no == self.reference_td_no:
                        # This td contains the reference number and a link to details
                        self._current_application.council_reference = tds[td_no].a.string

                        relative_info_url =  self._sanitiseInfoUrl(tds[td_no].a['href'])

                        self._current_application.info_url = urlparse.urljoin(self.info_url_base, relative_info_url)


                        # What about a comment url?
                        # There doesn't seem to be one, so we'll use the email address
                        if self.comments_email_address is not None:
                            # We're using the email address, as there doesn't seem
                            # to be a web form for comments
                            self._current_application.comment_url = self.comments_email_address
                        else:
                            # This link contains a code which we need for the comments url
                            # (on those sites that use it)
                            application_code = app_code_regex.search(relative_info_url).groups()[0]

                            relative_comments_url = self.comments_path %(application_code)
                            self._current_application.comment_url = urlparse.urljoin(self.base_url, relative_comments_url)

                    elif td_no == self.address_td_no:
                        # If this td contains a div, then the address is the
                        # string in there - otherwise, use the string in the td.
                        if tds[td_no].div is not None:
                            address = tds[td_no].div.string
                        else:
                            address = tds[td_no].string

                        self._current_application.address = address

                        self._current_application.postcode = self._getPostCode()

                    elif td_no == self.description_td_no:
                        if tds[td_no].div is not None:
                            # Mostly this is in a div
                            # Use the empty string if the description is missing
                            description = tds[td_no].div.string or ""
                        else:
                            # But sometimes (eg Crewe) it is directly in the td.
                            # Use the empty string if the description is missing
                            description = tds[td_no].string or ""

                        self._current_application.description = description

                self._results.addApplication(self._current_application)

        return self._results


    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()


class BroadlandLike:
    # FIXME - BroadlandLike authorities don't have postcodes on their site, but
    # they do have grid references. We should use these.

    results_table_attrs = {"class": "display_table"}

    info_url_path = "Northgate/PlanningExplorer/Generic/"
    search_url_path = "Northgate/PlanningExplorer/GeneralSearch.aspx"

    use_firefox_user_agent = True
    use_referer = True

    def _getPostData(self, asp_args, search_date):
        post_data = urllib.urlencode(asp_args + (
                ("cboSelectDateValue", "DATE_RECEIVED"),
                ("rbGroup", "rbRange"),
                ("dateStart", search_date.strftime(date_format)),
                ("dateEnd", search_date.strftime(date_format)),
                ("cboNumRecs", "99999"),
                ("csbtnSearch", "Search"),
                ))

        return post_data


    def _sanitiseInfoUrl(self, url):
        """The broadland info urls arrive full of rubbish. This method tidies
        them up."""

        # We need to
        # 1) Remove whitespace
        # 2) Remove &#xA; and &#xD;

        ws_re = re.compile("(?:(?:\s)|(?:&#x\w;))*")

        return ''.join(ws_re.split(url))



class BlackburnParser(PlanningExplorerParser):
    use_firefox_user_agent = True

class BroadlandParser(BroadlandLike, PlanningExplorerParser):
    # FIXME - is http://secure.broadland.gov.uk/mvm/Online/PL/GeneralSearch.aspx
    # a better url for Broadland?

    def _sanitisePostHtml(self, html):
        """The page that comes back from the post for the broadland site
        has a broken doctype declaration. We need to tidy that up before
        giving it to BeautifulSoup."""

        # This is what it looks like - note the missing close doublequote
        #<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd>

        # Split on the broken doctype and join with the doctype with
        # closing quote.

        html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'.join(html.split('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd>'))

        return html

class CamdenParser(BroadlandLike, PlanningExplorerParser):
    comments_path = "Northgate/PlanningExplorer/PLComments.aspx?pk=%s"

class CharnwoodParser(PlanningExplorerParser):
    use_firefox_user_agent = True

class CreweParser(PlanningExplorerParser):
    use_firefox_user_agent = True
    address_td_no = 4

    def _getPostData(self, asp_args, search_date):
        year_month_day = search_date.timetuple()[:3]

        post_data = urllib.urlencode(asp_args + (
                ("drDateReceived:_ctl0_hidden", urllib.quote('<DateChooser Value="%d%%2C%d%%2C%d"><ExpandEffects></ExpandEffects></DateChooser>' %year_month_day)),
                ("drDateReceivedxxctl0_input", search_date.strftime(date_format)),
                ("drDateReceived:_ctl1_hidden", urllib.quote('<DateChooser Value="%d%%2C%d%%2C%d"><ExpandEffects></ExpandEffects></DateChooser>' %year_month_day)),
                ("drDateReceivedxxctl1_input", search_date.strftime(date_format)),
                ("cboNumRecs", "99999"),
                ("csbtnSearch", "Search"),
                ))

        return post_data


class EastStaffsParser(PlanningExplorerParser):
    use_firefox_user_agent = True

    address_td_no = 4
    description_td_no = 1


class EppingForestParser(PlanningExplorerParser):
    use_firefox_user_agent = True

    address_td_no = 3
    description_td_no = 1

class ForestHeathParser(BroadlandLike, PlanningExplorerParser):
    pass

class HackneyParser(PlanningExplorerParser):
    # FIXME - This will only get the first ten records on this
    # day. Need to deal with paging.

    use_firefox_user_agent = True

    address_td_no = 6
    description_td_no = 5

    def _modify_response(self, response):
        # In order to make sure we don't have to worry about any paging,
        # We'll fetch this url again with PS=99999.
        real_url_tuple = urlparse.urlsplit(response.geturl())

        query_string = real_url_tuple[3]
        
        # Get the query as a list of key, value pairs
        parsed_query_list = list(cgi.parse_qsl(query_string))

        # Go through the query string replacing any PS parameters
        # with PS=99999
        
        for i in range(len(parsed_query_list)):
            key, value = parsed_query_list[i]

            if key == "PS":
                value = "99999"
                parsed_query_list[i] = (key, value)

        new_query_string = urllib.urlencode(parsed_query_list)
        
        new_url_tuple = real_url_tuple[:3] + (new_query_string,) + real_url_tuple[4:]
        
        new_url = urlparse.urlunsplit(new_url_tuple)        
        new_request = urllib2.Request(new_url, None, self._getHeaders())
        new_response = urllib2.urlopen(new_request)

        return new_response


    def _getPostData(self, asp_args, search_date):
        post_data = urllib.urlencode(asp_args + (
                ("ctl00", "DATE_RECEIVED"),
                ("rbGroup", "ctl05"),
                ("ctl07_input", search_date.strftime(date_format)),
                ("ctl08_input", search_date.strftime(date_format)),
                ("edrDateSelection", "1"),
                ("csbtnSearch", "Search"),
                ))

        return post_data
            
class KennetParser(BroadlandLike, PlanningExplorerParser):
    comments_path = "Northgate/PlanningExplorer/PLComments.aspx?pk=%s"
    
class LincolnParser(PlanningExplorerParser):
    use_firefox_user_agent = True
    results_table_attrs = {"class": "resultstable"}
    
class LiverpoolParser(PlanningExplorerParser):
    comments_email_address = "planningandbuildingcontrol@liverpool.gov.uk"
    use_firefox_user_agent = True
    use_referer = True

    results_table_attrs = {"xmlns:mvm":"http://www.mvm.co.uk"}

    info_url_path = "mvm/"
    search_url_path = "mvm/planningsearch.aspx"

    def _find_trs(self, results_table):
        """In this case we are after all trs except the first two which have a
        class attribute row0 or row1."""
        return results_table.findAll("tr", {"class":["row0", "row1"]})[3:]

    def _getPostData(self, asp_args, search_date):
        post_data = urllib.urlencode(asp_args + (
                ("dummy", "dummy field\tused for custom\tvalidator"),
                ("drReceived$txtStart", search_date.strftime(date_format)),
                ("drReceived$txtEnd", search_date.strftime(date_format)),
                ("cboNumRecs", "99999"),
                ("cmdSearch", "Search"),
                ))

        return post_data

    def _sanitiseInfoUrl(self, url):
        """The liverpool info urls arrive full of rubbish. This method tidies
        them up."""

        # We need to
        # 1) Remove whitespace
        # 2) Remove &#xA; and &#xD;

        ws_re = re.compile("(?:(?:\s)|(?:&#x\w;))*")

        return ''.join(ws_re.split(url))

# FIXME - Merton needs to be done here when it is back up.

class MertonParser(PlanningExplorerParser):
    use_firefox_user_agent = True
    
class ShrewsburyParser(PlanningExplorerParser):
    use_firefox_user_agent = True

class SouthNorfolkParser(PlanningExplorerParser):
    use_firefox_user_agent = True

class SouthShropshireParser(PlanningExplorerParser):
    comments_email_address = "planning@southshropshire.gov.uk"
    use_firefox_user_agent = True
    info_url_path = "MVM/Online/PL/"

    def _getPostData(self, asp_args, search_date):
        local_date_format = "%d-%m-%Y"
        year, month, day = search_date.timetuple()[:3]

        post_data = urllib.urlencode(asp_args + (
                ("edrDateSelection:htxtRange", "radRangeBetween"),
                ("cboDateList", "DATE_RECEIVED"),
                ("edrDateSelection:txtStart", search_date.strftime(local_date_format)),
                ("edrDateSelection:txtEnd", search_date.strftime(local_date_format)),
                ("edrDateSelection:txtDateReceived", "%(day)d-%(month)d-%(year)d~%(day)d-%(month)d-%(year)d" %({"day":day, "month":month, "year":year})),
                ("cboNumRecs", "99999"),
                ("csbtnSearch", "Search"),
                ))
        
        return post_data

class SouthTynesideParser(BroadlandLike, PlanningExplorerParser):
    # Unlike the other BroadlandLike sites, there are postcodes :-)
    pass


class StockportParser(PlanningExplorerParser):
    comments_email_address = "admin.dc@stockport.gov.uk"
    info_url_path = "MVM/Online/PL/"

    def _getPostData(self, asp_args, search_date):
        post_data = urllib.urlencode(asp_args + (
            ("drDateReceived:txtStart", search_date.strftime(date_format)),
            ("drDateReceived:txtEnd", search_date.strftime(date_format)),
            ("cboNumRecs", "99999"),
            ("csbtnSearch", "Search"),),
            )

        return post_data

class SwanseaParser(BroadlandLike, PlanningExplorerParser):
    # Unlike the other BroadlandLike sites, there are postcodes :-)
    pass

class TamworthParser(PlanningExplorerParser):
    comments_email_address = "planningadmin@tamworth.gov.uk"
    use_firefox_user_agent = True
    info_url_path = "MVM/Online/PL/"

class TraffordParser(PlanningExplorerParser):
    # There are no postcodes on the Trafford site.
    use_firefox_user_agent = True
    address_td_no = 3

class WestOxfordshireParser(PlanningExplorerParser):
    address_td_no = 3
    description_td_no = 1

    use_firefox_user_agent = True

class WalthamForestParser(PlanningExplorerParser):
    address_td_no = 2
    description_td_no = 3

    search_url_path = "PlanningExplorer/GeneralSearch.aspx"
    info_url_path = "PlanningExplorer/Generic/"
    use_firefox_user_agent = True

    def _getPostData(self, asp_args, search_date):
        post_data = urllib.urlencode(asp_args + (
                ("txtApplicantName", ""),
                ("txtAgentName", ""),
                ("cboStreetReferenceNumber", ""),
                ("txtProposal", ""),
                ("cboWardCode", ""),
                ("cboParishCode", ""),
                ("cboApplicationTypeCode", ""),
                ("cboDevelopmentTypeCode", ""),
                ("cboStatusCode", ""),
                ("cboSelectDateValue", "DATE_RECEIVED"),
                ("cboMonths", "1"),
                ("cboDays", "1"),
                ("rbGroup", "rbRange"),
                ("dateStart", search_date.strftime(date_format)),
                ("dateEnd", search_date.strftime(date_format)),
                #&dateStart=01%2F03%2F2008&dateEnd=01%2F04%2F2008&
                ("edrDateSelection", ""),
                ("csbtnSearch", "Search"),
                ))

        print post_data
        return post_data


#txtApplicantName=
#txtAgentName=
#cboStreetReferenceNumber=
#txtProposal=
#cboWardCode=
#cboParishCode=
#cboApplicationTypeCode=
#cboDevelopmentTypeCode=
#cboStatusCode=
#cboSelectDateValue=DATE_RECEIVED
#cboMonths=1
#cboDays=1
#rbGroup=rbRange
#dateStart=01%2F03%2F2008
#dateEnd=01%2F04%2F2008
#edrDateSelection=
#csbtnSearch=Search

if __name__ == '__main__':
    # NOTE - 04/11/2007 is a sunday
    # I'm using it to test that the scrapers behave on days with no apps.
    
    #parser = BlackburnParser("Blackburn With Darwen Borough Council", "Blackburn", "http://195.8.175.6/")
    #parser = BroadlandParser("Broadland Council", "Broadland", "http://www.broadland.gov.uk/")
    #parser = CamdenParser("London Borough of Camden", "Camden", "http://planningrecords.camden.gov.uk/")
    #parser = CharnwoodParser("Charnwood Borough Council", "Charnwood", "http://portal.charnwoodbc.gov.uk/")
    #parser = CreweParser("Crewe and Nantwich Borough Council", "Crewe and Nantwich", "http://portal.crewe-nantwich.gov.uk/")
    #parser = EastStaffsParser("East Staffordshire Borough Council", "East Staffs", "http://www2.eaststaffsbc.gov.uk/")
    #parser = EppingForestParser("Epping Forest District Council", "Epping Forest", "http://plan1.eppingforestdc.gov.uk/")
    #parser = ForestHeathParser("Forest Heath District Council", "Forest Heath", "http://195.171.177.73/")
    #parser = HackneyParser("London Borough of Hackney", "Hackney", "http://www.hackney.gov.uk/servapps/")
    #parser = KennetParser("Kennet District Council", "Kennet", "http://mvm-planning.kennet.gov.uk/")
    #parser = LincolnParser("Lincoln City Council", "Lincoln", "http://online.lincoln.gov.uk/")
    #parser = LiverpoolParser("Liverpool City Council", "Liverpool", "http://www.liverpool.gov.uk/")
    #parser = ShrewsburyParser("Shrewsbury and Atcham Borough Council", "Shrewsbury", "http://www2.shrewsbury.gov.uk/")
    #parser = SouthNorfolkParser("South Norfolk Council", "South Norfolk", "http://planning.south-norfolk.gov.uk/")
    #parser = SouthShropshireParser("South Shropshire District Council", "South Shropshire", "http://194.201.44.102/")
    #parser = SouthTynesideParser("South Tyneside Council", "South Tyneside", "http://poppy.southtyneside.gov.uk/")
    parser = StockportParser("Stockport Metropolitan District Council", "Stockport", "http://s1.stockport.gov.uk/council/eed/dc/planning/")
    #parser = SwanseaParser("Swansea City and County Council", "Swansea", "http://www2.swansea.gov.uk/")
    #parser = TamworthParser("Tamworth Borough Council", "Tamworth", "http://80.1.64.77/")
    #parser = TraffordParser("Trafford Council", "Trafford", "http://planning.trafford.gov.uk/")
    #parser = WestOxfordshireParser("West Oxfordshire District Council", "West Oxfordshire", "http://planning.westoxon.gov.uk/")
    #parser = WalthamForestParser("Waltham Forest", "Waltham Forest", "http://planning.walthamforest.gov.uk/")
    print parser.getResults(18, 4, 2008)

# To Do

# Sort out paging:
# South Shropshire - pages on 6

# Investigate catching unavailable message:
# Charnwood

# South Norfolk has no postcodes. I wonder if the postcodes are in the WAM site...
