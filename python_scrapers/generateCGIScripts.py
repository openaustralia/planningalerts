#!/usr/bin/python

list_of_sites_filename = "PublicAccessSites.csv"
template_filename = "CGITemplate"
python_location = "/usr/bin/python"

cgi_dir = "../CGI/"

# this should be a config file
other_files = ["PublicAccess.py", "PlanningUtils.py", "SouthOxfordshireParser.py", "SouthOxfordshire.cgi"]

import csv
from os import chmod
from shutil import copyfile

list_of_sites_file = open(list_of_sites_filename)
csv_reader = csv.DictReader(list_of_sites_file, quoting=csv.QUOTE_ALL, skipinitialspace=True)

# svn rm the cgi directory

# create the cgi directory


# create cgi files and write them in the cgi directory
template_contents = open(template_filename).read()

template = "#!" + python_location +"\n\n" + template_contents

for site_dict in csv_reader:
    filename = cgi_dir + "%s.cgi" %site_dict["authority_short_name"] 
    contents = template %site_dict

    this_file = open(filename, "w")
    print "Writing %s" %filename
    this_file.write(contents)
    this_file.close()

    chmod(filename, 0755)

# copy across other files that are needed
# these should probably come from a config file
for filename in other_files:
    copyfile(filename, cgi_dir+filename)
    

# write a README to warn people not to svn add stuff to CGI directory
readme_message = """
WARNING - this directory is only for generated files
and files which are automatically copied in.
Anything manually added here will be svn deleted.

"""
readme_file = open(cgi_dir+ "README", "w")
readme_file.write(readme_message)
readme_file.close()

# svn add the cgi directory and its contents
    
