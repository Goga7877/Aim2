--[[
    DEV AIM / ESP / FULLBRIGHT
    Roblox Luau
    Для собственной игры / тестирования

    Установка:
    LocalScript -> StarterPlayer > StarterPlayerScripts

    Возможности:
    • Красивый тёмный UI
    • Круглая кнопка открытия
    • Combat
    • Visuals
    • Misc
    • Config
    • Aim Assist
    • FOV Circle
    • ESP Box / Name / Health / Tracer
    • FullBright
    • Fog
    • Config Save / Load
    • Автозагрузка последнего конфига при наличии writefile
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--//==================================================
--// CONFIG
--//==================================================

local Config = {
    SilentAim = false,
    VisibilityCheck = true,
    DistanceCheck = true,

    Distance = 500,
    FOV = 120,
    HitChance = 100,

    FOVCircle = true,
    FOVFilled = false,
    FOVNumSides = 64,
    FOVThickness = 2,

    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPTracer = false,
    ESPColor = Color3.fromRGB(0, 170, 255),

    FullBright = false,
    Brightness = 2,
    ClockTime = 14,
    Fog = true,

    ConfigName = "default"
}

local DefaultConfig = {}

for k, v in pairs(Config) do
    DefaultConfig[k] = v
end

--//==================================================
--// FILE CONFIG SYSTEM
--//==================================================

local CONFIG_FOLDER = "DevAimConfigs"
local LAST_CONFIG_FILE = CONFIG_FOLDER .. "/last.txt"

local function canUseFiles()
    return typeof(writefile) == "function"
       and typeof(readfile) == "function"
       and typeof(isfile) == "function"
       and typeof(makefolder) == "function"
end

local function serializeValue(value)
    if typeof(value) == "Color3" then
        return {
            __type = "Color3",
            R = value.R,
            G = value.G,
            B = value.B
        }
    end

    return value
end

local function deserializeValue(value)
    if type(value) == "table" and value.__type == "Color3" then
        return Color3.new(value.R, value.G, value.B)
    end

    return value
end

local function encodeConfig()
    local data = {}

    for key, value in pairs(Config) do
        data[key] = serializeValue(value)
    end

    return game:GetService("HttpService"):JSONEncode(data)
end

local function decodeConfig(text)
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(text)
    end)

    if not ok or type(data) ~= "table" then
        return false
    end

    for key, value in pairs(data) do
        if Config[key] ~= nil then
            Config[key] = deserializeValue(value)
        end
    end

    return true
end

local function saveConfig(name)
    if not canUseFiles() then
        return false, "writefile недоступен"
    end

    pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
    end)

    local file = CONFIG_FOLDER .. "/" .. name .. ".json"

    local ok, err = pcall(function()
        writefile(file, encodeConfig())
        writefile(LAST_CONFIG_FILE, name)
    end)

    return ok, err
end

local function loadConfig(name)
    if not canUseFiles() then
        return false
    end

    local file = CONFIG_FOLDER .. "/" .. name .. ".json"

    if not isfile(file) then
        return false
    end

    local ok, text = pcall(readfile, file)

    if not ok then
        return false
    end

    return decodeConfig(text)
end

--//==================================================
--// LOAD LAST CONFIG
--//==================================================

if canUseFiles() then
    pcall(function()
        if isfile(LAST_CONFIG_FILE) then
            local last = readfile(LAST_CONFIG_FILE)

            if last and last ~= "" then
                Config.ConfigName = last
                loadConfig(last)
            end
        end
    end)
end

--//==================================================
--// GUI
--//==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DevAimInterface"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// Main
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 760, 0, 500)
Main.Position = UDim2.new(0.5, -380, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(13, 15, 18)
Main.BackgroundTransparency = 0.04
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 50, 58)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

--//==================================================
--// TOP BAR
--//==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 70)
Top.BackgroundTransparency = 1
Top.Parent = Main

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 45, 0, 45)
Avatar.Position = UDim2.new(0, 15, 0, 12)
Avatar.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
Avatar.Parent = Top

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

pcall(function()
    Avatar.Image = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size100x100
    )
end)

local Nick = Instance.new("TextLabel")
Nick.Size = UDim2.new(0, 250, 0, 25)
Nick.Position = UDim2.new(0, 70, 0, 12)
Nick.BackgroundTransparency = 1
Nick.Text = LocalPlayer.DisplayName
Nick.TextColor3 = Color3.fromRGB(240, 240, 240)
Nick.Font = Enum.Font.GothamBold
Nick.TextSize = 15
Nick.TextXAlignment = Enum.TextXAlignment.Left
Nick.Parent = Top

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 250, 0, 20)
Status.Position = UDim2.new(0, 70, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "●  Developer"
Status.TextColor3 = Color3.fromRGB(0, 190, 255)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 40)
Title.Position = UDim2.new(0, 300, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "DEV AIM"
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -52, 0, 15)
Close.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 25
Close.AutoButtonColor = false
Close.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

--//==================================================
--// SIDEBAR
--//==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 205, 1, -70)
Sidebar.Position = UDim2.new(0, 0, 0, 70)
Sidebar.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
Sidebar.BackgroundTransparency = 0.1
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -220, 1, -85)
Content.Position = UDim2.new(0, 215, 0, 75)
Content.BackgroundTransparency = 1
Content.Parent = Main

local CurrentCategory = "Combat"

local CategoryButtons = {}

local Categories = {
    {"⚔", "Combat"},
    {"◎", "Visuals"},
    {"☀", "Misc"},
    {"⚙", "Config"}
}

local function createCategory(icon, name, index)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 48)
    Button.Position = UDim2.new(0, 10, 0, 15 + ((index - 1) * 55))
    Button.BackgroundColor3 = Color3.fromRGB(24, 28, 34)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Sidebar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.TextColor3 = Color3.fromRGB(70, 180, 240)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 20
    Icon.Parent = Button

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -45, 1, 0)
    Text.Position = UDim2.new(0, 45, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = name
    Text.TextColor3 = Color3.fromRGB(190, 195, 205)
    Text.Font = Enum.Font.GothamMedium
    Text.TextSize = 13
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Button

    Button.MouseButton1Click:Connect(function()
        CurrentCategory = name

        for _, data in pairs(CategoryButtons) do
            data.Button.BackgroundTransparency = 1
            data.Text.TextColor3 = Color3.fromRGB(190, 195, 205)
        end

        Button.BackgroundTransparency = 0
        Button.BackgroundColor3 = Color3.fromRGB(28, 60, 75)
        Text.TextColor3 = Color3.fromRGB(255, 255, 255)

        updateContent()
    end)

    CategoryButtons[name] = {
        Button = Button,
        Text = Text
    }

    return Button
end

for i, data in ipairs(Categories) do
    createCategory(data[1], data[2], i)
end

CategoryButtons.Combat.Button.BackgroundTransparency = 0
CategoryButtons.Combat.Button.BackgroundColor3 = Color3.fromRGB(28, 60, 75)
CategoryButtons.Combat.Text.TextColor3 = Color3.fromRGB(255, 255, 255)

--//==================================================
--// UI HELPERS
--//==================================================

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        child:Destroy()
    end
end

local function createPanel(title, x, y, width, height)
    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, width, 0, height)
    Panel.Position = UDim2.new(0, x, 0, y)
    Panel.BackgroundColor3 = Color3.fromRGB(18, 21, 25)
    Panel.BackgroundTransparency = 0.05
    Panel.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Panel

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 44, 50)
    Stroke.Transparency = 0.5
    Stroke.Parent = Panel

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 40)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(245, 245, 245)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Panel

    return Panel
end

local function createToggle(parent, text, y, getter, setter)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -30, 0, 38)
    Button.Position = UDim2.new(0, 15, 0, y)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(205, 208, 215)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Position = UDim2.new(1, -38, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(45, 48, 54)
    Switch.Parent = Button

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(150, 155, 160)
    Circle.Parent = Switch

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local function refresh()
        local state = getter()

        TweenService:Create(
            Switch,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = state
                    and Color3.fromRGB(0, 150, 210)
                    or Color3.fromRGB(45, 48, 54)
            }
        ):Play()

        TweenService:Create(
            Circle,
            TweenInfo.new(0.15),
            {
                Position = state
                    and UDim2.new(1, -17, 0.5, -7)
                    or UDim2.new(0, 3, 0.5, -7)
            }
        ):Play()
    end

    Button.MouseButton1Click:Connect(function()
        setter(not getter())
        refresh()
    end)

    refresh()

    return Button
end

local function createSlider(parent, text, y, min, max, getter, setter)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -30, 0, 58)
    Container.Position = UDim2.new(0, 15, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(205, 208, 215)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.new(0.4, 0, 0, 20)
    Value.Position = UDim2.new(0.6, 0, 0, 0)
    Value.BackgroundTransparency = 1
    Value.TextColor3 = Color3.fromRGB(120, 195, 240)
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 12
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Container

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 5)
    Bar.Position = UDim2.new(0, 0, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 48, 55)
    Bar.Parent = Container

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Dragging = false

    local function refresh()
        local current = math.clamp(getter(), min, max)
        local alpha = (current - min) / (max - min)

        Label.Text = text
        Value.Text = tostring(math.floor(current))

        Fill.Size = UDim2.new(alpha, 0, 1, 0)
    end

    local function setFromX(x)
        local alpha = math.clamp(
            (x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0,
            1
        )

        local value = min + ((max - min) * alpha)

        setter(value)
        refresh()
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                setFromX(input.Position.X)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    refresh()

    return Container
end

local function createButton(parent, text, y, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -30, 0, 42)
    Button.Position = UDim2.new(0, 15, 0, y)
    Button.BackgroundColor3 = Color3.fromRGB(25, 50, 63)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(230, 240, 245)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(
            Button,
            TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(30, 75, 95)}
        ):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(
            Button,
            TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(25, 50, 63)}
        ):Play()
    end)

    Button.MouseButton1Click:Connect(callback)

    return Button
end

--//==================================================
--// CONTENT
--//==================================================

function updateContent()
    clearContent()

    --// COMBAT
    if CurrentCategory == "Combat" then

        local Aim = createPanel(
            "Silent Aim / Aim Assist",
            0, 0, 265, 385
        )

        createToggle(
            Aim,
            "Enable Silent Aim",
            48,
            function() return Config.SilentAim end,
            function(v) Config.SilentAim = v end
        )

        createToggle(
            Aim,
            "Visibility Check",
            90,
            function() return Config.VisibilityCheck end,
            function(v) Config.VisibilityCheck = v end
        )

        createToggle(
            Aim,
            "Distance Check",
            132,
            function() return Config.DistanceCheck end,
            function(v) Config.DistanceCheck = v end
        )

        createSlider(
            Aim,
            "Distance",
            175,
            50,
            2000,
            function() return Config.Distance end,
            function(v) Config.Distance = v end
        )

        createSlider(
            Aim,
            "FOV",
            230,
            20,
            500,
            function() return Config.FOV end,
            function(v) Config.FOV = v end
        )

        createSlider(
            Aim,
            "Hit Chance",
            285,
            0,
            100,
            function() return Config.HitChance end,
            function(v) Config.HitChance = v end
        )

        local FOV = createPanel(
            "FOV Circle",
            280, 0, 265, 385
        )

        createToggle(
            FOV,
            "Enable",
            48,
            function() return Config.FOVCircle end,
            function(v) Config.FOVCircle = v end
        )

        createToggle(
            FOV,
            "Filled",
            90,
            function() return Config.FOVFilled end,
            function(v) Config.FOVFilled = v end
        )

        createSlider(
            FOV,
            "NumSides",
            135,
            16,
            128,
            function() return Config.FOVNumSides end,
            function(v) Config.FOVNumSides = v end
        )

        createSlider(
            FOV,
            "Thickness",
            190,
            1,
            8,
            function() return Config.FOVThickness end,
            function(v) Config.FOVThickness = v end
        )

    --// VISUALS
    elseif CurrentCategory == "Visuals" then

        local ESP = createPanel(
            "ESP",
            0, 0, 545, 385
        )

        createToggle(
            ESP,
            "Box",
            50,
            function() return Config.ESPBox end,
            function(v) Config.ESPBox = v end
        )

        createToggle(
            ESP,
            "Name",
            95,
            function() return Config.ESPName end,
            function(v) Config.ESPName = v end
        )

        createToggle(
            ESP,
            "Health",
            140,
            function() return Config.ESPHealth end,
            function(v) Config.ESPHealth = v end
        )

        createToggle(
            ESP,
            "Tracer",
            185,
            function() return Config.ESPTracer end,
            function(v) Config.ESPTracer = v end
        )

        local ColorInfo = Instance.new("TextLabel")
        ColorInfo.Size = UDim2.new(1, -30, 0, 30)
        ColorInfo.Position = UDim2.new(0, 15, 0, 240)
        ColorInfo.BackgroundTransparency = 1
        ColorInfo.Text = "ESP Color"
        ColorInfo.TextColor3 = Color3.fromRGB(205, 208, 215)
        ColorInfo.Font = Enum.Font.Gotham
        ColorInfo.TextSize = 12
        ColorInfo.TextXAlignment = Enum.TextXAlignment.Left
        ColorInfo.Parent = ESP

        local ColorPreview = Instance.new("Frame")
        ColorPreview.Size = UDim2.new(0, 45, 0, 25)
        ColorPreview.Position = UDim2.new(1, -60, 0, 240)
        ColorPreview.BackgroundColor3 = Config.ESPColor
        ColorPreview.Parent = ESP

        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 7)
        ColorCorner.Parent = ColorPreview

        local ColorButton = Instance.new("TextButton")
        ColorButton.Size = UDim2.new(1, -30, 0, 42)
        ColorButton.Position = UDim2.new(0, 15, 0, 285)
        ColorButton.BackgroundColor3 = Color3.fromRGB(25, 50, 63)
        ColorButton.Text = "Change Color"
        ColorButton.TextColor3 = Color3.fromRGB(230, 240, 245)
        ColorButton.Font = Enum.Font.GothamBold
        ColorButton.TextSize = 12
        ColorButton.AutoButtonColor = false
        ColorButton.Parent = ESP

        local ColorButtonCorner = Instance.new("UICorner")
        ColorButtonCorner.CornerRadius = UDim.new(0, 9)
        ColorButtonCorner.Parent = ColorButton

        local colors = {
            Color3.fromRGB(0, 170, 255),
            Color3.fromRGB(0, 255, 120),
            Color3.fromRGB(255, 80, 80),
            Color3.fromRGB(255, 190, 0),
            Color3.fromRGB(200, 100, 255)
        }

        local colorIndex = 1

        ColorButton.MouseButton1Click:Connect(function()
            colorIndex += 1

            if colorIndex > #colors then
                colorIndex = 1
            end

            Config.ESPColor = colors[colorIndex]
            ColorPreview.BackgroundColor3 = Config.ESPColor
        end)

    --// MISC
    elseif CurrentCategory == "Misc" then

        local Bright = createPanel(
            "FullBright",
            0, 0, 545, 385
        )

        createToggle(
            Bright,
            "Enable FullBright",
            50,
            function() return Config.FullBright end,
            function(v) Config.FullBright = v end
        )

        createSlider(
            Bright,
            "Brightness",
            105,
            0,
            10,
            function() return Config.Brightness end,
            function(v) Config.Brightness = v end
        )

        createSlider(
            Bright,
            "ClockTime",
            170,
            0,
            24,
            function() return Config.ClockTime end,
            function(v) Config.ClockTime = v end
        )

        createToggle(
            Bright,
            "Fog",
            235,
            function() return Config.Fog end,
            function(v) Config.Fog = v end
        )

    --// CONFIG
    elseif CurrentCategory == "Config" then

        local ConfigPanel = createPanel(
            "Config System",
            0, 0, 545, 385
        )

        local NameBox = Instance.new("TextBox")
        NameBox.Size = UDim2.new(1, -30, 0, 42)
        NameBox.Position = UDim2.new(0, 15, 0, 55)
        NameBox.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
        NameBox.PlaceholderText = "Config name..."
        NameBox.Text = Config.ConfigName
        NameBox.TextColor3 = Color3.fromRGB(235, 235, 235)
        NameBox.PlaceholderColor3 = Color3.fromRGB(100, 105, 110)
        NameBox.Font = Enum.Font.Gotham
        NameBox.TextSize = 12
        NameBox.ClearTextOnFocus = false
        NameBox.Parent = ConfigPanel

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 8)
        BoxCorner.Parent = NameBox

        local BoxStroke = Instance.new("UIStroke")
        BoxStroke.Color = Color3.fromRGB(45, 50, 58)
        BoxStroke.Transparency = 0.4
        BoxStroke.Parent = NameBox

        createButton(
            ConfigPanel,
            "Save Config",
            115,
            function()
                local name = NameBox.Text

                if name == "" then
                    name = "default"
                end

                Config.ConfigName = name

                local success = saveConfig(name)

                if success then
                    NameBox.Text = name
                end
            end
        )

        createButton(
            ConfigPanel,
            "Load Config",
            165,
            function()
                local name = NameBox.Text

                if name == "" then
                    name = "default"
                end

                Config.ConfigName = name

                if loadConfig(name) then
                    updateContent()
                end
            end
        )

        createButton(
            ConfigPanel,
            "Reset Config",
            215,
            function()

                for key, value in pairs(DefaultConfig) do
                    Config[key] = value
                end

                updateContent()
            end
        )

        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.new(1, -30, 0, 70)
        Info.Position = UDim2.new(0, 15, 0, 275)
        Info.BackgroundTransparency = 1
        Info.TextWrapped = true

        if canUseFiles() then
            Info.Text =
                "File Config System: READY\n\n" ..
                "Последний использованный конфиг\n" ..
                "загружается автоматически."
        else
            Info.Text =
                "File Config System: UNAVAILABLE\n\n" ..
                "writefile/readfile недоступны\n" ..
                "в обычном Roblox LocalScript."
        end

        Info.TextColor3 = Color3.fromRGB(135, 140, 148)
        Info.Font = Enum.Font.Gotham
        Info.TextSize = 11
        Info.TextXAlignment = Enum.TextXAlignment.Left
        Info.TextYAlignment = Enum.TextYAlignment.Top
        Info.Parent = ConfigPanel
    end
end

--//==================================================
--// OPEN BUTTON
--//==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 54, 0, 54)
OpenButton.Position = UDim2.new(0, 20, 1, -75)
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
OpenButton.Text = "≡"
OpenButton.TextColor3 = Color3.fromRGB(0, 180, 240)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 25
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 150, 210)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

--//==================================================
--// OPEN / CLOSE ANIMATION
--//==================================================

local MenuOpen = false

local function openMenu()
    if MenuOpen then
        return
    end

    MenuOpen = true
    Main.Visible = true

    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundTransparency = 1

    TweenService:Create(
        Main,
        TweenInfo.new(
            0.25,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(0, 760, 0, 500),
            Position = UDim2.new(0.5, -380, 0.5, -250),
            BackgroundTransparency = 0.04
        }
    ):Play()
end

local function closeMenu()
    if not MenuOpen then
        return
    end

    MenuOpen = false

    local tween = TweenService:Create(
        Main,
        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        ),
        {
            Size = UDim2.new(0, 700, 0, 450),
            Position = UDim2.new(0.5, -350, 0.5, -225),
            BackgroundTransparency = 1
        }
    )

    tween:Play()

    tween.Completed:Once(function()
        if not MenuOpen then
            Main.Visible = false
        end
    end)
end

local function toggleMenu()
    if MenuOpen then
        closeMenu()
    else
        openMenu()
    end
end

OpenButton.MouseButton1Click:Connect(toggleMenu)

Close.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Insert
    or input.KeyCode == Enum.KeyCode.RightShift then

        toggleMenu()
    end

    if input.KeyCode == Enum.KeyCode.X and MenuOpen then
        closeMenu()
    end
end)

--//==================================================
--// FOV CIRCLE
--//==================================================

local FOVGui = Instance.new("Frame")
FOVGui.Name = "FOVCircle"
FOVGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGui.BackgroundTransparency = 1
FOVGui.BorderSizePixel = 0
FOVGui.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(0, 170, 255)
FOVStroke.Thickness = Config.FOVThickness
FOVStroke.Transparency = 0.1
FOVStroke.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVGui

--//==================================================
--// AIM TARGET
--//==================================================

local function getCharacter(player)

    local character = player.Character

    if not character then
        return nil
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    local head =
        character:FindFirstChild("Head")

    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    if not root or not head then
        return nil
    end

    return character, humanoid, root, head
end

local function visibleTarget(character, targetPart)

    if not Config.VisibilityCheck then
        return true
    end

    local origin =
        Camera.CFrame.Position

    local direction =
        targetPart.Position - origin

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        character
    }

    local result =
        workspace:Raycast(
            origin,
            direction,
            params
        )

    return result == nil
end

local function getBestTarget()

    local bestPlayer = nil
    local bestPart = nil
    local bestScreenDistance = math.huge

    local viewport =
        Camera.ViewportSize

    local center =
        Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local character,
                humanoid,
                root,
                head =
                getCharacter(player)

            if character then

                local screenPosition,
                    onScreen =
                    Camera:WorldToViewportPoint(
                        head.Position
                    )

                if onScreen then

                    local screenDistance =
                        (
                            Vector2.new(
                                screenPosition.X,
                                screenPosition.Y
                            ) - center
                        ).Magnitude

                    if screenDistance <= Config.FOV then

                        local worldDistance =
                            (
                                root.Position -
                                Camera.CFrame.Position
                            ).Magnitude

                        local distanceOK =
                            not Config.DistanceCheck
                            or worldDistance <= Config.Distance

                        if distanceOK
                        and visibleTarget(character, head)
                        and screenDistance < bestScreenDistance then

                            bestScreenDistance =
                                screenDistance

                            bestPlayer =
                                player

                            bestPart =
                                head
                        end
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart
end

--//==================================================
--// ESP
--//==================================================

local ESPCache = {}

local function createESP(player)

    if ESPCache[player] then
        return ESPCache[player]
    end

    local data = {}

    data.box = Instance.new("Frame")
    data.box.Name = "ESPBox"
    data.box.BackgroundTransparency = 1
    data.box.BorderSizePixel = 1
    data.box.Visible = false
    data.box.Parent = ScreenGui

    data.name = Instance.new("TextLabel")
    data.name.Name = "ESPName"
    data.name.BackgroundTransparency = 1
    data.name.TextColor3 = Config.ESPColor
    data.name.Font = Enum.Font.GothamBold
    data.name.TextSize = 11
    data.name.Visible = false
    data.name.Parent = ScreenGui

    data.health = Instance.new("TextLabel")
    data.health.Name = "ESPHealth"
    data.health.BackgroundTransparency = 1
    data.health.TextColor3 = Color3.fromRGB(80, 255, 100)
    data.health.Font = Enum.Font.GothamBold
    data.health.TextSize = 10
    data.health.Visible = false
    data.health.Parent = ScreenGui

    data.tracer = Instance.new("Frame")
    data.tracer.Name = "ESPTracer"
    data.tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    data.tracer.BorderSizePixel = 0
    data.tracer.BackgroundColor3 = Config.ESPColor
    data.tracer.Visible = false
    data.tracer.Parent = ScreenGui

    ESPCache[player] = data

    return data
end

local function hideESP(data)

    data.box.Visible = false
    data.name.Visible = false
    data.health.Visible = false
    data.tracer.Visible = false
end

local function updateESP(player)

    local data =
        createESP(player)

    if player == LocalPlayer then
        hideESP(data)
        return
    end

    local character,
        humanoid,
        root,
        head =
        getCharacter(player)

    if not character then
        hideESP(data)
        return
    end

    local rootPos,
        rootVisible =
        Camera:WorldToViewportPoint(
            root.Position
        )

    local headPos,
        headVisible =
        Camera:WorldToViewportPoint(
            head.Position
        )

    if not rootVisible or not headVisible then
        hideESP(data)
        return
    end

    local distance =
        (
            Camera.CFrame.Position -
            root.Position
        ).Magnitude

    if distance > Config.Distance then
        hideESP(data)
        return
    end

    local height =
        math.clamp(
            2500 / math.max(distance, 1),
            25,
            180
        )

    local width =
        height * 0.55

    local x =
        rootPos.X - width / 2

    local y =
        headPos.Y - height * 0.15

    if Config.ESPBox then

        data.box.Visible = true

        data.box.Position =
            UDim2.fromOffset(
                x,
                y
            )

        data.box.Size =
            UDim2.fromOffset(
                width,
                height
            )

        data.box.BorderColor3 =
            Config.ESPColor

    else
        data.box.Visible = false
    end

    if Config.ESPName then

        data.name.Visible = true

        data.name.Text =
            player.DisplayName

        data.name.Position =
            UDim2.fromOffset(
                headPos.X - 75,
                y - 20
            )

        data.name.Size =
            UDim2.fromOffset(
                150,
                18
            )

        data.name.TextColor3 =
            Config.ESPColor

    else
        data.name.Visible = false
    end

    if Config.ESPHealth then

        data.health.Visible = true

        local hp =
            math.floor(
                humanoid.Health
            )

        local maxHp =
            math.floor(
                humanoid.MaxHealth
            )

        data.health.Text =
            "HP " ..
            hp ..
            "/" ..
            maxHp

        data.health.Position =
            UDim2.fromOffset(
                headPos.X - 45,
                y + height + 2
            )

        data.health.Size =
            UDim2.fromOffset(
                90,
                18
            )

    else
        data.health.Visible = false
    end

    if Config.ESPTracer then

        local screenSize =
            Camera.ViewportSize

        local start =
            Vector2.new(
                screenSize.X / 2,
                screenSize.Y
            )

        local finish =
            Vector2.new(
                rootPos.X,
                rootPos.Y
            )

        local difference =
            finish - start

        data.tracer.Visible = true

        data.tracer.Position =
            UDim2.fromOffset(
                (start.X + finish.X) / 2,
                (start.Y + finish.Y) / 2
            )

        data.tracer.Size =
            UDim2.fromOffset(
                difference.Magnitude,
                1
            )

        data.tracer.Rotation =
            math.deg(
                math.atan2(
                    difference.Y,
                    difference.X
                )
            )

        data.tracer.BackgroundColor3 =
            Config.ESPColor

    else
        data.tracer.Visible = false
    end
end

Players.PlayerRemoving:Connect(function(player)

    local data =
        ESPCache[player]

    if data then

        for _, object in pairs(data) do

            pcall(function()
                object:Destroy()
            end)

        end
    end

    ESPCache[player] = nil
end)

--//==================================================
--// FULLBRIGHT
--//==================================================

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local function updateLighting()

    if Config.FullBright then

        Lighting.Brightness =
            Config.Brightness

        Lighting.ClockTime =
            Config.ClockTime

        Lighting.GlobalShadows =
            false

        if Config.Fog then
            Lighting.FogEnd = 100000
        end

    else

        Lighting.Brightness =
            OriginalLighting.Brightness

        Lighting.ClockTime =
            OriginalLighting.ClockTime

        Lighting.GlobalShadows =
            OriginalLighting.GlobalShadows

        if Config.Fog then
            Lighting.FogEnd =
                OriginalLighting.FogEnd
        end
    end
end

--//==================================================
--// RENDER LOOP
--//==================================================

local LightingTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)

    -- FOV
    local viewport =
        Camera.ViewportSize

    FOVGui.Position =
        UDim2.fromOffset(
            viewport.X / 2,
            viewport.Y / 2
        )

    FOVGui.Size =
        UDim2.fromOffset(
            Config.FOV * 2,
            Config.FOV * 2
        )

    FOVGui.Visible =
        Config.FOVCircle

    FOVStroke.Thickness =
        math.clamp(
            Config.FOVThickness,
            1,
            8
        )

    -- AIM ASSIST
    if Config.SilentAim then

        local chance =
            math.random(1, 100)

        if chance <= Config.HitChance then

            local target,
                targetPart =
                getBestTarget()

            if target and targetPart then

                local cameraPosition =
                    Camera.CFrame.Position

                local desired =
                    CFrame.lookAt(
                        cameraPosition,
                        targetPart.Position
                    )

                Camera.CFrame =
                    Camera.CFrame:Lerp(
                        desired,
                        0.12
                    )
            end
        end
    end

    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then
            updateESP(player)
        end

    end

    -- LIGHTING
    LightingTimer += deltaTime

    if LightingTimer >= 0.1 then

        LightingTimer = 0

        pcall(function()
            updateLighting()
        end)

    end
end)

--//==================================================
--// RESPAWN
--//==================================================

LocalPlayer.CharacterAdded:Connect(function()

    task.wait(1)

    pcall(function()
        Camera =
            workspace.CurrentCamera
    end)

end)

--//==================================================
--// STARTUP
--//==================================================

OpenButton.Visible = true

OpenButton.Size =
    UDim2.new(
        0,
        0,
        0,
        0
    )

TweenService:Create(
    OpenButton,
    TweenInfo.new(
        0.45,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),
    {
        Size = UDim2.new(
            0,
            54,
            0,
            54
        )
    }
):Play()    
