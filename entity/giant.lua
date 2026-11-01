GIANT_SPRITE = 30
GIANT_SPRITE_STEP = 28
GIANT_SPRITE_WINDUP = 80
GIANT_SPRITE_THROW = 82
GIANT_STAND_DURATION = 0.75
GIANT_STEP_DURATION = 0.75
GIANT_STEP_DISTANCE = 4
GIANT_STEPS_BEFORE_THROW = 3
GIANT_WINDUP_DURATION = 0.75
GIANT_THROW_DURATION = 0.75
GIANT_HP = 20

function giant_new(tx, ty)
    if state_flags[STATE_FLAG_GIANT_DEAD] then return end
    music(0)

    local state = "stand"
    local timer = 0
    local step_count = 3
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", GIANT_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, 2, -6, 4, 12),
        big_sprite = GIANT_SPRITE,
        facing = 1
    }

    function e.update()
        local body = e.body
        timer = max(0, timer - 1 / 30)
        e.facing = sgn(player.body.x - body.x)

        if state == "stand" and timer <= 0 then
            if step_count >= GIANT_STEPS_BEFORE_THROW then
                state = "windup"
                e.big_sprite = GIANT_SPRITE_WINDUP
                timer = GIANT_WINDUP_DURATION
                step_count = 0
            else
                state = "step"
                e.big_sprite = GIANT_SPRITE_STEP
                timer = GIANT_STEP_DURATION
            end
        elseif state == "step" and timer <= 0 then
            state = "stand"
            body.x += e.facing * GIANT_STEP_DISTANCE
            e.big_sprite = GIANT_SPRITE
            timer = GIANT_STAND_DURATION
            step_count += 1
            sfx(3)
        elseif state == "windup" and timer <= 0 then
            add(entities, magic_stone_new(body.x, body.y - 8, e.facing, "player", 13))

            state = "throw"
            e.big_sprite = GIANT_SPRITE_THROW
            timer = GIANT_THROW_DURATION
        elseif state == "throw" and timer <= 0 then
            state = "stand"
            e.big_sprite = GIANT_SPRITE
            timer = GIANT_STAND_DURATION
        end
    end

    function e.die()
        state_flags[STATE_FLAG_GIANT_DEAD] = true
        music(AREA_MUSIC[area] or -1)
    end

    return e
end
