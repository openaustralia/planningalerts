#!/usr/local/bin/python

# This is the parser for Coventry City Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Coventry City Council"
authority_short_name = "Coventry"
base_url = "http://planning.coventry.gov.uk/"

import ApplicationSearchServletParser

parser = ApplicationSearchServletParser.CoventrySearchParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
