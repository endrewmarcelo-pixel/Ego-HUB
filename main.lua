-- ====================================================================
-- EGO-HUB 2026 - VERSÃO NATIVA SEM BIBLIOTECAS EXTERNAS (ANTI-ERRO)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Estados globais
local wallAtivado = false
local flying = false
local speed = 50

-- Atualiza referências ao renascer
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- ====================================================================
-- CRIAÇÃO DA INTERFACE VISUAL PADRÃO (ROBLOX GUI)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EgoHubNativo"
ScreenGui.ResetOnSpawn = false

-- Injeção segura na interface
local sucessoGui, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not sucessoGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Painel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 210)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar o menu pela tela

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Título do Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Ego-HUB | Nativo"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Botão Modo Wall (ESP)
local BtnWall = Instance.new("TextButton")
BtnWall.Name = "BtnWall"
BtnWall.Parent = MainFrame
BtnWall.Size = UDim2.new(0, 190, 0, 35)
BtnWall.Position = UDim2.new(0.06, 0, 0.25, 0)
BtnWall.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho (Desativado)
BtnWall.Text = "Modo Wall: OFF"
BtnWall.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnWall.Font = Enum.Font.SourceSansBold
BtnWall.TextSize = 14
BtnWall.BorderSizePixel = 0

local WallCorner = Instance.new("UICorner")
WallCorner.CornerRadius = UDim.new(0, 6)
WallCorner.Parent = BtnWall

-- Botão Modo Fly (Voo)
local BtnFly = Instance.new("TextButton")
BtnFly.Name = "BtnFly"
BtnFly.Parent = MainFrame
BtnFly.Size = UDim2.new(0, 190, 0, 35)
BtnFly.Position = UDim2.new(0.06, 0, 0.48, 0)
BtnFly.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho (Desativado)
BtnFly.Text = "Modo Fly: OFF"
BtnFly.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFly.Font = Enum.Font.SourceSansBold
BtnFly.TextSize = 14
BtnFly.BorderSizePixel = 0

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 6)
FlyCorner.Parent = BtnFly

-- Caixa de Texto para Velocidade (Substitui o Slider para evitar bugs)
local InputSpeed = Instance.new("TextBox")
InputSpeed.Name = "InputSpeed"
InputSpeed.Parent = MainFrame
InputSpeed.Size = UDim2.new(0, 190, 0, 35)
InputSpeed.Position = UDim2.new(0.06, 0, 0.72, 0)
InputSpeed.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InputSpeed.Text = "50"
InputSpeed.PlaceholderText = "Velocidade (1-300)"
InputSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
InputSpeed.Font = Enum.Font.SourceSans
InputSpeed.TextSize = 14
InputSpeed.BorderSizePixel = 0

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = InputSpeed

-- ====================================================================
-- LÓGICA DO SISTEMA 1: MODO WALL / ESP
-- ====================================================================
local function removerTodosOsDestaques()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local destaque = player.Character:FindFirstChild("DestaqueEgoHub")
            if destaque then destaque:Destroy() end
        end
    end
end

local function aplicarDestaque(character)
    if not wallAtivado or not character or character.Name == LocalPlayer.Name then return end
    local root = character:WaitForChild("HumanoidRootPart", 3)
    if not root or character:FindFirstChild("DestaqueEgoHub") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "DestaqueEgoHub"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.Parent = character
end

local function conectarJogador(player)
    player.CharacterAdded:Connect(function(char) if wallAtivado then aplicarDestaque(char) end end)
    if player.Character and wallAtivado then aplicarDestaque(player.Character) end
end

for _, player in ipairs(Players:GetPlayers()) do conectarJogador(player) end
Players.PlayerAdded:Connect(conectarJogador)

BtnWall.MouseButton1Click:Connect(function()
    wallAtivado = not wallAtivado
    if wallAtivado then
        BtnWall.Text = "Modo Wall: ON"
        BtnWall.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
        for _, p in ipairs(Players:GetPlayers()) do if p.Character then aplicarDestaque(p.Character) end end
    else
        BtnWall.Text = "Modo Wall: OFF"
        BtnWall.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho
        removerTodosOsDestaques()
    end
end)

-- ====================================================================
-- LÓGICA DO SISTEMA 2: MODO FLY
-- ====================================================================
local attachment = Instance.new("Attachment", hrp)
local linearVelocity = Instance.new("LinearVelocity", hrp)
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
linearVelocity.Enabled = false

local function setFlyState(state)
    flying = state
    linearVelocity.Enabled = flying
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:ChangeState(flying and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp)
    end
end

BtnFly.MouseButton1Click:Connect(function()
    setFlyState(not flying)
    if flying then
        BtnFly.Text = "Modo Fly: ON"
        BtnFly.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
    else
        BtnFly.Text = "Modo Fly: OFF"
        BtnFly.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho
    end
end)

-- Atualiza a velocidade digitada na caixa de texto (Limita entre 1 e 300)
InputSpeed.FocusLost:Connect(function(enterPressed)
    local valor = tonumber(InputSpeed.Text)
    if valor then
        speed = math.clamp(valor, 1, 300)
        InputSpeed.Text = tostring(speed)
    else
        InputSpeed.Text = tostring(speed)
    end
end)

RunService.RenderStepped:Connect(function()
    if not flying or not hrp then return end
    local direction = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
    linearVelocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.new(0, 0, 0)
end)

-- Ativando o atalho ocultar/mostrar com a tecla HOME
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Home then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
