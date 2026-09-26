function player_death_system_run()
    if player.hurtbox.hp <= 0 then
        state = "player_dead"
    end
end