
export type Table = { any }
export type Dict = { [any]: any }


local tableUtils = {}

tableUtils.Keys = function(tbl: Dict) : { string }
    local keys = table.create(#tbl)

    for key in tbl do
        table.insert(keys, key)
    end

    return keys
end
tableUtils.Values = function(tbl: Dict) : { any }
    local values = table.create(#tbl)

    for _, value in tbl do
        table.insert(values, value)
    end

    return values
end
tableUtils.IsEmpty = function(tbl: Table | Dict) : boolean
    return next(tbl) == nil
end
tableUtils.Filter = function(tbl: Dict, predicate: (val: any, key: any, tbl: Dict) -> boolean) : Table
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
tableUtils.Cut = function(tbl: Table, len: number) : Table
    local n = #tbl
    len = math.clamp(len, 1, n)

    return if len == n then table.clone(tbl) else table.move(tbl, 1, len, 1, table.create(len))
end
tableUtils.CheckForSome = function(tbl: Dict, callback: (val: any, key: any, tbl: Dict) -> boolean) : boolean
    for k, v in tbl do
        if callback(v, k, tbl) then
            return true
        end
    end

    return false
end
tableUtils.CheckForEvery = function(tbl: Dict, callback: (val: any, key: any, tbl: Dict) -> boolean) : boolean
    for k, v in tbl do
        if not callback(v, k, tbl) then
            return false
        end
    end

    return true
end
tableUtils.Find = function(tbl: Dict, callback: (val: any, key: any, tbl: Dict) -> boolean) : (string?, any?)
    for k, v in tbl do
        if callback(v, k, tbl) then
            return v, k
        end
    end

    return nil, nil
end
tableUtils.Map = function(tbl: Dict, callback: (val: any, key: any, tbl: Dict) -> any) : Dict
    local newT = table.create(#tbl)

    for k, v in tbl do
        newT[k] = callback(v, k, tbl)
    end

    return newT
end
tableUtils.Merge = function(tbl1: Table, tbl2: Table)
    local newT = table.clone(tbl1)

    for _, v in tbl2 do
        table.insert(newT, v)
    end

    return newT
end
tableUtils.CountDictLength = function(dict: Dict) : number
    local count = 0

    for _, _ in dict do
        count += 1
    end

    return count
end
tableUtils.MakePackage = function(t: Dict, whiteList: { string }) : Dict
    local newT = {}

    for key: string, val: any in table.clone(t) do
        if table.find(whiteList, key) then
            newT[key] = val
        end
    end

    return newT
end
tableUtils.CopyTableExcept = function(t: Dict, except: { string }, shouldIncludeFunc: boolean?) : Dict
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
tableUtils.Clone = function(tbl: Dict) : Dict
    return tableUtils.CopyTableExcept(tbl, {}, false)
end

return tableUtils