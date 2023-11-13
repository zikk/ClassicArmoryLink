local regionName = GetCurrentRegionName():lower()
local realms

if regionName == "eu" then
    realms = EuRealmsList
elseif regionName == "us" then
    realms = UsRealmsList
end

-- Global variable to keep track of the current armory frame
local currentArmoryFrame = nil

function GetRealmSlugByName(realmName)
    for _, realm in ipairs(realms) do
        for _, name in pairs(realm.name) do
            if name == realmName then
                return realm.slug
            end
        end
    end
    -- return nil -- Return nil if no match is found
end

local function CreateArmoryFrame(characterName, realmName)
     -- Close the existing frame if it's open
    if currentArmoryFrame and currentArmoryFrame:IsShown() then
        currentArmoryFrame:Hide()
    end

    local realmSlug = GetRealmSlugByName(realmName)

    -- Generate the URL
    local armoryURL = string.format("https://classic-armory.info/%s/classic/%s/%s", regionName, realmSlug, characterName:lower())

    local armoryFrame = CreateFrame("Frame", "ArmoryFrame", UIParent, "BackdropTemplate")
    armoryFrame:SetPoint("CENTER")
    armoryFrame:SetSize(600, 70)
    armoryFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    armoryFrame:SetMovable(true)
    armoryFrame:EnableMouse(true)
    armoryFrame:RegisterForDrag("LeftButton")
    armoryFrame:SetScript("OnDragStart", armoryFrame.StartMoving)
    armoryFrame:SetScript("OnDragStop", armoryFrame.StopMovingOrSizing)

    -- Create the EditBox within the frame
    local editBox = CreateFrame("EditBox", "ArmoryLinkBox", armoryFrame, "InputBoxTemplate")
    editBox:SetSize(550, 20)
    editBox:SetPoint("CENTER", armoryFrame, "CENTER", 0, 0)
    local armoryURL = armoryURL -- Replace with your desired URL
    editBox:SetText(armoryURL)
    editBox:HighlightText()
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function() armoryFrame:Hide() end)

    -- Create a Close Button
    local closeButton = CreateFrame("Button", "ArmoryCloseButton", armoryFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", armoryFrame, "TOPRIGHT")
    closeButton:SetScript("OnClick", function() armoryFrame:Hide() end)

    currentArmoryFrame = armoryFrame
    return armoryFrame
end

local function CreateArmoryButton(parentFrame, isInspect)
    if not parentFrame then return end -- Guard clause to ensure parentFrame is not nil

    local armoryButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    armoryButton:SetSize(70, 20)
    armoryButton:SetText("Armory")
    armoryButton:SetFrameStrata("HIGH")

    if isInspect then
        armoryButton:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 160, -50)
        armoryButton:Hide() -- Start hidden for Inspect Frame
    else
        armoryButton:SetPoint("TOPRIGHT", parentFrame, "TOPLEFT", 135, -76)
        armoryButton:Hide() -- Start hidden for Character Frame
    end

    local function UpdateButtonVisibility()
        if not isInspect then
            local selectedTab = PanelTemplates_GetSelectedTab(CharacterFrame)
            if selectedTab == 1 then
                armoryButton:Show()
            else
                armoryButton:Hide()
            end
        elseif isInspect then
            local selectedTab = PanelTemplates_GetSelectedTab(InspectFrame)
            if selectedTab == 1 then
                armoryButton:Show()
            else
                armoryButton:Hide()
            end
        end
    end

    if not isInspect then
        hooksecurefunc("CharacterFrameTab_OnClick", UpdateButtonVisibility)
        CharacterFrame:HookScript("OnShow", UpdateButtonVisibility)
    elseif isInspect then
        hooksecurefunc("InspectSwitchTabs", UpdateButtonVisibility)
        InspectFrame:HookScript("OnShow", UpdateButtonVisibility)
    end

    parentFrame:HookScript("OnShow", function() armoryButton:Show() end)
    parentFrame:HookScript("OnHide", function() armoryButton:Hide() end)

    armoryButton:SetScript("OnClick", function()
        local characterName, realmName

        if isInspect then
            characterName, realmName = UnitName("target", true)
        else
            characterName = UnitName("player", true)
        end
        local armoryFrame = CreateArmoryFrame(characterName, realmName or GetRealmName())
        armoryFrame:Show()
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ClassicArmoryLink" then
        CreateArmoryButton(CharacterFrame, false)
    elseif event == "INSPECT_READY" then
        CreateArmoryButton(InspectFrame, true)
    end
end)
