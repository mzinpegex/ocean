local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local swimHandler = require(ServerScriptService.AssetsOcean.Scripts.Ocean.SwimHandler)

local assets = ReplicatedStorage.AssetsOcean
local swimRemote = assets.Remotes.Swim
local seaSize = assets.Mesh.OceanPart.Mesh.Scale.X

local function getChunk(pos)
    local x = math.floor(pos.X / seaSize)
    local z = math.floor(pos.Z / seaSize)
    return x .. " " .. z
end

-- PlayerAdded
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        local rp = hum.RootPart
        local lastChunk = "nil"
        
        RunService.Heartbeat:Connect(function()
            local pos = rp.Position
            local chunk = getChunk(pos)
            
            if lastChunk ~= chunk then
                lastChunk = chunk
                assets.Remotes.NewChunk:FireClient(plr, chunk, seaSize)
                print(chunk)
            end
        end)
    end)
end)

swimRemote.OnServerEvent:Connect(function(plr, action)
    local char = plr.Character
    local hum = char:WaitForChild("Humanoid")
    local rp = hum.RootPart
    
    swimHandler.SwimActions(plr, action)
end)
