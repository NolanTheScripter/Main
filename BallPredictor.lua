-- BallPredictor.lua
local BallPredictor = {}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Settings
local PREDICTION_TIME = 2
local STEP = 0.05
local GRAVITY = Vector3.new(0, -Workspace.Gravity, 0)
local MAX_BOUNCES = 1

local function createSplinePart()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.ForceField
	part.Color = Color3.fromRGB(255, 140, 0)
	part.Size = Vector3.new(0.15, 0.15, 0.15)
	part.Transparency = 0.1
	return part
end

local splineParts = table.create(60, nil)
for i = 1, 60 do
	splineParts[i] = createSplinePart()
end

-- Dot cache
local function createDot()
	local dot = Instance.new("Part")
	dot.Size = Vector3.new(0.2, 0.2, 0.2)
	dot.Anchored = true
	dot.CanCollide = false
	dot.Material = Enum.Material.Neon
	dot.Color = Color3.fromRGB(255, 255, 255)
	dot.Transparency = 0.2
	return dot
end

local dots = table.create(100, nil)
for i = 1, 100 do
	dots[i] = createDot()
end

-- RK4 Physics Integrator
local function rk4(position, velocity, dt)
	local function acceleration() return GRAVITY end

	local a1 = acceleration()
	local v1 = velocity

	local a2 = acceleration()
	local v2 = velocity + 0.5 * dt * a1

	local a3 = acceleration()
	local v3 = velocity + 0.5 * dt * a2

	local a4 = acceleration()
	local v4 = velocity + dt * a3

	local posDelta = (v1 + 2*v2 + 2*v3 + v4) * (dt / 6)
	local velDelta = (a1 + 2*a2 + 2*a3 + a4) * (dt / 6)

	return position + posDelta, velocity + velDelta
end

-- Bounce-aware RK4 trajectory
local function predictRK4Trajectory(origin, velocity)
	local points = {}
	local pos = origin
	local vel = velocity
	local bounces = 0

	for t = 0, PREDICTION_TIME, STEP do
		table.insert(points, pos)

		local nextPos, nextVel = rk4(pos, vel, STEP)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {Workspace.Terrain}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local rayResult = Workspace:Raycast(pos, (nextPos - pos), rayParams)
		if rayResult then
			if bounces < MAX_BOUNCES then
				local normal = rayResult.Normal
				nextVel = nextVel - 2 * nextVel:Dot(normal) * normal
				pos = rayResult.Position
				vel = nextVel
				bounces += 1
			else
				break
			end
		else
			pos, vel = nextPos, nextVel
		end
	end

	return points
end

-- Beam + Attachments
local function createBeam(ball)
	local att0 = Instance.new("Attachment", ball)
	local att1 = Instance.new("Attachment", ball)

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.FaceCamera = true
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	beam.Transparency = NumberSequence.new(0.1)
	beam.LightEmission = 1
	beam.Parent = ball

	return att0, att1, beam
end

-- Dot trail renderer
local function renderDots(points)
	for i, dot in ipairs(dots) do
		if points[i] then
			dot.Position = points[i]
			dot.Parent = Workspace
		else
			dot.Parent = nil
		end
	end
end

-- Future player prediction
local function predictPlayerFuture()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	return hrp.Position + hrp.Velocity * 0.4
end

-- Visualizer Entry
function BallPredictor.Visualize(ball)
	local a0, a1, beam = createBeam(ball)

	RunService.RenderStepped:Connect(function()
		if not ball or not ball.Parent then return end

		local vel = ball.AssemblyLinearVelocity
		local points = predictRK4Trajectory(ball.Position, vel)

		-- Beam curvature
		if #points >= 2 then
			local midpoint = points[math.floor(#points / 2)]
			a1.Position = midpoint - ball.Position
		end

		-- Beam color = speed
		local color = Color3.fromHSV((vel.Magnitude % 50) / 50, 1, 1)
		beam.Color = ColorSequence.new(color)

		-- Render dot trail
		renderDots(points)

			-- Render smooth spline parts along the path
        for i, part in ipairs(splineParts) do
	            local pt = points[i * 2] -- skip every other point for spacing
     	        if pt then
    	     	part.Position = pt
     	    	part.Parent = Workspace
        	else
         	    part.Parent = nil
            end
        end

		-- (Optional) Player prediction (can render a sphere if needed)
		local futurePos = predictPlayerFuture()
		if futurePos then
			-- Optional: Draw marker or use for pass prediction
		end

    if futurePos then
        if not BallPredictor.PassLine then
    		       local at1 = Instance.new("Attachment")
          	   at1.Position = Vector3.zero
    	  	     at1.Name = "TargetAttachment"
      		     at1.Parent = Workspace.Terrain

      		     local passBeam = Instance.new("Beam")
      		     passBeam.Attachment0 = a0
      		     passBeam.Attachment1 = at1
      		     passBeam.Width0 = 0.1
      		     passBeam.Width1 = 0.1
      		     passBeam.Transparency = NumberSequence.new(0.3)
    	  	     passBeam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
       		     passBeam.LightEmission = 1
    	  	     passBeam.ZIndex = 2
      		     passBeam.Parent = ball

    	  	     BallPredictor.PassLine = {
    	  		       Attachment = at1,
      			       Beam = passBeam
      	 	     }
       end
    
       BallPredictor.PassLine.Attachment.WorldPosition = futurePoselse
    	 if BallPredictor.PassLine then
        		BallPredictor.PassLine.Attachment.Parent = nil
		        BallPredictor.PassLine.Beam:Destroy()
		       BallPredictor.PassLine = nil
	     end
     end
	end)
end

return BallPredictor
