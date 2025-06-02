--[[
    CloneRef
]]

local tempPart = Instance.new("Part")

for _, regItem in pairs(getreg()) do
    if type(regItem) == "table" and #regItem > 0 then
        if rawget(regItem, "__mode") == "kvs" then
            for key, val in pairs(regItem) do
                if val == tempPart then
                    getgenv().InstanceList = regItem
                    break
                end
            end
        end
    end
end

local cloneWrapper = {}

function cloneWrapper.invalidate(instance)
    if not InstanceList then return instance end
    for idx, obj in pairs(InstanceList) do
        if obj == instance then
            InstanceList[idx] = nil
            return instance
        end
    end
    return instance
end

if typeof(cloneref) ~= "function" then
    getgenv().cloneref = cloneWrapper.invalidate
end
