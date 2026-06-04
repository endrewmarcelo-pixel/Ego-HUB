local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE INTERNAS
local espEnabled = true
local maxDistance = 1000

local BONE_COLOR = Color3.fromRGB(0, 255, 0)
local BONE_THICKNESS = 2 -- Espessura para LineHandleAdornment (em pixels/escala relativa)

-- Pasta para armazenar as linhas
local ESP_Folder = workspace:FindFirstChild("ESP_Bones_Folder")
if not ESP_Folder then
    ESP_Folder = Instance.new("Folder")
    ESP_Folder.Name = "ESP_Bones_Folder"
    ESP_Folder.Parent = workspace
end

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

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Menu ESP Bone Universal"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

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
        ESP_Folder:ClearAllChildren()
    end
end)

DistanceInput.FocusLost:Connect(function(enterPressed)
    local numericValue = tonumber(DistanceInput.Text)
    if numericValue then
        maxDistance = math.clamp(numericValue, 10, 5000)
    end
    DistanceInput.Text = tostring(maxDistance)
end)

-- FUNÇÃO ATUALIZADA UTILIZANDO LINEHANDLEADORNMENT (RENDERIZAÇÃO GARANTIDA NO WORKSPACE)
local function drawBoneLine(id, part1, part2)
    local line = ESP_Folder:FindFirstChild(id)
    if not line then
        line = Instance.new("LineHandleAdornment")
        line.Name = id
        line.Color3 = BONE_COLOR
        line.Thickness = BONE_THICKNESS
        line.AlwaysOnTop = true -- Força a exibição através das paredes
        line.ZIndex = 10
        line.Parent = ESP_Folder
    end
    
    -- Ancorando dinamicamente ao espaço do mundo 3D
    line.Adornee = part1
    line.Length = (part1.Position - part2.Position).Magnitude
    line.CFrame = part1.CFrame:ToObjectSpace(CFrame.lookAt(part1.Position, part2.Position))
end

local function clearUnusedLines(activeIds)
    for _, child in ipairs(ESP_Folder:GetChildren()) do
        if not activeIds[child.Name] then
            child:Destroy()
        end
    end
end

-- LOOP DE RENDERIZAÇÃO
RunService.RenderStepped:Connect(function()
    local activeIds = {}
    
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
                
                if distance <= maxDistance then
                    -- Varre todas as juntas físicas do esqueleto (Funciona em R6, R15 e rigs customizados)
                    for _, object in ipairs(char:GetDescendants()) do
                        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
                            local part0 = object.Part0
                            local part1 = object.Part1
                            
                            if part0.Name ~= "Handle" and part1.Name ~= "Handle" then
                                local lineId = player.Name .. "_" .. part0.Name .. "_" .. part1.Name
                                activeIds[lineId] = true
                                drawBoneLine(lineId, part0, part1)
                            end
                        end
                    end
                end
            end
        end
    end
    
    clearUnusedLines(activeIds)
end)
