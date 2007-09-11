__auth__ = None

import re

date_format = "%d/%m/%Y"


def xmlQuote(text):
    # Change &s to &amp;s
    # I suspect there is probably some standard python
    # function I should be using for this...
    return text.replace('&', '&amp;')

def fixNewlines(text):
    # This can be used to sort out windows newlines
    return text.replace("\r\n","\n")

# So what can a postcode look like then?
# This list of formats comes from http://www.mailsorttechnical.com/frequentlyaskedquestions.cfm
#AN NAA  	M1 1AA
#ANN NAA 	M60 1NW
#AAN NAA 	CR2 6XH
#AANN NAA 	DN55 1PT
#ANA NAA 	W1A 1HP
#AANA NAA 	EC1A 1BB

postcode_regex = re.compile("[A-Z][A-Z]?\d(\d|[A-Z])? ?\d[A-Z][A-Z]")

def getPostcodeFromText(text):
    """This function takes a piece of text and returns the first
    bit of it that looks like a postcode."""

    postcode_match = postcode_regex.search(text)

    if postcode_match is not None:
        return postcode_match.group()
    

class PlanningAuthorityResults:
    """This class represents a set of results of a planning search.

       This should probably be separated out so that it can be used for
       authorities other than Cherwell.
       """

    def __init__(self, authority_name, authority_short_name):
	self.authority_name = authority_name
	self.authority_short_name = authority_short_name
	
	# this will be a list of PlanningApplication objects
	self.planning_applications = []


    def addApplication(self, application):
	self.planning_applications.append(application)

    def __repr__(self):
	return self.displayXML()
        
    def displayXML(self):
        """This should display the contents of this object in the planningalerts format.
           i.e. in the same format as this one:
           http://www.planningalerts.com/lambeth.xml
           """

	applications_bit = "".join([x.displayXML() for x in self.planning_applications])

	return "<planning>\n" +\
               "<authority_name>%s</authority_name>\n" %self.authority_name +\
               "<authority_short_name>%s</authority_short_name>\n" %self.authority_short_name +\
               "<applications>\n" + applications_bit +\
	       "</applications>\n" +\
               "</planning>\n"



class PlanningApplication:
    def __init__(self, no_postcode_default='No postcode'):
        self.council_reference = None
	self.address = None
	self.postcode = no_postcode_default
	self.description = None
	self.info_url = None
	self.comment_url = None

        # expecting this as a datetime.date object
	self.date_received = None

    def __repr__(self):
	return self.displayXML()
        
    def displayXML(self):
        #print self.council_reference, self.address, self.postcode, self.description, self.info_url, self.comment_url, self.date_received
	return "<application>\n" +\
	"<council_reference>%s</council_reference>\n" %xmlQuote(self.council_reference) +\
        "<address>%s</address>\n" %xmlQuote(self.address) +\
        "<postcode>%s</postcode>\n" %self.postcode +\
	"<description>%s</description>\n" %xmlQuote(self.description) +\
	"<info_url>%s</info_url>\n" %xmlQuote(self.info_url) +\
	"<comment_url>%s</comment_url>\n" %xmlQuote(self.comment_url) +\
        "<date_received>%s</date_received>\n" %self.date_received.strftime(date_format) +\
        "</application>\n"
