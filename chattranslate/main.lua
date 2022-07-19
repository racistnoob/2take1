if not menu.is_trusted_mode_enabled(8) then
    menu.notify("Trusted mode for http not enabled", "chat translate", 10)
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

menu.add_feature("translate hack", "toggle", 0, function(f)
    if f.on then
        chatlistener = event.add_event_listener("chat", function(event)
            if player.is_player_valid(event.player) then
                if #event.body > 4 and event.player ~= player.player_id() then
                    local pid = event.player
                    statusCode, response = web.get("http://ip-api.com/json/"..pIp.."?fields=49154")
                    translatedText = Translate(event.body)
                    if translatedText ~= nil then
                        menu.notify(player.get_player_name(pid)..": "..translatedText, "Google Translate")
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
