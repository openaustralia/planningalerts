#!/usr/local/bin/python

# This is the parser for Hartlepool Borough Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Hartlepool Borough Council"
authority_short_name = "Hartlepool"
base_url = "http://eforms.hartlepool.gov.uk:7777/"

import ApplicationSearchServletParser

parser = ApplicationSearchServletParser.HartlepoolSearchParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
