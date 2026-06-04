-- ====================================================================
-- EGO-HUB 2026 - REPOSITÓRIO ATUALIZADO E LINK ANTIBUG
-- ====================================================================

-- 1. Carrega a Biblioteca Rayfield com o link oficial e estável do GitHub
local Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()

-- 2. Cria a Janela Principal do Menu
local Window = Rayfield:CreateWindow({
   Name = "Ego-HUB | Multi-Hack",
   Icon = 0,
   LoadingTitle = "Carregando Interface...",
   LoadingSubtitle = "Por favor, aguarde",
   Theme = "Default",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

-- 3. Cria as Abas do Menu
local TabVisual = Window:CreateTab("Visuais", 4483362458)
local TabFly = Window:CreateTab("Movimento", 4483362458)

-- ====================================================================
-- SISTEMA 1: MODO WALL / ESP (DESTAQUE DE JOGADORES)
-- ====================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local wallAtivado = false
local COR_BRILHO = Color3.fromRGB(0, 255, 0) -- Verde
local TRANSPARENCIA = 0.5

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
    highlight.FillColor = COR_BRILHO
    highlight.FillTransparency = TRANSPARENCIA
    highlight.OutlineTransparency = 1
    highlight.Parent = character
end

local function conectarJogador(player)
    player.CharacterAdded:Connect(function(char) if wallAtivado then aplicarDestaque(char) end end)
    if player.Character and wallAtivado then aplicarDestaque(player.Character) end
end

for _, player in ipairs(Players:GetPlayers()) do conectarJogador(player) end
Players.PlayerAdded:Connect(conectarJogador)

TabVisual:CreateToggle({
   Name = "Modo Wall (Highlight ESP)",
   CurrentValue = false,
   Flag = "WallToggle",
   Callback = function(Value)
       wallAtivado = Value
       if wallAtivado then
           for _, p in ipairs(Players:GetPlayers()) do if p.Character then aplicarDestaque(p.Character) end end
       else
           removerTodosOsDestaques()
       end
   end,
})

-- ====================================================================
-- SISTEMA 2: MODO FLY (VOO COM CONTROLE DE VELOCIDADE)
-- ====================================================================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local flying = false
local speed = 50 

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

RunService.RenderStepped:Connect(function()
	if not flying or not hrp then return end
	local direction = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
	linearVelocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.new(0, 0, 0)
end)

TabFly:CreateToggle({
   Name = "Ativar Modo Voo (FLY)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value) setFlyState(Value) end,
})

TabFly:CreateSlider({
   Name = "Velocidade do Voo",
   Range = {1, 300},
   Increment = 1,
   Suffix = " Studs/s",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value) speed = Value end,
})

Rayfield:Notify({
   Title = "Ego-HUB",
   Content = "Menu carregado! Sistemas integrados.",
   Duration = 5,
   Image = 4483362458,
})
