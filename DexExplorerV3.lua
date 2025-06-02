task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SirMiloRBLX2/scripts/main/CloneRef.lua", true))()
    end)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SirMiloRBLX2/scripts/main/bypass.lua", true))()
    end)
    
    local Dex = game:GetObjects("rbxassetid://9352453730")[1]

    local charset = {}
    for i = 48, 57 do table.insert(charset, string.char(i)) end
    for i = 65, 90 do table.insert(charset, string.char(i)) end
    for i = 97,122 do table.insert(charset, string.char(i)) end
    local function RandomCharacters(len)
        local s = {}
        for _ = 1, len do
            table.insert(s, charset[math.random(1, #charset)])
        end
        return table.concat(s)
    end

    Dex.Name = RandomCharacters(math.random(5, 20))

    local CoreGui = cloneref(game:GetService("CoreGui"))
    local function protectGui(ui)
        if gethui then
            ui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(ui)
            ui.Parent = CoreGui
        else
            ui.Parent = CoreGui
        end
    end
    protectGui(Dex)
    
    local function LoadScripts(obj)
        local function GiveOwnGlobals(fn, scr)
            local env = {}
            local real = {script = scr}
            setmetatable(env, {
                __index = function(_, k)
                    return real[k] or getfenv()[k]
                end,
                __newindex = function(_, k, v)
                    if real[k] then
                        real[k] = v
                    else
                        getfenv()[k] = v
                    end
                end
            })
            setfenv(fn, env)
            return fn
        end

        if obj:IsA("LocalScript") or obj:IsA("Script") then
            task.spawn(function()
                pcall(function()
                    GiveOwnGlobals(loadstring(obj.Source, "=" .. obj:GetFullName()), obj)()
                end)
            end)
        end

        for _, child in ipairs(obj:GetChildren()) do
            LoadScripts(child)
        end
    end

    LoadScripts(Dex)
end)
