Citizen.CreateThread(function()
    local player = GetPlayerPed(-1)
    local notifIn = false
    local notifOut = false
    if Config.blip then
        for k, v in pairs(Config.zones) do
            zone = AddBlipForRadius(v.x, v.y, v.z, v.c)
            SetBlipSprite(zone, 9)
            SetBlipAlpha(zone, 100)
            SetBlipColour(zone, 2)
        end
    end

    while true do
        wait = 500
        for k, v in pairs(Config.zones) do
            -- print(wait)
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local pos = Config.zones
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
            if dist <= v.c then
                wait = 0
                if not notifIn then
                    NetworkSetFriendlyFireOption(false)
                    ClearPlayerWantedLevel(PlayerId())
                    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                    notifIn = true
                    notifOut = false
                    if Config.marker then
                        --Le -1.0667 est pour que le marker ce place au ras du sol | 3.0667 = hauteur | 46, 255, 0,= couleur rgba | 155 = opacité
                        DrawMarker(1, v.x, v.y, v.z - 1.0667, 0, 0, 0, 0, 0, 0, v.c * 2 - 1, v.c * 2.0 - 1, 3.0667, 46, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
                    end
                end
            else
                if not notifOut then
                    NetworkSetFriendlyFireOption(true)
                    notifOut = true
                    notifIn = false
                end
                if Config.marker then
                    -- 20 = distance a la quelle s'affiche le marker
                    if dist <= v.c + 20 then
                        wait = 0
                        --Le -1.0667 est pour que le marker ce place au ras du sol | 3.0667 = hauteur | 46, 255, 0,= couleur rgba | 155 = opacité
                        DrawMarker(1, v.x, v.y, v.z - 1.0667, 0, 0, 0, 0, 0, 0, v.c * 2 - 1, v.c * 2.0 - 1, 3.0667, 46, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
                    end
                end
            end
            
            if notifIn then
                SetEntityInvincible(player,true)
                DisableControlAction(2, 37, true) -- désactiver la roue des armes (TAB), quand dans la zone safe
                DisableControlAction(0, 140, true) -- désactiver (R), quand dans la zone safe
                DisablePlayerFiring(player, true) -- Désactive le tir d'une manière ou d'une autre, quand dans la zone safe
                DisableControlAction(0, 106, true) -- Désactiver les commandes de la souris, quand dans la zone safe
                if IsDisabledControlJustPressed(2, 37) then
                    --si TAB est enfoncé, envoyer un message
                    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                    BeginTextCommandThefeedPost('STRING')
                    AddTextComponentSubstringPlayerName('~r~Vous ne pouvez pas sortir d\'arme dans la zone safe.')
                    EndTextCommandThefeedPostTicker(0, 1)
                end
                if IsDisabledControlJustPressed(0, 106) then
                    --si clic gauche est enfoncé, envoyer un message
                    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                    BeginTextCommandThefeedPost('STRING')
                    AddTextComponentSubstringPlayerName('~r~Vous ne pouvez pas frapper dans la zone safe.')
                    EndTextCommandThefeedPostTicker(0, 1)
                end
            end
        end
        Citizen.Wait(wait) -- Ne pas toucher
    end
end)
