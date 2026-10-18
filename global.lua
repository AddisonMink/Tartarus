LADDER_BIT = 2
SKULL_BLOCK_BIT = 3
CRACKED_BLOCK_BIT = 6
SWITCH_BLOCK_BIT = 7
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
STATE_FLAG_DEVIL_3_DEAD = 13
STATE_FLAG_MAGIC_WAND = 14
STATE_FLAG_GREEN_SWORD = 15
STATE_FLAG_GREEN_HEART = 16
STATE_FLAG_SWORDSMAN_DEAD = 17
STATE_FLAG_BRAIN = 18
STATE_FLAG_TYPHON_DEAD = 19
STATE_FLAGS_LENGTH = 19

-- when map data is loaded for the first time, new flags will be added to keep track of skull blocks and switch blocks.

-- ephemeral global state. reset on game start and continue.
global_start_tx = 0 -- initial spawn tx for a new game
global_start_ty = 0 -- initial spawn ty for a new game
state = "title"
menu_index = 1
room_tx = 0
room_ty = 0
text_box_content = nil
player = nil
rock_body = nil -- body of a magic stone.
area = nil -- current area name
entities = {} -- list of entities.
state_flags = {} -- array of state flags.
debug_state_flag_overrides = {} -- list of state flags to set to true for debug purposes