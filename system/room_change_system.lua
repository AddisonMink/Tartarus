function room_change_system()
    local tx, ty = body_tile_coords(player.body)
    local rtx = flr(tx / ROOM_WIDTH) * ROOM_WIDTH
    local rty = flr(ty / ROOM_HEIGHT) * ROOM_HEIGHT

    if rtx ~= room_tx or rty ~= room_ty then
        init_room(rtx, rty)
    end
end