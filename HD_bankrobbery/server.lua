ESX = exports['es_extended']:getSharedObject()

local isBankRobberyActive = false

ESX.RegisterServerCallback('HD_bankrobbery:canRob', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local policeCount = 0

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end

    if policeCount >= Config.RequiredCops and not isBankRobberyActive then
        cb(true)
        isBankRobberyActive = true
    else
        cb(false)
    end
end)

RegisterServerEvent('HD_bankrobbery:notifyPolice')
AddEventHandler('HD_bankrobbery:notifyPolice', function(bank)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            if Config.UseCDDispatch then
                -- cd_dispatch ilmoitus
                TriggerEvent('cd_dispatch:AddNotification', {
                    job_table = {'police'},
                    coords = {x = bank.x, y = bank.y, z = bank.z},
                    title = '022A - Pankkiryöstö',
                    message = 'Pankkiryöstö käynnissä sijainnissa: [' .. bank.x .. ', ' .. bank.y .. ']',
                    flash = 0,
                    unique_id = tostring(math.random(0000000, 9999999)),
                    blip = {
                        sprite = 161,
                        scale = 1.2,
                        colour = 1,
                        flashes = false,
                        text = '022A - Pankkiryöstö',
                        time = (5*60*1000),
                        sound = 1,
                    }
                })
            else
                -- ESX ilmoitus
                TriggerClientEvent('esx:showNotification', xPlayer.source, "Pankkiryöstö käynnissä sijainnissa: [" .. bank.x .. ", " .. bank.y .. ", " .. bank.z .. "]")
            end
        end
    end
end)

ESX.RegisterServerCallback('HD_bankrobbery:reward', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = math.random(Config.MinReward, Config.MaxReward)
    xPlayer.addMoney(reward)
    cb(reward)
    isBankRobberyActive = false
end)
