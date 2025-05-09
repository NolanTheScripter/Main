-- HTMLParser.lua
local HTMLParser = {}

-- Complete HTML element mapping based on MDN documentation
local elementMap = {
    -- Document metadata
    ["head"] = {instance = "Frame", hidden = true},
    ["title"] = {instance = "TextLabel", parent = "head", textOnly = true},
    ["base"] = {instance = nil}, -- Not applicable
    ["link"] = {instance = nil}, -- Stylesheets handled separately
    ["meta"] = {instance = nil}, -- Not applicable
    ["style"] = {instance = nil}, -- CSS handled separately
    
    -- Content sectioning
    ["body"] = {instance = "Frame", root = true},
    ["header"] = "Frame",
    ["footer"] = "Frame",
    ["section"] = "Frame",
    ["article"] = "Frame",
    ["nav"] = "Frame",
    ["aside"] = "Frame",
    ["h1"] = {instance = "TextLabel", defaultSize = 36},
    ["h2"] = {instance = "TextLabel", defaultSize = 30},
    ["h3"] = {instance = "TextLabel", defaultSize = 24},
    ["h4"] = {instance = "TextLabel", defaultSize = 18},
    ["h5"] = {instance = "TextLabel", defaultSize = 14},
    ["h6"] = {instance = "TextLabel", defaultSize = 12},
    
    -- Text content
    ["p"] = "TextLabel",
    ["pre"] = {instance = "TextLabel", font = "Code", preserveWhitespace = true},
    ["blockquote"] = {instance = "Frame", children = {
        {instance = "TextLabel", property = "Text", value = "❝", position = UDim2.new(0, -20, 0, 0)},
        {instance = "TextLabel", property = "Text", value = "❞", position = UDim2.new(1, 0, 1, -20)}
    }},
    ["ol"] = {instance = "ScrollingFrame", layout = "UIListLayout", listType = "ordered"},
    ["ul"] = {instance = "ScrollingFrame", layout = "UIListLayout", listType = "unordered"},
    ["li"] = {instance = "Frame", layout = "UIPadding", paddingLeft = 20},
    ["dl"] = {instance = "Frame", layout = "UIListLayout"},
    ["dt"] = {instance = "TextLabel", font = "SourceSansBold"},
    ["dd"] = {instance = "TextLabel", indent = 20},
    ["figure"] = "Frame",
    ["figcaption"] = {instance = "TextLabel", position = "bottom"},
    ["main"] = "Frame",
    ["div"] = "Frame",
    ["hr"] = {instance = "Frame", size = UDim2.new(1, 0, 0, 1), bgColor = Color3.fromRGB(200, 200, 200)},
    
    -- Inline text semantics
    ["a"] = {instance = "TextButton", textColor = Color3.fromRGB(0, 102, 204), underline = true},
    ["abbr"] = {instance = "TextLabel", tooltip = true},
    ["b"] = {instance = "TextLabel", font = "SourceSansBold"},
    ["strong"] = {instance = "TextLabel", font = "SourceSansBold"},
    ["i"] = {instance = "TextLabel", font = "SourceSansItalic"},
    ["em"] = {instance = "TextLabel", font = "SourceSansItalic"},
    ["mark"] = {instance = "TextLabel", bgColor = Color3.fromRGB(255, 255, 0)},
    ["small"] = {instance = "TextLabel", textScale = 0.8},
    ["s"] = {instance = "TextLabel", strikeThrough = true},
    ["cite"] = {instance = "TextLabel", font = "SourceSansItalic"},
    ["q"] = {instance = "TextLabel", prefix = "❝", suffix = "❞"},
    ["code"] = {instance = "TextLabel", font = "Code", bgColor = Color3.fromRGB(240, 240, 240)},
    ["var"] = {instance = "TextLabel", font = "SourceSansItalic"},
    ["samp"] = {instance = "TextLabel", font = "Code"},
    ["kbd"] = {instance = "TextLabel", font = "Code", bgColor = Color3.fromRGB(240, 240, 240), border = true},
    ["sub"] = {instance = "TextLabel", position = "subscript"},
    ["sup"] = {instance = "TextLabel", position = "superscript"},
    ["time"] = "TextLabel",
    ["data"] = "TextLabel",
    ["span"] = "TextLabel",
    ["br"] = {instance = "TextLabel", text = "\n", size = UDim2.new(1, 0, 0, 0)},
    ["wbr"] = nil, -- Not applicable
    
    -- Image and multimedia
    ["img"] = {instance = "ImageLabel", missingImage = "rbxassetid://4483345998"},
    ["picture"] = {instance = "ImageLabel", responsive = true},
    ["source"] = {instance = nil}, -- Handled by picture
    ["audio"] = {instance = "Sound", ui = true},
    ["video"] = {instance = "VideoFrame"},
    ["track"] = nil, -- Not supported
    ["embed"] = nil, -- Not supported
    ["object"] = nil, -- Not supported
    ["iframe"] = {instance = "Frame", border = true}, -- Limited support
    
    -- Embedded content
    ["canvas"] = {instance = "Frame", customRenderer = true},
    ["svg"] = {instance = "Frame", customRenderer = true},
    ["math"] = {instance = "TextLabel", font = "Code"}, -- Limited math support
    
    -- Scripting
    ["script"] = nil, -- Handled separately
    ["noscript"] = nil, -- Not applicable
    ["template"] = nil, -- Not supported
    
    -- Demarcating edits
    ["del"] = {instance = "TextLabel", strikeThrough = true, textColor = Color3.fromRGB(200, 0, 0)},
    ["ins"] = {instance = "TextLabel", underline = true, textColor = Color3.fromRGB(0, 200, 0)},
    
    -- Table content
    ["table"] = {instance = "Frame", layout = "Grid"},
    ["caption"] = {instance = "TextLabel", position = "top"},
    ["colgroup"] = {instance = nil}, -- Handled by table
    ["col"] = {instance = nil}, -- Handled by table
    ["tbody"] = {instance = "Frame", layout = "VerticalList"},
    ["thead"] = {instance = "Frame", layout = "VerticalList", header = true},
    ["tfoot"] = {instance = "Frame", layout = "VerticalList", footer = true},
    ["tr"] = {instance = "Frame", layout = "HorizontalList"},
    ["td"] = {instance = "TextLabel", border = true, padding = 5},
    ["th"] = {instance = "TextLabel", border = true, padding = 5, font = "SourceSansBold"},
    
    -- Forms
    ["form"] = {instance = "Frame", layout = "VerticalList"},
    ["input"] = {
        ["text"] = "TextBox",
        ["password"] = {instance = "TextBox", hideText = true},
        ["email"] = "TextBox",
        ["number"] = {instance = "TextBox", keyboardType = "NumberPad"},
        ["tel"] = {instance = "TextBox", keyboardType = "PhonePad"},
        ["url"] = "TextBox",
        ["search"] = "TextBox",
        ["date"] = {instance = "TextBox", customPicker = true},
        ["time"] = {instance = "TextBox", customPicker = true},
        ["datetime-local"] = {instance = "TextBox", customPicker = true},
        ["month"] = {instance = "TextBox", customPicker = true},
        ["week"] = {instance = "TextBox", customPicker = true},
        ["color"] = {instance = "TextButton", colorPicker = true},
        ["checkbox"] = {instance = "ImageButton", toggle = true},
        ["radio"] = {instance = "ImageButton", radioGroup = true},
        ["range"] = {instance = "Frame", slider = true},
        ["file"] = {instance = "TextButton", filePicker = true},
        ["submit"] = {instance = "TextButton", formSubmit = true},
        ["image"] = {instance = "ImageButton", formSubmit = true},
        ["reset"] = {instance = "TextButton", formReset = true},
        ["button"] = "TextButton",
        ["hidden"] = {instance = "Frame", visible = false}
    },
    ["button"] = "TextButton",
    ["select"] = {instance = "TextButton", dropdown = true},
    ["datalist"] = {instance = "Frame", dropdownOptions = true},
    ["optgroup"] = {instance = "TextLabel", group = true},
    ["option"] = {instance = "TextButton", selectable = true},
    ["textarea"] = {instance = "TextBox", multiLine = true},
    ["output"] = "TextLabel",
    ["progress"] = {instance = "Frame", progressBar = true},
    ["meter"] = {instance = "Frame", progressBar = true},
    ["fieldset"] = {instance = "Frame", border = true},
    ["legend"] = {instance = "TextLabel", position = "top-left"},
    
    -- Interactive elements
    ["details"] = {instance = "Frame", collapsible = true},
    ["summary"] = {instance = "TextButton", collapsibleHeader = true},
    ["dialog"] = {instance = "Frame", modal = true},
    ["menu"] = {instance = "Frame", layout = "VerticalList"},
    ["menuitem"] = {instance = "TextButton", menuItem = true},
    
    -- Web Components
    ["slot"] = {instance = "Frame", slot = true},
    ["template"] = nil -- Not supported
}

-- Default properties for Roblox instances
local defaultProperties = {
    Frame = {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0
    },
    TextLabel = {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    },
    TextButton = {
        BackgroundColor3 = Color3.fromRGB(99, 99, 99),
        Size = UDim2.new(0, 100, 0, 30),
        Text = "Button",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        AutoButtonColor = true
    },
    TextBox = {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 200, 0, 30),
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        ClearTextOnFocus = false,
        TextWrapped = false
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 100),
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Stretch
    },
    ImageButton = {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 100),
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Stretch,
        AutoButtonColor = true
    },
    ScrollingFrame = {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 12,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    }
}

function HTMLParser.parse(html)
    -- Advanced HTML parsing with DOM construction
    local document = {
        type = "document",
        children = {},
        nodeName = "#document"
    }
    
    local currentParent = document
    local stack = {}
    local selfClosingTags = {
        area = true, base = true, br = true, col = true, embed = true,
        hr = true, img = true, input = true, link = true, meta = true,
        param = true, source = true, track = true, wbr = true
    }
    
    -- Parse HTML with proper tag handling
    for tag, attrs, content in html:gmatch("<(/?)([%w-]+)(.-)(%/?)>([^<]*)") do
        local isClosing = tag == "/"
        local isSelfClosing = attrs == "/" or selfClosingTags[tag]
        local tagName = tag:lower()
        
        if isClosing then
            -- Closing tag
            if stack[#stack] and stack[#stack].nodeName == tagName then
                currentParent = table.remove(stack)
            end
        else
            -- Opening tag
            local element = {
                nodeName = tagName,
                attributes = HTMLParser.parseAttributes(attrs),
                children = {},
                parent = currentParent
            }
            
            -- Handle special elements
            if tagName == "style" then
                element.content = content
            elseif tagName == "script" then
                element.content = content
            elseif not isSelfClosing and content and content:match("%S") then
                element.textContent = content:gsub("^%s*(.-)%s*$", "%1")
            end
            
            table.insert(currentParent.children, element)
            
            if not isSelfClosing then
                table.insert(stack, currentParent)
                currentParent = element
            end
        end
    end
    
    return document
end

function HTMLParser.parseAttributes(attrString)
    local attributes = {}
    
    for name, value in attrString:gmatch('(%w+)%s*=%s*"([^"]*)"') do
        attributes[name] = value
    end
    
    for name, value in attrString:gmatch("(%w+)%s*=%s*'([^']*)'") do
        attributes[name] = value
    end
    
    for name in attrString:gmatch("(%w+)%s*=") do
        if not attributes[name] then
            attributes[name] = true
        end
    end
    
    return attributes
end

function HTMLParser.applyStyles(document, stylesheet)
    -- Implement CSS specificity rules (inline > id > class > tag)
    local function applyStyles(node)
        -- Calculate specificity for each rule
        local matchedRules = {}
        
        -- Match tag selectors
        if stylesheet[node.nodeName] then
            table.insert(matchedRules, {
                selector = node.nodeName,
                specificity = 0x0001,
                styles = stylesheet[node.nodeName]
            })
        end
        
        -- Match class selectors
        if node.attributes and node.attributes.class then
            for className in node.attributes.class:gmatch("[^%s]+") do
                local selector = "." .. className
                if stylesheet[selector] then
                    table.insert(matchedRules, {
                        selector = selector,
                        specificity = 0x0010,
                        styles = stylesheet[selector]
                    })
                end
            end
        end
        
        -- Match ID selectors
        if node.attributes and node.attributes.id then
            local selector = "#" .. node.attributes.id
            if stylesheet[selector] then
                table.insert(matchedRules, {
                    selector = selector,
                    specificity = 0x0100,
                    styles = stylesheet[selector]
                })
            end
        end
        
        -- Match attribute selectors
        if node.attributes then
            for attr, value in pairs(node.attributes) do
                local selector = "[" .. attr .. "]"
                if stylesheet[selector] then
                    table.insert(matchedRules, {
                        selector = selector,
                        specificity = 0x0010,
                        styles = stylesheet[selector]
                    })
                end
                
                selector = "[" .. attr .. "=" .. value .. "]"
                if stylesheet[selector] then
                    table.insert(matchedRules, {
                        selector = selector,
                        specificity = 0x0010,
                        styles = stylesheet[selector]
                    })
                end
            end
        end
        
        -- Sort by specificity (higher first)
        table.sort(matchedRules, function(a, b)
            return a.specificity > b.specificity
        end)
        
        -- Apply styles in order of specificity
        node.computedStyle = {}
        for _, rule in ipairs(matchedRules) do
            for prop, value in pairs(rule.styles) do
                node.computedStyle[prop] = value
            end
        end
        
        -- Apply inline styles (highest specificity)
        if node.attributes and node.attributes.style then
            local inlineStyles = CSSParser.parseInlineStyles(node.attributes.style)
            for prop, value in pairs(inlineStyles) do
                node.computedStyle[prop] = value
            end
        end
        
        -- Process children
        for _, child in ipairs(node.children) do
            applyStyles(child)
        end
    end
    
    applyStyles(document)
end

function HTMLParser.generateLua(node, parentVar, options, indent)
    indent = indent or ""
    options = options or {}
    parentVar = parentVar or "script.Parent"
    
    local luaCode = ""
    local comments = options.generateComments
    
    local function createInstance(element, varName)
        local elementInfo = elementMap[element.nodeName] or elementMap.div
        local instanceType = type(elementInfo) == "table" and elementInfo.instance or elementInfo
        instanceType = instanceType or "Frame" -- Default to Frame
        
        -- Special handling for input elements
        if element.nodeName == "input" and element.attributes and element.attributes.type then
            local inputType = element.attributes.type
            if type(elementMap.input) == "table" and elementMap.input[inputType] then
                elementInfo = elementMap.input[inputType]
                instanceType = type(elementInfo) == "table" and elementInfo.instance or elementInfo
            end
        end
        
        -- Create instance
        luaCode = luaCode .. indent .. "local " .. varName .. " = Instance.new(\"" .. instanceType .. "\")\n"
        
        -- Set name if available
        if element.attributes and element.attributes.id then
            luaCode = luaCode .. indent .. varName .. ".Name = \"" .. element.attributes.id .. "\"\n"
        elseif element.attributes and element.attributes.name then
            luaCode = luaCode .. indent .. varName .. ".Name = \"" .. element.attributes.name .. "\"\n"
        end
        
        -- Apply default properties
        local defaults = defaultProperties[instanceType] or defaultProperties.Frame
        for prop, value in pairs(defaults) do
            luaCode = luaCode .. indent .. varName .. "." .. prop .. " = " .. HTMLParser.valueToLua(value) .. "\n"
        end
        
        -- Apply computed styles
        if element.computedStyle then
            local styleProps = CSSParser.cssToRobloxProperties(element.computedStyle, element.nodeName)
            for prop, value in pairs(styleProps) do
                luaCode = luaCode .. indent .. varName .. "." .. prop .. " = " .. HTMLParser.valueToLua(value) .. "\n"
            end
        end
        
        -- Apply special attributes
        if element.attributes then
            -- Handle common attributes
            if element.attributes.hidden then
                luaCode = luaCode .. indent .. varName .. ".Visible = false\n"
            end
            
            if element.attributes.disabled and (instanceType == "TextButton" or instanceType == "TextBox") then
                luaCode = luaCode .. indent .. varName .. ".Active = false\n"
            end
            
            if element.attributes.title then
                luaCode = luaCode .. indent .. "-- Tooltip: " .. element.attributes.title .. "\n"
            end
            
            -- Handle input-specific attributes
            if element.nodeName == "input" then
                if element.attributes.placeholder then
                    luaCode = luaCode .. indent .. varName .. ".PlaceholderText = \"" .. element.attributes.placeholder .. "\"\n"
                end
                
                if element.attributes.value then
                    luaCode = luaCode .. indent .. varName .. ".Text = \"" .. element.attributes.value .. "\"\n"
                end
                
                if element.attributes.checked and (element.attributes.type == "checkbox" or element.attributes.type == "radio") then
                    luaCode = luaCode .. indent .. varName .. ".Checked = true\n"
                end
            end
            
            -- Handle textarea
            if element.nodeName == "textarea" and element.attributes.placeholder then
                luaCode = luaCode .. indent .. varName .. ".PlaceholderText = \"" .. element.attributes.placeholder .. "\"\n"
            end
        end
        
        -- Set text content if applicable
        if element.textContent and (instanceType == "TextLabel" or instanceType == "TextButton" or instanceType == "TextBox") then
            luaCode = luaCode .. indent .. varName .. ".Text = [=[" .. element.textContent .. "]=]\n"
        end
        
        -- Handle special elements
        if element.nodeName == "a" and element.attributes and element.attributes.href then
            luaCode = luaCode .. indent .. "-- Hyperlink: " .. element.attributes.href .. "\n"
        end
        
        if element.nodeName == "img" and element.attributes and element.attributes.src then
            luaCode = luaCode .. indent .. varName .. ".Image = \"" .. element.attributes.src .. "\"\n"
        end
        
        -- Create child elements for com