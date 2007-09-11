#!/usr/local/bin/python

# This is the parser for Mansfield District Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Mansfield District Council"
authority_short_name = "Mansfield"
base_url = "http://www.mansfield.gov.uk/Fastweb23/"

import FastWeb

parser = FastWeb.FastWeb(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
