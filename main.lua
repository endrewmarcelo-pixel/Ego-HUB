local Players = game:Service("Players")
local RunService = game.RunService or game:FindService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- VARIÁVEIS DE CONTROLE INTERNAS
-- ==========================================
local wallHackEnabled = false
local speedEnabled = false
local silentAimEnabled = false

local walkSpeedValue = 16 -- Padrão do Roblox
local silentAimFOV = 150  -- Raio do círculo de mira (médio)

-- Interface Principal
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Premium_Menu_Gui")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Premium_Menu_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Elementos de Renderização do Silent Aim e Wallhack
local RenderingContainer = Instance.new("Folder")
RenderingContainer.Name = "RenderingContainer"
RenderingContainer.Parent = ScreenGui

-- Círculo Visual do Silent Aim (FOV)
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 0.9
FOVCircle.Size = UDim2.fromOffset(silentAimFOV * 2, silentAimFOV * 2)
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVUIStroke = Instance.new("UIStroke")
FOVUIStroke.Color = Color3.fromRGB(255, 255, 255)
FOVUIStroke.Thickness = 1
FOVUIStroke.Transparency = 0.5
FOVUIStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0) -- Torna um círculo perfeito
FOVCorner.Parent = FOVCircle

-- Posiciona o FOV no centro da tela e o atualiza
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Visible = silentAimEnabled
end)

-- ==========================================
-- BOTÃO ALFA (REDONDO) PARA ABRIR/FECHAR
-- ==========================================
local MenuFrame = Instance.new("Frame") -- Criado antes para referência

local AlphaButton = Instance.new("TextButton")
AlphaButton.Size = UDim2.fromOffset(50, 50)
AlphaButton.Position = UDim2.new(0.02, 0, 0.2, 0)
AlphaButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AlphaButton.BackgroundTransparency = 0.3 -- Efeito Alfa / Semitransparente
AlphaButton.Text = "M"
AlphaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AlphaButton.Font = Enum.Font.GothamBold
AlphaButton.TextSize = 18
AlphaButton.Active = true
AlphaButton.Parent = ScreenGui

local AlphaCorner = Instance.new("UICorner")
AlphaCorner.CornerRadius = UDim.new(1, 0) -- Redondo
AlphaCorner.Parent = AlphaButton

local AlphaStroke = Instance.new("UIStroke")
AlphaStroke.Thickness = 2
AlphaStroke.Color = Color3.fromRGB(255, 255, 255)
AlphaStroke.Parent = AlphaButton

-- Fazer o Botão Alfa ser Arrastável
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

-- Clique para abrir/fechar o Menu
AlphaButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

-- ==========================================
-- ESTRUTURA DO MENU PRINCIPAL ARRASTÁVEL
-- ==========================================
MenuFrame.Size = UDim2.fromOffset(260, 310)
MenuFrame.Position = UDim2.new(0.05, 0, 0.30, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false -- Inicia fechado
MenuFrame.Active = true
MenuFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MenuFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopLine.BorderSizePixel = 0
TopLine.Parent = MenuFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
})
UIGradient.Parent = TopLine

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "PREMIUM MULTIMENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MenuFrame

-- Função para criar botões padronizados On/Off
local function createMenuButton(yPos, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
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

local ToggleWall, StrokeWall = createMenuButton(50, "WALLHACK (CHAM)")
local ToggleSpeed, StrokeSpeed = createMenuButton(95, "SPEED HACK")
local ToggleAim, StrokeAim = createMenuButton(140, "SILENT AIM")

-- Painel Input de Velocidade (10-1000)
local SpeedInputFrame = Instance.new("Frame")
SpeedInputFrame.Size = UDim2.new(1, -30, 0, 38)
SpeedInputFrame.Position = UDim2.new(0, 15, 0, 185)
SpeedInputFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
SpeedInputFrame.BorderSizePixel = 0
SpeedInputFrame.Parent = MenuFrame

local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 8)
SpeedInputCorner.Parent = SpeedInputFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 110, 1, 0)
SpeedLabel.Position = UDim2.new(0, 15, 0, 0)
SpeedLabel.Text = "Valor da Vel (10-1000):"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedInputFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, -145, 1, -12)
SpeedInput.Position = UDim2.new(0, 130, 0, 6)
SpeedInput.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
SpeedInput.Text = tostring(walkSpeedValue)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 12
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = SpeedInputFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

-- Arrastar o Menu Principal
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
-- LÓGICA DE ATIVAÇÃO DOS BOTÕES
-- ==========================================
local function applyStyles(state, btn, stroke, text)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
        btn.TextColor3 = Color3.fromRGB(75, 230, 130)
        btn.Text = text .. ": ATIVADO"
        stroke.Color = Color3.fromRGB(75, 230, 130)
    else
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
        btn.TextColor3 = Color3.fromRGB(230, 75, 75)
        btn.Text = text .. ": DESATIVADO"
        stroke.Color = Color3.fromRGB(230, 75, 75)
    end
end

ToggleWall.MouseButton1Click:Connect(function()
    wallHackEnabled = not wallHackEnabled
    applyStyles(wallHackEnabled, ToggleWall, StrokeWall, "WALLHACK (CHAM)")
    if not wallHackEnabled then RenderingContainer:ClearAllChildren() end
end)

ToggleSpeed.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    applyStyles(speedEnabled, ToggleSpeed, StrokeSpeed, "SPEED HACK")
end)

ToggleAim.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
