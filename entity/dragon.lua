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
    music(0)

    local state = "walk"
    local timer = DRAGON_WALK_DURATION
    local fire_count = 0
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", DRAGON_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, 0, -5, 4, 12),
        big_sprite = DRAGON_SPRITE,
        facing = 1
    }

    function e.update()
        local body = e.body
        local front_tx, front_ty = tile_coords(body.x + 4, body.y + 4)
        front_tx += e.facing

        e.hitbox.x = e.facing < 0 and 0 or 3

        if state == "walk" then
            timer = max(0, timer - 1 / 30)
            body.vx = e.facing * DRAGON_SPEED
            e.facing = sgn(player.body.x - body.x)
            e.big_sprite = alternate(DRAGON_SPRITE, DRAGON_SPRITE_2, DRAGON_FPS)

            if fget(mget(front_tx, front_ty), CRACKED_BLOCK_BIT) then
                state = "pickaxe_windup"
                body.vx = 0
                e.big_sprite = DRAGON_SPRITE_PICKAXE_WINDUP
                timer = DRAGON_PICKAXE_WINDUP_DURATION
            elseif timer <= 0 then
                state = "breath_windup"
                body.vx = 0
                e.big_sprite = DRAGON_BREATH_SPRITE
                timer = DRAGON_BREATH_WINDUP_DURATION
            end
        elseif state == "pickaxe_windup" then
            timer = max(0, timer - 1 / 30)
            if timer <= 0 then
                state = "pickaxe_attack"
                e.big_sprite = DRAGON_SPRITE_PICKAXE_ATTACK
                timer = DRAGON_PICKAXE_ATTACK_DURATION

                if fget(mget(front_tx, front_ty), CRACKED_BLOCK_BIT) then
                    mset(front_tx, front_ty, 0)
                    add(entities, poof_new(front_tx * 8, front_ty * 8))
                end
                sfx(9)
            end
        elseif state == "pickaxe_attack" then
            timer = max(0, timer - 1 / 30)
            if timer <= 0 then
                state = "walk"
                timer = DRAGON_WALK_DURATION
            end
        elseif state == "breath_windup" then
            timer = max(0, timer - 1 / 30)
            if timer <= 0 then
                state = "breath"
                timer = 0
                fire_count = 0
            end
        elseif state == "breath" then
            timer = max(0, timer - 1 / 30)
            if timer <= 0 then
                fire_count += 1
                add(entities, dragon_fire_new(body.x + e.facing * 8, body.y - 8, e.facing))

                if fire_count < DRAGON_BREATH_FIRE_COUNT then
                    timer = DRAGON_BREATH_INTERVAL
                else
                    state = "walk"
                    timer = DRAGON_WALK_DURATION
                end
            end
        end
    end

    function e.die()
        state_flags[STATE_FLAG_DRAGON_DEAD] = true
        music(AREA_MUSIC[area] or -1)
    end

    function e.draw()
        local body, facing = e.body, e.facing
        if state == "pickaxe_windup" then
            sprite_draw(DRAGON_SPRITE_PICKAXE, body.x - facing * 12, body.y - 4, facing > 0)
        elseif state == "pickaxe_attack" then
            sprite_draw(DRAGON_SPRITE_PICKAXE, body.x + facing * 12, body.y, facing < 0)
        end
    end

    return e
end