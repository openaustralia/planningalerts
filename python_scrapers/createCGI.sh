#!/bin/bash

echo Removing contents of CGI directory
svn rm --force ../CGI/*

echo Running generateCGIScripts
python generateCGIScripts.py

svn add ../CGI/*

echo Committing changes to svn
(cd ../CGI ; svn commit -m "Removing and regenerating CGI directory")

echo Done
