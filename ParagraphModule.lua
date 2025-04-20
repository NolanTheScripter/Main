local ParagraphModule = {}
ParagraphModule.__index = ParagraphModule

-- Default settings
local DEFAULT_SETTINGS = {
    Font = Enum.Font.SourceSans,
    BoldFont = Enum.Font.SourceSansBold,
    TextColor = Color3.fromRGB(255, 255, 255),
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    BackgroundTransparency = 0.5,
    TextSize = 14,
    TextWrapped = true,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    RichText = true,
    AutoScalePadding = 10, -- pixels
    MinTextSize = 8,
    MaxTextSize = 50,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Parent = nil
}

function ParagraphModule.new(settings)
    local self = setmetatable({}, ParagraphModule)
    
    -- Merge custom settings with defaults
    self.settings = table.clone(DEFAULT_SETTINGS)
    for k, v in pairs(settings or {}) do
        self.settings[k] = v
    end
    
    -- Create the container frame
    self.frame = Instance.new("Frame")
    self.frame.BackgroundColor3 = self.settings.BackgroundColor
    self.frame.BackgroundTransparency = self.settings.BackgroundTransparency
    self.frame.Size = self.settings.Size
    self.frame.Position = self.settings.Position
    self.frame.ClipsDescendants = true
    
    -- Add aspect ratio constraint
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.Parent = self.frame
    
    -- Create the text label
    self.textLabel = Instance.new("TextLabel")
    self.textLabel.Font = self.settings.Font
    self.textLabel.TextColor3 = self.settings.TextColor
    self.textLabel.TextSize = self.settings.TextSize
    self.textLabel.TextWrapped = self.settings.TextWrapped
    self.textLabel.TextScaled = self.settings.TextScaled
    self.textLabel.TextXAlignment = self.settings.TextXAlignment
    self.textLabel.TextYAlignment = self.settings.TextYAlignment
    self.textLabel.RichText = self.settings.RichText
    self.textLabel.BackgroundTransparency = 1
    self.textLabel.Size = UDim2.new(1, -self.settings.AutoScalePadding * 2, 1, -self.settings.AutoScalePadding * 2)
    self.textLabel.Position = UDim2.new(0, self.settings.AutoScalePadding, 0, self.settings.AutoScalePadding)
    self.textLabel.Parent = self.frame
    
    -- Auto-scale text functionality
    self.textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        self:adjustTextSize()
    end)
    
    -- Set parent if provided
    if self.settings.Parent then
        self:setParent(self.settings.Parent)
    end
    
    return self
end

function ParagraphModule:adjustTextSize()
    local padding = self.settings.AutoScalePadding
    local availableWidth = self.frame.AbsoluteSize.X - (padding * 2)
    local availableHeight = self.frame.AbsoluteSize.Y - (padding * 2)
    
    -- Calculate required text size based on bounds
    local textBounds = self.textLabel.TextBounds
    local widthRatio = availableWidth / textBounds.X
    local heightRatio = availableHeight / textBounds.Y
    local scaleRatio = math.min(widthRatio, heightRatio)
    
    -- Apply constrained text size
    local newSize = math.clamp(
        self.settings.TextSize * scaleRatio,
        self.settings.MinTextSize,
        self.settings.MaxTextSize
    )
    
    self.textLabel.TextSize = newSize
end

function ParagraphModule:setText(text)
    self.textLabel.Text = text
    self:adjustTextSize()
end

function ParagraphModule:setParent(parent)
    self.frame.Parent = parent
    self:adjustTextSize() -- Recalculate when parent changes
end

function ParagraphModule:setVisible(visible)
    self.frame.Visible = visible
end

function ParagraphModule:destroy()
    self.frame:Destroy()
    setmetatable(self, nil)
end

-- Rich text formatting helpers
function ParagraphModule:formatBold(text)
    return string.format("<b>%s</b>", text)
end

function ParagraphModule:formatItalic(text)
    return string.format("<i>%s</i>", text)
end

function ParagraphModule:formatColor(text, color)
    local hex = Color3.fromHex(color or "#FFFFFF")
    return string.format('<font color="#%s">%s</font>', hex:ToHex(), text)
end

function ParagraphModule:formatHeader(text, level)
    level = math.clamp(level or 1, 1, 6)
    return string.format("<h%d>%s</h%d>", level, text, level)
end

return ParagraphModule