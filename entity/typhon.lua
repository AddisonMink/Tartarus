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

function typhon_trigger_new()
    local state = "dialogue"
    local timer = 1

    return {
        update = function()
            timer = max(0, timer - 1 / 30)
            if timer <= 0 and state == "dialogue" then
                text_box_content = TYPHON_DEAD_DIALOGUE
                music(2)
                state = "done"
            end

            if state == "done" and text_box_content == nil then
                state_flags[STATE_FLAG_TYPHON_DEAD] = true
            end
        end
    }
end

function typhon_new(tx, ty)
    music(0)

    local state = "idle"
    local timer = TYPHON_INTERVAL * 2
    local origin_x = tx * 8
    local target_x
    local e = {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", TYPHON_HP, -3, -7, 14, 14),
        hitbox = hitbox_new("player", 2, -6, -4, 20, 12),
        facing = -1,
        big_sprite = TYPHON_SPRITE
    }

    function e.update()
        local body = e.body
        local fps = state == "charge" and 4 or 2
        timer = max(0, timer - 1 / 30)
        e.big_sprite = alternate(TYPHON_SPRITE, TYPHON_SPRITE_2, fps)

        if state == "idle" and timer <= 0 then
            state = "make_blocks"
        elseif state == "make_blocks" then
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

            state = "cast"
            timer = TYPHON_CAST_DUR
        elseif state == "cast" and timer <= 0 then
            state = "move"
            target_x = body.x == origin_x + TYPHON_OFFSET and origin_x - TYPHON_OFFSET
                    or body.x + TYPHON_OFFSET
        elseif state == "move" then
            if body.x < target_x then
                body.x = min(body.x + TYPHON_SPEED, target_x)
            elseif body.x > target_x then
                body.x = max(body.x - TYPHON_SPEED, target_x)
            end
            if body.x == target_x then
                state = "idle"
                timer = TYPHON_INTERVAL
            end
        end
    end

    function e.draw()
        local body, hurtbox = e.body, e.hurtbox
        local hand_sprite, flip_tail, charge_sprite
        local color = hurtbox.just_hit_timer > 0 and 7
        local flash = hurtbox.invincible_timer > 0 and alternate(true, false, INVINCIBLE_FLASH_FPS)
        local hand_offset = state == "cast" and -8 or 0
        if flash then return end

        if state == "cast" then
            hand_sprite = TYPHON_SPRITE_HAND
            charge_sprite = alternate(TYPHON_CHARGE_SPRITE, TYPHON_CHARGE_SPRITE_2, 4)
        else
            hand_sprite = alternate(TYPHON_SPRITE_HAND, TYPHON_SPRITE_HAND_2, 2)
            flip_tail = alternate(true, false, 2)
        end

        sprite_draw(hand_sprite, body.x + 12, body.y + hand_offset, true, color)
        sprite_draw(hand_sprite, body.x - 12, body.y + hand_offset, false, color)

        sprite_draw(TYPHON_SPRITE_TAIL, body.x, body.y + 7, flip_tail, color)

        if state == "cast" then
            sprite_draw(charge_sprite, body.x + 12, body.y + hand_offset, true, 8)
            sprite_draw(charge_sprite, body.x - 12, body.y + hand_offset, false, 8)
        end
    end

    function e.die()
        for o in all(entities) do
            if o ~= e and o.hurtbox and o.hurtbox.layer == "enemy" then
                del(entities, o)
            end
        end
        music(-1)
        add(entities, typhon_trigger_new())
    end

    return e
end