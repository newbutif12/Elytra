-- Minecraft-inspired Elytra flight (R6/R15)
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local old=player.PlayerGui:FindFirstChild("SteveElytraUI")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="SteveElytraUI"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local button=Instance.new("TextButton")
button.Size=UDim2.fromOffset(94,38)
button.Position=UDim2.new(1,-110,0.58,0)
button.Text="ELYTRA"
button.TextColor3=Color3.fromRGB(180,235,255)
button.BackgroundColor3=Color3.fromRGB(15,22,30)
button.Parent=gui
Instance.new("UICorner",button).CornerRadius=UDim.new(0,9)
local character,humanoid,root,attachment,velocity,orientation,wings,steve
local flying=false
local speed=35
local function stop()
 flying=false; button.Text="ELYTRA"
 if velocity then velocity:Destroy(); velocity=nil end
 if orientation then orientation:Destroy(); orientation=nil end
 if attachment then attachment:Destroy(); attachment=nil end
 if wings then wings:Destroy(); wings=nil end
 if humanoid then humanoid.AutoRotate=true end
end
local function pixel(parent,size,offset,color)
 local p=Instance.new("Part")
 p.Size=size; p.Color=color; p.Material=Enum.Material.SmoothPlastic
 p.CanCollide=false; p.CanTouch=false; p.Massless=true
 p.CFrame=parent.CFrame*CFrame.new(offset)
 p.Parent=wings
 local w=Instance.new("WeldConstraint",p); w.Part0=parent; w.Part1=p
 return p
end

-- Cross-platform pixel texture: Roblox EditableImage (when permitted).
-- Falls back to physical pixel blocks on restricted iOS/Android executors.
local function tryPixelTexture(wing)
 local ok, result=pcall(function()
  local asset=game:GetService("AssetService")
  local img=asset:CreateEditableImage({Size=Vector2.new(16,32)})
  if not img then return false end
  local pixels=buffer.create(16*32*4)
  for y=0,31 do
   for x=0,15 do
    local i=(y*16+x)*4
    local edge=(x<2 or x>13 or y<2 or y>29)
    local v=((x*17+y*13+math.floor(y/4)*19)%37)
    buffer.writeu8(pixels,i,edge and 36 or 72+v)
    buffer.writeu8(pixels,i+1,edge and 35 or 73+v)
    buffer.writeu8(pixels,i+2,edge and 47 or 103+v)
    buffer.writeu8(pixels,i+3,255)
   end
  end
  img:WritePixelsBuffer(Vector2.zero,Vector2.new(16,32),pixels)
  local decal=Instance.new("Decal")
  decal.Face=Enum.NormalId.Top
  decal.TextureContent=Content.fromObject(img)
  decal.Parent=wing
  return true
 end)
 return ok and result==true
end

local function makeWings()
 local torso=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
 if not torso then return end
 wings=Instance.new("Model"); wings.Name="ElytraWings"; wings.Parent=character
 for _,side in ipairs({-1,1}) do
  local wing=Instance.new("Part")
  wing.Name=side<0 and "LeftWing" or "RightWing"
  wing.Size=Vector3.new(1.35,0.14,2.35)
  wing.Material=Enum.Material.SmoothPlastic
  wing.Color=Color3.fromRGB(75,75,95)
  wing.CanCollide=false; wing.CanTouch=false; wing.Massless=true
  wing.Parent=wings
  wing.CFrame=torso.CFrame*CFrame.new(side*0.82,0.12,0.95)*CFrame.Angles(math.rad(12),math.rad(side*18),math.rad(side*10))
  local weld=Instance.new("WeldConstraint")
  weld.Part0=torso; weld.Part1=wing; weld.Parent=wing
  -- Fallback geometry for devices without EditableImage permissions.
  if not tryPixelTexture(wing) then
  for row=1,4 do
   for col=1,2 do
    local patch=Instance.new("Part")
    patch.Size=Vector3.new(0.56,0.025,0.49)
    patch.Color3=Color3.fromRGB(58+row*9,48+col*8,76+row*5)
    patch.Material=Enum.Material.SmoothPlastic
    patch.CanCollide=false; patch.CanTouch=false; patch.Massless=true
    patch.CFrame=wing.CFrame*CFrame.new((col-1.5)*0.63,0.085,(row-2.5)*0.53)
    patch.Parent=wings
    local pw=Instance.new("WeldConstraint",patch); pw.Part0=wing; pw.Part1=patch
   end
  end
  end
 end
end

-- Client-side Steve-inspired block skin, assembled without external Asset IDs.
local function makeSteve()
 if steve then steve:Destroy() end
 steve=Instance.new("Model"); steve.Name="StevePixelSkin"; steve.Parent=character
 local palette={
  head=Color3.fromRGB(165,116,83),
  torso=Color3.fromRGB(30,174,186),
  arm=Color3.fromRGB(168,118,86),
  leg=Color3.fromRGB(47,48,151)
 }
 local pieces={
  {{"Head"}, "head"},
  {{"UpperTorso","Torso"}, "torso"},
  {{"LeftUpperArm","Left Arm"}, "arm"},
  {{"RightUpperArm","Right Arm"}, "arm"},
  {{"LeftUpperLeg","Left Leg"}, "leg"},
  {{"RightUpperLeg","Right Leg"}, "leg"}
 }
 for _,entry in ipairs(pieces) do
  local limb
  for _,name in ipairs(entry[1]) do limb=character:FindFirstChild(name); if limb then break end end
  if limb and limb:IsA("BasePart") then
   limb.LocalTransparencyModifier=1
   local shell=Instance.new("Part")
   shell.Name="Steve_"..limb.Name; shell.Size=limb.Size+Vector3.new(0.03,0.03,0.03)
   shell.Color=palette[entry[2]]; shell.Material=Enum.Material.SmoothPlastic
   shell.CanCollide=false; shell.CanTouch=false; shell.Massless=true
   shell.CFrame=limb.CFrame; shell.Parent=steve
   local weld=Instance.new("WeldConstraint",shell); weld.Part0=limb; weld.Part1=shell
   if entry[2]=="head" then
    for _,side in ipairs({-1,1}) do
     local eye=Instance.new("Part")
     eye.Size=Vector3.new(0.19,0.17,0.025)
     eye.Color=Color3.fromRGB(238,238,238)
     eye.CanCollide=false; eye.Massless=true
     eye.CFrame=limb.CFrame*CFrame.new(side*0.22,0.06,-limb.Size.Z/2-0.035)
     eye.Parent=steve
     local ew=Instance.new("WeldConstraint",eye); ew.Part0=limb; ew.Part1=eye
     local pupil=Instance.new("Part")
     pupil.Size=Vector3.new(0.075,0.11,0.028); pupil.Color=Color3.fromRGB(43,61,159)
     pupil.CanCollide=false; pupil.Massless=true
     pupil.CFrame=eye.CFrame*CFrame.new(0,0,-0.028); pupil.Parent=steve
     local pw=Instance.new("WeldConstraint",pupil); pw.Part0=eye; pw.Part1=pupil
    end
   end
  end
 end
end

local function start()
 if flying or not root or not humanoid or humanoid.Health<=0 then return end
 -- Take off from the ground as well as in midair.
 flying=true; speed=35; button.Text="STOP"
 attachment=Instance.new("Attachment",root)
 velocity=Instance.new("LinearVelocity",root)
 velocity.Attachment0=attachment; velocity.MaxForce=100000
 velocity.VectorVelocity=root.CFrame.LookVector*speed
 orientation=Instance.new("AlignOrientation",root)
 orientation.Attachment0=attachment
 orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment
 orientation.MaxTorque=100000; orientation.Responsiveness=12
 humanoid.AutoRotate=false
 makeWings()
end
local function toggle() if flying then stop() else start() end end
button.Activated:Connect(toggle)
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.Space and humanoid then toggle() end
end)
local function setup(c)
 stop(); if steve then steve:Destroy(); steve=nil end
 character=c
 humanoid=c:WaitForChild("Humanoid")
 root=c:WaitForChild("HumanoidRootPart")
 humanoid.Died:Connect(stop)
 makeSteve()
end
player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end
RunService.RenderStepped:Connect(function(dt)
 if not flying or not root or not humanoid or not velocity or not orientation then return end
 -- Infinite flight: landing does not turn flight off.
 local camera=workspace.CurrentCamera
 if not camera then return end
 local look=camera.CFrame.LookVector
 local pitch=math.clamp(-look.Y,-1,1)
 speed=math.clamp(speed+pitch*26*dt-2.5*dt,16,105)
 local move=humanoid.MoveDirection
 local direction=look+move*0.45
 if direction.Magnitude<0.01 then direction=look end
 direction=direction.Unit
 -- Camera up = climb, camera down = dive. Keep enough lift to gain height.
 local vertical = math.clamp(look.Y * speed * 1.25, -90, 70)
 if root and root.AssemblyLinearVelocity.Y < 2 and look.Y > -0.1 then vertical=math.max(vertical,22) end
 if look.Y > 0.12 then
  vertical = math.max(vertical, 12 + look.Y * 30)
 end
 local horizontal = Vector3.new(direction.X,0,direction.Z)
 if horizontal.Magnitude > 0.01 then horizontal = horizontal.Unit else horizontal = Vector3.zero end
 velocity.VectorVelocity = horizontal * speed * math.max(0.35, 1-math.abs(look.Y)*0.4) + Vector3.new(0,vertical,0)
 orientation.CFrame=CFrame.lookAt(Vector3.zero,direction)*CFrame.Angles(math.rad(-65),0,0)
end)
