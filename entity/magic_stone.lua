MAGIC_STONE_SPRITE = 52
MAGIC_STONE_SPEED_X = 1
MAGIC_STONE_SPEED_Y = -1
MAGIC_STONE_DURATION = 2

function magic_stone_new(x, y, facing, layer, color)
    local body = body_new(x, y - 1)
    body.vx = facing * MAGIC_STONE_SPEED_X
    body.vy = MAGIC_STONE_SPEED_Y

    local state = "flying"
    local timer = 0
    local e = {
        body = body,
        hitbox = hitbox_new(layer, 1, 1, 1, 6, 6),
        sprite = MAGIC_STONE_SPRITE,
        color = color
    }

    function e.update()
        if state == "flying" and body_grounded(body) then
            state = "grounded"
            body.vx = 0
            body.vy = 0
            e.hitbox = nil
            timer = MAGIC_STONE_DURATION
            rock_body = body
            sfx(7)
        elseif state == "grounded" then
            timer = max(0, timer - 1 / 30)
            if timer <= 0 then
                add(entities, poof_new(body.x, body.y))
                del(entities, e)
                rock_body = nil
            end
        end
    end

    return e
end
