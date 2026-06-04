local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = true -- Altere para 'false' se quiser começar desligado

-- Loop de renderização que roda a cada frame físico do jogo
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    
    local character = LocalPlayer.Character
    if character then
        -- Varre todas as partes do seu personagem
        for _, part in ipairs(character:GetDescendants()) do
            -- Desativa a colisão apenas de partes físicas (braços, pernas, torso, roupas)
            if part:IsA("BasePart") and part.CanCollide then
                -- Mantém a checagem para não atravessar o chão puro se estiver andando normal
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end
end)
