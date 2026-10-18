function switch_system_run()
    local key = room_tx .. "," .. room_ty
    local switch_flag = ROOM_SWITCH_FLAGS[key]

    if switch_flag and state_flags[switch_flag] then
        for tx = room_tx, room_tx + ROOM_WIDTH - 1 do
            for ty = room_ty, room_ty + ROOM_HEIGHT - 1 do
                if fget(mget(tx, ty), SWITCH_BLOCK_BIT) then
                    add(entities, poof_new(tx * 8, ty * 8))
                    mset(tx, ty, 0)
                end
            end
        end
    end
end