WINDOW_CAMERA_OFFSET_X = 64 - ROOM_WIDTH * 4
WINDOW_CAMERA_OFFSET_Y = 8
BOTTOM_PANE_OFFSET_Y = ROOM_HEIGHT * 8 + 8
BOTTOM_PANE_HEIGHT = 40
INVINCIBLE_FLASH_FPS = 12
INVENTORY_ROWS = 2
INVENTORY_COLS = 5

INVENTORY_FLAGS = {
    STATE_FLAG_SWORD,
    STATE_FLAG_RED_SWORD,
    STATE_FLAG_GREEN_SWORD,
    STATE_FLAG_HEART,
    STATE_FLAG_RED_HEART,
    STATE_FLAG_GREEN_HEART,
    STATE_FLAG_MAGIC_STONE,
    STATE_FLAG_PICKAXE,
    STATE_FLAG_MAGIC_WAND,
    STATE_FLAG_BRAIN,
}

INVENTORY_SPRITES = {
    [STATE_FLAG_SWORD] = SWORD_PICKUP_SPRITE,
    [STATE_FLAG_RED_SWORD] = RED_SWORD_PICKUP_SPRITE,
    [STATE_FLAG_GREEN_SWORD] = GREEN_SWORD_PICKUP_SPRITE,
    [STATE_FLAG_HEART] = HEART_PICKUP_SPRITE,
    [STATE_FLAG_RED_HEART] = RED_HEART_PICKUP_SPRITE,
    [STATE_FLAG_MAGIC_STONE] = MAGIC_STONE_PICKUP_SPRITE,
    [STATE_FLAG_PICKAXE] = PICKAXE_PICKUP_SPRITE,
    [STATE_FLAG_MAGIC_WAND] = MAGIC_WAND_PICKUP_SPRITE,
    [STATE_FLAG_BRAIN] = BRAIN_PICKUP_SPRITE,
    [STATE_FLAG_GREEN_HEART] = GREEN_HEART_PICKUP_SPRITE
}

function draw_system_run()
    local room_x = room_tx * 8
    local room_y = room_ty * 8
    local camera_x = room_x - WINDOW_CAMERA_OFFSET_X
    local camera_y = room_y - WINDOW_CAMERA_OFFSET_Y
    local bottom_pane_y = room_y + BOTTOM_PANE_OFFSET_Y

    camera(camera_x, camera_y)
    _private_draw_top_bar()
    draw_frame(room_x, room_y, ROOM_WIDTH * 8, ROOM_HEIGHT * 8, 12)
    clip(WINDOW_CAMERA_OFFSET_X, WINDOW_CAMERA_OFFSET_Y, ROOM_WIDTH * 8, ROOM_HEIGHT * 8)
    map()

    for entity in all(entities) do
        _private_draw_entity(entity)
    end

    if player.hurtbox.hp > 0 then
        _private_draw_entity(player)
    end

    if text_box_content then
        _private_draw_text_box(camera_x, camera_y)
    end

    clip()

    draw_frame(room_x, bottom_pane_y, ROOM_WIDTH * 8, BOTTOM_PANE_HEIGHT, 12)
    _private_draw_inventory()
end

function _private_draw_top_bar()
    local x = room_tx * 8
    local y = room_ty * 8 - 8
    local first_tile = mget(room_tx, room_ty)

    -- draw health bar
    for i = 1, player_max_hp() do
        local c1 = state_flags[STATE_FLAG_RED_SWORD] and 8 or 12
        local c2 = state_flags[STATE_FLAG_RED_SWORD] and 2 or 1
        local color = i <= player.hurtbox.hp and c1 or c2
        print("♥", x + (i - 1) * 8, y, color)
    end

    local x = room_tx * 8 + ROOM_WIDTH * 8 - #area * 4
    print(area, x, y, AREA_COLOR[area] or 7)
end

function _private_draw_entity(e)
    if e.sprite or e.big_sprite then
        local s = e.sprite
        local size = 1
        local x = e.body.x
        local y = e.body.y
        local color = e.hurtbox and e.hurtbox.just_hit_timer > 0 and 7 or e.color
        local flash = e.hurtbox and e.hurtbox.invincible_timer > 0 and alternate(true, false, INVINCIBLE_FLASH_FPS)
        local flip = e.facing and e.facing < 0

        if e.big_sprite then
            s = e.big_sprite
            size = 2
            x -= 4
            y -= 8
        end

        if not flash then
            sprite_draw(s, x, y, flip, color, size)
        end
    end

    if e.draw then
        e:draw()
    end

    --if e.hitbox then
    --    local x = e.hitbox.x + e.body.x
    --    local x2 = x + e.hitbox.w
    --    local y = e.hitbox.y + e.body.y
    --    local y2 = y + e.hitbox.h
    --    rect(x, y, x2, y2, 7)
    --end

    --if e.hurtbox then
    --    local x = e.hurtbox.x + e.body.x
    --    local x2 = x + e.hurtbox.w
    --    local y = e.hurtbox.y + e.body.y
    --    local y2 = y + e.hurtbox.h
    --    rect(x, y, x2, y2, 11)
    --end
end

function _private_draw_text_box()
    local widths, max_width = {}, 0
    for line in all(text_box_content) do
        local w = text_width(line)
        add(widths, w)
        max_width = max(max_width, w)
    end

    local x = room_tx * 8 + ROOM_WIDTH * 4 - max_width / 2
    local y = room_ty * 8 + ROOM_HEIGHT * 4 - (#text_box_content * 4)

    rectfill(x - 4, y - 4, x + max_width + 4, y + #text_box_content * 8, 0)
    rect(x - 4, y - 4, x + max_width + 4, y + #text_box_content * 8, 12)
    for i, line in ipairs(text_box_content) do
        local x = x + max_width / 2 - widths[i] / 2
        print(line, x, y, 12)
        y += 8
    end
end

function _private_draw_inventory()
    for r = 1, INVENTORY_ROWS do
        for c = 1, INVENTORY_COLS do
            local i = (r - 1) * INVENTORY_COLS + c
            local x = room_tx * 8 + (c - 1) * 16 + 20 - 1
            local y = room_ty * 8 + BOTTOM_PANE_OFFSET_Y + (r - 1) * 16 + 8 - 1
            local flag = INVENTORY_FLAGS[i]
            local sprite = state_flags[flag] and INVENTORY_SPRITES[flag]
            draw_frame(x, y, 10, 10, sprite and 12 or 1)
            if sprite then
                spr(sprite, x + 1, y + 1)
            end
        end
    end
end