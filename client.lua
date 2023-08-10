MenuData = {}
TriggerEvent("redemrp_menu_base:getData", function(call)
    MenuData = call
end)
local DelPrompt
local setCoopPrompt
local prompt, prompt2 = false, false
local myCoop = nil
local myChickens = {}
local eggs = 0
local isFeeding = false
local bucket = nil
local feedbucket = 's_leatherfeedbucket01x'

RegisterNetEvent("chikens:openMenu")
AddEventHandler("chikens:openMenu", function()
    MenuData.CloseAll()
    local elements = {
        {
            label = "Pegar ovos-" .. eggs,
            value = 'get',
            desc = "pegar",
        },
        {
            label = "Recrutar Galinha",
            value = 'addChicken',
            desc = "adcionar",
        },
        {
            label = "Alimentar",
            value = 'feed',
            desc = "Alimentar",
        },

    }

    local nuifocus = false
    MenuData.Open('default', GetCurrentResourceName(), 'test_menu',
        {
            title    = 'Galinheiro',
            subtext  = 'Ovos e Galinhas',
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            print("v", data.current.value)
            if (data.current.value == 'get') then
                if eggs > 0 then
                    TriggerServerEvent("chikens:getEggs", eggs)
                    eggs = 0
                    menu.close()
                end
            end
            if (data.current.value == 'addChicken') then
                AddChicken()
                menu.close()
            end
            if (data.current.value == 'feed') then
                isFeeding = true
                PromptSetEnabled(setFeedPrompt, true)
                PromptSetVisible(setFeedPrompt, true)
                menu.close()
            end
        end,
        function(data, menu)
            menu.close()
        end, nuifocus)
end)

function SetupSetCampPrompt()
    Citizen.CreateThread(function()
        local str = 'Colocar'
        setCoopPrompt = PromptRegisterBegin()
        PromptSetControlAction(setCoopPrompt, 0x07CE1E61)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(setCoopPrompt, str)
        PromptSetEnabled(setCoopPrompt, false)
        PromptSetVisible(setCoopPrompt, false)
        PromptSetHoldMode(setCoopPrompt, true)
        PromptRegisterEnd(setCoopPrompt)
    end)
end

function SetupSetFeedPrompt()
    Citizen.CreateThread(function()
        local str = 'Alimentar'
        setFeedPrompt = PromptRegisterBegin()
        PromptSetControlAction(setFeedPrompt, 0x07CE1E61)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(setFeedPrompt, str)
        PromptSetEnabled(setFeedPrompt, false)
        PromptSetVisible(setFeedPrompt, false)
        PromptSetHoldMode(setFeedPrompt, true)
        PromptRegisterEnd(setFeedPrompt)
    end)
end

function SetupDelPrompt()
    Citizen.CreateThread(function()
        local str = 'Remove'
        DelPrompt = PromptRegisterBegin()
        PromptSetControlAction(DelPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(DelPrompt, str)
        PromptSetEnabled(DelPrompt, false)
        PromptSetVisible(DelPrompt, false)
        PromptSetHoldMode(DelPrompt, true)
        PromptRegisterEnd(DelPrompt)
    end)
end

function AddChicken()
    local model = "a_c_chicken_01"

    while not HasModelLoaded(GetHashKey(model)) do
        Wait(500)
        modelrequest(GetHashKey(model))
    end
    local npc = CreatePed(GetHashKey(model), myCoop.x + math.random(-2, 2), myCoop.y + 2, myCoop.z, 00, false, false, 0,
        0)
    while not DoesEntityExist(npc) do
        Wait(300)
    end
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityInvincible(npc, true)
    TaskStandStill(npc, -1)
    Wait(100)

    SET_PED_RELATIONSHIP_GROUP_HASH(npc, GetHashKey(model))
    SetEntityCanBeDamagedByRelationshipGroup(npc, false, `PLAYER`)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(model))
    local chikensCount = #myChickens + 1
    myChickens[chikensCount] = { ["objetc"] = npc, ['hunger'] = 60, ['thirst'] = 100 }
end

function SET_PED_RELATIONSHIP_GROUP_HASH(iVar0, iParam0)
    return Citizen.InvokeNative(0xC80A74AC829DDD92, iVar0, _GET_DEFAULT_RELATIONSHIP_GROUP_HASH(iParam0))
end

function _GET_DEFAULT_RELATIONSHIP_GROUP_HASH(iParam0)
    return Citizen.InvokeNative(0x3CC4A718C258BDD0, iParam0);
end

function modelrequest(model)
    Citizen.CreateThread(function()
        RequestModel(model)
    end)
end

local isPlacing = false
RegisterNetEvent('chikens:setcoop')
AddEventHandler('chikens:setcoop', function()
    local myPed = PlayerPedId()
    if isPlacing == false then
        isPlacing = true
        local pHead = GetEntityHeading(myPed)
        local pos = GetEntityCoords(myPed, true)
        local coop = 'p_chickencoopcart01x'
        if not HasModelLoaded(coop) then
            RequestModel(coop)
        end

        while not HasModelLoaded(coop) do
            Citizen.Wait(100)
        end

        local tempObj = CreateObject(coop, pos.x, pos.y, pos.z, true, true, false)
        SetEntityHeading(tempObj, pHead)
        AttachEntityToEntity(tempObj, myPed, 0, 0.0, -1.55, 0.0, 0.0, 00.0, 0.0, true, false, false, false, false)

        while isPlacing do
            Wait(1)
            if prompt == false then
                PromptSetEnabled(setCoopPrompt, true)
                PromptSetVisible(setCoopPrompt, true)
                prompt = true
            end

            if PromptHasHoldModeCompleted(setCoopPrompt) then
                PromptSetEnabled(setCoopPrompt, false)
                PromptSetVisible(setCoopPrompt, false)
                PromptSetEnabled(DelPrompt, false)
                PromptSetVisible(DelPrompt, false)
                prompt = false
                prompt2 = false
                local pPos = GetEntityCoords(tempObj, true)
                DeleteObject(tempObj)
                TaskTurnPedToFaceCoord(myPed, pPos.x, pPos.y, pPos.z, 2000)
                Citizen.Wait(3000)
                local coopObject = CreateObject(coop, pPos.x, pPos.y, pPos.z, true, true, false)
                myCoop = {
                    ['owner'] = myPed,
                    ["coop"] = coopObject,
                    ['x'] = pPos.x,
                    ['y'] = pPos.y,
                    ['z'] = pPos.z,
                    ["chikens"] = nil
                }
                PlaceObjectOnGroundProperly(myCoop.coop)
                SetModelAsNoLongerNeeded(coop)
                break
            end
            if prompt2 == false then
                PromptSetEnabled(DelPrompt, true)
                PromptSetVisible(DelPrompt, true)
                prompt2 = true
            end
            if PromptHasHoldModeCompleted(DelPrompt) then
                PromptSetEnabled(setCoopPrompt, false)
                PromptSetVisible(setCoopPrompt, false)
                PromptSetEnabled(DelPrompt, false)
                PromptSetVisible(DelPrompt, false)
                prompt = false
                prompt2 = false
                DeleteObject(tempObj)
                isPlacing = false
                break
            end
        end
    else
        TriggerEvent("redemrp_notification:start", 'Finish first what you started!', 5)
    end
end)

Citizen.CreateThread(function()
    SetupSetFeedPrompt()
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId(), true)

        if isFeeding then
            if PromptHasHoldModeCompleted(setFeedPrompt) then
                local playerpedid = PlayerPedId()
                local playerCo = GetEntityCoords(playerpedid)
                bucket = CreateObject(feedbucket, playerCo.x, playerCo.y, playerCo.z, true, true, true)
                SetEntityAsMissionEntity(bucket, true, false)
                SetModelAsNoLongerNeeded(feedbucket)
                local boneIndex = GetEntityBoneIndexByName(playerpedid, "SKEL_L_Finger12")
                AttachEntityToEntity(bucket, playerpedid, boneIndex, 0.06, -0.1, -0.13, -0.0, 0.0, 100.0, true, true,
                    false, true, 0, true)
                PromptSetEnabled(setFeedPrompt, false)
                PromptSetVisible(setFeedPrompt, false)
                RequestAnimDict("amb_work@world_human_feed_chickens@male_a@idle_a")
                while (not HasAnimDictLoaded("amb_work@world_human_feed_chickens@male_a@idle_a")) do
                    Citizen.Wait(100)
                end

                TaskPlayAnim(playerpedid, "amb_work@world_human_feed_chickens@male_a@idle_a", "idle_a", 8.0, -8.0, 15000,
                    1, 0, true, 0, false, 0, false)
                exports.redemrp_progressbars:DisplayProgressBar(15000, "Alimentando...", function()
                    Wait(15000)
                end)
                isFeeding = false
                ChickensAddFood()
                DeleteObject(bucket)
                ClearPedTasksImmediately(playerpedid)
            end
        else

        end
    end
end)

function ChickensAddFood()
    if myChickens ~= nil and #myChickens >= 1 then
        for index, value in ipairs(myChickens) do
            value.hunger = value.hunger + 10
        end
    end
end

function ChickensAddHunger()
    if myChickens ~= nil and #myChickens >= 1 then
        for index, value in ipairs(myChickens) do
            value.hunger = value.hunger - 10
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId(), true)
        if myCoop ~= nil then
            if myChickens ~= nil and #myChickens >= 1 then
                if isFeeding then
                    for index, value in ipairs(myChickens) do
                        ClearPedTasks(value.objetc)
                        ClearPedSecondaryTask(value.objetc)
                        --  TaskFollowToOffsetOfEntity(value.objetc, PlayerPedId(), 0.0, -1.5, 0.0, 1.0, -1,5* 100000000, 1, 1, 0, 0, 1)
                        TaskGoToCoordAnyMeans(value.objetc, pos.x, pos.y, pos.z, 2.0, 0, 0, 786603, 1.0)
                    end
                    Wait(500)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId(), true)
        if myCoop ~= nil then
            if myChickens ~= nil and #myChickens >= 1 then
                Wait(30000)
                for index, value in ipairs(myChickens) do
                    if value.hunger > 50 then
                        eggs = eggs + 1
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    SetupSetCampPrompt()
    SetupDelPrompt()
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId(), true)
        if myCoop ~= nil then
            if GetDistanceBetweenCoords(myCoop.x, myCoop.y, myCoop.z, pos.x, pos.y, pos.z, true) < 2.0 then
                DrawText3D(myCoop.x, myCoop.y, myCoop.z, 'Abrir [U]')
                if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0xD8F73058) then
                    TriggerEvent("chikens:openMenu")
                end
            end
        end
    end
end)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str, _x, _y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 52, 52, 52, 190, 0)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if myCoop ~= nil then
            DeleteObject(myCoop.coop)
            for index, value in ipairs(myChickens) do
                DeletePed(value.objetc)
            end
        end
    end
end)
