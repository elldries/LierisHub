--[[
  ____  _   ___     ________   __
 |  _ \| | | \ \   / /  ____| \ \   / /
 | |_) | | | |\ \ / /| |__     \ \_/ / 
 |  _ <| | | | \ V / |  __|     \   /  
 | |_) | |_| |  | |  | |____     | |   
 |____/ \___/   |_|  |______|    |_|   

Ruvex UI Library - Advanced Roblox UI System
Combining ALL functionality from Mercury, Flux, Cerberus, Criminality, PPHud & Luminosity
Color Scheme: Red, Dark, Black, White
Compatible with all Roblox executors
Cross-device support with responsive design
]]

local Ruvex = {
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    flags = {},
    Flags = {},
    ThemeObjects = {
        Main = {},
        Secondary = {},
        Tertiary = {},
        Accent = {},
        Background = {},
        Text = {},
        SecondaryText = {},
        Divider = {},
        Success = {},
        Warning = {},
        Error = {}
    },
    Toggled = true,
    DragSpeed = 0.06,
    LockDragging = false,
    ToggleKey = Enum.KeyCode.Home,
    CurrentTheme = "Dark",
    Windows = {},
    Notifications = {}
}

Ruvex.Flags = Ruvex.flags

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize

-- Multiple Theme System (From Mercury)
local Themes = {
    Dark = {
        Main = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Tertiary = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(220, 50, 47),
        DarkerAccent = Color3.fromRGB(180, 35, 32),
        Background = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(180, 180, 180),
        TertiaryText = Color3.fromRGB(130, 130, 130),
        Divider = Color3.fromRGB(55, 55, 55),
        Hover = Color3.fromRGB(220, 50, 47),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69)
    },
    Crimson = {
        Main = Color3.fromRGB(18, 12, 12),
        Secondary = Color3.fromRGB(28, 18, 18),
        Tertiary = Color3.fromRGB(48, 28, 28),
        Accent = Color3.fromRGB(200, 30, 30),
        DarkerAccent = Color3.fromRGB(160, 20, 20),
        Background = Color3.fromRGB(38, 22, 22),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(180, 180, 180),
        TertiaryText = Color3.fromRGB(130, 130, 130),
        Divider = Color3.fromRGB(55, 35, 35),
        Hover = Color3.fromRGB(200, 30, 30),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69)
    },
    Midnight = {
        Main = Color3.fromRGB(8, 8, 12),
        Secondary = Color3.fromRGB(18, 18, 22),
        Tertiary = Color3.fromRGB(38, 38, 42),
        Accent = Color3.fromRGB(255, 20, 20),
        DarkerAccent = Color3.fromRGB(200, 15, 15),
        Background = Color3.fromRGB(28, 28, 32),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(180, 180, 180),
        TertiaryText = Color3.fromRGB(130, 130, 130),
        Divider = Color3.fromRGB(48, 48, 52),
        Hover = Color3.fromRGB(255, 20, 20),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69)
    }
}

local Colors = Themes[Ruvex.CurrentTheme]

-- Compatibility Layer (From Cerberus/Criminality/PPHUD)
local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder

-- GUI Detection Bypass (Enhanced from Cerberus)
if not getgenv().RuvexBypassLoaded then
    getgenv().RuvexBypassLoaded = true
    local RobloxGuis = {"RobloxGui", "TeleportGui", "RobloxPromptGui", "RobloxLoadingGui", "PlayerList", "RobloxNetworkPauseNotification", "PurchasePrompt", "HeadsetDisconnectedDialog", "ThemeProvider", "DevConsoleMaster"}
    
    local function FilterTable(tbl)
        if not syn_context_get then return tbl end
        local context = syn_context_get()
        syn_context_set(7)
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
        syn_context_set(context)
        return new
    end
    
    if hookfunc and game.ContentProvider then
        local old = hookfunc(game.ContentProvider.PreloadAsync, function(self, tbl, cb)
            if self ~= game.ContentProvider or type(tbl) ~= "table" then
                return old(self, tbl, cb)
            end
            tbl = FilterTable(tbl)
            return old(self, tbl, cb)
        end)
    end
end

-- Signal System (From Criminality)
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = {
        callback = callback,
        connected = true
    }
    table.insert(self._connections, connection)
    return {
        Disconnect = function()
            connection.connected = false
            for i, conn in pairs(self._connections) do
                if conn == connection then
                    table.remove(self._connections, i)
                    break
                end
            end
        end
    }
end

function Signal:Fire(...)
    for _, connection in pairs(self._connections) do
        if connection.connected then
            task.spawn(connection.callback, ...)
        end
    end
end

-- Utility Functions (Enhanced from all libraries)
local Utilities = {}

function Utilities:Create(class, properties, children)
    local object = Instance.new(class)
    
    -- Default properties
    local defaults = {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.SourceSansBold,
        Text = "",
        BackgroundColor3 = Colors.Main
    }
    
    for prop, value in pairs(defaults) do
        pcall(function()
            object[prop] = value
        end)
    end
    
    -- Apply custom properties
    if properties then
        for prop, value in pairs(properties) do
            if prop == "Theme" then
                for themeProp, themeColor in pairs(value) do
                    if type(themeColor) == "table" then
                        local colorName, modifier = themeColor[1], themeColor[2] or 0
                        local baseColor = Colors[colorName]
                        if baseColor then
                            local finalColor = modifier ~= 0 and Utilities:ModifyColor(baseColor, modifier) or baseColor
                            object[themeProp] = finalColor
                            table.insert(Ruvex.ThemeObjects[colorName], {object, themeProp, colorName, modifier})
                        end
                    else
                        local baseColor = Colors[themeColor]
                        if baseColor then
                            object[themeProp] = baseColor
                            table.insert(Ruvex.ThemeObjects[themeColor], {object, themeProp, themeColor, 0})
                        end
                    end
                end
            else
                object[prop] = value
            end
        end
    end
    
    -- Add children
    if children then
        for _, child in pairs(children) do
            child.Parent = object
        end
    end
    
    return object
end

function Utilities:Tween(object, info, properties, callback)
    if typeof(info) == "number" then
        info = TweenInfo.new(info, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
    
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

-- Color modification functions (Enhanced from Mercury)
function Utilities:ModifyColor(color, amount)
    local h, s, v = Color3.toHSV(color)
    if amount > 0 then
        v = math.clamp(v + (amount / 100), 0, 1)
    else
        v = math.clamp(v + (amount / 100), 0, 1)
    end
    return Color3.fromHSV(h, s, v)
end

function Utilities:Darken(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s/f, 0, 1), math.clamp(v*f, 0, 1))
end

function Utilities:Lighten(color, f)
    local h, s, v = Color3.toHSV(color)
    f = 1 - ((f or 15) / 80)
    return Color3.fromHSV(h, math.clamp(s*f, 0, 1), math.clamp(v/f, 0, 1))
end

-- Advanced Color Functions (From Mercury)
function Utilities:HSVtoRGB(h, s, v)
    return Color3.fromHSV(h, s, v)
end

function Utilities:RGBtoHSV(color)
    return Color3.toHSV(color)
end

function Utilities:BlendColors(color1, color2, alpha)
    local r1, g1, b1 = color1.R, color1.G, color1.B
    local r2, g2, b2 = color2.R, color2.G, color2.B
    
    local r = r1 + (r2 - r1) * alpha
    local g = g1 + (g2 - g1) * alpha
    local b = b1 + (b2 - b1) * alpha
    
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

function Utilities:GetContrastColor(color)
    local brightness = (color.R * 299 + color.G * 587 + color.B * 114) / 1000
    return brightness > 0.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
end

function Utilities:GetTextSize(text, textSize, font)
    return TextService:GetTextSize(text, textSize, font or Enum.Font.SourceSansBold, Vector2.new(math.huge, math.huge))
end

function Utilities:MakeDraggable(object, handle, lockDragging)
    handle = handle or object
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            if lockDragging or Ruvex.LockDragging then
                local screenGui = object:FindFirstAncestorOfClass("ScreenGui")
                if screenGui then
                    local frameX = math.clamp(framePos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - object.AbsoluteSize.X)
                    local frameY = math.clamp(framePos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - object.AbsoluteSize.Y)
                    object.Position = UDim2.new(framePos.X.Scale, frameX, framePos.Y.Scale, frameY)
                end
            else
                object.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end
    end)
end

function Utilities:MakeResizable(object, minSize, maxSize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1200, 800)
    
    local resizeButton = Utilities:Create("Frame", {
        Name = "ResizeHandle",
        Size = UDim2.fromOffset(15, 15),
        Position = UDim2.new(1, -15, 1, -15),
        BackgroundColor3 = Colors.Accent,
        Parent = object
    })
    
    Utilities:CreateCorner(resizeButton, 2)
    
    local resizing = false
    local resizeStart = nil
    local sizeStart = nil
    
    resizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            sizeStart = object.AbsoluteSize
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
            local delta = input.Position - resizeStart
            local newSizeX = math.clamp(sizeStart.X + delta.X, minSize.X, maxSize.X)
            local newSizeY = math.clamp(sizeStart.Y + delta.Y, minSize.Y, maxSize.Y)
            object.Size = UDim2.fromOffset(newSizeX, newSizeY)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

function Utilities:CreateCorner(object, radius)
    return Utilities:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = object
    })
end

function Utilities:CreateGradient(object, colorSequence, rotation)
    return Utilities:Create("UIGradient", {
        Color = colorSequence,
        Rotation = rotation or 0,
        Parent = object
    })
end

function Utilities:CreateStroke(object, color, thickness)
    return Utilities:Create("UIStroke", {
        Color = color or Colors.Divider,
        Thickness = thickness or 1,
        Parent = object
    })
end

-- Tooltip System (From Mercury)
function Utilities:CreateTooltip(object, text, delay)
    delay = delay or 0.5
    
    local tooltipContainer = Utilities:Create("TextLabel", {
        Name = "Tooltip",
        Text = text,
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        BackgroundColor3 = Utilities:ModifyColor(Colors.Main, 20),
        TextColor3 = Colors.Text,
        Position = UDim2.new(0.5, 0, 0, -8),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        TextTransparency = 1,
        ZIndex = 10000,
        Parent = object
    })
    
    Utilities:CreateCorner(tooltipContainer, 6)
    Utilities:CreateStroke(tooltipContainer, Colors.Accent, 1)
    
    -- Auto-size tooltip
    local textBounds = Utilities:GetTextSize(text, 14, Enum.Font.SourceSansBold)
    tooltipContainer.Size = UDim2.fromOffset(textBounds.X + 16, textBounds.Y + 8)
    
    -- Arrow pointing down
    local tooltipArrow = Utilities:Create("ImageLabel", {
        Name = "TooltipArrow",
        Image = "rbxassetid://4292970642",
        ImageColor3 = Utilities:ModifyColor(Colors.Main, 20),
        AnchorPoint = Vector2.new(0.5, 0),
        Rotation = 180,
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromOffset(12, 8),
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        ZIndex = 10000,
        Parent = tooltipContainer
    })
    
    local hovered = false
    local showTooltip = false
    
    object.MouseEnter:Connect(function()
        hovered = true
        task.spawn(function()
            task.wait(delay)
            if hovered then
                showTooltip = true
                Utilities:Tween(tooltipContainer, 0.2, {BackgroundTransparency = 0, TextTransparency = 0})
                Utilities:Tween(tooltipArrow, 0.2, {ImageTransparency = 0})
            end
        end)
    end)
    
    object.MouseLeave:Connect(function()
        hovered = false
        showTooltip = false
        Utilities:Tween(tooltipContainer, 0.2, {BackgroundTransparency = 1, TextTransparency = 1})
        Utilities:Tween(tooltipArrow, 0.2, {ImageTransparency = 1})
    end)
    
    return tooltipContainer
end

-- Advanced Object Creation with Theme Support (From Mercury)
function Utilities:CreateThemedObject(class, properties)
    local object = Instance.new(class)
    
    local defaults = {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.SourceSansBold,
        Text = "",
        BackgroundColor3 = Colors.Main
    }
    
    -- Apply defaults
    for prop, value in pairs(defaults) do
        pcall(function()
            object[prop] = value
        end)
    end
    
    -- Apply custom properties with theme support
    if properties then
        for prop, value in pairs(properties) do
            if prop == "Theme" then
                -- Theme handling
                for themeProp, themeValue in pairs(value) do
                    if type(themeValue) == "table" then
                        local colorName, modifier = themeValue[1], themeValue[2] or 0
                        local baseColor = Colors[colorName]
                        if baseColor then
                            local finalColor = modifier ~= 0 and Utilities:ModifyColor(baseColor, modifier) or baseColor
                            object[themeProp] = finalColor
                            table.insert(Ruvex.ThemeObjects[colorName], {object, themeProp, colorName, modifier})
                        end
                    else
                        local baseColor = Colors[themeValue]
                        if baseColor then
                            object[themeProp] = baseColor
                            table.insert(Ruvex.ThemeObjects[themeValue], {object, themeProp, themeValue, 0})
                        end
                    end
                end
            else
                object[prop] = value
            end
        end
    end
    
    return object
end

-- Fade Animation System (From Mercury)
function Utilities:CreateFade(object, colorOverride)
    local fadeFrame = Utilities:Create("Frame", {
        Name = "FadeFrame",
        BackgroundColor3 = colorOverride or object.BackgroundColor3,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        ZIndex = object.ZIndex + 1,
        Visible = false,
        Parent = object
    })
    
    local corner = object:FindFirstChildOfClass("UICorner")
    if corner then
        Utilities:CreateCorner(fadeFrame, corner.CornerRadius.Offset)
    end
    
    return {
        Show = function(instant, length)
            length = length or 0.2
            fadeFrame.BackgroundTransparency = 1
            fadeFrame.Visible = true
            
            if instant then
                fadeFrame.BackgroundTransparency = 0.2
            else
                Utilities:Tween(fadeFrame, length, {BackgroundTransparency = 0.2})
            end
        end,
        Hide = function(instant, length)
            length = length or 0.2
            
            if instant then
                fadeFrame.BackgroundTransparency = 1
                fadeFrame.Visible = false
            else
                Utilities:Tween(fadeFrame, length, {BackgroundTransparency = 1}, function()
                    fadeFrame.Visible = false
                end)
            end
        end,
        SetColor = function(color)
            fadeFrame.BackgroundColor3 = color
        end
    }
end

-- Text Animation System (From Cerberus)
function Utilities:AnimateText(textInstance, animationSpeed, text, placeholderText, fillPlaceHolder, emptyPlaceHolderText)
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

-- Rainbow Effect System (Enhanced from Flux)
coroutine.wrap(function()
    while wait() do
        Ruvex.RainbowColorValue = Ruvex.RainbowColorValue + 1/255
        Ruvex.HueSelectionPosition = Ruvex.HueSelectionPosition + 1
        
        if Ruvex.RainbowColorValue >= 1 then
            Ruvex.RainbowColorValue = 0
        end
        
        if Ruvex.HueSelectionPosition == 80 then
            Ruvex.HueSelectionPosition = 0
        end
    end
end)()

function Utilities:GetRainbowColor()
    return Color3.fromHSV(Ruvex.RainbowColorValue, 1, 1)
end

-- Config System (From Criminality/PPHUD)
local ConfigSystem = {
    ConfigFolder = "RuvexConfigs"
}

function ConfigSystem:Init()
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
end

function ConfigSystem:SaveConfig(configName, data)
    if not configName or not data then return false end
    
    local success, result = pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        writefile(self.ConfigFolder .. "/" .. configName .. ".json", jsonData)
        return true
    end)
    
    return success
end

function ConfigSystem:LoadConfig(configName)
    if not configName then return nil end
    
    local filePath = self.ConfigFolder .. "/" .. configName .. ".json"
    if not isfile(filePath) then return nil end
    
    local success, result = pcall(function()
        local fileContent = readfile(filePath)
        return HttpService:JSONDecode(fileContent)
    end)
    
    return success and result or nil
end

function ConfigSystem:GetConfigs()
    if not isfolder(self.ConfigFolder) then return {} end
    
    local configs = {}
    for _, file in pairs(listfiles(self.ConfigFolder)) do
        if file:match("%.json$") then
            local configName = file:match("([^/\\]+)%.json$")
            table.insert(configs, configName)
        end
    end
    
    return configs
end

ConfigSystem:Init()

-- Theme System Functions
function Ruvex:ChangeTheme(themeName)
    if not Themes[themeName] then return end
    
    self.CurrentTheme = themeName
    Colors = Themes[themeName]
    
    -- Update all theme objects
    for colorName, objects in pairs(self.ThemeObjects) do
        for _, obj in pairs(objects) do
            local element, property, theme, colorAlter = obj[1], obj[2], obj[3], obj[4] or 0
            local themeColor = Colors[theme]
            if themeColor then
                local modifiedColor = themeColor
                if colorAlter < 0 then
                    modifiedColor = Utilities:Darken(themeColor, -colorAlter)
                elseif colorAlter > 0 then
                    modifiedColor = Utilities:Lighten(themeColor, colorAlter)
                end
                if element and element[property] then
                    element[property] = modifiedColor
                end
            end
        end
    end
end

function Ruvex:GetThemes()
    local themeList = {}
    for name, _ in pairs(Themes) do
        table.insert(themeList, name)
    end
    return themeList
end

-- Console System (Enhanced from PPHUD/Criminality)
local Console = {
    Messages = {},
    MaxMessages = 100,
    Visible = false,
    Container = nil
}

function Console:Init(parent)
    if self.Container then return end
    
    self.Container = Utilities:Create("Frame", {
        Name = "RuvexConsole",
        Size = UDim2.new(0, 500, 0, 300),
        Position = UDim2.new(0.5, -250, 0.5, -150),
        BackgroundColor3 = Colors.Main,
        Visible = false,
        ZIndex = 10000,
        Parent = parent
    })
    
    Utilities:CreateCorner(self.Container, 8)
    Utilities:CreateStroke(self.Container, Colors.Accent, 2)
    
    local header = Utilities:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        Parent = self.Container
    })
    
    Utilities:CreateCorner(header, 8)
    
    local headerExtend = Utilities:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Parent = header
    })
    
    local title = Utilities:Create("TextLabel", {
        Text = "Ruvex Console",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        Parent = header
    })
    
    local closeButton = Utilities:Create("TextButton", {
        Text = "×",
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -30, 0.5, -12.5),
        BackgroundColor3 = Colors.Error,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        Parent = header
    })
    
    Utilities:CreateCorner(closeButton, 4)
    
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    local scrollFrame = Utilities:Create("ScrollingFrame", {
        Name = "MessagesFrame",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.fromOffset(0, 30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Container
    })
    
    local messagesList = Utilities:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = scrollFrame
    })
    
    local messagesPadding = Utilities:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 5),
        Parent = scrollFrame
    })
    
    Utilities:MakeDraggable(self.Container, header)
    Utilities:MakeResizable(self.Container, Vector2.new(300, 200), Vector2.new(800, 600))
end

function Console:AddMessage(text, messageType, timestamp)
    if not self.Container then return end
    
    messageType = messageType or "INFO"
    timestamp = timestamp or os.date("%H:%M:%S")
    
    local typeColors = {
        INFO = Colors.Text,
        SUCCESS = Colors.Success,
        WARNING = Colors.Warning,
        ERROR = Colors.Error
    }
    
    local message = {
        text = text,
        type = messageType,
        time = timestamp
    }
    
    table.insert(self.Messages, message)
    
    -- Remove old messages if we exceed max
    if #self.Messages > self.MaxMessages then
        table.remove(self.Messages, 1)
    end
    
    local scrollFrame = self.Container:FindFirstChild("MessagesFrame")
    if scrollFrame then
        local messageFrame = Utilities:Create("Frame", {
            Name = "Message",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = scrollFrame
        })
        
        local messageText = Utilities:Create("TextLabel", {
            Text = string.format("[%s] [%s] %s", timestamp, messageType, text),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = typeColors[messageType] or Colors.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            Parent = messageFrame
        })
        
        -- Auto-scroll to bottom
        task.wait()
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
    end
end

function Console:Toggle()
    if not self.Container then return end
    
    self.Visible = not self.Visible
    self.Container.Visible = self.Visible
end

function Console:Clear()
    if not self.Container then return end
    
    self.Messages = {}
    local scrollFrame = self.Container:FindFirstChild("MessagesFrame")
    if scrollFrame then
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child.Name == "Message" then
                child:Destroy()
            end
        end
    end
end

-- Main Window Creation
function Ruvex:Window(config)
    config = config or {}
    config.Name = config.Name or "Ruvex"
    config.Size = config.Size or UDim2.fromOffset(700, 500)
    config.Theme = config.Theme or self.CurrentTheme
    config.Resizable = config.Resizable ~= false
    config.Console = config.Console ~= false
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Config = config,
        Signals = {
            TabAdded = Signal.new(),
            TabChanged = Signal.new(),
            WindowResized = Signal.new()
        }
    }
    
    -- Apply theme if different
    if config.Theme ~= self.CurrentTheme then
        self:ChangeTheme(config.Theme)
    end
    
    -- Main ScreenGui
    local ScreenGui = Utilities:Create("ScreenGui", {
        Name = "Ruvex_" .. config.Name,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Protect GUI (Enhanced protection)
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Main Frame
    local MainFrame = Utilities:Create("Frame", {
        Name = "MainFrame",
        Size = config.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Main,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    Utilities:CreateCorner(MainFrame, 12)
    Utilities:CreateStroke(MainFrame, Colors.Accent, 2)
    Utilities:MakeDraggable(MainFrame)
    
    if config.Resizable then
        Utilities:MakeResizable(MainFrame, Vector2.new(500, 350), Vector2.new(1400, 900))
    end
    
    -- Enhanced gradient background
    Utilities:CreateGradient(MainFrame, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Main),
        ColorSequenceKeypoint.new(0.7, Utilities:ModifyColor(Colors.Main, 5)),
        ColorSequenceKeypoint.new(1, Colors.Secondary)
    }), 135)
    
    -- Title Bar
    local TitleBar = Utilities:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.Secondary,
        Parent = MainFrame
    })
    
    Utilities:CreateCorner(TitleBar, 12)
    
    -- Hide bottom corners of title bar
    local TitleBarExtend = Utilities:Create("Frame", {
        Name = "TitleBarExtend",
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    -- Title with enhanced styling
    local TitleText = Utilities:Create("TextLabel", {
        Name = "TitleText",
        Text = config.Name,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        Parent = TitleBar
    })
    
    -- Control buttons container
    local ControlsFrame = Utilities:Create("Frame", {
        Name = "ControlsFrame",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -125, 0, 0),
        BackgroundTransparency = 1,
        Parent = TitleBar
    })
    
    local ControlsList = Utilities:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        Parent = ControlsFrame
    })
    
    -- Console Button (if enabled)
    if config.Console then
        Console:Init(ScreenGui)
        
        local ConsoleButton = Utilities:Create("TextButton", {
            Name = "ConsoleButton",
            Text = "≡",
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = Colors.Tertiary,
            TextColor3 = Colors.Text,
            TextSize = 16,
            Font = Enum.Font.SourceSansBold,
            Parent = ControlsFrame
        })
        
        Utilities:CreateCorner(ConsoleButton, 6)
        
        ConsoleButton.MouseButton1Click:Connect(function()
            Console:Toggle()
        end)
        
        ConsoleButton.MouseEnter:Connect(function()
            Utilities:Tween(ConsoleButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Tertiary, 20)})
        end)
        
        ConsoleButton.MouseLeave:Connect(function()
            Utilities:Tween(ConsoleButton, 0.2, {BackgroundColor3 = Colors.Tertiary})
        end)
    end
    
    -- Minimize Button
    local MinimizeButton = Utilities:Create("TextButton", {
        Name = "MinimizeButton",
        Text = "—",
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Colors.Warning,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        Parent = ControlsFrame
    })
    
    Utilities:CreateCorner(MinimizeButton, 6)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        self.Toggled = not self.Toggled
        ScreenGui.Enabled = self.Toggled
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Utilities:Tween(MinimizeButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Warning, 20)})
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Utilities:Tween(MinimizeButton, 0.2, {BackgroundColor3 = Colors.Warning})
    end)
    
    -- Close Button
    local CloseButton = Utilities:Create("TextButton", {
        Name = "CloseButton",
        Text = "×",
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Colors.Error,
        TextColor3 = Colors.Text,
        TextSize = 18,
        Font = Enum.Font.SourceSansBold,
        Parent = ControlsFrame
    })
    
    Utilities:CreateCorner(CloseButton, 6)
    
    CloseButton.MouseButton1Click:Connect(function()
        Utilities:Tween(MainFrame, 0.3, {Size = UDim2.fromOffset(0, 0)}, function()
            ScreenGui:Destroy()
        end)
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Utilities:Tween(CloseButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Error, 20)})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Utilities:Tween(CloseButton, 0.2, {BackgroundColor3 = Colors.Error})
    end)
    
    -- Tab Container (Enhanced design)
    local TabContainer = Utilities:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 180, 1, -40),
        Position = UDim2.fromOffset(0, 40),
        BackgroundColor3 = Colors.Background,
        Parent = MainFrame
    })
    
    local TabScrollFrame = Utilities:Create("ScrollingFrame", {
        Name = "TabScrollFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabContainer
    })
    
    local TabList = Utilities:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = TabScrollFrame
    })
    
    local TabPadding = Utilities:Create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 15),
        Parent = TabScrollFrame
    })
    
    -- Content Container
    local ContentContainer = Utilities:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -180, 1, -40),
        Position = UDim2.fromOffset(180, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Toggle functionality (Enhanced)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            self.Toggled = not self.Toggled
            ScreenGui.Enabled = self.Toggled
            
            if self.Toggled then
                Utilities:Tween(MainFrame, 0.3, {Size = config.Size})
            else
                Utilities:Tween(MainFrame, 0.3, {Size = UDim2.fromOffset(0, 0)})
            end
        end
    end)
    
    -- Tab Creation Function
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or "rbxassetid://7734053426"
        
        local Tab = {
            Elements = {},
            Config = tabConfig,
            Window = self
        }
        
        -- Tab Button (Enhanced with icon)
        local TabButton = Utilities:Create("TextButton", {
            Name = "TabButton",
            Text = "",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Colors.Tertiary,
            Parent = TabScrollFrame
        })
        
        Utilities:CreateCorner(TabButton, 8)
        
        -- Tab Icon
        local TabIcon = Utilities:Create("ImageLabel", {
            Name = "TabIcon",
            Image = tabConfig.Icon,
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromOffset(12, 8),
            BackgroundTransparency = 1,
            ImageColor3 = Colors.SecondaryText,
            Parent = TabButton
        })
        
        -- Tab Label
        local TabLabel = Utilities:Create("TextLabel", {
            Name = "TabLabel",
            Text = tabConfig.Name,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.fromOffset(45, 0),
            BackgroundTransparency = 1,
            TextColor3 = Colors.SecondaryText,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.SourceSansBold,
            Parent = TabButton
        })
        
        -- Tab Content (Enhanced scrolling)
        local TabContent = Utilities:Create("ScrollingFrame", {
            Name = "TabContent",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Colors.Accent,
            CanvasSize = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentContainer
        })
        
        local ContentList = Utilities:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = TabContent
        })
        
        local ContentPadding = Utilities:Create("UIPadding", {
            PaddingTop = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            Parent = TabContent
        })
        
        -- Tab Selection Logic (Enhanced animations)
        local function SelectTab()
            -- Deselect all tabs
            for _, tab in pairs(Window.Tabs) do
                Utilities:Tween(tab.Button, 0.3, {BackgroundColor3 = Colors.Tertiary})
                Utilities:Tween(tab.Icon, 0.3, {ImageColor3 = Colors.SecondaryText})
                Utilities:Tween(tab.Label, 0.3, {TextColor3 = Colors.SecondaryText})
                tab.Content.Visible = false
            end
            
            -- Select this tab with enhanced animation
            Utilities:Tween(TabButton, 0.3, {BackgroundColor3 = Colors.Accent})
            Utilities:Tween(TabIcon, 0.3, {ImageColor3 = Colors.Text})
            Utilities:Tween(TabLabel, 0.3, {TextColor3 = Colors.Text})
            TabContent.Visible = true
            Window.CurrentTab = Tab
            
            -- Fire tab changed signal
            Window.Signals.TabChanged:Fire(Tab)
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        -- Enhanced hover effects
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utilities:Tween(TabButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Tertiary, 15)})
                Utilities:Tween(TabIcon, 0.2, {ImageColor3 = Colors.Text})
                Utilities:Tween(TabLabel, 0.2, {TextColor3 = Colors.Text})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utilities:Tween(TabButton, 0.2, {BackgroundColor3 = Colors.Tertiary})
                Utilities:Tween(TabIcon, 0.2, {ImageColor3 = Colors.SecondaryText})
                Utilities:Tween(TabLabel, 0.2, {TextColor3 = Colors.SecondaryText})
            end
        end)
        
        -- Store tab references
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.Content = TabContent
        
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab automatically
        if #Window.Tabs == 1 then
            SelectTab()
        end
        
        -- Fire tab added signal
        Window.Signals.TabAdded:Fire(Tab)
        
        -- Section Creation Function (Enhanced)
        function Tab:Section(sectionConfig)
            sectionConfig = sectionConfig or {}
            sectionConfig.Name = sectionConfig.Name or "Section"
            sectionConfig.Side = sectionConfig.Side or "Left" -- Left or Right
            
            local Section = {
                Elements = {},
                Config = sectionConfig,
                Tab = self
            }
            
            -- Create side containers if they don't exist
            local LeftSide = TabContent:FindFirstChild("LeftSide")
            local RightSide = TabContent:FindFirstChild("RightSide")
            
            if not LeftSide then
                -- Replace single content with two-column layout
                ContentList:Destroy()
                ContentPadding:Destroy()
                
                LeftSide = Utilities:Create("Frame", {
                    Name = "LeftSide",
                    Size = UDim2.new(0.48, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = TabContent
                })
                
                local LeftList = Utilities:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                    Parent = LeftSide
                })
                
                local LeftPadding = Utilities:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 20),
                    PaddingLeft = UDim.new(0, 20),
                    PaddingRight = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 20),
                    Parent = LeftSide
                })
                
                RightSide = Utilities:Create("Frame", {
                    Name = "RightSide",
                    Size = UDim2.new(0.48, 0, 1, 0),
                    Position = UDim2.new(0.52, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = TabContent
                })
                
                local RightList = Utilities:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                    Parent = RightSide
                })
                
                local RightPadding = Utilities:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 20),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 20),
                    PaddingBottom = UDim.new(0, 20),
                    Parent = RightSide
                })
            end
            
            local targetSide = sectionConfig.Side == "Right" and RightSide or LeftSide
            
            -- Section Frame (Enhanced design)
            local SectionFrame = Utilities:Create("Frame", {
                Name = "SectionFrame",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Colors.Background,
                Parent = targetSide
            })
            
            Utilities:CreateCorner(SectionFrame, 10)
            Utilities:CreateStroke(SectionFrame, Colors.Divider, 1)
            
            -- Section Header with gradient
            local SectionHeader = Utilities:Create("Frame", {
                Name = "SectionHeader",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Colors.Secondary,
                Parent = SectionFrame
            })
            
            Utilities:CreateCorner(SectionHeader, 10)
            Utilities:CreateGradient(SectionHeader, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Colors.Secondary),
                ColorSequenceKeypoint.new(1, Utilities:ModifyColor(Colors.Secondary, 10))
            }), 90)
            
            -- Hide bottom corners
            local HeaderExtend = Utilities:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 1, -10),
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Parent = SectionHeader
            })
            
            -- Section Title with enhanced styling
            local SectionTitle = Utilities:Create("TextLabel", {
                Name = "SectionTitle",
                Text = sectionConfig.Name,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.fromOffset(15, 0),
                BackgroundTransparency = 1,
                TextColor3 = Colors.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSansBold,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Utilities:Create("Frame", {
                Name = "SectionContent",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.fromOffset(0, 40),
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            
            local SectionList = Utilities:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = SectionContent
            })
            
            local SectionPadding = Utilities:Create("UIPadding", {
                PaddingTop = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 15),
                Parent = SectionContent
            })
            
            -- Auto-resize section
            local function UpdateSectionSize()
                SectionContent.Size = UDim2.new(1, 0, 0, SectionList.AbsoluteContentSize.Y + 30)
                SectionFrame.Size = UDim2.new(1, 0, 0, 40 + SectionList.AbsoluteContentSize.Y + 30)
            end
            
            SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            -- Enhanced UI Elements
            
            -- Button Element (Enhanced)
            function Section:Button(buttonConfig)
                buttonConfig = buttonConfig or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Description = buttonConfig.Description
                buttonConfig.Callback = buttonConfig.Callback or function() end
                
                local ButtonFrame = Utilities:Create("Frame", {
                    Name = "ButtonFrame",
                    Size = UDim2.new(1, 0, 0, buttonConfig.Description and 55 or 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(ButtonFrame, 8)
                Utilities:CreateStroke(ButtonFrame, Colors.Divider, 1)
                
                local ButtonMain = Utilities:Create("TextButton", {
                    Name = "ButtonMain",
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = ButtonFrame
                })
                
                local ButtonLabel = Utilities:Create("TextLabel", {
                    Text = buttonConfig.Name,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.fromOffset(15, buttonConfig.Description and 8 or 7.5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = ButtonFrame
                })
                
                if buttonConfig.Description then
                    local ButtonDesc = Utilities:Create("TextLabel", {
                        Text = buttonConfig.Description,
                        Size = UDim2.new(1, -20, 0, 15),
                        Position = UDim2.fromOffset(15, 28),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.SecondaryText,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.SourceSans,
                        Parent = ButtonFrame
                    })
                end
                
                -- Enhanced button interactions
                ButtonMain.MouseButton1Click:Connect(function()
                    -- Click animation
                    Utilities:Tween(ButtonFrame, 0.1, {BackgroundColor3 = Colors.Accent}, function()
                        Utilities:Tween(ButtonFrame, 0.1, {BackgroundColor3 = Colors.Tertiary})
                    end)
                    
                    buttonConfig.Callback()
                    
                    -- Add to console if available
                    if Console.Container then
                        Console:AddMessage("Button clicked: " .. buttonConfig.Name, "INFO")
                    end
                end)
                
                ButtonMain.MouseEnter:Connect(function()
                    Utilities:Tween(ButtonFrame, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Tertiary, 15)})
                end)
                
                ButtonMain.MouseLeave:Connect(function()
                    Utilities:Tween(ButtonFrame, 0.2, {BackgroundColor3 = Colors.Tertiary})
                end)
                
                return {
                    SetText = function(self, newText)
                        ButtonLabel.Text = newText
                    end,
                    SetCallback = function(self, newCallback)
                        buttonConfig.Callback = newCallback
                    end
                }
            end
            
            -- Toggle Element (Enhanced)
            function Section:Toggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Flag = toggleConfig.Flag
                toggleConfig.Callback = toggleConfig.Callback or function() end
                
                local toggled = toggleConfig.Default
                if toggleConfig.Flag then
                    Ruvex.flags[toggleConfig.Flag] = toggled
                end
                
                local ToggleFrame = Utilities:Create("Frame", {
                    Name = "ToggleFrame",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(ToggleFrame, 8)
                Utilities:CreateStroke(ToggleFrame, Colors.Divider, 1)
                
                local ToggleButton = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = ToggleFrame
                })
                
                local ToggleLabel = Utilities:Create("TextLabel", {
                    Text = toggleConfig.Name,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.fromOffset(15, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = ToggleFrame
                })
                
                -- Enhanced toggle switch
                local ToggleSwitch = Utilities:Create("Frame", {
                    Name = "ToggleSwitch",
                    Size = UDim2.fromOffset(40, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = toggled and Colors.Accent or Colors.Background,
                    Parent = ToggleFrame
                })
                
                Utilities:CreateCorner(ToggleSwitch, 10)
                
                local ToggleKnob = Utilities:Create("Frame", {
                    Name = "ToggleKnob",
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(0, toggled and 22 or 2, 0.5, -8),
                    BackgroundColor3 = Colors.Text,
                    Parent = ToggleSwitch
                })
                
                Utilities:CreateCorner(ToggleKnob, 8)
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggleConfig.Flag then
                        Ruvex.flags[toggleConfig.Flag] = toggled
                    end
                    
                    -- Enhanced toggle animation
                    Utilities:Tween(ToggleSwitch, 0.2, {BackgroundColor3 = toggled and Colors.Accent or Colors.Background})
                    Utilities:Tween(ToggleKnob, 0.2, {Position = UDim2.new(0, toggled and 22 or 2, 0.5, -8)})
                    
                    toggleConfig.Callback(toggled)
                    
                    if Console.Container then
                        Console:AddMessage("Toggle " .. (toggled and "enabled" or "disabled") .. ": " .. toggleConfig.Name, "INFO")
                    end
                end)
                
                ToggleButton.MouseEnter:Connect(function()
                    Utilities:Tween(ToggleFrame, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Tertiary, 10)})
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    Utilities:Tween(ToggleFrame, 0.2, {BackgroundColor3 = Colors.Tertiary})
                end)
                
                return {
                    Set = function(self, value)
                        toggled = value
                        if toggleConfig.Flag then
                            Ruvex.flags[toggleConfig.Flag] = toggled
                        end
                        
                        Utilities:Tween(ToggleSwitch, 0.2, {BackgroundColor3 = toggled and Colors.Accent or Colors.Background})
                        Utilities:Tween(ToggleKnob, 0.2, {Position = UDim2.new(0, toggled and 22 or 2, 0.5, -8)})
                        
                        toggleConfig.Callback(toggled)
                    end,
                    Get = function(self)
                        return toggled
                    end
                }
            end
            
            -- Slider Element (Enhanced)
            function Section:Slider(sliderConfig)
                sliderConfig = sliderConfig or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or 50
                sliderConfig.Increment = sliderConfig.Increment or 1
                sliderConfig.Suffix = sliderConfig.Suffix or ""
                sliderConfig.Flag = sliderConfig.Flag
                sliderConfig.Callback = sliderConfig.Callback or function() end
                
                local value = sliderConfig.Default
                if sliderConfig.Flag then
                    Ruvex.flags[sliderConfig.Flag] = value
                end
                
                local SliderFrame = Utilities:Create("Frame", {
                    Name = "SliderFrame",
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(SliderFrame, 8)
                Utilities:CreateStroke(SliderFrame, Colors.Divider, 1)
                
                local SliderLabel = Utilities:Create("TextLabel", {
                    Text = sliderConfig.Name,
                    Size = UDim2.new(0.7, 0, 0, 20),
                    Position = UDim2.fromOffset(15, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = SliderFrame
                })
                
                local SliderValue = Utilities:Create("TextLabel", {
                    Text = tostring(value) .. sliderConfig.Suffix,
                    Size = UDim2.new(0.3, -15, 0, 20),
                    Position = UDim2.new(0.7, 0, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.SourceSansBold,
                    Parent = SliderFrame
                })
                
                -- Enhanced slider track
                local SliderTrack = Utilities:Create("Frame", {
                    Name = "SliderTrack",
                    Size = UDim2.new(1, -30, 0, 4),
                    Position = UDim2.fromOffset(15, 30),
                    BackgroundColor3 = Colors.Background,
                    Parent = SliderFrame
                })
                
                Utilities:CreateCorner(SliderTrack, 2)
                
                local SliderFill = Utilities:Create("Frame", {
                    Name = "SliderFill",
                    Size = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0),
                    BackgroundColor3 = Colors.Accent,
                    Parent = SliderTrack
                })
                
                Utilities:CreateCorner(SliderFill, 2)
                
                local SliderKnob = Utilities:Create("Frame", {
                    Name = "SliderKnob",
                    Size = UDim2.fromOffset(12, 12),
                    Position = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), -6, 0.5, -6),
                    BackgroundColor3 = Colors.Text,
                    Parent = SliderTrack
                })
                
                Utilities:CreateCorner(SliderKnob, 6)
                
                local SliderInput = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = SliderTrack
                })
                
                local dragging = false
                
                local function UpdateSlider(input)
                    local percentage = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * percentage)
                    value = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                    
                    -- Apply increment
                    if sliderConfig.Increment > 0 then
                        value = math.floor(value / sliderConfig.Increment) * sliderConfig.Increment
                    end
                    
                    local displayPercentage = (value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    
                    SliderValue.Text = tostring(value) .. sliderConfig.Suffix
                    Utilities:Tween(SliderFill, 0.1, {Size = UDim2.new(displayPercentage, 0, 1, 0)})
                    Utilities:Tween(SliderKnob, 0.1, {Position = UDim2.new(displayPercentage, -6, 0.5, -6)})
                    
                    if sliderConfig.Flag then
                        Ruvex.flags[sliderConfig.Flag] = value
                    end
                    
                    sliderConfig.Callback(value)
                end
                
                SliderInput.MouseButton1Down:Connect(function()
                    dragging = true
                    UpdateSlider(UserInputService:GetMouseLocation())
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return {
                    Set = function(self, newValue)
                        value = math.clamp(newValue, sliderConfig.Min, sliderConfig.Max)
                        local percentage = (value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                        
                        SliderValue.Text = tostring(value) .. sliderConfig.Suffix
                        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(percentage, -6, 0.5, -6)
                        
                        if sliderConfig.Flag then
                            Ruvex.flags[sliderConfig.Flag] = value
                        end
                        
                        sliderConfig.Callback(value)
                    end,
                    Get = function(self)
                        return value
                    end
                }
            end
            
            -- Dropdown Element (Enhanced)
            function Section:Dropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                dropdownConfig.Default = dropdownConfig.Default or dropdownConfig.Options[1]
                dropdownConfig.Flag = dropdownConfig.Flag
                dropdownConfig.Callback = dropdownConfig.Callback or function() end
                
                local selected = dropdownConfig.Default
                if dropdownConfig.Flag then
                    Ruvex.flags[dropdownConfig.Flag] = selected
                end
                
                local opened = false
                
                local DropdownFrame = Utilities:Create("Frame", {
                    Name = "DropdownFrame",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(DropdownFrame, 8)
                Utilities:CreateStroke(DropdownFrame, Colors.Divider, 1)
                
                local DropdownButton = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = DropdownFrame
                })
                
                local DropdownLabel = Utilities:Create("TextLabel", {
                    Text = dropdownConfig.Name .. ": " .. selected,
                    Size = UDim2.new(1, -40, 0, 35),
                    Position = UDim2.fromOffset(15, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = DropdownFrame
                })
                
                local DropdownArrow = Utilities:Create("TextLabel", {
                    Text = "▼",
                    Size = UDim2.fromOffset(20, 35),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.SecondaryText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Font = Enum.Font.SourceSansBold,
                    Parent = DropdownFrame
                })
                
                local OptionsFrame = Utilities:Create("Frame", {
                    Name = "OptionsFrame",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    BackgroundColor3 = Colors.Background,
                    Visible = false,
                    Parent = DropdownFrame,
                    ZIndex = 5
                })
                
                Utilities:CreateCorner(OptionsFrame, 8)
                Utilities:CreateStroke(OptionsFrame, Colors.Divider, 1)
                
                local OptionsList = Utilities:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsFrame
                })
                
                local function CreateOption(option)
                    local OptionButton = Utilities:Create("TextButton", {
                        Text = option,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = selected == option and Colors.Accent or Colors.Background,
                        TextColor3 = Colors.Text,
                        TextSize = 13,
                        Font = Enum.Font.SourceSansBold,
                        Parent = OptionsFrame,
                        ZIndex = 6
                    })
                    
                    Utilities:CreateCorner(OptionButton, 6)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        if dropdownConfig.Flag then
                            Ruvex.flags[dropdownConfig.Flag] = selected
                        end
                        
                        DropdownLabel.Text = dropdownConfig.Name .. ": " .. selected
                        
                        -- Update option colors
                        for _, child in pairs(OptionsFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.BackgroundColor3 = child.Text == selected and Colors.Accent or Colors.Background
                            end
                        end
                        
                        opened = false
                        OptionsFrame.Visible = false
                        Utilities:Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
                        Utilities:Tween(DropdownArrow, 0.2, {Rotation = 0})
                        
                        dropdownConfig.Callback(selected)
                        
                        if Console.Container then
                            Console:AddMessage("Dropdown changed to: " .. selected, "INFO")
                        end
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        if selected ~= option then
                            Utilities:Tween(OptionButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Background, 15)})
                        end
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        if selected ~= option then
                            Utilities:Tween(OptionButton, 0.2, {BackgroundColor3 = Colors.Background})
                        end
                    end)
                end
                
                for _, option in pairs(dropdownConfig.Options) do
                    CreateOption(option)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    OptionsFrame.Visible = opened
                    
                    if opened then
                        local optionsHeight = #dropdownConfig.Options * 30
                        OptionsFrame.Size = UDim2.new(1, 0, 0, optionsHeight)
                        Utilities:Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 35 + optionsHeight)})
                        Utilities:Tween(DropdownArrow, 0.2, {Rotation = 180})
                    else
                        Utilities:Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
                        Utilities:Tween(DropdownArrow, 0.2, {Rotation = 0})
                    end
                end)
                
                return {
                    Set = function(self, option)
                        if table.find(dropdownConfig.Options, option) then
                            selected = option
                            if dropdownConfig.Flag then
                                Ruvex.flags[dropdownConfig.Flag] = selected
                            end
                            DropdownLabel.Text = dropdownConfig.Name .. ": " .. selected
                            dropdownConfig.Callback(selected)
                        end
                    end,
                    Get = function(self)
                        return selected
                    end,
                    AddOption = function(self, option)
                        table.insert(dropdownConfig.Options, option)
                        CreateOption(option)
                    end,
                    RemoveOption = function(self, option)
                        local index = table.find(dropdownConfig.Options, option)
                        if index then
                            table.remove(dropdownConfig.Options, index)
                            for _, child in pairs(OptionsFrame:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == option then
                                    child:Destroy()
                                    break
                                end
                            end
                        end
                    end
                }
            end
            
            -- Textbox Element (Enhanced)
            function Section:Textbox(textboxConfig)
                textboxConfig = textboxConfig or {}
                textboxConfig.Name = textboxConfig.Name or "Textbox"
                textboxConfig.Default = textboxConfig.Default or ""
                textboxConfig.Placeholder = textboxConfig.Placeholder or "Enter text..."
                textboxConfig.Flag = textboxConfig.Flag
                textboxConfig.Callback = textboxConfig.Callback or function() end
                
                local text = textboxConfig.Default
                if textboxConfig.Flag then
                    Ruvex.flags[textboxConfig.Flag] = text
                end
                
                local TextboxFrame = Utilities:Create("Frame", {
                    Name = "TextboxFrame",
                    Size = UDim2.new(1, 0, 0, 55),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(TextboxFrame, 8)
                Utilities:CreateStroke(TextboxFrame, Colors.Divider, 1)
                
                local TextboxLabel = Utilities:Create("TextLabel", {
                    Text = textboxConfig.Name,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.fromOffset(15, 8),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = TextboxFrame
                })
                
                local TextboxInput = Utilities:Create("TextBox", {
                    Text = text,
                    PlaceholderText = textboxConfig.Placeholder,
                    Size = UDim2.new(1, -20, 0, 22),
                    Position = UDim2.fromOffset(10, 28),
                    BackgroundColor3 = Colors.Main,
                    TextColor3 = Colors.Text,
                    PlaceholderColor3 = Colors.SecondaryText,
                    TextSize = 13,
                    Font = Enum.Font.SourceSans,
                    ClearButtonOnFocus = false,
                    Parent = TextboxFrame
                })
                
                Utilities:CreateCorner(TextboxInput, 6)
                Utilities:CreateStroke(TextboxInput, Colors.Divider, 1)
                
                -- Enhanced focus effects
                TextboxInput.Focused:Connect(function()
                    Utilities:Tween(TextboxInput, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Main, 10)})
                end)
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    text = TextboxInput.Text
                    if textboxConfig.Flag then
                        Ruvex.flags[textboxConfig.Flag] = text
                    end
                    
                    Utilities:Tween(TextboxInput, 0.2, {BackgroundColor3 = Colors.Main})
                    textboxConfig.Callback(text)
                    
                    if Console.Container then
                        Console:AddMessage("Textbox updated: " .. textboxConfig.Name .. " = " .. text, "INFO")
                    end
                end)
                
                return {
                    Set = function(self, newText)
                        text = newText
                        TextboxInput.Text = newText
                        if textboxConfig.Flag then
                            Ruvex.flags[textboxConfig.Flag] = text
                        end
                        textboxConfig.Callback(text)
                    end,
                    Get = function(self)
                        return text
                    end
                }
            end
            
            -- Keybind Element (New)
            function Section:Keybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                keybindConfig.Name = keybindConfig.Name or "Keybind"
                keybindConfig.Default = keybindConfig.Default or Enum.KeyCode.F
                keybindConfig.Flag = keybindConfig.Flag
                keybindConfig.Callback = keybindConfig.Callback or function() end
                
                local keybind = keybindConfig.Default
                if keybindConfig.Flag then
                    Ruvex.flags[keybindConfig.Flag] = keybind
                end
                
                local KeybindFrame = Utilities:Create("Frame", {
                    Name = "KeybindFrame",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(KeybindFrame, 8)
                Utilities:CreateStroke(KeybindFrame, Colors.Divider, 1)
                
                local KeybindLabel = Utilities:Create("TextLabel", {
                    Text = keybindConfig.Name,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.fromOffset(15, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Utilities:Create("TextButton", {
                    Text = keybind.Name,
                    Size = UDim2.new(0.3, -15, 0, 25),
                    Position = UDim2.new(0.7, 0, 0.5, -12.5),
                    BackgroundColor3 = Colors.Accent,
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    Font = Enum.Font.SourceSansBold,
                    Parent = KeybindFrame
                })
                
                Utilities:CreateCorner(KeybindButton, 6)
                
                local listening = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    
                    listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.BackgroundColor3 = Colors.Warning
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybind = input.KeyCode
                            KeybindButton.Text = keybind.Name
                            KeybindButton.BackgroundColor3 = Colors.Accent
                            
                            if keybindConfig.Flag then
                                Ruvex.flags[keybindConfig.Flag] = keybind
                            end
                            
                            listening = false
                            connection:Disconnect()
                            
                            if Console.Container then
                                Console:AddMessage("Keybind changed: " .. keybindConfig.Name .. " = " .. keybind.Name, "INFO")
                            end
                        end
                    end)
                end)
                
                -- Listen for keybind presses
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or listening then return end
                    
                    if input.KeyCode == keybind then
                        keybindConfig.Callback(keybind)
                        
                        if Console.Container then
                            Console:AddMessage("Keybind pressed: " .. keybindConfig.Name, "INFO")
                        end
                    end
                end)
                
                return {
                    Set = function(self, newKeybind)
                        keybind = newKeybind
                        KeybindButton.Text = keybind.Name
                        if keybindConfig.Flag then
                            Ruvex.flags[keybindConfig.Flag] = keybind
                        end
                    end,
                    Get = function(self)
                        return keybind
                    end
                }
            end
            
            -- Advanced Color Picker (Enhanced)
            function Section:ColorPicker(colorConfig)
                colorConfig = colorConfig or {}
                colorConfig.Name = colorConfig.Name or "Color Picker"
                colorConfig.Default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
                colorConfig.Flag = colorConfig.Flag
                colorConfig.Callback = colorConfig.Callback or function() end
                
                local color = colorConfig.Default
                if colorConfig.Flag then
                    Ruvex.flags[colorConfig.Flag] = color
                end
                
                local ColorFrame = Utilities:Create("Frame", {
                    Name = "ColorFrame",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(ColorFrame, 8)
                Utilities:CreateStroke(ColorFrame, Colors.Divider, 1)
                
                local ColorLabel = Utilities:Create("TextLabel", {
                    Text = colorConfig.Name,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.fromOffset(15, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = ColorFrame
                })
                
                local ColorPreview = Utilities:Create("Frame", {
                    Size = UDim2.fromOffset(40, 25),
                    Position = UDim2.new(1, -50, 0.5, -12.5),
                    BackgroundColor3 = color,
                    Parent = ColorFrame
                })
                
                Utilities:CreateCorner(ColorPreview, 6)
                Utilities:CreateStroke(ColorPreview, Colors.Divider, 1)
                
                local ColorButton = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = ColorPreview
                })
                
                -- Rainbow mode toggle
                local rainbowMode = false
                local rainbowConnection
                
                ColorButton.MouseButton1Click:Connect(function()
                    -- Toggle through preset colors and rainbow mode
                    local colors = {
                        Color3.fromRGB(255, 255, 255),
                        Color3.fromRGB(220, 50, 47),
                        Color3.fromRGB(40, 167, 69),
                        Color3.fromRGB(255, 193, 7),
                        Color3.fromRGB(0, 123, 255),
                        Color3.fromRGB(108, 117, 125),
                        "RAINBOW"
                    }
                    
                    local currentIndex = 1
                    
                    if rainbowMode then
                        currentIndex = 7
                    else
                        for i, c in pairs(colors) do
                            if type(c) ~= "string" and c == color then
                                currentIndex = i
                                break
                            end
                        end
                    end
                    
                    local nextIndex = currentIndex % #colors + 1
                    local nextColor = colors[nextIndex]
                    
                    if nextColor == "RAINBOW" then
                        rainbowMode = true
                        if rainbowConnection then rainbowConnection:Disconnect() end
                        rainbowConnection = RunService.Heartbeat:Connect(function()
                            color = Utilities:GetRainbowColor()
                            ColorPreview.BackgroundColor3 = color
                            if colorConfig.Flag then
                                Ruvex.flags[colorConfig.Flag] = color
                            end
                            colorConfig.Callback(color)
                        end)
                    else
                        rainbowMode = false
                        if rainbowConnection then
                            rainbowConnection:Disconnect()
                            rainbowConnection = nil
                        end
                        color = nextColor
                        ColorPreview.BackgroundColor3 = color
                        if colorConfig.Flag then
                            Ruvex.flags[colorConfig.Flag] = color
                        end
                        colorConfig.Callback(color)
                    end
                    
                    if Console.Container then
                        Console:AddMessage("Color changed: " .. colorConfig.Name .. (rainbowMode and " (Rainbow)" or ""), "INFO")
                    end
                end)
                
                return {
                    Set = function(self, newColor)
                        if rainbowConnection then
                            rainbowConnection:Disconnect()
                            rainbowConnection = nil
                            rainbowMode = false
                        end
                        
                        color = newColor
                        ColorPreview.BackgroundColor3 = color
                        if colorConfig.Flag then
                            Ruvex.flags[colorConfig.Flag] = color
                        end
                        colorConfig.Callback(color)
                    end,
                    Get = function(self)
                        return color
                    end,
                    SetRainbow = function(self, enabled)
                        if enabled then
                            rainbowMode = true
                            if rainbowConnection then rainbowConnection:Disconnect() end
                            rainbowConnection = RunService.Heartbeat:Connect(function()
                                color = Utilities:GetRainbowColor()
                                ColorPreview.BackgroundColor3 = color
                                if colorConfig.Flag then
                                    Ruvex.flags[colorConfig.Flag] = color
                                end
                                colorConfig.Callback(color)
                            end)
                        else
                            rainbowMode = false
                            if rainbowConnection then
                                rainbowConnection:Disconnect()
                                rainbowConnection = nil
                            end
                        end
                    end
                }
            end
            
            -- Label Element (Enhanced)
            function Section:Label(labelConfig)
                labelConfig = labelConfig or {}
                labelConfig.Text = labelConfig.Text or "Label"
                labelConfig.Size = labelConfig.Size or 14
                labelConfig.Color = labelConfig.Color or Colors.SecondaryText
                
                local LabelFrame = Utilities:Create("TextLabel", {
                    Name = "LabelFrame",
                    Text = labelConfig.Text,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    TextColor3 = labelConfig.Color,
                    TextSize = labelConfig.Size,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Font = Enum.Font.SourceSans,
                    Parent = SectionContent
                })
                
                local LabelPadding = Utilities:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 15),
                    PaddingRight = UDim.new(0, 15),
                    Parent = LabelFrame
                })
                
                return {
                    Set = function(self, newText)
                        LabelFrame.Text = newText
                    end,
                    SetColor = function(self, newColor)
                        LabelFrame.TextColor3 = newColor
                    end
                }
            end
            
            -- Multi-Dropdown Element (New Advanced Component)
            function Section:MultiDropdown(multiDropdownConfig)
                multiDropdownConfig = multiDropdownConfig or {}
                multiDropdownConfig.Name = multiDropdownConfig.Name or "Multi Dropdown"
                multiDropdownConfig.Options = multiDropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                multiDropdownConfig.Default = multiDropdownConfig.Default or {}
                multiDropdownConfig.Flag = multiDropdownConfig.Flag
                multiDropdownConfig.Callback = multiDropdownConfig.Callback or function() end
                
                local selected = multiDropdownConfig.Default
                if multiDropdownConfig.Flag then
                    Ruvex.flags[multiDropdownConfig.Flag] = selected
                end
                
                local opened = false
                
                local MultiDropdownFrame = Utilities:Create("Frame", {
                    Name = "MultiDropdownFrame",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(MultiDropdownFrame, 8)
                Utilities:CreateStroke(MultiDropdownFrame, Colors.Divider, 1)
                
                local MultiDropdownButton = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = MultiDropdownFrame
                })
                
                local function GetSelectedText()
                    if #selected == 0 then return "None Selected"
                    elseif #selected == 1 then return selected[1]
                    else return #selected .. " Selected"
                    end
                end
                
                local MultiDropdownLabel = Utilities:Create("TextLabel", {
                    Text = multiDropdownConfig.Name .. ": " .. GetSelectedText(),
                    Size = UDim2.new(1, -40, 0, 35),
                    Position = UDim2.fromOffset(15, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = MultiDropdownFrame
                })
                
                local MultiDropdownArrow = Utilities:Create("TextLabel", {
                    Text = "▼",
                    Size = UDim2.fromOffset(20, 35),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.SecondaryText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Font = Enum.Font.SourceSansBold,
                    Parent = MultiDropdownFrame
                })
                
                local OptionsFrame = Utilities:Create("Frame", {
                    Name = "OptionsFrame",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    BackgroundColor3 = Colors.Background,
                    Visible = false,
                    Parent = MultiDropdownFrame,
                    ZIndex = 5
                })
                
                Utilities:CreateCorner(OptionsFrame, 8)
                Utilities:CreateStroke(OptionsFrame, Colors.Divider, 1)
                
                local OptionsList = Utilities:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsFrame
                })
                
                local function CreateOption(option)
                    local isSelected = table.find(selected, option) ~= nil
                    
                    local OptionButton = Utilities:Create("TextButton", {
                        Text = "",
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Colors.Background,
                        Parent = OptionsFrame,
                        ZIndex = 6
                    })
                    
                    Utilities:CreateCorner(OptionButton, 6)
                    
                    local OptionCheckbox = Utilities:Create("Frame", {
                        Size = UDim2.fromOffset(16, 16),
                        Position = UDim2.fromOffset(10, 7),
                        BackgroundColor3 = isSelected and Colors.Accent or Colors.Tertiary,
                        Parent = OptionButton
                    })
                    
                    Utilities:CreateCorner(OptionCheckbox, 3)
                    
                    if isSelected then
                        local checkmark = Utilities:Create("TextLabel", {
                            Text = "✓",
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = Colors.Text,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Font = Enum.Font.SourceSansBold,
                            Parent = OptionCheckbox
                        })
                    end
                    
                    local OptionText = Utilities:Create("TextLabel", {
                        Text = option,
                        Size = UDim2.new(1, -35, 1, 0),
                        Position = UDim2.fromOffset(30, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.SourceSansBold,
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        local index = table.find(selected, option)
                        if index then
                            table.remove(selected, index)
                            OptionCheckbox.BackgroundColor3 = Colors.Tertiary
                            for _, child in pairs(OptionCheckbox:GetChildren()) do
                                if child.Name ~= "UICorner" then child:Destroy() end
                            end
                        else
                            table.insert(selected, option)
                            OptionCheckbox.BackgroundColor3 = Colors.Accent
                            Utilities:Create("TextLabel", {
                                Text = "✓",
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                TextColor3 = Colors.Text,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                Font = Enum.Font.SourceSansBold,
                                Parent = OptionCheckbox
                            })
                        end
                        
                        if multiDropdownConfig.Flag then
                            Ruvex.flags[multiDropdownConfig.Flag] = selected
                        end
                        
                        MultiDropdownLabel.Text = multiDropdownConfig.Name .. ": " .. GetSelectedText()
                        multiDropdownConfig.Callback(selected)
                        
                        if Console.Container then
                            Console:AddMessage("Multi-dropdown changed: " .. multiDropdownConfig.Name, "INFO")
                        end
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Utilities:Tween(OptionButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Background, 15)})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Utilities:Tween(OptionButton, 0.2, {BackgroundColor3 = Colors.Background})
                    end)
                end
                
                for _, option in pairs(multiDropdownConfig.Options) do
                    CreateOption(option)
                end
                
                MultiDropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    OptionsFrame.Visible = opened
                    
                    if opened then
                        local optionsHeight = #multiDropdownConfig.Options * 30
                        OptionsFrame.Size = UDim2.new(1, 0, 0, optionsHeight)
                        Utilities:Tween(MultiDropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 35 + optionsHeight)})
                        Utilities:Tween(MultiDropdownArrow, 0.2, {Rotation = 180})
                    else
                        Utilities:Tween(MultiDropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
                        Utilities:Tween(MultiDropdownArrow, 0.2, {Rotation = 0})
                    end
                end)
                
                return {
                    Set = function(self, options)
                        selected = options or {}
                        if multiDropdownConfig.Flag then
                            Ruvex.flags[multiDropdownConfig.Flag] = selected
                        end
                        MultiDropdownLabel.Text = multiDropdownConfig.Name .. ": " .. GetSelectedText()
                        
                        -- Update visual state
                        for _, child in pairs(OptionsFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                local option = child:FindFirstChild("TextLabel").Text
                                local checkbox = child:FindFirstChild("Frame")
                                local isSelected = table.find(selected, option) ~= nil
                                
                                checkbox.BackgroundColor3 = isSelected and Colors.Accent or Colors.Tertiary
                                for _, checkChild in pairs(checkbox:GetChildren()) do
                                    if checkChild.Name ~= "UICorner" then checkChild:Destroy() end
                                end
                                
                                if isSelected then
                                    Utilities:Create("TextLabel", {
                                        Text = "✓",
                                        Size = UDim2.new(1, 0, 1, 0),
                                        BackgroundTransparency = 1,
                                        TextColor3 = Colors.Text,
                                        TextSize = 12,
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        Font = Enum.Font.SourceSansBold,
                                        Parent = checkbox
                                    })
                                end
                            end
                        end
                        
                        multiDropdownConfig.Callback(selected)
                    end,
                    Get = function(self)
                        return selected
                    end,
                    AddOption = function(self, option)
                        table.insert(multiDropdownConfig.Options, option)
                        CreateOption(option)
                    end,
                    RemoveOption = function(self, option)
                        local index = table.find(multiDropdownConfig.Options, option)
                        if index then
                            table.remove(multiDropdownConfig.Options, index)
                            -- Remove from selected if present
                            local selectedIndex = table.find(selected, option)
                            if selectedIndex then
                                table.remove(selected, selectedIndex)
                            end
                            -- Remove UI element
                            for _, child in pairs(OptionsFrame:GetChildren()) do
                                if child:IsA("TextButton") and child:FindFirstChild("TextLabel").Text == option then
                                    child:Destroy()
                                    break
                                end
                            end
                        end
                    end
                }
            end
            
            -- Range Slider Element (New Advanced Component)
            function Section:RangeSlider(rangeSliderConfig)
                rangeSliderConfig = rangeSliderConfig or {}
                rangeSliderConfig.Name = rangeSliderConfig.Name or "Range Slider"
                rangeSliderConfig.Min = rangeSliderConfig.Min or 0
                rangeSliderConfig.Max = rangeSliderConfig.Max or 100
                rangeSliderConfig.DefaultMin = rangeSliderConfig.DefaultMin or 25
                rangeSliderConfig.DefaultMax = rangeSliderConfig.DefaultMax or 75
                rangeSliderConfig.Increment = rangeSliderConfig.Increment or 1
                rangeSliderConfig.Suffix = rangeSliderConfig.Suffix or ""
                rangeSliderConfig.Flag = rangeSliderConfig.Flag
                rangeSliderConfig.Callback = rangeSliderConfig.Callback or function() end
                
                local minValue = rangeSliderConfig.DefaultMin
                local maxValue = rangeSliderConfig.DefaultMax
                
                if rangeSliderConfig.Flag then
                    Ruvex.flags[rangeSliderConfig.Flag] = {minValue, maxValue}
                end
                
                local RangeSliderFrame = Utilities:Create("Frame", {
                    Name = "RangeSliderFrame",
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(RangeSliderFrame, 8)
                Utilities:CreateStroke(RangeSliderFrame, Colors.Divider, 1)
                
                local RangeSliderLabel = Utilities:Create("TextLabel", {
                    Text = rangeSliderConfig.Name,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.fromOffset(15, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = RangeSliderFrame
                })
                
                local RangeSliderValue = Utilities:Create("TextLabel", {
                    Text = tostring(minValue) .. rangeSliderConfig.Suffix .. " - " .. tostring(maxValue) .. rangeSliderConfig.Suffix,
                    Size = UDim2.new(1, -15, 0, 20),
                    Position = UDim2.new(0, 0, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.SourceSansBold,
                    Parent = RangeSliderFrame
                })
                
                -- Range slider track
                local RangeSliderTrack = Utilities:Create("Frame", {
                    Name = "RangeSliderTrack",
                    Size = UDim2.new(1, -30, 0, 4),
                    Position = UDim2.fromOffset(15, 35),
                    BackgroundColor3 = Colors.Background,
                    Parent = RangeSliderFrame
                })
                
                Utilities:CreateCorner(RangeSliderTrack, 2)
                
                local minPercent = (minValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min)
                local maxPercent = (maxValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min)
                
                local RangeSliderFill = Utilities:Create("Frame", {
                    Name = "RangeSliderFill",
                    Size = UDim2.new(maxPercent - minPercent, 0, 1, 0),
                    Position = UDim2.new(minPercent, 0, 0, 0),
                    BackgroundColor3 = Colors.Accent,
                    Parent = RangeSliderTrack
                })
                
                Utilities:CreateCorner(RangeSliderFill, 2)
                
                local MinKnob = Utilities:Create("Frame", {
                    Name = "MinKnob",
                    Size = UDim2.fromOffset(12, 12),
                    Position = UDim2.new(minPercent, -6, 0.5, -6),
                    BackgroundColor3 = Colors.Text,
                    Parent = RangeSliderTrack
                })
                
                Utilities:CreateCorner(MinKnob, 6)
                
                local MaxKnob = Utilities:Create("Frame", {
                    Name = "MaxKnob",
                    Size = UDim2.fromOffset(12, 12),
                    Position = UDim2.new(maxPercent, -6, 0.5, -6),
                    BackgroundColor3 = Colors.Text,
                    Parent = RangeSliderTrack
                })
                
                Utilities:CreateCorner(MaxKnob, 6)
                
                local RangeSliderInput = Utilities:Create("TextButton", {
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = RangeSliderTrack
                })
                
                local draggingMin = false
                local draggingMax = false
                
                local function UpdateRange()
                    local newMinPercent = (minValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min)
                    local newMaxPercent = (maxValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min)
                    
                    RangeSliderValue.Text = tostring(minValue) .. rangeSliderConfig.Suffix .. " - " .. tostring(maxValue) .. rangeSliderConfig.Suffix
                    
                    Utilities:Tween(RangeSliderFill, 0.1, {
                        Size = UDim2.new(newMaxPercent - newMinPercent, 0, 1, 0),
                        Position = UDim2.new(newMinPercent, 0, 0, 0)
                    })
                    Utilities:Tween(MinKnob, 0.1, {Position = UDim2.new(newMinPercent, -6, 0.5, -6)})
                    Utilities:Tween(MaxKnob, 0.1, {Position = UDim2.new(newMaxPercent, -6, 0.5, -6)})
                    
                    if rangeSliderConfig.Flag then
                        Ruvex.flags[rangeSliderConfig.Flag] = {minValue, maxValue}
                    end
                    
                    rangeSliderConfig.Callback({minValue, maxValue})
                end
                
                local function HandleInput(input)
                    local percentage = math.clamp((input.Position.X - RangeSliderTrack.AbsolutePosition.X) / RangeSliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor(rangeSliderConfig.Min + (rangeSliderConfig.Max - rangeSliderConfig.Min) * percentage)
                    value = math.clamp(value, rangeSliderConfig.Min, rangeSliderConfig.Max)
                    
                    if rangeSliderConfig.Increment > 0 then
                        value = math.floor(value / rangeSliderConfig.Increment) * rangeSliderConfig.Increment
                    end
                    
                    if draggingMin then
                        minValue = math.min(value, maxValue - rangeSliderConfig.Increment)
                    elseif draggingMax then
                        maxValue = math.max(value, minValue + rangeSliderConfig.Increment)
                    else
                        -- Determine which knob is closer
                        local minDist = math.abs(percentage - (minValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min))
                        local maxDist = math.abs(percentage - (maxValue - rangeSliderConfig.Min) / (rangeSliderConfig.Max - rangeSliderConfig.Min))
                        
                        if minDist < maxDist then
                            minValue = math.min(value, maxValue - rangeSliderConfig.Increment)
                            draggingMin = true
                        else
                            maxValue = math.max(value, minValue + rangeSliderConfig.Increment)
                            draggingMax = true
                        end
                    end
                    
                    UpdateRange()
                end
                
                RangeSliderInput.MouseButton1Down:Connect(function()
                    HandleInput(UserInputService:GetMouseLocation())
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and (draggingMin or draggingMax) then
                        HandleInput(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingMin = false
                        draggingMax = false
                    end
                end)
                
                return {
                    Set = function(self, newMin, newMax)
                        minValue = math.clamp(newMin or minValue, rangeSliderConfig.Min, rangeSliderConfig.Max)
                        maxValue = math.clamp(newMax or maxValue, rangeSliderConfig.Min, rangeSliderConfig.Max)
                        
                        if minValue >= maxValue then
                            maxValue = minValue + rangeSliderConfig.Increment
                        end
                        
                        UpdateRange()
                    end,
                    Get = function(self)
                        return {minValue, maxValue}
                    end
                }
            end
            
            -- Progress Bar Element (New Component)
            function Section:ProgressBar(progressConfig)
                progressConfig = progressConfig or {}
                progressConfig.Name = progressConfig.Name or "Progress Bar"
                progressConfig.Min = progressConfig.Min or 0
                progressConfig.Max = progressConfig.Max or 100
                progressConfig.Default = progressConfig.Default or 0
                progressConfig.Suffix = progressConfig.Suffix or "%"
                progressConfig.Color = progressConfig.Color or Colors.Accent
                
                local progress = progressConfig.Default
                
                local ProgressFrame = Utilities:Create("Frame", {
                    Name = "ProgressFrame",
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(ProgressFrame, 8)
                Utilities:CreateStroke(ProgressFrame, Colors.Divider, 1)
                
                local ProgressLabel = Utilities:Create("TextLabel", {
                    Text = progressConfig.Name,
                    Size = UDim2.new(0.7, 0, 0, 20),
                    Position = UDim2.fromOffset(15, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = ProgressFrame
                })
                
                local ProgressValue = Utilities:Create("TextLabel", {
                    Text = tostring(progress) .. progressConfig.Suffix,
                    Size = UDim2.new(0.3, -15, 0, 20),
                    Position = UDim2.new(0.7, 0, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = progressConfig.Color,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.SourceSansBold,
                    Parent = ProgressFrame
                })
                
                local ProgressTrack = Utilities:Create("Frame", {
                    Name = "ProgressTrack",
                    Size = UDim2.new(1, -30, 0, 6),
                    Position = UDim2.fromOffset(15, 30),
                    BackgroundColor3 = Colors.Background,
                    Parent = ProgressFrame
                })
                
                Utilities:CreateCorner(ProgressTrack, 3)
                
                local ProgressFill = Utilities:Create("Frame", {
                    Name = "ProgressFill",
                    Size = UDim2.new((progress - progressConfig.Min) / (progressConfig.Max - progressConfig.Min), 0, 1, 0),
                    BackgroundColor3 = progressConfig.Color,
                    Parent = ProgressTrack
                })
                
                Utilities:CreateCorner(ProgressFill, 3)
                
                return {
                    Set = function(self, newProgress)
                        progress = math.clamp(newProgress, progressConfig.Min, progressConfig.Max)
                        local percentage = (progress - progressConfig.Min) / (progressConfig.Max - progressConfig.Min)
                        
                        ProgressValue.Text = tostring(progress) .. progressConfig.Suffix
                        Utilities:Tween(ProgressFill, 0.3, {Size = UDim2.new(percentage, 0, 1, 0)})
                    end,
                    Get = function(self)
                        return progress
                    end,
                    SetColor = function(self, newColor)
                        progressConfig.Color = newColor
                        ProgressFill.BackgroundColor3 = newColor
                        ProgressValue.TextColor3 = newColor
                    end
                }
            end
            
            -- Checkbox List Element (New Advanced Component)
            function Section:CheckboxList(checkboxListConfig)
                checkboxListConfig = checkboxListConfig or {}
                checkboxListConfig.Name = checkboxListConfig.Name or "Checkbox List"
                checkboxListConfig.Options = checkboxListConfig.Options or {"Option 1", "Option 2", "Option 3"}
                checkboxListConfig.Default = checkboxListConfig.Default or {}
                checkboxListConfig.Flag = checkboxListConfig.Flag
                checkboxListConfig.Callback = checkboxListConfig.Callback or function() end
                
                local selected = checkboxListConfig.Default
                if checkboxListConfig.Flag then
                    Ruvex.flags[checkboxListConfig.Flag] = selected
                end
                
                local CheckboxListFrame = Utilities:Create("Frame", {
                    Name = "CheckboxListFrame",
                    Size = UDim2.new(1, 0, 0, 35 + (#checkboxListConfig.Options * 30)),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(CheckboxListFrame, 8)
                Utilities:CreateStroke(CheckboxListFrame, Colors.Divider, 1)
                
                local CheckboxListLabel = Utilities:Create("TextLabel", {
                    Text = checkboxListConfig.Name,
                    Size = UDim2.new(1, -20, 0, 30),
                    Position = UDim2.fromOffset(15, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = CheckboxListFrame
                })
                
                local CheckboxContainer = Utilities:Create("Frame", {
                    Name = "CheckboxContainer",
                    Size = UDim2.new(1, 0, 0, #checkboxListConfig.Options * 30),
                    Position = UDim2.fromOffset(0, 35),
                    BackgroundTransparency = 1,
                    Parent = CheckboxListFrame
                })
                
                local CheckboxList = Utilities:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = CheckboxContainer
                })
                
                local function CreateCheckbox(option, index)
                    local isSelected = table.find(selected, option) ~= nil
                    
                    local CheckboxFrame = Utilities:Create("Frame", {
                        Name = "CheckboxFrame_" .. index,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundTransparency = 1,
                        Parent = CheckboxContainer
                    })
                    
                    local CheckboxButton = Utilities:Create("TextButton", {
                        Text = "",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Parent = CheckboxFrame
                    })
                    
                    local Checkbox = Utilities:Create("Frame", {
                        Size = UDim2.fromOffset(18, 18),
                        Position = UDim2.fromOffset(15, 6),
                        BackgroundColor3 = isSelected and Colors.Accent or Colors.Background,
                        Parent = CheckboxFrame
                    })
                    
                    Utilities:CreateCorner(Checkbox, 4)
                    Utilities:CreateStroke(Checkbox, Colors.Divider, 1)
                    
                    local checkmark = nil
                    if isSelected then
                        checkmark = Utilities:Create("TextLabel", {
                            Text = "✓",
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            TextColor3 = Colors.Text,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Font = Enum.Font.SourceSansBold,
                            Parent = Checkbox
                        })
                    end
                    
                    local CheckboxText = Utilities:Create("TextLabel", {
                        Text = option,
                        Size = UDim2.new(1, -50, 1, 0),
                        Position = UDim2.fromOffset(40, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.SourceSansBold,
                        Parent = CheckboxFrame
                    })
                    
                    CheckboxButton.MouseButton1Click:Connect(function()
                        local index = table.find(selected, option)
                        if index then
                            table.remove(selected, index)
                            Checkbox.BackgroundColor3 = Colors.Background
                            if checkmark then checkmark:Destroy() checkmark = nil end
                        else
                            table.insert(selected, option)
                            Checkbox.BackgroundColor3 = Colors.Accent
                            checkmark = Utilities:Create("TextLabel", {
                                Text = "✓",
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                TextColor3 = Colors.Text,
                                TextSize = 14,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                Font = Enum.Font.SourceSansBold,
                                Parent = Checkbox
                            })
                        end
                        
                        if checkboxListConfig.Flag then
                            Ruvex.flags[checkboxListConfig.Flag] = selected
                        end
                        
                        checkboxListConfig.Callback(selected)
                        
                        if Console.Container then
                            Console:AddMessage("Checkbox list updated: " .. checkboxListConfig.Name, "INFO")
                        end
                    end)
                    
                    CheckboxButton.MouseEnter:Connect(function()
                        Utilities:Tween(CheckboxFrame, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Tertiary, 10)})
                    end)
                    
                    CheckboxButton.MouseLeave:Connect(function()
                        Utilities:Tween(CheckboxFrame, 0.2, {BackgroundTransparency = 1})
                    end)
                    
                    return CheckboxFrame
                end
                
                for index, option in pairs(checkboxListConfig.Options) do
                    CreateCheckbox(option, index)
                end
                
                return {
                    Set = function(self, options)
                        selected = options or {}
                        if checkboxListConfig.Flag then
                            Ruvex.flags[checkboxListConfig.Flag] = selected
                        end
                        
                        -- Update all checkboxes
                        for index, option in pairs(checkboxListConfig.Options) do
                            local checkboxFrame = CheckboxContainer:FindFirstChild("CheckboxFrame_" .. index)
                            if checkboxFrame then
                                local checkbox = checkboxFrame:FindFirstChild("Frame")
                                local isSelected = table.find(selected, option) ~= nil
                                
                                checkbox.BackgroundColor3 = isSelected and Colors.Accent or Colors.Background
                                
                                local existingCheckmark = checkbox:FindFirstChild("TextLabel")
                                if isSelected and not existingCheckmark then
                                    Utilities:Create("TextLabel", {
                                        Text = "✓",
                                        Size = UDim2.new(1, 0, 1, 0),
                                        BackgroundTransparency = 1,
                                        TextColor3 = Colors.Text,
                                        TextSize = 14,
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        Font = Enum.Font.SourceSansBold,
                                        Parent = checkbox
                                    })
                                elseif not isSelected and existingCheckmark then
                                    existingCheckmark:Destroy()
                                end
                            end
                        end
                        
                        checkboxListConfig.Callback(selected)
                    end,
                    Get = function(self)
                        return selected
                    end,
                    AddOption = function(self, option)
                        table.insert(checkboxListConfig.Options, option)
                        CreateCheckbox(option, #checkboxListConfig.Options)
                        
                        -- Resize container
                        local newHeight = 35 + (#checkboxListConfig.Options * 30)
                        CheckboxListFrame.Size = UDim2.new(1, 0, 0, newHeight)
                        CheckboxContainer.Size = UDim2.new(1, 0, 0, #checkboxListConfig.Options * 30)
                    end,
                    RemoveOption = function(self, option)
                        local index = table.find(checkboxListConfig.Options, option)
                        if index then
                            table.remove(checkboxListConfig.Options, index)
                            
                            -- Remove from selected if present
                            local selectedIndex = table.find(selected, option)
                            if selectedIndex then
                                table.remove(selected, selectedIndex)
                            end
                            
                            -- Remove UI element
                            local checkboxFrame = CheckboxContainer:FindFirstChild("CheckboxFrame_" .. index)
                            if checkboxFrame then
                                checkboxFrame:Destroy()
                            end
                            
                            -- Resize container
                            local newHeight = 35 + (#checkboxListConfig.Options * 30)
                            CheckboxListFrame.Size = UDim2.new(1, 0, 0, newHeight)
                            CheckboxContainer.Size = UDim2.new(1, 0, 0, #checkboxListConfig.Options * 30)
                        end
                    end
                }
            end
            
            -- Search Bar Element (From Cerberus)
            function Section:SearchBar(searchConfig)
                searchConfig = searchConfig or {}
                searchConfig.Name = searchConfig.Name or "Search Bar"
                searchConfig.Placeholder = searchConfig.Placeholder or "Search..."
                searchConfig.Flag = searchConfig.Flag
                searchConfig.Callback = searchConfig.Callback or function() end
                
                local searchText = ""
                if searchConfig.Flag then
                    Ruvex.flags[searchConfig.Flag] = searchText
                end
                
                local SearchFrame = Utilities:Create("Frame", {
                    Name = "SearchFrame",
                    Size = UDim2.new(1, 0, 0, 55),
                    BackgroundColor3 = Colors.Tertiary,
                    Parent = SectionContent
                })
                
                Utilities:CreateCorner(SearchFrame, 8)
                Utilities:CreateStroke(SearchFrame, Colors.Divider, 1)
                
                local SearchLabel = Utilities:Create("TextLabel", {
                    Text = searchConfig.Name,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.fromOffset(15, 8),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.SourceSansBold,
                    Parent = SearchFrame
                })
                
                local SearchInput = Utilities:Create("TextBox", {
                    Text = "",
                    PlaceholderText = searchConfig.Placeholder,
                    Size = UDim2.new(1, -50, 0, 22),
                    Position = UDim2.fromOffset(10, 28),
                    BackgroundColor3 = Colors.Main,
                    TextColor3 = Colors.Text,
                    PlaceholderColor3 = Colors.SecondaryText,
                    TextSize = 13,
                    Font = Enum.Font.SourceSans,
                    ClearButtonOnFocus = false,
                    Parent = SearchFrame
                })
                
                Utilities:CreateCorner(SearchInput, 6)
                Utilities:CreateStroke(SearchInput, Colors.Divider, 1)
                
                local SearchIcon = Utilities:Create("TextLabel", {
                    Text = "🔍",
                    Size = UDim2.fromOffset(20, 22),
                    Position = UDim2.new(1, -35, 0, 28),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.SecondaryText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Font = Enum.Font.SourceSansBold,
                    Parent = SearchFrame
                })
                
                SearchInput.Changed:Connect(function(property)
                    if property == "Text" then
                        searchText = SearchInput.Text
                        if searchConfig.Flag then
                            Ruvex.flags[searchConfig.Flag] = searchText
                        end
                        searchConfig.Callback(searchText)
                        
                        if Console.Container then
                            Console:AddMessage("Search query: " .. searchText, "INFO")
                        end
                    end
                end)
                
                SearchInput.Focused:Connect(function()
                    Utilities:Tween(SearchInput, 0.2, {BackgroundColor3 = Utilities:ModifyColor(Colors.Main, 10)})
                    Utilities:Tween(SearchIcon, 0.2, {TextColor3 = Colors.Accent})
                end)
                
                SearchInput.FocusLost:Connect(function()
                    Utilities:Tween(SearchInput, 0.2, {BackgroundColor3 = Colors.Main})
                    Utilities:Tween(SearchIcon, 0.2, {TextColor3 = Colors.SecondaryText})
                end)
                
                return {
                    Set = function(self, newText)
                        searchText = newText
                        SearchInput.Text = newText
                        if searchConfig.Flag then
                            Ruvex.flags[searchConfig.Flag] = searchText
                        end
                        searchConfig.Callback(searchText)
                    end,
                    Get = function(self)
                        return searchText
                    end,
                    Clear = function(self)
                        searchText = ""
                        SearchInput.Text = ""
                        if searchConfig.Flag then
                            Ruvex.flags[searchConfig.Flag] = searchText
                        end
                        searchConfig.Callback(searchText)
                    end
                }
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Window management functions
    function Window:SetTheme(themeName)
        Ruvex:ChangeTheme(themeName)
    end
    
    function Window:SaveConfig(configName)
        return ConfigSystem:SaveConfig(configName, Ruvex.flags)
    end
    
    function Window:LoadConfig(configName)
        local config = ConfigSystem:LoadConfig(configName)
        if config then
            for flag, value in pairs(config) do
                Ruvex.flags[flag] = value
            end
            if Console.Container then
                Console:AddMessage("Config loaded: " .. configName, "SUCCESS")
            end
            return true
        end
        return false
    end
    
    function Window:GetConfigs()
        return ConfigSystem:GetConfigs()
    end
    
    function Window:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end
        
        for i, window in pairs(Ruvex.Windows) do
            if window == self then
                table.remove(Ruvex.Windows, i)
                break
            end
        end
    end
    
    table.insert(Ruvex.Windows, Window)
    return Window
end

-- Notification System (Enhanced from Flux)
function Ruvex:Notification(notificationConfig)
    notificationConfig = notificationConfig or {}
    notificationConfig.Title = notificationConfig.Title or "Notification"
    notificationConfig.Text = notificationConfig.Text or "This is a notification"
    notificationConfig.Duration = notificationConfig.Duration or 3
    notificationConfig.Type = notificationConfig.Type or "Info" -- Info, Success, Warning, Error
    notificationConfig.Actions = notificationConfig.Actions or {}
    
    local NotificationContainer = CoreGui:FindFirstChild("RuvexNotifications")
    if not NotificationContainer then
        NotificationContainer = Utilities:Create("ScreenGui", {
            Name = "RuvexNotifications",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui
        })
        
        local NotificationList = Utilities:Create("Frame", {
            Name = "NotificationList",
            Size = UDim2.new(0, 350, 1, 0),
            Position = UDim2.new(1, -360, 0, 10),
            BackgroundTransparency = 1,
            Parent = NotificationContainer
        })
        
        local ListLayout = Utilities:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Parent = NotificationList
        })
    end
    
    local typeColors = {
        Info = Colors.Accent,
        Success = Colors.Success,
        Warning = Colors.Warning,
        Error = Colors.Error
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✗"
    }
    
    local NotificationFrame = Utilities:Create("Frame", {
        Name = "NotificationFrame",
        Size = UDim2.new(1, 0, 0, #notificationConfig.Actions > 0 and 100 or 80),
        BackgroundColor3 = Colors.Secondary,
        Parent = NotificationContainer.NotificationList
    })
    
    Utilities:CreateCorner(NotificationFrame, 10)
    Utilities:CreateStroke(NotificationFrame, typeColors[notificationConfig.Type] or Colors.Accent, 2)
    
    -- Enhanced notification with icon
    local NotificationIcon = Utilities:Create("TextLabel", {
        Text = typeIcons[notificationConfig.Type] or "ℹ",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(15, 15),
        BackgroundTransparency = 1,
        TextColor3 = typeColors[notificationConfig.Type] or Colors.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.SourceSansBold,
        Parent = NotificationFrame
    })
    
    local NotificationTitle = Utilities:Create("TextLabel", {
        Text = notificationConfig.Title,
        Size = UDim2.new(1, -60, 0, 25),
        Position = UDim2.fromOffset(50, 10),
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        Parent = NotificationFrame
    })
    
    local NotificationText = Utilities:Create("TextLabel", {
        Text = notificationConfig.Text,
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.fromOffset(50, 35),
        BackgroundTransparency = 1,
        TextColor3 = Colors.SecondaryText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Font = Enum.Font.SourceSans,
        Parent = NotificationFrame
    })
    
    -- Action buttons
    if #notificationConfig.Actions > 0 then
        local ActionsFrame = Utilities:Create("Frame", {
            Name = "ActionsFrame",
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.fromOffset(10, 70),
            BackgroundTransparency = 1,
            Parent = NotificationFrame
        })
        
        local ActionsList = Utilities:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = ActionsFrame
        })
        
        for _, action in pairs(notificationConfig.Actions) do
            local ActionButton = Utilities:Create("TextButton", {
                Text = action.Text or "Action",
                Size = UDim2.new(0, 80, 1, 0),
                BackgroundColor3 = action.Primary and Colors.Accent or Colors.Tertiary,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Font = Enum.Font.SourceSansBold,
                Parent = ActionsFrame
            })
            
            Utilities:CreateCorner(ActionButton, 6)
            
            ActionButton.MouseButton1Click:Connect(function()
                if action.Callback then
                    action.Callback()
                end
                NotificationFrame:Destroy()
            end)
            
            ActionButton.MouseEnter:Connect(function()
                Utilities:Tween(ActionButton, 0.2, {BackgroundColor3 = Utilities:ModifyColor(ActionButton.BackgroundColor3, 20)})
            end)
            
            ActionButton.MouseLeave:Connect(function()
                Utilities:Tween(ActionButton, 0.2, {BackgroundColor3 = action.Primary and Colors.Accent or Colors.Tertiary})
            end)
        end
    end
    
    -- Close button
    local CloseButton = Utilities:Create("TextButton", {
        Text = "×",
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -25, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = Colors.SecondaryText,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        Parent = NotificationFrame
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        Utilities:Tween(NotificationFrame, 0.3, {Position = UDim2.new(1, 0, 0, 0)}, function()
            NotificationFrame:Destroy()
        end)
    end)
    
    -- Slide in animation
    NotificationFrame.Position = UDim2.new(1, 0, 0, 0)
    Utilities:Tween(NotificationFrame, 0.4, {Position = UDim2.new(0, 0, 0, 0)})
    
    -- Auto-remove after duration (if no actions)
    if #notificationConfig.Actions == 0 then
        task.spawn(function()
            task.wait(notificationConfig.Duration)
            if NotificationFrame.Parent then
                Utilities:Tween(NotificationFrame, 0.3, {Position = UDim2.new(1, 0, 0, 0)}, function()
                    NotificationFrame:Destroy()
                end)
            end
        end)
    end
    
    table.insert(Ruvex.Notifications, NotificationFrame)
    
    return {
        Destroy = function()
            if NotificationFrame.Parent then
                NotificationFrame:Destroy()
            end
        end
    }
end

-- Global functions for easy access
function Ruvex:SaveFlags(configName)
    return ConfigSystem:SaveConfig(configName, self.flags)
end

function Ruvex:LoadFlags(configName)
    local config = ConfigSystem:LoadConfig(configName)
    if config then
        for flag, value in pairs(config) do
            self.flags[flag] = value
        end
        return true
    end
    return false
end

function Ruvex:ClearFlags()
    self.flags = {}
    self.Flags = self.flags
end

-- Advanced Visual Effects System (From all libraries)
local VisualEffects = {}

function VisualEffects:CreateGlow(object, color, intensity, size)
    local glow = Utilities:Create("ImageLabel", {
        Name = "Glow",
        Image = "rbxassetid://4996891970",
        ImageColor3 = color or Colors.Accent,
        ImageTransparency = 0.8,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, size or 30, 1, size or 30),
        Position = UDim2.new(0, -(size or 30)/2, 0, -(size or 30)/2),
        ZIndex = object.ZIndex - 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Parent = object
    })
    
    return glow
end

function VisualEffects:CreateShadow(object, color, offset, blur)
    local shadow = Utilities:Create("Frame", {
        Name = "Shadow",
        BackgroundColor3 = color or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        Size = object.Size,
        Position = object.Position + UDim2.fromOffset(offset or 5, offset or 5),
        ZIndex = object.ZIndex - 1,
        Parent = object.Parent
    })
    
    local corner = object:FindFirstChildOfClass("UICorner")
    if corner then
        Utilities:CreateCorner(shadow, corner.CornerRadius.Offset)
    end
    
    return shadow
end

function VisualEffects:CreateParticle(object, particleType)
    if particleType == "Rainbow" then
        local particles = {}
        for i = 1, 8 do
            local particle = Utilities:Create("Frame", {
                Size = UDim2.fromOffset(4, 4),
                Position = UDim2.fromOffset(math.random(-10, 10), math.random(-10, 10)),
                BackgroundColor3 = Color3.fromHSV(math.random(), 1, 1),
                BackgroundTransparency = 0.3,
                ZIndex = object.ZIndex + 1,
                Parent = object
            })
            Utilities:CreateCorner(particle, 2)
            table.insert(particles, particle)
        end
        
        task.spawn(function()
            while object.Parent do
                for _, particle in pairs(particles) do
                    if particle.Parent then
                        particle.BackgroundColor3 = Utilities:GetRainbowColor()
                        Utilities:Tween(particle, 2, {
                            Position = UDim2.fromOffset(math.random(-20, 20), math.random(-20, 20)),
                            BackgroundTransparency = math.random(0.2, 0.8)
                        })
                    end
                end
                task.wait(2)
            end
        end)
        
        return particles
    end
end

-- Enhanced Tab System with Icons (From Flux)
function Ruvex:CreateAdvancedTab(parent, config)
    config = config or {}
    config.Name = config.Name or "Tab"
    config.Icon = config.Icon or "rbxassetid://7734053426"
    config.IconSize = config.IconSize or UDim2.fromOffset(20, 20)
    config.Selected = config.Selected or false
    
    local TabFrame = Utilities:Create("Frame", {
        Name = "AdvancedTab",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = config.Selected and Colors.Accent or Colors.Tertiary,
        Parent = parent
    })
    
    Utilities:CreateCorner(TabFrame, 10)
    
    local TabButton = Utilities:Create("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = TabFrame
    })
    
    local TabIcon = Utilities:Create("ImageLabel", {
        Image = config.Icon,
        Size = config.IconSize,
        Position = UDim2.fromOffset(15, 15),
        BackgroundTransparency = 1,
        ImageColor3 = config.Selected and Colors.Text or Colors.SecondaryText,
        Parent = TabFrame
    })
    
    local TabLabel = Utilities:Create("TextLabel", {
        Text = config.Name,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(50, 0),
        BackgroundTransparency = 1,
        TextColor3 = config.Selected and Colors.Text or Colors.SecondaryText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        Parent = TabFrame
    })
    
    if config.Selected then
        VisualEffects:CreateGlow(TabFrame, Colors.Accent, 0.6, 20)
    end
    
    return {
        Frame = TabFrame,
        Button = TabButton,
        Icon = TabIcon,
        Label = TabLabel,
        Select = function()
            Utilities:Tween(TabFrame, 0.3, {BackgroundColor3 = Colors.Accent})
            Utilities:Tween(TabIcon, 0.3, {ImageColor3 = Colors.Text})
            Utilities:Tween(TabLabel, 0.3, {TextColor3 = Colors.Text})
            VisualEffects:CreateGlow(TabFrame, Colors.Accent, 0.6, 20)
        end,
        Deselect = function()
            Utilities:Tween(TabFrame, 0.3, {BackgroundColor3 = Colors.Tertiary})
            Utilities:Tween(TabIcon, 0.3, {ImageColor3 = Colors.SecondaryText})
            Utilities:Tween(TabLabel, 0.3, {TextColor3 = Colors.SecondaryText})
            local glow = TabFrame:FindFirstChild("Glow")
            if glow then glow:Destroy() end
        end
    }
end

-- Enhanced Keybind System (From multiple libraries)
function Ruvex:CreateGlobalKeybind(keyCode, callback, description)
    description = description or "Global Keybind"
    
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == keyCode then
            callback()
            if Console.Container then
                Console:AddMessage("Global keybind triggered: " .. description, "INFO")
            end
        end
    end)
    
    return {
        Disconnect = function()
            connection:Disconnect()
        end,
        SetKey = function(newKey)
            connection:Disconnect()
            keyCode = newKey
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == keyCode then
                    callback()
                    if Console.Container then
                        Console:AddMessage("Global keybind triggered: " .. description, "INFO")
                    end
                end
            end)
        end
    }
end

-- Flexible Theme System with Live Updates (Enhanced from Mercury)
function Ruvex:CreateCustomTheme(themeName, colors)
    Themes[themeName] = colors
    
    return {
        Apply = function()
            Ruvex:ChangeTheme(themeName)
        end,
        Update = function(newColors)
            for colorName, color in pairs(newColors) do
                Themes[themeName][colorName] = color
            end
            if Ruvex.CurrentTheme == themeName then
                Ruvex:ChangeTheme(themeName)
            end
        end,
        Remove = function()
            Themes[themeName] = nil
        end
    }
end

-- Advanced Animation Presets (From all libraries)
local AnimationPresets = {
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

function Utilities:AnimateWithPreset(object, preset, properties, callback)
    local tweenInfo = AnimationPresets[preset] or AnimationPresets.Smooth
    return Utilities:Tween(object, tweenInfo, properties, callback)
end

-- Enhanced Notification System with Advanced Features (From Flux)
function Ruvex:AdvancedNotification(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Text = config.Text or "This is a notification"
    config.Duration = config.Duration or 4
    config.Type = config.Type or "Info"
    config.Icon = config.Icon
    config.Sound = config.Sound
    config.Position = config.Position or "TopRight"
    config.Actions = config.Actions or {}
    config.Progress = config.Progress
    
    local NotificationContainer = CoreGui:FindFirstChild("RuvexAdvancedNotifications")
    if not NotificationContainer then
        NotificationContainer = Utilities:Create("ScreenGui", {
            Name = "RuvexAdvancedNotifications",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui
        })
        
        local positions = {
            TopRight = UDim2.new(1, -360, 0, 10),
            TopLeft = UDim2.new(0, 10, 0, 10),
            BottomRight = UDim2.new(1, -360, 1, -200),
            BottomLeft = UDim2.new(0, 10, 1, -200)
        }
        
        for posName, pos in pairs(positions) do
            local NotificationList = Utilities:Create("Frame", {
                Name = posName .. "List",
                Size = UDim2.new(0, 350, 0, 400),
                Position = pos,
                BackgroundTransparency = 1,
                Parent = NotificationContainer
            })
            
            Utilities:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Parent = NotificationList
            })
        end
    end
    
    local targetList = NotificationContainer:FindFirstChild(config.Position .. "List")
    if not targetList then
        targetList = NotificationContainer:FindFirstChild("TopRightList")
    end
    
    local typeColors = {
        Info = Colors.Accent,
        Success = Colors.Success,
        Warning = Colors.Warning,
        Error = Colors.Error,
        Custom = config.Color or Colors.Accent
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✗",
        Custom = config.Icon or "●"
    }
    
    local NotificationFrame = Utilities:Create("Frame", {
        Name = "AdvancedNotification",
        Size = UDim2.new(1, 0, 0, config.Progress and 110 or 90),
        BackgroundColor3 = Colors.Background,
        Parent = targetList
    })
    
    Utilities:CreateCorner(NotificationFrame, 12)
    Utilities:CreateStroke(NotificationFrame, typeColors[config.Type] or Colors.Accent, 2)
    VisualEffects:CreateGlow(NotificationFrame, typeColors[config.Type] or Colors.Accent, 0.8, 25)
    
    -- Notification content with advanced layout
    local ContentFrame = Utilities:Create("Frame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Parent = NotificationFrame
    })
    
    local NotificationIcon = Utilities:Create("TextLabel", {
        Text = typeIcons[config.Type] or "ℹ",
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        TextColor3 = typeColors[config.Type] or Colors.Accent,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.SourceSansBold,
        Parent = ContentFrame
    })
    
    local NotificationTitle = Utilities:Create("TextLabel", {
        Text = config.Title,
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.fromOffset(40, 0),
        BackgroundTransparency = 1,
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        Parent = ContentFrame
    })
    
    local NotificationText = Utilities:Create("TextLabel", {
        Text = config.Text,
        Size = UDim2.new(1, -80, 0, 35),
        Position = UDim2.fromOffset(40, 22),
        BackgroundTransparency = 1,
        TextColor3 = Colors.SecondaryText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Font = Enum.Font.SourceSans,
        Parent = ContentFrame
    })
    
    -- Progress bar if specified
    if config.Progress then
        local ProgressTrack = Utilities:Create("Frame", {
            Size = UDim2.new(1, -80, 0, 4),
            Position = UDim2.fromOffset(40, 60),
            BackgroundColor3 = Colors.Tertiary,
            Parent = ContentFrame
        })
        
        Utilities:CreateCorner(ProgressTrack, 2)
        
        local ProgressFill = Utilities:Create("Frame", {
            Size = UDim2.new(config.Progress / 100, 0, 1, 0),
            BackgroundColor3 = typeColors[config.Type] or Colors.Accent,
            Parent = ProgressTrack
        })
        
        Utilities:CreateCorner(ProgressFill, 2)
    end
    
    -- Advanced action buttons
    if #config.Actions > 0 then
        local ActionsFrame = Utilities:Create("Frame", {
            Size = UDim2.new(1, -80, 0, 25),
            Position = UDim2.fromOffset(40, config.Progress and 70 or 60),
            BackgroundTransparency = 1,
            Parent = ContentFrame
        })
        
        local ActionsList = Utilities:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = ActionsFrame
        })
        
        for _, action in pairs(config.Actions) do
            local ActionButton = Utilities:Create("TextButton", {
                Text = action.Text or "Action",
                Size = UDim2.new(0, 80, 1, 0),
                BackgroundColor3 = action.Primary and Colors.Accent or Colors.Tertiary,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Font = Enum.Font.SourceSansBold,
                Parent = ActionsFrame
            })
            
            Utilities:CreateCorner(ActionButton, 6)
            
            ActionButton.MouseButton1Click:Connect(function()
                if action.Callback then
                    action.Callback()
                end
                NotificationFrame:Destroy()
            end)
            
            ActionButton.MouseEnter:Connect(function()
                Utilities:AnimateWithPreset(ActionButton, "Quick", {BackgroundColor3 = Utilities:ModifyColor(ActionButton.BackgroundColor3, 20)})
            end)
            
            ActionButton.MouseLeave:Connect(function()
                Utilities:AnimateWithPreset(ActionButton, "Quick", {BackgroundColor3 = action.Primary and Colors.Accent or Colors.Tertiary})
            end)
        end
    end
    
    -- Close button with advanced design
    local CloseButton = Utilities:Create("TextButton", {
        Text = "×",
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = Colors.Error,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        Parent = NotificationFrame
    })
    
    Utilities:CreateCorner(CloseButton, 12)
    
    CloseButton.MouseButton1Click:Connect(function()
        Utilities:AnimateWithPreset(NotificationFrame, "Quick", {Position = UDim2.new(1, 0, 0, 0)}, function()
            NotificationFrame:Destroy()
        end)
    end)
    
    -- Slide in animation with advanced preset
    NotificationFrame.Position = UDim2.new(1, 0, 0, 0)
    Utilities:AnimateWithPreset(NotificationFrame, "Bounce", {Position = UDim2.new(0, 0, 0, 0)})
    
    -- Auto-remove with visual countdown
    if #config.Actions == 0 then
        task.spawn(function()
            task.wait(config.Duration)
            if NotificationFrame.Parent then
                Utilities:AnimateWithPreset(NotificationFrame, "Quick", {Position = UDim2.new(1, 0, 0, 0)}, function()
                    NotificationFrame:Destroy()
                end)
            end
        end)
    end
    
    -- Sound effect if specified
    if config.Sound then
        task.spawn(function()
            local sound = Instance.new("Sound")
            sound.SoundId = config.Sound
            sound.Volume = 0.5
            sound.Parent = NotificationFrame
            sound:Play()
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
        end)
    end
    
    return {
        Destroy = function()
            if NotificationFrame.Parent then
                NotificationFrame:Destroy()
            end
        end,
        UpdateProgress = function(progress)
            local progressFill = NotificationFrame:FindFirstChild("ProgressFill", true)
            if progressFill then
                Utilities:Tween(progressFill, 0.3, {Size = UDim2.new(progress / 100, 0, 1, 0)})
            end
        end
    }
end

-- Enhanced Drag and Drop System (From PPHUD/Cerberus)
function Utilities:CreateAdvancedDragging(object, handle, config)
    config = config or {}
    config.Constrain = config.Constrain or false
    config.Grid = config.Grid or false
    config.GridSize = config.GridSize or 10
    config.Smoothing = config.Smoothing or false
    config.OnDragStart = config.OnDragStart or function() end
    config.OnDrag = config.OnDrag or function() end
    config.OnDragEnd = config.OnDragEnd or function() end
    
    handle = handle or object
    local dragging = false
    local dragInput, mousePos, framePos
    local dragOffset = Vector2.new()
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = object.Position
            dragOffset = input.Position - Vector2.new(object.AbsolutePosition.X, object.AbsolutePosition.Y)
            
            config.OnDragStart(object)
            
            if config.Smoothing then
                handle.BackgroundColor3 = Utilities:ModifyColor(handle.BackgroundColor3, 10)
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    config.OnDragEnd(object)
                    
                    if config.Smoothing then
                        Utilities:Tween(handle, 0.2, {BackgroundColor3 = Colors.Secondary})
                    end
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local newPosition = framePos + UDim2.fromOffset(delta.X, delta.Y)
            
            if config.Grid then
                local gridX = math.floor((newPosition.X.Offset + config.GridSize/2) / config.GridSize) * config.GridSize
                local gridY = math.floor((newPosition.Y.Offset + config.GridSize/2) / config.GridSize) * config.GridSize
                newPosition = UDim2.new(newPosition.X.Scale, gridX, newPosition.Y.Scale, gridY)
            end
            
            if config.Constrain and object.Parent then
                local parentSize = object.Parent.AbsoluteSize
                local objectSize = object.AbsoluteSize
                
                local minX = 0
                local minY = 0
                local maxX = parentSize.X - objectSize.X
                local maxY = parentSize.Y - objectSize.Y
                
                newPosition = UDim2.fromOffset(
                    math.clamp(newPosition.X.Offset, minX, maxX),
                    math.clamp(newPosition.Y.Offset, minY, maxY)
                )
            end
            
            object.Position = newPosition
            config.OnDrag(object, newPosition)
        end
    end)
end

-- Initialize console logging
if Console.Container then
    Console:AddMessage("Ruvex UI Library initialized successfully", "SUCCESS")
    Console:AddMessage("Version: 3.0 - MAXIMUM Integration Complete", "INFO")
    Console:AddMessage("Theme: " .. Ruvex.CurrentTheme, "INFO")
    Console:AddMessage("All libraries merged: Mercury + Flux + Cerberus + Criminality + PPHUD", "INFO")
    Console:AddMessage("Advanced features: Tooltips, Visual Effects, Enhanced Animations, Glow Effects", "SUCCESS")
    Console:AddMessage("Components: 15+ UI elements with full functionality", "SUCCESS")
    Console:AddMessage("Console toggle: LeftAlt key or Console button", "INFO")
end

return Ruvex
