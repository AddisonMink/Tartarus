SQUID_SPRITE = 192
SQUID_SPRITE_2 = 194
SQUID_FPS = 2
SQUID_HP = 18
SQUID_SPEED = 0.5

function squid_1_new(tx, ty)
    add(entities, squid_trigger_new())
    return {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", SQUID_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 2, 2, -6, 4, 12),
        facing = -1,
        big_sprite = SQUID_SPRITE,
        update = squid_update,
        die = squid_die
    }
end

function squid_trigger_new()
    return {
        update = function(self)
            if not state_flags[STATE_FLAG_BRAIN] then return end
            player.body.x = player.body.x - room_tx * 8 + 98 * 8
            player.body.y = player.body.y - room_ty * 8 + 24 * 8
            player.hurtbox.invincible_timer = 1
        end
    }
end

function squid_update(self)
    if body_would_collides(self.body, self.facing * SQUID_SPEED, 0) then
        self.facing *= -1
    end

    self.big_sprite = alternate(SQUID_SPRITE, SQUID_SPRITE_2, SQUID_FPS)
    self.body.x += self.facing * SQUID_SPEED
end

function squid_die(self)
    local tx, ty = body_tile_coords(self.body)
    add(entities, pickup_new(tx, ty, BRAIN_PICKUP_SPRITE, STATE_FLAG_BRAIN, "brain"))

    for tx = room_tx, room_tx + ROOM_WIDTH - 1 do
        for ty = room_ty, room_ty + ROOM_HEIGHT - 1 do
            if fget(mget(tx, ty), SPIKE_BIT) then
                mset(tx, ty, 0)
                add(entities, poof_new(tx * 8, ty * 8))
            end
        end
    end
end