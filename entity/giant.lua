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

    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", GIANT_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, 2, -6, 4, 12),
        big_sprite = GIANT_SPRITE,
        facing = 1,
        timer = 0,
        step_count = 3,
        state = "stand",
        update = giant_update,
        die = giant_die
    }
end

function giant_update(self)
    tick_down(self, "timer")
    self.facing = sgn(player.body.x - self.body.x)

    if self.state == "stand" and self.timer <= 0 then
        if self.step_count >= GIANT_STEPS_BEFORE_THROW then
            self.state = "windup"
            self.big_sprite = GIANT_SPRITE_WINDUP
            self.timer = GIANT_WINDUP_DURATION
            self.step_count = 0
        else
            self.state = "step"
            self.big_sprite = GIANT_SPRITE_STEP
            self.timer = GIANT_STEP_DURATION
        end
    elseif self.state == "step" and self.timer <= 0 then
        self.state = "stand"
        self.body.x += self.facing * GIANT_STEP_DISTANCE
        self.big_sprite = GIANT_SPRITE
        self.timer = GIANT_STAND_DURATION
        self.step_count += 1
    elseif self.state == "windup" and self.timer <= 0 then
        add(entities, magic_stone_new(self.body.x, self.body.y - 8, self.facing, "player", 13))

        self.state = "throw"
        self.big_sprite = GIANT_SPRITE_THROW
        self.timer = GIANT_THROW_DURATION
    elseif self.state == "throw" and self.timer <= 0 then
        self.state = "stand"
        self.big_sprite = GIANT_SPRITE
        self.timer = GIANT_STAND_DURATION
    end
end

function giant_die(self)
    state_flags[STATE_FLAG_GIANT_DEAD] = true
end