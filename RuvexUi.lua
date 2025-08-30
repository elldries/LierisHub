-- Ruvex UI Library
-- Полностью объединенная библиотека на основе Mercury Lib и Cerberus Lib
-- Совместима со всеми script executors

-- Mercury Lib base detection bypass and Cerberus security features
_G.JxereasExistingHooks = _G.JxereasExistingHooks or {}
if not _G.JxereasExistingHooks.GuiDetectionBypass then
    local CoreGui = game.CoreGui
    local ContentProvider = game.ContentProvider
    local RobloxGuis = {"RobloxGui", "TeleportGui", "RobloxPromptGui", "RobloxLoadingGui", "PlayerList", "RobloxNetworkPauseNotification", "PurchasePrompt", "HeadsetDisconnectedDialog", "ThemeProvider", "DevConsoleMaster"}

    local function FilterTable(tbl)
        local context = syn_context_get and syn_context_get() or 0
        if syn_context_set then syn_context_set(7) end
        local new = {}
        for i,v in ipairs(tbl) do
            if typeof(v) ~= "Instance" then
                table.insert(new, v)
            else
                if v == CoreGui or v == game then
                    for i,v in pairs(RobloxGuis) do
                        local gui = CoreGui:FindFirstChild(v)
                        if gui then
                            table.insert(new, gui)
                        end
                    end
                    if v == game then
                        for i,v in pairs(game:GetChildren()) do
                            if v ~= CoreGui then
                                table.insert(new, v)
                            end
                        end
                    end
                else
                    if not CoreGui:IsAncestorOf(v) then
                        table.insert(new, v)
                    else
                        for j,k in pairs(RobloxGuis) do
                            local gui = CoreGui:FindFirstChild(k)
                            if gui then
                                if v == gui or gui:IsAncestorOf(v) then
                                    table.insert(new, v)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        if syn_context_set then syn_context_set(context) end
        return new
    end

    if hookfunc then
        local old
        old = hookfunc(ContentProvider.PreloadAsync, function(self, tbl, cb)
            if self ~= ContentProvider or type(tbl) ~= "table" then
                return old(self, tbl, cb)
            end
            tbl = FilterTable(tbl)
            return old(self, tbl, cb)
        end)
    end

    _G.JxereasExistingHooks.GuiDetectionBypass = true
end

-- Anti-idle from Cerberus
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if getconnections then
    for _, connection in pairs(getconnections(player.Idled)) do
        if connection.Enabled then
            connection:Disable()
        end
    end
end

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local HTTPService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Ruvex Library (Mercury base with Cerberus integration)
local Library = {
    Themes = {
        Dark = {
            Main = Color3.fromRGB(15, 15, 15),
            Secondary = Color3.fromRGB(25, 25, 25),
            Tertiary = Color3.fromRGB(200, 50, 50),
            StrongText = Color3.fromRGB(255, 255, 255),
            WeakText = Color3.fromRGB(150, 150, 150)
        },
        Red = {
            Main = Color3.fromRGB(20, 20, 25),
            Secondary = Color3.fromRGB(30, 30, 35),
            Tertiary = Color3.fromRGB(220, 60, 60),
            StrongText = Color3.fromRGB(255, 255, 255),
            WeakText = Color3.fromRGB(180, 180, 180)
        },
        Crimson = {
            Main = Color3.fromRGB(25, 15, 15),
            Secondary = Color3.fromRGB(35, 25, 25),
            Tertiary = Color3.fromRGB(180, 40, 40),
            StrongText = Color3.fromRGB(255, 255, 255),
            WeakText = Color3.fromRGB(200, 150, 150)
        },
        Cerberus = {
            Main = Color3.fromRGB(24, 25, 32),
            Secondary = Color3.fromRGB(40, 41, 52),
            Tertiary = Color3.fromRGB(131, 39, 45),
            StrongText = Color3.fromRGB(255, 255, 255),
            WeakText = Color3.fromRGB(139, 141, 147)
        }
    },
    ColorPickerStyles = {
        Legacy = 0,
        Modern = 1
    },
    Toggled = true,
    ThemeObjects = {
        Main = {},
        Secondary = {},
        Tertiary = {},
        StrongText = {},
        WeakText = {}
    },
    WelcomeText = nil,
    DisplayName = nil,
    DragSpeed = 0.06,
    LockDragging = false,
    ToggleKey = Enum.KeyCode.Home,
    UrlLabel = nil,
    Url = nil,
    Tabs = {}
}

Library.__index = Library

local selectedTab
Library._promptExists = false
Library._colorPickerExists = false

local GlobalTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- Mercury utility functions
function Library:set_defaults(defaults, options)
    defaults = defaults or {}
    options = options or {}
    for option, value in next, options do
        defaults[option] = value
    end
    return defaults
end

function Library:change_theme(toTheme)
    Library.CurrentTheme = toTheme
    if Library.DisplayName then
        local c = self:lighten(toTheme.Tertiary, 20)
        Library.DisplayName.Text = "Welcome, <font color='rgb(" ..  math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")'> <b>" .. LocalPlayer.DisplayName .. "</b> </font>"
    end
    for color, objects in next, Library.ThemeObjects do
        local themeColor = Library.CurrentTheme[color]
        if themeColor then
            for _, obj in next, objects do
                local element, property, theme, colorAlter = obj[1], obj[2], obj[3], obj[4] or 0
                local themeColor = Library.CurrentTheme[theme]
                local modifiedColor = themeColor
                if colorAlter < 0 then
                    modifiedColor = Library:darken(themeColor, -1 * colorAlter)
                elseif colorAlter > 0 then
                    modifiedColor = Library:lighten(themeColor, colorAlter)
                end
                if element and element.tween then
                    element:tween{[property] = modifiedColor}
                end
            end
        end
    end
end

function Library:object(class, properties)
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
        local options = Library:set_defaults({
            Length = 0.2,
            Style = Enum.EasingStyle.Linear,
            Direction = Enum.EasingDirection.InOut
        }, options)
        callback = callback or function() return end

        local ti = TweenInfo.new(options.Length, options.Style, options.Direction)
        options.Length = nil
        options.Style = nil 
        options.Direction = nil

        local tween = TweenService:Create(localObject, ti, options)
        tween:Play()

        tween.Completed:Connect(function()
            callback()
        end)

        return tween
    end

    function methods:round(radius)
        radius = radius or 6
        Library:object("UICorner", {
            Parent = localObject,
            CornerRadius = UDim.new(0, radius)
        })
        return methods
    end

    function methods:object(class, properties)
        local properties = properties or {}
        properties.Parent = localObject
        return Library:object(class, properties)
    end

    function methods:crossfade(p2, length)
        length = length or .2
        self:tween({ImageTransparency = 1})
        p2:tween({ImageTransparency = 0})
    end

    function methods:fade(state, colorOverride, length, instant)
        length = length or 0.2
        if not rawget(self, "fadeFrame") then
            local frame = self:object("Frame", {
                BackgroundColor3 = colorOverride or self.BackgroundColor3,
                BackgroundTransparency = (state and 1) or 0,
                Size = UDim2.fromScale(1, 1),
                Centered = true,
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

    function methods:stroke(color, thickness, strokeMode)
        thickness = thickness or 1
        strokeMode = strokeMode or Enum.ApplyStrokeMode.Border
        local stroke = self:object("UIStroke", {
            ApplyStrokeMode = strokeMode,
            Thickness = thickness
        })

        if type(color) == "table" then
            local theme, colorAlter = color[1], color[2] or 0
            local themeColor = Library.CurrentTheme[theme]
            local modifiedColor = themeColor
            if colorAlter < 0 then
                modifiedColor = Library:darken(themeColor, -1 * colorAlter)
            elseif colorAlter > 0 then
                modifiedColor = Library:lighten(themeColor, colorAlter)
            end
            stroke.Color = modifiedColor
            table.insert(Library.ThemeObjects[theme], {stroke, "Color", theme, colorAlter})
        elseif type(color) == "string" then
            local themeColor = Library.CurrentTheme[color]
            stroke.Color = themeColor
            table.insert(Library.ThemeObjects[color], {stroke, "Color", color, 0})
        else
            stroke.Color = color
        end

        return methods
    end

    local customHandlers = {
        Centered = function(value)
            if value then
                localObject.AnchorPoint = Vector2.new(0.5, 0.5)
                localObject.Position = UDim2.fromScale(0.5, 0.5)
            end       
        end,
        Theme = function(value)
            for property, obj in next, value do
                if type(obj) == "table" then
                    local theme, colorAlter = obj[1], obj[2] or 0
                    local themeColor = Library.CurrentTheme[theme]
                    local modifiedColor = themeColor
                    if colorAlter < 0 then
                        modifiedColor = Library:darken(themeColor, -1 * colorAlter)
                    elseif colorAlter > 0 then
                        modifiedColor = Library:lighten(themeColor, colorAlter)
                    end
                    localObject[property] = modifiedColor
                    table.insert(Library.ThemeObjects[theme], {methods, property, theme, colorAlter})
                else
                    local themeColor = Library.CurrentTheme[obj]
                    localObject[property] = themeColor
                    table.insert(Library.ThemeObjects[obj], {methods, property, obj, 0})
                end
            end
        end,
    }

    for property, value in next, properties do
        if customHandlers[property] then
            customHandlers[property](value)
        else
            localObject[property] = value
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

function Library:show(state)
    self.Toggled = state
    if self.mainFrame then
        self.mainFrame.ClipsDescendants = true
        if state then
            self.mainFrame:tween({Size = self.mainFrame.oldSize, Length = 0.25}, function()
                rawset(self.mainFrame, "oldSize", (state and self.mainFrame.oldSize) or self.mainFrame.Size)
                self.mainFrame.ClipsDescendants = false
            end)
            wait(0.15)
            self.mainFrame:fade(not state, self.mainFrame.BackgroundColor3, 0.15)
        else          
            self.mainFrame:fade(not state, self.mainFrame.BackgroundColor3, 0.15)
            wait(0.1)
            self.mainFrame:tween{Size = UDim2.new(), Length = 0.25}
        end
    end
end

function Library:darken(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s/f, 0, 1), math.clamp(v*f, 0, 1))
end

function Library:lighten(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s*f, 0, 1), math.clamp(v/f, 0, 1))
end

function Library:set_status(txt)
    if self.statusText then
        self.statusText.Text = txt
    end
end

-- Cerberus utility functions
local function animateText(textInstance, animationSpeed, text, placeholderText, fillPlaceHolder, emptyPlaceHolderText)
    if emptyPlaceHolderText then
        for i = #textInstance.PlaceholderText, 0, -1 do
            textInstance.PlaceholderText = textInstance.PlaceholderText:sub(1,i)
            task.wait(animationSpeed)
        end
    else
        for i = #textInstance.Text, 0, -1 do
            textInstance.Text = textInstance.Text:sub(1,i)
            task.wait(animationSpeed)
        end
    end

    if fillPlaceHolder then
        for i = 1, #placeholderText do
            textInstance.PlaceholderText = placeholderText:sub(1, i)
            task.wait(animationSpeed)
        end
    else
        for i = 1, #text do
            textInstance.Text = text:sub(1, i)
            task.wait(animationSpeed)
        end
    end
end

local function toPolar(vector)
    return vector.Magnitude, math.atan2(vector.Y, vector.X)
end

local function toCartesian(radius, theta)
    return math.cos(theta) * radius, math.sin(theta) * radius
end

-- Combined Mercury & Cerberus window creation
function Library:create(options)
    local settings = {
        Theme = "Dark"
    }

    if readfile and writefile and isfile then
        if not isfile("RuvexSettings.json") then
            writefile("RuvexSettings.json", HTTPService:JSONEncode(settings))
        end
        settings = HTTPService:JSONDecode(readfile("RuvexSettings.json"))
        Library.CurrentTheme = Library.Themes[settings.Theme]
    else
        Library.CurrentTheme = Library.Themes.Dark
    end

    options = self:set_defaults({
        Name = "Ruvex",
        Size = UDim2.fromOffset(750, 500),
        Theme = self.CurrentTheme,
        Link = "https://github.com/ruvex/ui-lib"
    }, options)

    if getgenv and getgenv().RuvexUI then
        getgenv():RuvexUI()
        getgenv().RuvexUI = nil
    end

    if options.Link:sub(-1, -1) == "/" then
        options.Link = options.Link:sub(1, -2)
    end

    self.CurrentTheme = options.Theme

    local gui = self:object("ScreenGui", {
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Name = "Ruvex"
    })

    -- Protect GUI
    if syn and syn.protect_gui then
        syn.protect_gui(gui.AbsoluteObject)
    end

    local notificationHolder = gui:object("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30,1, -30),
        Size = UDim2.new(0, 300, 1, -60)
    })

    local _notiHolderList = notificationHolder:object("UIListLayout", {
        Padding = UDim.new(0, 20),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    -- Main window (Mercury base with Cerberus styling)
    local core = gui:object("Frame", {
        Size = UDim2.new(),
        Theme = {BackgroundColor3 = "Main"},
        Centered = true,
        ClipsDescendants = true             
    }):round(10)

    core:fade(true, nil, 0.2, true)
    core:fade(false, nil, 0.4)
    core:tween({Size = options.Size, Length = 0.3}, function()
        core.ClipsDescendants = false
    end)

    -- Mercury dragging system
    do
        local S, Event = pcall(function()
            return core.MouseEnter
        end)

        if S then
            core.Active = true

            Event:connect(function()
                local Input = core.InputBegan:connect(function(Key)
                    if Key.UserInputType == Enum.UserInputType.MouseButton1 then
                        local ObjectPosition = Vector2.new(Mouse.X - core.AbsolutePosition.X, Mouse.Y - core.AbsolutePosition.Y)
                        while RunService.RenderStepped:wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            if Library.LockDragging then
                                local FrameX, FrameY = math.clamp(Mouse.X - ObjectPosition.X, 0, gui.AbsoluteSize.X - core.AbsoluteSize.X), math.clamp(Mouse.Y - ObjectPosition.Y, 0, gui.AbsoluteSize.Y - core.AbsoluteSize.Y)
                                core:tween{
                                    Position = UDim2.fromOffset(FrameX + (core.Size.X.Offset * core.AnchorPoint.X), FrameY + (core.Size.Y.Offset * core.AnchorPoint.Y)),
                                    Length = Library.DragSpeed
                                }
                            else
                                core:tween{
                                    Position = UDim2.fromOffset(Mouse.X - ObjectPosition.X + (core.Size.X.Offset * core.AnchorPoint.X), Mouse.Y - ObjectPosition.Y + (core.Size.Y.Offset * core.AnchorPoint.Y)),
                                    Length = Library.DragSpeed    
                                }
                            end       
                        end
                    end
                end)

                local Leave
                Leave = core.MouseLeave:connect(function()
                    Input:disconnect()
                    Leave:disconnect()
                end)
            end)
        end
    end

    rawset(core, "oldSize", options.Size)
    self.mainFrame = core

    -- Cerberus-style header
    local heading = core:object("Frame", {
        Theme = {BackgroundColor3 = "Secondary"},
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0)
    }):round(10)

    -- Header corner fix
    local headingCornerHiding = heading:object("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 10)
    })

    local headingSeperator = heading:object("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Tertiary"},
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2)
    })

    local title = heading:object("TextLabel", {
        Theme = {TextColor3 = "StrongText"},
        Size = UDim2.new(0.7, 0, 1, 0),
        Text = options.Name,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    title:object("UIPadding", {
        PaddingLeft = UDim.new(0, 15)
    })

    -- Window controls (Cerberus style)
    local buttonHolder = heading:object("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0)
    })

    buttonHolder:object("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6)
    })

    buttonHolder:object("UIPadding", {
        PaddingRight = UDim.new(0, 6)
    })

    local minus = buttonHolder:object("ImageButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.5, 0),
        Image = "rbxassetid://11520996670",
        Theme = {ImageColor3 = "StrongText"}
    })

    local close = buttonHolder:object("ImageButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.5, 0),
        Image = "rbxassetid://11520882762",
        ImageRectOffset = Vector2.new(48, 0),
        ImageRectSize = Vector2.new(20, 20),
        Theme = {ImageColor3 = "StrongText"}
    })

    -- Window close functionality
    local function closeUI()
        core.ClipsDescendants = true
        core:fade(true)
        wait(0.1)
        core:tween({Size = UDim2.new()}, function()
            gui.AbsoluteObject:Destroy()
        end)
    end

    if getgenv then
        getgenv().RuvexUI = closeUI
    end

    close.MouseButton1Click:connect(function()
        closeUI()
    end)

    minus.MouseButton1Click:connect(function()
        self:show(false)
    end)

    -- Container for pages (Cerberus + Mercury hybrid)
    local holder = core:object("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })

    -- Tab system (Mercury style)
    local tabs = holder:object("ScrollingFrame", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 5, 1, -5),
        Size = UDim2.new(0.225, 0, 1, -15),
        ScrollBarThickness = 0
    })

    tabs:object("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    -- Page container
    local pageContainer = holder:object("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -5),
        Size = UDim2.new(0.775, -25, 1, -15)
    })

    -- Page logo background
    local pageLogo = pageContainer:object("ImageLabel", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -5),
        Size = UDim2.new(0.774999976, -25, 1, -15),
        ZIndex = 0,
        Image = "rbxassetid://11435586663",
        Theme = {ImageColor3 = "WeakText"},
        ImageTransparency = 0.9
    })

    self.container = pageContainer
    self.tabs = tabs
    self.core = core
    self.gui = gui
    self.notificationHolder = notificationHolder

    return self
end

-- Notification system (Mercury enhanced)
function Library:notify(options)
    options = self:set_defaults({
        Title = "Notification",
        Text = "Sample text",
        Duration = 5,
        Callback = function() end
    }, options)

    local noti = self.notificationHolder:object("Frame", {
        Size = UDim2.fromOffset(300, 0),
        Theme = {BackgroundColor3 = "Main"},
        BackgroundTransparency = 1
    }):round(5)

    local _shadow = noti:object("ImageLabel", {
        ZIndex = -1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.new(1, 70,1, 70),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280)
    })

    local fadeOut

    local durationHolder = noti:object("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 1,1, -1),
        Size = UDim2.new(1, 0,0, 4)
    }):round(100)

    local length = durationHolder:object("Frame", {
        BackgroundTransparency = 1,
        Theme = {BackgroundColor3 = "Tertiary"},
        Size = UDim2.fromScale(1, 1)
    }):round(100)

    local icon = noti:object("ImageLabel", {
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.fromOffset(18, 18),
        Image = "rbxassetid://8628681683",
        Theme = {ImageColor3 = "Tertiary"}
    })

    local exit = noti:object("ImageButton", {
        Image = "http://www.roblox.com/asset/?id=8497487650",
        AnchorPoint = Vector2.new(1, 0),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(1, -3,0, 3),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        ImageTransparency = 1
    })

    exit.MouseButton1Click:Connect(function()
        fadeOut()
    end)

    local text = noti:object("TextLabel", {
        BackgroundTransparency = 1,
        Text = options.Text,
        Position = UDim2.new(0, 0,0, 23),
        Size = UDim2.new(1, 0, 100, 0),
        TextSize = 16,
        TextTransparency = 1,
        TextWrapped = true,
        Theme = {TextColor3 = "StrongText"},
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    text:tween({Size = UDim2.new(1, 0, 0, text.TextBounds.Y)})

    local titleLabel = noti:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(23, 0),
        Size = UDim2.new(1, -60,0, 20),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1
    })

    fadeOut = function()
        task.delay(0.3, function()
            noti.AbsoluteObject:Destroy()
            options.Callback()
        end)

        icon:tween({ImageTransparency = 1, Length = 0.2})
        exit:tween({ImageTransparency = 1, Length = 0.2})
        durationHolder:tween({BackgroundTransparency = 1, Length = 0.2})
        length:tween({BackgroundTransparency = 1, Length = 0.2})
        text:tween({TextTransparency = 1, Length = 0.2})
        titleLabel:tween({TextTransparency = 1, Length = 0.2}, function()
            _shadow:tween({ImageTransparency = 1, Length = 0.2})
            noti:tween({BackgroundTransparency = 1, Length = 0.2, Size = UDim2.fromOffset(300, 0)})
        end)
    end

    _shadow:tween({ImageTransparency = .6, Length = 0.2})
    noti:tween({BackgroundTransparency = 0, Length = 0.2, Size = UDim2.fromOffset(300, text.TextBounds.Y + 63)}, function()
        icon:tween({ImageTransparency = 0, Length = 0.2})
        exit:tween({ImageTransparency = 0, Length = 0.2})
        durationHolder:tween({BackgroundTransparency = 0, Length = 0.2})
        length:tween({BackgroundTransparency = 0, Length = 0.2})
        text:tween({TextTransparency = 0, Length = 0.2})
        titleLabel:tween({TextTransparency = 0, Length = 0.2})
    end)

    length:tween({Size = UDim2.fromScale(0, 1), Length = options.Duration}, function()
        fadeOut()
    end)
end

-- Tab creation (Mercury + Cerberus hybrid)
function Library:tab(options)
    options = self:set_defaults({
        Name = "New Tab",
        Icon = "rbxassetid://10746039695"
    }, options)

    -- Create tab button (Cerberus style)
    local tabButton = self.tabs:object("TextButton", {
        Theme = {BackgroundColor3 = "Secondary"},
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        Text = ""
    })

    local tabText = tabButton:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.035, 30, 0, 0),
        Size = UDim2.new(0.965, -30, 1, 0),
        Text = options.Name,
        Theme = {TextColor3 = "WeakText"},
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    })

    tabText:object("UIPadding", {
        PaddingLeft = UDim.new(0, 3)
    })

    local tabImage = tabButton:object("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.035, 5, 0.5, 0),
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Image = options.Icon,
        Theme = {ImageColor3 = "WeakText"}
    })

    tabImage:object("UIAspectRatioConstraint", {})

    local tabSeperator = tabButton:object("Frame", {
        Theme = {BackgroundColor3 = "Tertiary"},
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 3, 1, 0)
    }):round(2)

    -- Create page (Mercury style with Cerberus layout)
    local page = self.container:object("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -5),
        Visible = false,
        Size = UDim2.new(0.775, -25, 1, -15)
    })

    -- Left and right scrolling frames (Cerberus style)
    local leftScrollingFrame = page:object("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -5, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.CurrentTheme.Tertiary,
        CanvasSize = UDim2.fromScale(0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    leftScrollingFrame:object("UIListLayout", {
        Padding = UDim.new(0,7),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    local rightScrollingFrame = page:object("ScrollingFrame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        CanvasSize = UDim2.fromScale(0,0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.CurrentTheme.Tertiary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    rightScrollingFrame:object("UIListLayout", {
        Padding = UDim.new(0,7),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    self.Tabs[#self.Tabs+1] = {page, tabButton, options.Name, leftScrollingFrame, rightScrollingFrame}

    -- Tab functionality
    local function selectTab()
        for _, tabInfo in next, self.Tabs do
            local tabPage = tabInfo[1]
            local tabBtn = tabInfo[2]
            tabPage.Visible = false
            tabBtn:tween{BackgroundTransparency = 1}
            local btnText = tabBtn:FindFirstChild("TabText") or tabBtn:GetChildren()[1]
            local btnImage = tabBtn:FindFirstChild("TabImage") or tabBtn:GetChildren()[2] 
            local btnSep = tabBtn:FindFirstChild("TabSeperator") or tabBtn:GetChildren()[3]
            if btnText then btnText:tween{TextColor3 = self.CurrentTheme.WeakText} end
            if btnImage then btnImage:tween{ImageColor3 = self.CurrentTheme.WeakText} end
            if btnSep then btnSep:tween{BackgroundTransparency = 1} end
        end

        selectedTab = tabButton
        page.Visible = true
        tabButton:tween{BackgroundTransparency = 0.1}
        tabText:tween{TextColor3 = self.CurrentTheme.StrongText}
        tabImage:tween{ImageColor3 = self.CurrentTheme.Tertiary}
        tabSeperator:tween{BackgroundTransparency = 0}
    end

    -- Hover effects (Cerberus style)
    tabButton.MouseEnter:connect(function()
        if selectedTab ~= tabButton then
            tabButton:tween{BackgroundTransparency = 0.9}
        end
    end)

    tabButton.MouseLeave:connect(function()
        if selectedTab ~= tabButton then
            tabButton:tween{BackgroundTransparency = 1}
        end
    end)

    tabButton.MouseButton1Click:connect(function()
        selectTab()
    end)

    -- Select first tab
    if #self.Tabs == 1 then
        selectTab()
    end

    return setmetatable({
        leftFrame = leftScrollingFrame,
        rightFrame = rightScrollingFrame,
        page = page,
        tabButton = tabButton,
        container = leftScrollingFrame
    }, Library)
end

-- Toggle (Mercury + Cerberus styling)
function Library:toggle(options)
    options = self:set_defaults({
        Name = "Toggle",
        StartingState = false,
        Description = nil,
        Callback = function(state) end
    }, options)

    if options.StartingState then options.Callback(true) end

    local toggleContainer = self.container:object("TextButton", {
        Theme = {BackgroundColor3 = "Secondary"},
        Size = UDim2.new(1, -20, 0, 52)
    }):round(7)

    local toggled = options.StartingState

    local toggleFrame = toggleContainer:object("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Theme = {BackgroundColor3 = {"Secondary", 20}},
        Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20)
    }):round(10)

    local toggleCircle = toggleFrame:object("Frame", {
        Theme = {BackgroundColor3 = toggled and "Tertiary" or "WeakText"},
        Position = UDim2.new(0, toggled and 22 or 2, 0, 2),
        Size = UDim2.new(0, 16, 0, 16)
    }):round(8)

    local text = toggleContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, (options.Description and 5) or 0),
        Size = (options.Description and UDim2.new(0.5, -10, 0, 22)) or UDim2.new(0.5, -10, 1, 0),
        Text = options.Name,
        TextSize = 22,
        Theme = {TextColor3 = "StrongText"},
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if options.Description then
        local description = toggleContainer:object("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 27),
            Size = UDim2.new(0.5, -10, 0, 20),
            Text = options.Description,
            TextSize = 18,
            Theme = {TextColor3 = "WeakText"},
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local function toggle()
        toggled = not toggled
        toggleCircle:tween{
            Position = UDim2.new(0, toggled and 22 or 2, 0, 2),
            BackgroundColor3 = toggled and self.CurrentTheme.Tertiary or self.CurrentTheme.WeakText
        }
        options.Callback(toggled)
    end

    do
        local hovered = false

        toggleContainer.MouseEnter:connect(function()
            hovered = true
            toggleContainer:tween{BackgroundColor3 = self:lighten(Library.CurrentTheme.Secondary, 10)}
        end)

        toggleContainer.MouseLeave:connect(function()
            hovered = false
            toggleContainer:tween{BackgroundColor3 = Library.CurrentTheme.Secondary}
        end)

        toggleContainer.MouseButton1Click:connect(function()
            toggle()
        end)
    end

    local methods = {}
    function methods:Toggle() toggle() end
    function methods:SetState(state)
        toggled = state
        toggleCircle:tween{
            Position = UDim2.new(0, toggled and 22 or 2, 0, 2),
            BackgroundColor3 = toggled and self.CurrentTheme.Tertiary or self.CurrentTheme.WeakText
        }
        options.Callback(toggled)
    end

    return methods
end

-- Button (Mercury + Cerberus styling)
function Library:button(options)
    options = self:set_defaults({
        Name = "Button",
        Description = nil,
        Callback = function() end
    }, options)

    local buttonContainer = self.container:object("TextButton", {
        Theme = {BackgroundColor3 = "Secondary"},
        Size = UDim2.new(1, -20, 0, 52)
    }):round(7)

    local text = buttonContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, (options.Description and 5) or 0),
        Size = (options.Description and UDim2.new(0.5, -10, 0, 22)) or UDim2.new(0.5, -10, 1, 0),
        Text = options.Name,
        TextSize = 22,
        Theme = {TextColor3 = "StrongText"},
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if options.Description then
        local description = buttonContainer:object("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 27),
            Size = UDim2.new(0.5, -10, 0, 20),
            Text = options.Description,
            TextSize = 18,
            Theme = {TextColor3 = "WeakText"},
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local icon = buttonContainer:object("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        Image = "rbxassetid://8498776661",
        Theme = {ImageColor3 = "Tertiary"}
    })

    do
        local hovered = false

        buttonContainer.MouseEnter:connect(function()
            hovered = true
            buttonContainer:tween{BackgroundColor3 = self:lighten(Library.CurrentTheme.Secondary, 10)}
        end)

        buttonContainer.MouseLeave:connect(function()
            hovered = false
            buttonContainer:tween{BackgroundColor3 = Library.CurrentTheme.Secondary}
        end)

        buttonContainer.MouseButton1Click:connect(function()
            options.Callback()
        end)
    end

    local methods = {}
    function methods:Fire() options.Callback() end
    function methods:SetText(txt) text.Text = txt end

    return methods
end

-- Dropdown (Mercury + Cerberus hybrid)
function Library:dropdown(options)
    options = self:set_defaults({
        Name = "Dropdown",
        StartingText = "Select...",
        Items = {},
        Callback = function(item) return end
    }, options)

    local newSize = 0
    local open = false

    local dropdownContainer = self.container:object("TextButton", {
        Theme = {BackgroundColor3 = "Secondary"},
        Size = UDim2.new(1, -20, 0, 52)
    }):round(7)

    local text = dropdownContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 15),
        Size = UDim2.new(0.5, -10, 0, 22),
        Text = options.Name,
        TextSize = 22,
        Theme = {TextColor3 = "StrongText"},
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local icon = dropdownContainer:object("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -11, 0, 12),
        Size = UDim2.fromOffset(26, 26),
        Image = "rbxassetid://8498840035",
        Theme = {ImageColor3 = "Tertiary"}
    })

    local selectedText = dropdownContainer:object("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Theme = {
            BackgroundColor3 = {"Secondary", -20},
            TextColor3 = "WeakText"
        },
        Position = UDim2.new(1, -50, 0, 16),
        Size = UDim2.fromOffset(200, 20),
        TextSize = 14,
        Text = options.StartingText
    }):round(5):stroke("Tertiary")

    local itemContainer = dropdownContainer:object("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 55),
        Size = UDim2.new(1, -10, 0, 0),
        ClipsDescendants = true
    })

    selectedText.Size = UDim2.fromOffset(selectedText.TextBounds.X + 20, 20)

    local _gridItemContainer = itemContainer:object("UIGridLayout", {
        CellPadding = UDim2.fromOffset(0, 5),
        CellSize = UDim2.new(1, 0, 0, 20),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })

    local items = {}
    for i, v in next, options.Items do
        if typeof(v) == "table" then
            items[i] = v
        else
            items[i] = {tostring(v), v}
        end
    end

    local toggle

    for i, item in next, items do
        local label = item[1]
        local value = item[2]

        local newItem = itemContainer:object("TextButton", {
            Theme = {
                BackgroundColor3 = {"Secondary", 25},
                TextColor3 = {"StrongText", 25}
            },
            Text = label,
            TextSize = 14
        }):round(5)

        items[i] = {{label, value}, newItem}

        newItem.MouseEnter:connect(function()
            newItem:tween{BackgroundColor3 = Library.CurrentTheme.Tertiary}
        end)

        newItem.MouseLeave:connect(function()
            newItem:tween{BackgroundColor3 = self:lighten(Library.CurrentTheme.Secondary, 25)}
        end)

        newItem.MouseButton1Click:connect(function()
            toggle()
            selectedText.Text = newItem.Text
            selectedText:tween{Size = UDim2.fromOffset(selectedText.TextBounds.X + 20, 20), Length = 0.05}
            options.Callback(value)
        end)
    end

    do
        local hovered = false

        newSize = (25 * #items) + 5
        itemContainer.Size = (not open and UDim2.new(1, -10, 0, 0)) or UDim2.new(1, -10, 0, newSize)

        toggle = function()
            newSize = (25 * #items) + 5
            open = not open
            if open then
                itemContainer:tween{Size = UDim2.new(1, -10, 0, newSize)}
                dropdownContainer:tween{Size = UDim2.new(1, -20, 0, 52 + newSize)}
                icon:tween{Rotation = 180, Position = UDim2.new(1, -11, 0, 15)}
            else
                itemContainer:tween{Size = UDim2.new(1, -10, 0, 0)}
                dropdownContainer:tween{Size = UDim2.new(1, -20, 0, 52)}
                icon:tween{Rotation = 0, Position = UDim2.new(1, -11, 0, 12)}
            end
        end

        dropdownContainer.MouseEnter:connect(function()
            hovered = true
            dropdownContainer:tween{BackgroundColor3 = self:lighten(Library.CurrentTheme.Secondary, 10)}
        end)

        dropdownContainer.MouseLeave:connect(function()
            hovered = false
            dropdownContainer:tween{BackgroundColor3 = Library.CurrentTheme.Secondary}
        end)

        dropdownContainer.MouseButton1Click:connect(function()
            toggle()
        end)
    end

    local methods = {}
    function methods:Set(text_)
        selectedText.Text = text_
        selectedText:tween{Size = UDim2.fromOffset(selectedText.TextBounds.X + 20, 20), Length = 0.05}
    end

    return methods
end

-- Slider (Cerberus style)
function Library:slider(options)
    options = self:set_defaults({
        Name = "Slider",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(value) end
    }, options)

    local sliderContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 32)
    })

    local textGrouping = sliderContainer:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14)
    })

    local numberText = textGrouping:object("TextBox", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Theme = {TextColor3 = "WeakText"},
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(options.Default)
    })

    local sliderText = textGrouping:object("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Theme = {TextColor3 = "StrongText"},
        Text = options.Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sliderBackground = sliderContainer:object("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0.5, -2),
        Text = ""
    }):round(7)

    local emptySliderBackground = sliderBackground:object("Frame", {
        Theme = {BackgroundColor3 = {"Secondary", 20}},
        Size = UDim2.new(1, 0, 1, 0)
    }):round(7)

    local slider = sliderBackground:object("Frame", {
        Theme = {BackgroundColor3 = "Tertiary"},
        Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0)
    }):round(7)

    local value = options.Default

    local function updateSlider()
        local percentage = math.clamp((value - options.Min) / (options.Max - options.Min), 0, 1)
        slider:tween{Size = UDim2.new(percentage, 0, 1, 0)}
        numberText.Text = tostring(value)
        options.Callback(value)
    end

    local dragging = false

    sliderBackground.MouseButton1Down:connect(function()
        dragging = true
        while dragging and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            local mouse = Mouse
            local relativeX = math.clamp((mouse.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
            value = math.floor(options.Min + (relativeX * (options.Max - options.Min)))
            updateSlider()
            RunService.RenderStepped:Wait()
        end
        dragging = false
    end)

    numberText.FocusLost:connect(function()
        local newValue = tonumber(numberText.Text)
        if newValue and newValue >= options.Min and newValue <= options.Max then
            value = newValue
            updateSlider()
        else
            numberText.Text = tostring(value)
        end
    end)

    updateSlider()

    local methods = {}
    function methods:SetValue(newValue)
        value = math.clamp(newValue, options.Min, options.Max)
        updateSlider()
    end

    return methods
end

-- Textbox (Cerberus style)
function Library:textbox(options)
    options = self:set_defaults({
        Name = "Textbox",
        PlaceholderText = "Type here...",
        Default = "",
        Callback = function(text) end
    }, options)

    local textboxContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18)
    })

    local textboxNameText = textboxContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -18, 1, 0),
        Theme = {TextColor3 = "StrongText"},
        Text = options.Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local boxBackground = textboxContainer:object("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0)
    }):round(7)

    local textBoxText = boxBackground:object("TextBox", {
        Theme = {
            BackgroundColor3 = {"Secondary", 20},
            TextColor3 = "WeakText"
        },
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        PlaceholderText = options.PlaceholderText,
        Text = options.Default,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }):round(5)

    textBoxText.FocusLost:connect(function()
        options.Callback(textBoxText.Text)
    end)

    local methods = {}
    function methods:SetText(text)
        textBoxText.Text = text
    end

    return methods
end

-- Keybind (Cerberus style)  
function Library:keybind(options)
    options = self:set_defaults({
        Name = "Keybind",
        Default = Enum.KeyCode.None,
        Callback = function(key) end
    }, options)

    local keybindContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18)
    })

    local keybindText = keybindContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -18, 1, 0),
        Theme = {TextColor3 = "StrongText"},
        Text = options.Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local boxBackground = keybindContainer:object("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Theme = {BackgroundColor3 = "Secondary"},
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0)
    }):round(7)

    local keyText = boxBackground:object("TextLabel", {
        Theme = {
            BackgroundColor3 = {"Secondary", 20},
            TextColor3 = "WeakText"
        },
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 3, 0, 0),
        Text = (options.Default == Enum.KeyCode.None and "None") or options.Default.Name,
        TextSize = 14
    }):round(5)

    local currentKey = options.Default
    local listening = false

    boxBackground.MouseButton1Click:connect(function()
        if listening then return end
        listening = true
        keyText.Text = "Press any key..."
        
        local connection
        connection = UserInputService.InputBegan:connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyText.Text = input.KeyCode.Name
                listening = false
                connection:Disconnect()
                options.Callback(currentKey)
            end
        end)
    end)

    local methods = {}
    function methods:SetKey(key)
        currentKey = key
        keyText.Text = (key == Enum.KeyCode.None and "None") or key.Name
    end

    return methods
end

-- Label (Simple text display)
function Library:label(options)
    options = self:set_defaults({
        Name = "Label",
        Text = "Sample text"
    }, options)

    local labelContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25)
    })

    local text = labelContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = options.Text,
        TextSize = 16,
        Theme = {TextColor3 = "StrongText"},
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    local methods = {}
    function methods:SetText(newText)
        text.Text = newText
    end

    return methods
end

-- Section divider
function Library:section(options)
    options = self:set_defaults({
        Name = "Section"
    }, options)

    local sectionContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30)
    })

    local line = sectionContainer:object("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -40, 0, 1),
        Theme = {BackgroundColor3 = "Tertiary"}
    })

    local text = sectionContainer:object("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 20),
        Theme = {
            BackgroundColor3 = "Main",
            TextColor3 = "Tertiary"
        },
        Text = "  " .. options.Name .. "  ",
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })

    text.Size = UDim2.new(0, text.TextBounds.X, 0, 20)

    return {}
end

-- Color picker (Enhanced from Mercury)
function Library:colorpicker(options)
    options = self:set_defaults({
        Name = "Color Picker",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color) end
    }, options)

    local colorContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18)
    })

    local colorText = colorContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Theme = {TextColor3 = "StrongText"},
        Text = options.Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local colorDisplay = colorContainer:object("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = options.Default,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Text = ""
    }):round(5):stroke("Tertiary")

    local currentColor = options.Default

    colorDisplay.MouseButton1Click:connect(function()
        if Library._colorPickerExists then return end
        Library._colorPickerExists = true

        local darkener = self.core:object("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 100
        })

        local pickerFrame = darkener:object("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 200, 0, 250),
            Theme = {BackgroundColor3 = "Secondary"},
            ZIndex = 101
        }):round(10)

        local titleText = pickerFrame:object("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Choose Color",
            Theme = {TextColor3 = "StrongText"},
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 102
        })

        local colorPreview = pickerFrame:object("Frame", {
            Position = UDim2.new(0, 10, 0, 40),
            Size = UDim2.new(1, -20, 0, 30),
            BackgroundColor3 = currentColor,
            ZIndex = 102
        }):round(5)

        local rSlider = pickerFrame:object("Frame", {
            Position = UDim2.new(0, 10, 0, 80),
            Size = UDim2.new(1, -20, 0, 20),
            BackgroundTransparency = 1,
            ZIndex = 102
        })

        local rLabel = rSlider:object("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Text = "R:",
            Theme = {TextColor3 = "StrongText"},
            TextSize = 14,
            ZIndex = 102
        })

        local rBar = rSlider:object("Frame", {
            Position = UDim2.new(0, 25, 0, 8),
            Size = UDim2.new(1, -50, 0, 4),
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            ZIndex = 102
        }):round(2)

        local rValue = rSlider:object("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            Text = tostring(math.floor(currentColor.R * 255)),
            Theme = {TextColor3 = "WeakText"},
            TextSize = 14,
            ZIndex = 102
        })

        -- Similar setup for G and B sliders...
        local gSlider = pickerFrame:object("Frame", {
            Position = UDim2.new(0, 10, 0, 110),
            Size = UDim2.new(1, -20, 0, 20),
            BackgroundTransparency = 1,
            ZIndex = 102
        })

        local gLabel = gSlider:object("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Text = "G:",
            Theme = {TextColor3 = "StrongText"},
            TextSize = 14,
            ZIndex = 102
        })

        local gBar = gSlider:object("Frame", {
            Position = UDim2.new(0, 25, 0, 8),
            Size = UDim2.new(1, -50, 0, 4),
            BackgroundColor3 = Color3.fromRGB(0, 255, 0),
            ZIndex = 102
        }):round(2)

        local gValue = gSlider:object("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            Text = tostring(math.floor(currentColor.G * 255)),
            Theme = {TextColor3 = "WeakText"},
            TextSize = 14,
            ZIndex = 102
        })

        local bSlider = pickerFrame:object("Frame", {
            Position = UDim2.new(0, 10, 0, 140),
            Size = UDim2.new(1, -20, 0, 20),
            BackgroundTransparency = 1,
            ZIndex = 102
        })

        local bLabel = bSlider:object("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Text = "B:",
            Theme = {TextColor3 = "StrongText"},
            TextSize = 14,
            ZIndex = 102
        })

        local bBar = bSlider:object("Frame", {
            Position = UDim2.new(0, 25, 0, 8),
            Size = UDim2.new(1, -50, 0, 4),
            BackgroundColor3 = Color3.fromRGB(0, 0, 255),
            ZIndex = 102
        }):round(2)

        local bValue = bSlider:object("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            Text = tostring(math.floor(currentColor.B * 255)),
            Theme = {TextColor3 = "WeakText"},
            TextSize = 14,
            ZIndex = 102
        })

        -- Buttons
        local buttonFrame = pickerFrame:object("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 10, 1, -10),
            Size = UDim2.new(1, -20, 0, 30),
            BackgroundTransparency = 1,
            ZIndex = 102
        })

        local confirmButton = buttonFrame:object("TextButton", {
            Size = UDim2.new(0.5, -5, 1, 0),
            Theme = {BackgroundColor3 = "Tertiary"},
            Text = "Confirm",
            TextSize = 14,
            Theme = {TextColor3 = "StrongText"},
            ZIndex = 102
        }):round(5)

        local cancelButton = buttonFrame:object("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0.5, -5, 1, 0),
            Theme = {BackgroundColor3 = "WeakText"},
            Text = "Cancel",
            TextSize = 14,
            Theme = {TextColor3 = "StrongText"},
            ZIndex = 102
        }):round(5)

        local function updateColor()
            local r = math.floor(currentColor.R * 255)
            local g = math.floor(currentColor.G * 255)
            local b = math.floor(currentColor.B * 255)
            
            colorPreview:tween{BackgroundColor3 = currentColor}
            rValue.Text = tostring(r)
            gValue.Text = tostring(g)
            bValue.Text = tostring(b)
        end

        local function closePicker()
            darkener:tween({BackgroundTransparency = 1}, function()
                darkener.AbsoluteObject:Destroy()
                Library._colorPickerExists = false
            end)
        end

        confirmButton.MouseButton1Click:connect(function()
            colorDisplay:tween{BackgroundColor3 = currentColor}
            options.Callback(currentColor)
            closePicker()
        end)

        cancelButton.MouseButton1Click:connect(function()
            closePicker()
        end)

        updateColor()
    end)

    local methods = {}
    function methods:SetColor(color)
        currentColor = color
        colorDisplay:tween{BackgroundColor3 = color}
    end

    return methods
end

-- Theme selector
function Library:theme_selector()
    local themeContainer = self.container:object("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 80)
    })

    local themeText = themeContainer:object("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Text = "Theme Selection",
        Theme = {TextColor3 = "StrongText"},
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local themeGrid = themeContainer:object("Frame", {
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 1, -25),
        BackgroundTransparency = 1
    })

    themeGrid:object("UIGridLayout", {
        CellSize = UDim2.new(0.2, -5, 0, 45),
        CellPadding = UDim2.new(0, 5, 0, 5)
    })

    for themeName, themeData in pairs(Library.Themes) do
        local themeButton = themeGrid:object("TextButton", {
            BackgroundColor3 = themeData.Secondary,
            Text = "",
            ZIndex = 2
        }):round(8):stroke("Tertiary", 2)

        local themeLabel = themeButton:object("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.6, 0),
            Text = themeName,
            TextColor3 = themeData.StrongText,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 3
        })

        local accentShow = themeButton:object("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -5),
            Size = UDim2.new(0.8, 0, 0, 8),
            BackgroundColor3 = themeData.Tertiary,
            ZIndex = 3
        }):round(4)

        themeButton.MouseButton1Click:connect(function()
            self:change_theme(themeData)
            if isfile and writefile then
                writefile("RuvexSettings.json", HTTPService:JSONEncode({Theme = themeName}))
            end
        end)

        themeButton.MouseEnter:connect(function()
            themeButton:tween{Size = UDim2.new(1, 5, 1, 5)}
        end)

        themeButton.MouseLeave:connect(function()
            themeButton:tween{Size = UDim2.new(1, 0, 1, 0)}
        end)
    end

    return {}
end

-- Global toggle visibility function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Library.ToggleKey then
        Library.Toggled = not Library.Toggled
        if Library.mainFrame then
            Library:show(Library.Toggled)
        end
    end
end)

-- Initialize function for easy setup
function Library.init()
    local lib = Library:create({
        Name = "Ruvex UI Library",
        Size = UDim2.fromOffset(750, 500),
        Theme = Library.CurrentTheme
    })
    
    lib:notify({
        Title = "Ruvex UI",
        Text = "Library loaded successfully! Press Home to toggle visibility.",
        Duration = 3
    })
    
    return lib
end

return Library
