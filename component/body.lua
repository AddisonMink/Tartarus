-- ASSUMPTION: Sometimes a globl variable named rock_body will be set to a body.
-- If rock_body is set, it will be used for collision checks with falling bodies.

-- Bodies are assumed to be 6x8 rectangles centered within the 8x8 rect with top left corner at (body.x, body.y)

function body_new(x, y, kinematic)
    return { x = x, y = y, vx = 0, vy = 0, kinematic = kinematic }
end

function body_tile_coords(body)
    return tile_coords(body.x + 4, body.y + 4)
end

function body_intersects_tile(body, tx, ty)
    local tx1 = tx * 8
    local ty1 = ty * 8
    local bx1 = body.x
    local by1 = body.y
    local bx2 = body.x + 6
    local by2 = body.y + 7
    local tx2 = tx1 + 7
    local ty2 = ty1 + 7

    return bx1 <= tx2 and bx2 >= tx1 and by1 <= ty2 and by2 >= ty1
end

function body_on_same_tile(body1, body2)
    local tx1, ty1 = body_tile_coords(body1)
    local tx2, ty2 = body_tile_coords(body2)
    return tx1 == tx2 and ty1 == ty2
end

function body_contains_point(body, x, y)
    return x >= body.x
            and x < body.x + 7
            and y >= body.y
            and y < body.y + 7
end

function body_point_collides(x, y, falling, rock_body)
    local tile = mget(tile_coords(x, y))

    return fget(tile, 0)
            or falling and fget(tile, 1) and y % 8 < 1
            or falling and rock_body and body_contains_point(rock_body, x, y) and abs(rock_body.y - y) < 1
end

function body_would_collides(body, dx, dy)
    local x = body.x + dx
    local y = body.y + dy
    local falling = dy > 0
    local rock_body = rock_body ~= body and rock_body

    return body_point_collides(x + 1, y)
            or body_point_collides(x + 6, y)
            or body_point_collides(x + 1, y + 7, falling, rock_body)
            or body_point_collides(x + 6, y + 7, falling, rock_body)
end

function body_grounded(body)
    return body_would_collides(body, 0, 1)
end

function body_update(body)
    if body.kinematic then return end

    local dist_x = abs(body.vx)
    local dir_x = sgn(body.vx)
    local diff_x = flr(dist_x)
    local frac_x = dist_x - diff_x

    local dist_y = abs(body.vy)
    local dir_y = sgn(body.vy)
    local diff_y = flr(dist_y)
    local frac_y = dist_y - diff_y

    for i = 1, diff_x do
        if body_would_collides(body, dir_x, 0) then
            break
        end
        body.x += dir_x
    end

    if not body_would_collides(body, frac_x * dir_x, 0) then
        body.x += frac_x * dir_x
    end

    for i = 1, diff_y do
        if body_would_collides(body, 0, dir_y) then
            break
        end
        body.y += dir_y
    end

    if not body_would_collides(body, 0, frac_y * dir_y) then
        body.y += frac_y * dir_y
    end
end