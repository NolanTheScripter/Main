-- CSSParser.lua
local CSSParser = {}

-- Extended CSS property to Roblox property mapping
local propertyMap = {
    -- Box model
    ["width"] = function(value, element)
        local num = tonumber(value:match("%d+")) or 0
        local unit = value:match("%a+$") or "px"
        
        if unit == "%" then
            return {Size = UDim2.new(num / 100, 0, element.computedStyle.height and nil or 1, 0)}
        else
            return {Size = UDim2.new(0, num, element.computedStyle.height and nil or 0, 0)}
        end
    end,
    
    ["height"] = function(value, element)
        local num = tonumber(value:match("%d+")) or 0
        local unit = value:match("%a+$") or "px"
        
        if unit == "%" then
            return {Size = UDim2.new(element.computedStyle.width and nil or 1, 0, num / 100, 0)}
        else
            return {Size = UDim2.new(element.computedStyle.width and nil or 0, 0, 0, num)}
        end
    end,
    
    ["min-width"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {MinSize = Vector2.new(num, 0)}
    end,
    
    ["max-width"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {MaxSize = Vector2.new(num, 99999)}
    end,
    
    ["min-height"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {MinSize = Vector2.new(0, num)}
    end,
    
    ["max-height"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {MaxSize = Vector2.new(99999, num)}
    end,
    
    ["margin"] = function(value)
        local top, right, bottom, left = CSSParser.parseBoxValue(value)
        return {
            UIPadding = {
                PaddingTop = UDim.new(0, top),
                PaddingRight = UDim.new(0, right),
                PaddingBottom = UDim.new(0, bottom),
                PaddingLeft = UDim.new(0, left)
            }
        }
    end,
    
    ["padding"] = function(value)
        local top, right, bottom, left = CSSParser.parseBoxValue(value)
        return {
            UIPadding = {
                PaddingTop = UDim.new(0, top),
                PaddingRight = UDim.new(0, right),
                PaddingBottom = UDim.new(0, bottom),
                PaddingLeft = UDim.new(0, left)
            }
        }
    end,
    
    -- Positioning
    ["position"] = function(value)
        if value == "absolute" then
            return {Position = UDim2.new(0, 0, 0, 0)}
        elseif value == "relative" then
            return {} -- Default in Roblox
        elseif value == "fixed" then
            return {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0)}
        end
        return {}
    end,
    
    ["top"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {Position = UDim2.new(0, 0, 0, num)}
    end,
    
    ["right"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {Position = UDim2.new(1, -num, 0, 0)}
    end,
    
    ["bottom"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {Position = UDim2.new(0, 0, 1, -num)}
    end,
    
    ["left"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {Position = UDim2.new(0, num, 0, 0)}
    end,
    
    ["z-index"] = function(value)
        return {ZIndex = tonumber(value) or 1}
    end,
    
    -- Flexbox/grid layout (simplified)
    ["display"] = function(value, element)
        if value == "flex" then
            if element.computedStyle["flex-direction"] == "column" then
                return {UIListLayout = {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)}}
            else
                return {UIListLayout = {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), FillDirection = Enum.FillDirection.Horizontal}}
            end
        elseif value == "grid" then
            return {UIGridLayout = {
                CellSize = UDim2.new(0, 100, 0, 100),
                CellPadding = UDim2.new(0, 5, 0, 5)
            }}
        elseif value == "none" then
            return {Visible = false}
        end
        return {}
    end,
    
    ["flex-direction"] = function(value)
        if value == "column" then
            return {UIListLayout = {FillDirection = Enum.FillDirection.Vertical}}
        elseif value == "row" then
            return {UIListLayout = {FillDirection = Enum.FillDirection.Horizontal}}
        end
        return {}
    end,
    
    ["flex-wrap"] = function(value)
        if value == "wrap" then
            return {UIGridLayout = {FillDirectionMaxCells = 0}}
        end
        return {}
    end,
    
    ["justify-content"] = function(value)
        local map = {
            ["flex-start"] = Enum.HorizontalAlignment.Left,
            ["flex-end"] = Enum.HorizontalAlignment.Right,
            ["center"] = Enum.HorizontalAlignment.Center,
            ["space-between"] = Enum.HorizontalAlignment.Center, -- Approximate
            ["space-around"] = Enum.HorizontalAlignment.Center -- Approximate
        }
        if map[value] then
            return {UIListLayout = {HorizontalAlignment = map[value]}}
        end
        return {}
    end,
    
    ["align-items"] = function(value)
        local map = {
            ["flex-start"] = Enum.VerticalAlignment.Top,
            ["flex-end"] = Enum.VerticalAlignment.Bottom,
            ["center"] = Enum.VerticalAlignment.Center,
            ["stretch"] = Enum.VerticalAlignment.Center -- Approximate
        }
        if map[value] then
            return {UIListLayout = {VerticalAlignment = map[value]}}
        end
        return {}
    end,
    
    -- Visual styling
    ["background-color"] = function(value)
        return {BackgroundColor3 = CSSParser.parseColor(value)}
    end,
    
    ["background"] = function(value)
        -- Simplified background parser
        if value:match("url%(") then
            local url = value:match("url%([\"']?(.-)[\"']?%)")
            return {BackgroundColor3 = Color3.fromRGB(255, 255, 255), Image = url}
        else
            return {BackgroundColor3 = CSSParser.parseColor(value)}
        end
    end,
    
    ["color"] = function(value)
        return {TextColor3 = CSSParser.parseColor(value)}
    end,
    
    ["font-family"] = function(value)
        local fontMap = {
            ["Arial"] = Enum.Font.Arial,
            ["Helvetica"] = Enum.Font.SourceSans,
            ["Verdana"] = Enum.Font.SourceSans,
            ["Times New Roman"] = Enum.Font.SourceSans,
            ["Courier New"] = Enum.Font.Code,
            ["monospace"] = Enum.Font.Code,
            ["sans-serif"] = Enum.Font.SourceSans,
            ["serif"] = Enum.Font.SourceSans
        }
        
        -- Try each font in order
        for font in value:gmatch("[^,]+") do
            font = font:gsub("^%s*(.-)%s*$", "%1"):gsub("['\"]", "")
            if fontMap[font] then
                return {Font = fontMap[font]}
            end
        end
        
        return {Font = Enum.Font.SourceSans}
    end,
    
    ["font-size"] = function(value)
        local num = tonumber(value:match("%d+")) or 14
        return {TextSize = num}
    end,
    
    ["font-weight"] = function(value)
        if value == "bold" or tonumber(value) and tonumber(value) >= 600 then
            return {Font = Enum.Font.SourceSansBold}
        end
        return {}
    end,
    
    ["font-style"] = function(value)
        if value == "italic" then
            return {Font = Enum.Font.SourceSansItalic}
        end
        return {}
    end,
    
    ["text-align"] = function(value)
        local map = {
            ["left"] = Enum.TextXAlignment.Left,
            ["right"] = Enum.TextXAlignment.Right,
            ["center"] = Enum.TextXAlignment.Center,
            ["justify"] = Enum.TextXAlignment.Left -- No justify in Roblox
        }
        if map[value] then
            return {TextXAlignment = map[value]}
        end
        return {}
    end,
    
    ["vertical-align"] = function(value)
        local map = {
            ["top"] = Enum.TextYAlignment.Top,
            ["bottom"] = Enum.TextYAlignment.Bottom,
            ["middle"] = Enum.TextYAlignment.Center,
            ["baseline"] = Enum.TextYAlignment.Center
        }
        if map[value] then
            return {TextYAlignment = map[value]}
        end
        return {}
    end,
    
    ["text-decoration"] = function(value)
        if value:match("underline") then
            return {UIStroke = {Color = Color3.fromRGB(0, 0, 0), Thickness = 1}}
        elseif value:match("line-through") then
            return {Text = "-" .. (element.text or "") .. "-"} -- Approximate
        end
        return {}
    end,
    
    ["border"] = function(value)
        local width, style, color = value:match("(%d+)%a*%s+(%a+)%s+(%a+)")
        width = tonumber(width) or 1
        color = color or "black"
        
        return {
            UIStroke = {
                Color = CSSParser.parseColor(color),
                Thickness = width
            }
        }
    end,
    
    ["border-radius"] = function(value)
        local num = tonumber(value:match("%d+")) or 0
        return {UICorner = {CornerRadius = UDim.new(0, num)}}
    end,
    
    ["opacity"] = function(value)
        local num = tonumber(value) or 1
        return {BackgroundTransparency = 1 - num}
    end,
    
    ["visibility"] = function(value)
        if value == "hidden" then
            return {Visible = false}
        end
        return {}
    end,
    
    ["box-shadow"] = function(value)
        -- Simplified box shadow
        local x, y, blur, color = value:match("(%d+)%a*%s+(%d+)%a*%s+(%d+)%a*%s+(%a+)")
        if x and y then
            return {
                UIStroke = {
                    Color = CSSParser.parseColor(color or "black"),
                    Thickness = 1,
                    Transparency = 0.5
                }
            }
        end
        return {}
    end,
    
    -- Transforms and animations
    ["transform"] = function(value)
        if value:match("translate") then
            local x, y = value:match("translate%(([%d%-]+)%a*[, ]+([%d%-]+)%a*%)")
            x = tonumber(x) or 0
            y = tonumber(y) or 0
            return {Position = UDim2.new(0, x, 0, y)}
        elseif value:match("rotate") then
            local deg = value:match("rotate%(([%d%-]+)deg%)")
            if deg then
                return {Rotation = tonumber(deg)}
            end
        elseif value:match("scale") then
            local x, y = value:match("scale%(([%d%.]+)[, ]*([%d%.]*)%)")
            x = tonumber(x) or 1
            y = tonumber(y) or x
            return {Size = UDim2.new(0, x * 100, 0, y * 100)}
        end
        return {}
    end,
    
    ["transition"] = function(value)
        -- Will be handled by JavaScript parser
        return {}
    end,
    
    -- Advanced selectors (pseudo-classes)
    [":hover"] = function(value)
        -- Will be handled by JavaScript parser
        return {}
    end,
    
    [":active"] = function(value)
        -- Will be handled by JavaScript parser
        return {}
    end
}

function CSSParser.parse(css)
    local stylesheet = {}
    
    -- Remove comments
    css = css:gsub("/%*.-%*/", "")
    
    -- Parse @rules
    local atRules = {}
    for atRule in css:gmatch("(@[^{]-){([^}]*)}") do
        local name, content = atRule:match("(@%a+)([^{]*){(.*)}")
        if name and content then
            atRules[name] = atRules[name] or {}
            table.insert(atRules[name], content)
        end
    end
    
    -- Parse regular rules
    for rule in css:gmatch("([^{]-){([^}]*)}") do
        local selectors, declarations = rule:match("([^{]*)%s*{(.*)}")
        if selectors and declarations then
            selectors = selectors:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
            
            -- Parse individual selectors
            for selector in selectors:gmatch("[^,]+") do
                selector = selector:gsub("^%s*(.-)%s*$", "%1")
                
                -- Parse declarations
                local style = {}
                for decl in declarations:gmatch("([^:]-):%s*([^;]-);") do
                    local prop, value = decl:match("([^:]-):%s*([^;]-);")
                    if prop and value then
                        prop = prop:gsub("^%s*(.-)%s*$", "%1")
                        value = value:gsub("^%s*(.-)%s*$", "%1")
                        style[prop] = value
                    end
                end
                
                -- Add to stylesheet
                if not stylesheet[selector] then
                    stylesheet[selector] = {}
                end
                
                for prop, value in pairs(style) do
                    stylesheet[selector][prop] = value
                end
            end
        end
    end
    
    -- Process @media rules
    if atRules["@media"] then
        for _, mediaRule in ipairs(atRules["@media"]) do
            local conditions, content = mediaRule:match("([^{]*)%s*{(.*)}")
            if conditions then
                -- Simplified media query handling
                if conditions:match("max%-width") then
                    local maxWidth = conditions:match("max%-width%:%s*(%d+)px")
                    maxWidth = tonumber(maxWidth)
                    
                    if maxWidth then
                        -- Add responsive styles
                        stylesheet["@media (max-width:"..maxWidth.."px)"] = CSSParser.parse(content)
                    end
                end
            end
        end
    end
    
    return stylesheet
end

function CSSParser.parseInlineStyles(styleStr)
    local styles = {}
    for prop, value in styleStr:gmatch("([%a-]+)%s*:%s*([^;]+)") do
        styles[prop] = value
    end
    return styles
end

function CSSParser.parseBoxValue(value)
    local parts = {}
    for part in value:gmatch("[^%s]+") do
        table.insert(parts, tonumber(part) or 0)
    end
    
    if #parts == 1 then
        return parts[1], parts[1], parts[1], parts[1]
    elseif #parts == 2 then
        return parts[1], parts[2], parts[1], parts[2]
    elseif #parts == 3 then
        return parts[1], parts[2], parts[3], parts[2]
    elseif #parts == 4 then
        return parts[1], parts[2], parts[3], parts[4]
    end
    
    return 0, 0, 0, 0
end

function CSSParser.parseColor(colorStr)
    if colorStr:match("^rgb%(") then
        local r, g, b = colorStr:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    elseif colorStr:match("^rgba%(") then
        local r, g, b = colorStr:match("rgba%((%d+),%s*(%d+),%s*(%d+)")
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    elseif colorStr:match("^hsl%(") then
        local h, s, l = colorStr:match("hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)")
        return Color3.fromHSV(tonumber(h)/360, tonumber(s)/100, tonumber(l)/100)
    elseif colorStr:match("^#") then
        local hex = colorStr:sub(2)
        if #hex == 3 then
            return Color3.fromRGB(
                tonumber(hex:sub(1,1)..hex:sub(1,1), 16),
                tonumber(hex:sub(2,2)..hex:sub(2,2), 16),
                tonumber(hex:sub(3,3)..hex:sub(3,3), 16))
        elseif #hex == 6 then
            return Color3.fromRGB(
                tonumber(hex:sub(1,2), 16),
                tonumber(hex:sub(3,4), 16),
                tonumber(hex:sub(5,6), 16))
        elseif #hex == 8 then
            -- RGBA hex (ignore alpha)
            return Color3.fromRGB(
                tonumber(hex:sub(1,2), 16),
                tonumber(hex:sub(3,4), 16),
                tonumber(hex:sub(5,6), 16))
        end
    elseif colorStr == "transparent" then
        return Color3.new(1, 1, 1) -- White with transparency
    else
        -- Named colors
        local colorNames = {
            aliceblue = Color3.fromRGB(240, 248, 255),
            antiquewhite = Color3.fromRGB(250, 235, 215),
            aqua = Color3.fromRGB(0, 255, 255),
            aquamarine = Color3.fromRGB(127, 255, 212),
            azure = Color3.fromRGB(240, 255, 255),
            beige = Color3.fromRGB(245, 245, 220),
            bisque = Color3.fromRGB(255, 228, 196),
            black = Color3.fromRGB(0, 0, 0),
            blanchedalmond = Color3.fromRGB(255, 235, 205),
            blue = Color3.fromRGB(0, 0, 255),
            blueviolet = Color3.fromRGB(138, 43, 226),
            brown = Color3.fromRGB(165, 42, 42),
            burlywood = Color3.fromRGB(222, 184, 135),
            cadetblue = Color3.fromRGB(95, 158, 160),
            chartreuse = Color3.fromRGB(127, 255, 0),
            chocolate = Color3.fromRGB(210, 105, 30),
            coral = Color3.fromRGB(255, 127, 80),
            cornflowerblue = Color3.fromRGB(100, 149, 237),
            cornsilk = Color3.fromRGB(255, 248, 220),
            crimson = Color3.fromRGB(220, 20, 60),
            cyan = Color3.fromRGB(0, 255, 255),
            darkblue = Color3.fromRGB(0, 0, 139),
            darkcyan = Color3.fromRGB(0, 139, 139),
            darkgoldenrod = Color3.fromRGB(184, 134, 11),
            darkgray = Color3.fromRGB(169, 169, 169),
            darkgreen = Color3.fromRGB(0, 100, 0),
            darkgrey = Color3.fromRGB(169, 169, 169),
            darkkhaki = Color3.fromRGB(189, 183, 107),
            darkmagenta = Color3.fromRGB(139, 0, 139),
            darkolivegreen = Color3.fromRGB(85, 107, 47),
            darkorange = Color3.fromRGB(255, 140, 0),
            darkorchid = Color3.fromRGB(153, 50, 204),
            darkred = Color3.fromRGB(139, 0, 0),
            darksalmon = Color3.fromRGB(233, 150, 122),
            darkseagreen = Color3.fromRGB(143, 188, 143),
            darkslateblue = Color3.fromRGB(72, 61, 139),
            darkslategray = Color3.fromRGB(47, 79, 79),
            darkslategrey = Color3.fromRGB(47, 79, 79),
            darkturquoise = Color3.fromRGB(0, 206, 209),
            darkviolet = Color3.fromRGB(148, 0, 211),
            deeppink = Color3.fromRGB(255, 20, 147),
            deepskyblue = Color3.fromRGB(0, 191, 255),
            dimgray = Color3.fromRGB(105, 105, 105),
            dimgrey = Color3.fromRGB(105, 105, 105),
            dodgerblue = Color3.fromRGB(30, 144, 255),
            firebrick = Color3.fromRGB(178, 34, 34),
            floralwhite = Color3.fromRGB(255, 250, 240),
            forestgreen = Color3.fromRGB(34, 139, 34),
            fuchsia = Color3.fromRGB(255, 0, 255),
            gainsboro = Color3.fromRGB(220, 220, 220),
            ghostwhite = Color3.fromRGB(248, 248, 255),
            gold = Color3.fromRGB(255, 215, 0),
            goldenrod = Color3.fromRGB(218, 165, 32),
            gray = Color3.fromRGB(128, 128, 128),
            green = Color3.fromRGB(0, 128, 0),
            greenyellow = Color3.fromRGB(173, 255, 47),
            grey = Color3.fromRGB(128, 128, 128),
            honeydew = Color3.fromRGB(240, 255, 240),
            hotpink = Color3.fromRGB(255, 105, 180),
            indianred = Color3.fromRGB(205, 92, 92),
            indigo = Color3.fromRGB(75, 0, 130),
            ivory = Color3.fromRGB(255, 255, 240),
            khaki = Color3.fromRGB(240, 230, 140),
            lavender = Color3.fromRGB(230, 230, 250),
            lavenderblush = Color3.fromRGB(255, 240, 245),
            lawngreen = Color3.fromRGB(124, 252, 0),
            lemonchiffon = Color3.fromRGB(255, 250, 205),
            lightblue = Color3.fromRGB(173, 216, 230),
            lightcoral = Color3.fromRGB(240, 128, 128),
            lightcyan = Color3.fromRGB(224, 255, 255),
            lightgoldenrodyellow = Color3.fromRGB(250, 250, 210),
            lightgray = Color3.fromRGB(211, 211, 211),
            lightgreen = Color3.fromRGB(144, 238, 144),
            lightgrey = Color3.fromRGB(211, 211, 211),
            light