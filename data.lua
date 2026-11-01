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
    [DEVIL_SPRITE_CAST] = devil_3_new,
    [MAGIC_WAND_PICKUP_SPRITE] = magic_wand_pickup_new,
    [SQUID_SPRITE] = squid_1_new,
    [SNAKE_SPRITE] = snake_new,
    [SNAKE_SPRITE_2] = snake_new_no_turn,
    [GREEN_SWORD_PICKUP_SPRITE] = green_sword_pickup_new,
    [SWITCH_SPRITE] = switch_new,
    [DEVIL_FIREBALL_SPRITE] = fireball_spawner_new,
    [SWORDSMAN_SPRITE] = swordsman_new,
    [JELLY_SPRITE] = jelly_new,
    [GREEN_HEART_PICKUP_SPRITE] = green_heart_pickup_new,
    [DEVIL_BLOCK_SPRITE_1] = devil_block_1_new,
    [DEVIL_BLOCK_SPRITE_2] = devil_block_2_new,
    [DEVIL_BLOCK_SPRITE_3] = devil_block_3_new,
    [TYPHON_SPRITE] = typhon_new
}

AREA_COLOR = {
    fomor = 13,
    fafnir = 4,
    babel = 9,
    proteus = 2,
    tyrfing = 15,
    typhon = 8
}

AREA_MUSIC = {
    fomor = 8,
    fafnir = 12,
    tyrfing = 5,
    babel = 3,
    proteus = 15
}

AREA_TILE_TO_NAME = {
    [64] = "fomor",
    [73] = "fafnir",
    [94] = "tyrfing",
    [236] = "proteus",
    [124] = "typhon"
}

DEFAULT_AREA_NAME = "babel"

-- Array[(constructor: Function, tx: Int, ty: Int)]
ROOM_DATA = {}

-- Map[room_key: String] = state_flag
ROOM_CLEAR_FLAGS = {}

-- Map[room_key: String] = state_flag
ROOM_SWITCH_FLAGS = {}

-- NOT IDEMPOTENT!
function load_room_data()
    for room_x = 0, 128 / ROOM_WIDTH - 1 do
        for room_y = 0, 40 / ROOM_HEIGHT - 1 do
            local tx = room_x * ROOM_WIDTH
            local ty = room_y * ROOM_HEIGHT
            local key = tx .. "," .. ty
            ROOM_DATA[key] = {}

            for tx = tx, tx + ROOM_WIDTH - 1 do
                for ty = ty, ty + ROOM_HEIGHT - 1 do
                    local tile = mget(tx, ty)

                    if tile == PLAYER_SPRITE then
                        global_start_tx = tx
                        global_start_ty = ty
                    elseif fget(tile, SKULL_BLOCK_BIT) then
                        STATE_FLAGS_LENGTH += 1
                        ROOM_CLEAR_FLAGS[key] = STATE_FLAGS_LENGTH
                    elseif fget(tile, SWITCH_BLOCK_BIT) then
                        STATE_FLAGS_LENGTH += 1
                        ROOM_SWITCH_FLAGS[key] = STATE_FLAGS_LENGTH
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
    mset(global_start_tx, global_start_ty, 0)
    local first_tile = mget(tx, ty)
    local old_area = area

    room_tx = tx
    room_ty = ty
    rock_body = nil
    entities = { player }
    area = AREA_TILE_TO_NAME[first_tile] or DEFAULT_AREA_NAME
    if area ~= old_area then
        music(AREA_MUSIC[area] or -1)
    end

    for spawn in all(ROOM_DATA[room_tx .. "," .. room_ty]) do
        local constructor, tx, ty = unpack(spawn)
        local entity = constructor(tx, ty)

        if entity and entity.hurtbox and entity.hurtbox.layer == "enemy" then
            entity.color = AREA_COLOR[area]
        end

        add(entities, entity)
    end
end

function new_game()
    for i = 1, STATE_FLAGS_LENGTH do
        dset(i, 0)
    end

    state_flags = {}
    dset(STATE_FLAG_START_TX, global_start_tx)
    dset(STATE_FLAG_START_TY, global_start_ty)
end

function load_game(state_flag_overrides)
    state_flag_overrides = state_flag_overrides or {}
    -- load saved state flags
    state_flags[STATE_FLAG_START_TX] = dget(STATE_FLAG_START_TX)
    state_flags[STATE_FLAG_START_TY] = dget(STATE_FLAG_START_TY)
    for i = 3, STATE_FLAGS_LENGTH do
        local saved_value = dget(i) == 1
        local override_value = state_flag_overrides[i]

        if override_value ~= nil then
            saved_value = override_value == 1
        end

        state_flags[i] = saved_value
    end

    player = player_new(state_flags[STATE_FLAG_START_TX], state_flags[STATE_FLAG_START_TY])
    init_room(0, 0)
end

function save_game(start_tx, start_ty)
    state_flags[STATE_FLAG_START_TX] = start_tx
    state_flags[STATE_FLAG_START_TY] = start_ty
    dset(STATE_FLAG_START_TX, state_flags[STATE_FLAG_START_TX])
    dset(STATE_FLAG_START_TY, state_flags[STATE_FLAG_START_TY])

    for i = 3, STATE_FLAGS_LENGTH do
        dset(i, state_flags[i] and 1 or 0)
    end

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

    -- remove switch blocks in activated rooms
    for k, v in pairs(ROOM_SWITCH_FLAGS) do
        local tx, ty = unpack(split(k, ","))

        if state_flags[v] then
            for tx = tx, tx + ROOM_WIDTH - 1 do
                for ty = ty, ty + ROOM_HEIGHT - 1 do
                    if fget(mget(tx, ty), SWITCH_BLOCK_BIT) then
                        mset(tx, ty, 0)
                    end
                end
            end
        end
    end
end