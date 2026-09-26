BAT_SPRITE_HANG = 10
BAT_SPRITE_FLY_1 = 11
BAT_SPRITE_FLY_2 = 12
BAT_FPS = 6
BAT_ACTIVATION_DIST_X = 32
BAT_ACTIVATION_DIST_Y = 32
BAT_TURN_DISTANCE = 16
BAT_SPEED = 0.6

function bat_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", 1, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        facing = 1,
        sprite = BAT_SPRITE_HANG,
        state = "hang",
        update = bat_update
    }
end

function bat_update(self)
    local dx = player.body.x - self.body.x
    local dy = player.body.y - self.body.y
    local x_dist = abs(dx)
    local y_dist = abs(dy)

    if self.state == "hang" then
        local start_flying = x_dist <= BAT_ACTIVATION_DIST_X
                and y_dist <= BAT_ACTIVATION_DIST_Y
                and dy > 0

        if start_flying then
            self.state = "fly"
            self.sprite = BAT_SPRITE_FLY_1
            self.facing = sgn(player.body.x - self.body.x)
        end
    elseif self.state == "fly" then
        if abs(dy) >= 1 then
            self.body.y += sgn(dy) * BAT_SPEED
        end

        if sgn(dx) ~= self.facing and x_dist >= BAT_TURN_DISTANCE then
            self.facing *= -1
        end

        self.body.x += self.facing * BAT_SPEED
        self.sprite = alternate(BAT_SPRITE_FLY_1, BAT_SPRITE_FLY_2, BAT_FPS)
    end
end