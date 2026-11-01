SWITCH_SPRITE = 106
SWITCH_SPRITE_2 = 198
SWITCH_FPS = 2

function switch_new(tx, ty)
    local room_key = room_tx .. "," .. room_ty
    local switch_flag = ROOM_SWITCH_FLAGS[room_key]
    if state_flags[switch_flag] then return end

    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", 1, 1, 1, 6, 6),
        sprite = SWITCH_SPRITE
    }

    function e.update()
        e.sprite = alternate(SWITCH_SPRITE, SWITCH_SPRITE_2, SWITCH_FPS)
    end

    function e.die()
        if switch_flag then
            state_flags[switch_flag] = true
        end
    end

    return e
end
