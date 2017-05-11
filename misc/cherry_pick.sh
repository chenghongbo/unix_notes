#!/bin/bash


#******************************************************************
#
# this script is to port commit in a long running RC branch back to
# main or master branch, by doing git cherry-pick
# detailed usage:
#  -f to specify name of feature branch (or source branch), mandatory
#  -m to specify name of main branch (or master branch).    mandatory
#  -d to specify path to the git repo. If omitted, `pwd` is assumed
#  -t to instruct script run in test mode. No argument needed.
#
#  -----------------------
#  script logic:
#
#  1. checkout main branch

#  2. run git log --pretty=oneline master..RC to get a list of commit
#     (hash and msgs) that's in RC but not master branch, and store 
#     them in array RC_COMMIT_HASH and RC_COMMIT_MSG, respectively
#
#  3. run git log --pretty=oneline RC..master to get a list of commit
#     (hash and msgs) that's in master branch but not RC, and store 
#     them in array MAIN_COMMIT_HASH and MAIN_COMMIT_MSG, respectively
#
#  4. Compare each commit msg stored in RC_COMMIT_MSG array with that in
#     MAIN_COMMIT_MSG, if the same msg is found, we skip cherry-picking
#     the commit corresponding to that msg. if not, do git cherry-picking
#
#******************************************************************

##-----------------------------------------
## variable definition for later use
##-----------------------------------------

help_msg=$(cat <<-EOFE

##########################################################################

   Missing arguments. Exitting...
   Usage: `basename $0` [-d repo_directory] [-t] -f feature_branch -m main_branch
	where:
	-d: path to the git repo. If omitted, `pwd` is assumed
	-t: instruct script run in test mode. No argument needed
	-f: name of feature branch. mandatory.
	-m: name of main branch (or master branch). mandatory.

##########################################################################

EOFE
)

gitoptions="--pretty=oneline"
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


while getopts "d:f:m:t" FLAG; 
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
		t) # run in test mode
			testmode=true
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


## check if user.email or user.name is set
[[ -z "$(git config --get user.name)" || -z "$(git config --get user.email)" ]] && die 19 "user.email or user.name not set for git. Exiting..."

## check if we're on in a git repo
git status > /dev/null 2>&1
[[ $? -eq 0  ]] || die 128 "script not running in any git repo. current dir: `pwd`"

[[ $testmode == "true" ]] && echo "******* running in test mode *********"

############ checkout source branch
git checkout $feature_branch || die 3 "Not able to checkout branch $feature_branch,"
git checkout $main_branch



echo
echo "------------------------------------------------------------------------"
echo "getting list of commits in $feature_branch but not $main_branch"
echo "------------------------------------------------------------------------"
echo

## an array to store RC commit hash and msg
declare -a RC_COMMIT_MSG
declare -a RC_COMMIT_HASH
count=0
#for commit in "$(git log "$gitoptions" ${main_branch}..${feature_branch})"
while read commit
do
	temp_array=($commit)
	RC_COMMIT_HASH[$count]=${temp_array[0]}
	RC_COMMIT_MSG[$count]=${temp_array[@]:1}
	count=$((count+1))
done < <(git log $gitoptions ${main_branch}..${feature_branch})

echo
echo "------------------------------------------------------------------------"
echo "getting list of commits in $main_branch but not $feature_branch"
echo "------------------------------------------------------------------------"
echo

declare -a MAIN_COMMIT_MSG
declare -a MAIN_COMMIT_HASH
main_count=0
#for commit in $(git log $gitoptions ${feature_branch}..${main_branch})

while read commit
do
	temp_array=($commit)
	MAIN_COMMIT_HASH[$main_count]=${temp_array[0]}
	MAIN_COMMIT_MSG[$main_count]=${temp_array[@]:1}
	main_count=$((main_count+1))
done < <(git log $gitoptions ${feature_branch}..${main_branch})

for i in `seq 0 $(($count-1))`
do
	is_cherry="true"
	for j in `seq 0 $(($main_count-1))`
	do
		if [[ "${RC_COMMIT_MSG[$i]}" == "${MAIN_COMMIT_MSG[$j]}" ]]
		then
			is_cherry=false
		fi
	done
	if [[ $is_cherry == "true" ]] ## commit msg not found in main branch commit log
	then
		if [[ $testmode == "true" ]]
		then
			echo " [dry-run]: will be cherry-picked: ${RC_COMMIT_HASH[$i]} ${RC_COMMIT_MSG[$i]}"
		else
			echo "cherry picking ${RC_COMMIT_HASH[$i]} ${RC_COMMIT_MSG[$i]} ..."
			git cherry-pick ${RC_COMMIT_HASH[$i]} || die $? "cherry pick for ${RC_COMMIT_HASH[$i]} failed. exiting..."
		fi
	fi
done
