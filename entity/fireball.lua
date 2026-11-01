FIREBALL_SPRITE = 61
FIREBALL_SPRITE_2 = 62
FIREBALL_ACCEL = 0.2
FIREBALL_DURATION = 2
FIREBALL_FPS = 8

function fireball_new(x, y, facing)
    sfx(10)
    local timer = FIREBALL_DURATION
    local x_vel = 0.5 * facing
    local e = {
        body = body_new(x, y, true),
        hitbox = hitbox_new("enemy", 1 + player_attack_bonus() * 2, 2, 2, 4, 4),
        facing = facing,
        sprite = FIREBALL_SPRITE,
        color = state_flags[STATE_FLAG_GREEN_SWORD] and 15 or state_flags[STATE_FLAG_RED_SWORD] and 8
    }

    function e.update()
        timer = max(0, timer - 1 / 30)
        e.sprite = alternate(FIREBALL_SPRITE, FIREBALL_SPRITE_2, FIREBALL_FPS)
        if timer <= 0 then
            del(entities, e)
        end

        x_vel += FIREBALL_ACCEL * facing
        e.body.x += x_vel
    end

    return e
end
