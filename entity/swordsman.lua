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
    music(0)

    local state = "idle"
    local timer = SWORDSMAN_IDLE_DUR
    local e = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", SWORDSMAN_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, -2, -4, 12, 10),
        facing = -1,
        big_sprite = SWORDSMAN_SPRITE
    }

    function e.update()
        local body = e.body
        timer = max(0, timer - 1 / 30)

        if state == "idle" then
            e.big_sprite = alternate(SWORDSMAN_SPRITE, SWORDSMAN_SPRITE_2, SWORDSMAN_FPS)

            if timer <= 0 then
                state = "windup"
                e.big_sprite = SWORDSMAN_SPRITE_WINDUP
                timer = SWORDSMAN_WINDUP_DUR
            end
        elseif state == "idle_2" then
            e.big_sprite = alternate(SWORDSMAN_SPRITE, SWORDSMAN_SPRITE_2, SWORDSMAN_FPS)

            if timer <= 0 then
                state = "charge_windup"
                e.big_sprite = SWORDSMAN_SPRITE_CHARGE_WINDUP
                timer = SWORDSMAN_WINDUP_DUR
            end
        elseif state == "windup" and timer <= 0 then
            state = "attack"
            e.big_sprite = SWORDSMAN_SPRITE_ATTACK
            timer = SWORDSMAN_ATTACK_DUR
            add(entities, dragon_fire_new(body.x, body.y, e.facing))
        elseif state == "charge_windup" and timer <= 0 then
            state = "charge"
            body.vx = e.facing * SWORDSMAN_CHARGE_ACCEL
            e.hitbox.damage = 2
            e.big_sprite = SWORDSMAN_SPRITE_CHARGE
        elseif state == "attack" and timer <= 0 then
            state = "idle_2"
            e.big_sprite = SWORDSMAN_SPRITE
            timer = SWORDSMAN_IDLE_2_DUR
        elseif state == "charge" then
            if body_would_collides(body, e.facing * 8, 0) then
                state = "recover"
                body.vx = 0
                e.hitbox.damage = 1
                timer = SWORDSMAN_RECOVER_DUR
                sfx(3)
            else
                body.vx += e.facing * SWORDSMAN_CHARGE_ACCEL
            end
        elseif state == "recover" and timer <= 0 then
            state = "idle"
            e.facing *= -1
            e.big_sprite = SWORDSMAN_SPRITE
            timer = SWORDSMAN_IDLE_DUR
        end
    end

    function e.draw()
        if state == "windup" then
            sprite_draw(SWORD_PICKUP_SPRITE, e.body.x - e.facing * 10, e.body.y - 8, e.facing > 0, 15)
        end
    end

    function e.die()
        state_flags[STATE_FLAG_SWORDSMAN_DEAD] = true
        music(AREA_MUSIC[area] or -1)
    end

    return e
end