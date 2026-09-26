function hurtbox_system_run()
    for e in all(entities) do
        if e.hurtbox then
            tick_down(e.hurtbox, "just_hit_timer")
            tick_down(e.hurtbox, "invincible_timer")

            if e.hurtbox.hp <= 0 then
                add(entities, poof_new(e.body.x, e.body.y))
                if e.die then e:die() end
                del(entities, e)
            end
        end
    end
end