function tile_coords(x, y)
    return flr(x / 8), flr(y / 8)
end

function alternate(val_1, val_2, fps)
    return flr(time() * fps) % 2 == 0 and val_1 or val_2
end

function set_pal(color)
    for i = 0, 15 do
        pal(i, color)
    end
end

function tick_down(object, field)
    local value = object[field]
    object[field] = max(0, object[field] - 1 / 30)
end

function sprite_draw(s, x, y, flip_x, color, size)
    size = size or 1
    set_pal(0)
    spr(s, x - 1, y, size, size, flip_x)
    spr(s, x + 1, y, size, size, flip_x)
    spr(s, x, y - 1, size, size, flip_x)

    if color then set_pal(color) else pal() end
    spr(s, x, y, size, size, flip_x)
    pal()
end

function text_width(text)
    local length = 0

    local wide_chars = {
        ["\131"] = 8,
        ["\148"] = 8,
        ["\142"] = 8,
        ["\151"] = 8,
        ["\135"] = 8
    }

    for c in all(text) do
        length += wide_chars[c] or 4
    end

    return length
end

function draw_frame(x, y, w, h, color)
    x -= 1
    y -= 1
    local x2 = x + w + 1
    local y2 = y + h + 1
    rect(x, y, x2, y2, color)
end