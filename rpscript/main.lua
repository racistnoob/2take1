rpscript = {}
rpscript.seat = {}
rpscript.seat.info = {
    Hashes = {
        -- camping chairs
        { ["hash"] = 291348133 },
        { ["hash"] = 1071807406 },
        { ["hash"] = 3186063286 }
    },
    Animations = {
        { ["dict"] = "timetable@ron@ig_5_p3", ["anim"] = "ig_5_p3_base", ["mult"] = 0.6 },
        { ["dict"] = "timetable@ron@ig_3_couch", ["anim"] = "base", ["mult"] = 0.5 },
        { ["dict"] = "timetable@jimmy@mics3_ig_15@", ["anim"] = "mics3_15_base_tracy", ["mult"] = 0.8 },
    }
}
rpscript.crouch = {}
rpscript.crouch.crouched = false
rpscript.crouch.IsAiming = false
rpscript.crouch.aimCam = false
rpscript.parent = menu.add_feature("RP/FiveM Script", "parent", 0).id

local function loadAnim(dict)
    while (not streaming.has_anim_dict_loaded(dict)) do
        streaming.request_anim_dict(dict)
        system.wait(0)
    end
end

local function updatePlayerInfo()
    rpscript.pid = player.player_id()
    rpscript.ped = player.get_player_ped(rpscript.pid)
end

-- natives
local function ClearPedTasks(Ped)
    return native.call(0xE1EF3C1216AFF2CD, Ped)
end

local function SetCanPedEquipWeapon(Ped, hash, toggle)
    return native.call(0xB4771B9AAF4E68E4, Ped, hash, toggle)
end

local function SetCanPedEquipWeapon(Ped, toggle)
    return native.call(0xEFF296097FF1E509, Ped, toggle)
end

local function CreateCamWithParams(camName, posX, posY, posZ, rotX, rotY, rotZ, fov, active, rotationOrder)
    return native.call(0xB51194800B257161, camName, posX, posY, posZ, rotX, rotY, rotZ, fov, active, rotationOrder):__tointeger64()
end

local function DestroyCam(cam)
    return native.call(0x865908C81A2C22E9, cam)
end

local function GetGameplayCamFov()
    return native.call(0x65019750A0324133):__tonumber()
end

local function SetCamAffectsAiming(cam, toggle)
    return native.call(0x8C1DC7770C51DC8D, cam, toggle)
end

local function RenderScriptCams(render, ease, easeTime, p3, p4)
    return native.call(0x07E5B515DB0636FC, render, ease, easeTime, p3, p4)
end

local function SetCamActive(cam, active)
    return native.call(0x026FB97D0A425F84, cam, active)
end

local function DisableAimCamThisUpdate()
    return native.call(0x1A31FE0049E542F6)
end

local function SetPlayerSimulateAiming(Player, toggle)
    return native.call(0xC54C95DA968EC5B5, Player, toggle)
end

local function SetThirdPersonAimCamNearClipThisUpdate(distance)
    return native.call(0x42156508606DE65E, distance)
end

local function SetPedCanPlayAmbientAnims(Ped, toggle)
    return native.call(0x6373D1349925A70E, Ped, toggle)
end

local function SetPedCanPlayAmbientBaseAnims(Ped, toggle)
    return native.call(0x0EB0585D15254740, Ped, toggle)
end

local function SetPedMovementClipset(Ped, clipSet, transitionSpeed)
    return native.call(0xAF8A94EDE7712BEF, Ped, clipSet, transitionSpeed)
end

local function SetPedStrafeClipset(Ped, clipSet)
    return native.call(0x29A28F3F8CF6D854, Ped, clipSet)
end

local function ResetPedStrafeClipset(Ped)
    return native.call(0x20510814175EA477, Ped)
end

local function EnableCrosshairThisFrame()
    return native.call(0xEA7F0AD7E9BA676F)
end

local function DisplaySniperScopeThisFrame()
    return native.call(0x73115226F4814E62)
end

local function PlaceObjectOnGroundProperly(obj)
    return native.call(0x58A850EAEE20FAA3, obj)
end

local function SetPedUsingActionMode(Ped, p1, p2, action)
    return native.call(0xD75ACCF5E0FB5367, Ped, p1, p2, action)
end

-- weapon animation
local function getWeapon()
    updatePlayerInfo()
    return ped.get_current_ped_weapon(rpscript.ped)
end

local function Equip(bool)
    if not ped.is_ped_in_any_vehicle(rpscript.ped) then
        rpscript.tempWep = rpscript.currentwep
        rpscript.tempWep2 = getWeapon()
        rpscript.blocked = true
        if bool then
            weapon.give_delayed_weapon_to_ped(rpscript.ped, rpscript.tempWep, 2, 1)
            ai.task_play_anim(rpscript.ped, "reaction@intimidation@1h", "intro", 2.0, 2.0, -1, 48, 0, false, false, false)
            system.wait(1250)
            SetCanPedEquipWeapon(rpscript.ped, rpscript.tempWep, false)
            weapon.give_delayed_weapon_to_ped(rpscript.ped, rpscript.tempWep2, 2, 1)
            system.wait(1250)
            ClearPedTasks(rpscript.ped)
        else
            weapon.give_delayed_weapon_to_ped(rpscript.ped, rpscript.tempWep, 2, 1)
            ai.task_play_anim(rpscript.ped, "reaction@intimidation@1h", "outro", 2.0, 2.0, -1, 48, 0, false, false, false)
            system.wait(1500)
            SetCanPedEquipWeapon(rpscript.ped, rpscript.tempWep, false)
            weapon.give_delayed_weapon_to_ped(rpscript.ped, rpscript.tempWep2, 2, 1)
            ClearPedTasks(rpscript.ped)
        end
        system.wait(500)
        rpscript.currentwep = getWeapon()
        rpscript.blocked = false
        SetCanPedEquipWeapon(rpscript.ped, true)
    end
    streaming.remove_anim_dict("reaction@intimidation@1h")
end

-- crouching
rpscript.crouch.aimCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam.get_gameplay_cam_pos(), 0.0, 0.0, 0.0, GetGameplayCamFov(), false, 0)
SetCamAffectsAiming(rpscript.crouch.aimCamera, true)
local function enableaimCam(b)
    if b then
        rpscript.crouch.aimCam = true
        RenderScriptCams(true, true, 500, true, false)
        SetCamActive(rpscript.crouch.aimCamera, true)
    else
        SetPlayerSimulateAiming(rpscript.pid, false)
        SetCamActive(rpscript.crouch.aimCamera, false)
        RenderScriptCams(false, true, 500, true, false)
        rpscript.crouch.aimCam = false
    end
end

local function crouchReset()
    updatePlayerInfo()
    enableaimCam(false)
    controls.disable_control_action(2, 36, true)
    ResetPedStrafeClipset(rpscript.ped)
    streaming.request_anim_set('move_m@JOG@')
    SetPedMovementClipset(rpscript.ped, "move_m@JOG@", 1.0)
    ped.reset_ped_movement_clipset(rpscript.ped, 0.5)
    rpscript.crouch.crouched = false
end

local function Crouch()
    controls.disable_control_action(2, 36, true)
    SetPedCanPlayAmbientAnims(rpscript.ped, false)
    SetPedCanPlayAmbientBaseAnims(rpscript.ped, false)

    SetThirdPersonAimCamNearClipThisUpdate(-10.0)
    streaming.request_anim_set('move_ped_crouched')
    SetPedMovementClipset(rpscript.ped, "move_ped_crouched", 1.0)

    streaming.request_anim_set('move_ped_crouched_strafing')
    SetPedStrafeClipset(rpscript.ped, "move_ped_crouched_strafing")
end

local function CrouchOnTick()
    updatePlayerInfo()
    local crouchKeyPressed = controls.is_control_pressed(2, 36)
    if (crouchKeyPressed) and not player.is_player_in_any_vehicle(rpscript.pid) then
        SetPedUsingActionMode(rpscript.ped, false, -1, 0)
        if not rpscript.crouch.crouched then
            Crouch()
            rpscript.crouch.crouched = true
        else
            crouchReset()
        end
    end
end

local function aimHudThisTick()
    EnableCrosshairThisFrame()
    DisplaySniperScopeThisFrame()
end

-- features
menu.add_feature("Weapon Pull Animation", "toggle", rpscript.parent, function(f)
    rpscript.currentwep = getWeapon()
    while f.on do
        system.wait(0)
        updatePlayerInfo()
        if not entity.is_entity_dead(rpscript.ped) and not player.is_player_in_any_vehicle(rpscript.ped) then
            if rpscript.currentwep ~= getWeapon() then
                loadAnim("reaction@intimidation@1h")
                if getWeapon() ~= 2725352035 then -- equip
                    Equip(true)
                else -- unequip
                    Equip(false)
                end
            end
        end
    end
end)

menu.add_feature("Crouching", "toggle", rpscript.parent, function(f)
    menu.notify("Press CTRL to crouch","RP/FiveM")
    while f.on do
        CrouchOnTick()
        if rpscript.crouch.crouched then
            if controls.get_control_normal(0,25) == 1.0 then
                rpscript.crouch.IsAiming = true
            else
                rpscript.crouch.IsAiming = false
            end
            if player.is_player_free_aiming(rpscript.pid) and rpscript.crouch.IsAiming then
                if not rpscript.crouch.aimCam then
                    enableaimCam(true)
                end
                DisableAimCamThisUpdate()
                SetPlayerSimulateAiming(rpscript.pid, true)
                aimHudThisTick()
                SetThirdPersonAimCamNearClipThisUpdate(-10.0)
            end
        end
        system.yield(0)
    end
    if not f.on then
        updatePlayerInfo()
        crouchReset()
    end
end)

rpscript.seat.feat = menu.add_feature("Seat", "value_i", rpscript.parent, function(f)
    updatePlayerInfo()
    rpscript.thing = rpscript.seat.info.Hashes[f.value]
    seatanim = rpscript.seat.info.Animations[math.random(1,#rpscript.seat.info.Animations)]
    if f.on then
        for i, v in pairs(rpscript.seat.info.Hashes) do
            if v.id then
                entity.delete_entity(v.id)
                v.id = nil
            end
        end

        streaming.request_model(rpscript.thing.hash)
        while not streaming.has_model_loaded(rpscript.thing.hash) do
            system.wait(100)
        end

        rpscript.thing.id = object.create_object(rpscript.thing.hash, v3(0,0,0), true, false)
        entity.set_entity_as_mission_entity(rpscript.thing.id, true, true)
        entity.freeze_entity(rpscript.thing.id, true)
        entity.set_entity_collision(rpscript.thing.id, false, false, true, true)
        ppedcoords = player.get_player_coords(rpscript.pid)
        ppedrot = entity.get_entity_rotation(rpscript.ped)
        ppedrot.z = ppedrot.z - 180
        entity.set_entity_rotation(rpscript.thing.id, ppedrot)
        dir = ppedrot
        dir:transformRotToDir()
        dir = dir * seatanim.mult
        ppedcoords = ppedcoords + dir

        entity.set_entity_coords_no_offset(rpscript.thing.id, ppedcoords)
        PlaceObjectOnGroundProperly(rpscript.thing.id)
        loadAnim(seatanim.dict)
        ai.task_play_anim(rpscript.ped, seatanim.dict, seatanim.anim, 2.0, 2.0, -1, 1, 0, false, false, false)
        streaming.remove_anim_dict(seatanim.dict)
        entity.freeze_entity(rpscript.ped, true)
    end
    if not f.on then
        for i, v in pairs(rpscript.seat.info.Hashes) do
            if v.id then
                entity.delete_entity(v.id)
                v.id = nil
            end
        end
        entity.freeze_entity(rpscript.ped, false)
        ClearPedTasks(rpscript.ped)
    end
end)
rpscript.seat.feat.min, rpscript.seat.feat.max=1, #rpscript.seat.info.Hashes

event.add_event_listener("exit", function()
    if rpscript.crouch.aimCamera ~= nil then
        DestroyCam(rpscript.crouch.aimCamera)
    end
    crouchReset()
end)
