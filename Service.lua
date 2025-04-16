local serviceCache = {}

local function getService(name: string)
    assert(typeof(name) == "string", "[getService] Service name must be a string")

    if serviceCache[name] then
        return serviceCache[name]
    end

    local success, service = pcall(game.GetService, game, name)
    if success and service then
        serviceCache[name] = service
        return service
    else
        warn("[getService] Service not found:", name)
        return nil
    end
end

local Services = {
    Tween = getService("TweenService"),
    Run = getService("RunService"),
    Debris = getService("Debris"),
    UserInput = getService("UserInputService"),
    Http = getService("HttpService"),
    Players = getService("Players"),
    Replicated = getService("ReplicatedStorage"),
    ReplicatedFirst = getService("ReplicatedFirst"),
    Workspace = getService("Workspace"),
    Lighting = getService("Lighting"),
    Sound = getService("SoundService"),
    CoreGui = getService("CoreGui"),
    PlayerScripts = getService("PlayerScripts"),
    StarterGui = getService("StarterGui"),
    StarterPack = getService("StarterPack"),
    StarterPlayer = getService("StarterPlayer"),
    StarterCharacterScripts = getService("StarterCharacterScripts"),
    Chat = getService("Chat"),
    Text = getService("TextService"),
    Collection = getService("CollectionService"),
    DataStore = getService("DataStoreService"),
    Messaging = getService("MessagingService"),
    AvatarEditor = getService("AvatarEditorService"),
    Localization = getService("LocalizationService"),
    Badge = getService("BadgeService"),
    Marketplace = getService("MarketplaceService"),
    Analytics = getService("AnalyticsService"),
    Social = getService("SocialService"),
    Teleport = getService("TeleportService"),
    VR = getService("VRService"),
    Feedback = getService("FeedbackService"),
    Group = getService("GroupService"),
    Gui = getService("GuiService"),
    Leaderboard = getService("LeaderboardService"),
    NetworkClient = getService("NetworkClient"),
    NetworkReplicator = getService("NetworkReplicator"),
    Rendering = getService("RenderingService"),
    LocalizationTable = getService("LocalizationTableService"),
    Terrain = getService("Workspace"):FindFirstChildOfClass("Terrain"),
    TerrainRegion = getService("TerrainRegionService"),
    TextChat = getService("TextChatService"),
    Physics = getService("PhysicsService"),
    ContentProvider = getService("ContentProvider"),
    Ad = getService("AdService"),
    Trust = getService("TrustService"),
    VideoCapture = getService("VideoCaptureService"),
    VideoPlayback = getService("VideoPlaybackService"),
    VoiceChat = getService("VoiceChatService"),
    MemoryStore = getService("MemoryStoreService"),
    Friend = getService("FriendService"),
    Gamepad = getService("GamepadService"),
    Notification = getService("NotificationService"),
    Policy = getService("PolicyService"),
    Haptic = getService("HapticService"),
    Keyboard = getService("KeyboardService"),
    Mouse = getService("MouseService"),
    Studio = getService("StudioService"),
    ScriptContext = getService("ScriptContext"),
}

Services.getService = getService

return Services