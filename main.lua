local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE INTERNAS
local espEnabled = true
local maxDistance = 1000 -- Distância padrão inicial

local BONE_COLOR = Color3.fromRGB(0, 255, 0)
local BONE_THICKNESS = 0.15

local R15_BONES = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

-- CRIANDO A INTERFACE GRÁFICA (UI) DE CONTROLE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Controller"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 130)
Frame.Position = UDim2.new(0, 20, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Cantos arredondados na UI
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Menu ESP Bone"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- Botão de On/Off
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 35)
ToggleButton.Position = UDim2.new(0, 20, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
ToggleButton.Text = "ESP: ATIVADO"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

-- Caixa de texto para digitar a distância
local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(0, 180, 0, 35)
DistanceInput.Position = UDim2.new(0, 20, 0, 80)
DistanceInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DistanceInput.Text = tostring(maxDistance)
DistanceInput.PlaceholderText = "Distância (10-5000)"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.SourceSans
DistanceInput.TextSize = 16
DistanceInput.ClearTextOnFocus = false
DistanceInput.Parent = Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DistanceInput

-- LÓGICA DA INTERFACE DO USUÁRIO (UI)
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        ToggleButton.Text = "ESP: ATIVADO"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        ToggleButton.Text = "ESP: DESATIVADO"
    end
end)

DistanceInput.FocusLost:Connect(function(enterPressed)
    local numericValue = tonumber(DistanceInput.Text)
    if numericValue then
        -- Força o valor inserido a ficar estritamente entre 10 e 5000
        maxDistance = math.clamp(numericValue, 10, 5000)
    end
    DistanceInput.Text = tostring(maxDistance)
end)

-- SISTEMA DO ESP BONE (RENDERIZAÇÃO)
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "ESP_Bones_Folder"
ESP_Folder.Parent = LocalPlayer.PlayerGui

local function drawBoneLine(id, part1, part2)
    local line = ESP_Folder:FindFirstChild(id)
    if not line then
        line = Instance.new("CylinderHandleAdornment")
        line.Name = id
        line.Color3 = BONE_COLOR
        line.Radius = BONE_THICKNESS
        line.AlwaysOnTop = true
        line.ZIndex = 10
        line.Parent = ESP_Folder
    end
    
    local p1 = part1.Position
    local p2 = part2.Position
    local distance = (p1 - p2).Magnitude
    
    line.Height = distance
    line.Adornee = part1
    line.CFrame = CFrame.lookAt(p1, p2) * CFrame.Angles(0, math.rad(90), 0) * CFrame.new(-distance / 2, 0, 0)
end

local function clearUnusedLines(activeIds)
    for _, child in ipairs(ESP_Folder:GetChildren()) do
        if not activeIds[child.Name] then
            child:Destroy()
        end
    end
end

RunService.RenderStepped:Connect(function()
    local activeIds = {}
    
    -- Se o ESP estiver desligado ou seu personagem sumir, limpa as linhas e ignora o frame
    local myCharacter = LocalPlayer.Character
    if not espEnabled or not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then 
        ESP_Folder:ClearAllChildren()
        return 
    end
    
    local myPos = myCharacter.HumanoidRootPart.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local distance = (myPos - root.Position).Magnitude
                
                -- Usa o valor em tempo real configurado na UI
                if distance <= maxDistance then
                    for _, bonePair in ipairs(R15_BONES) do
                        local part1 = char:FindFirstChild(bonePair[1])
                        local part2 = char:FindFirstChild(bonePair[2])
                        
                        if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
                            local lineId = player.Name .. "_" .. bonePair[1] .. "_" .. bonePair[2]
                            activeIds[lineId] = true
                            drawBoneLine(lineId, part1, part2)
                        end
                    end
                end
            end
        end
    end
    
    clearUnusedLines(activeIds)
end)
