#!/bin/sh

f_lsr() {
   local file dir=$1  # local variables make recursion possible
   cd "$dir" || return
   set -- .* *   # positional parameters deal correctly with spaces, etc.
   for file do
      test "$file" = "." -o "$file" = ".." && continue
      printf '%s/%s\n' "$dir" "$file"
      test -d "$file" -a ! -L "$file" && f_lsr "$dir/$file"
   done
   cd ..
}

f_lsr "$1"
