function player_death_system_run()
    if player.hurtbox.hp <= 0 then
        state = "player_dead"
        music(-1)
    end
end