local Keyboard = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local KEY_SIZE = UDim2.new(0, 50, 0, 50)
local SPECIAL_KEYS = {
    Shift = UDim2.new(0, 80, 0, 50),
    Back = UDim2.new(0, 80, 0, 50),
    Space = UDim2.new(0, 200, 0, 50),
    Return = UDim2.new(0, 100, 0, 50),
    ModeSwitch = UDim2.new(0, 70, 0, 50)
}

local COLORS = {
    Background = Color3.fromRGB(15, 15, 15),
    KeyNormal = Color3.fromRGB(20, 20, 20),
    KeyPressed = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(0, 200, 255)
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local currentTextbox = nil
local isShift = false
local isSymbols = false

local layouts = {
    QWERTY = {
        rows = {
            {"Q","W","E","R","T","Y","U","I","O","P"},
            {"A","S","D","F","G","H","J","K","L"},
            {"Shift","Z","X","C","V","B","N","M","Back"},
            {"123","Emoji","Mic","Space","Return"}
        },
        symbols = false
    },
    SYMBOLS = {
        rows = {
            {"1","2","3","4","5","6","7","8","9","0"},
            {"!","@","#","$","%","^","&","*","(",")"},
            {"Shift","-","_","+","=","/","?","<",">"},
            {"ABC","Emoji","Mic","Space","Return"}
        },
        symbols = true
    }
}


local gui = nil
local keyInstances = {}

local function createKeyButton(text, parent, size)
    local button = Instance.new("TextButton")
    button.Size = size or KEY_SIZE
    button.BackgroundColor3 = COLORS.KeyNormal
    button.TextColor3 = COLORS.Text
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20
    button.TextWrapped = true
    button.Parent = parent

    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = COLORS.KeyPressed
    end)

    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = COLORS.KeyNormal
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.KeyNormal
    end)

    return button
end

local function updateKeyboardLayout()
    local currentLayout = isSymbols and layouts.SYMBOLS or layouts.QWERTY
    local rows = currentLayout.rows

    for rowIndex, row in ipairs(rows) do
        local rowInstances = keyInstances[rowIndex]
        for keyIndex, key in ipairs(row) do
            local button = rowInstances[keyIndex]
            if button then
                button.Text = key
                button.Visible = true

                if not currentLayout.symbols and key:match("%a") then
                    button.Text = isShift and key:upper() or key:lower()
                end
            end
        end
        
        for i = #row + 1, #rowInstances do
            rowInstances[i].Visible = false
        end
    end
end

local function initializeKeyboardGUI()
    if gui then return gui end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DragnirKeyboard"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(1, 0, 0, 250)
    mainFrame.Position = UDim2.new(0, 0, 1, -250)
    mainFrame.BackgroundColor3 = COLORS.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local layoutFrame = Instance.new("Frame")
    layoutFrame.Name = "Layout"
    layoutFrame.Size = UDim2.new(1, 0, 1, 0)
    layoutFrame.BackgroundTransparency = 1
    layoutFrame.Parent = mainFrame

    for rowIndex = 1, 4 do
        local rowFrame = Instance.new("Frame")
        rowFrame.Size = UDim2.new(1, 0, 0, 55)
        rowFrame.Position = UDim2.new(0, 0, 0, (rowIndex - 1) * 55)
        rowFrame.BackgroundTransparency = 1
        rowFrame.Parent = layoutFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = rowFrame

        keyInstances[rowIndex] = {}
        for _ = 1, 10 do
            local button = createKeyButton("", rowFrame)
            button.Visible = false
            table.insert(keyInstances[rowIndex], button)
        end
    end

    gui = screenGui
    return screenGui
end

local function handleKeyPress(key)
    if not currentTextbox then return end

    if key == "Shift" then
        isShift = not isShift
        updateKeyboardLayout()
    elseif key == "123" or key == "ABC" then
        isSymbols = not isSymbols
        isShift = false
        updateKeyboardLayout()
    elseif key == "Back" then
        if #currentTextbox.Text > 0 then
            currentTextbox.Text = currentTextbox.Text:sub(1, -2)
        end
    elseif key == "Space" then
        currentTextbox.Text ..= " "
    elseif key == "Return" then
        currentTextbox:ReleaseFocus()
        Keyboard:Hide()
    elseif key:match("%a") then
        local char = isShift and key:upper() or key:lower()
        currentTextbox.Text ..= char
        if isShift then
            isShift = false
            updateKeyboardLayout()
        end
    else
        currentTextbox.Text ..= key
    end
end

function Keyboard:Show(textbox)
    if not gui then
        initializeKeyboardGUI().Parent = playerGui
    else
        gui.Enabled = true
    end

    currentTextbox = textbox
    updateKeyboardLayout()
end

function Keyboard:Hide()
    if gui then
        gui.Enabled = false
    end
    currentTextbox = nil
    isShift = false
    isSymbols = false
end

initializeKeyboardGUI()

return Keyboard