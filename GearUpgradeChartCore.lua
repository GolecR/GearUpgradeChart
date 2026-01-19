-- Ace Setup
GearUpgradeChart = LibStub("AceAddon-3.0"):NewAddon("GearUpgradeChart", "AceHook-3.0")
AceGUI = LibStub("AceGUI-3.0")

-- Global Variables
GUF = nil
GUF_WIDTH = 550
GUF_HEIGHT = 400
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
    headerContainer:AddChild(h1)

    for i = 1, 8, 1 do
        local hn = AceGUI:Create("Label")
        hn:SetText(tostring(i))
        hn:SetWidth(50)
        headerContainer:AddChild(hn)
    end

    GUF:AddChild(headerContainer)

    -- Set up content rows
    -- TWW Season 3 Explorer and Adventurer are weird and have different upgrade paths
    local gearLevels = {
        {level = "Explorer", ilvls = {98, 99, 100, 101, 102, 103, 104, 105} },
        {level = "Adventurer", ilvls = {102, 103, 104, 105, 108, 111, 115, 118} },
        {level = "Veteran", ilvls = {108, 111, 115, 118, 121, 124, 128, 131} },
        {level = "Champion", ilvls = {121, 124, 128, 131, 134, 137, 141, 144} },
        {level = "Hero", ilvls = {134, 137, 141, 144, 147, 150, 154, 157} },
        {level = "Myth", ilvls = {147, 150, 154, 157, 160, 163, 167, 170} }
    }

    for _, gearInfo in ipairs(gearLevels) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local levelLabel = AceGUI:Create("Label")
        levelLabel:SetText(gearInfo.level)
        levelLabel:SetWidth(100)
        rowContainer:AddChild(levelLabel)

        for _, ilvl in ipairs(gearInfo.ilvls) do
            local ilvlLabel = AceGUI:Create("Label")
            ilvlLabel:SetText(tostring(ilvl))
            ilvlLabel:SetWidth(50)
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
    h1:SetWidth(100)

    mPlusEndChestHeaderContainer:AddChild(h1)
    GUF:AddChild(mPlusEndChestHeaderContainer)

    local mPlusEndChestRewards = {
        {name = "Champion", dungeonlevels = {"2-3", "4", "5", "6"}},
        {name = "Hero", dungeonlevels = {"7-8", "9+"}}
    }

    for _, chestInfo in ipairs(mPlusEndChestRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local chestLabel = AceGUI:Create("Label")
        chestLabel:SetText(chestInfo.name)
        chestLabel:SetWidth(100)
        rowContainer:AddChild(chestLabel)

        for _, dungeonlevel in ipairs(chestInfo.dungeonlevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(dungeonlevel)
            dlLabel:SetWidth(50)
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
    h1:SetWidth(100)

    mPlusVaultHeaderContainer:AddChild(h1)
    GUF:AddChild(mPlusVaultHeaderContainer)

   local mPlusVaultRewards = {
        {name = "Champion", dungeonlevels = {" ", " ", " ", "2"}},
        {name = "Hero", dungeonlevels = {"3-4", "5-6", "7", "8-9"}},
        {name = "Myth", dungeonlevels = {"10+"}}
    }

    for _, vaultInfo in ipairs(mPlusVaultRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local vaultLabel = AceGUI:Create("Label")
        vaultLabel:SetText(vaultInfo.name)
        vaultLabel:SetWidth(100)
        rowContainer:AddChild(vaultLabel)

        for _, dungeonlevel in ipairs(vaultInfo.dungeonlevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(dungeonlevel)
            dlLabel:SetWidth(50)
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
    h1:SetWidth(100)

    delveHeaderContainer:AddChild(h1)
    GUF:AddChild(delveHeaderContainer)

    local delveRewards = {
        {name = "Veteran", delveLevels ={"1-2", "3"}},
        {name = "Champion", delveLevels ={"4", " ", "5", "6"}},
        {name = "Hero", delveLevels ={"7", " ", "8"}}
    }

    for _, delveInfo in ipairs(delveRewards) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local delveLabel = AceGUI:Create("Label")
        delveLabel:SetText(delveInfo.name)
        delveLabel:SetWidth(100)
        rowContainer:AddChild(delveLabel)

        for _, delveLevel in ipairs(delveInfo.delveLevels) do
            local dlLabel = AceGUI:Create("Label")
            dlLabel:SetText(delveLevel)
            dlLabel:SetWidth(50)
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
    h1:SetWidth(100)

    currencyHeaderContainer:AddChild(h1)
    GUF:AddChild(currencyHeaderContainer)

    local currencies = {
        {name = "Weathered Crest", id = GUF_WEATHERED_ID},
        {name = "Carved Crest", id = GUF_CARVED_ID},
        {name = "Runed Crest", id = GUF_RUNED_ID},
        {name = "Gilded Crest", id = GUF_GILDED_ID}
    }

    for _, currencyInfo in ipairs(currencies) do
        local rowContainer = AceGUI:Create("SimpleGroup")
        rowContainer:SetLayout("Flow")
        rowContainer:SetFullWidth(true)

        local currencyLabel = AceGUI:Create("Label")
        currencyLabel:SetText(currencyInfo.name)
        currencyLabel:SetWidth(100)
        rowContainer:AddChild(currencyLabel)

        local currencyAmountLabel = AceGUI:Create("Label")
        local currencyInfoData = C_CurrencyInfo.GetCurrencyInfo(currencyInfo.id)

        currencyAmountLabel:SetText(string.format("%d (Earnable: %s)", currencyInfoData.quantity, currencyInfoData.maxQuantity - currencyInfoData.totalEarned >= 0 and tostring(currencyInfoData.maxQuantity - currencyInfoData.totalEarned) or "uncapped"))
        currencyAmountLabel:SetWidth(200)       
        rowContainer:AddChild(currencyAmountLabel)

        GUF:AddChild(rowContainer)
    end

end