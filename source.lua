--[[
    ██╗  ██╗███████╗██╗ ██████╗  █████╗
    ╚██╗██╔╝██╔════╝██║██╔═══██╗██╔══██╗
     ╚███╔╝ █████╗  ██║██║   ██║███████║
     ██╔██╗ ██╔══╝  ██║██║   ██║██╔══██║
    ██╔╝ ██╗███████╗██║╚██████╔╝██║  ██║
    ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝

    Xeioa UI Library
    Version: 1.0.0

    Features:
      - Window with drag & open/close toggle
      - Tabs & Groupboxes (Left / Right)
      - Tabboxes inside Groupboxes
      - Toggle / Checkbox
      - Button (with sub-buttons)
      - Label (wrapping)
      - Slider (with suffix, rounding, compact)
      - Input / Textbox (numeric, finished, placeholder)
      - Dropdown (multi-select, searchable, display format)
      - ColorPicker (with transparency)
      - Keybind
      - Divider
      - Notification system
      - Theme system
      - Open/Close keybind (default: RightShift)
]]

-- ─────────────────────────────────────────────
--  Services
-- ─────────────────────────────────────────────
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local lp    = Players.LocalPlayer
local mouse = lp:GetMouse()

-- ─────────────────────────────────────────────
--  Utility helpers
-- ─────────────────────────────────────────────
local function tween(obj, info, props)
    return TweenService:Create(obj, info, props):Play()
end

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function round(n, d)
    d = d or 0
    local m = 10^d
    return math.floor(n * m + 0.5) / m
end

local function clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

local function stripRichText(s)
    return s:gsub("<[^>]+>", "")
end

-- ─────────────────────────────────────────────
--  Global state
-- ─────────────────────────────────────────────
if not getgenv then getgenv = function() return _G end end

getgenv().XeioaOptions  = getgenv().XeioaOptions  or {}
getgenv().XeioaToggles  = getgenv().XeioaToggles  or {}

local Library = {
    Name            = "Xeioa",
    Version         = "1.0.0",
    Options         = getgenv().XeioaOptions,
    Toggles         = getgenv().XeioaToggles,
    Connections     = {},
    Windows         = {},
    -- default open/close key
    ToggleKey       = Enum.KeyCode.RightShift,
    -- default theme
    Theme = {
        Background      = Color3.fromRGB(18, 18, 24),
        TopBar          = Color3.fromRGB(26, 26, 34),
        Accent          = Color3.fromRGB(120, 100, 240),
        AccentDark      = Color3.fromRGB(80, 60, 190),
        Text            = Color3.fromRGB(230, 230, 240),
        TextDark        = Color3.fromRGB(150, 150, 165),
        Element         = Color3.fromRGB(30, 30, 40),
        ElementHover    = Color3.fromRGB(40, 40, 55),
        ElementStroke   = Color3.fromRGB(55, 55, 70),
        Toggle_ON       = Color3.fromRGB(120, 100, 240),
        Toggle_OFF      = Color3.fromRGB(60, 60, 78),
        SliderFill      = Color3.fromRGB(120, 100, 240),
        Divider         = Color3.fromRGB(50, 50, 65),
        Notification    = Color3.fromRGB(26, 26, 34),
        NotifStroke     = Color3.fromRGB(120, 100, 240),
        Red             = Color3.fromRGB(220, 80, 80),
        Green           = Color3.fromRGB(80, 200, 120),
    },
    Themes = {
        Default = {
            Background      = Color3.fromRGB(18, 18, 24),
            TopBar          = Color3.fromRGB(26, 26, 34),
            Accent          = Color3.fromRGB(120, 100, 240),
            AccentDark      = Color3.fromRGB(80, 60, 190),
            Text            = Color3.fromRGB(230, 230, 240),
            TextDark        = Color3.fromRGB(150, 150, 165),
            Element         = Color3.fromRGB(30, 30, 40),
            ElementHover    = Color3.fromRGB(40, 40, 55),
            ElementStroke   = Color3.fromRGB(55, 55, 70),
            Toggle_ON       = Color3.fromRGB(120, 100, 240),
            Toggle_OFF      = Color3.fromRGB(60, 60, 78),
            SliderFill      = Color3.fromRGB(120, 100, 240),
            Divider         = Color3.fromRGB(50, 50, 65),
            Notification    = Color3.fromRGB(26, 26, 34),
            NotifStroke     = Color3.fromRGB(120, 100, 240),
            Red             = Color3.fromRGB(220, 80, 80),
            Green           = Color3.fromRGB(80, 200, 120),
        },
        Ocean = {
            Background      = Color3.fromRGB(12, 22, 38),
            TopBar          = Color3.fromRGB(18, 32, 54),
            Accent          = Color3.fromRGB(60, 160, 240),
            AccentDark      = Color3.fromRGB(30, 110, 190),
            Text            = Color3.fromRGB(220, 235, 255),
            TextDark        = Color3.fromRGB(130, 160, 200),
            Element         = Color3.fromRGB(20, 34, 55),
            ElementHover    = Color3.fromRGB(28, 46, 72),
            ElementStroke   = Color3.fromRGB(40, 60, 90),
            Toggle_ON       = Color3.fromRGB(60, 160, 240),
            Toggle_OFF      = Color3.fromRGB(30, 50, 75),
            SliderFill      = Color3.fromRGB(60, 160, 240),
            Divider         = Color3.fromRGB(30, 50, 75),
            Notification    = Color3.fromRGB(18, 32, 54),
            NotifStroke     = Color3.fromRGB(60, 160, 240),
            Red             = Color3.fromRGB(220, 80, 80),
            Green           = Color3.fromRGB(60, 200, 130),
        },
        Crimson = {
            Background      = Color3.fromRGB(22, 12, 14),
            TopBar          = Color3.fromRGB(34, 18, 20),
            Accent          = Color3.fromRGB(220, 60, 80),
            AccentDark      = Color3.fromRGB(160, 30, 50),
            Text            = Color3.fromRGB(255, 230, 232),
            TextDark        = Color3.fromRGB(180, 140, 145),
            Element         = Color3.fromRGB(36, 20, 22),
            ElementHover    = Color3.fromRGB(50, 28, 32),
            ElementStroke   = Color3.fromRGB(70, 38, 42),
            Toggle_ON       = Color3.fromRGB(220, 60, 80),
            Toggle_OFF      = Color3.fromRGB(70, 38, 42),
            SliderFill      = Color3.fromRGB(220, 60, 80),
            Divider         = Color3.fromRGB(60, 34, 36),
            Notification    = Color3.fromRGB(34, 18, 20),
            NotifStroke     = Color3.fromRGB(220, 60, 80),
            Red             = Color3.fromRGB(220, 80, 80),
            Green           = Color3.fromRGB(80, 200, 120),
        },
        Emerald = {
            Background      = Color3.fromRGB(12, 22, 18),
            TopBar          = Color3.fromRGB(18, 34, 28),
            Accent          = Color3.fromRGB(60, 210, 130),
            AccentDark      = Color3.fromRGB(30, 150, 90),
            Text            = Color3.fromRGB(220, 255, 240),
            TextDark        = Color3.fromRGB(130, 190, 160),
            Element         = Color3.fromRGB(20, 36, 28),
            ElementHover    = Color3.fromRGB(28, 50, 38),
            ElementStroke   = Color3.fromRGB(40, 70, 54),
            Toggle_ON       = Color3.fromRGB(60, 210, 130),
            Toggle_OFF      = Color3.fromRGB(30, 60, 44),
            SliderFill      = Color3.fromRGB(60, 210, 130),
            Divider         = Color3.fromRGB(30, 56, 42),
            Notification    = Color3.fromRGB(18, 34, 28),
            NotifStroke     = Color3.fromRGB(60, 210, 130),
            Red             = Color3.fromRGB(220, 80, 80),
            Green           = Color3.fromRGB(60, 210, 130),
        },
    },
}

-- ─────────────────────────────────────────────
--  Theme API
-- ─────────────────────────────────────────────
function Library:SetTheme(name)
    local t = self.Themes[name]
    if not t then return end
    for k, v in pairs(t) do
        self.Theme[k] = v
    end
end

-- ─────────────────────────────────────────────
--  Notifications
-- ─────────────────────────────────────────────
local NotifGui = create("ScreenGui", {
    Name              = "XeioaNotifications",
    ResetOnSpawn      = false,
    DisplayOrder      = 999,
    IgnoreGuiInset    = true,
    Parent            = CoreGui,
})

local NotifHolder = create("Frame", {
    Name              = "Holder",
    BackgroundTransparency = 1,
    Size              = UDim2.new(0, 280, 1, 0),
    Position          = UDim2.new(1, -290, 0, 0),
    Parent            = NotifGui,
}, {
    create("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding         = UDim.new(0, 6),
    }),
    create("UIPadding", {
        PaddingBottom   = UDim.new(0, 12),
    }),
})

local notifCount = 0

function Library:Notify(options)
    options = options or {}
    local title    = options.Title    or "Xeioa"
    local text     = options.Text     or ""
    local duration = options.Duration or 4
    local ntype    = options.Type     or "info" -- "info", "success", "error", "warning"
    local T        = self.Theme

    local accentColor = T.Accent
    if ntype == "success" then accentColor = T.Green
    elseif ntype == "error" then accentColor = T.Red
    elseif ntype == "warning" then accentColor = Color3.fromRGB(240, 180, 50) end

    notifCount = notifCount + 1

    local frame = create("Frame", {
        Name              = "Notif_" .. notifCount,
        BackgroundColor3  = T.Notification,
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        ClipsDescendants  = true,
        Parent            = NotifHolder,
    }, {
        create("UICorner",   { CornerRadius = UDim.new(0, 8) }),
        create("UIStroke",   { Color = accentColor, Thickness = 1.5 }),
        create("UIPadding",  { PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10),
                                PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12) }),
    })

    local accent = create("Frame", {
        Name             = "Accent",
        BackgroundColor3 = accentColor,
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, -12, 0, 0),
        Parent           = frame,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 3) }),
    })

    local layout = create("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Position               = UDim2.new(0, 8, 0, 0),
        Parent                 = frame,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    create("TextLabel", {
        Text             = title,
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 16),
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = 1,
        Parent           = layout,
    })

    create("TextLabel", {
        Text             = text,
        TextColor3       = T.TextDark,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        LayoutOrder      = 2,
        Parent           = layout,
    })

    local progressBg = create("Frame", {
        BackgroundColor3 = T.ElementStroke,
        Size             = UDim2.new(1, 8, 0, 2),
        Position         = UDim2.new(0, -8, 1, 6),
        Parent           = frame,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    local progressFill = create("Frame", {
        BackgroundColor3 = accentColor,
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = progressBg,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    frame.BackgroundTransparency = 1
    task.delay(0.05, function()
        tween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 0 })
    end)

    tween(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(duration, function()
        tween(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint),
            { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
        task.delay(0.45, function()
            frame:Destroy()
        end)
    end)

    return frame
end

-- ─────────────────────────────────────────────
--  Window
-- ─────────────────────────────────────────────
function Library:CreateWindow(options)
    options = options or {}
    local title      = options.Title      or "Xeioa"
    local subtitle   = options.Subtitle   or ""
    local toggleKey  = options.ToggleKey  or self.ToggleKey
    local autoShow   = options.AutoShow   ~= false
    local center     = options.Center     or false
    local size       = options.Size       or Vector2.new(580, 440)
    local position   = options.Position
    local T          = self.Theme

    local screenGui = create("ScreenGui", {
        Name           = "Xeioa_" .. title,
        ResetOnSpawn   = false,
        DisplayOrder   = 100,
        IgnoreGuiInset = true,
        Parent         = CoreGui,
    })

    local windowSize = UDim2.new(0, size.X, 0, size.Y)
    local startPos   = center
        and UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
        or  (position and UDim2.new(0, position.X, 0, position.Y)
             or UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2))

    local mainFrame = create("Frame", {
        Name             = "Main",
        BackgroundColor3 = T.Background,
        Size             = windowSize,
        Position         = startPos,
        ClipsDescendants = false,
        Parent           = screenGui,
    }, {
        create("UICorner",  { CornerRadius = UDim.new(0, 10) }),
        create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
        create("UISizeConstraint", { MinSize = Vector2.new(400, 300), MaxSize = Vector2.new(900, 700) }),
    })

    -- Drop shadow
    local shadow = create("ImageLabel", {
        Name                  = "Shadow",
        BackgroundTransparency = 1,
        Image                 = "rbxassetid://6014261993",
        ImageColor3           = Color3.new(0,0,0),
        ImageTransparency     = 0.5,
        Size                  = UDim2.new(1, 50, 1, 50),
        Position              = UDim2.new(0, -25, 0, -25),
        ZIndex                = 0,
        Parent                = mainFrame,
    })

    -- Top bar
    local topBar = create("Frame", {
        Name             = "TopBar",
        BackgroundColor3 = T.TopBar,
        Size             = UDim2.new(1, 0, 0, 46),
        Parent           = mainFrame,
    }, {
        create("UICorner",  { CornerRadius = UDim.new(0, 10) }),
    })

    local topBarFix = create("Frame", {
        BackgroundColor3 = T.TopBar,
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BorderSizePixel  = 0,
        Parent           = topBar,
    })

    local accentLine = create("Frame", {
        Name             = "AccentLine",
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        Parent           = topBar,
    })

    local titleLabel = create("TextLabel", {
        Text             = title,
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -100, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = topBar,
    })

    if subtitle ~= "" then
        local subLabel = create("TextLabel", {
            Text            = subtitle,
            TextColor3      = T.TextDark,
            Font            = Enum.Font.Gotham,
            TextSize        = 11,
            BackgroundTransparency = 1,
            Size            = UDim2.new(0, 200, 1, 0),
            Position        = UDim2.new(0, 14 + titleLabel.TextBounds.X + 8, 0, 0),
            TextXAlignment  = Enum.TextXAlignment.Left,
            Parent          = topBar,
        })
    end

    -- Close button
    local closeBtn = create("TextButton", {
        Text             = "×",
        TextColor3       = T.TextDark,
        Font             = Enum.Font.GothamBold,
        TextSize         = 20,
        BackgroundColor3 = T.Element,
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -38, 0.5, -14),
        Parent           = topBar,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Red, TextColor3 = Color3.new(1,1,1) })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Element, TextColor3 = T.TextDark })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Minimize button
    local minBtn = create("TextButton", {
        Text             = "–",
        TextColor3       = T.TextDark,
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        BackgroundColor3 = T.Element,
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -70, 0.5, -14),
        Parent           = topBar,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    minBtn.MouseEnter:Connect(function()
        tween(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1,1,1) })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Element, TextColor3 = T.TextDark })
    end)

    -- Key hint label
    local keyHint = create("TextLabel", {
        Text             = "[" .. toggleKey.Name .. " = toggle]",
        TextColor3       = T.TextDark,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 160, 0, 18),
        Position         = UDim2.new(1, -240, 0.5, -9),
        TextXAlignment   = Enum.TextXAlignment.Right,
        Parent           = topBar,
    })

    -- Content area
    local contentFrame = create("Frame", {
        Name             = "Content",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, -46),
        Position         = UDim2.new(0, 0, 0, 46),
        Parent           = mainFrame,
    })

    -- Tab bar
    local tabBar = create("Frame", {
        Name             = "TabBar",
        BackgroundColor3 = T.TopBar,
        Size             = UDim2.new(1, 0, 0, 36),
        Parent           = contentFrame,
    }, {
        create("UIStroke", { Color = T.ElementStroke, Thickness = 1 }),
        create("Frame", {
            BackgroundColor3 = T.TopBar,
            Size             = UDim2.new(1, 0, 0, 4),
            Position         = UDim2.new(0, 0, 0, 0),
            BorderSizePixel  = 0,
        }),
    })

    local tabBarList = create("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 1, 0),
        Position               = UDim2.new(0, 4, 0, 0),
        Parent                 = tabBar,
    }, {
        create("UIListLayout", {
            FillDirection  = Enum.FillDirection.Horizontal,
            SortOrder      = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding        = UDim.new(0, 2),
        }),
    })

    -- Tab content container
    local tabContent = create("Frame", {
        Name             = "TabContent",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, -36),
        Position         = UDim2.new(0, 0, 0, 36),
        Parent           = contentFrame,
    })

    -- ─── Dragging ───
    local dragging, dragStart, startPos2 = false, nil, nil
    topBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos2 = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos2.X.Scale, startPos2.X.Offset + delta.X,
                startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ─── Window object ───
    local Window = {
        ScreenGui   = screenGui,
        MainFrame   = mainFrame,
        TabBar      = tabBarList,
        TabContent  = tabContent,
        Tabs        = {},
        ActiveTab   = nil,
        Visible     = true,
        ToggleKey   = toggleKey,
    }

    -- Open/Close
    local function setVisible(v)
        Window.Visible = v
        local targetSize = v and windowSize or UDim2.new(0, size.X, 0, 0)
        local targetTrans = v and 0 or 1
        tween(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = targetSize })
        contentFrame.Visible = v
    end

    minBtn.MouseButton1Click:Connect(function()
        setVisible(not Window.Visible)
    end)

    -- Keybind toggle
    local kconn = UserInputService.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == toggleKey then
            setVisible(not Window.Visible)
        end
    end)
    table.insert(Library.Connections, kconn)

    -- ─── AddTab ───
    function Window:AddTab(name, icon)
        local T = Library.Theme
        local tabBtn = create("TextButton", {
            Text             = name,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 1,
            AutomaticSize    = Enum.AutomaticSize.X,
            Size             = UDim2.new(0, 0, 1, -6),
            Parent           = self.TabBar,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
        })

        local underline = create("Frame", {
            BackgroundColor3 = T.Accent,
            Size             = UDim2.new(1, 0, 0, 2),
            Position         = UDim2.new(0, 0, 1, 0),
            Transparency     = 1,
            Parent           = tabBtn,
        })

        local page = create("ScrollingFrame", {
            Name             = "Page_" .. name,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Accent,
            Visible          = false,
            Parent           = self.TabContent,
        }, {
            create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10),
                                   PaddingTop  = UDim.new(0,10), PaddingBottom = UDim.new(0,10) }),
        })

        local function activate()
            if self.ActiveTab then
                tween(self.ActiveTab.Btn, TweenInfo.new(0.15),
                    { TextColor3 = T.TextDark, BackgroundTransparency = 1 })
                self.ActiveTab.Underline.Visible = false
                self.ActiveTab.Page.Visible = false
            end
            tween(tabBtn, TweenInfo.new(0.15),
                { TextColor3 = T.Text, BackgroundTransparency = 0.85 })
            underline.Visible = true
            page.Visible      = true
            self.ActiveTab = { Btn = tabBtn, Underline = underline, Page = page }
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if self.ActiveTab and self.ActiveTab.Btn == tabBtn then return end
            tween(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.92 })
        end)
        tabBtn.MouseLeave:Connect(function()
            if self.ActiveTab and self.ActiveTab.Btn == tabBtn then return end
            tween(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 })
        end)

        if not self.ActiveTab then activate() end

        -- Groupbox row layout for the page
        local rowLayout = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = page,
        }, {
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder     = Enum.SortOrder.LayoutOrder,
                Padding       = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })

        local Tab = {
            Page       = page,
            RowLayout  = rowLayout,
            LeftCol    = nil,
            RightCol   = nil,
        }

        local function ensureColumns()
            if not Tab.LeftCol then
                Tab.LeftCol = create("Frame", {
                    BackgroundTransparency = 1,
                    Size                   = UDim2.new(0.5, -4, 0, 0),
                    AutomaticSize          = Enum.AutomaticSize.Y,
                    LayoutOrder            = 1,
                    Parent                 = rowLayout,
                }, {
                    create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding   = UDim.new(0, 8),
                    }),
                })
                Tab.RightCol = create("Frame", {
                    BackgroundTransparency = 1,
                    Size                   = UDim2.new(0.5, -4, 0, 0),
                    AutomaticSize          = Enum.AutomaticSize.Y,
                    LayoutOrder            = 2,
                    Parent                 = rowLayout,
                }, {
                    create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding   = UDim.new(0, 8),
                    }),
                })
            end
        end

        local function makeGroupbox(parent, title, side)
            ensureColumns()
            local col = (side == "Left") and Tab.LeftCol or Tab.RightCol
            local T   = Library.Theme

            local gb = create("Frame", {
                Name             = "GB_" .. title,
                BackgroundColor3 = T.Element,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                Parent           = col,
            }, {
                create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
                create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
                create("UIPadding", { PaddingTop = UDim.new(0,32), PaddingBottom = UDim.new(0,10),
                                       PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10) }),
            })

            create("TextLabel", {
                Text             = title,
                TextColor3       = T.Text,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, 0, 0, 22),
                Position         = UDim2.new(0, 10, 0, 6),
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = gb,
            })

            create("Frame", {
                BackgroundColor3 = T.ElementStroke,
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0, 30),
                BorderSizePixel  = 0,
                Parent           = gb,
            })

            local itemList = create("Frame", {
                BackgroundTransparency = 1,
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                Parent                 = gb,
            }, {
                create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding   = UDim.new(0, 4),
                }),
            })

            return Library:_MakeGroupboxAPI(itemList)
        end

        function Tab:AddLeftGroupbox(title)
            return makeGroupbox(page, title, "Left")
        end

        function Tab:AddRightGroupbox(title)
            return makeGroupbox(page, title, "Right")
        end

        function Tab:AddGroupbox(title)
            ensureColumns()
            -- Picks the shorter column
            local lc = Tab.LeftCol
            local rc = Tab.RightCol
            local side = "Left"
            if lc and rc then
                local lh = lc.AbsoluteSize.Y
                local rh = rc.AbsoluteSize.Y
                if rh < lh then side = "Right" end
            end
            return makeGroupbox(page, title, side)
        end

        -- Tabbox inside a groupbox
        function Tab:AddLeftTabbox()
            ensureColumns()
            return Library:_MakeTabbox(Tab.LeftCol)
        end
        function Tab:AddRightTabbox()
            ensureColumns()
            return Library:_MakeTabbox(Tab.RightCol)
        end

        self.Tabs[name] = Tab
        return Tab
    end

    -- AddKeyTab (special: shows an input + unlock flow)
    function Window:AddKeyTab(name)
        local tab = self:AddTab(name)
        local gb  = tab:AddLeftGroupbox("Key System")
        gb:AddLabel("Enter the correct key to unlock this tab.", true)
        local unlocked = false
        gb:AddInput("XeioaKey_" .. name, {
            Text        = "Key",
            Placeholder = "Enter key...",
            Callback    = function(val)
                if val == "xeioa" then
                    Library:Notify({ Title = "Unlocked!", Text = "Key accepted.", Type = "success" })
                    unlocked = true
                else
                    Library:Notify({ Title = "Wrong Key", Text = "That key is incorrect.", Type = "error" })
                end
            end,
        })
        return tab
    end

    table.insert(self.Windows, Window)
    if not autoShow then
        contentFrame.Visible = false
        Window.Visible       = false
    end

    return Window
end

-- ─────────────────────────────────────────────
--  Tabbox
-- ─────────────────────────────────────────────
function Library:_MakeTabbox(parentCol)
    local T = self.Theme

    local container = create("Frame", {
        BackgroundColor3 = T.Element,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Parent           = parentCol,
    }, {
        create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
    })

    local tabBtnRow = create("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 28),
        Position               = UDim2.new(0, 0, 0, 0),
        Parent                 = container,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder     = Enum.SortOrder.LayoutOrder,
            Padding       = UDim.new(0, 2),
        }),
        create("UIPadding", { PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4) }),
    })

    local divider = create("Frame", {
        BackgroundColor3 = T.ElementStroke,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 28),
        BorderSizePixel  = 0,
        Parent           = container,
    })

    local pageHolder = create("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Position               = UDim2.new(0, 0, 0, 34),
        Parent                 = container,
    }, {
        create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
                               PaddingBottom = UDim.new(0,8) }),
    })

    local Tabbox = { ActiveTab = nil }

    function Tabbox:AddTab(name)
        local btn = create("TextButton", {
            Text             = name,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 11,
            BackgroundTransparency = 1,
            AutomaticSize    = Enum.AutomaticSize.X,
            Size             = UDim2.new(0, 0, 1, -4),
            Parent           = tabBtnRow,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        local itemList = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Visible                = false,
            Parent                 = pageHolder,
        }, {
            create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4) }),
        })

        local function activate()
            if Tabbox.ActiveTab then
                tween(Tabbox.ActiveTab.Btn, TweenInfo.new(0.12),
                    { TextColor3 = T.TextDark, BackgroundTransparency = 1 })
                Tabbox.ActiveTab.Page.Visible = false
            end
            tween(btn, TweenInfo.new(0.12),
                { TextColor3 = T.Text, BackgroundTransparency = 0.85 })
            itemList.Visible = true
            Tabbox.ActiveTab = { Btn = btn, Page = itemList }
        end

        btn.MouseButton1Click:Connect(activate)
        if not Tabbox.ActiveTab then activate() end

        return Library:_MakeGroupboxAPI(itemList)
    end

    return Tabbox
end

-- ─────────────────────────────────────────────
--  Groupbox element API
-- ─────────────────────────────────────────────
function Library:_MakeGroupboxAPI(itemList)
    local T   = self.Theme
    local API = {}

    -- ── Helper: element wrapper ──
    local function makeRow(height)
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, height or 28),
            AutomaticSize          = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            Parent                 = itemList,
        })
        return row
    end

    -- ── Divider ──
    function API:AddDivider()
        local row = makeRow(10)
        create("Frame", {
            BackgroundColor3 = T.Divider,
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BorderSizePixel  = 0,
            Parent           = row,
        })
        return API
    end

    -- ── Label ──
    function API:AddLabel(text, doesWrap, idx)
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = itemList,
        })
        local lbl = create("TextLabel", {
            Text             = text,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = doesWrap or false,
            RichText         = true,
            Parent           = row,
        })
        local obj = { Frame = row, Label = lbl }
        function obj:SetText(t) lbl.Text = t end
        if idx then Library.Options[idx] = obj end
        return API
    end

    -- ── Toggle ──
    function API:AddToggle(idx, options)
        options = options or {}
        local text     = options.Text     or idx
        local default  = options.Default  ~= nil and options.Default or false
        local disabled = options.Disabled or false
        local risky    = options.Risky    or false
        local cb       = options.Callback

        local row = makeRow(28)
        local value = default

        local bg = create("TextButton", {
            Text             = "",
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        local label = create("TextLabel", {
            Text             = text,
            TextColor3       = risky and T.Red or T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -46, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = bg,
        })

        local toggleTrack = create("Frame", {
            BackgroundColor3 = value and T.Toggle_ON or T.Toggle_OFF,
            Size             = UDim2.new(0, 36, 0, 18),
            Position         = UDim2.new(1, -36, 0.5, -9),
            Parent           = bg,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })

        local knob = create("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = value
                and UDim2.new(1, -15, 0.5, -6)
                or  UDim2.new(0, 3, 0.5, -6),
            Parent           = toggleTrack,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1,0) }),
        })

        local callbacks = {}
        local toggleObj = {
            Value = value,
            OnChanged = function(self, fn)
                table.insert(callbacks, fn)
                return self
            end,
            SetValue = function(self, v)
                value = v
                self.Value = v
                tween(toggleTrack, TweenInfo.new(0.2), { BackgroundColor3 = v and T.Toggle_ON or T.Toggle_OFF })
                tween(knob, TweenInfo.new(0.2), {
                    Position = v
                        and UDim2.new(1, -15, 0.5, -6)
                        or  UDim2.new(0, 3, 0.5, -6),
                })
                if cb then cb(v) end
                for _, fn in ipairs(callbacks) do fn(v) end
            end,
            AddColorPicker = function(self, cpIdx, cpOptions)
                return API:_AddColorPickerInline(row, cpIdx, cpOptions)
            end,
        }

        if not disabled then
            bg.MouseButton1Click:Connect(function()
                toggleObj:SetValue(not value)
            end)
            bg.MouseEnter:Connect(function()
                tween(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover })
            end)
            bg.MouseLeave:Connect(function()
                tween(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.Element })
            end)
        else
            bg.BackgroundColor3 = Color3.fromRGB(25,25,32)
            label.TextColor3    = T.TextDark
        end

        Library.Toggles[idx] = toggleObj
        if options.Tooltip then
            API:_Tooltip(bg, options.Tooltip)
        end
        return toggleObj
    end

    -- Checkbox (alias, same as toggle visually slightly different)
    function API:AddCheckbox(idx, options)
        options = options or {}
        local text     = options.Text    or idx
        local default  = options.Default ~= nil and options.Default or false
        local disabled = options.Disabled or false
        local risky    = options.Risky   or false
        local cb       = options.Callback

        local row = makeRow(26)
        local value = default

        local bg = create("TextButton", {
            Text             = "",
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        local box = create("Frame", {
            BackgroundColor3 = value and T.Accent or T.Toggle_OFF,
            Size             = UDim2.new(0, 16, 0, 16),
            Position         = UDim2.new(1, -16, 0.5, -8),
            Parent           = bg,
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            create("UIStroke", { Color = T.ElementStroke, Thickness = 1 }),
        })

        local check = create("TextLabel", {
            Text             = "✓",
            TextColor3       = Color3.new(1,1,1),
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1,0,1,0),
            TextTransparency = value and 0 or 1,
            Parent           = box,
        })

        create("TextLabel", {
            Text             = text,
            TextColor3       = risky and T.Red or T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -28, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = bg,
        })

        local callbacks = {}
        local cbObj = {
            Value = value,
            OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
            SetValue = function(self, v)
                value = v
                self.Value = v
                tween(box, TweenInfo.new(0.15), { BackgroundColor3 = v and T.Accent or T.Toggle_OFF })
                tween(check, TweenInfo.new(0.15), { TextTransparency = v and 0 or 1 })
                if cb then cb(v) end
                for _, fn in ipairs(callbacks) do fn(v) end
            end,
        }

        if not disabled then
            bg.MouseButton1Click:Connect(function() cbObj:SetValue(not value) end)
            bg.MouseEnter:Connect(function() tween(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover }) end)
            bg.MouseLeave:Connect(function() tween(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.Element }) end)
        end

        Library.Toggles[idx] = cbObj
        if options.Tooltip then API:_Tooltip(bg, options.Tooltip) end
        return cbObj
    end

    -- ── Button ──
    function API:AddButton(options)
        options = options or {}
        local text       = options.Text       or "Button"
        local func       = options.Func       or function() end
        local doubleClick= options.DoubleClick or false
        local disabled   = options.Disabled   or false
        local risky      = options.Risky      or false

        local row = makeRow(28)

        local function makeBtnFrame(parent, btnText, w, xPos)
            local btn = create("TextButton", {
                Text             = btnText,
                TextColor3       = risky and T.Red or T.Text,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                BackgroundColor3 = T.Element,
                Size             = w or UDim2.new(1, 0, 1, 0),
                Position         = xPos or UDim2.new(0,0,0,0),
                Parent           = parent,
            }, {
                create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
                create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            })
            return btn
        end

        local mainBtn = makeBtnFrame(row, text)
        local lastClick = 0

        if not disabled then
            mainBtn.MouseButton1Click:Connect(function()
                if doubleClick then
                    local now = tick()
                    if now - lastClick < 0.4 then
                        func()
                        lastClick = 0
                    else
                        lastClick = now
                        tween(mainBtn, TweenInfo.new(0.1), { BackgroundColor3 = T.Accent })
                        task.delay(0.1, function()
                            tween(mainBtn, TweenInfo.new(0.1), { BackgroundColor3 = T.Element })
                        end)
                    end
                else
                    tween(mainBtn, TweenInfo.new(0.08), { BackgroundColor3 = T.AccentDark })
                    task.delay(0.12, function()
                        tween(mainBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.Element })
                    end)
                    func()
                end
            end)
            mainBtn.MouseEnter:Connect(function()
                tween(mainBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover })
            end)
            mainBtn.MouseLeave:Connect(function()
                tween(mainBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.Element })
            end)
        else
            mainBtn.TextColor3 = T.TextDark
        end

        if options.Tooltip then API:_Tooltip(mainBtn, options.Tooltip) end

        local btnObj = {}
        function btnObj:AddButton(subOptions)
            -- Adjust main btn to half, add sub button
            mainBtn.Size     = UDim2.new(0.5, -2, 1, 0)
            local subBtn = makeBtnFrame(row, subOptions.Text or "Sub",
                UDim2.new(0.5, -2, 1, 0), UDim2.new(0.5, 2, 0, 0))
            local subFunc = subOptions.Func or function() end
            local subDbl  = subOptions.DoubleClick or false
            local subLastClick = 0

            subBtn.MouseButton1Click:Connect(function()
                if subDbl then
                    local now = tick()
                    if now - subLastClick < 0.4 then subFunc(); subLastClick = 0
                    else subLastClick = now end
                else
                    subFunc()
                end
                tween(subBtn, TweenInfo.new(0.08), { BackgroundColor3 = T.AccentDark })
                task.delay(0.12, function()
                    tween(subBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.Element })
                end)
            end)
            subBtn.MouseEnter:Connect(function() tween(subBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover }) end)
            subBtn.MouseLeave:Connect(function() tween(subBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.Element }) end)
            if subOptions.Tooltip then API:_Tooltip(subBtn, subOptions.Tooltip) end
            return btnObj
        end

        return btnObj
    end

    -- ── Slider ──
    function API:AddSlider(idx, options)
        options = options or {}
        local text     = options.Text     or idx
        local default  = options.Default  or 0
        local min      = options.Min      or 0
        local max      = options.Max      or 100
        local suffix   = options.Suffix   or ""
        local rounding = options.Rounding or 0
        local compact  = options.Compact  or false
        local disabled = options.Disabled or false
        local cb       = options.Callback
        local fmtFn    = options.FormatDisplayValue

        local rowH = compact and 28 or 44
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, rowH),
            Parent                 = itemList,
        })

        local bg = create("Frame", {
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
                                   PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4) }),
        })

        if not compact then
            create("TextLabel", {
                Text             = text,
                TextColor3       = T.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                BackgroundTransparency = 1,
                Size             = UDim2.new(0.7, 0, 0, 16),
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = bg,
            })
        end

        local sliderBg = create("Frame", {
            BackgroundColor3 = T.ElementStroke,
            Size             = UDim2.new(1, 0, 0, 6),
            Position         = compact and UDim2.new(0, 0, 0.5, -3) or UDim2.new(0, 0, 1, -14),
            Parent           = bg,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1,0) }),
        })

        local fill = create("Frame", {
            BackgroundColor3 = T.SliderFill,
            Size             = UDim2.new(0, 0, 1, 0),
            Parent           = sliderBg,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1,0) }),
        })

        local handle = create("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = UDim2.new(0, -6, 0.5, -6),
            AnchorPoint      = Vector2.new(0, 0),
            Parent           = sliderBg,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1,0) }),
            create("UIStroke", { Color = T.Accent, Thickness = 2 }),
        })

        local valLabel = create("TextLabel", {
            Text             = tostring(round(default, rounding)) .. suffix,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.3, 0, 0, 16),
            Position         = UDim2.new(0.7, 0, 0, 0),
            TextXAlignment   = Enum.TextXAlignment.Right,
            Parent           = bg,
        })

        local value = default
        local draggingSlider = false

        local function updateSlider(v)
            v = round(clamp(v, min, max), rounding)
            value = v
            local pct = (v - min) / (max - min)
            tween(fill,   TweenInfo.new(0.05), { Size     = UDim2.new(pct, 0, 1, 0) })
            tween(handle, TweenInfo.new(0.05), { Position = UDim2.new(pct, -6, 0.5, -6) })
            local displayVal = fmtFn and fmtFn({ Max = max, Min = min }, v) or nil
            valLabel.Text = (displayVal or (tostring(v) .. suffix))
        end

        updateSlider(default)

        local sliderObj = {
            Value = value,
            OnChanged = function(self, fn)
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if self.Value ~= value then
                        self.Value = value
                        fn(value)
                    end
                end)
                table.insert(Library.Connections, conn)
                return self
            end,
            SetValue = function(self, v)
                updateSlider(v)
                self.Value = value
                if cb then cb(value) end
            end,
        }

        if not disabled then
            sliderBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then
                    draggingSlider = false
                    if cb then cb(value) end
                end
            end)
            RunService.Heartbeat:Connect(function()
                if draggingSlider then
                    local rel = (mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                    updateSlider(min + (max - min) * clamp(rel, 0, 1))
                    sliderObj.Value = value
                end
            end)
        end

        Library.Options[idx] = sliderObj
        if options.Tooltip then API:_Tooltip(bg, options.Tooltip) end
        return sliderObj
    end

    -- ── Input ──
    function API:AddInput(idx, options)
        options = options or {}
        local text        = options.Text        or idx
        local default     = options.Default      or ""
        local numeric     = options.Numeric      or false
        local finished    = options.Finished     or false
        local placeholder = options.Placeholder  or ""
        local clearFocus  = options.ClearTextOnFocus ~= false
        local cb          = options.Callback
        local maxLen      = options.MaxLength

        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 48),
            Parent                 = itemList,
        })

        local bg = create("Frame", {
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
                                   PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4) }),
        })

        create("TextLabel", {
            Text             = text,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 14),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = bg,
        })

        local inputBg = create("Frame", {
            BackgroundColor3 = T.Background,
            Size             = UDim2.new(1, 0, 0, 22),
            Position         = UDim2.new(0, 0, 1, -24),
            Parent           = bg,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6) }),
        })

        local box = create("TextBox", {
            Text             = default,
            PlaceholderText  = placeholder,
            PlaceholderColor3 = T.TextDark,
            TextColor3       = T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            ClearTextOnFocus = clearFocus,
            Parent           = inputBg,
        })

        if maxLen then
            box:GetPropertyChangedSignal("Text"):Connect(function()
                if #box.Text > maxLen then
                    box.Text = box.Text:sub(1, maxLen)
                end
            end)
        end

        box.Focused:Connect(function()
            tween(inputBg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover })
        end)
        box.FocusLost:Connect(function()
            tween(inputBg, TweenInfo.new(0.12), { BackgroundColor3 = T.Background })
        end)

        local callbacks = {}
        local inputObj = {
            Value = default,
            OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
            SetValue  = function(self, v)
                box.Text = v
                self.Value = v
                if cb then cb(v) end
                for _, fn in ipairs(callbacks) do fn(v) end
            end,
        }

        if finished then
            box.FocusLost:Connect(function(enter)
                if enter then
                    if numeric then
                        local n = tonumber(box.Text)
                        box.Text = n and tostring(n) or "0"
                    end
                    inputObj.Value = box.Text
                    if cb then cb(box.Text) end
                    for _, fn in ipairs(callbacks) do fn(box.Text) end
                end
            end)
        else
            box:GetPropertyChangedSignal("Text"):Connect(function()
                if numeric then
                    local clean = box.Text:gsub("[^%d%.%-]", "")
                    if clean ~= box.Text then box.Text = clean end
                end
                inputObj.Value = box.Text
                if cb then cb(box.Text) end
                for _, fn in ipairs(callbacks) do fn(box.Text) end
            end)
        end

        Library.Options[idx] = inputObj
        if options.Tooltip then API:_Tooltip(bg, options.Tooltip) end
        return inputObj
    end

    -- ── Dropdown ──
    function API:AddDropdown(idx, options)
        options = options or {}
        local text      = options.Text      or idx
        local values    = options.Values    or {}
        local default   = options.Default   or 1
        local multi     = options.Multi     or false
        local searchable= options.Searchable or false
        local disabled  = options.Disabled  or false
        local cb        = options.Callback
        local fmtFn     = options.FormatDisplayValue

        local selected = {}
        if multi then
            selected = {}
        else
            if type(default) == "number" then
                selected = values[default]
            else
                selected = default
            end
        end

        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Parent                 = itemList,
        })

        local bg = create("Frame", {
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
                                   PaddingTop = UDim.new(0,5), PaddingBottom = UDim.new(0,5) }),
        })

        create("TextLabel", {
            Text             = text,
            TextColor3       = T.TextDark,
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 14),
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = 1,
            Parent           = bg,
        })

        local function getDisplayText()
            if multi then
                local sel = {}
                for k in pairs(selected) do table.insert(sel, k) end
                return #sel == 0 and "None" or table.concat(sel, ", ")
            else
                if fmtFn and selected then
                    return fmtFn(selected) or selected
                end
                return selected or "Select..."
            end
        end

        local selector = create("Frame", {
            BackgroundColor3 = T.Background,
            Size             = UDim2.new(1, 0, 0, 24),
            LayoutOrder      = 2,
            Parent           = bg,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        local selectorText = create("TextLabel", {
            Text             = getDisplayText(),
            TextColor3       = T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -20, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextTruncate     = Enum.TextTruncate.AtEnd,
            Parent           = selector,
        })

        local arrow = create("TextLabel", {
            Text             = "▾",
            TextColor3       = T.TextDark,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0, 16, 1, 0),
            Position         = UDim2.new(1, -16, 0, 0),
            Parent           = selector,
        })

        local dropdownFrame = nil
        local open = false

        local function closeDropdown()
            if dropdownFrame then
                dropdownFrame:Destroy()
                dropdownFrame = nil
            end
            open = false
            tween(arrow, TweenInfo.new(0.12), { Rotation = 0 })
        end

        local function openDropdown()
            open = true
            tween(arrow, TweenInfo.new(0.12), { Rotation = 180 })

            dropdownFrame = create("Frame", {
                BackgroundColor3 = T.Background,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                Position         = UDim2.new(0, 0, 1, 4),
                ZIndex           = 10,
                Parent           = selector,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                create("UIStroke", { Color = T.ElementStroke, Thickness = 1 }),
                create("UIPadding", { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4) }),
            })

            local listLayout = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 2),
                Parent    = dropdownFrame,
            })

            local searchBox = nil
            if searchable then
                local sbg = create("Frame", {
                    BackgroundColor3 = T.Element,
                    Size             = UDim2.new(1, -8, 0, 22),
                    LayoutOrder      = 0,
                    Parent           = dropdownFrame,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0,4) }),
                    create("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6) }),
                })
                searchBox = create("TextBox", {
                    PlaceholderText   = "Search...",
                    PlaceholderColor3 = T.TextDark,
                    Text              = "",
                    TextColor3        = T.Text,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 11,
                    BackgroundTransparency = 1,
                    Size              = UDim2.new(1, 0, 1, 0),
                    Parent            = sbg,
                })
            end

            local function renderItems(filter)
                for _, c in ipairs(dropdownFrame:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, v in ipairs(values) do
                    local display = fmtFn and fmtFn(v) or v
                    if filter and filter ~= "" then
                        if not display:lower():find(filter:lower(), 1, true) then
                            continue
                        end
                    end

                    local isSelected = multi
                        and (selected[v] == true)
                        or  (selected == v)

                    local item = create("TextButton", {
                        Text             = display,
                        TextColor3       = isSelected and T.Accent or T.Text,
                        Font             = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                        TextSize         = 12,
                        BackgroundColor3 = isSelected and Color3.fromRGB(40,35,60) or Color3.fromRGB(0,0,0),
                        BackgroundTransparency = isSelected and 0 or 1,
                        Size             = UDim2.new(1, -8, 0, 24),
                        LayoutOrder      = i + 1,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        ZIndex           = 11,
                        Parent           = dropdownFrame,
                    }, {
                        create("UICorner",  { CornerRadius = UDim.new(0,4) }),
                        create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
                    })

                    item.MouseButton1Click:Connect(function()
                        if multi then
                            selected[v] = not selected[v] or nil
                        else
                            selected = v
                            closeDropdown()
                        end
                        selectorText.Text = getDisplayText()
                        if cb then
                            cb(multi and (function()
                                local t={}; for k in pairs(selected) do table.insert(t,k) end; return t
                            end)() or selected)
                        end
                        if not multi then return end
                        renderItems(searchBox and searchBox.Text or "")
                    end)
                    item.MouseEnter:Connect(function()
                        tween(item, TweenInfo.new(0.1), { BackgroundTransparency = 0, BackgroundColor3 = T.ElementHover })
                    end)
                    item.MouseLeave:Connect(function()
                        tween(item, TweenInfo.new(0.1), {
                            BackgroundTransparency = isSelected and 0 or 1,
                            BackgroundColor3       = isSelected and Color3.fromRGB(40,35,60) or T.ElementHover,
                        })
                    end)
                end
            end

            renderItems()

            if searchBox then
                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    renderItems(searchBox.Text)
                end)
            end
        end

        local selectorBtn = create("TextButton", {
            Text             = "",
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
            ZIndex           = 5,
            Parent           = selector,
        })
        selectorBtn.MouseButton1Click:Connect(function()
            if disabled then return end
            if open then closeDropdown() else openDropdown() end
        end)

        -- Auto-close when clicking outside
        UserInputService.InputBegan:Connect(function(inp)
            if open and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = inp.Position
                if dropdownFrame then
                    local abs = dropdownFrame.AbsolutePosition
                    local sz  = dropdownFrame.AbsoluteSize
                    if pos.X < abs.X or pos.X > abs.X + sz.X or
                       pos.Y < abs.Y or pos.Y > abs.Y + sz.Y then
                        closeDropdown()
                    end
                end
            end
        end)

        local dropObj = {
            Value = selected,
            OnChanged = function(self, fn)
                local prev = selected
                RunService.Heartbeat:Connect(function()
                    if selected ~= prev then
                        prev = selected
                        fn(selected)
                    end
                end)
                return self
            end,
            SetValue = function(self, v)
                if multi then
                    selected = {}
                    if type(v) == "table" then
                        for _, k in ipairs(v) do selected[k] = true end
                    else
                        selected[v] = true
                    end
                else
                    selected = v
                end
                self.Value = selected
                selectorText.Text = getDisplayText()
                if cb then cb(v) end
            end,
            SetValues = function(self, newVals)
                values = newVals
                selectorText.Text = getDisplayText()
            end,
        }

        Library.Options[idx] = dropObj
        if options.Tooltip then API:_Tooltip(bg, options.Tooltip) end
        return dropObj
    end

    -- ── ColorPicker ──
    function API:AddColorPicker(idx, options)
        options = options or {}
        local text        = options.Title       or options.Text or "Color"
        local default     = options.Default      or Color3.new(1, 0, 0)
        local transparency= options.Transparency
        local cb          = options.Callback

        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 28),
            Parent                 = itemList,
        })

        local bg = create("Frame", {
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        create("TextLabel", {
            Text             = text,
            TextColor3       = T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -40, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = bg,
        })

        local preview = create("TextButton", {
            Text             = "",
            BackgroundColor3 = default,
            Size             = UDim2.new(0, 24, 0, 18),
            Position         = UDim2.new(1, -24, 0.5, -9),
            Parent           = bg,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 4) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
        })

        local color    = default
        local trans    = transparency or 0
        local pickerOpen = false
        local pickerFrame = nil

        local callbacks = {}
        local cpObj = {
            Value = { Color = color, Transparency = trans },
            OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
            SetValue = function(self, v)
                if type(v) == "userdata" then
                    color = v
                else
                    color = v.Color or color
                    trans = v.Transparency or trans
                end
                preview.BackgroundColor3 = color
                self.Value = { Color = color, Transparency = trans }
                if cb then cb(color) end
                for _, fn in ipairs(callbacks) do fn(color) end
            end,
        }

        -- Simple picker popup (hue + saturation/value + optional transparency)
        local function openPicker()
            pickerOpen = true
            pickerFrame = create("Frame", {
                BackgroundColor3 = T.Background,
                Size             = UDim2.new(0, 180, 0, transparency ~= nil and 130 or 110),
                Position         = UDim2.new(1, 6, 0, 0),
                ZIndex           = 20,
                Parent           = bg,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                create("UIStroke", { Color = T.ElementStroke, Thickness = 1 }),
                create("UIPadding", { PaddingTop = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
                                       PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
            })

            -- Hue bar
            local hueGrad = create("Frame", {
                Size   = UDim2.new(1, 0, 0, 14),
                Parent = pickerFrame,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1,1)),
                        ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
                        ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
                        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1,1)),
                        ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
                        ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
                        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1,1)),
                    }),
                }),
            })

            local h, s, v2 = Color3.toHSV(color)
            local hueHandle = create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Size             = UDim2.new(0, 4, 1, 2),
                Position         = UDim2.new(h, -2, 0, -1),
                Parent           = hueGrad,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0,2) }),
            })

            -- SV square
            local svFrame = create("Frame", {
                Size     = UDim2.new(1, 0, 0, 60),
                Position = UDim2.new(0, 0, 0, 20),
                Parent   = pickerFrame,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0,4) }),
                create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
                    }),
                }),
            })

            -- Darkness overlay
            create("Frame", {
                BackgroundColor3 = Color3.new(0,0,0),
                BackgroundTransparency = 0,
                Size             = UDim2.new(1,0,1,0),
                Parent           = svFrame,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0,4) }),
                create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Rotation = 90,
                }),
            })

            local svHandle = create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(s, -5, 1-v2, -5),
                Parent           = svFrame,
            }, {
                create("UICorner",  { CornerRadius = UDim.new(1,0) }),
                create("UIStroke",  { Color = Color3.new(0,0,0), Thickness = 1 }),
            })

            local function updateColor()
                color = Color3.fromHSV(h, s, v2)
                preview.BackgroundColor3 = color
                cpObj.Value = { Color = color, Transparency = trans }
                if cb then cb(color) end
                for _, fn in ipairs(callbacks) do fn(color) end
            end

            local draggingHue = false
            local draggingSV  = false

            hueGrad.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end
            end)
            svFrame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = false; draggingSV = false
                end
            end)

            RunService.Heartbeat:Connect(function()
                if draggingHue then
                    h = clamp((mouse.X - hueGrad.AbsolutePosition.X) / hueGrad.AbsoluteSize.X, 0, 1)
                    hueHandle.Position = UDim2.new(h, -2, 0, -1)
                    updateColor()
                end
                if draggingSV then
                    s  = clamp((mouse.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                    v2 = 1 - clamp((mouse.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                    svHandle.Position = UDim2.new(s, -5, 1-v2, -5)
                    updateColor()
                end
            end)

            if transparency ~= nil then
                local transLabel = create("TextLabel", {
                    Text             = "Transparency",
                    TextColor3       = T.TextDark,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 10,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, 12),
                    Position         = UDim2.new(0, 0, 0, 86),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = pickerFrame,
                })
                local transBg = create("Frame", {
                    Size     = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 100),
                    Parent   = pickerFrame,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(1,0) }),
                    create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0)),
                    }),
                })
                local transHandle = create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size             = UDim2.new(0,8,0,8),
                    Position         = UDim2.new(trans, -4, 0.5, -4),
                    Parent           = transBg,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(1,0) }),
                })

                local draggingTrans = false
                transBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingTrans = true end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingTrans = false end
                end)
                RunService.Heartbeat:Connect(function()
                    if draggingTrans then
                        trans = clamp((mouse.X - transBg.AbsolutePosition.X) / transBg.AbsoluteSize.X, 0, 1)
                        transHandle.Position = UDim2.new(trans, -4, 0.5, -4)
                        cpObj.Value = { Color = color, Transparency = trans }
                        if cb then cb(color) end
                    end
                end)
            end
        end

        local function closePicker()
            if pickerFrame then pickerFrame:Destroy(); pickerFrame = nil end
            pickerOpen = false
        end

        preview.MouseButton1Click:Connect(function()
            if pickerOpen then closePicker() else openPicker() end
        end)

        UserInputService.InputBegan:Connect(function(inp)
            if pickerOpen and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if pickerFrame then
                    local abs = pickerFrame.AbsolutePosition
                    local sz  = pickerFrame.AbsoluteSize
                    local pos = inp.Position
                    if pos.X < abs.X or pos.X > abs.X + sz.X or
                       pos.Y < abs.Y or pos.Y > abs.Y + sz.Y then
                        task.delay(0.05, closePicker)
                    end
                end
            end
        end)

        Library.Options[idx] = cpObj
        if options.Tooltip then API:_Tooltip(bg, options.Tooltip) end
        return cpObj
    end

    -- Inline color picker (chained from toggle)
    function API:_AddColorPickerInline(parentRow, idx, options)
        return self:AddColorPicker(idx, options)
    end

    -- ── Keybind ──
    function API:AddKeybind(idx, options)
        options = options or {}
        local text     = options.Text     or idx
        local default  = options.Default  or Enum.KeyCode.Unknown
        local cb       = options.Callback

        local row = makeRow(28)
        local binding = default
        local listening = false

        local bg = create("Frame", {
            BackgroundColor3 = T.Element,
            Size             = UDim2.new(1, 0, 1, 0),
            Parent           = row,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
            create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
        })

        create("TextLabel", {
            Text             = text,
            TextColor3       = T.Text,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -80, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = bg,
        })

        local keyBtn = create("TextButton", {
            Text             = binding.Name,
            TextColor3       = T.Text,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 11,
            BackgroundColor3 = T.Background,
            Size             = UDim2.new(0, 72, 0, 20),
            Position         = UDim2.new(1, -72, 0.5, -10),
            Parent           = bg,
        }, {
            create("UICorner",  { CornerRadius = UDim.new(0, 4) }),
            create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
        })

        local keybindObj = {
            Value = binding,
            OnChanged = function(self, fn)
                local conn = UserInputService.InputBegan:Connect(function(inp, gp)
                    if not gp and inp.KeyCode == binding then fn(binding) end
                end)
                table.insert(Library.Connections, conn)
                return self
            end,
            SetValue = function(self, k)
                binding = k
                self.Value = k
                keyBtn.Text = k.Name
            end,
        }

        keyBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = T.Accent
            local conn
            conn = UserInputService.InputBegan:Connect(function(inp, gp)
                if not gp then
                    binding = inp.KeyCode
                    keybindObj.Value = binding
                    keyBtn.Text = binding.Name
                    keyBtn.TextColor3 = T.Text
                    listening = false
                    conn:Disconnect()
                    if cb then cb(binding) end
                end
            end)
        end)

        keyBtn.MouseEnter:Connect(function()
            tween(keyBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.ElementHover })
        end)
        keyBtn.MouseLeave:Connect(function()
            tween(keyBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.Background })
        end)

        Library.Options[idx] = keybindObj
        return keybindObj
    end

    -- ── Tooltip helper ──
    function API:_Tooltip(element, tipText)
        local tipFrame = nil
        element.MouseEnter:Connect(function()
            tipFrame = create("Frame", {
                BackgroundColor3 = T.TopBar,
                AutomaticSize    = Enum.AutomaticSize.XY,
                ZIndex           = 50,
                Parent           = element,
            }, {
                create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
                create("UIStroke",  { Color = T.ElementStroke, Thickness = 1 }),
                create("UIPadding", { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
                                       PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) }),
                create("TextLabel", {
                    Text             = tipText,
                    TextColor3       = T.TextDark,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    BackgroundTransparency = 1,
                    AutomaticSize    = Enum.AutomaticSize.XY,
                    ZIndex           = 51,
                }),
            })
            local mx, my = mouse.X, mouse.Y
            local ap = element.AbsolutePosition
            tipFrame.Position = UDim2.new(0, mx - ap.X + 8, 0, my - ap.Y + 8)
        end)
        element.MouseLeave:Connect(function()
            if tipFrame then tipFrame:Destroy(); tipFrame = nil end
        end)
    end

    return API
end

-- ─────────────────────────────────────────────
--  Cleanup
-- ─────────────────────────────────────────────
function Library:Destroy()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
    for _, win in ipairs(self.Windows) do
        win.ScreenGui:Destroy()
    end
    self.Windows = {}
    NotifGui:Destroy()
end

return Library
