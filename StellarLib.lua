local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function Create(Class, Properties)
	local Inst = Instance.new(Class)
	for Key, Value in Properties do
		Inst[Key] = Value
	end
	return Inst
end

local Library = {}
Library.Flags = {}
Library.Registry = {}
Library.WindowKeybind = Enum.KeyCode.RightControl
Library.WindowOpen = true

Library.Theme = {
	Main = Color3.fromRGB(5, 5, 5),
	Secondary = Color3.fromRGB(8, 8, 8),
	Stroke = Color3.fromRGB(34, 34, 34),
	Accent = Color3.fromRGB(77, 188, 233),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(136, 136, 136),
	ElementBg = Color3.fromRGB(20, 20, 20),
	ElementStroke = Color3.fromRGB(51, 51, 51),
	SubTitleBg = Color3.fromRGB(45, 45, 45),
	NavBarBg = Color3.fromRGB(26, 26, 26),
	Font = Enum.Font.Nunito,
	FontBold = Enum.Font.Nunito,
	AnimationSpeed = 1
}

local Assets = {
	Button = "rbxassetid://12967326152",
	ToggleCog = "rbxassetid://11293977610",
	Settings = "rbxassetid://12974220219",
	Search = "rbxassetid://11293977875",
	Dropdown = "rbxassetid://12967775051",
	Textbox = "rbxassetid://12975591097",
	Return = "rbxassetid://11422155687",
	Keybind = "rbxassetid://12974370712",
	PickerCursor = "rbxassetid://10709798174"
}

local function GetDarkerColor(Color)
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S, V * 0.5)
end

local function GetTime(BaseTime)
	return BaseTime / Library.Theme.AnimationSpeed
end

local function BindToTheme(Obj, Prop, ThemeKey)
	if Library.Theme[ThemeKey] then
		Obj[Prop] = Library.Theme[ThemeKey]
		
		local Found = false
		for _, Item in Library.Registry do
			if Item.Object == Obj and Item.Property == Prop then
				Item.ThemeKey = ThemeKey
				Found = true
				break
			end
		end
		
		if not Found then
			table.insert(Library.Registry, {Object = Obj, Property = Prop, ThemeKey = ThemeKey, Type = "Property"})
		end
	end
	return Obj
end

local function AddGradient(Parent, Color)
	Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	if Parent:FindFirstChild("UIGradient") then
		if Parent.UIGradient.Name == "ActiveGradient" then
			return Parent.UIGradient
		end
		Parent.UIGradient:Destroy()
	end

	local Gradient = Create("UIGradient", {
		Parent = Parent,
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color),
			ColorSequenceKeypoint.new(1, GetDarkerColor(Color))
		})
	})
	return Gradient
end

local function TweenGradient(Obj, TargetColor, Time)
	local Gradient = Obj:FindFirstChild("UIGradient")
	if not Gradient then return end

	local ColorVal = Instance.new("Color3Value")
	ColorVal.Value = Gradient.Color.Keypoints[1].Value
	ColorVal.Parent = Obj

	local Info = TweenInfo.new(GetTime(Time), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local Tween = TweenService:Create(ColorVal, Info, {Value = TargetColor})

	local Conn
	Conn = ColorVal:GetPropertyChangedSignal("Value"):Connect(function()
		if not Gradient or not Gradient.Parent then
			Conn:Disconnect()
			ColorVal:Destroy()
			return
		end
		local Current = ColorVal.Value
		Gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Current),
			ColorSequenceKeypoint.new(1, GetDarkerColor(Current))
		})
	end)

	Tween.Completed:Connect(function()
		Conn:Disconnect()
		ColorVal:Destroy()
	end)
	Tween:Play()
end

local function BindGradient(Obj, ThemeKey)
	if Library.Theme[ThemeKey] then
		AddGradient(Obj, Library.Theme[ThemeKey])
		
		local Found = false
		for _, Item in Library.Registry do
			if Item.Object == Obj and Item.Type == "Gradient" then
				Item.ThemeKey = ThemeKey
				Found = true
				break
			end
		end
		
		if not Found then
			table.insert(Library.Registry, {Object = Obj, ThemeKey = ThemeKey, Type = "Gradient"})
		end
	end
end

local function PlayClickEffect(Obj)
	TweenGradient(Obj, Library.Theme.Accent, 0.2)
	task.delay(GetTime(0.2), function()
		TweenGradient(Obj, Library.Theme.Stroke, 0.2)
	end)
end

function Library:GetTheme()
	return Library.Theme
end

function Library:SetTheme(NewTheme)
	for Key, Val in NewTheme do
		Library.Theme[Key] = Val
	end

	for _, Item in Library.Registry do
		if Item.Object and Item.Object.Parent then
			if Item.Type == "Property" then
				TweenService:Create(Item.Object, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {[Item.Property] = Library.Theme[Item.ThemeKey]}):Play()
			elseif Item.Type == "Gradient" then
				TweenGradient(Item.Object, Library.Theme[Item.ThemeKey], 0.5)
			elseif Item.Type == "ActiveGradient" then
				local Gradient = Item.Object
				if Gradient and Gradient.Parent then
					local ColorVal = Instance.new("Color3Value")
					ColorVal.Value = Gradient.Color.Keypoints[1].Value
					ColorVal.Parent = Gradient.Parent

					local Info = TweenInfo.new(GetTime(0.5), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					local Tween = TweenService:Create(ColorVal, Info, {Value = Library.Theme[Item.ThemeKey]})

					local Conn
					Conn = ColorVal:GetPropertyChangedSignal("Value"):Connect(function()
						if not Gradient or not Gradient.Parent then
							Conn:Disconnect()
							ColorVal:Destroy()
							return
						end
						local Current = ColorVal.Value
						Gradient.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Current),
							ColorSequenceKeypoint.new(1, GetDarkerColor(Current))
						})
					end)
					Tween.Completed:Connect(function()
						Conn:Disconnect()
						ColorVal:Destroy()
					end)
					Tween:Play()
				end
			end
		end
	end
end

function Library:SetWindowKeybind(Key)
	Library.WindowKeybind = Key
end

function Library:Window(Options)
	local Title = Options.Title or "Stellar"
	local SubTitle = Options.SubTitle or "Game"
	local Status = Options.Status or ""

	local ScreenGui = Create("ScreenGui", {
		Name = "Stellar",
		Parent = CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})

	local PopupContainer = Create("Frame", {
		Name = "PopupContainer",
		Parent = ScreenGui,
		BorderSizePixel = 1,
		ZIndex = 200,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Size = UDim2.new(0, 0, 0, 0)
	})
	BindToTheme(PopupContainer, "BackgroundColor3", "Main")
	BindToTheme(PopupContainer, "BorderColor3", "Stroke")

	Create("UICorner", {Parent = PopupContainer, CornerRadius = UDim.new(0, 6)})
	BindToTheme(Create("UIStroke", {Parent = PopupContainer, Thickness = 1}), "Color", "Stroke")
	Create("UIPadding", {Parent = PopupContainer, PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1)})
	Create("UIListLayout", {Parent = PopupContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)})

	local PopupOwner = nil
	local PopupConnection = nil

	local function ClosePopup()
		if PopupContainer.Visible then
			local CurrentSize = PopupContainer.AbsoluteSize
			local Info = TweenInfo.new(GetTime(0.3), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			local Tween = TweenService:Create(PopupContainer, Info, {Size = UDim2.new(0, 0, 0, CurrentSize.Y)})
			Tween:Play()
			Tween.Completed:Connect(function()
				if PopupContainer.Size.X.Offset == 0 then
					PopupContainer.Visible = false
					PopupOwner = nil
				end
			end)
			if PopupConnection then
				PopupConnection:Disconnect()
				PopupConnection = nil
			end
		end
	end

	local function OpenPopup(OwnerButton, ContentBuilder)
		if PopupContainer.Visible and PopupOwner == OwnerButton then
			ClosePopup()
			return
		end

		for _, child in PopupContainer:GetChildren() do
			if not child:IsA("UIListLayout") and not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIPadding") then
				child:Destroy()
			end
		end

		PopupContainer.Size = UDim2.new(0, 0, 0, 0)
		PopupContainer.Visible = true
		ContentBuilder(PopupContainer)

		PopupOwner = OwnerButton

		local BtnAbsPos = OwnerButton.AbsolutePosition
		local MainFrame = ScreenGui:FindFirstChild("MainFrame")
		local MainPos = MainFrame.AbsolutePosition
		local MainSize = MainFrame.AbsoluteSize

		PopupContainer.Position = UDim2.new(0, MainPos.X + MainSize.X + 12, 0, BtnAbsPos.Y)

		local TargetWidth = 142
		local Info = TweenInfo.new(GetTime(0.35), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		PopupContainer.Size = UDim2.new(0, 0, 0, 0)
		PopupContainer.AutomaticSize = Enum.AutomaticSize.Y
		TweenService:Create(PopupContainer, Info, {Size = UDim2.new(0, TargetWidth, 0, 0)}):Play()

		if PopupConnection then PopupConnection:Disconnect() end
		PopupConnection = UserInputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
				local MousePos = Vector2.new(Input.Position.X, Input.Position.Y)
				local PopPos = PopupContainer.AbsolutePosition
				local PopSize = PopupContainer.AbsoluteSize
				local InPopup = (MousePos.X >= PopPos.X and MousePos.X <= PopPos.X + PopSize.X) and (MousePos.Y >= PopPos.Y and MousePos.Y <= PopPos.Y + PopSize.Y)
				local OwnerPos = OwnerButton.AbsolutePosition
				local OwnerSize = OwnerButton.AbsoluteSize
				local InOwner = (MousePos.X >= OwnerPos.X and MousePos.X <= OwnerPos.X + OwnerSize.X) and (MousePos.Y >= OwnerPos.Y and MousePos.Y <= OwnerPos.Y + OwnerSize.Y)

				local ColorPicker = ScreenGui:FindFirstChild("ColorPickerPopup")
				local InCP = false
				if ColorPicker and ColorPicker.Visible then
					local CPPos = ColorPicker.AbsolutePosition
					local CPSize = ColorPicker.AbsoluteSize
					InCP = (MousePos.X >= CPPos.X and MousePos.X <= CPPos.X + CPSize.X) and (MousePos.Y >= CPPos.Y and MousePos.Y <= CPPos.Y + CPSize.Y)
				end

				if not InPopup and not InOwner and not InCP then ClosePopup() end
			end
		end)
	end

	local MainFrame = Create("CanvasGroup", {Name = "MainFrame", Parent = ScreenGui, BorderSizePixel = 0, Position = UDim2.new(0.5, -350, 0.5, -275), Size = UDim2.new(0, 700, 0, 550), GroupTransparency = 0})
	BindToTheme(MainFrame, "BackgroundColor3", "Main")
	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
	local MainStroke = BindToTheme(Create("UIStroke", {Parent = MainFrame, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}), "Color", "Stroke")
	Create("UIDragDetector", {Parent = MainFrame})

	UserInputService.InputBegan:Connect(function(Input, GPE)
		if not GPE and Input.KeyCode == Library.WindowKeybind then
			Library.WindowOpen = not Library.WindowOpen

			if Library.WindowOpen then
				MainFrame.Visible = true
				MainStroke.Enabled = false 
				local Tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0})
				Tween.Completed:Connect(function()
					if Library.WindowOpen then MainStroke.Enabled = true end 
				end)
				Tween:Play()
			else
				MainStroke.Enabled = false 
				local Tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 1})
				Tween:Play()
				Tween.Completed:Connect(function()
					if not Library.WindowOpen then
						MainFrame.Visible = false
					end
				end)
			end
		end
	end)

	local Header = Create("Frame", {Name = "Header", Parent = MainFrame, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 50)})
	BindToTheme(Header, "BackgroundColor3", "Main")
	Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 6)})
	BindToTheme(Create("Frame", {Parent = Header, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1)}), "BackgroundColor3", "Stroke")
	local TitleLabel = Create("TextLabel", {Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Library.Theme.FontBold, Text = Title, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left})
	BindToTheme(TitleLabel, "TextColor3", "TextMain")

	local SubTitleContainer = Create("Frame", {Parent = Header, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Position = UDim2.new(0, TitleLabel.TextBounds.X + 25, 0.5, -12), Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X})
	Create("UICorner", {Parent = SubTitleContainer, CornerRadius = UDim.new(0, 4)})
	BindToTheme(Create("UIStroke", {Parent = SubTitleContainer, Thickness = 1}), "Color", "Stroke")
	BindGradient(SubTitleContainer, "SubTitleBg")

	local SubLabel = Create("TextLabel", {Parent = SubTitleContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Font = Library.Theme.Font, Text = SubTitle, TextSize = 13})
	BindToTheme(SubLabel, "TextColor3", "TextDim")
	Create("UIPadding", {Parent = SubTitleContainer, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	local HeaderTools = Create("Frame", {Parent = Header, BorderSizePixel = 0, Position = UDim2.new(1, -95, 0.5, -12), Size = UDim2.new(0, 80, 0, 24), Visible = false})
	BindToTheme(HeaderTools, "BackgroundColor3", "NavBarBg")
	Create("UICorner", {Parent = HeaderTools, CornerRadius = UDim.new(0, 6)})
	BindToTheme(Create("UIStroke", {Parent = HeaderTools, Thickness = 1}), "Color", "ElementStroke")
	BindGradient(HeaderTools, "NavBarBg")

	local Body = Create("Frame", {Name = "Body", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -80)})
	BindToTheme(Body, "BackgroundColor3", "Main")

	local Sidebar = Create("ScrollingFrame", {Name = "Sidebar", Parent = Body, BorderSizePixel = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 200, 1, 0), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y})
	BindToTheme(Sidebar, "BackgroundColor3", "Main")
	BindToTheme(Sidebar, "BorderColor3", "Stroke")

	Create("UIPadding", {Parent = Sidebar, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})
	Create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
	local ContentArea = Create("Frame", {Name = "ContentArea", Parent = Body, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0), ClipsDescendants = true})
	local Footer = Create("Frame", {Name = "Footer", Parent = MainFrame, BorderSizePixel = 1, Position = UDim2.new(0, 0, 1, -30), Size = UDim2.new(1, 0, 0, 30)})
	BindToTheme(Footer, "BackgroundColor3", "Secondary")
	BindToTheme(Footer, "BorderColor3", "Stroke")

	local StatusLabel = Create("TextLabel", {Parent = Footer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Library.Theme.Font, Text = Status, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
	BindToTheme(StatusLabel, "TextColor3", "TextDim")
	Create("ImageLabel", {Parent = Footer, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://13961129994", ImageColor3 = Color3.fromRGB(68, 68, 68)})

	local WindowFunctions = {}
	local Tabs = {}
	local FirstTab = true
	local ActiveTab = nil
	local ActiveTabIndex = 1

	function WindowFunctions:Seperator(SepOptions)
		local SepTitle = SepOptions.Title or ""
		local Sep = Create("TextLabel", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Library.Theme.Font, Text = SepTitle, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
		BindToTheme(Sep, "TextColor3", "TextDim")
	end

	function WindowFunctions:Tab(TabOptions)
		local TabTitle = TabOptions.Title or "Tab"
		local Sections = TabOptions.Sections or {}

		local TabButton = Create("TextButton", {Parent = Sidebar, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false, Font = Library.Theme.Font, Text = "", TextColor3 = Color3.fromRGB(204, 204, 204), TextSize = 14})
		Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 4)})
		local TabBtnLabel = Create("TextLabel", {Parent = TabButton, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Library.Theme.Font, Text = TabTitle, TextColor3 = Color3.fromRGB(204, 204, 204), TextSize = 14, ZIndex = 2})

		BindGradient(TabButton, "ElementBg")

		local TabContent = Create("Frame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
		Create("UIPadding", {Parent = TabContent, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})

		local TopBar = nil
		local SectionContainer = nil

		if #Sections > 0 then
			TopBar = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
			Create("UIListLayout", {Parent = TopBar, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)})
			SectionContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 1, -45), ClipsDescendants = true})
		else
			SectionContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true})
		end

		local SectionStorage = {}
		local ActiveSection = nil
		local ActiveSectionIndex = 1

		local function ShowSection(SectionName, NewIndex)
			local NewFrame = SectionStorage[SectionName]
			if not NewFrame then return end
			if ActiveSection == NewFrame then return end

			if ActiveSection then
				local OldFrame = ActiveSection
				local Direction = (NewIndex > ActiveSectionIndex) and -1 or 1

				TweenService:Create(OldFrame, TweenInfo.new(GetTime(0.4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(Direction, 0, 0, 0)}):Play()
				task.delay(GetTime(0.4), function()
					if ActiveSection ~= OldFrame then OldFrame.Visible = false end
				end)

				NewFrame.Visible = true
				NewFrame.Position = UDim2.new(-Direction, 0, 0, 0)
				TweenService:Create(NewFrame, TweenInfo.new(GetTime(0.4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
			end

			ActiveSection = NewFrame
			ActiveSectionIndex = NewIndex
		end

		local function CreateElements(ParentFrame)
			local Elements = {}
			Create("UIListLayout", {Parent = ParentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)})

			local CurrentContainer = nil

			local function CreateContainer()
				if ParentFrame:FindFirstChild("Frame") and not ParentFrame:FindFirstChild("Frame"):FindFirstChild("TextButton") then
					return ParentFrame:FindFirstChild("Frame")
				end
				local Container = Create("Frame", {Parent = ParentFrame, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderSizePixel = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
				BindToTheme(Container, "BorderColor3", "Stroke")
				Create("UIPadding", {Parent = Container, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
				BindToTheme(Create("UIStroke", {Parent = Container, Thickness = 1}), "Color", "Stroke")
				Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
				Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)})
				return Container
			end

			CurrentContainer = CreateContainer()

			local function CreateRow(Title, Desc)
				local Row = Create("Frame", {Parent = CurrentContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), BorderSizePixel = 0})

				local TextContainer = Create("Frame", {Parent = Row, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0)})
				Create("UIPadding", {Parent = TextContainer, PaddingLeft = UDim.new(0, 13)})
				Create("UIListLayout", {Parent = TextContainer, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 2)})
				local TitleLbl = Create("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Library.Theme.Font, Text = Title, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
				BindToTheme(TitleLbl, "TextColor3", "TextMain")
				local DescLbl = Create("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Library.Theme.Font, Text = Desc, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
				BindToTheme(DescLbl, "TextColor3", "TextDim")
				return Row
			end

			local function CreateAttachments(Container, ToggleCallback)
				local Funcs = {}
				function Funcs:Bind(BindOptions)
					local DefaultBind = BindOptions.Default or Enum.KeyCode.RightShift
					local Mode = BindOptions.Mode or "Toggle"
					local BindCallback = BindOptions.Callback or function() end

					local BindBtn = Create("TextButton", {Parent = Container, Size = UDim2.new(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.X, Text = "", AutoButtonColor = false, LayoutOrder = 5})
					BindToTheme(BindBtn, "BackgroundColor3", "Stroke")
					BindToTheme(BindBtn, "BorderColor3", "ElementStroke")

					Create("UIPadding", {Parent = BindBtn, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
					Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
					BindGradient(BindBtn, "Stroke")

					local ContentContainer = Create("Frame", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
					Create("UIListLayout", {Parent = ContentContainer, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4)})

					local BindLabel = Create("TextLabel", {Parent = ContentContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Font = Library.Theme.Font, Text = DefaultBind.Name, TextColor3 = Color3.fromRGB(204, 204, 204), TextSize = 12, LayoutOrder = 1})
					local BindIcon = Create("ImageLabel", {Parent = ContentContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 12, 0, 12), Image = Assets.Keybind, LayoutOrder = 2})
					BindToTheme(BindIcon, "ImageColor3", "TextMain")

					local Key = DefaultBind
					local Binding = false

					BindBtn.MouseButton1Click:Connect(function() Binding = true; BindLabel.Text = "..." end)

					BindBtn.MouseButton2Click:Connect(function()
						OpenPopup(BindBtn, function(Popup)
							local Modes = {"Toggle", "Hold", "Always"}
							local ScrollFrame = Create("ScrollingFrame", {Parent = Popup, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 90), AutomaticSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0})
							Create("UIListLayout", {Parent = ScrollFrame, SortOrder = Enum.SortOrder.LayoutOrder})
							for _, m in Modes do
								local OptBtn = Create("TextButton", {Parent = ScrollFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 140, 0, 30), Text = m, Font = Library.Theme.Font, TextColor3 = (Mode == m) and Library.Theme.Accent or Library.Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
								Create("UIPadding", {Parent = OptBtn, PaddingLeft = UDim.new(0, 10)})
								OptBtn.MouseButton1Click:Connect(function() Mode = m; ClosePopup() end)
							end
						end)
					end)

					local function SetKey(NewKey)
						Key = NewKey
						if type(NewKey) == "string" then
							BindLabel.Text = NewKey
						elseif NewKey.EnumType == Enum.KeyCode then
							BindLabel.Text = NewKey.Name
						elseif NewKey.EnumType == Enum.UserInputType then
							if NewKey == Enum.UserInputType.MouseButton1 then BindLabel.Text = "MB1" end
							if NewKey == Enum.UserInputType.MouseButton2 then BindLabel.Text = "MB2" end
							if NewKey == Enum.UserInputType.MouseButton3 then BindLabel.Text = "MB3" end
						end
						BindCallback(NewKey)
					end

					UserInputService.InputBegan:Connect(function(Input)
						if Binding then
							if Input.UserInputType == Enum.UserInputType.Keyboard then
								if Input.KeyCode == Enum.KeyCode.Escape then
									Binding = false
									Key = nil
									BindLabel.Text = "None"
									PlayClickEffect(BindBtn)
								else
									Binding = false
									SetKey(Input.KeyCode)
									PlayClickEffect(BindBtn)
								end
							elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
								Binding = false
								SetKey(Enum.UserInputType.MouseButton1)
								PlayClickEffect(BindBtn)
							elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
								Binding = false
								SetKey(Enum.UserInputType.MouseButton2)
								PlayClickEffect(BindBtn)
							elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
								Binding = false
								SetKey(Enum.UserInputType.MouseButton3)
								PlayClickEffect(BindBtn)
							end
						elseif Key and ToggleCallback then
							local Trigger = false
							if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key then
								Trigger = true
							elseif (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.MouseButton3) and Input.UserInputType == Key then
								Trigger = true
							end

							if Trigger then
								if Mode == "Toggle" then
									ToggleCallback("Toggle")
								elseif Mode == "Hold" then
									ToggleCallback(true)
								end
							end
						end
					end)

					UserInputService.InputEnded:Connect(function(Input)
						if Key and ToggleCallback and Mode == "Hold" then
							local Trigger = false
							if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key then
								Trigger = true
							elseif (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.MouseButton3) and Input.UserInputType == Key then
								Trigger = true
							end

							if Trigger then ToggleCallback(false) end
						end
					end)

					local BindObj = {}
					function BindObj:GetValue() return Key end
					function BindObj:SetValue(NewKey) SetKey(NewKey) end
					function BindObj:GetMode() return Mode end
					function BindObj:SetMode(NewMode) Mode = NewMode end
					function BindObj:GetComponentType() return "Bind" end

					if BindOptions.Flag then Library.Flags[BindOptions.Flag] = BindObj end

					return Funcs
				end

				function Funcs:Colorpicker(ColorProps)
					ColorProps = ColorProps or {}
					local Default = ColorProps.Default or Color3.fromRGB(255, 255, 255)
					local Callback = ColorProps.Callback or function() end
					local CurrentColor = Default
					local CurrentAlpha = 1
					local HSV = {Color3.toHSV(CurrentColor)}

					local ColorBtn = Create("TextButton", {Parent = Container, Text = "", Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = CurrentColor, AutoButtonColor = false, LayoutOrder = 2})
					Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(1, 0)})
					BindToTheme(Create("UIStroke", {Parent = ColorBtn, Thickness = 1}), "Color", "Stroke")

					local PickerFrame = Create("Frame", {Name = "ColorPickerPopup", Parent = ScreenGui, BorderSizePixel = 1, Size = UDim2.new(0, 220, 0, 225), Visible = false, ZIndex = 3000})
					BindToTheme(PickerFrame, "BackgroundColor3", "Main")
					BindToTheme(PickerFrame, "BorderColor3", "Stroke")
					Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0, 6)})
					BindToTheme(Create("UIStroke", {Parent = PickerFrame, Thickness = 1}), "Color", "Stroke")
					Create("UIPadding", {Parent = PickerFrame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
					Create("UIDragDetector", {Parent = PickerFrame})

					local ColorMap = Create("TextButton", {Parent = PickerFrame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1), AutoButtonColor = false, Text = "", ZIndex = 3001})
					local SatOverlay = Create("Frame", {Parent = ColorMap, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3002, BorderSizePixel = 0})
					local SatGradient = Create("UIGradient", {Parent = SatOverlay, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}})
					local ValOverlay = Create("Frame", {Parent = ColorMap, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 3003, BorderSizePixel = 0})
					local ValGradient = Create("UIGradient", {Parent = ValOverlay, Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}})
					local MapMarker = Create("ImageLabel", {Parent = ColorMap, Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, Image = Assets.PickerCursor, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0), ZIndex = 3004})
					Create("UICorner", {Parent = ColorMap, CornerRadius = UDim.new(0, 4)})

					local function CreatePickerSlider(Title, Suffix, MaxVal)
						local SliderFrame = Create("Frame", {Parent = PickerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 0, 0, 0)})
						local Top = Create("Frame", {Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15)})
						local TitleLbl = Create("TextLabel", {Parent = Top, Text = Title, Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Font = Library.Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
						BindToTheme(TitleLbl, "TextColor3", "TextDim")

						local ValLabel = Create("TextLabel", {Parent = Top, Text = "0", Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Font = Library.Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
						BindToTheme(ValLabel, "TextColor3", "TextMain")

						local Track = Create("TextButton", {Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(26, 26, 26), BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 4), Text = "", AutoButtonColor = false})
						Create("UICorner", {Parent = Track, CornerRadius = UDim.new(0, 2)})

						local Fill = Create("Frame", {Parent = Track, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)})
						BindToTheme(Fill, "BackgroundColor3", "Accent")
						Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 2)})
						-- Removed gradient from slider fill as requested
						-- BindGradient(Fill, "Accent")

						local Thumb = Create("Frame", {Parent = Track, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1})
						BindToTheme(Thumb, "BackgroundColor3", "Accent")
						Create("UICorner", {Parent = Thumb, CornerRadius = UDim.new(1, 0)})
						local InnerThumb = Create("Frame", {Parent = Thumb, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1})
						BindToTheme(InnerThumb, "BackgroundColor3", "Main")
						Create("UICorner", {Parent = InnerThumb, CornerRadius = UDim.new(1, 0)})

						Track.MouseEnter:Connect(function()
							TweenService:Create(Thumb, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = 0}):Play()
							TweenService:Create(InnerThumb, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = 0}):Play()
						end)
						Track.MouseLeave:Connect(function()
							TweenService:Create(Thumb, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = 1}):Play()
							TweenService:Create(InnerThumb, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = 1}):Play()
						end)

						return {Frame = SliderFrame, Track = Track, Fill = Fill, Thumb = Thumb, Label = ValLabel}
					end

					Create("UIListLayout", {Parent = PickerFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
					ColorMap.LayoutOrder = 1

					local HueSlider = CreatePickerSlider("Hue", "", 1)
					HueSlider.Frame.LayoutOrder = 2
					local AlphaSlider = CreatePickerSlider("Transparency", "%", 1)
					AlphaSlider.Frame.LayoutOrder = 3

					local function UpdateVisuals()
						ColorBtn.BackgroundColor3 = CurrentColor
						ColorMap.BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1)

						TweenService:Create(MapMarker, TweenInfo.new(GetTime(0.05)), {Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)}):Play()

						local HuePct = HSV[1]
						TweenService:Create(HueSlider.Fill, TweenInfo.new(GetTime(0.05)), {Size = UDim2.new(HuePct, 0, 1, 0)}):Play()
						TweenService:Create(HueSlider.Thumb, TweenInfo.new(GetTime(0.05)), {Position = UDim2.new(HuePct, 0, 0.5, 0)}):Play()
						HueSlider.Label.Text = `{math.floor(HSV[1] * 360)}`

						local AlphaPct = CurrentAlpha
						TweenService:Create(AlphaSlider.Fill, TweenInfo.new(GetTime(0.05)), {Size = UDim2.new(AlphaPct, 0, 1, 0)}):Play()
						TweenService:Create(AlphaSlider.Thumb, TweenInfo.new(GetTime(0.05)), {Position = UDim2.new(AlphaPct, 0, 0.5, 0)}):Play()
						AlphaSlider.Label.Text = `{math.floor(CurrentAlpha * 100)}%`

						Callback(CurrentColor, CurrentAlpha)
					end

					local function HandleInput(GuiObj, Type, Input)
						local function Update(InputPos)
							local MaxX = GuiObj.AbsoluteSize.X
							local MaxY = GuiObj.AbsoluteSize.Y
							local Px = math.clamp(InputPos.X - GuiObj.AbsolutePosition.X, 0, MaxX)
							local Py = math.clamp(InputPos.Y - GuiObj.AbsolutePosition.Y, 0, MaxY)
							local X = Px / MaxX
							local Y = Py / MaxY

							if Type == "Map" then
								HSV[2] = X
								HSV[3] = 1 - Y
							elseif Type == "Hue" then
								HSV[1] = X
							elseif Type == "Alpha" then
								CurrentAlpha = X
							end
							CurrentColor = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
							UpdateVisuals()
						end
						Update(Input.Position)
						local MoveConn = UserInputService.InputChanged:Connect(function(Mv)
							if Mv.UserInputType == Enum.UserInputType.MouseMovement or Mv.UserInputType == Enum.UserInputType.Touch then
								Update(Mv.Position)
							end
						end)
						local EndConn
						EndConn = UserInputService.InputEnded:Connect(function(End)
							if End.UserInputType == Enum.UserInputType.MouseButton1 or End.UserInputType == Enum.UserInputType.Touch then
								MoveConn:Disconnect()
								EndConn:Disconnect()
							end
						end)
					end

					ColorMap.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(ColorMap, "Map", Input) end end)
					HueSlider.Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(HueSlider.Track, "Hue", Input) end end)
					AlphaSlider.Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(AlphaSlider.Track, "Alpha", Input) end end)

					ColorBtn.MouseButton1Click:Connect(function()
						if PickerFrame.Visible then
							PickerFrame.Visible = false
						else
							ClosePopup()

							local BtnPos = ColorBtn.AbsolutePosition
							local ScreenSize = ScreenGui.AbsoluteSize
							local X = BtnPos.X - 230
							local Y = BtnPos.Y + 25

							if X < 0 then X = BtnPos.X + 35 end
							if Y + 225 > ScreenSize.Y then Y = ScreenSize.Y - 230 end

							PickerFrame.Position = UDim2.new(0, X, 0, Y)
							PickerFrame.Visible = true
						end
					end)

					UserInputService.InputBegan:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							if PickerFrame.Visible then
								local MousePos = Vector2.new(Input.Position.X, Input.Position.Y)
								local PPos = PickerFrame.AbsolutePosition
								local PSize = PickerFrame.AbsoluteSize
								local BtnPos = ColorBtn.AbsolutePosition
								local BtnSize = ColorBtn.AbsoluteSize

								local InPicker = (MousePos.X >= PPos.X and MousePos.X <= PPos.X + PSize.X) and (MousePos.Y >= PPos.Y and MousePos.Y <= PPos.Y + PSize.Y)
								local InBtn = (MousePos.X >= BtnPos.X and MousePos.X <= BtnPos.X + BtnSize.X) and (MousePos.Y >= BtnPos.Y and MousePos.Y <= BtnPos.Y + BtnSize.Y)

								if not InPicker and not InBtn then
									PickerFrame.Visible = false
								end
							end
						end
					end)

					local CPObj = {}
					function CPObj:GetValue() return CurrentColor end
					function CPObj:SetValue(Val) CurrentColor = Val; HSV = {Color3.toHSV(Val)}; UpdateVisuals() end
					function CPObj:GetTransparency() return CurrentAlpha end
					function CPObj:SetTransparency(Val) CurrentAlpha = Val; UpdateVisuals() end
					function CPObj:GetComponentType() return "Colorpicker" end

					if ColorProps.Flag then Library.Flags[ColorProps.Flag] = CPObj end

					UpdateVisuals()

					return Funcs
				end

				return Funcs
			end

			local function CreateBoolean(Options, IsCheckbox)
				local Title = Options.Title or "Title"
				local Desc = Options.Description or ""
				local Default = Options.Default or false
				local Callback = Options.Callback or function() end
				local Row = CreateRow(Title, Desc)
				local State = Default
				local RightSide = Create("Frame", {Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(1, -100, 0, 0), Size = UDim2.new(0, 100, 1, 0)})
				Create("UIListLayout", {Parent = RightSide, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})

				local Switch, Circle
				if not IsCheckbox then
					Switch = Create("TextButton", {Parent = RightSide, BorderSizePixel = 0, Size = UDim2.new(0, 36, 0, 20), Text = "", AutoButtonColor = false, LayoutOrder = 10})
					Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
					BindToTheme(Create("UIStroke", {Parent = Switch, Thickness = 1}), "Color", "ElementStroke")
					BindGradient(Switch, State and "Accent" or "ElementStroke")

					Circle = Create("Frame", {Parent = Switch, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = State and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3), Size = UDim2.new(0, 14, 0, 14)})
					Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
					Circle.BackgroundColor3 = State and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
				end

				local function SetState(NewState)
					if NewState == "Toggle" then NewState = not State end
					if NewState == State then return end
					State = NewState

					if Switch then
						local TargetTheme = State and "Accent" or "ElementStroke"
						BindGradient(Switch, TargetTheme) -- This now updates existing registry instead of duplicating
						TweenGradient(Switch, Library.Theme[TargetTheme], 0.3)

						local TargetKnobColor = State and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
						local TargetPos = State and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
						TweenService:Create(Circle, TweenInfo.new(GetTime(0.3), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = TargetKnobColor, Position = TargetPos}):Play()
					end
					Callback(State)
				end

				if Switch then
					Switch.MouseButton1Click:Connect(function() SetState("Toggle") end)
				end

				local TglObj = {}
				function TglObj:GetValue() return State end
				function TglObj:SetValue(Val) SetState(Val) end
				function TglObj:GetComponentType() return "Toggle" end
				if Options.Flag then Library.Flags[Options.Flag] = TglObj end

				return CreateAttachments(RightSide, SetState)
			end

			function Elements:Toggle(ToggleOptions) return CreateBoolean(ToggleOptions, false) end
			function Elements:Label(LabelOptions)
				local LblTitle = LabelOptions.Title or "Label"
				local LblDesc = LabelOptions.Description or ""
				local Row = CreateRow(LblTitle, LblDesc)
				local RightSide = Create("Frame", {Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(1, -100, 0, 0), Size = UDim2.new(0, 100, 1, 0)})
				Create("UIListLayout", {Parent = RightSide, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})
				return CreateAttachments(RightSide)
			end

			function Elements:Slider(SliderOptions)
				local SliderTitle = SliderOptions.Title or "Slider"
				local SliderDesc = SliderOptions.Description or ""
				local Min = SliderOptions.Min or 0
				local Max = SliderOptions.Max or 100
				local Default = SliderOptions.Default or Min
				local Prefix = SliderOptions.Prefix or ""
				local Suffix = SliderOptions.Suffix or ""
				local Dual = SliderOptions.Dual or false
				local Decimal = SliderOptions.Decimal
				local ZeroNumber = SliderOptions.ZeroNumber
				local Callback = SliderOptions.Callback or function() end

				local Precision = Decimal and 10 ^ Decimal or 1

				local CurrentValue = Default
				local CurrentMin = Min
				local CurrentMax = Max

				if Dual then
					if type(Default) == "table" then
						CurrentMin = Default.Min or Min
						CurrentMax = Default.Max or Max
					else
						CurrentMin = Min
						CurrentMax = Default or Max
					end
				end

				local Row = CreateRow(SliderTitle, SliderDesc)
				Row:Destroy()

				local SliderRoot = Create("TextButton", {Parent = CurrentContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = "", AutoButtonColor = false})
				local SliderContent = Create("Frame", {Parent = SliderRoot, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
				Create("UIPadding", {Parent = SliderContent, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 13)})
				Create("UIListLayout", {Parent = SliderContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})

				local TopRow = Create("Frame", {Parent = SliderContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1})
				local TitleLbl = Create("TextLabel", {Parent = TopRow, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Font = Library.Theme.Font, Text = SliderTitle, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
				BindToTheme(TitleLbl, "TextColor3", "TextMain")
				local ValueLabel = Create("TextLabel", {Parent = TopRow, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 60, 1, 0), Font = Library.Theme.Font, Text = "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
				BindToTheme(ValueLabel, "TextColor3", "TextMain")
				if SliderDesc ~= "" then
					local DescLbl = Create("TextLabel", {Parent = SliderContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Library.Theme.Font, Text = SliderDesc, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = 2})
					BindToTheme(DescLbl, "TextColor3", "TextDim")
				end

				local TrackContainer = Create("Frame", {Parent = SliderContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), LayoutOrder = 3})
				local Track = Create("Frame", {Parent = TrackContainer, BackgroundColor3 = Color3.fromRGB(26, 26, 26), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 4)})
				Create("UICorner", {Parent = Track, CornerRadius = UDim.new(0, 2)})
				local Fill = Create("Frame", {Parent = Track, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)})
				BindToTheme(Fill, "BackgroundColor3", "Accent")
				Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 2)})
				-- Removed gradient from slider fill as requested
				-- BindGradient(Fill, "Accent")

				local ThumbMax = Create("Frame", {Parent = Track, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1})
				BindToTheme(ThumbMax, "BackgroundColor3", "Accent")
				Create("UICorner", {Parent = ThumbMax, CornerRadius = UDim.new(1, 0)})
				local InnerThumbMax = Create("Frame", {Parent = ThumbMax, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1})
				BindToTheme(InnerThumbMax, "BackgroundColor3", "Main")
				Create("UICorner", {Parent = InnerThumbMax, CornerRadius = UDim.new(1, 0)})

				local ThumbMin, InnerThumbMin
				if Dual then
					ThumbMin = Create("Frame", {Parent = Track, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1})
					BindToTheme(ThumbMin, "BackgroundColor3", "Accent")
					Create("UICorner", {Parent = ThumbMin, CornerRadius = UDim.new(1, 0)})
					InnerThumbMin = Create("Frame", {Parent = ThumbMin, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1})
					BindToTheme(InnerThumbMin, "BackgroundColor3", "Main")
					Create("UICorner", {Parent = InnerThumbMin, CornerRadius = UDim.new(1, 0)})
				end

				local function Round(num)
					return math.floor(num * Precision + 0.5) / Precision
				end

				local function UpdateVisuals()
					if Dual then
						local PctMin = (CurrentMin - Min) / (Max - Min)
						local PctMax = (CurrentMax - Min) / (Max - Min)
						PctMin = math.clamp(PctMin, 0, 1)
						PctMax = math.clamp(PctMax, 0, 1)

						TweenService:Create(Fill, TweenInfo.new(GetTime(0.05), Enum.EasingStyle.Sine), {Position = UDim2.new(PctMin, 0, 0, 0), Size = UDim2.new(PctMax - PctMin, 0, 1, 0)}):Play()
						TweenService:Create(ThumbMin, TweenInfo.new(GetTime(0.05), Enum.EasingStyle.Sine), {Position = UDim2.new(PctMin, 0, 0.5, 0)}):Play()
						TweenService:Create(ThumbMax, TweenInfo.new(GetTime(0.05), Enum.EasingStyle.Sine), {Position = UDim2.new(PctMax, 0, 0.5, 0)}):Play()

						ValueLabel.Text = `{Prefix}{Round(CurrentMin)} - {Round(CurrentMax)}{Suffix}`
					else
						local StartVal = ZeroNumber or Min
						local PctVal = (CurrentValue - Min) / (Max - Min)
						local PctZero = (StartVal - Min) / (Max - Min)
						PctVal = math.clamp(PctVal, 0, 1)
						PctZero = math.clamp(PctZero, 0, 1)

						local Pos = math.min(PctZero, PctVal)
						local Size = math.abs(PctVal - PctZero)

						TweenService:Create(Fill, TweenInfo.new(GetTime(0.05), Enum.EasingStyle.Sine), {Position = UDim2.new(Pos, 0, 0, 0), Size = UDim2.new(Size, 0, 1, 0)}):Play()
						TweenService:Create(ThumbMax, TweenInfo.new(GetTime(0.05), Enum.EasingStyle.Sine), {Position = UDim2.new(PctVal, 0, 0.5, 0)}):Play()
						ValueLabel.Text = `{Prefix}{Round(CurrentValue)}{Suffix}`
					end
				end

				local Dragging = false
				local DragTarget = "Max"

				local function UpdateSlider(Input)
					local SizeX = Track.AbsoluteSize.X
					local PosX = Track.AbsolutePosition.X
					local Pct = math.clamp((Input.Position.X - PosX) / SizeX, 0, 1)
					local Value = Min + ((Max - Min) * Pct)
					Value = Round(Value)

					if Dual then
						if DragTarget == "Min" then
							CurrentMin = math.min(Value, CurrentMax)
						else
							CurrentMax = math.max(Value, CurrentMin)
						end
						UpdateVisuals()
						Callback(CurrentMin, CurrentMax)
					else
						CurrentValue = Value
						UpdateVisuals()
						Callback(CurrentValue)
					end
				end

				local function SetValue(Val)
					if Dual and type(Val) == "table" then
						CurrentMin = Val.Min or Min
						CurrentMax = Val.Max or Max
						UpdateVisuals()
					elseif not Dual then
						CurrentValue = Val
						UpdateVisuals()
					end
				end

				UpdateVisuals()

				local function SetThumbVisibility(Transparency)
					TweenService:Create(ThumbMax, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = Transparency}):Play()
					TweenService:Create(InnerThumbMax, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = Transparency}):Play()
					if ThumbMin then
						TweenService:Create(ThumbMin, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = Transparency}):Play()
						TweenService:Create(InnerThumbMin, TweenInfo.new(GetTime(0.2)), {BackgroundTransparency = Transparency}):Play()
					end
				end

				SliderRoot.MouseEnter:Connect(function()
					SetThumbVisibility(0)
				end)
				SliderRoot.MouseLeave:Connect(function()
					SetThumbVisibility(1)
				end)

				SliderRoot.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						if Dual then
							local MouseX = Input.Position.X
							local MinPos = ThumbMin.AbsolutePosition.X
							local MaxPos = ThumbMax.AbsolutePosition.X

							if math.abs(MouseX - MinPos) == math.abs(MouseX - MaxPos) then
								if MouseX < MinPos then DragTarget = "Min" else DragTarget = "Max" end
							elseif math.abs(MouseX - MinPos) < math.abs(MouseX - MaxPos) then
								DragTarget = "Min"
							else
								DragTarget = "Max"
							end
						else
							DragTarget = "Max"
						end
						UpdateSlider(Input)
					end
				end)
				UserInputService.InputChanged:Connect(function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(Input) end end)
				UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
					end
				end)

				local SldObj = {}
				function SldObj:GetValue() return Dual and {Min = CurrentMin, Max = CurrentMax} or CurrentValue end
				function SldObj:SetValue(Val) SetValue(Val) end
				function SldObj:GetComponentType() return "Slider" end
				if SliderOptions.Flag then Library.Flags[SliderOptions.Flag] = SldObj end
			end

			function Elements:Dropdown(DropdownOptions)
				local DropTitle = DropdownOptions.Title or "Dropdown"
				local DropDesc = DropdownOptions.Description or ""
				local Options = DropdownOptions.Options or {}
				local Default = DropdownOptions.Default or (DropdownOptions.Multi and {}) or "Select..."
				local Multi = DropdownOptions.Multi or false
				local Callback = DropdownOptions.Callback or function() end
				local Row = CreateRow(DropTitle, DropDesc)
				local Box = Create("TextButton", {Parent = Row, BorderColor3 = Library.Theme.Stroke, Position = UDim2.new(1, -140, 0.5, -12), Size = UDim2.new(0, 140, 0, 24), Text = "", AutoButtonColor = false})
				BindToTheme(Box, "BackgroundColor3", "Stroke")
				Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
				BindGradient(Box, "Stroke")
				local CurrentLabel = Create("TextLabel", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Library.Theme.Font, Text = "", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
				BindToTheme(CurrentLabel, "TextColor3", "TextMain")
				local DropIcon = Create("ImageLabel", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(1, -22, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = Assets.Dropdown})
				BindToTheme(DropIcon, "ImageColor3", "TextMain")

				local Selected = Multi and (type(Default) == "table" and Default or {}) or Default

				local function UpdateText()
					local Txt = ""
					if Multi then
						if #Selected == 0 then Txt = "Select..." else Txt = table.concat(Selected, ", ") end
					else
						Txt = tostring(Selected)
					end
					CurrentLabel.Text = Txt

					local TextSize = TextService:GetTextSize(Txt, 13, Library.Theme.Font, Vector2.new(1000, 24)).X
					local TargetWidth = math.clamp(TextSize + 40, 140, 240)
					TweenService:Create(Box, TweenInfo.new(GetTime(0.2), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, TargetWidth, 0, 24), Position = UDim2.new(1, -TargetWidth, 0.5, -12)}):Play()
				end

				UpdateText()

				local function RefreshList(Container)
					for _, C in Container:GetChildren() do
						if C:IsA("TextButton") or C:IsA("Frame") then
							C:Destroy()
						end
					end

					for i, Option in Options do
						local IsSelected = false
						if Multi then
							for _, s in Selected do
								if s == Option then IsSelected = true break end
							end
						else
							IsSelected = (Selected == Option)
						end

						local OptBtn = Create("TextButton", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(0, 140, 0, 30), Text = Option, Font = Library.Theme.Font, TextColor3 = IsSelected and Library.Theme.Accent or Library.Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
						Create("UIPadding", {Parent = OptBtn, PaddingLeft = UDim.new(0, 10)})
						if i < #Options then
							local Sep = Create("Frame", {Parent = OptBtn, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1)})
							BindToTheme(Sep, "BackgroundColor3", "Stroke")
						end
						OptBtn.MouseButton1Click:Connect(function()
							if Multi then
								local Found = false
								for idx, s in Selected do
									if s == Option then
										table.remove(Selected, idx)
										Found = true
										OptBtn.TextColor3 = Library.Theme.TextDim
										break
									end
								end
								if not Found then
									table.insert(Selected, Option)
									OptBtn.TextColor3 = Library.Theme.Accent
								end
								UpdateText()
								Callback(Selected)
							else
								Selected = Option
								UpdateText()
								Callback(Option)
								ClosePopup()
							end
						end)
					end
				end

				Box.MouseButton1Click:Connect(function()
					OpenPopup(Box, function(Container)
						local ScrollFrame = Create("ScrollingFrame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, BorderSizePixel = 0})
						local MaxHeight = math.min(#Options * 30, 240)
						ScrollFrame.Size = UDim2.new(1, 0, 0, MaxHeight)
						Create("UIListLayout", {Parent = ScrollFrame, SortOrder = Enum.SortOrder.LayoutOrder})
						RefreshList(ScrollFrame)
					end)
				end)

				local DropObj = {}
				function DropObj:GetValue() return Selected end
				function DropObj:SetValue(Val) Selected = Val; UpdateText() end
				function DropObj:GetOptions() return Options end
				function DropObj:SetOptions(NewOpts) Options = NewOpts end
				function DropObj:GetComponentType() return "Dropdown" end
				if DropdownOptions.Flag then Library.Flags[DropdownOptions.Flag] = DropObj end
			end

			function Elements:Textbox(TextboxOptions)
				local TextTitle = TextboxOptions.Title or "Textbox"
				local TextDesc = TextboxOptions.Description or ""
				local Placeholder = TextboxOptions.Placeholder or "Placeholder"
				local Default = TextboxOptions.Default or ""
				local ClearOnFocus = TextboxOptions.ClearOnFocus
				local Callback = TextboxOptions.Callback or function() end
				local Row = CreateRow(TextTitle, TextDesc)
				local Box = Create("Frame", {Parent = Row, BorderColor3 = Library.Theme.Stroke, Position = UDim2.new(1, -140, 0.5, -12), Size = UDim2.new(0, 140, 0, 24), ClipsDescendants = true})
				BindToTheme(Box, "BackgroundColor3", "Stroke")
				Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
				BindGradient(Box, "Stroke")
				local Input = Create("TextBox", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Library.Theme.Font, Text = Default, PlaceholderText = Placeholder, TextColor3 = Color3.fromRGB(204, 204, 204), PlaceholderColor3 = Color3.fromRGB(119, 119, 119), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = ClearOnFocus, TextTruncate = Enum.TextTruncate.AtEnd})

				local function UpdateWidth()
					local TextSize = TextService:GetTextSize(Input.Text, 13, Library.Theme.Font, Vector2.new(1000, 24)).X
					local TargetWidth = math.clamp(TextSize + 20, 140, 240)
					TweenService:Create(Box, TweenInfo.new(GetTime(0.2), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, TargetWidth, 0, 24), Position = UDim2.new(1, -TargetWidth, 0.5, -12)}):Play()
				end
				Input:GetPropertyChangedSignal("Text"):Connect(UpdateWidth)
				Input.FocusLost:Connect(function() Callback(Input.Text); PlayClickEffect(Box) end)
				local TxtIcon = Create("ImageLabel", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(1, -22, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), Image = Assets.Textbox})
				BindToTheme(TxtIcon, "ImageColor3", "TextMain")

				local TxtObj = {}
				function TxtObj:GetValue() return Input.Text end
				function TxtObj:SetValue(Val) Input.Text = Val; UpdateWidth() end
				function TxtObj:GetComponentType() return "Textbox" end
				if TextboxOptions.Flag then Library.Flags[TextboxOptions.Flag] = TxtObj end
			end

			function Elements:Button(ButtonOptions)
				local BtnTitle = ButtonOptions.Title or "Button"
				local BtnDesc = ButtonOptions.Description or ""
				local BtnText = ButtonOptions.Action or "Button"
				local Callback = ButtonOptions.Callback or function() end
				local Row = CreateRow(BtnTitle, BtnDesc)
				local Box = Create("TextButton", {Parent = Row, BorderColor3 = Library.Theme.Stroke, Position = UDim2.new(1, -140, 0.5, -12), Size = UDim2.new(0, 140, 0, 24), Text = "", AutoButtonColor = false})
				BindToTheme(Box, "BackgroundColor3", "Stroke")
				Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
				BindGradient(Box, "Stroke")
				local BtnLbl = Create("TextLabel", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Library.Theme.Font, Text = BtnText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
				BindToTheme(BtnLbl, "TextColor3", "TextDim")
				local BtnIcon = Create("ImageLabel", {Parent = Box, BackgroundTransparency = 1, Position = UDim2.new(1, -22, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), Image = Assets.Button})
				BindToTheme(BtnIcon, "ImageColor3", "TextMain")
				Box.MouseButton1Click:Connect(function() PlayClickEffect(Box); Callback() end)
			end
			return Elements
		end

		if #Sections > 0 then
			for i, SectionName in Sections do
				local TopBtn = Create("TextButton", {Parent = TopBar, BackgroundColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Library.Theme.ElementBg, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), AutoButtonColor = false, Font = Library.Theme.Font, Text = "", TextColor3 = (i == 1) and Color3.fromRGB(0, 0, 0) or Library.Theme.TextDim, TextSize = 14, AutomaticSize = Enum.AutomaticSize.X})
				Create("UIPadding", {Parent = TopBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})
				Create("UICorner", {Parent = TopBtn, CornerRadius = UDim.new(0, 4)})
				Create("TextLabel", {Parent = TopBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Library.Theme.Font, Text = SectionName, TextColor3 = (i == 1) and Color3.fromRGB(0, 0, 0) or Library.Theme.TextDim, TextSize = 14, ZIndex = 2})

				local AccentTop = Library.Theme.Accent
				local AccentBot = GetDarkerColor(AccentTop)

				BindGradient(TopBtn, "ElementBg")

				local ActiveGradient = Create("UIGradient", {Name = "ActiveGradient", Parent = TopBtn, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, AccentTop), ColorSequenceKeypoint.new(1, AccentBot)}), Rotation = 90, Enabled = (i == 1)})
				table.insert(Library.Registry, {Object = ActiveGradient, ThemeKey = "Accent", Type = "ActiveGradient"})

				local SectionFrame = Create("ScrollingFrame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, Visible = (i == 1), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0)})
				Create("UIPadding", {Parent = SectionFrame, PaddingRight = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 10)})
				SectionStorage[SectionName] = SectionFrame

				if i == 1 then
					TopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					local NormGrad = TopBtn:FindFirstChild("UIGradient")
					if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = false end
					ActiveSection = SectionFrame
				end

				TopBtn.MouseButton1Click:Connect(function()
					for _, Btn in TopBar:GetChildren() do
						if Btn:IsA("TextButton") then
							local NormGrad = Btn:FindFirstChild("UIGradient")
							if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = true end

							if Btn:FindFirstChild("TextLabel") then Btn.TextLabel.TextColor3 = Library.Theme.TextDim end
							if Btn:FindFirstChild("ActiveGradient") then Btn.ActiveGradient.Enabled = false end
						end
					end

					local NormGrad = TopBtn:FindFirstChild("UIGradient")
					if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = false end

					TopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if TopBtn:FindFirstChild("TextLabel") then TopBtn.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0) end
					if TopBtn:FindFirstChild("ActiveGradient") then TopBtn.ActiveGradient.Enabled = true end
					ShowSection(SectionName, i)
				end)
			end
		else
			local DefaultFrame = Create("ScrollingFrame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0)})
			Create("UIPadding", {Parent = DefaultFrame, PaddingRight = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 10)})
			SectionStorage["Default"] = DefaultFrame
			local DirectElements = CreateElements(DefaultFrame)
			local TabProxy = {}
			setmetatable(TabProxy, {__index = function(_, key) if DirectElements[key] then return DirectElements[key] end return DirectElements end})
		end
		local TabFunctions = {}
		function TabFunctions:GetSection(Name) if SectionStorage[Name] then return CreateElements(SectionStorage[Name]) end; if SectionStorage["Default"] then return CreateElements(SectionStorage["Default"]) end end
		if #Sections == 0 then
			local DefaultElems = CreateElements(SectionStorage["Default"])
			for FuncName, Func in DefaultElems do
				TabFunctions[FuncName] = Func
			end
		end

		local ThisTabIndex = #Tabs + 1
		TabButton.MouseButton1Click:Connect(function()
			for _, Tab in Tabs do
				if Tab.Button:FindFirstChild("ActiveGradient") then Tab.Button.ActiveGradient.Enabled = false end
				local NormGrad = Tab.Button:FindFirstChild("UIGradient")
				if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = true end

				if Tab.Button:FindFirstChild("TextLabel") then Tab.Button.TextLabel.TextColor3 = Color3.fromRGB(204, 204, 204) end
				Tab.Button.Font = Library.Theme.Font
			end

			local NormGrad = TabButton:FindFirstChild("UIGradient")
			if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = false end

			if TabButton:FindFirstChild("ActiveGradient") then TabButton.ActiveGradient.Enabled = true end
			if TabButton:FindFirstChild("TextLabel") then TabButton.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0) end
			TabButton.Font = Library.Theme.FontBold
			TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

			if ActiveTab ~= TabContent then
				if ActiveTab then
					local OldTab = ActiveTab
					local Direction = (ThisTabIndex > ActiveTabIndex) and -1 or 1
					TweenService:Create(OldTab, TweenInfo.new(GetTime(0.5), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, Direction, 0)}):Play()
					task.delay(GetTime(0.5), function()
						if ActiveTab ~= OldTab then OldTab.Visible = false end
					end)
					ActiveTab = TabContent
					ActiveTabIndex = ThisTabIndex
					TabContent.Visible = true
					TabContent.Position = UDim2.new(0, 0, -Direction, 0)
					TweenService:Create(TabContent, TweenInfo.new(GetTime(0.5), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
				else
					ActiveTab = TabContent
					ActiveTabIndex = ThisTabIndex
					TabContent.Visible = true
				end
			end
		end)

		local ActiveTabGrad = Create("UIGradient", {Name = "ActiveGradient", Parent = TabButton, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1, GetDarkerColor(Library.Theme.Accent))}), Rotation = 90, Enabled = false})
		table.insert(Library.Registry, {Object = ActiveTabGrad, ThemeKey = "Accent", Type = "ActiveGradient"})

		table.insert(Tabs, {Button = TabButton, Content = TabContent})
		if FirstTab then
			local NormGrad = TabButton:FindFirstChild("UIGradient")
			if NormGrad and NormGrad.Name ~= "ActiveGradient" then NormGrad.Enabled = false end

			if TabButton:FindFirstChild("ActiveGradient") then TabButton.ActiveGradient.Enabled = true end
			if TabButton:FindFirstChild("TextLabel") then TabButton.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0) end
			TabButton.Font = Library.Theme.FontBold
			TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TabContent.Visible = true
			ActiveTab = TabContent
			FirstTab = false
		end
		return TabFunctions
	end
	return WindowFunctions
end
return Library