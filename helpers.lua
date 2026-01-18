--=== Help functions ===--
FiveSecondRule.pop = function(list)
    if table.getn(list) == 0 then return nil end
    local el = list[1]
    for i = 1, table.getn(list) - 1 do
       list[i] = list[i + 1]
    end
    list[table.getn(list)] = nil  -- remove duplicate last element
    return el
end

FiveSecondRule.split_into_words = function(str)
    local words = {}
    for word in string.gfind(str, "%S+") do
        table.insert(words, word)
    end
    if table.getn(words) > 0 then return words else return nil end
end

FiveSecondRule.is_valid_color = function(color)
    return type(color) == "string" and string.find(string.lower(color), "^%x%x%x%x%x%x$") ~= nil
end
