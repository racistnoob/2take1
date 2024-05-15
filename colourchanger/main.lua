local colourChanger = {
    primary = {0,0,0},
    secondary = {0,0,0},
    pearlescent = {0,0,0},
    wheel = {0,0,0},
    neon = {0,0,0},
    tyresmoke = {255,255,255}
}

local saveDir = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\scripts\\Vehicle Colour Changer\\", "")

local parentFeature = menu.add_feature("Vehicle Colour Changer", "parent", 0).id
local colourFix = menu.add_feature("GTA Colour Correction", "toggle", parentFeature, function(f)
    if f.on then
        menu.notify("This feature will darken the colours to make them more accurate", "Vehicle Colour Changer")
    end
end)

local LSCColours = { -- getting these took way too long and made me want to kill myself
    {"#080808"}, {"#0F0F0F"}, {"#1C1E21"}, {"#292C2E"}, {"#5A5E66"}, {"#777C87"}, {"#515459"}, {"#323B47"}, {"#333333"}, {"#1F2226"}, {"#23292E"}, {"#121110"}, {"#050505"}, {"#121212"}, {"#2F3233"}, {"#080808"}, {"#121212"}, {"#202224"}, {"#575961"}, {"#23292E"}, {"#323B47"}, {"#0F1012"}, {"#212121"}, {"#5B5D5E"}, {"#888A99"}, {"#697187"}, {"#3B4654"}, {"#690000"}, {"#8A0B00"}, {"#6B0000"}, {"#611009"}, {"#4A0A0A"}, {"#470E0E"}, {"#380C00"}, {"#26030B"}, {"#630012"}, {"#802800"}, {"#6E4F2D"}, {"#BD4800"}, {"#780000"}, {"#360000"}, {"#AB3F00"}, {"#DE7E00"}, {"#520000"}, {"#8C0404"}, {"#4A1000"}, {"#592525"}, {"#754231"}, {"#210804"}, {"#001207"}, {"#001A0B"}, {"#00211E"}, {"#1F261E"}, {"#003805"}, {"#0B4145"}, {"#418503"}, {"#0F1F15"}, {"#023613"}, {"#162419"}, {"#2A3625"}, {"#455C56"}, {"#000D14"}, {"#001029"}, {"#1C2F4F"}, {"#001B57"}, {"#3B4E78"}, {"#272D3B"}, {"#95B2DB"}, {"#3E627A"}, {"#1C3140"}, {"#0055C4"}, {"#1A182E"}, {"#161629"}, {"#0E316D"}, {"#395A83"}, {"#09142E"}, {"#0F1021"}, {"#152A52"}, {"#324654"}, {"#152563"}, {"#223BA1"}, {"#1F1FA1"}, {"#030E2E"}, {"#0F1E73"}, {"#001C32"}, {"#2A3754"}, {"#303C5E"}, {"#3B6796"}, {"#F5890F"}, {"#D9A600"}, {"#4A341B"}, {"#A2A827"}, {"#568F00"}, {"#57514B"}, {"#291B06"}, {"#262117"}, {"#120D07"}, {"#332111"}, {"#3D3023"}, {"#5E5343"}, {"#37382B"}, {"#221918"}, {"#575036"}, {"#241309"}, {"#3B1700"}, {"#6E6246"}, {"#998D73"}, {"#CFC0A5"}, {"#1F1709"}, {"#3D311D"}, {"#665847"}, {"#F0F0F0"}, {"#B3B9C9"}, {"#615F55"}, {"#241E1A"}, {"#171413"}, {"#3B372F"}, {"#3B4045"}, {"#1A1E21"}, {"#5E646B"}, {"#000000"}, {"#B0B0B0"}, {"#999999"}, {"#B56519"}, {"#C45C33"}, {"#47783C"}, {"#BA8425"}, {"#2A77A1"}, {"#243022"}, {"#6B5F54"}, {"#C96E34"}, {"#D9D9D9"}, {"#F0F0F0"}, {"#3F4228"}, {"#FFFFFF"}, {"#B01259"}, {"#8F2F55"}, {"#F69799"}, {"#8F2F55"}, {"#C26610"}, {"#69BD45"}, {"#00AEEF"}, {"#000108"}, {"#080000"}, {"#565751"}, {"#320642"}, {"#00080F"}, {"#080808"}, {"#320642"}, {"#050008"}, {"#6B0B00"}, {"#121710"}, {"#323325"}, {"#3B352D"}, {"#706656"}, {"#2B302B"}, {"#414347"}, {"#6690B5"}, {"#47391B"}, {"#47391B", "#FFD859"}
}

local function reqCtrl(ent)
    local check_time = utils.time_ms() + 1000
    network.request_control_of_entity(ent)
    while not network.has_control_of_entity(ent) and entity.is_an_entity(ent) and check_time > utils.time_ms() do
        system.wait(0)
    end
    return network.has_control_of_entity(ent)
end

local function RGBAToInt(R, G, B)
    return ((R&255)<<0)|((G&255)<<8)|((B&255)<<0x10)|((255&255)<<24)
end

local function HexToDec(hex)
    return tonumber('0x'..hex) or 0
end

local function HexToRGB(hexArg)
    hexArg = hexArg:gsub('#','')

    if string.len(hexArg) == 3 then
        local r, g, b = hexArg:sub(1,1), hexArg:sub(2,2), hexArg:sub(3,3)
        return HexToDec(r) * 17, HexToDec(g) * 17, HexToDec(b) * 17

    elseif string.len(hexArg) == 6 then
        local r, g, b = hexArg:sub(1,2), hexArg:sub(3,4), hexArg:sub(5,6)
        return HexToDec(r), HexToDec(g), HexToDec(b)

    else
        return 0, 0, 0
    end
end

local function RainbowRGB(speed)
    speed = speed * 0.25 * utils.time_ms() / 1000
    
    local r = math.floor(math.sin(speed) * 127 + 128)
    local g = math.floor(math.sin(speed + 2) * 127 + 128)
    local b = math.floor(math.sin(speed + 4) * 127 + 128)
    
    return r, g, b
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

local function getVehRGB(veh, type)
    local funcs = {
        vehicle.get_vehicle_custom_primary_colour,
        vehicle.get_vehicle_custom_secondary_colour,
        vehicle.get_vehicle_custom_pearlescent_colour,
        vehicle.get_vehicle_custom_wheel_colour,
        vehicle.get_vehicle_neon_lights_color
    }

    if veh ~= nil then
        if type == 1 and not vehicle.is_vehicle_primary_colour_custom(veh) then
            local colorIndex = vehicle.get_vehicle_primary_color(veh) + 1
            local hexColor = LSCColours[colorIndex][1]
            local r, g, b = HexToRGB(hexColor)
            return tonumber(b), tonumber(g), tonumber(r)

        elseif type == 2 and not vehicle.is_vehicle_secondary_colour_custom(veh) then
            local colorIndex = vehicle.get_vehicle_secondary_color(veh) + 1
            local hexColor = LSCColours[colorIndex][1]
            local r, g, b = HexToRGB(hexColor)
            return tonumber(b), tonumber(g), tonumber(r)

        else
            local rgbValues = IntToRGBA(funcs[type](veh), "r", "g", "b")
            return rgbValues
        end
    else
        return
    end
end

local function getRGBInput(type)
    local colorlist = {
        colourChanger.primary,
        colourChanger.secondary,
        colourChanger.pearlescent,
        colourChanger.wheel,
        colourChanger.neon,
        colourChanger.tyresmoke
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

    if colourFix.on then
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
        if colourFix.on then
            return math.floor(b*(1-0.6)), math.floor(g*(1-0.6)), math.floor(r*(1-0.6))
        end
        return b, g, r
    else
        menu.notify("Invalid HEX format", "Vehicle Colour Changer")
        return false
    end
end

menu.add_feature("Paint type: ", "autoaction_value_str", parentFeature, function(f)
    pcall(function() ------- ??? idk probably because im a retard or something
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end 

        local primaryR, primaryG, primaryB = getVehRGB(veh, 1)
        local secondaryR, secondaryG, secondaryB = getVehRGB(veh, 2)

        local ptype = 0
        if f.value == 1 then
            ptype = 12
        elseif f.value == 2 then
            ptype = 118
        elseif f.value == 3 then
            ptype = 120
        end

        vehicle.set_vehicle_colors(veh, ptype, ptype)
        vehicle.set_vehicle_custom_primary_colour(veh, RGBAToInt(primaryR, primaryG, primaryB))
        vehicle.set_vehicle_custom_secondary_colour(veh, RGBAToInt(secondaryR, secondaryG, secondaryB))
    end)
end):set_str_data({"Classic/Metallic","Matte","Metals","Chrome"})

local primaryParent = menu.add_feature("Primary", "parent", parentFeature).id
local secondaryParent = menu.add_feature("Secondary", "parent", parentFeature).id
local pearlescentParent = menu.add_feature("Pearlescent", "parent", parentFeature).id
local wheelParent = menu.add_feature("Wheel", "parent", parentFeature).id
local miscParent = menu.add_feature("Miscellaneous", "parent", parentFeature).id
local savedParent = menu.add_feature("Saved Colours", "parent", parentFeature)

local dirtParent = menu.add_feature("Dirt Options", "parent", miscParent).id

local rgbParent = menu.add_feature("Rainbow Options", "parent", miscParent).id
local neonParent = menu.add_feature("Neons", "parent", rgbParent).id
local headlightsParent = menu.add_feature("Headlights", "parent", rgbParent).id
local smokeParent = menu.add_feature("Tyre Smoke", "parent", rgbParent).id

menu.create_thread(function()

    local function refreshColoursFunc()
        local function saveColour(func, filename)
            local r, s
            if func ~= nil then
                repeat
                    r,s = input.get("Enter colour name", "", 100, 0)
                    if r == 2 then
                        menu.notify("Cancelled", "Vehicle Colour Changer")
                        return false
                    end
                    system.wait(0)
                until r == 0
            else
                s = filename
            end
            
            
            if not utils.dir_exists(saveDir) then
                utils.make_dir(saveDir)
            end
            local file = io.open(saveDir .. "\\".. s.. ".lua", "wb")
            local charS,charE = "   ","\n"
            file:write("return {" .. charE)
            
            for i=1,5 do
                file:write("["..i.."] = {")
                local color3, color2, color1 = getVehRGB(player.get_player_vehicle(player.player_id()),i)
                file:write(color1..", ".. color2..", "..color3.."}")
                if i ~= 5 then
                    file:write(",")
                end
            end

            file:write("}")
            file:close()
            menu.notify("Saved colours " .. s, "Vehicle Colour Changer")
            refreshColoursFunc()
        end

        local savecolours = menu.add_feature("Save current colours", "action", savedParent.id, saveColour)

        local refreshcolours = menu.add_feature("Refresh saved colours", "action", savedParent.id, refreshColoursFunc)

        for _, child in pairs(savedParent.children) do
            if child.id ~= savecolours.id and child.id ~= refreshcolours.id then
                menu.delete_feature(child.id)
            end
        end
    
        local savedColours = utils.get_all_files_in_directory(saveDir, "lua")
        for i=1, #savedColours do
            local fileName = savedColours[i]:gsub("%.lua", "")
            menu.add_feature(fileName, "action_value_str", savedParent.id, function(f)
                -- delete
                if f.value == 2 then
                    print(savedColours[i])
                    io.remove(saveDir .. "\\" .. savedColours[i])
                    refreshColoursFunc()
                    return
                end
    
                if not player.is_player_in_any_vehicle(player.player_id()) then
                    menu.notify("Please enter a vehicle","Vehicle Colour Changer")
                    return
                end
    
                local veh = player.get_player_vehicle(player.player_id())
                if not network.has_control_of_entity(veh) then
                    reqCtrl(veh)
                end

                -- overwrite
                if f.value == 1 then
                    saveColour(nil, fileName)
                end
    
                -- apply
                if f.value == 0 then
                    local colourTable = dofile(saveDir .. "\\"..savedColours[i])
                    colourChanger.primary = colourTable[1]
                    colourChanger.secondary = colourTable[2]
                    colourChanger.pearlescent = colourTable[3]
                    colourChanger.wheel = colourTable[4]
                    colourChanger.neon = colourTable[5]

                    local function convertColor(color)
                        return RGBAToInt(color[3], color[2], color[1])
                    end

                    local primaryColor = convertColor(colourChanger.primary)
                    local secondaryColor = convertColor(colourChanger.secondary)
                    local pearlescentColor = convertColor(colourChanger.pearlescent)
                    local wheelColor = convertColor(colourChanger.wheel)
                    local neonColor = convertColor(colourChanger.neon)

                    vehicle.set_vehicle_custom_primary_colour(veh, primaryColor)
                    vehicle.set_vehicle_custom_secondary_colour(veh, secondaryColor)
                    vehicle.set_vehicle_custom_pearlescent_colour(veh, pearlescentColor)
                    vehicle.set_vehicle_custom_wheel_colour(veh, wheelColor)
                    vehicle.set_vehicle_neon_lights_color(veh, neonColor)
                end
            end):set_str_data({"Apply","Overwrite","Delete"})
        end
    end
    refreshColoursFunc()

    -- Primary

    menu.add_feature("Set HEX value", "action", primaryParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())
            
            colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1] = getVehRGB(veh, 1)
            colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1] = getHEXInput()

            if RGBToHex(colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1]) ~= false then
                menu.notify("Set primary HEX to:\n"..RGBToHex(colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", primaryParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())

            colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1] = getVehRGB(veh, 1)
            colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1] = getRGBInput(1)
            menu.notify("Set primary RGB to:\n"..colourChanger.primary[1]..", "..colourChanger.primary[2]..", "..colourChanger.primary[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply primary colour", "action", primaryParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        local intColour = RGBAToInt(colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1])
        vehicle.set_vehicle_custom_primary_colour(veh, intColour)
        menu.notify("Changed primary colour to:\nRGB: "..
                colourChanger.primary[1]..", "..
                colourChanger.primary[2]..", "..
                colourChanger.primary[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 1))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", primaryParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)

        colourChanger.primary[3], colourChanger.primary[2], colourChanger.primary[1] = getVehRGB(veh, 1)
        menu.notify("Primary colour values:\nRGB: "..
                colourChanger.primary[1]..", "..
                colourChanger.primary[2]..", "..
                colourChanger.primary[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 1))
        , "Vehicle Colour Changer")
    end)

    -- Secondary
    menu.add_feature("Set HEX value", "action", secondaryParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())

            colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1] = getVehRGB(veh, 2)
            colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1] = getHEXInput()
            if RGBToHex(colourChanger.secondary[3],colourChanger.secondary[2],colourChanger.secondary[1]) ~= false then
                menu.notify("Set secondary HEX to:\n"..RGBToHex(colourChanger.secondary[3],colourChanger.secondary[2],colourChanger.secondary[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", secondaryParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())
            colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1] = getVehRGB(veh, 2)
            colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1] = getRGBInput(2)
            menu.notify("Set secondary RGB to:\n"..colourChanger.secondary[1]..", "..colourChanger.secondary[2]..", "..colourChanger.secondary[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply secondary colour", "action", secondaryParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        local intColour = RGBAToInt(colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1])
        vehicle.set_vehicle_custom_secondary_colour(veh, intColour)
        menu.notify("Changed secondary colour to:\nRGB: "..
                colourChanger.secondary[1]..", "..
                colourChanger.secondary[2]..", "..
                colourChanger.secondary[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 2))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", secondaryParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)
        colourChanger.secondary[3], colourChanger.secondary[2], colourChanger.secondary[1] = getVehRGB(veh, 2)
        menu.notify("Secondary colour values:\nRGB: "..
                colourChanger.secondary[1]..", "..
                colourChanger.secondary[2]..", "..
                colourChanger.secondary[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 2))
        , "Vehicle Colour Changer")
    end)
    -- Pearlescent

    menu.add_feature("Set HEX value", "action", pearlescentParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())

            colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1] = getVehRGB(veh, 3)
            colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1] = getHEXInput()
            
            if RGBToHex(colourChanger.pearlescent[3],colourChanger.pearlescent[2],colourChanger.pearlescent[1]) ~= false then
                menu.notify("Set pearlescent HEX to:\n"..RGBToHex(colourChanger.pearlescent[3],colourChanger.pearlescent[2],colourChanger.pearlescent[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", pearlescentParent, function()
        pcall(function()
            colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1] = getVehRGB(veh, 3)
            colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1] = getRGBInput(3)
            
            menu.notify("Set pearlescent RGB to:\n"..colourChanger.pearlescent[1]..", "..colourChanger.pearlescent[2]..", "..colourChanger.pearlescent[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply pearlescent colour", "action", pearlescentParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end
        
        vehicle.set_vehicle_custom_pearlescent_colour(veh, RGBAToInt(colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1]))
        menu.notify("Changed pearlescent colour to:\nRGB: "..
                colourChanger.pearlescent[1]..", "..
                colourChanger.pearlescent[2]..", "..
                colourChanger.pearlescent[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 3))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", pearlescentParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)

        colourChanger.pearlescent[3], colourChanger.pearlescent[2], colourChanger.pearlescent[1] = getVehRGB(veh, 3)
        menu.notify("Pearlescent colour values:\nRGB: "..
                colourChanger.pearlescent[1]..", "..
                colourChanger.pearlescent[2]..", "..
                colourChanger.pearlescent[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 3))
        , "Vehicle Colour Changer")
    end)

    -- Wheel
    menu.add_feature("Set HEX value", "action", wheelParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())

            colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1] = getVehRGB(veh, 4)
            colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1] = getHEXInput()
            if RGBToHex(colourChanger.wheel[3],colourChanger.wheel[2],colourChanger.wheel[1]) ~= false then
                menu.notify("Set wheel HEX to:\n"..RGBToHex(colourChanger.wheel[3],colourChanger.wheel[2],colourChanger.wheel[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", wheelParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())

            colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1] = getVehRGB(veh, 4)
            colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1] = getRGBInput(4)
            menu.notify("Set wheel RGB to:\n"..colourChanger.wheel[1]..", "..colourChanger.wheel[2]..", "..colourChanger.wheel[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply wheel colour", "action", wheelParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)
        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        vehicle.set_vehicle_custom_wheel_colour(veh, RGBAToInt(colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1]))
        menu.notify("Changed wheel colour to:\nRGB: "..
                colourChanger.wheel[1]..", "..
                colourChanger.wheel[2]..", "..
                colourChanger.wheel[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 4))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", wheelParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local veh = player.get_player_vehicle(playerID)

        colourChanger.wheel[3], colourChanger.wheel[2], colourChanger.wheel[1] = getVehRGB(veh, 4)
        menu.notify("Wheel colour values:\nRGB: "..
                colourChanger.wheel[1]..", "..
                colourChanger.wheel[2]..", "..
                colourChanger.wheel[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 4))
        , "Vehicle Colour Changer")
    end)

    -- Misc

    -- Dirt
    local function set_vehicle_dirt_level(veh, dirtLevel)
        native.call(0x79D3B596FE44EE8B, veh, dirtLevel)
    end

    local function get_vehicle_dirt_level(veh)
        return native.call(0x8F17BC8BA08DA62B, veh):__tonumber()
    end

    local dirtLevel = menu.add_feature("Dirt Level", "autoaction_value_i", dirtParent, function(f)
        local veh = player.get_player_vehicle(player.player_id())

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        while f.value do
            system.wait(0)
            set_vehicle_dirt_level(veh, f.value+0.0)
        end
    end)
    dirtLevel.min, dirtLevel.max, dirtLevel.mod = 0.0, 15.0, 1.0

    menu.add_feature("Auto Clean", "toggle", dirtParent, function(f)
        while f.on do
            system.wait(0)
            local playerID = player.player_id()
            if player.is_player_in_any_vehicle(playerID) then
                local veh = player.get_player_vehicle(playerID)
                local driverPed = vehicle.get_ped_in_vehicle_seat(veh, -1)
                local playerPed = player.get_player_ped(playerID)

                if driverPed == playerPed and get_vehicle_dirt_level(veh) ~= 0.0 then
                    set_vehicle_dirt_level(veh, 0.0)
                end
            end
        end
    end)

    -- Neon
    neonsEnabled = menu.add_feature("Neons enabled", "toggle", neonParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        
        local veh = player.get_player_vehicle(playerID)
        for i=0,4 do
            vehicle.set_vehicle_neon_light_enabled(veh, i, f.on)
        end
        if not f.on then
            rgbNeons.on = false
        end
    end)

    rgbNeons = menu.add_feature("Rainbow Neons                Speed:", "value_i", neonParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if f.on then
            neonsEnabled.on = true
        end
        while f.on and neonsEnabled.on do
            if player.is_player_in_any_vehicle(playerID) then
                vehicle.set_vehicle_neon_lights_color(veh, RGBAToInt(RainbowRGB(f.value)))
            end
            system.wait(0)
        end
        if not f.on or not neonsEnabled.on then
            vehicle.set_vehicle_neon_lights_color(veh, RGBAToInt(colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1]))
        end
    end)
    rgbNeons.min, rgbNeons.max, rgbNeons.mod, rgbNeons.value = 1, 20, 1, 1

    menu.add_feature("Set HEX value", "action", neonParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())
            colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1] = getVehRGB(veh, 5)
            colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1] = getHEXInput()
            if RGBToHex(colourChanger.neon[3],colourChanger.neon[2],colourChanger.neon[1]) ~= false then
                menu.notify("Set neon HEX to:\n"..RGBToHex(colourChanger.neon[3],colourChanger.neon[2],colourChanger.neon[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", neonParent, function()
        pcall(function()
            local veh = player.get_player_vehicle(player.player_id())
            colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1] = getVehRGB(veh, 5)
            colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1] = getRGBInput(5)
            menu.notify("Set neon RGB to:\n"..colourChanger.neon[1]..", "..colourChanger.neon[2]..", "..colourChanger.neon[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply neon colour", "action", neonParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        local intColour = RGBAToInt(colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1])
        vehicle.set_vehicle_neon_lights_color(veh, intColour)
        menu.notify("Changed neon colour to:\nRGB: "..
                colourChanger.neon[1]..", "..
                colourChanger.neon[2]..", "..
                colourChanger.neon[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 5))
        , "Vehicle Colour Changer")
    end)

    menu.add_feature("Display colour values", "action", neonParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        colourChanger.neon[3], colourChanger.neon[2], colourChanger.neon[1] = getVehRGB(veh, 5)
        menu.notify("Neon colour values:\nRGB: "..
                colourChanger.neon[1]..", "..
                colourChanger.neon[2]..", "..
                colourChanger.neon[3].."\nHEX: "..
                RGBToHex(getVehRGB(veh, 5))
        , "Vehicle Colour Changer")
    end)

    rgbXenons = menu.add_feature("Rainbow Xenons               Delay:", "value_i", headlightsParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        vehicle.toggle_vehicle_mod(veh, 22, f.on)
        while true do
            if not f.on then
                vehicle.toggle_vehicle_mod(veh, 22, false)
                vehicle.set_vehicle_headlight_color(veh, 0)
                break
            end
            while f.on do
                for i = 1, 12 do
                    if f.on then
                        vehicle.set_vehicle_headlight_color(veh, i)
                        system.wait(f.value*100)
                    end
                end
                system.wait(0)
            end
        end
    end)
    rgbXenons.min = 0
    rgbXenons.max = 25
    rgbXenons.mod = 1

    menu.add_feature("Xenon Lights", "value_str", headlightsParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        if f.on and not rgbXenons.on then
            vehicle.toggle_vehicle_mod(veh, 22, f.on)
            vehicle.set_vehicle_headlight_color(veh, f.value)
        end
        if not f.on and not rgbXenons.on then
            vehicle.toggle_vehicle_mod(veh, 22, false)
        end
    end):set_str_data({"Xenon","White","Blue","Elec Blue","Mint Green","Lime Green","Yellow","Gold","Orange","Red","Pony Pink","Hot Pink","Purple","Blacklight"})

    local function set_entity_render_scored(veh, toggle)
        return native.call(0x730F5F8D3F0F2050, veh, toggle)
    end

    menu.add_feature("Render scorched", "toggle", miscParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        if f.on then
            set_entity_render_scored(veh, true)
        end
        if not f.on then
            set_entity_render_scored(veh, false)
        end
    end)

    -- Tyre Smoke
    tyreSmokeEnabled = menu.add_feature("Tyre Smoke enabled", "toggle", smokeParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        if f.on then
            vehicle.set_vehicle_mod(veh, 20, true)
        end
        if not f.on then
            vehicle.toggle_vehicle_mod(veh, 20, false)
            rainbowTyreSmoke.on = false
        end
    end)

    rainbowTyreSmoke = menu.add_feature("Rainbow Tyre Smoke        Speed:", "value_i", smokeParent, function(f)
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        if f.on then
            tyreSmokeEnabled.on = true
        end
        while f.on and tyreSmokeEnabled.on do
            if player.is_player_in_any_vehicle(playerID) then
                vehicle.set_vehicle_tire_smoke_color(veh, RainbowRGB(f.value*2))
            end
            system.wait(0)
        end
        if not f.on or not tyreSmokeEnabled.on then
            vehicle.set_vehicle_tire_smoke_color(veh, colourChanger.tyresmoke[1], colourChanger.tyresmoke[2], colourChanger.tyresmoke[3])
        end
    end)
    rainbowTyreSmoke.min, rainbowTyreSmoke.max, rainbowTyreSmoke.mod, rainbowTyreSmoke.value = 1, 10, 1, 1

    menu.add_feature("Set HEX value", "action", smokeParent, function()
        pcall(function()
            colourChanger.tyresmoke[3], colourChanger.tyresmoke[2], colourChanger.tyresmoke[1] = getHEXInput()
            if RGBToHex(colourChanger.tyresmoke[3],colourChanger.tyresmoke[2],colourChanger.tyresmoke[1]) ~= false then
                menu.notify("Set tyre smoke HEX to:\n"..RGBToHex(colourChanger.tyresmoke[3],colourChanger.tyresmoke[2],colourChanger.tyresmoke[1]), "Vehicle Colour Changer")
            else
                menu.notify("Invalid HEX format", "Vehicle Colour Changer")
            end
        end)
    end)

    menu.add_feature("Set RGB value", "action", smokeParent, function()
        pcall(function()
            colourChanger.tyresmoke[3], colourChanger.tyresmoke[2], colourChanger.tyresmoke[1] = getRGBInput(5)
            menu.notify("Set tyre smoke RGB to:\n"..colourChanger.tyresmoke[1]..", "..colourChanger.tyresmoke[2]..", "..colourChanger.tyresmoke[3], "Vehicle Colour Changer")
        end)
    end)

    menu.add_feature("Apply tyre smoke colour", "action", smokeParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end
        local veh = player.get_player_vehicle(playerID)

        if not network.has_control_of_entity(veh) then
            reqCtrl(veh)
        end

        vehicle.set_vehicle_tire_smoke_color(veh, colourChanger.tyresmoke[1], colourChanger.tyresmoke[2], colourChanger.tyresmoke[3])
        menu.notify("Changed tyre smoke colour to:\nRGB: "..
                colourChanger.tyresmoke[1]..", "..
                colourChanger.tyresmoke[2]..", "..
                colourChanger.tyresmoke[3].."\nHEX: "..
                RGBToHex(colourChanger.tyresmoke[1], colourChanger.tyresmoke[2], colourChanger.tyresmoke[3])
        , "Vehicle Colour Changer")
    end)

    local function get_vehicle_tyre_smoke_color(veh)
        local r = native.ByteBuffer8()
        local g = native.ByteBuffer8()
        local b = native.ByteBuffer8()
        native.call(0xB635392A4938B3C3, veh, r, g, b)
        return r, g, b
    end

    menu.add_feature("Display colour values", "action", smokeParent, function()
        local playerID = player.player_id()
        if not player.is_player_in_any_vehicle(playerID) then
            menu.notify("Please enter a vehicle","Vehicle Colour Changer")
            return
        end

        local r, g, b = get_vehicle_tyre_smoke_color(player.get_player_vehicle(playerID))

        menu.notify("Tyre Smoke colour values:\nRGB: "..
                r..", "..
                g..", "..
                b.."\nHEX: "..
                RGBToHex(r, g, b)
        , "Vehicle Colour Changer")
    end)
end,nil)
