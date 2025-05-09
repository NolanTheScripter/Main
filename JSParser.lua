-- JSParser.lua
local JSParser = {}

-- Map of JS events to Roblox events
local eventMap = {
    -- Mouse events
    ["onclick"] = "MouseButton1Click",
    ["ondblclick"] = "MouseButton1Click", -- Approximate
    ["onmousedown"] = "MouseButton1Down",
    ["onmouseup"] = "MouseButton1Up",
    ["onmouseover"] = "MouseEnter",
    ["onmouseout"] = "MouseLeave",
    ["onmousemove"] = "MouseMoved",
    ["onmouseenter"] = "MouseEnter",
    ["onmouseleave"] = "MouseLeave",
    ["oncontextmenu"] = "MouseButton2Click",
    
    -- Keyboard events
    ["onkeydown"] = "InputBegan", -- Approximate
    ["onkeyup"] = "InputEnded", -- Approximate
    ["onkeypress"] = "InputChanged", -- Approximate
    
    -- Focus events
    ["onfocus"] = "Focused",
    ["onblur"] = "FocusLost",
    
    -- Form events
    ["onchange"] = "Changed",
    ["oninput"] = "TextChanged",
    ["oninvalid"] = nil, -- Not applicable
    ["onreset"] = nil, -- Custom implementation needed
    ["onselect"] = "TextSelected", -- Approximate
    ["onsubmit"] = nil, -- Custom implementation needed
    
    -- Drag events
    ["ondrag"] = nil, -- Custom implementation needed
    ["ondragend"] = nil, -- Custom implementation needed
    ["ondragenter"] = nil, -- Custom implementation needed
    ["ondragleave"] = nil, -- Custom implementation needed
    ["ondragover"] = nil, -- Custom implementation needed
    ["ondragstart"] = nil, -- Custom implementation needed
    ["ondrop"] = nil, -- Custom implementation needed
    
    -- Clipboard events
    ["oncopy"] = nil, -- Custom implementation needed
    ["oncut"] = nil, -- Custom implementation needed
    ["onpaste"] = nil, -- Custom implementation needed
    
    -- Media events
    ["onabort"] = nil, -- Not applicable
    ["oncanplay"] = nil, -- Not applicable
    ["oncanplaythrough"] = nil, -- Not applicable
    ["ondurationchange"] = nil, -- Not applicable
    ["onemptied"] = nil, -- Not applicable
    ["onended"] = nil, -- Not applicable
    ["onerror"] = nil, -- Not applicable
    ["onloadeddata"] = nil, -- Not applicable
    ["onloadedmetadata"] = nil, -- Not applicable
    ["onloadstart"] = nil, -- Not applicable
    ["onpause"] = nil, -- Not applicable
    ["onplay"] = nil, -- Not applicable
    ["onplaying"] = nil, -- Not applicable
    ["onprogress"] = nil, -- Not applicable
    ["onratechange"] = nil, -- Not applicable
    ["onseeked"] = nil, -- Not applicable
    ["onseeking"] = nil, -- Not applicable
    ["onstalled"] = nil, -- Not applicable
    ["onsuspend"] = nil, -- Not applicable
    ["ontimeupdate"] = nil, -- Not applicable
    ["onvolumechange"] = nil, -- Not applicable
    ["onwaiting"] = nil, -- Not applicable
    
    -- Animation events
    ["onanimationend"] = nil, -- Custom implementation needed
    ["onanimationiteration"] = nil, -- Custom implementation needed
    ["onanimationstart"] = nil, -- Custom implementation needed
    
    -- Transition events
    ["ontransitionend"] = nil, -- Custom implementation needed
    
    -- Window events
    ["onafterprint"] = nil, -- Not applicable
    ["onbeforeprint"] = nil, -- Not applicable
    ["onbeforeunload"] = nil, -- Not applicable
    ["onhashchange"] = nil, -- Not applicable
    ["onlanguagechange"] = nil, -- Not applicable
    ["onmessage"] = nil, -- Not applicable
    ["onoffline"] = nil, -- Not applicable
    ["ononline"] = nil, -- Not applicable
    ["onpagehide"] = nil, -- Not applicable
    ["onpageshow"] = nil, -- Not applicable
    ["onpopstate"] = nil, -- Not applicable
    ["onrejectionhandled"] = nil, -- Not applicable
    ["onstorage"] = nil, -- Not applicable
    ["onunhandledrejection"] = nil, -- Not applicable
    ["onunload"] = nil, -- Not applicable
}

-- Map of JS functions to Lua equivalents
local functionMap = {
    ["alert"] = "warn",
    ["console.log"] = "print",
    ["console.warn"] = "warn",
    ["console.error"] = "error",
    ["setTimeout"] = "task.delay",
    ["setInterval"] = "while true do %s task.wait(%d) end",
    ["clearTimeout"] = nil, -- Custom implementation needed
    ["clearInterval"] = nil, -- Custom implementation needed
    ["requestAnimationFrame"] = "RunService.Heartbeat:Connect", -- Approximate
    ["cancelAnimationFrame"] = nil, -- Custom implementation needed
    ["fetch"] = "game:GetService('HttpService'):GetAsync", -- Approximate
    ["localStorage.getItem"] = nil, -- Custom implementation needed
    ["localStorage.setItem"] = nil, -- Custom implementation needed
    ["sessionStorage.getItem"] = nil, -- Custom implementation needed
    ["sessionStorage.setItem"] = nil, -- Custom implementation needed
    ["parseInt"] = "tonumber",
    ["parseFloat"] = "tonumber",
    ["isNaN"] = "function(x) return x ~= x end",
    ["isFinite"] = "function(x) return x > -math.huge and x < math.huge end",
    ["encodeURI"] = "game:GetService('HttpService'):UrlEncode",
    ["encodeURIComponent"] = "game:GetService('HttpService'):UrlEncode",
    ["decodeURI"] = "game:GetService('HttpService'):UrlDecode",
    ["decodeURIComponent"] = "game:GetService('HttpService'):UrlDecode",
    ["Math.random"] = "math.random",
    ["Math.floor"] = "math.floor",
    ["Math.ceil"] = "math.ceil",
    ["Math.round"] = "math.round",
    ["Math.max"] = "math.max",
    ["Math.min"] = "math.min",
    ["Math.abs"] = "math.abs",
    ["Math.sqrt"] = "math.sqrt",
    ["Math.pow"] = "math.pow",
    ["Math.sin"] = "math.sin",
    ["Math.cos"] = "math.cos",
    ["Math.tan"] = "math.tan",
    ["Math.asin"] = "math.asin",
    ["Math.acos"] = "math.acos",
    ["Math.atan"] = "math.atan",
    ["Math.atan2"] = "math.atan2",
    ["Math.log"] = "math.log",
    ["Math.exp"] = "math.exp"
}

-- Map of DOM methods to Roblox equivalents
local domMethodMap = {
    ["getElementById"] = "FindFirstChild",
    ["getElementsByClassName"] = "GetChildren", -- Approximate
    ["getElementsByTagName"] = "GetChildren", -- Approximate
    ["querySelector"] = "FindFirstChild", -- Approximate
    ["querySelectorAll"] = "GetChildren", -- Approximate
    ["createElement"] = "Instance.new",
    ["appendChild"] = "Parent = ",
    ["removeChild"] = "Destroy",
    ["insertBefore"] = "Parent = ", -- Approximate
    ["replaceChild"] = "Parent = ", -- Approximate
    ["addEventListener"] = "Connect",
    ["removeEventListener"] = "Disconnect",
    ["dispatchEvent"] = nil, -- Custom implementation needed
    ["setAttribute"] = nil, -- Convert to property assignment
    ["getAttribute"] = nil, -- Convert to property access
    ["removeAttribute"] = nil, -- Convert to property assignment
    ["hasAttribute"] = nil, -- Convert to property check
    ["classList.add"] = nil, -- Convert to property assignment
    ["classList.remove"] = nil, -- Convert to property assignment
    ["classList.toggle"] = nil, -- Convert to property assignment
    ["classList.contains"] = nil, -- Convert to property check
    ["classList.replace"] = nil, -- Convert to property assignment
    ["classList.item"] = nil, -- Convert to property access
    ["focus"] = "CaptureFocus",
    ["blur"] = "ReleaseFocus",
    ["click"] = "Activate",
    ["scrollIntoView"] = nil, -- Custom implementation needed
    ["insertAdjacentHTML"] = nil, -- Custom implementation needed
    ["insertAdjacentText"] = nil, -- Custom implementation needed
    ["insertAdjacentElement"] = nil, -- Custom implementation needed
    ["matches"] = nil, -- Not applicable
    ["closest"] = nil, -- Not applicable
    ["getBoundingClientRect"] = "AbsolutePosition and AbsoluteSize", -- Approximate
    ["getClientRects"] = nil, -- Not applicable
    ["contains"] = "FindFirstChild", -- Approximate
    ["compareDocumentPosition"] = nil, -- Not applicable
    ["isEqualNode"] = nil, -- Not applicable
    ["isSameNode"] = nil, -- Not applicable
    ["normalize"] = nil, -- Not applicable
    ["cloneNode"] = "Clone"
}

function JSParser.parse(js)
    local parsed = {
        variables = {},
        functions = {},
        eventHandlers = {},
        timers = {},
        domManipulations = {},
        customCode = {}
    }
    
    -- This is a placeholder for actual JavaScript parsing
    -- A real implementation would use a proper JavaScript parser
    
    -- Simple pattern matching for common constructs
    for event, _ in pairs(eventMap) do
        for elementId, handler in js:gmatch("document%.getElementById%(\"([^\"]+)\"%)%."..event.."%s*=%s*([^;]+)") do
            table.insert(parsed.eventHandlers, {
                elementId = elementId,
                event = event,
                handler = handler
            })
        end
    end
    
    -- Find setTimeout/setInterval calls
    for timerType in pairs({setTimeout=true, setInterval=true}) do
        for func, delay in js:gmatch(timerType.."%(([^,]+)%s*,%s*(%d+)%)") do
            table.insert(parsed.timers, {
                type = timerType,
                func = func,
                delay = tonumber(delay) or 0
            })
        end
    end
    
    -- Find variable declarations
    for varType, name, value in js:gmatch("(%a*)%s*(%a[%w_]*)%s*=%s*([^;]+)") do
        table.insert(parsed.variables, {
            varType = varType ~= "" and varType or "var",
            name = name,
            value = value
        })
    end
    
    -- Find function declarations
    for funcType, name, params, body in js:gmatch("(%a*)%s*function%s*([%w_]*)%s*%(([^)]*)%)%s*{([^}]*)}") do
        table.insert(parsed.functions, {
            funcType = funcType ~= "" and funcType or "function",
            name = name,
            params = params,
            body = body
        })
    end
    
    -- Find DOM manipulations
    for method, element, arg in js:gmatch("document%.([%w_]+)%(\"([^\"]+)\"%)%.([^;]+)") do
        table.insert(parsed.domManipulations, {
            method = method,
            element = element,
            arg = arg
        })
    end
    
    -- Add remaining code as custom
    parsed.customCode = js
    
    return parsed
end

function JSParser.generateLua(parsed, domTree, options)
    options = options or {}
    local luaCode = "\n-- JavaScript converted to Lua\n"
    
    -- Add variable declarations
    if #parsed.variables > 0 then
        luaCode = luaCode .. "-- Variables\n"
        for _, var in ipairs(parsed.variables) do
            local value = var.value
            -- Convert JS values to Lua
            value = value:gsub("null", "nil")
                   :gsub("undefined", "nil")
                   :gsub("true", "true")
                   :gsub("false", "false")
                   :gsub("new Date%(", "DateTime.now() -- Approximate: ")
            
            luaCode = luaCode .. "local " .. var.name .. " = " .. value .. "\n"
        end
        luaCode = luaCode .. "\n"
    end
    
    -- Add function declarations
    if #parsed.functions > 0 then
        luaCode = luaCode .. "-- Functions\n"
        for _, func in ipairs(parsed.functions) do
            local params = func.params:gsub("const%s+", ""):gsub("let%s+", ""):gsub("var%s+", "")
            local body = JSParser.convertJSToLua(func.body)
            
            luaCode = luaCode .. "local function " .. (func.name ~= "" and func.name or "") .. "(" .. params .. ")\n"
            luaCode = luaCode .. "    " .. body:gsub("\n", "\n    ") .. "\n"
            luaCode = luaCode .. "end\n\n"
        end
    end
    
    -- Add event handlers
    if #parsed.eventHandlers > 0 then
        luaCode = luaCode .. "-- Event handlers\n"
        for _, handler in ipairs(parsed.eventHandlers) do
            local varName = handler.elementId:gsub("[^%w_]", "_")
            local robloxEvent = eventMap[handler.event] or handler.event
            
            luaCode = luaCode .. varName .. "." .. robloxEvent .. ":Connect(function()\n"
            luaCode = luaCode .. "    " .. JSParser.convertJSToLua(handler.handler):gsub("\n", "\n    ") .. "\n"
            luaCode = luaCode .. "end)\n\n"
        end
    end
    
    -- Add timers
    if #parsed.timers > 0 then
        luaCode = luaCode .. "-- Timers\n"
        for _, timer in ipairs(parsed.timers) do
            if timer.type == "setTimeout" then
                luaCode = luaCode .. "task.delay(" .. (timer.delay / 1000) .. ", function()\n"
                luaCode = luaCode .. "    " .. JSParser.convertJSToLua(timer.func):gsub("\n", "\n    ") .. "\n"
                luaCode = luaCode .. "end)\n\n"
            elseif timer.type == "setInterval" then
                luaCode = luaCode .. "while true do\n"
                luaCode = luaCode .. "    " .. JSParser.convertJSToLua(timer.func):gsub("\n", "\n    ") .. "\n"
                luaCode = luaCode .. "    task.wait(" .. (timer.delay / 1000) .. ")\n"
                luaCode = luaCode .. "end\n\n"
            end
        end
    end
    
    -- Add DOM manipulations
    if #parsed.domManipulations > 0 then
        luaCode = luaCode .. "-- DOM manipulations\n"
        for _, manip in ipairs(parsed.domManipulations) do
            local varName = manip.element:gsub("[^%w_]", "_")
            local method = domMethodMap[manip.method] or manip.method
            local arg = JSParser.convertJSToLua(manip.arg)
            
            if method == "FindFirstChild" then
                luaCode = luaCode .. "local " .. varName .. " = script.Parent:FindFirstChild(\"" .. manip.element .. "\")\n"
            elseif method:match("Parent = ") then
                luaCode = luaCode .. varName .. ".Parent = " .. arg .. "\n"
            else
                luaCode = luaCode .. varName .. ":" .. method .. "(" .. arg .. ")\n"
            end
        end
        luaCode = luaCode .. "\n"
    end
    
    -- Add custom code
    if parsed.customCode ~= "" then
        luaCode = luaCode .. "-- Additional JavaScript code\n"
        luaCode = luaCode .. JSParser.convertJSToLua(parsed.customCode) .. "\n"
    end
    
    return luaCode
end

function JSParser.convertJSToLua(jsCode)
    -- Convert JavaScript syntax to Lua
    local luaCode = jsCode
    
    -- Convert operators
    luaCode = luaCode:gsub("===", "==")
                     :gsub("!==", "~=")
                     :gsub("!=", "~=")
                     :gsub("&&", "and")
                     :gsub("%|%|", "or")
                     :gsub("typeof%s+", "-- typeof: ")
                     :gsub("instanceof", "-- instanceof: ")
                     :gsub("delete%s+", "-- delete: ")
                     :gsub("void%s+", "-- void: ")
                     :gsub("in%s+", "-- in: ")
                     :gsub("new%s+", "-- new: ")
                     :gsub("this%.", "script.Parent.")
                     :gsub("this", "script.Parent")
                     :gsub("console%.log", "print")
                     :gsub("console%.warn", "warn")
                     :gsub("console%.error", "error")
                     :gsub("alert", "warn")
                     :gsub("document%.getElementById%(\"([^\"]+)\"%)", "%1")
                     :gsub("document%.body", "script.Parent")
                     :gsub("window%.", "-- window.")
                     :gsub("localStorage%.", "-- localStorage.")
                     :gsub("sessionStorage%.", "-- sessionStorage.")
                     :gsub("JSON%.parse", "game:GetService('HttpService'):JSONDecode")
                     :gsub("JSON%.stringify", "game:GetService('HttpService'):JSONEncode")
    
    -- Convert arrow functions
    luaCode = luaCode:gsub("(%a+)%s*=>%s*{([^}]*)}", "function(%1)\n%2\nend")
                     :gsub("(%a+)%s*=>%s*([^;]+)", "function(%1) return %2 end")
    
    -- Convert template literals
    luaCode = luaCode:gsub("`([^`]*)`", function(s)
        return "[=[" .. s:gsub("%${([^}]*)}", "] =] .. %1 .. [=[") .. "]=]"
    end)
    
    -- Convert for loops
    luaCode = luaCode:gsub("for%s*%(%s*var%s+(%a+)%s*=%s*(%d+)%s*;%s*%a+%s*<%s*(%d+)%s*;%s*%a+%+%+%s*%)", 
                          "for %1 = %2, %3 - 1 do")
                     :gsub("for%s*%(%s*let%s+(%a+)%s*=%s*(%d+)%s*;%s*%a+%s*<%s*(%d+)%s*;%s*%a+%+%+%s*%)", 
                          "for %1 = %2, %3 - 1 do")
                     :gsub("for%s*%(%s*const%s+(%a+)%s*=%s*(%d+)%s*;%s*%a+%s*<%s*(%d+)%s*;%s*%a+%+%+%s*%)", 
                          "for %1 = %2, %3 - 1 do")
                     :gsub("%+%+", " = %1 + 1")
                     :gsub("--", " = %1 - 1")
    
    -- Convert try/catch
    luaCode = luaCode:gsub("try%s*{([^}]*)}%s*catch%s*%(%a+%)%s*{([^}]*)}", 
                          "local success, err = pcall(function()\n%1\nend)\nif not success then\n%2\nend")
    
    -- Convert switch statements
    for switch in luaCode:gmatch("switch%s*%([^%)]*%)%s*{([^}]*)}") do
        local var = switch:match("switch%s*%(([^%)]*)%)")
        local cases = {}
        for case in switch:gmatch("case%s+([^:]+):([^;]*)") do
            table.insert(cases, {value = case[1], code = case[2]})
        end
        local default = switch:match("default%s*:([^;]*)")
        
        local converted = "if " .. var .. " == " .. cases[1].value .. " then\n" .. cases[1].code
        for i = 2, #cases do
            converted = converted .. "\nelseif " .. var .. " == " .. cases[i].value .. " then\n" .. cases[i].code
        end
        if default then
            converted = converted .. "\nelse\n" .. default .. "\nend"
        else
            converted = converted .. "\nend"
        end
        
        luaCode = luaCode:gsub("switch%s*%([^%)]*%)%s*{([^}]*)}", converted)
    end
    
    return luaCode
end

return JSParser