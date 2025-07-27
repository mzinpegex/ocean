local module = {}

local ps = game:GetService("Players")
local runs = game:GetService("RunService")
local repS = game:GetService("ReplicatedStorage")

local Utilities = require(repS.AssetsOcean.Modules.Utilitary.Utils)

local ocean = workspace.Ocean
local oceanL = ocean.Levels.OceanLevel
local groundL = ocean.Levels.OceanGround
local swimLT, emergeLT, immerseLT, jumpLT = tick(), tick(), tick(), tick()
local jumpcd = 0.25
local drowningTime = 10 

local Table = require(script.Table)

local SwimAnimations = {}

local Animations = {
	IdleSwim = "rbxassetid://18920355444",
	Emerge = "rbxassetid://105029885846145",
	Immerse = "rbxassetid://104335729200719"
}

local function PlayAnimation(humanoid, animId, plrId)
	if not SwimAnimations[plrId] then
		SwimAnimations[plrId] = {}
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	if SwimAnimations[plrId].Current and SwimAnimations[plrId].Current.Animation.AnimationId == animId then
		return
	end

	if SwimAnimations[plrId].Current then
		SwimAnimations[plrId].Current:Stop()
	end

	if not SwimAnimations[plrId][animId] then
		local animation = Instance.new("Animation")
		animation.AnimationId = animId
		SwimAnimations[plrId][animId] = animator:LoadAnimation(animation)
	end

	local track = SwimAnimations[plrId][animId]
	track.Looped = true
	track:Play()
	SwimAnimations[plrId].Current = track
end

local function StopAnimation(plrId)
	if SwimAnimations[plrId] and SwimAnimations[plrId].Current then
		SwimAnimations[plrId].Current:Stop()
		SwimAnimations[plrId].Current = nil
	end
end

ps.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		local rp = hum.RootPart

		local plrid = plr.UserId
		local PlrTable = Table.AllPlayers[plrid]
		
		local cn
		
		cn = runs.Heartbeat:Connect(function(dt)
			if rp.Position.Y <= oceanL.Value.Y and not PlrTable["Swimming"] then
				print("x")
				Table:SetSwimming(plr, true)

				local RootFX = repS.AssetsOcean.VFX.Part.Emit:Clone()
				RootFX.Parent = rp
				local SplashSound = repS.AssetsOcean.VFX.Splash:Clone()
				SplashSound.Parent = RootFX
				SplashSound:Play()
				Utilities.Particle_Setup({Holder = RootFX, Type = "Emit"})

				task.delay(2, function()
					RootFX:Destroy()
					SplashSound:Destroy()
				end)
				
				PlayAnimation(hum, Animations.IdleSwim, plrid)

				swimLT = tick()
				local bodypos = Instance.new("BodyPosition", rp)
				bodypos.Name = "Swimming" .. plrid
				bodypos.Position = Vector3.new(rp.Position.X, oceanL.Value.Y + hum.HipHeight - 0.5, rp.Position.Z)
				bodypos.MaxForce = Vector3.new(0, math.huge, 0)
				bodypos.P = 10000
			elseif rp.Position.Y - rp.Size.Y / 2 > oceanL.Value.Y and PlrTable["Swimming"] then
				Table:SetSwimming(plr, false)
				StopAnimation(plrid)
				Table:SetEmerging(plr, false)
				Table:SetImmersing(plr, false)
				Table:SetCanJump(plr, true)
				local bp = rp:FindFirstChild("Swimming" .. plrid)

				if bp then
					bp:Destroy()
				end
				
				StopAnimation(plrid)
			end
		end)
		
		hum.Died:Connect(function()
			cn:Disconnect()
			
			StopAnimation(plrid)
			SwimAnimations[plrid] = nil
		end)
	end)
end)

module.SwimActions = function(plr, action)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	local rp = hum.RootPart

	local plrid = plr.UserId
	local PlrTable = Table.AllPlayers[plrid]
	local remote = repS.AssetsOcean.Remotes.Swim

	if action == "underwater" or action == "notunderwater" then
		remote:FireClient(plr, action)
	end

	if PlrTable["Swimming"] then
		local bp = rp:FindFirstChild("Swimming" .. plrid)
		if not bp or tick() - swimLT < 0.5 then return end

		if action == "emerge" then
			if rp.Position.Y >= oceanL.Value.Y - 1 and PlrTable["CanJump"] then
				if tick() - jumpLT >= jumpcd then
					jumpLT = tick()
					Table:SetCanJump(plr, false)
					hum.Jump = true

					local bv = Instance.new("BodyVelocity", rp)
					bv.MaxForce = Vector3.new(0, math.huge, 0)
					bv.Velocity = Vector3.new(0, 30, 0)

					task.wait(0.2)
					bv:Destroy()
				end
			else
				if tick() - emergeLT >= 0.05 then
					emergeLT = tick()
					Table:SetEmerging(plr, true)
					bp.Position += Vector3.new(0, 0.5, 0)
					
					PlayAnimation(hum, Animations.Emerge, plrid)
				end
			end
		elseif action == "emergecancel" then
			Table:SetEmerging(plr, false)
			StopAnimation(plrid)
			
			PlayAnimation(hum, Animations.IdleSwim, plrid)
		elseif action == "immerse" then
			if tick() - immerseLT >= 0.05 then
				immerseLT = tick()
				
				PlayAnimation(hum, Animations.Immerse, plrid)

				if math.abs(groundL.Value.Y) - math.abs(bp.Position.Y) >= (rp.Size.Y + char:FindFirstChild("Left Leg").Size.Y) then
					Table:SetImmersing(plr, true)
					bp.Position -= Vector3.new(0, 0.5, 0)
				else
					Table:SetImmersing(plr, false)
				end
			end
		elseif action == "immersecancel" then
			Table:SetImmersing(plr, false)
			
			StopAnimation(plrid)
			
			PlayAnimation(hum, Animations.IdleSwim, plrid)
		end
	end
end

return module
