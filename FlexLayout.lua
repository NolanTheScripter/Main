-- Core/FlexLayout.lua
local FlexLayout = {}

FlexLayout.FlexDirection = {
    ROW = {HorizontalFlex = Enum.UIFlexAlignment.Fill, VerticalFlex = nil},
    COLUMN = {VerticalFlex = Enum.UIFlexAlignment.Fill, HorizontalFlex = nil},
    WRAP = {Wraps = true, HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween}
}

function FlexLayout.createContainer(parent, direction, padding, spacing)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, 0)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = direction.fillDirection or Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, spacing or 8)
    
    -- Configuration Flex
    if direction.HorizontalFlex then
        listLayout.HorizontalFlex = direction.HorizontalFlex
        listLayout.VerticalFlex = Enum.UIFlexAlignment.Start
    end
    
    if direction.VerticalFlex then
        listLayout.VerticalFlex = direction.VerticalFlex
        listLayout.HorizontalFlex = Enum.UIFlexAlignment.Start
    end
    
    if direction.Wraps then
        listLayout.Wraps = true
        listLayout.FillDirection = Enum.FillDirection.Horizontal
    end
    
    -- Padding adaptatif
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, padding or 12)
    uiPadding.PaddingRight = UDim.new(0, padding or 12)
    uiPadding.PaddingTop = UDim.new(0, padding or 12)
    uiPadding.PaddingBottom = UDim.new(0, padding or 12)
    
    listLayout.Parent = container
    uiPadding.Parent = container
    container.Parent = parent
    
    return container
end

-- Responsive breakpoints
FlexLayout.Breakpoints = {
    MOBILE = 600,
    TABLET = 900,
    DESKTOP = 1200
}

function FlexLayout.adjustForViewport(container)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local width = viewportSize.X
    
    local listLayout = container:FindFirstChildOfClass("UIListLayout")
    if not listLayout then return end
    
    if width < FlexLayout.Breakpoints.MOBILE then
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.Wraps = false
    elseif width < FlexLayout.Breakpoints.TABLET then
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.Wraps = true
    else
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.Wraps = false
    end
end

return FlexLayout