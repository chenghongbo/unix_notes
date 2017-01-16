What is Dtrace?
What can it do for us?
which OS is Dtrace available on?

==== D program structure ====

	probes /predicate/ { actions }
	probes /predicate/ { actions }
	...

When probes fire, the predicate test determines whether to execute the actions
(also called the clause), which are a series of statements. Without the predicate,
the actions are always executed. Without a predicate or an action, a default line of
output is printed to indicate that the probe fired. The only valid combinations are
the following:

	probes
	probes { actions }
	probes /predicate/ { actions }

The actions may be left blank, but when doing so, the braces are still necessary.

==== What is a probe ====

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


==== predicates ====

Instead of conditional statements (if/then/else), DTrace has predicates. Predi-
cates evaluate their expression and, if true, execute the action statements that fol-
low in the clause. The expression is written in D, similar to the C language. For
example, the predicate

	/uid == 101/

will execute the action that follows only if the uid variable (current user ID) is
equal to 101.

==== Actions
Actions can be a single statement or multiple statements separated by semicolons:

	{ action one; action two; action three }

------------------------------------------  variables  ---------------------------------------
==== Associative Arrays
Associative arrays can contain multiple values accessed via a key. They are
declared with an assignment of the following form:

	name[key] = expression;

The key may be a comma-separated list of expressions. The example

	a[123, "foo"] = 456;

declares a key of the integer 123 and the string foo, storing the integer value 456.
Associative arrays have the same issues as scalars, with the potential to become
corrupted if multiple CPUs modify the same key/value simultaneously.

==== Thread local variables ====

Thread-local variables are stored with the current thread of execution. They have
this prefix:

	self->

To declare a thread-local variable, set a value. The example

	self->x = 1;

declares a thread-local variable, x, to contain the value 1.

If thread-local variables are set but not freed after use, memory may be con-
sumed needlessly while those threads still exist on the system. Once the thread is
destroyed, the thread-local variables are freed.

Thread-local variables should be used in preference to scalars and associative
arrays wherever possible to avoid the possibility of multiple CPUs writing to the
same D variable location and the contents becoming corrupted.

==== Clause local variables ====

Clause-local variables are for use within a single of action group { }. They have
this prefix:

	this->

To declare a clause-local variable, set a value. The example

	this->y = 1;

declares a clause-local variable, y, to contain the value 1.

Clause-local variables do not need to be freed; this is done automatically when
the probe finishes executing all actions associated with that probe. If there are
multiple probe { action } groups for the same probe, clause-local variables can
be accessed across the action groups.

They should be used for temporary variables within an action, because they
have the lowest performance cost of all the variable types.

==== Built-in ====

A variety of built-in variables are available as scalar globals.

Variable Name	Type		Description
arg0...arg9	uint64_t	Probe arguments; content is provider-specific
args[] 		*		Typed probe arguments; content is provider-specific
cpu		processorid_t	CPU ID of the current CPU
curpsinfo	psinfo_t	Process state info for the current thread
curthread	kthread_t	Operating system internal kernel thread structure for the current thread
errno		int		Error value from the last system call
execname	string		The name of the current process
pid		pid_t		Process ID for current process
ppid		pid_t		Parent process ID for current process
......


It is common to use built-in variables in predicates in order to gather data for
specific processes, threads, or events of interest. The example

	/execname == "ls" /

is a predicate that will cause the actions in the clause to be executed only when the
process name is ls.

==== Macros  =====

DTrace provides macro variables including the ones presented in below table.
For example, a D script called file.d could match the $target process ID in a
predicate:

	/pid == $target/

which is provided to the D script at the command line,

      	./file.d -p 123

so the predicate will fire the action clause only if the specified process ID, 123, is
on-CPU.

Variable Name	Type			Description
$target		pid_t			Process ID specified using -p PID or -c command
$1..$N		Integer or string	Command-line arguments to dtrace(1M)
$$1..$$N	String (forced)		Command-line arguments to dtrace(1M)

==== External Variables ====

External variables are defined by the operating system (external to DTrace) and
accessed by prefixing the kernel variable name with a backquote. The kernel inte-
ger variable k could be printed using this:

	printf("k: %d\n",`k);

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

Function	Arguments		Result
--------------------------------------------------------------------------------------------------------
count		None			The number of times called.
--------------------------------------------------------------------------------------------------------
sum		Scalar			The total value.
--------------------------------------------------------------------------------------------------------
avg		Scalar			The arithmetic average.
--------------------------------------------------------------------------------------------------------
min		Scalar			The smallest value.
--------------------------------------------------------------------------------------------------------
max		Scalar			The largest value.
--------------------------------------------------------------------------------------------------------
stddev		Scalar			The standard deviation.
--------------------------------------------------------------------------------------------------------
lquantize	Scalar,			A linear frequency distribution, sized by the specified 
		lower bound,		range, of the values of the specified expressions. Incre-
		upper bound,		ments the value in the highest bucket that is less than the 
		step			specified expression. 
--------------------------------------------------------------------------------------------------------
quantize	Scalar			A power-of-two frequency distribution of the values of the 
					specified expressions. Increments the value in the highest 
					power-of-two bucket that is less than the specified expression. 
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







==============================   checking system view ==============================

About CPU utilization

A specific example of this is memory bus I/O. CPU “load” and “store” instruc-
tions may stall while on-CPU, waiting for the memory bus to complete a data
transfer. 

Since these stall cycles occur during a CPU instruction, they’re treated as
utilized, although perhaps not in the expected way (utilized while waiting!).
The level of parallelism of the workload is also a factor; 

a single-threaded application may consume 100 percent of a single CPU, leaving 
other CPUs virtually idle. In such a scenario, on systems with a large number 
of CPUs, tools that aggregate utilization would indicate very low systemwide 
CPU utilization, potentially steering you away from looking more closely at CPUs. 

A highly threaded workload with lock contention in the application may show many 
CPUs running at 100 percent utilization, but most of the threads are spinning on 
locks, rather than doing the work they were designed to do. The key point is that 
CPU utilization alone is not sufficient to determine to what extent the CPUs 
themselves are the real performance problem.

It is instructive to know exactly what the CPUs are doing—whether that is the
processing of instructions or memory I/O stall cycles—and for what applications or
kernel software.


CPU related Providers:

Provider		Description
profile, tick 		These providers allow for time-based data collection and 
			are very useful for kernel and user CPU profiling.

sched			Observing scheduling activity is key to understanding CPU 
			usage on loaded systems.

proc			The proc provider lets you observe key process/thread events.

sysinfo			This is important for tracking systemwide events that relate 
			to CPU usage.  

fbt 			The function boundary tracing provider can be used to examine 
			CPU usage by kernel function.

pid 			The pid provider enables instrumenting unmodified user code 
			for drilling down on application profiling.

lockstat 		lockstat is both a DTrace consumer (lockstat(1M)) and a special 
			provider used for observing kernel locks and kernel profiling.

syscall 		Observing system calls is generally a good place to start, 
			because system calls are where applications meet the kernel, 
			and they can provide insight as to what the workload is doing.

plockstat 		This provides statistics on user locks. It can identify lock 
			contention in application code.

The profile probe has two arguments: arg0 and arg1. arg0 is the program
counter (PC) of the current instruction if the CPU is running in the kernel, and
arg1 is the PC of the current instruction if the CPU is executing in user mode.
Thus, the test /arg0/ (arg0 != 0) equates to “is the CPU executing in the ker-
nel?” and /arg1/ (arg1 != 0) equates to “is the CPU executing in user mode?”

Which processes are on-CPU?
	dtrace -n 'profile-997hz { @[pid, execname] = count(); }'

Which processes are on-CPU, running user code?
	dtrace -n 'profile-997hz /arg1/ { @[pid, execname] = count(); }'

What are the top user functions running on-CPU (%usr time)?
	dtrace -n 'profile-997hz /arg1/ { @[execname, ufunc(arg1)] = count(); }'

What are the top kernel functions running on-CPU (%sys time)?
	dtrace -n 'profile-997hz /arg0/ { @[func(arg0)] = count(); }'

What are the top five kernel stack traces on the CPU (shows why)?
	dtrace -n 'profile-997hz { @[stack()] = count(); } END { trunc(@, 5); }'

What are the top five user stack traces on the CPU (shows why)?
	dtrace -n 'profile-997hz { @[ustack()] = count(); } END { trunc(@, 5); }'

What threads are on-CPU, counted by their thread name (FreeBSD)?
	dtrace -n 'profile-997 { @[stringof(curthread->td_name)] = count(); }'
