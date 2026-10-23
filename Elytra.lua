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
local character,humanoid,root,attachment,velocity,orientation,wings
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
 end
end
local function start()
 if flying or not root or not humanoid or humanoid.Health<=0 then return end
 if humanoid.FloorMaterial~=Enum.Material.Air then return end
 flying=true; speed=35; button.Text="LAND"
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
 if input.KeyCode==Enum.KeyCode.Space and humanoid and humanoid.FloorMaterial==Enum.Material.Air then toggle() end
end)
local function setup(c)
 stop(); character=c
 humanoid=c:WaitForChild("Humanoid")
 root=c:WaitForChild("HumanoidRootPart")
 humanoid.Died:Connect(stop)
end
player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end
RunService.RenderStepped:Connect(function(dt)
 if not flying or not root or not humanoid or not velocity or not orientation then return end
 if humanoid.FloorMaterial~=Enum.Material.Air then stop(); return end
 local camera=workspace.CurrentCamera
 if not camera then return end
 local look=camera.CFrame.LookVector
 local pitch=math.clamp(-look.Y,-1,1)
 speed=math.clamp(speed+pitch*26*dt-2.5*dt,16,105)
 local move=humanoid.MoveDirection
 local direction=look+move*0.45
 if direction.Magnitude<0.01 then direction=look end
 direction=direction.Unit
 velocity.VectorVelocity=direction*speed+Vector3.new(0,-3,0)
 orientation.CFrame=CFrame.lookAt(Vector3.zero,direction)*CFrame.Angles(math.rad(-65),0,0)
end)
