CHECKPOINT_SPRITE = 14
CHECKPOINT_INTERVAL = 2

function checkpoint_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8, true),
        sprite = CHECKPOINT_SPRITE,
        timer = 0,
        update = checkpoint_update,
        draw = checkpoint_draw
    }
end

function checkpoint_update(self)
    tick_down(self, "timer")

    if self.timer <= 0 then
        self.sprite = CHECKPOINT_SPRITE

        if body_on_same_tile(self.body, player.body) then
            local tx, ty = body_tile_coords(self.body)
            add(entities, poof_new(self.body.x, self.body.y))
            self.timer = CHECKPOINT_INTERVAL
            self.sprite = nil
            save_game(tx, ty)
        end
    end
end

function checkpoint_draw(self)
    if not self.sprite then
        local message = "checkpoint"
        local x = self.body.x + 4 - #message * 2
        print(message, x, self.body.y - 8, 12)
    end
end