-- this starts a single line comment

--[[ while this starts a multiline
      comment 

]]

-- lua为动态类型脚本语言， 意味着无需为变量设定类型
 a = 5
 b = 'string' -- 或 b = "string"
 c = 7; d = 8
 e = 9 f = 10 -- 也有效，但不推荐
 g = a*c
 h = false -- 布尔型
--  (g,h) = (11,12) 无效赋值
 k = '\x61\x6c\x6f\x0a\x31\x32\x33\x22' -- alo\n123"


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

 print(a, b, c,d,e,f,g,h,k)
 print(10 + 1) -- 11
 print("10 + 1") -- 10 + 1


 -- tables
 
 t = {}
 t["key"] = "value"
 t[10] = "another string"
 print(t) -- 输出t的内存地址
 print(t["key"],t[10]) -- t[key] 无效
