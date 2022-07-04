ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(1000)
    end
end)

function getClosestCoords(_table)
    local zonedist = nil
    local _ClosestCoord = nil
    local playerdist = 1000
    local _playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(_playerPed, true))
    for _, v in pairs(_table) do
        local _Distance = Vdist(v.x, v.y, v.z, x, y, z)
        if _Distance <= playerdist then
            playerdist = _Distance
            _ClosestCoord = v
            zonedist = _
        end
    end
    return zonedist
end

Citizen.CreateThread(function()

    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(1000)
    end

    local interval = 1000
    local player = GetPlayerPed(-1)
    local notifIn = false
    local notifOut = false
    
Citizen.CreateThread(function()
    if Config.blip then
        Citizen.Wait(0)
        for _, v in pairs(Config.zones) do
            zone = AddBlipForRadius(v.x, v.y, v.z, v.c)
            SetBlipSprite(zone, 9)
            SetBlipAlpha(zone, 100)
            SetBlipColour(zone, 2)
        end
    end
end)

    while true do
        local closestZone = getClosestCoords(Config.zones)
        --print('closestZone', closestZone)
        local circonference = Config.zones[closestZone].c
        local x, y, z = table.unpack(GetEntityCoords(player, true))
        local dist = Vdist(Config.zones[closestZone].x, Config.zones[closestZone].y, Config.zones[closestZone].z, x, y, z)

        if dist <= circonference then
            if not notifIn then
                NetworkSetFriendlyFireOption(false)
                ClearPlayerWantedLevel(PlayerId())
                SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                ESX.ShowNotification('~g~Vous êtes dans une zone safe')
                notifIn = true
                notifOut = false
            end
        else
            if not notifOut then
                --print('entrer')
                NetworkSetFriendlyFireOption(true)
                ESX.ShowNotification('~r~Vous êtes sorti de la zone safe') -- si entrer dans la zone safe, envoyer un message
                notifOut = true
                notifIn = false
            end
        end
        if notifIn then
            interval = 0
            SetEntityInvincible(player,true)
            DisableControlAction(2, 37, true) -- désactiver la roue des armes (TAB), quand dans la zone safe
            DisableControlAction(0, 140, true) -- désactiver (R), quand dans la zone safe
            DisablePlayerFiring(player, true) -- Désactive le tir d'une manière ou d'une autre, quand dans la zone safe
            DisableControlAction(0, 106, true) -- Désactiver les commandes de la souris, quand dans la zone safe
            if IsDisabledControlJustPressed(2, 37) then
                --si TAB est enfoncé, envoyer un message
                SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                ESX.ShowNotification('~r~Vous ne pouvez pas sortir d\'arme dans la zone safe.')

            end
            if IsDisabledControlJustPressed(0, 106) then
                --si clic gauche est enfoncé, envoyer un message
                SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                ESX.ShowNotification('~r~Vous ne pouvez pas frapper dans la zone safe.')

            end
        else
            interval = 1000 -- Ne pas toucher
        end
        if dist <= circonference + 20 then
            -- 20 = distance a la quelle s'affiche le marker
            interval = 0
            if Config.marker then
                if DoesEntityExist(player) then
                    --Le -1.0667 est pour que le marker ce place au ras du sol | 3.0667 = hauteur | 46, 255, 0,= couleur rgba | 155 = opacité
                    DrawMarker(1, Config.zones[closestZone].x, Config.zones[closestZone].y, Config.zones[closestZone].z - 1.0667, 0, 0, 0, 0, 0, 0, circonference * 2 - 1, circonference * 2.0 - 1, 3.0667, 46, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
                end
            end
        end
        --end
        --print("interval -> ", interval)
        Citizen.Wait(interval) -- Ne pas toucher antie crash
    end
end)
