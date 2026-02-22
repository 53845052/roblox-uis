local oTweenService = game:GetService("TweenService")
local oUserInputService = game:GetService("UserInputService")
local oRunService = game:GetService("RunService")

local tLibrary = {}
tLibrary.AnimationSpeed = 1
tLibrary.ActivePopup = nil 
tLibrary.ThemeObjects = {}
tLibrary.DynamicUpdates = {}
tLibrary.Flags = {}
tLibrary.WindowKeybind = nil
tLibrary.WindowVisible = true
tLibrary.MainFrame = nil

local tConfig = { Colors = { MainBg = Color3.fromRGB(17, 17, 22), PanelBg = Color3.fromRGB(24, 24, 30), SectionBg = Color3.fromRGB(19, 19, 24), ElementBg = Color3.fromRGB(15, 15, 19), Accent = Color3.fromRGB(218, 36, 155), TextMain = Color3.fromRGB(138, 138, 149), TextLight = Color3.fromRGB(231, 231, 235), Border = Color3.fromRGB(35, 35, 42), Separator = Color3.fromRGB(31, 24, 34) }, Font = Font.new("rbxassetid://12187371840", Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextSize = 13, ChevronImage = "rbxassetid://10709790948", PickerCursor = "rbxassetid://10709798174" }

local function fnAnim(nTime, oStyle, oDir)
    return TweenInfo.new(nTime / tLibrary.AnimationSpeed, oStyle or Enum.EasingStyle.Quad, oDir or Enum.EasingDirection.Out)
end

local function fnCreate(sClass, tProperties, tThemeProps)
    local oInstance = Instance.new(sClass)
    for sKey, vValue in tProperties do oInstance[sKey] = vValue end
    if tThemeProps then for sProp, sColorKey in tThemeProps do oInstance[sProp] = tConfig.Colors[sColorKey]; table.insert(tLibrary.ThemeObjects, {oInstance, sProp, sColorKey}) end end
    return oInstance
end

local function fnGetBindText(oBind)
    if not oBind then return "None" end
    if oBind == Enum.UserInputType.MouseButton1 then return "MB1" end
    if oBind == Enum.UserInputType.MouseButton2 then return "MB2" end
    if oBind == Enum.UserInputType.MouseButton3 then return "MB3" end
    if oBind == Enum.KeyCode.Unknown then return "None" end
    if typeof(oBind) == "EnumItem" then if oBind.Name == "MouseButton1" then return "MB1" end; if oBind.Name == "MouseButton2" then return "MB2" end; if oBind.Name == "MouseButton3" then return "MB3" end; return oBind.Name end
    return "None"
end

local function fnMakeDraggable(oTopBar, oObject)
    local bDragging = nil
    local oDragInput = nil
    local oDragStart = nil
    local oStartPosition = nil
    oTopBar.InputBegan:Connect(function(oInput)
        if oInput.UserInputType == Enum.UserInputType.MouseButton1 or oInput.UserInputType == Enum.UserInputType.Touch then
            bDragging = true; oDragStart = oInput.Position; oStartPosition = oObject.Position
            oInput.Changed:Connect(function() if oInput.UserInputState == Enum.UserInputState.End then bDragging = false end end)
        end
    end)
    oTopBar.InputChanged:Connect(function(oInput) if oInput.UserInputType == Enum.UserInputType.MouseMovement or oInput.UserInputType == Enum.UserInputType.Touch then oDragInput = oInput end end)
    oUserInputService.InputChanged:Connect(function(oInput)
        if oInput == oDragInput and bDragging then local oDelta = oInput.Position - oDragStart; oObject.Position = UDim2.new(oStartPosition.X.Scale, oStartPosition.X.Offset + oDelta.X, oStartPosition.Y.Scale, oStartPosition.Y.Offset + oDelta.Y) end
    end)
end

function tLibrary:ClosePopups()
    if tLibrary.ActivePopup then tLibrary.ActivePopup.Close(); tLibrary.ActivePopup = nil end
end

function tLibrary:SetTheme(tNewColors)
    for sKey, vValue in tNewColors do if tConfig.Colors[sKey] then tConfig.Colors[sKey] = vValue end end
    for _, tObjData in tLibrary.ThemeObjects do local oInstance, sProp, sColorKey = tObjData[1], tObjData[2], tObjData[3]; if oInstance.Parent then oInstance[sProp] = tConfig.Colors[sColorKey] end end
    for _, fnFunc in tLibrary.DynamicUpdates do fnFunc() end
end

function tLibrary:GetTheme()
    local tThemeCopy = {}
    for sKey, vValue in tConfig.Colors do tThemeCopy[sKey] = vValue end
    return tThemeCopy
end

function tLibrary:SetAnimationSpeed(nNewAnimationSpeed)
    tLibrary.AnimationSpeed = nNewAnimationSpeed
end

function tLibrary:SetWindowKeybind(oKeyCode)
    tLibrary.WindowKeybind = oKeyCode
end

oUserInputService.InputBegan:Connect(function(oInput, bProcessed)
    if oInput.UserInputType == Enum.UserInputType.MouseButton1 or oInput.UserInputType == Enum.UserInputType.Touch then
        if tLibrary.ActivePopup and tLibrary.ActivePopup.Element then
            local oEle = tLibrary.ActivePopup.Element
            local nMx, nMy = oInput.Position.X, oInput.Position.Y
            local nPx, nPy = oEle.AbsolutePosition.X, oEle.AbsolutePosition.Y
            local nSx, nSy = oEle.AbsoluteSize.X, oEle.AbsoluteSize.Y
            if nMx < nPx or nMx > nPx + nSx or nMy < nPy or nMy > nPy + nSy then
                local bInIgnore = false
                if tLibrary.ActivePopup.Ignore then
                    for _, oIgnore in tLibrary.ActivePopup.Ignore do
                        local nIx, nIy = oIgnore.AbsolutePosition.X, oIgnore.AbsolutePosition.Y
                        local nIsx, nIsy = oIgnore.AbsoluteSize.X, oIgnore.AbsoluteSize.Y
                        if nMx >= nIx and nMx <= nIx + nIsx and nMy >= nIy and nMy <= nIy + nIsy then bInIgnore = true; break end
                    end
                end
                if not bInIgnore then tLibrary:ClosePopups() end
            end
        end
    end
    if not bProcessed and tLibrary.WindowKeybind and oInput.KeyCode == tLibrary.WindowKeybind and tLibrary.MainFrame then
        tLibrary.WindowVisible = not tLibrary.WindowVisible
        if tLibrary.WindowVisible then
            tLibrary.MainFrame.Visible = true
            oTweenService:Create(tLibrary.MainFrame, fnAnim(0.2), {GroupTransparency = 0}):Play()
        else
            local oTween = oTweenService:Create(tLibrary.MainFrame, fnAnim(0.2), {GroupTransparency = 1})
            oTween:Play()
            task.spawn(function()
                oTween.Completed:Wait()
                if not tLibrary.WindowVisible then tLibrary.MainFrame.Visible = false end
            end)
        end
    end
end)

function tLibrary:Window(vNameOrIcon)
    local oScreenGui = fnCreate("ScreenGui", { Name = "Seraph", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, IgnoreGuiInset = true })
    
    local oMainFrame = fnCreate("CanvasGroup", { Name = "MainFrame", Parent = oScreenGui, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0.9, 0, 0.9, 0), GroupTransparency = 0 }, {BackgroundColor3 = "PanelBg"})
    fnCreate("UISizeConstraint", { Parent = oMainFrame, MaxSize = Vector2.new(800, 600), MinSize = Vector2.new(400, 300) })
    tLibrary.MainFrame = oMainFrame
    fnCreate("UICorner", { Parent = oMainFrame, CornerRadius = UDim.new(0, 3) })
    fnCreate("UIStroke", { Parent = oMainFrame, Thickness = 1 }, {Color = "MainBg"})

    local oTopBar = fnCreate("Frame", { Name = "TopBar", Parent = oMainFrame, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 48) }, {BackgroundColor3 = "MainBg"})
    fnMakeDraggable(oTopBar, oMainFrame)
    
    if tostring(vNameOrIcon):find("rbxassetid") then
        fnCreate("ImageLabel", { Parent = oTopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 32, 0, 32), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 15, 0.5, 0), Image = vNameOrIcon, ScaleType = Enum.ScaleType.Fit }, {ImageColor3 = "Accent"})
    else
        fnCreate("TextLabel", { Parent = oTopBar, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(0, 100, 1, 0), FontFace = tConfig.Font, Text = tostring(vNameOrIcon or "F/"), TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left }, {TextColor3 = "Accent"})
    end

    local oTabContainer = fnCreate("Frame", { Parent = oTopBar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -20, 1, 0) })
    fnCreate("UIListLayout", { Parent = oTabContainer, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5) }) 

    local oBody = fnCreate("Frame", { Parent = oMainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(1, 0, 1, -48) })
    
    local oSidebarArea = fnCreate("Frame", { Parent = oBody, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(0, 140, 1, -30) })
    fnCreate("TextLabel", { Parent = oSidebarArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), FontFace = tConfig.Font, Text = "CATEGORIES", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, {TextColor3 = "TextMain"})
    local oSidebarList = fnCreate("ScrollingFrame", { Parent = oSidebarArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 1, -25), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y })
    fnCreate("UIListLayout", { Parent = oSidebarList, Padding = UDim.new(0, 10) })

    local oContentArea = fnCreate("Frame", { Parent = oBody, BackgroundTransparency = 1, Position = UDim2.new(0, 165, 0, 15), Size = UDim2.new(1, -180, 1, -30) })
    fnCreate("TextLabel", { Parent = oContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), FontFace = tConfig.Font, Text = "FEATURES", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, {TextColor3 = "TextMain"})
    local oSectionContainer = fnCreate("ScrollingFrame", { Parent = oContentArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 1, -25), ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, {ScrollBarImageColor3 = "Border"})
    fnCreate("UIListLayout", { Parent = oSectionContainer, Padding = UDim.new(0, 10) })

    local oContentFadeOverlay = fnCreate("Frame", { Parent = oContentArea, Name = "ContentFadeOverlay", Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), ZIndex = 1000, BackgroundTransparency = 1, Visible = false, BorderSizePixel = 0 }, {BackgroundColor3 = "PanelBg"})
    local oTabFadeOverlay = fnCreate("Frame", { Parent = oBody, Name = "TabFadeOverlay", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), ZIndex = 2000, BackgroundTransparency = 1, Visible = false, BorderSizePixel = 0 }, {BackgroundColor3 = "PanelBg"})

    local tWindowFunctions = {}
    local bFirstTab = true
    local tCurrentActiveSections = nil
    local bIsAnimatingTab = false

    function tWindowFunctions:AddTab(tIconAsset)
        local oTabButton = fnCreate("ImageButton", { Parent = oTabContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 32, 0, 32), Image = "", AutoButtonColor = false }, {BackgroundColor3 = "PanelBg"})
        fnCreate("UICorner", { Parent = oTabButton, CornerRadius = UDim.new(0, 4) })
        local oIconImg = fnCreate("ImageLabel", { Parent = oTabButton, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Image = tIconAsset[1] or "rbxassetid://10734962600" }, {ImageColor3 = "TextMain"})

        local tTabFunctions = {}
        local tCategories = {} 
        local tTabSubCategories = {} 
        local bIsThisTabActive = bFirstTab
        local bTabFirstSubCategory = true
        local fnActiveSubAction = nil 

        table.insert(tLibrary.DynamicUpdates, function() if bIsThisTabActive then oIconImg.ImageColor3 = tConfig.Colors.TextLight else oIconImg.ImageColor3 = tConfig.Colors.TextMain end end)

        local function fnActivateTab()
            if bIsAnimatingTab then return end
            tLibrary:ClosePopups()
            for _, oBtn in oTabContainer:GetChildren() do 
                if oBtn:IsA("ImageButton") then 
                    oTweenService:Create(oBtn, fnAnim(0.2), {BackgroundTransparency = 1}):Play()
                    local oInnerIcon = oBtn:FindFirstChild("ImageLabel")
                    if oInnerIcon then oTweenService:Create(oInnerIcon, fnAnim(0.2), {ImageColor3 = tConfig.Colors.TextMain}):Play() end
                end 
            end
            oTweenService:Create(oTabButton, fnAnim(0.2), {BackgroundTransparency = 1}):Play() 
            oTweenService:Create(oIconImg, fnAnim(0.2), {ImageColor3 = tConfig.Colors.TextLight}):Play()

            task.spawn(function()
                bIsAnimatingTab = true
                oTabFadeOverlay.Visible = true
                local oOutTween = oTweenService:Create(oTabFadeOverlay, fnAnim(0.12), {BackgroundTransparency = 0}); oOutTween:Play(); oOutTween.Completed:Wait()
                for _, oChild in oSidebarList:GetChildren() do if oChild:IsA("Frame") then oChild.Visible = false end end
                for _, oCat in tCategories do oCat.Visible = true end
                if fnActiveSubAction then fnActiveSubAction(true) else for _, oChild in oSectionContainer:GetChildren() do if oChild:IsA("Frame") then oChild.Visible = false end end end
                local oInTween = oTweenService:Create(oTabFadeOverlay, fnAnim(0.12), {BackgroundTransparency = 1}); oInTween:Play(); oInTween.Completed:Wait()
                oTabFadeOverlay.Visible = false; bIsAnimatingTab = false
            end)
        end

        oTabButton.MouseButton1Click:Connect(fnActivateTab)
        if bFirstTab then bFirstTab = false; oIconImg.ImageColor3 = tConfig.Colors.TextLight end

        function tTabFunctions:AddCategory(sCatName)
            local oCategoryFrame = fnCreate("Frame", { Parent = oSidebarList, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = bIsThisTabActive, BorderSizePixel = 0 }, {BackgroundColor3 = "SectionBg"})
            fnCreate("UICorner", {Parent = oCategoryFrame, CornerRadius = UDim.new(0, 4)})
            fnCreate("UIStroke", {Parent = oCategoryFrame, Thickness = 1}, {Color = "Border"})
            table.insert(tCategories, oCategoryFrame)

            local oCatHeader = fnCreate("TextButton", { Parent = oCategoryFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), FontFace = tConfig.Font, Text = "  " .. sCatName, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false }, {TextColor3 = "TextLight"})
            local oCatIcon = fnCreate("ImageLabel", { Parent = oCatHeader, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 0.5, -8), Image = tConfig.ChevronImage, Rotation = 0 }, {ImageColor3 = "TextMain"})
            local oSubCatContainer = fnCreate("Frame", { Parent = oCategoryFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true, Visible = true })
            fnCreate("UIListLayout", { Parent = oSubCatContainer, Padding = UDim.new(0, 2) })
            fnCreate("UIPadding", { Parent = oSubCatContainer, PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })

            local bCatOpen = true
            oCatHeader.MouseButton1Click:Connect(function() bCatOpen = not bCatOpen; oSubCatContainer.Visible = bCatOpen; oTweenService:Create(oCatIcon, fnAnim(0.2), {Rotation = bCatOpen and 0 or -90}):Play() end)

            local tCategoryFunctions = {}

            function tCategoryFunctions:AddSubCategory(sSubCatName)
                local oSubButton = fnCreate("TextButton", { Parent = oSubCatContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), FontFace = tConfig.Font, Text = "  " .. sSubCatName, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false }, {TextColor3 = "TextMain"})
                fnCreate("UICorner", {Parent = oSubButton, CornerRadius = UDim.new(0, 3)})
                local oActiveBorder = fnCreate("Frame", { Parent = oSubButton, BorderSizePixel = 0, Size = UDim2.new(0, 2, 1, 0), Visible = false }, {BackgroundColor3 = "Accent"})

                local tSubFunctions = {}
                local tAssociatedSections = {}
                local tSubState = {bIsActive = false, oButton = oSubButton, oActiveBorder = oActiveBorder}
                table.insert(tTabSubCategories, tSubState)

                table.insert(tLibrary.DynamicUpdates, function()
                    if tSubState.bIsActive then
                        oSubButton.TextColor3 = tConfig.Colors.TextLight; oSubButton.BackgroundTransparency = 0.95; oSubButton.BackgroundColor3 = Color3.new(1,1,1); oActiveBorder.Visible = true
                    else
                        oSubButton.TextColor3 = tConfig.Colors.TextMain; oSubButton.BackgroundTransparency = 1; oActiveBorder.Visible = false
                    end
                end)

                local function fnSelectSubCategory(bNoFade)
                    tLibrary:ClosePopups()
                    fnActiveSubAction = fnSelectSubCategory
                    tCurrentActiveSections = tAssociatedSections
                    
                    for _, tState in tTabSubCategories do
                        tState.bIsActive = false; oTweenService:Create(tState.oButton, fnAnim(0.2), {BackgroundTransparency = 1, TextColor3 = tConfig.Colors.TextMain}):Play(); tState.oActiveBorder.Visible = false
                    end
                    
                    tSubState.bIsActive = true; oTweenService:Create(oSubButton, fnAnim(0.2), {BackgroundTransparency = 0.95, BackgroundColor3 = Color3.new(1,1,1), TextColor3 = tConfig.Colors.TextLight}):Play(); oActiveBorder.Visible = true

                    if not bNoFade then
                        task.spawn(function()
                            oContentFadeOverlay.Visible = true
                            local oOutTween = oTweenService:Create(oContentFadeOverlay, fnAnim(0.12), {BackgroundTransparency = 0}); oOutTween:Play(); oOutTween.Completed:Wait()
                            if tCurrentActiveSections == tAssociatedSections then
                                for _, oChild in oSectionContainer:GetChildren() do if oChild:IsA("Frame") then oChild.Visible = false end end
                                for _, oSection in tAssociatedSections do oSection.Visible = true end
                                local oInTween = oTweenService:Create(oContentFadeOverlay, fnAnim(0.12), {BackgroundTransparency = 1}); oInTween:Play(); oInTween.Completed:Wait()
                                if tCurrentActiveSections == tAssociatedSections then oContentFadeOverlay.Visible = false end
                            end
                        end)
                    else
                        oContentFadeOverlay.Visible = false
                        for _, oChild in oSectionContainer:GetChildren() do if oChild:IsA("Frame") then oChild.Visible = false end end
                        for _, oSection in tAssociatedSections do oSection.Visible = true end
                    end
                end

                oSubButton.MouseButton1Click:Connect(function() fnSelectSubCategory(false) end)

                if bTabFirstSubCategory then fnActiveSubAction = fnSelectSubCategory; bTabFirstSubCategory = false; if bIsThisTabActive then fnSelectSubCategory(true) end end

                function tSubFunctions:AddSection(sSectionName)
                    local oSectionFrame = fnCreate("Frame", { Parent = oSectionContainer, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, BorderSizePixel = 0 }, {BackgroundColor3 = "SectionBg"})
                    fnCreate("UICorner", {Parent = oSectionFrame, CornerRadius = UDim.new(0, 4)})
                    fnCreate("UIStroke", {Parent = oSectionFrame, Thickness = 1}, {Color = "Border"})
                    table.insert(tAssociatedSections, oSectionFrame)
                    
                    if tSubState.bIsActive then oSectionFrame.Visible = true end

                    local oHeaderBtn = fnCreate("TextButton", { Parent = oSectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Text = "  " .. sSectionName, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false }, {TextColor3 = "TextMain"})
                    local oSecIcon = fnCreate("ImageLabel", { Parent = oHeaderBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 0.5, -8), Image = tConfig.ChevronImage, Rotation = 0 }, {ImageColor3 = "TextMain"}) 
                    fnCreate("Frame", { Parent = oSectionFrame, BorderSizePixel = 0, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1, 0, 0, 1) }, {BackgroundColor3 = "Separator"})

                    local oElementsContainer = fnCreate("Frame", { Parent = oSectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = false })
                    fnCreate("UIListLayout", { Parent = oElementsContainer, Padding = UDim.new(0, 8) })
                    fnCreate("UIPadding", { Parent = oSectionFrame, PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

                    local bSecOpen = true
                    oHeaderBtn.MouseButton1Click:Connect(function() bSecOpen = not bSecOpen; oElementsContainer.Visible = bSecOpen; oTweenService:Create(oSecIcon, fnAnim(0.2), {Rotation = bSecOpen and 0 or -90}):Play() end)

                    local tSectionFunctions = {}

                    local function fnAttachAddons(tFunctionsObj, oRightSideContainer, fnParentToggleFunc, bIsLabel)
                        function tFunctionsObj:Colorpicker(tColProps)
                            local oCurrentColor = tColProps.Default or Color3.new(1,1,1)
                            local nCurrentAlpha = 1
                            local tHSV = {Color3.toHSV(oCurrentColor)}

                            local oColorBtn = fnCreate("TextButton", { Parent = oRightSideContainer, Text = "", Size = UDim2.new(0, 25, 0, 12), BackgroundColor3 = oCurrentColor, BorderSizePixel = 1, AutoButtonColor = false, LayoutOrder = 1 }, {BorderColor3 = "Border"})
                            local oPickerFrame = fnCreate("Frame", { Parent = oScreenGui, Name = "ColorPickerPopup", BorderSizePixel = 1, Size = UDim2.new(0, 220, 0, 190), Visible = false, ZIndex = 3000 }, {BackgroundColor3 = "PanelBg", BorderColor3 = "Border"})
                            fnCreate("UIStroke", { Parent = oPickerFrame, Thickness = 2 }, {Color = "Border"})
                            
                            local oColorMap = fnCreate("TextButton", { Parent = oPickerFrame, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 0, 130), BackgroundColor3 = Color3.fromHSV(tHSV[1], 1, 1), AutoButtonColor = false, Text = "", ZIndex = 3001 })
                            local oSatOverlay = fnCreate("Frame", {Parent = oColorMap, Size = UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(1,1,1), ZIndex=3002, BorderSizePixel=0})
                            local oSatGradient = fnCreate("UIGradient", {Parent = oSatOverlay, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}})
                            local oValOverlay = fnCreate("Frame", {Parent = oColorMap, Size = UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(0,0,0), ZIndex=3003, BorderSizePixel=0})
                            local oValGradient = fnCreate("UIGradient", {Parent = oValOverlay, Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}})
                            local oMapMarker = fnCreate("ImageLabel", { Parent = oColorMap, Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, Image = tConfig.PickerCursor, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(tHSV[2], 0, 1-tHSV[3], 0), ZIndex = 3004 })

                            local oHueBar = fnCreate("TextButton", { Parent = oPickerFrame, Position = UDim2.new(0, 10, 0, 150), Size = UDim2.new(1, -20, 0, 10), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false, Text = "", ZIndex = 3001 })
                            fnCreate("UIGradient", { Parent = oHueBar, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))} })
                            local oHueMarker = fnCreate("Frame", { Parent = oHueBar, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 3002, Position = UDim2.new(tHSV[1], 0, 0, 0) })

                            local oAlphaBar = fnCreate("TextButton", { Parent = oPickerFrame, Position = UDim2.new(0, 10, 0, 170), Size = UDim2.new(1, -20, 0, 10), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false, Text = "", ZIndex = 3001 })
                            fnCreate("ImageLabel", { Parent = oAlphaBar, Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Image="rbxassetid://138299238074834", ScaleType=Enum.ScaleType.Tile, TileSize=UDim2.new(0,10,0,10), ZIndex=3001 })
                            local oAlphaGradient = fnCreate("UIGradient", { Parent = fnCreate("Frame", {Parent=oAlphaBar, Size=UDim2.new(1,0,1,0), BackgroundColor3=oCurrentColor, ZIndex=3002}), Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)} })
                            local oAlphaMarker = fnCreate("Frame", { Parent = oAlphaBar, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 3003, Position = UDim2.new(nCurrentAlpha, 0, 0, 0) })

                            local function fnUpdateVisuals()
                                oColorBtn.BackgroundColor3 = oCurrentColor; oColorMap.BackgroundColor3 = Color3.fromHSV(tHSV[1], 1, 1); oAlphaGradient.Parent.BackgroundColor3 = oCurrentColor
                                oTweenService:Create(oMapMarker, fnAnim(0.08), {Position = UDim2.new(tHSV[2], 0, 1-tHSV[3], 0)}):Play(); oTweenService:Create(oHueMarker, fnAnim(0.08), {Position = UDim2.new(tHSV[1], 0, 0, 0)}):Play(); oTweenService:Create(oAlphaMarker, fnAnim(0.08), {Position = UDim2.new(nCurrentAlpha, 0, 0, 0)}):Play()
                                if tColProps.Callback then tColProps.Callback(oCurrentColor) end
                            end

                            local function fnHandleInput(oGuiObj, sType, oInitInput)
                                local function update(inputVec)
                                    local nMaxX, nMaxY = oGuiObj.AbsoluteSize.X, oGuiObj.AbsoluteSize.Y
                                    local nPx, nPy = math.clamp(inputVec.X - oGuiObj.AbsolutePosition.X, 0, nMaxX), math.clamp(inputVec.Y - oGuiObj.AbsolutePosition.Y, 0, nMaxY)
                                    local nX, nY = nPx/nMaxX, nPy/nMaxY
                                    if sType == "Map" then tHSV[2]=nX; tHSV[3]=1-nY elseif sType == "Hue" then tHSV[1]=nX elseif sType == "Alpha" then nCurrentAlpha=nX end
                                    oCurrentColor = Color3.fromHSV(tHSV[1], tHSV[2], tHSV[3]); fnUpdateVisuals()
                                end
                                update(oInitInput.Position)
                                local cMove = oUserInputService.InputChanged:Connect(function(oMove)
                                    if oMove.UserInputType == Enum.UserInputType.MouseMovement or oMove.UserInputType == Enum.UserInputType.Touch then update(oMove.Position) end
                                end)
                                local cEnd; cEnd = oUserInputService.InputEnded:Connect(function(oEnd)
                                    if oEnd.UserInputType == Enum.UserInputType.MouseButton1 or oEnd.UserInputType == Enum.UserInputType.Touch then cMove:Disconnect(); cEnd:Disconnect() end
                                end)
                            end

                            oColorMap.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fnHandleInput(oColorMap, "Map", i) end end)
                            oHueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fnHandleInput(oHueBar, "Hue", i) end end)
                            oAlphaBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fnHandleInput(oAlphaBar, "Alpha", i) end end)
                            
                            oColorBtn.MouseButton1Click:Connect(function()
                                if oPickerFrame.Visible then 
                                    oPickerFrame.Visible = false; tLibrary.ActivePopup = nil 
                                else 
                                    tLibrary:ClosePopups(); 
                                    tLibrary.ActivePopup = {Element = oPickerFrame, Ignore = {oColorBtn}, Close = function() oPickerFrame.Visible = false end}; 
                                    local nPx = oColorBtn.AbsolutePosition.X - 200
                                    local nPy = oColorBtn.AbsolutePosition.Y + 20
                                    
                                    if nPx < 0 then nPx = oColorBtn.AbsolutePosition.X + oColorBtn.AbsoluteSize.X + 10 end
                                    if nPy + 190 > oScreenGui.AbsoluteSize.Y then nPy = oScreenGui.AbsoluteSize.Y - 195 end
                                    
                                    oPickerFrame.Position = UDim2.new(0, nPx, 0, nPy)
                                    oPickerFrame.Visible = true; 
                                end
                            end)
                            
                            oMapMarker.Position = UDim2.new(tHSV[2], 0, 1-tHSV[3], 0); oHueMarker.Position = UDim2.new(tHSV[1], 0, 0, 0); oAlphaMarker.Position = UDim2.new(nCurrentAlpha, 0, 0, 0)
                            
                            local tCPFunctions = {}
                            function tCPFunctions:SetValue(oVal) oCurrentColor = oVal; tHSV = {Color3.toHSV(oCurrentColor)}; fnUpdateVisuals() end
                            function tCPFunctions:GetValue() return oCurrentColor end
                            if tColProps.Flag then tLibrary.Flags[tColProps.Flag] = tCPFunctions end
                            
                            return tFunctionsObj
                        end

                        function tFunctionsObj:Bind(tBindProps)
                            local oCurrentBind = tBindProps.Default
                            local sCurrentMode = tBindProps.Type or "Hold"

                            local oBindFrame = fnCreate("Frame", { Parent = oRightSideContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 10 })
                            fnCreate("UIListLayout", { Parent = oBindFrame, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4) })
                            
                            local oModeBtn = nil
                            if not bIsLabel then
                                oModeBtn = fnCreate("TextButton", { Parent = oBindFrame, BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, Text = sCurrentMode, FontFace = tConfig.Font, TextSize = 10, AutoButtonColor = false }, {BackgroundColor3 = "ElementBg", BorderColor3 = "Border", TextColor3 = "TextMain"})
                                fnCreate("UIPadding", { Parent = oModeBtn, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
                                oModeBtn.MouseButton1Click:Connect(function()
                                    if tLibrary.ActivePopup then tLibrary:ClosePopups() end
                                    local oModeDrop = fnCreate("Frame", { Parent = oScreenGui, BorderSizePixel = 1, Size = UDim2.new(0, oModeBtn.AbsoluteSize.X, 0, 60), Visible = true, ZIndex = 3000 }, {BackgroundColor3 = "ElementBg", BorderColor3 = "Border"})
                                    fnCreate("UIListLayout", {Parent = oModeDrop}); 
                                    
                                    local nMaxH = 60
                                    local nY = oModeBtn.AbsolutePosition.Y + oModeBtn.AbsoluteSize.Y + 2
                                    if nY + nMaxH > oScreenGui.AbsoluteSize.Y then nY = oModeBtn.AbsolutePosition.Y - nMaxH - 2 end
                                    oModeDrop.Position = UDim2.new(0, oModeBtn.AbsolutePosition.X, 0, nY)
                                    
                                    local tModes = {"Hold", "Toggle", "Always"}
                                    for _, sMode in tModes do
                                        local oMBtn = fnCreate("TextButton", { Parent = oModeDrop, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = sMode, FontFace = tConfig.Font, TextSize = 10, ZIndex = 3002, AutoButtonColor = false }, {TextColor3 = (sMode == sCurrentMode and "TextLight" or "TextMain")})
                                        oMBtn.MouseButton1Click:Connect(function() sCurrentMode = sMode; oModeBtn.Text = sMode; oModeDrop:Destroy(); tLibrary.ActivePopup = nil; if fnParentToggleFunc then if sCurrentMode == "Always" then fnParentToggleFunc(true) else fnParentToggleFunc(tFunctionsObj:GetValue()) end end end)
                                    end
                                    tLibrary.ActivePopup = {Element = oModeDrop, Ignore = {oModeBtn}, Close = function() oModeDrop:Destroy() end}
                                end)
                            end

                            local oKeyBtn = fnCreate("TextButton", { Parent = oBindFrame, BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, Text = fnGetBindText(oCurrentBind), FontFace = tConfig.Font, TextSize = 10, AutoButtonColor = false }, {BackgroundColor3 = "ElementBg", BorderColor3 = "Border", TextColor3 = "TextMain"})
                            fnCreate("UIPadding", { Parent = oKeyBtn, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })

                            local bBinding = false
                            oKeyBtn.MouseButton1Click:Connect(function()
                                if bBinding then return end; bBinding = true; oKeyBtn.Text = "..."
                                local cInputCon; cInputCon = oUserInputService.InputBegan:Connect(function(oInput)
                                    if oInput.UserInputType == Enum.UserInputType.Keyboard then 
                                        if oInput.KeyCode == Enum.KeyCode.Escape then oCurrentBind = nil; oKeyBtn.Text = "None" 
                                        else oCurrentBind = oInput.KeyCode; oKeyBtn.Text = oInput.KeyCode.Name end; 
                                        bBinding = false; cInputCon:Disconnect() 
                                        if bIsLabel and tBindProps.Callback then tBindProps.Callback(oCurrentBind) end
                                    elseif oInput.UserInputType == Enum.UserInputType.MouseButton1 or oInput.UserInputType == Enum.UserInputType.MouseButton2 or oInput.UserInputType == Enum.UserInputType.MouseButton3 then 
                                        oCurrentBind = oInput.UserInputType; oKeyBtn.Text = fnGetBindText(oInput.UserInputType); 
                                        bBinding = false; cInputCon:Disconnect() 
                                        if bIsLabel and tBindProps.Callback then tBindProps.Callback(oCurrentBind) end
                                    end
                                end)
                            end)
                            
                            if not bIsLabel then
                                oUserInputService.InputBegan:Connect(function(oInput)
                                    if not bBinding and oCurrentBind and (oInput.KeyCode == oCurrentBind or oInput.UserInputType == oCurrentBind) then if fnParentToggleFunc then if sCurrentMode == "Toggle" then fnParentToggleFunc(not tFunctionsObj:GetValue()) elseif sCurrentMode == "Hold" then fnParentToggleFunc(true) end else if tBindProps.Callback then tBindProps.Callback() end end end
                                end)
                                oUserInputService.InputEnded:Connect(function(oInput)
                                    if not bBinding and oCurrentBind and (oInput.KeyCode == oCurrentBind or oInput.UserInputType == oCurrentBind) then if fnParentToggleFunc and sCurrentMode == "Hold" then fnParentToggleFunc(false) end end
                                end)
                                if fnParentToggleFunc and sCurrentMode == "Always" then fnParentToggleFunc(true) end
                            end
                            
                            local tBindFunctions = {}
                            function tBindFunctions:SetValue(oVal) oCurrentBind = oVal; oKeyBtn.Text = fnGetBindText(oCurrentBind) end
                            function tBindFunctions:GetValue() return oCurrentBind end
                            if tBindProps.Flag then tLibrary.Flags[tBindProps.Flag] = tBindFunctions end

                            return tFunctionsObj
                        end
                    end

                    function tSectionFunctions:Button(tProps)
                        local oButtonFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26) })
                        fnCreate("UIListLayout", { Parent = oButtonFrame, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5) })
                        
                        local tButtonsInGroup = {}
                        local tButtonFunctions = {}

                        local function fnAddButton(tBtnProps)
                            local oBtn = fnCreate("TextButton", { Parent = oButtonFrame, BorderSizePixel = 0, FontFace = tConfig.Font, Text = tBtnProps.Title, TextSize = 12, AutoButtonColor = false }, {BackgroundColor3 = "ElementBg", TextColor3 = "TextMain"})
                            fnCreate("UICorner", { Parent = oBtn, CornerRadius = UDim.new(0, 4) })
                            local oStroke = fnCreate("UIStroke", { Parent = oBtn, Thickness = 1 }, {Color = "Border"})
                            
                            oBtn.MouseEnter:Connect(function() oTweenService:Create(oBtn, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextLight}):Play(); oTweenService:Create(oStroke, fnAnim(0.15), {Color = tConfig.Colors.Accent}):Play() end)
                            oBtn.MouseLeave:Connect(function() oTweenService:Create(oBtn, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextMain}):Play(); oTweenService:Create(oStroke, fnAnim(0.15), {Color = tConfig.Colors.Border}):Play() end)
                            oBtn.MouseButton1Click:Connect(function() local oClickTween = oTweenService:Create(oBtn, fnAnim(0.1), {BackgroundColor3 = tConfig.Colors.SectionBg}); oClickTween:Play(); oClickTween.Completed:Wait(); oTweenService:Create(oBtn, fnAnim(0.1), {BackgroundColor3 = tConfig.Colors.ElementBg}):Play(); if tBtnProps.Callback then tBtnProps.Callback() end end)

                            table.insert(tButtonsInGroup, oBtn)

                            local nTotalPadding = (#tButtonsInGroup - 1) * 5
                            local nOffset = - (nTotalPadding / #tButtonsInGroup)
                            
                            for _, b in tButtonsInGroup do
                                b.Size = UDim2.new(1 / #tButtonsInGroup, nOffset, 1, 0)
                            end

                            if tBtnProps.Flag then 
                                tLibrary.Flags[tBtnProps.Flag] = {
                                    SetValue = function(_, oVal) oBtn.Text = tostring(oVal) end,
                                    GetValue = function() return oBtn.Text end
                                }
                            end

                            return tButtonFunctions
                        end

                        function tButtonFunctions:Button(tNewProps)
                            return fnAddButton(tNewProps)
                        end

                        function tButtonFunctions:SetValue(oVal) tButtonsInGroup[1].Text = tostring(oVal) end
                        function tButtonFunctions:GetValue() return tButtonsInGroup[1].Text end

                        return fnAddButton(tProps)
                    end

                    function tSectionFunctions:Label(tProps)
                        local oLabelFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) })
                        local oTitle = fnCreate("TextLabel", { Parent = oLabelFrame, BackgroundTransparency = 1, Text = tProps.Title, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 1, 0) }, {TextColor3 = "TextMain"})
                        local oRightSide = fnCreate("Frame", { Parent = oLabelFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0) })
                        local oRightLayout = fnCreate("UIListLayout", { Parent = oRightSide, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
                        oRightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() oRightSide.Size = UDim2.new(0, oRightLayout.AbsoluteContentSize.X, 1, 0) end)

                        local tLabelFunctions = {}
                        function tLabelFunctions:SetValue(oVal) oTitle.Text = tostring(oVal) end
                        function tLabelFunctions:GetValue() return oTitle.Text end
                        
                        fnAttachAddons(tLabelFunctions, oRightSide, nil, true)
                        if tProps.Flag then tLibrary.Flags[tProps.Flag] = tLabelFunctions end
                        return tLabelFunctions
                    end

                    function tSectionFunctions:Textbox(tProps)
                        local oTextboxFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26) })
                        fnCreate("TextLabel", { Parent = oTextboxFrame, BackgroundTransparency = 1, Text = tProps.Title, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.5, -5, 1, 0) }, {TextColor3 = "TextMain"})

                        local oInputBox = fnCreate("TextBox", { 
                            Parent = oTextboxFrame, 
                            BorderSizePixel = 0, 
                            Text = tProps.Default or "", 
                            PlaceholderText = tProps.Placeholder or "", 
                            PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                            FontFace = tConfig.Font, 
                            TextSize = 11, 
                            TextXAlignment = Enum.TextXAlignment.Left, 
                            Position = UDim2.new(0.5, 5, 0, 0), 
                            Size = UDim2.new(0.5, -5, 1, 0), 
                            ClearTextOnFocus = tProps.ClearText or false,
                            ClipsDescendants = true
                        }, {BackgroundColor3 = "ElementBg", TextColor3 = "TextMain"})
                        
                        fnCreate("UIPadding", {Parent = oInputBox, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0, 8)})
                        fnCreate("UICorner", {Parent = oInputBox, CornerRadius = UDim.new(0, 3)})
                        local oStroke = fnCreate("UIStroke", {Parent = oInputBox, Thickness = 1}, {Color = "Border"})

                        local tTextboxFunctions = {}

                        oInputBox.Focused:Connect(function()
                            oTweenService:Create(oStroke, fnAnim(0.15), {Color = tConfig.Colors.Accent}):Play()
                            oTweenService:Create(oInputBox, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextLight}):Play()
                        end)

                        oInputBox.FocusLost:Connect(function()
                            oTweenService:Create(oStroke, fnAnim(0.15), {Color = tConfig.Colors.Border}):Play()
                            oTweenService:Create(oInputBox, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextMain}):Play()
                            if tProps.Callback then tProps.Callback(oInputBox.Text) end
                        end)

                        function tTextboxFunctions:SetValue(sVal)
                            oInputBox.Text = tostring(sVal)
                            if tProps.Callback then tProps.Callback(oInputBox.Text) end
                        end

                        function tTextboxFunctions:GetValue()
                            return oInputBox.Text
                        end

                        if tProps.Flag then tLibrary.Flags[tProps.Flag] = tTextboxFunctions end
                        return tTextboxFunctions
                    end

                    function tSectionFunctions:Toggle(tProps)
                        local oToggleFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) })
                        local oCheckbox = fnCreate("TextButton", { Parent = oToggleFrame, BorderSizePixel = 0, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0.5, -6), Text = "", AutoButtonColor = false }, {BackgroundColor3 = "ElementBg"})
                        local oCheckStroke = fnCreate("UIStroke", { Parent = oCheckbox, Color = Color3.fromRGB(50,50,50), Thickness = 1 })
                        local oTitle = fnCreate("TextLabel", { Parent = oToggleFrame, BackgroundTransparency = 1, Text = tProps.Title, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 22, 0, 0), Size = UDim2.new(1, -22, 1, 0) }, {TextColor3 = "TextMain"})
                        local oRightSide = fnCreate("Frame", { Parent = oToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0) })
                        local oRightLayout = fnCreate("UIListLayout", { Parent = oRightSide, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
                        oRightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() oRightSide.Size = UDim2.new(0, oRightLayout.AbsoluteContentSize.X, 1, 0) end)

                        local bToggled = tProps.Default or false
                        local function fnUpdateState(bForcedVal)
                            if bForcedVal ~= nil then bToggled = bForcedVal end
                            if bToggled then oTweenService:Create(oCheckbox, fnAnim(0.15), {BackgroundColor3 = tConfig.Colors.Accent}):Play(); oCheckStroke.Color = tConfig.Colors.Accent; oTweenService:Create(oTitle, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextLight}):Play() else oTweenService:Create(oCheckbox, fnAnim(0.15), {BackgroundColor3 = tConfig.Colors.ElementBg}):Play(); oCheckStroke.Color = Color3.fromRGB(50,50,50); oTweenService:Create(oTitle, fnAnim(0.15), {TextColor3 = tConfig.Colors.TextMain}):Play() end
                            if tProps.Callback then tProps.Callback(bToggled) end
                        end
                        fnUpdateState()
                        table.insert(tLibrary.DynamicUpdates, function() fnUpdateState(bToggled) end)

                        oCheckbox.MouseButton1Click:Connect(function() bToggled = not bToggled; fnUpdateState() end)

                        local tToggleFunctions = {}
                        function tToggleFunctions:SetValue(oVal) fnUpdateState(oVal) end
                        function tToggleFunctions:GetValue() return bToggled end
                        
                        fnAttachAddons(tToggleFunctions, oRightSide, fnUpdateState, false)
                        if tProps.Flag then tLibrary.Flags[tProps.Flag] = tToggleFunctions end
                        return tToggleFunctions
                    end

                    function tSectionFunctions:Slider(tProps)
                        local oSliderFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35) })
                        fnCreate("TextLabel", { Parent = oSliderFrame, BackgroundTransparency = 1, Text = tProps.Title, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 15) }, {TextColor3 = "TextMain"})
                        local oValueLabel = fnCreate("TextLabel", { Parent = oSliderFrame, BackgroundTransparency = 1, Text = "", FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 15) }, {TextColor3 = "TextLight"})
                        local oSliderBg = fnCreate("TextButton", { Parent = oSliderFrame, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 4), Text = "", AutoButtonColor = false }, {BackgroundColor3 = "ElementBg"})
                        local oSliderFill = fnCreate("Frame", { Parent = oSliderBg, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0) }, {BackgroundColor3 = "Accent"})

                        local tSliderFunctions = {}
                        local nDecimals = tProps.Decimal or 0
                        local nMult = 10 ^ nDecimals
                        local sFormat = "%." .. nDecimals .. "f"
                        local sPrefix = tProps.Prefix or ""
                        local sSuffix = tProps.Suffix or ""

                        if tProps.Dual then
                            local nCurrentMin = tProps.Default and tProps.Default[1] or tProps.Min
                            local nCurrentMax = tProps.Default and tProps.Default[2] or tProps.Max
                            oValueLabel.Text = `{sPrefix}{string.format(sFormat, nCurrentMin)}{sSuffix} - {sPrefix}{string.format(sFormat, nCurrentMax)}{sSuffix}`
                            
                            oSliderBg.InputBegan:Connect(function(oInput)
                                if oInput.UserInputType == Enum.UserInputType.MouseButton1 or oInput.UserInputType == Enum.UserInputType.Touch then 
                                    local function update(inputVec)
                                        local nRatio = math.clamp((inputVec.X - oSliderBg.AbsolutePosition.X) / oSliderBg.AbsoluteSize.X, 0, 1)
                                        local nRaw = tProps.Min + ((tProps.Max - tProps.Min) * nRatio)
                                        local nNewValue = math.floor(nRaw * nMult + 0.5) / nMult

                                        local nDistMin = math.abs(nNewValue - nCurrentMin)
                                        local nDistMax = math.abs(nNewValue - nCurrentMax)
                                        if nDistMin < nDistMax then nCurrentMin = math.clamp(nNewValue, tProps.Min, nCurrentMax) else nCurrentMax = math.clamp(nNewValue, nCurrentMin, tProps.Max) end
                                        tSliderFunctions:SetValue({nCurrentMin, nCurrentMax})
                                    end
                                    update(oInput.Position)
                                    local cMove = oUserInputService.InputChanged:Connect(function(oMove)
                                        if oMove.UserInputType == Enum.UserInputType.MouseMovement or oMove.UserInputType == Enum.UserInputType.Touch then update(oMove.Position) end
                                    end)
                                    local cEnd; cEnd = oUserInputService.InputEnded:Connect(function(oEnd)
                                        if oEnd.UserInputType == Enum.UserInputType.MouseButton1 or oEnd.UserInputType == Enum.UserInputType.Touch then cMove:Disconnect(); cEnd:Disconnect() end
                                    end)
                                end
                            end)
                            
                            function tSliderFunctions:SetValue(tVal)
                                nCurrentMin = math.clamp(math.floor(tVal[1] * nMult + 0.5) / nMult, tProps.Min, tProps.Max); nCurrentMax = math.clamp(math.floor(tVal[2] * nMult + 0.5) / nMult, nCurrentMin, tProps.Max)
                                oValueLabel.Text = `{sPrefix}{string.format(sFormat, nCurrentMin)}{sSuffix} - {sPrefix}{string.format(sFormat, nCurrentMax)}{sSuffix}`
                                local nMinScale = (nCurrentMin - tProps.Min) / (tProps.Max - tProps.Min); local nMaxScale = (nCurrentMax - tProps.Min) / (tProps.Max - tProps.Min)
                                oTweenService:Create(oSliderFill, fnAnim(0.08), { Position = UDim2.new(nMinScale, 0, 0, 0), Size = UDim2.new(nMaxScale - nMinScale, 0, 1, 0) }):Play()
                                if tProps.Callback then tProps.Callback({nCurrentMin, nCurrentMax}) end
                            end
                            function tSliderFunctions:GetValue() return {nCurrentMin, nCurrentMax} end
                            
                            local nMinScale = (nCurrentMin - tProps.Min) / (tProps.Max - tProps.Min); local nMaxScale = (nCurrentMax - tProps.Min) / (tProps.Max - tProps.Min)
                            oSliderFill.Position = UDim2.new(nMinScale, 0, 0, 0); oSliderFill.Size = UDim2.new(nMaxScale - nMinScale, 0, 1, 0)
                        else
                            local nZeroValue = tProps.ZeroValue or tProps.Min
                            local nCurrentValue = tProps.Default or nZeroValue
                            local nZeroScale = (nZeroValue - tProps.Min) / (tProps.Max - tProps.Min)
                            oValueLabel.Text = `{sPrefix}{string.format(sFormat, nCurrentValue)}{sSuffix}`

                            oSliderBg.InputBegan:Connect(function(oInput)
                                if oInput.UserInputType == Enum.UserInputType.MouseButton1 or oInput.UserInputType == Enum.UserInputType.Touch then 
                                    local function update(inputVec)
                                        local nPos = math.clamp((inputVec.X - oSliderBg.AbsolutePosition.X) / oSliderBg.AbsoluteSize.X, 0, 1)
                                        local nRaw = (nPos * (tProps.Max - tProps.Min)) + tProps.Min
                                        local nVal = math.floor(nRaw * nMult + 0.5) / nMult
                                        tSliderFunctions:SetValue(nVal)
                                    end
                                    update(oInput.Position)
                                    local cMove = oUserInputService.InputChanged:Connect(function(oMove)
                                        if oMove.UserInputType == Enum.UserInputType.MouseMovement or oMove.UserInputType == Enum.UserInputType.Touch then update(oMove.Position) end
                                    end)
                                    local cEnd; cEnd = oUserInputService.InputEnded:Connect(function(oEnd)
                                        if oEnd.UserInputType == Enum.UserInputType.MouseButton1 or oEnd.UserInputType == Enum.UserInputType.Touch then cMove:Disconnect(); cEnd:Disconnect() end
                                    end)
                                end
                            end)
                            
                            function tSliderFunctions:SetValue(nVal)
                                nCurrentValue = math.clamp(math.floor(nVal * nMult + 0.5) / nMult, tProps.Min, tProps.Max)
                                local nPos = (nCurrentValue - tProps.Min) / (tProps.Max - tProps.Min)
                                local nStartScale = math.min(nZeroScale, nPos)
                                local nFillSize = math.abs(nPos - nZeroScale)
                                oTweenService:Create(oSliderFill, fnAnim(0.08), {Position = UDim2.new(nStartScale, 0, 0, 0), Size = UDim2.new(nFillSize, 0, 1, 0)}):Play()
                                oValueLabel.Text = `{sPrefix}{string.format(sFormat, nCurrentValue)}{sSuffix}`
                                if tProps.Callback then tProps.Callback(nCurrentValue) end
                            end
                            function tSliderFunctions:GetValue() return nCurrentValue end

                            local nStartPercent = (nCurrentValue - tProps.Min) / (tProps.Max - tProps.Min)
                            local nInitStart = math.min(nZeroScale, nStartPercent)
                            local nInitSize = math.abs(nStartPercent - nZeroScale)
                            oSliderFill.Position = UDim2.new(nInitStart, 0, 0, 0)
                            oSliderFill.Size = UDim2.new(nInitSize, 0, 1, 0)
                        end
                        if tProps.Flag then tLibrary.Flags[tProps.Flag] = tSliderFunctions end
                        return tSliderFunctions
                    end

                    function tSectionFunctions:Dropdown(tProps)
                        local oDropFrame = fnCreate("Frame", { Parent = oElementsContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), ZIndex = 5 })
                        fnCreate("TextLabel", { Parent = oDropFrame, Text = tProps.Title, FontFace = tConfig.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5 }, {TextColor3 = "TextMain"})
                        
                        local sDefaultText = "Select..."
                        local tSelections = {}
                        if tProps.Multi then if type(tProps.Default) == "table" then tSelections = tProps.Default end; if #tSelections > 0 then sDefaultText = table.concat(tSelections, ", ") end else sDefaultText = tProps.Default or "Select..." end

                        local oMainButton = fnCreate("TextButton", { Parent = oDropFrame, BorderSizePixel = 0, Text = sDefaultText, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = tConfig.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), AutoButtonColor = false, ZIndex = 5 }, {BackgroundColor3 = "ElementBg", TextColor3 = "TextMain"})
                        fnCreate("UIPadding", {Parent = oMainButton, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0, 20)})
                        fnCreate("UIStroke", {Parent = oMainButton, Thickness = 1}, {Color = "Border"})
                        local oChevron = fnCreate("ImageLabel", { Parent = oMainButton, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, 2, 0.5, -7), Image = tConfig.ChevronImage, Rotation = -90 }, {ImageColor3 = "TextMain"})

                        local oDropList = fnCreate("ScrollingFrame", { Parent = oScreenGui, BorderSizePixel = 1, Size = UDim2.new(0.5, 0, 0, 0), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 3000 }, {BackgroundColor3 = "ElementBg", BorderColor3 = "Border"})
                        fnCreate("UIListLayout", {Parent = oDropList})

                        local function fnCloseDrop() oDropList.Visible = false; oTweenService:Create(oChevron, fnAnim(0.2), {Rotation = -90}):Play() end
                        local function fnUpdateDropPos() 
                            if oDropList.Visible and oMainButton.Parent then 
                                local nMaxH = math.min(#tProps.Options * 20, 160)
                                local nY = oMainButton.AbsolutePosition.Y + oMainButton.AbsoluteSize.Y + 2
                                if nY + nMaxH > oScreenGui.AbsoluteSize.Y then nY = oMainButton.AbsolutePosition.Y - nMaxH - 2 end
                                oDropList.Position = UDim2.new(0, oMainButton.AbsolutePosition.X, 0, nY)
                                oDropList.Size = UDim2.new(0, oMainButton.AbsoluteSize.X, 0, nMaxH) 
                            end 
                        end

                        oMainButton.MouseButton1Click:Connect(function()
                            if oDropList.Visible then fnCloseDrop(); tLibrary.ActivePopup = nil else if not tProps.Multi then tLibrary:ClosePopups() end; tLibrary.ActivePopup = {Element = oDropList, Ignore = {oMainButton}, Close = fnCloseDrop}; oDropList.Visible = true; oTweenService:Create(oChevron, fnAnim(0.2), {Rotation = 0}):Play(); fnUpdateDropPos(); local cLoop; cLoop = oRunService.RenderStepped:Connect(function() if not oDropList.Visible then cLoop:Disconnect() else fnUpdateDropPos() end end) end
                        end)
                        
                        local tOptionButtons = {} 
                        local tDropdownFunctions = {}

                        table.insert(tLibrary.DynamicUpdates, function()
                            for _, oBtn in tOptionButtons do
                                if oBtn.Parent then
                                    if tProps.Multi then 
                                        if table.find(tSelections, oBtn.Text) then oBtn.TextColor3 = tConfig.Colors.TextLight else oBtn.TextColor3 = tConfig.Colors.TextMain end 
                                    else 
                                        if oMainButton.Text == oBtn.Text then oBtn.TextColor3 = tConfig.Colors.TextLight else oBtn.TextColor3 = tConfig.Colors.TextMain end 
                                    end
                                end
                            end
                        end)

                        function tDropdownFunctions:SetValue(oVal)
                            if tProps.Multi then
                                tSelections = oVal
                                local sTxt = table.concat(tSelections, ", "); oMainButton.Text = sTxt == "" and "Select..." or sTxt
                                for _, oBtn in tOptionButtons do if table.find(tSelections, oBtn.Text) then oBtn.TextColor3 = tConfig.Colors.TextLight else oBtn.TextColor3 = tConfig.Colors.TextMain end end
                                if tProps.Callback then tProps.Callback(tSelections) end
                            else
                                oMainButton.Text = oVal
                                for _, oBtn in tOptionButtons do if oBtn.Text == oVal then oBtn.TextColor3 = tConfig.Colors.TextLight else oBtn.TextColor3 = tConfig.Colors.TextMain end end
                                if tProps.Callback then tProps.Callback(oVal) end
                            end
                        end
                        function tDropdownFunctions:GetValue() return tProps.Multi and tSelections or oMainButton.Text end

                        local function fnBuildOptions(tNewOpts)
                            for _, oBtn in tOptionButtons do oBtn:Destroy() end
                            table.clear(tOptionButtons)
                            
                            if tProps.Multi then
                                local tNewSelections = {}
                                for _, sSel in tSelections do
                                    if table.find(tNewOpts, sSel) then table.insert(tNewSelections, sSel) end
                                end
                                tDropdownFunctions:SetValue(tNewSelections)
                            else
                                if not table.find(tNewOpts, oMainButton.Text) then
                                    if not table.find(tNewOpts, tProps.Default) then oMainButton.Text = "Select..." else tDropdownFunctions:SetValue(tProps.Default) end
                                else
                                    tDropdownFunctions:SetValue(oMainButton.Text)
                                end
                            end

                            tProps.Options = tNewOpts

                            for _, sOpt in tProps.Options do
                                local oOptBtn = fnCreate("TextButton", { Parent = oDropList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = sOpt, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = tConfig.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3002, AutoButtonColor = false }, {TextColor3 = "TextMain"})
                                fnCreate("UIPadding", {Parent = oOptBtn, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
                                table.insert(tOptionButtons, oOptBtn)
                                
                                local function fnUpdateHighlight()
                                    if tProps.Multi then if table.find(tSelections, sOpt) then oOptBtn.TextColor3 = tConfig.Colors.TextLight else oOptBtn.TextColor3 = tConfig.Colors.TextMain end else if oMainButton.Text == sOpt then oOptBtn.TextColor3 = tConfig.Colors.TextLight else oOptBtn.TextColor3 = tConfig.Colors.TextMain end end
                                end
                                fnUpdateHighlight()

                                oOptBtn.MouseButton1Click:Connect(function()
                                    if tProps.Multi then if table.find(tSelections, sOpt) then table.remove(tSelections, table.find(tSelections, sOpt)) else table.insert(tSelections, sOpt) end; tDropdownFunctions:SetValue(tSelections) else tDropdownFunctions:SetValue(sOpt); fnCloseDrop(); tLibrary.ActivePopup = nil end
                                end)
                            end
                        end
                        
                        function tDropdownFunctions:SetOptions(tNewOpts)
                            fnBuildOptions(tNewOpts)
                        end
                        
                        fnBuildOptions(tProps.Options)
                        
                        if tProps.Flag then tLibrary.Flags[tProps.Flag] = tDropdownFunctions end
                        return tDropdownFunctions
                    end
                    return tSectionFunctions
                end
                return tSubFunctions
            end
            return tCategoryFunctions
        end
        return tTabFunctions
    end
    return tWindowFunctions
end

return tLibrary