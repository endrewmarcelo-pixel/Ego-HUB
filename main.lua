local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- VARIÁVEIS DE CONTROLE INTERNAS
-- ==========================================
local espEnabled = false
local noclipEnabled = false
local espNamesEnabled = false
local maxDistance = 1000

local BONE_COLOR = Color3.fromRGB(255, 255, 255)
local BONE_THICKNESS = 3

local BONE_STRUCTURE = {
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- ==========================================
-- ESTRUTURA VISUAL DO MENU (UI)
-- ==========================================
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESP_System_V3")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_System_V3"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

local LinesContainer = Instance.new("Folder")
LinesContainer.Name = "LinesContainer"
LinesContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.30, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 12)
TopLineCorner.Parent = TopLine

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
})
UIGradient.Parent = TopLine

local HeaderIcon = Instance.new("ImageLabel")
HeaderIcon.Size = UDim2.new(0, 20, 0, 20)
HeaderIcon.Position = UDim2.new(0, 15, 0, 15)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Image = "rbxassetid://10734951437"
HeaderIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
HeaderIcon.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 20)
Title.Position = UDim2.new(0, 42, 0, 15)
Title.Text = "HACK MENU MULTIFUNÇÕES"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local function createMenuButton(yPos, text, iconId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
    btn.Text = "    " .. text
    btn.TextColor3 = Color3.fromRGB(230, 75, 75)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(230, 75, 75)
    stroke.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(1, -32, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(230, 75, 75)
    icon.Parent = btn

    return btn, stroke, icon
end

local ToggleESP, StrokeESP, IconESP = createMenuButton(50, "SKELETON ESP", "rbxassetid://10734950309")
local ToggleNames, StrokeNames, IconNames = createMenuButton(95, "ESP NAMES", "rbxassetid://10723350179")
local ToggleNoclip, StrokeNoclip, IconNoclip = createMenuButton(140, "NOCLIP (ATRAVESSAR)", "rbxassetid://10734947470")

local DistanceFrame = Instance.new("Frame")
DistanceFrame.Size = UDim2.new(1, -30, 0, 38)
DistanceFrame.Position = UDim2.new(0, 15, 0, 220)
DistanceFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
DistanceFrame.BorderSizePixel = 0
DistanceFrame.Parent = MainFrame

local DistCorner = Instance.new("UICorner")
DistCorner.CornerRadius = UDim.new(0, 8)
DistCorner.Parent = DistanceFrame

local DistIcon = Instance.new("ImageLabel")
DistIcon.Size = UDim2.new(0, 18, 0, 18)
DistIcon.Position = UDim2.new(0, 12, 0.5, -9)
DistIcon.BackgroundTransparency = 1
DistIcon.Image = "rbxassetid://10723346959"
DistIcon.ImageColor3 = Color3.fromRGB(150, 150, 160)
DistIcon.Parent = DistanceFrame

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 80, 1, 0)
DistLabel.Position = UDim2.new(0, 38, 0, 0)
DistLabel.Text = "Alcance:"
DistLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
DistLabel.BackgroundTransparency = 1
DistLabel.Font = Enum.Font.GothamMedium
DistLabel.TextSize = 12
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistanceFrame

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(1, -130, 1, -12)
DistanceInput.Position = UDim2.new(0, 115, 0, 6)
DistanceInput.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
DistanceInput.Text = tostring(maxDistance)
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.GothamBold
DistanceInput.TextSize = 13
DistanceInput.ClearTextOnFocus = false
DistanceInput.Parent = DistanceFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DistanceInput

-- ==========================================
-- LÓGICA DE INTERAÇÃO DOS BOTÕES
-- ==========================================
local function applyActiveStyle(btn, stroke, icon, text)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
    btn.TextColor3 = Color3.fromRGB(75, 230, 130)
    btn.Text = "    " .. text .. ": ATIVADO"
    stroke.Color = Color3.fromRGB(75, 230, 130)
    icon.ImageColor3 = Color3.fromRGB(75, 230, 130)
end

local function applyInactiveStyle(btn, stroke, icon, text)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
    btn.TextColor3 = Color3.fromRGB(230, 75, 75)
    btn.Text = "    " .. text .. ": DESATIVADO"
    stroke.Color = Color3.fromRGB(230, 75, 75)
    icon.ImageColor3 = Color3.fromRGB(230, 75, 75)
end

ToggleESP.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then applyActiveStyle(ToggleESP, StrokeESP, IconESP, "SKELETON ESP") else applyInactiveStyle(ToggleESP, StrokeESP, IconESP, "SKELETON ESP") LinesContainer:ClearAllChildren() end
end)

ToggleNames.MouseButton1Click:Connect(function()
    espNamesEnabled = not espNamesEnabled
    if espNamesEnabled then applyActiveStyle(ToggleNames, StrokeNames, IconNames, "ESP NAMES") else applyInactiveStyle(ToggleNames, StrokeNames, IconNames, "ESP NAMES") LinesContainer:ClearAllChildren() end
end)

ToggleNoclip.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then applyActiveStyle(ToggleNoclip, StrokeNoclip, IconNoclip, "NOCLIP") else applyInactiveStyle(ToggleNoclip, StrokeNoclip, IconNoclip, "NOCLIP") end
end)

DistanceInput.FocusLost:Connect(function()
    local numericValue = tonumber(DistanceInput.Text)
    if numericValue then maxDistance = math.clamp(numericValue, 10, 5000) end
    DistanceInput.Text = tostring(maxDistance)
end)

-- Sistema Flutuante / Arrastável
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- RENDERIZADORES
-- ==========================================
local function drawLineBetweenPoints(id, p1, p2)
    local lineFrame = LinesContainer:FindFirstChild(id)
    if not lineFrame then
        lineFrame = Instance.new("Frame")
        lineFrame.Name = id
        lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        lineFrame.BackgroundColor3 = BONE_COLOR
        lineFrame.BorderSizePixel = 0
        lineFrame.Parent = LinesContainer
    end
    local diff = p2 - p1
    lineFrame.Size = UDim2.fromOffset(diff.Magnitude, BONE_THICKNESS)
    lineFrame.Position = UDim2.fromOffset((p1 + p2).X / 2, (p1 + p2).Y / 2)
    lineFrame.Rotation = math.atan2(diff.Y, diff.X) * (180 / math.pi)
end

local function drawPlayerName(id, position, text)
    local nameLabel = LinesContainer:FindFirstChild(id)
    if not nameLabel then
        nameLabel = Instance.new("TextLabel")
