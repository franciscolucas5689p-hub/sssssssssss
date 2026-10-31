-- ORELHA HUB
-- Roblox Studio | LocalScript
-- Recursos de teste para jogadores no seu proprio jogo.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("ORELHA_HUB")
if old then old:Destroy() end

local settings = {
    ESP = false,
    Aim = false,
    NPCAim = false,
    FOV = 150,
    TeamCheck = true
}

local gui = Instance.new("ScreenGui")
gui.Name = "ORELHA_HUB"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true -- usa coordenadas da tela para acompanhar o mouse
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(245, 310)
panel.Position = UDim2.new(0.05, 0, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 21, 33)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(112, 58, 190)
title.BorderSizePixel = 0
title.Text = "ORELHA HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.Parent = panel
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Arrastar o painel pela barra de titulo
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function makeButton(label, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.86, 0, 0, 36)
    b.Position = UDim2.new(0.07, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 48, 88)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = label
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(callback)
    return b
end

local espButton, aimButton, npcAimButton, fovButton

espButton = makeButton("ESP JOGADORES: OFF", 55, function()
    settings.ESP = not settings.ESP
    espButton.Text = "ESP JOGADORES: " .. (settings.ESP and "ON" or "OFF")
end)

aimButton = makeButton("MIRA ASSISTIDA: OFF", 99, function()
    settings.Aim = not settings.Aim
    aimButton.Text = "MIRA ASSISTIDA: " .. (settings.Aim and "ON" or "OFF")
end)

npcAimButton = makeButton("GRUDAR EM NPCs: OFF", 143, function()
    settings.NPCAim = not settings.NPCAim
    npcAimButton.Text = "GRUDAR EM NPCs: " .. (settings.NPCAim and "ON" or "OFF")
end)

fovButton = makeButton("FOV: 150 (+25)", 187, function()
    settings.FOV += 25
    if settings.FOV > 400 then settings.FOV = 50 end
    fovButton.Text = "FOV: " .. settings.FOV .. " (+25)"
end)

makeButton("FECHAR HUB", 231, function()
    gui:Destroy()
end)

-- Circulo de FOV: apenas indicador visual da area de mira.
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromOffset(0, 0)
circle.Size = UDim2.fromOffset(settings.FOV * 2, settings.FOV * 2)
circle.BackgroundTransparency = 1
circle.Parent = gui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 105, 255)
stroke.Thickness = 2
stroke.Parent = circle

local highlights = {}

local function isValidPlayer(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character then return false end
    if settings.TeamCheck and player.Team ~= nil and targetPlayer.Team == player.Team then
        return false
    end
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and root ~= nil and hum.Health > 0
end

local function updateESP()
    for character, highlight in pairs(highlights) do
        if not character.Parent or not settings.ESP then
            highlight:Destroy()
            highlights[character] = nil
        end
    end

    if not settings.ESP then return end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character and isValidPlayer(targetPlayer) and not highlights[character] then
            local h = Instance.new("Highlight")
            h.Name = "OrelhaHubESP"
            h.FillColor = Color3.fromRGB(165, 85, 255)
            h.OutlineColor = Color3.new(1, 1, 1)
            h.DepthMode = Enum.HighlightDepthMode.Occluded
            h.Parent = character
            highlights[character] = h
        end
    end
end

local cachedNPCs = {}
local function refreshNPCs()
    table.clear(cachedNPCs)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(cachedNPCs, obj)
            end
        end
    end
end

local function updateAim()
    if not settings.Aim and not settings.NPCAim then return end

    local center = UserInputService:GetMouseLocation()
    local bestPart, bestDistance = nil, settings.FOV

    if settings.Aim then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if isValidPlayer(targetPlayer) then
                local character = targetPlayer.Character
                local targetPart = character:FindFirstChild("UpperTorso")
                    or character:FindFirstChild("Torso")
                    or character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, visible = camera:WorldToViewportPoint(targetPart.Position)
                    if visible then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distance < bestDistance then
                            bestDistance, bestPart = distance, targetPart
                        end
                    end
                end
            end
        end
    end

    if settings.NPCAim then
        for _, npc in ipairs(cachedNPCs) do
            if npc.Parent then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local targetPart = npc:FindFirstChild("UpperTorso")
                    or npc:FindFirstChild("Torso")
                    or npc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and targetPart then
                    local screenPos, visible = camera:WorldToViewportPoint(targetPart.Position)
                    if visible then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distance < bestDistance then
                            bestDistance, bestPart = distance, targetPart
                        end
                    end
                end
            end
        end
    end

    -- Suaviza a mira no alvo mais proximo do cursor dentro do FOV.
    if bestPart then
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, bestPart.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.12)
    end
end

local accumulator = 0
local connection
connection = RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then
        connection:Disconnect()
        return
    end

    local mousePosition = UserInputService:GetMouseLocation()
    circle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
    circle.Size = UDim2.fromOffset(settings.FOV * 2, settings.FOV * 2)
    circle.Visible = settings.Aim or settings.NPCAim
    accumulator += dt

    if accumulator >= 0.25 then
        accumulator = 0
        updateESP()
        if settings.NPCAim then refreshNPCs() end
    end

    updateAim()
end)

print("ORELHA HUB carregado!")
