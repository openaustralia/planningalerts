#!/usr/local/bin/python

# This is the parser for The Borough of Oadby and Wigston.
# it is generated from the file CGITemplate

import cgi
import cgitb
#cgitb.enable(display=0, logdir="/tmp")


form = cgi.FieldStorage()
day = form.getfirst('day')
month = form.getfirst('month')
year = form.getfirst('year')


authority_name = "The Borough of Oadby and Wigston"
authority_short_name = "Oadby and Wigston"
base_url = "http://web.owbc.net/PublicAccess/tdc/"

import PublicAccess

parser = PublicAccess.PublicAccessParser(authority_name,
                                         authority_short_name,
                                         base_url)

xml = parser.getResults(day, month, year)

print "Content-Type: text/xml"     # XML is following
print
print xml                          # print the xml
