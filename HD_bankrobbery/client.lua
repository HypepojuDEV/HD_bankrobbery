ESX = exports['es_extended']:getSharedObject()
local isRobbing = false
local robTime = Config.RobberyTime
local playerCoords
local bankCoords
local blipRobbery = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        playerCoords = GetEntityCoords(PlayerPedId())
        for _, bank in pairs(Config.Banks) do
            bankCoords = vector3(bank.x, bank.y, bank.z)
            local distance = #(playerCoords - bankCoords)
            if distance < 10.0 and not isRobbing then
                DrawMarker(1, bank.x, bank.y, bank.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 255, 0, 0, 100, false, true, 2, false, false, false, false)
                if distance < 1.0 then
                    ESX.ShowHelpNotification("Paina ~INPUT_CONTEXT~ aloittaaksesi pankkiryöstön")
                    if IsControlJustReleased(0, 38) then
                        ESX.TriggerServerCallback('HD_bankrobbery:canRob', function(canRob)
                            if canRob then
                                StartRobbery(bank)
                            else
                                ESX.ShowNotification("Ei tarpeeksi poliiseja tai ryöstö on jo käynnissä.")
                            end
                        end)
                    end
                end
            end
        end
    end
end)

function StartRobbery(bank)
    isRobbing = true
    ESX.ShowNotification("Aloitit ryöstön, kestää " .. robTime .. " sekuntia.")
    TriggerServerEvent('HD_bankrobbery:notifyPolice', bank)

    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + (robTime * 1000)
        local startCoords = GetEntityCoords(PlayerPedId())
        while GetGameTimer() < endTime do
            Citizen.Wait(0)
            DrawText3D(bank.x, bank.y, bank.z, "Ryöstö käynnissä: " .. math.ceil((endTime - GetGameTimer()) / 1000) .. " sekuntia")
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - startCoords) > 10.0 then
                ESX.ShowNotification("Poistuit ryöstöalueelta, ryöstö epäonnistui.")
                isRobbing = false
                return
            end
        end

        ESX.TriggerServerCallback('HD_bankrobbery:reward', function(reward)
            ESX.ShowNotification("Ryöstö onnistui, ansaitsit €" .. reward)
            isRobbing = false
        end)
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0, 0, 0, 75)
end
