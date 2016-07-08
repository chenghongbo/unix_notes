# get environment variables
import os
os.getenv('MYENV')
os.getenv('MYENV','Not Set Yet')

os.environ['HOME']
os.environ.get('HOME')

## to check if a file exists or not
import os.path
os.path.isfile(fname) 
os.path.exists(fname)  # true for both files and dirs

## read file content
with open('filename') as f:
        lines = f.readlines()
        ## lines will be a list, with each line in file as an item
        ## including the trailing new line

    ## the following is to strip the new line character in each line
lines = [line.rstrip('\n') for line in open('filename')]

## read file, line by line, instead of as a whole
with open(fname) as f:
        for line in f:
                    print line.rstrip('\n')
"""The with statement handles opening and closing the file, including if an exception is raised in the inner block. The for line in f treats the file object f as an iterable, which automatically uses buffered IO and memory management so you don't have to worry about large files."""

## write to file

## read user input from stdin

name = raw_input("Enter your name: ")   # Python 2.x, read only single lines
name = input("Enter your name: ")   # Python 3

## argument parsing
