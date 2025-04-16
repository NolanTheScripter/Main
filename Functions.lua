local functionCache = {}

local function getFunction(name: string)
    assert(typeof(name) == "string", "[getFunction] Function name must be a string")

    if functionCache[name] then
        return functionCache[name]
    end

    local success, func = pcall(function()
        return require(name)  -- Assuming you are requiring a module for each function.
    end)
    
    if success and func then
        functionCache[name] = func
        return func
    else
        warn("[getFunction] Function not found:", name)
        return nil
    end
end

local Functions = {
    -- Task Functions
    Wait = getFunction("task.wait"),
    Spawn = getFunction("task.spawn"),
    Delay = getFunction("delay"),

    -- General Lua Functions
    Print = getFunction("print"),
    Error = getFunction("error"),
    Type = getFunction("type"),
    PCall = getFunction("pcall"),
    XPCall = getFunction("xpcall"),
    Assert = getFunction("assert"),
    GetMetatable = getFunction("getmetatable"),
    SetMetatable = getFunction("setmetatable"),
    Pairs = getFunction("pairs"),
    IPairs = getFunction("ipairs"),
    Next = getFunction("next"),
    Tonumber = getFunction("tonumber"),
    Tostring = getFunction("tostring"),
    Loadstring = getFunction("loadstring"),
    Load = getFunction("load"),

    -- Math Functions
    Abs = getFunction("math.abs"),
    Acos = getFunction("math.acos"),
    Asin = getFunction("math.asin"),
    Atan = getFunction("math.atan"),
    Ceil = getFunction("math.ceil"),
    Cos = getFunction("math.cos"),
    Deg = getFunction("math.deg"),
    Exp = getFunction("math.exp"),
    Floor = getFunction("math.floor"),
    Fmod = getFunction("math.fmod"),
    Huge = getFunction("math.huge"),
    Log = getFunction("math.log"),
    Max = getFunction("math.max"),
    Min = getFunction("math.min"),
    Pi = getFunction("math.pi"),
    Pow = getFunction("math.pow"),
    Rad = getFunction("math.rad"),
    Random = getFunction("math.random"),
    Randomseed = getFunction("math.randomseed"),
    Sin = getFunction("math.sin"),
    Sqrt = getFunction("math.sqrt"),
    Tan = getFunction("math.tan"),

    -- String Functions
    Char = getFunction("string.char"),
    Find = getFunction("string.find"),
    Format = getFunction("string.format"),
    Gsub = getFunction("string.gsub"),
    Len = getFunction("string.len"),
    Lower = getFunction("string.lower"),
    Match = getFunction("string.match"),
    Rep = getFunction("string.rep"),
    Reverse = getFunction("string.reverse"),
    Sub = getFunction("string.sub"),
    Upper = getFunction("string.upper"),

    -- Table Functions
    Insert = getFunction("table.insert"),
    Remove = getFunction("table.remove"),
    Sort = getFunction("table.sort"),
    Maxn = getFunction("table.maxn"),
    Move = getFunction("table.move"),
    Clear = getFunction("table.clear"),

    -- Debugging Functions
    PrintError = getFunction("debug.print"),
    GetInfo = getFunction("debug.getinfo"),
    GetLocal = getFunction("debug.getlocal"),
    SetLocal = getFunction("debug.setlocal"),
    Traceback = getFunction("debug.traceback"),

    -- Roblox Specific Functions
    Connect = getFunction("RBXScriptSignal.Connect"),
    Disconnect = getFunction("RBXScriptSignal.Disconnect"),
    WaitForChild = getFunction("Instance.WaitForChild"),
    FindFirstChild = getFunction("Instance.FindFirstChild"),
    FindFirstChildWhichIsA = getFunction("Instance.FindFirstChildWhichIsA"),
    IsA = getFunction("Instance.IsA"),
    Clone = getFunction("Instance.Clone"),
    Destroy = getFunction("Instance.Destroy"),

    -- Other Roblox Functions
    GetService = getFunction("game.GetService"),
    FindService = getFunction("game.FindService"),

    -- UserInputService Functions
    IsKeyDown = getFunction("UserInputService.IsKeyDown"),
    GetKeysPressed = getFunction("UserInputService.GetKeysPressed"),

    -- Task Scheduler Functions
    GetHeartbeat = getFunction("RunService.Heartbeat"),
    GetRenderStepped = getFunction("RunService.RenderStepped"),
    GetStepped = getFunction("RunService.Stepped"),

    -- Math Utility Functions
    IsNaN = getFunction("math.isnan"),
    Sign = getFunction("math.sign"),
    Clamp = getFunction("math.clamp"),

    -- Misc Functions
    LoadModule = getFunction("require"),
    CloneTable = getFunction("table.clone"),
}

Functions.getFunction = getFunction

return Functions