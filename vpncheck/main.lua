if not menu.is_trusted_mode_enabled(8) then
    menu.notify("Trusted mode for http not enabled", "VPN/Proxy Check", 10)
    return
end
vpncheck = {}
vpncheck.api = menu.add_feature("VPN/Proxy Check API:", "autoaction_value_str", 0)
vpncheck.api:set_str_data({"proxycheck.io", "ip-api.com"})

function vpncheck.notify(num,str,var)
    if num == 1 then
        menu.notify('Player is using a VPN/Proxy\nVPN: '..(str or "Unknown"), "VPN/Proxy Check")
    elseif num == 2 then
        menu.notify("Player is not using VPN/Proxy", "VPN/Proxy Check")
    elseif num == 3 then
        menu.notify("Invalid IP Address", "VPN/Proxy Check", 4)
    elseif num == 4 then
        if var == 1 then
            menu.notify("Reached maximum limit for today", "VPN/Proxy Check", 4)
        else
            menu.notify("Reached maximum limit of requests in a minute", "VPN/Proxy Check", 4)
        end
    end
end

menu.add_player_feature("VPN/Proxy Check", "action", 0, function(f, pid)
    if player.is_player_valid(pid) then
        if not network.is_session_started() then
            menu.notify("Please join online", "VPN/Proxy Check", 10)
            return
        end
        vpncheck.pIp = player.get_player_ip(pid)
        vpncheck.pIp = string.format("%i.%i.%i.%i", vpncheck.pIp >> 24 & 255, vpncheck.pIp >> 16 & 255, vpncheck.pIp >> 8 & 255, vpncheck.pIp & 255)
        if vpncheck.api.value == 0 then
            statusCode, response = web.get("https://proxycheck.io/v2/"..vpncheck.pIp.."?vpn=1")
            if response:find("ok") then
                if response:find('"proxy": "no"') then
                    vpncheck.notify(2)
                elseif response:find('"proxy": "yes"') then
                    if response:find("name") then
                        vpncheck.notify(1, response:match("\"name\":%s+\"([^\"]+)\","))
                    else
                        vpncheck.notify(1)
                    end
                end
            elseif response:find("error") then
                vpncheck.notify(3)
            elseif response:find("denied") then
                vpncheck.notify(4,nil,1)
            end
        else
            statusCode, response = web.get("http://ip-api.com/json/"..vpncheck.pIp.."?fields=147456")
            if response:find("success") then
                if response:find("true") then
                    vpncheck.notify(1)
                elseif response:find("false") then
                    vpncheck.notify(2)
                end
            elseif response:find("fail") then
                vpncheck.notify(3)
            elseif statusCode == "429" then
                vpncheck.notify(4,nil,2)
            end
        end
    end
end)
