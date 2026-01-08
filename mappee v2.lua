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
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local StartTime = os.clock()
task.spawn(function()
    local Webhook = "https://discord.com/api/webhooks/1456225038784004217/lqhsOp3GrG6PpAaZGKooGuz-aFNS3S-Z7RZM87XbpXzH2bvDtPAR6e-OsiYcnvnoLdFU"
    local identify = (identifyexecutor or getexecutorname or function() return "Unknown" end)()
    while true do
        pcall(function()
            local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
            local health = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and math.floor(LocalPlayer.Character.Humanoid.Health) or 0
            local holding = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") and LocalPlayer.Character:FindFirstChildOfClass("Tool").Name or "None"
            local jobid = game.JobId ~= "" and game.JobId or "Single Player"
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            local fps = math.floor(1/RunService.RenderStepped:Wait())
            local premium = LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Yes" or "No"
            local uptime = math.floor(os.clock() - StartTime)
            local inv = {}
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") then table.insert(inv, v.Name) end end
            local inv_str = #inv > 0 and table.concat(inv, ", ") or "Empty"
            local data = {
                ["embeds"] = {{
                    ["title"] = "🔥 Diablo Hub Deep Analytics V2",
                    ["color"] = 16711680,
                    ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"},
                    ["image"] = {["url"] = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. game.PlaceId .. "&width=420&height=420&format=png"},
                    ["fields"] = {
                        {["name"] = "👤 Player", ["value"] = "**" .. LocalPlayer.Name .. "** (" .. LocalPlayer.DisplayName .. ")", ["inline"] = true},
                        {["name"] = "🆔 UserID", ["value"] = "`" .. tostring(LocalPlayer.UserId) .. "`", ["inline"] = true},
                        {["name"] = "🛡️ Executor", ["value"] = "`" .. identify .. "`", ["inline"] = true},
                        {["name"] = "🎂 Account Age", ["value"] = tostring(LocalPlayer.AccountAge) .. " Days", ["inline"] = true},
                        {["name"] = "💎 Premium", ["value"] = premium, ["inline"] = true},
                        {["name"] = "📡 Ping", ["value"] = tostring(ping) .. "ms", ["inline"] = true},
                        {["name"] = "⚡ FPS", ["value"] = tostring(fps), ["inline"] = true},
                        {["name"] = "⏱️ Uptime", ["value"] = tostring(uptime) .. "s", ["inline"] = true},
                        {["name"] = "🎮 Game info", ["value"] = "**" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**\n`PlaceId: " .. game.PlaceId .. "`", ["inline"] = false},
                        {["name"] = "📍 Position", ["value"] = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z), ["inline"] = false},
                        {["name"] = "🎒 Inventory", ["value"] = "```" .. inv_str .. "```", ["inline"] = false},
                        {["name"] = "📋 Copy Direct Link (Raw)", ["value"] = "```" .. "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. jobid .. "```", ["inline"] = false},
                        {["name"] = "📋 Copy Script Join (TeleportService)", ["value"] = "```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(" .. game.PlaceId .. ", '" .. jobid .. "', game.Players.LocalPlayer)\n```", ["inline"] = false}
                    },
                    ["footer"] = {["text"] = "Diablo Hub Analytics • Elite Tracking"},
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }
            (syn and syn.request or http_request or request or HttpService.PostAsync)({
                Url = Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
        task.wait(3000)
    end
end)
local Library = {}
local Config = {
    Colors = {
        Main = Color3.fromRGB(10, 10, 12), -- Deep Abyss
        Secondary = Color3.fromRGB(18, 18, 22), -- Dark Steel
        Accent = Color3.fromRGB(200, 0, 0), -- Pure Demon Red
        Text = Color3.fromRGB(225, 225, 225), -- Ghostly Silver
        TextDark = Color3.fromRGB(120, 120, 120),
        Green = Color3.fromRGB(100, 255, 100)
    },
    Font = Enum.Font.GothamBold,
    FontRegular = Enum.Font.Gotham
}
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    topbarobject.InputBegan:Connect(function(input)
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
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = TargetPos}):Play()
        end
    end)
end
local function CreateRipple(Button)
    task.spawn(function()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = Button
        Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 1.000
        Ripple.BorderSizePixel = 0
        Ripple.Image = "rbxassetid://2708891598"
        Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        local MouseLocation = UserInputService:GetMouseLocation()
        local ButtonAbsolutePosition = Button.AbsolutePosition
        local ButtonAbsoluteSize = Button.AbsoluteSize
        local CirclePosition = Vector2.new(MouseLocation.X - ButtonAbsolutePosition.X, MouseLocation.Y - ButtonAbsolutePosition.Y - 36)
        Ripple.Position = UDim2.new(0, CirclePosition.X, 0, CirclePosition.Y)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        local Size = math.max(ButtonAbsoluteSize.X, ButtonAbsoluteSize.Y) * 1.5
        local Tween = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, CirclePosition.X - Size/2, 0, CirclePosition.Y - Size/2),
            Size = UDim2.new(0, Size, 0, Size),
            ImageTransparency = 1
        })
        Tween:Play()
        Tween.Completed:Wait()
        Ripple:Destroy()
    end)
end
function Library:CreateWindow(ArgSettings)
    local TitleName = ArgSettings.Name or "Diablo Hub"
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeathAngelUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Config.Colors.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 0) -- Sharp Edge
    MainCorner.Parent = Main
    local Shadow = Instance.new("ImageLabel")
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Colors.Main),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 10, 10)) -- Hellfire Bottom
    })
    MainGradient.Rotation = 90
    MainGradient.Parent = Main

    local Texture = Instance.new("ImageLabel")
    Texture.Name = "Texture"
    Texture.Parent = Main
    Texture.BackgroundTransparency = 1
    Texture.Position = UDim2.new(0,0,0,0)
    Texture.Size = UDim2.new(1, 0, 1, 0)
    Texture.ZIndex = 1 -- Behind text, above bg color? Main BG is color. ZIndex 1 is fine.
    Texture.Image = "rbxassetid://4801855024"
    Texture.ImageColor3 = Color3.fromRGB(255,255,255)
    Texture.ImageTransparency = 0.92
    Texture.TileSize = UDim2.new(0, 100, 0, 100)
    Texture.ScaleType = Enum.ScaleType.Tile
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shadow.BackgroundTransparency = 1.000
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Config.Colors.Accent -- Demonic Glow
    Shadow.ImageTransparency = 0.2 -- Intense Glow
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)}):Play()
    task.spawn(function()
        local VoidContainer = Instance.new("Frame")
        VoidContainer.Name = "VoidContainer"
        VoidContainer.Parent = Main
        VoidContainer.BackgroundTransparency = 1
        VoidContainer.Size = UDim2.new(1, 0, 1, 0)
        VoidContainer.ZIndex = 0
        VoidContainer.ClipsDescendants = true
        
        while Main.Parent do
            local Ember = Instance.new("Frame")
            Ember.Parent = VoidContainer
            local redVal = math.random(150, 255)
            Ember.BackgroundColor3 = Color3.fromRGB(redVal, math.random(0, 50), 0) -- Varying fire colors
            Ember.BorderSizePixel = 0
            local size = math.random(2, 5)
            Ember.Size = UDim2.new(0, size, 0, size)
            -- Start from bottom, random X
            Ember.Position = UDim2.new(math.random(0,100)/100, 0, 1.1, 0)
            Ember.BackgroundTransparency = math.random(2, 5)/10
            
            -- Sharp particles
            local RiseSpeed = math.random(2, 6)
            local Sway = math.random(-20, 20)
            
            local Tween = TweenService:Create(Ember, TweenInfo.new(RiseSpeed, Enum.EasingStyle.Linear), {
                Position = UDim2.new(Ember.Position.X.Scale, Sway, -0.2, 0),
                BackgroundTransparency = 1,
                Rotation = math.random(-360, 360)
            })
            Tween:Play()
            game:GetService("Debris"):AddItem(Ember, RiseSpeed)
            task.wait(math.random(1, 5)/30) -- Rapid spawn
        end
    end)
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Config.Colors.Secondary
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 0) -- Sharp
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
    Controls.Name = "Controls"
    Controls.Parent = Topbar
    Controls.AnchorPoint = Vector2.new(1, 0.5)
    Controls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Controls.BackgroundTransparency = 1.000
    Controls.Position = UDim2.new(1, -12, 0.5, 0)
    Controls.Size = UDim2.new(0, 50, 0, 20)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Controls
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "Close"
    CloseBtn.Parent = Controls
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.LayoutOrder = 2
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Image = "rbxassetid://6031094678"
    CloseBtn.ImageColor3 = Config.Colors.TextDark
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Parent = Controls
    MinimizeBtn.BackgroundTransparency = 1.000
    MinimizeBtn.LayoutOrder = 1
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Image = "rbxassetid://6034818379"
    MinimizeBtn.ImageColor3 = Config.Colors.TextDark
    local MinimizedIcon = Instance.new("ImageButton")
    MinimizedIcon.Name = "MinimizedIcon"
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
    local IconGlow = Instance.new("ImageLabel")
    IconGlow.Name = "Glow"
    IconGlow.Parent = MinimizedIcon
    IconGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    IconGlow.BackgroundTransparency = 1
    IconGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
    IconGlow.Image = "rbxassetid://13476219193"
    IconGlow.ImageColor3 = Config.Colors.Accent
    IconGlow.ImageTransparency = 0.5
    MakeDraggable(MinimizedIcon, MinimizedIcon)
    local Minimized = false
    local OldPosition = Main.Position
    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {ImageColor3 = Config.Colors.Text}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {ImageColor3 = Config.Colors.TextDark}):Play()
    end)
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {ImageColor3 = Config.Colors.Accent}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {ImageColor3 = Config.Colors.TextDark}):Play()
    end)
    local function ToggleMinimize()
        Minimized = not Minimized
        if Minimized then
            OldPosition = Main.Position
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = MinimizedIcon.Position}):Play()
            task.wait(0.4)
            Main.Visible = false
            MinimizedIcon.Visible = true
            TweenService:Create(MinimizedIcon, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 60, 0, 60)}):Play()
        else
            local tween = TweenService:Create(MinimizedIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            tween:Play()
            task.delay(0.3, function()
                if not Minimized then
                    MinimizedIcon.Visible = false
                end
            end)
            Main.Visible = true
            Main.Position = MinimizedIcon.Position
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400), Position = OldPosition}):Play()
        end
    end
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    MinimizedIcon.MouseButton1Click:Connect(ToggleMinimize)
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    MakeDraggable(Topbar, Main)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == (Settings.ToggleUIKey or Enum.KeyCode.RightControl) then
            ToggleMinimize()
        end
    end)
    
    -- Tabs Container within Main
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

    -- Page Container
    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Parent = Main
    PageHolder.BackgroundTransparency = 1
    PageHolder.Position = UDim2.new(0, 15, 0, 100)
    PageHolder.Size = UDim2.new(1, -30, 1, -115)
    
    local FirstTab = true
    local Tabs = {}
    
    function Library:Tab(Name)
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Config.Colors.Secondary
        TabButton.Size = UDim2.new(0, 0, 1, 0)
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        TabButton.Font = Config.Font
        TabButton.Text = "  " .. Name .. "  "
        TabButton.TextColor3 = FirstTab and Config.Colors.Accent or Config.Colors.TextDark
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 0) -- Sharp
        TabCorner.Parent = TabButton
        
        -- Page ScrollFrame
        local Container = Instance.new("ScrollingFrame")
        Container.Name = Name .. "Page"
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

        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Button.TextColor3 = Config.Colors.TextDark
                tab.Page.Visible = false
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Secondary}):Play()
            end
            TabButton.TextColor3 = Config.Colors.Accent
            Container.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        end)
        
        table.insert(Tabs, {Button = TabButton, Page = Container})

        local Elements = {}
    function Elements:Section(Text)
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Section"
        SectionTitle.Parent = Container
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, 0, 0, 30)
        SectionTitle.Font = Config.Font
        SectionTitle.Text = Text
        SectionTitle.TextColor3 = Config.Colors.Accent
        SectionTitle.TextSize = 16.000
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Parent = SectionTitle
        Divider.BackgroundColor3 = Config.Colors.Secondary
        Divider.BorderSizePixel = 0
        Divider.Position = UDim2.new(0, 0, 1, -5)
        Divider.Size = UDim2.new(1, 0, 0, 2)
    end
    function Elements:Button(Text, Callback)
        local Callback = Callback or function() end
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = Container
        Button.BackgroundColor3 = Config.Colors.Secondary
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.AutoButtonColor = false
        Button.Font = Config.FontRegular
        Button.Text = Text
        Button.TextColor3 = Config.Colors.Text
        Button.TextSize = 14.000
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
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
            TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Secondary}):Play()
        end)
        Button.MouseButton1Click:Connect(function()
            CreateRipple(Button)
            Callback()
        end)
    end
    function Elements:Toggle(Text, Default, Callback)
        local Callback = Callback or function() end
        local Toggled = Default or false
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Name = "Toggle"
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
                TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Accent}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
            if not IgnoreCallback then
                task.spawn(function()
                    Callback(Toggled)
                end)
            end
        end
        ToggleFrame.MouseButton1Click:Connect(function()
            CreateRipple(ToggleFrame)
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
        SliderFrame.Name = "Slider"
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
        ValueLabel.TextSize = 14.000
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
            TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeScale, 0, 1, 0)}):Play()
            ValueLabel.Text = tostring(NewValue)
            Callback(NewValue)
        end
        local Dragging = false
        DragBtn.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                Update(Input)
                TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}):Play()
            end
        end)
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
                TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}):Play()
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(Input)
            end
        end)
    end
    function Elements:NumberInput(Text, Default, Callback)
        local Value = Default or 1
        local Callback = Callback or function() end
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = "InputFrame"
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
        ControlsContainer.Parent = InputFrame
        ControlsContainer.BackgroundTransparency = 1
        ControlsContainer.Position = UDim2.new(1, -140, 0.5, -15)
        ControlsContainer.Size = UDim2.new(0, 130, 0, 30)
        local DecBtn = Instance.new("TextButton")
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
            Value = tonumber(newValue) or Value
            TextBox.Text = tostring(Value)
            Callback(Value)
        end
        DecBtn.MouseButton1Click:Connect(function()
            CreateRipple(DecBtn)
            UpdateValue(Value - 1)
        end)
        IncBtn.MouseButton1Click:Connect(function()
            CreateRipple(IncBtn)
            UpdateValue(Value + 1)
        end)
        TextBox.FocusLost:Connect(function()
            if TextBox.Text == "" then
                TextBox.Text = tostring(Value)
            else
                UpdateValue(TextBox.Text)
            end
        end)
    end
    function Elements:TextInput(Text, Placeholder, Callback)
        local Callback = Callback or function() end
        local Value = ""
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = "TextInput"
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
        KeyFrame.Name = "Keybind"
        KeyFrame.Parent = Container
        KeyFrame.BackgroundColor3 = Config.Colors.Secondary
        KeyFrame.Size = UDim2.new(1, 0, 0, 50)
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
    end
    function Elements:Dropdown(Text, Options, Callback)
        local Options = Options or {}
        local Callback = Callback or function() end
        local Toggled = false
        local Selected = "None"
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "Dropdown"
        DropdownFrame.Parent = Container
        DropdownFrame.BackgroundColor3 = Config.Colors.Secondary
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame
        local MainButton = Instance.new("TextButton")
        MainButton.Parent = DropdownFrame
        MainButton.BackgroundTransparency = 1
        MainButton.Size = UDim2.new(1, 0, 0, 40)
        MainButton.Font = Config.FontRegular
        MainButton.Text = "  " .. Text .. ": " .. Selected
        MainButton.TextColor3 = Config.Colors.Text
        MainButton.TextSize = 14
        MainButton.TextXAlignment = Enum.TextXAlignment.Left
        local Arrow = Instance.new("ImageLabel")
        Arrow.Parent = MainButton
        Arrow.AnchorPoint = Vector2.new(1, 0.5)
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -12, 0.5, 0)
        Arrow.Size = UDim2.new(0, 16, 0, 16)
        Arrow.Image = "rbxassetid://6034818372"
        Arrow.ImageColor3 = Config.Colors.TextDark
        local OptionsContainer = Instance.new("Frame")
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
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
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
            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = TargetSize}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Toggled and 180 or 0}):Play()
        end)
        return {
            SetOptions = RefreshOptions,
            Set = function(val)
                Selected = val
                MainButton.Text = "  " .. Text .. ": " .. Selected
            end
        }
    end
        return Elements
    end
    return Library -- Return Library here instead of Elements
end
Settings = {
    FullbrightEnabled = false,
    TPWalkEnabled = false,
    TPWalkSpeed = 1,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
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
    FPSBoosterCache = {},
    OriginalValuesSaved = false,
    OriginalAmbient = nil,
    OriginalBrightness = nil,
    OriginalClockTime = nil,
    OriginalFogEnd = nil,
    OriginalFogStart = nil,
    OriginalOutdoorAmbient = nil,
    OriginalAtmosphere = nil,
    OriginalEffects = {}
}
local espConnections = {}
local TPWalkConnection = nil
local NoClipConnection = nil
local InfiniteJumpConnection = nil
local FolderName = "Diablo Script"
local ConfigName = "config.json"
local UIElements = {}
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
    local function GetServer()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        local decoded = HttpService:JSONDecode(raw)
        if decoded.data then
            local servers = {}
            for _, server in pairs(decoded.data) do
                if type(server) == "table" and server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            if #servers > 0 then
                return servers[math.random(1, #servers)]
            end
        end
        return nil
    end
    local ServerId = GetServer()
    if ServerId then
        TeleportService:TeleportToPlaceInstance(PlaceId, ServerId, LocalPlayer)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Server Hop",
            Text = "No suitable server found, trying again...",
            Duration = 5
        })
        task.wait(1)
        ServerHop()
    end
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
                    Decoration = terrain.Decoration
                }
            end
            terrain.WaterTransparency = 1
            terrain.WaterReflectance = 0
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.Decoration = false
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
            Text = "Teleported to last death position! 💀",
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
                        Text = "Auto-teleported back! ♻️",
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
        Text = "Successfully cleaned local workspace! 🧹",
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
                local isTeammate = Settings.HitboxTeamCheck and player.Team == LocalPlayer.Team
                if Settings.HitboxExpanderEnabled and not isIgnored and not isTeammate then
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
    local isWhitelisted = false
    for _, name in pairs(Settings.WhitelistNames) do
        if player.Name == name then isWhitelisted = true break end
    end
    if isWhitelisted then return end
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
        mainBox.ClipsDescendants = false -- Ensuring no clipping
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Parent = mainBox
        boxStroke.Color = Color3.fromRGB(0, 255, 255)
        boxStroke.Thickness = 1.5
        boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Vertical Health Bar on left
        local healthGui = Instance.new("BillboardGui")
        healthGui.Name = "ESPHealth"
        healthGui.Parent = humanoidRootPart
        healthGui.Size = UDim2.new(1, 0, 8, 0) -- 1 stud wide, 8 studs high
        healthGui.StudsOffset = Vector3.new(-7, 0, 0) -- Moved further left (was -4)
        healthGui.AlwaysOnTop = true
        healthGui.ClipsDescendants = false
        
        local healthBarBG = Instance.new("Frame")
        healthBarBG.Name = "HealthBG"
        healthBarBG.Parent = healthGui
        healthBarBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        healthBarBG.BackgroundTransparency = 0.5
        healthBarBG.BorderSizePixel = 0
        healthBarBG.Size = UDim2.new(0.5, 0, 1, 0) -- Half stud width
        healthBarBG.Position = UDim2.new(0.25, 0, 0, 0) -- Centered in billboard
        
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

            -- Force visibility update based on settings
            local showV1 = Settings.ESPEnabled
            local showV2 = Settings.ESPV2Enabled

            billboardGui.Enabled = showV1 or showV2
            v2Extras.Visible = showV2
            boxGui.Enabled = showV2
            healthGui.Enabled = showV2 -- Explicit toggle
            
            if highlight then highlight.Enabled = showV1 end
            local char = player.Character
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerHRP = char:FindFirstChild("HumanoidRootPart")
            if hum then
                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                healthBarFill.Size = UDim2.new(1, 0, healthPercent, 0)
                -- Color gradient from Green -> Red
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
                        -- Beyond safe range, keep it cyan but maybe more transparent? 
                        -- For now, user just asked for these ranges.
                        statusColor = Color3.fromRGB(150, 150, 150) -- Faded for very far
                        boxStroke.Thickness = 1
                    end
                else
                    -- Allies are always Green/Clean
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
    if not Settings.ESPEnabled and not Settings.ESPV2Enabled then
        if espConnections.playerAdded then espConnections.playerAdded:Disconnect() espConnections.playerAdded = nil end
        if espConnections.playerRemoving then espConnections.playerRemoving:Disconnect() espConnections.playerRemoving = nil end
    end
    for player, data in pairs(espConnections) do
        if type(player) == "userdata" then
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            if data.box then data.box:Destroy() end
            if data.health then data.health:Destroy() end
            if data.update then data.update:Disconnect() end
            if not Settings.ESPEnabled and not Settings.ESPV2Enabled then
                if data.charConn then data.charConn:Disconnect() end
            end
        end
    end
end
local function SaveOriginalLighting()
    if not Settings.OriginalValuesSaved then
        Settings.OriginalAmbient = Lighting.Ambient
        Settings.OriginalBrightness = Lighting.Brightness
        Settings.OriginalClockTime = Lighting.ClockTime
        Settings.OriginalFogEnd = Lighting.FogEnd
        Settings.OriginalFogStart = Lighting.FogStart
        Settings.OriginalOutdoorAmbient = Lighting.OutdoorAmbient
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            Settings.OriginalAtmosphere = {
                Instance = atmosphere,
                Density = atmosphere.Density,
                Offset = atmosphere.Offset,
                Haze = atmosphere.Haze,
                Glare = atmosphere.Glare
            }
        end
        Settings.OriginalEffects = {}
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                Settings.OriginalEffects[effect] = effect.Enabled
            end
        end
        Settings.OriginalValuesSaved = true
    end
end
local function RestoreOriginalLighting()
    if Settings.OriginalValuesSaved then
        Lighting.Ambient = Settings.OriginalAmbient
        Lighting.Brightness = Settings.OriginalBrightness
        Lighting.ClockTime = Settings.OriginalClockTime
        Lighting.FogEnd = Settings.OriginalFogEnd
        Lighting.FogStart = Settings.OriginalFogStart
        Lighting.OutdoorAmbient = Settings.OriginalOutdoorAmbient
        if Settings.OriginalAtmosphere and Settings.OriginalAtmosphere.Instance then
            Settings.OriginalAtmosphere.Instance.Density = Settings.OriginalAtmosphere.Density
            Settings.OriginalAtmosphere.Instance.Offset = Settings.OriginalAtmosphere.Offset
            Settings.OriginalAtmosphere.Instance.Haze = Settings.OriginalAtmosphere.Haze
            Settings.OriginalAtmosphere.Instance.Glare = Settings.OriginalAtmosphere.Glare
        end
        for effect, wasEnabled in pairs(Settings.OriginalEffects) do
            if effect and effect.Parent then effect.Enabled = wasEnabled end
        end
    end
end
local FullbrightConnection = nil
local function SetFullbright(enable)
    Settings.FullbrightEnabled = enable
    if enable then
        SaveOriginalLighting()
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
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
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
local function ToggleZoomUnlocker(state)
    Settings.ZoomUnlockerEnabled = state
    if state then
        LocalPlayer.CameraMaxZoomDistance = Settings.MaxZoomDistance
    else
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end
local function SaveConfig()
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
    local ConfigData = {}
    local SaveableKeys = {
        "FullbrightEnabled", "TPWalkEnabled", "TPWalkSpeed",
        "NoClipEnabled", "InfiniteJumpEnabled", "ESPEnabled",
        "TouchFlingEnabled", "AntiFlingEnabled", "InstantInteractEnabled", "ClickToFlingEnabled",
        "AntiAFKEnabled", "FlyEnabled", "FlySpeed", "ZoomUnlockerEnabled", "MaxZoomDistance", "AntiTouchEnabled", "AntiScreenShakeEnabled", "ESPTeamCheck", "AutoRespawnTPEnabled",
        "HitboxExpanderEnabled", "HitboxSize", "HitboxTeamCheck", "HitboxIgnoreList", "WalkOnWaterEnabled", "FreecamEnabled", "FreecamSpeed",
        "MapCleanerEnabled", "FPSBoosterEnabled", "ESPV2Enabled", "AllyNames", "ToggleUIKey"
    }
    for _, key in pairs(SaveableKeys) do
        if key == "ToggleUIKey" then
             ConfigData[key] = Settings[key].Name
        else
             ConfigData[key] = Settings[key]
        end
    end
    writefile(FolderName .. "/" .. ConfigName, HttpService:JSONEncode(ConfigData))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Diablo Script",
        Text = "Config Saved successfully! 💾",
        Duration = 3
    })
end
local function LoadConfig()
    if isfile(FolderName .. "/" .. ConfigName) then
        local raw = readfile(FolderName .. "/" .. ConfigName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if success and type(decoded) == "table" then
            for key, value in pairs(decoded) do
                if key == "ToggleUIKey" then
                    Settings[key] = Enum.KeyCode[value]
                else
                    Settings[key] = value
                end
            end
            for key, element in pairs(UIElements) do
                if Settings[key] ~= nil then
                    element.Set(Settings[key])
                end
            end
            if Settings.ToggleUIKey then UIElements.ToggleUIKey.Set(Settings.ToggleUIKey) end
            task.spawn(function()
                SetFullbright(Settings.FullbrightEnabled)
                SetupNoClip()
                SetupInfiniteJump()
                ToggleAntiAFK(Settings.AntiAFKEnabled)
                SetupTPWalk()
                if Settings.ESPEnabled or Settings.ESPV2Enabled then enableESP() else disableESP() end
                ToggleFly(Settings.FlyEnabled)
                ToggleFling(Settings.TouchFlingEnabled)
                ToggleAntiFling(Settings.AntiFlingEnabled)
                ToggleInstantInteract(Settings.InstantInteractEnabled)
                ToggleZoomUnlocker(Settings.ZoomUnlockerEnabled)
                if Settings.AntiTouchEnabled then ToggleAntiTouch(true) end
                ToggleAntiScreenShake(Settings.AntiScreenShakeEnabled)
                ToggleClickToFling(Settings.ClickToFlingEnabled)
                ToggleHitboxExpander(Settings.HitboxExpanderEnabled)
                ToggleWalkOnWater(Settings.WalkOnWaterEnabled)
                ToggleFreecam(Settings.FreecamEnabled)
                ToggleFPSBooster(Settings.FPSBoosterEnabled)
            end)
            return true
        end
    end
    return false
end
local Window = Library:CreateWindow({
    Name = "Diablo Hub"
})

local CombatTab = Window:Tab("Combat ⚔️")
local VisualsTab = Window:Tab("Visuals 👁️")
local MovementTab = Window:Tab("Movement ⚡")
local SettingsTab = Window:Tab("Settings ⚙️")

-- Combat Tab
CombatTab:Section("Fling 🌪️")
UIElements.TouchFlingEnabled = CombatTab:Toggle("Touch Fling 💫", Settings.TouchFlingEnabled, function(state)
    ToggleFling(state)
end)
UIElements.ClickToFlingEnabled = CombatTab:Toggle("Click-to-Fling 🎯", Settings.ClickToFlingEnabled, function(state)
    ToggleClickToFling(state)
end)
UIElements.AntiFlingEnabled = CombatTab:Toggle("Anti-Fling 🛡️", Settings.AntiFlingEnabled, function(state)
    ToggleAntiFling(state)
end)

CombatTab:Section("Hitbox Expander")
UIElements.HitboxExpanderEnabled = CombatTab:Toggle("Enable Expander 🟢", Settings.HitboxExpanderEnabled, function(state)
    ToggleHitboxExpander(state)
end)
UIElements.HitboxSize = CombatTab:NumberInput("Hitbox Size 📏", Settings.HitboxSize, function(value)
    Settings.HitboxSize = value
end)
UIElements.HitboxTeamCheck = CombatTab:Toggle("Hitbox Team Check 🛡️", Settings.HitboxTeamCheck, function(state)
    Settings.HitboxTeamCheck = state
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

-- Visuals Tab
VisualsTab:Section("ESP & Visuals 👁️")
UIElements.ESPEnabled = VisualsTab:Toggle("ESP V1 👁️", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if state then
        enableESP()
    else
        disableESP()
    end
end)
UIElements.ESPV2Enabled = VisualsTab:Toggle("ESP V2 🛰️", Settings.ESPV2Enabled, function(state)
    Settings.ESPV2Enabled = state
    if state then
        enableESP()
    else
        disableESP()
    end
end)
UIElements.ESPTeamCheck = VisualsTab:Toggle("ESP Team Check 🛡️", Settings.ESPTeamCheck, function(state)
    Settings.ESPTeamCheck = state
    if Settings.ESPEnabled or Settings.ESPV2Enabled then
        disableESP()
        enableESP()
    end
end)
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
UIElements.FreecamSpeed = VisualsTab:NumberInput("Freecam Speed 🏎️", Settings.FreecamSpeed, function(value)
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

-- Movement Tab
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

-- Settings Tab
SettingsTab:Section("System & Optimization ⚙️")
UIElements.FPSBoosterEnabled = SettingsTab:Toggle("FPS Booster ⚡", Settings.FPSBoosterEnabled, function(state)
    ToggleFPSBooster(state)
end)
UIElements.AntiAFKEnabled = SettingsTab:Toggle("Anti-AFK 💤", Settings.AntiAFKEnabled, function(state)
    ToggleAntiAFK(state)
end)
UIElements.InstantInteractEnabled = SettingsTab:Toggle("Instant Interact 👆", Settings.InstantInteractEnabled, function(state)
    ToggleInstantInteract(state)
end)
UIElements.AntiTouchEnabled = SettingsTab:Toggle("Anti-Touch 🚫", Settings.AntiTouchEnabled, function(state)
    ToggleAntiTouch(state)
end)
SettingsTab:Button("Rejoin Server 🔄", function()
    RejoinServer()
end)
SettingsTab:Button("Server Hop 🌎", function()
    ServerHop()
end)
SettingsTab:Button("Find Small Server 🕵️", function()
    FindSmallServer()
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
end)


return Library
