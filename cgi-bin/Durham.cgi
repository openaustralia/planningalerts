#!/usr/local/bin/python

# This is the parser for Durham City Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Durham City Council"
authority_short_name = "Durham"
base_url = "http://publicaccess.durhamcity.gov.uk/publicaccess/dc/"

#print "Content-Type: text/html"     # HTML is following
#print

import PublicAccess

parser = PublicAccess.PublicAccessParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
