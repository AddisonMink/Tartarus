JELLY_SPRITE_2 = 246
JELLY_SPRITE = 230
JELLY_GRAVITY = 0.025
JELLY_FALL_DUR = 1
JELLY_JUMP_ACC = 0.05
JELLY_JUMP_DUR = 0.69
JELLY_FIREBALL_INTERVAL = 2

function jelly_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", 3, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = JELLY_SPRITE_2,
        state = "fall",
        timer = JELLY_FALL_DUR,
        vy = 0,
        jump = 0,
        update = jelly_update
    }
end

function jelly_update(self)
    tick_down(self, "timer")

    if self.state == "fall" then
        self.vy += JELLY_GRAVITY

        if self.timer <= 0 then
            self.state = "jump"
            self.sprite = JELLY_SPRITE
            self.vy = -JELLY_JUMP_ACC
            self.timer = JELLY_JUMP_DUR
            self.jump += 1
            if self.jump % JELLY_FIREBALL_INTERVAL == 0 then
                add(entities, devil_fireball_new(self.body.x, self.body.y))
            end
        end
    elseif self.state == "jump" then
        self.vy -= JELLY_JUMP_ACC

        if self.timer <= 0 then
            self.state = "fall"
            self.sprite = JELLY_SPRITE_2
            self.timer = JELLY_FALL_DUR
            self.vy = 0
        end
    end

    self.body.y += self.vy
end