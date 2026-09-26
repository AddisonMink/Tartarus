function hurtbox_new(layer, hp, x, y, w, h)
    return {
        layer = layer,
        hp = hp,
        x = x,
        y = y,
        w = w,
        h = h,
        just_hit_timer = 0,
        invincible_timer = 0,
    }
end