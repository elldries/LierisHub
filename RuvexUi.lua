-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HTTPService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- Ruvex Main Library
local Ruvex = {
    -- Theme System with Red/Black/White Color Scheme
    Themes = {
        Dark = {
            Primary = Color3.fromRGB(15, 15, 15),       -- Deep Black
            Secondary = Color3.fromRGB(25, 25, 25),     -- Dark Gray
            Tertiary = Color3.fromRGB(220, 50, 50),     -- Red Accent
            Background = Color3.fromRGB(10, 10, 10),    -- Background Black
            Surface = Color3.fromRGB(30, 30, 30),       -- Surface Gray
            Border = Color3.fromRGB(40, 40, 40),        -- Border Color
            
            -- Text Colors
            PrimaryText = Color3.fromRGB(255, 255, 255),    -- Pure White
            SecondaryText = Color3.fromRGB(200, 200, 200),  -- Light Gray
            TertiaryText = Color3.fromRGB(150, 150, 150),   -- Medium Gray
            AccentText = Color3.fromRGB(255, 80, 80),       -- Light Red
            
            -- Interactive States
            Hover = Color3.fromRGB(45, 45, 45),             -- Hover State
            Active = Color3.fromRGB(180, 40, 40),           -- Active Red
            Disabled = Color3.fromRGB(60, 60, 60),          -- Disabled Gray
        },
        Light = {
            Primary = Color3.fromRGB(245, 245, 245),
            Secondary = Color3.fromRGB(220, 220, 220),
            Tertiary = Color3.fromRGB(200, 60, 60),
            Background = Color3.fromRGB(255, 255, 255),
            Surface = Color3.fromRGB(240, 240, 240),
            Border = Color3.fromRGB(200, 200, 200),
            
            PrimaryText = Color3.fromRGB(20, 20, 20),
            SecondaryText = Color3.fromRGB(60, 60, 60),
            TertiaryText = Color3.fromRGB(100, 100, 100),
            AccentText = Color3.fromRGB(180, 40, 40),
            
            Hover = Color3.fromRGB(235, 235, 235),
            Active = Color3.fromRGB(200, 60, 60),
            Disabled = Color3.fromRGB(180, 180, 180),
        }
    },
    
    -- Theme Management
    ThemeObjects = {
        Primary = {},
        Secondary = {},
        Tertiary = {},
        Background = {},
        Surface = {},
        Border = {},
        PrimaryText = {},
        SecondaryText = {},
        TertiaryText = {},
        AccentText = {},
        Hover = {},
        Active = {},
        Disabled = {}
    },
    
    CurrentTheme = nil,
    
    -- Rainbow System (from Flux)
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    
    -- Configuration
    flags = {},
    DragSpeed = 0.06,
    LockDragging = false,
    ToggleKey = Enum.KeyCode.Home,
    Toggled = true,
    
    -- Cache Systems
    _tweenCache = {},
    _objectCache = {},
    
    -- Window Management
    Windows = {},
    Notifications = {}
}

Ruvex.__index = Ruvex

-- Initialize with Dark theme
Ruvex.CurrentTheme = Ruvex.Themes.Dark

-- Rainbow Color System (Enhanced from Flux)
coroutine.wrap(function()
    while wait() do
        Ruvex.RainbowColorValue = Ruvex.RainbowColorValue + 1 / 255
        Ruvex.HueSelectionPosition = Ruvex.HueSelectionPosition + 1
        
        if Ruvex.RainbowColorValue >= 1 then
            Ruvex.RainbowColorValue = 0
        end
        
        if Ruvex.HueSelectionPosition == 80 then
            Ruvex.HueSelectionPosition = 0
        end
    end
end)()

-- Utility Functions
function Ruvex:Create(instanceType, properties, children)
    local instance = Instance.new(instanceType)
    properties = properties or {}
    children = children or {}
    
    -- Default properties for better appearance
    local defaults = {
        BorderSizePixel = 0,
        BackgroundColor3 = self.CurrentTheme.Primary
    }
    
    -- Apply defaults first
    for property, value in pairs(defaults) do
        pcall(function()
            instance[property] = value
        end)
    end
    
    -- Apply custom properties
    for property, value in pairs(properties) do
        if property == "Theme" then
            self:ApplyTheme(instance, value)
        else
            instance[property] = value
        end
    end
    
    -- Add children
    for _, child in pairs(children) do
        if typeof(child) == "Instance" then
            child.Parent = instance
        end
    end
    
    return instance
end

function Ruvex:ApplyTheme(object, themeProperties)
    for property, themeInfo in pairs(themeProperties) do
        if type(themeInfo) == "table" then
            local themeName, modifier = themeInfo[1], themeInfo[2] or 0
            local color = self.CurrentTheme[themeName]
            if color then
                if modifier > 0 then
                    color = self:Lighten(color, modifier)
                elseif modifier < 0 then
                    color = self:Darken(color, -modifier)
                end
                object[property] = color
                table.insert(self.ThemeObjects[themeName], {object, property, themeName, modifier})
            end
        elseif type(themeInfo) == "string" then
            local color = self.CurrentTheme[themeInfo]
            if color then
                object[property] = color
                table.insert(self.ThemeObjects[themeInfo], {object, property, themeInfo, 0})
            end
        end
    end
end

function Ruvex:Tween(object, tweenInfo, properties, callback)
    local tween
    if typeof(tweenInfo) == "number" then
        tween = TweenService:Create(object, TweenInfo.new(tweenInfo, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    else
        tween = TweenService:Create(object, tweenInfo, properties)
    end
    
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

function Ruvex:Lighten(color, amount)
    local h, s, v = Color3.toHSV(color)
    amount = amount or 15
    local factor = 1 - ((amount) / 80)
    return Color3.fromHSV(h, math.clamp(s * factor, 0, 1), math.clamp(v / factor, 0, 1))
end

function Ruvex:Darken(color, amount)
    local h, s, v = Color3.toHSV(color)
    amount = amount or 15
    local factor = 1 - ((amount) / 80)
    return Color3.fromHSV(h, math.clamp(s / factor, 0, 1), math.clamp(v * factor, 0, 1))
end

function Ruvex:GetRainbowColor()
    return Color3.fromHSV(self.RainbowColorValue, 1, 1)
end

-- Advanced Object Creation with Methods (Enhanced from Mercury)
function Ruvex:Object(class, properties)
    properties = properties or {}
    local object = Instance.new(class)
    local methods = {}
    
    -- Apply properties
    for property, value in pairs(properties) do
        if property == "Theme" then
            self:ApplyTheme(object, value)
        elseif property == "Centered" and value then
            object.AnchorPoint = Vector2.new(0.5, 0.5)
            object.Position = UDim2.fromScale(0.5, 0.5)
        else
            object[property] = value
        end
    end
    
    -- Method functions
    function methods:Tween(tweenProperties, callback)
        local length = tweenProperties.Length or 0.2
        tweenProperties.Length = nil
        return Ruvex:Tween(object, length, tweenProperties, callback)
    end
    
    function methods:Round(radius)
        radius = radius or 6
        local corner = Ruvex:Create("UICorner", {
            Parent = object,
            CornerRadius = UDim.new(0, radius)
        })
        return methods
    end
    
    function methods:Stroke(color, thickness)
        thickness = thickness or 1
        local stroke = Ruvex:Create("UIStroke", {
            Parent = object,
            Thickness = thickness,
            Color = color or Ruvex.CurrentTheme.Border
        })
        return methods
    end
    
    function methods:Fade(state, color, length, instant)
        length = length or 0.2
        if not rawget(methods, "fadeFrame") then
            local frame = Ruvex:Create("Frame", {
                Parent = object,
                BackgroundColor3 = color or object.BackgroundColor3,
                BackgroundTransparency = (state and 1) or 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 999
            })
            frame:Round(6)
            rawset(methods, "fadeFrame", frame)
        end
        
        local fadeFrame = rawget(methods, "fadeFrame")
        if instant then
            fadeFrame.BackgroundTransparency = state and 0 or 1
            fadeFrame.Visible = state
        else
            if state then
                fadeFrame.Visible = true
                fadeFrame.BackgroundTransparency = 1
                Ruvex:Tween(fadeFrame, length, {BackgroundTransparency = 0})
            else
                Ruvex:Tween(fadeFrame, length, {BackgroundTransparency = 1}, function()
                    fadeFrame.Visible = false
                end)
            end
        end
        return methods
    end
    
    function methods:Object(class, props)
        props = props or {}
        props.Parent = object
        return Ruvex:Object(class, props)
    end
    
    function methods:Tooltip(text)
        local tooltip = methods:Object("TextLabel", {
            Theme = {
                BackgroundColor3 = {"Primary", 10},
                TextColor3 = {"PrimaryText"}
            },
            TextSize = 14,
            Text = text,
            Position = UDim2.new(0.5, 0, 0, -8),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            TextTransparency = 1,
            ZIndex = 1000
        }):Round(4)
        
        local textBounds = TextService:GetTextSize(text, 14, Enum.Font.SourceSans, Vector2.new(200, math.huge))
        tooltip.Size = UDim2.fromOffset(textBounds.X + 16, textBounds.Y + 8)
        
        local hovered = false
        
        object.MouseEnter:Connect(function()
            hovered = true
            wait(0.2)
            if hovered then
                tooltip:Tween({BackgroundTransparency = 0.1, TextTransparency = 0})
            end
        end)
        
        object.MouseLeave:Connect(function()
            hovered = false
            tooltip:Tween({BackgroundTransparency = 1, TextTransparency = 1})
        end)
        
        return methods
    end
    
    -- Return methods with metamethods for property access
    return setmetatable(methods, {
        __index = function(_, property)
            return object[property]
        end,
        __newindex = function(_, property, value)
            object[property] = value
        end,
    })
end

-- Dragging System (Enhanced from Multiple Libraries)
function Ruvex:MakeDraggable(dragObject, targetObject)
    targetObject = targetObject or dragObject
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPosition
        
        if self.LockDragging then
            local maxX = targetObject.Parent.AbsoluteSize.X - targetObject.AbsoluteSize.X
            local maxY = targetObject.Parent.AbsoluteSize.Y - targetObject.AbsoluteSize.Y
            local clampedX = math.clamp(startPosition.X.Offset + delta.X, 0, maxX)
            local clampedY = math.clamp(startPosition.Y.Offset + delta.Y, 0, maxY)
            newPosition = UDim2.new(startPosition.X.Scale, clampedX, startPosition.Y.Scale, clampedY)
        else
            newPosition = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
        
        self:Tween(targetObject, self.DragSpeed, {Position = newPosition})
    end
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = targetObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Theme Management
function Ruvex:ChangeTheme(themeName)
    if not self.Themes[themeName] then
        warn("Theme '" .. themeName .. "' does not exist")
        return
    end
    
    self.CurrentTheme = self.Themes[themeName]
    
    -- Update all themed objects
    for themeProperty, objects in pairs(self.ThemeObjects) do
        for _, objectData in pairs(objects) do
            local object, property, theme, modifier = objectData[1], objectData[2], objectData[3], objectData[4]
            local color = self.CurrentTheme[theme]
            
            if color then
                if modifier > 0 then
                    color = self:Lighten(color, modifier)
                elseif modifier < 0 then
                    color = self:Darken(color, -modifier)
                end
                object[property] = color
            end
        end
    end
end

-- Window Creation System
function Ruvex:CreateWindow(options)
    options = options or {}
    options.Title = options.Title or "Ruvex Window"
    options.Size = options.Size or UDim2.fromOffset(600, 400)
    options.MinSize = options.MinSize or UDim2.fromOffset(300, 200)
    options.Resizable = options.Resizable ~= false
    options.Draggable = options.Draggable ~= false
    
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Create main GUI
    local gui = self:Create("ScreenGui", {
        Name = "RuvexWindow",
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    
    -- Main window frame
    local mainFrame = self:Object("Frame", {
        Size = UDim2.new(),
        Theme = {BackgroundColor3 = "Primary"},
        Centered = true,
        ClipsDescendants = true
    }):Round(8):Stroke(self.CurrentTheme.Border, 1)
    
    mainFrame.Parent = gui
    window.MainFrame = mainFrame
    
    -- Shadow effect
    local shadowHolder = self:Object("Frame", {
        Parent = gui,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 0
    })
    
    local shadow = self:Object("ImageLabel", {
        Parent = shadowHolder,
        Centered = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.7,
        SliceCenter = Rect.new(47, 47, 450, 450),
        ScaleType = Enum.ScaleType.Slice
    })
    
    -- Title bar
    local titleBar = mainFrame:Object("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 0, 0, 0)
    }):Round(8)
    
    -- Title text
    local titleText = titleBar:Object("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Theme = {
            BackgroundColor3 = "Secondary",
            TextColor3 = "PrimaryText"
        },
        Text = options.Title,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        BackgroundTransparency = 1
    })
    
    -- Close button
    local closeButton = titleBar:Object("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Theme = {BackgroundColor3 = "Hover"},
        Text = "X",
        TextSize = 14,
        Theme = {TextColor3 = "PrimaryText"},
        Font = Enum.Font.SourceSansBold,
        BackgroundTransparency = 1
    }):Round(3)
    
    -- Close button functionality
    closeButton.MouseEnter:Connect(function()
        closeButton:Tween({BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(220, 50, 50)})
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton:Tween({BackgroundTransparency = 1})
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        window:Close()
    end)
    
    -- Tab container
    local tabContainer = mainFrame:Object("ScrollingFrame", {
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 35),
        Theme = {BackgroundColor3 = "Surface"},
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    tabContainer:Object("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        HorizontalAlignment = Enum.HorizontalAlignment.Left
    })
    
    -- Content area
    local contentArea = mainFrame:Object("Frame", {
        Size = UDim2.new(1, -10, 1, -70),
        Position = UDim2.new(0, 5, 0, 65),
        Theme = {BackgroundColor3 = {"Surface", -5}},
        BackgroundTransparency = 0
    }):Round(6)
    
    -- Make draggable
    if options.Draggable then
        self:MakeDraggable(titleBar, mainFrame)
    end
    
    -- Animation in
    mainFrame:Tween({Size = options.Size}, function()
        mainFrame.ClipsDescendants = false
    end)
    
    -- Window methods
    function window:Close()
        mainFrame.ClipsDescendants = true
        mainFrame:Tween({Size = UDim2.new()}, function()
            gui:Destroy()
        end)
    end
    
    function window:Toggle()
        self.Ruvex.Toggled = not self.Ruvex.Toggled
        if self.Ruvex.Toggled then
            mainFrame:Tween({Size = options.Size})
        else
            mainFrame:Tween({Size = UDim2.new()})
        end
    end
    
    function window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        tabOptions.Name = tabOptions.Name or "Tab " .. (#self.Tabs + 1)
        tabOptions.Icon = tabOptions.Icon or ""
        
        local tab = {}
        
        -- Tab button
        local tabButton = tabContainer:Object("TextButton", {
            Size = UDim2.new(0, 120, 1, 0),
            Theme = {BackgroundColor3 = "Secondary"},
            Text = "",
            BackgroundTransparency = (#self.Tabs == 0) and 0 or 0.5
        }):Round(4)
        
        local tabIcon = tabButton:Object("ImageLabel", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Theme = {ImageColor3 = "PrimaryText"},
            Image = tabOptions.Icon,
            BackgroundTransparency = 1
        })
        
        local tabLabel = tabButton:Object("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            Theme = {
                BackgroundColor3 = "Secondary",
                TextColor3 = "PrimaryText"
            },
            Text = tabOptions.Name,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans
        })
        
        -- Tab content
        local tabContent = contentArea:Object("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Theme = {ScrollBarImageColor3 = "Border"},
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = #self.Tabs == 0
        })
        
        tabContent:Object("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        tabContent:Object("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        })
        
        tab.Content = tabContent
        tab.Button = tabButton
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            for _, existingTab in pairs(self.Tabs) do
                existingTab.Content.Visible = false
                existingTab.Button:Tween({BackgroundTransparency = 0.5})
            end
            
            tabContent.Visible = true
            tabButton:Tween({BackgroundTransparency = 0})
            self.CurrentTab = tab
        end)
        
        -- Tab hover effects
        tabButton.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then
                tabButton:Tween({BackgroundTransparency = 0.3})
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then
                tabButton:Tween({BackgroundTransparency = 0.5})
            end
        end)
        
        -- Set as current tab if first
        if #self.Tabs == 0 then
            self.CurrentTab = tab
        end
        
        table.insert(self.Tabs, tab)
        
        -- Tab component creation methods
        function tab:Button(buttonOptions)
            buttonOptions = buttonOptions or {}
            buttonOptions.Text = buttonOptions.Text or "Button"
            buttonOptions.Callback = buttonOptions.Callback or function() end
            
            local button = tabContent:Object("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = "Secondary"},
                Text = buttonOptions.Text,
                TextSize = 14,
                Theme = {TextColor3 = "PrimaryText"},
                Font = Enum.Font.SourceSans
            }):Round(6)
            
            button.MouseEnter:Connect(function()
                button:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Hover})
            end)
            
            button.MouseLeave:Connect(function()
                button:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Secondary})
            end)
            
            button.MouseButton1Down:Connect(function()
                button:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Active})
            end)
            
            button.MouseButton1Up:Connect(function()
                button:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Hover})
            end)
            
            button.MouseButton1Click:Connect(buttonOptions.Callback)
            
            return button
        end
        
        function tab:Toggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            toggleOptions.Text = toggleOptions.Text or "Toggle"
            toggleOptions.Default = toggleOptions.Default or false
            toggleOptions.Callback = toggleOptions.Callback or function() end
            
            local toggleFrame = tabContent:Object("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = "Secondary"},
                BackgroundTransparency = 0
            }):Round(6)
            
            local toggleLabel = toggleFrame:Object("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = toggleOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local toggleButton = toggleFrame:Object("TextButton", {
                Size = UDim2.fromOffset(40, 20),
                Position = UDim2.new(1, -45, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Theme = {BackgroundColor3 = toggleOptions.Default and "Tertiary" or "Disabled"},
                Text = "",
                BackgroundTransparency = 0
            }):Round(10)
            
            local toggleIndicator = toggleButton:Object("Frame", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, toggleOptions.Default and 22 or 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Theme = {BackgroundColor3 = "PrimaryText"}
            }):Round(8)
            
            local state = toggleOptions.Default
            Ruvex.flags[toggleOptions.Flag or toggleOptions.Text] = state
            
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                Ruvex.flags[toggleOptions.Flag or toggleOptions.Text] = state
                
                if state then
                    toggleButton:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                    toggleIndicator:Tween({Position = UDim2.new(0, 22, 0.5, 0)})
                else
                    toggleButton:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Disabled})
                    toggleIndicator:Tween({Position = UDim2.new(0, 2, 0.5, 0)})
                end
                
                toggleOptions.Callback(state)
            end)
            
            toggleFrame.MouseEnter:Connect(function()
                toggleFrame:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Hover})
            end)
            
            toggleFrame.MouseLeave:Connect(function()
                toggleFrame:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Secondary})
            end)
            
            return toggleFrame
        end
        
        function tab:Slider(sliderOptions)
            sliderOptions = sliderOptions or {}
            sliderOptions.Text = sliderOptions.Text or "Slider"
            sliderOptions.Min = sliderOptions.Min or 0
            sliderOptions.Max = sliderOptions.Max or 100
            sliderOptions.Default = sliderOptions.Default or sliderOptions.Min
            sliderOptions.Callback = sliderOptions.Callback or function() end
            
            local sliderFrame = tabContent:Object("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                Theme = {BackgroundColor3 = "Secondary"}
            }):Round(6)
            
            local sliderLabel = sliderFrame:Object("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = sliderOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local sliderTrack = sliderFrame:Object("Frame", {
                Size = UDim2.new(1, -20, 0, 4),
                Position = UDim2.new(0, 10, 0, 30),
                Theme = {BackgroundColor3 = "Disabled"}
            }):Round(2)
            
            local sliderFill = sliderTrack:Object("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                Theme = {BackgroundColor3 = "Tertiary"}
            }):Round(2)
            
            local sliderKnob = sliderTrack:Object("TextButton", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(0, -6, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Theme = {BackgroundColor3 = "PrimaryText"},
                Text = ""
            }):Round(6)
            
            local valueLabel = sliderFrame:Object("TextLabel", {
                Size = UDim2.fromOffset(50, 20),
                Position = UDim2.new(1, -60, 0, 5),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "AccentText"
                },
                Text = tostring(sliderOptions.Default),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local value = sliderOptions.Default
            local dragging = false
            
            local function updateSlider(inputPosition)
                local relativePos = math.clamp((inputPosition.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                value = math.floor(sliderOptions.Min + (sliderOptions.Max - sliderOptions.Min) * relativePos)
                
                sliderFill:Tween({Size = UDim2.new(relativePos, 0, 1, 0)})
                sliderKnob:Tween({Position = UDim2.new(relativePos, -6, 0.5, 0)})
                valueLabel.Text = tostring(value)
                
                Ruvex.flags[sliderOptions.Flag or sliderOptions.Text] = value
                sliderOptions.Callback(value)
            end
            
            -- Initial setup
            local initialPos = (sliderOptions.Default - sliderOptions.Min) / (sliderOptions.Max - sliderOptions.Min)
            sliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
            sliderKnob.Position = UDim2.new(initialPos, -6, 0.5, 0)
            Ruvex.flags[sliderOptions.Flag or sliderOptions.Text] = value
            
            sliderKnob.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input.Position)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            sliderTrack.MouseButton1Click:Connect(function()
                updateSlider(Mouse)
            end)
            
            return sliderFrame
        end
        
        function tab:Dropdown(dropdownOptions)
            dropdownOptions = dropdownOptions or {}
            dropdownOptions.Text = dropdownOptions.Text or "Dropdown"
            dropdownOptions.Options = dropdownOptions.Options or {"Option 1", "Option 2"}
            dropdownOptions.Default = dropdownOptions.Default or dropdownOptions.Options[1]
            dropdownOptions.Callback = dropdownOptions.Callback or function() end
            
            local dropdownFrame = tabContent:Object("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = "Secondary"}
            }):Round(6)
            
            local dropdownLabel = dropdownFrame:Object("TextLabel", {
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = dropdownOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local dropdownButton = dropdownFrame:Object("TextButton", {
                Size = UDim2.new(0.5, -10, 0, 25),
                Position = UDim2.new(0.5, 5, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Theme = {BackgroundColor3 = "Surface"},
                Text = dropdownOptions.Default,
                TextSize = 12,
                Theme = {TextColor3 = "PrimaryText"},
                Font = Enum.Font.SourceSans
            }):Round(4)
            
            local dropdownArrow = dropdownButton:Object("TextLabel", {
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -20, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Theme = {
                    BackgroundColor3 = "Surface",
                    TextColor3 = "TertiaryText"
                },
                Text = "▼",
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local expanded = false
            local optionsList = nil
            
            local currentValue = dropdownOptions.Default
            Ruvex.flags[dropdownOptions.Flag or dropdownOptions.Text] = currentValue
            
            dropdownButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                
                if expanded then
                    dropdownArrow:Tween({Rotation = 180})
                    
                    -- Create options list
                    optionsList = dropdownFrame:Object("Frame", {
                        Size = UDim2.new(0.5, -10, 0, #dropdownOptions.Options * 25),
                        Position = UDim2.new(0.5, 5, 1, 5),
                        Theme = {BackgroundColor3 = "Primary"},
                        ZIndex = 100
                    }):Round(4):Stroke(Ruvex.CurrentTheme.Border, 1)
                    
                    optionsList:Object("UIListLayout")
                    
                    for i, option in ipairs(dropdownOptions.Options) do
                        local optionButton = optionsList:Object("TextButton", {
                            Size = UDim2.new(1, 0, 0, 25),
                            Theme = {BackgroundColor3 = "Primary"},
                            Text = option,
                            TextSize = 12,
                            Theme = {TextColor3 = "PrimaryText"},
                            Font = Enum.Font.SourceSans,
                            ZIndex = 101
                        })
                        
                        optionButton.MouseEnter:Connect(function()
                            optionButton:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Hover})
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            optionButton:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Primary})
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            currentValue = option
                            dropdownButton.Text = option
                            Ruvex.flags[dropdownOptions.Flag or dropdownOptions.Text] = currentValue
                            dropdownOptions.Callback(currentValue)
                            
                            expanded = false
                            dropdownArrow:Tween({Rotation = 0})
                            if optionsList then
                                optionsList:Destroy()
                                optionsList = nil
                            end
                        end)
                    end
                    
                    optionsList:Tween({Size = UDim2.new(0.5, -10, 0, #dropdownOptions.Options * 25)})
                else
                    dropdownArrow:Tween({Rotation = 0})
                    if optionsList then
                        optionsList:Tween({Size = UDim2.new(0.5, -10, 0, 0)}, function()
                            optionsList:Destroy()
                            optionsList = nil
                        end)
                    end
                end
            end)
            
            return dropdownFrame
        end
        
        function tab:Textbox(textboxOptions)
            textboxOptions = textboxOptions or {}
            textboxOptions.Text = textboxOptions.Text or "Textbox"
            textboxOptions.PlaceholderText = textboxOptions.PlaceholderText or "Enter text..."
            textboxOptions.Default = textboxOptions.Default or ""
            textboxOptions.Callback = textboxOptions.Callback or function() end
            
            local textboxFrame = tabContent:Object("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                Theme = {BackgroundColor3 = "Secondary"}
            }):Round(6)
            
            local textboxLabel = textboxFrame:Object("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = textboxOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local textbox = textboxFrame:Object("TextBox", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 25),
                Theme = {BackgroundColor3 = "Surface"},
                Text = textboxOptions.Default,
                PlaceholderText = textboxOptions.PlaceholderText,
                TextSize = 12,
                Theme = {TextColor3 = "PrimaryText"},
                Font = Enum.Font.SourceSans,
                ClearButtonOnFocus = false
            }):Round(4)
            
            Ruvex.flags[textboxOptions.Flag or textboxOptions.Text] = textboxOptions.Default
            
            textbox.FocusLost:Connect(function()
                local value = textbox.Text
                Ruvex.flags[textboxOptions.Flag or textboxOptions.Text] = value
                textboxOptions.Callback(value)
            end)
            
            textbox.Focused:Connect(function()
                textbox:Tween({BackgroundColor3 = Ruvex:Lighten(Ruvex.CurrentTheme.Surface, 10)})
            end)
            
            textbox.FocusLost:Connect(function()
                textbox:Tween({BackgroundColor3 = Ruvex.CurrentTheme.Surface})
            end)
            
            return textboxFrame
        end
        
        function tab:ColorPicker(colorOptions)
            colorOptions = colorOptions or {}
            colorOptions.Text = colorOptions.Text or "Color Picker"
            colorOptions.Default = colorOptions.Default or Color3.fromRGB(255, 255, 255)
            colorOptions.Callback = colorOptions.Callback or function() end
            
            local colorFrame = tabContent:Object("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = "Secondary"}
            }):Round(6)
            
            local colorLabel = colorFrame:Object("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = colorOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans
            })
            
            local colorPreview = colorFrame:Object("TextButton", {
                Size = UDim2.fromOffset(40, 20),
                Position = UDim2.new(1, -45, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = colorOptions.Default,
                Text = ""
            }):Round(4):Stroke(Ruvex.CurrentTheme.Border, 1)
            
            Ruvex.flags[colorOptions.Flag or colorOptions.Text] = colorOptions.Default
            
            colorPreview.MouseButton1Click:Connect(function()
                -- Simple color picker - cycles through predefined colors
                local colors = {
                    Color3.fromRGB(220, 50, 50),   -- Red
                    Color3.fromRGB(50, 220, 50),   -- Green  
                    Color3.fromRGB(50, 50, 220),   -- Blue
                    Color3.fromRGB(220, 220, 50),  -- Yellow
                    Color3.fromRGB(220, 50, 220),  -- Magenta
                    Color3.fromRGB(50, 220, 220),  -- Cyan
                    Color3.fromRGB(255, 255, 255), -- White
                    Color3.fromRGB(0, 0, 0)        -- Black
                }
                
                local currentIndex = 1
                for i, color in ipairs(colors) do
                    if colorPreview.BackgroundColor3 == color then
                        currentIndex = i
                        break
                    end
                end
                
                currentIndex = currentIndex % #colors + 1
                local newColor = colors[currentIndex]
                
                colorPreview:Tween({BackgroundColor3 = newColor})
                Ruvex.flags[colorOptions.Flag or colorOptions.Text] = newColor
                colorOptions.Callback(newColor)
            end)
            
            return colorFrame
        end
        
        function tab:Label(labelOptions)
            labelOptions = labelOptions or {}
            labelOptions.Text = labelOptions.Text or "Label"
            
            local label = tabContent:Object("TextLabel", {
                Size = UDim2.new(1, 0, 0, 25),
                Theme = {
                    BackgroundColor3 = "Secondary",
                    TextColor3 = "PrimaryText"
                },
                Text = labelOptions.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 0,
                Font = Enum.Font.SourceSans
            }):Round(6)
            
            return label
        end
        
        return tab
    end
    
    -- Add resize functionality if enabled
    if options.Resizable then
        local resizeButton = mainFrame:Object("TextButton", {
            Size = UDim2.fromOffset(15, 15),
            Position = UDim2.new(1, -15, 1, -15),
            Theme = {BackgroundColor3 = "Border"},
            Text = "",
            BackgroundTransparency = 0.5
        }):Round(3)
        
        local resizing = false
        
        resizeButton.MouseButton1Down:Connect(function()
            resizing = true
            
            local function resize()
                local mousePos = UserInputService:GetMouseLocation()
                local newSize = UDim2.fromOffset(
                    math.max(options.MinSize.X.Offset, mousePos.X - mainFrame.AbsolutePosition.X + 15),
                    math.max(options.MinSize.Y.Offset, mousePos.Y - mainFrame.AbsolutePosition.Y + 15)
                )
                self:Tween(mainFrame, 0.05, {Size = newSize})
            end
            
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    resize()
                end
            end)
            
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end)
    end
    
    table.insert(self.Windows, window)
    return window
end

-- Notification System (Enhanced from Flux)
function Ruvex:Notification(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Description = options.Description or "This is a notification."
    options.Duration = options.Duration or 5
    options.Type = options.Type or "info" -- info, success, warning, error
    
    local colors = {
        info = self.CurrentTheme.Tertiary,
        success = Color3.fromRGB(50, 220, 50),
        warning = Color3.fromRGB(220, 220, 50),
        error = Color3.fromRGB(220, 50, 50)
    }
    
    -- Create notification GUI
    local notificationGui = self:Create("ScreenGui", {
        Name = "RuvexNotification",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    local notificationFrame = self:Object("Frame", {
        Parent = notificationGui,
        Size = UDim2.fromOffset(350, 80),
        Position = UDim2.new(1, 20, 0, 20),
        Theme = {BackgroundColor3 = "Primary"},
        ZIndex = 1000
    }):Round(8):Stroke(colors[options.Type], 2)
    
    local titleLabel = notificationFrame:Object("TextLabel", {
        Size = UDim2.new(1, -60, 0, 25),
        Position = UDim2.new(0, 15, 0, 8),
        Theme = {
            BackgroundColor3 = "Primary",
            TextColor3 = "PrimaryText"
        },
        Text = options.Title,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold
    })
    
    local descriptionLabel = notificationFrame:Object("TextLabel", {
        Size = UDim2.new(1, -60, 0, 40),
        Position = UDim2.new(0, 15, 0, 30),
        Theme = {
            BackgroundColor3 = "Primary",
            TextColor3 = "SecondaryText"
        },
        Text = options.Description,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        TextWrapped = true
    })
    
    local closeButton = notificationFrame:Object("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -25, 0, 8),
        Theme = {BackgroundColor3 = "Hover"},
        Text = "X",
        TextSize = 12,
        Theme = {TextColor3 = "PrimaryText"},
        Font = Enum.Font.SourceSansBold,
        BackgroundTransparency = 0.5
    }):Round(3)
    
    -- Animation in
    notificationFrame:Tween({Position = UDim2.new(1, -370, 0, 20)})
    
    -- Close functionality
    local function closeNotification()
        notificationFrame:Tween({Position = UDim2.new(1, 20, 0, 20)}, function()
            notificationGui:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    closeButton.MouseEnter:Connect(function()
        closeButton:Tween({BackgroundTransparency = 0.2})
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton:Tween({BackgroundTransparency = 0.5})
    end)
    
    -- Auto close
    if options.Duration > 0 then
        wait(options.Duration)
        closeNotification()
    end
    
    return notificationFrame
end

-- Input Handling System
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Ruvex.ToggleKey then
        Ruvex.Toggled = not Ruvex.Toggled
        
        for _, window in pairs(Ruvex.Windows) do
            if window.Toggle then
                window:Toggle()
            end
        end
    end
end)

-- Configuration Management
function Ruvex:SaveConfig(configName)
    configName = configName or "RuvexConfig"
    
    if writefile then
        local config = {
            flags = self.flags,
            theme = "Dark" -- Always save as dark theme for consistency
        }
        writefile(configName .. ".json", HTTPService:JSONEncode(config))
    end
end

function Ruvex:LoadConfig(configName)
    configName = configName or "RuvexConfig"
    
    if readfile and isfile and isfile(configName .. ".json") then
        local success, config = pcall(function()
            return HTTPService:JSONDecode(readfile(configName .. ".json"))
        end)
        
        if success and config then
            self.flags = config.flags or {}
            if config.theme and self.Themes[config.theme] then
                self:ChangeTheme(config.theme)
            end
        end
    end
end

-- Compatibility Functions
local function getHuiOrCoreGui()
    if syn and syn.protect_gui then
        return CoreGui
    elseif gethui then
        return gethui()
    else
        return CoreGui
    end
end

-- Example Usage Function
function Ruvex:Demo()
    local window = self:CreateWindow({
        Title = "Ruvex Demo",
        Size = UDim2.fromOffset(500, 350),
        Draggable = true,
        Resizable = true
    })
    
    local mainTab = window:Tab({
        Name = "Main",
        Icon = ""
    })
    
    mainTab:Label({Text = "Welcome to Ruvex UI Library!"})
    
    mainTab:Button({
        Text = "Test Button",
        Callback = function()
            Ruvex:Notification({
                Title = "Button Clicked",
                Description = "You clicked the test button!",
                Type = "success"
            })
        end
    })
    
    mainTab:Toggle({
        Text = "Sample Toggle",
        Default = false,
        Callback = function(state)
            print("Toggle state:", state)
        end
    })
    
    mainTab:Slider({
        Text = "Sample Slider",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(value)
            print("Slider value:", value)
        end
    })
    
    mainTab:Dropdown({
        Text = "Sample Dropdown",
        Options = {"Option 1", "Option 2", "Option 3"},
        Default = "Option 1",
        Callback = function(selected)
            print("Selected:", selected)
        end
    })
    
    mainTab:Textbox({
        Text = "Sample Textbox",
        PlaceholderText = "Type something...",
        Callback = function(text)
            print("Text entered:", text)
        end
    })
    
    mainTab:ColorPicker({
        Text = "Sample Color",
        Default = Color3.fromRGB(220, 50, 50),
        Callback = function(color)
            print("Color selected:", color)
        end
    })
    
    local settingsTab = window:Tab({
        Name = "Settings"
    })
    
    settingsTab:Button({
        Text = "Change to Light Theme",
        Callback = function()
            Ruvex:ChangeTheme("Light")
        end
    })
    
    settingsTab:Button({
        Text = "Change to Dark Theme", 
        Callback = function()
            Ruvex:ChangeTheme("Dark")
        end
    })
    
    settingsTab:Toggle({
        Text = "Lock Dragging",
        Default = Ruvex.LockDragging,
        Callback = function(state)
            Ruvex.LockDragging = state
        end
    })
    
    settingsTab:Slider({
        Text = "Drag Speed",
        Min = 1,
        Max = 20,
        Default = math.floor(Ruvex.DragSpeed * 100),
        Callback = function(value)
            Ruvex.DragSpeed = value / 100
        end
    })
    
    return window
end

-- Rainbow Color Functions (Enhanced from Flux)
function Ruvex:GetRainbowColor()
    return Color3.fromHSV(self.RainbowColorValue, 1, 1)
end

function Ruvex:RainbowifyObject(object, property)
    property = property or "BackgroundColor3"
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if object and object.Parent then
            object[property] = self:GetRainbowColor()
        else
            connection:Disconnect()
        end
    end)
    
    return connection
end

-- Initialize the library
Ruvex:LoadConfig()

-- Compatibility with different executors
if syn and syn.protect_gui then
    -- Synapse X compatibility
elseif gethui then
    -- Other executor compatibility
end

return Ruvex
