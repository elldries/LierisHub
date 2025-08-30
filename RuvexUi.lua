
-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- Main Library Object
local Ruvex = {
    Version = "1.0.0",
    Authors = {"Mercury", "Flux", "Cerberus", "CriminalityHud", "PPHUD", "Luminosity"},
    
    -- Color Scheme (Red, Dark, Black, White)
    Colors = {
        Main = Color3.fromRGB(15, 15, 15),           -- Dark Black
        Secondary = Color3.fromRGB(25, 25, 25),      -- Lighter Black
        Tertiary = Color3.fromRGB(35, 35, 35),       -- Dark Gray
        Background = Color3.fromRGB(20, 20, 20),     -- Background Black
        
        Accent = Color3.fromRGB(255, 45, 45),        -- Red Accent
        AccentDark = Color3.fromRGB(200, 35, 35),    -- Darker Red
        AccentLight = Color3.fromRGB(255, 85, 85),   -- Lighter Red
        
        Text = Color3.fromRGB(255, 255, 255),        -- White Text
        TextSecondary = Color3.fromRGB(200, 200, 200), -- Light Gray Text
        TextTertiary = Color3.fromRGB(150, 150, 150),  -- Dim Gray Text
        
        Border = Color3.fromRGB(40, 40, 40),         -- Border Color
        Hover = Color3.fromRGB(30, 30, 30),          -- Hover State
        Active = Color3.fromRGB(45, 45, 45)          -- Active State
    },
    
    -- Theme Management
    ThemeObjects = {
        Main = {},
        Secondary = {},
        Tertiary = {},
        Background = {},
        Accent = {},
        AccentDark = {},
        AccentLight = {},
        Text = {},
        TextSecondary = {},
        TextTertiary = {},
        Border = {},
        Hover = {},
        Active = {}
    },
    
    -- Configuration
    Config = {
        ToggleKey = Enum.KeyCode.RightControl,
        DragSpeed = 0.15,
        AnimationSpeed = 0.2,
        WindowSize = UDim2.fromOffset(700, 500),
        LockDragging = false,
        Toggled = true
    },
    
    -- State Management
    Flags = {},
    Windows = {},
    Notifications = {},
    
    -- Signal System (from CriminalityHud)
    Signal = {}
}

-- Signal Implementation
do
    local Signal = {}
    Signal.__index = Signal

    function Signal.new(name)
        local self = setmetatable({}, Signal)
        self._handlerListHead = false
        self._name = name
        return self
    end

    function Signal:Connect(fn)
        local connection = {
            Connected = true,
            _fn = fn,
            _next = false
        }
        
        if self._handlerListHead then
            connection._next = self._handlerListHead
            self._handlerListHead = connection
        else
            self._handlerListHead = connection
        end
        
        local function disconnect()
            connection.Connected = false
        end
        
        return {Disconnect = disconnect}
    end

    function Signal:Fire(...)
        local handler = self._handlerListHead
        while handler do
            if handler.Connected then
                handler._fn(...)
            end
            handler = handler._next
        end
    end

    Ruvex.Signal = Signal
end

-- Utility Functions
function Ruvex:Create(className, properties, children)
    local instance = Instance.new(className)
    
    -- Apply forced properties
    local forcedProps = {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.SourceSans,
        Text = ""
    }
    
    for prop, value in pairs(forcedProps) do
        pcall(function()
            instance[prop] = value
        end)
    end
    
    -- Apply custom properties
    properties = properties or {}
    for prop, value in pairs(properties) do
        if prop == "Theme" then
            for themeProp, themeValue in pairs(value) do
                if type(themeValue) == "string" then
                    instance[themeProp] = self.Colors[themeValue]
                    table.insert(self.ThemeObjects[themeValue], {instance, themeProp})
                elseif type(themeValue) == "table" then
                    local colorName, adjustment = themeValue[1], themeValue[2] or 0
                    local baseColor = self.Colors[colorName]
                    local modifiedColor = self:AdjustColor(baseColor, adjustment)
                    instance[themeProp] = modifiedColor
                    table.insert(self.ThemeObjects[colorName], {instance, themeProp, adjustment})
                end
            end
        else
            instance[prop] = value
        end
    end
    
    -- Add children
    if children then
        for _, child in pairs(children) do
            child.Parent = instance
        end
    end
    
    return instance
end

function Ruvex:Tween(instance, properties, length, style, direction, callback)
    length = length or self.Config.AnimationSpeed
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    callback = callback or function() end
    
    local tweenInfo = TweenInfo.new(length, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    
    tween.Completed:Connect(callback)
    tween:Play()
    
    return tween
end

function Ruvex:AdjustColor(color, adjustment)
    if adjustment == 0 then return color end
    
    local h, s, v = Color3.toHSV(color)
    
    if adjustment > 0 then
        -- Lighten
        local factor = 1 - (adjustment / 100)
        return Color3.fromHSV(h, math.clamp(s * factor, 0, 1), math.clamp(v / factor, 0, 1))
    else
        -- Darken
        local factor = 1 - (math.abs(adjustment) / 100)
        return Color3.fromHSV(h, math.clamp(s / factor, 0, 1), math.clamp(v * factor, 0, 1))
    end
end

function Ruvex:MakeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
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
    
    frame.InputChanged:Connect(function(input)
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

function Ruvex:UpdateTheme(newColors)
    if newColors then
        for colorName, colorValue in pairs(newColors) do
            self.Colors[colorName] = colorValue
        end
    end
    
    for colorName, objects in pairs(self.ThemeObjects) do
        local themeColor = self.Colors[colorName]
        for _, objData in pairs(objects) do
            local obj, prop, adjustment = objData[1], objData[2], objData[3] or 0
            local finalColor = adjustment ~= 0 and self:AdjustColor(themeColor, adjustment) or themeColor
            obj[prop] = finalColor
        end
    end
end

-- Window Creation
function Ruvex:CreateWindow(options)
    options = options or {}
    options.Title = options.Title or "Ruvex UI"
    options.Size = options.Size or self.Config.WindowSize
    options.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Create main screen GUI
    local screenGui = self:Create("ScreenGui", {
        Name = "RuvexUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui
    })
    
    -- Main window frame
    local mainFrame = self:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 0, 0, 0),
        Position = options.Position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Theme = {BackgroundColor3 = "Main"},
        ClipsDescendants = true,
        Parent = screenGui
    })
    
    -- Add corner rounding
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    -- Window shadow/glow effect
    local shadowFrame = self:Create("ImageLabel", {
        Name = "Shadow",
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891970",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Parent = mainFrame
    })
    
    -- Title bar
    local titleBar = self:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Theme = {BackgroundColor3 = {"Secondary", 5}},
        Parent = mainFrame
    })
    
    -- Title bar corner
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = titleBar
    })
    
    -- Title bar corner mask
    self:Create("Frame", {
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        Theme = {BackgroundColor3 = {"Secondary", 5}},
        Parent = titleBar
    })
    
    -- Window title
    local titleLabel = self:Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Theme = {
            BackgroundColor3 = "Main",
            TextColor3 = "Text"
        },
        BackgroundTransparency = 1,
        Text = options.Title,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Close button
    local closeButton = self:Create("ImageButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://8497487650",
        Theme = {ImageColor3 = "TextSecondary"},
        Parent = titleBar
    })
    
    -- Close button hover effects
    closeButton.MouseEnter:Connect(function()
        self:Tween(closeButton, {ImageColor3 = self.Colors.Accent}, 0.15)
    end)
    
    closeButton.MouseLeave:Connect(function()
        self:Tween(closeButton, {ImageColor3 = self.Colors.TextSecondary}, 0.15)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        self:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Tab container
    local tabContainer = self:Create("Frame", {
        Name = "TabContainer",
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 1, -30),
        Theme = {BackgroundColor3 = {"Secondary", -5}},
        Parent = mainFrame
    })
    
    -- Tab list layout
    self:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabContainer
    })
    
    -- Tab padding
    self:Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = tabContainer
    })
    
    -- Content container
    local contentContainer = self:Create("Frame", {
        Name = "ContentContainer",
        Position = UDim2.new(0, 150, 0, 30),
        Size = UDim2.new(1, -150, 1, -30),
        Theme = {BackgroundColor3 = "Background"},
        Parent = mainFrame
    })
    
    -- Make window draggable
    self:MakeDraggable(mainFrame)
    
    -- Window animation
    self:Tween(mainFrame, {Size = options.Size}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Toggle functionality
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.ToggleKey then
            self.Config.Toggled = not self.Config.Toggled
            if self.Config.Toggled then
                screenGui.Enabled = true
                mainFrame.ClipsDescendants = true
                self:Tween(mainFrame, {Size = options.Size}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, function()
                    mainFrame.ClipsDescendants = false
                end)
            else
                mainFrame.ClipsDescendants = true
                self:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                    screenGui.Enabled = false
                end)
            end
        end
    end)
    
    -- Window methods
    function window:CreateTab(tabName, iconId)
        tabName = tabName or "New Tab"
        iconId = iconId or "rbxassetid://10746039695"
        
        local tab = {}
        tab.Name = tabName
        tab.Sections = {}
        tab.Active = false
        
        -- Tab button
        local tabButton = Ruvex:Create("TextButton", {
            Name = "TabButton",
            Size = UDim2.new(1, 0, 0, 35),
            Theme = {
                BackgroundColor3 = {"Tertiary", -10},
                TextColor3 = "TextTertiary"
            },
            Text = "",
            Parent = tabContainer
        })
        
        -- Tab button corner
        Ruvex:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        -- Tab icon
        local tabIcon = Ruvex:Create("ImageLabel", {
            Name = "TabIcon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 8, 0.5, -10),
            BackgroundTransparency = 1,
            Image = iconId,
            Theme = {ImageColor3 = "TextTertiary"},
            Parent = tabButton
        })
        
        -- Tab text
        local tabText = Ruvex:Create("TextLabel", {
            Name = "TabText",
            Position = UDim2.new(0, 35, 0, 0),
            Size = UDim2.new(1, -35, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Theme = {TextColor3 = "TextTertiary"},
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Tab content frame
        local tabContent = Ruvex:Create("ScrollingFrame", {
            Name = "TabContent",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Ruvex.Colors.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentContainer
        })
        
        -- Tab content layout
        Ruvex:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = tabContent
        })
        
        -- Tab content padding
        Ruvex:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent
        })
        
        -- Tab button hover effects
        tabButton.MouseEnter:Connect(function()
            if not tab.Active then
                Ruvex:Tween(tabButton, {BackgroundColor3 = Ruvex.Colors.Hover}, 0.15)
                Ruvex:Tween(tabText, {TextColor3 = Ruvex.Colors.TextSecondary}, 0.15)
                Ruvex:Tween(tabIcon, {ImageColor3 = Ruvex.Colors.TextSecondary}, 0.15)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tab.Active then
                Ruvex:Tween(tabButton, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.15)
                Ruvex:Tween(tabText, {TextColor3 = Ruvex.Colors.TextTertiary}, 0.15)
                Ruvex:Tween(tabIcon, {ImageColor3 = Ruvex.Colors.TextTertiary}, 0.15)
            end
        end)
        
        -- Tab selection
        tabButton.MouseButton1Click:Connect(function()
            -- Deactivate other tabs
            for _, otherTab in pairs(window.Tabs) do
                if otherTab ~= tab then
                    otherTab.Active = false
                    otherTab.Content.Visible = false
                    Ruvex:Tween(otherTab.Button, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.2)
                    Ruvex:Tween(otherTab.Text, {TextColor3 = Ruvex.Colors.TextTertiary}, 0.2)
                    Ruvex:Tween(otherTab.Icon, {ImageColor3 = Ruvex.Colors.TextTertiary}, 0.2)
                end
            end
            
            -- Activate this tab
            tab.Active = true
            tabContent.Visible = true
            window.CurrentTab = tab
            Ruvex:Tween(tabButton, {BackgroundColor3 = Ruvex.Colors.Accent}, 0.2)
            Ruvex:Tween(tabText, {TextColor3 = Ruvex.Colors.Text}, 0.2)
            Ruvex:Tween(tabIcon, {ImageColor3 = Ruvex.Colors.Text}, 0.2)
        end)
        
        -- Tab methods
        function tab:CreateSection(sectionName)
            sectionName = sectionName or "New Section"
            
            local section = {}
            section.Name = sectionName
            section.Elements = {}
            
            -- Section frame
            local sectionFrame = Ruvex:Create("Frame", {
                Name = "Section",
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = {"Secondary", 5}},
                Parent = tabContent
            })
            
            -- Section corner
            Ruvex:Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = sectionFrame
            })
            
            -- Section title
            local sectionTitle = Ruvex:Create("TextLabel", {
                Name = "SectionTitle",
                Size = UDim2.new(1, 0, 0, 25),
                Position = UDim2.new(0, 15, 0, 5),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                Theme = {TextColor3 = "Text"},
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
            -- Section content container
            local sectionContent = Ruvex:Create("Frame", {
                Name = "SectionContent",
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            -- Section content layout
            local contentLayout = Ruvex:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = sectionContent
            })
            
            -- Section content padding
            Ruvex:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 10),
                Parent = sectionContent
            })
            
            -- Auto-resize section
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
                sectionFrame.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
            end)
            
            -- Section methods
            function section:CreateButton(buttonOptions)
                buttonOptions = buttonOptions or {}
                buttonOptions.Text = buttonOptions.Text or "Button"
                buttonOptions.Callback = buttonOptions.Callback or function() end
                
                local button = Ruvex:Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    Theme = {
                        BackgroundColor3 = {"Tertiary", 5},
                        TextColor3 = "Text"
                    },
                    Text = buttonOptions.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = sectionContent
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = button
                })
                
                -- Button hover effects
                button.MouseEnter:Connect(function()
                    Ruvex:Tween(button, {BackgroundColor3 = Ruvex.Colors.Hover}, 0.15)
                end)
                
                button.MouseLeave:Connect(function()
                    Ruvex:Tween(button, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.15)
                end)
                
                button.MouseButton1Click:Connect(function()
                    Ruvex:Tween(button, {BackgroundColor3 = Ruvex.Colors.Accent}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, function()
                        Ruvex:Tween(button, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.1)
                    end)
                    buttonOptions.Callback()
                end)
                
                return button
            end
            
            function section:CreateToggle(toggleOptions)
                toggleOptions = toggleOptions or {}
                toggleOptions.Text = toggleOptions.Text or "Toggle"
                toggleOptions.Default = toggleOptions.Default or false
                toggleOptions.Callback = toggleOptions.Callback or function() end
                toggleOptions.Flag = toggleOptions.Flag or toggleOptions.Text
                
                local toggleState = toggleOptions.Default
                Ruvex.Flags[toggleOptions.Flag] = toggleState
                
                local toggleFrame = Ruvex:Create("Frame", {
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                -- Toggle checkbox
                local toggleBox = Ruvex:Create("Frame", {
                    Name = "ToggleBox",
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new(0, 0, 0.5, -7.5),
                    Theme = {
                        BackgroundColor3 = toggleState and "Accent" or {"Tertiary", 10},
                        BorderColor3 = "Border"
                    },
                    BorderSizePixel = 1,
                    Parent = toggleFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = toggleBox
                })
                
                -- Toggle checkmark
                local checkmark = Ruvex:Create("ImageLabel", {
                    Name = "Checkmark",
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0.5, -5, 0.5, -5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://4507264584",
                    Theme = {ImageColor3 = "Text"},
                    ImageTransparency = toggleState and 0 or 1,
                    Parent = toggleBox
                })
                
                -- Toggle text
                local toggleText = Ruvex:Create("TextLabel", {
                    Name = "ToggleText",
                    Position = UDim2.new(0, 25, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleOptions.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "Text"},
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                -- Toggle button
                local toggleButton = Ruvex:Create("TextButton", {
                    Name = "ToggleButton",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = toggleFrame
                })
                
                -- Toggle functionality
                toggleButton.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    Ruvex.Flags[toggleOptions.Flag] = toggleState
                    
                    if toggleState then
                        Ruvex:Tween(toggleBox, {BackgroundColor3 = Ruvex.Colors.Accent}, 0.2)
                        Ruvex:Tween(checkmark, {ImageTransparency = 0}, 0.2)
                    else
                        Ruvex:Tween(toggleBox, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.2)
                        Ruvex:Tween(checkmark, {ImageTransparency = 1}, 0.2)
                    end
                    
                    toggleOptions.Callback(toggleState)
                end)
                
                -- Toggle hover effects
                toggleButton.MouseEnter:Connect(function()
                    Ruvex:Tween(toggleBox, {BorderColor3 = Ruvex.Colors.Accent}, 0.15)
                end)
                
                toggleButton.MouseLeave:Connect(function()
                    Ruvex:Tween(toggleBox, {BorderColor3 = Ruvex.Colors.Border}, 0.15)
                end)
                
                local toggleMethods = {}
                function toggleMethods:SetValue(value)
                    toggleState = value
                    Ruvex.Flags[toggleOptions.Flag] = toggleState
                    
                    if toggleState then
                        toggleBox.BackgroundColor3 = Ruvex.Colors.Accent
                        checkmark.ImageTransparency = 0
                    else
                        toggleBox.BackgroundColor3 = Ruvex.Colors.Tertiary
                        checkmark.ImageTransparency = 1
                    end
                    
                    toggleOptions.Callback(toggleState)
                end
                
                function toggleMethods:GetValue()
                    return toggleState
                end
                
                return toggleMethods
            end
            
            function section:CreateSlider(sliderOptions)
                sliderOptions = sliderOptions or {}
                sliderOptions.Text = sliderOptions.Text or "Slider"
                sliderOptions.Min = sliderOptions.Min or 0
                sliderOptions.Max = sliderOptions.Max or 100
                sliderOptions.Default = sliderOptions.Default or sliderOptions.Min
                sliderOptions.Increment = sliderOptions.Increment or 1
                sliderOptions.Callback = sliderOptions.Callback or function() end
                sliderOptions.Flag = sliderOptions.Flag or sliderOptions.Text
                
                local sliderValue = sliderOptions.Default
                Ruvex.Flags[sliderOptions.Flag] = sliderValue
                
                local sliderFrame = Ruvex:Create("Frame", {
                    Name = "Slider",
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                -- Slider title
                local sliderTitle = Ruvex:Create("TextLabel", {
                    Name = "SliderTitle",
                    Size = UDim2.new(0.7, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = sliderOptions.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "Text"},
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                -- Slider value display
                local sliderValueLabel = Ruvex:Create("TextLabel", {
                    Name = "SliderValue",
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = tostring(sliderValue),
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "Accent"},
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderFrame
                })
                
                -- Slider track
                local sliderTrack = Ruvex:Create("Frame", {
                    Name = "SliderTrack",
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 6),
                    Theme = {BackgroundColor3 = {"Tertiary", 10}},
                    Parent = sliderFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = sliderTrack
                })
                
                -- Slider fill
                local sliderFill = Ruvex:Create("Frame", {
                    Name = "SliderFill",
                    Size = UDim2.new((sliderValue - sliderOptions.Min) / (sliderOptions.Max - sliderOptions.Min), 0, 1, 0),
                    Theme = {BackgroundColor3 = "Accent"},
                    Parent = sliderTrack
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = sliderFill
                })
                
                -- Slider handle
                local sliderHandle = Ruvex:Create("Frame", {
                    Name = "SliderHandle",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((sliderValue - sliderOptions.Min) / (sliderOptions.Max - sliderOptions.Min), -6, 0.5, -6),
                    Theme = {BackgroundColor3 = "Text"},
                    Parent = sliderTrack
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = sliderHandle
                })
                
                -- Slider button
                local sliderButton = Ruvex:Create("TextButton", {
                    Name = "SliderButton",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = sliderTrack
                })
                
                -- Slider dragging
                local dragging = false
                
                local function updateSlider(input)
                    local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    local newValue = math.floor((sliderOptions.Min + (sliderOptions.Max - sliderOptions.Min) * percentage) / sliderOptions.Increment + 0.5) * sliderOptions.Increment
                    newValue = math.clamp(newValue, sliderOptions.Min, sliderOptions.Max)
                    
                    sliderValue = newValue
                    Ruvex.Flags[sliderOptions.Flag] = sliderValue
                    sliderValueLabel.Text = tostring(sliderValue)
                    
                    local fillPercentage = (sliderValue - sliderOptions.Min) / (sliderOptions.Max - sliderOptions.Min)
                    Ruvex:Tween(sliderFill, {Size = UDim2.new(fillPercentage, 0, 1, 0)}, 0.1)
                    Ruvex:Tween(sliderHandle, {Position = UDim2.new(fillPercentage, -6, 0.5, -6)}, 0.1)
                    
                    sliderOptions.Callback(sliderValue)
                end
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                sliderButton.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                local sliderMethods = {}
                function sliderMethods:SetValue(value)
                    sliderValue = math.clamp(value, sliderOptions.Min, sliderOptions.Max)
                    Ruvex.Flags[sliderOptions.Flag] = sliderValue
                    sliderValueLabel.Text = tostring(sliderValue)
                    
                    local fillPercentage = (sliderValue - sliderOptions.Min) / (sliderOptions.Max - sliderOptions.Min)
                    sliderFill.Size = UDim2.new(fillPercentage, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(fillPercentage, -6, 0.5, -6)
                    
                    sliderOptions.Callback(sliderValue)
                end
                
                function sliderMethods:GetValue()
                    return sliderValue
                end
                
                return sliderMethods
            end
            
            function section:CreateDropdown(dropdownOptions)
                dropdownOptions = dropdownOptions or {}
                dropdownOptions.Text = dropdownOptions.Text or "Dropdown"
                dropdownOptions.Options = dropdownOptions.Options or {"Option 1", "Option 2"}
                dropdownOptions.Default = dropdownOptions.Default or dropdownOptions.Options[1]
                dropdownOptions.Callback = dropdownOptions.Callback or function() end
                dropdownOptions.Flag = dropdownOptions.Flag or dropdownOptions.Text
                
                local selectedValue = dropdownOptions.Default
                local isOpen = false
                Ruvex.Flags[dropdownOptions.Flag] = selectedValue
                
                local dropdownFrame = Ruvex:Create("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                -- Dropdown main button
                local dropdownButton = Ruvex:Create("TextButton", {
                    Name = "DropdownButton",
                    Size = UDim2.new(1, 0, 0, 30),
                    Theme = {
                        BackgroundColor3 = {"Tertiary", 5},
                        TextColor3 = "Text"
                    },
                    Text = dropdownOptions.Text .. ": " .. selectedValue,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = dropdownButton
                })
                
                -- Dropdown arrow
                local dropdownArrow = Ruvex:Create("ImageLabel", {
                    Name = "DropdownArrow",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -20, 0.5, -6),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6034818372",
                    Theme = {ImageColor3 = "TextSecondary"},
                    Parent = dropdownButton
                })
                
                -- Dropdown options container
                local optionsContainer = Ruvex:Create("Frame", {
                    Name = "OptionsContainer",
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 0),
                    Theme = {BackgroundColor3 = {"Secondary", 10}},
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = dropdownFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = optionsContainer
                })
                
                local optionsLayout = Ruvex:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionsContainer
                })
                
                -- Create option buttons
                for i, option in pairs(dropdownOptions.Options) do
                    local optionButton = Ruvex:Create("TextButton", {
                        Name = "OptionButton",
                        Size = UDim2.new(1, 0, 0, 25),
                        Theme = {
                            BackgroundColor3 = {"Secondary", 10},
                            TextColor3 = "TextSecondary"
                        },
                        Text = option,
                        TextSize = 13,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = optionsContainer
                    })
                    
                    Ruvex:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        Parent = optionButton
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        Ruvex:Tween(optionButton, {BackgroundColor3 = Ruvex.Colors.Hover}, 0.15)
                        Ruvex:Tween(optionButton, {TextColor3 = Ruvex.Colors.Text}, 0.15)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Ruvex:Tween(optionButton, {BackgroundColor3 = Ruvex.Colors.Secondary}, 0.15)
                        Ruvex:Tween(optionButton, {TextColor3 = Ruvex.Colors.TextSecondary}, 0.15)
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedValue = option
                        Ruvex.Flags[dropdownOptions.Flag] = selectedValue
                        dropdownButton.Text = dropdownOptions.Text .. ": " .. selectedValue
                        
                        -- Close dropdown
                        isOpen = false
                        optionsContainer.Visible = false
                        Ruvex:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        Ruvex:Tween(dropdownArrow, {Rotation = 0}, 0.2)
                        
                        dropdownOptions.Callback(selectedValue)
                    end)
                end
                
                -- Dropdown toggle functionality
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    optionsContainer.Visible = isOpen
                    
                    if isOpen then
                        local containerHeight = #dropdownOptions.Options * 25
                        Ruvex:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, containerHeight)}, 0.2)
                        Ruvex:Tween(dropdownArrow, {Rotation = 180}, 0.2)
                    else
                        Ruvex:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        Ruvex:Tween(dropdownArrow, {Rotation = 0}, 0.2)
                    end
                end)
                
                -- Dropdown hover effects
                dropdownButton.MouseEnter:Connect(function()
                    if not isOpen then
                        Ruvex:Tween(dropdownButton, {BackgroundColor3 = Ruvex.Colors.Hover}, 0.15)
                    end
                end)
                
                dropdownButton.MouseLeave:Connect(function()
                    if not isOpen then
                        Ruvex:Tween(dropdownButton, {BackgroundColor3 = Ruvex.Colors.Tertiary}, 0.15)
                    end
                end)
                
                local dropdownMethods = {}
                function dropdownMethods:SetValue(value)
                    if table.find(dropdownOptions.Options, value) then
                        selectedValue = value
                        Ruvex.Flags[dropdownOptions.Flag] = selectedValue
                        dropdownButton.Text = dropdownOptions.Text .. ": " .. selectedValue
                        dropdownOptions.Callback(selectedValue)
                    end
                end
                
                function dropdownMethods:GetValue()
                    return selectedValue
                end
                
                function dropdownMethods:SetOptions(newOptions)
                    dropdownOptions.Options = newOptions
                    -- Clear existing options
                    for _, child in pairs(optionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Recreate options
                    for i, option in pairs(newOptions) do
                        local optionButton = Ruvex:Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 25),
                            Theme = {
                                BackgroundColor3 = {"Secondary", 10},
                                TextColor3 = "TextSecondary"
                            },
                            Text = option,
                            TextSize = 13,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = optionsContainer
                        })
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdownMethods:SetValue(option)
                            isOpen = false
                            optionsContainer.Visible = false
                            Ruvex:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                            Ruvex:Tween(dropdownArrow, {Rotation = 0}, 0.2)
                        end)
                    end
                end
                
                return dropdownMethods
            end
            
            function section:CreateTextbox(textboxOptions)
                textboxOptions = textboxOptions or {}
                textboxOptions.Text = textboxOptions.Text or "Textbox"
                textboxOptions.Placeholder = textboxOptions.Placeholder or "Enter text..."
                textboxOptions.Default = textboxOptions.Default or ""
                textboxOptions.Callback = textboxOptions.Callback or function() end
                textboxOptions.Flag = textboxOptions.Flag or textboxOptions.Text
                
                local textboxValue = textboxOptions.Default
                Ruvex.Flags[textboxOptions.Flag] = textboxValue
                
                local textboxFrame = Ruvex:Create("Frame", {
                    Name = "Textbox",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                -- Textbox title
                local textboxTitle = Ruvex:Create("TextLabel", {
                    Name = "TextboxTitle",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = textboxOptions.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "Text"},
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxFrame
                })
                
                -- Textbox input
                local textboxInput = Ruvex:Create("TextBox", {
                    Name = "TextboxInput",
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 25),
                    Theme = {
                        BackgroundColor3 = {"Tertiary", 5},
                        TextColor3 = "Text",
                        PlaceholderColor3 = "TextTertiary"
                    },
                    Text = textboxValue,
                    PlaceholderText = textboxOptions.Placeholder,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = textboxInput
                })
                
                Ruvex:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = textboxInput
                })
                
                -- Textbox border
                local textboxBorder = Ruvex:Create("UIStroke", {
                    Color = Ruvex.Colors.Border,
                    Thickness = 1,
                    Parent = textboxInput
                })
                
                -- Textbox focus effects
                textboxInput.Focused:Connect(function()
                    Ruvex:Tween(textboxBorder, {Color = Ruvex.Colors.Accent}, 0.15)
                end)
                
                textboxInput.FocusLost:Connect(function(enterPressed)
                    Ruvex:Tween(textboxBorder, {Color = Ruvex.Colors.Border}, 0.15)
                    if enterPressed then
                        textboxValue = textboxInput.Text
                        Ruvex.Flags[textboxOptions.Flag] = textboxValue
                        textboxOptions.Callback(textboxValue)
                    end
                end)
                
                local textboxMethods = {}
                function textboxMethods:SetValue(value)
                    textboxValue = tostring(value)
                    textboxInput.Text = textboxValue
                    Ruvex.Flags[textboxOptions.Flag] = textboxValue
                    textboxOptions.Callback(textboxValue)
                end
                
                function textboxMethods:GetValue()
                    return textboxValue
                end
                
                return textboxMethods
            end
            
            function section:CreateKeybind(keybindOptions)
                keybindOptions = keybindOptions or {}
                keybindOptions.Text = keybindOptions.Text or "Keybind"
                keybindOptions.Default = keybindOptions.Default or Enum.KeyCode.F
                keybindOptions.Callback = keybindOptions.Callback or function() end
                keybindOptions.Flag = keybindOptions.Flag or keybindOptions.Text
                
                local currentKey = keybindOptions.Default
                local isBinding = false
                Ruvex.Flags[keybindOptions.Flag] = currentKey
                
                local keybindFrame = Ruvex:Create("Frame", {
                    Name = "Keybind",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                -- Keybind text
                local keybindText = Ruvex:Create("TextLabel", {
                    Name = "KeybindText",
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybindOptions.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "Text"},
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindFrame
                })
                
                -- Keybind button
                local keybindButton = Ruvex:Create("TextButton", {
                    Name = "KeybindButton",
                    Position = UDim2.new(0.6, 0, 0.5, -12.5),
                    Size = UDim2.new(0.4, 0, 0, 25),
                    Theme = {
                        BackgroundColor3 = {"Secondary", 10},
                        TextColor3 = "TextSecondary"
                    },
                    Text = tostring(currentKey):gsub("Enum.KeyCode.", ""),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    Parent = keybindFrame
                })
                
                Ruvex:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybindButton
                })
                
                -- Keybind functionality
                keybindButton.MouseButton1Click:Connect(function()
                    isBinding = true
                    keybindButton.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            Ruvex.Flags[keybindOptions.Flag] = currentKey
                            keybindButton.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                            isBinding = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                -- Keybind hover effects
                keybindButton.MouseEnter:Connect(function()
                    if not isBinding then
                        Ruvex:Tween(keybindButton, {BackgroundColor3 = Ruvex.Colors.Hover}, 0.15)
                    end
                end)
                
                keybindButton.MouseLeave:Connect(function()
                    if not isBinding then
                        Ruvex:Tween(keybindButton, {BackgroundColor3 = Ruvex.Colors.Secondary}, 0.15)
                    end
                end)
                
                -- Listen for key presses
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode == currentKey and not isBinding then
                        keybindOptions.Callback()
                    end
                end)
                
                local keybindMethods = {}
                function keybindMethods:SetKey(key)
                    currentKey = key
                    Ruvex.Flags[keybindOptions.Flag] = currentKey
                    keybindButton.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                end
                
                function keybindMethods:GetKey()
                    return currentKey
                end
                
                return keybindMethods
            end
            
            function section:CreateLabel(labelText)
                labelText = labelText or "Label"
                
                local labelFrame = Ruvex:Create("Frame", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local label = Ruvex:Create("TextLabel", {
                    Name = "LabelText",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    Theme = {TextColor3 = "TextSecondary"},
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = labelFrame
                })
                
                local labelMethods = {}
                function labelMethods:SetText(text)
                    label.Text = tostring(text)
                end
                
                function labelMethods:GetText()
                    return label.Text
                end
                
                return labelMethods
            end
            
            return section
        end
        
        -- Store tab references
        tab.Button = tabButton
        tab.Text = tabText
        tab.Icon = tabIcon
        tab.Content = tabContent
        
        table.insert(window.Tabs, tab)
        
        -- Auto-select first tab
        if #window.Tabs == 1 then
            tab.Active = true
            tabContent.Visible = true
            window.CurrentTab = tab
            tabButton.BackgroundColor3 = Ruvex.Colors.Accent
            tabText.TextColor3 = Ruvex.Colors.Text
            tabIcon.ImageColor3 = Ruvex.Colors.Text
        end
        
        return tab
    end
    
    -- Store window
    table.insert(self.Windows, window)
    return window
end

-- Notification System (Enhanced from Flux)
function Ruvex:CreateNotification(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Text = options.Text or "This is a notification"
    options.Duration = options.Duration or 5
    options.Type = options.Type or "Info" -- Info, Success, Warning, Error
    
    local typeColors = {
        Info = self.Colors.Accent,
        Success = Color3.fromRGB(45, 255, 45),
        Warning = Color3.fromRGB(255, 200, 45),
        Error = Color3.fromRGB(255, 45, 45)
    }
    
    local notificationFrame = self:Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 320, 1, -100 - (#self.Notifications * 90)),
        Theme = {BackgroundColor3 = {"Secondary", 10}},
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notificationFrame
    })
    
    -- Notification border
    self:Create("UIStroke", {
        Color = typeColors[options.Type],
        Thickness = 2,
        Parent = notificationFrame
    })
    
    -- Notification title
    local notificationTitle = self:Create("TextLabel", {
        Name = "NotificationTitle",
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Theme = {TextColor3 = "Text"},
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notificationFrame
    })
    
    -- Notification text
    local notificationText = self:Create("TextLabel", {
        Name = "NotificationText",
        Position = UDim2.new(0, 15, 0, 28),
        Size = UDim2.new(1, -30, 0, 40),
        BackgroundTransparency = 1,
        Text = options.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Theme = {TextColor3 = "TextSecondary"},
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notificationFrame
    })
    
    -- Close button
    local closeButton = self:Create("ImageButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0, 8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://8497487650",
        Theme = {ImageColor3 = "TextTertiary"},
        Parent = notificationFrame
    })
    
    closeButton.MouseEnter:Connect(function()
        self:Tween(closeButton, {ImageColor3 = self.Colors.Accent}, 0.15)
    end)
    
    closeButton.MouseLeave:Connect(function()
        self:Tween(closeButton, {ImageColor3 = self.Colors.TextTertiary}, 0.15)
    end)
    
    -- Animation in
    self:Tween(notificationFrame, {Position = UDim2.new(1, -320, 1, -100 - (#self.Notifications * 90))}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    table.insert(self.Notifications, notificationFrame)
    
    -- Auto-close after duration
    if options.Duration > 0 then
        spawn(function()
            wait(options.Duration)
            self:CloseNotification(notificationFrame)
        end)
    end
    
    -- Manual close
    closeButton.MouseButton1Click:Connect(function()
        self:CloseNotification(notificationFrame)
    end)
    
    return notificationFrame
end

function Ruvex:CloseNotification(notification)
    -- Animation out
    self:Tween(notification, {
        Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        notification:Destroy()
        
        -- Remove from notifications table
        for i, notif in pairs(self.Notifications) do
            if notif == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
        
        -- Reposition remaining notifications
        for i, notif in pairs(self.Notifications) do
            self:Tween(notif, {Position = UDim2.new(1, -320, 1, -100 - ((i-1) * 90))}, 0.2)
        end
    end)
end

-- Color Picker System
function Ruvex:CreateColorPicker(options)
    options = options or {}
    options.Text = options.Text or "Color Picker"
    options.Default = options.Default or Color3.fromRGB(255, 255, 255)
    options.Callback = options.Callback or function() end
    options.Flag = options.Flag or options.Text
    
    local currentColor = options.Default
    Ruvex.Flags[options.Flag] = currentColor
    
    -- This is a complex component, simplified for now
    local colorFrame = self:Create("Frame", {
        Name = "ColorPicker",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local colorPreview = self:Create("Frame", {
        Name = "ColorPreview",
        Size = UDim2.new(0, 30, 0, 25),
        Position = UDim2.new(1, -35, 0.5, -12.5),
        BackgroundColor3 = currentColor,
        Parent = colorFrame
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorPreview
    })
    
    local colorText = self:Create("TextLabel", {
        Name = "ColorText",
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = options.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Theme = {TextColor3 = "Text"},
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorFrame
    })
    
    local colorMethods = {}
    function colorMethods:SetColor(color)
        currentColor = color
        colorPreview.BackgroundColor3 = color
        Ruvex.Flags[options.Flag] = color
        options.Callback(color)
    end
    
    function colorMethods:GetColor()
        return currentColor
    end
    
    return colorMethods
end

-- Load/Save Configuration System (from CriminalityHud)
function Ruvex:SaveConfig(configName)
    configName = configName or "default"
    
    if not isfolder or not writefile then
        return false
    end
    
    if not isfolder("RuvexConfigs") then
        makefolder("RuvexConfigs")
    end
    
    local configData = {}
    for flag, value in pairs(self.Flags) do
        if type(value) == "userdata" and typeof(value) == "Color3" then
            configData[flag] = {R = value.R, G = value.G, B = value.B, Type = "Color3"}
        else
            configData[flag] = value
        end
    end
    
    local success, result = pcall(function()
        writefile("RuvexConfigs/" .. configName .. ".json", HttpService:JSONEncode(configData))
    end)
    
    return success
end

function Ruvex:LoadConfig(configName)
    configName = configName or "default"
    
    if not isfile or not readfile then
        return false
    end
    
    if not isfile("RuvexConfigs/" .. configName .. ".json") then
        return false
    end
    
    local success, result = pcall(function()
        local configData = HttpService:JSONDecode(readfile("RuvexConfigs/" .. configName .. ".json"))
        
        for flag, value in pairs(configData) do
            if type(value) == "table" and value.Type == "Color3" then
                self.Flags[flag] = Color3.new(value.R, value.G, value.B)
            else
                self.Flags[flag] = value
            end
        end
    end)
    
    return success
end

-- Advanced Features

-- Ripple Effect System
function Ruvex:CreateRipple(button, clickPosition)
    local ripple = self:Create("Frame", {
        Name = "Ripple",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Colors.Accent,
        BackgroundTransparency = 0.8,
        ZIndex = 10,
        Parent = button
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    self:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
        ripple:Destroy()
    end)
end

-- Rainbow Effect System (from Flux)
function Ruvex:CreateRainbowEffect(object, property)
    property = property or "BackgroundColor3"
    
    local rainbowValue = 0
    local rainbowConnection
    
    rainbowConnection = RunService.Heartbeat:Connect(function()
        rainbowValue = rainbowValue + 0.01
        if rainbowValue >= 1 then
            rainbowValue = 0
        end
        
        local hue = rainbowValue
        local color = Color3.fromHSV(hue, 1, 1)
        object[property] = color
    end)
    
    return {
        Disconnect = function()
            rainbowConnection:Disconnect()
        end
    }
end

-- Initialize Ruvex
Ruvex.__index = Ruvex

-- Loading Screen System (from Luminosity)
function Ruvex:CreateLoader(options)
    options = options or {}
    options.Title = options.Title or "Loading"
    options.Subtitle = options.Subtitle or "Please wait..."
    
    local loaderGui = self:Create("ScreenGui", {
        Name = "RuvexLoader",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui
    })
    
    -- Background overlay
    local overlay = self:Create("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        Parent = loaderGui
    })
    
    -- Loading frame
    local loadingFrame = self:Create("Frame", {
        Name = "LoadingFrame",
        Size = UDim2.new(0, 350, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Theme = {BackgroundColor3 = "Main"},
        Parent = overlay
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = loadingFrame
    })
    
    -- Loading title
    local loadingTitle = self:Create("TextLabel", {
        Name = "LoadingTitle",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Theme = {TextColor3 = "Text"},
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = loadingFrame
    })
    
    -- Loading subtitle
    local loadingSubtitle = self:Create("TextLabel", {
        Name = "LoadingSubtitle",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1,
        Text = options.Subtitle,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Theme = {TextColor3 = "TextSecondary"},
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = loadingFrame
    })
    
    -- Loading spinner
    local spinner = self:Create("Frame", {
        Name = "Spinner",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0, 100),
        BackgroundTransparency = 1,
        Parent = loadingFrame
    })
    
    for i = 1, 8 do
        local dot = self:Create("Frame", {
            Name = "Dot" .. i,
            Size = UDim2.new(0, 4, 0, 4),
            Position = UDim2.new(0.5, -2, 0.5, -2),
            Theme = {BackgroundColor3 = "Accent"},
            Parent = spinner
        })
        
        self:Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = dot
        })
        
        -- Position dots in circle
        local angle = (i - 1) * (360 / 8)
        local radian = math.rad(angle)
        local x = math.cos(radian) * 15
        local y = math.sin(radian) * 15
        
        dot.Position = UDim2.new(0.5, x - 2, 0.5, y - 2)
        
        -- Animate dots
        spawn(function()
            while spinner.Parent do
                self:Tween(dot, {BackgroundTransparency = 0.8}, 0.3)
                wait(0.1 * i)
                self:Tween(dot, {BackgroundTransparency = 0}, 0.3)
                wait(0.8 - (0.1 * i))
            end
        end)
    end
    
    -- Loading progress bar
    local progressBar = self:Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(0.8, 0, 0, 4),
        Position = UDim2.new(0.1, 0, 0, 160),
        Theme = {BackgroundColor3 = {"Tertiary", 10}},
        Parent = loadingFrame
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = progressBar
    })
    
    local progressFill = self:Create("Frame", {
        Name = "ProgressFill",
        Size = UDim2.new(0, 0, 1, 0),
        Theme = {BackgroundColor3 = "Accent"},
        Parent = progressBar
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = progressFill
    })
    
    local loaderMethods = {}
    function loaderMethods:SetProgress(percentage)
        percentage = math.clamp(percentage, 0, 100)
        self:Tween(progressFill, {Size = UDim2.new(percentage / 100, 0, 1, 0)}, 0.2)
    end
    
    function loaderMethods:SetText(title, subtitle)
        if title then loadingTitle.Text = title end
        if subtitle then loadingSubtitle.Text = subtitle end
    end
    
    function loaderMethods:Close()
        self:Tween(loadingFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            loaderGui:Destroy()
        end)
    end
    
    return loaderMethods
end

-- Console System (Enhanced from multiple libraries)
function Ruvex:CreateConsole(options)
    options = options or {}
    options.Title = options.Title or "Ruvex Console"
    options.Size = options.Size or UDim2.fromOffset(500, 300)
    
    local console = {}
    console.Messages = {}
    console.Visible = false
    
    local consoleGui = self:Create("ScreenGui", {
        Name = "RuvexConsole",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui
    })
    
    local consoleFrame = self:Create("Frame", {
        Name = "ConsoleFrame",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Theme = {BackgroundColor3 = "Main"},
        ClipsDescendants = true,
        Parent = consoleGui
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = consoleFrame
    })
    
    -- Console title bar
    local consoleTitleBar = self:Create("Frame", {
        Name = "ConsoleTitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Theme = {BackgroundColor3 = {"Secondary", 5}},
        Parent = consoleFrame
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = consoleTitleBar
    })
    
    self:Create("Frame", {
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        Theme = {BackgroundColor3 = {"Secondary", 5}},
        Parent = consoleTitleBar
    })
    
    local consoleTitleLabel = self:Create("TextLabel", {
        Name = "ConsoleTitleLabel",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Title,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Theme = {TextColor3 = "Text"},
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = consoleTitleBar
    })
    
    -- Console close button
    local consoleCloseButton = self:Create("ImageButton", {
        Name = "ConsoleCloseButton",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://8497487650",
        Theme = {ImageColor3 = "TextSecondary"},
        Parent = consoleTitleBar
    })
    
    consoleCloseButton.MouseButton1Click:Connect(function()
        console:Hide()
    end)
    
    -- Console content area
    local consoleContent = self:Create("ScrollingFrame", {
        Name = "ConsoleContent",
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -60),
        Theme = {BackgroundColor3 = "Background"},
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = consoleFrame
    })
    
    local consoleLayout = self:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = consoleContent
    })
    
    self:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = consoleContent
    })
    
    -- Console input area
    local consoleInputFrame = self:Create("Frame", {
        Name = "ConsoleInputFrame",
        Position = UDim2.new(0, 0, 1, -30),
        Size = UDim2.new(1, 0, 0, 30),
        Theme = {BackgroundColor3 = {"Secondary", -5}},
        Parent = consoleFrame
    })
    
    local consoleInput = self:Create("TextBox", {
        Name = "ConsoleInput",
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        Theme = {
            BackgroundColor3 = "Tertiary",
            TextColor3 = "Text",
            PlaceholderColor3 = "TextTertiary"
        },
        PlaceholderText = "Enter command...",
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = consoleInputFrame
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = consoleInput
    })
    
    self:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = consoleInput
    })
    
    self:MakeDraggable(consoleFrame)
    
    -- Console methods
    function console:Log(message, messageType)
        messageType = messageType or "INFO"
        local timestamp = os.date("%H:%M:%S")
        
        local logColors = {
            INFO = self.Colors.TextSecondary,
            WARN = Color3.fromRGB(255, 200, 45),
            ERROR = Color3.fromRGB(255, 45, 45),
            SUCCESS = Color3.fromRGB(45, 255, 45)
        }
        
        local messageFrame = self:Create("Frame", {
            Name = "Message",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = consoleContent
        })
        
        local messageText = self:Create("TextLabel", {
            Name = "MessageText",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = string.format("[%s] [%s] %s", timestamp, messageType, message),
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextColor3 = logColors[messageType] or self.Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = messageFrame
        })
        
        table.insert(console.Messages, {Frame = messageFrame, Text = message, Type = messageType, Time = timestamp})
        
        -- Auto-scroll to bottom
        spawn(function()
            wait(0.1)
            consoleContent.CanvasPosition = Vector2.new(0, consoleContent.CanvasSize.Y.Offset)
        end)
    end
    
    function console:Clear()
        for _, child in pairs(consoleContent:GetChildren()) do
            if child.Name == "Message" then
                child:Destroy()
            end
        end
        console.Messages = {}
    end
    
    function console:Show()
        console.Visible = true
        consoleGui.Enabled = true
        self:Tween(consoleFrame, {Size = options.Size}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
    
    function console:Hide()
        console.Visible = false
        self:Tween(consoleFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            consoleGui.Enabled = false
        end)
    end
    
    function console:Toggle()
        if console.Visible then
            console:Hide()
        else
            console:Show()
        end
    end
    
    -- Console input handling
    consoleInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and consoleInput.Text ~= "" then
            local command = consoleInput.Text
            console:Log("Command executed: " .. command, "INFO")
            consoleInput.Text = ""
            
            -- Execute command if it's a valid Lua expression
            local success, result = pcall(function()
                return loadstring("return " .. command)()
            end)
            
            if success then
                console:Log("Result: " .. tostring(result), "SUCCESS")
            else
                console:Log("Error: " .. tostring(result), "ERROR")
            end
        end
    end)
    
    return console
end

-- Advanced Groupbox System (from Bracket)
function Ruvex:CreateGroupbox(parent, groupboxOptions)
    groupboxOptions = groupboxOptions or {}
    groupboxOptions.Name = groupboxOptions.Name or "Groupbox"
    groupboxOptions.Side = groupboxOptions.Side or "Left"
    
    local groupbox = {}
    groupbox.Elements = {}
    
    local groupboxFrame = self:Create("Frame", {
        Name = "Groupbox",
        Size = UDim2.new(0.48, 0, 0, 40),
        Theme = {BackgroundColor3 = {"Secondary", 5}},
        Parent = parent
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = groupboxFrame
    })
    
    -- Groupbox title
    local groupboxTitle = self:Create("TextLabel", {
        Name = "GroupboxTitle",
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = groupboxOptions.Name,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Theme = {TextColor3 = "Text"},
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = groupboxFrame
    })
    
    -- Groupbox content
    local groupboxContent = self:Create("Frame", {
        Name = "GroupboxContent",
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = groupboxFrame
    })
    
    local groupboxLayout = self:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = groupboxContent
    })
    
    self:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = groupboxContent
    })
    
    -- Auto-resize groupbox
    groupboxLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        groupboxContent.Size = UDim2.new(1, 0, 0, groupboxLayout.AbsoluteContentSize.Y + 10)
        groupboxFrame.Size = UDim2.new(0.48, 0, 0, groupboxLayout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Groupbox element creation methods (similar to section methods)
    function groupbox:CreateButton(buttonOptions)
        -- Same as section:CreateButton but adapted for groupbox
        return parent:CreateButton(buttonOptions)
    end
    
    function groupbox:CreateToggle(toggleOptions)
        -- Same as section:CreateToggle but adapted for groupbox  
        return parent:CreateToggle(toggleOptions)
    end
    
    function groupbox:CreateSlider(sliderOptions)
        -- Same as section:CreateSlider but adapted for groupbox
        return parent:CreateSlider(sliderOptions)
    end
    
    return groupbox
end

-- Advanced Input Validation System
function Ruvex:ValidateInput(value, validation)
    validation = validation or {}
    
    if validation.Required and (not value or value == "") then
        return false, "This field is required"
    end
    
    if validation.MinLength and string.len(value) < validation.MinLength then
        return false, "Minimum " .. validation.MinLength .. " characters required"
    end
    
    if validation.MaxLength and string.len(value) > validation.MaxLength then
        return false, "Maximum " .. validation.MaxLength .. " characters allowed"
    end
    
    if validation.Pattern and not string.match(value, validation.Pattern) then
        return false, validation.PatternError or "Invalid format"
    end
    
    if validation.Custom and type(validation.Custom) == "function" then
        local success, error = validation.Custom(value)
        if not success then
            return false, error or "Validation failed"
        end
    end
    
    return true, nil
end

-- Multi-Selection System (Enhanced from PPHUD)
function Ruvex:CreateMultiSelect(options)
    options = options or {}
    options.Text = options.Text or "Multi Select"
    options.Options = options.Options or {"Option 1", "Option 2", "Option 3"}
    options.Default = options.Default or {}
    options.Callback = options.Callback or function() end
    options.Flag = options.Flag or options.Text
    
    local selectedValues = {}
    for _, value in pairs(options.Default) do
        table.insert(selectedValues, value)
    end
    Ruvex.Flags[options.Flag] = selectedValues
    
    local multiFrame = self:Create("Frame", {
        Name = "MultiSelect",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local multiButton = self:Create("TextButton", {
        Name = "MultiButton",
        Size = UDim2.new(1, 0, 0, 30),
        Theme = {
            BackgroundColor3 = {"Tertiary", 5},
            TextColor3 = "Text"
        },
        Text = options.Text .. ": " .. (#selectedValues > 0 and table.concat(selectedValues, ", ") or "None"),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = multiFrame
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = multiButton
    })
    
    local multiMethods = {}
    function multiMethods:SetValues(values)
        selectedValues = values or {}
        Ruvex.Flags[options.Flag] = selectedValues
        multiButton.Text = options.Text .. ": " .. (#selectedValues > 0 and table.concat(selectedValues, ", ") or "None")
        options.Callback(selectedValues)
    end
    
    function multiMethods:GetValues()
        return selectedValues
    end
    
    function multiMethods:AddValue(value)
        if not table.find(selectedValues, value) then
            table.insert(selectedValues, value)
            multiMethods:SetValues(selectedValues)
        end
    end
    
    function multiMethods:RemoveValue(value)
        local index = table.find(selectedValues, value)
        if index then
            table.remove(selectedValues, index)
            multiMethods:SetValues(selectedValues)
        end
    end
    
    return multiMethods
end

-- Performance Monitor (from CriminalityHud concepts)
function Ruvex:CreatePerformanceMonitor()
    local monitor = {}
    monitor.Stats = {
        FPS = 0,
        Memory = 0,
        Ping = 0
    }
    
    -- FPS Counter
    local lastTime = tick()
    local frameCount = 0
    
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            monitor.Stats.FPS = frameCount
            frameCount = 0
            lastTime = tick()
        end
    end)
    
    function monitor:GetFPS()
        return monitor.Stats.FPS
    end
    
    function monitor:GetMemory()
        return math.floor(collectgarbage("count"))
    end
    
    function monitor:GetPing()
        return LocalPlayer:GetNetworkPing() * 1000
    end
    
    function monitor:GetStats()
        return {
            FPS = monitor:GetFPS(),
            Memory = monitor:GetMemory(),
            Ping = monitor:GetPing()
        }
    end
    
    return monitor
end

-- Theme Preset System
function Ruvex:CreateThemePreset(presetName, colors)
    local preset = {
        Name = presetName,
        Colors = colors or {}
    }
    
    function preset:Apply()
        Ruvex:UpdateTheme(preset.Colors)
    end
    
    return preset
end

-- Default theme presets
Ruvex.Presets = {
    RedDark = Ruvex:CreateThemePreset("Red Dark", {
        Main = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Tertiary = Color3.fromRGB(35, 35, 35),
        Background = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 45, 45),
        AccentDark = Color3.fromRGB(200, 35, 35),
        AccentLight = Color3.fromRGB(255, 85, 85),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        TextTertiary = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 40),
        Hover = Color3.fromRGB(30, 30, 30),
        Active = Color3.fromRGB(45, 45, 45)
    }),
    
    CrimsonNight = Ruvex:CreateThemePreset("Crimson Night", {
        Main = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(20, 20, 30),
        Tertiary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(15, 15, 25),
        Accent = Color3.fromRGB(220, 20, 60),
        AccentDark = Color3.fromRGB(180, 15, 50),
        AccentLight = Color3.fromRGB(255, 60, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        TextTertiary = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 50),
        Hover = Color3.fromRGB(25, 25, 35),
        Active = Color3.fromRGB(40, 40, 50)
    })
}

-- Animation Library (Enhanced)
Ruvex.Animations = {
    -- Fade animations
    FadeIn = function(object, duration)
        return Ruvex:Tween(object, {BackgroundTransparency = 0}, duration or 0.3)
    end,
    
    FadeOut = function(object, duration)
        return Ruvex:Tween(object, {BackgroundTransparency = 1}, duration or 0.3)
    end,
    
    -- Scale animations
    ScaleIn = function(object, duration)
        return Ruvex:Tween(object, {Size = object.Size}, duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end,
    
    ScaleOut = function(object, duration)
        return Ruvex:Tween(object, {Size = UDim2.new(0, 0, 0, 0)}, duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    end,
    
    -- Slide animations
    SlideDown = function(object, distance, duration)
        local currentPos = object.Position
        return Ruvex:Tween(object, {Position = currentPos + UDim2.new(0, 0, 0, distance or 20)}, duration or 0.3)
    end,
    
    SlideUp = function(object, distance, duration)
        local currentPos = object.Position
        return Ruvex:Tween(object, {Position = currentPos - UDim2.new(0, 0, 0, distance or 20)}, duration or 0.3)
    end,
    
    -- Pulse animation
    Pulse = function(object, scale, duration)
        scale = scale or 1.1
        duration = duration or 0.5
        local originalSize = object.Size
        Ruvex:Tween(object, {Size = originalSize * scale}, duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            Ruvex:Tween(object, {Size = originalSize}, duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end)
    end
}

-- Utility Functions (Enhanced from Luminosity)
function Ruvex:GetTextBounds(text, textSize, font, frameSize)
    return TextService:GetTextSize(text, textSize, font or Enum.Font.Gotham, frameSize or Vector2.new(1000, 1000))
end

function Ruvex:FormatNumber(number, decimals)
    decimals = decimals or 0
    return string.format("%." .. decimals .. "f", number)
end

function Ruvex:Lerp(start, goal, t)
    return start + (goal - start) * t
end

function Ruvex:Round(number, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(number * mult + 0.5) / mult
end

function Ruvex:TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function Ruvex:DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = self:DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Device Detection and Responsive Design
function Ruvex:GetDeviceType()
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    
    if viewportSize.X < 768 then
        return "Mobile"
    elseif viewportSize.X < 1024 then
        return "Tablet"
    else
        return "Desktop"
    end
end

function Ruvex:GetScreenInfo()
    local camera = workspace.CurrentCamera
    return {
        ViewportSize = camera.ViewportSize,
        DeviceType = self:GetDeviceType(),
        AspectRatio = camera.ViewportSize.X / camera.ViewportSize.Y
    }
end

-- Error Handling and Debugging
function Ruvex:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Ruvex Error]: " .. tostring(result))
        return nil, result
    end
    return result
end

function Ruvex:DebugLog(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[Ruvex][%s][%s] %s", timestamp, level, message))
end

-- Initialize default configuration
function Ruvex:Initialize(config)
    config = config or {}
    
    -- Merge user config with defaults
    for key, value in pairs(config) do
        if self.Config[key] ~= nil then
            self.Config[key] = value
        end
    end
    
    -- Initialize theme
    self:UpdateTheme()
    
    -- Create performance monitor if requested
    if config.ShowPerformance then
        self.PerformanceMonitor = self:CreatePerformanceMonitor()
    end
    
    self:DebugLog("Ruvex Library Initialized - Version " .. self.Version)
    
    return self
end

-- Version check and update system
function Ruvex:GetVersion()
    return self.Version
end

function Ruvex:TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function Ruvex:DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = self:DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Device Detection and Responsive Design
function Ruvex:GetDeviceType()
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    
    if viewportSize.X < 768 then
        return "Mobile"
    elseif viewportSize.X < 1024 then
        return "Tablet"
    else
        return "Desktop"
    end
end

function Ruvex:GetScreenInfo()
    local camera = workspace.CurrentCamera
    return {
        ViewportSize = camera.ViewportSize,
        DeviceType = self:GetDeviceType(),
        AspectRatio = camera.ViewportSize.X / camera.ViewportSize.Y
    }
end

-- Error Handling and Debugging
function Ruvex:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Ruvex Error]: " .. tostring(result))
        return nil, result
    end
    return result
end

function Ruvex:DebugLog(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[Ruvex][%s][%s] %s", timestamp, level, message))
end

-- Initialize default configuration
function Ruvex:Initialize(config)
    config = config or {}
    
    -- Merge user config with defaults
    for key, value in pairs(config) do
        if self.Config[key] ~= nil then
            self.Config[key] = value
        end
    end
    
    -- Initialize theme
    self:UpdateTheme()
    
    -- Create performance monitor if requested
    if config.ShowPerformance then
        self.PerformanceMonitor = self:CreatePerformanceMonitor()
    end
    
    self:DebugLog("Ruvex Library Initialized - Version " .. self.Version)
    
    return self
end

-- Version check and update system
function Ruvex:GetVersion()
    return self.Version
end

function Ruvex:CheckCompatibility()
    local services = {
        "TweenService",
        "RunService", 
        "UserInputService",
        "Players",
        "TextService",
        "GuiService"
    }
    
    for _, serviceName in pairs(services) do
        local success = pcall(function()
            game:GetService(serviceName)
        end)
        
        if not success then
            self:DebugLog("Service " .. serviceName .. " not available", "ERROR")
            return false
        end
    end
    
    self:DebugLog("All required services available", "SUCCESS")
    return true
end

-- Global hotkey to toggle all Ruvex windows
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Ruvex.Config.ToggleKey then
        for _, window in pairs(Ruvex.Windows) do
            if window.ScreenGui then
                window.ScreenGui.Enabled = not window.ScreenGui.Enabled
            end
        end
    end
end)

-- Return the library
return Ruvex
