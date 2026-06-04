local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- VARIÁVEIS DE CONTROLE INTERNAS
local espEnabled = true
local maxDistance = 1000

local BONE_COLOR = Color3.fromRGB(255, 255, 255) -- Branco
local BONE_THICKNESS = 3 -- Espessura em Pixels

-- Interface Principal (Telas, Menu e Linhas juntas)
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESP_System")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_System"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Otimiza o alinhamento de tela do Roblox
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Pasta de Linhas 2D de Alta Performance (Dentro do ScreenGui para nunca sumir)
local LinesContainer = Instance.new("Folder")
LinesContainer.Name = "LinesContainer"
LinesContainer.Parent = ScreenGui

-- INTERFACE GRÁFICA (UI) DO MENU
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 220, 0, 130)
MenuFrame.Position = UDim2.new(0, 20, 0.4, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
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
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
ToggleButton.Text = "ESP: ATIVADO"
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
DistanceInput.PlaceholderText = "Distância (10-5000)"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.SourceSans
DistanceInput.TextSize = 16
DistanceInput.ClearTextOnFocus = false
DistanceInput.Parent = MenuFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DistanceInput

-- LÓGICA DO MENU
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
    if numericValue then
        maxDistance = math.clamp(numericValue, 10, 5000)
    end
    DistanceInput.Text = tostring(maxDistance)
end)

-- FUNÇÃO MATEMÁTICA DE PROJEÇÃO DE LINHA NA TELA
local function updateScreenLine(id, screenPos1, screenPos2)
    local lineFrame = LinesContainer:FindFirstChild(id)
    if not lineFrame then
        lineFrame = Instance.new("Frame")
        lineFrame.Name = id
        lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        lineFrame.BackgroundColor3 = BONE_COLOR
        lineFrame.BorderSizePixel = 0
        lineFrame.Parent = LinesContainer
    end

    local distance = (screenPos1 - screenPos2).Magnitude
    local center = (screenPos1 + screenPos2) / 2
    local angle = math.atan2(screenPos2.Y - screenPos1.Y, screenPos2.X - screenPos1.X)

    lineFrame.Size = UDim2.new(0, distance, 0, BONE_THICKNESS)
    lineFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    lineFrame.Rotation = math.rad(angle)
end

local function clearUnusedLines(activeIds)
    for _, child in ipairs(LinesContainer:GetChildren()) do
        if not activeIds[child.Name] then
            child:Destroy()
        end
    end
end

-- LOOP PRINCIPAL ATUALIZADO VIA CAMERA (RENDER STEPPED)
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
                    for _, object in ipairs(char:GetDescendants()) do
                        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
                            local part0 = object.Part0
                            local part1 = object.Part1
                            
                            -- Mantém os filtros aplicados anteriormente (Sem Cabeça e Sem Itens)
                            if part0.Name ~= "Handle" and part1.Name ~= "Handle" and part0.Name ~= "Head" and part1.Name ~= "Head" then
                                
                                -- Projeta os pontos 3D reais para a tela do seu monitor
                                local pos3D_1, onScreen1 = Camera:WorldToViewportPoint(part0.Position)
                                local pos3D_2, onScreen2 = Camera:WorldToViewportPoint(part1.Position)
                                
                                -- Só desenha se ambas as partes estiverem no campo de visão da câmera
                                if onScreen1 and onScreen2 then
                                    local lineId = player.Name .. "_" .. part0.Name .. "_" .. part1.Name
                                    activeIds[lineId] = true
                                    
                                    local screenPos1 = Vector2.new(pos3D_1.X, pos3D_1.Y)
                                    local screenPos2 = Vector2.new(pos3D_2.X, pos3D_2.Y)
                                    
                                    updateScreenLine(lineId, screenPos1, screenPos2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    clearUnusedLines(activeIds)
end)
