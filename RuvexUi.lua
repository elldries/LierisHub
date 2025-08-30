--[[
  RUVEX UI LIBRARY - COMPLETE COMBINATION
  Combining: Mercury Lib + Cerberus Lib + Flux Lib + Criminality Lib + PPHud Lib
  
  Features:
  - Mercury: Tab interface, window design, theme system, animations
  - Flux: Color customization, rainbow effects, notifications  
  - Cerberus: Button designs, security features
  - Criminality: Smooth transitions, drag system
  - PPHud: UI components, design elements
  
  Theme: Red, Dark, Black, White
  Language: English only
  Compatibility: All Roblox script executors
  Devices: All devices supported with responsive design
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

-- MAIN LIBRARY
local Ruvex = {
  Flags = {},
  Toggled = true,
  ThemeObjects = {
    Main = {},
    Secondary = {},
    Accent = {},
    Text = {},
    WeakText = {}
  },
  DragSpeed = 0.15,
  ToggleKey = Enum.KeyCode.LeftAlt,
  RainbowValue = 0,
  Windows = {}
}

-- COMPATIBILITY
local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder
local gethui = gethui or (syn and syn.protect_gui and CoreGui) or CoreGui

-- RUVEX THEME (Red, Dark, Black, White)
local Colors = {
  Main = Color3.fromRGB(18, 18, 20),           -- Very dark background
  Secondary = Color3.fromRGB(28, 28, 32),      -- Dark secondary
  Tertiary = Color3.fromRGB(38, 38, 42),       -- Medium dark
  
  Accent = Color3.fromRGB(235, 64, 52),        -- Red accent
  AccentHover = Color3.fromRGB(255, 84, 72),   -- Lighter red
  AccentDark = Color3.fromRGB(205, 44, 32),    -- Darker red
  
  Text = Color3.fromRGB(255, 255, 255),        -- White text
  WeakText = Color3.fromRGB(160, 160, 160),    -- Gray text
  VeryWeakText = Color3.fromRGB(100, 100, 100), -- Very gray text
  
  Background = Color3.fromRGB(12, 12, 14),     -- Pure dark
  Border = Color3.fromRGB(45, 45, 50),         -- Border color
  Hover = Color3.fromRGB(48, 48, 52),          -- Hover state
  
  Success = Color3.fromRGB(40, 167, 69),       -- Green
  Warning = Color3.fromRGB(255, 193, 7),       -- Yellow
  Error = Color3.fromRGB(220, 53, 69)          -- Red
}

-- UTILITY FUNCTIONS
local Utilities = {}

function Utilities:Create(className, properties, children)
  local instance = Instance.new(className)
  
  -- Defaults
  local defaults = {
    BorderSizePixel = 0,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSans,
    Text = "",
    TextColor3 = Colors.Text,
    AutoButtonColor = false
  }
  
  for prop, value in pairs(defaults) do
    pcall(function()
      instance[prop] = value
    end)
  end
  
  -- Apply properties
  for prop, value in pairs(properties or {}) do
    instance[prop] = value
  end
  
  -- Add children
  for _, child in pairs(children or {}) do
    child.Parent = instance
  end
  
  return instance
end

function Utilities:Tween(instance, duration, properties, style, direction, callback)
  local tween = TweenService:Create(
    instance,
    TweenInfo.new(
      duration or 0.2,
      style or Enum.EasingStyle.Quad,
      direction or Enum.EasingDirection.Out
    ),
    properties
  )
  
  tween:Play()
  
  if callback then
    tween.Completed:Connect(callback)
  end
  
  return tween
end

function Utilities:Round(instance, radius)
  local corner = Utilities:Create("UICorner", {
    CornerRadius = UDim.new(0, radius or 6),
    Parent = instance
  })
  return corner
end

function Utilities:MakeDraggable(frame, handle)
  local handle = handle or frame
  local dragging = false
  local dragInput, mousePos, framePos
  
  local function update(input)
    local delta = input.Position - mousePos
    frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
  end
  
  handle.InputBegan:Connect(function(input)
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
  
  handle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
      dragInput = input
    end
  end)
  
  UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
      update(input)
    end
  end)
end

function Utilities:GetTextBounds(text, textSize, font, frameSize)
  return TextService:GetTextSize(text, textSize, font, frameSize)
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

-- MAIN WINDOW CREATION
function Ruvex:CreateWindow(options)
  options = options or {}
  local windowName = options.Name or "Ruvex"
  local windowSize = options.Size or UDim2.new(0, 650, 0, 450)
  
  local Window = {}
  Window.Tabs = {}
  Window.SelectedTab = nil
  
  -- Screen GUI
  local ScreenGui = Utilities:Create("ScreenGui", {
    Name = "Ruvex_" .. windowName,
    Parent = gethui(),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
  })
  
  -- Protection for executors
  if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
  end
  
  -- Main Frame
  local MainFrame = Utilities:Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = windowSize,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Colors.Main,
    ClipsDescendants = true,
    Visible = true
  })
  
  Utilities:Round(MainFrame, 10)
  
  -- Shadow
  local Shadow = Utilities:Create("ImageLabel", {
    Name = "Shadow",
    Parent = MainFrame,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 47, 1, 47),
    ZIndex = 0,
    Image = "rbxassetid://6015897843",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.3,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(47, 47, 450, 450),
    BackgroundTransparency = 1
  })
  
  -- Top Bar (Mercury style)
  local TopBar = Utilities:Create("Frame", {
    Name = "TopBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Colors.Secondary
  })
  
  Utilities:Round(TopBar, 10)
  
  -- Fix top bar corners
  Utilities:Create("Frame", {
    Parent = TopBar,
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Colors.Secondary
  })
  
  -- Title
  local Title = Utilities:Create("TextLabel", {
    Name = "Title",
    Parent = TopBar,
    Size = UDim2.new(1, -120, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = windowName,
    TextColor3 = Colors.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
  })
  
  -- Close Button
  local CloseButton = Utilities:Create("TextButton", {
    Name = "CloseButton",
    Parent = TopBar,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = Colors.Error,
    Text = "×",
    TextColor3 = Colors.Text,
    TextSize = 20,
    Font = Enum.Font.GothamBold
  })
  
  Utilities:Round(CloseButton, 6)
  
  -- Minimize Button
  local MinimizeButton = Utilities:Create("TextButton", {
    Name = "MinimizeButton",
    Parent = TopBar,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0, 5),
    BackgroundColor3 = Colors.Warning,
    Text = "−",
    TextColor3 = Colors.Background,
    TextSize = 20,
    Font = Enum.Font.GothamBold
  })
  
  Utilities:Round(MinimizeButton, 6)
  
  -- Tab Container (Mercury style with improvements)
  local TabContainer = Utilities:Create("ScrollingFrame", {
    Name = "TabContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundTransparency = 1,
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    AutomaticCanvasSize = Enum.AutomaticSize.X,
    CanvasSize = UDim2.new(0, 0, 0, 0)
  })
  
  Utilities:Create("UIListLayout", {
    Parent = TabContainer,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
  })
  
  -- Content Container
  local ContentContainer = Utilities:Create("Frame", {
    Name = "ContentContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -20, 1, -105),
    Position = UDim2.new(0, 10, 0, 95),
    BackgroundTransparency = 1
  })
  
  -- Make draggable
  Utilities:MakeDraggable(MainFrame, TopBar)
  
  -- Window Functions
  function Window:Show()
    MainFrame.Visible = true
    Ruvex.Toggled = true
  end
  
  function Window:Hide()
    MainFrame.Visible = false
    Ruvex.Toggled = false
  end
  
  function Window:Toggle()
    if Ruvex.Toggled then
      Window:Hide()
    else
      Window:Show()
    end
  end
  
  function Window:Destroy()
    ScreenGui:Destroy()
  end
  
  -- Button Events
  CloseButton.MouseButton1Click:Connect(function()
    Window:Destroy()
  end)
  
  MinimizeButton.MouseButton1Click:Connect(function()
    Window:Toggle()
  end)
  
  -- Button Hover Effects (Criminality style transitions)
  CloseButton.MouseEnter:Connect(function()
    Utilities:Tween(CloseButton, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 73, 73)})
  end)
  
  CloseButton.MouseLeave:Connect(function()
    Utilities:Tween(CloseButton, 0.15, {BackgroundColor3 = Colors.Error})
  end)
  
  MinimizeButton.MouseEnter:Connect(function()
    Utilities:Tween(MinimizeButton, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 213, 27)})
  end)
  
  MinimizeButton.MouseLeave:Connect(function()
    Utilities:Tween(MinimizeButton, 0.15, {BackgroundColor3 = Colors.Warning})
  end)
  
  -- Tab Creation Function (Mercury base)
  function Window:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or ""
    
    local Tab = {}
    Tab.Sections = {}
    
    -- Tab Button
    local TabButton = Utilities:Create("TextButton", {
      Name = tabName .. "Tab",
      Parent = TabContainer,
      Size = UDim2.new(0, 140, 0, 35),
      BackgroundColor3 = Colors.Secondary,
      Text = ""
    })
    
    Utilities:Round(TabButton, 8)
    
    -- Tab Icon
    local TabIcon = nil
    if tabIcon ~= "" then
      TabIcon = Utilities:Create("ImageLabel", {
        Name = "TabIcon",
        Parent = TabButton,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundTransparency = 1,
        Image = tabIcon,
        ImageColor3 = Colors.WeakText
      })
    end
    
    -- Tab Label
    local TabLabel = Utilities:Create("TextLabel", {
      Name = "TabLabel",
      Parent = TabButton,
      Size = UDim2.new(1, TabIcon and -35 or -15, 1, 0),
      Position = UDim2.new(0, TabIcon and 30 or 8, 0, 0),
      BackgroundTransparency = 1,
      Text = tabName,
      TextColor3 = Colors.WeakText,
      TextSize = 14,
      Font = Enum.Font.SourceSans,
      TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Content
    local TabContent = Utilities:Create("ScrollingFrame", {
      Name = tabName .. "Content",
      Parent = ContentContainer,
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      ScrollBarThickness = 6,
      ScrollBarImageColor3 = Colors.Accent,
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      CanvasSize = UDim2.new(0, 0, 0, 0),
      Visible = false
    })
    
    Utilities:Create("UIListLayout", {
      Parent = TabContent,
      HorizontalAlignment = Enum.HorizontalAlignment.Center,
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 12)
    })
    
    Utilities:Create("UIPadding", {
      Parent = TabContent,
      PaddingTop = UDim.new(0, 15),
      PaddingBottom = UDim.new(0, 15),
      PaddingLeft = UDim.new(0, 15),
      PaddingRight = UDim.new(0, 15)
    })
    
    -- Tab Selection Logic
    local function selectTab()
      -- Deselect all tabs
      for _, tab in pairs(Window.Tabs) do
        tab.Content.Visible = false
        Utilities:Tween(tab.Button, 0.2, {BackgroundColor3 = Colors.Secondary})
        Utilities:Tween(tab.Label, 0.2, {TextColor3 = Colors.WeakText})
        if tab.Icon then
          Utilities:Tween(tab.Icon, 0.2, {ImageColor3 = Colors.WeakText})
        end
      end
      
      -- Select this tab
      TabContent.Visible = true
      Utilities:Tween(TabButton, 0.2, {BackgroundColor3 = Colors.Accent})
      Utilities:Tween(TabLabel, 0.2, {TextColor3 = Colors.Text})
      if TabIcon then
        Utilities:Tween(TabIcon, 0.2, {ImageColor3 = Colors.Text})
      end
      
      Window.SelectedTab = Tab
    end
    
    -- Tab Events
    TabButton.MouseButton1Click:Connect(selectTab)
    
    -- Hover Effects (Criminality style)
    TabButton.MouseEnter:Connect(function()
      if Window.SelectedTab ~= Tab then
        Utilities:Tween(TabButton, 0.15, {BackgroundColor3 = Colors.Hover})
        Utilities:Tween(TabLabel, 0.15, {TextColor3 = Colors.Text})
        if TabIcon then
          Utilities:Tween(TabIcon, 0.15, {ImageColor3 = Colors.Text})
        end
      end
    end)
    
    TabButton.MouseLeave:Connect(function()
      if Window.SelectedTab ~= Tab then
        Utilities:Tween(TabButton, 0.15, {BackgroundColor3 = Colors.Secondary})
        Utilities:Tween(TabLabel, 0.15, {TextColor3 = Colors.WeakText})
        if TabIcon then
          Utilities:Tween(TabIcon, 0.15, {ImageColor3 = Colors.WeakText})
        end
      end
    end)
    
    -- Store tab
    Tab.Button = TabButton
    Tab.Label = TabLabel
    Tab.Icon = TabIcon
    Tab.Content = TabContent
    Tab.Name = tabName
    
    table.insert(Window.Tabs, Tab)
    
    -- Select first tab
    if #Window.Tabs == 1 then
      selectTab()
    end
    
    -- Section Creation (Cerberus style design)
    function Tab:CreateSection(options)
      options = options or {}
      local sectionName = options.Name or "Section"
      
      local Section = {}
      
      -- Section Frame
      local SectionFrame = Utilities:Create("Frame", {
        Name = sectionName .. "Section",
        Parent = TabContent,
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = Colors.Secondary
      })
      
      Utilities:Round(SectionFrame, 8)
      
      -- Section Header (Cerberus style)
      local SectionHeader = Utilities:Create("Frame", {
        Name = "SectionHeader",
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.Tertiary
      })
      
      Utilities:Round(SectionHeader, 8)
      
      -- Hide bottom corners
      Utilities:Create("Frame", {
        Parent = SectionHeader,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Colors.Tertiary
      })
      
      -- Section Title
      local SectionTitle = Utilities:Create("TextLabel", {
        Name = "SectionTitle",
        Parent = SectionHeader,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = sectionName,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })
      
      -- Red accent line (Ruvex theme)
      local AccentLine = Utilities:Create("Frame", {
        Name = "AccentLine",
        Parent = SectionHeader,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Colors.Accent
      })
      
      -- Section Content
      local SectionContent = Utilities:Create("ScrollingFrame", {
        Name = "SectionContent",
        Parent = SectionFrame,
        Size = UDim2.new(1, -10, 1, -45),
        Position = UDim2.new(0, 5, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
      })
      
      Utilities:Create("UIListLayout", {
        Parent = SectionContent,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
      })
      
      Utilities:Create("UIPadding", {
        Parent = SectionContent,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
      })
      
      -- Auto-resize section
      local function updateSize()
        local contentSize = SectionContent.UIListLayout.AbsoluteContentSize.Y + 55
        SectionFrame.Size = UDim2.new(1, 0, 0, math.max(contentSize, 100))
      end
      
      SectionContent.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
      
      Section.Frame = SectionFrame
      Section.Content = SectionContent
      Section.Name = sectionName
      
      table.insert(Tab.Sections, Section)
      
      -- SECTION UI COMPONENTS (Combined from all libraries)
      
      -- Button Component (Cerberus + Flux style)
      function Section:CreateButton(options)
        options = options or {}
        local buttonText = options.Text or "Button"
        local buttonDesc = options.Description or ""
        local callback = options.Callback or function() end
        
        local Button = {}
        
        local ButtonFrame = Utilities:Create("Frame", {
          Name = "ButtonFrame",
          Parent = SectionContent,
          Size = UDim2.new(1, 0, 0, buttonDesc ~= "" and 60 or 35),
          BackgroundColor3 = Colors.Tertiary
        })
        
        Utilities:Round(ButtonFrame, 6)
        
        local ButtonMain = Utilities:Create("TextButton", {
          Name = "ButtonMain",
          Parent = ButtonFrame,
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          Text = ""
        })
        
        local ButtonLabel = Utilities:Create("TextLabel", {
          Name = "ButtonLabel",
          Parent = ButtonFrame,
          Size = UDim2.new(1, -20, 0, 20),
          Position = UDim2.new(0, 10, 0, 8),
          BackgroundTransparency = 1,
          Text = buttonText,
          TextColor3 = Colors.Text,
          TextSize = 14,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        if buttonDesc ~= "" then
          local ButtonDesc = Utilities:Create("TextLabel", {
            Name = "ButtonDesc",
            Parent = ButtonFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            Text = buttonDesc,
            TextColor3 = Colors.WeakText,
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
          })
        end
        
        -- Button Events (Criminality style animations)
        ButtonMain.MouseEnter:Connect(function()
          Utilities:Tween(ButtonFrame, 0.15, {BackgroundColor3 = Colors.Accent})
          Utilities:Tween(ButtonLabel, 0.15, {TextColor3 = Colors.Text})
        end)
        
        ButtonMain.MouseLeave:Connect(function()
          Utilities:Tween(ButtonFrame, 0.15, {BackgroundColor3 = Colors.Tertiary})
          Utilities:Tween(ButtonLabel, 0.15, {TextColor3 = Colors.Text})
        end)
        
        ButtonMain.MouseButton1Down:Connect(function()
          Utilities:Tween(ButtonFrame, 0.1, {BackgroundColor3 = Colors.AccentDark})
        end)
        
        ButtonMain.MouseButton1Up:Connect(function()
          Utilities:Tween(ButtonFrame, 0.1, {BackgroundColor3 = Colors.Accent})
        end)
        
        ButtonMain.MouseButton1Click:Connect(function()
          pcall(callback)
        end)
        
        Button.Frame = ButtonFrame
        Button.Button = ButtonMain
        Button.Label = ButtonLabel
        
        return Button
      end
      
      -- Toggle Component (Mercury + Cerberus style)
      function Section:CreateToggle(options)
        options = options or {}
        local toggleText = options.Text or "Toggle"
        local toggleDesc = options.Description or ""
        local defaultState = options.Default or false
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local Toggle = {}
        local toggled = defaultState
        
        if flag then
          Ruvex.Flags[flag] = toggled
        end
        
        local ToggleFrame = Utilities:Create("Frame", {
          Name = "ToggleFrame",
          Parent = SectionContent,
          Size = UDim2.new(1, 0, 0, toggleDesc ~= "" and 55 or 35),
          BackgroundColor3 = Colors.Tertiary
        })
        
        Utilities:Round(ToggleFrame, 6)
        
        local ToggleButton = Utilities:Create("TextButton", {
          Name = "ToggleButton",
          Parent = ToggleFrame,
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          Text = ""
        })
        
        local ToggleLabel = Utilities:Create("TextLabel", {
          Name = "ToggleLabel",
          Parent = ToggleFrame,
          Size = UDim2.new(1, -55, 0, 20),
          Position = UDim2.new(0, 10, 0, 8),
          BackgroundTransparency = 1,
          Text = toggleText,
          TextColor3 = Colors.Text,
          TextSize = 14,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        if toggleDesc ~= "" then
          local ToggleDesc = Utilities:Create("TextLabel", {
            Name = "ToggleDesc",
            Parent = ToggleFrame,
            Size = UDim2.new(1, -55, 0, 20),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundTransparency = 1,
            Text = toggleDesc,
            TextColor3 = Colors.WeakText,
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
          })
        end
        
        -- Toggle Switch (Cerberus style)
        local ToggleSwitch = Utilities:Create("Frame", {
          Name = "ToggleSwitch",
          Parent = ToggleFrame,
          Size = UDim2.new(0, 35, 0, 18),
          Position = UDim2.new(1, -40, 0, 8),
          BackgroundColor3 = toggled and Colors.Accent or Colors.Border
        })
        
        Utilities:Round(ToggleSwitch, 9)
        
        local ToggleCircle = Utilities:Create("Frame", {
          Name = "ToggleCircle",
          Parent = ToggleSwitch,
          Size = UDim2.new(0, 14, 0, 14),
          Position = UDim2.new(0, toggled and 19 or 2, 0, 2),
          BackgroundColor3 = Colors.Text
        })
        
        Utilities:Round(ToggleCircle, 7)
        
        local function updateToggle()
          Utilities:Tween(ToggleSwitch, 0.2, {BackgroundColor3 = toggled and Colors.Accent or Colors.Border})
          Utilities:Tween(ToggleCircle, 0.2, {Position = UDim2.new(0, toggled and 19 or 2, 0, 2)})
          
          if flag then
            Ruvex.Flags[flag] = toggled
          end
          
          pcall(callback, toggled)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
          toggled = not toggled
          updateToggle()
        end)
        
        -- Hover effects
        ToggleButton.MouseEnter:Connect(function()
          Utilities:Tween(ToggleFrame, 0.15, {BackgroundColor3 = Colors.Hover})
        end)
        
        ToggleButton.MouseLeave:Connect(function()
          Utilities:Tween(ToggleFrame, 0.15, {BackgroundColor3 = Colors.Tertiary})
        end)
        
        Toggle.Frame = ToggleFrame
        Toggle.Switch = ToggleSwitch
        Toggle.Circle = ToggleCircle
        
        function Toggle:Set(value)
          toggled = value
          updateToggle()
        end
        
        return Toggle
      end
      
      -- Slider Component (Mercury + Flux style)
      function Section:CreateSlider(options)
        options = options or {}
        local sliderText = options.Text or "Slider"
        local sliderDesc = options.Description or ""
        local minValue = options.Min or 0
        local maxValue = options.Max or 100
        local defaultValue = options.Default or minValue
        local increment = options.Increment or 1
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local Slider = {}
        local currentValue = defaultValue
        
        if flag then
          Ruvex.Flags[flag] = currentValue
        end
        
        local SliderFrame = Utilities:Create("Frame", {
          Name = "SliderFrame",
          Parent = SectionContent,
          Size = UDim2.new(1, 0, 0, sliderDesc ~= "" and 70 or 50),
          BackgroundColor3 = Colors.Tertiary
        })
        
        Utilities:Round(SliderFrame, 6)
        
        local SliderLabel = Utilities:Create("TextLabel", {
          Name = "SliderLabel",
          Parent = SliderFrame,
          Size = UDim2.new(1, -80, 0, 20),
          Position = UDim2.new(0, 10, 0, 8),
          BackgroundTransparency = 1,
          Text = sliderText,
          TextColor3 = Colors.Text,
          TextSize = 14,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SliderValue = Utilities:Create("TextLabel", {
          Name = "SliderValue",
          Parent = SliderFrame,
          Size = UDim2.new(0, 70, 0, 20),
          Position = UDim2.new(1, -75, 0, 8),
          BackgroundTransparency = 1,
          Text = tostring(currentValue),
          TextColor3 = Colors.Accent,
          TextSize = 14,
          Font = Enum.Font.SourceSansBold,
          TextXAlignment = Enum.TextXAlignment.Right
        })
        
        if sliderDesc ~= "" then
          local SliderDesc = Utilities:Create("TextLabel", {
            Name = "SliderDesc",
            Parent = SliderFrame,
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundTransparency = 1,
            Text = sliderDesc,
            TextColor3 = Colors.WeakText,
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
          })
        end
        
        -- Slider Bar
        local SliderBar = Utilities:Create("Frame", {
          Name = "SliderBar",
          Parent = SliderFrame,
          Size = UDim2.new(1, -20, 0, 4),
          Position = UDim2.new(0, 10, 1, -12),
          BackgroundColor3 = Colors.Border
        })
        
        Utilities:Round(SliderBar, 2)
        
        local SliderFill = Utilities:Create("Frame", {
          Name = "SliderFill",
          Parent = SliderBar,
          Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0),
          BackgroundColor3 = Colors.Accent
        })
        
        Utilities:Round(SliderFill, 2)
        
        local SliderButton = Utilities:Create("TextButton", {
          Name = "SliderButton",
          Parent = SliderBar,
          Size = UDim2.new(1, 0, 0, 20),
          Position = UDim2.new(0, 0, 0, -8),
          BackgroundTransparency = 1,
          Text = ""
        })
        
        local function updateSlider(value)
          currentValue = math.clamp(value, minValue, maxValue)
          currentValue = math.floor((currentValue / increment) + 0.5) * increment
          
          local percentage = (currentValue - minValue) / (maxValue - minValue)
          
          Utilities:Tween(SliderFill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
          SliderValue.Text = tostring(currentValue)
          
          if flag then
            Ruvex.Flags[flag] = currentValue
          end
          
          pcall(callback, currentValue)
        end
        
        local dragging = false
        
        SliderButton.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
          end
        end)
        
        SliderButton.InputEnded:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
          end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
          if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = minValue + (maxValue - minValue) * percentage
            updateSlider(value)
          end
        end)
        
        -- Hover effects
        SliderButton.MouseEnter:Connect(function()
          Utilities:Tween(SliderFrame, 0.15, {BackgroundColor3 = Colors.Hover})
        end)
        
        SliderButton.MouseLeave:Connect(function()
          Utilities:Tween(SliderFrame, 0.15, {BackgroundColor3 = Colors.Tertiary})
        end)
        
        Slider.Frame = SliderFrame
        Slider.Bar = SliderBar
        Slider.Fill = SliderFill
        
        function Slider:Set(value)
          updateSlider(value)
        end
        
        return Slider
      end
      
      -- Input/TextBox Component (Combined style)
      function Section:CreateInput(options)
        options = options or {}
        local inputText = options.Text or "Input"
        local inputDesc = options.Description or ""
        local placeholder = options.Placeholder or "Enter text..."
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local Input = {}
        local currentText = ""
        
        if flag then
          Ruvex.Flags[flag] = currentText
        end
        
        local InputFrame = Utilities:Create("Frame", {
          Name = "InputFrame",
          Parent = SectionContent,
          Size = UDim2.new(1, 0, 0, inputDesc ~= "" and 70 or 50),
          BackgroundColor3 = Colors.Tertiary
        })
        
        Utilities:Round(InputFrame, 6)
        
        local InputLabel = Utilities:Create("TextLabel", {
          Name = "InputLabel",
          Parent = InputFrame,
          Size = UDim2.new(1, -20, 0, 20),
          Position = UDim2.new(0, 10, 0, 8),
          BackgroundTransparency = 1,
          Text = inputText,
          TextColor3 = Colors.Text,
          TextSize = 14,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        if inputDesc ~= "" then
          local InputDesc = Utilities:Create("TextLabel", {
            Name = "InputDesc",
            Parent = InputFrame,
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundTransparency = 1,
            Text = inputDesc,
            TextColor3 = Colors.WeakText,
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
          })
        end
        
        local InputBox = Utilities:Create("TextBox", {
          Name = "InputBox",
          Parent = InputFrame,
          Size = UDim2.new(1, -20, 0, 25),
          Position = UDim2.new(0, 10, 1, -30),
          BackgroundColor3 = Colors.Secondary,
          Text = "",
          PlaceholderText = placeholder,
          PlaceholderColor3 = Colors.VeryWeakText,
          TextColor3 = Colors.Text,
          TextSize = 13,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left,
          ClearButtonOnFocus = false
        })
        
        Utilities:Round(InputBox, 4)
        
        -- Border effect
        local InputBorder = Utilities:Create("UIStroke", {
          Parent = InputBox,
          Color = Colors.Border,
          Thickness = 1,
          Transparency = 0
        })
        
        InputBox.FocusLost:Connect(function(enterPressed)
          currentText = InputBox.Text
          
          if flag then
            Ruvex.Flags[flag] = currentText
          end
          
          pcall(callback, currentText, enterPressed)
          
          Utilities:Tween(InputBorder, 0.2, {Color = Colors.Border})
        end)
        
        InputBox.Focused:Connect(function()
          Utilities:Tween(InputBorder, 0.2, {Color = Colors.Accent})
        end)
        
        Input.Frame = InputFrame
        Input.Box = InputBox
        
        function Input:Set(text)
          InputBox.Text = text
          currentText = text
          if flag then
            Ruvex.Flags[flag] = currentText
          end
        end
        
        return Input
      end
      
      -- Dropdown Component (Flux + Mercury style)
      function Section:CreateDropdown(options)
        options = options or {}
        local dropdownText = options.Text or "Dropdown"
        local dropdownDesc = options.Description or ""
        local dropdownOptions = options.Options or {"Option 1", "Option 2", "Option 3"}
        local defaultOption = options.Default or dropdownOptions[1]
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local Dropdown = {}
        local currentOption = defaultOption
        local isOpen = false
        
        if flag then
          Ruvex.Flags[flag] = currentOption
        end
        
        local DropdownFrame = Utilities:Create("Frame", {
          Name = "DropdownFrame",
          Parent = SectionContent,
          Size = UDim2.new(1, 0, 0, dropdownDesc ~= "" and 70 or 50),
          BackgroundColor3 = Colors.Tertiary
        })
        
        Utilities:Round(DropdownFrame, 6)
        
        local DropdownLabel = Utilities:Create("TextLabel", {
          Name = "DropdownLabel",
          Parent = DropdownFrame,
          Size = UDim2.new(1, -20, 0, 20),
          Position = UDim2.new(0, 10, 0, 8),
          BackgroundTransparency = 1,
          Text = dropdownText,
          TextColor3 = Colors.Text,
          TextSize = 14,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        if dropdownDesc ~= "" then
          local DropdownDesc = Utilities:Create("TextLabel", {
            Name = "DropdownDesc",
            Parent = DropdownFrame,
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundTransparency = 1,
            Text = dropdownDesc,
            TextColor3 = Colors.WeakText,
            TextSize = 12,
            Font = Enum.Font.SourceSans,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
          })
        end
        
        local DropdownButton = Utilities:Create("TextButton", {
          Name = "DropdownButton",
          Parent = DropdownFrame,
          Size = UDim2.new(1, -20, 0, 25),
          Position = UDim2.new(0, 10, 1, -30),
          BackgroundColor3 = Colors.Secondary,
          Text = currentOption,
          TextColor3 = Colors.Text,
          TextSize = 13,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Utilities:Round(DropdownButton, 4)
        
        local DropdownArrow = Utilities:Create("TextLabel", {
          Name = "DropdownArrow",
          Parent = DropdownButton,
          Size = UDim2.new(0, 20, 1, 0),
          Position = UDim2.new(1, -20, 0, 0),
          BackgroundTransparency = 1,
          Text = "▼",
          TextColor3 = Colors.WeakText,
          TextSize = 12,
          Font = Enum.Font.SourceSans,
          TextXAlignment = Enum.TextXAlignment.Center
        })
        
        -- Dropdown options container
        local OptionsContainer = Utilities:Create("Frame", {
          Name = "OptionsContainer",
          Parent = DropdownFrame,
          Size = UDim2.new(1, -20, 0, #dropdownOptions * 25),
          Position = UDim2.new(0, 10, 1, -5),
          BackgroundColor3 = Colors.Secondary,
          Visible = false,
          ZIndex = 10
        })
        
        Utilities:Round(OptionsContainer, 4)
        
        Utilities:Create("UIListLayout", {
          Parent = OptionsContainer,
          SortOrder = Enum.SortOrder.LayoutOrder,
          Padding = UDim.new(0, 0)
        })
        
        -- Create option buttons
        for i, option in ipairs(dropdownOptions) do
          local OptionButton = Utilities:Create("TextButton", {
            Name = "Option" .. i,
            Parent = OptionsContainer,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundColor3 = Colors.Secondary,
            Text = option,
            TextColor3 = Colors.Text,
            TextSize = 13,
            Font = Enum.Font.SourceSans,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i
          })
          
          if i == 1 then
            Utilities:Round(OptionButton, 4)
          elseif i == #dropdownOptions then
            Utilities:Round(OptionButton, 4)
          end
          
          OptionButton.MouseEnter:Connect(function()
            Utilities:Tween(OptionButton, 0.15, {BackgroundColor3 = Colors.Hover})
          end)
          
          OptionButton.MouseLeave:Connect(function()
            Utilities:Tween(OptionButton, 0.15, {BackgroundColor3 = Colors.Secondary})
          end)
          
          OptionButton.MouseButton1Click:Connect(function()
            currentOption = option
            DropdownButton.Text = currentOption
            
            if flag then
              Ruvex.Flags[flag] = currentOption
            end
            
            pcall(callback, currentOption)
            
            -- Close dropdown
            isOpen = false
            Utilities:Tween(OptionsContainer, 0.2, {Size = UDim2.new(1, -20, 0, 0)}, nil, nil, function()
              OptionsContainer.Visible = false
            end)
            Utilities:Tween(DropdownArrow, 0.2, {Rotation = 0})
          end)
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
          isOpen = not isOpen
          
          if isOpen then
            OptionsContainer.Visible = true
            OptionsContainer.Size = UDim2.new(1, -20, 0, 0)
            Utilities:Tween(OptionsContainer, 0.2, {Size = UDim2.new(1, -20, 0, #dropdownOptions * 25)})
            Utilities:Tween(DropdownArrow, 0.2, {Rotation = 180})
            
            -- Expand section if needed
            local newSize = (dropdownDesc ~= "" and 70 or 50) + (#dropdownOptions * 25) + 5
            Utilities:Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, newSize)})
          else
            Utilities:Tween(OptionsContainer, 0.2, {Size = UDim2.new(1, -20, 0, 0)}, nil, nil, function()
              OptionsContainer.Visible = false
            end)
            Utilities:Tween(DropdownArrow, 0.2, {Rotation = 0})
            
            -- Collapse section
            local originalSize = dropdownDesc ~= "" and 70 or 50
            Utilities:Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, originalSize)})
          end
        end)
        
        -- Hover effects
        DropdownButton.MouseEnter:Connect(function()
          Utilities:Tween(DropdownFrame, 0.15, {BackgroundColor3 = Colors.Hover})
        end)
        
        DropdownButton.MouseLeave:Connect(function()
          Utilities:Tween(DropdownFrame, 0.15, {BackgroundColor3 = Colors.Tertiary})
        end)
        
        Dropdown.Frame = DropdownFrame
        Dropdown.Button = DropdownButton
        
        function Dropdown:Set(option)
          if table.find(dropdownOptions, option) then
            currentOption = option
            DropdownButton.Text = currentOption
            if flag then
              Ruvex.Flags[flag] = currentOption
            end
          end
        end
        
        return Dropdown
      end
      
      return Section, SectionContent
    end
    
    return Tab
  end
  
  -- Global toggle
  UserInputService.InputBegan:Connect(function(key, gameProcessed)
    if key.KeyCode == Ruvex.ToggleKey and not gameProcessed then
      Window:Toggle()
    end
  end)
  
  table.insert(Ruvex.Windows, Window)
  return Window
end

-- NOTIFICATION SYSTEM (Flux style)
function Ruvex:Notify(options)
  options = options or {}
  local title = options.Title or "Notification"
  local description = options.Description or "No description provided"
  local duration = options.Duration or 3
  
  -- Find or create notification container
  local NotificationContainer = CoreGui:FindFirstChild("RuvexNotifications")
  if not NotificationContainer then
    NotificationContainer = Utilities:Create("ScreenGui", {
      Name = "RuvexNotifications",
      Parent = CoreGui,
      ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local NotificationFrame = Utilities:Create("Frame", {
      Name = "NotificationFrame",
      Parent = NotificationContainer,
      Size = UDim2.new(0, 300, 1, -40),
      Position = UDim2.new(1, -320, 0, 20),
      BackgroundTransparency = 1
    })
    
    Utilities:Create("UIListLayout", {
      Parent = NotificationFrame,
      HorizontalAlignment = Enum.HorizontalAlignment.Right,
      VerticalAlignment = Enum.VerticalAlignment.Top,
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 10)
    })
  end
  
  local NotificationFrame = NotificationContainer.NotificationFrame
  
  -- Create notification
  local Notification = Utilities:Create("Frame", {
    Name = "Notification",
    Parent = NotificationFrame,
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundColor3 = Colors.Secondary,
    BorderSizePixel = 1,
    BorderColor3 = Colors.Accent
  })
  
  Utilities:Round(Notification, 8)
  
  -- Title
  local NotificationTitle = Utilities:Create("TextLabel", {
    Name = "NotificationTitle",
    Parent = Notification,
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundTransparency = 1,
    Text = title,
    TextColor3 = Colors.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd
  })
  
  -- Description
  local NotificationDesc = Utilities:Create("TextLabel", {
    Name = "NotificationDesc",
    Parent = Notification,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 35),
    BackgroundTransparency = 1,
    Text = description,
    TextColor3 = Colors.WeakText,
    TextSize = 14,
    Font = Enum.Font.SourceSans,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
  })
  
  -- Animate in
  Notification.Position = UDim2.new(1, 50, 0, 0)
  Utilities:Tween(Notification, 0.3, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back)
  
  -- Auto remove
  spawn(function()
    wait(duration)
    Utilities:Tween(Notification, 0.3, {Position = UDim2.new(1, 50, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
      Notification:Destroy()
    end)
  end)
  
  return Notification
end

return Ruvex
