-- ====================================================================
-- EGO-HUB 2026 - VERSÃO NATIVA COM FLY, WALL E ESP BONE (ANTI-ERRO)
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
local espBoneAtivado = false
local flying = false
local speed = 50

-- Tabelas para guardar os desenhos do esqueleto
local esqueletos Ativos = {}

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

local sucessoGui, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not sucessoGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 255) -- Aumentado para caber o novo botão
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

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

-- Botão Modo Wall (Highlight)
local BtnWall = Instance.new("TextButton")
BtnWall.Parent = MainFrame
BtnWall.Size = UDim2.new(0, 190, 0, 35)
BtnWall.Position = UDim2.new(0.06, 0, 0.18, 0)
BtnWall.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
BtnWall.Text = "Modo Wall: OFF"
BtnWall.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnWall.Font = Enum.Font.SourceSansBold
BtnWall.TextSize = 14

local WallCorner = Instance.new("UICorner")
WallCorner.CornerRadius = UDim.new(0, 6)
WallCorner.Parent = BtnWall

-- BOTÃO NOVO: ESP BONE (ESQUELETO)
local BtnBone = Instance.new("TextButton")
BtnBone.Parent = MainFrame
BtnBone.Size = UDim2.new(0, 190, 0, 35)
BtnBone.Position = UDim2.new(0.06, 0, 0.36, 0)
BtnBone.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
BtnBone.Text = "ESP Bone: OFF"
BtnBone.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBone.Font = Enum.Font.SourceSansBold
BtnBone.TextSize = 14

local BoneCorner = Instance.new("UICorner")
BoneCorner.CornerRadius = UDim.new(0, 6)
BoneCorner.Parent = BtnBone

-- Botão Modo Fly
local BtnFly = Instance.new("TextButton")
BtnFly.Parent = MainFrame
BtnFly.Size = UDim2.new(0, 190, 0, 35)
BtnFly.Position = UDim2.new(0.06, 0, 0.54, 0)
BtnFly.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
BtnFly.Text = "Modo Fly: OFF"
BtnFly.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFly.Font = Enum.Font.SourceSansBold
BtnFly.TextSize = 14

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 6)
FlyCorner.Parent = BtnFly

-- Entrada de Velocidade
local InputSpeed = Instance.new("TextBox")
InputSpeed.Parent = MainFrame
InputSpeed.Size = UDim2.new(0, 190, 0, 35)
InputSpeed.Position = UDim2.new(0.06, 0, 0.73, 0)
InputSpeed.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InputSpeed.Text = "50"
InputSpeed.PlaceholderText = "Velocidade (1-300)"
InputSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
InputSpeed.Font = Enum.Font.SourceSans
InputSpeed.TextSize = 14

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = InputSpeed

-- ====================================================================
-- LÓGICA DO SISTEMA: ESP BONE (ESQUELETO 3D)
-- ====================================================================
local function criarOsso(p1, p2, pai)
    local adorn = Instance.new("CylinderHandleAdornment")
    adorn.Name = "BoneLine"
    adorn.Color3 = Color3.fromRGB(255, 0, 0) -- Cor do esqueleto (Vermelho)
    adorn.AlwaysOnTop = true
    adorn.Radius = 0.08
    adorn.Transparency = 0.2
    adorn.Adornee = p1
    adorn.Parent = pai
    
    -- Atualiza a posição e tamanho do osso baseado na distância das articulações
    local conexao
    conexao = RunService.Heartbeat:Connect(function()
        if not adorn or not adorn.Parent or not p1 or not p2 then
            conexao:Disconnect()
            return
        end
        local mag = (p1.Position - p2.Position).Magnitude
        adorn.Height = mag
        adorn.CFrame = CFrame.lookAt(p1.Position, p2.Position) * CFrame.new(0, 0, -mag/2)
    end)
end

local function designarEsqueleto(player)
    if player == LocalPlayer then return end
    
    local function criar()
        if not espBoneAtivado then return end
        local char = player.Character
        if not char then return end
        
        local pastaBones = Instance.new("Folder")
        pastaBones.Name = "EgoBones"
        pastaBones.Parent = char
        esqueletosAtivos[player] = pastaBones
        
        -- Suporta R15 e R6 de forma inteligente
        if char:WaitForChild("Humanoid", 5).RigType == Enum.HumanoidRigType.R15 then
            local partes = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}
            for _, p in ipairs(partes) do char:WaitForChild(p, 5) end
            
            pcall(function()
                criarOsso(char.Head, char.UpperTorso, pastaBones)
                criarOsso(char.UpperTorso, char.LowerTorso, pastaBones)
                -- Braço Esquerdo
                criarOsso(char.UpperTorso, char.LeftUpperArm, pastaBones)
                criarOsso(char.LeftUpperArm, char.LeftLowerArm, pastaBones)
                -- Braço Direito
                criarOsso(char.UpperTorso, char.RightUpperArm, pastaBones)
                criarOsso(char.RightUpperArm, char.RightLowerArm, pastaBones)
                -- Perna Esquerda
                criarOsso(char.LowerTorso, char.LeftUpperLeg, pastaBones)
                criarOsso(char.LeftUpperLeg, char.LeftLowerLeg, pastaBones)
                -- Perna Direito
                criarOsso(char.LowerTorso, char.RightUpperLeg, pastaBones)
                criarOsso(char.RightUpperLeg, char.RightLowerLeg, pastaBones)
            end)
        else -- R6 Rig
            local partes = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            for _, p in ipairs(partes) do char:WaitForChild(p, 5) end
            
            pcall(function()
                criarOsso(char.Head, char.Torso, pastaBones)
                criarOsso(char.Torso, char["Left Arm"], pastaBones)
                criarOsso(char.Torso, char["Right Arm"], pastaBones)
                criarOsso(char.Torso, char["Left Leg"], pastaBones)
                criarOsso(char.Torso, char["Right Leg"], pastaBones)
            end)
        end
    end
    
    player.CharacterAdded:Connect(function()
        task.wait(1)
        criar()
    end)
    criar()
end

local function removerTodosOsBones()
    for _, folder in pairs(esqueletosAtivos) do
        if folder then folder:Destroy() end
    end
    esqueletosAtivos = {}
end

BtnBone.MouseButton1Click:Connect(function()
    espBoneAtivado = not espBoneAtivado
    if espBoneAtivado then
        BtnBone.Text = "ESP Bone: ON"
        BtnBone.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
        for _, p in ipairs(Players:GetPlayers()) do designarEsqueleto(p) end
    else
        BtnBone.Text = "ESP Bone: OFF"
        BtnBone.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho
        removerTodosOsBones()
    end
end)

-- Vincular lógica de novos jogadores que entrarem na partida
Players.PlayerAdded:Connect(designarEsqueleto)

-- ====================================================================
-- LÓGICA DO SISTEMA 2: MODO WALL (HIGHLIGHT)
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

BtnWall.MouseButton1Click:Connect(function()
    wallAtivado = not wallAtivado
    if wallAtivado then
        BtnWall.Text = "Modo Wall: ON"
        BtnWall.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
