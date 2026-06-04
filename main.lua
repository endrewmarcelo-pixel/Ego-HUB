-- ==========================================
--               EGO-HUB 2026                
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
local ativado = true
local COR_BRILHO = Color3.fromRGB(0, 255, 0) -- Verde
local TRANSPARENCIA = 0.5

-- Criando a Interface Visual (UI)
local ScreenGui = Instance.new("ScreenGui")
local Botao = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "EgoHubUI"
ScreenGui.ResetOnSpawn = false -- Garante que o botão não suma se você morrer

-- Injeção segura na interface
local sucesso, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not sucesso then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Estilização do Botão Flutuante
Botao.Name = "AlternarEfeito"
Botao.Parent = ScreenGui
Botao.Size = UDim2.new(0, 120, 0, 40)
Botao.Position = UDim2.new(0.05, 0, 0.4, 0) -- Lado esquerdo da tela
Botao.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde Esmeralda
Botao.Text = "Ego-HUB: ON"
Botao.TextColor3 = Color3.fromRGB(255, 255, 255)
Botao.Font = Enum.Font.SourceSansBold
Botao.TextSize = 14
Botao.BorderSizePixel = 0
Botao.Draggable = true -- Arrasta para qualquer lugar da tela

-- Arredondamento das bordas
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Botao

-- Função para remover o efeito de todos
local function removerTodosOsDestaques()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local destaque = player.Character:FindFirstChild("DestaqueEgoHub")
            if destaque then
                destaque:Destroy()
            end
        end
    end
end

-- Função para aplicar o efeito visual
local function aplicarDestaque(character)
    if not ativado or not character then return end
    if character.Name == LocalPlayer.Name then return end

    -- Espera até 3 segundos pelo corpo carregar
    local root = character:WaitForChild("HumanoidRootPart", 3)
    if not root then return end

    if not character:FindFirstChild("DestaqueEgoHub") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "DestaqueEgoHub"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = COR_BRILHO
        highlight.FillTransparency = TRANSPARENCIA
        highlight.OutlineTransparency = 1
        highlight.Parent = character
    end
end

-- Gerenciamento correto de novos e antigos jogadores
local function conectarJogador(player)
    player.CharacterAdded:Connect(function(char)
        if ativado then
            aplicarDestaque(char)
        end
    end)
    if player.Character and ativado then
        aplicarDestaque(player.Character)
    end
end

-- Inicia o monitoramento global
for _, player in ipairs(Players:GetPlayers()) do
    conectarJogador(player)
end
Players.PlayerAdded:Connect(conectarJogador)

-- Lógica do clique do botão (Ligar/Desligar)
Botao.MouseButton1Click:Connect(function()
    ativado = not ativado
    
    if ativado then
        Botao.Text = "Ego-HUB: ON"
        Botao.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then aplicarDestaque(p.Character) end
        end
    else
        Botao.Text = "Ego-HUB: OFF"
        Botao.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho
        removerTodosOsDestaques()
    end
end)
-- 1. Carrega a Biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- 2. Cria a Janela do Menu
local Window = Rayfield:CreateWindow({
   Name = "Ego-HUB | Fly Menu",
   LoadingTitle = "Carregando Interface...",
   LoadingSubtitle = "Por favor, aguarde",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

-- 3. Cria a Aba de Funções
local TabFly = Window:CreateTab("Voo", 4483362458)

-- 4. Variáveis e Lógica do FLY Mode
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local flying = false
local speed = 50 -- Velocidade inicial padrão

-- Garante que o script se adapte se o personagem morrer e renascer
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- Cria a força física para o voo
local attachment = Instance.new("Attachment", hrp)
local linearVelocity = Instance.new("LinearVelocity", hrp)
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = math.huge
linearVelocity.Enabled = false

local function setFlyState(state)
	flying = state
	linearVelocity.Enabled = flying
	
	if flying then
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

-- Atualiza a direção do voo baseado nos comandos e na câmera
RunService.RenderStepped:Connect(function()
	if not flying then return end
	
	local direction = Vector3.new(0, 0, 0)
	
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
	
	if direction.Magnitude > 0 then
		linearVelocity.VectorVelocity = direction.Unit * speed
	else
		linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
	end
end)

-- 5. Elementos da Interface

-- Botão ON/OFF do Voo
TabFly:CreateToggle({
   Name = "Ativar Modo Voo (FLY)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       setFlyState(Value)
   end,
})

-- Linha Reta / Slider de Velocidade (1 ao 300)
TabFly:CreateSlider({
   Name = "Velocidade do Voo",
   Range = {1, 300},
   Increment = 1,
   Suffix = " Studs/s",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
       speed = Value -- Atualiza a variável velocidade em tempo real
   end,
})

-- Notificação de inicialização bem-sucedida
Rayfield:Notify({
   Title = "Ego-HUB",
   Content = "Menu carregado com controle de velocidade!",
   Duration = 4,
   Image = 4483362458,
})
