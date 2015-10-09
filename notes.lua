-- this starts a single line comment

--[[ while this starts a multiline
      comment 

]]

-- lua为动态类型脚本语言， 意味着无需为变量设定类型
-- 变量名称有效字符集为大小写字母，数字和下划线
-- 但变量不可以数字开头
-- 尽量不要使用下划线加全大写字母的变量，因为可能和一些内置变量冲突
--
 a = 5
 b = 'string' -- 或 b = "string"
 c = 7; d = 8
 e = 9 f = 10 -- 也有效，但不推荐
 g = a*c
 h = false -- 布尔型
--  (g,h) = (11,12) 无效赋值
 i = "Hello" .. " World!"
 k = '\x61\x6c\x6f\x0a\x31\x32\x33\x22' -- alo\n123"

 m,n = 5,9,10 -- 10 将会被丢弃
 m,n,p = 5,9    -- p 为nil

-- 长字符串
--
page = [[
<html>
<head>
<title>An HTML Page</title>
</head>
<body>
<a href="http://www.lua.org">Lua</a>
</body>
</html>
]]

 print(a, b, c,d,e,f,g,h,i,k)
 print(10 + 1) -- 11
 print("10 + 1") -- 10 + 1


 -- tables
 
 t = {}
 t["key"] = "value"
 t[10] = "another string"
 print(t) -- 输出t的内存地址
 print(t["key"],t[10]) -- t[key] 无效

 -- 变量作用域
 --
 -- global 变量

 a = "test string" -- global
 local b = "test string"  -- local

 -- local的作用域为他们定义时所在的最小的代码块: 函数，控制结构，花括号，文件
 -- 注意，在互动模式下，每行都是一个代码块（除非命令是要分多行输入)
 --

 x = 10
 if i > 20 then
	 local x -- local to the "then" body
	 x = 20
	 print(x + 2) -- -- (would print 22 if test succeeded)
 else
	 print(x) -- --> 10 (the global one)
 end
 print(x) -- --> 10 (the global one)


--  分支结构

if a < 0 then a = 0 end
if a < b then return a else return b end
if line > MAXLINES then
	showpage()
	line = 0
end

if op == "+" then
	r = a + b
elseif op == "-" then
	r = a - b
elseif op == "*" then
	r = a*b
elseif op == "/" then
	r = a/b
else
	error("invalid operation")
end

-- lua没有switch语句
--
local i = 1
while a[i] do
	print(a[i])
	i = i + 1
end


-- print the first non-empty input line
 repeat
	 line = io.read()
 until line ~= ""
 print(line)


--[[ unlike in most other languages, in Lua the scope of a local variable declared
inside the loop includes the condition:
]]
local sqr = x/2
repeat
	sqr = (sqr + x/sqr)/2
	local error = math.abs(sqr^2 - x)
until error < x/10000   -- local 'error' still visible here

-- numeric for 循环
--
for var = exp1, exp2, exp3 do
	<something>
end

--[[
The for loop has some subtleties that you should learn in order to make good
use of it. First, all three expressions are evaluated once, before the loop starts.
For instance, in our first example, Lua calls f(x) only once. Second, the control
variable is a local variable automatically declared by the for statement, and it
is visible only inside the loop.
]]

-- generic for loop 

-- print all values of table 't'
 for k, v in pairs(t) do print(k, v) end
 

 -- about break/return/goto
 --
 --[[
 The break and return statements allow us to jump out of a block. The goto
 statement allows us to jump to almost any point in a function.
 We use the break statement to finish a loop. This statement breaks the inner
 loop (for, repeat, or while) that contains it; it cannot be used outside a loop.
 After the break, the program continues running from the point immediately
 after the broken loop.
 A return statement returns occasional results from a function or simply
 finishes the function. There is an implicit return at the end of any function, so
 you do not need to write one if your function ends naturally, without returning
 any value.
 For syntactic reasons, a return can appear only as the last statement of a
 block: in other words, as the last statement in your chunk or just before an
 end, an else, or an until. For instance, in the next example, return is the last
 statement of the then block.
 ]]
 --
 --函数
 --
function fn_name(x)
	 -- statements
	return x
end

function f(a,b) print(a,b) end

-- function in lua can return multiple results

s, e = string.find("hello Lua users", "Lua")
print(s, e) --> 7 9

-- also in assignment

function foo2 () return "a", "b" end

x,y,z = 10,foo2() -- x=10, y="a", z="b"
x,y,z = foo2(),10 -- y=10, x="a", z=nil, 函数如果不在赋值语句的最后，则只使用它的第一个返回值

--[[
--Beware that a return statement does not need parentheses around the returned
--value; any pair of parentheses placed there counts as an extra pair. Therefore,
--a statement like return (f(x)) always returns one single value, no matter how
--many values f returns.
--]]
--
--A function in Lua can be variadic, that is, it can receive a variable number of
--arguments. For instance, we have already called print with one, two, and more
--arguments. Although print is defined in C, we can define variadic functions in
--Lua, too.
--As a simple example, the following function returns the summation of all its
--arguments:
function add (...)
	local s = 0
	for i, v in ipairs{...} do
		s = s + v
	end
	return s
end
print(add(3, 4, 10, 25, 12))


--[[ 
Functions in Lua are first-class values with proper lexical scoping.
What does it mean for functions to be “first-class values”? It means that,
in Lua, a function is a value with the same rights as conventional values like
numbers and strings. We can store functions in variables (both global and local)
and in tables, we can pass functions as arguments to and return them from other
functions.
What does it mean for functions to have “lexical scoping”? It means that
functions can access variables of their enclosing functions. 1 As we will see
in this chapter, this apparently innocuous property brings great power to the
language, because it allows us to apply in Lua many powerful programming
techniques from the functional-language world. Even if you have no interest at
all in functional programming, it is worth learning a little about how to explore
these techniques, because they can make your programs smaller and simpler.
A somewhat confusing notion in Lua is that functions, like all other values,
are anonymous; they do not have names. When we talk about a function
name, such as print , we are actually talking about a variable that holds that
function. Like any other variable holding any other value, we can manipulate
such variables in many ways. The following example, although a little silly,
shows the point:
 ]]
 a = {p = print}
 a.p("Hello World") --> Hello World
 print = math.sin ---- 'print' now refers to the sine function
 a.p(print(1)) ----> 0.841470
 sin = a.p ---- 'sin' now refers to the print function
 sin(10, 20) ----> 10 20
