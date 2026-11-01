DEVIL_FIREBALL_SPRITE = 58
DEVIL_FIREBALL_SPRITE_2 = 63
DEVIL_FIREBALL_FPS = 8
DEVIL_FIREBALL_SPEED = 0.5

function devil_fireball_new(x, y)
    sfx(10)
    local e = {
        body = body_new(x, y, true),
        hurtbox = hurtbox_new("enemy", 1, 0, 0, 8, 8),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        color = AREA_COLOR[area],
        sprite = DEVIL_FIREBALL_SPRITE
    }

    function e.update()
        local body = e.body
        local dx = player.body.x - body.x
        local dy = player.body.y - body.y
        local dist = sqrt(dx * dx + dy * dy)

        e.sprite = alternate(DEVIL_FIREBALL_SPRITE, DEVIL_FIREBALL_SPRITE_2, DEVIL_FIREBALL_FPS)
        body.x += DEVIL_FIREBALL_SPEED * dx / dist
        body.y += DEVIL_FIREBALL_SPEED * dy / dist
    end

    return e
end
