--********************************************************************************--
--*                                                                              *--
--*                 MFPD-CustomCamera: Bodycam Experience for FiveM             *--
--*                                                                              *--
--********************************************************************************--

local chestCam = nil
local sensitivityX = 0.5 -- Camera horizontal movement sensitivity
local sensitivityY = 0.5 -- Camera vertical movement sensitivity

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

    AttachCamToPedBone(chestCam, playerPed, 31086, -0.04, 0.1, 0.0, true)
    SetCamFov(chestCam, 60.0)
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsCamActive(chestCam) then
            local mouseX, mouseY = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)

            local playerPed = PlayerPedId()
            local heading = GetEntityHeading(playerPed)

            local camHeading = heading - mouseX * sensitivityX
            camHeading = camHeading % 360.0

            local camPitch = GetGameplayCamRelativePitch() + mouseY * sensitivityY
            camPitch = math.max(-80.0, math.min(80.0, camPitch)) 
            SetCamRot(chestCam, camPitch, 0.0, camHeading)
        end
    end
end)
