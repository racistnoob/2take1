
if ccloaded then
    menu.notify("Colour Changer already loaded!", "Vehicle Colour Changer", 6, 0x0000FF)
    return
end

local ppid = player.player_id
local cc = {
    features = {},
    colors = {
        primary = {0,0,0},
        secondary = {0,0,0},
        pearlescent = {0,0,0},
        wheel = {0,0,0},
        neon = {0,0,0}
    }
}
cc.features.parent = menu.add_feature("Vehicle Colour Changer", "parent", 0).id
cc.features.colourfix = menu.add_feature("GTA Colour Correction", "toggle", cc.features.parent, function(f)
    if f.on then
        menu.notify("This feature will darken the colours to make them more accurate", "Vehicle Colour Changer")
    end
end)
cc.features.primary = menu.add_feature("Primary", "parent", cc.features.parent).id
cc.features.secondary = menu.add_feature("Secondary", "parent", cc.features.parent).id
cc.features.pearlescent = menu.add_feature("Pearlescent", "parent", cc.features.parent).id
cc.features.wheel = menu.add_feature("Wheel", "parent", cc.features.parent).id
cc.features.misc = menu.add_feature("Miscellaneous", "parent", cc.features.parent).id
cc.features.rgb = menu.add_feature("Rainbow", "parent", cc.features.misc).id
cc.features.dirt = menu.add_feature("Dirt", "parent", cc.features.misc).id
cc.features.neon = menu.add_feature("Neons", "parent", cc.features.rgb).id
cc.features.xenons = menu.add_feature("Headlights", "parent", cc.features.rgb).id

lsccolours = { -- getting these took way too long and made me want to kill myself
    {"#080808"}, {"#0F0F0F"}, {"#1C1E21"}, {"#292C2E"}, {"#5A5E66"}, {"#777C87"}, {"#515459"}, {"#323B47"}, {"#333333"}, {"#1F2226"}, {"#23292E"}, {"#121110"}, {"#050505"}, {"#121212"}, {"#2F3233"}, {"#080808"}, {"#121212"}, {"#202224"}, {"#575961"}, {"#23292E"}, {"#323B47"}, {"#0F1012"}, {"#212121"}, {"#5B5D5E"}, {"#888A99"}, {"#697187"}, {"#3B4654"}, {"#690000"}, {"#8A0B00"}, {"#6B0000"}, {"#611009"}, {"#4A0A0A"}, {"#470E0E"}, {"#380C00"}, {"#26030B"}, {"#630012"}, {"#802800"}, {"#6E4F2D"}, {"#BD4800"}, {"#780000"}, {"#360000"}, {"#AB3F00"}, {"#DE7E00"}, {"#520000"}, {"#8C0404"}, {"#4A1000"}, {"#592525"}, {"#754231"}, {"#210804"}, {"#001207"}, {"#001A0B"}, {"#00211E"}, {"#1F261E"}, {"#003805"}, {"#0B4145"}, {"#418503"}, {"#0F1F15"}, {"#023613"}, {"#162419"}, {"#2A3625"}, {"#455C56"}, {"#000D14"}, {"#001029"}, {"#1C2F4F"}, {"#001B57"}, {"#3B4E78"}, {"#272D3B"}, {"#95B2DB"}, {"#3E627A"}, {"#1C3140"}, {"#0055C4"}, {"#1A182E"}, {"#161629"}, {"#0E316D"}, {"#395A83"}, {"#09142E"}, {"#0F1021"}, {"#152A52"}, {"#324654"}, {"#152563"}, {"#223BA1"}, {"#1F1FA1"}, {"#030E2E"}, {"#0F1E73"}, {"#001C32"}, {"#2A3754"}, {"#303C5E"}, {"#3B6796"}, {"#F5890F"}, {"#D9A600"}, {"#4A341B"}, {"#A2A827"}, {"#568F00"}, {"#57514B"}, {"#291B06"}, {"#262117"}, {"#120D07"}, {"#332111"}, {"#3D3023"}, {"#5E5343"}, {"#37382B"}, {"#221918"}, {"#575036"}, {"#241309"}, {"#3B1700"}, {"#6E6246"}, {"#998D73"}, {"#CFC0A5"}, {"#1F1709"}, {"#3D311D"}, {"#665847"}, {"#F0F0F0"}, {"#B3B9C9"}, {"#615F55"}, {"#241E1A"}, {"#171413"}, {"#3B372F"}, {"#3B4045"}, {"#1A1E21"}, {"#5E646B"}, {"#000000"}, {"#B0B0B0"}, {"#999999"}, {"#B56519"}, {"#C45C33"}, {"#47783C"}, {"#BA8425"}, {"#2A77A1"}, {"#243022"}, {"#6B5F54"}, {"#C96E34"}, {"#D9D9D9"}, {"#F0F0F0"}, {"#3F4228"}, {"#FFFFFF"}, {"#B01259"}, {"#8F2F55"}, {"#F69799"}, {"#8F2F55"}, {"#C26610"}, {"#69BD45"}, {"#00AEEF"}, {"#000108"}, {"#080000"}, {"#565751"}, {"#320642"}, {"#00080F"}, {"#080808"}, {"#320642"}, {"#050008"}, {"#6B0B00"}, {"#121710"}, {"#323325"}, {"#3B352D"}, {"#706656"}, {"#2B302B"}, {"#414347"}, {"#6690B5"}, {"#47391B"}, {"#47391B", "#FFD859"}
}

local function reqCtrl(ent)
    local check_time = utils.time_ms() + 1000
    network.request_control_of_entity(ent)
    while not network.has_control_of_entity(ent) and entity.is_an_entity(ent) and check_time > utils.time_ms() do
        system.yield(0)
    end
    return network.has_control_of_entity(ent)
end

local function RGBAToInt(R, G, B)
    return ((R&255)<<0)|((G&255)<<8)|((B&255)<<0x10)|((255&255)<<24)
end

local function HexToRGB(hexArg)
    hexArg = hexArg:gsub('#','')
    if(string.len(hexArg) == 3) then
        return tonumber('0x'..hexArg:sub(1,1)) * 17, tonumber('0x'..hexArg:sub(2,2)) * 17, tonumber('0x'..hexArg:sub(3,3)) * 17
    elseif(string.len(hexArg) == 6) then
        return tonumber('0x'..hexArg:sub(1,2)), tonumber('0x'..hexArg:sub(3,4)), tonumber('0x'..hexArg:sub(5,6))
    else
        return 0, 0, 0
    end
end

local function RainbowRGB(speed)
    speed = speed * 0.25
    local result = {}
    local d = utils.time_ms() / 1000
    result.r = math.floor(math.sin(d*speed+0)*127+128)
    result.g = math.floor(math.sin(d*speed+2)*127+128)
    result.b = math.floor(math.sin(d*speed+4)*127+128)
    return ((result.r&255)<<0)|((result.g&255)<<8)|((result.b&255)<<0x10)|((255&255)<<24) -- returns RGB as Int
end

local function RGBToHex(r,g,b)
    return string.format("#%02X%02X%02X", b, g, r)
end

local conversionValues = {a = 24, b = 16, g = 8, r = 0}
local function IntToRGBA(...)
    local int, val1, val2, val3, val4 = ...
    local values = {val1, val2, val3, val4}
    for k, v in pairs(values) do
        values[k] = int >> conversionValues[v] & 0xff
    end
    return table.unpack(values)
end

local function getVehRGB(veh,type)
    local funcs = {
        vehicle.get_vehicle_custom_primary_colour,
        vehicle.get_vehicle_custom_secondary_colour,
        vehicle.get_vehicle_custom_pearlescent_colour,
        vehicle.get_vehicle_custom_wheel_colour,
        vehicle.get_vehicle_neon_lights_color
    }
    if type == 1 and not vehicle.is_vehicle_primary_colour_custom(veh) then
        local r, g, b = HexToRGB(lsccolours[vehicle.get_vehicle_primary_color(veh)+1][1])
        return tonumber(b), tonumber(g), tonumber(r)
    elseif type == 2 and not vehicle.is_vehicle_secondary_colour_custom(veh) then
        local r, g, b = HexToRGB(lsccolours[vehicle.get_vehicle_secondary_color(veh)+1][1])
        return tonumber(b), tonumber(g), tonumber(r)
    else
        return IntToRGBA(funcs[type](veh), "r", "g", "b")
    end
end

local function getRGBInput(type)
    colorlist = {
        cc.colors.primary,
        cc.colors.secondary,
        cc.colors.pearlescent,
        cc.colors.wheel,
        cc.colors.neon
    }
    local r, s
    repeat
        r,s = input.get("Enter R, G, B ("..colorlist[type][1]..", "..colorlist[type][2]..", "..colorlist[type][3]..")", "", 13, 0)
        if r == 2 then
            menu.notify("Cancelled", "Vehicle Colour Changer")
            return false
        end
        system.wait(0)
    until r == 0
    local parts = {}
    for token in s:gmatch("[^,]+") do
        local num = tonumber(token)
        if not num or num < 0 or num > 255 then
            menu.notify("Invalid RGB format", "Vehicle Colour Changer")
            return false
        end
        parts[#parts + 1] = num
    end
    if #parts ~= 3 then
        menu.notify("Invalid RGB format", "Vehicle Colour Changer")
        return false
    end
    if cc.features.colourfix.on then
        for i=1,3 do
            parts[i] = math.floor(parts[i]*(1-0.6))
        end
    end
    return tonumber(parts[3]), tonumber(parts[2]), tonumber(parts[1])
end

local function getHEXInput()
    local r, s
    repeat
        r,s = input.get("Enter HEX", "", 7, 0)
        if r == 2 then
            if r == 2 then menu.notify("Cancelled", "Vehicle Colour Changer") return false end
        end
        system.wait(0)
    until r == 0
    if s == (nil or "") then
        menu.notify("Invalid HEX format", "Vehicle Colour Changer")
        return false
    end
    s = s:gsub(" ","")
    s = s:lower()
    local r, g, b = HexToRGB(s)
    if r ~= nil then
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        if cc.features.colourfix.on then
            return math.floor(b*(1-0.6)), math.floor(g*(1-0.6)), math.floor(r*(1-0.6))
        end
        return b, g, r
    else
        menu.notify("Invalid HEX format", "Vehicle Colour Changer")
        return false
    end
end

-- dont look below this -- it is a fucking eyesore

menu.create_thread(function()
    -- Primary
    menu.add_feature("Set HEX value", "action", cc.features.primary, function()
        pcall(function()
            cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1] = getVehRGB(player.get_player_vehicle(ppid()),1)
            cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1] = getHEXInput()
            if RGBToHex(cc.colors.primary[3],cc.colors.primary[2],cc.colors.primary[1]) ~= false then
                menu.notify("Set primary HEX to:\n"..RGBToHex(cc.colors.primary[3],cc.colors.primary[2],cc.colors.primary[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", cc.features.primary, function()
        pcall(function()
            cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1] = getVehRGB(player.get_player_vehicle(ppid()),1)
            cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1] = getRGBInput(1)
            menu.notify("Set primary RGB to:\n"..cc.colors.primary[1]..", "..cc.colors.primary[2]..", "..cc.colors.primary[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply primary colour", "action", cc.features.primary, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(ppid())
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end
        vehicle.set_vehicle_custom_primary_colour(veh, RGBAToInt(cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1]))
        menu.notify("Changed primary colour to:\nRGB: "..
                cc.colors.primary[1]..", "..
                cc.colors.primary[2]..", "..
                cc.colors.primary[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),1))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", cc.features.primary, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        cc.colors.primary[3], cc.colors.primary[2], cc.colors.primary[1] = getVehRGB(player.get_player_vehicle(ppid()),1)
        menu.notify("Primary colour values:\nRGB: "..
                cc.colors.primary[1]..", "..
                cc.colors.primary[2]..", "..
                cc.colors.primary[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),1))
        , "Vehicle Colour Changer")
    end)

    -- Secondary
    menu.add_feature("Set HEX value", "action", cc.features.secondary, function()
        pcall(function()
            cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1] = getVehRGB(player.get_player_vehicle(ppid()),2)
            cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1] = getHEXInput()
            if RGBToHex(cc.colors.secondary[3],cc.colors.secondary[2],cc.colors.secondary[1]) ~= false then
                menu.notify("Set secondary HEX to:\n"..RGBToHex(cc.colors.secondary[3],cc.colors.secondary[2],cc.colors.secondary[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", cc.features.secondary, function()
        pcall(function()
            cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1] = getVehRGB(player.get_player_vehicle(ppid()),2)
            cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1] = getRGBInput(2)
            menu.notify("Set secondary RGB to:\n"..cc.colors.secondary[1]..", "..cc.colors.secondary[2]..", "..cc.colors.secondary[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply secondary colour", "action", cc.features.secondary, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(ppid())
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end
        vehicle.set_vehicle_custom_secondary_colour(veh, RGBAToInt(cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1]))
        menu.notify("Changed secondary colour to:\nRGB: "..
                cc.colors.secondary[1]..", "..
                cc.colors.secondary[2]..", "..
                cc.colors.secondary[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),2))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", cc.features.secondary, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        cc.colors.secondary[3], cc.colors.secondary[2], cc.colors.secondary[1] = getVehRGB(player.get_player_vehicle(ppid()),2)
        menu.notify("Secondary colour values:\nRGB: "..
                cc.colors.secondary[1]..", "..
                cc.colors.secondary[2]..", "..
                cc.colors.secondary[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),2))
        , "Vehicle Colour Changer")
    end)
    -- Pearlescent

    menu.add_feature("Set HEX value", "action", cc.features.pearlescent, function()
        pcall(function()
            cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1] = getVehRGB(player.get_player_vehicle(ppid()),3)
            cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1] = getHEXInput()
            if RGBToHex(cc.colors.pearlescent[3],cc.colors.pearlescent[2],cc.colors.pearlescent[1]) ~= false then
                menu.notify("Set pearlescent HEX to:\n"..RGBToHex(cc.colors.pearlescent[3],cc.colors.pearlescent[2],cc.colors.pearlescent[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", cc.features.pearlescent, function()
        pcall(function()
            cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1] = getVehRGB(player.get_player_vehicle(ppid()),3)
            cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1] = getRGBInput(3)
            menu.notify("Set pearlescent RGB to:\n"..cc.colors.pearlescent[1]..", "..cc.colors.pearlescent[2]..", "..cc.colors.pearlescent[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply pearlescent colour", "action", cc.features.pearlescent, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Precise Colour Changer", 6, 0x0000FF)
            return
        end

        local veh = player.get_player_vehicle(ppid())
        if not network.has_control_of_entity(veh) then
            req_control(veh)
        end
        vehicle.set_vehicle_custom_pearlescent_colour(veh, RGBAToInt(cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1]))
        menu.notify("Changed pearlescent colour to:\nRGB: "..
                cc.colors.pearlescent[1]..", "..
                cc.colors.pearlescent[2]..", "..
                cc.colors.pearlescent[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),3))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", cc.features.pearlescent, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        cc.colors.pearlescent[3], cc.colors.pearlescent[2], cc.colors.pearlescent[1] = getVehRGB(player.get_player_vehicle(ppid()),3)
        menu.notify("Pearlescent colour values:\nRGB: "..
                cc.colors.pearlescent[1]..", "..
                cc.colors.pearlescent[2]..", "..
                cc.colors.pearlescent[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),3))
        , "Vehicle Colour Changer")
    end)

    -- Wheel
    menu.add_feature("Set HEX value", "action", cc.features.wheel, function()
        pcall(function()
            cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1] = getVehRGB(player.get_player_vehicle(ppid()),4)
            cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1] = getHEXInput()
            if RGBToHex(cc.colors.wheel[3],cc.colors.wheel[2],cc.colors.wheel[1]) ~= false then
                menu.notify("Set wheel HEX to:\n"..RGBToHex(cc.colors.wheel[3],cc.colors.wheel[2],cc.colors.wheel[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", cc.features.wheel, function()
        pcall(function()
            cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1] = getVehRGB(player.get_player_vehicle(ppid()),4)
            cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1] = getRGBInput(4)
            menu.notify("Set wheel RGB to:\n"..cc.colors.wheel[1]..", "..cc.colors.wheel[2]..", "..cc.colors.wheel[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply wheel colour", "action", cc.features.wheel, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(ppid())
        if not network.has_control_of_entity(veh) then
            req_control(veh)
        end
        vehicle.set_vehicle_custom_wheel_colour(veh, RGBAToInt(cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1]))
        menu.notify("Changed wheel colour to:\nRGB: "..
                cc.colors.wheel[1]..", "..
                cc.colors.wheel[2]..", "..
                cc.colors.wheel[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),4))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", cc.features.wheel, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        cc.colors.wheel[3], cc.colors.wheel[2], cc.colors.wheel[1] = getVehRGB(player.get_player_vehicle(ppid()),4)
        menu.notify("Wheel colour values:\nRGB: "..
                cc.colors.wheel[1]..", "..
                cc.colors.wheel[2]..", "..
                cc.colors.wheel[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),4))
        , "Vehicle Colour Changer")
    end)

    -- Misc

    -- Dirt
    cc.features.dirtlevel = menu.add_feature("Dirt Level", "autoaction_value_i", cc.features.dirt, function(f)
        local veh = player.get_player_vehicle(player.player_id())
        while f.value do
            system.wait(0)
            native.call(0x79D3B596FE44EE8B, veh, f.value+0.0)
        end
    end)
    cc.features.dirtlevel.min = 0.0
    cc.features.dirtlevel.max = 15.0
    cc.features.dirtlevel.mod = 1.0

    menu.add_feature("Auto Clean", "toggle", cc.features.dirt, function(f)
        while f.on do
            system.yield(0)
            local pid = player.player_id()
            if player.is_player_in_any_vehicle(pid) then
                local veh = player.get_player_vehicle(pid)
                if vehicle.get_ped_in_vehicle_seat(veh, -1) == player.get_player_ped(pid) and native.call(0x8F17BC8BA08DA62B, veh):__tonumber() ~= 0.0 then
                    native.call(0x79D3B596FE44EE8B, veh, 0.0)
                end
            end
        end
    end)

    -- Neon
    cc.features.neonenabled = menu.add_feature("Neons enabled", "toggle", cc.features.neon, function(f)
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        for i=0,4 do
            vehicle.set_vehicle_neon_light_enabled(player.get_player_vehicle(player.player_id()), i, f.on)
        end
        if not f.on then
            cc.features.rainbowneon.on = false
        end
    end)

    cc.features.rainbowneon = menu.add_feature("Rainbow Neons                Speed:", "value_i", cc.features.neon, function(f)
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        if f.on then
            cc.features.neonenabled.on = true
        end
        while f.on and cc.features.neonenabled.on do
            if player.is_player_in_any_vehicle(player.player_id()) then
                vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), RainbowRGB(f.value))
            end
            system.yield(0)
        end
        if not f.on or not cc.features.neonenabled.on then
            vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), RGBAToInt(cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1]))
        end
    end)
    cc.features.rainbowneon.min = 1
    cc.features.rainbowneon.max = 20
    cc.features.rainbowneon.mod = 1
    cc.features.rainbowneon.value = 1

    menu.add_feature("Set HEX value", "action", cc.features.neon, function()
        pcall(function()
            cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1] = getVehRGB(player.get_player_vehicle(ppid()),5)
            cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1] = getHEXInput()
            if RGBToHex(cc.colors.neon[3],cc.colors.neon[2],cc.colors.neon[1]) ~= false then
                menu.notify("Set neon HEX to:\n"..RGBToHex(cc.colors.neon[3],cc.colors.neon[2],cc.colors.neon[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", cc.features.neon, function()
        pcall(function()
            cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1] = getVehRGB(player.get_player_vehicle(ppid()),5)
            cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1] = getRGBInput(5)
            menu.notify("Set neon RGB to:\n"..cc.colors.neon[1]..", "..cc.colors.neon[2]..", "..cc.colors.neon[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply neon colour", "action", cc.features.neon, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(ppid())
        if not network.has_control_of_entity(veh) then
            req_control(veh)
        end
        vehicle.set_vehicle_neon_lights_color(veh, RGBAToInt(cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1]))
        menu.notify("Changed neon colour to:\nRGB: "..
                cc.colors.neon[1]..", "..
                cc.colors.neon[2]..", "..
                cc.colors.neon[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),5))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", cc.features.neon, function()
        if not player.is_player_in_any_vehicle(ppid()) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        cc.colors.neon[3], cc.colors.neon[2], cc.colors.neon[1] = getVehRGB(player.get_player_vehicle(ppid()),5)
        menu.notify("Neon colour values:\nRGB: "..
                cc.colors.neon[1]..", "..
                cc.colors.neon[2]..", "..
                cc.colors.neon[3].."\nHEX: "..
                RGBToHex(getVehRGB(player.get_player_vehicle(ppid()),5))
        , "Vehicle Colour Changer")
    end)

    cc.features.rgbxenons = menu.add_feature("Rainbow Xenons", "toggle", cc.features.xenons, function(f)
        local veh = player.get_player_vehicle(player.player_id())
        vehicle.toggle_vehicle_mod(veh, 22, f.on)
        while f.on do
            for i=1,12 do
                if f.on then
                    vehicle.set_vehicle_headlight_color(veh, i)
                    system.wait(350)
                end
            end
            if not f.on then
                vehicle.toggle_vehicle_mod(veh, 22, false)
                vehicle.set_vehicle_headlight_color(veh, 0)
            end
            system.wait(0)
        end
    end)

    menu.add_feature("Xenon Lights", "value_str", cc.features.xenons, function(f)
        local veh = player.get_player_vehicle(player.player_id())
        if f.on and not cc.features.rgbxenons.on then
            vehicle.toggle_vehicle_mod(veh, 22, f.on)
            vehicle.set_vehicle_headlight_color(veh, f.value)
        end
        if not f.on and not cc.features.rgbxenons.on then
            vehicle.toggle_vehicle_mod(veh, 22, false)
        end
    end):set_str_data({"Xenon","White","Blue","Elec Blue","Mint Green","Lime Green","Yellow","Gold","Orange","Red","Pony Pink","Hot Pink","Purple","Blacklight"})
end,nil)

ccloaded = true
