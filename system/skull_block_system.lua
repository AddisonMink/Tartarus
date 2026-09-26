function skull_block_run()
    local enemies_dead = true
    for e in all(entities) do
        if e.hurtbox and e.hurtbox.layer == "enemy" then
            enemies_dead = false
            break
        end
    end

    if enemies_dead then
        local state_flag = ROOM_CLEAR_FLAGS[room_tx .. "," .. room_ty]

        if state_flag then
            state_flags[state_flag] = 1
        end

        for tx = room_tx, room_tx + ROOM_WIDTH - 1 do
            for ty = room_ty, room_ty + ROOM_HEIGHT - 1 do
                if fget(mget(tx, ty), SKULL_BLOCK_BIT) then
                    add(entities, poof_new(tx * 8, ty * 8))
                    mset(tx, ty, 0)
                end
            end
        end
    end
end