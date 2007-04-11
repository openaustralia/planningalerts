#!/usr/local/bin/python

# This is the parser for St Helens Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "St Helens Council"
authority_short_name = "St Helens"
base_url = "http://212.248.225.150:8080/"

import ApplicationSearchServletParser

parser = ApplicationSearchServletParser.StHelensSearchParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
