-- Ace Setup
GearUpgradeChart = LibStub("AceAddon-3.0"):NewAddon("GearUpgradeChart", "AceHook-3.0")
AceGUI = LibStub("AceGUI-3.0")

-- Global Variables
GUF = nil
-- Window dimensions
GUF_WIDTH = 550
GUF_HEIGHT = 400
-- Font sizes
GUF_HEADER_FONT_SIZE = 14
GUF_CONTENT_FONT_SIZE = 12
-- Font Colors
GUF_EXPLORER_RGB = {157, 157, 157}
GUF_ADVENTURER_RGB = {255, 255, 255}
GUF_VETERAN_RGB = {30, 255, 0}
GUF_CHAMPION_RGB = {0, 112, 221}
GUF_HERO_RGB = {163, 53, 238}
GUF_MYTH_RGB = {255, 128, 0}
-- Currency IDs
GUF_WEATHERED_ID = 3284
GUF_CARVED_ID = 3286
GUF_RUNED_ID = 3288
GUF_GILDED_ID = 3290


function GearUpgradeChart:OnInitialize()
    self:HookScript(CharacterFrame, "OnShow", "CharacterFrameOnShow")
    self:HookScript(CharacterFrame, "OnHide", "CharacterFrameOnHide")
    hooksecurefunc(CharacterFrame, "SetPoint", GearUpgradeChart.CharacterFrameSetPoint)
end

function GearUpgradeChart:CharacterFrameOnShow(frame)
    if GUF then
        GUF:Show()
        return
    end

    -- Set up the Gear Upgrade Frame
    GUF = AceGUI:Create("Window")
    GUF:SetTitle("Gear Upgrade Chart: TWW Season 3")
    GUF:SetLayout("List")
    GUF:SetWidth(GUF_WIDTH)
    GUF:SetHeight(GUF_HEIGHT)
           
    -- Make window static size
    GUF.frame:IsResizable(false)
    GUF.frame:SetResizeBounds(GUF_WIDTH, GUF_HEIGHT, GUF_WIDTH, GUF_HEIGHT)
    if GUF.sizer_se then
        GUF.sizer_se:Hide()
    end

    GearUpgradeChart:GenerateItemLevels()
    GearUpgradeChart:GenerateMPlusEndChest()
    GearUpgradeChart:GenerateMPlusVault()
    GearUpgradeChart:GenerateDelveRewards()
    GearUpgradeChart:GenerateCurrencies()

    GearUpgradeChart:PositionGUF()

    GUF:Show()
end

function GearUpgradeChart:CharacterFrameOnHide(frame)
    if GUF then
        GUF:Hide()
        GUF:Release()
        GUF = nil
        return
    end
end

function GearUpgradeChart:CharacterFrameSetPoint(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    if GUF then
        GearUpgradeChart:PositionGUF()
    end
end

function GearUpgradeChart:PositionGUF()
    -- Get CharacterFrame details
    local characterFrameBottom = CharacterFrameTab1:GetBottom()
    local characterFrameLeft = CharacterFrame:GetLeft()

    -- Position the Gear Upgrade Frame
    GUF:ClearAllPoints()
    GUF:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", characterFrameLeft, characterFrameBottom)
end

function GearUpgradeChart:GenerateItemLevels()
    -- Set up header row
    local headerContainer = AceGUI:Create("SimpleGroup")
    headerContainer:SetLayout("Flow")
    headerContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("Gear Level")
    h1:SetWidth(100)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")
    headerContainer:AddChild(h1)

    for i = 1, 8, 1 do
        local hn = AceGUI:Create("Label")
        hn:SetText(tostring(i))
        hn:SetWidth(50)
        hn:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")
        headerContainer:AddChild(hn)
    end

    GUF:AddChild(headerContainer)

    -- Set up content rows
    -- TWW Season 3 Explorer and Adventurer are weird and have different upgrade paths
    local gearLevels = {
        {level = "Explorer", ilvls = {98, 99, 100, 101, 102, 103, 104, 105}, rgb = GUF_EXPLORER_RGB },
        {level = "Adventurer", ilvls = {102, 103, 104, 105, 108, 111, 115, 118}, rgb = GUF_ADVENTURER_RGB },
        {level = "Veteran", ilvls = {108, 111, 115, 118, 121, 124, 128, 131}, rgb = GUF_VETERAN_RGB },
        {level = "Champion", ilvls = {121, 124, 128, 131, 134, 137, 141, 144}, rgb = GUF_CHAMPION_RGB },
        {level = "Hero", ilvls = {134, 137, 141, 144, 147, 150, 154, 157}, rgb = GUF_HERO_RGB },
        {level = "Myth", ilvls = {147, 150, 154, 157, 160, 163, 167, 170}, rgb = GUF_MYTH_RGB }
    }

    for _, gearInfo in ipairs(gearLevels) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local levelLabel = AceGUI:Create("Label")
        levelLabel:SetText(gearInfo.level)
        levelLabel:SetWidth(100)
        levelLabel.label:SetTextColor(gearInfo.rgb[1]/255, gearInfo.rgb[2]/255, gearInfo.rgb[3]/255)
        levelLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(levelLabel)

        for _, ilvl in ipairs(gearInfo.ilvls) do
            local ilvlLabel = AceGUI:Create("Label")
            ilvlLabel:SetText(tostring(ilvl))
            ilvlLabel:SetWidth(50)
            ilvlLabel.label:SetTextColor(gearInfo.rgb[1]/255, gearInfo.rgb[2]/255, gearInfo.rgb[3]/255)
            ilvlLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
            rowContainer:AddChild(ilvlLabel)
        end

        GUF:AddChild(rowContainer)
    end
end

function GearUpgradeChart:GenerateMPlusEndChest()
    -- Set up End Chests rows
    local mPlusEndChestHeaderContainer = AceGUI:Create("SimpleGroup")
    mPlusEndChestHeaderContainer:SetLayout("Flow")
    mPlusEndChestHeaderContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("M+ End Chests")
    h1:SetWidth(200)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")

    mPlusEndChestHeaderContainer:AddChild(h1)
    GUF:AddChild(mPlusEndChestHeaderContainer)

    local mPlusEndChestRewards = {
        {name = "Champion", dungeonlevels = {"2-3", "4", "5", "6"}, rgb = GUF_CHAMPION_RGB},
        {name = "Hero", dungeonlevels = {"7-8", "9+"}, rgb = GUF_HERO_RGB}
    }

    for _, chestInfo in ipairs(mPlusEndChestRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local chestLabel = AceGUI:Create("Label")
        chestLabel:SetText(chestInfo.name)
        chestLabel:SetWidth(100)
        chestLabel.label:SetTextColor(chestInfo.rgb[1]/255, chestInfo.rgb[2]/255, chestInfo.rgb[3]/255)
        chestLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(chestLabel)

        for _, dungeonlevel in ipairs(chestInfo.dungeonlevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(dungeonlevel)
            dlLabel:SetWidth(50)
            dlLabel.label:SetTextColor(chestInfo.rgb[1]/255, chestInfo.rgb[2]/255, chestInfo.rgb[3]/255)
            dlLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
            rowContainer:AddChild(dlLabel)
        end

        GUF:AddChild(rowContainer)
    end
end

function GearUpgradeChart:GenerateMPlusVault()
    -- Set up Vault rows
    local mPlusVaultHeaderContainer = AceGUI:Create("SimpleGroup")
    mPlusVaultHeaderContainer:SetLayout("Flow")
    mPlusVaultHeaderContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("M+ Vaults")
    h1:SetWidth(200)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")

    mPlusVaultHeaderContainer:AddChild(h1)
    GUF:AddChild(mPlusVaultHeaderContainer)

   local mPlusVaultRewards = {
        {name = "Champion", dungeonlevels = {" ", " ", " ", "2"}, rgb = GUF_CHAMPION_RGB},
        {name = "Hero", dungeonlevels = {"3-4", "5-6", "7", "8-9"}, rgb = GUF_HERO_RGB},
        {name = "Myth", dungeonlevels = {"10+"}, rgb = GUF_MYTH_RGB}
    }

    for _, vaultInfo in ipairs(mPlusVaultRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local vaultLabel = AceGUI:Create("Label")
        vaultLabel:SetText(vaultInfo.name)
        vaultLabel:SetWidth(100)
        vaultLabel.label:SetTextColor(vaultInfo.rgb[1]/255, vaultInfo.rgb[2]/255, vaultInfo.rgb[3]/255)
        vaultLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(vaultLabel)

        for _, dungeonlevel in ipairs(vaultInfo.dungeonlevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(dungeonlevel)
            dlLabel:SetWidth(50)
            dlLabel.label:SetTextColor(vaultInfo.rgb[1]/255, vaultInfo.rgb[2]/255, vaultInfo.rgb[3]/255)
            dlLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
            rowContainer:AddChild(dlLabel)
        end

        GUF:AddChild(rowContainer)
    end
end

function GearUpgradeChart:GenerateDelveRewards()
    -- Set up Delve rows
    local delveHeaderContainer = AceGUI:Create("SimpleGroup")
    delveHeaderContainer:SetLayout("Flow")
    delveHeaderContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("Delve Rewards")
    h1:SetWidth(200)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")

    delveHeaderContainer:AddChild(h1)
    GUF:AddChild(delveHeaderContainer)

    local delveRewards = {
        {name = "Veteran", delveLevels ={"1-2", "3"}, rgb = GUF_VETERAN_RGB},
        {name = "Champion", delveLevels ={"4", " ", "5", "6"}, rgb = GUF_CHAMPION_RGB},
        {name = "Hero", delveLevels ={"7", " ", "8"}, rgb = GUF_HERO_RGB}
    }

    for _, delveInfo in ipairs(delveRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local delveLabel = AceGUI:Create("Label")
        delveLabel:SetText(delveInfo.name)
        delveLabel:SetWidth(100)
        delveLabel.label:SetTextColor(delveInfo.rgb[1]/255, delveInfo.rgb[2]/255, delveInfo.rgb[3]/255)
        delveLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(delveLabel)

        for _, delveLevel in ipairs(delveInfo.delveLevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(delveLevel)
            dlLabel:SetWidth(50)
            dlLabel.label:SetTextColor(delveInfo.rgb[1]/255, delveInfo.rgb[2]/255, delveInfo.rgb[3]/255)
            dlLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
            rowContainer:AddChild(dlLabel)
        end

        GUF:AddChild(rowContainer)
    end
end

function GearUpgradeChart:GenerateCurrencies()
    local currencyHeaderContainer = AceGUI:Create("SimpleGroup")
    currencyHeaderContainer:SetLayout("Flow")
    currencyHeaderContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("Currencies")
    h1:SetWidth(200)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")

    currencyHeaderContainer:AddChild(h1)
    GUF:AddChild(currencyHeaderContainer)

    local currencies = {
        {name = "Weathered", id = GUF_WEATHERED_ID},
        {name = "Carved", id = GUF_CARVED_ID},
        {name = "Runed", id = GUF_RUNED_ID},
        {name = "Gilded", id = GUF_GILDED_ID}
    }

    for _, currencyInfo in ipairs(currencies) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local currencyLabel = AceGUI:Create("Label")
        currencyLabel:SetText(currencyInfo.name)
        currencyLabel:SetWidth(100)
        currencyLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(currencyLabel)

        local currencyAmountLabel = AceGUI:Create("Label")
        local currencyInfoData = C_CurrencyInfo.GetCurrencyInfo(currencyInfo.id)

        currencyAmountLabel:SetText(string.format("%d (Earnable: %s)", currencyInfoData.quantity, currencyInfoData.maxQuantity - currencyInfoData.totalEarned >= 0 and tostring(currencyInfoData.maxQuantity - currencyInfoData.totalEarned) or "uncapped"))
        currencyAmountLabel:SetWidth(200)
        currencyAmountLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(currencyAmountLabel)

        GUF:AddChild(rowContainer)
    end

end