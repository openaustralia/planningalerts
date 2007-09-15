#!/usr/local/bin/python

# This is the parser for Alnwick District Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Alnwick District Council"
authority_short_name = "Alnwick"
base_url = "http://services.castlemorpeth.gov.uk:7777/"

#print "Content-Type: text/html"     # HTML is following
#print

import ApplicationSearchServletParser

parser = ApplicationSearchServletParser.AlnwickSearchParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
