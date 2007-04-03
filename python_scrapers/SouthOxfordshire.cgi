#!/usr/bin/python

import cgi
import cgitb; cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')

from SouthOxfordshireParser import SouthOxfordshireParser

parser = SouthOxfordshireParser()

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
