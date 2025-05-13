local Obfuscator = {}
local Random = Random.new()

-- Configuration options
local config = {
    renameVariables = true,
    renameFunctions = true,
    encryptStrings = true,
    insertJunkCode = true,
    mutateNumbers = true,
    maxJunkCode = 5, -- Max junk code blocks to insert
    minVarLength = 3,
    maxVarLength = 12
}

-- Character sets for name generation
local lowercase = "abcdefghijklmnopqrstuvwxyz"
local uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local digits = "0123456789"
local allChars = lowercase .. uppercase .. digits

-- Generate a random identifier
local function randomName(length)
    local name = ""
    for i = 1, length do
        local pos = math.random(1, #allChars)
        name = name .. allChars:sub(pos, pos)
    end
    return name
end

-- String encryption/decryption
local function xorEncrypt(text, key)
    local encrypted = ""
    for i = 1, #text do
        local char = text:sub(i, i)
        local byte = string.byte(char) ~ key
        encrypted = encrypted .. string.char(byte)
    end
    return encrypted
end

-- Number mutation techniques
local function obfuscateNumber(n)
    if not config.mutateNumbers then return tostring(n) end
    
    local methods = {
        function(x) return string.format("(0x%X)", x) end, -- Hex
        function(x) return string.format("(%d+0)", x - x) end, -- Zero
        function(x) return string.format("(%d*1)", x) end, -- Multiply by 1
        function(x) return string.format("(math.floor(%f))", x + 0.0001) end, -- Floor
        function(x) return string.format("(tonumber('%d'))", x) end, -- tonumber
    }
    
    return methods[math.random(1, #methods)](n)
end

-- Generate junk code that does nothing
local function generateJunkCode()
    if not config.insertJunkCode then return "" end
    
    local junkPatterns = {
        "if %s then local %s = %s end",
        "local %s = function() return %s end",
        "for %s = 1, %d do break end",
        "repeat until true",
        "local %s = nil",
        "local %s = %s and %s or %s",
        "local %s = table.concat({%s})"
    }
    
    local pattern = junkPatterns[math.random(1, #junkPatterns)]
    local vars = {}
    local count = pattern:match("()%%s"):len() or 0
    
    for i = 1, count do
        table.insert(vars, randomName(math.random(config.minVarLength, config.maxVarLength)))
    end
    
    return string.format(pattern, unpack(vars))
end

-- Main obfuscation function
function Obfuscator.obfuscate(code)
    -- Phase 1: Parse and collect identifiers
    local identifiers = {}
    local strings = {}
    local numbers = {}
    
    -- Collect all identifiers (simplified regex approach - in reality would need a proper parser)
    for id in code:gmatch("[%a_][%w_]*") do
        if not keywords[id] and not table.find(identifiers, id) then
            table.insert(identifiers, id)
        end
    end
    
    -- Collect strings
    for str in code:gmatch('"(.-)"') do
        table.insert(strings, str)
    end
    for str in code:gmatch("'(.-)'") do
        table.insert(strings, str)
    end
    
    -- Collect numbers
    for num in code:gmatch("%d+%.?%d*") do
        table.insert(numbers, tonumber(num))
    end
    
    -- Phase 2: Create mapping for obfuscation
    local varMap = {}
    local funcMap = {}
    local stringMap = {}
    
    -- Create variable name mappings
    if config.renameVariables then
        for _, id in ipairs(identifiers) do
            varMap[id] = randomName(math.random(config.minVarLength, config.maxVarLength))
        end
    end
    
    -- Create string encryption mappings
    if config.encryptStrings then
        for _, str in ipairs(strings) do
            local key = math.random(1, 255)
            stringMap[str] = {
                encrypted = xorEncrypt(str, key),
                key = key
            }
        end
    end
    
    -- Phase 3: Apply transformations
    local obfuscated = code
    
    -- Replace strings
    if config.encryptStrings then
        for str, data in pairs(stringMap) do
            local replacement = string.format('(function() local k=%d return (%q):gsub(".", function(b) return string.char(b:byte()~k) end) end)()', 
                data.key, data.encrypted)
            obfuscated = obfuscated:gsub('"%s*'..str..'%s*"', '"'..replacement..'"')
            obfuscated = obfuscated:gsub("'%s*"..str.."%s*'", "'"..replacement.."'")
        end
    end
    
    -- Replace numbers
    for _, num in ipairs(numbers) do
        obfuscated = obfuscated:gsub(tostring(num), obfuscateNumber(num))
    end
    
    -- Replace variables
    if config.renameVariables then
        for old, new in pairs(varMap) do
            obfuscated = obfuscated:gsub("%f[%a_]"..old.."%f[^%a_]", new)
        end
    end
    
    -- Insert junk code at random positions
    if config.insertJunkCode then
        local lines = {}
        for line in obfuscated:gmatch("([^\n]*)\n?") do
            table.insert(lines, line)
        end
        
        local junkCount = math.random(1, config.maxJunkCode)
        for i = 1, junkCount do
            local pos = math.random(1, #lines)
            table.insert(lines, pos, generateJunkCode())
        end
        
        obfuscated = table.concat(lines, "\n")
    end
    
    -- Add header with decryption functions
    local header = [[
-- Obfuscated with Lua-Roblox Obfuscator
local function _XOR_DECRYPT(encrypted, key)
    local decrypted = ""
    for i = 1, #encrypted do
        local char = encrypted:sub(i, i)
        local byte = string.byte(char) ~ key
        decrypted = decrypted .. string.char(byte)
    end
    return decrypted
end
]]
    
    return header .. obfuscated
end

-- List of Lua keywords to avoid renaming
local keywords = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
    ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
    ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
    ["while"] = true
}

return Obfuscator