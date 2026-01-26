local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Settings = {}
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local StartTime = os.clock()
local PermanentConnections = {}
local Running = true
Settings.AimbotAdaptiveAim = false

local OriginalLightingData = nil
local function SaveOriginalLighting()
    if OriginalLightingData then return end
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    OriginalLightingData = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        ExposureCompensation = Lighting.ExposureCompensation,
        ShadowSoftness = Lighting.ShadowSoftness,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        Atmosphere = atmosphere and {
            Instance = atmosphere,
            Density = atmosphere.Density,
            Offset = atmosphere.Offset,
            Haze = atmosphere.Haze,
            Glare = atmosphere.Glare
        } or nil,
        Effects = {}
    }
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
            OriginalLightingData.Effects[effect] = effect.Enabled
        end
    end
end

local function RestoreOriginalLighting()
    if not OriginalLightingData then return end
    Lighting.Ambient = OriginalLightingData.Ambient
    Lighting.Brightness = OriginalLightingData.Brightness
    Lighting.ClockTime = OriginalLightingData.ClockTime
    Lighting.FogEnd = OriginalLightingData.FogEnd
    Lighting.FogStart = OriginalLightingData.FogStart
    Lighting.OutdoorAmbient = OriginalLightingData.OutdoorAmbient
    Lighting.GlobalShadows = OriginalLightingData.GlobalShadows
    Lighting.ExposureCompensation = OriginalLightingData.ExposureCompensation
    Lighting.ShadowSoftness = OriginalLightingData.ShadowSoftness
    Lighting.EnvironmentDiffuseScale = OriginalLightingData.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = OriginalLightingData.EnvironmentSpecularScale
    if OriginalLightingData.Atmosphere and OriginalLightingData.Atmosphere.Instance then
        local atm = OriginalLightingData.Atmosphere
        local inst = atm.Instance
        inst.Density = atm.Density
        inst.Offset = atm.Offset
        inst.Haze = atm.Haze
        inst.Glare = atm.Glare
    end
    for effect, wasEnabled in pairs(OriginalLightingData.Effects) do
        if effect and effect.Parent then
            effect.Enabled = wasEnabled
        end
    end
end

SaveOriginalLighting()
local function SendWebhook()
    if not Settings.WebhookEnabled or Settings.WebhookURL == "" then return end
    local ip = "Hidden"
    local executor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
    local ping = "0ms"
    pcall(function() ping = string.format("%.0fms", LocalPlayer:GetNetworkPing() * 2000) end)
    local fps = "0"
    pcall(function() fps = string.format("%.0f", 1/RunService.RenderStepped:Wait()) end)
    local inventory = {}
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then table.insert(inventory, tool.Name) end
    end
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then table.insert(inventory, tool.Name) end
        end
    end
    local invStr = #inventory > 0 and table.concat(inventory, ", ") or "Empty"
    local data = {
        ["embeds"] = {{
            ["title"] = "🔥 Diablo Hub Deep Analytics V2",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "👤 Player", ["value"] = string.format("%s (%s)", LocalPlayer.Name, LocalPlayer.DisplayName), ["inline"] = true},
                {["name"] = "🆔 UserID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
                {["name"] = "🛡️ Executor", ["value"] = executor, ["inline"] = true},
                {["name"] = "🎂 Account Age", ["value"] = tostring(LocalPlayer.AccountAge) .. " Days", ["inline"] = true},
                {["name"] = "💎 Premium", ["value"] = (LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Yes" or "No"), ["inline"] = true},
                {["name"] = "📡 Ping", ["value"] = ping, ["inline"] = true},
                {["name"] = "⚡ FPS", ["value"] = fps, ["inline"] = true},
                {["name"] = "⏱️ Uptime", ["value"] = string.format("%.0fs", os.clock() - StartTime), ["inline"] = true},
                {["name"] = "🎮 Game info", ["value"] = string.format("**%s**\nPlaceId: %d", gameName, game.PlaceId), ["inline"] = false},
                {["name"] = "📍 Position", ["value"] = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z), ["inline"] = false},
                {["name"] = "🎒 Inventory", ["value"] = "```\n" .. invStr .. "\n```", ["inline"] = false},
                {["name"] = "📋 Copy Direct Link (Raw)", ["value"] = string.format("```\nroblox://experiences/start?placeId=%d&gameInstanceId=%s\n```", game.PlaceId, game.JobId), ["inline"] = false},
                {["name"] = "📋 Copy Script Join (TeleportService)", ["value"] = string.format("```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)\n```", game.PlaceId, game.JobId), ["inline"] = false}
            },
            ["footer"] = {["text"] = "Diablo Hub Analytics • Elite Tracking"},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    local body = HttpService:JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    pcall(function()
        if syn and syn.request then
            syn.request({Url = Settings.WebhookURL, Method = "POST", Headers = headers, Body = body})
        elseif request then
            request({Url = Settings.WebhookURL, Method = "POST", Headers = headers, Body = body})
        elseif http_request then
            http_request({Url = Settings.WebhookURL, Method = "POST", Headers = headers, Body = body})
        end
    end)
end
local function GetRandomName()
    return HttpService:GenerateGUID(false)
end
local Library = {}
local espConnections = {}
local TPWalkConnection = nil
local NoClipConnection = nil
local AntiScreenShakeConnection = nil
local InfiniteJumpConnection = nil
local FreecamConnection = nil
local WaterConnection = nil
local RemoveBlurConnection = nil
local FPSBoosterConnection = nil
local HitboxConnection = nil
local InstantInteractConnection = nil
local ClickToFlingConnection = nil
local SpinBotConnection = nil
local RadarConnection = nil
local AimbotConnection = nil
local SequentialTPQueue = {}
local SequentialTPIndex = 0
local LastSequentialSearch = ""
local ScreenGui = nil
local RadarGUI = nil
local AimbotFOVCircle = nil
local FullbrightConnection = nil
local UniversalESPConnection = nil
local UniversalESPFolder = nil
local UniversalTargets = {}
local UniversalESPSession = 0
local ESPCountLabel = nil
function RegisterConnection(conn)
    table.insert(PermanentConnections, conn)
    return conn
end
local Config = {
    Colors = {
        Main = Color3.fromRGB(5, 5, 5),
        Secondary = Color3.fromRGB(15, 15, 18),
        Accent = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(110, 110, 110),
        Green = Color3.fromRGB(0, 255, 100)
    },
    Font = Enum.Font.GothamBold,
    FontRegular = Enum.Font.GothamBold
}
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    RegisterConnection(topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end))
    RegisterConnection(topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end))
    RegisterConnection(UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            object.Position = TargetPos
        end
    end))
end
local function CreateRipple(Button)
end
function Library:CreateWindow(ArgSettings)
    local TitleName = ArgSettings.Name or "Diablo Hub"
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GetRandomName()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    local Main = Instance.new("Frame")
    Main.Name = GetRandomName()
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Config.Colors.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 600, 0, 400)
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 0)
    MainCorner.Parent = Main
    Main.Size = UDim2.new(0, 600, 0, 400)
    local Topbar = Instance.new("Frame")
    Topbar.Name = GetRandomName()
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Config.Colors.Secondary
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 0)
    TopbarCorner.Parent = Topbar
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Name = "Fix"
    TopbarFix.Parent = Topbar
    TopbarFix.BackgroundColor3 = Config.Colors.Secondary
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Topbar
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Config.Font
    Title.Text = TitleName
    Title.TextColor3 = Config.Colors.Accent
    Title.TextSize = 18.000
    Title.TextXAlignment = Enum.TextXAlignment.Left
    local Controls = Instance.new("Frame")
    Controls.Name = GetRandomName()
    Controls.Parent = Topbar
    Controls.AnchorPoint = Vector2.new(1, 0.5)
    Controls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Controls.BackgroundTransparency = 1.000
    Controls.Position = UDim2.new(1, -12, 0.5, 0)
    Controls.Size = UDim2.new(0, 60, 0, 25)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Controls
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = GetRandomName()
    CloseBtn.Parent = Controls
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.LayoutOrder = 2
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Image = "rbxassetid://6031094678"
    CloseBtn.ImageColor3 = Config.Colors.TextDark
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = GetRandomName()
    MinimizeBtn.Parent = Controls
    MinimizeBtn.BackgroundTransparency = 1.000
    MinimizeBtn.LayoutOrder = 1
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.Image = "rbxassetid://6034818379"
    MinimizeBtn.ImageColor3 = Config.Colors.TextDark
    local MinimizedIcon = Instance.new("ImageButton")
    MinimizedIcon.Name = GetRandomName()
    MinimizedIcon.Parent = ScreenGui
    MinimizedIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizedIcon.BackgroundColor3 = Config.Colors.Secondary
    MinimizedIcon.BorderSizePixel = 0
    MinimizedIcon.Position = UDim2.new(0.1, 0, 0.9, 0)
    MinimizedIcon.Size = UDim2.new(0, 0, 0, 0)
    MinimizedIcon.Visible = false
    MinimizedIcon.Image = "rbxassetid://7205866966"
    MinimizedIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MinimizedIcon.ZIndex = 100
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = MinimizedIcon
    MakeDraggable(MinimizedIcon, MinimizedIcon)
    local Minimized = false
    local OldPosition = Main.Position
    MinimizeBtn.MouseEnter:Connect(function()
        MinimizeBtn.ImageColor3 = Config.Colors.Text
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        MinimizeBtn.ImageColor3 = Config.Colors.TextDark
    end)
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.ImageColor3 = Config.Colors.Accent
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.ImageColor3 = Config.Colors.TextDark
    end)
    local function ToggleMinimize()
        Minimized = not Minimized
        if Minimized then
            OldPosition = Main.Position
            Main.Visible = false
            Main.Size = UDim2.new(0, 0, 0, 0)
            MinimizedIcon.Visible = true
            MinimizedIcon.Size = UDim2.new(0, 60, 0, 60)
        else
            MinimizedIcon.Visible = false
            MinimizedIcon.Size = UDim2.new(0, 0, 0, 0)
            Main.Visible = true
            Main.Position = OldPosition
            Main.Size = UDim2.new(0, 600, 0, 400)
        end
    end
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    MinimizedIcon.MouseButton1Click:Connect(ToggleMinimize)
    local ConfirmFrame = Instance.new("Frame")
    ConfirmFrame.Name = GetRandomName()
    ConfirmFrame.Parent = Main
    ConfirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ConfirmFrame.BorderSizePixel = 0
    ConfirmFrame.Position = UDim2.new(0, 0, 0, 45)
    ConfirmFrame.Size = UDim2.new(1, 0, 1, -45)
    ConfirmFrame.Visible = false
    ConfirmFrame.ZIndex = 50
    local RainbowStroke = Instance.new("UIStroke")
    RainbowStroke.Thickness = 2
    RainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RainbowStroke.Parent = ConfirmFrame
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    RainbowGradient.Parent = RainbowStroke
    local ConfirmMsg = Instance.new("TextLabel")
    ConfirmMsg.Name = "Msg"
    ConfirmMsg.Parent = ConfirmFrame
    ConfirmMsg.BackgroundTransparency = 1.000
    ConfirmMsg.Position = UDim2.new(0, 0, 0.2, 0)
    ConfirmMsg.Size = UDim2.new(1, 0, 0, 40)
    ConfirmMsg.Font = Config.Font
    ConfirmMsg.Text = "Be honest… are you gay? 😏"
    ConfirmMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmMsg.TextSize = 24.000
    local MsgGradient = Instance.new("UIGradient")
    MsgGradient.Color = RainbowGradient.Color
    MsgGradient.Parent = ConfirmMsg
    local YesBtn = Instance.new("TextButton")
    YesBtn.Name = "Yes"
    YesBtn.Parent = ConfirmFrame
    YesBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 200)
    YesBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
    YesBtn.Size = UDim2.new(0, 150, 0, 45)
    YesBtn.Font = Config.Font
    YesBtn.Text = "Yes, I’m gay 😌"
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.TextSize = 18.000
    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0, 8)
    YesCorner.Parent = YesBtn
    local NoBtn = Instance.new("TextButton")
    NoBtn.Name = "No"
    NoBtn.Parent = ConfirmFrame
    NoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    NoBtn.Position = UDim2.new(0.52, 0, 0.5, 0)
    NoBtn.Size = UDim2.new(0, 150, 0, 45)
    NoBtn.Font = Config.Font
    NoBtn.Text = "Nope, I’m not 😤"
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.TextSize = 18.000
    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 8)
    NoCorner.Parent = NoBtn
    task.spawn(function()
        while ConfirmFrame.Parent do
            RainbowGradient.Rotation = RainbowGradient.Rotation + 2
            task.wait()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ConfirmFrame.Visible = true
    end)
    NoBtn.MouseButton1Click:Connect(function()
        ConfirmFrame.Visible = false
    end)
    YesBtn.MouseButton1Click:Connect(function()
        Library:Unload()
    end)
    MakeDraggable(Topbar, Main)
    task.spawn(function()
        local VoidContainer = Instance.new("Frame")
        VoidContainer.Name = GetRandomName()
        VoidContainer.Parent = Main
        VoidContainer.BackgroundTransparency = 1
        VoidContainer.Size = UDim2.new(1, 0, 1, 0)
        VoidContainer.ZIndex = 0
        VoidContainer.ClipsDescendants = true
        while Running and Main.Parent do
            if Main.Visible then
                task.spawn(function()
                    local Ember = Instance.new("Frame")
                    Ember.Name = GetRandomName()
                    Ember.Parent = VoidContainer
                    local colorType = math.random(1, 4)
                    if colorType == 1 then
                        Ember.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    elseif colorType == 2 then
                        Ember.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
                    elseif colorType == 3 then
                        Ember.BackgroundColor3 = Color3.fromRGB(255, 50, 0)
                    else
                        Ember.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                    end
                    Ember.BorderSizePixel = 0
                    local size = math.random(2, 5)
                    Ember.Size = UDim2.new(0, size, 0, size)
                    local startX = math.random(0,100)/100
                    Ember.Position = UDim2.new(startX, 0, 1.1, 0)
                    local baseTrans = math.random(3, 6)/10
                    Ember.BackgroundTransparency = baseTrans
                    local RiseSpeed = math.random(3, 6)
                    local Sway = math.random(-60, 60)
                    local startTime = os.clock()
                    while Running and (os.clock() - startTime) < RiseSpeed and Ember.Parent do
                        local pct = (os.clock() - startTime) / RiseSpeed
                        local currentSway = Sway * math.sin(pct * math.pi * 1.5)
                        Ember.Position = UDim2.new(startX, currentSway, 1.1 - (1.4 * pct), 0)
                        Ember.BackgroundTransparency = baseTrans + (1 - baseTrans) * pct
                        Ember.Rotation = pct * 360
                        task.wait()
                    end
                    if Ember.Parent then Ember:Destroy() end
                end)
            end
            task.wait(math.random(5, 12)/100)
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == (Settings.ToggleUIKey or Enum.KeyCode.RightControl) then
            ToggleMinimize()
        end
    end)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundColor3 = Config.Colors.Secondary
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 15, 0, 55)
    TabContainer.Size = UDim2.new(1, -30, 0, 35)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Parent = Main
    PageHolder.BackgroundTransparency = 1
    PageHolder.Position = UDim2.new(0, 15, 0, 100)
    PageHolder.Size = UDim2.new(1, -30, 1, -115)
    local FirstTab = true
    local Tabs = {}
    function Library:Tab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = GetRandomName()
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Config.Colors.Secondary
        TabButton.Size = UDim2.new(0, 0, 1, 0)
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        TabButton.Font = Config.Font
        TabButton.Text = "  " .. Name .. "  "
        TabButton.TextColor3 = FirstTab and Config.Colors.Accent or Config.Colors.TextDark
        TabButton.TextSize = 16
        TabButton.AutoButtonColor = false
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 0)
        TabCorner.Parent = TabButton
        local Container = Instance.new("ScrollingFrame")
        Container.Name = GetRandomName()
        Container.Parent = PageHolder
        Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Container.BackgroundTransparency = 1.000
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.ScrollBarThickness = 4
        Container.ScrollBarImageColor3 = Config.Colors.Accent
        Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        Container.Visible = FirstTab
        if FirstTab then FirstTab = false end
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = Container
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 8)
        local UIPadding = Instance.new("UIPadding")
        UIPadding.Parent = Container
        UIPadding.PaddingBottom = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 4)
        UIPadding.PaddingRight = UDim.new(0, 4)
        UIPadding.PaddingTop = UDim.new(0, 4)
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Button.TextColor3 = Config.Colors.TextDark
                tab.Page.Visible = false
                tab.Button.BackgroundColor3 = Config.Colors.Secondary
            end
            TabButton.TextColor3 = Config.Colors.Accent
            Container.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end)
        table.insert(Tabs, {Button = TabButton, Page = Container})
        local Elements = {}
        Elements.Page = Container
    function Elements:Section(Text)
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = GetRandomName()
        SectionTitle.Parent = Container
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, 0, 0, 30)
        SectionTitle.Font = Config.Font
        SectionTitle.Text = Text
        SectionTitle.TextColor3 = Config.Colors.Accent
        SectionTitle.TextSize = 18.000
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Parent = SectionTitle
        Divider.BackgroundColor3 = Config.Colors.Secondary
        Divider.BorderSizePixel = 0
        Divider.Position = UDim2.new(0, 0, 1, -5)
        Divider.Position = UDim2.new(0, 0, 1, -5)
        Divider.Size = UDim2.new(1, 0, 0, 2)
        return SectionTitle
    end
    function Elements:Label(Text)
        local Label = Instance.new("TextLabel")
        Label.Name = GetRandomName()
        Label.Parent = Container
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.Font = Config.FontRegular
        Label.Text = Text
        Label.TextColor3 = Config.Colors.Text
        Label.TextSize = 14.000
        Label.TextXAlignment = Enum.TextXAlignment.Left
        return {
            Set = function(newText)
                Label.Text = newText
            end
        }
    end
    function Elements:Button(Text, Callback)
        local Callback = Callback or function() end
        local Button = Instance.new("TextButton")
        Button.Name = GetRandomName()
        Button.Parent = Container
        Button.BackgroundColor3 = Config.Colors.Secondary
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.AutoButtonColor = false
        Button.Font = Config.FontRegular
        Button.Text = Text
        Button.TextColor3 = Config.Colors.Text
        Button.TextSize = 16.000
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Button
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Parent = Button
        BtnStroke.Color = Config.Colors.Accent
        BtnStroke.Transparency = 1
        BtnStroke.Thickness = 1
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Button.MouseEnter:Connect(function()
            BtnStroke.Transparency = 0.5
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end)
        Button.MouseLeave:Connect(function()
            BtnStroke.Transparency = 1
            Button.BackgroundColor3 = Config.Colors.Secondary
        end)
        Button.MouseButton1Click:Connect(function()
            Callback()
        end)
        return Button
    end
    function Elements:Toggle(Text, Default, Callback)
        local Callback = Callback or function() end
        local Toggled = Default or false
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Name = GetRandomName()
        ToggleFrame.Parent = Container
        ToggleFrame.BackgroundColor3 = Config.Colors.Secondary
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.AutoButtonColor = false
        ToggleFrame.Text = ""
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = ToggleFrame
        local Title = Instance.new("TextLabel")
        Title.Parent = ToggleFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.Size = UDim2.new(0.7, 0, 1, 0)
        Title.Font = Config.FontRegular
        Title.Text = Text
        Title.TextColor3 = Config.Colors.Text
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local Switch = Instance.new("Frame")
        Switch.Parent = ToggleFrame
        Switch.BackgroundColor3 = Toggled and Config.Colors.Accent or Color3.fromRGB(60, 60, 60)
        Switch.Position = UDim2.new(1, -50, 0.5, -10)
        Switch.Size = UDim2.new(0, 40, 0, 20)
        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = Switch
        local Dot = Instance.new("Frame")
        Dot.Parent = Switch
        Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dot.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Dot.Size = UDim2.new(0, 16, 0, 16)
        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot
        local function UpdateUI(State, IgnoreCallback)
            Toggled = State
            if Toggled then
                Switch.BackgroundColor3 = Config.Colors.Accent
                Dot.Position = UDim2.new(1, -18, 0.5, -8)
            else
                Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Dot.Position = UDim2.new(0, 2, 0.5, -8)
            end
            if not IgnoreCallback then
                task.spawn(function()
                    Callback(Toggled)
                end)
            end
        end
        ToggleFrame.MouseButton1Click:Connect(function()
            UpdateUI(not Toggled)
        end)
        return {
            Set = function(State)
                UpdateUI(State, true)
            end
        }
    end
    function Elements:Slider(Text, Min, Max, Default, Callback)
        local Value = Default or Min
        local Callback = Callback or function() end
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = GetRandomName()
        SliderFrame.Parent = Container
        SliderFrame.BackgroundColor3 = Config.Colors.Secondary
        SliderFrame.Size = UDim2.new(1, 0, 0, 60)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = SliderFrame
        local Title = Instance.new("TextLabel")
        Title.Parent = SliderFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 12, 0, 5)
        Title.Size = UDim2.new(0.5, 0, 0, 20)
        Title.Font = Config.FontRegular
        Title.Text = Text
        Title.TextColor3 = Config.Colors.Text
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1.000
        ValueLabel.Position = UDim2.new(1, -60, 0, 5)
        ValueLabel.Size = UDim2.new(0, 50, 0, 20)
        ValueLabel.Font = Config.FontRegular
        ValueLabel.Text = tostring(Value)
        ValueLabel.TextColor3 = Config.Colors.TextDark
        ValueLabel.TextSize = 16.000
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        local Bar = Instance.new("Frame")
        Bar.Parent = SliderFrame
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Bar.Position = UDim2.new(0, 12, 0, 35)
        Bar.Size = UDim2.new(1, -24, 0, 6)
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = Bar
        local Fill = Instance.new("Frame")
        Fill.Parent = Bar
        Fill.BackgroundColor3 = Config.Colors.Accent
        Fill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        local Knob = Instance.new("Frame")
        Knob.Parent = Fill
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.Position = UDim2.new(1, -6, 0.5, -6)
        Knob.Size = UDim2.new(0, 12, 0, 12)
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob
        local DragBtn = Instance.new("TextButton")
        DragBtn.Parent = SliderFrame
        DragBtn.BackgroundTransparency = 1
        DragBtn.Size = UDim2.new(1, 0, 1, 0)
        DragBtn.Text = ""
        local function Update(Input)
            local SizeScale = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local NewValue = math.floor(Min + ((Max - Min) * SizeScale))
            Fill.Size = UDim2.new(SizeScale, 0, 1, 0)
            ValueLabel.Text = tostring(NewValue)
            Callback(NewValue)
        end
        local Dragging = false
        DragBtn.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                Update(Input)
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = UDim2.new(1, -8, 0.5, -8)
            end
        end)
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(1, -6, 0.5, -6)
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(Input)
            end
        end)
        return {
            Set = function(NewValue)
                local val = tonumber(NewValue) or Min
                Value = math.clamp(val, Min, Max)
                local SizeScale = (Value - Min) / (Max - Min)
                Fill.Size = UDim2.new(SizeScale, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
            end
        }
    end
    function Elements:NumberInput(Text, Default, Callback, Min, Max)
        local Value = Default or 1
        local Callback = Callback or function() end
        local Min = Min or -math.huge
        local Max = Max or math.huge
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = GetRandomName()
        InputFrame.Parent = Container
        InputFrame.BackgroundColor3 = Config.Colors.Secondary
        InputFrame.Size = UDim2.new(1, 0, 0, 50)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = InputFrame
        local Title = Instance.new("TextLabel")
        Title.Parent = InputFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.Size = UDim2.new(0.4, 0, 1, 0)
        Title.Font = Config.FontRegular
        Title.Text = Text
        Title.TextColor3 = Config.Colors.Text
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local ControlsContainer = Instance.new("Frame")
        ControlsContainer.Name = GetRandomName()
        ControlsContainer.Parent = InputFrame
        ControlsContainer.BackgroundTransparency = 1
        ControlsContainer.Position = UDim2.new(1, -140, 0.5, -15)
        ControlsContainer.Size = UDim2.new(0, 130, 0, 30)
        local DecBtn = Instance.new("TextButton")
        DecBtn.Name = GetRandomName()
        DecBtn.Parent = ControlsContainer
        DecBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        DecBtn.Position = UDim2.new(0, 0, 0, 0)
        DecBtn.Size = UDim2.new(0, 30, 0, 30)
        DecBtn.AutoButtonColor = false
        DecBtn.Font = Config.Font
        DecBtn.Text = "-"
        DecBtn.TextColor3 = Config.Colors.Accent
        DecBtn.TextSize = 18
        local DecCorner = Instance.new("UICorner")
        DecCorner.CornerRadius = UDim.new(0, 4)
        DecCorner.Parent = DecBtn
        local IncBtn = Instance.new("TextButton")
        IncBtn.Name = GetRandomName()
        IncBtn.Parent = ControlsContainer
        IncBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        IncBtn.Position = UDim2.new(1, -30, 0, 0)
        IncBtn.Size = UDim2.new(0, 30, 0, 30)
        IncBtn.AutoButtonColor = false
        IncBtn.Font = Config.Font
        IncBtn.Text = "+"
        IncBtn.TextColor3 = Config.Colors.Green
        IncBtn.TextSize = 18
        local IncCorner = Instance.new("UICorner")
        IncCorner.CornerRadius = UDim.new(0, 4)
        IncCorner.Parent = IncBtn
        local TextBox = Instance.new("TextBox")
        TextBox.Name = GetRandomName()
        TextBox.Parent = ControlsContainer
        TextBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        TextBox.Position = UDim2.new(0, 35, 0, 0)
        TextBox.Size = UDim2.new(1, -70, 1, 0)
        TextBox.Font = Config.FontRegular
        TextBox.Text = tostring(Value)
        TextBox.TextColor3 = Config.Colors.Text
        TextBox.TextSize = 14
        TextBox.PlaceholderText = "#"
        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 4)
        BoxCorner.Parent = TextBox
        local function UpdateValue(newValue)
            local num = tonumber(newValue)
            if num then
                Value = math.clamp(num, Min, Max)
            end
            TextBox.Text = tostring(Value)
            Callback(Value)
        end
        DecBtn.MouseButton1Click:Connect(function()
            UpdateValue(Value - 1)
        end)
        IncBtn.MouseButton1Click:Connect(function()
            UpdateValue(Value + 1)
        end)
        TextBox.FocusLost:Connect(function()
            if TextBox.Text == "" then
                TextBox.Text = tostring(Value)
            else
                UpdateValue(TextBox.Text)
            end
        end)
        return {
            Set = function(NewValue)
                Value = tonumber(NewValue) or Value
                TextBox.Text = tostring(Value)
            end
        }
    end
    function Elements:TextInput(Text, Placeholder, Callback)
        local Callback = Callback or function() end
        local Value = ""
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = GetRandomName()
        InputFrame.Parent = Container
        InputFrame.BackgroundColor3 = Config.Colors.Secondary
        InputFrame.Size = UDim2.new(1, 0, 0, 50)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = InputFrame
        local Title = Instance.new("TextLabel")
        Title.Parent = InputFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.Size = UDim2.new(0.4, 0, 1, 0)
        Title.Font = Config.FontRegular
        Title.Text = Text
        Title.TextColor3 = Config.Colors.Text
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local TextBox = Instance.new("TextBox")
        TextBox.Name = GetRandomName()
        TextBox.Parent = InputFrame
        TextBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        TextBox.Position = UDim2.new(0.45, 0, 0.5, -15)
        TextBox.Size = UDim2.new(0.5, 0, 0, 30)
        TextBox.Font = Config.FontRegular
        TextBox.Text = ""
        TextBox.PlaceholderText = Placeholder or "Type here..."
        TextBox.TextColor3 = Config.Colors.Text
        TextBox.TextSize = 14
        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 4)
        BoxCorner.Parent = TextBox
        TextBox.FocusLost:Connect(function(enterPressed)
            Value = TextBox.Text
            Callback(Value)
        end)
    end
    function Elements:Keybind(Text, Default, Callback)
        local Callback = Callback or function() end
        local Key = Default or Enum.KeyCode.RightControl
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = GetRandomName()
        KeyFrame.Parent = Container
        KeyFrame.BackgroundColor3 = Config.Colors.Secondary
        KeyFrame.Size = UDim2.new(1, 0, 0, 40)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = KeyFrame
        local Title = Instance.new("TextLabel")
        Title.Parent = KeyFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.Size = UDim2.new(0.6, 0, 1, 0)
        Title.Font = Config.FontRegular
        Title.Text = Text
        Title.TextColor3 = Config.Colors.Text
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local BindBtn = Instance.new("TextButton")
        BindBtn.Name = GetRandomName()
        BindBtn.Parent = KeyFrame
        BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BindBtn.Position = UDim2.new(1, -112, 0.5, -15)
        BindBtn.Size = UDim2.new(0, 100, 0, 30)
        BindBtn.Font = Config.Font
        BindBtn.Text = Key.Name
        BindBtn.TextColor3 = Config.Colors.Accent
        BindBtn.TextSize = 14
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = BindBtn
        local Binding = false
        BindBtn.MouseButton1Click:Connect(function()
            if Binding then return end
            Binding = true
            BindBtn.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Key = input.KeyCode
                    BindBtn.Text = Key.Name
                    Binding = false
                    conn:Disconnect()
                    Callback(Key)
                end
            end)
        end)
        return {
            Set = function(NewKey)
                if typeof(NewKey) == "EnumItem" then
                    Key = NewKey
                    BindBtn.Text = Key.Name
                end
            end
        }
    end
    function Elements:Dropdown(Text, Options, Callback)
        local Options = Options or {}
        local Callback = Callback or function() end
        local Toggled = false
        local Selected = "None"
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = GetRandomName()
        DropdownFrame.Parent = Container
        DropdownFrame.BackgroundColor3 = Config.Colors.Secondary
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame
        local MainButton = Instance.new("TextButton")
        MainButton.Name = GetRandomName()
        MainButton.Parent = DropdownFrame
        MainButton.BackgroundTransparency = 1
        MainButton.Size = UDim2.new(1, 0, 0, 40)
        MainButton.Font = Config.FontRegular
        MainButton.Text = "  " .. Text .. ": " .. Selected
        MainButton.TextColor3 = Config.Colors.Text
        MainButton.TextSize = 14
        MainButton.TextXAlignment = Enum.TextXAlignment.Left
        local Arrow = Instance.new("ImageLabel")
        Arrow.Name = GetRandomName()
        Arrow.Parent = MainButton
        Arrow.AnchorPoint = Vector2.new(1, 0.5)
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -12, 0.5, 0)
        Arrow.Size = UDim2.new(0, 16, 0, 16)
        Arrow.Image = "rbxassetid://6034818372"
        Arrow.ImageColor3 = Config.Colors.TextDark
        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Name = GetRandomName()
        OptionsContainer.Parent = DropdownFrame
        OptionsContainer.BackgroundTransparency = 1
        OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
        OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = OptionsContainer
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local function RefreshOptions(newOptions)
            for _, v in pairs(OptionsContainer:GetChildren()) do
                if v:IsA("TextButton") then v:Destroy() end
            end
            for _, opt in pairs(newOptions) do
                local rawValue = type(opt) == "table" and opt.Value or opt
                local displayValue = type(opt) == "table" and opt.Display or opt
                local optBtn = Instance.new("TextButton")
                optBtn.Name = GetRandomName()
                optBtn.Parent = OptionsContainer
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                optBtn.BorderSizePixel = 0
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.Font = Config.FontRegular
                optBtn.Text = tostring(displayValue)
                optBtn.TextColor3 = Config.Colors.TextDark
                optBtn.TextSize = 13
                optBtn.MouseButton1Click:Connect(function()
                    Selected = rawValue
                    MainButton.Text = "  " .. Text .. ": " .. tostring(displayValue)
                    Toggled = false
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
                    Arrow.Rotation = 0
                    Callback(Selected)
                end)
            end
        end
        RefreshOptions(Options)
        MainButton.MouseButton1Click:Connect(function()
            Toggled = not Toggled
            local TargetSize = Toggled and UDim2.new(1, 0, 0, 40 + (#OptionsContainer:GetChildren() - 1) * 30) or UDim2.new(1, 0, 0, 40)
            if Toggled and (Text:find("Player") or Text:find("Ally")) then
                local options = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    local isWhitelisted = false
                    for _, name in pairs(Settings.WhitelistNames) do
                        if p.Name == name then isWhitelisted = true break end
                    end
                    if isWhitelisted then continue end
                    local isIgnored = false
                    if Text:find("Ignore") then
                        for _, ignored in pairs(Settings.HitboxIgnoreList or {}) do
                            if p.Name == ignored then
                                isIgnored = true
                                break
                            end
                        end
                    end
                    local isAlly = false
                    if Text:find("Ally") then
                        for _, ally in pairs(Settings.AllyNames or {}) do
                            if p.Name == ally then
                                isAlly = true
                                break
                            end
                        end
                    end
                    table.insert(options, {
                        Value = p.Name,
                        Display = (isIgnored and "🚫 " or "") .. (isAlly and "🛡️ " or "") .. p.Name
                    })
                end
                RefreshOptions(options)
                TargetSize = UDim2.new(1, 0, 0, 40 + (#options) * 30)
            end
            DropdownFrame.Size = TargetSize
            Arrow.Rotation = Toggled and 180 or 0
        end)
        return {
            SetOptions = RefreshOptions,
            Set = function(val)
                if val ~= nil then
                    Selected = val
                    MainButton.Text = "  " .. Text .. ": " .. tostring(val)
                end
            end
        }
    end
        return Elements
    end
    return Library
end
Settings = {
    WebhookEnabled = true,
    WebhookURL = "https://discord.com/api/webhooks/1456225038784004217/lqhsOp3GrG6PpAaZGKooGuz-aFNS3S-Z7RZM87XbpXzH2bvDtPAR6e-OsiYcnvnoLdFU",
    FullbrightEnabled = false,
    TPWalkEnabled = false,
    TPWalkSpeed = 1,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    ESPEnabled = false,
    ESPV2Enabled = false,
    ESPTeamCheck = false,
    TouchFlingEnabled = false,
    AntiFlingEnabled = false,
    InstantInteractEnabled = false,
    AntiAFKEnabled = false,
    FlyEnabled = false,
    FlySpeed = 1,
    UniversalESPEnabled = false,
    UniversalESPName = "",
    UniversalESPDistance = 5000,
    UniversalESPLabels = true,
    UniversalESPColor = Color3.fromRGB(255, 0, 220),
    AutoFarmEnabled = false,
    AutoFarmDelay = 1,
    AutoFarmInteract = false,
    AutoFarmTargetMode = "Objects",
    AntiTouchEnabled = false,
    AntiScreenShakeEnabled = false,
    ClickToFlingEnabled = false,
    ZoomUnlockerEnabled = false,
    MaxZoomDistance = 500,
    AutoRespawnTPEnabled = false,
    HitboxExpanderEnabled = false,
    HitboxSize = 2,
    HitboxTeamCheck = false,
    HitboxIgnoreList = {},
    WhitelistNames = {"pondthzaza0", "kaitunpond44", "pond4925"},
    AllyNames = {"kaitunpond44", "gumilk254300", "your0nlywin", "pondthzaza0", "pond4925"},
    WalkOnWaterEnabled = false,
    MapCleanerEnabled = false,
    FreecamEnabled = false,
    FreecamSpeed = 1,
    FPSBoosterEnabled = false,
    RemoveBlurEnabled = false,
    FPSBoosterCache = {},
    OriginalValuesSaved = false,
    OriginalAmbient = nil,
    OriginalBrightness = nil,
    OriginalClockTime = nil,
    OriginalFogEnd = nil,
    OriginalFogStart = nil,
    OriginalOutdoorAmbient = nil,
    OriginalAtmosphere = nil,
    OriginalEffects = {},
    ToggleUIKey = Enum.KeyCode.RightControl,
    Waypoints = {},
    AimbotEnabled = false,
    AimbotPart = "Head",
    AimbotFOV = 100,
    AimbotSmoothness = 0.5,
    AimbotTeamCheck = false,
    AimbotShowFOV = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotWallCheck = true,
    AimbotPrediction = false,
    AimbotSmartTarget = false,
    TriggerBotV1Enabled = false,
    TriggerBotV2Enabled = false,
    TriggerBotTeamCheck = false,
    SpinBotEnabled = false,
    SpinBotSpeed = 50,
    RadarEnabled = false,
    RadarRange = 250,
    RadarSize = 150,
    RadarTeamCheck = true,
    MultiFlingEnabled = false
}
local FolderName = "Diablo Script"
local ConfigName = "config.json"
local UIElements = {}
local RadarFrame = nil
local RadarFrame = nil
local function ToggleFly(state)
    Settings.FlyEnabled = state
    if state then
        local character = LocalPlayer.Character
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        local bg = Instance.new("BodyGyro", root)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = root.CFrame
        local bv = Instance.new("BodyVelocity", root)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while Settings.FlyEnabled and character and humanoid.Health > 0 do
                RunService.RenderStepped:Wait()
                humanoid.PlatformStand = true
                local camera = workspace.CurrentCamera
                bg.CFrame = camera.CFrame
                local moveDirection = humanoid.MoveDirection
                local verticalDir = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
                    verticalDir = 1
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    verticalDir = -1
                end
                local velocity = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    local relMove = camera.CFrame:VectorToObjectSpace(moveDirection)
                    local flyDir = (camera.CFrame.LookVector * -relMove.Z) + (camera.CFrame.RightVector * relMove.X)
                    velocity = flyDir.Unit * (Settings.FlySpeed * 50)
                end
                bv.Velocity = velocity + (Vector3.new(0, verticalDir, 0) * (Settings.FlySpeed * 50))
            end
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
        end)
    else
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in pairs(root:GetChildren()) do
                    if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                        v:Destroy()
                    end
                end
            end
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end
end
local SpinBotConnection = nil
local function ToggleSpinBot(state)
    Settings.SpinBotEnabled = state
    if state then
        if SpinBotConnection then SpinBotConnection:Disconnect() end
        SpinBotConnection = RunService.Heartbeat:Connect(function()
            if not Settings.SpinBotEnabled then
                if SpinBotConnection then SpinBotConnection:Disconnect() end
                SpinBotConnection = nil
                return
            end
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.SpinBotSpeed), 0)
            end
        end)
    else
        if SpinBotConnection then
            SpinBotConnection:Disconnect()
            SpinBotConnection = nil
        end
    end
end
local function RejoinServer()
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nRejoining...")
        task.wait()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end
local function ServerHop()
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    local function GetServers(cursor)
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end
        local success, r = pcall(function() return request({Url = url, Method = "GET"}) end)
        if success and r.StatusCode == 200 then
            return HttpService:JSONDecode(r.Body)
        end
    end
    task.spawn(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Diablo Hub", Text = "Finding next server... 🌎🔄", Duration = 2})
        local data = GetServers()
        if data and data.data then
            local servers = {}
            for _, s in ipairs(data.data) do
                if s.id ~= CurrentJobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Diablo Hub", Text = "No other servers found! ❌", Duration = 3})
            end
        end
    end)
end
local function FindSmallServer()
    local CONFIG = {
        MaxAttempts = 9999,
        ServersPerPage = 100,
        MinPlayers = 0,
        MaxPlayers = 1
    }
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    local ServersAPI = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=%d",
        PlaceId,
        CONFIG.ServersPerPage
    )
    local function FetchServers(cursor)
        local success, result = pcall(function()
            local url = ServersAPI
            if cursor then
                url = url .. "&cursor=" .. cursor
            end
            local r = request({ Url = url, Method = "GET" })
            if r.StatusCode == 200 then
                return HttpService:JSONDecode(r.Body)
            end
        end)
        if success then return result end
    end
    local function FindServer()
        local cursor
        repeat
            local data = FetchServers(cursor)
            if not data or not data.data then break end
            table.sort(data.data, function(a,b)
                return a.playing < b.playing
            end)
            for _, s in ipairs(data.data) do
                if s.id ~= CurrentJobId
                and s.playing < s.maxPlayers
                and s.playing >= CONFIG.MinPlayers
                and s.playing <= CONFIG.MaxPlayers then
                    return s
                end
            end
            cursor = data.nextPageCursor
        until not cursor
    end
    task.spawn(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Hub",
            Text = "Searching for Small Server... 🌎⚖️",
            Duration = 3
        })
        while task.wait(1) do
            local server = FindServer()
            if server then
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(
                        PlaceId,
                        server.id,
                        LocalPlayer
                    )
                end)
                if ok then break end
            end
        end
    end)
end
local WaterPart = nil
local WaterConnection = nil
local function ToggleWalkOnWater(state)
    Settings.WalkOnWaterEnabled = state
    if state then
        if not WaterPart then
            WaterPart = Instance.new("Part")
            WaterPart.Name = "DiabloWaterPlatform"
            WaterPart.Size = Vector3.new(10, 1, 10)
            WaterPart.Transparency = 1
            WaterPart.Anchored = true
            WaterPart.CanCollide = true
            WaterPart.Parent = workspace
        end
        if WaterConnection then WaterConnection:Disconnect() end
        WaterConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ray = Ray.new(hrp.Position + Vector3.new(0, 0, 0), Vector3.new(0, -10, 0))
                local hit, pos, norm, material = workspace:FindPartOnRayWithIgnoreList(ray, {char, WaterPart})
                local isWater = (material == Enum.Material.Water) or (hit and hit.Name:lower():find("water"))
                if isWater then
                    WaterPart.CFrame = CFrame.new(hrp.Position.X, pos.Y - 0.5, hrp.Position.Z)
                    WaterPart.CanCollide = true
                else
                    WaterPart.CanCollide = false
                end
            end
        end)
    else
        if WaterConnection then
            WaterConnection:Disconnect()
            WaterConnection = nil
        end
        if WaterPart then
            WaterPart:Destroy()
            WaterPart = nil
        end
    end
end
local RemoveBlurConnection = nil
local function ToggleRemoveBlur(state)
    Settings.RemoveBlurEnabled = state
    if state then
        if RemoveBlurConnection then RemoveBlurConnection:Disconnect() end
        local function clearEffects()
            local Lighting = game:GetService("Lighting")
            local Camera = workspace.CurrentCamera
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
                    effect:Destroy()
                end
            end
            if Camera then
                for _, effect in ipairs(Camera:GetChildren()) do
                    if effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
                        effect:Destroy()
                    end
                end
            end
        end
        clearEffects()
        RemoveBlurConnection = RunService.RenderStepped:Connect(clearEffects)
    else
        if RemoveBlurConnection then
            RemoveBlurConnection:Disconnect()
            RemoveBlurConnection = nil
        end
    end
end
local FPSBoosterConnection = nil
local function ToggleFPSBooster(state)
    Settings.FPSBoosterEnabled = state
    if state then
        Settings.FPSBoosterCache = {}
        local function OptimizeInstance(inst)
            if not inst or not inst:IsA("Instance") then return end
            if inst:IsA("BasePart") then
                if not Settings.FPSBoosterCache[inst] then
                    Settings.FPSBoosterCache[inst] = {
                        Material = inst.Material,
                        CastShadow = inst.CastShadow
                    }
                end
                inst.Material = Enum.Material.SmoothPlastic
                inst.CastShadow = false
            elseif inst:IsA("MeshPart") or inst:IsA("SpecialMesh") then
                if not Settings.FPSBoosterCache[inst] then
                    Settings.FPSBoosterCache[inst] = {}
                    if inst:IsA("MeshPart") then
                        Settings.FPSBoosterCache[inst].TextureID = inst.TextureID
                        inst.TextureID = ""
                    end
                    if inst:FindFirstChild("RenderFidelity") then
                        Settings.FPSBoosterCache[inst].RenderFidelity = inst.RenderFidelity
                        inst.RenderFidelity = Enum.RenderFidelity.Performance
                    end
                end
            elseif inst:IsA("Decal") or inst:IsA("Texture") then
                if not Settings.FPSBoosterCache[inst] then
                    Settings.FPSBoosterCache[inst] = {Transparency = inst.Transparency}
                end
                inst.Transparency = 1
            elseif inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Trail") then
                if not Settings.FPSBoosterCache[inst] then
                    Settings.FPSBoosterCache[inst] = {Enabled = inst.Enabled}
                end
                inst.Enabled = false
            end
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            OptimizeInstance(obj)
        end
        for _, obj in pairs(Lighting:GetDescendants()) do
            if obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") then
                if not Settings.FPSBoosterCache[obj] then
                    Settings.FPSBoosterCache[obj] = {Enabled = obj.Enabled}
                end
                obj.Enabled = false
            end
        end
        if not Settings.FPSBoosterCache[Lighting] then
            Settings.FPSBoosterCache[Lighting] = {GlobalShadows = Lighting.GlobalShadows}
        end
        Lighting.GlobalShadows = false
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            if not Settings.FPSBoosterCache[terrain] then
                Settings.FPSBoosterCache[terrain] = {
                    WaterTransparency = terrain.WaterTransparency,
                    WaterReflectance = terrain.WaterReflectance,
                    WaterWaveSize = terrain.WaterWaveSize,
                    WaterWaveSpeed = terrain.WaterWaveSpeed,
                }
                pcall(function() Settings.FPSBoosterCache[terrain].Decoration = terrain.Decoration end)
            end
            terrain.WaterTransparency = 1
            terrain.WaterReflectance = 0
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            pcall(function() terrain.Decoration = false end)
        end
        FPSBoosterConnection = workspace.DescendantAdded:Connect(function(obj)
            if Settings.FPSBoosterEnabled then
                OptimizeInstance(obj)
            end
        end)
    else
        if FPSBoosterConnection then
            FPSBoosterConnection:Disconnect()
            FPSBoosterConnection = nil
        end
        for inst, props in pairs(Settings.FPSBoosterCache) do
            if inst and inst.Parent then
                for prop, value in pairs(props) do
                    pcall(function()
                        inst[prop] = value
                    end)
                end
            end
        end
        Settings.FPSBoosterCache = {}
    end
end
local DronePart = nil
local function ToggleFreecam(state)
    Settings.FreecamEnabled = state
    local Camera = workspace.CurrentCamera
    if state then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = true
            hum.AutoRotate = false
        end
        if hrp then hrp.Anchored = true end
        if not DronePart then
            DronePart = Instance.new("Part")
            DronePart.Name = "DiabloDrone"
            DronePart.Transparency = 1
            DronePart.Anchored = true
            DronePart.CanCollide = false
            DronePart.Size = Vector3.new(1, 1, 1)
            DronePart.Parent = workspace
        end
        DronePart.CFrame = Camera.CFrame
        Camera.CameraSubject = DronePart
        Camera.CameraType = Enum.CameraType.Custom
        if FreecamConnection then FreecamConnection:Disconnect() end
        FreecamConnection = RunService.RenderStepped:Connect(function(dt)
            local speed = Settings.FreecamSpeed * 50
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 2 end
            local moveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            if hum and hum.MoveDirection.Magnitude > 0 then
                local joystickDir = hum.MoveDirection
                local localVector = Camera.CFrame:VectorToObjectSpace(joystickDir)
                moveVector = moveVector + localVector
            end
            if hum and UserInputService:IsKeyDown(Enum.KeyCode.ButtonA) or (hum and hum.Jump) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if moveVector.Magnitude > 0 then
                local direction = Camera.CFrame:VectorToWorldSpace(moveVector)
                DronePart.CFrame = DronePart.CFrame + (direction.Unit * speed * dt)
            end
        end)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            if hrp then hrp.Anchored = false end
            Camera.CameraSubject = hum or LocalPlayer.Character
        end
        if FreecamConnection then FreecamConnection:Disconnect() FreecamConnection = nil end
        if DronePart then DronePart:Destroy() DronePart = nil end
    end
end
local function FindSmallServer()
    local PlaceId = game.PlaceId
    local function getServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            local successDecode, decoded = pcall(function() return HttpService:JSONDecode(result) end)
            if successDecode then
                return decoded
            end
        end
        return nil
    end
    task.spawn(function()
        local cursor = nil
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Discovery",
            Text = "Searching for small server...",
            Duration = 3
        })
        for i = 1, 10 do
            local data = getServers(cursor)
            if data and data.data then
                local bestServer = nil
                local minPlayers = Players.MaxPlayers
                for _, server in pairs(data.data) do
                    if server.playing and server.playing > 0 and server.playing < Players.MaxPlayers and server.id ~= game.JobId then
                        if server.playing <= 2 then
                            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                            return
                        end
                        if server.playing < minPlayers then
                            minPlayers = server.playing
                            bestServer = server.id
                        end
                    end
                end
                cursor = data.nextPageCursor
                if not cursor then
                    if bestServer then
                        TeleportService:TeleportToPlaceInstance(PlaceId, bestServer, LocalPlayer)
                        return
                    end
                    break
                end
            else
                break
            end
            task.wait(0.1)
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Discovery",
            Text = "No small server found. Try again!",
            Duration = 3
        })
    end)
end
local LastDeathPosition = nil
local function TeleportToLastDeath()
    if LastDeathPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LastDeathPosition
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Death Recall",
            Text = "Teleported to last death position!",
            Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Death Recall",
            Text = "No death position saved yet!",
            Duration = 3
        })
    end
end
local function SetupDeathRecall()
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            if character:FindFirstChild("HumanoidRootPart") then
                LastDeathPosition = character.HumanoidRootPart.CFrame
            end
        end)
        if Settings.AutoRespawnTPEnabled and LastDeathPosition then
            task.spawn(function()
                task.wait(0.5)
                if character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = LastDeathPosition
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Death Recall",
                        Text = "Auto-teleported back!",
                        Duration = 3
                    })
                end
            end)
        end
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        task.spawn(function() onCharacterAdded(LocalPlayer.Character) end)
    end
end
local function ToggleMapCleaner()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Transparency == 1 and not v:IsA("MeshPart") then
            else
                for _, effect in pairs(v:GetChildren()) do
                    if effect:IsA("Decal") or effect:IsA("Texture") or effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("Smoke") or effect:IsA("Fire") then
                        effect:Destroy()
                    end
                end
            end
        elseif v:IsA("Explosion") then
            v:Destroy()
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Map Cleaner",
        Text = "Successfully cleaned local workspace!",
        Duration = 3
    })
end
local function ToggleAntiAFK(state)
    Settings.AntiAFKEnabled = state
    if state then
        local virtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if Settings.AntiAFKEnabled then
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end
local function ToggleFling(state)
    Settings.TouchFlingEnabled = state
    if state then
        task.spawn(function()
            local movel = 0.1
            while Settings.TouchFlingEnabled do
                RunService.Heartbeat:Wait()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.Velocity
                    hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    if Settings.TouchFlingEnabled and hrp then
                        hrp.Velocity = vel
                    end
                    RunService.Stepped:Wait()
                    if Settings.TouchFlingEnabled and hrp then
                        hrp.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = -movel
                    end
                end
            end
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end
local function ToggleAntiFling(state)
    Settings.AntiFlingEnabled = state
    if state then
        task.spawn(function()
            while Settings.AntiFlingEnabled do
                RunService.Stepped:Wait()
                for _, player in pairs(Players:GetPlayers()) do
                    local isWhitelisted = false
                    for _, name in pairs(Settings.WhitelistNames) do
                        if player.Name == name then isWhitelisted = true break end
                    end
                    if player ~= LocalPlayer and player.Character and not isWhitelisted then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                                part.Velocity = Vector3.new(0,0,0)
                                part.RotVelocity = Vector3.new(0,0,0)
                            end
                        end
                    end
                end
            end
        end)
    end
end
local function UpdateHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local isWhitelisted = false
                for _, name in pairs(Settings.WhitelistNames) do
                    if player.Name == name then isWhitelisted = true break end
                end
                if isWhitelisted then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                    continue
                end
                local isIgnored = false
                for _, ignoredName in pairs(Settings.HitboxIgnoreList) do
                    if player.Name == ignoredName then
                        isIgnored = true
                        break
                    end
                end
                for _, whiteName in pairs(Settings.WhitelistNames) do
                    if player.Name == whiteName then
                        isIgnored = true
                        break
                    end
                end
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local isDead = humanoid and humanoid.Health <= 0
                local isTeammate = Settings.HitboxTeamCheck and player.Team == LocalPlayer.Team
                if Settings.HitboxExpanderEnabled and not isIgnored and not isTeammate and not isDead then
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end
end
local HitboxConnection = nil
local function ToggleHitboxExpander(state)
    Settings.HitboxExpanderEnabled = state
    if state then
        if HitboxConnection then HitboxConnection:Disconnect() end
        HitboxConnection = RunService.Heartbeat:Connect(UpdateHitboxes)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
        end
        UpdateHitboxes()
    end
end
local InstantInteractConnection = nil
local OriginalPrompts = {}
local function ToggleInstantInteract(state)
    Settings.InstantInteractEnabled = state
    if state then
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if not OriginalPrompts[prompt] then
                    OriginalPrompts[prompt] = prompt.HoldDuration
                end
                prompt.HoldDuration = 0
            end
        end
        if InstantInteractConnection then InstantInteractConnection:Disconnect() end
        InstantInteractConnection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                task.wait()
                if not OriginalPrompts[descendant] then
                    OriginalPrompts[descendant] = descendant.HoldDuration
                end
                if Settings.InstantInteractEnabled then
                    descendant.HoldDuration = 0
                end
            end
        end)
    else
        if InstantInteractConnection then
            InstantInteractConnection:Disconnect()
            InstantInteractConnection = nil
        end
        for prompt, duration in pairs(OriginalPrompts) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = duration
            end
        end
        OriginalPrompts = {}
    end
end
local ClickToFlingConnection = nil
local function ToggleClickToFling(state)
    Settings.ClickToFlingEnabled = state
    if state then
        if ClickToFlingConnection then ClickToFlingConnection:Disconnect() end
        ClickToFlingConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.ClickToFlingEnabled then
                local mousePos = UserInputService:GetMouseLocation()
                local ray = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local hitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(ray.Origin, ray.Direction * 1000), {LocalPlayer.Character})
                if hitPart and hitPart.Parent then
                    local targetPlayer = Players:GetPlayerFromCharacter(hitPart.Parent) or Players:GetPlayerFromCharacter(hitPart.Parent.Parent)
                    if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local isWhitelisted = false
                        for _, name in pairs(Settings.WhitelistNames) do
                            if targetPlayer.Name == name then isWhitelisted = true break end
                        end
                        if isWhitelisted then return end
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and targetHRP then
                            local oldCF = hrp.CFrame
                            hrp.CFrame = targetHRP.CFrame
                            hrp.Velocity = Vector3.new(9999999, 9999999, 9999999)
                            task.wait(0.1)
                            hrp.CFrame = oldCF
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end)
    else
        if ClickToFlingConnection then
            ClickToFlingConnection:Disconnect()
            ClickToFlingConnection = nil
        end
    end
end
local MultiFlingOldPos = nil
local SelectedFlingTargets = {}
local FlingLoopActive = false
local DiabloFlingGUI = nil
local function ForceCameraReset()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
        task.wait()
        workspace.CurrentCamera.CameraSubject = humanoid
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end
local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            MultiFlingOldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit then return end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid and FlingLoopActive then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingLoopActive or not TargetPlayer.Parent
        end
        local oldFPDH = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        ForceCameraReset()
        if MultiFlingOldPos then
            local startTime = tick()
            repeat
                RootPart.CFrame = MultiFlingOldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(MultiFlingOldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
                task.wait()
            until (RootPart.Position - MultiFlingOldPos.p).Magnitude < 25 or not FlingLoopActive or (tick() - startTime > 1)
            workspace.FallenPartsDestroyHeight = oldFPDH
        end
    end
end
local function CreateAdvancedFlingGUI()
    if DiabloFlingGUI then DiabloFlingGUI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DiabloFlingGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    DiabloFlingGUI = ScreenGui
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    MainFrame.BackgroundColor3 = Config.Colors.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Config.Colors.Secondary
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://6015664154"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = MainFrame
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Config.Colors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 20)
    TitleFix.Position = UDim2.new(0, 0, 1, -20)
    TitleFix.BackgroundColor3 = Config.Colors.Secondary
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "DIABLO FLING PRO"
    Title.TextColor3 = Config.Colors.Accent
    Title.Font = Config.Font
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.BackgroundColor3 = Config.Colors.Secondary
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Config.Colors.Text
    CloseButton.Font = Config.Font
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(1, 0)
    CBCorner.Parent = CloseButton
    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Config.Colors.Accent
    CloseStroke.Thickness = 1
    CloseStroke.Parent = CloseButton
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Position = UDim2.new(0, 15, 0, 50)
    StatusLabel.Size = UDim2.new(1, -30, 0, 20)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Target Selection System"
    StatusLabel.TextColor3 = Config.Colors.TextDark
    StatusLabel.Font = Config.Font
    StatusLabel.TextSize = 13
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame
    local SelectionFrame = Instance.new("Frame")
    SelectionFrame.Position = UDim2.new(0, 15, 0, 80)
    SelectionFrame.Size = UDim2.new(1, -30, 0, 200)
    SelectionFrame.BackgroundColor3 = Config.Colors.Secondary
    SelectionFrame.BorderSizePixel = 0
    SelectionFrame.Parent = MainFrame
    local SFCorner = Instance.new("UICorner")
    SFCorner.CornerRadius = UDim.new(0, 10)
    SFCorner.Parent = SelectionFrame
    local PlayerScrollFrame = Instance.new("ScrollingFrame")
    PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
    PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
    PlayerScrollFrame.BackgroundTransparency = 1
    PlayerScrollFrame.BorderSizePixel = 0
    PlayerScrollFrame.ScrollBarThickness = 3
    PlayerScrollFrame.ScrollBarImageColor3 = Config.Colors.Accent
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerScrollFrame.Parent = SelectionFrame
    local StartSelectedBtn = Instance.new("TextButton")
    StartSelectedBtn.Position = UDim2.new(0, 15, 0, 295)
    StartSelectedBtn.Size = UDim2.new(0.5, -10, 0, 45)
    StartSelectedBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
    StartSelectedBtn.BorderSizePixel = 0
    StartSelectedBtn.Text = "START SELECTED"
    StartSelectedBtn.TextColor3 = Config.Colors.Text
    StartSelectedBtn.Font = Config.Font
    StartSelectedBtn.TextSize = 13
    StartSelectedBtn.Parent = MainFrame
    local SSBCorner = Instance.new("UICorner")
    SSBCorner.CornerRadius = UDim.new(0, 10)
    SSBCorner.Parent = StartSelectedBtn
    local FlingAllBtn = Instance.new("TextButton")
    FlingAllBtn.Position = UDim2.new(0.5, 5, 0, 295)
    FlingAllBtn.Size = UDim2.new(0.5, -10, 0, 45)
    FlingAllBtn.BackgroundColor3 = Config.Colors.Accent
    FlingAllBtn.BorderSizePixel = 0
    FlingAllBtn.Text = "FLING ALL"
    FlingAllBtn.TextColor3 = Config.Colors.Text
    FlingAllBtn.Font = Config.Font
    FlingAllBtn.TextSize = 14
    FlingAllBtn.Parent = MainFrame
    local FABCorner = Instance.new("UICorner")
    FABCorner.CornerRadius = UDim.new(0, 10)
    FABCorner.Parent = FlingAllBtn
    local StopBtn = Instance.new("TextButton")
    StopBtn.Position = UDim2.new(0, 15, 0, 355)
    StopBtn.Size = UDim2.new(1, -30, 0, 45)
    StopBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
    StopBtn.BorderSizePixel = 0
    StopBtn.Text = "STOP OPERATION"
    StopBtn.TextColor3 = Config.Colors.Text
    StopBtn.Font = Config.Font
    StopBtn.TextSize = 15
    StopBtn.Parent = MainFrame
    local STBCorner = Instance.new("UICorner")
    STBCorner.CornerRadius = UDim.new(0, 10)
    STBCorner.Parent = StopBtn
    local function UpdateStatus()
        local count = 0
        for _ in pairs(SelectedFlingTargets) do count = count + 1 end
        if FlingLoopActive then
            StatusLabel.Text = "STATUS: OPERATION ACTIVE"
            StatusLabel.TextColor3 = Config.Colors.Accent
        else
            StatusLabel.Text = "SELECTED TARGETS: " .. count
            StatusLabel.TextColor3 = Config.Colors.TextDark
        end
    end
    local function RefreshPlayerList()
        for _, child in pairs(PlayerScrollFrame:GetChildren()) do child:Destroy() end
        local PlayerList = Players:GetPlayers()
        table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
        local yPosition = 5
        for _, player in ipairs(PlayerList) do
            if player ~= LocalPlayer then
                local PlayerEntry = Instance.new("Frame")
                PlayerEntry.Size = UDim2.new(1, -10, 0, 35)
                PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
                PlayerEntry.BackgroundColor3 = Config.Colors.Main
                PlayerEntry.BorderSizePixel = 0
                PlayerEntry.Parent = PlayerScrollFrame
                local PECorner = Instance.new("UICorner")
                PECorner.CornerRadius = UDim.new(0, 8)
                PECorner.Parent = PlayerEntry
                local PEStroke = Instance.new("UIStroke")
                PEStroke.Color = Config.Colors.Secondary
                PEStroke.Thickness = 1
                PEStroke.Parent = PlayerEntry
                local Checkbox = Instance.new("Frame")
                Checkbox.Size = UDim2.new(0, 20, 0, 20)
                Checkbox.Position = UDim2.new(0, 8, 0.5, -10)
                Checkbox.BackgroundColor3 = Config.Colors.Secondary
                Checkbox.BorderSizePixel = 0
                Checkbox.Parent = PlayerEntry
                local CBCorner = Instance.new("UICorner")
                CBCorner.CornerRadius = UDim.new(0, 5)
                CBCorner.Parent = Checkbox
                local Checkmark = Instance.new("TextLabel")
                Checkmark.Size = UDim2.new(1, 0, 1, 0)
                Checkmark.BackgroundTransparency = 1
                Checkmark.Text = "✓"
                Checkmark.TextColor3 = Config.Colors.Accent
                Checkmark.TextSize = 14
                Checkmark.Font = Config.Font
                Checkmark.Visible = SelectedFlingTargets[player.Name] ~= nil
                Checkmark.Parent = Checkbox
                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, -45, 1, 0)
                NameLabel.Position = UDim2.new(0, 35, 0, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = player.DisplayName
                NameLabel.TextColor3 = Config.Colors.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Config.Font
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.Parent = PlayerEntry
                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = 2
                ClickArea.Parent = PlayerEntry
                ClickArea.MouseButton1Click:Connect(function()
                    if SelectedFlingTargets[player.Name] then
                        SelectedFlingTargets[player.Name] = nil
                        Checkmark.Visible = false
                        TweenService:Create(PEStroke, TweenInfo.new(0.2), {Color = Config.Colors.Secondary}):Play()
                    else
                        SelectedFlingTargets[player.Name] = player
                        Checkmark.Visible = true
                        TweenService:Create(PEStroke, TweenInfo.new(0.2), {Color = Config.Colors.Accent}):Play()
                    end
                    UpdateStatus()
                end)
                if SelectedFlingTargets[player.Name] then
                    PEStroke.Color = Config.Colors.Accent
                end
                yPosition = yPosition + 40
            end
        end
        PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
    end
    local function ExecutionLoop(targetList)
        if FlingLoopActive then return end
        FlingLoopActive = true
        UpdateStatus()
        task.spawn(function()
            while FlingLoopActive do
                local currentList = {}
                if targetList == "ALL" then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local isWhite = false
                            for _, n in pairs(Settings.WhitelistNames) do if p.Name == n then isWhite = true break end end
                            if not isWhite then table.insert(currentList, p) end
                        end
                    end
                else
                    for name, p in pairs(SelectedFlingTargets) do
                        if p and p.Parent then table.insert(currentList, p) end
                    end
                end
                if #currentList == 0 then break end
                for _, target in ipairs(currentList) do
                    if not FlingLoopActive then break end
                    SkidFling(target)
                    task.wait(0.05)
                end
                if targetList ~= "ALL" then break end
                task.wait(0.5)
            end
            FlingLoopActive = false
            UpdateStatus()
            ForceCameraReset()
        end)
    end
    StartSelectedBtn.MouseButton1Click:Connect(function() ExecutionLoop("SELECTED") end)
    FlingAllBtn.MouseButton1Click:Connect(function() ExecutionLoop("ALL") end)
    StopBtn.MouseButton1Click:Connect(function()
        FlingLoopActive = false
        UpdateStatus()
        ForceCameraReset()
    end)
    CloseButton.MouseButton1Click:Connect(function()
        FlingLoopActive = false
        ScreenGui:Destroy()
        DiabloFlingGUI = nil
        Settings.MultiFlingEnabled = false
        if UIElements.MultiFlingEnabled then UIElements.MultiFlingEnabled.Set(false) end
    end)
    RefreshPlayerList()
    UpdateStatus()
    Players.PlayerAdded:Connect(RefreshPlayerList)
    Players.PlayerRemoving:Connect(RefreshPlayerList)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
    MainFrame.BackgroundTransparency = 1
    Shadow.ImageTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -160, 0.5, -210), BackgroundTransparency = 0}):Play()
    TweenService:Create(Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0.5}):Play()
end
local function ToggleMultiFling(state)
    Settings.MultiFlingEnabled = state
    if state then
        CreateAdvancedFlingGUI()
    else
        if DiabloFlingGUI then DiabloFlingGUI:Destroy() DiabloFlingGUI = nil end
        FlingLoopActive = false
        ForceCameraReset()
    end
end
local function ToggleAntiTouch(state)
    Settings.AntiTouchEnabled = state
    if state then
        task.spawn(function()
            local function checkPart(part)
                if part:IsA("BasePart") then
                    local isKillPart = false
                    local name = part.Name:lower()
                    local keywords = {"lava", "kill", "deadly", "death", "spike", "hurt", "damag", "trap", "void", "laser", "saw", "blade", "spin", "beam", "plasma", "toxic", "acid", "poison"}
                    for _, kw in pairs(keywords) do
                        if name:find(kw) then
                            isKillPart = true
                            break
                        end
                    end
                    if not isKillPart and part.Material == Enum.Material.Neon then
                        local r, g, b = part.Color.R, part.Color.G, part.Color.B
                        if (r > 0.7 and g < 0.4 and b < 0.4) or (r > 0.7 and g > 0.4 and b < 0.2) then
                            isKillPart = true
                        end
                    end
                    if isKillPart then
                        part.CanTouch = false
                        for _, child in pairs(part:GetChildren()) do
                            if child:IsA("TouchTransmitter") then
                                child:Destroy()
                            end
                        end
                        if not part:FindFirstChild("AntiTouchWatcher") then
                            local watcher = Instance.new("BoolValue")
                            watcher.Name = "AntiTouchWatcher"
                            watcher.Parent = part
                            part.ChildAdded:Connect(function(child)
                                if Settings.AntiTouchEnabled and child:IsA("TouchTransmitter") then
                                    task.wait()
                                    child:Destroy()
                                end
                            end)
                        end
                    end
                end
            end
            for _, v in pairs(workspace:GetDescendants()) do
                checkPart(v)
            end
            local connection
            connection = workspace.DescendantAdded:Connect(function(v)
                if not Settings.AntiTouchEnabled then
                    connection:Disconnect()
                    return
                end
                checkPart(v)
            end)
            while Settings.AntiTouchEnabled do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v:FindFirstChild("AntiTouchWatcher") then
                        v.CanTouch = false
                    else
                        checkPart(v)
                    end
                end
                task.wait(3)
            end
        end)
    end
end
local function createESP(player)
    if player == LocalPlayer then return end
    local function applyToCharacter(character)
        if not character then return end
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end
        if espConnections[player] then
            if espConnections[player].highlight then espConnections[player].highlight:Destroy() end
            if espConnections[player].billboard then espConnections[player].billboard:Destroy() end
            if espConnections[player].box then espConnections[player].box:Destroy() end
            if espConnections[player].health then espConnections[player].health:Destroy() end
            if espConnections[player].update then espConnections[player].update:Disconnect() end
        end
        local highlight = nil
        if Settings.ESPEnabled then
            highlight = Instance.new("Highlight")
            highlight.Name = "DiabloHighlight"
            highlight.Parent = character
            highlight.FillColor = Config.Colors.Accent
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
        end
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESPInfo"
        billboardGui.Parent = humanoidRootPart
        billboardGui.Size = UDim2.new(0, 120, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 8, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.ClipsDescendants = false
        local mainFrame = Instance.new("Frame")
        mainFrame.Parent = billboardGui
        mainFrame.Size = UDim2.new(1, 0, 0.6, 0)
        mainFrame.BackgroundTransparency = 1
        mainFrame.BorderSizePixel = 0
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = mainFrame
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name .. "-0"
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        local v2Extras = Instance.new("Frame")
        v2Extras.Name = "V2Extras"
        v2Extras.Parent = billboardGui
        v2Extras.Size = UDim2.new(1, 0, 1, 0)
        v2Extras.BackgroundTransparency = 1
        local function createCorner(parent, pos, size, color)
            local corner = Instance.new("Frame")
            corner.Parent = parent
            corner.Size = size
            corner.Position = pos
            corner.BackgroundColor3 = color
            corner.BorderSizePixel = 0
            return corner
        end
        local accentColor = Color3.fromRGB(255, 50, 255)
        createCorner(v2Extras, UDim2.new(0, -3, 0, -3), UDim2.new(0, 12, 0, 2), accentColor)
        createCorner(v2Extras, UDim2.new(0, -3, 0, -3), UDim2.new(0, 2, 0, 12), accentColor)
        createCorner(v2Extras, UDim2.new(1, -9, 0, -3), UDim2.new(0, 12, 0, 2), accentColor)
        createCorner(v2Extras, UDim2.new(1, 1, 0, -3), UDim2.new(0, 2, 0, 12), accentColor)
        local boxGui = Instance.new("BillboardGui")
        boxGui.Name = "ESPBox"
        boxGui.Parent = humanoidRootPart
        boxGui.Size = UDim2.new(6, 0, 8, 0)
        boxGui.AlwaysOnTop = true
        boxGui.ClipsDescendants = false
        local mainBox = Instance.new("Frame")
        mainBox.Parent = boxGui
        mainBox.Size = UDim2.new(1, 0, 1, 0)
        mainBox.BackgroundTransparency = 1
        mainBox.BorderSizePixel = 0
        mainBox.ClipsDescendants = false
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Parent = mainBox
        boxStroke.Color = Color3.fromRGB(0, 255, 255)
        boxStroke.Thickness = 1.5
        boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local healthGui = Instance.new("BillboardGui")
        healthGui.Name = "ESPHealth"
        healthGui.Parent = humanoidRootPart
        healthGui.Size = UDim2.new(1, 0, 8, 0)
        healthGui.StudsOffset = Vector3.new(-7, 0, 0)
        healthGui.AlwaysOnTop = true
        healthGui.ClipsDescendants = false
        local healthBarBG = Instance.new("Frame")
        healthBarBG.Name = "HealthBG"
        healthBarBG.Parent = healthGui
        healthBarBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        healthBarBG.BackgroundTransparency = 0.5
        healthBarBG.BorderSizePixel = 0
        healthBarBG.Size = UDim2.new(0.5, 0, 1, 0)
        healthBarBG.Position = UDim2.new(0.25, 0, 0, 0)
        local healthBarStroke = Instance.new("UIStroke")
        healthBarStroke.Parent = healthBarBG
        healthBarStroke.Color = Color3.fromRGB(0, 0, 0)
        healthBarStroke.Thickness = 1
        local healthBarFill = Instance.new("Frame")
        healthBarFill.Name = "Fill"
        healthBarFill.Parent = healthBarBG
        healthBarFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        healthBarFill.BorderSizePixel = 0
        healthBarFill.AnchorPoint = Vector2.new(0, 1)
        healthBarFill.Position = UDim2.new(0, 0, 1, 0)
        healthBarFill.Size = UDim2.new(1, 0, 1, 0)
        local updateConnection
        updateConnection = RunService.Heartbeat:Connect(function()
            if (not Settings.ESPEnabled and not Settings.ESPV2Enabled) or not player.Character or not LocalPlayer.Character then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            local isTeammate = Settings.ESPTeamCheck and player.Team == LocalPlayer.Team
            if isTeammate then
                billboardGui.Enabled = false
                boxGui.Enabled = false
                healthGui.Enabled = false
                if highlight then highlight.Enabled = false end
                return
            end
            local showV1 = Settings.ESPEnabled
            local showV2 = Settings.ESPV2Enabled
            billboardGui.Enabled = showV1 or showV2
            v2Extras.Visible = showV2
            boxGui.Enabled = showV2
            healthGui.Enabled = showV2
            if highlight then highlight.Enabled = showV1 end
            local char = player.Character
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerHRP = char:FindFirstChild("HumanoidRootPart")
            if hum then
                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                healthBarFill.Size = UDim2.new(1, 0, healthPercent, 0)
                healthBarFill.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1)
            end
            if localHRP and playerHRP then
                local distance = math.floor((localHRP.Position - playerHRP.Position).Magnitude)
                nameLabel.Text = player.Name .. "-" .. distance
                local isAlly = false
                for _, allyName in pairs(Settings.AllyNames) do
                    if player.Name == allyName then
                        isAlly = true
                        break
                    end
                end
                local statusColor = Color3.fromRGB(0, 255, 255)
                if not isAlly then
                    if distance < 300 then
                        statusColor = Color3.fromRGB(255, 50, 50)
                        local pulse = (math.sin(tick() * 10) + 1) / 2
                        boxStroke.Thickness = 1.5 + (pulse * 1.5)
                    elseif distance < 600 then
                        statusColor = Color3.fromRGB(255, 200, 50)
                        boxStroke.Thickness = 1.5
                    elseif distance < 1200 then
                        statusColor = Color3.fromRGB(0, 255, 255)
                        boxStroke.Thickness = 1.5
                    else
                        statusColor = Color3.fromRGB(150, 150, 150)
                        boxStroke.Thickness = 1
                    end
                else
                    statusColor = Color3.fromRGB(0, 255, 100)
                    boxStroke.Thickness = 1.5
                end
                boxStroke.Color = statusColor
                nameLabel.TextColor3 = statusColor
            end
        end)
        if not espConnections[player] then espConnections[player] = {} end
        espConnections[player].highlight = highlight
        espConnections[player].billboard = billboardGui
        espConnections[player].box = boxGui
        espConnections[player].health = healthGui
        espConnections[player].update = updateConnection
    end
    if player.Character then
        task.spawn(function() applyToCharacter(player.Character) end)
    end
    local charConn = player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        applyToCharacter(char)
    end)
    if not espConnections[player] then espConnections[player] = {} end
    espConnections[player].charConn = charConn
end
local function enableESP()
    if not Settings.ESPEnabled and not Settings.ESPV2Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    if not espConnections.playerAdded then
        espConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
            createESP(player)
        end)
    end
    if not espConnections.playerRemoving then
        espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            if espConnections[player] then
                if espConnections[player].highlight then espConnections[player].highlight:Destroy() end
                if espConnections[player].billboard then espConnections[player].billboard:Destroy() end
                if espConnections[player].box then espConnections[player].box:Destroy() end
                if espConnections[player].health then espConnections[player].health:Destroy() end
                if espConnections[player].update then espConnections[player].update:Disconnect() end
                if espConnections[player].charConn then espConnections[player].charConn:Disconnect() end
                espConnections[player] = nil
            end
        end)
    end
end
local function disableESP()
    if espConnections.playerAdded then pcall(function() espConnections.playerAdded:Disconnect() end) espConnections.playerAdded = nil end
    if espConnections.playerRemoving then pcall(function() espConnections.playerRemoving:Disconnect() end) espConnections.playerRemoving = nil end
    for player, data in pairs(espConnections) do
        if type(data) == "table" then
            if data.highlight then pcall(function() data.highlight:Destroy() end) end
            if data.billboard then pcall(function() data.billboard:Destroy() end) end
            if data.box then pcall(function() data.box:Destroy() end) end
            if data.health then pcall(function() data.health:Destroy() end) end
            if data.update then pcall(function() data.update:Disconnect() end) end
            if data.charConn then pcall(function() data.charConn:Disconnect() end) end
        end
    end
end
local function SetFullbright(enable)
    Settings.FullbrightEnabled = enable
    if enable then
        if FullbrightConnection then FullbrightConnection:Disconnect() end
        FullbrightConnection = RunService.Heartbeat:Connect(function()
            if not Settings.FullbrightEnabled then
                if FullbrightConnection then FullbrightConnection:Disconnect() end
                FullbrightConnection = nil
                return
            end
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
            Lighting.ExposureCompensation = 0
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then
                atmosphere.Density = 0
                atmosphere.Offset = 0
                atmosphere.Haze = 0
                atmosphere.Glare = 0
            end
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                    effect.Enabled = false
                end
            end
        end)
    else
        if FullbrightConnection then
            FullbrightConnection:Disconnect()
            FullbrightConnection = nil
        end
        RestoreOriginalLighting()
    end
end
local function SetupTPWalk()
    if Settings.TPWalkEnabled then
        if TPWalkConnection then TPWalkConnection:Disconnect() end
        TPWalkConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                local moveDirection = character.Humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + (moveDirection * Settings.TPWalkSpeed / 10)
                end
            end
        end)
    else
        if TPWalkConnection then
            TPWalkConnection:Disconnect()
            TPWalkConnection = nil
        end
    end
end
local function SetupNoClip()
    if Settings.NoClipEnabled then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
    end
end
local AntiScreenShakeConnection = nil
local function ToggleAntiScreenShake(state)
    Settings.AntiScreenShakeEnabled = state
    if state then
        if AntiScreenShakeConnection then AntiScreenShakeConnection:Disconnect() end
        AntiScreenShakeConnection = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
        end)
    else
        if AntiScreenShakeConnection then
            AntiScreenShakeConnection:Disconnect()
            AntiScreenShakeConnection = nil
        end
    end
end
local function SetupInfiniteJump()
    if Settings.InfiniteJumpEnabled then
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfiniteJumpConnection then
            InfiniteJumpConnection:Disconnect()
            InfiniteJumpConnection = nil
        end
    end
end
local function SpectatePlayer(targetName)
    if not targetName or targetName == "None" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        return
    end
    local target = nil
    for _, v in pairs(Players:GetPlayers()) do
        local isWhitelisted = false
        for _, name in pairs(Settings.WhitelistNames) do
            if v.Name == name then isWhitelisted = true break end
        end
        if v.Name:lower():sub(1, #targetName) == targetName:lower() and not isWhitelisted then
            target = v
            break
        end
    end
    if target then
        if target.Character and target.Character:FindFirstChild("Humanoid") then
             workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Spectate",
                Text = "Player character not found",
                Duration = 3
            })
        end
    end
end
local function GetTargetPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Tool") or obj:IsA("Accessory") then
        local primary = (obj:IsA("Model") and obj.PrimaryPart) or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
        if primary then return primary end
        for _, v in pairs(obj:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency < 0.95 then
                return v
            end
        end
    end
    return nil
end
local function ShouldIgnoreObject(obj, searchTerm)
    local objName = obj.Name:lower()
    local loweredSearch = searchTerm:lower()
    if obj:IsA("SpawnLocation") then return true end
    local spawnTerms = {"spawn", "point", "location", "area", "pos", "node", "pivot", "marker", "center", "origin"}
    local isSpawnRelated = false
    for _, term in pairs(spawnTerms) do
        if objName:find(term) then
            isSpawnRelated = true
            break
        end
    end
    if isSpawnRelated then
        local searchHasSpawn = false
        for _, term in pairs(spawnTerms) do
            if loweredSearch:find(term) then
                searchHasSpawn = true
                break
            end
        end
        if not searchHasSpawn then return true end
    end
    if obj.Parent and obj.Parent.Name:lower():find("spawn") and not loweredSearch:find("spawn") then
        return true
    end
    return false
end
local function IsObjectValid(obj)
    if not obj or not obj.Parent then return false end
    local isPlayer = Players:GetPlayerFromCharacter(obj) or (obj.Parent and Players:GetPlayerFromCharacter(obj.Parent))
    if not isPlayer and not obj:IsDescendantOf(workspace) then return false end
    local blacklistedParents = {"trash", "collected", "hidden", "removed", "bin"}
    local pName = obj.Parent and obj.Parent.Name:lower() or ""
    for _, name in pairs(blacklistedParents) do
        if pName:find(name) then return false end
    end
    local target = GetTargetPart(obj)
    if target and target:IsA("BasePart") then
        if not isPlayer and target.Transparency > 0.95 then return false end
        return true
    end
    return isPlayer ~= nil
end
local function ToggleUniversalESP(state)
    Settings.UniversalESPEnabled = state
    UniversalESPSession = UniversalESPSession + 1
    local currentSession = UniversalESPSession
    if UniversalESPFolder then UniversalESPFolder:Destroy() end
    if not state then
        if UniversalESPConnection then UniversalESPConnection:Disconnect() end
        UniversalESPConnection = nil
        return
    end
    UniversalESPFolder = Instance.new("Folder")
    UniversalESPFolder.Name = "UniversalESP"
    UniversalESPFolder.Parent = CoreGui
    local foundCount = 0
    UniversalTargets = {}
    local function updateCount()
        if ESPCountLabel then
            ESPCountLabel.Set("Found: " .. foundCount .. " objects")
        end
    end
    local function Draw(obj)
        if (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Tool") or obj:IsA("Accessory")) then
            local searchTerm = Settings.UniversalESPName:lower()
            local objName = obj.Name:lower()
            local displayName = ""
            if obj:IsA("Model") then
                local p = Players:GetPlayerFromCharacter(obj)
                if p then displayName = p.DisplayName:lower() end
            end
            if (searchTerm ~= "" and (objName:find(searchTerm, 1, true) or displayName:find(searchTerm, 1, true))) then
                if ShouldIgnoreObject(obj, searchTerm) then return end
                table.insert(UniversalTargets, obj)
                foundCount = foundCount + 1
                updateCount()
                task.spawn(function()
                    local highlight = nil
                    local bg = nil
                    local box = nil
                    while IsObjectValid(obj) and currentSession == UniversalESPSession do
                        local targetPart = GetTargetPart(obj)
                        if not targetPart then break end
                        local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude) or 0
                        local inRange = dist <= Settings.UniversalESPDistance
                        local isPlayerChar = Players:GetPlayerFromCharacter(obj) ~= nil

                        if inRange then
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Adornee = obj
                                highlight.FillColor = Settings.UniversalESPColor
                                highlight.FillTransparency = 0.4
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent = UniversalESPFolder
                            end
                            if isPlayerChar and not box then
                                box = Instance.new("SelectionBox")
                                box.Adornee = obj
                                box.Color3 = Settings.UniversalESPColor
                                box.LineThickness = 0.05
                                box.Transparency = 0
                                box.Parent = UniversalESPFolder
                            end
                        else
                            if highlight then highlight:Destroy(); highlight = nil end
                            if box then box:Destroy(); box = nil end
                        end
                        if inRange and Settings.UniversalESPLabels then
                            if not bg then
                                bg = Instance.new("BillboardGui")
                                bg.Adornee = targetPart
                                bg.Size = UDim2.new(0, 100, 0, 40)
                                bg.StudsOffset = Vector3.new(0, 2, 0)
                                bg.AlwaysOnTop = true
                                bg.Parent = UniversalESPFolder
                                local tl = Instance.new("TextLabel")
                                tl.Name = "Label"
                                tl.BackgroundTransparency = 1
                                tl.Size = UDim2.new(1, 0, 1, 0)
                                tl.Font = Config.Font
                                tl.TextColor3 = Settings.UniversalESPColor
                                tl.TextStrokeTransparency = 0
                                tl.TextSize = 14
                                tl.Parent = bg
                            end
                            local tl = bg:FindFirstChild("Label")
                            if tl then tl.Text = string.format("%s\n[%d m]", obj.Name, math.floor(dist)) end
                        else
                            if bg then bg:Destroy(); bg = nil end
                        end
                        task.wait(1)
                    end
                    for i, v in ipairs(UniversalTargets) do
                        if v == obj then
                            table.remove(UniversalTargets, i)
                            foundCount = foundCount - 1
                            updateCount()
                            break
                        end
                    end
                    if highlight then highlight:Destroy() end
                    if bg then bg:Destroy() end
                end)
            end
        end
    end
    task.spawn(function()
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if currentSession ~= UniversalESPSession then return end
            if p.Character then Draw(p.Character) end
        end
        for _, v in pairs(workspace:GetDescendants()) do
            if currentSession ~= UniversalESPSession then return end
            Draw(v)
            count = count + 1
            if count % 250 == 0 then RunService.Heartbeat:Wait() end
        end
    end)
    if UniversalESPConnection then UniversalESPConnection:Disconnect() end
    UniversalESPConnection = workspace.DescendantAdded:Connect(function(obj)
        if currentSession == UniversalESPSession then
            Draw(obj)
        end
    end)
end
local function StartAutoFarm()
    local trackingConnection = nil
    local currentTarget = nil
    local function stopTracking()
        if trackingConnection then
            trackingConnection:Disconnect()
            trackingConnection = nil
        end
        currentTarget = nil
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp then hrp.Anchored = false end
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end

    task.spawn(function()
        while Settings.AutoFarmEnabled do
            local objects = {}
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5); continue end
            if Settings.AutoFarmTargetMode == "Players" then
                local targetedName = Settings.UniversalESPName:lower()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local targetPart = GetTargetPart(p.Character)
                        if targetPart then
                            local dist = (hrp.Position - targetPart.Position).Magnitude
                            if dist <= Settings.UniversalESPDistance then
                                local isWhitelisted = false
                                for _, name in pairs(Settings.WhitelistNames) do
                                    if p.Name == name then isWhitelisted = true break end
                                end
                                if not isWhitelisted then
                                    if targetedName == "" or p.Name:lower():find(targetedName, 1, true) or p.DisplayName:lower():find(targetedName, 1, true) then
                                        table.insert(objects, p.Character)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                if not Settings.UniversalESPEnabled then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Auto Farm",
                        Text = "Please enable ESP (X-Ray) for smooth Object Farm! 🔎",
                        Duration = 3
                    })
                    task.wait(2)
                    continue
                end
                for _, v in ipairs(UniversalTargets) do
                    if IsObjectValid(v) then
                        local targetPart = GetTargetPart(v)
                        if targetPart then
                            local dist = (hrp.Position - targetPart.Position).Magnitude
                            if dist <= Settings.UniversalESPDistance then
                                table.insert(objects, v)
                            end
                        end
                    end
                end
            end

            if #objects > 0 then
                table.sort(objects, function(a, b)
                    local aPos = GetTargetPart(a).Position
                    local bPos = GetTargetPart(b).Position
                    return (hrp.Position - aPos).Magnitude < (hrp.Position - bPos).Magnitude
                end)

                for _, target in ipairs(objects) do
                    if not Settings.AutoFarmEnabled then break end
                    currentTarget = target
                    if not trackingConnection then
                        trackingConnection = RunService.Heartbeat:Connect(function()
                            if not Settings.AutoFarmEnabled or not currentTarget or not IsObjectValid(currentTarget) then
                                stopTracking()
                                return
                            end
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local targetPart = GetTargetPart(currentTarget)
                            if hrp and targetPart then
                                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
                                if Settings.AutoFarmTargetMode == "Players" then
                                    local lookDownCFrame = targetPart.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                    hrp.CFrame = lookDownCFrame
                                else
                                    local offset = currentTarget:IsA("Model") and Vector3.new(0, -1, 0) or Vector3.new(0, 0, 0)
                                    hrp.CFrame = targetPart.CFrame + offset
                                end
                                hrp.Anchored = true
                                if hum then
                                    hum.PlatformStand = true
                                    if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                                        hum:ChangeState(Enum.HumanoidStateType.Physics)
                                    end
                                end
                            end
                        end)
                    end

                    local startTime = tick()
                    local delay = math.max(0.01, Settings.AutoFarmDelay)
                    while Settings.AutoFarmEnabled and currentTarget == target and IsObjectValid(target) and (tick() - startTime) < delay do
                        if Settings.AutoFarmInteract then
                            local targetPart = GetTargetPart(target)
                            if targetPart then
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, targetPart, 0)
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, targetPart, 1)
                                if Settings.AutoFarmTargetMode == "Players" then
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    task.wait(0.01)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                end

                                for _, prompt in pairs(target:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                    if not Settings.AutoFarmEnabled then break end
                end
            else
                stopTracking()
                task.wait(0.5)
            end
        end
        stopTracking()
    end)
end
local function TeleportNextObject()
    if Settings.AutoFarmTargetMode == "Objects" and Settings.UniversalESPName == "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hack Tools",
            Text = "Please enter an object name first!",
            Duration = 3
        })
        return
    end
    local searchTerm = Settings.UniversalESPName:lower()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if #SequentialTPQueue == 0 or LastSequentialSearch ~= (Settings.AutoFarmTargetMode .. ":" .. searchTerm) then
        SequentialTPQueue = {}
        SequentialTPIndex = 0
        LastSequentialSearch = (Settings.AutoFarmTargetMode .. ":" .. searchTerm)
        if Settings.AutoFarmTargetMode == "Players" then
            local targetedName = Settings.UniversalESPName:lower()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local targetPart = GetTargetPart(p.Character)
                    if targetPart then
                        local dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist <= Settings.UniversalESPDistance then
                            local isWhitelisted = false
                            for _, name in pairs(Settings.WhitelistNames) do
                                if p.Name == name then isWhitelisted = true break end
                            end
                            if not isWhitelisted then
                                if targetedName == "" or p.Name:lower():find(targetedName, 1, true) or p.DisplayName:lower():find(targetedName, 1, true) then
                                    table.insert(SequentialTPQueue, p.Character)
                                end
                            end
                        end
                    end
                end
            end
        else
            local count = 0
            for _, v in pairs(workspace:GetDescendants()) do
                local objName = v.Name:lower()
                if (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Tool") or v:IsA("Accessory")) and objName:find(searchTerm, 1, true) then
                    local targetPart = GetTargetPart(v)
                    if targetPart then
                        local dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist <= Settings.UniversalESPDistance then
                            if not ShouldIgnoreObject(v, searchTerm) then
                                table.insert(SequentialTPQueue, v)
                            end
                        end
                    end
                end
                count = count + 1
                if count % 250 == 0 then task.wait() end
            end
        end
    end
    if #SequentialTPQueue > 0 then
        SequentialTPIndex = SequentialTPIndex + 1
        if SequentialTPIndex > #SequentialTPQueue then
            SequentialTPIndex = 1
        end
        local targetResource = SequentialTPQueue[SequentialTPIndex]
        if IsObjectValid(targetResource) then
            local targetPosPart = GetTargetPart(targetResource)
            if targetPosPart then
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
                local isPlayerChar = Players:GetPlayerFromCharacter(targetResource)
                if isPlayerChar then
                    local lookDownCFrame = targetPosPart.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    hrp.CFrame = lookDownCFrame
                else
                    local offset = targetResource:IsA("Model") and Vector3.new(0, -1, 0) or Vector3.new(0, 0, 0)
                    hrp.CFrame = targetPosPart.CFrame + offset
                end
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand = true
                        hum:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                    hrp.Anchored = true
                    task.delay(0.2, function()
                        if hrp and hrp.Parent then hrp.Anchored = false end
                        if hum and hum.Parent then
                            hum.PlatformStand = false
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end)
            else
                table.remove(SequentialTPQueue, SequentialTPIndex)
                SequentialTPIndex = SequentialTPIndex - 1
            end
        else
            table.remove(SequentialTPQueue, SequentialTPIndex)
            SequentialTPIndex = SequentialTPIndex - 1
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hack Tools",
            Text = "No object found!",
            Duration = 3
        })
    end
end
local function ToggleZoomUnlocker(state)
    Settings.ZoomUnlockerEnabled = state
    if state then
        LocalPlayer.CameraMaxZoomDistance = Settings.MaxZoomDistance
    else
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end
local function SaveConfig(silent)
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
    local ConfigData = {}
    for key, value in pairs(Settings) do
        if typeof(value) == "EnumItem" then
            ConfigData[key] = {Type = "Enum", Value = value.Name, EnumType = tostring(value.EnumType)}
        elseif typeof(value) == "Color3" then
            ConfigData[key] = {Type = "Color3", r = value.r, g = value.g, b = value.b}
        else
            ConfigData[key] = value
        end
    end
    writefile(FolderName .. "/" .. ConfigName, HttpService:JSONEncode(ConfigData))
    if not silent then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Hub",
            Text = "Config Saved successfully! 💾",
            Duration = 3
        })
    end
end
local function LoadConfig()
    if isfile(FolderName .. "/" .. ConfigName) then
        local raw = readfile(FolderName .. "/" .. ConfigName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if success and type(decoded) == "table" then
            for key, data in pairs(decoded) do
                if type(data) == "table" and data.Type == "Enum" then
                    pcall(function()
                        local enumGroup = data.EnumType:gsub("Enum.", "")
                        Settings[key] = Enum[enumGroup][data.Value]
                    end)
                elseif type(data) == "table" and data.Type == "Color3" then
                    Settings[key] = Color3.new(data.r, data.g, data.b)
                elseif type(data) == "string" and (key == "ToggleUIKey" or key == "AimbotKey") then
                    pcall(function()
                        if pcall(function() return Enum.KeyCode[data] end) then
                            Settings[key] = Enum.KeyCode[data]
                        elseif pcall(function() return Enum.UserInputType[data] end) then
                            Settings[key] = Enum.UserInputType[data]
                        end
                    end)
                else
                    Settings[key] = data
                end
            end
            for key, element in pairs(UIElements) do
                if Settings[key] ~= nil and element and type(element) == "table" and element.Set then
                    element.Set(Settings[key])
                end
            end
            task.spawn(function()
                SetFullbright(Settings.FullbrightEnabled); task.wait(0.05)
                SetupNoClip(); task.wait(0.05)
                SetupInfiniteJump(); task.wait(0.05)
                ToggleAntiAFK(Settings.AntiAFKEnabled); task.wait(0.05)
                SetupTPWalk(); task.wait(0.05)
                if Settings.ESPEnabled or Settings.ESPV2Enabled then enableESP() else disableESP() end; task.wait(0.05)
                ToggleUniversalESP(Settings.UniversalESPEnabled); task.wait(0.05)
                if Settings.AutoFarmEnabled then StartAutoFarm() end; task.wait(0.05)
                ToggleFly(Settings.FlyEnabled); task.wait(0.05)
                ToggleFling(Settings.TouchFlingEnabled); task.wait(0.05)
                ToggleAntiFling(Settings.AntiFlingEnabled); task.wait(0.05)
                ToggleInstantInteract(Settings.InstantInteractEnabled); task.wait(0.05)
                ToggleZoomUnlocker(Settings.ZoomUnlockerEnabled); task.wait(0.05)
                ToggleAntiTouch(Settings.AntiTouchEnabled); task.wait(0.05)
                ToggleAntiScreenShake(Settings.AntiScreenShakeEnabled); task.wait(0.05)
                if Settings.MapCleanerEnabled then ToggleMapCleaner(true) end; task.wait(0.05)
                if Settings.FPSBoosterEnabled then ToggleFPSBooster(true) end; task.wait(0.05)
                if Settings.RemoveBlurEnabled then ToggleRemoveBlur(true) end; task.wait(0.05)
                ToggleHitboxExpander(Settings.HitboxExpanderEnabled); task.wait(0.05)
                ToggleClickToFling(Settings.ClickToFlingEnabled); task.wait(0.05)
                ToggleSpinBot(Settings.SpinBotEnabled); task.wait(0.05)
                RadarFrame.Visible = Settings.RadarEnabled; task.wait(0.05)
                SetupAimbot()
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Diablo Hub",
                Text = "Config Loaded successfully! 📂",
                Duration = 3
            })
            return true
        end
    end
    return false
end
local Window = Library:CreateWindow({
    Name = "Diablo Hub"
})
local CombatTab = Window:Tab("Combat ⚔️")
local AimbotTab = Window:Tab("Aimbot 🎯")
local VisualsTab = Window:Tab("Visuals 👁️")
local MovementTab = Window:Tab("Movement ⚡")
CombatTab:Section("Hitbox Expander")
UIElements.HitboxExpanderEnabled = CombatTab:Toggle("Enable Expander 📦", Settings.HitboxExpanderEnabled, function(state)
    ToggleHitboxExpander(state)
    SaveConfig(true)
end)
UIElements.HitboxSize = CombatTab:NumberInput("Hitbox Size 📏", Settings.HitboxSize, function(val)
    Settings.HitboxSize = val
    SaveConfig(true)
end)
UIElements.HitboxTeamCheck = CombatTab:Toggle("Hitbox Team Check 🛡️", Settings.HitboxTeamCheck, function(state)
    Settings.HitboxTeamCheck = state
    SaveConfig(true)
end)
CombatTab:Dropdown("Ignore Player 🚫", {}, function(selected)
    local foundIdx = nil
    for i, name in ipairs(Settings.HitboxIgnoreList) do
        if name == selected then
            foundIdx = i
            break
        end
    end
    if foundIdx then
        table.remove(Settings.HitboxIgnoreList, foundIdx)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hitbox Expander",
            Text = selected .. " removed from ignore list.",
            Duration = 3
        })
    else
        table.insert(Settings.HitboxIgnoreList, selected)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hitbox Expander",
            Text = selected .. " added to ignore list.",
            Duration = 3
        })
    end
end)
CombatTab:Button("Clear Ignore List 🗑️", function()
    Settings.HitboxIgnoreList = {}
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hitbox Expander",
        Text = "Ignore list cleared!",
        Duration = 3
    })
end)
CombatTab:Section("Fling 🌪️")
UIElements.TouchFlingEnabled = CombatTab:Toggle("Touch Fling 💫", Settings.TouchFlingEnabled, function(state)
    ToggleFling(state)
    SaveConfig(true)
end)
UIElements.ClickToFlingEnabled = CombatTab:Toggle("Click-to-Fling 🎯", Settings.ClickToFlingEnabled, function(state)
    ToggleClickToFling(state)
    SaveConfig(true)
end)
UIElements.AntiFlingEnabled = CombatTab:Toggle("Anti-Fling 🛡️", Settings.AntiFlingEnabled, function(state)
    ToggleAntiFling(state)
    SaveConfig(true)
end)
CombatTab:Section("Multi Fling 🌪️🌪️")
UIElements.MultiFlingEnabled = CombatTab:Toggle("Multi-Fling (Intense Mode) 🌪️", Settings.MultiFlingEnabled, function(state)
    ToggleMultiFling(state)
    SaveConfig(true)
end)
AimbotTab:Section("Aimbot / Camlock 🎯")
AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotFOVCircle.Thickness = 1
AimbotFOVCircle.Filled = false
AimbotFOVCircle.Transparency = 1
AimbotFOVCircle.NumSides = 64
AimbotFOVCircle.Radius = Settings.AimbotFOV
AimbotFOVCircle.Visible = false
local function IsVisible(target, part, accurate)
    if not Settings.AimbotWallCheck then return true end
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local destination = part.Position
    local params = RaycastParams.new()
    local filter = {LocalPlayer.Character, camera}
    for _, item in pairs(target.Character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Tool") then table.insert(filter, item) end
    end
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    if accurate then
        local off = part.Size.Y * 0.3
        local checkPoints = {destination, destination + Vector3.new(0, off, 0), destination - Vector3.new(0, off, 0)}
        for _, point in ipairs(checkPoints) do
            local result = workspace:Raycast(origin, (point - origin), params)
            if not result or result.Instance.Transparency > 0.6 or result.Instance:IsDescendantOf(target.Character) then
                return true
            end
        end
    else
        local result = workspace:Raycast(origin, (destination - origin), params)
        if not result or result.Instance.Transparency > 0.6 or result.Instance:IsDescendantOf(target.Character) then
            return true
        end
    end
    return false
end
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = Settings.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.AimbotTeamCheck and player.Team == LocalPlayer.Team then continue end
            local isWhitelisted = false
            for _, name in pairs(Settings.WhitelistNames) do
                if player.Name == name then isWhitelisted = true break end
            end
            if isWhitelisted then continue end
            local selectionParts = {Settings.AimbotPart, "Head", "HumanoidRootPart", "UpperTorso"}
            for _, partName in ipairs(selectionParts) do
                local part = player.Character:FindFirstChild(partName, true)
                if part then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        local bias = (player == Target) and 0.7 or 1.0
                        local weightedDist = dist * bias
                        if weightedDist < shortestDist then
                            if IsVisible(player, part, false) then
                                shortestDist = weightedDist
                                closest = player
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end
local Target = nil
local LastTarget = nil
local TargetSwitchTick = 0
function SetupAimbot()
    AimbotConnection = RegisterConnection(RunService.RenderStepped:Connect(function()
        AimbotFOVCircle.Radius = Settings.AimbotFOV
        AimbotFOVCircle.Visible = Settings.AimbotShowFOV and Settings.AimbotEnabled
        AimbotFOVCircle.Position = UserInputService:GetMouseLocation()
        local isAiming = false
        if Settings.AimbotEnabled then
            if typeof(Settings.AimbotKey) == "EnumItem" then
                if Settings.AimbotKey.EnumType == Enum.UserInputType then
                    isAiming = UserInputService:IsMouseButtonPressed(Settings.AimbotKey)
                elseif Settings.AimbotKey.EnumType == Enum.KeyCode then
                    isAiming = UserInputService:IsKeyDown(Settings.AimbotKey)
                end
            end
        end
        if isAiming then
            local function GetBestPart(p)
                local primary = p.Character:FindFirstChild(Settings.AimbotPart, true)
                if primary and IsVisible(p, primary, true) then return primary end
                if Settings.AimbotAdaptiveAim then
                    local bestResult = nil
                    local bestPriority = -1
                    local priorityMap = {["Head"]=10, ["UpperTorso"]=8, ["Torso"]=8, ["LowerTorso"]=7, ["HumanoidRootPart"]=6}
                    for _, obj in pairs(p.Character:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Transparency < 0.9 then
                            if IsVisible(p, obj, true) then
                                local priority = priorityMap[obj.Name] or 0
                                if priority > bestPriority then
                                    bestPriority = priority
                                    bestResult = obj
                                    if priority == 10 then break end
                                end
                            end
                        end
                    end
                    return bestResult
                else
                    local cores = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
                    for _, name in ipairs(cores) do
                        local obj = p.Character:FindFirstChild(name, true)
                        if obj and IsVisible(p, obj, false) then return obj end
                    end
                end
                return nil
            end
            local oldTarget = Target
            if not Target or not Target.Character or not Target.Character:FindFirstChild("Humanoid") or Target.Character.Humanoid.Health <= 0 then
                Target = GetClosestPlayer()
            else
                local bestPart = GetBestPart(Target)
                local mousePos = UserInputService:GetMouseLocation()
                local inFOV = false
                if bestPart then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(bestPart.Position)
                    if onScreen and (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude <= Settings.AimbotFOV then
                        inFOV = true
                    end
                end
                if not inFOV then
                    Target = GetClosestPlayer()
                end
            end
            if oldTarget ~= Target then
                LastTarget = oldTarget
                TargetSwitchTick = tick()
            end
            if Target and Target.Character then
                local targetPart = GetBestPart(Target)
                if targetPart then
                    local targetPos = targetPart.Position
                    if Settings.ResolverEnabled then
                        local velocity = targetPart.Velocity
                        if velocity.Magnitude > 50 or math.abs(targetPart.RotVelocity.Y) > 10 then
                            targetPos = Target.Character.HumanoidRootPart.Position
                        end
                    end
                    if Settings.AimbotPrediction then
                        local distance = (workspace.CurrentCamera.CFrame.Position - targetPos).Magnitude
                        local velocity = targetPart.Velocity
                        local predictionStrength = (distance / 1000) * (1 + (distance / 500))
                        targetPos = targetPos + (velocity * predictionStrength)
                    end
                    local currentCFrame = workspace.CurrentCamera.CFrame
                    local goalCFrame = CFrame.new(currentCFrame.Position, targetPos)
                    local magnetism = math.clamp(Settings.AimbotSmoothness, 0.01, 100)
                    if magnetism >= 95 then
                        workspace.CurrentCamera.CFrame = goalCFrame
                    else
                        local strength = magnetism / 100
                        local timeSinceSwitch = tick() - TargetSwitchTick
                        local alpha = strength ^ 2
                        if timeSinceSwitch < 0.2 then
                            local flickEased = math.sin((timeSinceSwitch / 0.2) * math.pi / 2)
                            alpha = alpha * flickEased
                        end
                        workspace.CurrentCamera.CFrame = currentCFrame:Lerp(goalCFrame, math.clamp(alpha, 0.01, 1))
                    end
                    if Settings.AutoTriggerSyncEnabled then
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                        local mousePos = UserInputService:GetMouseLocation()
                        if onScreen and (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude < 3 then
                            mouse1click()
                        end
                    end
                end
            end
        else
            Target = nil
            LastTarget = nil
        end
    end))
end
SetupAimbot()
UIElements.AimbotEnabled = AimbotTab:Toggle("Enable Aimbot 🎯", Settings.AimbotEnabled, function(state)
    Settings.AimbotEnabled = state
    SaveConfig(true)
end)
UIElements.AimbotKey = AimbotTab:Keybind("Lock Key 🔒", Settings.AimbotKey, function(key)
    Settings.AimbotKey = key
    SaveConfig(true)
end)
UIElements.AimbotPart = AimbotTab:Dropdown("Aim Part 🎯", {"Head", "HumanoidRootPart"}, function(selected)
    Settings.AimbotPart = selected
    SaveConfig(true)
end)
UIElements.AimbotFOV = AimbotTab:NumberInput("FOV Radius ⭕", Settings.AimbotFOV, function(val)
    Settings.AimbotFOV = val
    SaveConfig(true)
end)
UIElements.AimbotSmoothness = AimbotTab:NumberInput("Lock Magnetism (0-100) 🧲", Settings.AimbotSmoothness, function(val)
    Settings.AimbotSmoothness = math.clamp(val, 0.01, 100)
    SaveConfig(true)
end)
UIElements.AimbotTeamCheck = AimbotTab:Toggle("Team Check 🛡️", Settings.AimbotTeamCheck, function(state)
    Settings.AimbotTeamCheck = state
    SaveConfig(true)
end)
UIElements.AimbotWallCheck = AimbotTab:Toggle("Wall Check 🧱", Settings.AimbotWallCheck, function(state)
    Settings.AimbotWallCheck = state
end)
UIElements.AimbotShowFOV = AimbotTab:Toggle("Show FOV Circle ⭕", Settings.AimbotShowFOV, function(state)
    Settings.AimbotShowFOV = state
end)
UIElements.AimbotPrediction = AimbotTab:Toggle("Enable Prediction 🔮", Settings.AimbotPrediction, function(state)
    Settings.AimbotPrediction = state
    SaveConfig(true)
end)
UIElements.AimbotSmartTarget = AimbotTab:Toggle("Smart Target 🎯", Settings.AimbotSmartTarget, function(state)
    Settings.AimbotSmartTarget = state
    SaveConfig(true)
end)
UIElements.AimbotAdaptiveAim = AimbotTab:Toggle("Adaptive Aim (All Body) 🤸‍♂️", Settings.AimbotAdaptiveAim, function(state)
    Settings.AimbotAdaptiveAim = state
    SaveConfig(true)
end)
UIElements.ResolverEnabled = AimbotTab:Toggle("HVH Resolver 🌀🛡️", Settings.ResolverEnabled, function(state)
    Settings.ResolverEnabled = state
    SaveConfig(true)
end)
UIElements.AutoTriggerSyncEnabled = AimbotTab:Toggle("Auto-Trigger Sync ⚡💥", Settings.AutoTriggerSyncEnabled, function(state)
    Settings.AutoTriggerSyncEnabled = state
    SaveConfig(true)
end)
AimbotTab:Section("TriggerBot 🔫")
local isV2Holding = false
local function TriggerBotV1Logic()
    if not Settings.TriggerBotV1Enabled then return end
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if target and target.Parent then
        local player = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
        if player and player ~= LocalPlayer then
            if Settings.TriggerBotTeamCheck and player.Team == LocalPlayer.Team then return end
            local isWhitelisted = false
            for _, name in pairs(Settings.WhitelistNames) do
                if player.Name == name then isWhitelisted = true break end
            end
            if isWhitelisted then return end
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                mouse1click()
            end
        end
    end
end
local function TriggerBotV2Logic()
    if not Settings.TriggerBotV2Enabled then
        if isV2Holding then mouse1release() isV2Holding = false end
        return
    end
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    local shouldHold = false
    if target and target.Parent then
        local player = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
        if player and player ~= LocalPlayer then
            if not (Settings.TriggerBotTeamCheck and player.Team == LocalPlayer.Team) then
                local isWhitelisted = false
                for _, name in pairs(Settings.WhitelistNames) do
                    if player.Name == name then isWhitelisted = true break end
                end
                if not isWhitelisted then
                    shouldHold = true
                end
            end
        end
    end
    if shouldHold then
        if not isV2Holding then
            mouse1press()
            isV2Holding = true
        end
    else
        if isV2Holding then
            mouse1release()
            isV2Holding = false
        end
    end
end
RunService.RenderStepped:Connect(function()
    if Settings.TriggerBotV1Enabled then
        TriggerBotV1Logic()
    end
    if Settings.TriggerBotV2Enabled then
        TriggerBotV2Logic()
    end
end)
UIElements.TriggerBotV1Enabled = AimbotTab:Toggle("TriggerBot V1 (Semi) 🔫", Settings.TriggerBotV1Enabled, function(state)
    Settings.TriggerBotV1Enabled = state
end)
UIElements.TriggerBotV2Enabled = AimbotTab:Toggle("TriggerBot V2 (Rage Mode) 💀🔥", Settings.TriggerBotV2Enabled, function(state)
    Settings.TriggerBotV2Enabled = state
end)
UIElements.TriggerBotTeamCheck = AimbotTab:Toggle("Team Check 🛡️", Settings.TriggerBotTeamCheck, function(state)
    Settings.TriggerBotTeamCheck = state
end)
AimbotTab:Section("Whitelist Management (Aimbot & TriggerBot) 🛡️")
AimbotTab:Dropdown("Add/Remove Player 👤", {}, function(selected)
    local foundIdx = nil
    for i, name in ipairs(Settings.WhitelistNames) do
        if name == selected then
            foundIdx = i
            break
        end
    end
    if foundIdx then
        table.remove(Settings.WhitelistNames, foundIdx)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Whitelist System",
            Text = selected .. " removed from Whitelist.",
            Duration = 3
        })
    else
        table.insert(Settings.WhitelistNames, selected)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Whitelist System",
            Text = selected .. " added to Whitelist.",
            Duration = 3
        })
    end
    SaveConfig(true)
end)
AimbotTab:Button("Clear Whitelist 🗑️", function()
    Settings.WhitelistNames = {}
    SaveConfig(true)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Whitelist System",
        Text = "Whitelist cleared!",
        Duration = 3
    })
end)
VisualsTab:Section("ESP System 👁️")
UIElements.ESPEnabled = VisualsTab:Toggle("ESP V1 (Highlight) 👁️", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if state then enableESP() else disableESP() end
    SaveConfig(true)
end)
UIElements.ESPV2Enabled = VisualsTab:Toggle("ESP V2 (Info) 🛰️", Settings.ESPV2Enabled, function(state)
    Settings.ESPV2Enabled = state
    if state then enableESP() else disableESP() end
    SaveConfig(true)
end)
UIElements.ESPTeamCheck = VisualsTab:Toggle("ESP Team Check 🛡️", Settings.ESPTeamCheck, function(state)
    Settings.ESPTeamCheck = state
    if Settings.ESPEnabled or Settings.ESPV2Enabled then
        disableESP()
        enableESP()
    end
    SaveConfig(true)
end)
VisualsTab:Section("Ally System 🤝")
VisualsTab:Dropdown("Ally Management 🛡️", {}, function(selected)
    local foundIdx = nil
    for i, name in ipairs(Settings.AllyNames) do
        if name == selected then
            foundIdx = i
            break
        end
    end
    if foundIdx then
        table.remove(Settings.AllyNames, foundIdx)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Ally System",
            Text = selected .. " removed from Allies.",
            Duration = 3
        })
    else
        table.insert(Settings.AllyNames, selected)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Ally System",
            Text = selected .. " added to Allies.",
            Duration = 3
        })
    end
end)
VisualsTab:Button("Clear Ally List 🗑️", function()
    Settings.AllyNames = {}
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ally System",
        Text = "Ally list cleared!",
        Duration = 3
    })
end)
UIElements.FullbrightEnabled = VisualsTab:Toggle("Fullbright ☀️", Settings.FullbrightEnabled, function(state)
    SetFullbright(state)
end)
VisualsTab:Button("Deep Map Clean 🧹", function()
    ToggleMapCleaner()
end)
VisualsTab:Section("Camera Controls 🎥")
UIElements.FreecamEnabled = VisualsTab:Toggle("Freecam 🚁", Settings.FreecamEnabled, function(state)
    ToggleFreecam(state)
end)
UIElements.FreecamSpeed = VisualsTab:NumberInput("Freecam Speed 🏎️", 1, function(value)
    Settings.FreecamSpeed = value
end)
VisualsTab:Dropdown("Spectate Player 📹", {}, function(selected)
    SpectatePlayer(selected)
end)
VisualsTab:Button("Reset Camera 🎥", function()
    SpectatePlayer("None")
end)
UIElements.AntiScreenShakeEnabled = VisualsTab:Toggle("Anti-Screen Shake 📸", Settings.AntiScreenShakeEnabled, function(state)
    ToggleAntiScreenShake(state)
end)
UIElements.ZoomUnlockerEnabled = VisualsTab:Toggle("Zoom Unlocker 🔭", Settings.ZoomUnlockerEnabled, function(state)
    ToggleZoomUnlocker(state)
end)
UIElements.MaxZoomDistance = VisualsTab:NumberInput("Max Zoom Distance", Settings.MaxZoomDistance, function(value)
    Settings.MaxZoomDistance = value
    if Settings.ZoomUnlockerEnabled then
        ToggleZoomUnlocker(true)
    end
end)
VisualsTab:Section("Radar System 📡")
RadarGUI = Instance.new("ScreenGui")
RadarGUI.Name = "DiabloRadar"
if syn and syn.protect_gui then syn.protect_gui(RadarGUI) end
RadarGUI.Parent = game:GetService("CoreGui")
RadarFrame = Instance.new("Frame")
RadarFrame.Name = "RadarFrame"
RadarFrame.Parent = RadarGUI
RadarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RadarFrame.BackgroundTransparency = 0.2
RadarFrame.BorderSizePixel = 0
RadarFrame.Position = UDim2.new(0, 20, 0, 20)
RadarFrame.Size = UDim2.new(0, Settings.RadarSize, 0, Settings.RadarSize)
RadarFrame.Visible = Settings.RadarEnabled
MakeDraggable(RadarFrame, RadarFrame)
local RadarCorner = Instance.new("UICorner")
RadarCorner.CornerRadius = UDim.new(0, 5)
RadarCorner.Parent = RadarFrame
local RadarStroke = Instance.new("UIStroke")
RadarStroke.Parent = RadarFrame
RadarStroke.Thickness = 2
RadarStroke.Color = Color3.fromRGB(255, 60, 60)
RadarStroke.Transparency = 0
local GridV = Instance.new("Frame")
GridV.Parent = RadarFrame
GridV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GridV.BackgroundTransparency = 0.8
GridV.Size = UDim2.new(0, 1, 1, 0)
GridV.Position = UDim2.new(0.5, 0, 0, 0)
GridV.BorderSizePixel = 0
local GridH = Instance.new("Frame")
GridH.Parent = RadarFrame
GridH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GridH.BackgroundTransparency = 0.8
GridH.Size = UDim2.new(1, 0, 0, 1)
GridH.Position = UDim2.new(0, 0, 0.5, 0)
GridH.BorderSizePixel = 0
local RadarCenter = Instance.new("Frame")
RadarCenter.Name = "Center"
RadarCenter.Parent = RadarFrame
RadarCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RadarCenter.Size = UDim2.new(0, 5, 0, 5)
RadarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
RadarCenter.BorderSizePixel = 0
RadarCenter.ZIndex = 3
local CenterCorner = Instance.new("UICorner")
CenterCorner.CornerRadius = UDim.new(1, 0)
CenterCorner.Parent = RadarCenter
local Blips = {}
local function UpdateRadar()
    RadarFrame.Visible = Settings.RadarEnabled
    RadarFrame.Size = UDim2.new(0, Settings.RadarSize, 0, Settings.RadarSize)
    if not Settings.RadarEnabled then return end
    local origin = workspace.CurrentCamera.CFrame
    local camPos = origin.Position
    local camRot = origin.LookVector
    for player, blip in pairs(Blips) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            blip:Destroy()
            Blips[player] = nil
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local isTeammate = (player.Team == LocalPlayer.Team)
            if Settings.RadarTeamCheck and isTeammate then
                if Blips[player] then Blips[player].Visible = false end
                continue
            end
            if not Blips[player] then
                local b = Instance.new("Frame")
                b.Parent = RadarFrame
                b.Size = UDim2.new(0, 6, 0, 6)
                b.BorderSizePixel = 0
                b.ZIndex = 2
                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(1, 0)
                bc.Parent = b
                local bs = Instance.new("UIStroke")
                bs.Parent = b
                bs.Thickness = 1
                bs.Color = Color3.fromRGB(0, 0, 0)
                bs.Transparency = 0.2
                Blips[player] = b
            end
            local blip = Blips[player]
            blip.BackgroundColor3 = isTeammate and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 40, 40)
            local targetPos = player.Character.HumanoidRootPart.Position
            local relativePos = targetPos - camPos
            local rx = relativePos:Dot(origin.RightVector)
            local ry = relativePos:Dot(origin.LookVector)
            local scale = Settings.RadarSize / 2
            local mapX = (rx / Settings.RadarRange) * scale
            local mapY = (-ry / Settings.RadarRange) * scale
            mapX = math.clamp(mapX, -scale + 2, scale - 2)
            mapY = math.clamp(mapY, -scale + 2, scale - 2)
            blip.Position = UDim2.new(0.5, mapX - 2, 0.5, mapY - 2)
            blip.Visible = true
        else
            if Blips[player] then Blips[player].Visible = false end
        end
    end
end
RadarConnection = RegisterConnection(RunService.RenderStepped:Connect(UpdateRadar))
UIElements.RadarEnabled = VisualsTab:Toggle("Enable Radar 📡", Settings.RadarEnabled, function(state)
    Settings.RadarEnabled = state
    RadarFrame.Visible = state
    SaveConfig(true)
end)
UIElements.RadarRange = VisualsTab:NumberInput("Radar Range (Zoom) 🔍", Settings.RadarRange, function(val)
    Settings.RadarRange = val
    SaveConfig(true)
end)
UIElements.RadarSize = VisualsTab:NumberInput("Radar UI Size 📏", Settings.RadarSize, function(val)
    Settings.RadarSize = val
    RadarFrame.Size = UDim2.new(0, val, 0, val)
    SaveConfig(true)
end)
UIElements.RadarTeamCheck = VisualsTab:Toggle("Team Check 🛡️", Settings.RadarTeamCheck, function(state)
    Settings.RadarTeamCheck = state
    SaveConfig(true)
end)
MovementTab:Section("Movement Tweaks ⚡")
UIElements.FlyEnabled = MovementTab:Toggle("Fly 🕊️", Settings.FlyEnabled, function(state)
    ToggleFly(state)
end)
UIElements.FlySpeed = MovementTab:NumberInput("Fly Speed 🚀", 1, function(value)
    Settings.FlySpeed = value
end)
UIElements.TPWalkEnabled = MovementTab:Toggle("TP Walk ⚡", Settings.TPWalkEnabled, function(state)
    Settings.TPWalkEnabled = state
    SetupTPWalk()
end)
UIElements.TPWalkSpeed = MovementTab:NumberInput("TP Speed 🎯", 1, function(value)
    Settings.TPWalkSpeed = value
end)
UIElements.WalkOnWaterEnabled = MovementTab:Toggle("Walk on Water 🌊", Settings.WalkOnWaterEnabled, function(state)
    ToggleWalkOnWater(state)
end)
UIElements.InfiniteJumpEnabled = MovementTab:Toggle("Infinite Jump 🦘", Settings.InfiniteJumpEnabled, function(state)
    Settings.InfiniteJumpEnabled = state
    SetupInfiniteJump()
end)
UIElements.NoClipEnabled = MovementTab:Toggle("NoClip 👻", Settings.NoClipEnabled, function(state)
    Settings.NoClipEnabled = state
    SetupNoClip()
end)
MovementTab:Dropdown("Teleport to Player 📍", {}, function(selected)
    local target = Players:FindFirstChild(selected)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)
UIElements.AutoRespawnTPEnabled = MovementTab:Toggle("Auto Tp Last Death ♻️", Settings.AutoRespawnTPEnabled, function(state)
    Settings.AutoRespawnTPEnabled = state
end)
MovementTab:Button("TP to Last Death 💀", function()
    TeleportToLastDeath()
end)
MovementTab:Section("Spin Bot 🌪️")
UIElements.SpinBotEnabled = MovementTab:Toggle("Enable Spin Bot 🌪️", Settings.SpinBotEnabled, function(state)
    ToggleSpinBot(state)
    SaveConfig(true)
end)
UIElements.SpinBotSpeed = MovementTab:NumberInput("Spin Speed 🚄", Settings.SpinBotSpeed, function(value)
    Settings.SpinBotSpeed = value
    SaveConfig(true)
end)
local WaypointTab = Window:Tab("Waypoints 📍")
WaypointTab:Section("Saved Locations 📜")
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "WPList"
if WaypointTab.Page then
    ListFrame.Parent = WaypointTab.Page
else
    warn("WaypointTab.Page is missing!")
end
ListFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
ListFrame.BackgroundTransparency = 0.5
ListFrame.Size = UDim2.new(1, 0, 0, 200)
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListFrame.ScrollBarThickness = 4
local LLC = Instance.new("UIListLayout")
LLC.Parent = ListFrame
LLC.Padding = UDim.new(0, 5)
local Pad = Instance.new("UIPadding")
Pad.Parent = ListFrame
Pad.PaddingTop = UDim.new(0,5)
Pad.PaddingLeft = UDim.new(0,5)
Pad.PaddingRight = UDim.new(0,5)
local function RefreshWPList()
    for _, v in pairs(ListFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    for i, wp in pairs(Settings.Waypoints) do
        local Item = Instance.new("Frame")
        Item.Parent = ListFrame
        Item.BackgroundColor3 = Config.Colors.Secondary
        Item.Size = UDim2.new(1, 0, 0, 35)
        local ICorner = Instance.new("UICorner")
        ICorner.CornerRadius = UDim.new(0, 6)
        ICorner.Parent = Item
        local WName = Instance.new("TextLabel")
        WName.Parent = Item
        WName.BackgroundTransparency = 1
        WName.Position = UDim2.new(0, 10, 0, 0)
        WName.Size = UDim2.new(0.6, 0, 1, 0)
        WName.Font = Config.Font
        WName.Text = wp.Name .. " (" .. wp.X .. "," .. wp.Y .. "," .. wp.Z .. ")"
        WName.TextColor3 = Config.Colors.Text
        WName.TextSize = 12
        WName.TextXAlignment = Enum.TextXAlignment.Left
        local TPBtn = Instance.new("TextButton")
        TPBtn.Parent = Item
        TPBtn.BackgroundColor3 = Config.Colors.Accent
        TPBtn.Position = UDim2.new(1, -70, 0.5, -12)
        TPBtn.Size = UDim2.new(0, 40, 0, 24)
        TPBtn.Text = "GO"
        TPBtn.TextColor3 = Color3.new(1,1,1)
        TPBtn.Font = Config.Font
        local TPCorner = Instance.new("UICorner"); TPCorner.CornerRadius=UDim.new(0,4); TPCorner.Parent = TPBtn
        TPBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(wp.X, wp.Y + 3, wp.Z)
            end
        end)
        local DelBtn = Instance.new("TextButton")
        DelBtn.Parent = Item
        DelBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        DelBtn.Position = UDim2.new(1, -25, 0.5, -12)
        DelBtn.Size = UDim2.new(0, 20, 0, 24)
        DelBtn.Text = "X"
        DelBtn.TextColor3 = Color3.new(1,1,1)
        DelBtn.Font = Config.Font
        local DCorner = Instance.new("UICorner"); DCorner.CornerRadius=UDim.new(0,4); DCorner.Parent = DelBtn
        DelBtn.MouseButton1Click:Connect(function()
            table.remove(Settings.Waypoints, i)
            SaveConfig(true)
            RefreshWPList()
        end)
    end
end
WaypointTab:Button("Refresh List (รีเฟรช) 🔄", function()
    RefreshWPList()
end)
WaypointTab:Section("Add New Location ➕")
local NewWPName = ""
WaypointTab:TextInput("Location Name (ชื่อสถานที่)", "Enter Name...", function(val)
    NewWPName = val
end)
WaypointTab:Button("Save Here (บันทึกตรงนี้) 💾", function()
    if NewWPName == "" then
        NewWPName = "Waypoint " .. (#Settings.Waypoints + 1)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        table.insert(Settings.Waypoints, {
            Name = NewWPName,
            X = math.floor(pos.X),
            Y = math.floor(pos.Y),
            Z = math.floor(pos.Z)
        })
        SaveConfig(true)
        RefreshWPList()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Waypoints", Text="Saved '"..NewWPName.."'! 💾", Duration=2})
    end
end)
WaypointTab:Section("My Coordinates 🧭")
local CoordsBtn = WaypointTab:Button("Finding Position...", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        setclipboard(string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z))
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Waypoints",
            Text = "Copied! 📋",
            Duration = 2
        })
    end
end)
task.spawn(function()
    while CoordsBtn and CoordsBtn.Parent do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            CoordsBtn.Text = string.format("X: %.0f, Y: %.0f, Z: %.0f (Tap to Copy)", pos.X, pos.Y, pos.Z)
        end
        task.wait(0.2)
    end
end)
WaypointTab:Section("Share / Import 📤")
local ImportBox = ""
WaypointTab:TextInput("Enter Code (ใส่โค้ดที่นี่)", "Paste Code...", function(val)
    ImportBox = val
end)
local B62Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local function toBase62(num)
    if num == 0 then return "0" end
    local sign = num < 0 and "-" or ""
    num = math.abs(num)
    local result = ""
    while num > 0 do
        local remainder = num % 62
        result = string.sub(B62Chars, remainder + 1, remainder + 1) .. result
        num = math.floor(num / 62)
    end
    return sign .. result
end
local function fromBase62(str)
    local sign = 1
    if string.sub(str, 1, 1) == "-" then
        sign = -1
        str = string.sub(str, 2)
    end
    local result = 0
    local len = #str
    for i = 1, len do
        local char = string.sub(str, i, i)
        local pos = string.find(B62Chars, char)
        if pos then
            result = result + (pos - 1) * (62 ^ (len - i))
        end
    end
    return result * sign
end
WaypointTab:Button("Load Code (โหลดข้อมูล) 📥", function()
    if ImportBox ~= "" then
        local isJson, decoded = pcall(function() return HttpService:JSONDecode(ImportBox) end)
        local waypointsToAdd = {}
        if isJson and type(decoded) == "table" then
            for _, wp in pairs(decoded) do
                local newWP = nil
                if type(wp) == "table" then
                     if wp[1] and type(wp[1]) == "string" then
                         newWP = {Name = wp[1], X = tonumber(wp[2]) or 0, Y = tonumber(wp[3]) or 0, Z = tonumber(wp[4]) or 0}
                     elseif wp.Name and wp.X then
                         newWP = wp
                     end
                end
                if newWP then table.insert(waypointsToAdd, newWP) end
            end
        else
            for wpStr in string.gmatch(ImportBox, "([^;]+)") do
                local bName, bX, bY, bZ = string.match(wpStr, "^(.*)|([-%w]+),([-%w]+),([-%w]+)$")
                if bName and bX and bY and bZ then
                    table.insert(waypointsToAdd, {
                        Name = bName,
                        X = fromBase62(bX),
                        Y = fromBase62(bY),
                        Z = fromBase62(bZ)
                    })
                else
                    local tName, tX, tY, tZ = string.match(wpStr, "^(.*):([-%d]+),([-%d]+),([-%d]+)$")
                    if tName and tX and tY and tZ then
                        table.insert(waypointsToAdd, {
                            Name = tName,
                            X = tonumber(tX),
                            Y = tonumber(tY),
                            Z = tonumber(tZ)
                        })
                    end
                end
            end
        end
        if #waypointsToAdd > 0 then
            for _, wp in pairs(waypointsToAdd) do
                table.insert(Settings.Waypoints, wp)
            end
            SaveConfig(true)
            RefreshWPList()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="GenCode", Text="Loaded "..#waypointsToAdd.." waypoints! ✅", Duration=3})
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="GenCode", Text="Invalid Code! ❌", Duration=3})
        end
    end
end)
WaypointTab:Button("Copy All (ก๊อปปี้ทั้งหมด) 📤", function()
    local parts = {}
    for _, wp in pairs(Settings.Waypoints) do
        local safeName = wp.Name:gsub(":", "-"):gsub(";", ","):gsub("|", "-")
        local bx = toBase62(math.floor(wp.X))
        local by = toBase62(math.floor(wp.Y))
        local bz = toBase62(math.floor(wp.Z))
        table.insert(parts, string.format("%s|%s,%s,%s", safeName, bx, by, bz))
    end
    local rawCode = table.concat(parts, ";")
    setclipboard(rawCode)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="GenCode", Text="Copied Max Compressed Code! 🚀", Duration=3})
end)
local HackToolsTab = Window:Tab("Hack Tools 🛠️")
ESPCountLabel = HackToolsTab:Label("Found: 0 objects")
HackToolsTab:Section("Universal ESP 👁️")
UIElements.UniversalESPName = HackToolsTab:TextInput("Target Name", "Ex: Coin, Key, Chest...", function(text)
    Settings.UniversalESPName = text
    SaveConfig(true)
    if Settings.UniversalESPEnabled then
        ToggleUniversalESP(false); task.wait(); ToggleUniversalESP(true)
    end
end)
HackToolsTab:Button("Refresh Search 🔄", function()
    SequentialTPQueue = {}
    SequentialTPIndex = 0
    LastSequentialSearch = ""
    if Settings.UniversalESPEnabled then
        ToggleUniversalESP(false); task.wait(); ToggleUniversalESP(true)
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hack Tools",
        Text = "Search & Queue Refreshed! 🔄",
        Duration = 2
    })
end)
UIElements.UniversalESPEnabled = HackToolsTab:Toggle("Enable X-Ray Vision 🔎", Settings.UniversalESPEnabled, function(state)
    Settings.UniversalESPLabels = state
    ToggleUniversalESP(state)
    SaveConfig(true)
end)
UIElements.UniversalESPDistance = HackToolsTab:Slider("Max Distance 📏", 50, 20000, Settings.UniversalESPDistance, function(val)
    Settings.UniversalESPDistance = val
    SaveConfig(true)
end)
HackToolsTab:Section("Auto Farming Engine ⚡")
UIElements.AutoFarmTargetMode = HackToolsTab:Dropdown("Target Type 🎯", {"Objects", "Players"}, function(selected)
    Settings.AutoFarmTargetMode = selected
    SaveConfig(true)
end)
UIElements.AutoFarmEnabled = HackToolsTab:Toggle("Auto-Teleport Loop 🚀", Settings.AutoFarmEnabled, function(state)
    Settings.AutoFarmEnabled = state
    if state then StartAutoFarm() end
    SaveConfig(true)
end)
UIElements.AutoFarmInteract = HackToolsTab:Toggle("Auto-Interact (Touch/Prompt) 👆", Settings.AutoFarmInteract, function(state)
    Settings.AutoFarmInteract = state
    SaveConfig(true)
end)
UIElements.AutoFarmDelay = HackToolsTab:NumberInput("Wait Delay (s) ⏱️", Settings.AutoFarmDelay, function(val)
    Settings.AutoFarmDelay = val
    SaveConfig(true)
end, 0.01)
HackToolsTab:Button("Teleport Once 📍", function()
    TeleportNextObject()
end)
local SettingsTab = Window:Tab("Settings ⚙️")
SettingsTab:Section("System & Optimization ⚙️")
UIElements.FPSBoosterEnabled = SettingsTab:Toggle("FPS Booster ⚡", Settings.FPSBoosterEnabled, function(state)
    ToggleFPSBooster(state)
    SaveConfig(true)
end)
UIElements.RemoveBlurEnabled = SettingsTab:Toggle("Remove Blur 👓", Settings.RemoveBlurEnabled, function(state)
    ToggleRemoveBlur(state)
    SaveConfig(true)
end)
UIElements.AntiAFKEnabled = SettingsTab:Toggle("Anti-AFK 💤", Settings.AntiAFKEnabled, function(state)
    ToggleAntiAFK(state)
    SaveConfig(true)
end)
UIElements.InstantInteractEnabled = SettingsTab:Toggle("Instant Interact 👆", Settings.InstantInteractEnabled, function(state)
    ToggleInstantInteract(state)
    SaveConfig(true)
end)
UIElements.AntiTouchEnabled = SettingsTab:Toggle("Anti-Touch 🚫", Settings.AntiTouchEnabled, function(state)
    ToggleAntiTouch(state)
    SaveConfig(true)
end)
SettingsTab:Button("Rejoin Server 🔄", function()
    RejoinServer()
end)
SettingsTab:Button("Server Hop", function()
    ServerHop()
end)
SettingsTab:Button("Small Server", function()
    FindSmallServer()
end)
SettingsTab:Section("External Scripts 📜")
SettingsTab:Button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)
SettingsTab:Button("DEX Explorer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)
SettingsTab:Button("Free GamePass", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sqweex-lua/Free-Product-Obfs/main/obfuscated.lua"))()
end)
SettingsTab:Section("Configuration 💾")
SettingsTab:Button("Save Config 💾", function()
    SaveConfig()
end)
SettingsTab:Button("Load Config 📂", function()
    LoadConfig()
end)
SettingsTab:Section("Keybinds ⌨️")
UIElements.ToggleUIKey = SettingsTab:Keybind("Toggle UI Key 🔓", Settings.ToggleUIKey, function(key)
    Settings.ToggleUIKey = key
    SaveConfig(true)
end)
task.spawn(function()
    while true do
        local names = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                table.insert(names, v.Name)
            end
        end
        task.wait(5)
    end
end)
SetupDeathRecall()
task.spawn(function()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    task.wait(1)
    if LoadConfig() then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Script",
            Text = "Settings Auto-Loaded! ⚡",
            Duration = 5
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Diablo Script",
            Text = "Welcome! (No Config Found)",
            Duration = 5
        })
    end
    SendWebhook()
end)
function Library:Unload()
    Running = false
    pcall(function() ToggleFly(false) end)
    pcall(function() ToggleSpinBot(false) end)
    pcall(function() ToggleFreecam(false) end)
    pcall(function() ToggleWalkOnWater(false) end)
    pcall(function() SetFullbright(false) end)
    pcall(function() ToggleHitboxExpander(false) end)
    pcall(function() ToggleFPSBooster(false) end)
    pcall(function() ToggleInstantInteract(false) end)
    pcall(function() ToggleAntiScreenShake(false) end)
    pcall(function() ToggleZoomUnlocker(false) end)
    pcall(function() ToggleRemoveBlur(false) end)
    pcall(function() ToggleAntiTouch(false) end)
    pcall(function() SpectatePlayer("None") end)
    pcall(function() ToggleUniversalESP(false) end)
    pcall(function() disableESP() end)
    local globals = {
        TPWalkConnection, NoClipConnection, AntiScreenShakeConnection,
        InfiniteJumpConnection, FreecamConnection, WaterConnection,
        RemoveBlurConnection, FPSBoosterConnection, HitboxConnection,
        InstantInteractConnection, ClickToFlingConnection, SpinBotConnection,
        RadarConnection, AimbotConnection, FullbrightConnection, UniversalESPConnection
    }
    for _, conn in pairs(globals) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    if type(espConnections) == "table" then
        for _, conn in pairs(espConnections) do
            if type(conn) == "table" then
                for _, sub in pairs(conn) do
                    pcall(function() sub:Disconnect() end)
                    pcall(function() sub:Destroy() end)
                end
            else
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    if type(PermanentConnections) == "table" then
        for _, conn in pairs(PermanentConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if AimbotFOVCircle then
        pcall(function() AimbotFOVCircle.Visible = false end)
        pcall(function() AimbotFOVCircle:Remove() end)
    end
    if ScreenGui then pcall(function() ScreenGui:Destroy() end) end
    if RadarGUI then pcall(function() RadarGUI:Destroy() end) end
    if UniversalESPFolder then pcall(function() UniversalESPFolder:Destroy() end) end
    for k, v in pairs(Settings) do
        if type(v) == "boolean" then Settings[k] = false end
    end
    print("Diablo Hub fully unloaded! 🧹🛡️")
end
return Library
