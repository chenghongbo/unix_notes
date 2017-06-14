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

## date and time
import time, datetime
time.localtime()
print "Today is ", datetime.date.today()
print "epoch seconds ", time.time()

# date differences

now = datetime.date(2003, 8, 6)
difference1 = datetime.timedelta(days=1)
difference2 = datetime.timedelta(weeks=-2)

print "One day in the future is:", now + difference1
#=> One day in the future is: 2003-08-07

print "Two weeks in the past is:", now + difference2
#=> Two weeks in the past is: 2003-07-23

print datetime.date(2003, 8, 6) - datetime.date(2000, 8, 6)
#=> 1095 days, 0:00:00

## see more in http://pleac.sourceforge.net/pleac_python/datesandtimes.html

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


## pattern matching
import re
str = 'purple alice-b@google.com monkey dishwasher'
match = re.search('([\w.-]+)@([\w.-]+)', str) ## search is to find first match, if any
  if match:
      print match.group()   ## 'alice-b@google.com' (the whole match)
      print match.group(1)  ## 'alice-b' (the username, group 1)
      print match.group(2)  ## 'google.com' (the host, group 2)

str = 'purple alice@google.com, blah monkey bob@abc.com blah dishwasher'
tuples = re.findall(r'([\w\.-]+)@([\w\.-]+)', str)
print tuples  ## [('alice', 'google.com'), ('bob', 'abc.com')]
for tuple in tuples:
        print tuple[0]  ## username
        print tuple[1]  ## host

# Open file
f = open('test.txt', 'r')
# Feed the file text into findall(); it returns a list of all the found strings
strings = re.findall(r'some pattern', f.read())

str = 'purple alice@google.com, blah monkey bob@abc.com blah dishwasher'
## re.sub(pat, replacement, str) -- returns new string with all replacements,
## \1 is group(1), \2 group(2) in the replacement
print re.sub(r'([\w\.-]+)@([\w\.-]+)', r'\1@yo-yo-dyne.com', str)
## purple alice@yo-yo-dyne.com, blah monkey bob@yo-yo-dyne.com blah dishwasher

# match vs search
re.match("c", "abcdef")    # No match
re.search("c", "abcdef")   # Match
re.match('X', 'A\nB\nX', re.MULTILINE)  # No match
re.search('^X', 'A\nB\nX', re.MULTILINE)  # Match
"""
Basic patterns:

    a, X, 9, < -- ordinary characters just match themselves exactly. The meta-characters which do not match themselves because they have special meanings are: . ^ $ * + ? { [ ] \ | ( ) (details below)
    . (a period) -- matches any single character except newline '\n'
    \w -- (lowercase w) matches a "word" character: a letter or digit or underbar [a-zA-Z0-9_]. Note that although "word" is the mnemonic for this, it only matches a single word char, not a whole word. \W (upper case W) matches any non-word character.
    \b -- boundary between word and non-word
    \s -- (lowercase s) matches a single whitespace character -- space, newline, return, tab, form [ \n\r\t\f]. \S (upper case S) matches any non-whitespace character.
    \t, \n, \r -- tab, newline, return
    \d -- decimal digit [0-9] (some older regex utilities do not support but \d, but they all support \w and \s)
    ^ = start, $ = end -- match the start or end of the string
    \ -- inhibit the "specialness" of a character. So, for example, use \. to match a period or \\ to match a slash. If you are unsure if a character has special meaning, such as '@', you can put a slash in front of it, \@, to make sure it is treated just as a character.

Meta characters in python re
    . ^ $ * + ? { } [ ] \ | ( )

    \d
    Matches any decimal digit; this is equivalent to the class [0-9].
    \D
    Matches any non-digit character; this is equivalent to the class [^0-9].
    \s
    Matches any whitespace character; this is equivalent to the class [ \t\n\r\f\v].
    \S
    Matches any non-whitespace character; this is equivalent to the class [^ \t\n\r\f\v].
    \w
    Matches any alphanumeric character; this is equivalent to the class [a-zA-Z0-9_].
    \W
    Matches any non-alphanumeric character; this is equivalent to the class [^a-zA-Z0-9_].


    The re functions take options to modify the behavior of the pattern match. The option flag is added as an extra argument to the search() or findall() etc., e.g. re.search(pat, str, re.IGNORECASE).

    IGNORECASE -- ignore upper/lowercase differences for matching, so 'a' matches both 'a' and 'A'.
    DOTALL -- allow dot (.) to match newline -- normally it matches anything but newline. This can trip you up -- you think .* matches everything, but by default it does not go past the end of a line. Note that \s (whitespace) includes newlines, so if you want to match a run of whitespace that may include a newline, you can just use \s*
    MULTILINE -- Within a string made of many lines, allow ^ and $ to match the start and end of each line. Normally ^/$ would just match the start and end of the whole string.
    """

## see https://docs.python.org/2/library/re.html
## and http://pleac.sourceforge.net/pleac_python/patternmatching.html
