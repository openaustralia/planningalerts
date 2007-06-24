#!/usr/local/bin/python

# This is the parser for Surrey Heath Borough Council.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "Surrey Heath Borough Council"
authority_short_name = "Surrey Heath"
base_url = "https://www.public.surreyheath-online.gov.uk/whalecom60b1ef305f59f921/whalecom0/Scripts/PlanningPagesOnline/acolnetcgi.gov?ACTION=UNWRAP&RIPNAME=Root.pgesearch"

import AcolnetParser

parser = AcolnetParser.SurreyHeathParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
