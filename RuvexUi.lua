--[[
  RUVEX UI LIBRARY - COMPLETE SCRIPT MERGER
  Merging: Mercury Lib.lua + Cerberus Lib.lua + Flux Lib.lua + Criminality Lib.lua + PPHud Lib.lua
  
  Features from each library:
  - Mercury Lib: Tab interface, window design, theme system, animations
  - Cerberus Lib: Button design, security features, anti-detection
  - Flux Lib: Color system, rainbow effects, notification system  
  - Criminality Lib: Smooth transitions, drag system
  - PPHud Lib: Design elements, UI components
  
  Color scheme: Red, Dark, Black, White
  Language: English only
  Compatibility: All Roblox script executors
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HTTPService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- MAIN LIBRARY TABLE
local Ruvex = {
  Flags = {},
  Toggled = true,
  ThemeObjects = {
    Main = {},
    Secondary = {},
    Tertiary = {},
    StrongText = {},
    WeakText = {}
  },
  CurrentTheme = nil,
  DragSpeed = 0.06,
  ToggleKey = Enum.KeyCode.Home,
  RainbowValue = 0
}

-- THEMES SYSTEM (From Mercury + Flux)
Ruvex.Themes = {
  Dark = {
    Main = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(35, 35, 40),
    Tertiary = Color3.fromRGB(255, 50, 50),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(172, 172, 172)
  },
  Red = {
    Main = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Tertiary = Color3.fromRGB(255, 0, 0),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(172, 172, 172)
  },
  Crimson = {
    Main = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(25, 25, 30),
    Tertiary = Color3.fromRGB(220, 20, 60),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(172, 172, 172)
  },
  Cerberus = {
    Main = Color3.fromRGB(30, 30, 35),
    Secondary = Color3.fromRGB(40, 40, 45),
    Tertiary = Color3.fromRGB(255, 65, 65),
    StrongText = Color3.fromRGB(255, 255, 255),
    WeakText = Color3.fromRGB(172, 172, 172)
  }
}

Ruvex.CurrentTheme = Ruvex.Themes.Dark

-- UTILITY FUNCTIONS (Mercury Base)
function Ruvex:set_defaults(defaults, options)
  defaults = defaults or {}
  options = options or {}
  for option, value in next, options do
    defaults[option] = value
  end
  return defaults
end

function Ruvex:object(class, properties)
  local localObject = Instance.new(class)

  local forcedProps = {
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.SourceSans,
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
    local options = Ruvex:set_defaults({
      Length = 0.2,
      Style = Enum.EasingStyle.Linear,
      Direction = Enum.EasingDirection.InOut
    }, options)
    callback = callback or function() return end

    local ti = TweenInfo.new(options.Length, options.Style, options.Direction)
    options.Length = nil
    options.Style = nil 
    options.Direction = nil

    local tween = TweenService:Create(localObject, ti, options); tween:Play()

    tween.Completed:Connect(function()
      callback()
    end)

    return tween
  end

  function methods:round(radius)
    radius = radius or 6
    Ruvex:object("UICorner", {
      Parent = localObject,
      CornerRadius = UDim.new(0, radius)
    })
    return methods
  end

  function methods:object(class, properties)
    local properties = properties or {}
    properties.Parent = localObject
    return Ruvex:object(class, properties)
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
          local themeColor = Ruvex.CurrentTheme[theme]
          local modifiedColor = themeColor
          if colorAlter < 0 then
            modifiedColor = Ruvex:darken(themeColor, -1 * colorAlter)
          elseif colorAlter > 0 then
            modifiedColor = Ruvex:lighten(themeColor, colorAlter)
          end
          localObject[property] = modifiedColor
          table.insert(Ruvex.ThemeObjects[theme], {methods, property, theme, colorAlter})
        else
          local themeColor = Ruvex.CurrentTheme[obj]
          localObject[property] = themeColor
          table.insert(Ruvex.ThemeObjects[obj], {methods, property, obj, 0})
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

function Ruvex:show(state)
  self.Toggled = state
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

function Ruvex:change_theme(toTheme)
  Ruvex.CurrentTheme = toTheme
  local c = self:lighten(toTheme.Tertiary, 20)
  if Ruvex.DisplayName then
    Ruvex.DisplayName.Text = "Welcome, <font color='rgb(" ..  math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")'> <b>" .. LocalPlayer.DisplayName .. "</b> </font>"
  end
  for color, objects in next, Ruvex.ThemeObjects do
    local themeColor = Ruvex.CurrentTheme[color]
    for _, obj in next, objects do
      local element, property, theme, colorAlter = obj[1], obj[2], obj[3], obj[4] or 0
      local themeColor = Ruvex.CurrentTheme[theme]
      local modifiedColor = themeColor
      if colorAlter < 0 then
        modifiedColor = Ruvex:darken(themeColor, -1 * colorAlter)
      elseif colorAlter > 0 then
        modifiedColor = Ruvex:lighten(themeColor, colorAlter)
      end
      element:tween{[property] = modifiedColor}
    end
  end
end

-- RAINBOW SYSTEM (From Flux)
spawn(function()
  while true do
    Ruvex.RainbowValue = Ruvex.RainbowValue + 1/255
    if Ruvex.RainbowValue >= 1 then
      Ruvex.RainbowValue = 0
    end
    wait()
  end
end)

function Ruvex:GetRainbowColor()
  return Color3.fromHSV(Ruvex.RainbowValue, 1, 1)
end

-- MAIN WINDOW CREATION (Mercury Lib base)
function Ruvex:create(options)
  local settings = {
    Theme = "Dark"
  }

  if readfile and writefile and isfile then
    if not isfile("RuvexSettings.json") then
      writefile("RuvexSettings.json", HTTPService:JSONEncode(settings))
    end
    settings = HTTPService:JSONDecode(readfile("RuvexSettings.json"))
    Ruvex.CurrentTheme = Ruvex.Themes[settings.Theme]
  end

  options = self:set_defaults({
    Name = "Ruvex",
    Size = UDim2.fromOffset(600, 400),
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
    Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
  })

  -- Notification holder (Flux style)
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

  -- Main frame (Mercury style)
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
      core.Active = true;

      Event:connect(function()
        local Input = core.InputBegan:connect(function(Key)
          if Key.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjectPosition = Vector2.new(Mouse.X - core.AbsolutePosition.X, Mouse.Y - core.AbsolutePosition.Y)
            while RunService.RenderStepped:wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do

              if Ruvex.LockDragging then
                local FrameX, FrameY = math.clamp(Mouse.X - ObjectPosition.X, 0, gui.AbsoluteSize.X - core.AbsoluteSize.X), math.clamp(Mouse.Y - ObjectPosition.Y, 0, gui.AbsoluteSize.Y - core.AbsoluteSize.Y)
                core:tween{
                  Position = UDim2.fromOffset(FrameX + (core.Size.X.Offset * core.AnchorPoint.X), FrameY + (core.Size.Y.Offset * core.AnchorPoint.Y)),
                  Length = Ruvex.DragSpeed
                }
              else
                core:tween{
                  Position = UDim2.fromOffset(Mouse.X - ObjectPosition.X + (core.Size.X.Offset * core.AnchorPoint.X), Mouse.Y - ObjectPosition.Y + (core.Size.Y.Offset * core.AnchorPoint.Y)),
                  Length = Ruvex.DragSpeed    
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

  -- Title bar
  local titleBar = core:object("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 0, 0)
  }):round(10)

  -- Title bar corner fix
  local titleBarCorner = titleBar:object("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 10)
  })

  local titleBarSeparator = titleBar:object("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Theme = {BackgroundColor3 = "Tertiary"},
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 2)
  })

  local title = titleBar:object("TextLabel", {
    Theme = {TextColor3 = "StrongText"},
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.fromOffset(15, 0),
    Text = options.Name,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
  })

  -- Close button
  local closeButton = titleBar:object("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    BackgroundTransparency = 1,
    Text = "×",
    TextSize = 18,
    Theme = {TextColor3 = "StrongText"},
    Font = Enum.Font.GothamBold
  })

  closeButton.MouseButton1Click:Connect(function()
    core.ClipsDescendants = true
    core:fade(true)
    wait(0.1)
    core:tween({Size = UDim2.new()}, function()
      gui.AbsoluteObject:Destroy()
    end)
  end)

  -- Content area
  local contentFrame = core:object("Frame", {
    Position = UDim2.new(0, 0, 0, 35),
    Size = UDim2.new(1, 0, 1, -35),
    BackgroundTransparency = 1
  })

  -- Tab container (Mercury style)
  local tabContainer = contentFrame:object("Frame", {
    Size = UDim2.new(0, 150, 1, 0),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 0, 0)
  })

  local tabLayout = tabContainer:object("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5)
  })

  local tabPadding = tabContainer:object("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
  })

  -- Page container
  local pageContainer = contentFrame:object("Frame", {
    Position = UDim2.new(0, 150, 0, 0),
    Size = UDim2.new(1, -150, 1, 0),
    Theme = {BackgroundColor3 = "Main"},
    BackgroundTransparency = 1
  })

  -- Display name setup
  if LocalPlayer.DisplayName then
    local c = self:lighten(self.CurrentTheme.Tertiary, 20)
    self.DisplayName = core:object("TextLabel", {
      AnchorPoint = Vector2.new(0.5, 0),
      Position = UDim2.new(0.5, 0, 0, 45),
      Size = UDim2.new(1, -40, 0, 20),
      BackgroundTransparency = 1,
      Text = "Welcome, <font color='rgb(" ..  math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")'> <b>" .. LocalPlayer.DisplayName .. "</b> </font>",
      TextSize = 14,
      Font = Enum.Font.Gotham,
      Theme = {TextColor3 = "StrongText"},
      RichText = true,
      TextXAlignment = Enum.TextXAlignment.Center
    })
  end

  local Window = {
    gui = gui,
    core = core,
    tabs = {},
    selectedTab = nil,
    notificationHolder = notificationHolder
  }

  -- NOTIFICATION SYSTEM (Flux style)
  function Window:notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local text = options.Text or "No text provided"
    local duration = options.Duration or 3

    local notification = Ruvex:object("Frame", {
      Parent = self.notificationHolder,
      Size = UDim2.new(1, 0, 0, 80),
      Theme = {BackgroundColor3 = "Secondary"}
    }):round(8)

    local notifTitle = notification:object("TextLabel", {
      Size = UDim2.new(1, -20, 0, 25),
      Position = UDim2.fromOffset(10, 5),
      BackgroundTransparency = 1,
      Text = title,
      Theme = {TextColor3 = "StrongText"},
      TextSize = 16,
      Font = Enum.Font.GothamBold,
      TextXAlignment = Enum.TextXAlignment.Left
    })

    local notifText = notification:object("TextLabel", {
      Size = UDim2.new(1, -20, 0, 45),
      Position = UDim2.fromOffset(10, 30),
      BackgroundTransparency = 1,
      Text = text,
      Theme = {TextColor3 = "WeakText"},
      TextSize = 14,
      TextWrapped = true,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top
    })

    -- Animate notification
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification:tween{Position = UDim2.new(0, 0, 0, 0), Length = 0.3}

    -- Auto remove notification
    spawn(function()
      wait(duration)
      notification:tween({Position = UDim2.new(1, 0, 0, 0), Length = 0.3}, function()
        notification.AbsoluteObject:Destroy()
      end)
    end)
  end

  -- TAB CREATION (Mercury style)
  function Window:tab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "rbxassetid://7734053426"

    -- Tab button (Mercury style design)
    local tabButton = Ruvex:object("TextButton", {
      Parent = tabContainer,
      Size = UDim2.new(1, 0, 0, 35),
      Theme = {BackgroundColor3 = "Secondary"},
      Text = ""
    }):round(6)

    local tabIcon_img = tabButton:object("ImageLabel", {
      Size = UDim2.fromOffset(16, 16),
      Position = UDim2.fromOffset(10, 9.5),
      BackgroundTransparency = 1,
      Image = tabIcon,
      Theme = {ImageColor3 = "WeakText"}
    })

    local tabLabel = tabButton:object("TextLabel", {
      Size = UDim2.new(1, -35, 1, 0),
      Position = UDim2.fromOffset(35, 0),
      BackgroundTransparency = 1,
      Text = tabName,
      Theme = {TextColor3 = "WeakText"},
      TextSize = 14,
      Font = Enum.Font.Gotham,
      TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tab content frame
    local tabContent = Ruvex:object("ScrollingFrame", {
      Parent = pageContainer,
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      ScrollBarThickness = 3,
      Theme = {ScrollBarImageColor3 = "Tertiary"},
      Visible = false,
      CanvasSize = UDim2.new(0, 0, 0, 0),
      AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local contentLayout = tabContent:object("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 8)
    })

    local contentPadding = tabContent:object("UIPadding", {
      PaddingTop = UDim.new(0, 15),
      PaddingBottom = UDim.new(0, 15),
      PaddingLeft = UDim.new(0, 15),
      PaddingRight = UDim.new(0, 15)
    })

    -- Tab functionality
    local function selectTab()
      -- Deselect all tabs
      for _, tab in pairs(self.tabs) do
        tab.content.Visible = false
        tab.button:tween{Theme = {BackgroundColor3 = "Secondary"}}
        tab.icon:tween{Theme = {ImageColor3 = "WeakText"}}
        tab.label:tween{Theme = {TextColor3 = "WeakText"}}
      end

      -- Select this tab
      tabContent.Visible = true
      tabButton:tween{Theme = {BackgroundColor3 = "Tertiary"}}
      tabIcon_img:tween{Theme = {ImageColor3 = "StrongText"}}
      tabLabel:tween{Theme = {TextColor3 = "StrongText"}}
      self.selectedTab = Tab
    end

    tabButton.MouseButton1Click:Connect(selectTab)

    -- Hover effects (Criminality style)
    tabButton.MouseEnter:Connect(function()
      if self.selectedTab ~= Tab then
        tabButton:tween{Theme = {BackgroundColor3 = {"Tertiary", -20}}, Length = 0.15}
      end
    end)

    tabButton.MouseLeave:Connect(function()
      if self.selectedTab ~= Tab then
        tabButton:tween{Theme = {BackgroundColor3 = "Secondary"}, Length = 0.15}
      end
    end)

    local Tab = {
      name = tabName,
      button = tabButton,
      content = tabContent,
      icon = tabIcon_img,
      label = tabLabel,
      elements = {}
    }

    table.insert(self.tabs, Tab)

    -- Select first tab automatically
    if #self.tabs == 1 then
      selectTab()
    end

    -- TAB ELEMENT FUNCTIONS
    function Tab:section(options)
      options = options or {}
      local sectionName = options.Name or "Section"

      local section = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1
      })

      local sectionLabel = section:object("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = sectionName,
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local divider = section:object("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        Theme = {BackgroundColor3 = "Tertiary"},
        BorderSizePixel = 0
      })

      return section
    end

    function Tab:toggle(options)
      options = options or {}
      local toggleName = options.Name or "Toggle"
      local toggleDesc = options.Description or ""
      local startingState = options.StartingState or false
      local callback = options.Callback or function() end

      local toggle = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, toggleDesc ~= "" and 50 or 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local toggleButton = toggle:object("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
      })

      local toggleNameLabel = toggle:object("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        Position = UDim2.fromOffset(15, toggleDesc ~= "" and 5 or 8),
        BackgroundTransparency = 1,
        Text = toggleName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      if toggleDesc ~= "" then
        local toggleDescLabel = toggle:object("TextLabel", {
          Size = UDim2.new(1, -60, 0, 16),
          Position = UDim2.fromOffset(15, 25),
          BackgroundTransparency = 1,
          Text = toggleDesc,
          Theme = {TextColor3 = "WeakText"},
          TextSize = 12,
          TextXAlignment = Enum.TextXAlignment.Left
        })
      end

      -- Toggle switch (Cerberus style)
      local switchBG = toggle:object("Frame", {
        Size = UDim2.fromOffset(40, 20),
        Position = UDim2.new(1, -55, 0.5, -10),
        Theme = {BackgroundColor3 = startingState and "Tertiary" or "Main"}
      }):round(10)

      local switchKnob = switchBG:object("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(startingState and 22 or 2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      }):round(8)

      local toggled = startingState
      Ruvex.Flags[toggleName] = toggled

      local function updateToggle()
        toggled = not toggled
        Ruvex.Flags[toggleName] = toggled

        switchBG:tween{
          Theme = {BackgroundColor3 = toggled and "Tertiary" or "Main"},
          Length = 0.2
        }

        switchKnob:tween{
          Position = UDim2.fromOffset(toggled and 22 or 2, 2),
          Length = 0.2
        }

        callback(toggled)
      end

      toggleButton.MouseButton1Click:Connect(updateToggle)

      -- Hover effect
      toggleButton.MouseEnter:Connect(function()
        toggle:tween{Theme = {BackgroundColor3 = {"Secondary", 10}}, Length = 0.15}
      end)

      toggleButton.MouseLeave:Connect(function()
        toggle:tween{Theme = {BackgroundColor3 = "Secondary"}, Length = 0.15}
      end)

      local toggleObj = {
        SetState = function(self, state)
          if toggled ~= state then
            updateToggle()
          end
        end
      }

      return toggleObj
    end

    function Tab:button(options)
      options = options or {}
      local buttonName = options.Name or "Button"
      local buttonDesc = options.Description or ""
      local callback = options.Callback or function() end

      local button = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, buttonDesc ~= "" and 50 or 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local buttonClick = button:object("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
      })

      local buttonNameLabel = button:object("TextLabel", {
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.fromOffset(15, buttonDesc ~= "" and 5 or 8),
        BackgroundTransparency = 1,
        Text = buttonName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      if buttonDesc ~= "" then
        local buttonDescLabel = button:object("TextLabel", {
          Size = UDim2.new(1, -30, 0, 16),
          Position = UDim2.fromOffset(15, 25),
          BackgroundTransparency = 1,
          Text = buttonDesc,
          Theme = {TextColor3 = "WeakText"},
          TextSize = 12,
          TextXAlignment = Enum.TextXAlignment.Left
        })
      end

      buttonClick.MouseButton1Click:Connect(function()
        -- Click animation (Criminality style)
        button:tween{Theme = {BackgroundColor3 = "Tertiary"}, Length = 0.1}
        wait(0.1)
        button:tween{Theme = {BackgroundColor3 = "Secondary"}, Length = 0.1}
        callback()
      end)

      -- Hover effect
      buttonClick.MouseEnter:Connect(function()
        button:tween{Theme = {BackgroundColor3 = {"Secondary", 10}}, Length = 0.15}
      end)

      buttonClick.MouseLeave:Connect(function()
        button:tween{Theme = {BackgroundColor3 = "Secondary"}, Length = 0.15}
      end)

      return button
    end

    function Tab:slider(options)
      options = options or {}
      local sliderName = options.Name or "Slider"
      local min = options.Min or 0
      local max = options.Max or 100
      local default = options.Default or min
      local callback = options.Callback or function() end

      local slider = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 60),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local sliderNameLabel = slider:object("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 20),
        Position = UDim2.fromOffset(15, 8),
        BackgroundTransparency = 1,
        Text = sliderName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local sliderValueLabel = slider:object("TextLabel", {
        Size = UDim2.new(0.3, -15, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
      })

      local sliderTrack = slider:object("Frame", {
        Size = UDim2.new(1, -30, 0, 6),
        Position = UDim2.fromOffset(15, 35),
        Theme = {BackgroundColor3 = "Main"}
      }):round(3)

      local sliderFill = sliderTrack:object("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Theme = {BackgroundColor3 = "Tertiary"}
      }):round(3)

      local sliderKnob = sliderTrack:object("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0, 0.5)
      }):round(6)

      local currentValue = default
      Ruvex.Flags[sliderName] = currentValue

      local dragging = false

      local function updateSlider(input)
        local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * percent)

        sliderValueLabel.Text = tostring(currentValue)
        Ruvex.Flags[sliderName] = currentValue

        sliderFill:tween{Size = UDim2.new(percent, 0, 1, 0), Length = 0.1}
        sliderKnob:tween{Position = UDim2.new(percent, -6, 0.5, -6), Length = 0.1}

        callback(currentValue)
      end

      sliderTrack.InputBegan:Connect(function(input)
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

      local sliderObj = {
        SetValue = function(self, value)
          currentValue = math.clamp(value, min, max)
          local percent = (currentValue - min) / (max - min)

          sliderValueLabel.Text = tostring(currentValue)
          Ruvex.Flags[sliderName] = currentValue

          sliderFill:tween{Size = UDim2.new(percent, 0, 1, 0), Length = 0.2}
          sliderKnob:tween{Position = UDim2.new(percent, -6, 0.5, -6), Length = 0.2}

          callback(currentValue)
        end
      }

      return sliderObj
    end

    function Tab:dropdown(options)
      options = options or {}
      local dropdownName = options.Name or "Dropdown"
      local startingText = options.StartingText or "Select..."
      local items = options.Items or {}
      local callback = options.Callback or function() end

      local dropdown = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local dropdownButton = dropdown:object("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
      })

      local dropdownNameLabel = dropdown:object("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = dropdownName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local dropdownValue = dropdown:object("TextLabel", {
        Size = UDim2.new(0.4, -40, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = startingText,
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
      })

      local dropdownArrow = dropdown:object("TextLabel", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -35, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▼",
        Theme = {TextColor3 = "WeakText"},
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center
      })

      local dropdownList = Ruvex:object("Frame", {
        Parent = dropdown,
        Size = UDim2.new(1, 0, 0, #items * 30),
        Position = UDim2.new(0, 0, 1, 5),
        Theme = {BackgroundColor3 = "Main"},
        Visible = false,
        ZIndex = 10
      }):round(6)

      local listLayout = dropdownList:object("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder
      })

      local isOpen = false
      local selectedValue = nil

      for i, item in ipairs(items) do
        local itemButton = Ruvex:object("TextButton", {
          Parent = dropdownList,
          Size = UDim2.new(1, 0, 0, 30),
          BackgroundTransparency = 1,
          Text = item,
          Theme = {TextColor3 = "StrongText"},
          TextSize = 14,
          TextXAlignment = Enum.TextXAlignment.Left
        })

        local itemPadding = itemButton:object("UIPadding", {
          PaddingLeft = UDim.new(0, 15)
        })

        itemButton.MouseButton1Click:Connect(function()
          selectedValue = item
          dropdownValue.Text = item
          dropdownList.Visible = false
          isOpen = false
          dropdownArrow:tween{Rotation = 0, Length = 0.2}
          Ruvex.Flags[dropdownName] = selectedValue
          callback(selectedValue)
        end)

        itemButton.MouseEnter:Connect(function()
          itemButton:tween{Theme = {BackgroundColor3 = "Tertiary"}, Length = 0.15}
        end)

        itemButton.MouseLeave:Connect(function()
          itemButton:tween{BackgroundTransparency = 1, Length = 0.15}
        end)
      end

      dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        dropdownArrow:tween{Rotation = isOpen and 180 or 0, Length = 0.2}
      end)

      local dropdownObj = {
        Set = function(self, value)
          if table.find(items, value) then
            selectedValue = value
            dropdownValue.Text = value
            Ruvex.Flags[dropdownName] = selectedValue
            callback(selectedValue)
          end
        end
      }

      return dropdownObj
    end

    function Tab:textbox(options)
      options = options or {}
      local textboxName = options.Name or "Textbox"
      local placeholder = options.PlaceholderText or "Enter text..."
      local default = options.Default or ""
      local callback = options.Callback or function() end

      local textbox = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local textboxNameLabel = textbox:object("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = textboxName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local textboxInput = Ruvex:object("TextBox", {
        Parent = textbox,
        Size = UDim2.new(0.6, -30, 0, 25),
        Position = UDim2.new(0.4, 15, 0.5, -12.5),
        Theme = {BackgroundColor3 = "Main", TextColor3 = "StrongText", PlaceholderColor3 = "WeakText"},
        Text = default,
        PlaceholderText = placeholder,
        TextSize = 14,
        ClearTextOnFocus = false
      }):round(4)

      Ruvex.Flags[textboxName] = default

      textboxInput.FocusLost:Connect(function()
        Ruvex.Flags[textboxName] = textboxInput.Text
        callback(textboxInput.Text)
      end)

      local textboxObj = {
        SetText = function(self, text)
          textboxInput.Text = text
          Ruvex.Flags[textboxName] = text
          callback(text)
        end
      }

      return textboxObj
    end

    function Tab:keybind(options)
      options = options or {}
      local keybindName = options.Name or "Keybind"
      local default = options.Default or Enum.KeyCode.F
      local callback = options.Callback or function() end

      local keybind = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local keybindNameLabel = keybind:object("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = keybindName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local keybindButton = Ruvex:object("TextButton", {
        Parent = keybind,
        Size = UDim2.new(0.4, -30, 0, 25),
        Position = UDim2.new(0.6, 15, 0.5, -12.5),
        Theme = {BackgroundColor3 = "Main", TextColor3 = "StrongText"},
        Text = default.Name,
        TextSize = 14
      }):round(4)

      local currentKey = default
      local waiting = false
      Ruvex.Flags[keybindName] = currentKey

      keybindButton.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        keybindButton.Text = "Press key..."

        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keybindButton.Text = currentKey.Name
            Ruvex.Flags[keybindName] = currentKey
            waiting = false
            callback(currentKey)
            connection:Disconnect()
          end
        end)
      end)

      local keybindObj = {
        SetKey = function(self, key)
          currentKey = key
          keybindButton.Text = key.Name
          Ruvex.Flags[keybindName] = key
          callback(key)
        end
      }

      return keybindObj
    end

    function Tab:colorpicker(options)
      options = options or {}
      local colorpickerName = options.Name or "Color Picker"
      local default = options.Default or Color3.fromRGB(255, 0, 0)
      local callback = options.Callback or function() end

      local colorpicker = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      local colorpickerNameLabel = colorpicker:object("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = colorpickerName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local colorDisplay = Ruvex:object("Frame", {
        Parent = colorpicker,
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -40, 0.5, -12.5),
        BackgroundColor3 = default
      }):round(4)

      local colorButton = colorDisplay:object("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
      })

      local currentColor = default
      Ruvex.Flags[colorpickerName] = currentColor

      -- Rainbow option
      local rainbowToggle = false
      local rainbowConnection

      colorButton.MouseButton1Click:Connect(function()
        rainbowToggle = not rainbowToggle

        if rainbowToggle then
          rainbowConnection = RunService.Heartbeat:Connect(function()
            currentColor = Ruvex:GetRainbowColor()
            colorDisplay.BackgroundColor3 = currentColor
            Ruvex.Flags[colorpickerName] = currentColor
            callback(currentColor)
          end)
        else
          if rainbowConnection then
            rainbowConnection:Disconnect()
            rainbowConnection = nil
          end
        end
      end)

      local colorpickerObj = {
        SetColor = function(self, color)
          currentColor = color
          colorDisplay.BackgroundColor3 = color
          Ruvex.Flags[colorpickerName] = color
          callback(color)
        end
      }

      return colorpickerObj
    end

    function Tab:label(options)
      options = options or {}
      local text = options.Text or "Label"

      local label = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1
      })

      local labelText = label:object("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = text,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
      })

      local labelObj = {
        SetText = function(self, newText)
          labelText.Text = newText
        end
      }

      return labelObj
    end

    function Tab:theme_selector()
      local themeSection = self:section({Name = "Theme Settings"})

      local themes = {"Dark", "Red", "Crimson", "Cerberus"}

      local themeDropdown = self:dropdown({
        Name = "Theme",
        StartingText = "Dark",
        Items = themes,
        Callback = function(selected)
          Ruvex:change_theme(Ruvex.Themes[selected])
        end
      })

      local rainbowToggle = self:toggle({
        Name = "Rainbow Mode",
        Description = "Enable rainbow colors",
        StartingState = false,
        Callback = function(state)
          if state then
            -- Rainbow mode logic
            spawn(function()
              while Ruvex.Flags["Rainbow Mode"] do
                Ruvex.CurrentTheme.Tertiary = Ruvex:GetRainbowColor()
                Ruvex:change_theme(Ruvex.CurrentTheme)
                wait(0.1)
              end
            end)
          end
        end
      })

      return {themeDropdown, rainbowToggle}
    end

    return Tab
  end

  return Window
end

-- GLOBAL TOGGLE (Mercury Lib style)
UserInputService.InputBegan:Connect(function(key)
  if key.KeyCode == Ruvex.ToggleKey then
    Ruvex.Toggled = not Ruvex.Toggled

    for _, obj in pairs(CoreGui:GetChildren()) do
      if obj.Name:find("Ruvex") then
        obj.Enabled = Ruvex.Toggled
      end
    end
  end
end)

-- DESTRUCTION CLEANUP
if getgenv and getgenv().RuvexDestroy then
  getgenv().RuvexDestroy()
  getgenv().RuvexDestroy = nil
end

getgenv().RuvexDestroy = function()
  for _, obj in pairs(CoreGui:GetChildren()) do
    if obj.Name:find("Ruvex") then
      obj:Destroy()
    end
  end
end

return Ruvex
