--[[
  ██████  ██    ██ ██    ██ ███████ ██   ██           
  ██   ██ ██    ██ ██    ██ ██       ██ ██            
  ██████  ██    ██ ██    ██ █████     ███             
  ██   ██ ██    ██  ██  ██  ██       ██ ██            
  ██   ██  ██████    ████   ███████ ██   ██           

  Made by: elldries
  Discord: elldries
  Discord server: https://discord.gg/ZRzAUtZsBj
--]]

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil

-- Main Ruvex Library
local Ruvex = {}
Ruvex.RainbowColorValue = 0
Ruvex.HueSelectionPosition = 0
Ruvex.Toggled = true
Ruvex.ToggleKey = Enum.KeyCode.RightControl
Ruvex.flags = {}

-- Color Themes (Mercury + PPHud inspired)
Ruvex.Themes = {
    Main = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(35, 35, 40),
    Tertiary = Color3.fromRGB(255, 45, 45),
    Background = Color3.fromRGB(15, 15, 20),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(180, 180, 180),
    Divider = Color3.fromRGB(50, 50, 55),
    Accent = Color3.fromRGB(255, 45, 45),
    Hovering = Color3.fromRGB(45, 45, 50)
}

-- Theme Objects for live updates
Ruvex.ThemeObjects = {}
for themeName in pairs(Ruvex.Themes) do
    Ruvex.ThemeObjects[themeName] = {}
end

-- Rainbow Effect (Flux inspired)
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
function Ruvex:set_defaults(defaults, options)
    defaults = defaults or {}
    options = options or {}
    for option, value in next, options do
        defaults[option] = value
    end
    return defaults
end

function Ruvex:darken(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s/f, 0, 1), math.clamp(v*f, 0, 1))
end

function Ruvex:lighten(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s*f, 0, 1), math.clamp(v/f, 0, 1))
end

function Ruvex:GetXY(GuiObject)
    if not Mouse then return 0, 0 end
    local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
    return Px/Max, Py/May
end

function Ruvex:Round(Number, Increment)
    if not Number or not Increment then return 0 end
    Increment = 1 / Increment
    return math.round(Number * Increment) / Increment
end

-- Simple Tween Function (Criminality inspired)
function Ruvex:tween(instance, properties, callback)
    if not instance then return end
    
    local tweenInfo = TweenInfo.new(
        properties.Length or 0.2,
        properties.Style or Enum.EasingStyle.Quart,
        properties.Direction or Enum.EasingDirection.Out
    )
    
    -- Remove tween properties from the properties table
    local cleanProps = {}
    for prop, value in pairs(properties) do
        if prop ~= "Length" and prop ~= "Style" and prop ~= "Direction" then
            cleanProps[prop] = value
        end
    end
    
    local tween = TweenService:Create(instance, tweenInfo, cleanProps)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

-- Object Creation Function
function Ruvex:create(class, properties)
    local localObject = Instance.new(class)

    local forcedProps = {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = ""
    }

    for property, value in next, forcedProps do
        pcall(function()
            localObject[property] = value
        end)
    end

    local methods = {}
    methods.AbsoluteObject = localObject

    function methods:tween(options, callback)
        return Ruvex:tween(localObject, options, callback)
    end

    function methods:round(radius)
        radius = radius or 6
        Ruvex:create("UICorner", {
            Parent = localObject,
            CornerRadius = UDim.new(0, radius)
        })
        return methods
    end

    function methods:create(class, properties)
        local properties = properties or {}
        properties.Parent = localObject
        return Ruvex:create(class, properties)
    end

    function methods:stroke(color, thickness, strokeMode)
        thickness = thickness or 0.5  -- Thinner borders
        strokeMode = strokeMode or Enum.ApplyStrokeMode.Border
        local stroke = self:create("UIStroke", {
            ApplyStrokeMode = strokeMode,
            Thickness = thickness
        })

        if type(color) == "string" then
            local themeColor = Ruvex.Themes[color]
            stroke.Color = themeColor
            table.insert(Ruvex.ThemeObjects[color], {stroke, "Color", color, 0})
        else
            stroke.Color = color
        end

        return methods
    end

    -- Handle Theme properties
    local customHandlers = {
        Theme = function(value)
            for property, obj in next, value do
                if type(obj) == "table" then
                    local theme, colorAlter = obj[1], obj[2] or 0
                    local themeColor = Ruvex.Themes[theme]
                    local modifiedColor = themeColor
                    if colorAlter < 0 then
                        modifiedColor = Ruvex:darken(themeColor, -1 * colorAlter)
                    elseif colorAlter > 0 then
                        modifiedColor = Ruvex:lighten(themeColor, colorAlter)
                    end
                    localObject[property] = modifiedColor
                    table.insert(Ruvex.ThemeObjects[theme], {methods, property, theme, colorAlter})
                else
                    local themeColor = Ruvex.Themes[obj]
                    if themeColor then
                        localObject[property] = themeColor
                        table.insert(Ruvex.ThemeObjects[obj], {methods, property, obj, 0})
                    end
                end
            end
        end,
        Centered = function(value)
            if value then
                localObject.AnchorPoint = Vector2.new(0.5, 0.5)
                localObject.Position = UDim2.fromScale(0.5, 0.5)
            end
        end
    }

    for property, value in next, properties do
        if customHandlers[property] then
            customHandlers[property](value)
        else
            pcall(function()
                localObject[property] = value
            end)
        end
    end

    return setmetatable(methods, {
        __index = function(_, property)
            return localObject[property]
        end,
        __newindex = function(_, property, value)
            localObject[property] = value
        end,
    })
end

-- Simple Draggable Function (Criminality inspired)
function Ruvex:MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

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
            Update(input)
        end
    end)
end

-- Main Window Function (Mercury inspired design)
function Ruvex:Window(options)
    options = Ruvex:set_defaults({
        Name = "Ruvex",
        Size = UDim2.fromOffset(700, 500),
        CloseKey = Enum.KeyCode.RightControl,
        Theme = Ruvex.Themes
    }, options)

    local gui = Ruvex:create("ScreenGui", {
        Parent = (RunService:IsStudio() and LocalPlayer and LocalPlayer.PlayerGui) or CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Name = "RuvexUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    })

    -- Main frame (no shadows for cleaner look)
    local mainFrame = gui:create("Frame", {
        Size = options.Size,
        Theme = {BackgroundColor3 = "Main"},
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = false
    }):round(12)

    -- Title Bar
    local titleBar = mainFrame:create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 0, 0, 0)
    }):round(12)

    local titleBarHiding = titleBar:create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 12)
    })

    local titleBarDivider = titleBar:create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Tertiary"},
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2)
    })

    local titleText = titleBar:create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Theme = {
            BackgroundColor3 = "Secondary",
            TextColor3 = "StrongText"
        },
        BackgroundTransparency = 1,
        Text = options.Name,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local titlePadding = titleText:create("UIPadding", {
        PaddingLeft = UDim.new(0, 15)
    })

    -- Window Controls (Cerberus inspired)
    local controlsContainer = titleBar:create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 65, 0, 22),
        BackgroundTransparency = 1
    })

    -- Minimize Button
    local minimizeButton = controlsContainer:create("TextButton", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 28, 0, 22),
        Theme = {BackgroundColor3 = "Secondary"},
        BackgroundTransparency = 0.3,
        Text = "−",
        Theme = {TextColor3 = "StrongText"},
        TextSize = 16,
        Font = Enum.Font.GothamBold
    }):round(6)

    minimizeButton:stroke("Divider", 0.5)

    -- Close Button  
    local closeButton = controlsContainer:create("TextButton", {
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(0, 28, 0, 22),
        Theme = {BackgroundColor3 = "Tertiary"},
        BackgroundTransparency = 0.1,
        Text = "×",
        Theme = {TextColor3 = "StrongText"},
        TextSize = 16,
        Font = Enum.Font.GothamBold
    }):round(6)

    closeButton:stroke("Tertiary", 0.5)

    -- Simple minimize functionality
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        if not isMinimized then
            mainFrame:tween({
                Size = UDim2.new(options.Size.X.Scale, options.Size.X.Offset, 0, 35),
                Length = 0.2
            })
            minimizeButton.Text = "+"
            isMinimized = true
        else
            mainFrame:tween({
                Size = options.Size,
                Length = 0.2
            })
            minimizeButton.Text = "−"
            isMinimized = false
        end
    end)

    -- Simple button hover effects (Mercury inspired)
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton:tween{BackgroundTransparency = 0.1, Length = 0.15}
    end)

    minimizeButton.MouseLeave:Connect(function()
        minimizeButton:tween{BackgroundTransparency = 0.3, Length = 0.15}
    end)

    -- Simple close button - no complex animations
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    closeButton.MouseEnter:Connect(function()
        closeButton:tween{BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(220, 38, 38), Length = 0.15}
    end)

    closeButton.MouseLeave:Connect(function()
        closeButton:tween{BackgroundTransparency = 0.1, BackgroundColor3 = Ruvex.Themes.Tertiary, Length = 0.15}
    end)

    -- Tab Container (Mercury inspired)
    local tabContainer = mainFrame:create("ScrollingFrame", {
        Position = UDim2.new(0, 10, 0, 45),
        Size = UDim2.new(1, -20, 0, 35),
        Theme = {BackgroundColor3 = "Background"},
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }):round(6)

    local tabList = tabContainer:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local tabPadding = tabContainer:create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })

    -- Content Area with Background Pattern (Bracket inspired)
    local contentArea = mainFrame:create("Frame", {
        Position = UDim2.new(0, 10, 0, 90),
        Size = UDim2.new(1, -20, 1, -100),
        Theme = {BackgroundColor3 = "Background"},
        BackgroundTransparency = 1
    })

    -- Add subtle background pattern
    local backgroundPattern = contentArea:create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://2151741365",
        ImageTransparency = 0.95,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 200, 0, 200),
        ZIndex = 0
    })

    -- Make draggable
    Ruvex:MakeDraggable(titleBar, mainFrame)

    -- Simple toggle functionality
    UserInputService.InputBegan:Connect(function(key)
        if key.KeyCode == options.CloseKey then
            if Ruvex.Toggled then
                mainFrame.Visible = false
                Ruvex.Toggled = false
            else
                mainFrame.Visible = true
                Ruvex.Toggled = true
            end
        end
    end)

    local window = {}
    window.tabs = {}
    window.selectedTab = nil

    -- Tab Function (Mercury inspired)
    function window:Tab(name, icon)
        name = name or "Tab"
        icon = icon or "rbxassetid://10734950309"

        local tabButton = tabContainer:create("TextButton", {
            Size = UDim2.new(0, 120, 1, 0),
            Theme = {BackgroundColor3 = "Secondary"},
            BackgroundTransparency = 1,
            Text = ""
        }):round(6)

        tabButton:stroke("Divider", 0.5)

        local tabIcon = tabButton:create("ImageLabel", {
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Image = icon,
            Theme = {ImageColor3 = "StrongText"}
        })

        local tabLabel = tabButton:create("TextLabel", {
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -35, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Theme = {TextColor3 = "StrongText"},
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local tabContent = contentArea:create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            Theme = {BackgroundColor3 = "Background"},
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Ruvex.Themes.Divider,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = not window.selectedTab
        })

        local tabContentList = tabContent:create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 15)
        })

        local tabContentPadding = tabContent:create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })

        if not window.selectedTab then
            window.selectedTab = tabButton
            tabContent.Visible = true
            tabButton.BackgroundTransparency = 0.2
        else
            tabContent.Visible = false
        end

        -- Simple tab selection (Mercury inspired hover effects)
        local function selectTab()
            for _, tabData in pairs(window.tabs) do
                tabData.button.BackgroundTransparency = 1
                tabData.content.Visible = false
                tabData.button:tween{BackgroundTransparency = 1, Length = 0.15}
            end
            
            window.selectedTab = tabButton
            tabContent.Visible = true
            tabButton:tween{BackgroundTransparency = 0.2, Length = 0.15}
        end

        tabButton.MouseButton1Click:Connect(selectTab)

        -- Simple hover effects
        tabButton.MouseEnter:Connect(function()
            if window.selectedTab ~= tabButton then
                tabButton:tween{BackgroundTransparency = 0.4, Length = 0.15}
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if window.selectedTab ~= tabButton then
                tabButton:tween{BackgroundTransparency = 1, Length = 0.15}
            end
        end)

        local tab = {}
        tab.tabButton = tabButton
        tab.tabContent = tabContent

        window.tabs[name] = {
            button = tabButton,
            content = tabContent
        }

        -- Section Function
        function tab:Section(name)
            name = name or "Section"

            local sectionFrame = tabContent:create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Theme = {BackgroundColor3 = "Secondary"},
                AutomaticSize = Enum.AutomaticSize.Y
            }):round(8)

            sectionFrame:stroke("Divider", 0.5)

            local sectionTitle = sectionFrame:create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                Theme = {
                    BackgroundColor3 = "Tertiary",
                    TextColor3 = "StrongText"
                },
                Text = name,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            }):round(8)

            local titleHiding = sectionTitle:create("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Theme = {BackgroundColor3 = "Tertiary"},
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 8)
            })

            local titlePadding = sectionTitle:create("UIPadding", {
                PaddingLeft = UDim.new(0, 15)
            })

            local sectionContent = sectionFrame:create("Frame", {
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 1, -30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local sectionList = sectionContent:create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })

            local sectionPadding = sectionContent:create("UIPadding", {
                PaddingTop = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15)
            })

            local section = {}

            -- Button Function (Cerberus inspired)
            function section:Button(text, callback)
                text = text or "Button"
                callback = callback or function() end

                local buttonFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local button = buttonFrame:create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 0.2,
                    Text = text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham
                }):round(6)

                button:stroke("Divider", 0.5)

                button.MouseButton1Click:Connect(function()
                    pcall(callback)
                    
                    -- Simple click effect
                    button:tween{BackgroundTransparency = 0, Length = 0.1}
                    wait(0.1)
                    button:tween{BackgroundTransparency = 0.2, Length = 0.1}
                end)

                button.MouseEnter:Connect(function()
                    button:tween{BackgroundTransparency = 0.1, Length = 0.15}
                end)

                button.MouseLeave:Connect(function()
                    button:tween{BackgroundTransparency = 0.2, Length = 0.15}
                end)

                return {}
            end

            -- Toggle Function (Mercury inspired)
            function section:Toggle(text, default, callback)
                text = text or "Toggle"
                default = default or false
                callback = callback or function() end

                local currentValue = default

                local toggleFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local toggleLabel = toggleFrame:create("TextLabel", {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -50, 1, 0),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 1,
                    Text = text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local toggleButton = toggleFrame:create("TextButton", {
                    Position = UDim2.new(1, -40, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 35, 0, 18),
                    Theme = {BackgroundColor3 = currentValue and "Tertiary" or "Divider"},
                    Text = ""
                }):round(9)

                local toggleIndicator = toggleButton:create("Frame", {
                    Position = UDim2.new(currentValue and 1 or 0, currentValue and -16 or 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 14, 0, 14),
                    Theme = {BackgroundColor3 = "StrongText"}
                }):round(7)

                local function updateToggle()
                    currentValue = not currentValue
                    
                    toggleButton:tween({
                        BackgroundColor3 = currentValue and Ruvex.Themes.Tertiary or Ruvex.Themes.Divider,
                        Length = 0.2
                    })
                    
                    toggleIndicator:tween({
                        Position = UDim2.new(currentValue and 1 or 0, currentValue and -16 or 2, 0.5, 0),
                        Length = 0.2
                    })

                    pcall(callback, currentValue)
                end

                toggleButton.MouseButton1Click:Connect(updateToggle)

                local toggleObj = {}
                function toggleObj:SetValue(value)
                    if currentValue ~= value then
                        updateToggle()
                    end
                end

                function toggleObj:GetValue()
                    return currentValue
                end

                return toggleObj
            end

            -- Slider Function
            function section:Slider(text, min, max, default, callback)
                text = text or "Slider"
                min = min or 0
                max = max or 100
                default = default or min
                callback = callback or function() end

                local currentValue = default

                local sliderFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1
                })

                local sliderLabel = sliderFrame:create("TextLabel", {
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -60, 0, 20),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 1,
                    Text = text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local sliderValue = sliderFrame:create("TextLabel", {
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 60, 0, 20),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "Tertiary"
                    },
                    BackgroundTransparency = 1,
                    Text = tostring(currentValue),
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local sliderTrack = sliderFrame:create("Frame", {
                    Position = UDim2.new(0, 0, 0, 30),
                    Size = UDim2.new(1, 0, 0, 4),
                    Theme = {BackgroundColor3 = "Divider"}
                }):round(2)

                local sliderFill = sliderTrack:create("Frame", {
                    Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
                    Theme = {BackgroundColor3 = "Tertiary"}
                }):round(2)

                local sliderHandle = sliderTrack:create("Frame", {
                    Position = UDim2.new((currentValue - min) / (max - min), -6, 0.5, -6),
                    AnchorPoint = Vector2.new(0, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Theme = {BackgroundColor3 = "StrongText"}
                }):round(6)

                local dragging = false

                local function updateSlider(input)
                    if not sliderTrack or not sliderTrack.AbsolutePosition or not sliderTrack.AbsoluteSize then
                        return
                    end
                    
                    local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    currentValue = math.floor(min + (max - min) * percentage)

                    sliderValue.Text = tostring(currentValue)
                    sliderFill:tween({Size = UDim2.new(percentage, 0, 1, 0), Length = 0.1})
                    sliderHandle:tween({Position = UDim2.new(percentage, -6, 0.5, -6), Length = 0.1})

                    pcall(callback, currentValue)
                end

                sliderHandle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateSlider(input)
                    end
                end)

                local sliderObj = {}
                function sliderObj:SetValue(value)
                    currentValue = math.clamp(value, min, max)
                    local percentage = (currentValue - min) / (max - min)

                    sliderValue.Text = tostring(currentValue)
                    sliderFill:tween({Size = UDim2.new(percentage, 0, 1, 0), Length = 0.2})
                    sliderHandle:tween({Position = UDim2.new(percentage, -6, 0.5, -6), Length = 0.2})

                    pcall(callback, currentValue)
                end

                function sliderObj:GetValue()
                    return currentValue
                end

                return sliderObj
            end

            -- TextBox Function
            function section:TextBox(text, placeholder, callback)
                placeholder = placeholder or "Enter text..."
                callback = callback or function() end

                local currentValue = ""

                local textboxFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local textboxLabel = textboxFrame:create("TextLabel", {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 1,
                    Text = text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local textboxInput = textboxFrame:create("TextBox", {
                    Position = UDim2.new(0.4, 10, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0.6, -10, 0, 25),
                    Theme = {
                        BackgroundColor3 = "Secondary",
                        TextColor3 = "StrongText",
                        PlaceholderColor3 = "WeakText"
                    },
                    BackgroundTransparency = 0.2,
                    PlaceholderText = placeholder,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    Text = ""
                }):round(4)

                textboxInput:stroke("Divider", 0.5)

                textboxInput.Focused:Connect(function()
                    textboxInput:stroke("Tertiary", 0.5)
                end)

                textboxInput.FocusLost:Connect(function(enterPressed)
                    textboxInput:stroke("Divider", 0.5)
                    if enterPressed then
                        currentValue = textboxInput.Text
                        pcall(callback, currentValue)
                    end
                end)

                local textboxObj = {}
                function textboxObj:SetValue(value)
                    currentValue = tostring(value)
                    textboxInput.Text = currentValue
                    pcall(callback, currentValue)
                end

                function textboxObj:GetValue()
                    return currentValue
                end

                return textboxObj
            end

            -- Label Function
            function section:Label(text)
                text = text or "Label"

                local labelFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1
                })

                local label = labelFrame:create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Theme = {
                        BackgroundColor3 = "Background",
                        TextColor3 = "WeakText"
                    },
                    BackgroundTransparency = 1,
                    Text = text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })

                local labelObj = {}
                function labelObj:SetText(newText)
                    label.Text = newText
                end

                function labelObj:GetText()
                    return label.Text
                end

                return labelObj
            end

            return section
        end

        return tab
    end

    return window
end

return Ruvex
