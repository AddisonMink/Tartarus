SQUID_SPRITE = 192
SQUID_SPRITE_2 = 194
SQUID_FPS = 2
SQUID_HP = 18
SQUID_SPEED = 0.5
SQUID_SFX_INTERVAL = 2

function squid_1_new(tx, ty)
    local timer = SQUID_SFX_INTERVAL

    add(entities, squid_trigger_new())
    local e = {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", SQUID_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 2, 2, -6, 4, 12),
        facing = -1,
        big_sprite = SQUID_SPRITE
    }

    function e.update()
        timer = max(0, timer - 1 / 30)
        if timer <= 0 then
            sfx(12)
            timer = SQUID_SFX_INTERVAL
        end

        if body_would_collides(e.body, e.facing * SQUID_SPEED, 0) then
            e.facing *= -1
        end

        e.big_sprite = alternate(SQUID_SPRITE, SQUID_SPRITE_2, SQUID_FPS)
        e.body.x += e.facing * SQUID_SPEED
    end

    function e.die()
        local tx, ty = body_tile_coords(e.body)
        add(entities, brain_pickup_new(tx, ty))

        for tx = room_tx, room_tx + ROOM_WIDTH - 1 do
            for ty = room_ty, room_ty + ROOM_HEIGHT - 1 do
                if fget(mget(tx, ty), SPIKE_BIT) then
                    mset(tx, ty, 0)
                    add(entities, poof_new(tx * 8, ty * 8))
                end
            end
        end
    end

    return e
end

function squid_trigger_new()
    return {
        update = function()
            if not state_flags[STATE_FLAG_BRAIN] then return end
            player.body.x = player.body.x - room_tx * 8 + 98 * 8
            player.body.y = player.body.y - room_ty * 8 + 24 * 8
            player.hurtbox.invincible_timer = 1
        end
    }
end