local function switch(val, actions)
    local action = actions[val] or actions.default or function()
    end
    return action()
end
return switch
