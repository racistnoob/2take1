menu.add_feature("No Police Helicopters", "toggle", 0, function(f)
    while f.on do
        local vehicles = vehicle.get_all_vehicles()
        for _, VEHICLE in ipairs(vehicles) do
            if entity.get_entity_model_hash(VEHICLE) == 0x1517D4D9 then
                local isSafeToDelete = false
                for k = -1,vehicle.get_vehicle_model_number_of_seats(0x1517D4D9) do
                    local PED = vehicle.get_ped_in_vehicle_seat(VEHICLE, k)
                    if PED > 0 then
                        if ped.is_ped_a_player(PED) then
                            isSafeToDelete = false
                            break
                        end
                        isSafeToDelete = true
                        entity.delete_entity(PED)
                    end
                end
                if isSafeToDelete then
                    entity.delete_entity(VEHICLE)
                end
            end
        end
        system.yield(3500)
    end
end)
