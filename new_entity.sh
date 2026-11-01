# get command line arg as string
entity_name="$1"

# make anew file entity/<entity_name>.lua
touch "entity/${entity_name}.lua"

# add boilerplate code to the new entity file
echo "function ${entity_name}_new(x, y)
    local e = {
        body = body_new(x, y)
    }

    function e.update()
        -- update logic for ${entity_name} goes here
    end

    return e
end" > "entity/${entity_name}.lua"
