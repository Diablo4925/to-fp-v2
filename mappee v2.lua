local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Library = {}
local Config = {
    Colors = {
        Main = Color3.fromRGB(24, 24, 32),
        Secondary = Color3.fromRGB(32, 32, 42),
        Accent = Color3.fromRGB(220, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Green = Color3.fromRGB(46, 139, 87)
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
function Library:CreateWindow(Settings)
    local TitleName = Settings.Name or "Christmas Hub"
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ChristmasPremium"
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
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shadow.BackgroundTransparency = 1.000
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.400
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)}):Play()
    task.spawn(function()
        local SnowContainer = Instance.new("Frame")
        SnowContainer.Name = "SnowContainer"
        SnowContainer.Parent = Main
        SnowContainer.BackgroundTransparency = 1
        SnowContainer.Size = UDim2.new(1, 0, 1, 0)
        SnowContainer.ZIndex = 20
        SnowContainer.ClipsDescendants = true
        while Main.Parent do
            local Snow = Instance.new("Frame")
            Snow.Parent = SnowContainer
            Snow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Snow.BorderSizePixel = 0
            Snow.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
            Snow.Position = UDim2.new(math.random(0,100)/100, 0, -0.1, 0)
            Snow.BackgroundTransparency = math.random(30,80)/100
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(1,0)
            Corner.Parent = Snow
            local FallSpeed = math.random(3,8)
            local Sway = math.random(-50,50)
            local Tween = TweenService:Create(Snow, TweenInfo.new(FallSpeed, Enum.EasingStyle.Linear), {
                Position = UDim2.new(Snow.Position.X.Scale, Sway, 1.1, 0),
                BackgroundTransparency = 1
            })
            Tween:Play()
            
            game:GetService("Debris"):AddItem(Snow, FallSpeed)
            task.wait(math.random(1,5)/10)
        end
    end)
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Config.Colors.Secondary
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 12)
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
    MinimizedIcon.Image = "rbxassetid://6421296789"
    MinimizedIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MinimizedIcon.ZIndex = 100
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = MinimizedIcon
    
    local IconStroke = Instance.new("UIStroke")
    IconStroke.Parent = MinimizedIcon
    IconStroke.Color = Config.Colors.Accent
    IconStroke.Thickness = 2
    IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
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
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.Position = UDim2.new(0, 15, 0, 60)
    Container.Size = UDim2.new(1, -30, 1, -75)
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Config.Colors.Accent
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
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
        ToggleFrame.MouseButton1Click:Connect(function()
            CreateRipple(ToggleFrame)
            Toggled = not Toggled
            
            -- UI Update (Immediate)
            if Toggled then
                TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Accent}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
            -- Callback (Async)
            task.spawn(function()
                Callback(Toggled)
            end)
        end)
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
    return Elements
end
local Settings = {
    FullbrightEnabled = false,
    TPWalkEnabled = false,
    TPWalkSpeed = 1,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    ESPEnabled = false,
    TouchFlingEnabled = false,
    AntiFlingEnabled = false,
    InstantInteractEnabled = false,
    FlyEnabled = false,
    FlySpeed = 1,
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
                bg.CFrame = workspace.CurrentCamera.CFrame
                
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
                end
                
                bv.Velocity = moveDir * (Settings.FlySpeed * 50)
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
        local raw = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local decoded = HttpService:JSONDecode(raw)
        
        if decoded.data then
            for _, server in pairs(decoded.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    return server.id
                end
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
            Text = "No suitable server found, try again later.",
            Duration = 5
        })
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
                    if player ~= LocalPlayer and player.Character then
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
local InstantInteractConnection = nil
local OriginalPrompts = {}
local function ToggleInstantInteract(state)
    Settings.InstantInteractEnabled = state
    if state then
        -- Process existing prompts
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if not OriginalPrompts[prompt] then
                    OriginalPrompts[prompt] = prompt.HoldDuration
                end
                prompt.HoldDuration = 0
            end
        end
        
        -- Serialize new prompts
        if InstantInteractConnection then InstantInteractConnection:Disconnect() end
        InstantInteractConnection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                task.wait() -- Wait for properties to initialize
                if not OriginalPrompts[descendant] then
                    OriginalPrompts[descendant] = descendant.HoldDuration
                end
                if Settings.InstantInteractEnabled then
                    descendant.HoldDuration = 0
                end
            end
        end)
    else
        -- Cleanup connection
        if InstantInteractConnection then 
            InstantInteractConnection:Disconnect()
            InstantInteractConnection = nil
        end
        
        -- Restore originals
        for prompt, duration in pairs(OriginalPrompts) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = duration
            end
        end
        OriginalPrompts = {} -- Clear cache
    end
end
local function createESP(player)
    if player == LocalPlayer then return end
    if espConnections[player] and espConnections[player].highlight then
        espConnections[player].highlight:Destroy()
    end
    if espConnections[player] and espConnections[player].billboard then
        espConnections[player].billboard:Destroy()
    end
    if espConnections[player] and espConnections[player].update then
        espConnections[player].update:Disconnect()
    end
    
    local function applyToCharacter(character)
        if not character then return end
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "DiabloHighlight"
        highlight.Parent = character
        highlight.FillColor = Config.Colors.Accent
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESPInfo"
        billboardGui.Parent = humanoidRootPart
        billboardGui.Size = UDim2.new(0, 200, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboardGui
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Config.Font
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Parent = billboardGui
        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "0 studs"
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextScaled = true
        distanceLabel.Font = Config.FontRegular
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        local updateConnection
        updateConnection = RunService.Heartbeat:Connect(function()
            if not Settings.ESPEnabled or not player.Character or not LocalPlayer.Character or not highlight.Parent then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
            
            if localHRP and playerHRP then
                local distance = math.floor((localHRP.Position - playerHRP.Position).Magnitude)
                distanceLabel.Text = distance .. " studs"
            end
        end)
        
        if not espConnections[player] then espConnections[player] = {} end
        espConnections[player].highlight = highlight
        espConnections[player].billboard = billboardGui
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
    if not Settings.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    espConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
    
    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        if espConnections[player] then
            if espConnections[player].highlight then espConnections[player].highlight:Destroy() end
            if espConnections[player].billboard then espConnections[player].billboard:Destroy() end
            if espConnections[player].update then espConnections[player].update:Disconnect() end
            if espConnections[player].charConn then espConnections[player].charConn:Disconnect() end
            espConnections[player] = nil
        end
    end)
end
local function disableESP()
    if espConnections.playerAdded then espConnections.playerAdded:Disconnect() espConnections.playerAdded = nil end
    if espConnections.playerRemoving then espConnections.playerRemoving:Disconnect() espConnections.playerRemoving = nil end
    
    for player, data in pairs(espConnections) do
        if type(player) == "userdata" then
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            if data.update then data.update:Disconnect() end
            if data.charConn then data.charConn:Disconnect() end
        end
    end
    espConnections = {}
end
local function SaveOriginalLighting()
    if not Settings.OriginalValuesSaved then
        Settings.OriginalAmbient = Lighting.Ambient
        Settings.OriginalBrightness = Lighting.Brightness
        Settings.OriginalClockTime = Lighting.ClockTime
        Settings.OriginalFogEnd = Lighting.FogEnd
        Settings.OriginalFogStart = Lighting.FogStart
        Settings.OriginalOutdoorAmbient = Lighting.OutdoorAmbient
        
        -- Save Atmosphere
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
        
        -- Restore Atmosphere
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
local function SetFullbright(enable)
    if enable then
        SaveOriginalLighting()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        -- Handle Atmosphere
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
    else
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
    local target = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name:lower():sub(1, #targetName) == targetName:lower() then
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
    else
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end
local Window = Library:CreateWindow({
    Name = "🎄 Diablo Hub Merry Christmas"
})
Window:Section("Main Features")
Window:Toggle("Touch Fling 💫", Settings.TouchFlingEnabled, function(state)
    ToggleFling(state)
end)
Window:Toggle("Anti-Fling 🛡️", Settings.AntiFlingEnabled, function(state)
    ToggleAntiFling(state)
end)
Window:Toggle("Instant Interact 👆", Settings.InstantInteractEnabled, function(state)
    ToggleInstantInteract(state)
end)
Window:Toggle("Fullbright ☀️", Settings.FullbrightEnabled, function(state)
    Settings.FullbrightEnabled = state
    SetFullbright(state)
end)
Window:Toggle("NoClip 👻", Settings.NoClipEnabled, function(state)
    Settings.NoClipEnabled = state
    SetupNoClip()
end)
Window:Toggle("Infinite Jump 🦘", Settings.InfiniteJumpEnabled, function(state)
    Settings.InfiniteJumpEnabled = state
    SetupInfiniteJump()
end)
Window:Section("Movement")
Window:Toggle("Fly 🕊️", Settings.FlyEnabled, function(state)
    ToggleFly(state)
end)
Window:NumberInput("Fly Speed 🚀", 1, function(value)
    Settings.FlySpeed = value
end)
Window:Toggle("TP Walk ⚡", Settings.TPWalkEnabled, function(state)
    Settings.TPWalkEnabled = state
    SetupTPWalk()
end)
Window:NumberInput("TP Speed 🎯", 1, function(value)
    Settings.TPWalkSpeed = value
end)
Window:Section("Visuals")
Window:Toggle("ESP 👁️", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if state then
        enableESP()
    else
        disableESP()
    end
end)
Window:TextInput("Spectate Player 📹", "Player Name...", function(text)
    if text == "" then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    else
        SpectatePlayer(text)
    end
end)
Window:Section("Server & Utility")
Window:Button("Rejoin Server 🔄", function()
    RejoinServer()
end)
Window:Button("Server Hop 🌎", function()
    ServerHop()
end)
task.spawn(function()
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "มึงจะรันโปรกูหาพ่อมึงหรอ",
            Text = "เล่นโปรทำไมไอ่ไก่",
            Duration = 5
        })
    end
end)
return Library
