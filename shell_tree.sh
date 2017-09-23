#!/usr/bin/env bash
#set -x
count=0
indent="    "
prefix="-- "
lead='|'
list_recur() {
	local item dir=$1  # variable to store file or dir name
	local depth=$count
	cd "$dir" || return  ## if not a directory, exit
	set -- .* *
	for item do
		test "$item" = '.' -o "$item" = '..' -o "$item" = ".git" && continue
		echo -n "$lead"
		for i in `seq $count`
		do
			echo -n "$indent"
			## print a $lead character (|) in place of its parent
			## so that the look continous
			test $i -eq $(($count - 1)) && echo -n "$lead"
		done
		if test $count -gt 0; then
		#if [[ $count -gt 0 ]]; then
			echo -n "$lead"
		fi
		echo -n "$prefix"
		echo $item
		if test -d "$item" ; then
			 count=$(($count + 1))
			 list_recur "$dir/$item"
		fi
	done
	cd ..
	count=$(($count - 1))
}
echo $1
list_recur $1
