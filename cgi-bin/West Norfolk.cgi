#!/usr/local/bin/python

# This is the parser for Kings Lynn and West Norfolk Borough Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Kings Lynn and West Norfolk Borough Council"
authority_short_name = "West Norfolk"
base_url = "http://online.west-norfolk.gov.uk/publicaccess/tdc/"

#print "Content-Type: text/html"     # HTML is following
#print

import PublicAccess

parser = PublicAccess.PublicAccessParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
