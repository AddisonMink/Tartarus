SPAWN_DATA = {
    [ZOMBIE_SPRITE] = zombie_new,
    [BAT_SPRITE_HANG] = bat_new,
    [SWORD_PICKUP_SPRITE] = sword_pickup_new,
    [CHECKPOINT_SPRITE] = checkpoint_new,
    [HEART_PICKUP_SPRITE] = heart_pickup_new,
    [DRAGON_SPRITE] = dragon_new,
    [PICKAXE_PICKUP_SPRITE] = pickaxe_pickup_new,
    [MAGIC_STONE_PICKUP_SPRITE] = magic_stone_pickup_new,
    [GIANT_SPRITE] = giant_new,
    [RED_HEART_PICKUP_SPRITE] = red_heart_pickup_new,
    [RED_SWORD_PICKUP_SPRITE] = red_sword_pickup_new,
    [DEVIL_SPRITE] = devil_1_new,
    [DEVIL_SPRITE_2] = devil_2_new,
    [MAGIC_WAND_PICKUP_SPRITE] = magic_wand_pickup_new,
    [SQUID_SPRITE] = squid_1_new,
    [SNAKE_SPRITE] = snake_new,
    [GREEN_SWORD_PICKUP_SPRITE] = green_sword_pickup_new
}

AREA_COLOR = {
    fomor = 13,
    fafnir = 4,
    babel = 9,
    proteus = 2
}

-- Array[(constructor: Function, tx: Int, ty: Int)]
ROOM_DATA = {}

-- Map[room_key: String] = state_flag
ROOM_CLEAR_FLAGS = {}

-- NOT IDEMPOTENT!
function load_room_data()
    for room_x = 0, 128 / ROOM_WIDTH - 1 do
        for room_y = 0, 64 / ROOM_HEIGHT - 1 do
            local tx = room_x * ROOM_WIDTH
            local ty = room_y * ROOM_HEIGHT
            local key = tx .. "," .. ty
            ROOM_DATA[key] = {}

            for tx = tx, tx + ROOM_WIDTH - 1 do
                for ty = ty, ty + ROOM_HEIGHT - 1 do
                    local tile = mget(tx, ty)
                    if tile == PLAYER_SPRITE then
                        saved_state_flags[STATE_FLAG_START_TX] = tx
                        saved_state_flags[STATE_FLAG_START_TY] = ty
                        player_start_tx = tx
                        player_start_ty = ty
                    elseif fget(tile, SKULL_BLOCK_BIT) then
                        STATE_FLAGS_LENGTH += 1
                        ROOM_CLEAR_FLAGS[key] = STATE_FLAGS_LENGTH
                    elseif SPAWN_DATA[tile] then
                        add(ROOM_DATA[key], { SPAWN_DATA[tile], tx, ty })
                    end
                end
            end
        end
    end
end

function init_room(tx, ty)
    _private_load_map()
    local first_tile = mget(tx, ty)

    room_tx = tx
    room_ty = ty
    rock_body = nil
    entities = { player }

    area = first_tile == 64 and "fomor"
            or first_tile == 73 and "fafnir"
            or first_tile == 120 and "proteus"
            or "babel"

    for spawn in all(ROOM_DATA[room_tx .. "," .. room_ty]) do
        local constructor, tx, ty = unpack(spawn)
        local entity = constructor(tx, ty)

        if entity and entity.hurtbox and entity.hurtbox.layer == "enemy" then
            entity.color = AREA_COLOR[area]
        end

        add(entities, entity)
    end
end

function load_game()
    -- load saved state flags
    for i = 1, STATE_FLAGS_LENGTH do
        state_flags[i] = saved_state_flags[i]
    end

    _private_load_map()

    local start_tx = state_flags[STATE_FLAG_START_TX]
    local start_ty = state_flags[STATE_FLAG_START_TY]

    mset(player_start_tx, player_start_ty, 0)
    player = player_new(start_tx, start_ty)
    init_room(0, 0)
end

function save_game(start_tx, start_ty)
    for i = 1, STATE_FLAGS_LENGTH do
        saved_state_flags[i] = state_flags[i]
    end

    saved_state_flags[STATE_FLAG_START_TX] = start_tx
    saved_state_flags[STATE_FLAG_START_TY] = start_ty
    player.hurtbox.hp = player_max_hp()
end

function _private_load_map()
    reload(0x1000, 0x1000, 0x1000)
    reload(0x2000, 0x2000, 0x1000)

    -- remove entity tiles
    for key, data in pairs(ROOM_DATA) do
        for spawn in all(data) do
            local constructor, tx, ty = unpack(spawn)
            mset(tx, ty, 0)
        end
    end

    -- remove skull blocks in cleared rooms.
    for k, v in pairs(ROOM_CLEAR_FLAGS) do
        local tx, ty = unpack(split(k, ","))

        if state_flags[v] then
            for tx = tx, tx + ROOM_WIDTH - 1 do
                for ty = ty, ty + ROOM_HEIGHT - 1 do
                    if fget(mget(tx, ty), SKULL_BLOCK_BIT) then
                        mset(tx, ty, 0)
                    end
                end
            end
        end
    end

    mset(player_start_tx, player_start_ty, 0)
end