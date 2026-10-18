PLAYER_SPRITE = 1
PLAYER_SPRITE_CLIMB = 2
PLAYER_SPRITE_WALK = 3
PLAYER_SPRITE_ATTACK = 4
PLAYER_SPRITE_PICKAXE_WINDUP = 51
PLAYER_SPRITE_SWORD = 5
PLAYER_SPRITE_PICKAXE_ANGLE = 50
PLAYER_SPRITE_PICKAXE = 48
PLAYER_SPRITE_PICKAXE_BLUR = 26
PLAYER_CHARGE_SPRITE = 59
PLAYER_CHARGE_SPRITE_2 = 60
PLAYER_CHARGE_FPS = 8
PLAYER_FPS = 6
PLAYER_BASE_HP = 2
PLAYER_JUMP_SPEED = 2
PLAYER_ATTACK_DURATION = 0.25
PLAYER_ATTACK_COOLDOWN_DURATION = 0.25
PLAYER_PICKAXE_WINDUP_DURATION = 0.25
PLAYER_PICKAXE_BLUR_DURATION = 0.125
PLAYER_CHARGE_DURATION = 1
PLAYER_WALK_SPEED = 0.9

function player_max_hp()
    local heart = state_flags[STATE_FLAG_HEART] and 1 or 0
    local red_heart = state_flags[STATE_FLAG_RED_HEART] and 1 or 0
    local green_heart = state_flags[STATE_FLAG_GREEN_HEART] and 1 or 0
    return PLAYER_BASE_HP + heart + red_heart + green_heart
end

function player_attack_bonus()
    return state_flags[STATE_FLAG_GREEN_SWORD] and 2
            or state_flags[STATE_FLAG_RED_SWORD] and 1
            or 0
end

function player_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("player", player_max_hp(), 2, 2, 4, 4),
        sprite = PLAYER_SPRITE,
        facing = 1,
        state = "base",
        attack_timer = 0,
        cooldown_timer = 0,
        blur_timer = 0,
        charge_timer = nil,
        action_button_down = nil,
        update = player_update,
        draw = player_draw
    }
end

function player_update(self)
    local tx, ty = body_tile_coords(self.body)
    local on_ladder = fget(mget(tx, ty), LADDER_BIT)
    local above_ladder = fget(mget(tx, ty + 1), LADDER_BIT)
    local grounded = body_grounded(self.body)
    local btnp5 = btn(5) and not self.action_button_down

    self.action_button_down = btn(5)

    tick_down(self, "cooldown_timer")

    self.color = state_flags[STATE_FLAG_GREEN_SWORD] and 15
            or state_flags[STATE_FLAG_RED_SWORD] and 8
            or 12

    if self.state == "base" then
        local fireball = false

        if self.charge_timer and state_flags[STATE_FLAG_MAGIC_WAND] then
            if not btn(5) then
                fireball = self.charged
                self.charge_timer = nil
                self.charged = false
            else
                tick_down(self, "charge_timer")
                self.charged = self.charge_timer <= 0
            end
        end

        local dx = btn(0) and -1 or btn(1) and 1

        local jump = btnp(4) and grounded

        local ladder_dy = btn(2) and on_ladder and -1
                or btn(3) and above_ladder and 1

        local pickaxe = btnp5
                and btn(3)
                and self.cooldown_timer <= 0
                and state_flags[STATE_FLAG_PICKAXE]

        local magic_stone = btnp5
                and btn(2)
                and self.cooldown_timer <= 0
                and rock_body == nil
                and state_flags[STATE_FLAG_MAGIC_STONE]

        local attack = btnp5
                and self.cooldown_timer <= 0
                and state_flags[STATE_FLAG_SWORD]

        if fireball then
            add(entities, fireball_new(self.body.x, self.body.y, self.facing))
            self.state = "throw"
            self.sprite = PLAYER_SPRITE_ATTACK
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.charge_timer = nil
        end
        if pickaxe then
            self.state = "pickaxe_windup"
            self.sprite = PLAYER_SPRITE_PICKAXE_WINDUP
            self.attack_timer = PLAYER_PICKAXE_WINDUP_DURATION
            self.charge_timer = nil
        elseif magic_stone then
            add(entities, magic_stone_new(self.body.x, self.body.y, self.facing, "enemy", self.color))
            self.state = "throw"
            self.sprite = PLAYER_SPRITE_ATTACK
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.charge_timer = nil
        elseif attack then
            local power = 1 + player_attack_bonus()
            self.state = "attack"
            self.hitbox = hitbox_new("enemy", power, self.facing * 8, 2, 8, 4)
            self.sprite = PLAYER_SPRITE_ATTACK
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.charge_timer = nil
        elseif ladder_dy then
            self.state = "climb"
            self.body.kinematic = true
            self.body.x = tx * 8
            self.body.y += ladder_dy
            self.sprite = PLAYER_SPRITE_CLIMB
            self.old_facing = self.facing
            self.charge_timer = nil
        else
            self.body.vx = (dx or 0) * PLAYER_WALK_SPEED
            self.body.vy = jump and -PLAYER_JUMP_SPEED or self.body.vy
            self.sprite = (dx or not grounded) and alternate(PLAYER_SPRITE_WALK, PLAYER_SPRITE, PLAYER_FPS) or PLAYER_SPRITE
            self.facing = dx ~= 0 and dx or self.facing
        end
    elseif self.state == "climb" then
        if not (on_ladder or above_ladder) or grounded or btnp(4) then
            self.state = "base"
            self.body.kinematic = false
            self.body.vx = 0
            self.body.vy = 0
            self.sprite = PLAYER_SPRITE
            self.facing = self.old_facing
            self.old_facing = nil
        else
            local dy = btn(2) and -1 or btn(3) and 1
            self.body.y += dy or 0
            self.facing = dy and alternate(1, -1, PLAYER_FPS) or self.old_facing
        end
    elseif self.state == "attack" or self.state == "pickaxe" or self.state == "throw" then
        tick_down(self, "attack_timer")
        tick_down(self, "blur_timer")
        self.body.vx = grounded and 0 or self.body.vx

        if self.attack_timer <= 0 then
            self.state = "base"
            self.hitbox = nil
            self.sprite = PLAYER_SPRITE
            self.cooldown_timer = PLAYER_ATTACK_COOLDOWN_DURATION
            self.charge_timer = PLAYER_CHARGE_DURATION
        end
    elseif self.state == "pickaxe_windup" then
        tick_down(self, "attack_timer")
        self.body.vx = grounded and 0 or self.body.vx

        if self.attack_timer <= 0 then
            local power = 1 + player_attack_bonus()
            self.state = "pickaxe"
            self.hitbox = hitbox_new("enemy", power, self.facing < 0 and -6 or 2, -4, 12, 15)
            self.sprite = PLAYER_SPRITE_ATTACK
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.blur_timer = PLAYER_PICKAXE_BLUR_DURATION
            _private_destroy_cracked_tiles(self)
        end
    end
end

function player_draw(self)
    if self.state == "attack" then
        local x = self.body.x + self.facing * 8
        sprite_draw(PLAYER_SPRITE_SWORD, x, self.body.y, self.facing < 0, self.color)
    elseif self.state == "pickaxe_windup" then
        local x = self.body.x + self.facing * -7
        local y = self.body.y - 4
        sprite_draw(PLAYER_SPRITE_PICKAXE_ANGLE, x, y, self.facing > 0, self.color)
    elseif self.state == "pickaxe" then
        local x = self.body.x + self.facing * 8
        local y = self.body.y + 1
        local blur_x = self.body.x + (self.facing < 0 and -8 or 0)
        local blur_y = self.body.y - 8

        if self.blur_timer > 0 then
            sprite_draw(PLAYER_SPRITE_PICKAXE_BLUR, blur_x, blur_y, self.facing < 0, self.color, 2)
        end

        sprite_draw(PLAYER_SPRITE_PICKAXE, x, y, self.facing < 0, self.color)
    end

    if self.charged then
        local x = self.body.x
        local y = self.body.y
        local s = alternate(PLAYER_CHARGE_SPRITE, PLAYER_CHARGE_SPRITE_2, PLAYER_CHARGE_FPS)

        set_pal(self.color)
        spr(s, x, y)
        pal()
    end
end

function _private_destroy_cracked_tiles(self)
    local x = self.body.x + 4 + self.facing * 8
    local y = self.body.y

    for y in all({ 4, 8 }) do
        local tx, ty = tile_coords(x, self.body.y + y)
        if fget(mget(tx, ty), CRACKED_BLOCK_BIT) then
            mset(tx, ty, 0)
            add(entities, poof_new(tx * 8, ty * 8))
        end
    end
end