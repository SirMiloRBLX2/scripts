--[[
   Dex Explorer V3 Dex Bypass
--]]

local safeGcinfo = getrenv().gcinfo or collectgarbage
local hook = hookfunction or (syn and syn.hook_function)
local hookMeta = hookmetamethod or (syn and syn.hook_metatable)
local runService = cloneref(game:GetService("RunService"))

task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    -- === GCInfo/CollectGarbage Bypass ===
    local Amplitude, tick = 200, 0
    local spoofBase = safeGcinfo() + Amplitude
    local pi, acos, cos, floor = math.pi, math.acos, math.cos, math.floor

    local function spoofGC()
        local formula = ((acos(cos(pi * tick)) / pi * (Amplitude * 2)) - Amplitude)
        return floor(spoofBase + formula)
    end

    local originalGcinfo = hook(safeGcinfo, function(...)
        return spoofGC()
    end)

    local originalCollect = hook(collectgarbage, function(arg, ...)
        if arg == "count" then return spoofGC() end
        return originalCollect(arg, ...)
    end)

    runService.Stepped:Connect(function()
        tick += 0.05 + math.random() * 0.02
    end)

    while task.wait(math.random(0.1, 1)) do
        Amplitude = math.random(-100, 300)
    end
end)

-- === Memory Usage Bypass ===
local function memoryBypass(methodName, tag)
    task.spawn(function()
        repeat task.wait() until game:IsLoaded()
        local Stats = cloneref(game:GetService("Stats"))
        local Rand = 0
        local baseMem = tag and Stats:GetMemoryUsageMbForTag(tag) or Stats:GetTotalMemoryUsageMb()

        runService.Stepped:Connect(function()
            Rand = Random.new():NextNumber(tag and -0.15 or -5, tag and 0.15 or 5)
        end)

        local spoof = function()
            return baseMem + Rand
        end

        local __hookMeta
        __hookMeta = hookMeta(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and typeof(self) == "Instance" and self.ClassName == "Stats" then
                if method:lower() == methodName:lower() then
                    return spoof()
                end
            end
            return __hookMeta(self, ...)
        end)

        local realMethod = tag and Stats.GetMemoryUsageMbForTag or Stats.GetTotalMemoryUsageMb
        hook(realMethod, function(self, ...)
            if not checkcaller() then return spoof() end
            return realMethod(self, ...)
        end)
    end)
end

memoryBypass("GetTotalMemoryUsageMb")
memoryBypass("GetMemoryUsageMbForTag", Enum.DeveloperMemoryTag.Gui)

-- === PreloadAsync Bypass ===
task.spawn(function()
    local ContentProvider = cloneref(game:GetService("ContentProvider"))
    local CoreGui = cloneref(game:GetService("CoreGui"))

    local coreAssets, gameAssets = {}, {}
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ImageLabel") and v.Image:find("rbxassetid://") then
            if v:IsDescendantOf(CoreGui) then
                table.insert(coreAssets, v.Image)
            else
                table.insert(gameAssets, v.Image)
            end
        end
    end

    local function shuffle(tbl)
        for i = #tbl, 2, -1 do
            local j = math.random(i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
        return tbl
    end

    local __cpHook
    __cpHook = hookMeta(game, "__namecall", function(self, tbl, ...)
        local method = getnamecallmethod()
        if not checkcaller() and self.ClassName == "ContentProvider" then
            if method:lower() == "preloadasync" and type(tbl) == "table" then
                if tbl[1] == CoreGui then return __cpHook(self, shuffle(coreAssets), ...) end
                if tbl[1] == game then return __cpHook(self, shuffle(gameAssets), ...) end
            end
        end
        return __cpHook(self, tbl, ...)
    end)

    hook(ContentProvider.PreloadAsync, function(self, tbl, callback)
        if not checkcaller() and typeof(tbl) == "table" then
            if tbl[1] == CoreGui then return self:PreloadAsync(shuffle(coreAssets), callback) end
            if tbl[1] == game then return self:PreloadAsync(shuffle(gameAssets), callback) end
        end
        return self:PreloadAsync(tbl, callback)
    end)
end)

-- === GetFocusedTextBox Bypass ===
hookMeta(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and self.ClassName == "UserInputService" and method == "GetFocusedTextBox" then
        local success, textbox = pcall(self.GetFocusedTextBox, self, ...)
        if success and textbox and not pcall(function() return textbox:IsDescendantOf(workspace) end) then
            return nil
        end
    end
    return self[method](self, ...)
end)

-- === newproxy Bypass ===
local proxyRefs = {}
local newproxyFunc = newproxy or getrenv().newproxy
local originalNewproxy = hook(newproxyFunc, function(...)
    local px = originalNewproxy(...)
    proxyRefs[#proxyRefs+1] = px
    return px
end)

runService.Stepped:Connect(function()
    for _, v in ipairs(proxyRefs) do
        if v == nil then end
    end
    
    for i, v in pairs(TableNumbaor001) do
        if v == nil then
            TableNumbaor001[i] = nil
        end
    end
end)
