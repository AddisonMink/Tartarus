# get command line arg as string
entity_name="$1"

# make anew file entity/<entity_name>.lua
touch "entity/${entity_name}.lua"

# add boilerplate code to the new entity file
echo "function ${entity_name}_new(x, y)
    return {
        body = body_new(x, y),
        update = ${entity_name}_update
    }
end

function ${entity_name}_update(self)
    -- update logic for ${entity_name} goes here
end" > "entity/${entity_name}.lua"