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
local Ruvex = {
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    Toggled = true,
    ToggleKey = Enum.KeyCode.RightControl,
    flags = {},
    _tweenCache = {}
}

-- Enhanced Color Themes (Mercury + PPHud inspired)
Ruvex.Themes = {
    Main = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(35, 35, 40),
    Tertiary = Color3.fromRGB(255, 45, 45),
    Background = Color3.fromRGB(15, 15, 20),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(180, 180, 180),
    Divider = Color3.fromRGB(50, 50, 55),
    Accent = Color3.fromRGB(255, 45, 45),
    Hovering = Color3.fromRGB(45, 45, 50),
    Success = Color3.fromRGB(45, 255, 45),
    Warning = Color3.fromRGB(255, 200, 45),
    Error = Color3.fromRGB(255, 85, 85)
}

-- Theme Objects for live updates
Ruvex.ThemeObjects = {}
for themeName in pairs(Ruvex.Themes) do
    Ruvex.ThemeObjects[themeName] = {}
end

-- Enhanced Rainbow Effect (Flux inspired)
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

-- Enhanced Tween Function (Criminality inspired)
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

-- Enhanced Object Creation Function
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
        thickness = thickness or 1
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

    function methods:fade(state, colorOverride, length, instant)
        length = length or 0.2
        if not rawget(self, "fadeFrame") then
            local frame = self:create("Frame", {
                BackgroundColor3 = colorOverride or self.BackgroundColor3,
                BackgroundTransparency = (state and 1) or 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 999
            }):round(self.AbsoluteObject:FindFirstChildOfClass("UICorner") and self.AbsoluteObject:FindFirstChildOfClass("UICorner").CornerRadius.Offset or 0)
            rawset(self, "fadeFrame", frame)
        else
            self.fadeFrame.BackgroundColor3 = colorOverride or self.BackgroundColor3
        end

        if instant then
            if state then
                self.fadeFrame.BackgroundTransparency = 0
                self.fadeFrame.Visible = true
            else
                self.fadeFrame.BackgroundTransparency = 1
                self.fadeFrame.Visible = false
            end
        else
            if state then
                self.fadeFrame.BackgroundTransparency = 1
                self.fadeFrame.Visible = true
                self.fadeFrame:tween{BackgroundTransparency = 0, Length = length}
            else
                self.fadeFrame.BackgroundTransparency = 0
                self.fadeFrame:tween({BackgroundTransparency = 1, Length = length}, function()
                    self.fadeFrame.Visible = false
                end)
            end
        end
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

-- Enhanced Draggable Function (Criminality inspired)
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

    -- Notification holder
    local notificationHolder = gui:create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 1, -30),
        Size = UDim2.new(0, 300, 1, -60)
    })

    local notiHolderList = notificationHolder:create("UIListLayout", {
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    -- Main frame with enhanced shadow
    local mainFrame = gui:create("Frame", {
        Size = UDim2.new(),
        Theme = {BackgroundColor3 = "Main"},
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true
    }):round(12)

    -- Enhanced shadow effect
    local mainShadow = gui:create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 3),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118)
    })

    -- Enhanced opening animation (Criminality style)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 50, 0, 50)
    mainFrame:tween({
        BackgroundTransparency = 0, 
        Size = options.Size, 
        Length = 0.6, 
        Style = Enum.EasingStyle.Back, 
        Direction = Enum.EasingDirection.Out
    }, function()
        mainFrame.ClipsDescendants = false
    end)

    -- Animate shadow
    mainShadow.ImageTransparency = 1
    mainShadow:tween({ImageTransparency = 0.8, Length = 0.8})

    -- Enhanced Title Bar
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

    -- Enhanced Window Controls (Cerberus inspired)
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

    -- Enhanced minimize functionality
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        if not isMinimized then
            mainFrame:tween({
                Size = UDim2.new(options.Size.X.Scale, options.Size.X.Offset, 0, 35),
                Length = 0.3,
                Style = Enum.EasingStyle.Quart
            }, function()
                isMinimized = true
            end)
            minimizeButton.Text = "+"
        else
            mainFrame:tween({
                Size = options.Size,
                Length = 0.3,
                Style = Enum.EasingStyle.Quart
            }, function()
                isMinimized = false
            end)
            minimizeButton.Text = "−"
        end
    end)

    -- Enhanced button hover effects (Mercury inspired)
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton:tween{BackgroundTransparency = 0.1, BackgroundColor3 = Ruvex.Themes.Secondary, Length = 0.15}
    end)

    minimizeButton.MouseLeave:Connect(function()
        minimizeButton:tween{BackgroundTransparency = 0.3, BackgroundColor3 = Ruvex.Themes.Secondary, Length = 0.15}
    end)

    closeButton.MouseButton1Click:Connect(function()
        mainFrame:tween({
            Size = UDim2.new(), 
            Rotation = 5,
            Length = 0.3,
            Style = Enum.EasingStyle.Back,
            Direction = Enum.EasingDirection.In
        }, function()
            gui:Destroy()
        end)
    end)

    closeButton.MouseEnter:Connect(function()
        closeButton:tween{BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(220, 38, 38), Length = 0.15}
    end)

    closeButton.MouseLeave:Connect(function()
        closeButton:tween{BackgroundTransparency = 0.1, BackgroundColor3 = Ruvex.Themes.Tertiary, Length = 0.15}
    end)

    -- Enhanced Tab Container (Mercury inspired)
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

    -- Enhanced Content Area with Background Pattern (Bracket inspired)
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

    -- Toggle functionality
    UserInputService.InputBegan:Connect(function(key)
        if key.KeyCode == options.CloseKey then
            if Ruvex.Toggled then
                mainFrame:tween{Size = UDim2.new(), Length = 0.3}
                Ruvex.Toggled = false
            else
                mainFrame:tween{Size = options.Size, Length = 0.3}
                Ruvex.Toggled = true
            end
        end
    end)

    local window = {}
    window.tabs = {}
    window.selectedTab = nil

    -- Enhanced Notification Function (Mercury inspired)
    function window:Notification(title, description, duration)
        duration = duration or 4

        local notification = notificationHolder:create("Frame", {
            Size = UDim2.new(1, 0, 0, 85),
            Theme = {BackgroundColor3 = "Main"},
            BackgroundTransparency = 0,
            Position = UDim2.new(1, 20, 0, 0),
            ZIndex = 1000
        }):round(8)

        -- Add shadow effect
        local shadow = notification:create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 2, 0.5, 2),
            Size = UDim2.new(1, 20, 1, 20),
            ZIndex = 999,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.85,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 118, 118)
        })

        local notificationStroke = notification:create("UIStroke", {
            Color = Ruvex.Themes.Tertiary,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        -- Progress bar at top (Mercury inspired)
        local progressBar = notification:create("Frame", {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 3),
            Theme = {BackgroundColor3 = "Tertiary"},
            BorderSizePixel = 0
        })

        local progressCorner = progressBar:create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        })

        local progressHiding = progressBar:create("Frame", {
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 8),
            Theme = {BackgroundColor3 = "Tertiary"},
            BorderSizePixel = 0
        })

        local notificationIcon = notification:create("Frame", {
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(0, 20, 0, 20),
            Theme = {BackgroundColor3 = "Tertiary"},
            BorderSizePixel = 0
        }):round(10)

        local iconText = notificationIcon:create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "i",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })

        local notificationTitle = notification:create("TextLabel", {
            Position = UDim2.new(0, 45, 0, 12),
            Size = UDim2.new(1, -70, 0, 22),
            BackgroundTransparency = 1,
            Text = title,
            Theme = {TextColor3 = "StrongText"},
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })

        local notificationDesc = notification:create("TextLabel", {
            Position = UDim2.new(0, 45, 0, 35),
            Size = UDim2.new(1, -70, 0, 35),
            BackgroundTransparency = 1,
            Text = description,
            Theme = {TextColor3 = "WeakText"},
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })

        local closeNotifBtn = notification:create("TextButton", {
            Position = UDim2.new(1, -25, 0, 8),
            Size = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1,
            Text = "×",
            Theme = {TextColor3 = "WeakText"},
            TextSize = 14,
            Font = Enum.Font.GothamBold
        })

        -- Enhanced notification animations (Mercury style)
        notification.Position = UDim2.new(1, 20, 0, 0)
        notification:tween({
            Position = UDim2.new(0, 0, 0, 0),
            Length = 0.4,
            Style = Enum.EasingStyle.Back,
            Direction = Enum.EasingDirection.Out
        })

        -- Progress bar animation
        progressBar:tween({
            Size = UDim2.new(0, 0, 0, 3),
            Length = duration,
            Style = Enum.EasingStyle.Linear
        }, function()
            -- Fade out notification
            notification:tween({
                Position = UDim2.new(1, 20, 0, 0),
                Length = 0.3,
                Style = Enum.EasingStyle.Quart,
                Direction = Enum.EasingDirection.In
            }, function()
                notification:Destroy()
            end)
        end)

        closeNotifBtn.MouseButton1Click:Connect(function()
            notification:tween({
                Position = UDim2.new(1, 20, 0, 0),
                Length = 0.3,
                Style = Enum.EasingStyle.Quart,
                Direction = Enum.EasingDirection.In
            }, function()
                notification:Destroy()
            end)
        end)

        closeNotifBtn.MouseEnter:Connect(function()
            closeNotifBtn:tween{TextColor3 = Ruvex.Themes.StrongText, Length = 0.15}
        end)

        closeNotifBtn.MouseLeave:Connect(function()
            closeNotifBtn:tween{TextColor3 = Ruvex.Themes.WeakText, Length = 0.15}
        end)
    end

    -- Enhanced Tab Function (Mercury inspired)
    function window:Tab(name, icon)
        name = name or "New Tab"
        icon = icon or "rbxassetid://10734898355"

        local tab = {}
        local tabButton = tabContainer:create("TextButton", {
            Size = UDim2.new(0, 140, 1, 0),
            Theme = {BackgroundColor3 = "Secondary"},
            BackgroundTransparency = window.selectedTab and 1 or 0.2,
            Text = "",
            LayoutOrder = #window.tabs + 1
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

        -- Enhanced tab selection (Mercury inspired hover effects)
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

        -- Enhanced hover effects
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

        table.insert(window.tabs, {
            button = tabButton,
            content = tabContent,
            name = name
        })

        tab.sections = {}

        -- Tab Section Function
        function tab:Section(name)
            name = name or "New Section"

            local section = {}
            local sectionFrame = tabContent:create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Theme = {BackgroundColor3 = "Secondary"},
                BackgroundTransparency = 0.5,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #tab.sections + 1
            }):round(8)

            sectionFrame:stroke("Divider", 0.5)

            local sectionHeader = sectionFrame:create("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                Theme = {BackgroundColor3 = "Tertiary"},
                BackgroundTransparency = 0.8
            }):round(8)

            local sectionHiding = sectionHeader:create("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 8),
                Theme = {BackgroundColor3 = "Tertiary"},
                BackgroundTransparency = 0.8
            })

            local sectionTitle = sectionHeader:create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                Theme = {TextColor3 = "StrongText"},
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local sectionTitlePadding = sectionTitle:create("UIPadding", {
                PaddingLeft = UDim.new(0, 15)
            })

            local sectionContent = sectionFrame:create("Frame", {
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 1, -35),
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

            table.insert(tab.sections, section)

            -- Enhanced Button Function (Cerberus inspired)
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

                -- Enhanced button effects (Cerberus inspired)
                button.MouseButton1Click:Connect(function()
                    button:tween{
                        BackgroundTransparency = 0,
                        Length = 0.1
                    }
                    button:tween{
                        BackgroundTransparency = 0.2,
                        Length = 0.2
                    }
                    pcall(callback)
                end)

                button.MouseEnter:Connect(function()
                    button:tween{BackgroundTransparency = 0.1, Length = 0.15}
                end)

                button.MouseLeave:Connect(function()
                    button:tween{BackgroundTransparency = 0.2, Length = 0.15}
                end)

                local buttonObj = {}
                function buttonObj:SetText(newText)
                    button.Text = newText
                end

                return buttonObj
            end

            -- Enhanced Toggle Function
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
                    
                    toggleButton:tween{
                        BackgroundColor3 = currentValue and Ruvex.Themes.Tertiary or Ruvex.Themes.Divider,
                        Length = 0.2
                    }
                    
                    toggleIndicator:tween{
                        Position = UDim2.new(currentValue and 1 or 0, currentValue and -16 or 2, 0.5, 0),
                        Length = 0.2,
                        Style = Enum.EasingStyle.Quart
                    }

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

            -- Enhanced Slider Function
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
                    sliderFill:tween{Size = UDim2.new(percentage, 0, 1, 0), Length = 0.1}
                    sliderHandle:tween{Position = UDim2.new(percentage, -6, 0.5, -6), Length = 0.1}

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
                    sliderFill:tween{Size = UDim2.new(percentage, 0, 1, 0), Length = 0.2}
                    sliderHandle:tween{Position = UDim2.new(percentage, -6, 0.5, -6), Length = 0.2}

                    pcall(callback, currentValue)
                end

                function sliderObj:GetValue()
                    return currentValue
                end

                return sliderObj
            end

            -- Enhanced TextBox Function
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

                textboxInput:stroke("Divider", 1)

                textboxInput.Focused:Connect(function()
                    textboxInput:stroke("Tertiary", 1)
                end)

                textboxInput.FocusLost:Connect(function(enterPressed)
                    textboxInput:stroke("Divider", 1)
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

            -- Enhanced Dropdown Function
            function section:Dropdown(text, options, default, callback)
                options = options or {"Option 1", "Option 2"}
                default = default or options[1]
                callback = callback or function() end

                local currentValue = default
                local dropdownOpen = false

                local dropdownFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local dropdownLabel = dropdownFrame:create("TextLabel", {
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

                local dropdownButton = dropdownFrame:create("TextButton", {
                    Position = UDim2.new(0.4, 10, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0.6, -10, 0, 25),
                    Theme = {
                        BackgroundColor3 = "Secondary",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 0.2,
                    Text = default,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                }):round(4)

                local dropdownArrow = dropdownButton:create("TextLabel", {
                    Position = UDim2.new(1, -20, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 20, 0, 20),
                    Theme = {
                        BackgroundColor3 = "Secondary",
                        TextColor3 = "WeakText"
                    },
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextSize = 10,
                    Font = Enum.Font.Gotham
                })

                dropdownButton:stroke("Divider", 0.5)

                local listFrame = nil

                local function toggleDropdown()
                    dropdownOpen = not dropdownOpen

                    if dropdownOpen then
                        dropdownArrow:tween{Rotation = 180, Length = 0.2}
                        dropdownFrame:tween{Size = UDim2.new(1, 0, 0, 35 + (#options * 25) + 10), Length = 0.2}

                        if not listFrame then
                            listFrame = dropdownFrame:create("Frame", {
                                Position = UDim2.new(0.4, 10, 0, 35),
                                Size = UDim2.new(0.6, -10, 0, (#options * 25) + 10),
                                Theme = {BackgroundColor3 = "Main"},
                                ZIndex = 10,
                                BorderSizePixel = 0
                            }):round(4)

                            listFrame:stroke("Divider", 0.5)

                            local listLayout = listFrame:create("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 1)
                            })

                            local listPadding = listFrame:create("UIPadding", {
                                PaddingTop = UDim.new(0, 3),
                                PaddingBottom = UDim.new(0, 3)
                            })

                            for i, option in ipairs(options) do
                                local optionButton = listFrame:create("TextButton", {
                                    Size = UDim2.new(1, 0, 0, 23),
                                    Theme = {
                                        BackgroundColor3 = "Secondary",
                                        TextColor3 = "StrongText"
                                    },
                                    BackgroundTransparency = (option == currentValue) and 0.3 or 1,
                                    Text = option,
                                    TextSize = 12,
                                    Font = Enum.Font.Gotham,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    BorderSizePixel = 0
                                }):round(2)

                                local optionPadding = optionButton:create("UIPadding", {
                                    PaddingLeft = UDim.new(0, 10),
                                    PaddingRight = UDim.new(0, 10)
                                })

                                optionButton.MouseButton1Click:Connect(function()
                                    -- Update all option buttons
                                    for _, child in pairs(listFrame:GetChildren()) do
                                        if child:IsA("TextButton") then
                                            child:tween{BackgroundTransparency = 1, Length = 0.1}
                                        end
                                    end

                                    optionButton:tween{BackgroundTransparency = 0.3, Length = 0.1}
                                    currentValue = option
                                    dropdownButton.Text = option
                                    pcall(callback, currentValue)

                                    -- Close dropdown
                                    wait(0.1)
                                    dropdownOpen = false
                                    dropdownArrow:tween{Rotation = 0, Length = 0.2}
                                    dropdownFrame:tween{Size = UDim2.new(1, 0, 0, 35), Length = 0.2}
                                    listFrame.Visible = false
                                end)

                                optionButton.MouseEnter:Connect(function()
                                    if option ~= currentValue then
                                        optionButton:tween{BackgroundTransparency = 0.5, Length = 0.1}
                                    end
                                end)

                                optionButton.MouseLeave:Connect(function()
                                    if option ~= currentValue then
                                        optionButton:tween{BackgroundTransparency = 1, Length = 0.1}
                                    end
                                end)
                            end
                        end

                        listFrame.Visible = true
                    else
                        dropdownArrow:tween{Rotation = 0, Length = 0.2}
                        dropdownFrame:tween{Size = UDim2.new(1, 0, 0, 35), Length = 0.2}

                        if listFrame then
                            listFrame.Visible = false
                        end
                    end
                end

                dropdownButton.MouseButton1Click:Connect(toggleDropdown)

                local dropdownObj = {}
                function dropdownObj:SetValue(value)
                    currentValue = value
                    dropdownButton.Text = value
                    pcall(callback, currentValue)
                end

                function dropdownObj:GetValue()
                    return currentValue
                end

                return dropdownObj
            end

            -- Enhanced Color Picker Function (Cerberus + Flux inspired)
            function section:ColorPicker(text, default, callback)
                default = default or Color3.fromRGB(255, 45, 45)
                callback = callback or function() end

                local currentValue = default
                local rainbowMode = false

                local colorFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local colorLabel = colorFrame:create("TextLabel", {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0.7, 0, 1, 0),
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

                local colorPreview = colorFrame:create("Frame", {
                    Position = UDim2.new(1, -50, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 45, 0, 20),
                    BackgroundColor3 = currentValue
                }):round(4)

                colorPreview:stroke("Divider", 0.5)

                local colorButton = colorFrame:create("TextButton", {
                    Position = UDim2.new(1, -50, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 45, 0, 20),
                    BackgroundTransparency = 1,
                    Text = ""
                })

                colorButton.MouseButton1Click:Connect(function()
                    local colorPickerFrame = gui:create("Frame", {
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0, 350, 0, 280),
                        Theme = {BackgroundColor3 = "Main"},
                        ZIndex = 100
                    }):round(8)

                    colorPickerFrame:stroke("Tertiary", 1)

                    -- Add backdrop blur effect
                    local backdrop = gui:create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.3,
                        ZIndex = 99
                    })

                    local colorPickerTitle = colorPickerFrame:create("TextLabel", {
                        Position = UDim2.new(0, 15, 0, 10),
                        Size = UDim2.new(1, -30, 0, 25),
                        Theme = {
                            BackgroundColor3 = "Main",
                            TextColor3 = "StrongText"
                        },
                        BackgroundTransparency = 1,
                        Text = "Color Picker - " .. text,
                        TextSize = 16,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    -- Enhanced color wheel/gradient area (Cerberus inspired)
                    local colorGradient = colorPickerFrame:create("Frame", {
                        Position = UDim2.new(0, 15, 0, 50),
                        Size = UDim2.new(0, 200, 0, 150),
                        Theme = {BackgroundColor3 = "Secondary"}
                    }):round(6)

                    local hueGradient = colorGradient:create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                        })
                    })

                    colorGradient:stroke("Divider", 0.5)

                    -- Color gradient interaction
                    colorGradient.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local x, y = Ruvex:GetXY(colorGradient)
                            currentValue = Color3.fromHSV(x, 1, 1-y)
                            currentColorPreview:tween{BackgroundColor3 = currentValue, Length = 0.1}
                            colorPreview:tween{BackgroundColor3 = currentValue, Length = 0.1}

                            -- Update RGB inputs
                            local nr, ng, nb = math.floor(currentValue.R * 255), math.floor(currentValue.G * 255), math.floor(currentValue.B * 255)
                            if rInput then rInput.Text = tostring(nr) end
                            if gInput then gInput.Text = tostring(ng) end
                            if bInput then bInput.Text = tostring(nb) end

                            pcall(callback, currentValue)
                        end
                    end)

                    -- Current color preview (larger)
                    local currentColorPreview = colorPickerFrame:create("Frame", {
                        Position = UDim2.new(0, 230, 0, 50),
                        Size = UDim2.new(0, 100, 0, 50),
                        BackgroundColor3 = currentValue
                    }):round(6)

                    currentColorPreview:stroke("Divider", 0.5)

                    -- Enhanced RGB input fields
                    local rgbContainer = colorPickerFrame:create("Frame", {
                        Position = UDim2.new(0, 230, 0, 110),
                        Size = UDim2.new(0, 100, 0, 90),
                        BackgroundTransparency = 1
                    })

                    local rgbList = rgbContainer:create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 5)
                    })

                    local r, g, b = math.floor(currentValue.R * 255), math.floor(currentValue.G * 255), math.floor(currentValue.B * 255)

                    local function createColorInput(name, value, index)
                        local inputFrame = rgbContainer:create("Frame", {
                            Size = UDim2.new(1, 0, 0, 25),
                            BackgroundTransparency = 1,
                            LayoutOrder = index
                        })

                        local label = inputFrame:create("TextLabel", {
                            Size = UDim2.new(0, 20, 1, 0),
                            BackgroundTransparency = 1,
                            Text = name .. ":",
                            Theme = {TextColor3 = "StrongText"},
                            TextSize = 12,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        local input = inputFrame:create("TextBox", {
                            Position = UDim2.new(0, 25, 0, 0),
                            Size = UDim2.new(1, -25, 1, 0),
                            Theme = {
                                BackgroundColor3 = "Secondary",
                                TextColor3 = "StrongText"
                            },
                            Text = tostring(value),
                            TextSize = 12,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Center
                        }):round(4)

                        input:stroke("Divider", 0.5)

                        return input
                    end

                    local rInput = createColorInput("R", r, 1)
                    local gInput = createColorInput("G", g, 2)
                    local bInput = createColorInput("B", b, 3)

                    local function updateColorFromRGB()
                        local newR = math.clamp(tonumber(rInput.Text) or 0, 0, 255)
                        local newG = math.clamp(tonumber(gInput.Text) or 0, 0, 255)
                        local newB = math.clamp(tonumber(bInput.Text) or 0, 0, 255)

                        currentValue = Color3.fromRGB(newR, newG, newB)
                        currentColorPreview:tween{BackgroundColor3 = currentValue, Length = 0.1}
                        colorPreview:tween{BackgroundColor3 = currentValue, Length = 0.1}
                        pcall(callback, currentValue)
                    end

                    rInput.FocusLost:Connect(updateColorFromRGB)
                    gInput.FocusLost:Connect(updateColorFromRGB)
                    bInput.FocusLost:Connect(updateColorFromRGB)

                    -- Enhanced Rainbow mode controls (Flux inspired)
                    local rainbowToggle = colorPickerFrame:create("TextButton", {
                        Position = UDim2.new(0, 15, 0, 215),
                        Size = UDim2.new(0, 90, 0, 30),
                        Theme = {
                            BackgroundColor3 = rainbowMode and "Tertiary" or "Secondary",
                            TextColor3 = "StrongText"
                        },
                        Text = "Rainbow Mode",
                        TextSize = 12,
                        Font = Enum.Font.Gotham
                    }):round(6)

                    rainbowToggle.MouseButton1Click:Connect(function()
                        rainbowMode = not rainbowMode
                        if rainbowMode then
                            rainbowToggle:tween{BackgroundColor3 = Ruvex.Themes.Tertiary, Length = 0.2}
                            spawn(function()
                                while rainbowMode do
                                    local newColor = Color3.fromHSV(Ruvex.RainbowColorValue, 1, 1)
                                    currentValue = newColor
                                    currentColorPreview:tween{BackgroundColor3 = newColor, Length = 0.05}
                                    colorPreview:tween{BackgroundColor3 = newColor, Length = 0.05}

                                    -- Update RGB inputs
                                    local nr, ng, nb = math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255)
                                    rInput.Text = tostring(nr)
                                    gInput.Text = tostring(ng)
                                    bInput.Text = tostring(nb)

                                    pcall(callback, newColor)
                                    wait(0.05)
                                end
                            end)
                        else
                            rainbowToggle:tween{BackgroundColor3 = Ruvex.Themes.Secondary, Length = 0.2}
                        end
                    end)

                    -- Close button
                    local closeButton = colorPickerFrame:create("TextButton", {
                        Position = UDim2.new(1, -35, 0, 8),
                        Size = UDim2.new(0, 25, 0, 25),
                        BackgroundTransparency = 0.8,
                        Theme = {
                            BackgroundColor3 = "Tertiary",
                            TextColor3 = "StrongText"
                        },
                        Text = "×",
                        TextSize = 16,
                        Font = Enum.Font.GothamBold
                    }):round(6)

                    local function closeColorPicker()
                        rainbowMode = false
                        colorPickerFrame:Destroy()
                        backdrop:Destroy()
                    end

                    closeButton.MouseButton1Click:Connect(closeColorPicker)
                    backdrop.MouseButton1Click:Connect(closeColorPicker)

                    closeButton.MouseEnter:Connect(function()
                        closeButton:tween{BackgroundTransparency = 0, Length = 0.15}
                    end)

                    closeButton.MouseLeave:Connect(function()
                        closeButton:tween{BackgroundTransparency = 0.8, Length = 0.15}
                    end)
                end)

                local colorObj = {}
                function colorObj:SetValue(value)
                    currentValue = value
                    colorPreview:tween{BackgroundColor3 = value, Length = 0.2}
                    pcall(callback, currentValue)
                end

                function colorObj:GetValue()
                    return currentValue
                end

                function colorObj:SetRainbow(state)
                    rainbowMode = state
                    if rainbowMode then
                        spawn(function()
                            while rainbowMode do
                                currentValue = Color3.fromHSV(Ruvex.RainbowColorValue, 1, 1)
                                colorPreview:tween{BackgroundColor3 = currentValue, Length = 0.1}
                                pcall(callback, currentValue)
                                wait(0.1)
                            end
                        end)
                    end
                end

                return colorObj
            end

            -- Enhanced Keybind Function
            function section:Keybind(text, default, callback)
                default = default or Enum.KeyCode.F
                callback = callback or function() end

                local currentKey = default
                local isListening = false

                local keybindFrame = sectionContent:create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })

                local keybindLabel = keybindFrame:create("TextLabel", {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0.7, 0, 1, 0),
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

                local keybindButton = keybindFrame:create("TextButton", {
                    Position = UDim2.new(1, -80, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 75, 0, 25),
                    Theme = {
                        BackgroundColor3 = "Secondary",
                        TextColor3 = "StrongText"
                    },
                    BackgroundTransparency = 0.2,
                    Text = default.Name,
                    TextSize = 12,
                    Font = Enum.Font.Gotham
                }):round(4)

                keybindButton:stroke("Divider", 0.5)

                keybindButton.MouseButton1Click:Connect(function()
                    if not isListening then
                        isListening = true
                        keybindButton.Text = "..."
                        keybindButton:stroke("Tertiary", 0.5)

                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                currentKey = input.KeyCode
                                keybindButton.Text = input.KeyCode.Name
                                keybindButton:stroke("Divider", 0.5)
                                isListening = false
                                connection:Disconnect()
                            end
                        end)
                    end
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if input.KeyCode == currentKey and not isListening then
                        pcall(callback, currentKey)
                    end
                end)

                local keybindObj = {}
                function keybindObj:SetValue(value)
                    currentKey = value
                    keybindButton.Text = value.Name
                end

                function keybindObj:GetValue()
                    return currentKey
                end

                return keybindObj
            end

            -- Enhanced Label Function
            function section:Label(text)
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

                return labelObj
            end

            return section
        end

        return tab
    end

    return window
end

return Ruvex
