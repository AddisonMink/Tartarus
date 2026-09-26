LADDER_BIT = 2
SKULL_BLOCK_BIT = 3
CRACKED_BLOCK_BIT = 6
SPIKE_BIT = 4
ROOM_WIDTH = 14
ROOM_HEIGHT = 8

-- first few stage flags are reserved for specific global state.
STATE_FLAG_START_TX = 1
STATE_FLAG_START_TY = 2
STATE_FLAG_SWORD = 3
STATE_FLAG_HEART = 4
STATE_FLAG_PICKAXE = 5
STATE_FLAG_MAGIC_STONE = 6
STATE_FLAG_RED_HEART = 7
STATE_FLAG_RED_SWORD = 8
STATE_FLAG_GIANT_DEAD = 9
STATE_FLAG_DRAGON_DEAD = 10
STATE_FLAG_DEVIL_1_DEAD = 11
STATE_FLAG_DEVIL_2_DEAD = 12
STATE_FLAG_MAGIC_WAND = 13
STATE_FLAG_SQUID_1 = 14
STATE_FLAG_GREEN_SWORD = 15
STATE_FLAGS_LENGTH = 15

-- when map data is loaded for the first time, new flags will be added to keep track of skull blocks.

state = "play"
player_start_tx = 0
player_start_ty = 0
room_tx = 0
room_ty = 0
text_box_content = nil
player = nil
rock_body = nil -- body of a magic stone.
area = nil -- current area name
entities = {} -- list of entities.
state_flags = {} -- array of state flags.
saved_state_flags = {} -- saved game state