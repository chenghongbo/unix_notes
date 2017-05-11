#!/bin/bash


#******************************************************************
#
# this script is mainly to rebase a feature branch onto master
# then rebase master onto that feature branch
# detailed usage:
#  -s to specify name of feature branch (or source branch), mandatory
#  -m to specify name of main branch (or master branch).    mandatory
#  -d to specify path to the git repo. If omitted, `pwd` is assumed
#
#******************************************************************

##-----------------------------------------
## variable definition for later use
##-----------------------------------------

help_msg=$(cat <<-EOFE

##########################################################################

   Missing arguments. Exitting...
   Usage: `basename $0` [-d repo_directory] -f feature_branch -m main_branch

##########################################################################

EOFE
)

today=$(date '+%Y-%m-%d_%H:%M:%S')

## a function to display msg and exit
## Usage: die reture_code "error msg to display"
die () {
    rc=$1
    shift
    echo "$@" 1>&2
    exit $rc
}

###########################################
##  argument processing
###########################################


while getopts "d:f:m:" FLAG; 
do
	case $FLAG in
		d) # get target directory
			target_dir=$OPTARG
			;;
		f) # get source branch name
			feature_branch=$OPTARG
			;;
		m) # get target branch name
			main_branch=$OPTARG
			;;
		*) # show usage msg
			die 111 "$help_msg"
			;;
	esac
done

## check if we get all arguments we need
if [[ "$#" -lt 1 || -z "$feature_branch" || -z "$main_branch" ]]
then
	die 1 "$help_msg"
fi

shift $((OPTIND-1))

## if target_dir is null, set it to current working dir
target_dir=${target_dir:=`pwd`}

## check direcotry permission and go there
if [[ ! -x "$target_dir" || ! -d "$target_dir" ]] 
then
	die 101 "check dir $target_dir for existence or permission"
fi

cd "$target_dir"

#*************************************
#
# rebase feature branch to master
#
#*************************************
echo
echo "--------------------------------------"
echo "starting to rebase from $feature_branch"
echo "--------------------------------------"
echo

## check if we're on in a git repo

git status > /dev/null 2>&1
[[ $? -eq 0  ]] || die 128 "script not running in any git repo. current dir: `pwd`"

############ checkout source branch
git checkout $feature_branch

[[ $? -eq 0 ]] || die 3 "Not able to checkout branch $feature_branch,"

## do rebase here, main onto feature_branch
git rebase $main_branch

## if anything goes wrong, we abort and send email
[[ $? -eq 0 ]] || die 5 "Error rebasing $main_branch from $feature_branch"


######################################################
#
# rebase feature_branch onto main_branch
#
######################################################
echo
echo "--------------------------------------"
echo "starting to rebase from $main_branch"
echo "--------------------------------------"
echo
git checkout $main_branch
 [[ $? -eq 0 ]] || die 7 "error checking out $main_branch"

## feature branch rebase main
git rebase $feature_branch

## if anything goes wrong, we abort 
[[ $? -eq 0 ]] || die 9 "Error rebasing $feature_branch from $main_branch"
