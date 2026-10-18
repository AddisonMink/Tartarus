FIREBALL_SPAWNER_INTERVAL = 2
FIREBALL_MIN_DIST = 24

function fireball_spawner_new()
    return {
        timer = FIREBALL_SPAWNER_INTERVAL,
        update = fireball_spawner_update
    }
end

function fireball_spawner_update(self)
    tick_down(self, "timer")
    if self.timer <= 0 then
        local x = (room_tx + rnd(ROOM_WIDTH)) * 8
        local y = (room_ty + rnd(ROOM_HEIGHT)) * 8
        local dist_x = x - player.body.x
        local dist_y = y - player.body.y
        local dist = sqrt(dist_x * dist_x + dist_y * dist_y)

        if dist >= FIREBALL_MIN_DIST then
            self.timer = FIREBALL_SPAWNER_INTERVAL
            add(entities, devil_fireball_new(x, y))
        end
    end
end