--[[
RUVEX UI LIBRARY - ПОЛНОСТЬЮ ИСПРАВЛЕННАЯ ВЕРСИЯ
База от Mercury Lib и Cerberus Lib
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

-- RUVEX LIBRARY
local Ruvex = {
  Themes = {
    Dark = {
      Main = Color3.fromRGB(25, 25, 30),
      Secondary = Color3.fromRGB(35, 35, 40),
      Tertiary = Color3.fromRGB(255, 50, 50),
      StrongText = Color3.fromRGB(255, 255, 255),
      WeakText = Color3.fromRGB(172, 172, 172)
    }
  },
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
  RainbowValue = 0,
  flags = {}
}

-- Устанавливаем текущую тему
Ruvex.CurrentTheme = Ruvex.Themes.Dark

-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
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

-- СОЗДАНИЕ ОБЪЕКТОВ
function Ruvex:object(class, properties)
  local localObject = Instance.new(class)
  properties = properties or {}

  -- Применяем базовые свойства
  local forcedProps = {
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.SourceSans,
    Text = ""
  }

  for property, value in pairs(forcedProps) do
    pcall(function()
      localObject[property] = value
    end)
  end

  local methods = {}
  methods.AbsoluteObject = localObject

  -- Функция анимации
  function methods:tween(options, callback)
    options = Ruvex:set_defaults({
      Length = 0.2,
      Style = Enum.EasingStyle.Linear,
      Direction = Enum.EasingDirection.InOut
    }, options or {})
    
    callback = callback or function() end

    local ti = TweenInfo.new(options.Length, options.Style, options.Direction)
    local tweenOptions = {}
    
    for k, v in pairs(options) do
      if k ~= "Length" and k ~= "Style" and k ~= "Direction" then
        tweenOptions[k] = v
      end
    end

    local tween = TweenService:Create(localObject, ti, tweenOptions)
    tween:Play()

    tween.Completed:Connect(function()
      callback()
    end)

    return tween
  end

  -- Функция закругления углов
  function methods:round(radius)
    radius = radius or 6
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = localObject
    return methods
  end

  -- Функция создания дочернего объекта
  function methods:object(class, props)
    props = props or {}
    props.Parent = localObject
    return Ruvex:object(class, props)
  end

  -- Обработка специальных свойств
  local customHandlers = {
    Centered = function(value)
      if value then
        localObject.AnchorPoint = Vector2.new(0.5, 0.5)
        localObject.Position = UDim2.fromScale(0.5, 0.5)
      end
    end,
    Theme = function(value)
      for property, obj in pairs(value) do
        if type(obj) == "table" then
          local theme, colorAlter = obj[1], obj[2] or 0
          local themeColor = Ruvex.CurrentTheme[theme]
          if themeColor then
            local modifiedColor = themeColor
            if colorAlter < 0 then
              modifiedColor = Ruvex:darken(themeColor, math.abs(colorAlter))
            elseif colorAlter > 0 then
              modifiedColor = Ruvex:lighten(themeColor, colorAlter)
            end
            localObject[property] = modifiedColor
            table.insert(Ruvex.ThemeObjects[theme], {methods, property, theme, colorAlter})
          end
        else
          local themeColor = Ruvex.CurrentTheme[obj]
          if themeColor then
            localObject[property] = themeColor
            table.insert(Ruvex.ThemeObjects[obj], {methods, property, obj, 0})
          end
        end
      end
    end
  }

  -- Применяем свойства
  for property, value in pairs(properties) do
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

-- RAINBOW ЭФФЕКТ
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

-- СОЗДАНИЕ ГЛАВНОГО ОКНА
function Ruvex:create(options)
  options = self:set_defaults({
    Name = "Ruvex",
    Size = UDim2.fromOffset(600, 400),
    Theme = self.CurrentTheme
  }, options or {})

  self.CurrentTheme = options.Theme

  -- Создание ScreenGui
  local gui = self:object("ScreenGui", {
    Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
  })

  -- Holder для уведомлений
  local notificationHolder = gui:object("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -30, 1, -30),
    Size = UDim2.new(0, 300, 1, -60)
  })

  notificationHolder:object("UIListLayout", {
    Padding = UDim.new(0, 20),
    VerticalAlignment = Enum.VerticalAlignment.Bottom
  })

  -- Главный фрейм
  local core = gui:object("Frame", {
    Size = UDim2.new(),
    Theme = {BackgroundColor3 = "Main"},
    Centered = true,
    ClipsDescendants = true
  }):round(10)

  -- Анимация появления
  core:tween({Size = options.Size, Length = 0.3}, function()
    core.ClipsDescendants = false
  end)

  -- Система перетаскивания
  local function makeDraggable(frame, handle)
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

  -- Заголовок
  local titleBar = core:object("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 0, 0)
  }):round(10)

  -- Скрываем нижние углы заголовка
  titleBar:object("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 10)
  })

  -- Красная полоска
  titleBar:object("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Theme = {BackgroundColor3 = "Tertiary"},
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 2)
  })

  -- Название
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

  -- Кнопка закрытия
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
    core:tween({Size = UDim2.new()}, function()
      gui.AbsoluteObject:Destroy()
    end)
  end)

  -- Делаем окно перетаскиваемым
  makeDraggable(core, titleBar)

  -- Область контента
  local contentFrame = core:object("Frame", {
    Position = UDim2.new(0, 0, 0, 35),
    Size = UDim2.new(1, 0, 1, -35),
    BackgroundTransparency = 1
  })

  -- Контейнер вкладок
  local tabContainer = contentFrame:object("Frame", {
    Size = UDim2.new(0, 150, 1, 0),
    Theme = {BackgroundColor3 = "Secondary"},
    Position = UDim2.new(0, 0, 0, 0)
  })

  tabContainer:object("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5)
  })

  tabContainer:object("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
  })

  -- Контейнер страниц
  local pageContainer = contentFrame:object("Frame", {
    Position = UDim2.new(0, 150, 0, 0),
    Size = UDim2.new(1, -150, 1, 0),
    BackgroundTransparency = 1
  })

  local Window = {
    gui = gui,
    core = core,
    tabs = {},
    selectedTab = nil,
    notificationHolder = notificationHolder
  }

  -- СИСТЕМА УВЕДОМЛЕНИЙ
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

    notification:object("TextLabel", {
      Size = UDim2.new(1, -20, 0, 25),
      Position = UDim2.fromOffset(10, 5),
      BackgroundTransparency = 1,
      Text = title,
      Theme = {TextColor3 = "StrongText"},
      TextSize = 16,
      Font = Enum.Font.GothamBold,
      TextXAlignment = Enum.TextXAlignment.Left
    })

    notification:object("TextLabel", {
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

    -- Анимация появления
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification:tween({Position = UDim2.new(0, 0, 0, 0), Length = 0.3})

    -- Автоматическое удаление
    spawn(function()
      wait(duration)
      notification:tween({Position = UDim2.new(1, 0, 0, 0), Length = 0.3}, function()
        notification.AbsoluteObject:Destroy()
      end)
    end)
  end

  -- СОЗДАНИЕ ВКЛАДОК
  function Window:tab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or ""

    -- Кнопка вкладки
    local tabButton = Ruvex:object("TextButton", {
      Parent = tabContainer,
      Size = UDim2.new(1, 0, 0, 35),
      Theme = {BackgroundColor3 = "Secondary"},
      Text = ""
    }):round(6)

    -- Иконка вкладки
    local tabIcon_img = nil
    if tabIcon ~= "" then
      tabIcon_img = tabButton:object("ImageLabel", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(10, 9.5),
        BackgroundTransparency = 1,
        Image = tabIcon,
        Theme = {ImageColor3 = "WeakText"}
      })
    end

    -- Текст вкладки
    local tabLabel = tabButton:object("TextLabel", {
      Size = UDim2.new(1, tabIcon_img and -35 or -15, 1, 0),
      Position = UDim2.fromOffset(tabIcon_img and 35 or 10, 0),
      BackgroundTransparency = 1,
      Text = tabName,
      Theme = {TextColor3 = "WeakText"},
      TextSize = 14,
      Font = Enum.Font.Gotham,
      TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Контент вкладки
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

    tabContent:object("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 8)
    })

    tabContent:object("UIPadding", {
      PaddingTop = UDim.new(0, 15),
      PaddingBottom = UDim.new(0, 15),
      PaddingLeft = UDim.new(0, 15),
      PaddingRight = UDim.new(0, 15)
    })

    -- Логика выбора вкладки
    local function selectTab()
      -- Снять выделение со всех вкладок
      for _, tab in pairs(self.tabs) do
        tab.content.Visible = false
        tab.button:tween({Theme = {BackgroundColor3 = "Secondary"}})
        tab.label:tween({Theme = {TextColor3 = "WeakText"}})
        if tab.icon then
          tab.icon:tween({Theme = {ImageColor3 = "WeakText"}})
        end
      end

      -- Выбрать эту вкладку
      tabContent.Visible = true
      tabButton:tween({Theme = {BackgroundColor3 = "Tertiary"}})
      tabLabel:tween({Theme = {TextColor3 = "StrongText"}})
      if tabIcon_img then
        tabIcon_img:tween({Theme = {ImageColor3 = "StrongText"}})
      end
      self.selectedTab = Tab
    end

    tabButton.MouseButton1Click:Connect(selectTab)

    -- Эффекты наведения
    tabButton.MouseEnter:Connect(function()
      if self.selectedTab ~= Tab then
        tabButton:tween({Theme = {BackgroundColor3 = {"Tertiary", -20}}}, {Length = 0.15})
      end
    end)

    tabButton.MouseLeave:Connect(function()
      if self.selectedTab ~= Tab then
        tabButton:tween({Theme = {BackgroundColor3 = "Secondary"}}, {Length = 0.15})
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

    -- Автоматически выбрать первую вкладку
    if #self.tabs == 1 then
      selectTab()
    end

    -- ФУНКЦИИ ЭЛЕМЕНТОВ ВКЛАДКИ
    
    -- Секция
    function Tab:section(options)
      options = options or {}
      local sectionName = options.Name or "Section"

      local section = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1
      })

      section:object("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = sectionName,
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      section:object("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        Theme = {BackgroundColor3 = "Tertiary"},
        BorderSizePixel = 0
      })

      return section
    end

    -- Переключатель
    function Tab:toggle(options)
      options = options or {}
      local toggleName = options.Name or "Toggle"
      local toggleDesc = options.Description or ""
      local startingState = options.StartingState or false
      local callback = options.Callback or function() end
      local flag = options.Flag

      local toggleState = startingState
      if flag then
        Ruvex.flags[flag] = toggleState
      end

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

      toggle:object("TextLabel", {
        Size = UDim2.new(1, -55, 0, 20),
        Position = UDim2.fromOffset(15, 8),
        BackgroundTransparency = 1,
        Text = toggleName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      if toggleDesc ~= "" then
        toggle:object("TextLabel", {
          Size = UDim2.new(1, -55, 0, 20),
          Position = UDim2.fromOffset(15, 25),
          BackgroundTransparency = 1,
          Text = toggleDesc,
          Theme = {TextColor3 = "WeakText"},
          TextSize = 12,
          Font = Enum.Font.Gotham,
          TextXAlignment = Enum.TextXAlignment.Left
        })
      end

      -- Переключатель
      local toggleSwitch = toggle:object("Frame", {
        Size = UDim2.fromOffset(40, 20),
        Position = UDim2.new(1, -50, 0, 8),
        Theme = {BackgroundColor3 = toggleState and "Tertiary" or {"WeakText", -20}}
      }):round(10)

      local toggleIndicator = toggleSwitch:object("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(toggleState and 22 or 2, 2),
        Theme = {BackgroundColor3 = "StrongText"}
      }):round(8)

      local function updateToggle()
        toggleSwitch:tween({Theme = {BackgroundColor3 = toggleState and "Tertiary" or {"WeakText", -20}}})
        toggleIndicator:tween({Position = UDim2.fromOffset(toggleState and 22 or 2, 2)})
        
        if flag then
          Ruvex.flags[flag] = toggleState
        end
        
        pcall(callback, toggleState)
      end

      toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        updateToggle()
      end)

      -- Эффекты наведения
      toggleButton.MouseEnter:Connect(function()
        toggle:tween({Theme = {BackgroundColor3 = {"Secondary", 10}}}, {Length = 0.15})
      end)

      toggleButton.MouseLeave:Connect(function()
        toggle:tween({Theme = {BackgroundColor3 = "Secondary"}}, {Length = 0.15})
      end)

      return toggle
    end

    -- Кнопка
    function Tab:button(options)
      options = options or {}
      local buttonName = options.Name or "Button"
      local buttonDesc = options.Description or ""
      local callback = options.Callback or function() end

      local button = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, buttonDesc ~= "" and 50 or 35),
        Theme = {BackgroundColor3 = "Tertiary"}
      }):round(6)

      local buttonBtn = button:object("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
      })

      button:object("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(15, 8),
        BackgroundTransparency = 1,
        Text = buttonName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      if buttonDesc ~= "" then
        button:object("TextLabel", {
          Size = UDim2.new(1, -20, 0, 20),
          Position = UDim2.fromOffset(15, 25),
          BackgroundTransparency = 1,
          Text = buttonDesc,
          Theme = {TextColor3 = "WeakText"},
          TextSize = 12,
          Font = Enum.Font.Gotham,
          TextXAlignment = Enum.TextXAlignment.Left
        })
      end

      buttonBtn.MouseButton1Click:Connect(function()
        pcall(callback)
      end)

      -- Эффекты наведения
      buttonBtn.MouseEnter:Connect(function()
        button:tween({Theme = {BackgroundColor3 = {"Tertiary", 20}}}, {Length = 0.15})
      end)

      buttonBtn.MouseLeave:Connect(function()
        button:tween({Theme = {BackgroundColor3 = "Tertiary"}}, {Length = 0.15})
      end)

      return button
    end

    -- Слайдер
    function Tab:slider(options)
      options = options or {}
      local sliderName = options.Name or "Slider"
      local sliderDesc = options.Description or ""
      local min = options.Min or 0
      local max = options.Max or 100
      local increment = options.Increment or 1
      local startingValue = options.StartingValue or min
      local callback = options.Callback or function() end
      local flag = options.Flag

      local sliderValue = startingValue
      if flag then
        Ruvex.flags[flag] = sliderValue
      end

      local slider = Ruvex:object("Frame", {
        Parent = tabContent,
        Size = UDim2.new(1, 0, 0, sliderDesc ~= "" and 65 or 45),
        Theme = {BackgroundColor3 = "Secondary"}
      }):round(6)

      slider:object("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 20),
        Position = UDim2.fromOffset(15, 8),
        BackgroundTransparency = 1,
        Text = sliderName,
        Theme = {TextColor3 = "StrongText"},
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
      })

      local sliderValueLabel = slider:object("TextLabel", {
        Size = UDim2.new(0.3, -15, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(sliderValue),
        Theme = {TextColor3 = "Tertiary"},
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
      })

      if sliderDesc ~= "" then
        slider:object("TextLabel", {
          Size = UDim2.new(1, -20, 0, 15),
          Position = UDim2.fromOffset(15, 25),
          BackgroundTransparency = 1,
          Text = sliderDesc,
          Theme = {TextColor3 = "WeakText"},
          TextSize = 12,
          Font = Enum.Font.Gotham,
          TextXAlignment = Enum.TextXAlignment.Left
        })
      end

      -- Полоса слайдера
      local sliderBar = slider:object("Frame", {
        Size = UDim2.new(1, -30, 0, 4),
        Position = UDim2.new(0, 15, 1, -12),
        Theme = {BackgroundColor3 = {"WeakText", -30}}
      }):round(2)

      local sliderFill = sliderBar:object("Frame", {
        Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0),
        Theme = {BackgroundColor3 = "Tertiary"}
      }):round(2)

      local sliderButton = sliderBar:object("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, -8),
        BackgroundTransparency = 1,
        Text = ""
      })

      local function updateSlider(value)
        sliderValue = math.clamp(value, min, max)
        sliderValue = math.floor((sliderValue / increment) + 0.5) * increment
        
        local percentage = (sliderValue - min) / (max - min)
        sliderFill:tween({Size = UDim2.new(percentage, 0, 1, 0)}, {Length = 0.1})
        sliderValueLabel.Text = tostring(sliderValue)
        
        if flag then
          Ruvex.flags[flag] = sliderValue
        end
        
        pcall(callback, sliderValue)
      end

      local dragging = false
      
      sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
          dragging = true
        end
      end)

      sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
          dragging = false
        end
      end)

      UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
          local percentage = math.clamp((Mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
          local value = min + (max - min) * percentage
          updateSlider(value)
        end
      end)

      -- Эффекты наведения
      sliderButton.MouseEnter:Connect(function()
        slider:tween({Theme = {BackgroundColor3 = {"Secondary", 10}}}, {Length = 0.15})
      end)

      sliderButton.MouseLeave:Connect(function()
        slider:tween({Theme = {BackgroundColor3 = "Secondary"}}, {Length = 0.15})
      end)

      return slider
    end

    return Tab
  end

  -- Глобальное переключение
  UserInputService.InputBegan:Connect(function(key, gameProcessed)
    if key.KeyCode == Ruvex.ToggleKey and not gameProcessed then
      Ruvex.Toggled = not Ruvex.Toggled
      Window.core.Visible = Ruvex.Toggled
    end
  end)

  return Window
end

return Ruvex
