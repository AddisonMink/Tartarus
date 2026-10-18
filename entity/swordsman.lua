SWORDSMAN_SPRITE = 202
SWORDSMAN_SPRITE_2 = 204
SWORDSMAN_SPRITE_WINDUP = 206
SWORDSMAN_SPRITE_ATTACK = 224
SWORDSMAN_SPRITE_CHARGE_WINDUP = 226
SWORDSMAN_SPRITE_CHARGE = 228
SWORDSMAN_FPS = 2
SWORDSMAN_HP = 30
SWORDSMAN_IDLE_DUR = 2
SWORDSMAN_IDLE_2_DUR = 0.5
SWORDSMAN_WINDUP_DUR = 0.5
SWORDSMAN_ATTACK_DUR = 1
SWORDSMAN_CHARGE_ACCEL = 0.2
SWORDSMAN_RECOVER_DUR = 1

function swordsman_new(tx, ty)
    if state_flags[STATE_FLAG_SWORDSMAN_DEAD] then return end

    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", SWORDSMAN_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, -2, -4, 12, 10),
        facing = -1,
        big_sprite = SWORDSMAN_SPRITE,
        state = "idle",
        timer = SWORDSMAN_IDLE_DUR,
        update = swordsman_update,
        draw = swordsman_draw,
        die = swordsman_die
    }
end

function swordsman_update(self)
    tick_down(self, "timer")

    if self.state == "idle" then
        self.big_sprite = alternate(SWORDSMAN_SPRITE, SWORDSMAN_SPRITE_2, SWORDSMAN_FPS)

        if self.timer <= 0 then
            self.state = "windup"
            self.big_sprite = SWORDSMAN_SPRITE_WINDUP
            self.timer = SWORDSMAN_WINDUP_DUR
        end
    elseif self.state == "idle_2" then
        self.big_sprite = alternate(SWORDSMAN_SPRITE, SWORDSMAN_SPRITE_2, SWORDSMAN_FPS)

        if self.timer <= 0 then
            self.state = "charge_windup"
            self.big_sprite = SWORDSMAN_SPRITE_CHARGE_WINDUP
            self.timer = SWORDSMAN_WINDUP_DUR
        end
    elseif self.state == "windup" and self.timer <= 0 then
        self.state = "attack"
        self.big_sprite = SWORDSMAN_SPRITE_ATTACK
        self.timer = SWORDSMAN_ATTACK_DUR
        add(entities, dragon_fire_new(self.body.x, self.body.y, self.facing))
    elseif self.state == "charge_windup" and self.timer <= 0 then
        self.state = "charge"
        self.body.vx = self.facing * SWORDSMAN_CHARGE_ACCEL
        self.hitbox.damage = 2
        self.big_sprite = SWORDSMAN_SPRITE_CHARGE
    elseif self.state == "attack" and self.timer <= 0 then
        self.state = "idle_2"
        self.big_sprite = SWORDSMAN_SPRITE
        self.timer = SWORDSMAN_IDLE_2_DUR
    elseif self.state == "charge" then
        if body_would_collides(self.body, self.facing * 8, 0) then
            self.state = "recover"
            self.body.vx = 0
            self.hitbox.damage = 1
            self.timer = SWORDSMAN_RECOVER_DUR
        else
            self.body.vx += self.facing * SWORDSMAN_CHARGE_ACCEL
        end
    elseif self.state == "recover" and self.timer <= 0 then
        self.state = "idle"
        self.facing *= -1
        self.big_sprite = SWORDSMAN_SPRITE
        self.timer = SWORDSMAN_IDLE_DUR
    end
end

function swordsman_draw(self)
    if self.state == "windup" then
        sprite_draw(SWORD_PICKUP_SPRITE, self.body.x - self.facing * 10, self.body.y - 8, self.facing > 0, 15)
    end
end

function swordsman_die(self)
    state_flags[STATE_FLAG_SWORDSMAN_DEAD] = true
end