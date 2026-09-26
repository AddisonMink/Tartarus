POOF_SPRITE = 8
POOF_SPRITE_2 = 9
POOF_DURATION = 0.25

function poof_new(x, y)
    return {
        body = body_new(x, y, true),
        sprite = POOF_SPRITE,
        timer = POOF_DURATION,
        update = poof_update
    }
end

function poof_update(self)
    tick_down(self, "timer")

    if self.timer < POOF_DURATION / 2 then
        self.sprite = POOF_SPRITE_2
    end

    if self.timer <= 0 then
        del(entities, self)
    end
end