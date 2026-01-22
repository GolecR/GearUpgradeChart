-- Ace Setup
GearUpgradeChart = LibStub("AceAddon-3.0"):NewAddon("GearUpgradeChart", "AceHook-3.0")
AceGUI = LibStub("AceGUI-3.0")

-- Global Variables
GUF = nil
-- Window dimensions
GUF_WIDTH = 650
GUF_HEIGHT = 350
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

    -- Set up the Gear Upgrade "Frame"
    GUF = AceGUI:Create("Window")
    GUF:SetTitle("Gear Upgrade Chart: TWW Season 3")
    GUF:SetLayout("Fill")
    GUF:SetWidth(GUF_WIDTH)
    GUF:SetHeight(GUF_HEIGHT)

    -- Set up Tabs infrastructre
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")

    tabs:SetTabs({
        {text = "Gear Tiers", value = "gear_tiers"},
        {text = "Rewards", value = "rewards"},
        {text = "Currencies", value = "currencies"}
    })

    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        GearUpgradeChart:DrawTab(container, group)
    end)

    tabs:SelectTab("gear_tiers")

    GUF:AddChild(tabs)
           
    -- Make window static size
    GUF.frame:IsResizable(false)
    GUF.frame:SetResizeBounds(GUF_WIDTH, GUF_HEIGHT, GUF_WIDTH, GUF_HEIGHT)
    if GUF.sizer_se then
        GUF.sizer_se:Hide()
    end
end

function GearUpgradeChart:DrawTab(container, group)
    container:ReleaseChildren()

    if group == "gear_tiers" then
        GearUpgradeChart:GenerateGearTiersTabContent(container)
    elseif group == "rewards" then
        GearUpgradeChart:GenerateRewardsTabContent(container)
    elseif group == "currencies" then
        GearUpgradeChart:GenerateCurrenciesTabContent(container)
    end
end

function GearUpgradeChart:GenerateGearTiersTabContent(container)
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

    container:AddChild(headerContainer)

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

        container:AddChild(rowContainer)
    end    
end

function GearUpgradeChart:GenerateRewardsTabContent(container)
    -- Set up End Chests rows
    local headerContainer = AceGUI:Create("SimpleGroup")
    headerContainer:SetLayout("Flow")
    headerContainer:SetFullWidth(true)

    local headerCells = {{value = "Keystone/Delve Level", width = 150},
                         {value = "M+ End Chest", width = 100},
                         {value = "M+ Crests", width = 100},
                         {value = "M+ Vault", width = 100},
                         {value = "Delve Reward", width = 100}}

    for _, value in ipairs(headerCells) do
        local h1 = AceGUI:Create("Label")
        h1:SetText(value.value)
        h1:SetWidth(value.width)
        h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")
        headerContainer:AddChild(h1)
    end

    container:AddChild(headerContainer)

    local rows = {
        {level = "1", mPlusEndChest = {reward = "Champion 1", rgb = GUF_CHAMPION_RGB}, mPlusVault = {reward = "Champion 4", rgb = GUF_CHAMPION_RGB}, mPlusCrests = {reward = " ", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Veteran 1", rgb = GUF_VETERAN_RGB}},
        {level = "2", mPlusEndChest = {reward = "Champion 2", rgb = GUF_CHAMPION_RGB}, mPlusVault = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "10 Runed", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Veteran 1", rgb = GUF_VETERAN_RGB}},
        {level = "3", mPlusEndChest = {reward = "Champion 2", rgb = GUF_CHAMPION_RGB}, mPlusVault = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "12 Runed ", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Veteran 3", rgb = GUF_VETERAN_RGB}},
        {level = "4", mPlusEndChest = {reward = "Champion 3", rgb = GUF_CHAMPION_RGB}, mPlusVault = {reward = "Hero 2", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "14 Runed", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Champion 1", rgb = GUF_CHAMPION_RGB}},
        {level = "5", mPlusEndChest = {reward = "Champion 4", rgb = GUF_CHAMPION_RGB}, mPlusVault = {reward = "Hero 2", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "16 Runed ", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Champion 3", rgb = GUF_CHAMPION_RGB}},
        {level = "6", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Hero 3", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "18 Runed", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Champion 4", rgb = GUF_CHAMPION_RGB}},
        {level = "7", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Hero 4", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "10 Gilded ", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 1", rgb = GUF_HERO_RGB}},
        {level = "8", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Hero 4", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "12 Gilded", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 3", rgb = GUF_HERO_RGB}},
        {level = "9", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Hero 4", rgb = GUF_HERO_RGB}, mPlusCrests = {reward = "14 Gilded ", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 3", rgb = GUF_HERO_RGB}},
        {level = "10", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Myth 1", rgb = GUF_MYTH_RGB}, mPlusCrests = {reward = "16 Gilded", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 3", rgb = GUF_HERO_RGB}},
        {level = "11", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Myth 1", rgb = GUF_MYTH_RGB}, mPlusCrests = {reward = "18 Gilded", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 3", rgb = GUF_HERO_RGB}},
        {level = "12", mPlusEndChest = {reward = "Hero 1", rgb = GUF_HERO_RGB}, mPlusVault = {reward = "Myth 1", rgb = GUF_MYTH_RGB}, mPlusCrests = {reward = "20 Gilded", rgb = GUF_ADVENTURER_RGB}, delveReward = {reward = "Hero 3", rgb = GUF_HERO_RGB}}
    }

    for _, row in ipairs(rows) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local levelLabel = AceGUI:Create("Label")
        levelLabel:SetText(row.level)
        levelLabel:SetWidth(150)
        levelLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(levelLabel)

        local mPlusEndChestLabel = AceGUI:Create("Label")
        mPlusEndChestLabel:SetText(row.mPlusEndChest.reward)
        mPlusEndChestLabel:SetWidth(100)
        mPlusEndChestLabel.label:SetTextColor(row.mPlusEndChest.rgb[1]/255, row.mPlusEndChest.rgb[2]/255, row.mPlusEndChest.rgb[3]/255)
        mPlusEndChestLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(mPlusEndChestLabel)

        local mPlusCrestsLabel = AceGUI:Create("Label")
        mPlusCrestsLabel:SetText(row.mPlusCrests.reward)
        mPlusCrestsLabel:SetWidth(100)
        mPlusCrestsLabel.label:SetTextColor(row.mPlusCrests.rgb[1]/255, row.mPlusCrests.rgb[2]/255, row.mPlusCrests.rgb[3]/255)
        mPlusCrestsLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(mPlusCrestsLabel)

        local mPlusVaultLabel = AceGUI:Create("Label")
        mPlusVaultLabel:SetText(row.mPlusVault.reward)
        mPlusVaultLabel:SetWidth(100)
        mPlusVaultLabel.label:SetTextColor(row.mPlusVault.rgb[1]/255, row.mPlusVault.rgb[2]/255, row.mPlusVault.rgb[3]/255)
        mPlusVaultLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(mPlusVaultLabel)
        
        local delveRewardLabel = AceGUI:Create("Label")
        delveRewardLabel:SetText(row.delveReward.reward)
        delveRewardLabel:SetWidth(100)
        delveRewardLabel.label:SetTextColor(row.delveReward.rgb[1]/255, row.delveReward.rgb[2]/255, row.delveReward.rgb[3]/255)
        delveRewardLabel:SetFont(GameFontNormal:GetFont(), GUF_CONTENT_FONT_SIZE, "OUTLINE")
        rowContainer:AddChild(delveRewardLabel)

        container:AddChild(rowContainer)
    end
end

function GearUpgradeChart:GenerateCurrenciesTabContent(container)
    local headerContainer = AceGUI:Create("SimpleGroup")
    headerContainer:SetLayout("Flow")
    headerContainer:SetFullWidth(true)

    local h1 = AceGUI:Create("Label")
    h1:SetText("Currencies")
    h1:SetWidth(200)
    h1:SetFont(GameFontNormal:GetFont(), GUF_HEADER_FONT_SIZE, "OUTLINE")

    headerContainer:AddChild(h1)
    container:AddChild(headerContainer)

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

        container:AddChild(rowContainer)   
    end
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