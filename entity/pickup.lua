SWORD_PICKUP_SPRITE = 13
HEART_PICKUP_SPRITE = 15
PICKAXE_PICKUP_SPRITE = 50
MAGIC_STONE_PICKUP_SPRITE = 52
RED_HEART_PICKUP_SPRITE = 53
RED_SWORD_PICKUP_SPRITE = 54
MAGIC_WAND_PICKUP_SPRITE = 57
GREEN_SWORD_PICKUP_SPRITE = 55

PICKUP_TEXT_BOX_CONTENT = {
    sword = {
        "fOUND bLUE sWORD!",
        "pRESS \151 TO ATTACK"
    },
    heart = {
        "fOUND bLUE hEART!",
        "\135 INCREASED"
    },
    pickaxe = {
        "pLUNDERED fAFNIR'S",
        "pICKAXE!",
        "hOLD \131 + press \151",
        "TO BREAK CRACKED TILES"
    },
    magic_stone = {
        "pLUNDERED fOMOR'S",
        "mAGIC sTONE!",
        "hOLD \148 + press \151",
        "TO THROW. yOU CAN STAND",
        "ON IT"
    },
    red_heart = {
        "fOUND rED hEART!",
        "\135 INCREASED"
    },
    red_sword = {
        "fOUND rED sWORD!",
        "iT'S STRONGER THAN",
        "THE BLUE SWORD"
    },
    magic_wand = {
        "pLUNDERED bABEL'S",
        "mAGIC wAND!",
        "aFTER ATTACKING, HOLD",
        "\151 TO CHARGE, THEN",
        "RELEASE TO CAST A",
        "SPELL"
    },
    green_sword = {
        "fOUND gREEN sWORD!",
        "tHE STRONGEST SWORD",
        "OF ALL!"
    }
}

function pickup_new(tx, ty, sprite, flag, content_key)
    if state_flags[flag] then return end

    return {
        body = body_new(tx * 8, ty * 8),
        sprite = sprite,
        flag = flag,
        content_key = content_key,
        update = pickup_update
    }
end

function pickup_update(self)
    if body_on_same_tile(self.body, player.body) then
        state_flags[self.flag] = true
        del(entities, self)
        text_box_content = PICKUP_TEXT_BOX_CONTENT[self.content_key]
    end
end

function sword_pickup_new(tx, ty)
    return pickup_new(tx, ty, SWORD_PICKUP_SPRITE, STATE_FLAG_SWORD, "sword")
end

function heart_pickup_new(tx, ty)
    return pickup_new(tx, ty, HEART_PICKUP_SPRITE, STATE_FLAG_HEART, "heart")
end

function pickaxe_pickup_new(tx, ty)
    return pickup_new(tx, ty, PICKAXE_PICKUP_SPRITE, STATE_FLAG_PICKAXE, "pickaxe")
end

function magic_stone_pickup_new(tx, ty)
    return pickup_new(tx, ty, MAGIC_STONE_PICKUP_SPRITE, STATE_FLAG_MAGIC_STONE, "magic_stone")
end

function red_heart_pickup_new(tx, ty)
    return pickup_new(tx, ty, RED_HEART_PICKUP_SPRITE, STATE_FLAG_RED_HEART, "red_heart")
end

function red_sword_pickup_new(tx, ty)
    return pickup_new(tx, ty, RED_SWORD_PICKUP_SPRITE, STATE_FLAG_RED_SWORD, "red_sword")
end

function magic_wand_pickup_new(tx, ty)
    return pickup_new(tx, ty, MAGIC_WAND_PICKUP_SPRITE, STATE_FLAG_MAGIC_WAND, "magic_wand")
end

function green_sword_pickup_new(tx, ty)
    return pickup_new(tx, ty, GREEN_SWORD_PICKUP_SPRITE, STATE_FLAG_GREEN_SWORD, "green_sword")
end