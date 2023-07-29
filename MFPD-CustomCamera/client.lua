--********************************************************************************--
--*                                                                              *--
--*                 MFPD-CustomCamera: Bodycam Experience for FiveM             *--
--*                                                                              *--
--********************************************************************************--

local chestCam = nil
local xOffset, yOffset, zOffset = 0.0, 0.0, -0.5 -- Default offsets
local sensitivityY = 0.1 -- Camera vertical movement sensitivity
local smoothnessFactor = 1.0 -- Adjust the smoothness factor (0.0 to 1.0)

RegisterCommand("bdy", function()
    local playerPed = PlayerPedId()
    local isFirstPerson = IsCamActive(chestCam)

    if not isFirstPerson then
        AttachCameraToChest(playerPed)
    else
        DetachCameraFromChest()
    end
end)

function AttachCameraToChest(playerPed)
    if not DoesCamExist(chestCam) then
        chestCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end

    AttachCamToPedBone(chestCam, playerPed, 31086, 0.0, 0.0, 0.0, true)
    SetCamRot(chestCam, -20.0, 0.0, GetEntityHeading(playerPed))
    SetCamFov(chestCam, 50.0)
    RenderScriptCams(true, false, 1, true, true)
    SetCamActive(chestCam, true)
    SetCamAffectsAiming(chestCam, false)
end

function DetachCameraFromChest()
    if DoesCamExist(chestCam) then
        RenderScriptCams(false, false, 1, true, true)
        SetCamActive(chestCam, false)
        DestroyCam(chestCam, true)
        chestCam = nil
    end
end


function IsCameraClipping(playerPed, cameraPos, armPos)
    local direction = armPos - cameraPos
    local rayHandle = StartShapeTestRay(cameraPos.x, cameraPos.y, cameraPos.z, armPos.x, armPos.y, armPos.z, 10, playerPed, 0)
    local _, _, _, _, result = GetShapeTestResult(rayHandle)
    return result == 1
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsCamActive(chestCam) then
            local playerPed = PlayerPedId()

            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local offsetDistance = 0.8 -- Adjust this value to set the distance of the camera from the player's chest 
            local cameraHeightOffset = -0.1 -- Adjust this value to set the additional height offset for the camera
            local zOffsetModifier = -0.2 -- Adjust this value to set the amount of manual zOffset adjustment (lower value moves the camera down)

            
            local x = coords.x - offsetDistance * math.cos(math.rad(heading))
            local y = coords.y - offsetDistance * math.sin(math.rad(heading))
            local z = coords.z + cameraHeightOffset

            
            local mouseY = GetDisabledControlNormal(0, 2) 
            zOffset = zOffset + mouseY * sensitivityY

            
            zOffset = math.max(-0.6, math.min(0.6, zOffset))

           
            local smoothX = xOffset + (x - xOffset) * smoothnessFactor
            local smoothY = yOffset + (y - yOffset) * smoothnessFactor
            local smoothZ = zOffset + (z - zOffset) * smoothnessFactor

            xOffset, yOffset, zOffset = smoothX, smoothY, smoothZ

            
            local pitchRadians = GetGameplayCamRelativePitch()

           
            local pitchDegrees = math.deg(pitchRadians)

            
            local pitchOffset = 0.5 
            zOffset = zOffset + pitchOffset * math.cos(pitchRadians)

           
            local isAiming = IsPlayerFreeAiming(PlayerId())
            if isAiming then
                zOffset = zOffset - 0.3
                yOffset = yOffset - 0.1
            end

            
            local cameraPos = GetCamCoord(chestCam)
            local leftArmPos = GetWorldPositionOfEntityBone(playerPed, GetPedBoneIndex(playerPed, 28422)) 
            local rightArmPos = GetWorldPositionOfEntityBone(playerPed, GetPedBoneIndex(playerPed, 60309)) 

            local xOffsetModifier = 0.1
            if IsCameraClipping(playerPed, cameraPos, leftArmPos) then
                xOffset = xOffset - xOffsetModifier
            elseif IsCameraClipping(playerPed, cameraPos, rightArmPos) then
                xOffset = xOffset + xOffsetModifier
            end

            
            local pitchOffsetMultiplier = 0.2
            local pitchOffsetModifier = pitchOffsetMultiplier * math.sin(pitchRadians)
            zOffset = zOffset + pitchOffsetModifier

            
            SetCamCoord(chestCam, xOffset, yOffset, z + zOffset + zOffsetModifier) 
            SetCamRot(chestCam, -10.0, 0.0, GetEntityHeading(playerPed)) 
        end
    end
end)