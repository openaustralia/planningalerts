#!/usr/local/bin/python

# This is the parser for Wellingborough Borough Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Wellingborough Borough Council"
authority_short_name = "Wellingborough"
base_url = "http://planning.wellingborough.gov.uk/"

import ApplicationSearchServletParser

parser = ApplicationSearchServletParser.WellingboroughSearchParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
