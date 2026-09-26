function spike_system_run()
    local tx, ty = body_tile_coords(player.body)

    local spike_kill = fget(mget(tx, ty), SPIKE_BIT)
            and not body_grounded(player.body)
            and player.body.vy > 0
            and not player.body.kinematic
            and player.body.y < ty * 8

    if spike_kill then
        player.hurtbox.hp = 0
    end
end