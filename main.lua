local Players = game:GetService("Players")
local RunService = game.RunService or game:FindService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- VARIÁVEIS DE CONTROLE AJUSTÁVEIS
-- ==========================================
local aimbotEnabled = false
local silentAimEnabled = false

local aimbotSmoothness = 5 -- Quanto maior, mais lento/disfarçado é o puxão (1 a 50)
local aimbotFOV = 150       -- Raio do círculo do Aimbot
local silentAimFOV = 120   -- Raio do círculo do Silent Aim

-- Interface Principal
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Combat_Menu_Gui")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Combat_Menu_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ==========================================
-- CÍRCULOS VISUAIS DE FOV (MIRA)
-- ==========================================
local function createFOVCircle(name, color, size)
    local circle = Instance.new("Frame")
    circle.Name = name
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.BackgroundColor3 = color
    circle.BackgroundTransparency = 0.95
    circle.Size = UDim2.fromOffset(size * 2, size * 2)
    circle.Visible = false
    circle.Parent = ScreenGui

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = circle

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle
    return circle
end

local AimbotCircle = createFOVCircle("AimbotFOV", Color3.fromRGB(255, 80, 80), aimbotFOV)
local SilentCircle = createFOVCircle("SilentFOV", Color3.fromRGB(80, 150, 255), silentAimFOV)

-- Atualiza a posição dos círculos no centro da tela
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    local center = UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2)
    
    AimbotCircle.Position = center
    AimbotCircle.Visible = aimbotEnabled
    AimbotCircle.Size = UDim2.fromOffset(aimbotFOV * 2, aimbotFOV * 2)

    SilentCircle.Position = center
    SilentCircle.Visible = silentAimEnabled
    SilentCircle.Size = UDim2.fromOffset(silentAimFOV * 2, silentAimFOV * 2)
end)

-- ==========================================
-- BOTÃO ALFA (REDONDO) PARA ABRIR/FECHAR
-- ==========================================
local MenuFrame = Instance.new("Frame")

local AlphaButton = Instance.new("TextButton")
AlphaButton.Size = UDim2.fromOffset(50, 50)
AlphaButton.Position = UDim2.new(0.02, 0, 0.2, 0)
AlphaButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
AlphaButton.BackgroundTransparency = 0.3
AlphaButton.Text = "AIM"
AlphaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AlphaButton.Font = Enum.Font.GothamBold
AlphaButton.TextSize = 14
AlphaButton.Active = true
AlphaButton.Parent = ScreenGui

local AlphaCorner = Instance.new("UICorner")
AlphaCorner.CornerRadius = UDim.new(1, 0)
AlphaCorner.Parent = AlphaButton

local AlphaStroke = Instance.new("UIStroke")
AlphaStroke.Thickness = 2
AlphaStroke.Color = Color3.fromRGB(255, 255, 255)
AlphaStroke.Parent = AlphaButton

-- Sistema de arrastar o botão Alfa
local btnDragging, btnDragInput, btnDragStart, btnStartPos
AlphaButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true btnDragStart = input.Position btnStartPos = AlphaButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then btnDragging = false end end)
    end
end)
AlphaButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then btnDragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == btnDragInput and btnDragging then
        local delta = input.Position - btnDragStart
        AlphaButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)

AlphaButton.MouseButton1Click:Connect(function() MenuFrame.Visible = not MenuFrame.Visible end)

-- ==========================================
-- PAINEL DO MENU COMBAT ARRASTÁVEL
-- ==========================================
MenuFrame.Size = UDim2.fromOffset(280, 310)
MenuFrame.Position = UDim2.new(0.05, 0, 0.30, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Active = true
MenuFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MenuFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TopLine.BorderSizePixel = 0
TopLine.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "COMBAT ASSIST MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MenuFrame

-- Função para criar botões On/Off
local function createMenuButton(yPos, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 35)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 32)
    btn.Text = text .. ": DESATIVADO"
    btn.TextColor3 = Color3.fromRGB(230, 75, 75)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = MenuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(230, 75, 75)
    stroke.Parent = btn

    return btn, stroke
end

local ToggleAimbot, StrokeAimbot = createMenuButton(45, "LOCK-ON AIMBOT")
local ToggleSilent, StrokeSilent = createMenuButton(90, "SILENT AIM")

-- Função para criar caixas de ajuste (Inputs numéricos)
local function createAdjusterFrame(yPos, labelText, defaultValue)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 35)
    frame.Position = UDim2.new(0, 15, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    frame.BorderSizePixel = 0
    frame.Parent = MenuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(150, 150, 160)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -175, 1, -12)
    input.Position = UDim2.new(0, 160, 0, 6)
    input.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    input.Text = tostring(defaultValue)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = frame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    return input
end

local InputAimSmooth = createAdjusterFrame(140, "Aimbot Suavidade (1-50):", aimbotSmoothness)
local InputAimFOV = createAdjusterFrame(185, "Raio Aimbot FOV (10-800):", aimbotFOV)
local InputSilentFOV = createAdjusterFrame(230, "Raio Silent FOV (10-800):", silentAimFOV)

-- Arrastar o menu principal
local menuDragging, menuDragInput, menuDragStart, menuStartPos
MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true menuDragStart = input.Position menuStartPos = MenuFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then menuDragging = false end end)
    end
end)
MenuFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then menuDragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == menuDragInput and menuDragging then
        local delta = input.Position - menuDragStart
        MenuFrame.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- INTERAÇÕES DOS BOTÕES E VALIDAÇÕES
-- ==========================================
local function updateBtnStyle(state, btn, stroke, text)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
        btn.TextColor3 = Color3.fromRGB(75, 230, 130)
        btn.Text = text .. ": ATIVADO"
        stroke.Color = Color3.fromRGB(75, 230, 130)
    else
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 32)
        btn.TextColor3 = Color3.fromRGB(230, 75, 75)
        btn.Text = text .. ": DESATIVADO"
        stroke.Color = Color3.fromRGB(230, 75, 75)
    end
end

ToggleAimbot.MouseButton1Click:Connect(function() aimbotEnabled = not aimbotEnabled updateBtnStyle(aimbotEnabled, ToggleAimbot, StrokeAimbot, "LOCK-ON AIMBOT") end)
