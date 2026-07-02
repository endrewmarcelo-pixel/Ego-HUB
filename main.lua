
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local PlaceBox = Instance.new("TextBox")
    local JobBox = Instance.new("TextBox")
    local TeleportButton = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")
    local UICorner_Frame = Instance.new("UICorner")
    local UICorner_Place = Instance.new("UICorner")
    local UICorner_Job = Instance.new("UICorner")
    local UICorner_Btn = Instance.new("UICorner")
    local UICorner_Close = Instance.new("UICorner")

    -- Configuração do ScreenGui
    ScreenGui.Name = "EgoHub_CustomTeleporter"
    ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Janela Principal (GUI)
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.Position = UDim2.new(0.5, -125, 0.4, -85)
    MainFrame.Size = UDim2.new(0, 250, 0, 175)
    MainFrame.Active = true
    MainFrame.Draggable = true 

    UICorner_Frame.CornerRadius = UDim.new(0, 8)
    UICorner_Frame.Parent = MainFrame

    -- Título da Janela
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Size = UDim2.new(0, 200, 0, 25)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "TELEPORTE: PLACE & JOB"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão Fechar (X)
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Position = UDim2.new(0.85, 0, 0.03, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14

    UICorner_Close.CornerRadius = UDim.new(0, 5)
    UICorner_Close.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Caixinha 1: Place ID
    PlaceBox.Name = "PlaceBox"
    PlaceBox.Parent = MainFrame
    PlaceBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    PlaceBox.Position = UDim2.new(0.05, 0, 0.22, 0)
    PlaceBox.Size = UDim2.new(0.9, 0, 0, 30)
    PlaceBox.Font = Enum.Font.SourceSans
    PlaceBox.PlaceholderText = "Digite o Place ID..."
    PlaceBox.Text = ""
    PlaceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlaceBox.TextSize = 14
    PlaceBox.ClearTextOnFocus = false

    UICorner_Place.CornerRadius = UDim.new(0, 5)
    UICorner_Place.Parent = PlaceBox

    -- Caixinha 2: Job ID
    JobBox.Name = "JobBox"
    JobBox.Parent = MainFrame
    JobBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    JobBox.Position = UDim2.new(0.05, 0, 0.47, 0)
    JobBox.Size = UDim2.new(0.9, 0, 0, 30)
    JobBox.Font = Enum.Font.SourceSans
    JobBox.PlaceholderText = "Cole o Job ID aqui..."
    JobBox.Text = ""
    JobBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    JobBox.TextSize = 14
    JobBox.ClearTextOnFocus = false

    UICorner_Job.CornerRadius = UDim.new(0, 5)
    UICorner_Job.Parent = JobBox

    -- Botão para Executar Ação
    TeleportButton.Name = "TeleportButton"
    TeleportButton.Parent = MainFrame
    TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    TeleportButton.Position = UDim2.new(0.05, 0, 0.73, 0)
    TeleportButton.Size = UDim2.new(0.9, 0, 0, 35)
    TeleportButton.Font = Enum.Font.SourceSansBold
    TeleportButton.Text = "TELEPORTAR"
    TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportButton.TextSize = 16

    UICorner_Btn.CornerRadius = UDim.new(0, 5)
    UICorner_Btn.Parent = TeleportButton

    -- Lógica do Teleporte Seguro com Tratamento de Erros
    TeleportButton.MouseButton1Click:Connect(function()
        local targetPlace = tonumber(PlaceBox.Text:gsub("%s+", ""))
        local targetJob = JobBox.Text:gsub("%s+", "")
        
        if targetPlace and targetJob ~= "" and targetJob ~= "Cole o Job ID aqui..." then
            TeleportButton.Text = "Conectando..."
            TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            task.wait(0.3)
            
            -- O pcall previne quedas do script caso o servidor esteja restrito
            local success, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(targetPlace, targetJob, game:GetService("Players").LocalPlayer)
            end)
            
            if not success then
                TeleportButton.Text = "Erro / Local Restrito"
                TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                task.wait(2)
                TeleportButton.Text = "TELEPORTAR"
                TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            end
        else
            TeleportButton.Text = "Preencha os dois campos!"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1.5)
            TeleportButton.Text = "TELEPORTAR"
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end
