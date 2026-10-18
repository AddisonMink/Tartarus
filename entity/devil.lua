DEVIL_SPRITE = 84
DEVIL_SPRITE_2 = 86
DEVIL_FPS = 2
DEVIL_SPRITE_CAST = 88
DEVIL_CAST_COOLDOWN = 5
DEVIL_CAST_INTERVAL = 1
DEVIL_NUM_FIREBALLS = 3
DEVIL_HP = 2

function devil_new(tx, ty, kill_flag)
    if state_flags[kill_flag] then return end
    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", DEVIL_HP, -3, -7, 14, 7),
        big_sprite = DEVIL_SPRITE,
        color = 9,
        facing = -1,
        state = "idle",
        timer = DEVIL_CAST_COOLDOWN - 2,
        num_fireballs = 0,
        update = devil_update,
        die = function(self)
            state_flags[kill_flag] = true
        end
    }
end

function devil_update(self)
    tick_down(self, "timer")

    if self.state == "idle" then
        if self.timer <= 0 then
            self.state = "casting"
            self.big_sprite = DEVIL_SPRITE_CAST
            self.num_fireballs = 0
        else
            self.big_sprite = alternate(DEVIL_SPRITE, DEVIL_SPRITE_2, DEVIL_FPS)
        end
    elseif self.state == "casting" then
        if self.timer <= 0 then
            if self.num_fireballs < DEVIL_NUM_FIREBALLS then
                local fireball_x = self.body.x + 4 + self.facing * 12
                local fireball_y = self.body.y - 4

                self.num_fireballs = self.num_fireballs + 1
                self.timer = DEVIL_CAST_INTERVAL
                add(entities, devil_fireball_new(fireball_x, fireball_y, self.facing))
            else
                self.state = "idle"
                self.timer = DEVIL_CAST_COOLDOWN
            end
        else
            self.big_sprite = self.timer > DEVIL_CAST_INTERVAL / 2 and DEVIL_SPRITE_CAST or DEVIL_SPRITE
        end
    end
end

function devil_1_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_1_DEAD)
end

function devil_2_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_2_DEAD)
end

function devil_3_new(tx, ty)
    return devil_new(tx, ty, STATE_FLAG_DEVIL_3_DEAD)
end