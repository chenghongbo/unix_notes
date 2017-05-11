#!/bin/bash


#******************************************************************
#
# this script is to get a list of changes for a tag (or release)
# since a previous (old) tag.
#
#  -----------------------
#  script logic:
#
#  1. run git log --pretty=oneline old_tag..new_tag to get a list of 
#     commits (hash and msgs) that's in new_tag but not old_tag, and 
#     store them in array new_tag_msg
#
#  2. run git log --pretty=oneline new_tag..old_tag to get a list of 
#     commits (hash and msgs) that's in old_tag but not new_tag, and 
#     store them in array old_tag_msg
#
#  3. Compare each commit msg in new_tag_msg array with that in
#     old_tag_msg, if the same msg is found, we remove that msg from
#     the array (means the same change has been released in old_tag).
#
#******************************************************************

##-----------------------------------------
## variable definition for later use
##-----------------------------------------

help_msg=$(cat <<-EOFE

##########################################################################

   Missing arguments. Exitting...
   Usage: `basename $0` [-d repo_directory] -n new_tag -o old_tag
	where:
	-d: path to the git repo. If omitted, `pwd` is assumed
	-n: name of new tag or release (eg. v3.0.6). Mandatory.
	-o: name of old tag or release (eg. v2.8.2). Mandatory.

##########################################################################

EOFE
)

gitoptions="--format=%s "
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


while getopts "d:o:n:" FLAG; 
do
	case $FLAG in
		d) # get target directory
			target_dir=$OPTARG
			;;
		n) # get source branch name
			new_tag=$OPTARG
			;;
		o) # get target branch name
			old_tag=$OPTARG
			;;
		*) # show usage msg
			die 111 "$help_msg"
			;;
	esac
done

## check if we get all arguments we need
if [[ "$#" -lt 1 || -z "$new_tag" || -z "$old_tag" ]]
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

## check if we're on in a git repo
git status > /dev/null 2>&1
[[ $? -eq 0  ]] || die 128 "script not running in any git repo. current dir: `pwd`"

[[ -z $(git tag -l "$new_tag") ]] &&  die 3 "tag not found: $new_tag"
[[ -z $(git tag -l "$old_tag") ]] &&  die 5 "tag not found: $old_tag"
## array to store commit msg in each tag
declare -a new_tag_msg
declare -a old_tag_msg
declare -a changelist
count=0
old_count=0
c_count=0 ## for change list index, as $count may not be consequtive

## check what we get is tags or branches
is_tag_new=$(git tag -l "$new_tag")
is_branch_new=$(git branch --list "$new_tag")
is_tag_old=$(git tag -l "$old_tag")
is_branch_old=$(git branch --list "$old_tag")

if [[ -n "$is_tag_new" ]]
then
	continue
fi
	
#for commit in "$(git log "$gitoptions" ${old_tag}..${new_tag})"
while read commit
do
	new_tag_msg[$count]="$commit"
	count=$((count+1))
done < <(git log $gitoptions tags/${old_tag}..tags/${new_tag})

#for commit in $(git log $gitoptions ${new_tag}..${old_tag})
while read commit
do
	old_tag_msg[$old_count]="$commit"
	old_count=$((old_count+1))
done < <(git log $gitoptions tags/${new_tag}..tags/${old_tag})

for i in `seq 0 $(($count-1))`
do
	keep_me=true ## check if this msg needs to be put on change list
	for j in `seq 0 $(($old_count-1))`
	do
		if [[ "${new_tag_msg[$i]}" == "${old_tag_msg[$j]}" ]]
		then
			keep_me=false
		fi
	done
	
	if [[ "$keep_me" == "true" ]]
	then
		changelist[$c_count]="${new_tag_msg[$i]}"
		c_count=$(($c_count+1))
	fi
done

## check if changelist is empty
if [[ ${#changelist} -gt 0 ]]
then
	for msg in `seq 0 $(($c_count-1))`
	do
		## format can be further customized according to requirments
		printf '%3d.  %s\n' $msg "${changelist[$msg]}"
	done
else ## no changes
	echo "no changes in this release ($new_tag)"	
fi
