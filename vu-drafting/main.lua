local displayText = ''

Citizen.CreateThread(function()
    local function shapetests(veh)
        local int, hit, coords, normal, entity
        hit = false
        local testDistance = Config.DraftingMaxDistance
        local vehCoords = GetEntityCoords(veh)
        local vehVel = GetEntityVelocity(veh)
        local draftPower = 0.0
        local dir = GetOffsetFromEntityInWorldCoords(veh, 0, 0, 0.5)
        local dir2 = vector3(dir.x + vehVel.x * testDistance, dir.y + vehVel.y * testDistance, dir.z + vehVel.z * testDistance)
        local rayHandle = StartShapeTestCapsule(dir.x, dir.y, dir.z, dir2.x, dir2.y, dir2.z, 1.2, 2, veh, 2)
        repeat
            int, hit, coords, normal, entity = GetShapeTestResult(rayHandle)
            -- Wait(1)
        until int ~= 1
        if hit == 1 then
            -- displayText = int .. hit .. coords .. normal .. entity
            -- DrawLine(dir.x, dir.y, dir.z, dir2.x, dir2.y, dir2.z, 255, 0, 0, 255)
            -- local entityCoords = GetEntityCoords(entity)
            local distance2 = #(coords - GetEntityCoords(veh))
            local toDist = GetOffsetFromEntityInWorldCoords(veh, 0.0, distance2, 0.0)
            -- DrawLine(coords.x, coords.y, coords.z, toDist.x, toDist.y, entityCoords.z, 255, 0, 0, 255)
            -- DrawLine(vehCoords.x, vehCoords.y, vehCoords.z, toDist.x, toDist.y, entityCoords.z, 255, 0, 0, 255)
            if #(coords - vehCoords) < testDistance then
                draftPower = #(toDist - coords)
                -- displayText = 'Drafting: '.. #(coords - vehCoords) ..'/'.. testDistance
                return int, hit, coords, normal, entity, draftPower
            end
            entity = 0
        end

        return int, hit, coords, normal, entity, draftPower
    end

    local playerPed = PlayerPedId()
    while true do
        -- print(GetPlayerServerId(source))
        Citizen.Wait(13)
        -- position
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local vehVel = GetEntityVelocity(veh)
            local vehAbsVel = #GetEntityVelocity(veh)
            local _, hit, _, _, entity, draftPower = shapetests(veh)
            if entity ~= 0 and entity then
                local otherVel = GetEntityVelocity(entity)
                local relativeVel = otherVel - vehVel
                if hit ~= 0 and #relativeVel < vehAbsVel / Config.DraftingMargin and vehAbsVel > (Config.MinDraftingSpeed / 2.23694) then
                    local pow = 1 + ((40 / draftPower) or 0)
                    if pow > 100 then pow = 100.0 end
                    pow = Round(pow * 10) / 10
                    -- displayText = 'Drafting power: ' .. pow .. '%'
                    ModifyVehicleTopSpeed(veh, pow * Config.DraftingMultiplier)
                    SetAirDragMultiplierForPlayersVehicle(playerPed, 0.0)
                    -- SetVehicleCurrentRpm(veh, 1.1)
                    Citizen.SetTimeout(1500, function()
                        ModifyVehicleTopSpeed(veh, 0.0)
                        SetAirDragMultiplierForPlayersVehicle(playerPed, 1.0)
                        -- displayText = 'Drafting power: ' .. 0 .. '%'
                    end)
                else
                    -- ModifyVehicleTopSpeed(veh, 0.0)
                end
            end
        end
    end
end)
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         SetTextFont(0)
--         SetTextProportional(2)
--         SetTextScale(0.0, 0.3)
--         SetTextColour(255, 255, 255, 255)
--         SetTextDropshadow(0, 0, 0, 0, 255)
--         SetTextEdge(2, 0, 0, 0, 2505)
--         SetTextDropShadow()
--         SetTextOutline()
--         SetTextEntry("STRING")
--         -- displayText = dump(#relativeVel) .. ', ' .. dump(#GetEntityVelocity(veh)) .. ', ' .. dump(coords)
--         AddTextComponentSubstringKeyboardDisplay(displayText)
--         DrawText(0.5, 0.5)
--     end
-- end)
