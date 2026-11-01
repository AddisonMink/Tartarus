ZOMBIE_SPRITE = 6
ZOMBIE_SPRITE_WALK = 7
ZOMBIE_FPS = 2
ZOMBIE_SPEED = 0.5
ZOMBIE_HP = 3

function zombie_new(tx, ty)
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", ZOMBIE_HP, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = ZOMBIE_SPRITE,
        facing = 1
    }

    function e.update()
        local body = e.body
        local turn = body_would_collides(body, e.facing, 0)
                or not body_would_collides(body, e.facing * 8, 1)

        e.sprite = alternate(ZOMBIE_SPRITE_WALK, ZOMBIE_SPRITE, ZOMBIE_FPS)

        if turn then
            e.facing = -e.facing
        end

        body.vx = e.facing * ZOMBIE_SPEED
    end

    return e
end
