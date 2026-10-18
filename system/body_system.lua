GRAVITY = 0.2
TERMINAL_VELOCITY = 5

function body_system_run()
    if text_box_content then return end

    for e in all(entities) do
        if e.body then
            e.body.vy = min(e.body.vy + GRAVITY, TERMINAL_VELOCITY)

            body_update(e.body)

            if body_grounded(e.body) then
                e.body.vy = 0
            end
        end
    end
end