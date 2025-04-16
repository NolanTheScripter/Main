local ClassCache = {}

local function getClass(name: string)
    assert(typeof(name) == "string", "[getClass] Class name must be a string")
    
    if ClassCache[name] then
        return ClassCache[name]
    end

    -- Attempt to get the class using the game's standard class system.
    local success, class = pcall(function()
        return game:FindFirstChildOfClass(name)
    end)
    
    if success and class then
        ClassCache[name] = class
        return class
    else
        warn("[getClass] Class not found:", name)
        return nil
    end
end

local Classes = {
    -- General Roblox Classes
    DataStoreService = getClass("DataStoreService"),
    MarketplaceService = getClass("MarketplaceService"),
    TeleportService = getClass("TeleportService"),
    ReplicatedStorage = getClass("ReplicatedStorage"),
    Workspace = getClass("Workspace"),
    Players = getClass("Players"),
    Lighting = getClass("Lighting"),
    SoundService = getClass("SoundService"),
    HttpService = getClass("HttpService"),
    UserInputService = getClass("UserInputService"),
    GuiService = getClass("GuiService"),
    CoreGui = getClass("CoreGui"),
    StarterGui = getClass("StarterGui"),
    StarterPlayer = getClass("StarterPlayer"),
    StarterPack = getClass("StarterPack"),
    StarterCharacterScripts = getClass("StarterCharacterScripts"),
    Chat = getClass("Chat"),
    TextService = getClass("TextService"),
    NetworkService = getClass("NetworkService"),
    CollectionService = getClass("CollectionService"),
    BadgeService = getClass("BadgeService"),
    AvatarEditorService = getClass("AvatarEditorService"),
    LocalizationService = getClass("LocalizationService"),
    MessagingService = getClass("MessagingService"),
    SocialService = getClass("SocialService"),
    FeedbackService = getClass("FeedbackService"),
    SurfaceGui = getClass("SurfaceGui"),
    GroupService = getClass("GroupService"),
    LeaderboardService = getClass("LeaderboardService"),
    NetworkClient = getClass("NetworkClient"),
    NetworkReplicator = getClass("NetworkReplicator"),
    RenderingService = getClass("RenderingService"),
    LocalizationTableService = getClass("LocalizationTableService"),
    Terrain = getClass("Terrain"),
    TerrainRegionService = getClass("TerrainRegionService"),

    -- Instance-based classes
    BasePart = getClass("BasePart"),
    Part = getClass("Part"),
    Model = getClass("Model"),
    MeshPart = getClass("MeshPart"),
    Terrain = getClass("Terrain"),
    Decal = getClass("Decal"),
    Texture = getClass("Texture"),
    Weld = getClass("Weld"),
    WeldConstraint = getClass("WeldConstraint"),
    Motor6D = getClass("Motor6D"),
    Attachment = getClass("Attachment"),
    BodyPosition = getClass("BodyPosition"),
    BodyVelocity = getClass("BodyVelocity"),
    BodyGyro = getClass("BodyGyro"),
    BallSocketConstraint = getClass("BallSocketConstraint"),
    HingeConstraint = getClass("HingeConstraint"),
    RodConstraint = getClass("RodConstraint"),
    SliderConstraint = getClass("SliderConstraint"),
    DistanceConstraint = getClass("DistanceConstraint"),
    SurfaceConstraint = getClass("SurfaceConstraint"),
    LinearVelocity = getClass("LinearVelocity"),
    AngularVelocity = getClass("AngularVelocity"),
    PointLight = getClass("PointLight"),
    SpotLight = getClass("SpotLight"),
    SurfaceLight = getClass("SurfaceLight"),
    Fire = getClass("Fire"),
    Sparkles = getClass("Sparkles"),
    Smoke = getClass("Smoke"),
    Explosion = getClass("Explosion"),
    Fireball = getClass("Fireball"),
    RopeConstraint = getClass("RopeConstraint"),
    Beam = getClass("Beam"),
    Trail = getClass("Trail"),

    -- GUI Classes
    ScreenGui = getClass("ScreenGui"),
    Frame = getClass("Frame"),
    TextLabel = getClass("TextLabel"),
    TextButton = getClass("TextButton"),
    ImageLabel = getClass("ImageLabel"),
    ImageButton = getClass("ImageButton"),
    TextBox = getClass("TextBox"),
    ScrollBar = getClass("ScrollBar"),
    ScrollFrame = getClass("ScrollingFrame"),
    TextBox = getClass("TextBox"),
    ViewportFrame = getClass("ViewportFrame"),
    UIGridLayout = getClass("UIGridLayout"),
    UIListLayout = getClass("UIListLayout"),
    UIPadding = getClass("UIPadding"),
    UIAspectRatioConstraint = getClass("UIAspectRatioConstraint"),
    UICorner = getClass("UICorner"),
    UIStroke = getClass("UIStroke"),
    UITextSizeConstraint = getClass("UITextSizeConstraint"),
    UITextLabel = getClass("UITextLabel"),

    -- Miscellaneous Roblox Classes
    Script = getClass("Script"),
    LocalScript = getClass("LocalScript"),
    ModuleScript = getClass("ModuleScript"),
    RemoteEvent = getClass("RemoteEvent"),
    RemoteFunction = getClass("RemoteFunction"),
    BoolValue = getClass("BoolValue"),
    IntValue = getClass("IntValue"),
    StringValue = getClass("StringValue"),
    ObjectValue = getClass("ObjectValue"),
    CFrameValue = getClass("CFrameValue"),
    Color3Value = getClass("Color3Value"),
    ColorSequenceValue = getClass("ColorSequenceValue"),
    Vector3Value = getClass("Vector3Value"),
    Vector2Value = getClass("Vector2Value"),

    -- Network Classes
    NetworkClient = getClass("NetworkClient"),
    NetworkReplicator = getClass("NetworkReplicator"),

    -- Customization and Avatar Classes
    AvatarEditorService = getClass("AvatarEditorService"),
    AvatarEditor = getClass("AvatarEditor"),
    Clothing = getClass("Clothing"),
    Shirt = getClass("Shirt"),
    Pants = getClass("Pants"),
    Hat = getClass("Hat"),
    Face = getClass("Face"),

    -- Other Roblox Classes
    Sound = getClass("Sound"),
    ParticleEmitter = getClass("ParticleEmitter"),
    ImageHandleAdornment = getClass("ImageHandleAdornment"),
    TextLabel = getClass("TextLabel"),
    BillboardGui = getClass("BillboardGui"),
    SurfaceGui = getClass("SurfaceGui"),
    -- Additional as needed
}

Classes.getClass = getClass

return Classes