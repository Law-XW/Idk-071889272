--[[
    RobloxUI Library
    
    Verwendung / Usage:
    
    local Library = require(path.to.UILibrary)
    local Window = Library:CreateWindow("Mein Menü")
    
    local Tab = Window:CreateTab("Allgemein")
    Tab:CreateButton("Klick mich", function()
        print("Button geklickt!")
    end)
    Tab:CreateToggle("Speedhack", false, function(value)
        print("Toggle:", value)
    end)
    
    Steuerung:
    - PC:     Rechter Shift → Menü auf/zu
    - Handy:  Button unten rechts → Menü auf/zu
]]

local Library = {}
Library.__index = Library

-- Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Farben / Design
local COLORS = {
    Background   = Color3.fromRGB(18, 18, 24),
    TopBar       = Color3.fromRGB(25, 25, 35),
    TabBar       = Color3.fromRGB(20, 20, 30),
    TabActive    = Color3.fromRGB(99, 102, 241),
    TabInactive  = Color3.fromRGB(40, 40, 56),
    Element      = Color3.fromRGB(30, 30, 44),
    ElementHover = Color3.fromRGB(45, 45, 65),
    ButtonColor  = Color3.fromRGB(99, 102, 241),
    ButtonHover  = Color3.fromRGB(120, 123, 255),
    ToggleOff    = Color3.fromRGB(60, 60, 80),
    ToggleOn     = Color3.fromRGB(99, 102, 241),
    ToggleKnob   = Color3.fromRGB(255, 255, 255),
    Text         = Color3.fromRGB(230, 230, 240),
    TextDim      = Color3.fromRGB(140, 140, 165),
    Title        = Color3.fromRGB(255, 255, 255),
    OpenButton   = Color3.fromRGB(99, 102, 241),
    OpenButtonHover = Color3.fromRGB(120, 123, 255),
    Divider      = Color3.fromRGB(40, 40, 58),
}

local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─────────────────────────────────────────────
-- Hilfsfunktionen / Helpers
-- ─────────────────────────────────────────────

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

local function newLabel(text, size, color, parent)
    local l = Instance.new("TextLabel")
    l.Text              = text
    l.TextSize          = size or 14
    l.TextColor3        = color or COLORS.Text
    l.Font              = Enum.Font.GothamMedium
    l.BackgroundTransparency = 1
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.TextYAlignment    = Enum.TextYAlignment.Center
    l.Size              = UDim2.new(1, 0, 1, 0)
    l.Parent            = parent
    return l
end

-- ─────────────────────────────────────────────
-- Library:CreateWindow
-- ─────────────────────────────────────────────

function Library:CreateWindow(title)
    local self = setmetatable({}, Library)
    self._tabs      = {}
    self._activeTab = nil
    self._open      = true

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name              = "RobloxUILib"
    screenGui.ResetOnSpawn      = false
    screenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset    = true
    screenGui.Parent            = PlayerGui

    -- ── Haupt-Fenster ────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name              = "MainFrame"
    mainFrame.Size              = UDim2.new(0, 400, 0, 520)
    mainFrame.Position          = UDim2.new(0.5, -200, 0.5, -260)
    mainFrame.BackgroundColor3  = COLORS.Background
    mainFrame.BorderSizePixel   = 0
    mainFrame.ClipsDescendants  = true
    mainFrame.Parent            = screenGui
    makeCorner(mainFrame, 10)

    -- Schatten (Shadow)
    local shadow = Instance.new("ImageLabel")
    shadow.Name                 = "Shadow"
    shadow.AnchorPoint          = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position             = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size                 = UDim2.new(1, 24, 1, 24)
    shadow.Image                = "rbxassetid://6015897843"
    shadow.ImageColor3          = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency    = 0.55
    shadow.ScaleType            = Enum.ScaleType.Slice
    shadow.SliceCenter          = Rect.new(49, 49, 450, 450)
    shadow.ZIndex               = -1
    shadow.Parent               = mainFrame

    -- ── Titelzeile ───────────────────────────
    local topBar = Instance.new("Frame")
    topBar.Name             = "TopBar"
    topBar.Size             = UDim2.new(1, 0, 0, 44)
    topBar.BackgroundColor3 = COLORS.TopBar
    topBar.BorderSizePixel  = 0
    topBar.Parent           = mainFrame
    makeCorner(topBar, 10)

    -- Runde untere Ecken des TopBar reparieren
    local topBarFix = Instance.new("Frame")
    topBarFix.Size             = UDim2.new(1, 0, 0, 10)
    topBarFix.Position         = UDim2.new(0, 0, 1, -10)
    topBarFix.BackgroundColor3 = COLORS.TopBar
    topBarFix.BorderSizePixel  = 0
    topBarFix.Parent           = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text             = title or "Menü"
    titleLabel.Font             = Enum.Font.GothamBold
    titleLabel.TextSize         = 16
    titleLabel.TextColor3       = COLORS.Title
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size             = UDim2.new(1, -20, 1, 0)
    titleLabel.Position         = UDim2.new(0, 16, 0, 0)
    titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
    titleLabel.Parent           = topBar

    -- Schließen-Button (X) oben rechts
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text           = "✕"
    closeBtn.Font           = Enum.Font.GothamBold
    closeBtn.TextSize       = 14
    closeBtn.TextColor3     = COLORS.TextDim
    closeBtn.BackgroundColor3 = COLORS.TabInactive
    closeBtn.Size           = UDim2.new(0, 28, 0, 28)
    closeBtn.Position       = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent         = topBar
    makeCorner(closeBtn, 6)

    -- Draggable
    do
        local dragging, dragInput, dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        topBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ── Tab-Leiste ───────────────────────────
    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, 36)
    tabBar.Position         = UDim2.new(0, 0, 0, 44)
    tabBar.BackgroundColor3 = COLORS.TabBar
    tabBar.BorderSizePixel  = 0
    tabBar.Parent           = mainFrame

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection   = Enum.FillDirection.Horizontal
    tabList.SortOrder       = Enum.SortOrder.LayoutOrder
    tabList.Padding         = UDim.new(0, 4)
    tabList.Parent          = tabBar
    makePadding(tabBar, 4, 4, 8, 8)

    -- Trennlinie unter Tab-Leiste
    local divider = Instance.new("Frame")
    divider.Size            = UDim2.new(1, 0, 0, 1)
    divider.Position        = UDim2.new(0, 0, 0, 80)
    divider.BackgroundColor3 = COLORS.Divider
    divider.BorderSizePixel = 0
    divider.Parent          = mainFrame

    -- ── Content-Bereich ──────────────────────
    local contentHolder = Instance.new("Frame")
    contentHolder.Name          = "ContentHolder"
    contentHolder.Size          = UDim2.new(1, 0, 1, -82)
    contentHolder.Position      = UDim2.new(0, 0, 0, 82)
    contentHolder.BackgroundTransparency = 1
    contentHolder.ClipsDescendants = true
    contentHolder.Parent        = mainFrame

    -- ── Open/Close-Steuerung ─────────────────
    local function setOpen(val)
        self._open = val
        if val then
            mainFrame.Visible = true
            tween(mainFrame, TWEEN_MED, {
                Size     = UDim2.new(0, 400, 0, 520),
                Position = UDim2.new(0.5, -200, 0.5, -260),
            })
        else
            tween(mainFrame, TWEEN_MED, {
                Size = UDim2.new(0, 400, 0, 0),
            })
            task.delay(0.26, function()
                if not self._open then
                    mainFrame.Visible = false
                end
            end)
        end
    end

    local function toggle()
        setOpen(not self._open)
    end

    -- Close-Button im TopBar
    closeBtn.MouseButton1Click:Connect(toggle)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TWEEN_FAST, { TextColor3 = COLORS.Text })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TWEEN_FAST, { TextColor3 = COLORS.TextDim })
    end)

    -- PC: Rechter Shift
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggle()
        end
    end)

    -- ── Mobiler Öffnen-Button ────────────────
    local openBtnGui = Instance.new("ScreenGui")
    openBtnGui.Name            = "UILibOpenButton"
    openBtnGui.ResetOnSpawn    = false
    openBtnGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    openBtnGui.IgnoreGuiInset  = true
    openBtnGui.Enabled         = isMobile()
    openBtnGui.Parent          = PlayerGui

    local openBtn = Instance.new("TextButton")
    openBtn.Text            = "☰"
    openBtn.Font            = Enum.Font.GothamBold
    openBtn.TextSize        = 22
    openBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
    openBtn.BackgroundColor3 = COLORS.OpenButton
    openBtn.Size            = UDim2.new(0, 54, 0, 54)
    openBtn.Position        = UDim2.new(1, -68, 1, -80)
    openBtn.BorderSizePixel = 0
    openBtn.Parent          = openBtnGui
    makeCorner(openBtn, 14)

    -- Schatten für mobilen Button
    local mobShadow = Instance.new("ImageLabel")
    mobShadow.BackgroundTransparency = 1
    mobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    mobShadow.Position    = UDim2.new(0.5, 0, 0.5, 3)
    mobShadow.Size        = UDim2.new(1, 20, 1, 20)
    mobShadow.Image       = "rbxassetid://6015897843"
    mobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    mobShadow.ImageTransparency = 0.6
    mobShadow.ScaleType   = Enum.ScaleType.Slice
    mobShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    mobShadow.ZIndex      = -1
    mobShadow.Parent      = openBtn

    openBtn.MouseButton1Click:Connect(function()
        toggle()
        tween(openBtn, TWEEN_FAST, { BackgroundColor3 = COLORS.OpenButtonHover })
        task.delay(0.15, function()
            tween(openBtn, TWEEN_FAST, { BackgroundColor3 = COLORS.OpenButton })
        end)
    end)

    -- ── Tab erstellen ────────────────────────
    function self:CreateTab(name)
        local tab = {}
        tab._elements = {}

        -- Tab-Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Text             = name
        tabBtn.Font             = Enum.Font.GothamMedium
        tabBtn.TextSize         = 13
        tabBtn.TextColor3       = COLORS.TextDim
        tabBtn.BackgroundColor3 = COLORS.TabInactive
        tabBtn.Size             = UDim2.new(0, 90, 1, 0)
        tabBtn.BorderSizePixel  = 0
        tabBtn.LayoutOrder      = #self._tabs + 1
        tabBtn.Parent           = tabBar
        makeCorner(tabBtn, 6)

        -- Scroll-Container für Elemente
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name                = name .. "Scroll"
        scrollFrame.Size                = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel     = 0
        scrollFrame.ScrollBarThickness  = 3
        scrollFrame.ScrollBarImageColor3 = COLORS.TabActive
        scrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible             = false
        scrollFrame.Parent              = contentHolder

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder   = Enum.SortOrder.LayoutOrder
        listLayout.Padding     = UDim.new(0, 6)
        listLayout.Parent      = scrollFrame
        makePadding(scrollFrame, 10, 10, 10, 10)

        -- Canvas-Größe automatisch anpassen
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0,
                listLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Tab aktivieren
        local function activate()
            -- Alle anderen deaktivieren
            for _, t in ipairs(self._tabs) do
                tween(t._btn, TWEEN_FAST, {
                    BackgroundColor3 = COLORS.TabInactive,
                    TextColor3       = COLORS.TextDim,
                })
                t._scroll.Visible = false
            end
            -- Diesen aktivieren
            tween(tabBtn, TWEEN_FAST, {
                BackgroundColor3 = COLORS.TabActive,
                TextColor3       = COLORS.Title,
            })
            scrollFrame.Visible = true
            self._activeTab = tab
        end

        tabBtn.MouseButton1Click:Connect(activate)

        tab._btn    = tabBtn
        tab._scroll = scrollFrame
        tab._layout = listLayout
        tab._count  = 0

        table.insert(self._tabs, tab)

        -- Ersten Tab direkt aktivieren
        if #self._tabs == 1 then
            activate()
        end

        -- ── Button ──────────────────────────
        function tab:CreateButton(label, callback)
            tab._count += 1
            local row = Instance.new("Frame")
            row.Name            = "Button_" .. label
            row.Size            = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = COLORS.Element
            row.BorderSizePixel = 0
            row.LayoutOrder     = tab._count
            row.Parent          = scrollFrame
            makeCorner(row, 7)

            local btn = Instance.new("TextButton")
            btn.Text            = label
            btn.Font            = Enum.Font.GothamMedium
            btn.TextSize        = 14
            btn.TextColor3      = COLORS.Title
            btn.BackgroundColor3 = COLORS.ButtonColor
            btn.Size            = UDim2.new(0, 90, 0, 28)
            btn.Position        = UDim2.new(1, -100, 0.5, -14)
            btn.BorderSizePixel = 0
            btn.Parent          = row
            makeCorner(btn, 6)

            local rowLabel = newLabel(label, 14, COLORS.Text, row)
            rowLabel.Position = UDim2.new(0, 12, 0, 0)
            rowLabel.Size     = UDim2.new(1, -120, 1, 0)

            btn.MouseEnter:Connect(function()
                tween(btn, TWEEN_FAST, { BackgroundColor3 = COLORS.ButtonHover })
                tween(row, TWEEN_FAST, { BackgroundColor3 = COLORS.ElementHover })
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, TWEEN_FAST, { BackgroundColor3 = COLORS.ButtonColor })
                tween(row, TWEEN_FAST, { BackgroundColor3 = COLORS.Element })
            end)
            btn.MouseButton1Click:Connect(function()
                tween(btn, TWEEN_FAST, { BackgroundColor3 = COLORS.TabInactive })
                task.delay(0.1, function()
                    tween(btn, TWEEN_FAST, { BackgroundColor3 = COLORS.ButtonColor })
                end)
                if callback then callback() end
            end)

            return btn
        end

        -- ── Toggle ──────────────────────────
        function tab:CreateToggle(label, default, callback)
            tab._count += 1
            local value = default or false

            local row = Instance.new("Frame")
            row.Name            = "Toggle_" .. label
            row.Size            = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = COLORS.Element
            row.BorderSizePixel = 0
            row.LayoutOrder     = tab._count
            row.Parent          = scrollFrame
            makeCorner(row, 7)

            local rowLabel = newLabel(label, 14, COLORS.Text, row)
            rowLabel.Position = UDim2.new(0, 12, 0, 0)
            rowLabel.Size     = UDim2.new(1, -70, 1, 0)

            -- Toggle-Hintergrund
            local track = Instance.new("Frame")
            track.Size            = UDim2.new(0, 44, 0, 24)
            track.Position        = UDim2.new(1, -56, 0.5, -12)
            track.BackgroundColor3 = value and COLORS.ToggleOn or COLORS.ToggleOff
            track.BorderSizePixel = 0
            track.Parent          = row
            makeCorner(track, 12)

            -- Toggle-Knopf
            local knob = Instance.new("Frame")
            knob.Size            = UDim2.new(0, 18, 0, 18)
            knob.Position        = value
                and UDim2.new(1, -21, 0.5, -9)
                or  UDim2.new(0, 3,   0.5, -9)
            knob.BackgroundColor3 = COLORS.ToggleKnob
            knob.BorderSizePixel = 0
            knob.Parent          = track
            makeCorner(knob, 9)

            local function updateVisual()
                tween(track, TWEEN_FAST, {
                    BackgroundColor3 = value and COLORS.ToggleOn or COLORS.ToggleOff
                })
                tween(knob, TWEEN_FAST, {
                    Position = value
                        and UDim2.new(1, -21, 0.5, -9)
                        or  UDim2.new(0, 3,   0.5, -9)
                })
            end

            -- Klickbereich
            local hitbox = Instance.new("TextButton")
            hitbox.Text             = ""
            hitbox.BackgroundTransparency = 1
            hitbox.Size             = UDim2.new(1, 0, 1, 0)
            hitbox.Parent           = row

            hitbox.MouseEnter:Connect(function()
                tween(row, TWEEN_FAST, { BackgroundColor3 = COLORS.ElementHover })
            end)
            hitbox.MouseLeave:Connect(function()
                tween(row, TWEEN_FAST, { BackgroundColor3 = COLORS.Element })
            end)
            hitbox.MouseButton1Click:Connect(function()
                value = not value
                updateVisual()
                if callback then callback(value) end
            end)

            -- Getter/Setter
            local toggleObj = {}
            function toggleObj:SetValue(v)
                value = v
                updateVisual()
                if callback then callback(value) end
            end
            function toggleObj:GetValue()
                return value
            end

            return toggleObj
        end

        return tab
    end

    return self
end

return Library
