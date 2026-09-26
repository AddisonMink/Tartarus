function update_system()
    if text_box_content then
        if btnp(5) then
            text_box_content = nil
        end
        return
    end

    for entity in all(entities) do
        if entity.update then entity:update() end
    end
end