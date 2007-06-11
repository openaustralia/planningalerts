#!/usr/local/bin/python

# This is the parser for South Bedfordshire District Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "South Bedfordshire District Council"
authority_short_name = "South Bedfordshire"
base_url = "http://planning.southbeds.gov.uk/plantech/DCWebPages/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

import AcolnetParser

parser = AcolnetParser.SouthBedfordshireParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
