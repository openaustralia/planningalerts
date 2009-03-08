#!/usr/bin/env python

list_of_sites_filename = "SitesToGenerate.csv"
other_files_to_copy_filename = "OtherFilesToCopy.csv"
other_files_location = "python_scrapers/"
template_filename = "python_scrapers/CGITemplate.py"
cgi_dir = "cgi-bin/"

import csv
import urllib

from os import chmod, environ
from shutil import copyfile
import MySQLdb

# First, copy across files that are needed in the CGI directory
# that aren't generated.

other_files_to_copy = open(other_files_to_copy_filename)
other_files_csv_reader = csv.DictReader(
    other_files_to_copy, 
    quoting=csv.QUOTE_ALL, 
    skipinitialspace=True,
    )

for file_dict in other_files_csv_reader:
    filename = file_dict["filename"]
    copyfile(other_files_location + filename, cgi_dir+filename)

    # the idea here is to have filename and permissions
    # in the csv file.
    # Until version 2.6 of python, there is no easy way
    # to convert a string to an octal, so I am using
    # integers to represent permissions...
    # see README for details.
    chmod(cgi_dir+filename, int(file_dict["permissions"]))

# Next we generate the cgi files

list_of_sites_file = open(list_of_sites_filename)
csv_reader = csv.DictReader(
    list_of_sites_file, 
    quoting=csv.QUOTE_ALL, 
    skipinitialspace=True,
    )

# create cgi files and write them in the cgi directory
template= open(template_filename).read()

# Get a mysql cursor
mysql_connection = MySQLdb.connect(
    db=environ['MYSQL_DB_NAME'],
    user=environ['MYSQL_USERNAME'],
    passwd=environ['MYSQL_PASSWORD'],
    )
mysql_cursor = mysql_connection.cursor()

python_scraper_location = "/cgi-bin/%s.cgi?day={day}&month={month}&year={year}"
php_scraper_location = "/scrapers/%(php_scraper)s.php?day={day}&month={month}&year={year}"

# All of this should probably be done with SqlAlchemy or something.

authority_select_query = "SELECT * FROM authority WHERE short_name = '%(short_name)s';"

# FIXME: Both of these queries should set planning_email and notes.
authority_insert_query = 'INSERT INTO authority (full_name, short_name, feed_url, external, disabled, planning_email) values ("%(full_name)s", "%(short_name)s", "%(feed_url)s", %(external)s, %(disabled)s, "%(planning_email)s");'
authority_update_query = 'UPDATE authority SET full_name="%(full_name)s", external="%(external)s", disabled=%(disabled)s, feed_url="%(feed_url)s", external=%(external)s WHERE short_name = "%(short_name)s";'

for site_dict in csv_reader:
    # We need these to be 1 or 0 to pass them into mysql.
    site_dict['external'] = 1 if site_dict['external'] else 0
    site_dict['disabled'] = 1 if site_dict['disabled'] else 0

    if site_dict['external']:
        # This scraper is somewhere else.
        pass
    elif site_dict['feed_url']:
        # This scraper is local and uses an non-generated file in cgi-bin
        pass
    elif site_dict['php_scraper']:
        # Uses a PHP scraper.
        site_dict['feed_url'] = php_scraper_location %site_dict
    elif site_dict['python_module'] and site_dict['parser_class']:
        # We need to generate a python CGI file
        file_location = cgi_dir + "%(short_name)s.cgi" %site_dict 
        contents = template %site_dict

        this_file = open(file_location, "w")
        this_file.write(contents)
        this_file.close()
        chmod(file_location, 0755)

        quoted_short_name = urllib.quote(site_dict["short_name"])
        site_dict['feed_url'] = python_scraper_location %(quoted_short_name)
    else:
        # Something has gone wrong.
        print "ERROR: Config for %(short_name)s is faulty." %site_dict

        # print "Disabling this scraper"
        # FIXME: Should have a query here to set disabled for this scraper.
        continue

    # Do we have a record for this authority already?
    row_count = mysql_cursor.execute(authority_select_query %site_dict)

    if row_count > 1:
        print "ERROR: There is more than one row for %(short_name)s." %site_dict
        print "Skipping this scraper."

        continue
    elif row_count == 1:
        mysql_cursor.execute(authority_update_query %site_dict)
    elif row_count == 0:
        mysql_cursor.execute(authority_insert_query %site_dict)
    else:
        print "ERROR: How on earth did we get here? Row count is %s" %(row_count)
    
# write a README to warn people not to svn add stuff to CGI directory
readme_message = """
WARNING - this directory is only for generated files
and files which are automatically copied in.
Anything manually added here will be lost.

"""
readme_file = open(cgi_dir + "README", "w")
readme_file.write(readme_message)
readme_file.close()

    
