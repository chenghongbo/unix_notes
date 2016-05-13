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