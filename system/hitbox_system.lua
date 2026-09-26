JUST_HIT_DURATION = 0.125
INVINCIBLE_DURATION = 0.5

function hitbox_system_run()
    for e in all(entities) do
        if e.hitbox then
            for e2 in all(entities) do
                if e2.hurtbox and e ~= e2 and _private_hit(e, e2) then
                    _private_apply_hitbox(e, e2)
                end
            end
        end
    end
end

function _private_hit(e, e2)
    local hitbox = e.hitbox
    local hurtbox = e2.hurtbox

    local hit_x = hitbox.x + e.body.x
    local hit_x2 = hit_x + hitbox.w - 1

    local hurt_x = hurtbox.x + e2.body.x
    local hurt_x2 = hurt_x + hurtbox.w - 1

    local hit_y = hitbox.y + e.body.y
    local hit_y2 = hit_y + hitbox.h - 1

    local hurt_y = hurtbox.y + e2.body.y
    local hurt_y2 = hurt_y + hurtbox.h - 1

    return hitbox.layer == hurtbox.layer
            and hurtbox.invincible_timer <= 0
            and hit_x <= hurt_x2
            and hit_x2 >= hurt_x
            and hit_y <= hurt_y2
            and hit_y2 >= hurt_y
end

function _private_apply_hitbox(e, e2)
    e2.hurtbox.hp -= e.hitbox.damage
    e2.hurtbox.just_hit_timer = JUST_HIT_DURATION
    e2.hurtbox.invincible_timer = INVINCIBLE_DURATION
end