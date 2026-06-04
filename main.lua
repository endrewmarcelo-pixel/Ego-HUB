local Players = game:GetService("Players")
local RunService = game.RunService or game:FindService("RunService") -- CORREÇÃO ABSOLUTA DA LINHA 2
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = true -- Mude para 'false' se quiser que comece desligado

-- Executa a cada atualização de física do cenário de forma super estável
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    
    local character = LocalPlayer.Character
    if character then
        -- Desativa a colisão das partes para permitir atravessar paredes
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                -- Mantém apenas a base do pé/quadril ativa para você não cair no vácuo do mapa
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end
end)
