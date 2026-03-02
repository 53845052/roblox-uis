local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Body = Color3.fromRGB(20, 20, 26),
    Sidebar = Color3.fromRGB(26, 26, 34),
    Main = Color3.fromRGB(30, 30, 40),
    Search = Color3.fromRGB(35, 35, 45),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(130, 130, 145),
    Accent = Color3.fromRGB(225, 225, 245),
    Border = Color3.fromRGB(45, 45, 58),
    Font = Enum.Font.GothamMedium
}
local Font = Enum.Font.GothamMedium

local Icons = {
    Placeholder = "rbxassetid://11419709766",
    Save = "rbxassetid://11419703493",
    Search = "rbxassetid://11293977875",
    Keyboard = "rbxassetid://12974370712",
    ChevronDown = "rbxassetid://11421095840",
    Pipette = "rbxassetid://11419718822",
    PickerCursor = "rbxassetid://11293981586",
    Checkmark = "rbxassetid://10709790644"
}

local TweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenSmooth = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function Create(Class, Properties)
    local Inst = Instance.new(Class)
    for Key, Value in Properties do
        Inst[Key] = Value
    end
    return Inst
end

local function FormatKeyName(KeyEnum)
    if not KeyEnum then return "" end
    local KeyName = KeyEnum.Name
    if KeyName == "MouseButton1" then return "MB1" end
    if KeyName == "MouseButton2" then return "MB2" end
    if KeyName == "MouseButton3" then return "MB3" end
    return KeyName
end

local ThemeConnections = {}
local function ThemeUpdate(func)
    table.insert(ThemeConnections, func)
end

local Library = {
    ToggleKey = nil,
    Flags = {}
}

function Library:SetWindowKeybind(KeyEnum)
    self.ToggleKey = KeyEnum
end

function Library:GetTheme()
    return Theme
end

function Library:SetTheme(NewTheme)
    for Key, Value in NewTheme do
        if Theme[Key] then
            Theme[Key] = Value
        end
    end
    for _, Func in ThemeConnections do
        task.spawn(Func)
    end
end

function Library:Window(Options)
    local SubTitle = Options.SubTitle or "v1.0.0"
    local ScreenGui = Create("ScreenGui", {ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    local Success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not Success then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Create("CanvasGroup", {Size = UDim2.new(0, 850, 0, 550), Position = UDim2.new(0.5, -425, 0.5, -275), BackgroundColor3 = Theme.Body, BorderSizePixel = 0, GroupTransparency = 0, Parent = ScreenGui})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
    Create("UIDragDetector", {Parent = MainFrame})

    local BottomBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 1, -64), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = MainFrame})
    
    local ProfileFrame = Create("Frame", {Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Parent = BottomBar})
    local AvatarImage = Create("ImageLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 0, 0.5, -20), BackgroundColor3 = Theme.Search, Parent = ProfileFrame})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = AvatarImage})
    
    task.spawn(function()
        local success, thumb = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        if success then AvatarImage.Image = thumb end
    end)
    
    local ProfileName = Create("TextLabel", {Size = UDim2.new(1, -52, 0, 20), Position = UDim2.new(0, 52, 0.5, -18), BackgroundTransparency = 1, Text = LocalPlayer.DisplayName or "User", TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = ProfileFrame})
    local ProfileSub = Create("TextLabel", {Size = UDim2.new(1, -52, 0, 16), Position = UDim2.new(0, 52, 0.5, 2), BackgroundTransparency = 1, Text = SubTitle, TextColor3 = Theme.TextSecondary, Font = Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = ProfileFrame})

    local TabContainerNav = Create("Frame", {Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0.5, -150, 0, 0), BackgroundTransparency = 1, Parent = BottomBar})
    Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), Parent = TabContainerNav})

    local ActionContainer = Create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -270, 0, 0), BackgroundTransparency = 1, Parent = BottomBar})
    Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), Parent = ActionContainer})
    
    local SaveBtn = Create("TextButton", {Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = Theme.Search, Text = "", AutoButtonColor = false, LayoutOrder = 2, Parent = ActionContainer})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SaveBtn})
    local SaveIcon = Create("ImageLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = Icons.Save, ImageColor3 = Theme.TextSecondary, Parent = SaveBtn})

    local SearchBar = Create("Frame", {Size = UDim2.new(0, 160, 0, 40), BackgroundColor3 = Theme.Search, LayoutOrder = 1, Parent = ActionContainer})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchBar})
    local SearchIcon = Create("ImageLabel", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 12, 0.5, -8), BackgroundTransparency = 1, Image = Icons.Search, ImageColor3 = Theme.TextSecondary, Parent = SearchBar})
    local SearchBox = Create("TextBox", {Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Search...", TextColor3 = Theme.TextPrimary, PlaceholderColor3 = Theme.TextSecondary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = SearchBar})

    local ContentArea = Create("Frame", {Size = UDim2.new(1, 0, 1, -64), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Parent = MainFrame})
    local TabContainer = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = ContentArea})
    
    local SearchContent = Create("ScrollingFrame", {Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = TabContainer})
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = SearchContent})

    local NoResultsLabel = Create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "No results found", TextColor3 = Theme.TextSecondary, Font = Theme.Font, TextSize = 16, Visible = false, Parent = TabContainer})

    local WindowObj = {
        ScreenGui = ScreenGui,
        Tabs = {},
        AllRows = {},
        CurrentTab = nil,
        Watermarks = {},
        Popups = {},
        Visible = true
    }

    ThemeUpdate(function()
        MainFrame.BackgroundColor3 = Theme.Body
        BottomBar.BackgroundColor3 = Theme.Sidebar
        ProfileName.TextColor3 = Theme.TextPrimary
        ProfileSub.TextColor3 = Theme.TextSecondary
        SearchBar.BackgroundColor3 = Theme.Search
        SearchIcon.ImageColor3 = Theme.TextSecondary
        SearchBox.TextColor3 = Theme.TextPrimary
        SearchBox.PlaceholderColor3 = Theme.TextSecondary
        SearchContent.ScrollBarImageColor3 = Theme.Accent
        NoResultsLabel.TextColor3 = Theme.TextSecondary
        
        if WindowObj.CurrentTab and WindowObj.CurrentTab.IsConfig then
            SaveBtn.BackgroundColor3 = Theme.Accent
            SaveIcon.ImageColor3 = Color3.fromRGB(17, 17, 17)
        else
            SaveBtn.BackgroundColor3 = Theme.Search
            SaveIcon.ImageColor3 = Theme.TextSecondary
        end
    end)

    function WindowObj:ToggleVisibility()
        self.Visible = not self.Visible
        if self.Visible then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenSmooth, {GroupTransparency = 0}):Play()
        else
            for _, popup in self.Popups do
                if type(popup.Close) == "function" then popup.Close() end
            end
            local tw = TweenService:Create(MainFrame, TweenSmooth, {GroupTransparency = 1})
            tw:Play()
            tw.Completed:Once(function()
                if not self.Visible then MainFrame.Visible = false end
            end)
        end
        for _, wm in self.Watermarks do wm:UpdatePosition() end
    end

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Library.ToggleKey and Input.KeyCode == Library.ToggleKey then WindowObj:ToggleVisibility() end
    end)

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() for _, wm in WindowObj.Watermarks do wm:UpdatePosition() end end)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() for _, wm in WindowObj.Watermarks do wm:UpdatePosition() end end)

    function WindowObj:Watermark(InitialText)
        local wmFrame = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Sidebar,
            Size = UDim2.fromOffset(0, 26),
            ClipsDescendants = true,
            ZIndex = 5000
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = wmFrame})
        local wmStroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = wmFrame})
        
        local topAccent = Create("Frame", {
            Parent = wmFrame,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 5001
        })
        
        Create("UIGradient", {
            Parent = topAccent,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.15, 0),
                NumberSequenceKeypoint.new(0.85, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        })

        local wmText = Create("TextLabel", {
            Parent = wmFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), 
            Text = InitialText or "",
            RichText = true,
            TextColor3 = Theme.TextPrimary,
            Font = Enum.Font.Code,
            TextSize = 13,
            ZIndex = 5001
        })
        Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = wmText})

        ThemeUpdate(function()
            wmFrame.BackgroundColor3 = Theme.Sidebar
            wmStroke.Color = Theme.Border
            topAccent.BackgroundColor3 = Theme.Accent
            wmText.TextColor3 = Theme.TextPrimary
        end)

        local wmObj = {Frame = wmFrame, PosString = "TopLeft", CurrentText = InitialText or ""}
        
        function wmObj:UpdateSize()
            local cleanText = string.gsub(self.CurrentText, "<[^>]->", "")
            local textWidth = TextService:GetTextSize(cleanText, 13, Enum.Font.Code, Vector2.new(10000, 26)).X
            wmFrame.Size = UDim2.fromOffset(textWidth + 24, 26)
        end
        function wmObj:SetText(newText)
            self.CurrentText = newText; wmText.Text = newText
            self:UpdateSize(); self:UpdatePosition()
        end
        function wmObj:SetVisible(state) wmFrame.Visible = state end
        
        function wmObj:UpdatePosition()
            local pos = self.PosString
            if WindowObj.Visible then
                local mfPos = MainFrame.AbsolutePosition
                local mfSize = MainFrame.AbsoluteSize
                local wmSize = wmFrame.AbsoluteSize
                local padding = 8
                
                if pos == "TopLeft" then wmFrame.Position = UDim2.fromOffset(mfPos.X, mfPos.Y - wmSize.Y - padding); wmFrame.AnchorPoint = Vector2.new(0, 0)
                elseif pos == "TopRight" then wmFrame.Position = UDim2.fromOffset(mfPos.X + mfSize.X, mfPos.Y - wmSize.Y - padding); wmFrame.AnchorPoint = Vector2.new(1, 0)
                elseif pos == "BottomLeft" then wmFrame.Position = UDim2.fromOffset(mfPos.X, mfPos.Y + mfSize.Y + padding); wmFrame.AnchorPoint = Vector2.new(0, 0)
                elseif pos == "BottomRight" then wmFrame.Position = UDim2.fromOffset(mfPos.X + mfSize.X, mfPos.Y + mfSize.Y + padding); wmFrame.AnchorPoint = Vector2.new(1, 0) end
            else
                if pos == "TopLeft" then wmFrame.Position = UDim2.new(0, 15, 0, 15); wmFrame.AnchorPoint = Vector2.new(0, 0)
                elseif pos == "TopRight" then wmFrame.Position = UDim2.new(1, -15, 0, 15); wmFrame.AnchorPoint = Vector2.new(1, 0)
                elseif pos == "BottomLeft" then wmFrame.Position = UDim2.new(0, 15, 1, -15); wmFrame.AnchorPoint = Vector2.new(0, 1)
                elseif pos == "BottomRight" then wmFrame.Position = UDim2.new(1, -15, 1, -15); wmFrame.AnchorPoint = Vector2.new(1, 1) end
            end
        end

        function wmObj:SetPosition(posString) self.PosString = posString; self:UpdatePosition() end
        wmFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() wmObj:UpdatePosition() end)
        wmObj:UpdateSize()
        wmObj:SetPosition("TopLeft")
        task.defer(function() wmObj:UpdatePosition() end)
        table.insert(WindowObj.Watermarks, wmObj)
        return wmObj
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = string.lower(SearchBox.Text)
        for _, Comp in WindowObj.AllRows do Comp.Row.Parent = Comp.OriginalParent end

        if Query == "" then
            SearchContent.Visible = false
            NoResultsLabel.Visible = false
            if WindowObj.CurrentTab then WindowObj.CurrentTab.Canvas.Visible = true end
        else
            if WindowObj.CurrentTab then WindowObj.CurrentTab.Canvas.Visible = false end
            SearchContent.Visible = true
            
            local FoundMatches = 0
            for _, Comp in WindowObj.AllRows do
                if string.find(string.lower(Comp.Title), Query) then
                    Comp.Row.Parent = SearchContent
                    FoundMatches = FoundMatches + 1
                end
            end
            NoResultsLabel.Visible = (FoundMatches == 0)
        end
    end)

    function WindowObj:Tab(Options)
        local TabTitle = Options.Title or "Tab"
        local TabIcon = Options.Icon or Icons.Placeholder
        local IsConfig = Options.IsConfig or false

        local TabBtn = Create("TextButton", {Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 1, BackgroundColor3 = Theme.Search, Text = "", AutoButtonColor = false})
        if not IsConfig then TabBtn.Parent = TabContainerNav end
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        local TabIconImage = Create("ImageLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = TabIcon, ImageColor3 = Theme.TextSecondary, Parent = TabBtn})

        local TabCanvas = Create("CanvasGroup", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false, Parent = TabContainer})
        local TabContent = Create("ScrollingFrame", {Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = TabCanvas})
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = TabContent})

        ThemeUpdate(function()
            if WindowObj.CurrentTab and WindowObj.CurrentTab.TabButton == TabBtn then
                TabBtn.BackgroundColor3 = Theme.Search
                TabIconImage.ImageColor3 = Theme.Accent
            else
                TabBtn.BackgroundColor3 = Theme.Sidebar
                TabIconImage.ImageColor3 = Theme.TextSecondary
            end
            TabContent.ScrollBarImageColor3 = Theme.Accent
        end)

        local TabObj = {Canvas = TabCanvas, Container = TabContent, TabButton = TabBtn, Title = TabTitle, Icon = TabIcon, IsConfig = IsConfig, LayoutOrder = 0}
        table.insert(WindowObj.Tabs, TabObj)

        local function ActivateTab()
            if WindowObj.CurrentTab == TabObj then return end

            for _, Tab in WindowObj.Tabs do
                if Tab == TabObj then continue end
                if Tab == WindowObj.CurrentTab then
                    local Outgoing = Tab
                    local tw = TweenService:Create(Outgoing.Canvas, TweenSmooth, {GroupTransparency = 1})
                    tw:Play()
                    task.delay(0.25, function() if WindowObj.CurrentTab ~= Outgoing then Outgoing.Canvas.Visible = false end end)
                else
                    Tab.Canvas.Visible = false; Tab.Canvas.GroupTransparency = 1
                end

                if Tab.IsConfig then
                    TweenService:Create(SaveBtn, TweenFast, {BackgroundColor3 = Theme.Search}):Play()
                    TweenService:Create(SaveIcon, TweenFast, {ImageColor3 = Theme.TextSecondary}):Play()
                else
                    TweenService:Create(Tab.TabButton, TweenFast, {BackgroundTransparency = 1}):Play()
                    TweenService:Create(Tab.TabButton:FindFirstChildOfClass("ImageLabel"), TweenFast, {ImageColor3 = Theme.TextSecondary}):Play()
                end
            end
            
            TabObj.Canvas.Visible = true
            TabObj.Canvas.GroupTransparency = WindowObj.CurrentTab and 1 or 0
            TweenService:Create(TabObj.Canvas, TweenSmooth, {GroupTransparency = 0}):Play()

            if TabObj.IsConfig then
                TweenService:Create(SaveBtn, TweenFast, {BackgroundColor3 = Theme.Accent}):Play()
                TweenService:Create(SaveIcon, TweenFast, {ImageColor3 = Color3.fromRGB(17, 17, 17)}):Play()
            else
                TweenService:Create(TabObj.TabButton, TweenFast, {BackgroundTransparency = 0}):Play()
                TweenService:Create(TabObj.TabButton:FindFirstChildOfClass("ImageLabel"), TweenFast, {ImageColor3 = Theme.Accent}):Play()
            end

            WindowObj.CurrentTab = TabObj
        end

        function TabObj:Activate() ActivateTab() end

        if not IsConfig then
            TabBtn.MouseButton1Click:Connect(ActivateTab)
            local ActiveTabsCount = 0
            for _, t in WindowObj.Tabs do if not t.IsConfig then ActiveTabsCount += 1 end end
            if ActiveTabsCount == 1 then ActivateTab() end
        end

        local function CreateRow(ComponentTitle, Height)
            TabObj.LayoutOrder = TabObj.LayoutOrder + 1
            local Row = Create("Frame", {Size = UDim2.new(1, 0, 0, Height or 40), BackgroundTransparency = 1, LayoutOrder = TabObj.LayoutOrder, Parent = TabContent})
            local RowSep = Create("Frame", {Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 1, -1), BackgroundColor3 = Theme.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = Row})
            
            ThemeUpdate(function() RowSep.BackgroundColor3 = Theme.Border end)
            table.insert(WindowObj.AllRows, {Row = Row, OriginalParent = TabContent, Title = ComponentTitle or ""})
            return Row
        end

        local function AttachColorPicker(TargetRow, CompTitle, ColorProps, RightOffset)
            ColorProps = ColorProps or {}
            RightOffset = RightOffset or 8
            local DefaultColor = ColorProps.Default or Color3.fromRGB(255, 255, 255)
            local CurrentColor = DefaultColor
            local CurrentAlpha = (ColorProps.Transparency or 100) / 100
            local HSV = {Color3.toHSV(CurrentColor)}
            local CPCallback = ColorProps.Callback or function() end
            
            local FlagName = ColorProps.Flag or string.format("%s/Colorpicker/%s", TabObj.Title, CompTitle)

            local CPContainer = Create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -RightOffset, 0, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, ZIndex = 10, Parent = TargetRow})
            Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), Parent = CPContainer})

            local PipetteBtn = Create("TextButton", {Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 1, ZIndex = 10, Parent = CPContainer})
            local PipetteIcon = Create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = Icons.Pipette, ImageColor3 = Theme.TextSecondary, ZIndex = 10, Parent = PipetteBtn})

            local ColorBtn = Create("TextButton", {Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = CurrentColor, Text = "", AutoButtonColor = false, LayoutOrder = 2, ZIndex = 10, Parent = CPContainer})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorBtn})
            
            local HexBox = Create("TextBox", {Size = UDim2.new(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, ClearTextOnFocus = false, LayoutOrder = 3, ZIndex = 10, Parent = CPContainer})

            local TransparencyLabel = Create("TextLabel", {Size = UDim2.new(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextSecondary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 4, ZIndex = 10, Parent = CPContainer})

            local PickerFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Theme.Main, BorderSizePixel = 0, Size = UDim2.new(0, 220, 0, 0), Visible = false, ClipsDescendants = true, ZIndex = 3000})
            Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0, 6)})
            local PickerStroke = Create("UIStroke", {Parent = PickerFrame, Color = Theme.Border, Thickness = 1})
            Create("UIPadding", {Parent = PickerFrame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
            Create("UIDragDetector", {Parent = PickerFrame})

            local ColorMap = Create("TextButton", {Parent = PickerFrame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1), AutoButtonColor = false, Text = "", ZIndex = 3001})
            local SatOverlay = Create("Frame", {Parent = ColorMap, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3002, BorderSizePixel = 0})
            Create("UIGradient", {Parent = SatOverlay, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}})
            local ValOverlay = Create("Frame", {Parent = ColorMap, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 3003, BorderSizePixel = 0})
            Create("UIGradient", {Parent = ValOverlay, Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}})
            
            local MapMarker = Create("Frame", {Parent = ColorMap, Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0), ZIndex = 3004})
            Create("UICorner", {Parent = MapMarker, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = MapMarker, Color = Color3.new(1, 1, 1), Thickness = 2})
            Create("UICorner", {Parent = ColorMap, CornerRadius = UDim.new(0, 4)})

            local function CreatePickerSlider(SliderTitle)
                local SliderFrame = Create("Frame", {Parent = PickerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), ZIndex = 3001})
                local Top = Create("Frame", {Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), ZIndex = 3001})
                local TitleLab = Create("TextLabel", {Parent = Top, Text = SliderTitle, Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3001})
                local ValLabel = Create("TextLabel", {Parent = Top, Text = "0", Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.TextPrimary, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3001})

                local Track = Create("TextButton", {Parent = SliderFrame, BackgroundColor3 = Theme.Search, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 4), Text = "", AutoButtonColor = false, ZIndex = 3001})
                Create("UICorner", {Parent = Track, CornerRadius = UDim.new(0, 2)})

                local Fill = Create("Frame", {Parent = Track, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 3002})
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 2)})

                return {Frame = SliderFrame, Track = Track, Fill = Fill, Label = ValLabel, Title = TitleLab}
            end

            Create("UIListLayout", {Parent = PickerFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            ColorMap.LayoutOrder = 1

            local HueSlider = CreatePickerSlider("Hue")
            HueSlider.Frame.LayoutOrder = 2

            local AlphaSlider = CreatePickerSlider("Transparency")
            AlphaSlider.Frame.LayoutOrder = 3

            ThemeUpdate(function()
                PipetteIcon.ImageColor3 = Theme.TextSecondary
                HexBox.TextColor3 = Theme.TextPrimary
                TransparencyLabel.TextColor3 = Theme.TextSecondary
                PickerFrame.BackgroundColor3 = Theme.Main
                PickerStroke.Color = Theme.Border

                HueSlider.Track.BackgroundColor3 = Theme.Search
                HueSlider.Fill.BackgroundColor3 = Theme.Accent
                HueSlider.Label.TextColor3 = Theme.TextPrimary
                HueSlider.Title.TextColor3 = Theme.TextSecondary

                AlphaSlider.Track.BackgroundColor3 = Theme.Search
                AlphaSlider.Fill.BackgroundColor3 = Theme.Accent
                AlphaSlider.Label.TextColor3 = Theme.TextPrimary
                AlphaSlider.Title.TextColor3 = Theme.TextSecondary
            end)

            local function UpdateVisuals(TriggerCallback)
                ColorBtn.BackgroundColor3 = CurrentColor
                HexBox.Text = CurrentColor:ToHex():upper()
                TransparencyLabel.Text = tostring(math.floor(CurrentAlpha * 100)) .. "%"
                ColorMap.BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1)

                TweenService:Create(MapMarker, TweenInfo.new(0.05), {Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)}):Play()

                local HuePct = HSV[1]
                TweenService:Create(HueSlider.Fill, TweenInfo.new(0.05), {Size = UDim2.new(HuePct, 0, 1, 0)}):Play()
                HueSlider.Label.Text = tostring(math.floor(HSV[1] * 360))

                local AlphaPct = CurrentAlpha
                TweenService:Create(AlphaSlider.Fill, TweenInfo.new(0.05), {Size = UDim2.new(AlphaPct, 0, 1, 0)}):Play()
                AlphaSlider.Label.Text = tostring(math.floor(CurrentAlpha * 100)) .. "%"
                
                if TriggerCallback then CPCallback(CurrentColor, CurrentAlpha) end
            end

            HexBox.FocusLost:Connect(function()
                local success, ParsedColor = pcall(function() return Color3.fromHex(HexBox.Text) end)
                if success then
                    CurrentColor = ParsedColor
                    HSV = {Color3.toHSV(CurrentColor)}
                    UpdateVisuals(true)
                else
                    HexBox.Text = CurrentColor:ToHex():upper()
                end
            end)

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
                    UpdateVisuals(true)
                end

                Update(Input.Position)
                local MoveConn = UserInputService.InputChanged:Connect(function(Mv)
                    if Mv.UserInputType == Enum.UserInputType.MouseMovement or Mv.UserInputType == Enum.UserInputType.Touch then Update(Mv.Position) end
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

            local function ClosePicker()
                local tw = TweenService:Create(PickerFrame, TweenSmooth, {Size = UDim2.new(0, 220, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function()
                    if PickerFrame.Size.Y.Offset == 0 then PickerFrame.Visible = false end
                end)
            end
            table.insert(WindowObj.Popups, {Close = ClosePicker})

            ColorBtn.MouseButton1Click:Connect(function()
                if PickerFrame.Visible then
                    ClosePicker()
                else
                    local BtnPos = ColorBtn.AbsolutePosition
                    local ScreenSize = ScreenGui.AbsoluteSize
                    local X = BtnPos.X - 230
                    local Y = BtnPos.Y + 25

                    if X < 0 then X = BtnPos.X + 35 end
                    if Y + 225 > ScreenSize.Y then Y = ScreenSize.Y - 230 end

                    PickerFrame.Position = UDim2.new(0, X, 0, Y)
                    PickerFrame.Visible = true
                    TweenService:Create(PickerFrame, TweenSmooth, {Size = UDim2.new(0, 220, 0, 225)}):Play()
                end
            end)

            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if PickerFrame.Visible then
                        local MousePos = Vector2.new(Input.Position.X, Input.Position.Y)
                        local PPos, PSize = PickerFrame.AbsolutePosition, PickerFrame.AbsoluteSize
                        local BtnPos, BtnSize = ColorBtn.AbsolutePosition, ColorBtn.AbsoluteSize

                        local InPicker = (MousePos.X >= PPos.X and MousePos.X <= PPos.X + PSize.X) and (MousePos.Y >= PPos.Y and MousePos.Y <= PPos.Y + PSize.Y)
                        local InBtn = (MousePos.X >= BtnPos.X and MousePos.X <= BtnPos.X + BtnSize.X) and (MousePos.Y >= BtnPos.Y and MousePos.Y <= BtnPos.Y + BtnSize.Y)

                        if not InPicker and not InBtn then ClosePicker() end
                    end
                end
            end)

            UpdateVisuals(false)
            
            local CPObj = {}
            function CPObj:GetComponentType() return "Colorpicker" end
            function CPObj:GetValue() return CurrentColor end
            function CPObj:GetTransparency() return CurrentAlpha * 100 end
            function CPObj:SetValue(color) CurrentColor = color; HSV = {Color3.toHSV(CurrentColor)}; UpdateVisuals(true) end
            function CPObj:SetTransparency(trans) CurrentAlpha = math.clamp(trans, 0, 100) / 100; UpdateVisuals(true) end
            Library.Flags[FlagName] = CPObj
            return CPObj
        end

        function TabObj:Colorpicker(CPOpts)
            local Title = CPOpts.Title or "Colorpicker"
            local Row = CreateRow(Title, 40)
            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -250, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})
            ThemeUpdate(function() TitleLabel.TextColor3 = Theme.TextPrimary end)
            
            local CPObj = AttachColorPicker(Row, Title, CPOpts, 8)
            CPObj.Row = Row
            return CPObj
        end

        function TabObj:Button(BOpts)
            local Title = BOpts.Title or "Button"
            local Action = BOpts.Action or "Click"
            local Callback = BOpts.Callback or function() end
            
            local FlagName = BOpts.Flag or string.format("%s/Button/%s", TabObj.Title, Title)
            local Row = CreateRow(Title, 40)

            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})

            local Btn = Create("TextButton", {
                Size = UDim2.new(0, 0, 0, 26),
                Position = UDim2.new(1, -8, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Theme.Search,
                Text = Action,
                TextColor3 = Theme.TextPrimary,
                Font = Theme.Font,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = Row
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Btn})
            Create("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = Btn})
            
            ThemeUpdate(function()
                TitleLabel.TextColor3 = Theme.TextPrimary
                Btn.BackgroundColor3 = Theme.Search
                Btn.TextColor3 = Theme.TextPrimary
            end)

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Border}):Play()
                task.delay(0.15, function() TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Search}):Play() end)
                Callback()
            end)

            local ButtonObj = {Row = Row}
            function ButtonObj:GetComponentType() return "Button" end
            function ButtonObj:Fire() Callback() end
            Library.Flags[FlagName] = ButtonObj
            return ButtonObj
        end

        function TabObj:Textbox(TOpts)
            local Title = TOpts.Title or "Textbox"
            local Default = TOpts.Default or ""
            local Placeholder = TOpts.Placeholder or "Type here"
            local Callback = TOpts.Callback or function() end
            
            local FlagName = TOpts.Flag or string.format("%s/Textbox/%s", TabObj.Title, Title)
            local Row = CreateRow(Title, 40)

            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})

            local InputBox = Create("TextBox", {
                Size = UDim2.new(0, 100, 0, 26),
                Position = UDim2.new(1, -8, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.Search,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = Theme.TextPrimary,
                PlaceholderColor3 = Theme.TextSecondary,
                Font = Enum.Font.Code,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.X,
                ClearTextOnFocus = false,
                ClipsDescendants = true,
                Parent = Row
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = InputBox})
            local Stroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = InputBox})
            Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = InputBox})
            Create("UISizeConstraint", {MinSize = Vector2.new(100, 26), MaxSize = Vector2.new(300, 26), Parent = InputBox})

            ThemeUpdate(function()
                TitleLabel.TextColor3 = Theme.TextPrimary
                InputBox.BackgroundColor3 = Theme.Search
                InputBox.TextColor3 = Theme.TextPrimary
                InputBox.PlaceholderColor3 = Theme.TextSecondary
                Stroke.Color = Theme.Border
            end)

            local CurrentValue = Default
            local function SetValue(val, triggerCallback)
                CurrentValue = tostring(val)
                InputBox.Text = CurrentValue
                if triggerCallback then Callback(CurrentValue) end
            end

            InputBox.FocusLost:Connect(function() SetValue(InputBox.Text, true) end)
            InputBox.Focused:Connect(function() TweenService:Create(Stroke, TweenFast, {Color = Theme.Accent}):Play() end)
            InputBox.FocusLost:Connect(function() TweenService:Create(Stroke, TweenFast, {Color = Theme.Border}):Play() end)

            local TextboxObj = {}
            function TextboxObj:GetComponentType() return "Textbox" end
            function TextboxObj:GetValue() return CurrentValue end
            function TextboxObj:SetValue(val) SetValue(val, true) end
            Library.Flags[FlagName] = TextboxObj
            return TextboxObj
        end

        function TabObj:Keybind(KOpts)
            local Title = KOpts.Title or "Keybind"
            local Default = KOpts.Default
            local Callback = KOpts.Callback or function() end
            
            local FlagName = KOpts.Flag or string.format("%s/Keybind/%s", TabObj.Title, Title)
            local CurrentKey = Default

            local Row = CreateRow(Title, 40)
            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})

            local KeyContainer = Create("TextButton", {Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = Row})
            Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), Parent = KeyContainer})

            local KeyText = Create("TextLabel", {Size = UDim2.new(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = FormatKeyName(Default), TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 2, Parent = KeyContainer})
            local KeyIconContainer = Create("Frame", {Size = UDim2.new(0, 24, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1, Parent = KeyContainer})
            local KeyboardIcon = Create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = Icons.Keyboard, ImageColor3 = Theme.TextPrimary, Parent = KeyIconContainer})

            local BindConnection
            
            ThemeUpdate(function()
                TitleLabel.TextColor3 = Theme.TextPrimary
                if BindConnection then
                    KeyText.TextColor3 = Theme.Accent
                    KeyboardIcon.ImageColor3 = Theme.Accent
                else
                    KeyText.TextColor3 = Theme.TextPrimary
                    KeyboardIcon.ImageColor3 = Theme.TextPrimary
                end
            end)
            
            local function SetValue(keyEnum, triggerCallback)
                CurrentKey = keyEnum
                KeyText.Text = FormatKeyName(keyEnum)
                TweenService:Create(KeyText, TweenFast, {TextColor3 = Theme.TextPrimary}):Play()
                TweenService:Create(KeyboardIcon, TweenFast, {ImageColor3 = Theme.TextPrimary}):Play()
                if triggerCallback then Callback(CurrentKey) end
            end

            KeyContainer.MouseButton1Click:Connect(function()
                KeyText.Text = "..."
                TweenService:Create(KeyText, TweenFast, {TextColor3 = Theme.Accent}):Play()
                TweenService:Create(KeyboardIcon, TweenFast, {ImageColor3 = Theme.Accent}):Play()

                if BindConnection then BindConnection:Disconnect() end
                
                BindConnection = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard or string.find(Input.UserInputType.Name, "MouseButton") then
                        local ValidKey = (Input.KeyCode.Name ~= "Unknown") and Input.KeyCode or Input.UserInputType
                        BindConnection:Disconnect(); BindConnection = nil
                        SetValue(ValidKey, true)
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(Input, Processed)
                if Processed then return end
                if CurrentKey and CurrentKey.Name ~= "Unknown" then
                    if Input.KeyCode == CurrentKey or Input.UserInputType == CurrentKey then Callback(CurrentKey) end
                end
            end)
            
            local KeybindObj = {}
            function KeybindObj:GetComponentType() return "Keybind" end
            function KeybindObj:GetValue() return CurrentKey end
            function KeybindObj:SetValue(val) SetValue(val, true) end
            Library.Flags[FlagName] = KeybindObj
            return KeybindObj
        end

        function TabObj:Slider(SOpts)
            local Title = SOpts.Title or "Slider"
            local Min = SOpts.Min or 0
            local Max = SOpts.Max or 100
            local Decimal = SOpts.Decimal or 0
            local Prefix = SOpts.Prefix or ""
            local Suffix = SOpts.Suffix or ""
            local Dual = SOpts.Dual or false
            local ZeroNumber = SOpts.ZeroNumber or Min
            local Callback = SOpts.Callback or function() end
            
            local FlagName = SOpts.Flag or string.format("%s/Slider/%s", TabObj.Title, Title)

            local CurrentValue
            if Dual then
                CurrentValue = type(SOpts.Default) == "table" and {math.clamp(SOpts.Default[1] or Min, Min, Max), math.clamp(SOpts.Default[2] or Max, Min, Max)} or {Min, Max}
            else
                CurrentValue = math.clamp(SOpts.Default or Min, Min, Max)
            end

            local Row = CreateRow(Title, 52)

            local TitleLabel = Create("TextLabel", {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})
            local ValueLabel = Create("TextLabel", {Size = UDim2.new(0, 150, 0, 20), Position = UDim2.new(1, -158, 0, 8), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = Row})

            local TrackBtn = Create("TextButton", {Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 8, 0, 28), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = Row})
            local Track = Create("Frame", {Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, -2), BackgroundColor3 = Theme.Search, Parent = TrackBtn})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

            local Fill = Create("Frame", {Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Theme.Accent, Parent = Track})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

            local Handle1 = Create("Frame", {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.TextPrimary, Parent = Fill})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Handle1})
            
            local Handle2
            if Dual then
                Handle1.Position = UDim2.new(0, 0, 0.5, 0)
                Handle2 = Create("Frame", {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.TextPrimary, Parent = Fill})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Handle2})
            end

            ThemeUpdate(function()
                TitleLabel.TextColor3 = Theme.TextPrimary
                ValueLabel.TextColor3 = Theme.TextPrimary
                Track.BackgroundColor3 = Theme.Search
                Fill.BackgroundColor3 = Theme.Accent
                Handle1.BackgroundColor3 = Theme.TextPrimary
                if Handle2 then Handle2.BackgroundColor3 = Theme.TextPrimary end
            end)

            local function FormatValue(val)
                local str = string.format("%." .. tostring(Decimal) .. "f", val)
                return string.format("%s%s%s", Prefix, str, Suffix)
            end

            local ZeroAlpha = math.clamp((ZeroNumber - Min) / (Max - Min), 0, 1)
            local Val1, Val2
            
            if Dual then
                Val1 = Create("NumberValue", {Value = CurrentValue[1], Parent = Row})
                Val2 = Create("NumberValue", {Value = CurrentValue[2], Parent = Row})
                local function updateText() ValueLabel.Text = string.format("( %s, %s )", FormatValue(Val1.Value), FormatValue(Val2.Value)) end
                Val1.Changed:Connect(updateText); Val2.Changed:Connect(updateText); updateText() 
            else
                Val1 = Create("NumberValue", {Value = CurrentValue, Parent = Row})
                Val1.Changed:Connect(function() ValueLabel.Text = string.format("( %s )", FormatValue(Val1.Value)) end)
                ValueLabel.Text = string.format("( %s )", FormatValue(Val1.Value))
            end

            local function UpdateVisuals(val)
                if Dual then
                    local a1 = (val[1] - Min) / (Max - Min)
                    local a2 = (val[2] - Min) / (Max - Min)
                    TweenService:Create(Fill, TweenSmooth, {Position = UDim2.new(a1, 0, 0, 0), Size = UDim2.new(a2 - a1, 0, 1, 0)}):Play()
                    TweenService:Create(Val1, TweenSmooth, {Value = val[1]}):Play()
                    TweenService:Create(Val2, TweenSmooth, {Value = val[2]}):Play()
                else
                    local a = (val - Min) / (Max - Min)
                    local startA = math.min(a, ZeroAlpha)
                    local sizeA = math.abs(a - ZeroAlpha)
                    TweenService:Create(Fill, TweenSmooth, {Position = UDim2.new(startA, 0, 0, 0), Size = UDim2.new(sizeA, 0, 1, 0)}):Play()
                    
                    if a < ZeroAlpha then
                        Handle1.Position = UDim2.new(0, 0, 0.5, 0)
                    else
                        Handle1.Position = UDim2.new(1, 0, 0.5, 0)
                    end
                    TweenService:Create(Val1, TweenSmooth, {Value = val}):Play()
                end
            end

            local function SetValue(Value, triggerCallback)
                if Dual then
                    CurrentValue = type(Value) == "table" and {math.clamp(Value[1], Min, Max), math.clamp(Value[2], Min, Max)} or {Min, Max}
                else
                    CurrentValue = math.clamp(Value, Min, Max)
                end
                UpdateVisuals(CurrentValue)
                if triggerCallback then Callback(CurrentValue) end
            end

            local IsDragging, ActiveHandle = false, 1

            local function HandleDrag(Input)
                local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local RawValue = Min + ((Max - Min) * Alpha)
                local Mult = 10 ^ Decimal
                local Value = math.round(RawValue * Mult) / Mult
                Value = math.clamp(Value, Min, Max)

                if Dual then
                    local newValue = {CurrentValue[1], CurrentValue[2]}
                    newValue[ActiveHandle] = Value
                    if ActiveHandle == 1 and newValue[1] > newValue[2] then newValue[1] = newValue[2]
                    elseif ActiveHandle == 2 and newValue[2] < newValue[1] then newValue[2] = newValue[1] end
                    SetValue(newValue, true)
                else
                    SetValue(Value, true)
                end
            end

            TrackBtn.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    IsDragging = true
                    if Dual then
                        local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local a1 = (CurrentValue[1] - Min) / (Max - Min)
                        local a2 = (CurrentValue[2] - Min) / (Max - Min)
                        local dist1, dist2 = math.abs(Alpha - a1), math.abs(Alpha - a2)
                        ActiveHandle = dist1 == dist2 and (Alpha > a1 and 2 or 1) or (dist1 < dist2 and 1 or 2)
                    end
                    HandleDrag(Input)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then IsDragging = false end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if IsDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then HandleDrag(Input) end
            end)
            
            UpdateVisuals(CurrentValue)
            local SliderObj = {}
            function SliderObj:GetComponentType() return "Slider" end
            function SliderObj:GetValue() return CurrentValue end
            function SliderObj:SetValue(val) SetValue(val, true) end
            Library.Flags[FlagName] = SliderObj
            return SliderObj
        end

        function TabObj:Toggle(TOpts)
            local Title = TOpts.Title or "Toggle"
            local Default = TOpts.Default or false
            local Callback = TOpts.Callback or function() end
            
            local FlagName = TOpts.Flag or string.format("%s/Toggle/%s", TabObj.Title, Title)

            local Row = CreateRow(Title, 40)
            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})

            local Checkbox = Create("TextButton", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Default and Theme.Accent or Theme.Search, Text = "", AutoButtonColor = false, Parent = Row})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Checkbox})

            local State = Default
            
            ThemeUpdate(function()
                Checkbox.BackgroundColor3 = State and Theme.Accent or Theme.Search
                TitleLabel.TextColor3 = Theme.TextPrimary
            end)
            
            local function SetState(newState, triggerCallback)
                State = newState
                TweenService:Create(Checkbox, TweenFast, {BackgroundColor3 = State and Theme.Accent or Theme.Search}):Play()
                if triggerCallback then Callback(State) end
            end

            Checkbox.MouseButton1Click:Connect(function() SetState(not State, true) end)
            
            local ClickLayer = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5, Parent = Row})
            ClickLayer.MouseButton1Click:Connect(function() SetState(not State, true) end)

            local ToggleObj = {Row = Row}
            function ToggleObj:GetComponentType() return "Toggle" end
            function ToggleObj:GetValue() return State end
            function ToggleObj:SetValue(val) SetState(val, true) end
            
            function ToggleObj:Colorpicker(ColorProps)
                AttachColorPicker(Row, Title, ColorProps, 36)
                return self
            end
            
            Library.Flags[FlagName] = ToggleObj
            return ToggleObj
        end

        function TabObj:Dropdown(DOpts)
            local Title = DOpts.Title or "Dropdown"
            local OptionsList = DOpts.Options or {}
            local Multi = DOpts.Multi or false
            local Default = DOpts.Default
            local Callback = DOpts.Callback or function() end
            
            local FlagName = DOpts.Flag or string.format("%s/Dropdown/%s", TabObj.Title, Title)
            local SelectedItems = {}

            if Multi then
                if type(Default) == "table" then for _, Item in Default do table.insert(SelectedItems, Item) end end
            else
                if type(Default) == "string" and Default ~= "" then table.insert(SelectedItems, Default)
                elseif type(Default) == "table" and #Default > 0 then table.insert(SelectedItems, Default[1]) end
            end
            
            local Row = CreateRow(Title, 40)
            local TitleLabel = Create("TextLabel", {Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})

            local DropBtn = Create("TextButton", {Size = UDim2.new(0, 160, 0, 26), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme.Search, Text = "", AutoButtonColor = false, Parent = Row})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropBtn})
            
            local DropdownText = Create("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextPrimary, Font = Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropBtn})
            local Chevron = Create("ImageLabel", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -20, 0.5, -8), BackgroundTransparency = 1, Image = Icons.ChevronDown, ImageColor3 = Theme.TextSecondary, Parent = DropBtn})

            local function UpdateDropdownText()
                local Str = ""
                for I, V in SelectedItems do Str = Str .. V .. (I < #SelectedItems and ", " or "") end
                if string.len(Str) > 18 then Str = string.sub(Str, 1, 15) .. "..." end
                if Str == "" then Str = "None" end
                DropdownText.Text = Str
            end

            local DropdownMenu = Create("ScrollingFrame", {Size = UDim2.new(0, 160, 0, 0), BackgroundColor3 = Theme.Main, Visible = false, ClipsDescendants = true, ZIndex = 10, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = ScreenGui})
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownMenu})
            local DropStroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = DropdownMenu})
            Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = DropdownMenu})
            local MenuLayout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = DropdownMenu})

            local OptionButtons, Separators, IsOpen, RenderConnection = {}, {}, false, nil
            
            local function CloseDropdown()
                IsOpen = false
                TweenService:Create(Chevron, TweenSmooth, {Rotation = 0}):Play()
                local tw = TweenService:Create(DropdownMenu, TweenSmooth, {Size = UDim2.new(0, 160, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function()
                    if not IsOpen then DropdownMenu.Visible = false; if RenderConnection then RenderConnection:Disconnect(); RenderConnection = nil end end
                end)
            end
            table.insert(WindowObj.Popups, {Close = CloseDropdown})

            local function SetValue(val, triggerCallback)
                SelectedItems = {}
                if Multi then
                    if type(val) == "table" then for _, v in val do table.insert(SelectedItems, v) end end
                else
                    if type(val) == "string" and val ~= "" then table.insert(SelectedItems, val)
                    elseif type(val) == "table" and #val > 0 then table.insert(SelectedItems, val[1]) end
                end
                for Option, OptBtn in OptionButtons do
                    TweenService:Create(OptBtn, TweenFast, {TextColor3 = table.find(SelectedItems, Option) and Theme.Accent or Theme.TextSecondary}):Play()
                end
                UpdateDropdownText()
                if triggerCallback then Callback(Multi and SelectedItems or SelectedItems[1]) end
            end

            local function SetOptionsList(newOptions)
                OptionsList = type(newOptions) == "table" and newOptions or {}
                for _, btn in OptionButtons do btn:Destroy() end
                for _, sep in Separators do sep:Destroy() end
                table.clear(OptionButtons); table.clear(Separators)

                local newSelected = {}
                for _, item in SelectedItems do if table.find(OptionsList, item) then table.insert(newSelected, item) end end
                SelectedItems = newSelected

                for Index, Option in OptionsList do
                    local OptBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = Option, TextColor3 = table.find(SelectedItems, Option) and Theme.Accent or Theme.TextSecondary, Font = Theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = DropdownMenu})
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = OptBtn})
                    OptionButtons[Option] = OptBtn

                    OptBtn.MouseButton1Click:Connect(function()
                        if Multi then
                            local Idx = table.find(SelectedItems, Option)
                            local newItems = {}
                            for _, v in SelectedItems do table.insert(newItems, v) end
                            if Idx then table.remove(newItems, Idx) else table.insert(newItems, Option) end
                            SetValue(newItems, true)
                        else
                            SetValue(Option, true); CloseDropdown()
                        end
                    end)
                end
                UpdateDropdownText()
                if IsOpen then
                    TweenService:Create(DropdownMenu, TweenSmooth, {Size = UDim2.new(0, 160, 0, math.min(MenuLayout.AbsoluteContentSize.Y + 8, 160))}):Play()
                end
            end
            
            SetOptionsList(OptionsList)
            
            ThemeUpdate(function()
                TitleLabel.TextColor3 = Theme.TextPrimary
                DropdownText.TextColor3 = Theme.TextPrimary
                Chevron.ImageColor3 = Theme.TextSecondary
                DropBtn.BackgroundColor3 = Theme.Search
                DropdownMenu.BackgroundColor3 = Theme.Main
                DropStroke.Color = Theme.Border
                for Option, OptBtn in OptionButtons do OptBtn.TextColor3 = table.find(SelectedItems, Option) and Theme.Accent or Theme.TextSecondary end
            end)

            DropBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    DropdownMenu.Visible = true
                    TweenService:Create(Chevron, TweenSmooth, {Rotation = 180}):Play()
                    TweenService:Create(DropdownMenu, TweenSmooth, {Size = UDim2.new(0, 160, 0, math.min(MenuLayout.AbsoluteContentSize.Y + 8, 160))}):Play()
                    RenderConnection = RunService.RenderStepped:Connect(function()
                        if not DropdownMenu.Visible then return end
                        DropdownMenu.Position = UDim2.fromOffset(DropBtn.AbsolutePosition.X, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 6)
                    end)
                else
                    CloseDropdown()
                end
            end)

            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and DropdownMenu.Visible then
                    local MousePos = Vector2.new(Input.Position.X, Input.Position.Y)
                    local MPos, MSize = DropdownMenu.AbsolutePosition, DropdownMenu.AbsoluteSize
                    local BPos, BSize = DropBtn.AbsolutePosition, DropBtn.AbsoluteSize
                    if not ((MousePos.X >= MPos.X and MousePos.X <= MPos.X + MSize.X) and (MousePos.Y >= MPos.Y and MousePos.Y <= MPos.Y + MSize.Y)) and 
                       not ((MousePos.X >= BPos.X and MousePos.X <= BPos.X + BSize.X) and (MousePos.Y >= BPos.Y and MousePos.Y <= BPos.Y + BSize.Y)) then
                        CloseDropdown()
                    end
                end
            end)
            
            local DropdownObj = {}
            function DropdownObj:GetComponentType() return "Dropdown" end
            function DropdownObj:GetValue() return Multi and SelectedItems or SelectedItems[1] end
            function DropdownObj:SetValue(val) SetValue(val, true) end
            function DropdownObj:SetOptions(newOptions) SetOptionsList(newOptions) end
            function DropdownObj:GetOptions() return OptionsList end
            Library.Flags[FlagName] = DropdownObj
            return DropdownObj
        end

        return TabObj
    end

    WindowObj.ConfigTab = WindowObj:Tab({Title = "Configuration", Icon = Icons.Save, IsConfig = true})
    SaveBtn.MouseButton1Click:Connect(function() WindowObj.ConfigTab:Activate() end)

    return WindowObj
end

return Library