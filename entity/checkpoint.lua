CHECKPOINT_SPRITE = 14
CHECKPOINT_INTERVAL = 2

function checkpoint_new(tx, ty)
    local timer = 0
    local e = {
        body = body_new(tx * 8, ty * 8, true),
        sprite = CHECKPOINT_SPRITE
    }

    function e.update()
        timer = max(0, timer - 1 / 30)

        if timer <= 0 then
            e.sprite = CHECKPOINT_SPRITE

            if body_on_same_tile(e.body, player.body) then
                local tx, ty = body_tile_coords(e.body)
                add(entities, poof_new(e.body.x, e.body.y))
                timer = CHECKPOINT_INTERVAL
                e.sprite = nil
                save_game(tx, ty)
            end
        end
    end

    function e.draw()
        if not e.sprite then
            local message = "checkpoint"
            print(message, e.body.x + 4 - #message * 2, e.body.y - 8, 12)
        end
    end

    return e
end
