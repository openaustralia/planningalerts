#!/usr/local/bin/python

# This is the parser for Derby City Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Derby City Council"
authority_short_name = "Derby"
base_url = "http://195.224.106.204/scripts/planningpages02%5CXSLPagesDC_DERBY%5CDCWebPages/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

import AcolnetParser

parser = AcolnetParser.DerbyParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
