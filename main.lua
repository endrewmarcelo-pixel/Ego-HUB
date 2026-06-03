-- Configurações do Efeito
local COR_BRILHO = Color3.fromRGB(0, 255, 0) -- Verde (Altere como quiser)
local TRANSPARENCIA = 0.5 -- 0 é totalmente visível, 1 é invisível

-- Função que aplica o destaque em um personagem específico
local function aplicarDestaque(character)
    if not character then return end
    
    -- Evita aplicar o efeito no seu próprio personagem
    local localPlayer = game:GetService("Players").LocalPlayer
    if character.Name == localPlayer.Name then return end

    -- Espera a parte principal do corpo carregar
    character:WaitForChild("HumanoidRootPart", 5)

    -- Verifica se o personagem já tem o efeito para não duplicar
    if not character:FindFirstChild("DestaqueEgoHub") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "DestaqueEgoHub"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = COR_BRILHO
        highlight.FillTransparency = TRANSPARENCIA
        highlight.OutlineTransparency = 1 -- Remove a linha de contorno para ficar mais limpo
        highlight.Parent = character
    end
end

-- Monitora todos os jogadores atuais e os novos que entrarem
local function monitorarJogadores()
    local Players = game:GetService("Players")

    -- Aplica para os jogadores que já estão no servidor
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            aplicarDestaque(player.Character)
        end
        -- Monitora se o jogador morrer e renascer
        player.CharacterAdded:Connect(aplicarDestaque)
    end

    -- Monitora novos jogadores que entrarem no servidor depois
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(aplicarDestaque)
    end)
end

-- Executa a função principal
monitorarJogadores()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") -- Garante que a interface não suma ao morrer
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
local ativado = true
local COR_BRILHO = Color3.fromRGB(0, 255, 0)
local TRANSPARENCIA = 0.5

-- Criando a Interface Visual (UI)
local ScreenGui = Instance.new("ScreenGui")
local Botao = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Configurações da Tela
ScreenGui.Name = "EgoHubUI"
-- Tenta colocar no CoreGui para proteção; se o executor não permitir, coloca no PlayerGui
local sucesso, erro = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not sucesso then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Configurações do Botão (Estilo Redondo e Moderno)
Botao.Name = "AlternarEfeito"
Botao.Parent = ScreenGui
Botao.Size = UDim2.new(0, 110, 0, 45)
Botao.Position = UDim2.new(0.05, 0, 0.4, 0) -- Fica no lado esquerdo médio da tela
Botao.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde Inicial
Botao.Text = "Ego-HUB: ON"
Botao.TextColor3 = Color3.fromRGB(255, 255, 255)
Botao.Font = Enum.Font.SourceSansBold
Botao.TextSize = 16
Botao.Draggable = true -- Permite arrastar o botão para onde você quiser na tela

-- Deixa os cantos do botão arredondados
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Botao

-- Função para remover o efeito de todos os personagens
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

-- Função para aplicar o destaque em um personagem específico
local function aplicarDestaque(character)
    if not ativado or not character then return end
    if character.Name == LocalPlayer.Name then return end

    character:WaitForChild("HumanoidRootPart", 5)

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

-- Monitoramento contínuo dos personagens no mapa
local function atualizarTodosOsJogadores()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            aplicarDestaque(player.Character)
        end
    end
end

-- Eventos de novos personagens surgindo
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if ativado then
            aplicarDestaque(char)
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function(char)
        if ativado then
            aplicarDestaque(char)
        end
    end)
end

-- Lógica do Clique no Botão (Alternar)
Botao.MouseButton1Click:Connect(function()
    ativado = not ativado -- Inverte o estado atual
    
    if ativado then
        Botao.Text = "Ego-HUB: ON"
        Botao.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
        atualizarTodosOsJogadores()
    else
        Botao.Text = "Ego-HUB: OFF"
        Botao.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vermelho
        removerTodosOsDestaques()
    end
end)

-- Execução inicial ao injetar o script
atualizarTodosOsJogadores()
