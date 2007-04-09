#!/usr/local/bin/python

list_of_sites_filename = "PublicAccessSites.csv"
other_files_to_copy_filename = "OtherFilesToCopy.csv"
template_filename = "CGITemplate"
python_location = "/usr/bin/python"

cgi_dir = "../CGI/"

import csv
from os import chmod
from shutil import copyfile

list_of_sites_file = open(list_of_sites_filename)
csv_reader = csv.DictReader(list_of_sites_file, quoting=csv.QUOTE_ALL, skipinitialspace=True)

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

other_files_to_copy = open(other_files_to_copy_filename)
other_files_csv_reader = csv.DictReader(other_files_to_copy, quoting=csv.QUOTE_ALL, skipinitialspace=True)

for file_dict in other_files_csv_reader:
    print file_dict
    filename = file_dict["filename"]
    copyfile(filename, cgi_dir+filename)

    # the idea here is to have filename and permissions
    # in the csv file.
    # Until version 2.6 of python, there is no easy way
    # to convert a string to an octal, so I am using
    # integers to represent permissions...
    # see README for details.
    chmod(cgi_dir+filename, int(file_dict["permissions"]))
    
# write a README to warn people not to svn add stuff to CGI directory
readme_message = """
WARNING - this directory is only for generated files
and files which are automatically copied in.
Anything manually added here will be svn deleted.

"""
readme_file = open(cgi_dir+ "README", "w")
readme_file.write(readme_message)
readme_file.close()

    
