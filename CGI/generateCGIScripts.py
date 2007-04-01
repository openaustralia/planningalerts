#!/usr/bin/python

list_of_sites_filename = "PublicAccessSites.csv"
template_filename = "CGITemplate"
python_location = "/usr/bin/python"

import csv
from os import chmod

list_of_sites_file = open(list_of_sites_filename)
csv_reader = csv.DictReader(list_of_sites_file, quoting=csv.QUOTE_ALL, skipinitialspace=True)

template_contents = open(template_filename).read()

template = "#!" + python_location +"\n\n" + template_contents

for site_dict in csv_reader:
    filename = "%s.cgi" %site_dict["authority_short_name"] 
    contents = template %site_dict

    this_file = open(filename, "w")
    print "Writing %s" %filename
    this_file.write(contents)
    this_file.close()

    chmod(filename, 0755)
    
# need to look at:
# "Perth and Kinross Council", "Perthshire", "http://193.63.61.22/publicaccess/"
