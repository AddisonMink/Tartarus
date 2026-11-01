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
    local state = "base"
    local attack_timer = 0
    local cooldown_timer = 0
    local blur_timer = 0
    local charge_timer = nil
    local charged = false
    local action_button_down = nil
    local old_facing = nil
    local color = 12

    local p = {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("player", player_max_hp(), 2, 2, 4, 4),
        sprite = PLAYER_SPRITE,
        facing = 1
    }

    local function destroy_cracked_tiles()
        local x = p.body.x + 4 + p.facing * 8

        for y in all({ 4, 8 }) do
            local tx, ty = tile_coords(x, p.body.y + y)
            if fget(mget(tx, ty), CRACKED_BLOCK_BIT) then
                mset(tx, ty, 0)
                add(entities, poof_new(tx * 8, ty * 8))
            end
        end
    end

    function p.update()
        local body = p.body
        local tx, ty = body_tile_coords(body)
        local on_ladder = fget(mget(tx, ty), LADDER_BIT)
        local above_ladder = fget(mget(tx, ty + 1), LADDER_BIT)
        local grounded = body_grounded(body)
        local btnp5 = btn(5) and not action_button_down

        action_button_down = btn(5)
        cooldown_timer = max(0, cooldown_timer - 1 / 30)

        color = state_flags[STATE_FLAG_GREEN_SWORD] and 15
                or state_flags[STATE_FLAG_RED_SWORD] and 8
                or 12
        p.color = color

        if state == "base" then
            local fireball = false

            if charge_timer and state_flags[STATE_FLAG_MAGIC_WAND] then
                if not btn(5) then
                    fireball = charged
                    charge_timer = nil
                    charged = false
                else
                    charge_timer = max(0, charge_timer - 1 / 30)
                    charged = charge_timer <= 0
                end
            end

            local dx = btn(0) and -1 or btn(1) and 1

            local jump = btnp(4) and grounded

            local ladder_dy = btn(2) and on_ladder and -1
                    or btn(3) and above_ladder and 1

            local pickaxe = btnp5
                    and btn(3)
                    and cooldown_timer <= 0
                    and state_flags[STATE_FLAG_PICKAXE]

            local magic_stone = btnp5
                    and btn(2)
                    and cooldown_timer <= 0
                    and rock_body == nil
                    and state_flags[STATE_FLAG_MAGIC_STONE]

            local attack = btnp5
                    and cooldown_timer <= 0
                    and state_flags[STATE_FLAG_SWORD]

            if fireball then
                add(entities, fireball_new(body.x, body.y, p.facing))
                state = "throw"
                p.sprite = PLAYER_SPRITE_ATTACK
                attack_timer = PLAYER_ATTACK_DURATION
                charge_timer = nil
            end
            if pickaxe then
                state = "pickaxe_windup"
                p.sprite = PLAYER_SPRITE_PICKAXE_WINDUP
                attack_timer = PLAYER_PICKAXE_WINDUP_DURATION
                charge_timer = nil
            elseif magic_stone then
                add(entities, magic_stone_new(body.x, body.y, p.facing, "enemy", color))
                state = "throw"
                p.sprite = PLAYER_SPRITE_ATTACK
                attack_timer = PLAYER_ATTACK_DURATION
                charge_timer = nil
            elseif attack then
                local power = 1 + player_attack_bonus()
                state = "attack"
                p.hitbox = hitbox_new("enemy", power, p.facing * 8, 2, 8, 4)
                p.sprite = PLAYER_SPRITE_ATTACK
                attack_timer = PLAYER_ATTACK_DURATION
                charge_timer = nil
            elseif ladder_dy then
                state = "climb"
                body.kinematic = true
                body.x = tx * 8
                body.y += ladder_dy
                p.sprite = PLAYER_SPRITE_CLIMB
                old_facing = p.facing
                charge_timer = nil
            else
                body.vx = (dx or 0) * PLAYER_WALK_SPEED
                body.vy = jump and -PLAYER_JUMP_SPEED or body.vy
                p.sprite = (dx or not grounded) and alternate(PLAYER_SPRITE_WALK, PLAYER_SPRITE, PLAYER_FPS) or PLAYER_SPRITE
                p.facing = dx ~= 0 and dx or p.facing
            end
        elseif state == "climb" then
            if not (on_ladder or above_ladder) or grounded or btnp(4) then
                state = "base"
                body.kinematic = false
                body.vx = 0
                body.vy = 0
                p.sprite = PLAYER_SPRITE
                p.facing = old_facing
                old_facing = nil
            else
                local dy = btn(2) and -1 or btn(3) and 1
                body.y += dy or 0
                p.facing = dy and alternate(1, -1, PLAYER_FPS) or old_facing
            end
        elseif state == "attack" or state == "pickaxe" or state == "throw" then
            attack_timer = max(0, attack_timer - 1 / 30)
            blur_timer = max(0, blur_timer - 1 / 30)
            body.vx = grounded and 0 or body.vx

            if attack_timer <= 0 then
                state = "base"
                p.hitbox = nil
                p.sprite = PLAYER_SPRITE
                cooldown_timer = PLAYER_ATTACK_COOLDOWN_DURATION
                charge_timer = PLAYER_CHARGE_DURATION
            end
        elseif state == "pickaxe_windup" then
            attack_timer = max(0, attack_timer - 1 / 30)
            body.vx = grounded and 0 or body.vx

            if attack_timer <= 0 then
                state = "pickaxe"
                p.hitbox = hitbox_new("enemy", 1, p.facing < 0 and -6 or 2, -4, 12, 15)
                p.sprite = PLAYER_SPRITE_ATTACK
                attack_timer = PLAYER_ATTACK_DURATION
                blur_timer = PLAYER_PICKAXE_BLUR_DURATION
                destroy_cracked_tiles()
                sfx(9)
            end
        end
    end

    function p.draw()
        local body, facing = p.body, p.facing

        if state == "attack" then
            sprite_draw(PLAYER_SPRITE_SWORD, body.x + facing * 8, body.y, facing < 0, color)
        elseif state == "pickaxe_windup" then
            sprite_draw(PLAYER_SPRITE_PICKAXE_ANGLE, body.x + facing * -7, body.y - 4, facing > 0, color)
        elseif state == "pickaxe" then
            if blur_timer > 0 then
                sprite_draw(PLAYER_SPRITE_PICKAXE_BLUR, body.x + (facing < 0 and -8 or 0), body.y - 8, facing < 0, color, 2)
            end

            sprite_draw(PLAYER_SPRITE_PICKAXE, body.x + facing * 8, body.y + 1, facing < 0, color)
        end

        if charged then
            set_pal(color)
            spr(alternate(PLAYER_CHARGE_SPRITE, PLAYER_CHARGE_SPRITE_2, PLAYER_CHARGE_FPS), body.x, body.y)
            pal()
        end
    end

    return p
end
