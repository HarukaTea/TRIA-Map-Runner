
local tableUtils = {}

tableUtils.Keys = function(tbl: { any }) : { string }
    local keys = table.create(#tbl)

    for key: string in tbl do
        table.insert(keys, key)
    end

    return keys
end
tableUtils.Values = function(tbl: { any }) : { any }
    local values = table.create(#tbl)

    for _, value in tbl do
        table.insert(values, value)
    end

    return values
end
tableUtils.IsEmpty = function(tbl: { any }) : boolean
    return next(tbl) == nil
end
tableUtils.Filter = function(tbl: { any }, predicate: (val: any, key: any, tbl: { table }) -> boolean) : { any }
    local newT = table.create(#tbl)

    if #tbl > 0 then
        local n = 0
        for i, v in tbl do
            if predicate(v, i, tbl) then
                n += 1
                newT[n] = v
            end
        end
    else
        for k, v in tbl do
            if predicate(v, k, tbl) then
                newT[k] = v
            end
        end
    end

    return newT
end
tableUtils.Cut = function(tbl: { any }, len: number) : { any }
    local n = #tbl
    len = math.clamp(len, 1, n)

    return if len == n then table.clone(tbl) else table.move(tbl, 1, len, 1, table.create(len))
end
tableUtils.CheckForSome = function(tbl: { any }, callback: (val: any, key: any, tbl: { table }) -> boolean) : boolean
    for k, v in tbl do
        if callback(v, k, tbl) then
            return true
        end
    end

    return false
end
tableUtils.CheckForEvery = function(tbl: { any }, callback: (val: any, key: any, tbl: { table }) -> boolean) : boolean
    for k, v in tbl do
        if not callback(v, k, tbl) then
            return false
        end
    end

    return true
end
tableUtils.Find = function(tbl: { any }, callback: (val: any, key: any, tbl: { table }) -> boolean) : (Value?, Key?)
    for k, v in tbl do
        if callback(v, k, tbl) then
            return v, k
        end
    end

    return nil, nil
end
tableUtils.Map = function(tbl: { any }, callback: (val: any, key: any, tbl: { table }) -> any) : { any }
    local newT = table.create(#tbl)

    for k, v in tbl do
        newT[k] = callback(v, k, tbl)
    end

    return newT
end
tableUtils.Merge = function(tbl1: { any }, tbl2: { any })
    local newT = table.clone(tbl1)

    for _, v in tbl2 do
        table.insert(newT, v)
    end

    return newT
end
tableUtils.CountDictLength = function(dict: { [any]: any }) : number
    local count = 0

    for _, _ in dict do
        count += 1
    end

    return count
end
tableUtils.MakePackage = function(t: { any }, whiteList: { string }) : { any }
    local newT = {}

    for key: string, val: any in table.clone(t) do
        if table.find(whiteList, key) then
            newT[key] = val
        end
    end

    return newT
end
tableUtils.CopyTableExcept = function(t: { any }, except: { string }, shouldIncludeFunc: boolean?) : { any }
    local newT = {}

    for key: string, val: any in t do
        if not shouldIncludeFunc then
            if typeof(val) == "function" then continue end
        end
        if table.find(except, key) then continue end

        newT[key] = val
    end

    return newT
end
tableUtils.Clone = function(tbl: { any }) : { any }
    return tableUtils.CopyTableExcept(tbl, {}, false)
end

return tableUtils