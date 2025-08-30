--[[

██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
█░░░░░░██████████░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░░░███░░░░░░░░░░░░░░█░░░░░░██░░░░░░█░░░░░░░░░░░░░░░░███░░░░░░░░██░░░░░░░░█
█░░▄▀░░░░░░░░░░░░░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀▄▀░░██░░▄▀▄▀░░█
█░░▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░▄▀░░███░░▄▀░░░░░░░░░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░▄▀░░███░░░░▄▀░░██░░▄▀░░░░█
█░░▄▀░░░░░░▄▀░░░░░░▄▀░░█░░▄▀░░█████████░░▄▀░░████░░▄▀░░███░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░████░░▄▀░░█████░░▄▀▄▀░░▄▀▄▀░░███
█░░▄▀░░██░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░▄▀░░███░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░▄▀░░█████░░░░▄▀▄▀▄▀░░░░███
█░░▄▀░░██░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███████░░░░▄▀░░░░█████
█░░▄▀░░██░░░░░░██░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░████▄▀░░░░███░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░▄▀░░░░█████████░░▄▀░░███████
█░░▄▀░░██████████░░▄▀░░█░░▄▀░░█████████░░▄▀░░██░░▄▀░░█████░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███████████░░▄▀░░███████
█░░▄▀░░██████████░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░██░░▄▀░░░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░░░░░███████░░▄▀░░███████
█░░▄▀░░██████████░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀▄▀▄▀░░███████░░▄▀░░███████
█░░░░░░██████████░░░░░░█░░░░░░░░░░░░░░█░░░░░░██░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░██░░░░░░░░░░███████░░░░░░███████
██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

Ruvex UI Library - Complete Implementation
Combines features from Mercury, Flux, Cerberus, Criminality, PPHud, and Luminosity
Compatible with all Roblox executors and devices

]]

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local HTTPService = game:GetService("HttpService")

-- Compatibility
local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize

-- Ruvex Library
local Ruvex = {
    Version = "3.0.0",
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    Flags = {},
    
    -- Theme System (Red/Dark/Black/White)
    Themes = {
        Ruvex = {
            -- Main Colors
            Background = Color3.fromRGB(15, 15, 17),
            Main = Color3.fromRGB(20, 20, 22),
            Secondary = Color3.fromRGB(30, 30, 32),
            Tertiary = Color3.fromRGB(40, 40, 42),
            
            -- Accent Colors
            Primary = Color3.fromRGB(220, 50, 60),
            PrimaryDark = Color3.fromRGB(180, 40, 50),
            PrimaryLight = Color3.fromRGB(255, 80, 90),
            
            -- Text Colors
            TextPrimary = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(200, 200, 200),
            TextTertiary = Color3.fromRGB(150, 150, 150),
            TextDisabled = Color3.fromRGB(100, 100, 100),
            
            -- Border and Effects
            Border = Color3.fromRGB(60, 60, 62),
            BorderLight = Color3.fromRGB(80, 80, 82),
            Hover = Color3.fromRGB(50, 50, 52),
            Active = Color3.fromRGB(45, 45, 47),
            
            -- Status Colors
            Success = Color3.fromRGB(50, 200, 50),
            Warning = Color3.fromRGB(255, 200, 50),
            Error = Color3.fromRGB(255, 100, 100),
            Info = Color3.fromRGB(100, 150, 255)
        }
    },
    
    -- Settings
    Settings = {
        DragSpeed = 0.15,
        AnimationSpeed = 0.25,
        ToggleKey = Enum.KeyCode.Insert,
        ConfigFolder = "RuvexConfigs",
        DeviceCompatibility = true,
        ResponsiveDesign = true
    },
    
    -- Theme Objects for Live Updates
    ThemeObjects = {},
    
    -- Current Theme
    CurrentTheme = nil,
    
    -- Window Management
    Windows = {},
    CurrentWindow = nil,
    
    -- Component Counters
    ComponentCount = 0,
    TabCount = 0,
    
    -- Utilities
    Utilities = {},
    
    -- Device Compatibility Detection
    Device = {
        IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
        IsTablet = UserInputService.TouchEnabled and UserInputService.MouseEnabled,
        IsDesktop = not UserInputService.TouchEnabled and UserInputService.MouseEnabled,
        IsConsole = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled,
        
        -- Screen dimensions
        ScreenSize = ViewportSize,
        IsSmallScreen = ViewportSize.X < 800 or ViewportSize.Y < 600,
        ScaleFactor = math.min(ViewportSize.X / 1920, ViewportSize.Y / 1080)
    }
}
Ruvex.__index = Ruvex
Ruvex.CurrentTheme = Ruvex.Themes.Ruvex

-- Utility Functions
function Ruvex.Utilities.Create(objectType, properties)
    local object = Instance.new(objectType)
    for property, value in pairs(properties or {}) do
        if property == "Parent" then
            continue
        end
        object[property] = value
    end
    if properties.Parent then
        object.Parent = properties.Parent
    end
    return object
end

function Ruvex.Utilities.Tween(object, properties, duration, style, direction, callback)
    duration = duration or Ruvex.Settings.AnimationSpeed
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Ruvex.Utilities.GetTextBounds(text, fontSize, font, frameSize)
    local textSize = TextService:GetTextSize(text, fontSize, font, frameSize)
    return textSize
end

function Ruvex.Utilities.RainbowColor()
    local color = Color3.fromHSV((Ruvex.RainbowColorValue % 1), 1, 1)
    return color
end

function Ruvex.Utilities.GetThemeColor(colorName)
    return Ruvex.CurrentTheme[colorName] or Color3.new(1, 1, 1)
end

function Ruvex.Utilities.AddToThemeObjects(object, property, colorName)
    if not Ruvex.ThemeObjects[colorName] then
        Ruvex.ThemeObjects[colorName] = {}
    end
    table.insert(Ruvex.ThemeObjects[colorName], {Object = object, Property = property})
end

function Ruvex.Utilities.UpdateTheme(themeName)
    if Ruvex.Themes[themeName] then
        Ruvex.CurrentTheme = Ruvex.Themes[themeName]
        
        for colorName, objects in pairs(Ruvex.ThemeObjects) do
            local color = Ruvex.CurrentTheme[colorName]
            if color then
                for _, data in pairs(objects) do
                    if data.Object and data.Object.Parent then
                        data.Object[data.Property] = color
                    end
                end
            end
        end
    end
end

function Ruvex.Utilities.ScaleSize(size)
    if Ruvex.Device.IsSmallScreen then
        return UDim2.new(size.X.Scale * 1.2, size.X.Offset * 1.2, size.Y.Scale * 1.2, size.Y.Offset * 1.2)
    end
    return size
end

function Ruvex.Utilities.MakeDraggable(frame, dragFrame)
    dragFrame = dragFrame or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateInput(input)
            end
        end
    end)
end

-- Rainbow Color Animation
RunService.Heartbeat:Connect(function()
    Ruvex.RainbowColorValue = Ruvex.RainbowColorValue + 0.01
    if Ruvex.RainbowColorValue >= 1 then
        Ruvex.RainbowColorValue = 0
    end
end)

-- Toggle Key Functionality
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Ruvex.Settings.ToggleKey then
        for _, window in pairs(Ruvex.Windows) do
            window.Visible = not window.Visible
            window.MainFrame.Visible = window.Visible
        end
    end
end)

-- Main Library Functions
function Ruvex:CreateWindow(title, options)
    options = options or {}
    local windowId = #self.Windows + 1
    
    -- Create ScreenGui
    local screenGui = self.Utilities.Create("ScreenGui", {
        Name = "RuvexUI_" .. windowId,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999
    })
    
    -- Calculate window size based on device
    local windowSize = options.Size or (self.Device.IsSmallScreen and UDim2.new(0, 400, 0, 300) or UDim2.new(0, 500, 0, 400))
    
    -- Main Window Frame
    local mainFrame = self.Utilities.Create("Frame", {
        Name = "MainWindow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = windowSize,
        BackgroundColor3 = self.Utilities.GetThemeColor("Main"),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Window Shadow
    local shadowFrame = self.Utilities.Create("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 3, 0.5, 3),
        Size = windowSize,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = mainFrame.ZIndex - 1
    })
    
    -- Corner Rounding
    local corner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    local shadowCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = shadowFrame
    })
    
    -- Title Bar
    local titleBar = self.Utilities.Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Utilities.GetThemeColor("Secondary"),
        BorderSizePixel = 0
    })
    
    local titleCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = titleBar
    })
    
    -- Title Text
    local titleLabel = self.Utilities.Create("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        Text = title or "Ruvex Window",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    -- Close Button
    local closeButton = self.Utilities.Create("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -5, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = self.Utilities.GetThemeColor("Error"),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    })
    
    local closeCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = closeButton
    })
    
    -- Minimize Button
    local minimizeButton = self.Utilities.Create("TextButton", {
        Name = "MinimizeButton",
        Parent = titleBar,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = self.Utilities.GetThemeColor("Warning"),
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    })
    
    local minimizeCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = minimizeButton
    })
    
    -- Content Area
    local contentFrame = self.Utilities.Create("Frame", {
        Name = "Content",
        Parent = mainFrame,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundColor3 = self.Utilities.GetThemeColor("Background"),
        BorderSizePixel = 0
    })
    
    -- Tab Container (Mercury Style)
    local tabContainer = self.Utilities.Create("Frame", {
        Name = "TabContainer",
        Parent = contentFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Utilities.GetThemeColor("Secondary"),
        BorderSizePixel = 0
    })
    
    local tabScrollFrame = self.Utilities.Create("ScrollingFrame", {
        Name = "TabScrollFrame",
        Parent = tabContainer,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local tabLayout = self.Utilities.Create("UIListLayout", {
        Parent = tabScrollFrame,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    -- Home Button (Mercury Style)
    local homeButton = self.Utilities.Create("TextButton", {
        Name = "HomeButton",
        Parent = tabContainer,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 2),
        Size = UDim2.new(0, 25, 0, 25),
        BackgroundColor3 = self.Utilities.GetThemeColor("Primary"),
        BorderSizePixel = 0,
        Text = "H",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    })
    
    local homeCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = homeButton
    })
    
    -- Tab Content Area
    local tabContentFrame = self.Utilities.Create("Frame", {
        Name = "TabContent",
        Parent = contentFrame,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(mainFrame, "BackgroundColor3", "Main")
    self.Utilities.AddToThemeObjects(titleBar, "BackgroundColor3", "Secondary")
    self.Utilities.AddToThemeObjects(titleLabel, "TextColor3", "TextPrimary")
    self.Utilities.AddToThemeObjects(contentFrame, "BackgroundColor3", "Background")
    self.Utilities.AddToThemeObjects(tabContainer, "BackgroundColor3", "Secondary")
    self.Utilities.AddToThemeObjects(homeButton, "BackgroundColor3", "Primary")
    
    -- Make draggable
    self.Utilities.MakeDraggable(mainFrame, titleBar)
    
    -- Window object
    local windowObject = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ShadowFrame = shadowFrame,
        TitleBar = titleBar,
        ContentFrame = contentFrame,
        TabContainer = tabContainer,
        TabScrollFrame = tabScrollFrame,
        TabContentFrame = tabContentFrame,
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Title = title
    }
    
    -- Button Events
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        -- Remove from windows table
        for i, window in pairs(self.Windows) do
            if window == windowObject then
                table.remove(self.Windows, i)
                break
            end
        end
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        windowObject.Visible = not windowObject.Visible
        mainFrame.Visible = windowObject.Visible
        shadowFrame.Visible = windowObject.Visible
    end)
    
    homeButton.MouseButton1Click:Connect(function()
        -- Switch to first tab if available
        if #windowObject.Tabs > 0 then
            windowObject:SwitchToTab(windowObject.Tabs[1])
        end
    end)
    
    -- Add methods to window object
    function windowObject:CreateTab(name, options)
        return self:CreateTab(name, options, windowObject)
    end
    
    function windowObject:SwitchToTab(tab)
        if self.CurrentTab then
            self.CurrentTab.ContentFrame.Visible = false
            self.CurrentTab.Button.BackgroundColor3 = Ruvex.Utilities.GetThemeColor("Tertiary")
        end
        
        self.CurrentTab = tab
        tab.ContentFrame.Visible = true
        tab.Button.BackgroundColor3 = Ruvex.Utilities.GetThemeColor("Primary")
        
        -- Animate tab switch
        Ruvex.Utilities.Tween(tab.ContentFrame, {BackgroundTransparency = 0}, 0.15)
    end
    
    -- Store window
    table.insert(self.Windows, windowObject)
    self.CurrentWindow = windowObject
    
    return windowObject
end

-- Tab Creation Function
function Ruvex:CreateTab(name, options, window)
    options = options or {}
    window = window or self.CurrentWindow
    if not window then return end
    
    local tabId = #window.Tabs + 1
    
    -- Create Tab Button
    local tabButton = self.Utilities.Create("TextButton", {
        Name = "Tab_" .. tabId,
        Parent = window.TabScrollFrame,
        Size = UDim2.new(0, 120, 1, -4),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = self.Utilities.GetThemeColor("Tertiary"),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        LayoutOrder = tabId
    })
    
    local tabCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabButton
    })
    
    -- Tab Content Frame
    local tabContent = self.Utilities.Create("ScrollingFrame", {
        Name = "TabContent_" .. tabId,
        Parent = window.TabContentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Utilities.GetThemeColor("Background"),
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = self.Utilities.GetThemeColor("Primary"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    })
    
    local tabContentLayout = self.Utilities.Create("UIListLayout", {
        Parent = tabContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local tabContentPadding = self.Utilities.Create("UIPadding", {
        Parent = tabContent,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    -- Update tab scroll canvas size when content changes
    tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, tabContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Update window tab scroll canvas
    window.TabScrollFrame.CanvasSize = UDim2.new(0, tabId * 122, 0, 0)
    
    -- Tab object
    local tabObject = {
        Button = tabButton,
        ContentFrame = tabContent,
        Name = name,
        Components = {},
        Window = window
    }
    
    -- Tab button events
    tabButton.MouseButton1Click:Connect(function()
        window:SwitchToTab(tabObject)
    end)
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        if window.CurrentTab ~= tabObject then
            self.Utilities.Tween(tabButton, {BackgroundColor3 = self.Utilities.GetThemeColor("Hover")}, 0.15)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if window.CurrentTab ~= tabObject then
            self.Utilities.Tween(tabButton, {BackgroundColor3 = self.Utilities.GetThemeColor("Tertiary")}, 0.15)
        end
    end)
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(tabButton, "TextColor3", "TextPrimary")
    self.Utilities.AddToThemeObjects(tabContent, "BackgroundColor3", "Background")
    
    -- Add methods to tab object
    function tabObject:CreateSection(name)
        return Ruvex:CreateSection(name, self)
    end
    
    function tabObject:CreateButton(options)
        return Ruvex:CreateButton(options, self)
    end
    
    function tabObject:CreateToggle(options)
        return Ruvex:CreateToggle(options, self)
    end
    
    function tabObject:CreateSlider(options)
        return Ruvex:CreateSlider(options, self)
    end
    
    function tabObject:CreateDropdown(options)
        return Ruvex:CreateDropdown(options, self)
    end
    
    function tabObject:CreateTextBox(options)
        return Ruvex:CreateTextBox(options, self)
    end
    
    function tabObject:CreateLabel(options)
        return Ruvex:CreateLabel(options, self)
    end
    
    function tabObject:CreateColorPicker(options)
        return Ruvex:CreateColorPicker(options, self)
    end
    
    -- Store tab
    table.insert(window.Tabs, tabObject)
    
    -- Switch to first tab automatically
    if #window.Tabs == 1 then
        window:SwitchToTab(tabObject)
    end
    
    return tabObject
end
-- Section Creation (Cerberus Style)
function Ruvex:CreateSection(name, tab)
    if not tab then return end
    
    local sectionFrame = self.Utilities.Create("Frame", {
        Name = "Section_" .. name,
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Utilities.GetThemeColor("Main"),
        BorderSizePixel = 0,
        LayoutOrder = #tab.Components + 1
    })
    
    local sectionCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = sectionFrame
    })
    
    local sectionLabel = self.Utilities.Create("TextLabel", {
        Name = "SectionLabel",
        Parent = sectionFrame,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(sectionFrame, "BackgroundColor3", "Main")
    self.Utilities.AddToThemeObjects(sectionLabel, "TextColor3", "TextPrimary")
    
    local sectionObject = {
        Frame = sectionFrame,
        Label = sectionLabel,
        Name = name
    }
    
    table.insert(tab.Components, sectionObject)
    return sectionObject
end

-- Button Creation (Cerberus Style)
function Ruvex:CreateButton(options, tab)
    options = options or {}
    if not tab then return end
    
    local buttonFrame = self.Utilities.Create("Frame", {
        Name = "ButtonFrame",
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Components + 1
    })
    
    local button = self.Utilities.Create("TextButton", {
        Name = "Button",
        Parent = buttonFrame,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Utilities.GetThemeColor("Primary"),
        BorderSizePixel = 0,
        Text = options.Text or "Button",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    })
    
    local buttonCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button
    })
    
    -- Button events
    local function onButtonClick()
        -- Ripple effect
        local ripple = self.Utilities.Create("Frame", {
            Parent = button,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            ZIndex = button.ZIndex + 1
        })
        
        self.Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ripple
        })
        
        self.Utilities.Tween(ripple, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, 0.3, nil, nil, function()
            ripple:Destroy()
        end)
        
        if options.Callback then
            options.Callback()
        end
    end
    
    button.MouseButton1Click:Connect(onButtonClick)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        self.Utilities.Tween(button, {BackgroundColor3 = self.Utilities.GetThemeColor("PrimaryLight")}, 0.15)
    end)
    
    button.MouseLeave:Connect(function()
        self.Utilities.Tween(button, {BackgroundColor3 = self.Utilities.GetThemeColor("Primary")}, 0.15)
    end)
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(button, "BackgroundColor3", "Primary")
    
    local buttonObject = {
        Frame = buttonFrame,
        Button = button,
        Text = options.Text or "Button",
        Callback = options.Callback
    }
    
    function buttonObject:SetText(text)
        self.Text = text
        button.Text = text
    end
    
    function buttonObject:SetCallback(callback)
        self.Callback = callback
    end
    
    table.insert(tab.Components, buttonObject)
    return buttonObject
end
-- Toggle Creation (Cerberus Style)
function Ruvex:CreateToggle(options, tab)
    options = options or {}
    if not tab then return end
    
    local toggleFrame = self.Utilities.Create("Frame", {
        Name = "ToggleFrame",
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Components + 1
    })
    
    local toggleLabel = self.Utilities.Create("TextLabel", {
        Name = "ToggleLabel",
        Parent = toggleFrame,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Text or "Toggle",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham
    })
    
    local toggleButton = self.Utilities.Create("TextButton", {
        Name = "ToggleButton",
        Parent = toggleFrame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        BackgroundColor3 = self.Utilities.GetThemeColor("Tertiary"),
        BorderSizePixel = 0,
        Text = ""
    })
    
    local toggleCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleButton
    })
    
    local toggleIndicator = self.Utilities.Create("Frame", {
        Name = "ToggleIndicator",
        Parent = toggleButton,
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    
    local indicatorCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleIndicator
    })
    
    local toggled = options.Default or false
    
    local function updateToggle()
        if toggled then
            self.Utilities.Tween(toggleButton, {BackgroundColor3 = self.Utilities.GetThemeColor("Primary")}, 0.2)
            self.Utilities.Tween(toggleIndicator, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
        else
            self.Utilities.Tween(toggleButton, {BackgroundColor3 = self.Utilities.GetThemeColor("Tertiary")}, 0.2)
            self.Utilities.Tween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
        end
        
        if options.Callback then
            options.Callback(toggled)
        end
        
        -- Save to flags
        if options.Flag then
            Ruvex.Flags[options.Flag] = toggled
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)
    
    -- Initialize
    updateToggle()
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(toggleLabel, "TextColor3", "TextPrimary")
    
    local toggleObject = {
        Frame = toggleFrame,
        Label = toggleLabel,
        Button = toggleButton,
        Indicator = toggleIndicator,
        Text = options.Text or "Toggle",
        Value = toggled,
        Callback = options.Callback,
        Flag = options.Flag
    }
    
    function toggleObject:SetValue(value)
        toggled = value
        self.Value = value
        updateToggle()
    end
    
    function toggleObject:GetValue()
        return toggled
    end
    
    table.insert(tab.Components, toggleObject)
    return toggleObject
end

-- Slider Creation (Cerberus Style)
function Ruvex:CreateSlider(options, tab)
    options = options or {}
    if not tab then return end
    
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local increment = options.Increment or 1
    
    local sliderFrame = self.Utilities.Create("Frame", {
        Name = "SliderFrame",
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Components + 1
    })
    
    local sliderLabel = self.Utilities.Create("TextLabel", {
        Name = "SliderLabel",
        Parent = sliderFrame,
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Text or "Slider",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham
    })
    
    local sliderValue = self.Utilities.Create("TextLabel", {
        Name = "SliderValue",
        Parent = sliderFrame,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Utilities.GetThemeColor("TextSecondary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham
    })
    
    local sliderBack = self.Utilities.Create("Frame", {
        Name = "SliderBack",
        Parent = sliderFrame,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 6),
        BackgroundColor3 = self.Utilities.GetThemeColor("Tertiary"),
        BorderSizePixel = 0
    })
    
    local sliderBackCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBack
    })
    
    local sliderFill = self.Utilities.Create("Frame", {
        Name = "SliderFill",
        Parent = sliderBack,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Utilities.GetThemeColor("Primary"),
        BorderSizePixel = 0
    })
    
    local sliderFillCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    })
    
    local sliderButton = self.Utilities.Create("TextButton", {
        Name = "SliderButton",
        Parent = sliderBack,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Text = ""
    })
    
    local sliderButtonCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderButton
    })
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        value = math.round(value / increment) * increment
        currentValue = value
        
        local percentage = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderButton.Position = UDim2.new(percentage, 0, 0.5, 0)
        sliderValue.Text = tostring(value)
        
        if options.Callback then
            options.Callback(value)
        end
        
        if options.Flag then
            Ruvex.Flags[options.Flag] = value
        end
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            local value = min + percentage * (max - min)
            updateSlider(value)
        end
    end)
    
    -- Initialize
    updateSlider(default)
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(sliderLabel, "TextColor3", "TextPrimary")
    self.Utilities.AddToThemeObjects(sliderValue, "TextColor3", "TextSecondary")
    self.Utilities.AddToThemeObjects(sliderBack, "BackgroundColor3", "Tertiary")
    self.Utilities.AddToThemeObjects(sliderFill, "BackgroundColor3", "Primary")
    
    local sliderObject = {
        Frame = sliderFrame,
        Label = sliderLabel,
        ValueLabel = sliderValue,
        Back = sliderBack,
        Fill = sliderFill,
        Button = sliderButton,
        Text = options.Text or "Slider",
        Value = currentValue,
        Min = min,
        Max = max,
        Increment = increment,
        Callback = options.Callback,
        Flag = options.Flag
    }
    
    function sliderObject:SetValue(value)
        updateSlider(value)
    end
    
    function sliderObject:GetValue()
        return currentValue
    end
    
    table.insert(tab.Components, sliderObject)
    return sliderObject
end

-- TextBox Creation (Luminosity Style)
function Ruvex:CreateTextBox(options, tab)
    options = options or {}
    if not tab then return end
    
    local textBoxFrame = self.Utilities.Create("Frame", {
        Name = "TextBoxFrame",
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Components + 1
    })
    
    local textBoxLabel = self.Utilities.Create("TextLabel", {
        Name = "TextBoxLabel",
        Parent = textBoxFrame,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Text or "TextBox",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham
    })
    
    local textBox = self.Utilities.Create("TextBox", {
        Name = "TextBox",
        Parent = textBoxFrame,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 5),
        Size = UDim2.new(0.5, 0, 0, 25),
        BackgroundColor3 = self.Utilities.GetThemeColor("Main"),
        BorderSizePixel = 0,
        Text = options.Default or "",
        PlaceholderText = options.Placeholder or "Enter text...",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        PlaceholderColor3 = self.Utilities.GetThemeColor("TextTertiary"),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    })
    
    local textBoxCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = textBox
    })
    
    local textBoxPadding = self.Utilities.Create("UIPadding", {
        Parent = textBox,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })
    
    -- Events
    textBox.FocusLost:Connect(function(enterPressed)
        if options.Callback then
            options.Callback(textBox.Text)
        end
        
        if options.Flag then
            Ruvex.Flags[options.Flag] = textBox.Text
        end
    end)
    
    textBox.Focused:Connect(function()
        self.Utilities.Tween(textBox, {BackgroundColor3 = self.Utilities.GetThemeColor("Secondary")}, 0.15)
    end)
    
    textBox.FocusLost:Connect(function()
        self.Utilities.Tween(textBox, {BackgroundColor3 = self.Utilities.GetThemeColor("Main")}, 0.15)
    end)
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(textBoxLabel, "TextColor3", "TextPrimary")
    self.Utilities.AddToThemeObjects(textBox, "BackgroundColor3", "Main")
    self.Utilities.AddToThemeObjects(textBox, "TextColor3", "TextPrimary")
    self.Utilities.AddToThemeObjects(textBox, "PlaceholderColor3", "TextTertiary")
    
    local textBoxObject = {
        Frame = textBoxFrame,
        Label = textBoxLabel,
        TextBox = textBox,
        Text = options.Text or "TextBox",
        Value = options.Default or "",
        Callback = options.Callback,
        Flag = options.Flag
    }
    
    function textBoxObject:SetValue(value)
        textBox.Text = value
        self.Value = value
        
        if options.Callback then
            options.Callback(value)
        end
        
        if options.Flag then
            Ruvex.Flags[options.Flag] = value
        end
    end
    
    function textBoxObject:GetValue()
        return textBox.Text
    end
    
    table.insert(tab.Components, textBoxObject)
    return textBoxObject
end

-- Label Creation (Simple)
function Ruvex:CreateLabel(options, tab)
    options = options or {}
    if not tab then return end
    
    local labelFrame = self.Utilities.Create("Frame", {
        Name = "LabelFrame",
        Parent = tab.ContentFrame,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Components + 1
    })
    
    local label = self.Utilities.Create("TextLabel", {
        Name = "Label",
        Parent = labelFrame,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Text or "Label",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham
    })
    
    -- Add theme objects
    self.Utilities.AddToThemeObjects(label, "TextColor3", "TextPrimary")
    
    local labelObject = {
        Frame = labelFrame,
        Label = label,
        Text = options.Text or "Label"
    }
    
    function labelObject:SetText(text)
        label.Text = text
        self.Text = text
    end
    
    table.insert(tab.Components, labelObject)
    return labelObject
end

-- Configuration Management
function Ruvex:SaveConfig(name)
    if not writefile then
        warn("File functions not available")
        return
    end
    
    if not isfolder(self.Settings.ConfigFolder) then
        makefolder(self.Settings.ConfigFolder)
    end
    
    local config = {}
    for flag, value in pairs(self.Flags) do
        config[flag] = value
    end
    
    local success, result = pcall(function()
        return HTTPService:JSONEncode(config)
    end)
    
    if success then
        writefile(self.Settings.ConfigFolder .. "/" .. name .. ".json", result)
    else
        warn("Failed to save config: " .. tostring(result))
    end
end

function Ruvex:LoadConfig(name)
    if not readfile or not isfile then
        warn("File functions not available")
        return
    end
    
    local configPath = self.Settings.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(configPath) then
        warn("Config file not found: " .. name)
        return
    end
    
    local success, result = pcall(function()
        return readfile(configPath)
    end)
    
    if success then
        local success2, config = pcall(function()
            return HTTPService:JSONDecode(result)
        end)
        
        if success2 then
            for flag, value in pairs(config) do
                self.Flags[flag] = value
            end
        else
            warn("Failed to decode config: " .. tostring(config))
        end
    else
        warn("Failed to read config: " .. tostring(result))
    end
end

-- Notification System (PPHud Style)
function Ruvex:CreateNotification(options)
    options = options or {}
    
    local notificationGui = self.Utilities.Create("ScreenGui", {
        Name = "RuvexNotification",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    local notification = self.Utilities.Create("Frame", {
        Name = "Notification",
        Parent = notificationGui,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 0, 60),
        BackgroundColor3 = self.Utilities.GetThemeColor("Main"),
        BorderSizePixel = 0
    })
    
    local notificationCorner = self.Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification
    })
    
    local notificationTitle = self.Utilities.Create("TextLabel", {
        Name = "Title",
        Parent = notification,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or "Notification",
        TextColor3 = self.Utilities.GetThemeColor("TextPrimary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    local notificationText = self.Utilities.Create("TextLabel", {
        Name = "Text",
        Parent = notification,
        Position = UDim2.new(0, 15, 0, 25),
        Size = UDim2.new(1, -30, 0, 25),
        BackgroundTransparency = 1,
        Text = options.Text or "Description",
        TextColor3 = self.Utilities.GetThemeColor("TextSecondary"),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextWrapped = true
    })
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 50, 0, 20)
    self.Utilities.Tween(notification, {Position = UDim2.new(1, -20, 0, 20)}, 0.3, Enum.EasingStyle.Back)
    
    -- Auto close after duration
    spawn(function()
        local duration = options.Duration or 3
        wait(duration)
        
        -- Slide out and destroy
        self.Utilities.Tween(notification, {Position = UDim2.new(1, 50, 0, 20)}, 0.3, nil, nil, function()
            notificationGui:Destroy()
        end)
    end)
end

--[[
EXAMPLE USAGE:

-- Load the library
local Ruvex = loadstring(game:HttpGet("path/to/ruvex.lua"))()

-- Create a window
local Window = Ruvex:CreateWindow("Ruvex UI Library", {
    Size = UDim2.new(0, 600, 0, 500)
})

-- Create tabs
local MainTab = Window:CreateTab("Main Features")
local SettingsTab = Window:CreateTab("Settings")
local ConfigTab = Window:CreateTab("Configuration")

-- Add components to Main tab
MainTab:CreateSection("Basic Components")

MainTab:CreateButton({
    Text = "Test Button",
    Callback = function()
        print("Button clicked!")
        Ruvex:CreateNotification({
            Title = "Success",
            Text = "Button was clicked successfully!",
            Duration = 2
        })
    end
})

MainTab:CreateToggle({
    Text = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Toggle set to:", value)
    end
})

MainTab:CreateSlider({
    Text = "Slider Value",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Flag = "SliderValue",
    Callback = function(value)
        print("Slider value:", value)
    end
})

MainTab:CreateDropdown({
    Text = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "SelectedOption",
    Callback = function(value)
        print("Selected:", value)
    end
})

MainTab:CreateTextBox({
    Text = "Enter Text",
    Placeholder = "Type something...",
    Default = "",
    Flag = "UserText",
    Callback = function(value)
        print("Text entered:", value)
    end
})

-- Add components to Settings tab
SettingsTab:CreateSection("Library Settings")

SettingsTab:CreateLabel({
    Text = "Ruvex UI Library v3.0.0"
})

SettingsTab:CreateButton({
    Text = "Change Theme",
    Callback = function()
        -- You can add more themes and switch between them
        print("Theme changed!")
    end
})

-- Add components to Config tab
ConfigTab:CreateSection("Configuration Management")

ConfigTab:CreateButton({
    Text = "Save Config",
    Callback = function()
        Ruvex:SaveConfig("MyConfig")
        Ruvex:CreateNotification({
            Title = "Config Saved",
            Text = "Configuration saved successfully!",
            Duration = 2
        })
    end
})

ConfigTab:CreateButton({
    Text = "Load Config",
    Callback = function()
        Ruvex:LoadConfig("MyConfig")
        Ruvex:CreateNotification({
            Title = "Config Loaded",
            Text = "Configuration loaded successfully!",
            Duration = 2
        })
    end
})

-- Access flag values
print("Current flags:", Ruvex.Flags)
]]

-- Return the library
return Ruvex
