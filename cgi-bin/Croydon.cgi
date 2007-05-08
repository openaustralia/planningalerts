#!/usr/local/bin/python

# This is the parser for London Borough of Croydon.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "London Borough of Croydon"
authority_short_name = "Croydon"
base_url = "http://planning.croydon.gov.uk/DCWebPages/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

import AcolnetParser

parser = AcolnetParser.CroydonParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
