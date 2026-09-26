DRAGON_SPRITE = 16
DRAGON_SPRITE_2 = 18
DRAGON_BREATH_SPRITE = 20
DRAGON_SPRITE_PICKAXE_WINDUP = 22
DRAGON_SPRITE_PICKAXE_ATTACK = 24
DRAGON_SPRITE_PICKAXE = 48
DRAGON_FPS = 2
DRAGON_SPEED = 0.25
DRAGON_WALK_DURATION = 2
DRAGON_BREATH_WINDUP_DURATION = 0.75
DRAGON_BREATH_INTERVAL = 0.25
DRAGON_BREATH_FIRE_COUNT = 5
DRAGON_PICKAXE_WINDUP_DURATION = 0.75
DRAGON_PICKAXE_ATTACK_DURATION = 0.75
DRAGON_HP = 20

function dragon_new(tx, ty)
    if state_flags[STATE_FLAG_DRAGON_DEAD] then return end

    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", DRAGON_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, 0, -5, 4, 12),
        big_sprite = DRAGON_SPRITE,
        facing = 1,
        state = "walk",
        timer = DRAGON_WALK_DURATION,
        update = dragon_update,
        die = dragon_die,
        draw = dragon_draw
    }
end

function dragon_update(self)
    local front_tx, front_ty = tile_coords(self.body.x + 4, self.body.y + 4)
    front_tx += self.facing

    self.hitbox.x = self.facing < 0 and 0 or 3

    if self.state == "walk" then
        tick_down(self, "timer")
        self.body.vx = self.facing * DRAGON_SPEED
        self.facing = sgn(player.body.x - self.body.x)
        self.big_sprite = alternate(DRAGON_SPRITE, DRAGON_SPRITE_2, DRAGON_FPS)

        if fget(mget(front_tx, front_ty), CRACKED_BLOCK_BIT) then
            self.state = "pickaxe_windup"
            self.body.vx = 0
            self.big_sprite = DRAGON_SPRITE_PICKAXE_WINDUP
            self.timer = DRAGON_PICKAXE_WINDUP_DURATION
        elseif self.timer <= 0 then
            self.state = "breath_windup"
            self.body.vx = 0
            self.big_sprite = DRAGON_BREATH_SPRITE
            self.timer = DRAGON_BREATH_WINDUP_DURATION
        end
    elseif self.state == "pickaxe_windup" then
        tick_down(self, "timer")
        if self.timer <= 0 then
            self.state = "pickaxe_attack"
            self.big_sprite = DRAGON_SPRITE_PICKAXE_ATTACK
            self.timer = DRAGON_PICKAXE_ATTACK_DURATION

            if fget(mget(front_tx, front_ty), CRACKED_BLOCK_BIT) then
                mset(front_tx, front_ty, 0)
                add(entities, poof_new(front_tx * 8, front_ty * 8))
            end
        end
    elseif self.state == "pickaxe_attack" then
        tick_down(self, "timer")
        if self.timer <= 0 then
            self.state = "walk"
            self.timer = DRAGON_WALK_DURATION
        end
    elseif self.state == "breath_windup" then
        tick_down(self, "timer")
        if self.timer <= 0 then
            self.state = "breath"
            self.timer = 0
            self.fire_count = 0
        end
    elseif self.state == "breath" then
        tick_down(self, "timer")
        if self.timer <= 0 then
            local x = self.body.x + self.facing * 8
            local y = self.body.y - 8
            self.fire_count += 1
            add(entities, dragon_fire_new(x, y, self.facing))

            if self.fire_count < DRAGON_BREATH_FIRE_COUNT then
                self.timer = DRAGON_BREATH_INTERVAL
            else
                self.state = "walk"
                self.timer = DRAGON_WALK_DURATION
            end
        end
    end
end

function dragon_die(self)
    state_flags[STATE_FLAG_DRAGON_DEAD] = true
end

function dragon_draw(self)
    if self.state == "pickaxe_windup" then
        sprite_draw(DRAGON_SPRITE_PICKAXE, self.body.x - self.facing * 12, self.body.y - 4, self.facing > 0)
    elseif self.state == "pickaxe_attack" then
        sprite_draw(DRAGON_SPRITE_PICKAXE, self.body.x + self.facing * 12, self.body.y, self.facing < 0)
    end
end