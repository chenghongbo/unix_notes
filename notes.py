# -*- coding: utf-8 -*-

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

f = open('workfile', 'w')  ## truncate workfile, if it exists
f.write('this is a test line.\n')
f.close()

for item in thelist:
      f.write("%s\n" % item)
f.close()  ## write a list to file

## read user input from stdin

name = raw_input("Enter your name: ")   # Python 2.x, read only single lines
name = input("Enter your name: ")   # Python 3

## argument parsing
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-f", "--file",dest="myfilename",help="the file name to read in",metavar="FILE",required=True)
parser.add_argument("-q", "--quiet",action="store_false",dest="verbose",help="don't priint status msg")
args = parser.parse_args()
print(args.myfilename)

    """
    dest: You will access the value of option with this variable
    help: This text gets displayed whey someone uses --help.
    default: If the command line argument was not specified, it will get this default value.
    action: Actions tell optparse what to do when it encounters an option on the command line. action defaults to store. These actions are available:
        store: take the next argument (or the remainder of the current argument), ensure that it is of the correct type, and store it to your chosen destination dest.
        store_true: store True in dest if this flag was set.
        store_false: store False in dest if this flag was set.
        store_const: store a constant value
        append: append this option’s argument to a list
        count: increment a counter by one
        callback: call a specified function
        nargs: ArgumentParser objects usually associate a single command-line argument with a single action to be taken. The nargs keyword argument associates a different number of command-line arguments with a single action.
        required: Mark a command line argument as non-optional (required).
        choices: Some command-line arguments should be selected from a restricted set of values. These can be handled by passing a container object as the choices keyword argument to add_argument(). When the command line is parsed, argument values will be checked, and an error message will be displayed if the argument was not one of the acceptable values.
        type: Use this command, if the argument is of another type (e.g. int or float).
    """
# see https://martin-thoma.com/how-to-parse-command-line-arguments-in-python/
# and https://docs.python.org/dev/library/argparse.html
