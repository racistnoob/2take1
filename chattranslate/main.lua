if not menu.is_trusted_mode_enabled(8) then
    menu.notify("Trusted mode for http not enabled", "VPN/Proxy Check", 10)
    return
end

local function Translate(text) -- credits for this codenz to xXx_Proddy_xXx
    local encoded = web.urlencode(text)
    local statusCode, body = web.get("https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=" .. encoded)
    if not body:find('"en"') then -- if translated from english to english then fuck off
        local translatedText = body:match(".-\"(.-)\",\"")
        return translatedText
    else
        return nil
    end
end

local function dec_to_ipv4(ip) -- credits for this codenz to xXx_Proddy_xXx
    return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
end

local engCountries = {'"US"','"AU"','"CA"','"GB"','"NZ"','"IE"'}
menu.add_feature("translate hack", "toggle", 0, function(f)
    if f.on then
        chatlistener = event.add_event_listener("chat", function(event)
            if player.is_player_valid(event.player) then
                if #event.body > 4 and event.player ~= player.player_id() then
                    local pid = event.player
                    pIp = dec_to_ipv4(player.get_player_ip(pid))
                    statusCode, response = web.get("http://ip-api.com/json/"..pIp.."?fields=49154")
                    if response:find("success") then
                        for i=1, #engCountries do
                            if not response:find(engCountries[i]) then
                                translatedText = Translate(event.body)
                                if translatedText ~= nil then
                                    menu.notify(player.get_player_name(pid)..": "..translatedText, "Google Translate")
                                end
                            end
                        end
                    elseif response:find("fail") then
                        notify("Invalid IP Address")
                    elseif statusCode == "429" then
                        notify("API Ratelimited")
                    end
                end
            end
        end)
        if not f.on then
            event.remove_event_listener("chat", chatlistener)
            chatlistener = nil
        end
    end
end)
