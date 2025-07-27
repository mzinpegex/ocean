local plrs = game:GetService("Players")
local runs = game:GetService("RunService")
local repS = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local assets = repS.AssetsOcean
local sea = assets.Mesh.OceanPart
local oceanFolder = workspace.Ocean
local swimRemote = assets.Remotes.Swim
local currentcamera = workspace.CurrentCamera
local underwater = false

local calculator = require(assets.Modules.ChunckCalculator)

assets.Remotes.NewChunk.OnClientEvent:Connect(function(chunk, seasize)
	local ChunkFolder = Instance.new("Folder", oceanFolder.Chunks)
	ChunkFolder.Name = chunk
	local seaClone = sea:Clone()
	seaClone.Parent = ChunkFolder
	
	local mainchunkpos = calculator.CalculatePOS(chunk, seasize)
	seaClone.Position = mainchunkpos
	local ground = oceanFolder.Levels:FindFirstChild("OceanGround")

	while not ground do
		task.wait(0.1)
		ground = oceanFolder.Levels:FindFirstChild("OceanGround")

		print("Procurando pelo OceanGround...")
	end

	calculator.GroundGen(mainchunkpos, ground, ChunkFolder, chunk)

	
	local parts = string.split(chunk, " ")

	local x = parts[1]
	local z = parts[2]

	x = tonumber(x)
	z = tonumber(z)
	
	local ChunkList = {}
	
	for i = 1, 3, 1 do
		if i == 1 then
			local chunk1 = tostring(x-1) .. " " .. tostring(z-1)
			table.insert(ChunkList, chunk1)
			
			local chunk2 = tostring(x) .. " " .. tostring(z-1)
			table.insert(ChunkList, chunk2)
			
			local chunk3 = tostring(x+1) .. " " .. tostring(z-1)
			table.insert(ChunkList, chunk3)
		end
		if i == 2 then
			local chunk1 = tostring(x-1) .. " " .. tostring(z)
			table.insert(ChunkList, chunk1)

			local chunk2 = tostring(x+1) .. " " .. tostring(z)
			table.insert(ChunkList, chunk2)
		end
		if i == 3 then
			local chunk1 = tostring(x-1) .. " " .. tostring(z+1)
			table.insert(ChunkList, chunk1)

			local chunk2 = tostring(x) .. " " .. tostring(z+1)
			table.insert(ChunkList, chunk2)

			local chunk3 = tostring(x+1) .. " " .. tostring(z+1)
			table.insert(ChunkList, chunk3)
		end
	end
	for i, v in pairs(ChunkList) do
		local chunkPos = calculator.CalculatePOS(v, seasize)
		local newSea = sea:Clone()
		newSea.Parent = ChunkFolder
		newSea.Position = chunkPos
		
		local ground = calculator.GroundGen(chunkPos, oceanFolder.Levels.OceanGround, ChunkFolder, chunk)
	end
	
	for i, v in pairs(oceanFolder.Chunks:GetChildren()) do
		if v.Name ~= chunk then
			v:Destroy()
		end
	end
end)

assets.Remotes.Swim.OnClientEvent:Connect(function(action)
	if action == "underwater" then
		local cc = assets.VFX.UnderWater:Clone()
		local undwater = assets.VFX.UnderwaterSound:Clone()
		undwater:Play()
		cc.Parent = currentcamera
		undwater.Parent = currentcamera
	elseif action == "notunderwater" then
		local cc = currentcamera:FindFirstChild("UnderWater")
		local undwater = currentcamera:FindFirstChild("UnderwaterSound")
		
		if cc then
			cc:Destroy()
			undwater:Destroy()
			print("destruiu")
		end
	end
end)

local im, em = false, false

uis.InputBegan:Connect(function(key, gpe)
	if gpe then return end
	
	if key.KeyCode == Enum.KeyCode.LeftControl then
		im = true
		while im == true do
			swimRemote:FireServer("immerse")
			task.wait()
		end
	elseif key.KeyCode == Enum.KeyCode.Space then
		em = true
		while em == true do
			swimRemote:FireServer("emerge")
			task.wait()
		end
	end
end)

uis.InputEnded:Connect(function(key, gpe)
	if gpe then return end

	if key.KeyCode == Enum.KeyCode.LeftControl then
		im = false
		swimRemote:FireServer("immersecancel")
	elseif key.KeyCode == Enum.KeyCode.Space then
		em = false
		swimRemote:FireServer("emergecancel")
	end
end)

currentcamera:GetPropertyChangedSignal("CFrame"):Connect(function()
	repeat task.wait() until plrs.LocalPlayer.Character or plrs.LocalPlayer.CharacterAdded:Wait()
	
	local pos = currentcamera.CFrame.Position
	
	if pos.Y < oceanFolder.Levels.OceanLevel.Value.Y and underwater == false then
		underwater = true
		swimRemote:FireServer("underwater")
		task.wait()
	elseif pos.Y >= oceanFolder.Levels.OceanLevel.Value.Y and underwater == true then
		underwater = false
		swimRemote:FireServer("notunderwater")
	end
end)
