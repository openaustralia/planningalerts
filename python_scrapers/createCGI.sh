#!/bin/bash

echo Removing contents of directory cgi-bin
svn rm --force ../cgi-bin/*

echo Running generateCGIScripts
python generateCGIScripts.py

svn add ../cgi-bin/*

#echo Committing changes to svn
#(cd ../cgi-bin ; svn commit -m "Removing and regenerating directory cgi-bin")

echo Done
