JELLY_SPRITE_2 = 246
JELLY_SPRITE = 230
JELLY_GRAVITY = 0.025
JELLY_FALL_DUR = 1
JELLY_JUMP_ACC = 0.05
JELLY_JUMP_DUR = 0.69
JELLY_FIREBALL_INTERVAL = 1

function jelly_new(tx, ty)
    local state = "fall"
    local timer = JELLY_FALL_DUR
    local vy = 0
    local jump = 0
    local e = {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", 3, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = JELLY_SPRITE_2
    }

    function e.update()
        timer = max(0, timer - 1 / 30)

        if state == "fall" then
            vy += JELLY_GRAVITY

            if timer <= 0 then
                state = "jump"
                e.sprite = JELLY_SPRITE
                vy = -JELLY_JUMP_ACC
                timer = JELLY_JUMP_DUR
                jump += 1
                if jump % JELLY_FIREBALL_INTERVAL == 0 then
                    add(entities, devil_fireball_new(e.body.x, e.body.y))
                end
            end
        elseif state == "jump" then
            vy -= JELLY_JUMP_ACC

            if timer <= 0 then
                state = "fall"
                e.sprite = JELLY_SPRITE_2
                timer = JELLY_FALL_DUR
                vy = 0
            end
        end

        e.body.y += vy
    end

    return e
end
