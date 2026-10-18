TYPHON_SPRITE = 231
TYPHON_SPRITE_2 = 233
TYPHON_SPRITE_HAND = 120
TYPHON_SPRITE_HAND_2 = 121
TYPHON_SPRITE_TAIL = 122
TYPHON_CHARGE_SPRITE = 59
TYPHON_CHARGE_SPRITE_2 = 60
TYPHON_TILE = 125
TYPHON_INTERVAL = 2
TYPHON_CAST_DUR = 4
TYPHON_HP = 30
TYPHON_OFFSET = 32
TYPHON_SPEED = 0.5

TYPHON_DEAD_DIALOGUE = {
    "wITH tYPHON SLAIN",
    "YOU RETURN TO THE",
    "SURFACE UNIMPEDED.",
    "yOU NOW POSSESS A",
    "TREASURE BOTH",
    "WORTHLESS AND",
    "INFINITELY VALUABLE!"
}

function typhon_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", TYPHON_HP, -3, -7, 14, 14),
        hitbox = hitbox_new("player", 2, -6, -4, 20, 12),
        facing = -1,
        big_sprite = TYPHON_SPRITE,
        state = "idle",
        timer = TYPHON_INTERVAL * 2,
        origin_x = tx * 8,
        update = typhon_update,
        die = typhon_die,
        draw = typhon_draw
    }
end

function typhon_trigger_new()
    local state = "dialogue"
    return {
        timer = 1,
        update = function(self)
            tick_down(self, "timer")
            if self.timer <= 0 and state == "dialogue" then
                text_box_content = TYPHON_DEAD_DIALOGUE
                state = "done"
            end

            if state == "done" and text_box_content == nil then
                state_flags[STATE_FLAG_TYPHON_DEAD] = true
            end
        end
    }
end

function typhon_update(self)
    local fps = self.state == "charge" and 4 or 2
    tick_down(self, "timer")
    self.big_sprite = alternate(TYPHON_SPRITE, TYPHON_SPRITE_2, fps)

    if self.state == "idle" and self.timer <= 0 then
        self.state = "make_blocks"
    elseif self.state == "make_blocks" then
        local px = player.body.x
        local py = player.body.y
        local ptx, pty = body_tile_coords(player.body)

        for tx = ptx - 1, ptx + 1 do
            for ty = pty - 1, pty + 1 do
                local spawn = (tx ~= ptx or ty ~= pty)
                        and mget(tx, ty) == 0
                        and not body_intersects_tile(player.body, tx, ty)
                if spawn then
                    mset(tx, ty, TYPHON_TILE)
                end
            end
        end

        add(entities, devil_fireball_new(px, py - 32))
        add(entities, devil_fireball_new(px, py + 32))
        add(entities, devil_fireball_new(px - 32, py))
        add(entities, devil_fireball_new(px + 32, py))

        self.state = "cast"
        self.timer = TYPHON_CAST_DUR
    elseif self.state == "cast" and self.timer <= 0 then
        self.state = "move"
        self.target_x = self.body.x == self.origin_x + TYPHON_OFFSET and self.origin_x - TYPHON_OFFSET
                or self.body.x + TYPHON_OFFSET
    elseif self.state == "move" then
        if self.body.x < self.target_x then
            self.body.x = min(self.body.x + TYPHON_SPEED, self.target_x)
        elseif self.body.x > self.target_x then
            self.body.x = max(self.body.x - TYPHON_SPEED, self.target_x)
        end
        if self.body.x == self.target_x then
            self.state = "idle"
            self.timer = TYPHON_INTERVAL
        end
    end
end

function typhon_draw(self)
    local hand_sprite, flip_tail, charge_sprite
    local color = self.hurtbox.just_hit_timer > 0 and 7
    local flash = self.hurtbox.invincible_timer > 0 and alternate(true, false, INVINCIBLE_FLASH_FPS)
    local hand_offset = self.state == "cast" and -8 or 0
    if flash then return end

    if self.state == "cast" then
        hand_sprite = TYPHON_SPRITE_HAND
        charge_sprite = alternate(TYPHON_CHARGE_SPRITE, TYPHON_CHARGE_SPRITE_2, 4)
    else
        hand_sprite = alternate(TYPHON_SPRITE_HAND, TYPHON_SPRITE_HAND_2, 2)
        flip_tail = alternate(true, false, 2)
    end

    sprite_draw(hand_sprite, self.body.x + 12, self.body.y + hand_offset, true, color)
    sprite_draw(hand_sprite, self.body.x - 12, self.body.y + hand_offset, false, color)

    sprite_draw(TYPHON_SPRITE_TAIL, self.body.x, self.body.y + 7, flip_tail, color)

    if self.state == "cast" then
        sprite_draw(charge_sprite, self.body.x + 12, self.body.y + hand_offset, true, 8)
        sprite_draw(charge_sprite, self.body.x - 12, self.body.y + hand_offset, false, 8)
    end
end

function typhon_die(self)
    for e in all(entities) do
        if e ~= self and e.hurtbox and e.hurtbox.layer == "enemy" then
            del(entities, e)
        end
    end
    add(entities, typhon_trigger_new())
end