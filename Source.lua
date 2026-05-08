local Library = {}
Library.__index = Library

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local C = {
    Bg         = Color3.fromRGB(8,   6,  18),
    BgElement  = Color3.fromRGB(16,  11, 32),
    BgHover    = Color3.fromRGB(28,  18, 52),
    TabInact   = Color3.fromRGB(22,  15, 42),
    TrackOff   = Color3.fromRGB(35,  24, 60),
    Knob       = Color3.fromRGB(255, 255, 255),
    Text       = Color3.fromRGB(245, 235, 255),
    TextDim    = Color3.fromRGB(160, 120, 200),
    Purple     = Color3.fromRGB(140,  40, 230),
    Pink       = Color3.fromRGB(230,  60, 180),
    PurpleDark = Color3.fromRGB(100,  20, 180),
    PinkDark   = Color3.fromRGB(180,  30, 130),
}

local TF = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TM = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tw(o, i, p) TweenService:Create(o, i, p):Play() end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p
end

local function gradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent   = p
    return g
end

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function makeDraggable(obj, handle)
    handle = handle or obj
    local drag, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag      = true
            dragStart = inp.Position
            startPos  = obj.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp == dragInput then
            local d = inp.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

function Library:CreateWindow(title)
    local self = setmetatable({}, Library)
    self._tabs = {}
    self._open = true

    local gui = Instance.new("ScreenGui")
    gui.Name           = "UILib"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent         = PlayerGui

    local win = Instance.new("Frame")
    win.Name             = "Win"
    win.Size             = UDim2.new(0, 500, 0, 340)
    win.Position         = UDim2.new(0.5, -250, 0.5, -170)
    win.BackgroundColor3 = C.Bg
    win.BorderSizePixel  = 0
    win.ClipsDescendants = true
    win.Parent           = gui
    corner(win, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness    = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    gradient(stroke, C.Purple, C.Pink, 90)
    stroke.Parent = win

    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint          = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position             = UDim2.new(0.5, 0, 0.5, 6)
    shadow.Size                 = UDim2.new(1, 30, 1, 30)
    shadow.Image                = "rbxassetid://6015897843"
    shadow.ImageColor3          = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency    = 0.45
    shadow.ScaleType            = Enum.ScaleType.Slice
    shadow.SliceCenter          = Rect.new(49, 49, 450, 450)
    shadow.ZIndex               = -1
    shadow.Parent               = win

    local topBar = Instance.new("Frame")
    topBar.Name             = "TopBar"
    topBar.Size             = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = C.PurpleDark
    topBar.BorderSizePixel  = 0
    topBar.Parent           = win
    corner(topBar, 12)
    gradient(topBar, C.Purple, C.Pink, 0)

    local topFix = Instance.new("Frame")
    topFix.Size             = UDim2.new(1, 0, 0, 12)
    topFix.Position         = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = C.Pink
    topFix.BorderSizePixel  = 0
    topFix.Parent           = topBar
    gradient(topFix, C.Purple, C.Pink, 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text              = "✦  " .. (title or "Menü")
    titleLbl.Font              = Enum.Font.GothamBold
    titleLbl.TextSize          = 15
    titleLbl.TextColor3        = C.Text
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size              = UDim2.new(1, -50, 1, 0)
    titleLbl.Position          = UDim2.new(0, 14, 0, 0)
    titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
    titleLbl.Parent            = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text             = "✕"
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.TextSize         = 13
    closeBtn.TextColor3       = C.Text
    closeBtn.BackgroundColor3 = C.PurpleDark
    closeBtn.Size             = UDim2.new(0, 26, 0, 26)
    closeBtn.Position         = UDim2.new(1, -34, 0.5, -13)
    closeBtn.BorderSizePixel  = 0
    closeBtn.Parent           = topBar
    corner(closeBtn, 6)
    gradient(closeBtn, C.Purple, C.Pink, 45)

    makeDraggable(win, topBar)

    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, 32)
    tabBar.Position         = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = Color3.fromRGB(12, 8, 25)
    tabBar.BorderSizePixel  = 0
    tabBar.Parent           = win

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.SortOrder     = Enum.SortOrder.LayoutOrder
    tabList.Padding       = UDim.new(0, 4)
    tabList.Parent        = tabBar
    pad(tabBar, 4, 4, 8, 8)

    local divLine = Instance.new("Frame")
    divLine.Size            = UDim2.new(1, 0, 0, 1)
    divLine.Position        = UDim2.new(0, 0, 0, 72)
    divLine.BackgroundColor3 = C.Purple
    divLine.BorderSizePixel = 0
    divLine.Parent          = win
    gradient(divLine, C.Purple, C.Pink, 0)

    local content = Instance.new("Frame")
    content.Name                 = "Content"
    content.Size                 = UDim2.new(1, 0, 1, -74)
    content.Position             = UDim2.new(0, 0, 0, 74)
    content.BackgroundTransparency = 1
    content.ClipsDescendants     = true
    content.Parent               = win

    local function setOpen(v)
        self._open = v
        if v then
            win.Visible = true
            tw(win, TM, { Size = UDim2.new(0, 500, 0, 340) })
        else
            tw(win, TM, { Size = UDim2.new(0, 500, 0, 0) })
            task.delay(0.24, function()
                if not self._open then win.Visible = false end
            end)
        end
    end

    local function toggle() setOpen(not self._open) end

    closeBtn.MouseButton1Click:Connect(toggle)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then toggle() end
    end)

    local mobGui = Instance.new("ScreenGui")
    mobGui.Name           = "UILibMob"
    mobGui.ResetOnSpawn   = false
    mobGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobGui.IgnoreGuiInset = true
    mobGui.Enabled        = isMobile()
    mobGui.Parent         = PlayerGui

    local mobBtn = Instance.new("TextButton")
    mobBtn.Text             = "✦"
    mobBtn.Font             = Enum.Font.GothamBold
    mobBtn.TextSize         = 20
    mobBtn.TextColor3       = C.Text
    mobBtn.BackgroundColor3 = C.Purple
    mobBtn.Size             = UDim2.new(0, 52, 0, 52)
    mobBtn.Position         = UDim2.new(1, -66, 1, -80)
    mobBtn.BorderSizePixel  = 0
    mobBtn.Parent           = mobGui
    corner(mobBtn, 14)
    gradient(mobBtn, C.Purple, C.Pink, 135)

    local mobStroke = Instance.new("UIStroke")
    mobStroke.Thickness = 1.5
    gradient(mobStroke, C.Pink, C.Purple, 135)
    mobStroke.Parent = mobBtn

    local mobShadow = Instance.new("ImageLabel")
    mobShadow.BackgroundTransparency = 1
    mobShadow.AnchorPoint   = Vector2.new(0.5, 0.5)
    mobShadow.Position      = UDim2.new(0.5, 0, 0.5, 4)
    mobShadow.Size          = UDim2.new(1, 22, 1, 22)
    mobShadow.Image         = "rbxassetid://6015897843"
    mobShadow.ImageColor3   = C.Purple
    mobShadow.ImageTransparency = 0.5
    mobShadow.ScaleType     = Enum.ScaleType.Slice
    mobShadow.SliceCenter   = Rect.new(49, 49, 450, 450)
    mobShadow.ZIndex        = -1
    mobShadow.Parent        = mobBtn

    makeDraggable(mobBtn, mobBtn)

    local clicking = false
    mobBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            clicking = true
        end
    end)
    mobBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and clicking then
            clicking = false
            toggle()
        end
    end)

    function self:CreateTab(name)
        local tab = { _count = 0 }

        local tabBtn = Instance.new("TextButton")
        tabBtn.Text             = name
        tabBtn.Font             = Enum.Font.GothamMedium
        tabBtn.TextSize         = 12
        tabBtn.TextColor3       = C.TextDim
        tabBtn.BackgroundColor3 = C.TabInact
        tabBtn.Size             = UDim2.new(0, 84, 1, 0)
        tabBtn.BorderSizePixel  = 0
        tabBtn.LayoutOrder      = #self._tabs + 1
        tabBtn.Parent           = tabBar
        corner(tabBtn, 6)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size                  = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel       = 0
        scroll.ScrollBarThickness    = 3
        scroll.ScrollBarImageColor3  = C.Purple
        scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
        scroll.Visible               = false
        scroll.Parent                = content

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding   = UDim.new(0, 5)
        layout.Parent    = scroll
        pad(scroll, 8, 8, 10, 10)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        local function activate()
            for _, t in ipairs(self._tabs) do
                tw(t._btn, TF, { BackgroundColor3 = C.TabInact, TextColor3 = C.TextDim })
                local g = t._btn:FindFirstChildOfClass("UIGradient")
                if g then g:Destroy() end
                t._scroll.Visible = false
            end
            tw(tabBtn, TF, { BackgroundColor3 = C.Purple, TextColor3 = C.Text })
            gradient(tabBtn, C.Purple, C.Pink, 0)
            scroll.Visible = true
            self._activeTab = tab
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tab._btn    = tabBtn
        tab._scroll = scroll
        tab._layout = layout

        table.insert(self._tabs, tab)
        if #self._tabs == 1 then activate() end

        function tab:CreateButton(label, cb)
            tab._count += 1
            local row = Instance.new("Frame")
            row.Name             = "Btn_" .. label
            row.Size             = UDim2.new(1, 0, 0, 36)
            row.BackgroundColor3 = C.BgElement
            row.BorderSizePixel  = 0
            row.LayoutOrder      = tab._count
            row.Parent           = scroll
            corner(row, 8)

            local lbl = Instance.new("TextLabel")
            lbl.Text                   = label
            lbl.Font                   = Enum.Font.GothamMedium
            lbl.TextSize               = 13
            lbl.TextColor3             = C.Text
            lbl.BackgroundTransparency = 1
            lbl.Size                   = UDim2.new(1, -110, 1, 0)
            lbl.Position               = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.Parent                 = row

            local btn = Instance.new("TextButton")
            btn.Text             = label
            btn.Font             = Enum.Font.GothamMedium
            btn.TextSize         = 12
            btn.TextColor3       = C.Text
            btn.BackgroundColor3 = C.Purple
            btn.Size             = UDim2.new(0, 80, 0, 24)
            btn.Position         = UDim2.new(1, -90, 0.5, -12)
            btn.BorderSizePixel  = 0
            btn.Parent           = row
            corner(btn, 6)
            gradient(btn, C.Purple, C.Pink, 0)

            btn.MouseEnter:Connect(function()
                tw(row, TF, { BackgroundColor3 = C.BgHover })
                tw(btn, TF, { BackgroundColor3 = C.PinkDark })
            end)
            btn.MouseLeave:Connect(function()
                tw(row, TF, { BackgroundColor3 = C.BgElement })
                tw(btn, TF, { BackgroundColor3 = C.Purple })
            end)
            btn.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
            return btn
        end

        function tab:CreateToggle(label, default, cb)
            tab._count += 1
            local val = default or false

            local row = Instance.new("Frame")
            row.Name             = "Tog_" .. label
            row.Size             = UDim2.new(1, 0, 0, 36)
            row.BackgroundColor3 = C.BgElement
            row.BorderSizePixel  = 0
            row.LayoutOrder      = tab._count
            row.Parent           = scroll
            corner(row, 8)

            local lbl = Instance.new("TextLabel")
            lbl.Text                   = label
            lbl.Font                   = Enum.Font.GothamMedium
            lbl.TextSize               = 13
            lbl.TextColor3             = C.Text
            lbl.BackgroundTransparency = 1
            lbl.Size                   = UDim2.new(1, -70, 1, 0)
            lbl.Position               = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.Parent                 = row

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(0, 42, 0, 22)
            track.Position         = UDim2.new(1, -52, 0.5, -11)
            track.BackgroundColor3 = val and C.Purple or C.TrackOff
            track.BorderSizePixel  = 0
            track.Parent           = row
            corner(track, 11)
            local trackGrad
            if val then trackGrad = gradient(track, C.Purple, C.Pink, 0) end

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
            knob.BackgroundColor3 = C.Knob
            knob.BorderSizePixel  = 0
            knob.Parent           = track
            corner(knob, 8)

            local function refresh()
                if val then
                    tw(track, TF, { BackgroundColor3 = C.Purple })
                    if not track:FindFirstChildOfClass("UIGradient") then
                        trackGrad = gradient(track, C.Purple, C.Pink, 0)
                    end
                else
                    local g = track:FindFirstChildOfClass("UIGradient")
                    if g then g:Destroy() end
                    tw(track, TF, { BackgroundColor3 = C.TrackOff })
                end
                tw(knob, TF, {
                    Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
                })
            end

            local hit = Instance.new("TextButton")
            hit.Text                   = ""
            hit.BackgroundTransparency = 1
            hit.Size                   = UDim2.new(1, 0, 1, 0)
            hit.Parent                 = row
            hit.MouseEnter:Connect(function() tw(row, TF, { BackgroundColor3 = C.BgHover }) end)
            hit.MouseLeave:Connect(function() tw(row, TF, { BackgroundColor3 = C.BgElement }) end)
            hit.MouseButton1Click:Connect(function()
                val = not val
                refresh()
                if cb then cb(val) end
            end)

            local obj = {}
            function obj:SetValue(v) val = v; refresh(); if cb then cb(val) end end
            function obj:GetValue() return val end
            return obj
        end

        function tab:CreateSlider(label, min, max, default, cb)
            tab._count += 1
            min = min or 0; max = max or 100; default = default or min
            local val = math.clamp(default, min, max)

            local row = Instance.new("Frame")
            row.Name             = "Slid_" .. label
            row.Size             = UDim2.new(1, 0, 0, 50)
            row.BackgroundColor3 = C.BgElement
            row.BorderSizePixel  = 0
            row.LayoutOrder      = tab._count
            row.Parent           = scroll
            corner(row, 8)

            local lbl = Instance.new("TextLabel")
            lbl.Text                   = label
            lbl.Font                   = Enum.Font.GothamMedium
            lbl.TextSize               = 13
            lbl.TextColor3             = C.Text
            lbl.BackgroundTransparency = 1
            lbl.Size                   = UDim2.new(0.6, 0, 0, 22)
            lbl.Position               = UDim2.new(0, 12, 0, 6)
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.Parent                 = row

            local valLbl = Instance.new("TextLabel")
            valLbl.Text                   = tostring(math.round(val))
            valLbl.Font                   = Enum.Font.GothamBold
            valLbl.TextSize               = 12
            valLbl.TextColor3             = C.Pink
            valLbl.BackgroundTransparency = 1
            valLbl.Size                   = UDim2.new(0.4, -12, 0, 22)
            valLbl.Position               = UDim2.new(0.6, 0, 0, 6)
            valLbl.TextXAlignment         = Enum.TextXAlignment.Right
            valLbl.Parent                 = row

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -24, 0, 6)
            track.Position         = UDim2.new(0, 12, 1, -18)
            track.BackgroundColor3 = C.TrackOff
            track.BorderSizePixel  = 0
            track.Parent           = row
            corner(track, 3)

            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new((val - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = C.Purple
            fill.BorderSizePixel  = 0
            fill.Parent           = track
            corner(fill, 3)
            gradient(fill, C.Purple, C.Pink, 0)

            local knobSlid = Instance.new("Frame")
            knobSlid.Size             = UDim2.new(0, 14, 0, 14)
            knobSlid.AnchorPoint      = Vector2.new(0.5, 0.5)
            knobSlid.Position         = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
            knobSlid.BackgroundColor3 = C.Knob
            knobSlid.BorderSizePixel  = 0
            knobSlid.ZIndex           = 2
            knobSlid.Parent           = track
            corner(knobSlid, 7)
            local kStroke = Instance.new("UIStroke")
            kStroke.Thickness = 1.5
            gradient(kStroke, C.Purple, C.Pink, 90)
            kStroke.Parent = knobSlid

            local function setVal(v)
                val = math.clamp(v, min, max)
                local pct = (val - min) / (max - min)
                fill.Size          = UDim2.new(pct, 0, 1, 0)
                knobSlid.Position  = UDim2.new(pct, 0, 0.5, 0)
                valLbl.Text        = tostring(math.round(val))
                if cb then cb(math.round(val)) end
            end

            local sliding = false
            local hitSlid = Instance.new("TextButton")
            hitSlid.Text                   = ""
            hitSlid.BackgroundTransparency = 1
            hitSlid.Size                   = UDim2.new(1, 0, 1, 0)
            hitSlid.ZIndex                 = 3
            hitSlid.Parent                 = track

            hitSlid.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            hitSlid.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not sliding then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    local abs   = track.AbsolutePosition
                    local size  = track.AbsoluteSize
                    local relX  = math.clamp((inp.Position.X - abs.X) / size.X, 0, 1)
                    setVal(min + relX * (max - min))
                end
            end)

            row.MouseEnter:Connect(function() tw(row, TF, { BackgroundColor3 = C.BgHover }) end)
            row.MouseLeave:Connect(function() tw(row, TF, { BackgroundColor3 = C.BgElement }) end)

            local obj = {}
            function obj:SetValue(v) setVal(v) end
            function obj:GetValue() return math.round(val) end
            return obj
        end

        return tab
    end

    return self
end

return Library
