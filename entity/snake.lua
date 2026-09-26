SNAKE_SPRITE = 192
SNAKE_SPRITE_2 = 193
SNAKE_FPS = 2
SNAKE_SPEED = 0.5
SNAKE_BREATH_INTERVAL = 2
SNAKE_BREATH_DURATION = 0.5
SNAKE_HP = 3

function snake_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", SNAKE_HP, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = SNAKE_SPRITE,
        facing = 1,
        timer = SNAKE_BREATH_INTERVAL,
        state = "walk",
        update = snake_update
    }
end

function snake_update(self)
    tick_down(self, "timer")

    if self.state == "walk" then
        if self.timer <= 0 then
            self.state = "breath"
            self.timer = SNAKE_BREATH_DURATION
            self.body.vx = 0
        else
            local turn = body_would_collides(self.body, self.facing, 0)
                    or not body_would_collides(self.body, self.facing * 8, 1)

            self.sprite = alternate(SNAKE_SPRITE_2, SNAKE_SPRITE, SNAKE_FPS)

            if turn then
                self.facing = -self.facing
            end

            self.body.vx = self.facing * SNAKE_SPEED
        end
    elseif self.state == "breath" then
        if self.timer <= 0 then
            self.state = "walk"
            self.timer = SNAKE_BREATH_INTERVAL
            add(entities, dragon_fire_new(self.body.x, self.body.y, self.facing))
        end
    end
end