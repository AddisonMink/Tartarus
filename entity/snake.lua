SNAKE_SPRITE = 196
SNAKE_SPRITE_2 = 197
SNAKE_FPS = 2
SNAKE_SPEED = 0.5
SNAKE_BREATH_INTERVAL = 2
SNAKE_BREATH_DURATION = 0.5
SNAKE_HP = 3

function snake_new_base(tx, ty, turn)
    local state = "walk"
    local timer = SNAKE_BREATH_INTERVAL
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", SNAKE_HP, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = SNAKE_SPRITE,
        facing = 1
    }

    function e.update()
        local body = e.body
        timer = max(0, timer - 1 / 30)

        if state == "walk" then
            if timer <= 0 then
                state = "breath"
                timer = SNAKE_BREATH_DURATION
                body.vx = 0
            else
                local should_turn = body_would_collides(body, e.facing, 0)
                        or not body_would_collides(body, e.facing * 8, 1)

                e.sprite = alternate(SNAKE_SPRITE_2, SNAKE_SPRITE, SNAKE_FPS)

                if should_turn then
                    if turn then
                        e.facing = -e.facing
                    else
                        body.vx = 0
                    end
                else
                    body.vx = e.facing * SNAKE_SPEED
                end
            end
        elseif state == "breath" then
            if timer <= 0 then
                state = "walk"
                timer = SNAKE_BREATH_INTERVAL
                add(entities, dragon_fire_new(body.x, body.y, e.facing))
            end
        end
    end

    return e
end

function snake_new(tx, ty)
    return snake_new_base(tx, ty, true)
end

function snake_new_no_turn(tx, ty)
    return snake_new_base(tx, ty, false)
end
