-- Python.lua
local Python = {}

-- Basic Functions (already implemented)
-- ... (keep all existing functions from previous implementation)

------------------
-- Time/Datetime --
------------------
Python.datetime = {
    now = function()
        return os.date("*t")
    end,
    
    strftime = function(format, time)
        time = time or os.time()
        return os.date(format, time)
    end,
    
    timestamp = function()
        return os.time()
    end,
    
    timedelta = function(days, seconds, microseconds, milliseconds, minutes, hours, weeks)
        return {
            days = days or 0,
            seconds = seconds or 0,
            microseconds = microseconds or 0,
            milliseconds = milliseconds or 0,
            minutes = minutes or 0,
            hours = hours or 0,
            weeks = weeks or 0
        }
    end
}

----------------
-- Statistics --
----------------
Python.statistics = {
    mean = function(tbl)
        return Python.sum(tbl) / #tbl
    end,
    
    median = function(tbl)
        local sorted = Python.sorted(tbl)
        local n = #sorted
        if n % 2 == 1 then
            return sorted[math.floor(n/2) + 1]
        else
            return (sorted[n/2] + sorted[n/2 + 1]) / 2
        end
    end,
    
    mode = function(tbl)
        local counts = {}
        local max_count = 0
        local mode_value
        
        for _, v in ipairs(tbl) do
            counts[v] = (counts[v] or 0) + 1
            if counts[v] > max_count then
                max_count = counts[v]
                mode_value = v
            end
        end
        
        return mode_value
    end,
    
    stdev = function(tbl)
        local m = Python.statistics.mean(tbl)
        local sum_sq = 0
        for _, v in ipairs(tbl) do
            sum_sq = sum_sq + (v - m)^2
        end
        return math.sqrt(sum_sq / #tbl)
    end
}

------------
-- String --
------------
Python.string = {
    capitalize = function(s)
        return s:sub(1,1):upper() .. s:sub(2):lower()
    end,
    
    lower = function(s)
        return s:lower()
    end,
    
    upper = function(s)
        return s:upper()
    end,
    
    title = function(s)
        return s:gsub("(%a)([%w_']*)", function(first, rest) 
            return first:upper() .. rest:lower() 
        end)
    end,
    
    isdigit = function(s)
        return s:match("^%d+$") ~= nil
    end,
    
    isalpha = function(s)
        return s:match("^%a+$") ~= nil
    end,
    
    isalnum = function(s)
        return s:match("^%w+$") ~= nil
    end,
    
    startswith = function(s, prefix)
        return s:sub(1, #prefix) == prefix
    end,
    
    endswith = function(s, suffix)
        return #s >= #suffix and s:sub(-#suffix) == suffix
    end,
    
    find = function(s, sub, start, _end)
        start = start or 1
        _end = _end or #s
        local i = s:sub(start, _end):find(sub)
        return i and (i + start - 1) or -1
    end,
    
    replace = function(s, old, new, count)
        count = count or -1
        local result, n = s:gsub(old, new, count)
        return result, n
    end
}

--------
-- Set --
--------
Python.set = function(tbl)
    local set = {}
    for _, v in ipairs(tbl or {}) do
        set[v] = true
    end
    
    local methods = {
        add = function(self, value)
            self[value] = true
        end,
        
        remove = function(self, value)
            if not self[value] then
                error("Value not in set")
            end
            self[value] = nil
        end,
        
        discard = function(self, value)
            self[value] = nil
        end,
        
        union = function(self, other)
            local result = Python.set({})
            for k in pairs(self) do result[k] = true end
            for k in pairs(other) do result[k] = true end
            return result
        end,
        
        intersection = function(self, other)
            local result = Python.set({})
            for k in pairs(self) do
                if other[k] then result[k] = true end
            end
            return result
        end,
        
        difference = function(self, other)
            local result = Python.set({})
            for k in pairs(self) do
                if not other[k] then result[k] = true end
            end
            return result
        end,
        
        issubset = function(self, other)
            for k in pairs(self) do
                if not other[k] then return false end
            end
            return true
        end,
        
        tolist = function(self)
            local result = {}
            for k in pairs(self) do
                table.insert(result, k)
            end
            return result
        end
    }
    
    return setmetatable(set, {
        __index = methods,
        __tostring = function(self)
            local items = {}
            for k in pairs(self) do
                table.insert(items, tostring(k))
            end
            return "{" .. table.concat(items, ", ") .. "}"
        end,
        __len = function(self)
            local count = 0
            for _ in pairs(self) do count = count + 1 end
            return count
        end
    })
end

---------
-- Tuple --
---------
Python.tuple = function(...)
    local t = {...}
    if #t == 1 and type(t[1]) == "table" then
        t = Python.slice(t[1])
    end
    
    return setmetatable(t, {
        __index = {
            count = function(self, value)
                local count = 0
                for _, v in ipairs(self) do
                    if v == value then count = count + 1 end
                end
                return count
            end,
            
            index = function(self, value)
                for i, v in ipairs(self) do
                    if v == value then return i - 1 end
                end
                error("Value not in tuple")
            end
        },
        __tostring = function(self)
            local items = Python.map(tostring, self)
            return "(" .. table.concat(items, ", ") .. ")"
        end,
        __add = function(a, b)
            local result = Python.slice(a)
            for _, v in ipairs(b) do
                table.insert(result, v)
            end
            return Python.tuple(result)
        end,
        __eq = function(a, b)
            if #a ~= #b then return false end
            for i = 1, #a do
                if a[i] ~= b[i] then return false end
            end
            return true
        end
    })
end

---------------
-- Dictionary --
---------------
Python.dict = function(tbl)
    tbl = tbl or {}
    local dict = {}
    
    -- If list of pairs, convert to dict
    if Python.isinstance(tbl, "list") then
        for _, pair in ipairs(tbl) do
            if type(pair) == "table" and #pair >= 2 then
                dict[pair[1]] = pair[2]
            end
        end
    else
        for k, v in pairs(tbl) do
            dict[k] = v
        end
    end
    
    local methods = {
        get = function(self, key, default)
            if self[key] ~= nil then
                return self[key]
            else
                return default
            end
        end,
        
        items = function(self)
            local items = {}
            for k, v in pairs(self) do
                table.insert(items, Python.tuple(k, v))
            end
            return items
        end,
        
        keys = function(self)
            local keys = {}
            for k in pairs(self) do
                table.insert(keys, k)
            end
            return keys
        end,
        
        values = function(self)
            local values = {}
            for _, v in pairs(self) do
                table.insert(values, v)
            end
            return values
        end,
        
        update = function(self, other)
            for k, v in pairs(other) do
                self[k] = v
            end
        end,
        
        pop = function(self, key, default)
            local value = self[key]
            if value == nil and default ~= nil then
                return default
            end
            self[key] = nil
            return value
        end,
        
        copy = function(self)
            return Python.dict(self)
        end
    }
    
    return setmetatable(dict, {
        __index = methods,
        __tostring = function(self)
            local items = {}
            for k, v in pairs(self) do
                table.insert(items, tostring(k) .. ": " .. tostring(v))
            end
            return "{" .. table.concat(items, ", ") .. "}"
        end,
        __len = function(self)
            local count = 0
            for _ in pairs(self) do count = count + 1 end
            return count
        end
    })
end

--------
-- Math --
--------
Python.math = {
    pi = math.pi,
    e = math.exp(1),
    
    ceil = math.ceil,
    floor = math.floor,
    fabs = math.abs,
    sqrt = math.sqrt,
    exp = math.exp,
    log = function(x, base)
        base = base or math.exp(1)
        return math.log(x) / math.log(base)
    end,
    pow = math.pow,
    sin = math.sin,
    cos = math.cos,
    tan = math.tan,
    asin = math.asin,
    acos = math.acos,
    atan = math.atan,
    atan2 = math.atan2,
    degrees = math.deg,
    radians = math.rad,
    
    gcd = function(a, b)
        while b ~= 0 do
            a, b = b, a % b
        end
        return math.abs(a)
    end,
    
    factorial = function(n)
        if n < 0 then error("Factorial not defined for negative numbers") end
        local result = 1
        for i = 2, n do
            result = result * i
        end
        return result
    end,
    
    isclose = function(a, b, rel_tol, abs_tol)
        rel_tol = rel_tol or 1e-09
        abs_tol = abs_tol or 0.0
        return math.abs(a - b) <= math.max(rel_tol * math.max(math.abs(a), math.abs(b)), abs_tol)
    end
}

-------
-- OS --
-------
Python.os = {
    name = function()
        if package.config:sub(1,1) == "\\" then
            return "nt"
        else
            return "posix"
        end
    end,
    
    getcwd = function()
        return io.popen("cd"):read("*l")
    end,
    
    listdir = function(path)
        path = path or "."
        local p = io.popen(Python.os.name() == "nt" and "dir /b "..path or "ls -a "..path)
        local files = {}
        for file in p:lines() do
            table.insert(files, file)
        end
        p:close()
        return files
    end,
    
    path = {
        exists = function(filename)
            local f = io.open(filename, "r")
            if f ~= nil then
                io.close(f)
                return true
            else
                return false
            end
        end,
        
        isfile = function(filename)
            if not Python.os.path.exists(filename) then return false end
            local p = io.popen(Python.os.name() == "nt" and "dir /a-d "..filename or "test -f "..filename)
            local result = p:read("*a")
            p:close()
            return result ~= ""
        end,
        
        isdir = function(dirname)
            if not Python.os.path.exists(dirname) then return false end
            local p = io.popen(Python.os.name() == "nt" and "dir /ad "..dirname or "test -d "..dirname)
            local result = p:read("*a")
            p:close()
            return result ~= ""
        end,
        
        join = function(...)
            local parts = {...}
            local path = ""
            for i, part in ipairs(parts) do
                if i > 1 then
                    path = path .. (path:sub(-1) == "/" and "" or "/")
                end
                path = path .. part
            end
            return path
        end
    }
}

--------
-- File --
--------
Python.open = function(filename, mode)
    mode = mode or "r"
    local file = io.open(filename, mode)
    
    if not file then
        error("Could not open file: " .. filename)
    end
    
    local methods = {
        read = function(self, size)
            if size then
                return self.file:read(size)
            else
                return self.file:read("*a")
            end
        end,
        
        readline = function(self)
            return self.file:read("*l")
        end,
        
        readlines = function(self)
            local lines = {}
            for line in self.file:lines() do
                table.insert(lines, line)
            end
            return lines
        end,
        
        write = function(self, content)
            return self.file:write(content)
        end,
        
        writelines = function(self, lines)
            for _, line in ipairs(lines) do
                self.file:write(line .. "\n")
            end
        end,
        
        close = function(self)
            return self.file:close()
        end,
        
        seek = function(self, offset, whence)
            whence = whence or "set"
            local modes = {set = "set", cur = "cur", end = "end"}
            return self.file:seek(modes[whence], offset)
        end,
        
        tell = function(self)
            return self.file:seek("cur")
        end
    }
    
    return setmetatable({file = file}, {
        __index = methods,
        __gc = function(self)
            if self.file then self.file:close() end
        end
    })
end

----------
-- Random --
----------
Python.random = {
    random = math.random,
    
    seed = function(x)
        math.randomseed(x or os.time())
    end,
    
    randint = function(a, b)
        return math.random(a, b)
    end,
    
    choice = function(tbl)
        return tbl[math.random(1, #tbl)]
    end,
    
    shuffle = function(tbl)
        local result = Python.slice(tbl)
        for i = #result, 2, -1 do
            local j = math.random(1, i)
            result[i], result[j] = result[j], result[i]
        end
        return result
    end,
    
    uniform = function(a, b)
        return a + math.random() * (b - a)
    end,
    
    gauss = function(mu, sigma)
        local u1, u2 = math.random(), math.random()
        local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
        return mu + z0 * sigma
    end
}

---------------------
-- Data Type Conversion --
---------------------
Python.int = function(x, base)
    base = base or 10
    if type(x) == "string" then
        return tonumber(x, base)
    else
        return math.floor(x)
    end
end

Python.float = tonumber

Python.str = tostring

Python.bool = function(x)
    if not x then return false end
    if type(x) == "boolean" then return x end
    if type(x) == "number" then return x ~= 0 end
    if type(x) == "string" then return #x > 0 end
    if type(x) == "table" then return next(x) ~= nil end
    return true
end

Python.list = function(x)
    if type(x) == "table" then
        local result = {}
        for _, v in ipairs(x) do
            table.insert(result, v)
        end
        return result
    elseif type(x) == "string" then
        local result = {}
        for c in x:gmatch(".") do
            table.insert(result, c)
        end
        return result
    else
        return {x}
    end
end

Python.tuple = function(...)
    return Python.tuple(...)
end

Python.dict = function(x)
    return Python.dict(x)
end

Python.set = function(x)
    return Python.set(x)
end

Python.bytes = function(x, encoding)
    encoding = encoding or "utf-8"
    if type(x) == "string" then
        local bytes = {}
        for i = 1, #x do
            table.insert(bytes, string.byte(x:sub(i, i)))
        end
        return bytes
    elseif type(x) == "table" then
        return Python.slice(x)
    else
        error("Cannot convert to bytes")
    end
end

--------
-- List --
--------
Python.list = function(x)
    if type(x) == "table" then
        local result = {}
        for _, v in ipairs(x) do
            table.insert(result, v)
        end
        return result
    elseif type(x) == "string" then
        local result = {}
        for c in x:gmatch(".") do
            table.insert(result, c)
        end
        return result
    else
        return {x}
    end
end

-- Add list methods to all tables created with Python.list
local list_methods = {
    append = function(self, value)
        table.insert(self, value)
    end,
    
    extend = function(self, other)
        for _, v in ipairs(other) do
            table.insert(self, v)
        end
    end,
    
    insert = function(self, index, value)
        table.insert(self, index, value)
    end,
    
    remove = function(self, value)
        for i, v in ipairs(self) do
            if v == value then
                table.remove(self, i)
                return
            end
        end
        error("Value not in list")
    end,
    
    pop = function(self, index)
        index = index or #self
        return table.remove(self, index)
    end,
    
    index = function(self, value)
        for i, v in ipairs(self) do
            if v == value then return i - 1 end
        end
        error("Value not in list")
    end,
    
    count = function(self, value)
        local count = 0
        for _, v in ipairs(self) do
            if v == value then count = count + 1 end
        end
        return count
    end,
    
    sort = function(self, key, reverse)
        key = key or function(x) return x end
        table.sort(self, function(a, b)
            local a_val = key(a)
            local b_val = key(b)
            if reverse then
                return a_val > b_val
            else
                return a_val < b_val
            end
        end)
    end,
    
    reverse = function(self)
        for i = 1, math.floor(#self / 2) do
            self[i], self[#self - i + 1] = self[#self - i + 1], self[i]
        end
    end,
    
    copy = function(self)
        return Python.list(self)
    end
}

-- Metatable for list objects
local list_metatable = {
    __index = list_methods,
    __tostring = function(self)
        local items = Python.map(tostring, self)
        return "[" .. table.concat(items, ", ") .. "]"
    end,
    __add = function(a, b)
        local result = Python.list(a)
        result:extend(b)
        return result
    end,
    __mul = function(a, b)
        if type(a) == "number" then
            a, b = b, a
        end
        local result = Python.list()
        for i = 1, b do
            result:extend(a)
        end
        return result
    end
}

-- Override Python.list to include methods
local original_list = Python.list
Python.list = function(x)
    local lst = original_list(x)
    return setmetatable(lst, list_metatable)
end

return Python