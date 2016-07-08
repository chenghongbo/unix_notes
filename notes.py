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
