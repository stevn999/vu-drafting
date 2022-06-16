local displayText = ''

Citizen.CreateThread(function()
    local function shapetests(veh)
        local int, hit, coords, normal, entity -- declare variables
        hit = false -- set hit to false for later tests
        local maxDistance = Config.DraftingMaxDistance
        local playerVehicleCoords = GetEntityCoords(veh) -- get the vehicle coordinates
        local playerVehicleVelocity = GetEntityVelocity(veh) -- get the vehicle velocity
        local draftPower = 0.0 -- set the draft power to 0 for later tests
        local dir = GetOffsetFromEntityInWorldCoords(veh, 0, 0, 0.5) -- A starting pint for the raycast
        local dir2 = vector3(dir.x + playerVehicleVelocity.x * maxDistance, dir.y + playerVehicleVelocity.y * maxDistance, dir.z + playerVehicleVelocity.z * maxDistance) -- An ending point for the raycast
        local rayHandle = StartShapeTestCapsule(dir.x, dir.y, dir.z, dir2.x, dir2.y, dir2.z, 1.2, 2, veh, 2) -- 1.2 is the radius of the ray
        -- Wait for the shape test to be valid
        repeat
            int, hit, coords, normal, entity = GetShapeTestResult(rayHandle)
        until int ~= 1

        if hit == 1 then -- If the raycast hit something
            local distanceFromCenter = #(coords - GetEntityCoords(veh)) -- Get the distance between the vehicle and the hit point
            local forwardPoint = GetOffsetFromEntityInWorldCoords(veh, 0.0, distanceFromCenter, 0.0) -- A point forward relative to the player's vehicle, and at the distance of the hit point

            if Config.Debug then -- If debug mode is enabled draw debug lines
                DrawLine(dir.x, dir.y, dir.z, dir2.x, dir2.y, dir2.z, 255, 0, 0, 255) -- Draw a red line from the starting point to the ending point
                DrawLine(coords.x, coords.y, coords.z, forwardPoint.x, forwardPoint.y, entityCoords.z, 255, 0, 0, 255) -- Draw a red line from the hit point to the forward point
                DrawLine(playerVehicleCoords.x, playerVehicleCoords.y, playerVehicleCoords.z, forwardPoint.x, forwardPoint.y, entityCoords.z, 255, 0, 0, 255) -- Draw a red line from the player vehicle to the forward point
            end

            if #(coords - playerVehicleCoords) < maxDistance then -- If the hit point is within the drafting distance
                draftPower = #(forwardPoint - coords) -- Draft power is higher if the play's vehicle is better aligned with the draft entity
                return int, hit, coords, normal, entity, draftPower
            end
            entity = 0 -- No idea why this works, disables 'snipe drafting'
        end
        return int, hit, coords, normal, entity, draftPower
    end

    local playerPed = PlayerPedId()
    while true do
        Citizen.Wait(8)

        if IsPedInAnyVehicle(playerPed, false) then -- If the player is in a vehicle
            local veh = GetVehiclePedIsIn(playerPed, false) -- Get the vehicle the player is in
            local vehVel = GetEntityVelocity(veh) -- Get the vehicle's velocity
            local vehAbsVel = #GetEntityVelocity(veh) -- Get the absolute velocity of the vehicle
            local _, hit, _, _, entity, draftPower = shapetests(veh) -- Get the results of the shape test

            if entity ~= 0 and entity then -- If the shape test hit something
                local hitVel = GetEntityVelocity(entity) -- Get the velocity of the hit entity
                local relativeVel = hitVel - vehVel -- Get the relative velocity of the hit entity

                if hit ~= 0 and #relativeVel < vehAbsVel / Config.DraftingMargin and vehAbsVel > (Config.MinDraftingSpeed / 2.23694) then -- If the vehicle is moving faster than the minimum drafting speed and the hit entity is moving faster than the drafting margin
                    local pow = 1 + ((40 / draftPower) or 0) -- Calculate the draft power

                    if pow > 100 then pow = 100.0 end -- Limit the draft power to 100%

                    pow = Round(pow * 10) / 10 -- Round the draft power to one decimal place

                    if Config.Debug then
                        displayText = 'Drafting power: ' .. pow .. '%' -- Display the draft power
                    end

                    ModifyVehicleTopSpeed(veh, pow * Config.DraftingMultiplier) -- Modify the vehicle's top speed

                    Citizen.SetTimeout(1500, function() -- Reset the vehicle's top speed after 1.5 seconds
                        ModifyVehicleTopSpeed(veh, 0.0) -- Reset the vehicle's top speed
                    end)
                end
            end
        end
    end
end)

Citizen.CreateThread(function() -- Display thread
    while true do
        Citizen.Wait(2)
        if Config.Debug then
            DisplayHelpText(displayText)
            SetTextFont(0)
            SetTextProportional(2)
            SetTextScale(0.0, 0.3)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(2, 0, 0, 0, 2505)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentSubstringKeyboardDisplay(displayText)
            DrawText(0.5, 0.5)
        end
    end
end)
