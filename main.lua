-- ACESSO DIRETO SEGURO AO MOTOR DO ROBLOX
local Players = game.Players or game:FindService("Players")
local RunService = game.RunService or game:FindService("RunService")
local UserInputService = game.UserInputService or game:FindService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÕES E ESTADOS INTERNOS
local silentAimEnabled = false
local silentAimFOV = 120

-- Interface Gráfica Principal
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SilentAim_Gui")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAim_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ==========================================
-- CÍRCULO VISUAL DO SILENT AIM (FOV)
-- ==========================================
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FOVCircle.BackgroundTransparency = 0.96
FOVCircle.Visible = false
FOVCircle.ZIndex = 1
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
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
AlphaButton.Text = "SILENT"
AlphaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AlphaButton.Font = Enum.Font.GothamBold
AlphaButton.TextSize = 9
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
local bDrag, bStart, bPos
AlphaButton.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        bDrag = true bStart = i.Position bPos = AlphaButton.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then bDrag = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if bDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - bStart
        AlphaButton.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
    end
end)

AlphaButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ==========================================
-- PAINEL DO MENU PRINCIPAL ARRASTÁVEL
-- ==========================================
MainFrame.Size = UDim2.fromOffset(240, 140)
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
Title.Text = "SILENT AIM CONTROL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

-- Arrastador do Menu Principal
local mDrag, mStart, mPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDrag = true mStart = i.Position mPos = MainFrame.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then mDrag = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if mDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - mStart
        MainFrame.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
    end
end)

-- Botão Alternador On/Off
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -30, 0, 34)
ToggleBtn.Position = UDim2.new(0, 15, 0, 45)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.ZIndex = 11
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 1
BtnStroke.Parent = ToggleBtn

local function updateVisual()
    if silentAimEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
        ToggleBtn.TextColor3 = Color3.fromRGB(75, 220, 130)
        ToggleBtn.Text = "SILENT AIM: LIGADO"
        BtnStroke.Color = Color3.fromRGB(75, 220, 130)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 28)
        ToggleBtn.TextColor3 = Color3.fromRGB(220, 75, 75)
        ToggleBtn.Text = "SILENT AIM: DESLIGADO"
        BtnStroke.Color = Color3.fromRGB(220, 75, 75)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    updateVisual()
end)
updateVisual()

-- Slider Ajustável do FOV
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -30, 0, 45)
SliderFrame.Position = UDim2.new(0, 15, 0, 85)
SliderFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
SliderFrame.BorderSizePixel = 0
SliderFrame.ZIndex = 11
SliderFrame.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = SliderFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -20, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 4)
SliderLabel.Text = "Raio do FOV: " .. silentAimFOV
SliderLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextSize = 10
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.ZIndex = 12
SliderLabel.Parent = SliderFrame

local SlideBar = Instance.new("TextButton")
SlideBar.Size = UDim2.new(1, -20, 0, 6)
SlideBar.Position = UDim2.new(0, 10, 0, 28)
SlideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SlideBar.Text = ""
SlideBar.ZIndex = 12
SlideBar.Parent = SliderFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = SlideBar

local FillBar = Instance.new("Frame")
FillBar.Size = UDim2.new((silentAimFOV - 10) / (600 - 10), 0, 1, 0)
FillBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
FillBar.BorderSizePixel = 0
FillBar.ZIndex = 13
FillBar.Parent = SlideBar

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = FillBar

local function slide(input)
    local rawPercentage = (input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X
    local percentage = math.clamp(rawPercentage, 0, 1)
    FillBar.Size = UDim2.new(percentage, 0, 1, 0)
    local value = math.floor(10 + (percentage * (600 - 10)))
    SliderLabel.Text = "Raio do FOV: " .. value
    silentAimFOV = value
end

local sliding = false
SlideBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true slide(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        slide(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
end)

-- ==========================================
-- MOTOR MATEMÁTICO INTERNO DO SILENT AIM
-- ==========================================
local function getClosestPlayerToCrosshair()
    local target = nil
    local shortestDistance = silentAimFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortestDistance then
