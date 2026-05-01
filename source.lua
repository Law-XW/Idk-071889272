local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function tw(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function make(class, props, children)
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

local function clampN(n, a, b)
	return math.max(a, math.min(b, n))
end

local function roundN(n, d)
	d = d or 0
	local m = 10 ^ d
	return math.floor(n * m + 0.5) / m
end

local function applyGradient(frame, c1, c2, rot)
	make("UIGradient", {
		Color = ColorSequence.new(c1, c2),
		Rotation = rot or 90,
		Parent = frame,
	})
end

if not getgenv then getgenv = function() return _G end end
getgenv().XeioaOptions = getgenv().XeioaOptions or {}
getgenv().XeioaToggles = getgenv().XeioaToggles or {}

local Library = {
	Options = getgenv().XeioaOptions,
	Toggles = getgenv().XeioaToggles,
	Connections = {},
	Windows = {},
	ToggleKey = Enum.KeyCode.RightShift,
	Theme = {
		BgA           = Color3.fromRGB(8, 4, 18),
		BgB           = Color3.fromRGB(22, 8, 38),
		TopA          = Color3.fromRGB(30, 8, 55),
		TopB          = Color3.fromRGB(80, 20, 110),
		AccentA       = Color3.fromRGB(220, 80, 200),
		AccentB       = Color3.fromRGB(140, 40, 240),
		Text          = Color3.fromRGB(255, 230, 255),
		TextDark      = Color3.fromRGB(180, 140, 200),
		ElemA         = Color3.fromRGB(28, 10, 50),
		ElemB         = Color3.fromRGB(50, 18, 80),
		ElemHover     = Color3.fromRGB(60, 22, 95),
		Stroke        = Color3.fromRGB(100, 40, 140),
		ToggleON_A    = Color3.fromRGB(220, 80, 200),
		ToggleON_B    = Color3.fromRGB(140, 40, 240),
		ToggleOFF     = Color3.fromRGB(40, 15, 65),
		SliderFillA   = Color3.fromRGB(220, 80, 200),
		SliderFillB   = Color3.fromRGB(140, 40, 240),
		Divider       = Color3.fromRGB(80, 30, 110),
		NotifBgA      = Color3.fromRGB(22, 8, 40),
		NotifBgB      = Color3.fromRGB(50, 16, 80),
		Red           = Color3.fromRGB(240, 70, 100),
		Green         = Color3.fromRGB(100, 240, 160),
	},
}

local T = Library.Theme

local NotifGui = make("ScreenGui", {
	Name = "XeioaNotifs",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
	Parent = CoreGui,
})

local NotifHolder = make("Frame", {
	Name = "Holder",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 290, 1, 0),
	Position = UDim2.new(1, -300, 0, 0),
	Parent = NotifGui,
}, {
	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 6),
	}),
	make("UIPadding", { PaddingBottom = UDim.new(0, 14) }),
})

local nCount = 0

function Library:Notify(opts)
	opts = opts or {}
	local title = opts.Title or "Xeioa"
	local text = opts.Text or ""
	local dur = opts.Duration or 4
	local ntype = opts.Type or "info"

	local ac = T.AccentA
	if ntype == "success" then ac = T.Green
	elseif ntype == "error" then ac = T.Red
	elseif ntype == "warning" then ac = Color3.fromRGB(255, 185, 50) end

	nCount = nCount + 1

	local frame = make("Frame", {
		Name = "N_" .. nCount,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = NotifHolder,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = ac, Thickness = 1.2 }),
		make("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
		}),
	})

	applyGradient(frame, T.NotifBgA, T.NotifBgB, 135)
	frame.BackgroundTransparency = 0

	make("Frame", {
		BackgroundColor3 = ac,
		Size = UDim2.new(0, 3, 1, 0),
		Position = UDim2.new(0, -14, 0, 0),
		Parent = frame,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 3) }),
	})

	local inner = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 6, 0, 0),
		Parent = frame,
	}, {
		make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	make("TextLabel", {
		Text = title,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = inner,
	})

	make("TextLabel", {
		Text = text,
		TextColor3 = T.TextDark,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 2,
		Parent = inner,
	})

	local progBg = make("Frame", {
		BackgroundColor3 = T.ElemB,
		Size = UDim2.new(1, 6, 0, 2),
		Position = UDim2.new(0, -6, 1, 5),
		Parent = frame,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local progFill = make("Frame", {
		BackgroundColor3 = ac,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = progBg,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	tw(progFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

	task.delay(dur, function()
		tw(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
		})
		task.delay(0.4, function() frame:Destroy() end)
	end)

	return frame
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Xeioa"
	local toggleKey = opts.ToggleKey or self.ToggleKey
	local autoShow = opts.AutoShow ~= false
	local sz = opts.Size or Vector2.new(580, 440)
	local center = opts.Center ~= false

	local screenGui = make("ScreenGui", {
		Name = "Xeioa_" .. title,
		ResetOnSpawn = false,
		DisplayOrder = 100,
		IgnoreGuiInset = true,
		Parent = CoreGui,
	})

	local winSize = UDim2.new(0, sz.X, 0, sz.Y)
	local startPos = center
		and UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2)
		or UDim2.new(0.1, 0, 0.1, 0)

	local mainFrame = make("Frame", {
		Name = "Main",
		BackgroundColor3 = T.BgA,
		Size = winSize,
		Position = startPos,
		ClipsDescendants = false,
		Parent = screenGui,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 12) }),
		make("UIStroke", { Color = T.Stroke, Thickness = 1.5 }),
	})

	applyGradient(mainFrame, T.BgA, T.BgB, 145)

	local shadow = make("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.45,
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.new(0, -30, 0, -30),
		ZIndex = 0,
		Parent = mainFrame,
	})

	local topBar = make("Frame", {
		Name = "TopBar",
		BackgroundColor3 = T.TopA,
		Size = UDim2.new(1, 0, 0, 44),
		ClipsDescendants = true,
		Parent = mainFrame,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 12) }),
	})

	applyGradient(topBar, T.TopA, T.TopB, 120)

	make("Frame", {
		BackgroundColor3 = T.TopB,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BorderSizePixel = 0,
		Parent = topBar,
	})

	local accentLine = make("Frame", {
		BackgroundColor3 = T.AccentA,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		Parent = topBar,
	})

	applyGradient(accentLine, T.AccentA, T.AccentB, 0)

	make("TextLabel", {
		Text = title,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -55, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	local closeBtn = make("TextButton", {
		Text = "✕",
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundColor3 = T.ElemA,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		Parent = topBar,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
		make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
	})

	closeBtn.MouseEnter:Connect(function()
		tw(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Red })
	end)
	closeBtn.MouseLeave:Connect(function()
		tw(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.ElemA })
	end)
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	closeBtn.TouchTap:Connect(function()
		screenGui:Destroy()
	end)

	local contentFrame = make("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -44),
		Position = UDim2.new(0, 0, 0, 44),
		Parent = mainFrame,
	})

	local tabBar = make("Frame", {
		Name = "TabBar",
		BackgroundColor3 = T.ElemA,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = contentFrame,
	})

	local tabBarList = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 0),
		Parent = tabBar,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 2),
		}),
	})

	local tabContent = make("Frame", {
		Name = "TabContent",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -34),
		Position = UDim2.new(0, 0, 0, 34),
		Parent = contentFrame,
	})

	local isDragging = false
	local dragStart = nil
	local startFramePos = nil

	local function onDragStart(inputPos)
		isDragging = true
		dragStart = inputPos
		startFramePos = mainFrame.Position
	end

	local function onDragMove(inputPos)
		if not isDragging then return end
		local delta = inputPos - dragStart
		mainFrame.Position = UDim2.new(
			startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
			startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
		)
	end

	local function onDragEnd()
		isDragging = false
	end

	topBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			onDragStart(inp.Position)
		elseif inp.UserInputType == Enum.UserInputType.Touch then
			onDragStart(inp.Position)
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			onDragMove(inp.Position)
		elseif inp.UserInputType == Enum.UserInputType.Touch then
			onDragMove(inp.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			onDragEnd()
		end
	end)

	local Window = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		TabBar = tabBarList,
		TabContent = tabContent,
		Tabs = {},
		ActiveTab = nil,
		Visible = true,
		ToggleKey = toggleKey,
	}

	local function setVisible(v)
		Window.Visible = v
		if v then
			mainFrame.Visible = true
			tw(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
				Size = winSize,
				Position = startPos,
			})
		else
			tw(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, sz.X, 0, 0),
			})
			task.delay(0.3, function()
				if not Window.Visible then
					mainFrame.Visible = false
				end
			end)
		end
	end

	local mobileBtn = make("TextButton", {
		Text = "✦",
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		BackgroundColor3 = T.ElemA,
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0, 20, 0.5, -25),
		ZIndex = 200,
		Parent = screenGui,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIStroke", { Color = T.AccentA, Thickness = 2 }),
	})

	applyGradient(mobileBtn, T.TopA, T.TopB, 135)

	local mbDragging = false
	local mbDragStart = nil
	local mbStartPos = nil

	mobileBtn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch then
			mbDragging = true
			mbDragStart = inp.Position
			mbStartPos = mobileBtn.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if mbDragging and inp.UserInputType == Enum.UserInputType.Touch then
			local delta = inp.Position - mbDragStart
			mobileBtn.Position = UDim2.new(
				mbStartPos.X.Scale, mbStartPos.X.Offset + delta.X,
				mbStartPos.Y.Scale, mbStartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch then
			mbDragging = false
		end
	end)

	mobileBtn.TouchTap:Connect(function()
		if mbDragging then return end
		setVisible(not Window.Visible)
	end)

	mobileBtn.MouseButton1Click:Connect(function()
		setVisible(not Window.Visible)
	end)

	if not isMobile then
		mobileBtn.Visible = false
	end

	local kconn = UserInputService.InputBegan:Connect(function(inp, gp)
		if not gp and inp.KeyCode == toggleKey then
			setVisible(not Window.Visible)
		end
	end)
	table.insert(Library.Connections, kconn)

	function Window:AddTab(name)
		local tabBtn = make("TextButton", {
			Text = name,
			TextColor3 = T.TextDark,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, -6),
			Parent = self.TabBar,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 6) }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
		})

		local underline = make("Frame", {
			BackgroundColor3 = T.AccentA,
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, 0),
			Visible = false,
			Parent = tabBtn,
		})

		applyGradient(underline, T.AccentA, T.AccentB, 0)

		local page = make("ScrollingFrame", {
			Name = "Page_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.AccentA,
			Visible = false,
			Parent = self.TabContent,
		}, {
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
		})

		local function activate()
			if self.ActiveTab then
				tw(self.ActiveTab.Btn, TweenInfo.new(0.15), {
					TextColor3 = T.TextDark,
					BackgroundTransparency = 1,
				})
				self.ActiveTab.Underline.Visible = false
				self.ActiveTab.Page.Visible = false
			end
			tw(tabBtn, TweenInfo.new(0.15), {
				TextColor3 = T.Text,
				BackgroundTransparency = 0.85,
			})
			underline.Visible = true
			page.Visible = true
			self.ActiveTab = { Btn = tabBtn, Underline = underline, Page = page }
		end

		tabBtn.MouseButton1Click:Connect(activate)
		tabBtn.TouchTap:Connect(activate)

		tabBtn.MouseEnter:Connect(function()
			if self.ActiveTab and self.ActiveTab.Btn == tabBtn then return end
			tw(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.9 })
		end)
		tabBtn.MouseLeave:Connect(function()
			if self.ActiveTab and self.ActiveTab.Btn == tabBtn then return end
			tw(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 })
		end)

		if not self.ActiveTab then activate() end

		local rowLayout = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = page,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
		})

		local Tab = {
			Page = page,
			RowLayout = rowLayout,
			LeftCol = nil,
			RightCol = nil,
		}

		local function ensureCols()
			if Tab.LeftCol then return end
			Tab.LeftCol = make("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Parent = rowLayout,
			}, {
				make("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),
			})
			Tab.RightCol = make("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Parent = rowLayout,
			}, {
				make("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),
			})
		end

		local function makeGB(title, side)
			ensureCols()
			local col = side == "Left" and Tab.LeftCol or Tab.RightCol

			local gb = make("Frame", {
				Name = "GB_" .. title,
				BackgroundColor3 = T.ElemA,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = col,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 10) }),
				make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
				make("UIPadding", {
					PaddingTop = UDim.new(0, 34),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
			})

			applyGradient(gb, T.ElemA, T.ElemB, 135)

			local gbHeader = make("Frame", {
				BackgroundColor3 = T.TopA,
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 0),
				ClipsDescendants = true,
				Parent = gb,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			})

			applyGradient(gbHeader, T.TopA, T.TopB, 120)

			make("Frame", {
				BackgroundColor3 = T.TopB,
				Size = UDim2.new(1, 0, 0, 10),
				Position = UDim2.new(0, 0, 1, -10),
				BorderSizePixel = 0,
				Parent = gbHeader,
			})

			make("TextLabel", {
				Text = title,
				TextColor3 = T.Text,
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = gbHeader,
			})

			local itemList = make("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = gb,
			}, {
				make("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5),
				}),
			})

			return Library:_BuildAPI(itemList)
		end

		function Tab:AddLeftGroupbox(title)
			return makeGB(title, "Left")
		end

		function Tab:AddRightGroupbox(title)
			return makeGB(title, "Right")
		end

		function Tab:AddGroupbox(title)
			ensureCols()
			return makeGB(title, "Left")
		end

		function Tab:AddLeftTabbox()
			ensureCols()
			return Library:_Tabbox(Tab.LeftCol)
		end

		function Tab:AddRightTabbox()
			ensureCols()
			return Library:_Tabbox(Tab.RightCol)
		end

		self.Tabs[name] = Tab
		return Tab
	end

	function Window:AddKeyTab(name)
		local tab = self:AddTab(name)
		local gb = tab:AddLeftGroupbox("Key Required")
		gb:AddLabel("Enter the key to unlock this tab.")
		gb:AddInput("XeioaKey_" .. name, {
			Text = "Key",
			Placeholder = "Type key here...",
			Finished = true,
			Callback = function(val)
				if val == "xeioa" then
					Library:Notify({ Title = "Access Granted", Text = "Key accepted.", Type = "success" })
				else
					Library:Notify({ Title = "Access Denied", Text = "Wrong key.", Type = "error" })
				end
			end,
		})
		return tab
	end

	table.insert(self.Windows, Window)

	if not autoShow then
		mainFrame.Visible = false
		Window.Visible = false
	end

	return Window
end

function Library:_Tabbox(parentCol)
	local container = make("Frame", {
		BackgroundColor3 = T.ElemA,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parentCol,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
	})

	applyGradient(container, T.ElemA, T.ElemB, 135)

	local btnRow = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = container,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		}),
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
	})

	make("Frame", {
		BackgroundColor3 = T.Stroke,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 28),
		BorderSizePixel = 0,
		Parent = container,
	})

	local pageHolder = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 0, 0, 34),
		Parent = container,
	}, {
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})

	local TB = { ActiveTab = nil }

	function TB:AddTab(name)
		local btn = make("TextButton", {
			Text = name,
			TextColor3 = T.TextDark,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, -4),
			Parent = btnRow,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 5) }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		local itemList = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = pageHolder,
		}, {
			make("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
		})

		local function activate()
			if TB.ActiveTab then
				tw(TB.ActiveTab.Btn, TweenInfo.new(0.12), {
					TextColor3 = T.TextDark,
					BackgroundTransparency = 1,
				})
				TB.ActiveTab.Page.Visible = false
			end
			tw(btn, TweenInfo.new(0.12), {
				TextColor3 = T.Text,
				BackgroundTransparency = 0.85,
			})
			itemList.Visible = true
			TB.ActiveTab = { Btn = btn, Page = itemList }
		end

		btn.MouseButton1Click:Connect(activate)
		btn.TouchTap:Connect(activate)
		if not TB.ActiveTab then activate() end

		return Library:_BuildAPI(itemList)
	end

	return TB
end

function Library:_BuildAPI(itemList)
	local API = {}

	local function row(h)
		return make("Frame", {
			BackgroundTransparency = 1,
			Size = h and UDim2.new(1, 0, 0, h) or UDim2.new(1, 0, 0, 0),
			AutomaticSize = h and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
			Parent = itemList,
		})
	end

	local function elemBg(parent, props)
		local f = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Parent = parent,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
		})
		applyGradient(f, T.ElemA, T.ElemB, 135)
		if props then
			for k, v in pairs(props) do
				f[k] = v
			end
		end
		return f
	end

	function API:AddDivider()
		local r = row(10)
		make("Frame", {
			BackgroundColor3 = T.Divider,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0),
			BorderSizePixel = 0,
			Parent = r,
		})
		return API
	end

	function API:AddLabel(text, doesWrap, idx)
		local r = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = itemList,
		})
		local lbl = make("TextLabel", {
			Text = text,
			TextColor3 = T.TextDark,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = doesWrap or false,
			RichText = true,
			Parent = r,
		})
		local obj = {
			SetText = function(self, t) lbl.Text = t end,
		}
		if idx then Library.Options[idx] = obj end
		return API
	end

	function API:AddToggle(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local default = opts.Default ~= nil and opts.Default or false
		local disabled = opts.Disabled or false
		local risky = opts.Risky or false
		local cb = opts.Callback

		local r = row(32)
		local value = default

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		make("TextLabel", {
			Text = text,
			TextColor3 = risky and T.Red or T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -50, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = bg,
		})

		local track = make("Frame", {
			BackgroundColor3 = value and T.ToggleON_A or T.ToggleOFF,
			Size = UDim2.new(0, 38, 0, 20),
			Position = UDim2.new(1, -38, 0.5, -10),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local trackGrad = make("UIGradient", {
			Color = ColorSequence.new(T.ToggleON_A, T.ToggleON_B),
			Rotation = 0,
			Enabled = value,
			Parent = track,
		})

		local knob = make("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 14, 0, 14),
			Position = value
				and UDim2.new(1, -17, 0.5, -7)
				or UDim2.new(0, 3, 0.5, -7),
			Parent = track,
		}, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local callbacks = {}

		local tObj = {
			Value = value,
			OnChanged = function(self, fn)
				table.insert(callbacks, fn)
				return self
			end,
			SetValue = function(self, v)
				value = v
				self.Value = v
				tw(track, TweenInfo.new(0.2), {
					BackgroundColor3 = v and T.ToggleON_A or T.ToggleOFF,
				})
				trackGrad.Enabled = v
				tw(knob, TweenInfo.new(0.2), {
					Position = v
						and UDim2.new(1, -17, 0.5, -7)
						or UDim2.new(0, 3, 0.5, -7),
				})
				if cb then cb(v) end
				for _, fn in ipairs(callbacks) do fn(v) end
			end,
		}

		if not disabled then
			local function toggle()
				tObj:SetValue(not value)
			end
			bg.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
			end)
			bg.TouchTap:Connect(toggle)
			bg.MouseEnter:Connect(function()
				tw(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover })
			end)
			bg.MouseLeave:Connect(function()
				tw(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA })
			end)
		end

		Library.Toggles[idx] = tObj
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return tObj
	end

	function API:AddCheckbox(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local default = opts.Default ~= nil and opts.Default or false
		local disabled = opts.Disabled or false
		local risky = opts.Risky or false
		local cb = opts.Callback

		local r = row(30)
		local value = default

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		local box = make("Frame", {
			BackgroundColor3 = value and T.AccentA or T.ToggleOFF,
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(1, -18, 0.5, -9),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 5) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
		})

		if value then applyGradient(box, T.AccentA, T.AccentB, 135) end

		local check = make("TextLabel", {
			Text = "✓",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			TextTransparency = value and 0 or 1,
			Parent = box,
		})

		make("TextLabel", {
			Text = text,
			TextColor3 = risky and T.Red or T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -28, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = bg,
		})

		local callbacks = {}
		local cbObj = {
			Value = value,
			OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
			SetValue = function(self, v)
				value = v
				self.Value = v
				tw(box, TweenInfo.new(0.15), {
					BackgroundColor3 = v and T.AccentA or T.ToggleOFF,
				})
				tw(check, TweenInfo.new(0.15), { TextTransparency = v and 0 or 1 })
				if cb then cb(v) end
				for _, fn in ipairs(callbacks) do fn(v) end
			end,
		}

		if not disabled then
			local function toggle() cbObj:SetValue(not value) end
			bg.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
			end)
			bg.TouchTap:Connect(toggle)
			bg.MouseEnter:Connect(function()
				tw(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover })
			end)
			bg.MouseLeave:Connect(function()
				tw(bg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA })
			end)
		end

		Library.Toggles[idx] = cbObj
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return cbObj
	end

	function API:AddButton(opts)
		opts = opts or {}
		local text = opts.Text or "Button"
		local func = opts.Func or function() end
		local doubleClick = opts.DoubleClick or false
		local disabled = opts.Disabled or false
		local risky = opts.Risky or false

		local r = row(30)

		local function makeB(parent, btnText, sz, pos)
			local b = make("TextButton", {
				Text = btnText,
				TextColor3 = risky and T.Red or T.Text,
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				BackgroundColor3 = T.ElemA,
				Size = sz or UDim2.new(1, 0, 1, 0),
				Position = pos or UDim2.new(0, 0, 0, 0),
				Parent = parent,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 7) }),
				make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			})
			applyGradient(b, T.ElemA, T.ElemB, 135)
			return b
		end

		local mb = makeB(r, text)
		local lastC = 0

		local function doClick()
			if doubleClick then
				local now = tick()
				if now - lastC < 0.4 then
					func()
					lastC = 0
				else
					lastC = now
					tw(mb, TweenInfo.new(0.1), { BackgroundColor3 = T.ElemHover })
					task.delay(0.1, function()
						tw(mb, TweenInfo.new(0.1), { BackgroundColor3 = T.ElemA })
					end)
				end
			else
				tw(mb, TweenInfo.new(0.08), { BackgroundColor3 = T.AccentB })
				task.delay(0.14, function()
					tw(mb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA })
				end)
				func()
			end
		end

		if not disabled then
			mb.MouseButton1Click:Connect(doClick)
			mb.TouchTap:Connect(doClick)
			mb.MouseEnter:Connect(function()
				tw(mb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover })
			end)
			mb.MouseLeave:Connect(function()
				tw(mb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA })
			end)
		else
			mb.TextColor3 = T.TextDark
		end

		if opts.Tooltip then API:_Tip(mb, opts.Tooltip) end

		local bObj = {}
		function bObj:AddButton(subOpts)
			mb.Size = UDim2.new(0.5, -2, 1, 0)
			local sb = makeB(r, subOpts.Text or "Sub",
				UDim2.new(0.5, -2, 1, 0),
				UDim2.new(0.5, 2, 0, 0))
			local sFunc = subOpts.Func or function() end
			local sDbl = subOpts.DoubleClick or false
			local sLast = 0

			local function sClick()
				if sDbl then
					local now = tick()
					if now - sLast < 0.4 then sFunc(); sLast = 0
					else sLast = now end
				else sFunc() end
				tw(sb, TweenInfo.new(0.08), { BackgroundColor3 = T.AccentB })
				task.delay(0.14, function()
					tw(sb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA })
				end)
			end

			sb.MouseButton1Click:Connect(sClick)
			sb.TouchTap:Connect(sClick)
			sb.MouseEnter:Connect(function() tw(sb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover }) end)
			sb.MouseLeave:Connect(function() tw(sb, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemA }) end)
			if subOpts.Tooltip then API:_Tip(sb, subOpts.Tooltip) end
			return bObj
		end

		return bObj
	end

	function API:AddSlider(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local default = opts.Default or 0
		local min = opts.Min or 0
		local max = opts.Max or 100
		local suffix = opts.Suffix or ""
		local rounding = opts.Rounding or 0
		local compact = opts.Compact or false
		local disabled = opts.Disabled or false
		local cb = opts.Callback
		local fmtFn = opts.FormatDisplayValue

		local rowH = compact and 30 or 46

		local r = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, rowH),
			Parent = itemList,
		})

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		local valLabel = make("TextLabel", {
			Text = "",
			TextColor3 = T.AccentA,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.35, 0, 0, 16),
			Position = UDim2.new(0.65, 0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = bg,
		})

		if not compact then
			make("TextLabel", {
				Text = text,
				TextColor3 = T.Text,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.65, 0, 0, 16),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = bg,
			})
		end

		local sliderBg = make("Frame", {
			BackgroundColor3 = T.ToggleOFF,
			Size = UDim2.new(1, 0, 0, 8),
			Position = compact
				and UDim2.new(0, 0, 0.5, -4)
				or UDim2.new(0, 0, 1, -16),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local fill = make("Frame", {
			BackgroundColor3 = T.SliderFillA,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = sliderBg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		applyGradient(fill, T.SliderFillA, T.SliderFillB, 0)

		local handle = make("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(0, -7, 0.5, -7),
			Parent = sliderBg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
			make("UIStroke", { Color = T.AccentA, Thickness = 2 }),
		})

		local value = default
		local draggingSlider = false
		local lastTouchPos = nil

		local function updateSlider(v)
			v = roundN(clampN(v, min, max), rounding)
			value = v
			local pct = (v - min) / (max - min)
			tw(fill, TweenInfo.new(0.06), { Size = UDim2.new(pct, 0, 1, 0) })
			tw(handle, TweenInfo.new(0.06), { Position = UDim2.new(pct, -7, 0.5, -7) })
			local display = fmtFn and fmtFn({ Max = max, Min = min }, v) or nil
			valLabel.Text = display or (tostring(v) .. suffix)
		end

		updateSlider(default)

		local sliderObj = {
			Value = value,
			_callbacks = {},
			OnChanged = function(self, fn)
				table.insert(self._callbacks, fn)
				return self
			end,
			SetValue = function(self, v)
				updateSlider(v)
				self.Value = value
				if cb then cb(value) end
				for _, fn in ipairs(self._callbacks) do fn(value) end
			end,
		}

		if not disabled then
			sliderBg.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = true
				elseif inp.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					lastTouchPos = inp.Position
				end
			end)

			sliderBg.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch and draggingSlider then
					lastTouchPos = inp.Position
				end
			end)

			UserInputService.InputEnded:Connect(function(inp)
				if (inp.UserInputType == Enum.UserInputType.MouseButton1
					or inp.UserInputType == Enum.UserInputType.Touch)
					and draggingSlider then
					draggingSlider = false
					if cb then cb(value) end
					for _, fn in ipairs(sliderObj._callbacks) do fn(value) end
				end
			end)

			RunService.Heartbeat:Connect(function()
				if not draggingSlider then return end
				local posX
				if isMobile and lastTouchPos then
					posX = lastTouchPos.X
				else
					posX = mouse.X
				end
				local rel = (posX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
				updateSlider(min + (max - min) * clampN(rel, 0, 1))
				sliderObj.Value = value
			end)
		end

		Library.Options[idx] = sliderObj
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return sliderObj
	end

	function API:AddInput(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local default = opts.Default or ""
		local numeric = opts.Numeric or false
		local finished = opts.Finished or false
		local placeholder = opts.Placeholder or ""
		local clearFocus = opts.ClearTextOnFocus ~= false
		local cb = opts.Callback
		local maxLen = opts.MaxLength

		local r = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 50),
			Parent = itemList,
		})

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		make("TextLabel", {
			Text = text,
			TextColor3 = T.TextDark,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = bg,
		})

		local inputBg = make("Frame", {
			BackgroundColor3 = T.BgA,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 1, -24),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 5) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			}),
		})

		local box = make("TextBox", {
			Text = default,
			PlaceholderText = placeholder,
			PlaceholderColor3 = T.TextDark,
			TextColor3 = T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = clearFocus,
			Parent = inputBg,
		})

		if maxLen then
			box:GetPropertyChangedSignal("Text"):Connect(function()
				if #box.Text > maxLen then box.Text = box.Text:sub(1, maxLen) end
			end)
		end

		box.Focused:Connect(function()
			tw(inputBg, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover })
		end)
		box.FocusLost:Connect(function()
			tw(inputBg, TweenInfo.new(0.12), { BackgroundColor3 = T.BgA })
		end)

		local callbacks = {}
		local inputObj = {
			Value = default,
			OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
			SetValue = function(self, v)
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
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return inputObj
	end

	function API:AddDropdown(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local values = opts.Values or {}
		local default = opts.Default or 1
		local multi = opts.Multi or false
		local searchable = opts.Searchable or false
		local disabled = opts.Disabled or false
		local cb = opts.Callback
		local fmtFn = opts.FormatDisplayValue

		local selected = {}
		if multi then
			selected = {}
		else
			selected = type(default) == "number" and values[default] or default
		end

		local r = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = itemList,
		})

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		local innerList = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = bg,
		}, {
			make("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
		})

		make("TextLabel", {
			Text = text,
			TextColor3 = T.TextDark,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = innerList,
		})

		local function getDisplay()
			if multi then
				local sel = {}
				for k in pairs(selected) do table.insert(sel, k) end
				return #sel == 0 and "None" or table.concat(sel, ", ")
			else
				if fmtFn and selected then return fmtFn(selected) or selected end
				return selected or "Select..."
			end
		end

		local selector = make("Frame", {
			BackgroundColor3 = T.BgA,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 2,
			Parent = innerList,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 6) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		local selText = make("TextLabel", {
			Text = getDisplay(),
			TextColor3 = T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -18, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = selector,
		})

		local arrow = make("TextLabel", {
			Text = "▾",
			TextColor3 = T.TextDark,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 1, 0),
			Position = UDim2.new(1, -16, 0, 0),
			Parent = selector,
		})

		local dropFrame = nil
		local open = false

		local function closeDD()
			if dropFrame then dropFrame:Destroy(); dropFrame = nil end
			open = false
			tw(arrow, TweenInfo.new(0.12), { Rotation = 0 })
		end

		local function openDD()
			open = true
			tw(arrow, TweenInfo.new(0.12), { Rotation = 180 })

			dropFrame = make("Frame", {
				BackgroundColor3 = T.BgB,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.new(0, 0, 1, 4),
				ZIndex = 10,
				Parent = selector,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 7) }),
				make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
				make("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),
			})

			make("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
				Parent = dropFrame,
			})

			local searchBox = nil
			if searchable then
				local sbg = make("Frame", {
					BackgroundColor3 = T.ElemA,
					Size = UDim2.new(1, -8, 0, 22),
					LayoutOrder = 0,
					ZIndex = 11,
					Parent = dropFrame,
				}, {
					make("UICorner", { CornerRadius = UDim.new(0, 5) }),
					make("UIPadding", {
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),
					}),
				})
				searchBox = make("TextBox", {
					PlaceholderText = "Search...",
					PlaceholderColor3 = T.TextDark,
					Text = "",
					TextColor3 = T.Text,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 12,
					Parent = sbg,
				})
			end

			local function renderItems(filter)
				for _, c in ipairs(dropFrame:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for i, v in ipairs(values) do
					local display = fmtFn and fmtFn(v) or v
					if filter and filter ~= "" then
						if not display:lower():find(filter:lower(), 1, true) then
							continue
						end
					end
					local isSel = multi and (selected[v] == true) or (selected == v)
					local item = make("TextButton", {
						Text = display,
						TextColor3 = isSel and T.AccentA or T.Text,
						Font = isSel and Enum.Font.GothamSemibold or Enum.Font.Gotham,
						TextSize = 12,
						BackgroundColor3 = isSel and T.ElemB or Color3.new(0, 0, 0),
						BackgroundTransparency = isSel and 0 or 1,
						Size = UDim2.new(1, -8, 0, 26),
						LayoutOrder = i + 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 11,
						Parent = dropFrame,
					}, {
						make("UICorner", { CornerRadius = UDim.new(0, 5) }),
						make("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
						}),
					})

					local function pick()
						if multi then
							selected[v] = not selected[v] or nil
						else
							selected = v
							closeDD()
						end
						selText.Text = getDisplay()
						if cb then
							cb(multi and (function()
								local t = {}
								for k in pairs(selected) do table.insert(t, k) end
								return t
							end)() or selected)
						end
						if not multi then return end
						renderItems(searchBox and searchBox.Text or "")
					end

					item.MouseButton1Click:Connect(pick)
					item.TouchTap:Connect(pick)
					item.MouseEnter:Connect(function()
						tw(item, TweenInfo.new(0.1), {
							BackgroundTransparency = 0,
							BackgroundColor3 = T.ElemHover,
						})
					end)
					item.MouseLeave:Connect(function()
						tw(item, TweenInfo.new(0.1), {
							BackgroundTransparency = isSel and 0 or 1,
							BackgroundColor3 = isSel and T.ElemB or T.ElemHover,
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

		local selBtn = make("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			Parent = selector,
		})

		local function toggleDD()
			if disabled then return end
			if open then closeDD() else openDD() end
		end

		selBtn.MouseButton1Click:Connect(toggleDD)
		selBtn.TouchTap:Connect(toggleDD)

		UserInputService.InputBegan:Connect(function(inp)
			if open and (inp.UserInputType == Enum.UserInputType.MouseButton1
				or inp.UserInputType == Enum.UserInputType.Touch) then
				if dropFrame then
					local abs = dropFrame.AbsolutePosition
					local sz2 = dropFrame.AbsoluteSize
					local pos = inp.Position
					if pos.X < abs.X or pos.X > abs.X + sz2.X
						or pos.Y < abs.Y or pos.Y > abs.Y + sz2.Y then
						closeDD()
					end
				end
			end
		end)

		local dropObj = {
			Value = selected,
			OnChanged = function(self, fn)
				local prev = selected
				RunService.Heartbeat:Connect(function()
					if selected ~= prev then prev = selected; fn(selected) end
				end)
				return self
			end,
			SetValue = function(self, v)
				if multi then
					selected = {}
					if type(v) == "table" then
						for _, k in ipairs(v) do selected[k] = true end
					else selected[v] = true end
				else selected = v end
				self.Value = selected
				selText.Text = getDisplay()
				if cb then cb(v) end
			end,
			SetValues = function(self, newVals)
				values = newVals
				selText.Text = getDisplay()
			end,
		}

		Library.Options[idx] = dropObj
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return dropObj
	end

	function API:AddColorPicker(idx, opts)
		opts = opts or {}
		local text = opts.Title or opts.Text or "Color"
		local default = opts.Default or Color3.new(1, 0, 0)
		local transparency = opts.Transparency
		local cb = opts.Callback

		local r = row(30)

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		make("TextLabel", {
			Text = text,
			TextColor3 = T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -38, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = bg,
		})

		local preview = make("TextButton", {
			Text = "",
			BackgroundColor3 = default,
			Size = UDim2.new(0, 26, 0, 20),
			Position = UDim2.new(1, -26, 0.5, -10),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 5) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
		})

		local color = default
		local trans = transparency or 0
		local pickerOpen = false
		local pickerFrame = nil

		local callbacks = {}
		local cpObj = {
			Value = { Color = color, Transparency = trans },
			OnChanged = function(self, fn) table.insert(callbacks, fn) return self end,
			SetValue = function(self, v)
				if type(v) == "userdata" then color = v
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

		local function closePicker()
			if pickerFrame then pickerFrame:Destroy(); pickerFrame = nil end
			pickerOpen = false
		end

		local function openPicker()
			pickerOpen = true
			pickerFrame = make("Frame", {
				BackgroundColor3 = T.BgB,
				Size = UDim2.new(0, 185, 0, transparency ~= nil and 135 or 110),
				Position = UDim2.new(1, 6, 0, 0),
				ZIndex = 20,
				Parent = bg,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 9) }),
				make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
				make("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
			})

			applyGradient(pickerFrame, T.BgA, T.BgB, 135)

			local hueBar = make("Frame", {
				Size = UDim2.new(1, 0, 0, 14),
				Parent = pickerFrame,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 4) }),
				make("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,     Color3.fromHSV(0,     1, 1)),
						ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
						ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
						ColorSequenceKeypoint.new(0.5,   Color3.fromHSV(0.5,   1, 1)),
						ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
						ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
						ColorSequenceKeypoint.new(1,     Color3.fromHSV(1,     1, 1)),
					}),
				}),
			})

			local h, s, v2 = Color3.toHSV(color)

			local hueHandle = make("Frame", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0, 4, 1, 2),
				Position = UDim2.new(h, -2, 0, -1),
				Parent = hueBar,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 2) }),
			})

			local svFrame = make("Frame", {
				Size = UDim2.new(1, 0, 0, 60),
				Position = UDim2.new(0, 0, 0, 20),
				Parent = pickerFrame,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 4) }),
				make("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1)),
					}),
				}),
			})

			make("Frame", {
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Parent = svFrame,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 4) }),
				make("UIGradient", {
					Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Rotation = 90,
				}),
			})

			local svHandle = make("Frame", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(s, -5, 1 - v2, -5),
				Parent = svFrame,
			}, {
				make("UICorner", { CornerRadius = UDim.new(1, 0) }),
				make("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }),
			})

			local function updateColor()
				color = Color3.fromHSV(h, s, v2)
				preview.BackgroundColor3 = color
				cpObj.Value = { Color = color, Transparency = trans }
				if cb then cb(color) end
				for _, fn in ipairs(callbacks) do fn(color) end
			end

			local dragHue = false
			local dragSV = false
			local hueTouch = nil
			local svTouch = nil

			hueBar.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true
				elseif inp.UserInputType == Enum.UserInputType.Touch then dragHue = true; hueTouch = inp end
			end)
			hueBar.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch then hueTouch = inp end
			end)
			svFrame.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true
				elseif inp.UserInputType == Enum.UserInputType.Touch then dragSV = true; svTouch = inp end
			end)
			svFrame.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch then svTouch = inp end
			end)
			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1
					or inp.UserInputType == Enum.UserInputType.Touch then
					dragHue = false; dragSV = false
				end
			end)

			RunService.Heartbeat:Connect(function()
				if dragHue then
					local px = isMobile and (hueTouch and hueTouch.Position.X or 0) or mouse.X
					h = clampN((px - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
					hueHandle.Position = UDim2.new(h, -2, 0, -1)
					updateColor()
				end
				if dragSV then
					local px = isMobile and (svTouch and svTouch.Position.X or 0) or mouse.X
					local py = isMobile and (svTouch and svTouch.Position.Y or 0) or mouse.Y
					s  = clampN((px - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
					v2 = 1 - clampN((py - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
					svHandle.Position = UDim2.new(s, -5, 1 - v2, -5)
					updateColor()
				end
			end)

			if transparency ~= nil then
				make("TextLabel", {
					Text = "Transparency",
					TextColor3 = T.TextDark,
					Font = Enum.Font.Gotham,
					TextSize = 10,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 12),
					Position = UDim2.new(0, 0, 0, 86),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = pickerFrame,
				})

				local transBg = make("Frame", {
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 0, 0, 100),
					Parent = pickerFrame,
				}, {
					make("UICorner", { CornerRadius = UDim.new(1, 0) }),
					make("UIGradient", {
						Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0)),
					}),
				})

				local transHandle = make("Frame", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					Size = UDim2.new(0, 8, 0, 8),
					Position = UDim2.new(trans, -4, 0.5, -4),
					Parent = transBg,
				}, {
					make("UICorner", { CornerRadius = UDim.new(1, 0) }),
				})

				local dragTrans = false
				local transTouch = nil
				transBg.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragTrans = true
					elseif inp.UserInputType == Enum.UserInputType.Touch then dragTrans = true; transTouch = inp end
				end)
				transBg.InputChanged:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.Touch then transTouch = inp end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1
						or inp.UserInputType == Enum.UserInputType.Touch then
						dragTrans = false
					end
				end)
				RunService.Heartbeat:Connect(function()
					if dragTrans then
						local px = isMobile and (transTouch and transTouch.Position.X or 0) or mouse.X
						trans = clampN((px - transBg.AbsolutePosition.X) / transBg.AbsoluteSize.X, 0, 1)
						transHandle.Position = UDim2.new(trans, -4, 0.5, -4)
						cpObj.Value = { Color = color, Transparency = trans }
						if cb then cb(color) end
					end
				end)
			end
		end

		local function toggle()
			if pickerOpen then closePicker() else openPicker() end
		end

		preview.MouseButton1Click:Connect(toggle)
		preview.TouchTap:Connect(toggle)

		UserInputService.InputBegan:Connect(function(inp)
			if pickerOpen and (inp.UserInputType == Enum.UserInputType.MouseButton1
				or inp.UserInputType == Enum.UserInputType.Touch) then
				if pickerFrame then
					local abs = pickerFrame.AbsolutePosition
					local sz2 = pickerFrame.AbsoluteSize
					local pos = inp.Position
					if pos.X < abs.X or pos.X > abs.X + sz2.X
						or pos.Y < abs.Y or pos.Y > abs.Y + sz2.Y then
						task.delay(0.05, closePicker)
					end
				end
			end
		end)

		Library.Options[idx] = cpObj
		if opts.Tooltip then API:_Tip(bg, opts.Tooltip) end
		return cpObj
	end

	function API:AddKeybind(idx, opts)
		opts = opts or {}
		local text = opts.Text or idx
		local default = opts.Default or Enum.KeyCode.Unknown
		local cb = opts.Callback

		local r = row(30)
		local binding = default
		local listening = false

		local bg = make("Frame", {
			BackgroundColor3 = T.ElemA,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = r,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 7) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),
		})

		applyGradient(bg, T.ElemA, T.ElemB, 135)

		make("TextLabel", {
			Text = text,
			TextColor3 = T.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -80, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = bg,
		})

		local keyBtn = make("TextButton", {
			Text = binding.Name,
			TextColor3 = T.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			BackgroundColor3 = T.BgA,
			Size = UDim2.new(0, 72, 0, 20),
			Position = UDim2.new(1, -72, 0.5, -10),
			Parent = bg,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 4) }),
			make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
		})

		local kbObj = {
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
			keyBtn.TextColor3 = T.AccentA
			local conn
			conn = UserInputService.InputBegan:Connect(function(inp, gp)
				if not gp then
					binding = inp.KeyCode
					kbObj.Value = binding
					keyBtn.Text = binding.Name
					keyBtn.TextColor3 = T.Text
					listening = false
					conn:Disconnect()
					if cb then cb(binding) end
				end
			end)
		end)

		keyBtn.MouseEnter:Connect(function()
			tw(keyBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.ElemHover })
		end)
		keyBtn.MouseLeave:Connect(function()
			tw(keyBtn, TweenInfo.new(0.12), { BackgroundColor3 = T.BgA })
		end)

		Library.Options[idx] = kbObj
		return kbObj
	end

	function API:_Tip(element, tipText)
		local tipFrame = nil
		element.MouseEnter:Connect(function()
			tipFrame = make("Frame", {
				BackgroundColor3 = T.BgB,
				AutomaticSize = Enum.AutomaticSize.XY,
				ZIndex = 50,
				Parent = element,
			}, {
				make("UICorner", { CornerRadius = UDim.new(0, 6) }),
				make("UIStroke", { Color = T.Stroke, Thickness = 1 }),
				make("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
				make("TextLabel", {
					Text = tipText,
					TextColor3 = T.TextDark,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
					ZIndex = 51,
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

function Library:Destroy()
	for _, conn in ipairs(self.Connections) do conn:Disconnect() end
	self.Connections = {}
	for _, win in ipairs(self.Windows) do win.ScreenGui:Destroy() end
	self.Windows = {}
	NotifGui:Destroy()
end

return Library
