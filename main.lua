local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local MAX_DISTANCE = 1000 -- Distância máxima de 1000 metros (Studs)
local BONE_COLOR = Color3.fromRGB(0, 255, 0) -- Cor verde para os ossos
local BONE_THICKNESS = 0.15 -- Espessura das linhas do esqueleto

-- Conexões de juntas padrão do R15 no Roblox
local R15_BONES = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    -- Braço Esquerdo
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    -- Braço Direito
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    -- Perna Esquerda
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    -- Perna Direita
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- Pasta para armazenar as linhas criadas no CoreGui ou PlayerGui
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "ESP_Bones_Folder"
ESP_Folder.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Função para criar ou atualizar uma linha (CylinderHandleAdornment)
local function drawBoneLine(id, part1, part2)
    local lineName = id
    local line = ESP_Folder:FindFirstChild(lineName)
    
    if not line then
        line = Instance.new("CylinderHandleAdornment")
        line.Name = lineName
        line.Color3 = BONE_COLOR
        line.Radius = BONE_THICKNESS
        line.AlwaysOnTop = true -- Faz o esqueleto aparecer através das paredes
        line.ZIndex = 10
        line.Parent = ESP_Folder
    end
    
    -- Calcula a distância e a direção entre as duas partes do corpo
    local p1 = part1.Position
    local p2 = part2.Position
    local distance = (p1 - p2).Magnitude
    
    line.Height = distance
    line.Adornee = part1
    line.CFrame = CFrame.lookAt(p1, p2) * CFrame.Angles(0, math.rad(90), 0) * CFrame.new(-distance / 2, 0, 0)
end

-- Limpa linhas antigas quando um jogador morre ou sai do alcance
local function clearUnusedLines(activeIds)
    for _, child in ipairs(ESP_Folder:GetChildren()) do
        if not activeIds[child.Name] then
            child:Destroy()
        end
    end
end

-- Loop principal executado a cada frame do jogo
RunService.RenderStepped:Connect(function()
    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then 
        ESP_Folder:ClearAllChildren()
        return 
    end
    
    local myPos = myCharacter.HumanoidRootPart.Position
    local activeIds = {}
    
    -- Varre todos os jogadores do servidor
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            -- Verifica se o jogador está vivo e se o personagem existe
            if root and hum and hum.Health > 0 then
                local distance = (myPos - root.Position).Magnitude
                
                -- Limita o desenho ao alcance estipulado de 1000 metros
                if distance <= MAX_DISTANCE then
                    -- Desenha cada conexão do esqueleto R15
                    for index, bonePair in ipairs(R15_BONES) do
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
