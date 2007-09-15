#!/usr/local/bin/python

# This is the parser for New Forest District Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "New Forest District Council"
authority_short_name = "New Forest DC"
base_url = "http://web3.newforest.gov.uk/planningonline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

#print "Content-Type: text/html"     # HTML is following
#print

import AcolnetParser

parser = AcolnetParser.NewForestDCParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)


print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
