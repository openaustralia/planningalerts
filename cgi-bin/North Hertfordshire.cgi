#!/usr/local/bin/python

# This is the parser for North Hertfordshire District Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "North Hertfordshire District Council"
authority_short_name = "North Hertfordshire"
base_url = "http://www.north-herts.gov.uk/dcdataonline/Pages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

#print "Content-Type: text/html"     # HTML is following
#print

import AcolnetParser

parser = AcolnetParser.NorthHertfordshireParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
