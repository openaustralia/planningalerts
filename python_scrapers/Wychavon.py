"""
This is the screenscraper for planning apps from Wychavon District Council.

This appears to be an Acolnet variant, and is searched by a block of months.
"""

import urllib
import urlparse

import datetime

from BeautifulSoup import BeautifulSoup

from PlanningUtils import PlanningApplication, \
    PlanningAuthorityResults, \
    getPostcodeFromText

class WychavonParser:
    
    def __init__(self, *args):
        self.authority_name = "Wychavon"
        self.authority_short_name = "Wychavon"
        # Currently hard coded--if this address updates, we'll need to scrape
        # the search form to get it each time.
        self.base_url = "http://www.e-wychavon.org.uk/scripts/plan2005/\
acolnetcgi.exe?ACTION=UNWRAP&WhereDescription=General%20Search&\
Whereclause3=%27%30%31%2F%7BEdtMonthEnd%7D%2F%7BEdtYearEnd%7D%27&\
RIPNAME=Root%2EPages%2EPgeDC%2EPgeListCases"
        
        self._results = PlanningAuthorityResults(self.authority_name, self.authority_short_name)


    def getResultsByDayMonthYear(self, day, month, year):
        
        form_data = "EdtYearNo=&EdtCaseNo=&EdtApplicant=&EdtAgent=&EdtLocation"\
        + "=&EdtWard=&EdtMonthStart1=" + str(month) + "&EdtYearStart=" \
        + str(year) + "&EdtMonthEnd=" + str(month) + "&EdtYearEnd="\
        + str(year) + "&submit=Search"

        # Fetch the results
        response = urllib.urlopen(self.base_url, form_data)
        soup = BeautifulSoup(response.read())
        
        
        #Each set of results has its own table
        results_tables = soup.findAll("table", cellpadding="2", cols="4")

        for table in results_tables:
            application = PlanningApplication()

            trs = table.findAll("tr")
            
            application.council_reference = trs[0].findAll("td")[1].font.font.\
                                                        font.string.strip()
            
            relative_info_url = trs[0].findAll("td")[1].a['href']
            application.info_url = urlparse.urljoin(self.base_url, relative_info_url)
            
            application.address = trs[1].findAll("td")[1].font.string.strip()
            application.postcode = getPostcodeFromText(application.address)
            
            #This code avoids an error if there's no description given.
            descrip = trs[2].findAll("td")[1].font.string
            if descrip == None:
                application.description = ""
            else:
                application.description = descrip.strip()

            date_format = "%d/%m/%y"
            date_string = trs[1].findAll("td")[3].font.string.strip()
                                                                    
            application.date_received = datetime.datetime.strptime(date_string, date_format) 

            apptype = trs[0].findAll("td")[3].font.string
            # Avoids throwing an error if no apptype is given (this can happen)
            if apptype != None:
                apptype = apptype.strip()
            
            # Is all this really necessary? I don't know, but I've assumed that
            # it is. The form will appear without the suffix, I don't know if
            # the council's backend would accept it or not. Current behaviour
            # is to degrade silently to no suffix if it can't match an
            # application type.
            if apptype == "Telecommunications":
                # Don't know why it's a naked IP rather than sitting on the
                # same site, but there it is.
                application.comment_url = "http://81.171.139.151/WAM/createCom"\
                +"ment.do?action=CreateApplicationComment&applicationType=PLANNI"\
                +"NG&appNumber=T3/" + application.council_reference + "/TC"
            else:
                comment_url = "http://81.171.139.151/WAM/createComment.do?acti"\
                +"on=CreateApplicationComment&applicationType=PLANNING&appNumber"\
                +"=W/" + application.council_reference + "/"
                suffix = ""
                if apptype == "Householder planning application":
                    suffix = "PP"
                elif apptype == "Non-householder planning application":
                    suffix = "PN"
                elif apptype == "Outline applications":
                    suffix = "OU"
                elif apptype == "Change of use":
                    suffix = "CU"
                elif apptype == "Listed Building consent":
                    suffix = "LB"
                elif apptype == "Advertisement application":
                    suffix = "AA"
                elif apptype == "Certificate of Lawfulness Existing":
                    suffix = "LUE"
                elif apptype == "Approval of reserved matters":
                    suffix = "VOC"
                #These are all the ones that I found, except "Advice - Pre-app/
                #Householder", the suffix for which is inconsistent. The suffix
                #for this could be obtained by scraping the description page for
                #each application.
                application.comment_url = comment_url + suffix

            self._results.addApplication(application)

        return self._results

    def getResults(self, day, month, year):
        return self.getResultsByDayMonthYear(int(day), int(month), int(year)).displayXML()

if __name__ == '__main__':
    parser = WychavonParser()
    #Put this in with constant numbers, copying the Barnsley example. Works for testing, but should it use the arguments for a real run?
    print parser.getResults(16,3,2009)
