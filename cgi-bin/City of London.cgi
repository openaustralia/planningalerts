#!/usr/local/bin/python

# This is the parser for City of London.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "City of London"
authority_short_name = "City of London"
base_url = "http://www.planning.cityoflondon.gov.uk/tdc/"

#print "Content-Type: text/html"     # HTML is following
#print

import PublicAccess

parser = PublicAccess.PublicAccessParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
