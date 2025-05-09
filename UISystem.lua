-- UISystem.lua
local UISystem = {}

function UISystem.analyzeLayouts(document)
    local function analyzeNode(node)
        -- Analyze flexbox/grid layouts
        if node.computedStyle and node.computedStyle.display then
            if node.computedStyle.display == "flex" then
                node.layoutType = "flex"
                node.layoutProperties = {
                    direction = node.computedStyle["flex-direction"] or "row",
                    wrap = node.computedStyle["flex-wrap"] or "nowrap",
                    justifyContent = node.computedStyle["justify-content"] or "flex-start",
                    alignItems = node.computedStyle["align-items"] or "stretch"
                }
            elseif node.computedStyle.display == "grid" then
                node.layoutType = "grid"
                node.layoutProperties = {
                    templateColumns = node.computedStyle["grid-template-columns"] or "auto",
                    templateRows = node.computedStyle["grid-template-rows"] or "auto",
                    gap = node.computedStyle["gap"] or "0"
                }
            end
        end
        
        -- Process children
        for _, child in ipairs(node.children) do
            analyzeNode(child)
        end
    end
    
    analyzeNode(document)
end

function UISystem.generateLayoutCode(node, parentVar, indent)
    indent = indent or ""
    local luaCode = ""
    
    if node.layoutType == "flex" then
        luaCode = luaCode .. indent .. "-- Flexbox layout\n"
        luaCode = luaCode .. indent .. "local listLayout = Instance.new(\"UIListLayout\")\n"
        
        -- Set flex direction
        if node.layoutProperties.direction == "column" then
            luaCode = luaCode .. indent .. "listLayout.FillDirection = Enum.FillDirection.Vertical\n"
        else
            luaCode = luaCode .. indent .. "listLayout.FillDirection = Enum.FillDirection.Horizontal\n"
        end
        
        -- Set justify content
        local justifyMap = {
            ["flex-start"] = "Left",
            ["flex-end"] = "Right",
            ["center"] = "Center",
            ["space-between"] = "Center", -- Approximate
            ["space-around"] = "Center" -- Approximate
        }
        if justifyMap[node.layoutProperties.justifyContent] then
            luaCode = luaCode .. indent .. "listLayout.HorizontalAlignment = Enum.HorizontalAlignment." .. justifyMap[node.layoutProperties.justifyContent] .. "\n"
        end
        
        -- Set align items
        local alignMap = {
            ["flex-start"] = "Top",
            ["flex-end"] = "Bottom",
            ["center"] = "Center",
            ["stretch"] = "Center" -- Approximate
        }
        if alignMap[node.layoutProperties.alignItems] then
            luaCode = luaCode .. indent .. "listLayout.VerticalAlignment = Enum.VerticalAlignment." .. alignMap[node.layoutProperties.alignItems] .. "\n"
        end
        
        -- Set padding if specified
        if node.computedStyle and node.computedStyle.gap then
            local gap = tonumber(node.computedStyle.gap:match("%d+")) or 0
            luaCode = luaCode .. indent .. "listLayout.Padding = UDim.new(0, " .. gap .. ")\n"
        end
        
        luaCode = luaCode .. indent .. "listLayout.Parent = " .. parentVar .. "\n\n"
        
    elseif node.layoutType == "grid" then
        luaCode = luaCode .. indent .. "-- Grid layout\n"
        luaCode = luaCode .. indent .. "local gridLayout = Instance.new(\"UIGridLayout\")\n"
        
        -- Parse template columns
        local columns = {}
        for col in node.layoutProperties.templateColumns:gmatch("[^%s]+") do
            table.insert(columns, col)
        end
        
        -- Parse template rows
        local rows = {}
        for row in node.layoutProperties.templateRows:gmatch("[^%s]+") do
            table.insert(rows, row)
        end
        
        -- Set cell size based on template
        if #columns > 0 and columns[1] ~= "auto" then
            local size = tonumber(columns[1]:match("%d+")) or 100
            luaCode = luaCode .. indent .. "gridLayout.CellSize = UDim2.new(0, " .. size .. ", 0, " .. size .. ")\n"
        end
        
        -- Set gap
        local gap = tonumber(node.layoutProperties.gap:match("%d+")) or 0
        luaCode = luaCode .. indent .. "gridLayout.CellPadding = UDim2.new(0, " .. gap .. ", 0, " .. gap .. ")\n"
        
        -- Set start corner
        luaCode = luaCode .. indent .. "gridLayout.StartCorner = Enum.StartCorner.TopLeft\n"
        
        luaCode = luaCode .. indent .. "gridLayout.Parent = " .. parentVar .. "\n\n"
    end
    
    return luaCode
end

return UISystem