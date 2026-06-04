local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- VARIÁVEIS DE CONTROLE INTERNAS (Inicia desligado)
local espEnabled = false
local maxDistance = 1000

local BONE_COLOR = Color3.fromRGB(255, 255, 255) -- Branco
local BONE_THICKNESS = 2 -- Espessura correta em pixels

-- Tabela estrutural rígida para evitar linhas cruzadas ou deitadas
local BONE_STRUCTURE = {
    -- Conexões Universais R15
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    
    -- Conexões Universais R6 (Caso o jogo use avatares clássicos)
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- Interface Principal
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESP_System")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_System"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Remove o deslocamento da barra superior do Roblox
ScreenGui.Parent = LocalPlayer.PlayerGui

local LinesContainer = Instance.new("Folder")
LinesContainer.Name = "LinesContainer"
LinesContainer.Parent = ScreenGui

-- INTERFACE GRÁFICA (UI) DO MENU ARRASTÁVEL
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 220, 0, 130)
MenuFrame.Position = UDim2.new(0, 20, 0.4, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Menu ESP Bone Screen"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MenuFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 35)
ToggleButton.Position = UDim2.new(0, 20, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleButton.Text = "ESP: DESATIVADO"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MenuFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(0, 180, 0, 35)
DistanceInput.Position = UDim2.new(0, 20, 0, 80)
DistanceInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DistanceInput.Text = tostring(maxDistance)
DistanceInput.PlaceholderText = "Distância (10-7000)"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.SourceSans
DistanceInput.TextSize = 16
DistanceInput.ClearTextOnFocus = false
DistanceInput.Parent = MenuFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DistanceInput

-- SISTEMA FLUTUANTE (Arrastar o menu)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MenuFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- LÓGICA DO BOTÃO
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        ToggleButton.Text = "ESP: ATIVADO"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        ToggleButton.Text = "ESP: DESATIVADO"
        LinesContainer:ClearAllChildren()
    end
end)

DistanceInput.FocusLost:Connect(function()
    local numericValue = tonumber(DistanceInput.Text)
    if numericValue then maxDistance = math.clamp(numericValue, 10, 5000) end
    DistanceInput.Text = tostring(maxDistance)
end)

-- FUNÇÃO TRIGONOMÉTRICA CORRIGIDA (Projeção matemática 2D exata)
local function drawLineBetweenPoints(id, p1, p2)
    local lineFrame = LinesContainer:FindFirstChild(id)
    if not lineFrame then
        lineFrame = Instance.new("Frame")
        lineFrame.Name = id
        lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        lineFrame.BackgroundColor3 = BONE_COLOR
        lineFrame.BorderSizePixel = 0
        lineFrame.Parent = LinesContainer
    end

    local diff = p2 - p1
    local length = diff.Magnitude -- Calcula o comprimento vetorial correto
    local midpoint = (p1 + p2) / 2 -- Define o centro exato entre as duas articulações
    
    -- Conversão matemática crucial de Radianos para Graus (Corrige o erro de deitar as linhas)
    local angleInDegrees = math.atan2(diff.Y, diff.X) * (180 / math.pi)

    lineFrame.Size = UDim2.fromOffset(length, BONE_THICKNESS)
    lineFrame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
    lineFrame.Rotation = angleInDegrees
end

local function clearUnusedLines(activeIds)
    for _, child in ipairs(LinesContainer:GetChildren()) do
        if not activeIds[child.Name] then child:Destroy() end
    end
end

-- LOOP DE CORRESPONDÊNCIA DA CÂMERA 3D -> TELA 2D
RunService.RenderStepped:Connect(function()
    local activeIds = {}
    
    local myCharacter = LocalPlayer.Character
    if not espEnabled or not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then 
        LinesContainer:ClearAllChildren()
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
                
                if distance <= maxDistance then
                    -- Processa a tabela de mapeamento anatômico fixo
                    for _, bonePair in ipairs(BONE_STRUCTURE) do
                        local partA = char:FindFirstChild(bonePair[1])
                        local partB = char:FindFirstChild(bonePair[2])
                        
                        -- Garante que ambos os membros existem no modelo atual do jogador (R6 ou R15)
                        if partA and partB and partA:IsA("BasePart") and partB:IsA("BasePart") then
                            
                            -- Projeta a posição 3D exata do osso do mundo real para coordenadas de tela pixeladas
                            local vectorA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                            local vectorB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                            
                            -- Renderiza se os ossos estiverem visíveis na viewport da sua câmera
                            if onScreenA and onScreenB then
                                local lineId = player.Name .. "_" .. bonePair[1] .. "_" .. bonePair[2]
                                activeIds[lineId] = true
                                
                                local screenP1 = Vector2.new(vectorA.X, vectorA.Y)
                                local screenP2 = Vector2.new(vectorB.X, vectorB.Y)
                                
                                drawLineBetweenPoints(lineId, screenP1, screenP2)
                            end
                        end
                    end
                end
            end
        end
    end
    
    clearUnusedLines(activeIds)
end)
