What is Dtrace?
What can it do for us?
which OS is Dtrace available on?

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
