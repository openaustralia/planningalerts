#!/usr/local/bin/python

# This is the parser for London Borough of Lewisham.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "London Borough of Lewisham"
authority_short_name = "Lewisham"
base_url = "http://acolnet.lewisham.gov.uk/lewis-xslpagesdc/acolnetcgi.exe?ACTION=UNWRAP&RIPNAME=Root.PgeSearch"

import AcolnetParser

parser = AcolnetParser.LewishamParser(authority_name, authority_short_name, base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
