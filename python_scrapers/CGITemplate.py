#!/usr/bin/env python

# This is the parser for %(full_name)s.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


full_name = "%(full_name)s"
short_name = "%(short_name)s"
base_url = "%(base_url)s"

#print "Content-Type: text/html"     # HTML is following
#print

print "Content-Type: text/xml; charset=utf-8"     # XML is following
print

import %(python_module)s
parser = %(python_module)s.%(parser_class)s(full_name, short_name, base_url)

xml = parser.getResults(day, month, year)
print xml.encode("utf-8")                          # print the xml
