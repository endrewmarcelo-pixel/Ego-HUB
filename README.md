local item = workspace:WaitForChild("workspace.Characters")

local highlight = Instance.new("Highlight")
highlight.Parent = item
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Verde
highlight.FillTransparency = 0.5
