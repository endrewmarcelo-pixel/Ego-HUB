-- ACESSO DIRETO SEGURO (Bypass de erros de injeção)
local Players = game.Players or game:FindService("Players")
local RunService = game.RunService or game:FindService("RunService")
local UserInputService = game.UserInputService or game:FindService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- CONFIGURAÇÕES E ESTADOS INTERNOS
-- ==========================================
local silentAimEnabled = false
local espBonesEnabled = false
local espNamesEnabled = false
local espLifeEnabled = false

local silentAimFOV = 120
local maxESPDistance = 1000

local BONE_COLOR = Color3.fromRGB(255, 255, 255)
local BONE_THICKNESS = 2

local BONE_STRUCTURE = {
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- Interface Gráfica Principal
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Universal_Cheat_v4")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Universal_Cheat_v4"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

local DrawingFolder = Instance.new("Folder")
DrawingFolder.Name = "DrawingFolder"
DrawingFolder.Parent = ScreenGui

-- ==========================================
-- CÍRCULO VISUAL DO SILENT AIM (FOV)
-- ==========================================
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FOVCircle.BackgroundTransparency = 0.96
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVCircle.ZIndex = 1
FOVCircle.Size = UDim2.fromOffset(silentAimFOV * 2, silentAimFOV * 2)
FOVStroke.Color = Color3.fromRGB(0, 150, 255)
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Size = UDim2.fromOffset(silentAimFOV * 2, silentAimFOV * 2)
    FOVCircle.Visible = silentAimEnabled
end)

-- ==========================================
-- BOTÃO ALFA REDONDO (ABRIR / FECHAR)
-- ==========================================
local MainFrame = Instance.new("Frame")

local AlphaButton = Instance.new("TextButton")
AlphaButton.Size = UDim2.fromOffset(45, 45)
AlphaButton.Position = UDim2.new(0.02, 0, 0.2, 0)
AlphaButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AlphaButton.BackgroundTransparency = 0.2
AlphaButton.Text = "MENU"
AlphaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AlphaButton.Font = Enum.Font.GothamBold
AlphaButton.TextSize = 10
AlphaButton.Active = true
AlphaButton.ZIndex = 20
AlphaButton.Parent = ScreenGui

local AlphaCorner = Instance.new("UICorner")
AlphaCorner.CornerRadius = UDim.new(1, 0)
AlphaCorner.Parent = AlphaButton

local AlphaStroke = Instance.new("UIStroke")
AlphaStroke.Thickness = 2
AlphaStroke.Color = Color3.fromRGB(255, 255, 255)
AlphaStroke.Parent = AlphaButton

-- Arrastador do Botão Alfa
local bDrag, bInput, bStart, bPos
AlphaButton.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        bDrag = true bStart = i.Position bPos = AlphaButton.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then bDrag = false end end)
    end
end)
AlphaButton.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then bInput = i end end)
UserInputService.InputChanged:Connect(function(i)
    if i == bInput and bDrag then
        local d = i.Position - bStart
        AlphaButton.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
    end
end)

AlphaButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ==========================================
-- PAINEL DO MENU DESIGN PREMIUM
-- ==========================================
MainFrame.Size = UDim2.fromOffset(260, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.28, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.Text = "UNIVERSAL ASSIST v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame

-- Arrastador do Menu Principal
local mDrag, mInput, mStart, mPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDrag = true mStart = i.Position mPos = MainFrame.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then mDrag = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then mInput = i end end)
UserInputService.InputChanged:Connect(function(i)
    if i == mInput and mDrag then
        local d = i.Position - mStart
        MainFrame.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
    end
end)

-- Componente: Botões Alternadores On/Off
local function createToggle(yPos, text, defaultState, callback)
    local state = defaultState

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 34)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 11
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Parent = btn

    local function updateVisual()
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
            btn.TextColor3 = Color3.fromRGB(75, 220, 130)
            btn.Text = text .. ": LIGADO"
            stroke.Color = Color3.fromRGB(75, 220, 130)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 25, 28)
            btn.TextColor3 = Color3.fromRGB(220, 75, 75)
            btn.Text = text .. ": DESLIGADO"
            stroke.Color = Color3.fromRGB(220, 75, 75)
        end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)

    updateVisual()
end

-- Instanciando os Botões
createToggle(45, "SILENT AIM", silentAimEnabled, function(v) silentAimEnabled = v end)
createToggle(85, "ESP BONES", espBonesEnabled, function(v) espBonesEnabled = v DrawingFolder:ClearAllChildren() end)
createToggle(125, "ESP NAMES", espNamesEnabled, function(v) espNamesEnabled = v DrawingFolder:ClearAllChildren() end)
createToggle(165, "ESP LIFE (BARRA)", espLifeEnabled, function(v) espLifeEnabled = v DrawingFolder:ClearAllChildren() end)

-- Componente: Sliders Ajustáveis (CORRIGIDO SEM ERROS DE PARENTING)
local function createSlider(yPos, labelText, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 45)
    frame.Position = UDim2.new(0, 15, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.Text = labelText .. ": " .. default
    label.TextColor3 = Color3.fromRGB(160, 160, 170)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12
    label.Parent = frame

    local slideBar = Instance.new("TextButton")
    slideBar.Size = UDim2.new(1, -20, 0, 6)
    slideBar.Position = UDim2.new(0, 10, 0, 28)
    slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    slideBar.Text = ""
    slideBar.ZIndex = 12
    slideBar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = slideBar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 13
    fill.Parent = slideBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

