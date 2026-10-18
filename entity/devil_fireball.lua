DEVIL_FIREBALL_SPRITE = 58
DEVIL_FIREBALL_SPRITE_2 = 63
DEVIL_FIREBALL_FPS = 8
DEVIL_FIREBALL_SPEED = 0.5

function devil_fireball_new(x, y)
    return {
        body = body_new(x, y, true),
        hurtbox = hurtbox_new("enemy", 1, 0, 0, 8, 8),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        color = AREA_COLOR[area],
        update = devil_fireball_update,
        sprite = DEVIL_FIREBALL_SPRITE,
    }
end

function devil_fireball_update(self)
    local dx = player.body.x - self.body.x
    local dy = player.body.y - self.body.y
    local dist = sqrt(dx * dx + dy * dy)

    self.sprite = alternate(DEVIL_FIREBALL_SPRITE, DEVIL_FIREBALL_SPRITE_2, DEVIL_FIREBALL_FPS)
    self.body.x += DEVIL_FIREBALL_SPEED * dx / dist
    self.body.y += DEVIL_FIREBALL_SPEED * dy / dist
end