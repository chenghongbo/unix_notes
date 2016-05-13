What is Dtrace?
What can it do for us?
which OS is Dtrace available on?

What is a probe?
A probe that has a module and function as part of its name is known as an anchored probe, and one that does not is known as unanchored.

How to specify a probe?
	provider:module:function:name

	where: 

	Provider: The name of the DTrace provider that is publishing this probe. The provider name typically
	corresponds to the name of the DTrace kernel module that performs the instrumentation to
	enable the probe.


	Module: If this probe corresponds to a specific program location, the name of the module in which the
	probe is located. This name is either the name of a kernel module or the name of a user library.

	Function: If this probe corresponds to a specific program location, the name of the program function in
	which the probe is located.


	Name: The final component of the probe description is a name that gives you some idea of the probe's
	semantic meaning, such as BEGIN or END.
	This name can be referenced in a D program by using the built-in variable probename.


====  Aggregations   ====
Aggregations are a special variable type used to summarize data. They are prefixed with an at (@) sign 
and are populated by aggregating functions.

@a = count();

populates an aggregation,  a, that counts the number of times it was invoked.

Aggregations can be printed and emptied explicitly with the  printa() and
trunc() functions (covered later in the chapter). Aggregations not explicitly
printed or truncated are automatically printed at the end of D programs. They
cannot be tested in predicates.

Aggregations may have keys, like associative arrays.

@a[pid] = count();

will count events separately by pid (process ID). The aggregation will be printed
as a table with the keys on the left and values on the right, sorted on the values in
ascending order.

An aggregation without a name, @, may be used for D programs (especially one-
liners) that use only one aggregation and so don’t need a name to differentiate
them.

Function			Arguments			Result
--------------------------------------------------------------------------------------------------------
count				None				The number of times called.
--------------------------------------------------------------------------------------------------------
sum					Scalar				The total value.
--------------------------------------------------------------------------------------------------------
avg					Scalar				The arithmetic average.
--------------------------------------------------------------------------------------------------------
min					Scalar				The smallest value.
--------------------------------------------------------------------------------------------------------
max					Scalar				The largest value.
--------------------------------------------------------------------------------------------------------
stddev				Scalar				The standard deviation.
--------------------------------------------------------------------------------------------------------
lquantize			Scalar,				A linear frequency distribution, sized by the specified 
					lower bound,		range, of the values of the specified expressions. Incre-
					upper bound,		ments the value in the highest bucket that is less than the 
					step				specified expression. 
--------------------------------------------------------------------------------------------------------
quantize			Scalar				A power-of-two frequency distribution of the values of 
										the specified expressions. Increments the value in the 
										highest power-of-two bucket that is less than the specified expression. 
--------------------------------------------------------------------------------------------------------

The trunc() function can either completely clear an aggregation, leaving no keys

	trunc(@a)

or truncate an aggregation to the top number of keys specified. For example, this
function truncates to the top 10:

	trunc(@a,10)
	
The clear() function clears the values of keys but leaves the keys in the aggregation.

The normalize() function can divide an aggregation by a value. The example

normalize(@a, 1024);

will divide the @a aggregation values by 1,024; this may be used before printing to
convert values to kilobytes instead of bytes.

The printa() function prints an aggregation during a D program execution and
is similar to printf(). 

@a[x, y] = sum(z);

	where the key consists of the integer x and string y, may be printed using
	
printa("%10d %-32s %@8d\n", @a);

which formats the key into columns: x, 10 characters wide and right-justified; y, 32
characters wide and left-justified. The aggregation value for each key is printed
using the %@ format code, eight characters wide and right-justified.


The printa() function can also print multiple aggregations:

printa("%10s %@8d %@8d\n", @a, @b);

The aggregations must share the same key to be printed in the same printa().
By default, sorting is in ascending order by the first aggregation. Several options
exist for changing the default sort behavior and for picking which aggregation to
sort by.
aggsortkey: Sort by key order; any ties are broken by value.
aggsortrev: Reverse sort.
aggsortpos: Position of the aggregation to use as primary sort key.
aggsortkeypos: Position of key to use as primary sort key.

The aggregation sort options can be used in combination.


DTrace actions may include built-in functions to print and process data and to
modify the execution of the program or the system (in a carefully controlled man-
ner). Several key functions are listed here.
Actions that print output (for example, trace() and printf()) will also print
default output columns from DTrace (CPU ID, probe ID, probe name), which can
be suppressed with quiet mode (see “Options” section). The output may also
become shuffled on multi-CPU systems because of the way DTrace collects per-
CPU buffers and prints them out, and a time stamp field can be included in the
output for postsorting, if accurate; chronological order is required.


The trace() action takes a single argument and prints it: 

trace(x)

This prints the variable x, which may be an integer, string, or pointer to binary
data. DTrace chooses an appropriate method for printing, which may include print-
ing hexadecimal (hex dump).


Variables can be printed with formatting using printf(), based on the C version:

printf(format, arguments ...)

The format string can contain regular text, plus directives, to describe how to
format the remaining arguments. Directives comprise the following.

	%: To indicate a format directive.
	-: (Optional.) To change justification from right to left.
	width: (Optional.) Width of column as an integer.  Text will overflow if needed.
	.length: (Optional.) To truncate to the length given.
	type: Covered in a moment.
	
Types include the following.
	a: Convert pointer argument to kernel symbol name.
	A: Convert pointer argument to user-land symbol name.
	d: Integer (any size).
	c: Character.
	f: Float.
	s: String.
	S: Escaped string (binary character safe).
	u: Unsigned integer (any size).
	Y: Convert nanoseconds since epoch (walltimestamp) to time string.

For example,

printf("%-8d %32.32s %d bytes\n", a, b, c);

prints the a variable as an integer in an 8-character-wide, left-justified column; the
b variable as a string in a 32-character-wide, right-justified column, and with no
overflow; and the c variable as an integer, followed by the text bytes and the new
line character \n.

To print a region of memory, the tracemem() function can be used. The example

tracemem(p, 256);

prints 256 bytes starting at the p pointer, in hexadecimal. If tracemem() is given
a data type it can recognize, such as a NULL-terminated string, it will print that in
a meaningful way (not as a hex dump).

DTrace operates in the kernel address space. To access data from the user-land
address space associated with a process, copyin() can be used. The example

a = copyin(p, 256);

copies 256 bytes of data from the p user-land pointer into the variable a. The buf-
fer pointers on the  read(2) and  write(2) syscalls are examples of user-land
pointers, so that

syscall::write:entry { w = copyin(arg0, arg2); }

will copy the data from write(2) into the w variable.


To inform DTrace that a pointer is a string, use stringof(). The example

printf("%s", stringof(p));

treats the p pointer variable as a string and prints it out using printf().


stringof()works only on pointers in the kernel address space; for user-land
pointers, use copyinstr(). For example, the first argument to the open(2) sys-
call is a user-land pointer to the path; it can be printed using the following:

syscall::open:entry { trace(copyinstr(arg0)); }


The stack() action fetches the current kernel stack back trace. Used alone,

	stack()

prints out the stack trace when the probe fires, with a line of output per stack
frame. To print a maximum of five stack frames only, use this:

	stack(5)

It can also be used as keys for aggregations. For example, the action

	@a[stack()] = count();

counts invocations by stack trace; that is, when the aggregation is printed, a list of
stack traces will be shown along with the counts for each stack, in ascending order.
To print them in printa() statements, use the %k format directive.