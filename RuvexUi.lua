-- Ruvex UI Library - Comprehensive Roblox UI Library
-- Combines elements from Mercury, Flux, Cerberus, Criminality, and PPHud libraries
-- Features: Red/Black/White theme, smooth transitions, modern design, full compatibility

local Ruvex = {
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    Flags = {},
    ThemeObjects = {
        Main = {},
        Secondary = {},
        Tertiary = {},
        Accent = {},
        AccentHover = {},
        AccentDark = {},
        Text = {},
        TextSecondary = {},
        TextDim = {},
        Border = {},
        BorderAccent = {},
        Success = {},
        Warning = {},
        Error = {}
    },
    CurrentTheme = nil,
    Toggled = true,
    ToggleKey = Enum.KeyCode.RightControl
}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Ruvex Color Themes (Red/Black/White)
Ruvex.Themes = {
    Dark = {
        Main = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Tertiary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(220, 50, 47),
        AccentHover = Color3.fromRGB(255, 65, 62),
        AccentDark = Color3.fromRGB(180, 40, 37),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        TextDim = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(45, 45, 45),
        BorderAccent = Color3.fromRGB(220, 50, 47),
        Success = Color3.fromRGB(40, 180, 40),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(220, 50, 47)
    }
}

Ruvex.CurrentTheme = Ruvex.Themes.Dark

-- Rainbow animation
RunService.Heartbeat:Connect(function()
    Ruvex.RainbowColorValue = Ruvex.RainbowColorValue + 1 / 255
    Ruvex.HueSelectionPosition = Ruvex.HueSelectionPosition + 1

    if Ruvex.RainbowColorValue >= 1 then
        Ruvex.RainbowColorValue = 0
    end

    if Ruvex.HueSelectionPosition == 80 then
        Ruvex.HueSelectionPosition = 0
    end
end)

-- Utility Functions
function Ruvex:Tween(object, duration, properties, easingStyle, easingDirection, callback)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

function Ruvex:CreateInstance(className, properties, children)
    local instance = Instance.new(className)
    
    -- Default properties
    if instance:IsA("GuiObject") then
        instance.BorderSizePixel = 0
        if instance:IsA("Frame") then
            instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        elseif instance:IsA("TextButton") or instance:IsA("ImageButton") then
            instance.AutoButtonColor = false
            instance.Text = ""
        elseif instance:IsA("TextLabel") then
            instance.Text = ""
            instance.Font = Enum.Font.SourceSans
        end
    end
    
    -- Apply properties
    if properties then
        for property, value in pairs(properties) do
            if property == "Theme" then
                for themeProp, themeValue in pairs(value) do
                    if type(themeValue) == "table" then
                        local theme, modifier = themeValue[1], themeValue[2] or 0
                        local color = Ruvex.CurrentTheme and Ruvex.CurrentTheme[theme]
                        if color then
                            if modifier ~= 0 then
                                color = Ruvex:ModifyColor(color, modifier)
                            end
                            instance[themeProp] = color
                            -- Безопасная проверка существования таблицы
                            if Ruvex.ThemeObjects[theme] then
                                table.insert(Ruvex.ThemeObjects[theme], {instance, themeProp, theme, modifier})
                            end
                        end
                    else
                        local color = Ruvex.CurrentTheme and Ruvex.CurrentTheme[themeValue]
                        if color then
                            instance[themeProp] = color
                            -- Безопасная проверка существования таблицы
                            if Ruvex.ThemeObjects[themeValue] then
                                table.insert(Ruvex.ThemeObjects[themeValue], {instance, themeProp, themeValue, 0})
                            end
                        end
                    end
                end
            else
                instance[property] = value
            end
        end
    end
    
    -- Add children
    if children then
        for _, child in pairs(children) do
            if child then
                child.Parent = instance
            end
        end
    end
    
    return instance
end

function Ruvex:CreateCorner(radius)
    return Ruvex:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 6)
    })
end

function Ruvex:CreateStroke(color, thickness)
    return Ruvex:CreateInstance("UIStroke", {
        Color = color or Ruvex.CurrentTheme.Border,
        Thickness = thickness or 1
    })
end

function Ruvex:ModifyColor(color, factor)
    local h, s, v = Color3.toHSV(color)
    factor = factor / 100
    if factor > 0 then
        v = math.clamp(v + factor, 0, 1)
    else
        v = math.clamp(v + factor, 0, 1)
    end
    return Color3.fromHSV(h, s, v)
end

function Ruvex:MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Ruvex:Tween(frame, 0.1, {
                Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- Main Window Creation
function Ruvex:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Name or "Ruvex"
    local windowSize = config.Size or UDim2.new(0, 650, 0, 450)
    local windowToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    
    Ruvex.ToggleKey = windowToggleKey
    
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Create ScreenGui
    local screenGui = Ruvex:CreateInstance("ScreenGui", {
        Name = "RuvexUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Main Frame
    local mainFrame = Ruvex:CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        Size = windowSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Theme = {
            BackgroundColor3 = "Main"
        },
        ClipsDescendants = true
    }, {
        Ruvex:CreateCorner(8),
        Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
    })
    
    -- Window Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    Ruvex:Tween(mainFrame, 0.4, {Size = windowSize}, Enum.EasingStyle.Back)
    
    -- Title Bar
    local titleBar = Ruvex:CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {
            BackgroundColor3 = "Secondary"
        }
    }, {
        Ruvex:CreateCorner(8),
        Ruvex:CreateStroke(Ruvex.CurrentTheme.BorderAccent, 1)
    })
    
    -- Hide bottom corners of title bar
    local titleBarBottom = Ruvex:CreateInstance("Frame", {
        Name = "TitleBarBottom",
        Parent = titleBar,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        Theme = {
            BackgroundColor3 = "Secondary"
        }
    })
    
    -- Title Text
    local titleText = Ruvex:CreateInstance("TextLabel", {
        Name = "TitleText",
        Parent = titleBar,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = windowTitle,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Theme = {
            TextColor3 = "Text"
        }
    })
    
    -- Window Controls
    local controlsFrame = Ruvex:CreateInstance("Frame", {
        Name = "Controls",
        Parent = titleBar,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1
    })
    
    local controlsLayout = Ruvex:CreateInstance("UIListLayout", {
        Parent = controlsFrame,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local controlsPadding = Ruvex:CreateInstance("UIPadding", {
        Parent = controlsFrame,
        PaddingRight = UDim.new(0, 15)
    })
    
    -- Minimize Button
    local minimizeBtn = Ruvex:CreateInstance("TextButton", {
        Name = "MinimizeButton",
        Parent = controlsFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Theme = {
            BackgroundColor3 = "Tertiary"
        },
        LayoutOrder = 1
    }, {
        Ruvex:CreateCorner(4)
    })
    
    local minimizeIcon = Ruvex:CreateInstance("TextLabel", {
        Parent = minimizeBtn,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "_",
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        BackgroundTransparency = 1,
        Theme = {
            TextColor3 = "Text"
        }
    })
    
    -- Close Button
    local closeBtn = Ruvex:CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = controlsFrame,
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(220, 50, 47),
        LayoutOrder = 2
    }, {
        Ruvex:CreateCorner(4)
    })
    
    local closeIcon = Ruvex:CreateInstance("TextLabel", {
        Parent = closeBtn,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "×",
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    -- Button Animations
    minimizeBtn.MouseEnter:Connect(function()
        Ruvex:Tween(minimizeBtn, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.AccentHover})
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Ruvex:Tween(minimizeBtn, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Ruvex:Tween(closeBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 65, 62)})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Ruvex:Tween(closeBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(220, 50, 47)})
    end)
    
    -- Tab Container
    local tabContainer = Ruvex:CreateInstance("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 35),
        Theme = {
            BackgroundColor3 = "Tertiary"
        }
    })
    
    local tabContainerStroke = Ruvex:CreateInstance("Frame", {
        Name = "TabStroke",
        Parent = tabContainer,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Theme = {
            BackgroundColor3 = "Border"
        }
    })
    
    local tabScrolling = Ruvex:CreateInstance("ScrollingFrame", {
        Name = "TabScrolling",
        Parent = tabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X
    })
    
    local tabLayout = Ruvex:CreateInstance("UIListLayout", {
        Parent = tabScrolling,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    -- Content Frame
    local contentFrame = Ruvex:CreateInstance("Frame", {
        Name = "ContentFrame",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 1, -65),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1
    })
    
    -- Make window draggable
    Ruvex:MakeDraggable(mainFrame, titleBar)
    
    -- Window Controls Functionality
    local minimized = false
    local originalSize = windowSize
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Ruvex:Tween(mainFrame, 0.3, {Size = UDim2.new(0, originalSize.X.Offset, 0, 35)})
            minimizeIcon.Text = "□"
        else
            Ruvex:Tween(mainFrame, 0.3, {Size = originalSize})
            minimizeIcon.Text = "_"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Ruvex:Tween(mainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Toggle Functionality
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Ruvex.ToggleKey then
            Ruvex.Toggled = not Ruvex.Toggled
            screenGui.Enabled = Ruvex.Toggled
        end
    end)
    
    -- Tab Creation Function
    function window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "New Tab"
        local tabIcon = config.Icon or ""
        
        local tab = {}
        tab.Sections = {}
        tab.LeftSections = {}
        tab.RightSections = {}
        
        -- Tab Button
        local tabButton = Ruvex:CreateInstance("TextButton", {
            Name = "TabButton",
            Parent = tabScrolling,
            Size = UDim2.new(0, 120, 1, 0),
            Theme = {
                BackgroundColor3 = "Tertiary"
            },
            LayoutOrder = #window.Tabs + 1
        })
        
        local tabButtonCorner = Ruvex:CreateCorner(0)
        tabButtonCorner.Parent = tabButton
        
        local tabText = Ruvex:CreateInstance("TextLabel", {
            Name = "TabText",
            Parent = tabButton,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, tabIcon ~= "" and 25 or 10, 0, 0),
            Text = tabName,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Theme = {
                TextColor3 = "TextSecondary"
            }
        })
        
        if tabIcon ~= "" then
            local tabIconLabel = Ruvex:CreateInstance("ImageLabel", {
                Name = "TabIcon",
                Parent = tabButton,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 8, 0.5, -8),
                Image = tabIcon,
                BackgroundTransparency = 1,
                Theme = {
                    ImageColor3 = "TextSecondary"
                }
            })
        end
        
        -- Tab Content
        local tabContent = Ruvex:CreateInstance("Frame", {
            Name = "TabContent",
            Parent = contentFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        })
        
        -- Left and Right Containers
        local leftContainer = Ruvex:CreateInstance("ScrollingFrame", {
            Name = "LeftContainer",
            Parent = tabContent,
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local leftLayout = Ruvex:CreateInstance("UIListLayout", {
            Parent = leftContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local leftPadding = Ruvex:CreateInstance("UIPadding", {
            Parent = leftContainer,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        local rightContainer = Ruvex:CreateInstance("ScrollingFrame", {
            Name = "RightContainer",
            Parent = tabContent,
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local rightLayout = Ruvex:CreateInstance("UIListLayout", {
            Parent = rightContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local rightPadding = Ruvex:CreateInstance("UIPadding", {
            Parent = rightContainer,
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        -- Tab Selection Logic
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, otherTab in pairs(window.Tabs) do
                otherTab.Content.Visible = false
                Ruvex:Tween(otherTab.Button, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                Ruvex:Tween(otherTab.TextLabel, 0.2, {TextColor3 = Ruvex.CurrentTheme.TextSecondary})
                if otherTab.IconLabel then
                    Ruvex:Tween(otherTab.IconLabel, 0.2, {ImageColor3 = Ruvex.CurrentTheme.TextSecondary})
                end
            end
            
            -- Show current tab
            tabContent.Visible = true
            window.CurrentTab = tab
            Ruvex:Tween(tabButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Accent})
            Ruvex:Tween(tabText, 0.2, {TextColor3 = Ruvex.CurrentTheme.Text})
            if tabIcon ~= "" then
                local iconLabel = tabButton:FindFirstChild("TabIcon")
                if iconLabel then
                    Ruvex:Tween(iconLabel, 0.2, {ImageColor3 = Ruvex.CurrentTheme.Text})
                end
            end
        end)
        
        -- Tab Hover Effects
        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Ruvex:Tween(tabButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Secondary})
                Ruvex:Tween(tabText, 0.2, {TextColor3 = Ruvex.CurrentTheme.Text})
                if tabIcon ~= "" then
                    local iconLabel = tabButton:FindFirstChild("TabIcon")
                    if iconLabel then
                        Ruvex:Tween(iconLabel, 0.2, {ImageColor3 = Ruvex.CurrentTheme.Text})
                    end
                end
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Ruvex:Tween(tabButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                Ruvex:Tween(tabText, 0.2, {TextColor3 = Ruvex.CurrentTheme.TextSecondary})
                if tabIcon ~= "" then
                    local iconLabel = tabButton:FindFirstChild("TabIcon")
                    if iconLabel then
                        Ruvex:Tween(iconLabel, 0.2, {ImageColor3 = Ruvex.CurrentTheme.TextSecondary})
                    end
                end
            end
        end)
        
        -- Section Creation Function
        function tab:CreateSection(config)
            config = config or {}
            local sectionName = config.Name or "New Section"
            local sectionSide = config.Side or "Auto"
            
            -- Determine which side to place section
            local container
            if sectionSide == "Left" then
                container = leftContainer
            elseif sectionSide == "Right" then
                container = rightContainer
            else
                -- Auto-balance
                container = (#tab.LeftSections <= #tab.RightSections) and leftContainer or rightContainer
            end
            
            local section = {}
            section.Elements = {}
            
            -- Section Frame
            local sectionFrame = Ruvex:CreateInstance("Frame", {
                Name = "Section",
                Parent = container,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Theme = {
                    BackgroundColor3 = "Secondary"
                }
            }, {
                Ruvex:CreateCorner(6),
                Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
            })
            
            -- Section Header
            local sectionHeader = Ruvex:CreateInstance("Frame", {
                Name = "SectionHeader",
                Parent = sectionFrame,
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {
                    BackgroundColor3 = "Tertiary"
                }
            }, {
                Ruvex:CreateCorner(6)
            })
            
            -- Hide bottom corners of header
            local headerBottom = Ruvex:CreateInstance("Frame", {
                Name = "HeaderBottom",
                Parent = sectionHeader,
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 1, -6),
                Theme = {
                    BackgroundColor3 = "Tertiary"
                }
            })
            
            local sectionTitle = Ruvex:CreateInstance("TextLabel", {
                Name = "SectionTitle",
                Parent = sectionHeader,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                Text = sectionName,
                Font = Enum.Font.SourceSansBold,
                TextSize = 14,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Theme = {
                    TextColor3 = "Text"
                }
            })
            
            -- Section Content
            local sectionContent = Ruvex:CreateInstance("Frame", {
                Name = "SectionContent",
                Parent = sectionFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 35),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            })
            
            local contentLayout = Ruvex:CreateInstance("UIListLayout", {
                Parent = sectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            local contentPadding = Ruvex:CreateInstance("UIPadding", {
                Parent = sectionContent,
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 15)
            })
            
            -- Track section
            if container == leftContainer then
                table.insert(tab.LeftSections, section)
            else
                table.insert(tab.RightSections, section)
            end
            table.insert(tab.Sections, section)
            
            -- UI Elements Creation Functions
            function section:CreateToggle(config)
                config = config or {}
                local toggleName = config.Name or "Toggle"
                local toggleDefault = config.Default or false
                local toggleCallback = config.Callback or function() end
                local toggleFlag = config.Flag
                
                local toggle = {}
                toggle.Value = toggleDefault
                
                if toggleFlag then
                    Ruvex.Flags[toggleFlag] = toggle.Value
                end
                
                -- Toggle Frame
                local toggleFrame = Ruvex:CreateInstance("Frame", {
                    Name = "ToggleFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })
                
                -- Toggle Button
                local toggleButton = Ruvex:CreateInstance("TextButton", {
                    Name = "ToggleButton",
                    Parent = toggleFrame,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 0, 0.5, -10),
                    Theme = {
                        BackgroundColor3 = toggleDefault and "Accent" or "Tertiary"
                    }
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                -- Toggle Checkmark
                local checkmark = Ruvex:CreateInstance("TextLabel", {
                    Name = "Checkmark",
                    Parent = toggleButton,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "✓",
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 12,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = toggleDefault and 0 or 1
                })
                
                -- Toggle Label
                local toggleLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = toggleFrame,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 30, 0, 0),
                    Text = toggleName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Toggle Functionality
                local function updateToggle()
                    if toggle.Value then
                        Ruvex:Tween(toggleButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Accent})
                        Ruvex:Tween(checkmark, 0.2, {TextTransparency = 0})
                    else
                        Ruvex:Tween(toggleButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                        Ruvex:Tween(checkmark, 0.2, {TextTransparency = 1})
                    end
                    
                    if toggleFlag then
                        Ruvex.Flags[toggleFlag] = toggle.Value
                    end
                    
                    toggleCallback(toggle.Value)
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    updateToggle()
                end)
                
                -- Hover Effects
                toggleButton.MouseEnter:Connect(function()
                    if not toggle.Value then
                        Ruvex:Tween(toggleButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Secondary})
                    end
                end)
                
                toggleButton.MouseLeave:Connect(function()
                    if not toggle.Value then
                        Ruvex:Tween(toggleButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                    end
                end)
                
                function toggle:Set(value)
                    toggle.Value = value
                    updateToggle()
                end
                
                return toggle
            end
            
            function section:CreateButton(config)
                config = config or {}
                local buttonName = config.Name or "Button"
                local buttonCallback = config.Callback or function() end
                
                local button = {}
                
                -- Button Frame
                local buttonFrame = Ruvex:CreateInstance("TextButton", {
                    Name = "ButtonFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 35),
                    Text = buttonName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    Theme = {
                        BackgroundColor3 = "Tertiary",
                        TextColor3 = "Text"
                    }
                }, {
                    Ruvex:CreateCorner(6),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                -- Button Effects
                buttonFrame.MouseEnter:Connect(function()
                    Ruvex:Tween(buttonFrame, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Accent})
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    Ruvex:Tween(buttonFrame, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                end)
                
                buttonFrame.MouseButton1Down:Connect(function()
                    Ruvex:Tween(buttonFrame, 0.1, {BackgroundColor3 = Ruvex.CurrentTheme.AccentDark})
                end)
                
                buttonFrame.MouseButton1Up:Connect(function()
                    Ruvex:Tween(buttonFrame, 0.1, {BackgroundColor3 = Ruvex.CurrentTheme.Accent})
                end)
                
                buttonFrame.MouseButton1Click:Connect(function()
                    buttonCallback()
                end)
                
                return button
            end
            
            function section:CreateSlider(config)
                config = config or {}
                local sliderName = config.Name or "Slider"
                local sliderMin = config.Min or 0
                local sliderMax = config.Max or 100
                local sliderDefault = config.Default or sliderMin
                local sliderIncrement = config.Increment or 1
                local sliderCallback = config.Callback or function() end
                local sliderFlag = config.Flag
                
                local slider = {}
                slider.Value = sliderDefault
                slider.Dragging = false
                
                if sliderFlag then
                    Ruvex.Flags[sliderFlag] = slider.Value
                end
                
                -- Slider Frame
                local sliderFrame = Ruvex:CreateInstance("Frame", {
                    Name = "SliderFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1
                })
                
                -- Slider Label
                local sliderLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "SliderLabel",
                    Parent = sliderFrame,
                    Size = UDim2.new(1, -50, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = sliderName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Slider Value Label
                local valueLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "ValueLabel",
                    Parent = sliderFrame,
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    Text = tostring(slider.Value),
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Theme = {
                        TextColor3 = "TextSecondary"
                    }
                })
                
                -- Slider Track
                local sliderTrack = Ruvex:CreateInstance("Frame", {
                    Name = "SliderTrack",
                    Parent = sliderFrame,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -20),
                    Theme = {
                        BackgroundColor3 = "Tertiary"
                    }
                }, {
                    Ruvex:CreateCorner(3)
                })
                
                -- Slider Fill
                local sliderFill = Ruvex:CreateInstance("Frame", {
                    Name = "SliderFill",
                    Parent = sliderTrack,
                    Size = UDim2.new((slider.Value - sliderMin) / (sliderMax - sliderMin), 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Theme = {
                        BackgroundColor3 = "Accent"
                    }
                }, {
                    Ruvex:CreateCorner(3)
                })
                
                -- Slider Handle
                local sliderHandle = Ruvex:CreateInstance("Frame", {
                    Name = "SliderHandle",
                    Parent = sliderTrack,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((slider.Value - sliderMin) / (sliderMax - sliderMin), -6, 0.5, -6),
                    Theme = {
                        BackgroundColor3 = "Text"
                    }
                }, {
                    Ruvex:CreateCorner(6)
                })
                
                -- Slider Input
                local sliderInput = Ruvex:CreateInstance("TextButton", {
                    Name = "SliderInput",
                    Parent = sliderTrack,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ""
                })
                
                -- Slider Functionality
                local function updateSlider(value)
                    value = math.clamp(value, sliderMin, sliderMax)
                    value = math.round(value / sliderIncrement) * sliderIncrement
                    slider.Value = value
                    
                    local percentage = (value - sliderMin) / (sliderMax - sliderMin)
                    
                    Ruvex:Tween(sliderFill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
                    Ruvex:Tween(sliderHandle, 0.1, {Position = UDim2.new(percentage, -6, 0.5, -6)})
                    
                    valueLabel.Text = tostring(value)
                    
                    if sliderFlag then
                        Ruvex.Flags[sliderFlag] = value
                    end
                    
                    sliderCallback(value)
                end
                
                sliderInput.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slider.Dragging = true
                        
                        local function updateFromMouse()
                            local mouse = Mouse
                            local percentage = math.clamp((mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                            local value = sliderMin + (sliderMax - sliderMin) * percentage
                            updateSlider(value)
                        end
                        
                        updateFromMouse()
                        
                        local connection
                        connection = Mouse.Move:Connect(function()
                            if slider.Dragging then
                                updateFromMouse()
                            else
                                connection:Disconnect()
                            end
                        end)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slider.Dragging = false
                    end
                end)
                
                function slider:Set(value)
                    updateSlider(value)
                end
                
                updateSlider(sliderDefault)
                
                return slider
            end
            
            function section:CreateDropdown(config)
                config = config or {}
                local dropdownName = config.Name or "Dropdown"
                local dropdownOptions = config.Options or {"Option 1", "Option 2"}
                local dropdownDefault = config.Default or dropdownOptions[1]
                local dropdownCallback = config.Callback or function() end
                local dropdownFlag = config.Flag
                
                local dropdown = {}
                dropdown.Value = dropdownDefault
                dropdown.Options = dropdownOptions
                dropdown.Open = false
                
                if dropdownFlag then
                    Ruvex.Flags[dropdownFlag] = dropdown.Value
                end
                
                -- Dropdown Frame
                local dropdownFrame = Ruvex:CreateInstance("Frame", {
                    Name = "DropdownFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1
                })
                
                -- Dropdown Label
                local dropdownLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "DropdownLabel",
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = dropdownName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Dropdown Button
                local dropdownButton = Ruvex:CreateInstance("TextButton", {
                    Name = "DropdownButton",
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 1, -25),
                    Theme = {
                        BackgroundColor3 = "Tertiary"
                    }
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                -- Dropdown Text
                local dropdownText = Ruvex:CreateInstance("TextLabel", {
                    Name = "DropdownText",
                    Parent = dropdownButton,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Text = dropdown.Value,
                    Font = Enum.Font.SourceSans,
                    TextSize = 12,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Dropdown Arrow
                local dropdownArrow = Ruvex:CreateInstance("TextLabel", {
                    Name = "DropdownArrow",
                    Parent = dropdownButton,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    Text = "▼",
                    Font = Enum.Font.SourceSans,
                    TextSize = 10,
                    BackgroundTransparency = 1,
                    Theme = {
                        TextColor3 = "TextSecondary"
                    }
                })
                
                -- Dropdown List
                local dropdownList = Ruvex:CreateInstance("Frame", {
                    Name = "DropdownList",
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, #dropdownOptions * 25),
                    Position = UDim2.new(0, 0, 1, 0),
                    Theme = {
                        BackgroundColor3 = "Secondary"
                    },
                    Visible = false,
                    ZIndex = 100
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                local listLayout = Ruvex:CreateInstance("UIListLayout", {
                    Parent = dropdownList,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                -- Create options
                for i, option in ipairs(dropdownOptions) do
                    local optionButton = Ruvex:CreateInstance("TextButton", {
                        Name = "Option",
                        Parent = dropdownList,
                        Size = UDim2.new(1, 0, 0, 25),
                        Text = option,
                        Font = Enum.Font.SourceSans,
                        TextSize = 12,
                        BackgroundTransparency = 1,
                        Theme = {
                            TextColor3 = "Text"
                        },
                        LayoutOrder = i
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        Ruvex:Tween(optionButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Ruvex:Tween(optionButton, 0.2, {BackgroundTransparency = 1})
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        dropdown.Value = option
                        dropdownText.Text = option
                        dropdown.Open = false
                        dropdownList.Visible = false
                        
                        Ruvex:Tween(dropdownArrow, 0.2, {Rotation = 0})
                        
                        if dropdownFlag then
                            Ruvex.Flags[dropdownFlag] = option
                        end
                        
                        dropdownCallback(option)
                    end)
                end
                
                -- Dropdown Functionality
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdown.Open = not dropdown.Open
                    dropdownList.Visible = dropdown.Open
                    
                    if dropdown.Open then
                        Ruvex:Tween(dropdownArrow, 0.2, {Rotation = 180})
                    else
                        Ruvex:Tween(dropdownArrow, 0.2, {Rotation = 0})
                    end
                end)
                
                function dropdown:Set(value)
                    if table.find(dropdown.Options, value) then
                        dropdown.Value = value
                        dropdownText.Text = value
                        
                        if dropdownFlag then
                            Ruvex.Flags[dropdownFlag] = value
                        end
                        
                        dropdownCallback(value)
                    end
                end
                
                function dropdown:SetOptions(options)
                    dropdown.Options = options
                    
                    -- Clear existing options
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new options
                    for i, option in ipairs(options) do
                        local optionButton = Ruvex:CreateInstance("TextButton", {
                            Name = "Option",
                            Parent = dropdownList,
                            Size = UDim2.new(1, 0, 0, 25),
                            Text = option,
                            Font = Enum.Font.SourceSans,
                            TextSize = 12,
                            BackgroundTransparency = 1,
                            Theme = {
                                TextColor3 = "Text"
                            },
                            LayoutOrder = i
                        })
                        
                        optionButton.MouseEnter:Connect(function()
                            Ruvex:Tween(optionButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            Ruvex:Tween(optionButton, 0.2, {BackgroundTransparency = 1})
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdown.Value = option
                            dropdownText.Text = option
                            dropdown.Open = false
                            dropdownList.Visible = false
                            
                            Ruvex:Tween(dropdownArrow, 0.2, {Rotation = 0})
                            
                            if dropdownFlag then
                                Ruvex.Flags[dropdownFlag] = option
                            end
                            
                            dropdownCallback(option)
                        end)
                    end
                    
                    dropdownList.Size = UDim2.new(1, 0, 0, #options * 25)
                end
                
                return dropdown
            end
            
            function section:CreateTextbox(config)
                config = config or {}
                local textboxName = config.Name or "Textbox"
                local textboxPlaceholder = config.Placeholder or "Enter text..."
                local textboxDefault = config.Default or ""
                local textboxCallback = config.Callback or function() end
                local textboxFlag = config.Flag
                
                local textbox = {}
                textbox.Value = textboxDefault
                
                if textboxFlag then
                    Ruvex.Flags[textboxFlag] = textbox.Value
                end
                
                -- Textbox Frame
                local textboxFrame = Ruvex:CreateInstance("Frame", {
                    Name = "TextboxFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1
                })
                
                -- Textbox Label
                local textboxLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "TextboxLabel",
                    Parent = textboxFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = textboxName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Textbox Input
                local textboxInput = Ruvex:CreateInstance("TextBox", {
                    Name = "TextboxInput",
                    Parent = textboxFrame,
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 1, -25),
                    Text = textboxDefault,
                    PlaceholderText = textboxPlaceholder,
                    Font = Enum.Font.SourceSans,
                    TextSize = 12,
                    Theme = {
                        BackgroundColor3 = "Tertiary",
                        TextColor3 = "Text",
                        PlaceholderColor3 = "TextDim"
                    },
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearButtonOnFocus = false
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                local inputPadding = Ruvex:CreateInstance("UIPadding", {
                    Parent = textboxInput,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                })
                
                -- Textbox Functionality
                textboxInput.FocusLost:Connect(function(enterPressed)
                    textbox.Value = textboxInput.Text
                    
                    if textboxFlag then
                        Ruvex.Flags[textboxFlag] = textbox.Value
                    end
                    
                    textboxCallback(textbox.Value, enterPressed)
                end)
                
                function textbox:Set(value)
                    textbox.Value = value
                    textboxInput.Text = value
                    
                    if textboxFlag then
                        Ruvex.Flags[textboxFlag] = value
                    end
                    
                    textboxCallback(value, false)
                end
                
                return textbox
            end
            
            function section:CreateColorPicker(config)
                config = config or {}
                local colorName = config.Name or "Color Picker"
                local colorDefault = config.Default or Color3.fromRGB(255, 0, 0)
                local colorCallback = config.Callback or function() end
                local colorFlag = config.Flag
                
                local colorPicker = {}
                colorPicker.Value = colorDefault
                colorPicker.Open = false
                
                if colorFlag then
                    Ruvex.Flags[colorFlag] = colorPicker.Value
                end
                
                -- Color Picker Frame
                local colorFrame = Ruvex:CreateInstance("Frame", {
                    Name = "ColorFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1
                })
                
                -- Color Label
                local colorLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "ColorLabel",
                    Parent = colorFrame,
                    Size = UDim2.new(1, -35, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = colorName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Color Display
                local colorDisplay = Ruvex:CreateInstance("TextButton", {
                    Name = "ColorDisplay",
                    Parent = colorFrame,
                    Size = UDim2.new(0, 30, 0, 25),
                    Position = UDim2.new(1, -30, 1, -25),
                    BackgroundColor3 = colorDefault,
                    Text = ""
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                -- Rainbow animation for color picker
                local colorConnection
                colorConnection = RunService.Heartbeat:Connect(function()
                    if not colorDisplay.Parent then
                        colorConnection:Disconnect()
                        return
                    end
                    
                    if colorPicker.Open then
                        colorDisplay.BackgroundColor3 = Color3.fromHSV(Ruvex.RainbowColorValue, 1, 1)
                    end
                end)
                
                colorDisplay.MouseButton1Click:Connect(function()
                    colorPicker.Open = not colorPicker.Open
                    if colorPicker.Open then
                        -- Simple rainbow color picker
                        colorDisplay.BackgroundColor3 = Color3.fromHSV(Ruvex.RainbowColorValue, 1, 1)
                        colorPicker.Value = colorDisplay.BackgroundColor3
                        
                        if colorFlag then
                            Ruvex.Flags[colorFlag] = colorPicker.Value
                        end
                        
                        colorCallback(colorPicker.Value)
                    end
                end)
                
                function colorPicker:Set(color)
                    colorPicker.Value = color
                    colorDisplay.BackgroundColor3 = color
                    
                    if colorFlag then
                        Ruvex.Flags[colorFlag] = color
                    end
                    
                    colorCallback(color)
                end
                
                return colorPicker
            end
            
            function section:CreateKeybind(config)
                config = config or {}
                local keybindName = config.Name or "Keybind"
                local keybindDefault = config.Default or Enum.KeyCode.F
                local keybindCallback = config.Callback or function() end
                local keybindFlag = config.Flag
                
                local keybind = {}
                keybind.Value = keybindDefault
                keybind.Listening = false
                
                if keybindFlag then
                    Ruvex.Flags[keybindFlag] = keybind.Value
                end
                
                -- Keybind Frame
                local keybindFrame = Ruvex:CreateInstance("Frame", {
                    Name = "KeybindFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })
                
                -- Keybind Label
                local keybindLabel = Ruvex:CreateInstance("TextLabel", {
                    Name = "KeybindLabel",
                    Parent = keybindFrame,
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = keybindName,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Theme = {
                        TextColor3 = "Text"
                    }
                })
                
                -- Keybind Button
                local keybindButton = Ruvex:CreateInstance("TextButton", {
                    Name = "KeybindButton",
                    Parent = keybindFrame,
                    Size = UDim2.new(0, 75, 0, 25),
                    Position = UDim2.new(1, -75, 0.5, -12.5),
                    Text = tostring(keybindDefault):gsub("Enum.KeyCode.", ""),
                    Font = Enum.Font.SourceSans,
                    TextSize = 11,
                    Theme = {
                        BackgroundColor3 = "Tertiary",
                        TextColor3 = "Text"
                    }
                }, {
                    Ruvex:CreateCorner(4),
                    Ruvex:CreateStroke(Ruvex.CurrentTheme.Border, 1)
                })
                
                -- Keybind Functionality
                keybindButton.MouseButton1Click:Connect(function()
                    if not keybind.Listening then
                        keybind.Listening = true
                        keybindButton.Text = "..."
                        Ruvex:Tween(keybindButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Accent})
                    end
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        keybind.Listening = false
                        keybind.Value = input.KeyCode
                        keybindButton.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        Ruvex:Tween(keybindButton, 0.2, {BackgroundColor3 = Ruvex.CurrentTheme.Tertiary})
                        
                        if keybindFlag then
                            Ruvex.Flags[keybindFlag] = keybind.Value
                        end
                    end
                    
                    if not gameProcessed and input.KeyCode == keybind.Value then
                        keybindCallback()
                    end
                end)
                
                function keybind:Set(keycode)
                    keybind.Value = keycode
                    keybindButton.Text = tostring(keycode):gsub("Enum.KeyCode.", "")
                    
                    if keybindFlag then
                        Ruvex.Flags[keybindFlag] = keycode
                    end
                end
                
                return keybind
            end
            
            function section:CreateLabel(config)
                config = config or {}
                local labelText = config.Text or "Label"
                local labelSize = config.Size or 13
                
                local label = {}
                
                -- Label Frame
                local labelFrame = Ruvex:CreateInstance("TextLabel", {
                    Name = "LabelFrame",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = labelText,
                    Font = Enum.Font.SourceSans,
                    TextSize = labelSize,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Theme = {
                        TextColor3 = "TextSecondary"
                    }
                })
                
                function label:Set(text)
                    labelFrame.Text = text
                end
                
                return label
            end
            
            function section:CreateSeparator()
                local separator = Ruvex:CreateInstance("Frame", {
                    Name = "Separator",
                    Parent = sectionContent,
                    Size = UDim2.new(1, 0, 0, 10),
                    BackgroundTransparency = 1
                })
                
                local line = Ruvex:CreateInstance("Frame", {
                    Name = "Line",
                    Parent = separator,
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Theme = {
                        BackgroundColor3 = "Border"
                    }
                })
                
                return separator
            end
            
            return section
        end
        
        -- Store tab data
        tab.Button = tabButton
        tab.Content = tabContent
        tab.TextLabel = tabText
        tab.IconLabel = tabIcon ~= "" and tabButton:FindFirstChild("TabIcon") or nil
        table.insert(window.Tabs, tab)
        
        -- Select first tab by default
        if #window.Tabs == 1 then
            tabButton.MouseButton1Click:Connect(function() end)()
        end
        
        return tab
    end
    
    -- Notification System
    function window:CreateNotification(config)
        config = config or {}
        local title = config.Title or "Notification"
        local text = config.Text or "This is a notification"
        local duration = config.Duration or 3
        local notifType = config.Type or "Info"
        
        local notificationFrame = Ruvex:CreateInstance("Frame", {
            Name = "Notification",
            Parent = screenGui,
            Size = UDim2.new(0, 300, 0, 80),
            Position = UDim2.new(1, 10, 1, -100),
            Theme = {
                BackgroundColor3 = "Secondary"
            },
            ZIndex = 1000
        }, {
            Ruvex:CreateCorner(8),
            Ruvex:CreateStroke(Ruvex.CurrentTheme.BorderAccent, 1)
        })
        
        local notifTitle = Ruvex:CreateInstance("TextLabel", {
            Name = "NotifTitle",
            Parent = notificationFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 10),
            Text = title,
            Font = Enum.Font.SourceSansBold,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Theme = {
                TextColor3 = "Text"
            }
        })
        
        local notifText = Ruvex:CreateInstance("TextLabel", {
            Name = "NotifText",
            Parent = notificationFrame,
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 35),
            Text = text,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Theme = {
                TextColor3 = "TextSecondary"
            }
        })
        
        -- Animate in
        Ruvex:Tween(notificationFrame, 0.3, {Position = UDim2.new(1, -310, 1, -100)})
        
        -- Auto remove
        task.spawn(function()
            task.wait(duration)
            Ruvex:Tween(notificationFrame, 0.3, {Position = UDim2.new(1, 10, 1, -100)}, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                notificationFrame:Destroy()
            end)
        end)
    end
    
    return window
end

-- Usage Example
--[[
    
    -- Load the Ruvex library
    local Ruvex = loadstring(game:HttpGet("path/to/ruvex.lua"))()
    
    -- Create a window
    local Window = Ruvex:CreateWindow({
        Name = "Ruvex UI Library",
        Size = UDim2.new(0, 650, 0, 450),
        ToggleKey = Enum.KeyCode.RightControl
    })
    
    -- Create tabs
    local MainTab = Window:CreateTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998"
    })
    
    local SettingsTab = Window:CreateTab({
        Name = "Settings",
        Icon = "rbxassetid://4483345998"
    })
    
    -- Create sections in the main tab
    local CombatSection = MainTab:CreateSection({
        Name = "Combat",
        Side = "Left"
    })
    
    local MovementSection = MainTab:CreateSection({
        Name = "Movement", 
        Side = "Right"
    })
    
    -- Add UI elements to sections
    local aimbot = CombatSection:CreateToggle({
        Name = "Aimbot",
        Default = false,
        Callback = function(value)
            print("Aimbot:", value)
        end,
        Flag = "Aimbot"
    })
    
    local aimbotKey = CombatSection:CreateKeybind({
        Name = "Aimbot Key",
        Default = Enum.KeyCode.E,
        Callback = function()
            print("Aimbot key pressed!")
        end,
        Flag = "AimbotKey"
    })
    
    local fov = CombatSection:CreateSlider({
        Name = "FOV",
        Min = 50,
        Max = 200,
        Default = 90,
        Increment = 1,
        Callback = function(value)
            print("FOV:", value)
        end,
        Flag = "FOV"
    })
    
    local weapon = CombatSection:CreateDropdown({
        Name = "Weapon",
        Options = {"AK47", "M4A4", "AWP", "Deagle"},
        Default = "AK47",
        Callback = function(value)
            print("Selected weapon:", value)
        end,
        Flag = "Weapon"
    })
    
    local crosshairColor = CombatSection:CreateColorPicker({
        Name = "Crosshair Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color)
            print("Crosshair color:", color)
        end,
        Flag = "CrosshairColor"
    })
    
    local speed = MovementSection:CreateSlider({
        Name = "Speed",
        Min = 16,
        Max = 100,
        Default = 16,
        Increment = 1,
        Callback = function(value)
            print("Speed:", value)
        end,
        Flag = "Speed"
    })
    
    local jumpHeight = MovementSection:CreateSlider({
        Name = "Jump Height",
        Min = 50,
        Max = 200,
        Default = 50,
        Increment = 5,
        Callback = function(value)
            print("Jump Height:", value)
        end,
        Flag = "JumpHeight"
    })
    
    local fly = MovementSection:CreateToggle({
        Name = "Fly",
        Default = false,
        Callback = function(value)
            print("Fly:", value)
        end,
        Flag = "Fly"
    })
    
    local playerName = MovementSection:CreateTextbox({
        Name = "Player Name",
        Placeholder = "Enter player name...",
        Default = "",
        Callback = function(value)
            print("Player name:", value)
        end,
        Flag = "PlayerName"
    })
    
    MovementSection:CreateSeparator()
    
    MovementSection:CreateLabel({
        Text = "Movement settings for enhanced gameplay"
    })
    
    local resetButton = MovementSection:CreateButton({
        Name = "Reset Settings",
        Callback = function()
            aimbot:Set(false)
            speed:Set(16)
            jumpHeight:Set(50)
            fly:Set(false)
            print("Settings reset!")
        end
    })
    
    -- Settings tab
    local GeneralSection = SettingsTab:CreateSection({
        Name = "General",
        Side = "Left"
    })
    
    local themes = GeneralSection:CreateDropdown({
        Name = "Theme",
        Options = {"Dark", "Light", "Blue", "Green"},
        Default = "Dark",
        Callback = function(value)
            print("Theme changed to:", value)
        end,
        Flag = "Theme"
    })
    
    local autoSave = GeneralSection:CreateToggle({
        Name = "Auto Save",
        Default = true,
        Callback = function(value)
            print("Auto save:", value)
        end,
        Flag = "AutoSave"
    })
    
    local configName = GeneralSection:CreateTextbox({
        Name = "Config Name",
        Placeholder = "default",
        Default = "default",
        Callback = function(value)
            print("Config name:", value)
        end,
        Flag = "ConfigName"
    })
    
    local saveButton = GeneralSection:CreateButton({
        Name = "Save Config",
        Callback = function()
            -- Save configuration logic here
            Window:CreateNotification({
                Title = "Config Saved",
                Text = "Your configuration has been saved successfully!",
                Duration = 3,
                Type = "Success"
            })
        end
    })
    
    local loadButton = GeneralSection:CreateButton({
        Name = "Load Config",
        Callback = function()
            -- Load configuration logic here
            Window:CreateNotification({
                Title = "Config Loaded", 
                Text = "Configuration loaded successfully!",
                Duration = 3,
                Type = "Info"
            })
        end
    })
    
    -- Access flag values
    print("Current aimbot state:", Ruvex.Flags.Aimbot)
    print("Current FOV:", Ruvex.Flags.FOV)
    
--]]

return Ruvex
