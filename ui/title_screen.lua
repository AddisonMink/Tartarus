function title_screen_draw()
    local new_game_str = "nEW gAME"
    local continue_str = "cONTINUE"
    local options_y = 80
    local selected_color = alternate(12, 13, 2)
    local x = -4
    local x2 = x + 120 - 1
    local y = -4
    local y2 = y + 120 - 1

    camera(-8, -8)
    rect(x, y, x2, y2, 13)

    clip(0, 0, 128, 72)
    map()
    clip()

    for tx = 0, 13 do
        for ty = 8, 13 do
            spr(64, tx * 8, ty * 8)
        end
    end

    local x = 32
    rectfill(32, options_y - 5, 76, options_y + 20, 0)
    print(new_game_str, 64 - #new_game_str * 2 - 8, options_y, menu_index == 1 and selected_color or 13)
    print(continue_str, 64 - #continue_str * 2 - 8, options_y + 10, menu_index == 2 and selected_color or 13)
end