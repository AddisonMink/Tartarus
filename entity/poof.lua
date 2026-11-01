POOF_SPRITE = 8
POOF_SPRITE_2 = 9
POOF_DURATION = 0.25

function poof_new(x, y)
    sfx(3)
    local timer = POOF_DURATION
    local e = {
        body = body_new(x, y, true),
        sprite = POOF_SPRITE
    }

    function e.update()
        timer = max(0, timer - 1 / 30)

        if timer < POOF_DURATION / 2 then
            e.sprite = POOF_SPRITE_2
        end

        if timer <= 0 then
            del(entities, e)
        end
    end

    return e
end
