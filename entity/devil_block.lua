DEVIL_BLOCK_SPRITE_1 = 160
DEVIL_BLOCK_SPRITE_2 = 161
DEVIL_BLOCK_SPRITE_3 = 176

function devil_block_new(tx, ty, flag)
    if state_flags[flag] then return end
    local x = tx * 8
    local y = ty * 8

    mset(tx, ty, DEVIL_BLOCK_SPRITE_1)

    local e = {
        body = body_new(x, y),
        sprite = DEVIL_BLOCK_SPRITE_1
    }

    function e.update()
        if state_flags[flag] then
            mset(tx, ty, 0)
            del(entities, e)
            add(entities, poof_new(x, y))
        end
    end

    return e
end

function devil_block_1_new(tx, ty)
    return devil_block_new(tx, ty, STATE_FLAG_DEVIL_1_DEAD)
end

function devil_block_2_new(tx, ty)
    return devil_block_new(tx, ty, STATE_FLAG_DEVIL_2_DEAD)
end

function devil_block_3_new(tx, ty)
    return devil_block_new(tx, ty, STATE_FLAG_DEVIL_3_DEAD)
end
