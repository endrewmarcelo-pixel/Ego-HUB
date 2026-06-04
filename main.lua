local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- VARIÁVEIS DE CONTROLE INTERNAS (Inicia OFF)
-- ==========================================
local espEnabled = false
local maxDistance = 1000

local BONE_COLOR = Color3.fromRGB(255, 255, 255)
local BONE_THICKNESS = 3

local BONE_STRUCTURE = {
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- ==========================================
-- ESTRUTURA VISUAL DO MENU (UI ILUSTRADA)
-- ==========================================
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESP_System_V2")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_System_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

local LinesContainer = Instance.new("Folder")
LinesContainer.Name = "LinesContainer"
LinesContainer.Parent = ScreenGui

-- Painel Principal (Fundo Premium Dark)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradiente Decorativo Superior (Efeito Gamer)
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 12)
TopLineCorner.Parent = TopLine

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
})
UIGradient.Parent = TopLine

-- Cabeçalho / Título com Ícone Ilustrado
local HeaderIcon = Instance.new("ImageLabel")
HeaderIcon.Size = UDim2.new(0, 20, 0, 20)
HeaderIcon.Position = UDim2.new(0, 15, 0, 15)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Image = "rbxassetid://10734951437" -- Ícone de Olho/Visão
HeaderIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
HeaderIcon.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 20)
Title.Position = UDim2.new(0, 42, 0, 15)
Title.Text = "SKELETON ESP v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- ==========================================
-- BOTÃO ON/OFF ILUSTRADO E INTERATIVO
-- ==========================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -30, 0, 40)
ToggleButton.Position = UDim2.new(0, 15, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 30, 35) -- Fundo neutro inicial
ToggleButton.Text = "    ESP: DESATIVADO"
ToggleButton.TextColor3 = Color3.fromRGB(230, 75, 75)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1
ButtonStroke.Color = Color3.fromRGB(230, 75, 75)
ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ButtonStroke.Parent = ToggleButton

-- Ícone de Status Interno do Botão
local StatusIcon = Instance.new("ImageLabel")
StatusIcon.Size = UDim2.new(0, 16, 0, 16)
StatusIcon.Position = UDim2.new(1, -32, 0.5, -8)
StatusIcon.BackgroundTransparency = 1
StatusIcon.Image = "rbxassetid://10734950309" -- Ícone de círculo/X desligado
StatusIcon.ImageColor3 = Color3.fromRGB(230, 75, 75)
StatusIcon.Parent = ToggleButton

-- ==========================================
-- CAMPO DE DISTÂNCIA ILUSTRADO
-- ==========================================
local DistanceFrame = Instance.new("Frame")
DistanceFrame.Size = UDim2.new(1, -30, 0, 40)
DistanceFrame.Position = UDim2.new(0, 15, 0, 105)
DistanceFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
DistanceFrame.BorderSizePixel = 0
DistanceFrame.Parent = MainFrame

local DistCorner = Instance.new("UICorner")
DistCorner.CornerRadius = UDim.new(0, 8)
DistCorner.Parent = DistanceFrame

local DistIcon = Instance.new("ImageLabel")
DistIcon.Size = UDim2.new(0, 18, 0, 18)
DistIcon.Position = UDim2.new(0, 12, 0.5, -9)
DistIcon.BackgroundTransparency = 1
DistIcon.Image = "rbxassetid://10723346959" -- Ícone de régua/métrica
DistIcon.ImageColor3 = Color3.fromRGB(150, 150, 160)
DistIcon.Parent = DistanceFrame

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 80, 1, 0)
DistLabel.Position = UDim2.new(0, 38, 0, 0)
DistLabel.Text = "Alcance:"
DistLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
DistLabel.BackgroundTransparency = 1
DistLabel.Font = Enum.Font.GothamMedium
DistLabel.TextSize = 12
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistanceFrame

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(1, -130, 1, -12)
DistanceInput.Position = UDim2.new(0, 115, 0, 6)
DistanceInput.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
DistanceInput.Text = tostring(maxDistance)
DistanceInput.PlaceholderText = "10-5000"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.GothamBold
DistanceInput.TextSize = 13
DistanceInput.ClearTextOnFocus = false
DistanceInput.Parent = DistanceFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DistanceInput

-- ==========================================
-- INTERAÇÕES E ANIMAÇÕES DO MENU
-- ==========================================

-- Lógica Visual Interativa do Botão On/Off (Muda cores e ícones de forma suave)
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
        ToggleButton.TextColor3 = Color3.fromRGB(75, 230, 130)
        ToggleButton.Text = "    ESP: ATIVADO"
        ButtonStroke.Color = Color3.fromRGB(75, 230, 130)
        StatusIcon.Image = "rbxassetid://10723423719" -- Ícone de Verificado/Check
        StatusIcon.ImageColor3 = Color3.fromRGB(75, 230, 130)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
        ToggleButton.TextColor3 = Color3.fromRGB(230, 75, 75)
        ToggleButton.Text = "    ESP: DESATIVADO"
        ButtonStroke.Color = Color3.fromRGB(230, 75, 75)
        StatusIcon.Image = "rbxassetid://10734950309" -- Ícone de X
        StatusIcon.ImageColor3 = Color3.fromRGB(230, 75, 75)
        LinesContainer:ClearAllChildren()
    end
end)

-- Validação de Input Numérico para Distância
DistanceInput.FocusLost:Connect(function()
    local numericValue = tonumber(DistanceInput.Text)
    if numericValue then maxDistance = math.clamp(numericValue, 10, 5000) end
    DistanceInput.Text = tostring(maxDistance)
end)

-- Motor do Sistema Flutuante / Arrastável
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- ==========================================
-- MOTOR MATEMÁTICO 2D DO ESP BONE
-- ==========================================
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
    local length = diff.Magnitude
    local midpoint = (p1 + p2) / 2
    local angleInDegrees = math.atan2(diff.Y, diff.X) * (180 / math.pi)

    lineFrame.Size = UDim2.fromOffset(length, BONE_THICKNESS)
    lineFrame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
    lineFrame.Rotation = angleInDegrees
end

local function clearUnusedLines(activeIds)
    for _, child in ipairs(LinesContainer:GetChildren()) do
