DEVIL_SPRITE = 84
DEVIL_SPRITE_2 = 86
DEVIL_FPS = 2
DEVIL_SPRITE_CAST = 88
DEVIL_CAST_COOLDOWN = 5
DEVIL_CAST_INTERVAL = 1
DEVIL_NUM_FIREBALLS = 3
DEVIL_HP = 2

function devil_new(tx, ty, kill_flag)
    if state_flags[kill_flag] then return end
    local state = "idle"
    local timer = DEVIL_CAST_COOLDOWN - 2
    local num_fireballs = 0
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", DEVIL_HP, -3, -7, 14, 7),
        big_sprite = DEVIL_SPRITE,
        color = 9,
        facing = -1
    }

    function e.update()
        timer = max(0, timer - 1 / 30)

        if state == "idle" then
            if timer <= 0 then
                state = "casting"
                e.big_sprite = DEVIL_SPRITE_CAST
                num_fireballs = 0
            else
                e.big_sprite = alternate(DEVIL_SPRITE, DEVIL_SPRITE_2, DEVIL_FPS)
            end
        elseif state == "casting" then
            if timer <= 0 then
                if num_fireballs < DEVIL_NUM_FIREBALLS then
                    local fireball_x = e.body.x + 4 + e.facing * 12
                    local fireball_y = e.body.y - 4

                    num_fireballs += 1
                    timer = DEVIL_CAST_INTERVAL
                    add(entities, devil_fireball_new(fireball_x, fireball_y, e.facing))
                else
                    state = "idle"
                    timer = DEVIL_CAST_COOLDOWN
                end
            else
                e.big_sprite = timer > DEVIL_CAST_INTERVAL / 2 and DEVIL_SPRITE_CAST or DEVIL_SPRITE
            end
        end
    end

    function e.die()
        state_flags[kill_flag] = true
    end

    return e
end

function devil_1_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_1_DEAD)
end

function devil_2_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_2_DEAD)
end

function devil_3_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_3_DEAD)
end
