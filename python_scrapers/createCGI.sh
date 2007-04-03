#!/bin/bash

echo Removing contents of CGI directory
svn rm --force ../CGI/*

echo Running generateCGIScripts
python generateCGIScripts.py

svn add ../CGI/*
