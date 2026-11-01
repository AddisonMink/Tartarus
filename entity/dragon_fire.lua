DRAGON_FIRE_SPRITE = 49
DRAGON_FIRE_SPEED = 2

function dragon_fire_new(x, y, facing)
    sfx(8)
    local e = {
        body = body_new(x, y),
        hitbox = hitbox_new("player", 2, 2, 2, 4, 4),
        sprite = DRAGON_FIRE_SPRITE,
        facing = facing,
        color = AREA_COLOR[area]
    }

    function e.update()
        local body = e.body
        if body_grounded(body) then
            body.vx = facing * DRAGON_FIRE_SPEED
        end

        if body_would_collides(body, body.vx, 0) then
            del(entities, e)
        end
    end

    return e
end
