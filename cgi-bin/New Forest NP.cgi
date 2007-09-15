#!/usr/local/bin/python

# This is the parser for New Forest National Park.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "New Forest National Park"
authority_short_name = "New Forest NP"
base_url = "http://web01.newforestnpa.gov.uk/planningpages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

#print "Content-Type: text/html"     # HTML is following
#print

import AcolnetParser

parser = AcolnetParser.NewForestNPParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
