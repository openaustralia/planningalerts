#!/usr/local/bin/python

import urllib2
import urlparse

from datetime import date

# Use this when we have python 2.5
#import datetime

import re

from BeautifulSoup import BeautifulSoup

# Adding this to try to help Surrey Heath - Duncan 14/9/2007
import cookielib
cookie_jar = cookielib.CookieJar()
################

import MultipartPostHandler
# this is not mine, or part of standard python (though it should be!)
# it comes from http://pipe.scs.fsu.edu/PostHandler/MultipartPostHandler.py

from PlanningUtils import getPostcodeFromText, PlanningAuthorityResults, PlanningApplication


date_format = "%d/%m/%Y"

#This is to get the system key out of the info url
system_key_regex = re.compile("TheSystemkey=(\d*)", re.IGNORECASE)

# We allow the optional > for Bridgnorth, which doesn't have broken html
end_head_regex = re.compile("</head>?", re.IGNORECASE)


class AcolnetParser:
    received_date_label = "Registration Date:"
    received_date_format = "%d/%m/%Y"

    comment_qs_template = "ACTION=UNWRAP&RIPNAME=Root.PgeCommentForm&TheSystemkey=%s"

    # There is no online comment facility in these, so we provide an
    # appropriate email address instead
    comments_email_address = None

    # The optional amp; is to cope with Oldham, which seems to have started
    # quoting this url.
    action_regex = re.compile("<form[^>]*action=\"([^\"]*ACTION=UNWRAP&(?:amp;)?RIPSESSION=[^\"]*)\"[^>]*>", re.IGNORECASE)    
  
    def _getResultsSections(self, soup):
        """In most cases, there is a table per app."""
        return soup.findAll("table", {"class": "results-table"})
  
    def _getCouncilReference(self, app_table):
#        return app_table.findAll("a")[1].string.strip()
        return app_table.a.string.strip()

    def _getDateReceived(self, app_table):
        date_str = ''.join(app_table.find(text=self.received_date_label).findNext("td").string.strip().split())
        day, month, year = date_str.split('/')
        return date(int(year), int(month), int(day))

        # This will be better from python 2.5
        #return datetime.datetime.strptime(date_str, self.received_date_format)

    def _getAddress(self, app_table):
        return app_table.find(text="Location:").findNext("td").string.strip()
    
    def _getDescription(self, app_table):
        return app_table.find(text="Proposal:").findNext("td").string.strip()

    def _getInfoUrl(self, app_table):
        """Returns the info url for this app.
        
        We also set the system key on self._current_application, 
        as we'll need that for the comment url.

        """
        url = app_table.a['href']
        self._current_application.system_key = system_key_regex.search(url).groups()[0]
        return urlparse.urljoin(self.base_url, url)

    def _getCommentUrl(self, app_table):
        """This must be run after _getInfoUrl"""

        if self.comments_email_address:
            return self.comments_email_address

        split_info_url = urlparse.urlsplit(self._current_application.info_url)

        comment_qs = self.comment_qs_template %self._current_application.system_key

        return urlparse.urlunsplit(split_info_url[:3] + (comment_qs,) + split_info_url[4:])


    def __init__(self,
                 authority_name,
                 authority_short_name,
                 base_url,
                 debug=False):
        self.authority_name = authority_name
        self.authority_short_name = authority_short_name
        self.base_url = base_url

        self.debug = debug

        # This in where we store the results
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)

        # This will store the planning application we are currently working on.
        self._current_application = None


    def _cleanupHTML(self, html):
        """This method should be overridden in subclasses to perform site specific
        HTML cleanup."""
        return html

    def _getSearchResponse(self):
        # It looks like we sometimes need to do some stuff to get around a
        # javascript redirect and cookies.
        search_form_request = urllib2.Request(self.base_url)
        search_form_response = urllib2.urlopen(search_form_request)

        return search_form_response
        

    def getResultsByDayMonthYear(self, day, month, year):
        # first we fetch the search page to get ourselves some session info...
        search_form_response = self._getSearchResponse()
        
        search_form_contents = search_form_response.read()

        # This sometimes causes a problem in HTMLParser, so let's just get the link
        # out with a regex...
        groups = self.action_regex.search(search_form_contents).groups()

        action = groups[0] 
        #print action

        # This is to handle the amp; which seems to have appeared in this
        # url on the Oldham site
        action = ''.join(action.split('amp;'))

        action_url = urlparse.urljoin(self.base_url, action)
        #print action_url

        our_date = date(year, month, day)
        
        search_data = {"regdate1": our_date.strftime(date_format),
                       "regdate2": our_date.strftime(date_format),
                       }
        
        opener = urllib2.build_opener(MultipartPostHandler.MultipartPostHandler)
        response = opener.open(action_url, search_data)
        results_html = response.read()

        # This is for doing site specific html cleanup
        results_html = self._cleanupHTML(results_html)

        #some javascript garbage in the header upsets HTMLParser,
        #so we'll just have the body
        just_body = "<html>" + end_head_regex.split(results_html)[-1]

        #self.feed(just_body)
        
        soup = BeautifulSoup(just_body)

        # Each app is in a table of it's own.
        results_tables = self._getResultsSections(soup)


        for app_table in results_tables:
            self._current_application = PlanningApplication()
            self._current_application.council_reference = self._getCouncilReference(app_table)
            self._current_application.address = self._getAddress(app_table)
            
            # Get the postcode from the address
            self._current_application.postcode = getPostcodeFromText(self._current_application.address)
            
            self._current_application.description = self._getDescription(app_table)
            self._current_application.info_url = self._getInfoUrl(app_table)
            self._current_application.comment_url = self._getCommentUrl(app_table)
            self._current_application.date_received = self._getDateReceived(app_table)

            self._results.addApplication(self._current_application)


        return self._results



    def getResults(self, day, month, year):
        results =  self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()
        #        import pdb;pdb.set_trace()
        return results

class BridgnorthParser(AcolnetParser):
    def _getResultsSections(self, soup):
        return soup.findAll("table", {"class": "app"})

    def _getCouncilReference(self, app_table):
        return app_table.a.string.split()[-1]

    def _getCommentUrl(self, app_table):
        """This must be run after _getInfoUrl"""
#http://www2.bridgnorth-dc.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeCommentForm&TheSystemkey=46958
        return self._current_application.info_url.replace("NewPages", "PgeCommentForm")

class BlackpoolParser(AcolnetParser):
    received_date_label = "Application Date:"

    def _getResultsSections(self, soup):
        return soup.findAll("table", {"class": "acolnet-results-table"})

    def _getCommentUrl(self, app_table):
        ref = self._getCouncilReference(app_table)
        return "https://www.blackpool.gov.uk/Services/M-R/PlanningApplications/Forms/PlanningNeighbourResponseForm.htm?Application_No=" + ref.replace('/','%2F')

class CanterburyParser(AcolnetParser):
    """Here the apps are one row each in a big table."""

    def _getResultsSections(self, soup):
        return soup.find("table").findAll("tr")[1:]

    def _getDateReceived(self, app_table):
        date_str = app_table.findAll("td")[3].string.strip()

        day, month, year = date_str.split('/')
        return date(int(year), int(month), int(day))

        # This will be better once we have python 2.5
        #return datetime.datetime.strptime(date_str, self.received_date_format)

    def _getAddress(self, app_table):
        return app_table.findAll("td")[1].string.strip()

    def _getDescription(self, app_table):
        return app_table.findAll("td")[2].string.strip()        

class GreenwichParser(AcolnetParser):
    received_date_label = "Registration date:"
    comment_qs_template = "ACTION=UNWRAP&RIPNAME=Root.PgeCommentNeighbourForm&TheSystemkey=%s"

    def _getInfoUrl(self, app_table):
        return AcolnetParser._getInfoUrl(self, app_table).replace('/?', '/acolnetcgi.gov?', 1)

#Kensington and chelsea is sufficiently different, it may as well be handled separately    

class MidBedsParser(AcolnetParser):
    def _getCouncilReference(self, app_table):
        return app_table.findAll("a")[1].string.strip()
    
class OldhamParser(AcolnetParser):
    def _cleanupHTML(self, html):
        """There is a bad table end tag in this one.
        Fix it before we start"""
        
        bad_table_end = '</table summary="Copyright">'
        good_table_end = '</table>'

        return html.replace(bad_table_end, good_table_end)

class SouthwarkParser(AcolnetParser):
    def _getDateReceived(self, app_table):
        date_str = ''.join(app_table.find(text="Statutory start date:").findNext("td").string.strip().split())
        
        day, month, year = date_str.split('/')
        return date(int(year), int(month), int(day))
    
        # Use this once we have python 2.5
        #return datetime.datetime.strptime(date_str, self.received_date_format)

class SurreyHeathParser(AcolnetParser):
    # This is not working yet.
    # _getSearchResponse is an attempt to work around
    # cookies and a javascript redirect.
    # I may have a bit more of a go at this at some point if I have time.
    case_number_tr = 1 # this one can be got by the td class attribute
    reg_date_tr = 2
    location_tr = 4
    proposal_tr = 5

    comments_email_address = "development-control@surreyheath.gov.uk"

    def _getSearchResponse(self):
        # It looks like we sometimes need to do some stuff to get around a
        # javascript redirect and cookies.
        search_form_request = urllib2.Request(self.base_url)

        # Lying about the user-agent doesn't seem to help.
        #search_form_request.add_header("user-agent", "Mozilla/5.0 (compatible; Konqu...L/3.5.6 (like Gecko) (Kubuntu)")
        
        search_form_response = urllib2.urlopen(search_form_request)
        
        cookie_jar.extract_cookies(search_form_response, search_form_request)


        print search_form_response.geturl()
        print search_form_response.info()

        print search_form_response.read()
#        validate_url = "https://www.public.surreyheath-online.gov.uk/whalecom7cace3215643e22bb7b0b8cc97a7/whalecom0/InternalSite/Validate.asp"
#        javascript_redirect_url = urlparse.urljoin(self.base_url, "/whalecom7cace3215643e22bb7b0b8cc97a7/whalecom0/InternalSite/RedirectToOrigURL.asp?site_name=public&secure=1")

#        javascript_redirect_request = urllib2.Request(javascript_redirect_url)
#        javascript_redirect_request.add_header('Referer', validate_url)
        
#        cookie_jar.add_cookie_header(javascript_redirect_request)

#        javascript_redirect_response = urllib2.urlopen(javascript_redirect_request)
        
#        return javascript_redirect_response
    

class BoltonLikeParser(AcolnetParser):
    """Note that Bolton has ceased to be BoltonLike with its latest change of url."""
    def _getCouncilReference(self, app_table):
        return app_table.findAll("a")[1].string.strip()
    
    
class LewishamParser(BoltonLikeParser):
    comments_email_address = "planning@lewisham.com"


class BassetlawParser(BoltonLikeParser):
    comments_email_address = "planning@bassetlaw.gov.uk"

    def _cleanupHTML(self, html):
        """There is a broken div in this page. We don't need any divs, so
        let's get rid of them all."""

        div_regex = re.compile("</?div[^>]*>", re.IGNORECASE)
        return div_regex.sub('', html)

class HarlowParser(AcolnetParser):
    def _getCommentUrl(self, app_table):
        """This must be run after _getInfoUrl"""
#http://www2.bridgnorth-dc.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeCommentForm&TheSystemkey=46958
        return self._current_application.info_url.replace("PgeResultDetail", "PgeCommentNeighbourForm&amp;hasreference=no")

if __name__ == '__main__':
    day = 1
    month = 8
    year = 2008

    #parser = AcolnetParser("Babergh", "Babergh", "http://planning.babergh.gov.uk/dcdatav2//acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = AcolnetParser("Barnet", "Barnet", "http://194.75.183.100/planning-cases/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Basingstoke", "Basingstoke", "http://planning.basingstoke.gov.uk/DCOnline2/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BassetlawParser("Bassetlaw", "Bassetlaw", "http://www.bassetlaw.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Bolton", "Bolton", "http://www.planning.bolton.gov.uk/DCOnlineV2/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BridgnorthParser("Bridgnorth", "Bridgnorth", "http://www2.bridgnorth-dc.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch")
    #parser = AcolnetParser("Bury", "Bury", "http://e-planning.bury.gov.uk/DCWebPages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = CanterburyParser("Canterbury", "Canterbury", "http://planning.canterbury.gov.uk/scripts/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    parser = AcolnetParser("Carlisle", "Carlisle", "http://planning.carlisle.gov.uk/acolnet/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Croydon", "Croydon", "http://planning.croydon.gov.uk/DCWebPages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Derby", "Derby", "http://eplanning.derby.gov.uk/acolnet/planningpages02/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("East Lindsey", "East Lindsey", "http://www.e-lindsey.gov.uk/planning/AcolnetCGI.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch", "AcolnetParser")
    #parser = AcolnetParser("Exeter City Council", "Exeter", "http://pub.exeter.gov.uk/scripts/Acolnet/dataonlineplanning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BoltonParser("Fylde", "Fylde", "http://www2.fylde.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Guildford", "Guildford", "http://www.guildford.gov.uk/DLDC_Version_2/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Harlow", "Harlow", "http://planning.harlow.gov.uk/DLDC_Version_2/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Havant", "Havant", "http://www3.havant.gov.uk/scripts/planningpages/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BoltonLikeParser("Hertsmere", "Hertsmere", "http://www2.hertsmere.gov.uk/ACOLNET/DCOnline//acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = LewishamParser("Lewisham", "Lewisham", "http://acolnet.lewisham.gov.uk/lewis-xslpagesdc/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.PgeSearch")
    #parser = AcolnetParser("Mid Suffolk", "Mid Suffolk", "http://planning.midsuffolk.gov.uk/planning/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BoltonLikeParser("New Forest District Council", "New Forest DC", "http://web3.newforest.gov.uk/planningonline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = BoltonLikeParser("New Forest National Park Authority", "New Forest NPA", "http://web01.newforestnpa.gov.uk/planningpages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("North Hertfordshire", "North Herts", "http://www.north-herts.gov.uk/dcdataonline/Pages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch")
    #parser = AcolnetParser("North Wiltshire", "North Wilts", "http://planning.northwilts.gov.uk/DCOnline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = OldhamParser("Oldham", "Oldham", "http://planning.oldham.gov.uk/planning/AcolNetCGI.gov?ACTION=UNWRAP&Root=PgeSearch")
    #parser = BoltonLikeParser("Renfrewshire", "Renfrewshire", "http://planning.renfrewshire.gov.uk/acolnetDCpages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch")
    #parser = AcolnetParser("South Bedfordshire", "South Bedfordshire", "http://planning.southbeds.gov.uk/plantech/DCWebPages/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.PgeSearch")
    #parser = SouthwarkParser("London Borough of Southwark", "Southwark", "http://planningonline.southwarksites.com/planningonline2/AcolNetCGI.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    #parser = AcolnetParser("Suffolk Coastal", "Suffolk Coastal", "http://apps3.suffolkcoastal.gov.uk/DCDataV2/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = AcolnetParser("Surrey Heath", "Surrey Heath", "https://www.public.surreyheath-online.gov.uk/whalecom60b1ef305f59f921/whalecom0/Scripts/PlanningPagesOnline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")

#    parser = MidBedsParser("Mid Bedfordshire District Council", "Mid Beds", "http://www.midbeds.gov.uk/acolnetDC/DCpages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = AcolnetParser("Cambridgeshire County Council", "Cambridgeshire", "http://planapps2.cambridgeshire.gov.uk/DCWebPages/AcolNetCGI.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = AcolnetParser("East Hampshire District Council", "East Hampshire", "http://planningdevelopment.easthants.gov.uk/dconline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = AcolnetParser("Stockport Metropolitan Borough Council", "Stockport", "http://planning.stockport.gov.uk/PlanningData/AcolNetCGI.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = BlackpoolParser("Blackpool Borough Council", "Blackpool", "http://www2.blackpool.gov.uk/PlanningApplications/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
#    parser = GreenwichParser("London Borough of Greenwich", "Greenwich", "http://onlineplanning.greenwich.gov.uk/acolnet/planningpages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch")
    print parser.getResults(day, month, year)
    
