-- Global variable to keep track of the current armory frame
local currentArmoryFrame = nil

local function CreateArmoryFrame(characterFullName, regionName)
     -- Close the existing frame if it's open
    if currentArmoryFrame and currentArmoryFrame:IsShown() then
        currentArmoryFrame:Hide()
    end

    -- Function to convert realm name to a slug
    local function RealmToSlug(realmName)
        return realmName:gsub("%s+", ""):lower() -- Replace spaces with nothing and lowercase
    end

    local characterName, realmName = "unknown", "unknown"

    if characterFullName then
        characterName, realmName = string.match(characterFullName, "^(.+)-(.+)$")
        if not realmName then -- If the character is from the same realm, realmName will be nil
            characterName, realmName = characterFullName, GetRealmName()
        end
    end

    local realmSlug = RealmToSlug(realmName)

    -- Generate the URL
    local armoryURL = string.format("https://classic-armory.info/%s/classic/%s/%s", regionName, realmSlug, characterName:lower())

    local armoryFrame = CreateFrame("Frame", "ArmoryFrame", UIParent, "BackdropTemplate")
    armoryFrame:SetPoint("CENTER")
    armoryFrame:SetSize(300, 100)
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
    editBox:SetSize(260, 20)
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
    armoryButton:SetSize(80, 22)
    armoryButton:SetText("Armory")
    armoryButton:SetFrameStrata("HIGH")

    if isInspect then
        armoryButton:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 160, -50)
    else
        armoryButton:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -90, -80)
    end

    -- Button visibility tied to the parent frame's visibility
    armoryButton:SetShown(parentFrame:IsShown())
    parentFrame:HookScript("OnShow", function() armoryButton:Show() end)
    parentFrame:HookScript("OnHide", function() armoryButton:Hide() end)

    armoryButton:SetScript("OnClick", function()
        local characterFullName, realmName
        local regionName = GetCurrentRegionName():lower()

        if isInspect then
            characterFullName = UnitName("target")
        else
            characterFullName = UnitName("player") .. "-" .. GetRealmName()
        end
        local armoryFrame = CreateArmoryFrame(characterFullName, regionName)
        armoryFrame:Show()
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ArmoryLink" then
        CreateArmoryButton(CharacterFrame, false)
    elseif event == "INSPECT_READY" then
        CreateArmoryButton(InspectFrame, true)
    end
end)
