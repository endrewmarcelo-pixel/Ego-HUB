-- Criando a Interface Gráfica Segura
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local TeleportButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner_Frame = Instance.new("UICorner")
local UICorner_Box = Instance.new("UICorner")
local UICorner_Btn = Instance.new("UICorner")
local UICorner_Close = Instance.new("UICorner")

-- Configurando a Janela Principal
ScreenGui.Name = "TeleportGui_AntiCrash"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -65)
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true 

UICorner_Frame.CornerRadius = UDim.new(0, 8)
UICorner_Frame.Parent = MainFrame

-- Título
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.Size = UDim2.new(0, 200, 0, 25)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "TELEPORTE POR JOB ID"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão de Fechar [X]
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

UICorner_Close.CornerRadius = UDim.new(0, 5)
UICorner_Close.Parent = CloseButton
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Caixinha de Escrita
TextBox.Name = "TextBox"
TextBox.Parent = MainFrame
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TextBox.Position = UDim2.new(0.05, 0, 0.3, 0)
TextBox.Size = UDim2.new(0.9, 0, 0, 30)
TextBox.Font = Enum.Font.SourceSans
TextBox.PlaceholderText = "Cole o Job ID aqui..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 14
TextBox.ClearTextOnFocus = false

UICorner_Box.CornerRadius = UDim.new(0, 5)
UICorner_Box.Parent = TextBox

-- Botão de Executar
TeleportButton.Name = "TeleportButton"
TeleportButton.Parent = MainFrame
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TeleportButton.Position = UDim2.new(0.05, 0, 0.65, 0)
TeleportButton.Size = UDim2.new(0.9, 0, 0, 35)
TeleportButton.Font = Enum.Font.SourceSansBold
TeleportButton.Text = "TELEPORTAR"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextSize = 16

UICorner_Btn.CornerRadius = UDim.new(0, 5)
UICorner_Btn.Parent = TeleportButton

-- Função de Teleporte Tratada
TeleportButton.MouseButton1Click:Connect(function()
    local targetId = TextBox.Text:gsub("%s+", "") -- Limpa espaços
    
    if targetId ~= "" and targetId ~= "Cole o Job ID aqui..." then
        TeleportButton.Text = "Verificando Restrições..."
        TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        task.wait(0.5)
        
        local placeId = game.PlaceId
        local teleportService = game:GetService("TeleportService")
        local localPlayer = game:GetService("Players").LocalPlayer
        
        -- O pcall protege o script de fechar o jogo em caso de erro de restrição
        local success, err = pcall(function()
            teleportService:TeleportToPlaceInstance(placeId, targetId, localPlayer)
        end)
        
        if not success then
            TeleportButton.Text = "Local Restrito / Erro!"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(2.5)
            TeleportButton.Text = "TELEPORTAR"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    else
        TeleportButton.Text = "Insira um ID válido!"
        TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(2)
        TeleportButton.Text = "TELEPORTAR"
        TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end
end)
