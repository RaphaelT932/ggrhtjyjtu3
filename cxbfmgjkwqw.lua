
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


--============================================================
-- ÍCONE FLUTUANTE - CARTOLA PRETA/DOURADA DO ROBLOX
--============================================================

-- Carregado diretamente pelo Roblox.
-- Usa somente um thumbnail hospedado pelo próprio Roblox.
local CartolaMiniIconImage =
	"rbxthumb://type=Asset&id=96281255959358&w=420&h=420"

-- Estado compartilhado entre proteções e Vehicle Fling.

--============================================================
-- REMOVER HUB ANTERIOR
--============================================================

do
	local Ok,Env=pcall(function()
		if type(getgenv)=="function" then
			return getgenv()
		end
	end)

	if
		Ok
		and
		type(Env)=="table"
		and
		type(Env.CartolaProtectionCleanup)=="function"
	then
		pcall(Env.CartolaProtectionCleanup)
		Env.CartolaProtectionCleanup=nil
	end
end

local OldHub = PlayerGui:FindFirstChild("CartolaHub")

if OldHub then
	OldHub:Destroy()
end

--============================================================
-- REMOTE DO PRESENTE
--============================================================

local Remotes =
	ReplicatedStorage:FindFirstChild("Remotes")

local GiftRemote =
	Remotes
	and
	Remotes:FindFirstChild("InteractGiftRE")

--============================================================
-- TEMA
--============================================================

local Theme = {

	Background = Color3.fromRGB(25,25,27),
	Topbar = Color3.fromRGB(27,27,29),

	Sidebar = Color3.fromRGB(27,27,29),

	SidebarButton =
		Color3.fromRGB(46,46,48),

	SidebarHover =
		Color3.fromRGB(55,55,58),

	SidebarSelected =
		Color3.fromRGB(50,50,53),

	Card =
		Color3.fromRGB(45,45,47),

	CardHover =
		Color3.fromRGB(53,53,56),

	Card2 =
		Color3.fromRGB(70,70,73),

	Text =
		Color3.fromRGB(245,245,245),

	SubText =
		Color3.fromRGB(160,160,165),

	Accent =
		Color3.fromRGB(75,165,255),

	Green =
		Color3.fromRGB(45,155,85),

	Red =
		Color3.fromRGB(195,55,55),

	Stroke =
		Color3.fromRGB(40,40,43)
}

--============================================================
-- HELPERS
--============================================================

local function New(
	ClassName,
	Properties,
	Parent
)

	local Object =
		Instance.new(ClassName)

	for Key, Value in pairs(
		Properties or {}
	) do

		Object[Key] = Value

	end

	Object.Parent = Parent

	return Object
end

local function Corner(
	Object,
	Radius
)

	return New(
		"UICorner",
		{
			CornerRadius =
				UDim.new(
					0,
					Radius or 8
				)
		},
		Object
	)

end

local function Stroke(Object)

	return New(
		"UIStroke",
		{
			Color = Theme.Stroke,
			Thickness = 1,
			Transparency = 0.3
		},
		Object
	)

end

--============================================================
-- SISTEMA DE KEY - SUPABASE RPC
--
-- A publishable key fica no cliente.
-- A validação ocorre em uma Database Function (RPC) SECURITY DEFINER.
-- A tabela permanece fechada para anon/authenticated.
--============================================================

do
	local HttpService =
		game:GetService("HttpService")

	local SupabaseUrl =
		"https://gwhcbtjjsbdqaaxzuidn.supabase.co"

	local SupabasePublishableKey =
		"sb_publishable_ocnr5SM45lWrrjQdhILxMQ_62OCb2xV"

	local ValidateUrl =
		SupabaseUrl
		..
		"/rest/v1/rpc/validate_cartola_key"

	local HttpRequest =
		request
		or
		http_request
		or
		(
			type(syn)=="table"
			and
			syn.request
		)
		or
		(
			type(http)=="table"
			and
			http.request
		)

	local KeyFile =
		"cartolahub_key.txt"

	-- HWID fornecido pelo executor.
	-- Não salvamos HWID em arquivo local.
	local CachedHWID =
		nil

	local KeyValidated =
		false

	local Validating =
		false

	local KeyClosed =
		false

	local KeyGui =
		New(
			"ScreenGui",
			{
				Name = "CartolaKeySystem",
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				ZIndexBehavior =
					Enum.ZIndexBehavior.Sibling,
				DisplayOrder = 2147483647
			},
			PlayerGui
		)

	local Shade =
		New(
			"Frame",
			{
				Size = UDim2.fromScale(1,1),
				BackgroundColor3 = Color3.fromRGB(8,8,10),
				BackgroundTransparency = 0.14,
				BorderSizePixel = 0
			},
			KeyGui
		)

	local Card =
		New(
			"Frame",
			{
				Name = "KeyCard",
				AnchorPoint = Vector2.new(0.5,0.5),
				Position = UDim2.fromScale(0.5,0.5),
				Size = UDim2.fromOffset(470,340),
				BackgroundColor3 = Color3.fromRGB(24,24,27),
				BorderSizePixel = 0,
				ClipsDescendants = true
			},
			Shade
		)

	Corner(Card,16)
	Stroke(Card)


	local CloseKeyButton =
		New(
			"TextButton",
			{
				Name = "CloseKeyButton",
				AnchorPoint = Vector2.new(1,0),
				Position = UDim2.new(1,-16,0,14),
				Size = UDim2.fromOffset(34,34),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Font = Enum.Font.GothamBold,
				Text = "×",
				TextColor3 = Theme.SubText,
				TextSize = 27,
				ZIndex = 6
			},
			Card
		)

	CloseKeyButton.MouseButton1Click:Connect(function()
		KeyClosed = true

		if KeyGui then
			KeyGui:Destroy()
		end
	end)

	-- Cartola sem fundo quadrado.
	New(
		"ImageLabel",
		{
			Position = UDim2.fromOffset(22,18),
			Size = UDim2.fromOffset(56,56),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = CartolaMiniIconImage,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 3
		},
		Card
	)

	New(
		"TextLabel",
		{
			Position = UDim2.fromOffset(92,17),
			Size = UDim2.new(1,-155,0,34),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "Cartola Hub",
			TextColor3 = Theme.Text,
			TextSize = 28,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3
		},
		Card
	)

	New(
		"TextLabel",
		{
			Position = UDim2.fromOffset(92,50),
			Size = UDim2.new(1,-155,0,20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "developed by didinho",
			TextColor3 = Theme.Accent,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3
		},
		Card
	)

	New(
		"Frame",
		{
			Position = UDim2.fromOffset(22,84),
			Size = UDim2.new(1,-44,0,1),
			BackgroundColor3 = Theme.Stroke,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0
		},
		Card
	)

	New(
		"TextLabel",
		{
			Position = UDim2.fromOffset(22,96),
			Size = UDim2.new(1,-44,0,22),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "Insira sua key para liberar o acesso ao script.",
			TextColor3 = Theme.SubText,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		},
		Card
	)

	local KeyBox =
		New(
			"TextBox",
			{
				Position = UDim2.fromOffset(22,128),
				Size = UDim2.new(1,-44,0,48),
				BackgroundColor3 = Color3.fromRGB(37,37,41),
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				PlaceholderText = "CARTOLA-XXXXXXXXXXXX",
				PlaceholderColor3 = Color3.fromRGB(125,125,132),
				Text = "",
				TextColor3 = Theme.Text,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3
			},
			Card
		)

	Corner(KeyBox,11)

	New(
		"UIStroke",
		{
			Color = Color3.fromRGB(72,72,79),
			Thickness = 1,
			Transparency = 0.20
		},
		KeyBox
	)

	New(
		"UIPadding",
		{
			PaddingLeft = UDim.new(0,15),
			PaddingRight = UDim.new(0,15)
		},
		KeyBox
	)

	-- Botão de validação sempre visível e com contraste alto.
	local ValidateButton =
		New(
			"TextButton",
			{
				Name = "ValidateKeyButton",
				Position = UDim2.fromOffset(22,188),
				Size = UDim2.new(1,-44,0,48),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Active = true,
				Visible = true,
				Font = Enum.Font.GothamBold,
				Text = "✓  Validar Key",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = 15,
				ZIndex = 5
			},
			Card
		)

	Corner(ValidateButton,11)

	New(
		"UIStroke",
		{
			Color = Color3.fromRGB(105,185,255),
			Thickness = 1,
			Transparency = 0.25
		},
		ValidateButton
	)

	local Status =
		New(
			"TextLabel",
			{
				Position = UDim2.fromOffset(22,248),
				Size = UDim2.new(1,-44,0,42),
				BackgroundColor3 = Color3.fromRGB(35,35,39),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Text = "Aguardando key",
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 3
			},
			Card
		)

	Corner(Status,10)

	New(
		"UIPadding",
		{
			PaddingLeft = UDim.new(0,13),
			PaddingRight = UDim.new(0,13)
		},
		Status
	)

	local Footer =
		New(
			"TextLabel",
			{
				Position = UDim2.fromOffset(22,305),
				Size = UDim2.new(1,-44,0,18),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = "Cartola Hub  •  Metro Life RP",
				TextColor3 = Theme.SubText,
				TextTransparency = 0.38,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Center
			},
			Card
		)

	local function ResizeKeyCard()
		local Camera = workspace.CurrentCamera

		if not Camera then
			return
		end

		local Viewport = Camera.ViewportSize
		local Width = math.clamp(math.floor(Viewport.X*0.92),330,470)
		local Height = 340

		if Viewport.Y < 390 then
			Height = math.max(320,math.floor(Viewport.Y*0.92))
		end

		Card.Size = UDim2.fromOffset(Width,Height)
	end

	ResizeKeyCard()

	if workspace.CurrentCamera then
		workspace.CurrentCamera
			:GetPropertyChangedSignal("ViewportSize")
			:Connect(ResizeKeyCard)
	end

	local function NormalizeKey(Value)
		return
			tostring(Value or "")
			:gsub("^%s+","")
			:gsub("%s+$","")
	end

	local function NormalizeHWID(Value)
		Value =
			tostring(Value or "")
			:gsub("^%s+","")
			:gsub("%s+$","")

		if
			#Value>=8
			and
			#Value<=512
		then
			return Value
		end

		return nil
	end

	local function GetExecutorHWID()
		if CachedHWID then
			return CachedHWID
		end

		local Candidates={}

		-- APIs comuns expostas por diferentes executores.
		if type(gethwid)=="function" then
			table.insert(
				Candidates,
				gethwid
			)
		end

		if type(get_hwid)=="function" then
			table.insert(
				Candidates,
				get_hwid
			)
		end

		if
			type(syn)=="table"
			and
			type(syn.gethwid)=="function"
		then
			table.insert(
				Candidates,
				syn.gethwid
			)
		end

		if
			type(fluxus)=="table"
			and
			type(fluxus.gethwid)=="function"
		then
			table.insert(
				Candidates,
				fluxus.gethwid
			)
		end

		if
			type(getexecutorhwid)=="function"
		then
			table.insert(
				Candidates,
				getexecutorhwid
			)
		end

		for _,Getter in ipairs(
			Candidates
		) do
			local Ok,Value=
				pcall(
					Getter
				)

			if Ok then
				Value=
					NormalizeHWID(
						Value
					)

				if Value then
					CachedHWID=Value
					return CachedHWID
				end
			end
		end

		return nil,
			"Seu executor não disponibiliza HWID compatível."
	end


	local function SaveKey(Value)
		if
			type(writefile)=="function"
		then
			pcall(
				writefile,
				KeyFile,
				Value
			)
		end
	end

	local function ReadSavedKey()
		if
			type(readfile)~="function"
		then
			return nil
		end

		if
			type(isfile)=="function"
			and
			not isfile(KeyFile)
		then
			return nil
		end

		local Ok,Value =
			pcall(
				readfile,
				KeyFile
			)

		if
			Ok
			and
			type(Value)=="string"
		then
			Value =
				NormalizeKey(Value)

			if Value~="" then
				return Value
			end
		end

		return nil
	end

	local function ValidateKey(Value)
		Value =
			NormalizeKey(Value)

		if Value=="" then
			return false,
				"Digite uma key."
		end

		if type(HttpRequest)~="function" then
			return false,
				"Executor sem suporte a request/http_request."
		end

		local CurrentHWID,HWIDError =
			GetExecutorHWID()

		if not CurrentHWID then
			return false,
				HWIDError
				or
				"Não foi possível obter o HWID deste dispositivo."
		end

		local Ok,Response =
			pcall(function()

				return HttpRequest({
					Url = ValidateUrl,
					Method = "POST",
					Headers = {
						["Content-Type"] =
							"application/json",
						["apikey"] =
							SupabasePublishableKey
					},
					Body =
						HttpService:JSONEncode({
							p_key = Value,
							p_user_id = Player.UserId,
							p_place_id = game.PlaceId,
							p_hwid = CurrentHWID
						})
				})

			end)

		if
			not Ok
			or
			type(Response)~="table"
		then
			return false,
				"Falha ao conectar ao servidor de keys."
		end

		local StatusCode =
			Response.StatusCode
			or
			Response.Status
			or
			0

		local Body =
			Response.Body
			or
			Response.body
			or
			""

		local Decoded

		pcall(function()
			Decoded =
				HttpService:JSONDecode(Body)
		end)

		if
			StatusCode>=200
			and
			StatusCode<300
			and
			type(Decoded)=="table"
			and
			Decoded.valid==true
		then
			return true,
				Decoded
		end

		local Message =
			type(Decoded)=="table"
			and
			(
				Decoded.message
				or
				Decoded.error
			)
			or
			"Key inválida."

		return false,
			tostring(Message)
	end

	local function TryKey(Value)
		if Validating then
			return
		end

		Validating =
			true

		ValidateButton.Text =
			"Validando..."

		Status.Text =
			"Validando Key..."

		Status.TextColor3 =
			Theme.SubText

		task.spawn(function()

			local Ok,Result =
				ValidateKey(Value)

			if Ok then

				local Clean =
					NormalizeKey(Value)

				SaveKey(Clean)

				Status.Text =
					"✅ Key válida. Abrindo Cartola Hub..."

				Status.TextColor3 =
					Theme.Green

				ValidateButton.Text =
					"Liberado"

				KeyValidated =
					true

				if KeyGui then
					KeyGui:Destroy()
				end

			else

				Status.Text =
					"❌ "..tostring(Result)

				Status.TextColor3 =
					Theme.Red

				ValidateButton.Text =
					"Validar Key"

				Validating =
					false

			end

		end)
	end

	ValidateButton.MouseButton1Click:Connect(function()
		TryKey(
			KeyBox.Text
		)
	end)

	KeyBox.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			TryKey(
				KeyBox.Text
			)
		end
	end)

	local SavedKey =
		ReadSavedKey()

	if SavedKey then
		KeyBox.Text =
			SavedKey

		Status.Text =
			"Validando key salva..."

		task.defer(
			TryKey,
			SavedKey
		)
	end

	while
		not KeyValidated
		and
		not KeyClosed
	do
		task.wait(0.05)
	end

	if
		KeyClosed
		and
		not KeyValidated
	then
		return
	end
end


--============================================================
-- PERSONAGEM
--============================================================

local function GetCharacter()

	return Player.Character

end

local function GetHumanoid()

	local Character =
		GetCharacter()

	if not Character then
		return nil
	end

	return Character
		:FindFirstChildOfClass(
			"Humanoid"
		)

end

local function GetRoot()

	local Character =
		GetCharacter()

	if not Character then
		return nil
	end

	return Character
		:FindFirstChild(
			"HumanoidRootPart"
		)

end

local function ClearCharacterVelocity()

	local Character =
		GetCharacter()

	if not Character then
		return
	end

	for _, Part in ipairs(
		Character:GetDescendants()
	) do

		if Part:IsA("BasePart") then

			Part.AssemblyLinearVelocity =
				Vector3.zero

			Part.AssemblyAngularVelocity =
				Vector3.zero

		end

	end

end

--============================================================
-- REJOIN
--============================================================

local function RejoinGame()

	local Success =
		pcall(function()

			TeleportService:Teleport(
				game.PlaceId,
				Player
			)

		end)

	return Success

end

--============================================================
-- GUI
--============================================================

local Gui = New(
	"ScreenGui",
	{
		Name = "CartolaHub",

		ResetOnSpawn = false,

		IgnoreGuiInset = true,

		ZIndexBehavior =
			Enum.ZIndexBehavior.Sibling
	},
	PlayerGui
)

--============================================================
-- REGISTRO CENTRAL DO PANIC
--
-- Não usa novos locals no escopo principal para evitar pressão no limite
-- de variáveis locais do Luau. Funções internas registram aqui seus
-- respectivos métodos de parada.
--============================================================

CartolaPanicRegistry = {
	Handlers = {}
}

function CartolaPanicRegistry:Register(Name, Callback)
	if
		type(Name) == "string"
		and
		type(Callback) == "function"
	then
		self.Handlers[Name] = Callback
	end
end

function CartolaPanicRegistry:Run()
	for Name, Callback in pairs(self.Handlers) do
		local Ok, ErrorMessage =
			pcall(Callback)

		if not Ok then

		end
	end
end

-- Usa toda a área disponível da tela para o mini ícone.
pcall(function()
	Gui.IgnoreGuiInset = true
	Gui.ScreenInsets = Enum.ScreenInsets.None
	Gui.ClipToDeviceSafeArea = false
end)

--============================================================
-- MAIN
--============================================================

local Main = New(
	"Frame",
	{
		Name = "Main",

		Size =
			UDim2.fromOffset(
				920,
				535
			),

		AnchorPoint =
			Vector2.new(
				0.5,
				0.5
			),

		Position =
			UDim2.fromScale(
				0.5,
				0.5
			),

		BackgroundColor3 =
			Theme.Background,

		BorderSizePixel = 0,

		ClipsDescendants = true
	},
	Gui
)

Corner(Main,14)
Stroke(Main)

New(
	"UIScale",
	{
		Name = "DesktopScale",
		Scale = 1
	},
	Main
)

Gui:SetAttribute(
	"CartolaGuiScale",
	1
)

Gui:SetAttribute(
	"CartolaPerformanceOptimized",
	true
)

Gui:SetAttribute(
	"CartolaVehicleListsOnDemand",
	true
)

--============================================================
-- TOPBAR
--============================================================

local Topbar = New(
	"Frame",
	{
		Size =
			UDim2.new(
				1,0,
				0,65
			),

		BackgroundColor3 =
			Theme.Topbar,

		BorderSizePixel = 0
	},
	Main
)

local DragArea = New(
	"Frame",
	{
		Size =
			UDim2.new(
				1,-100,
				1,0
			),

		BackgroundTransparency = 1,

		Active = true
	},
	Topbar
)

local Title = New(
	"TextLabel",
	{
		Size =
			UDim2.fromOffset(
				190,
				65
			),

		Position =
			UDim2.fromOffset(
				28,
				0
			),

		BackgroundTransparency = 1,

		Text = "Cartola Hub",

		TextColor3 = Theme.Text,

		Font =
			Enum.Font.GothamMedium,

		TextSize = 20,

		TextXAlignment =
			Enum.TextXAlignment.Left
	},
	DragArea
)

local Subtitle = New(
	"TextLabel",
	{
		Size =
			UDim2.new(
				1,-220,
				1,0
			),

		Position =
			UDim2.fromOffset(
				220,
				0
			),

		BackgroundTransparency = 1,

		Text =
			"Metro Life RP | By didinho",

		TextColor3 =
			Theme.SubText,

		Font =
			Enum.Font.Gotham,

		TextSize = 13,

		TextXAlignment =
			Enum.TextXAlignment.Left
	},
	DragArea
)

local Minimize = New(
	"TextButton",
	{
		Size = UDim2.fromOffset(45,45),
		Position = UDim2.new(1,-95,0,10),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false
	},
	Topbar
)

-- Ícone real de minimizar: evita a aparência de uma barra grossa/desalinhada.
-- Asset utilizado pelo Infinite Yield para a mesma finalidade.
local MinimizeIcon = New(
	"ImageLabel",
	{
		Size = UDim2.fromOffset(18,18),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5,0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2406617031",
		ImageColor3 = Theme.Text,
		ScaleType = Enum.ScaleType.Fit
	},
	Minimize
)

local Close = New(
	"TextButton",
	{
		Size =
			UDim2.fromOffset(
				45,
				45
			),

		Position =
			UDim2.new(
				1,-50,
				0,10
			),

		BackgroundTransparency = 1,

		Text = "×",

		TextColor3 =
			Theme.Text,

		Font =
			Enum.Font.Gotham,

		TextSize = 34
	},
	Topbar
)

--============================================================
-- SIDEBAR
--============================================================

local Sidebar = New(
	"ScrollingFrame",
	{
		Size =
			UDim2.new(
				0,300,
				1,-65
			),

		Position =
			UDim2.fromOffset(
				0,
				65
			),

		BackgroundColor3 =
			Theme.Sidebar,

		BorderSizePixel = 0,

		AutomaticCanvasSize =
			Enum.AutomaticSize.Y,

		CanvasSize =
			UDim2.new(),

		ScrollBarThickness = 2,

		ScrollBarImageColor3 =
			Theme.Accent
	},
	Main
)

local SidePadding = New(
	"UIPadding",
	{
		PaddingLeft =
			UDim.new(
				0,
				20
			),

		PaddingRight =
			UDim.new(
				0,
				18
			),

		PaddingTop =
			UDim.new(
				0,
				10
			),

		PaddingBottom =
			UDim.new(
				0,
				10
			)
	},
	Sidebar
)

New(
	"UIListLayout",
	{
		Padding =
			UDim.new(
				0,
				10
			),

		SortOrder =
			Enum.SortOrder.LayoutOrder
	},
	Sidebar
)

--============================================================
-- CONTENT
--============================================================

local Content = New(
	"Frame",
	{
		Size =
			UDim2.new(
				1,-300,
				1,-65
			),

		Position =
			UDim2.fromOffset(
				300,
				65
			),

		BackgroundTransparency = 1
	},
	Main
)

--============================================================
-- GUI DATA
--============================================================

local Pages = {}
local Tabs = {}

local TabLabels = {}
local TabIcons = {}

local PlayerSelectors = {}

local CurrentCompact = false

--============================================================
-- GLOBAL STATES
--============================================================

local GiftRunning = false

local FlingRunning = false

local WalkFlingEnabled = false

local FlyEnabled = false

local ManualNoclip = false

local FullbrightEnabled = false

local AntiLagEnabled = false

--============================================================
-- PAGE
--============================================================

local function CreatePage(Name)

	local Page = New(
		"ScrollingFrame",
		{
			Name = Name,

			Size =
				UDim2.fromScale(
					1,
					1
				),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			ScrollBarThickness = 3,

			ScrollBarImageColor3 =
				Theme.Accent,

			AutomaticCanvasSize =
				Enum.AutomaticSize.Y,

			CanvasSize =
				UDim2.new(),

			Visible = false
		},
		Content
	)

	New(
		"UIPadding",
		{
			PaddingLeft =
				UDim.new(
					0,
					28
				),

			PaddingRight =
				UDim.new(
					0,
					20
				),

			PaddingTop =
				UDim.new(
					0,
					20
				),

			PaddingBottom =
				UDim.new(
					0,
					20
				)
		},
		Page
	)

	New(
		"UIListLayout",
		{
			Padding =
				UDim.new(
					0,
					10
				),

			SortOrder =
				Enum.SortOrder.LayoutOrder
		},
		Page
	)

	Pages[Name] =
		Page

	return Page

end

local function CloseSelectors()

	for _, Selector in ipairs(
		PlayerSelectors
	) do

		if Selector.Close then

			Selector:Close()

		end

	end

end

local function OpenPage(Name)

	CloseSelectors()

	for PageName, Page in pairs(
		Pages
	) do

		Page.Visible =
			PageName == Name

	end

	for TabName, Data in pairs(
		Tabs
	) do

		local Active =
			TabName == Name

		Data.Accent.Visible =
			Active

		Data.Button.BackgroundColor3 =
			Active
			and Theme.SidebarSelected
			or Theme.SidebarButton

	end

end

--============================================================
-- TAB
--============================================================

local function CreateTab(
	IconText,
	Text,
	PageName
)

	local Button = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					1,0,
					0,47
				),

			BackgroundColor3 =
				Theme.SidebarButton,

			BorderSizePixel = 0,

			AutoButtonColor = false,

			Text = ""
		},
		Sidebar
	)

	Corner(Button,10)

	local Accent = New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					6,
					27
				),

			Position =
				UDim2.new(
					0,0,
					0.5,-13
				),

			BackgroundColor3 =
				Theme.Accent,

			BorderSizePixel = 0,

			Visible = false
		},
		Button
	)

	Corner(Accent,4)

	local Icon = New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					45,
					47
				),

			Position =
				UDim2.fromOffset(
					10,
					0
				),

			BackgroundTransparency = 1,

			Text =
				IconText,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.Gotham,

			TextSize = 20
		},
		Button
	)

	local Label = New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-65,
					1,0
				),

			Position =
				UDim2.fromOffset(
					60,
					0
				),

			BackgroundTransparency = 1,

			Text =
				Text,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.Gotham,

			TextSize = 16,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Button
	)

	Button.MouseEnter:Connect(function()

		if not Accent.Visible then

			Button.BackgroundColor3 =
				Theme.SidebarHover

		end

	end)

	Button.MouseLeave:Connect(function()

		if not Accent.Visible then

			Button.BackgroundColor3 =
				Theme.SidebarButton

		end

	end)

	Button.MouseButton1Click:Connect(function()

		OpenPage(PageName)

	end)

	Tabs[PageName] = {

		Button = Button,

		Accent = Accent

	}

	TabLabels[PageName] =
		Label

	TabIcons[PageName] =
		Icon

end

--============================================================
-- SECTION
--============================================================

local function Section(
	Parent,
	Text
)

	return New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-8,
					0,38
				),

			BackgroundTransparency = 1,

			Text =
				Text,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamBold,

			TextSize = 23,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Parent
	)

end

--============================================================
-- STATUS
--============================================================

local function Status(
	Parent,
	Text
)

	-- Mantemos o objeto para que as funções existentes possam
	-- atualizar .Text normalmente, mas ele não aparece na interface
	-- nem ocupa espaço no layout.
	return New(
		"TextLabel",
		{
			Size = UDim2.fromOffset(0,0),
			BackgroundTransparency = 1,
			Text = Text,
			Visible = false
		},
		Parent
	)

end

--============================================================
-- ACTION
--============================================================

local function Action(
	Parent,
	Text,
	Callback
)

	local Button = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					1,-8,
					0,55
				),

			BackgroundColor3 =
				Theme.Card,

			BorderSizePixel = 0,

			AutoButtonColor = false,

			Text = ""
		},
		Parent
	)

	Corner(Button,9)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-70,
					1,0
				),

			Position =
				UDim2.fromOffset(
					18,
					0
				),

			BackgroundTransparency = 1,

			Text =
				Text,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 15,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Button
	)

	New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					45,
					55
				),

			Position =
				UDim2.new(
					1,-55,
					0,0
				),

			BackgroundTransparency = 1,

			Text = "›",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.Gotham,

			TextSize = 32
		},
		Button
	)

	Button.MouseEnter:Connect(function()

		Button.BackgroundColor3 =
			Theme.CardHover

	end)

	Button.MouseLeave:Connect(function()

		Button.BackgroundColor3 =
			Theme.Card

	end)

	Button.MouseButton1Click:Connect(function()

		if Callback then
			Callback()
		end

	end)

	return Button

end

--============================================================
-- TOGGLE
--============================================================

local function Toggle(
	Parent,
	Text,
	Default,
	Callback
)

	local Enabled =
		Default == true

	local Frame = New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,-8,
					0,55
				),

			BackgroundColor3 =
				Theme.Card,

			BorderSizePixel = 0
		},
		Parent
	)

	Corner(Frame,9)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-100,
					1,0
				),

			Position =
				UDim2.fromOffset(
					18,
					0
				),

			BackgroundTransparency = 1,

			Text =
				Text,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 15,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Frame
	)

	local Switch = New(
		"TextButton",
		{
			Size =
				UDim2.fromOffset(
					65,
					36
				),

			Position =
				UDim2.new(
					1,-80,
					0.5,-18
				),

			BackgroundColor3 =
				Color3.fromRGB(
					63,
					63,
					65
				),

			BorderSizePixel = 0,

			Text = ""
		},
		Frame
	)

	Corner(Switch,20)

	local Ball = New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					28,
					28
				),

			Position =
				UDim2.fromOffset(
					5,
					4
				),

			BackgroundColor3 =
				Color3.fromRGB(
					130,
					130,
					135
				),

			BorderSizePixel = 0
		},
		Switch
	)

	Corner(Ball,20)

	local function Refresh()

		if Enabled then

			TweenService:Create(
				Switch,
				TweenInfo.new(0.15),
				{
					BackgroundColor3 =
						Theme.Accent
				}
			):Play()

			TweenService:Create(
				Ball,
				TweenInfo.new(0.15),
				{
					Position =
						UDim2.fromOffset(
							32,
							4
						),

					BackgroundColor3 =
						Theme.Text
				}
			):Play()

		else

			TweenService:Create(
				Switch,
				TweenInfo.new(0.15),
				{
					BackgroundColor3 =
						Color3.fromRGB(
							63,
							63,
							65
						)
				}
			):Play()

			TweenService:Create(
				Ball,
				TweenInfo.new(0.15),
				{
					Position =
						UDim2.fromOffset(
							5,
							4
						),

					BackgroundColor3 =
						Color3.fromRGB(
							130,
							130,
							135
						)
				}
			):Play()

		end

	end

	local Control = {}

	function Control:Set(
		Value,
		CallCallback
	)

		Enabled =
			Value == true

		Refresh()

		if
			CallCallback ~= false
			and
			Callback
		then

			Callback(Enabled)

		end

	end

	function Control:Get()

		return Enabled

	end

	Switch.MouseButton1Click:Connect(function()

		Control:Set(
			not Enabled
		)

	end)

	Refresh()

	return Control

end

--============================================================
-- SLIDER
--============================================================

local function Slider(
	Parent,
	Text,
	Minimum,
	Maximum,
	Default,
	Callback
)

	local Value =
		math.clamp(
			Default,
			Minimum,
			Maximum
		)

	local Frame = New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,-8,
					0,78
				),

			BackgroundColor3 =
				Theme.Card,

			BorderSizePixel = 0
		},
		Parent
	)

	Corner(Frame,9)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-100,
					0,35
				),

			Position =
				UDim2.fromOffset(
					18,
					3
				),

			BackgroundTransparency = 1,

			Text =
				Text,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 15,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Frame
	)

	local Number = New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					75,
					35
				),

			Position =
				UDim2.new(
					1,-93,
					0,3
				),

			BackgroundTransparency = 1,

			Text =
				tostring(Value),

			TextColor3 =
				Theme.Accent,

			Font =
				Enum.Font.GothamBold,

			TextSize = 15,

			TextXAlignment =
				Enum.TextXAlignment.Right
		},
		Frame
	)

	local Bar = New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,-36,
					0,8
				),

			Position =
				UDim2.fromOffset(
					18,
					53
				),

			BackgroundColor3 =
				Color3.fromRGB(
					65,
					65,
					68
				),

			BorderSizePixel = 0,

			Active = true
		},
		Frame
	)

	Corner(Bar,10)

	local Fill = New(
		"Frame",
		{
			BackgroundColor3 =
				Theme.Accent,

			BorderSizePixel = 0
		},
		Bar
	)

	Corner(Fill,10)

	local Knob = New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					18,
					18
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			BackgroundColor3 =
				Theme.Text,

			BorderSizePixel = 0
		},
		Bar
	)

	Corner(Knob,20)

	local Dragging = false

	local function Refresh()

		local Percent =
			(Value - Minimum)
			/
			(Maximum - Minimum)

		Fill.Size =
			UDim2.fromScale(
				Percent,
				1
			)

		Knob.Position =
			UDim2.new(
				Percent,0,
				0.5,0
			)

		Number.Text =
			tostring(Value)

	end

	local Control = {}

	function Control:SetValue(
		NewValue,
		CallCallback
	)

		Value =
			math.clamp(

				math.floor(
					NewValue + 0.5
				),

				Minimum,

				Maximum

			)

		Refresh()

		if
			CallCallback ~= false
			and
			Callback
		then

			Callback(Value)

		end

	end

	function Control:GetValue()

		return Value

	end

	local function SetFromX(X)

		if
			Bar.AbsoluteSize.X <= 0
		then
			return
		end

		local Percent =
			math.clamp(

				(
					X
					-
					Bar.AbsolutePosition.X
				)
				/
				Bar.AbsoluteSize.X,

				0,

				1

			)

		Control:SetValue(

			Minimum
			+
			(
				Maximum
				-
				Minimum
			)
			*
			Percent

		)

	end

	Bar.InputBegan:Connect(function(Input)

		if
			Input.UserInputType
			==
			Enum.UserInputType.MouseButton1

			or

			Input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			Dragging = true

			SetFromX(
				Input.Position.X
			)

		end

	end)

	UIS.InputChanged:Connect(function(Input)

		if not Dragging then
			return
		end

		if
			Input.UserInputType
			==
			Enum.UserInputType.MouseMovement

			or

			Input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			SetFromX(
				Input.Position.X
			)

		end

	end)

	UIS.InputEnded:Connect(function(Input)

		if
			Input.UserInputType
			==
			Enum.UserInputType.MouseButton1

			or

			Input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			Dragging = false

		end

	end)

	Refresh()

	return Control

end

--============================================================
-- PLAYER SELECTOR
--============================================================

local ThumbnailCache = {}

local function CreatePlayerSelector(
	Parent,
	TitleText,
	SingleSelect,
	HideBulkActions,
	KeepDisconnectedSelection,
	PlayerFilter
)

	SingleSelect =
		SingleSelect == true

	HideBulkActions =
		HideBulkActions == true

	KeepDisconnectedSelection =
		KeepDisconnectedSelection == true

	local Selected = {}

	local Rows = {}

	local Card = New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,-8,
					0,64
				),

			BackgroundColor3 =
				Theme.Card,

			BorderSizePixel = 0
		},
		Parent
	)

	Corner(Card,10)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					0.42,0,
					0,30
				),

			Position =
				UDim2.fromOffset(
					18,
					4
				),

			BackgroundTransparency = 1,

			Text =
				TitleText,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 15,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		Card
	)

	local Description = New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					0.42,0,
					0,24
				),

			Position =
				UDim2.fromOffset(
					18,
					31
				),

			BackgroundTransparency = 1,

			Text =
				"Nenhum selecionado",

			TextColor3 =
				Theme.SubText,

			Font =
				Enum.Font.Gotham,

			TextSize = 11,

			TextXAlignment =
				Enum.TextXAlignment.Left,

			TextTruncate =
				Enum.TextTruncate.AtEnd
		},
		Card
	)

	local OpenButton = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					0.48,-20,
					0,42
				),

			Position =
				UDim2.new(
					0.52,5,
					0.5,-21
				),

			BackgroundColor3 =
				Theme.Card2,

			BorderSizePixel = 0,

			Text =
				SingleSelect
				and
				"Selecionar Player"
				or
				"Selecionar Players",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamBold,

			TextSize = 14,

			TextTruncate =
				Enum.TextTruncate.AtEnd
		},
		Card
	)

	Corner(OpenButton,9)

	--========================================================
	-- OVERLAY
	--========================================================

	local Overlay = New(
		"Frame",
		{
			Size =
				UDim2.fromScale(
					1,
					1
				),

			BackgroundColor3 =
				Color3.fromRGB(
					10,
					10,
					12
				),

			BackgroundTransparency =
				0.12,

			BorderSizePixel = 0,

			Visible = false,

			ZIndex = 200
		},
		Content
	)

	local Panel = New(
		"Frame",
		{
			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),

			Size =
				UDim2.new(
					1,-30,
					1,-30
				),

			BackgroundColor3 =
				Color3.fromRGB(
					31,
					32,
					36
				),

			BorderSizePixel = 0,

			ZIndex = 201
		},
		Overlay
	)

	Corner(Panel,12)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,-80,
					0,60
				),

			Position =
				UDim2.fromOffset(
					20,
					0
				),

			BackgroundTransparency = 1,

			Text =
				SingleSelect
				and
				"Selecionar jogador"
				or
				"Selecionar jogadores",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamBold,

			TextSize = 19,

			TextXAlignment =
				Enum.TextXAlignment.Left,

			ZIndex = 203
		},
		Panel
	)

	local Exit = New(
		"TextButton",
		{
			Size =
				UDim2.fromOffset(
					42,
					42
				),

			Position =
				UDim2.new(
					1,-52,
					0,10
				),

			BackgroundColor3 =
				Color3.fromRGB(
					50,
					51,
					57
				),

			BorderSizePixel = 0,

			Text = "×",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.Gotham,

			TextSize = 27,

			ZIndex = 204
		},
		Panel
	)

	Corner(Exit,9)

	local Search = New(
		"TextBox",
		{
			Size =
				UDim2.new(
					1,-30,
					0,42
				),

			Position =
				UDim2.fromOffset(
					15,
					62
				),

			BackgroundColor3 =
				Color3.fromRGB(
					45,
					46,
					52
				),

			BorderSizePixel = 0,

			Text = "",

			PlaceholderText =
				"Pesquisar jogador",

			PlaceholderColor3 =
				Theme.SubText,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.Gotham,

			TextSize = 14,

			ClearTextOnFocus = false,

			ZIndex = 203
		},
		Panel
	)

	Corner(Search,9)

	New(
		"UIPadding",
		{
			PaddingLeft =
				UDim.new(
					0,
					14
				),

			PaddingRight =
				UDim.new(
					0,
					14
				)
		},
		Search
	)

	local ActionBar = New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,-30,
					0,44
				),

			Position =
				UDim2.fromOffset(
					15,
					112
				),

			BackgroundTransparency = 1,

			Visible =
				not SingleSelect and not HideBulkActions,

			ZIndex = 203
		},
		Panel
	)

	local SelectAll = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					0.5,-5,
					1,0
				),

			BackgroundColor3 =
				Theme.Accent,

			BorderSizePixel = 0,

			Text =
				"✓ Selecionar todos",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 13,

			ZIndex = 204
		},
		ActionBar
	)

	Corner(SelectAll,9)

	local Clear = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					0.5,-5,
					1,0
				),

			Position =
				UDim2.new(
					0.5,10,
					0,0
				),

			BackgroundColor3 =
				Theme.Card2,

			BorderSizePixel = 0,

			Text =
				"Limpar selecionados",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 13,

			ZIndex = 204
		},
		ActionBar
	)

	Corner(Clear,9)

	local List = New(
		"ScrollingFrame",
		{
			Size =
				(SingleSelect or HideBulkActions)
				and
				UDim2.new(
					1,-30,
					1,-122
				)
				or
				UDim2.new(
					1,-30,
					1,-174
				),

			Position =
				(SingleSelect or HideBulkActions)
				and
				UDim2.fromOffset(
					15,
					112
				)
				or
				UDim2.fromOffset(
					15,
					164
				),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			AutomaticCanvasSize =
				Enum.AutomaticSize.Y,

			CanvasSize =
				UDim2.new(),

			ScrollBarThickness = 4,

			ScrollBarImageColor3 =
				Theme.SubText,

			ZIndex = 202
		},
		Panel
	)

	New(
		"UIListLayout",
		{
			Padding =
				UDim.new(
					0,
					10
				),

			SortOrder =
				Enum.SortOrder.LayoutOrder
		},
		List
	)

	local Selector = {}

	local function IsSelected(Target)

		return
			Selected[
				Target.UserId
			]
			~=
			nil

	end

	function Selector:GetPlayers()

		local Result = {}

		for UserId, Target in pairs(
			Selected
		) do

			if
				Target
				and
				Target.Parent == Players
				and
				(
					not PlayerFilter
					or
					PlayerFilter(Target)
				)
			then

				table.insert(
					Result,
					Target
				)

			else

				if not KeepDisconnectedSelection then
					Selected[UserId] =
						nil
				end

			end

		end

		table.sort(
			Result,
			function(A,B)

				return
					A.DisplayName:lower()
					<
					B.DisplayName:lower()

			end
		)

		return Result

	end

	function Selector:GetSelectedCount()

		local Count = 0

		for _ in pairs(
			Selected
		) do
			Count += 1
		end

		return Count

	end

	function Selector:GetFirst()

		return
			Selector:GetPlayers()[1]

	end

	function Selector:Close()

		Overlay.Visible =
			false

	end

	local function UpdateSummary()

		local Targets =
			Selector:GetPlayers()

		local Count =
			#Targets

		local RememberedCount =
			Selector:GetSelectedCount()

		if
			Count == 0
			and
			KeepDisconnectedSelection
			and
			RememberedCount > 0
		then

			OpenButton.Text =
				tostring(RememberedCount)
				..
				" selecionado(s)"

			Description.Text =
				"Aguardando player voltar"

			return

		end

		if Count == 0 then

			OpenButton.Text =
				SingleSelect
				and
				"Selecionar Player"
				or
				"Selecionar Players"

			Description.Text =
				"Nenhum selecionado"

		elseif Count == 1 then

			OpenButton.Text =
				"✓ "
				..
				Targets[1].DisplayName

			Description.Text =
				"@"
				..
				Targets[1].Name

		else

			OpenButton.Text =
				tostring(Count)
				..
				" selecionados"

			local Names = {}

			for Index = 1,
				math.min(
					Count,
					3
				)
			do

				table.insert(
					Names,
					Targets[Index].DisplayName
				)

			end

			Description.Text =
				table.concat(
					Names,
					", "
				)

			if Count > 3 then

				Description.Text =
					Description.Text
					..
					" +"
					..
					tostring(
						Count - 3
					)

			end

		end

	end

	local function ResponsiveRow(Data)

		if not Data.Row.Parent then
			return
		end

		if CurrentCompact then

			Data.Row.Size =
				UDim2.new(
					1,-4,
					0,118
				)

			Data.Avatar.Size =
				UDim2.fromOffset(
					50,
					50
				)

			Data.Avatar.Position =
				UDim2.fromOffset(
					12,
					10
				)

			Data.Display.Size =
				UDim2.new(
					1,-85,
					0,25
				)

			Data.Display.Position =
				UDim2.fromOffset(
					72,
					8
				)

			Data.Username.Size =
				UDim2.new(
					1,-85,
					0,22
				)

			Data.Username.Position =
				UDim2.fromOffset(
					72,
					34
				)

			Data.Button.Size =
				UDim2.new(
					1,-24,
					0,38
				)

			Data.Button.Position =
				UDim2.new(
					0,12,
					1,-48
				)

			Data.RowClick.Size =
				UDim2.new(
					1,0,
					0,65
				)

		else

			Data.Row.Size =
				UDim2.new(
					1,-4,
					0,92
				)

			Data.Avatar.Size =
				UDim2.fromOffset(
					65,
					65
				)

			Data.Avatar.Position =
				UDim2.new(
					0,14,
					0.5,-32
				)

			Data.Display.Size =
				UDim2.new(
					1,-250,
					0,32
				)

			Data.Display.Position =
				UDim2.fromOffset(
					94,
					15
				)

			Data.Username.Size =
				UDim2.new(
					1,-250,
					0,26
				)

			Data.Username.Position =
				UDim2.fromOffset(
					94,
					46
				)

			Data.Button.Size =
				UDim2.fromOffset(
					125,
					48
				)

			Data.Button.Position =
				UDim2.new(
					1,-139,
					0.5,-24
				)

			Data.RowClick.Size =
				UDim2.new(
					1,-145,
					1,0
				)

		end

	end

	local function UpdateRow(Data)

		if IsSelected(Data.Target) then

			Data.Button.Text =
				"✓ Selecionado"

			Data.Button.BackgroundColor3 =
				Theme.Accent

			Data.Row.BackgroundColor3 =
				Color3.fromRGB(
					38,
					46,
					56
				)

		else

			Data.Button.Text =
				"Selecionar"

			Data.Button.BackgroundColor3 =
				Color3.fromRGB(
					48,
					49,
					55
				)

			Data.Row.BackgroundColor3 =
				Color3.fromRGB(
					34,
					35,
					40
				)

		end

	end

	local function RefreshRows()

		for _, Data in ipairs(
			Rows
		) do

			if Data.Row.Parent then

				UpdateRow(Data)

			end

		end

		UpdateSummary()

	end

	function Selector:Clear()

		Selected = {}

		RefreshRows()

	end

	local function CreateRow(Target)

		local Row = New(
			"Frame",
			{
				BackgroundColor3 =
					Color3.fromRGB(
						34,
						35,
						40
					),

				BorderSizePixel = 0,

				ZIndex = 203
			},
			List
		)

		Corner(Row,11)

		local AvatarImage = New(
			"ImageLabel",
			{
				BackgroundColor3 =
					Color3.fromRGB(
						55,
						56,
						62
					),

				BorderSizePixel = 0,

				Image = "",

				ZIndex = 204
			},
			Row
		)

		Corner(
			AvatarImage,
			100
		)

		if
			ThumbnailCache[
				Target.UserId
			]
		then

			AvatarImage.Image =
				ThumbnailCache[
					Target.UserId
				]

		else

			task.spawn(function()

				local Success,
				Image =
				pcall(function()

					return
						Players:GetUserThumbnailAsync(

							Target.UserId,

							Enum.ThumbnailType.HeadShot,

							Enum.ThumbnailSize.Size150x150

						)

				end)

				if Success then

					ThumbnailCache[
						Target.UserId
					] =
						Image

					if AvatarImage.Parent then

						AvatarImage.Image =
							Image

					end

				end

			end)

		end

		local Display = New(
			"TextLabel",
			{
				BackgroundTransparency = 1,

				Text =
					Target.DisplayName,

				TextColor3 =
					Theme.Text,

				Font =
					Enum.Font.GothamMedium,

				TextSize = 17,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				TextTruncate =
					Enum.TextTruncate.AtEnd,

				ZIndex = 204
			},
			Row
		)

		local Username = New(
			"TextLabel",
			{
				BackgroundTransparency = 1,

				Text =
					"@"
					..
					Target.Name,

				TextColor3 =
					Theme.SubText,

				Font =
					Enum.Font.Gotham,

				TextSize = 13,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				TextTruncate =
					Enum.TextTruncate.AtEnd,

				ZIndex = 204
			},
			Row
		)

		local Button = New(
			"TextButton",
			{
				BackgroundColor3 =
					Color3.fromRGB(
						48,
						49,
						55
					),

				BorderSizePixel = 0,

				Text =
					"Selecionar",

				TextColor3 =
					Theme.Text,

				Font =
					Enum.Font.GothamMedium,

				TextSize = 13,

				ZIndex = 206
			},
			Row
		)

		Corner(Button,9)

		local RowClick = New(
			"TextButton",
			{
				BackgroundTransparency = 1,

				Text = "",

				ZIndex = 205
			},
			Row
		)

		local Data = {

			Target =
				Target,

			Row =
				Row,

			Avatar =
				AvatarImage,

			Display =
				Display,

			Username =
				Username,

			Button =
				Button,

			RowClick =
				RowClick

		}

		table.insert(
			Rows,
			Data
		)

		ResponsiveRow(Data)

		UpdateRow(Data)

		local function TogglePlayer()

			if SingleSelect then

				if IsSelected(Target) then

					Selected = {}

				else

					Selected = {

						[
							Target.UserId
						] =
							Target

					}

				end

			else

				if IsSelected(Target) then

					Selected[
						Target.UserId
					] =
						nil

				else

					Selected[
						Target.UserId
					] =
						Target

				end

			end

			RefreshRows()

		end

		Button.MouseButton1Click:Connect(
			TogglePlayer
		)

		RowClick.MouseButton1Click:Connect(
			TogglePlayer
		)

	end

	local function RefreshList(Filter)

		Rows = {}

		for _, Child in ipairs(
			List:GetChildren()
		) do

			if
				Child:IsA("GuiObject")
				and
				not Child:IsA(
					"UIListLayout"
				)
			then

				Child:Destroy()

			end

		end

		Filter =
			string.lower(
				Filter or ""
			)

		local PlayerList =
			Players:GetPlayers()

		table.sort(
			PlayerList,
			function(A,B)

				return
					A.DisplayName:lower()
					<
					B.DisplayName:lower()

			end
		)

		local Found = 0

		for _, Target in ipairs(
			PlayerList
		) do

			if
				Target ~= Player
				and
				(
					not PlayerFilter
					or
					PlayerFilter(Target)
				)
			then

				local Username =
					Target.Name:lower()

				local DisplayName =
					Target.DisplayName:lower()

				local Match =
					Filter == ""
					or
					string.find(
						Username,
						Filter,
						1,
						true
					)
					or
					string.find(
						DisplayName,
						Filter,
						1,
						true
					)

				if Match then

					Found += 1

					CreateRow(
						Target
					)

				end

			end

		end

		if Found == 0 then

			New(
				"TextLabel",
				{
					Size =
						UDim2.new(
							1,0,
							0,80
						),

					BackgroundTransparency = 1,

					Text =
						"Nenhum jogador encontrado",

					TextColor3 =
						Theme.SubText,

					Font =
						Enum.Font.Gotham,

					TextSize = 14,

					ZIndex = 203
				},
				List
			)

		end

	end

	OpenButton.MouseButton1Click:Connect(function()

		for _, Other in ipairs(
			PlayerSelectors
		) do

			if Other ~= Selector then

				Other:Close()

			end

		end

		Search.Text = ""

		RefreshList()

		Overlay.Visible = true

	end)

	Exit.MouseButton1Click:Connect(function()

		Selector:Close()

	end)

	Search:GetPropertyChangedSignal(
		"Text"
	):Connect(function()

		RefreshList(
			Search.Text
		)

	end)

	SelectAll.MouseButton1Click:Connect(function()

		if SingleSelect then
			return
		end

		Selected = {}

		for _, Target in ipairs(
			Players:GetPlayers()
		) do

			if
				Target ~= Player
				and
				(
					not PlayerFilter
					or
					PlayerFilter(Target)
				)
			then

				Selected[
					Target.UserId
				] =
					Target

			end

		end

		RefreshRows()

	end)

	Clear.MouseButton1Click:Connect(function()

		if SingleSelect then
			return
		end

		Selector:Clear()

	end)

	function Selector:Responsive()

		for _, Data in ipairs(
			Rows
		) do

			ResponsiveRow(Data)

		end

	end

	Players.PlayerRemoving:Connect(function(
		Leaving
	)

		if not KeepDisconnectedSelection then
			Selected[
				Leaving.UserId
			] =
				nil
		end

		UpdateSummary()

		if Overlay.Visible then

			RefreshList(
				Search.Text
			)

		end

	end)

	Players.PlayerAdded:Connect(function(
		Joining
	)

		-- Se o mesmo UserId voltar, reconecta o Player novo à seleção
		-- memorizada. Usado pelo Presente Infinito.
		if
			KeepDisconnectedSelection
			and
			Selected[
				Joining.UserId
			]
		then
			Selected[
				Joining.UserId
			] =
				Joining
		end

		UpdateSummary()

		if Overlay.Visible then

			RefreshList(
				Search.Text
			)

		end

	end)

	UpdateSummary()

	table.insert(
		PlayerSelectors,
		Selector
	)

	return Selector

end

--============================================================
-- PÁGINAS
--============================================================

local Credits =
	CreatePage("Credits")

local OP =
	CreatePage("OP")

local Principal =
	CreatePage("Principal")

-- Abas extras sem criar novas variáveis locais no escopo principal.
CreatePage("Jogador")
CreatePage("Movimento")
CreatePage("Camera")
CreatePage("Visual")

-- Página dedicada às defesas. Não guardamos em outro local
-- para evitar aumentar a quantidade de locals do escopo principal.
CreatePage("Protecoes")

local Audio =
	CreatePage("Audio")

local Casa =
	CreatePage("Casa")

-- Compatibilidade interna: Avatar aponta para a aba Jogador.
local Avatar = Pages["Jogador"]

local Ferramentas =
	CreatePage("Ferramentas")

local Veiculos =
	CreatePage("Veiculos")

CreatePage("Scripts")

--============================================================
-- TABS
--============================================================

CreateTab("👑","Créditos","Credits")
CreateTab("⭐","OP","OP")
CreateTab("🎯","Alvo","Principal")
CreateTab("🧍","Jogador","Jogador")
CreateTab("🛡️","Proteções","Protecoes")
CreateTab("🏃","Movimento","Movimento")
CreateTab("👁","Visual","Visual")
CreateTab("🚘","Veículos","Veiculos")
CreateTab("🏠","Casa","Casa")
CreateTab("🛠","Utilidades","Ferramentas")
CreateTab("📜","Scripts","Scripts")

--============================================================
-- FAST BOOT
--
-- A estrutura principal já existe neste ponto. Abrimos a página OP
-- imediatamente e cedemos 1 frame para o Roblox desenhar a interface
-- antes de continuar criando as funções mais pesadas.
--============================================================

New(
	"TextLabel",
	{
		Name = "CartolaFastBootStatus",
		Size = UDim2.new(1,0,0,38),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "Carregando funções...",
		TextColor3 = Theme.SubText,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = -100000
	},
	OP
)

OpenPage("OP")

-- Um único yield aqui faz diferença principalmente depois de ofuscar:
-- a janela consegue ser renderizada antes da montagem do restante.
task.wait()

--============================================================
-- NOCLIP MANAGER
--
-- IMPORTANTE:
-- Noclip fica restrito às funções que realmente precisam dele.
-- WalkFling mantém colisão normal e usa apenas um pulso curto no contato.
--============================================================

local OriginalCollision = {}

local function NeedsNoclip()

	-- WalkFling mantém colisão normal. Noclip global enquanto o toggle
	-- estava ligado fazia o Humanoid perder o chão/assentos e conflitava
	-- com Fly, VFly e as proteções.
	return
		ManualNoclip
		or
		FlingRunning

end

local function RestoreCollision()

	for Part, State in pairs(
		OriginalCollision
	) do

		if
			Part
			and
			Part.Parent
		then

			Part.CanCollide =
				State

		end

	end

	OriginalCollision = {}

end

local CollisionConnection =
	RunService.Stepped:Connect(function()

		if NeedsNoclip() then

			local Character =
				GetCharacter()

			if Character then

				for _, Part in ipairs(
					Character:GetDescendants()
				) do

					if Part:IsA("BasePart") then

						if
							OriginalCollision[
								Part
							]
							==
							nil
						then

							OriginalCollision[
								Part
							] =
								Part.CanCollide

						end

						Part.CanCollide =
							false

					end

				end

			end

		elseif next(OriginalCollision) then

			RestoreCollision()

		end

	end)

--============================================================
-- OP / PRESENTE
--============================================================

Section(
	OP,
	"Presente Infinito"
)

local GiftPlayers =
	CreatePlayerSelector(
		OP,
		"Players",
		false,
		false,
		true
	)

local Items = {

	{name="Capacete Amarelo",id="HardHat"},
	{name="Escada",id="Ladder"},
	{name="Vassoura",id="Broom"},
	{name="Maquiagem",id="CosmeticsPowder"},
	{name="Perfume Feminino",id="PerfumeBottle2"},
	{name="Brinquedo Barulho",id="RattleDrum"},
	{name="Dentadura Barulho",id="Toy4"},
	{name="Apito",id="Whistle"},
	{name="Bandeira Vermelha",id="Flag"},
	{name="Cone Laranja",id="TrafficCone"},
	{name="Baton",id="Lipsticks"},
	{name="Muletas",id="Crutches"},
	{name="Bota de Natal",id="ChristmasSkate"},
	{name="Madeira",id="SheetWood"},
	{name="MotoSerra",id="BloodChainsaw"},
	{name="Patins",id="RollerShoes"},
	{name="Dinheiro",id="Money"},
	{name="Bastão de Selfie",id="SelfieStick"},
	{name="Raquete de Tenis",id="Racket_3"},
	{name="Caixa de Encomenda",id="ShippingBox"},
	{name="Cortador de Grama",id="LawnMower"},
	{name="Limpador de Vidros",id="Cleaner"},
	{name="Vara de Atrair Gatos",id="CatTeaser"},
	{name="Placa de Texto com Led",id="LedText"},
	{name="Carrinho de Sorvete",id="IceCreamArt"},
	{name="Mochila Escolar",id="SchoolBag"},
	{name="Carrinho Bugar Skin Pequena",id="LowFlatCart"},
	{name="Carrinho Limpeza",id="CleaningTrolley"},
	{name="Bebe Homem",id="BabyB"},
	{name="Mamadeira",id="Bottle_002"},
	{name="Buque Vermelho",id="ValentineRoseBouquet"},
	{name="Mascara",id="Mask"},
	{name="Carrinho de Bebe",id="Babycar_a"},
	{name="Carrinho de 2 Bebes",id="Babycar_c"},
	{name="Maca Medico",id="Stretcher"},
	{name="Balde de Cimento",id="ConcreteBucket"},
	{name="Peso de Academia",id="BarBell"},
	{name="Placa de Pare",id="ParkSign"},
	{name="Aspirador de Pó",id="Karcher"}

}

local SelectedTool =
	Items[1].id

local ItemFrame = New(
	"Frame",
	{
		Size =
			UDim2.new(
				1,-8,
				0,56
			),

		BackgroundColor3 =
			Theme.Card,

		BorderSizePixel = 0,

		ClipsDescendants = true
	},
	OP
)

Corner(ItemFrame,9)

New(
	"TextLabel",
	{
		Size =
			UDim2.new(
				0.42,0,
				1,0
			),

		Position =
			UDim2.fromOffset(
				18,
				0
			),

		BackgroundTransparency = 1,

		Text = "Item",

		TextColor3 =
			Theme.Text,

		Font =
			Enum.Font.GothamMedium,

		TextSize = 15,

		TextXAlignment =
			Enum.TextXAlignment.Left
	},
	ItemFrame
)

local ItemButton = New(
	"TextButton",
	{
		Size =
			UDim2.new(
				0.48,-20,
				0,38
			),

		Position =
			UDim2.new(
				0.52,5,
				0,9
			),

		BackgroundColor3 =
			Theme.Card2,

		BorderSizePixel = 0,

		Text =
			Items[1].name,

		TextColor3 =
			Theme.Text,

		Font =
			Enum.Font.GothamBold,

		TextSize = 13,

		TextTruncate =
			Enum.TextTruncate.AtEnd
	},
	ItemFrame
)

Corner(ItemButton,8)

local ItemList = New(
	"ScrollingFrame",
	{
		Size =
			UDim2.new(
				1,-36,
				0,185
			),

		Position =
			UDim2.fromOffset(
				18,
				62
			),

		BackgroundColor3 =
			Color3.fromRGB(
				35,
				35,
				38
			),

		BorderSizePixel = 0,

		ScrollBarThickness = 3,

		ScrollBarImageColor3 =
			Theme.Accent,

		CanvasSize =
			UDim2.new(
				0,0,
				0,#Items * 39
			)
	},
	ItemFrame
)

Corner(ItemList,8)

New(
	"UIListLayout",
	{
		Padding =
			UDim.new(
				0,
				4
			)
	},
	ItemList
)

local ItemOpened = false

for _, Item in ipairs(Items) do

	local Button = New(
		"TextButton",
		{
			Size =
				UDim2.new(
					1,-5,
					0,35
				),

			BackgroundColor3 =
				Theme.Card2,

			BorderSizePixel = 0,

			Text =
				Item.name,

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize = 13
		},
		ItemList
	)

	Corner(Button,7)

	Button.MouseButton1Click:Connect(function()

		SelectedTool =
			Item.id

		ItemButton.Text =
			Item.name

		ItemOpened =
			false

		ItemFrame.Size =
			UDim2.new(
				1,-8,
				0,56
			)

	end)

end

ItemButton.MouseButton1Click:Connect(function()

	ItemOpened =
		not ItemOpened

	ItemFrame.Size =
		UDim2.new(
			1,-8,
			0,
			ItemOpened
			and
			255
			or
			56
		)

end)

local GiftStatus =
	Status(
		OP,
		"✅ Pronto"
	)

local GiftButton = New(
	"TextButton",
	{
		Size =
			UDim2.new(
				1,-8,
				0,55
			),

		BackgroundColor3 =
			Theme.Green,

		BorderSizePixel = 0,

		Text =
			"▶ Iniciar Presente Infinito",

		TextColor3 =
			Theme.Text,

		Font =
			Enum.Font.GothamBold,

		TextSize = 14
	},
	OP
)

Corner(GiftButton,9)

local GiftCount = 0

GiftButton.MouseButton1Click:Connect(function()

	if GiftRunning then

		GiftRunning = false

		GiftButton.Text =
			"▶ Iniciar Presente Infinito"

		GiftButton.BackgroundColor3 =
			Theme.Green

		GiftStatus.Text =
			"⏹ Parado"

		return
	end

	if not GiftRemote then

		GiftStatus.Text =
			"⚠️ InteractGiftRE não encontrado"

		return
	end

	local Targets =
		GiftPlayers:GetPlayers()

	if
		#Targets == 0
		and
		GiftPlayers:GetSelectedCount() == 0
	then

		GiftStatus.Text =
			"⚠️ Selecione pelo menos 1 jogador"

		return
	end

	GiftRunning = true

	GiftCount = 0

	GiftButton.Text =
		"⏹ Parar"

	GiftButton.BackgroundColor3 =
		Theme.Red

	task.spawn(function()

		while GiftRunning do

			local Current =
				GiftPlayers:GetPlayers()

			if #Current == 0 then

				if
					GiftPlayers:GetSelectedCount()
					>
					0
				then
					GiftStatus.Text =
						"⏳ Player selecionado saiu • aguardando voltar"

					task.wait(1)
					continue
				end

				GiftRunning = false

				GiftButton.Text =
					"▶ Iniciar Presente Infinito"

				GiftButton.BackgroundColor3 =
					Theme.Green

				GiftStatus.Text =
					"⚠️ Nenhum jogador selecionado"

				break

			end

			GiftCount += 1

			for _, Target in ipairs(
				Current
			) do

				GiftRemote:FireServer({

					GiftBox =
						"GiftBox5",

					TargetUserId =
						Target.UserId,

					Action =
						"GiveGift",

					ToolId =
						SelectedTool

				})

			end

			GiftStatus.Text =
				"📤 "
				..
				GiftCount
				..
				"x | "
				..
				#Current
				..
				" players"

			task.wait(1)

		end

	end)

end)


--============================================================
-- BOMBA INFINITA / C4
-- BLOCO ISOLADO para não ultrapassar o limite de locais do Luau.
--============================================================

do

	local InfiniteBombEnabled = false
	local InfiniteBombThread = nil
	local InfiniteBombCycles = 0
	local InfiniteBombPlantCount = 0
	local InfiniteBombDetonateCount = 0

	local BombToolActivatedRE = nil
	local BombC4RE = nil
	local BombToggle = nil

	Section(
		OP,
		"Bomba Infinita"
	)

	local InfiniteBombStatus =
		Status(
			OP,
			"💣 Bomba Infinita: desligada"
		)

	local function ResolveBombRemotes()

		local BombRemotes =
			ReplicatedStorage:FindFirstChild("Remotes")

		if not BombRemotes then

			BombRemotes =
				ReplicatedStorage:WaitForChild(
					"Remotes",
					5
				)

		end

		if not BombRemotes then
			return false, "Pasta Remotes não encontrada"
		end

		BombToolActivatedRE =
			BombRemotes:FindFirstChild("ToolActivatedRE")

		if not BombToolActivatedRE then

			BombToolActivatedRE =
				BombRemotes:WaitForChild(
					"ToolActivatedRE",
					5
				)

		end

		BombC4RE =
			BombRemotes:FindFirstChild("C4RE")

		if not BombC4RE then

			BombC4RE =
				BombRemotes:WaitForChild(
					"C4RE",
					5
				)

		end

		if not BombToolActivatedRE then
			return false, "ToolActivatedRE não encontrado"
		end

		if not BombC4RE then
			return false, "C4RE não encontrado"
		end

		return true

	end

	local function GetBombPlacement()

		local Character =
			GetCharacter()

		local Root =
			GetRoot()

		if
			not Character
			or
			not Root
		then
			return nil
		end

		-- Planta alguns studs à frente em vez de exatamente embaixo do
		-- personagem. Isso evita que a própria sequência de C4 aplique
		-- pequenas correções físicas no Humanoid a cada ciclo.
		local Position =
			Root.Position
			+
			Root.CFrame.LookVector * 8

		local RayOrigin =
			Position
			+
			Vector3.new(0,3,0)

		local RaycastParameters =
			RaycastParams.new()

		RaycastParameters.FilterType =
			Enum.RaycastFilterType.Exclude

		RaycastParameters.FilterDescendantsInstances = {
			Character
		}

		local RaycastResult =
			workspace:Raycast(
				RayOrigin,
				Vector3.new(0,-16,0),
				RaycastParameters
			)

		local GroundPosition =
			RaycastResult
			and
			RaycastResult.Position
			or
			Vector3.new(
				Position.X,
				Position.Y - 3,
				Position.Z
			)

		local GroundPart =
			RaycastResult
			and
			RaycastResult.Instance
			or
			workspace:FindFirstChild("Baseplate")

		local RayPath =
			RaycastResult
			and
			RaycastResult.Instance:GetFullName()
			or
			"Workspace.Ground"

		return {
			RayPos = GroundPosition,
			RayPart = GroundPart,
			RayPath = RayPath
		}

	end

	local function PlantInfiniteC4()

		if not BombToolActivatedRE then
			return false
		end

		local Placement =
			GetBombPlacement()

		if
			not Placement
			or
			not Placement.RayPart
		then

			InfiniteBombStatus.Text =
				"⚠️ Não foi possível localizar o chão"

			return false

		end

		local Success,
			ErrorMessage =
			pcall(function()

				BombToolActivatedRE:FireServer({
					Normal = Vector3.new(0,1,0),
					RayPos = Placement.RayPos,
					InRange = true,
					RayPath = Placement.RayPath,
					RayPart = Placement.RayPart,
					Offset = CFrame.new(0,0,0),
					ToolName = "C4"
				})

			end)

		if not Success then

		end

		return Success

	end

	local function DetonateInfiniteC4()

		if not BombC4RE then
			return false
		end

		local Success,
			ErrorMessage =
			pcall(function()

				BombC4RE:FireServer()

			end)

		if not Success then

		end

		return Success

	end

	local function StopInfiniteBomb()

		InfiniteBombEnabled = false

		if InfiniteBombThread then

			pcall(function()
				task.cancel(InfiniteBombThread)
			end)

			InfiniteBombThread = nil

		end

		if InfiniteBombStatus and InfiniteBombStatus.Parent then

			InfiniteBombStatus.Text =
				"⏹ Parado | Ciclos: "
				..
				tostring(InfiniteBombCycles)

		end

	end

	CartolaPanicRegistry:Register(
		"BombaInfinita",
		StopInfiniteBomb
	)

	local function StartInfiniteBomb()

		if InfiniteBombEnabled then
			return
		end

		InfiniteBombStatus.Text =
			"⏳ Procurando remotes do C4..."

		local Found,
			Reason =
			ResolveBombRemotes()

		if not Found then

			InfiniteBombStatus.Text =
				"⚠️ " .. tostring(Reason)

			if BombToggle then
				BombToggle:Set(false, false)
			end

			return

		end

		InfiniteBombEnabled = true
		InfiniteBombCycles = 0
		InfiniteBombPlantCount = 0
		InfiniteBombDetonateCount = 0

		InfiniteBombStatus.Text =
			"💣 Bomba Infinita ativa"

		InfiniteBombThread =
			task.spawn(function()

				while InfiniteBombEnabled do

					InfiniteBombCycles += 1

					if PlantInfiniteC4() then
						InfiniteBombPlantCount += 1
					end

					task.wait(0.16)

					if not InfiniteBombEnabled then
						break
					end

					if DetonateInfiniteC4() then
						InfiniteBombDetonateCount += 1
					end

					InfiniteBombStatus.Text =
						"💣 Ciclos: "
						..
						tostring(InfiniteBombCycles)
						..
						" | Plantadas: "
						..
						tostring(InfiniteBombPlantCount)
						..
						" | Detonadas: "
						..
						tostring(InfiniteBombDetonateCount)

					task.wait(0.20)

				end

			end)

	end

	Action(
		OP,
		"Equipar Bomba",
		function()

			local Event =
				game:GetService(
					"ReplicatedStorage"
				).Remotes.EquipToolRF

			pcall(function()

				Event:InvokeServer(
					"C4"
				)

			end)

		end
	)

	BombToggle =
		Toggle(
			OP,
			"Bomba Infinita",
			false,
			function(Enabled)

				if Enabled then
					StartInfiniteBomb()
				else
					StopInfiniteBomb()
				end

			end
		)

	Gui.Destroying:Connect(function()
		StopInfiniteBomb()
	end)

end

--============================================================
-- DESBLOQUEIOS LEGO
-- Pets: Coelho, Cachorro, Lagartixa, Gato
-- Veículo: Ônibus LEGO
--============================================================

Section(
	OP,
	"Desbloqueios LEGO"
)

Action(
	OP,
	"Desbloquear Pets e Ônibus LEGO",
	function()

		local Remotes =
			ReplicatedStorage:FindFirstChild(
				"Remotes"
			)

		if not Remotes then
			return
		end

		-- Pet Coelho
		pcall(function()
			local Event = Remotes:FindFirstChild("LegoMusicGameRF")
			if Event then
				Event:InvokeServer("MarkCompleted")
				task.wait(0.08)
				Event:InvokeServer("ClaimReward")
			end
		end)

		task.wait(0.08)

		-- Pet Cachorro
		pcall(function()
			local LegoCafeCounter = ReplicatedStorage:FindFirstChild("LegoCafeCounter")
			local CafeCompletedRE = LegoCafeCounter and LegoCafeCounter:FindFirstChild("CafeCompletedRE")
			if CafeCompletedRE then
				CafeCompletedRE:FireServer("CompleteCafeGame")
			end
		end)

		task.wait(0.08)

		pcall(function()
			local Event = Remotes:FindFirstChild("LegoCafeCounterRF")
			if Event then
				Event:InvokeServer("ClaimReward")
			end
		end)

		task.wait(0.08)

		-- Pet Lagartixa
		pcall(function()
			local Event = Remotes:FindFirstChild("LegoPhotoRF")
			if Event then
				Event:InvokeServer("MarkCompleted")
				task.wait(0.08)
				Event:InvokeServer("ClaimReward")
			end
		end)

		task.wait(0.08)

		-- Pet Gato
		pcall(function()
			local Event = Remotes:FindFirstChild("LegoCakeRF")
			if Event then
				Event:InvokeServer("MarkCompleted")
				task.wait(0.08)
				Event:InvokeServer("ClaimReward")
			end
		end)

		task.wait(0.08)

		-- Ônibus LEGO
		pcall(function()
			local Event = Remotes:FindFirstChild("LogoMgrRF")
			if Event then
				Event:InvokeServer("ClaimLegoBus")
			end
		end)

	end
)

--============================================================
-- BARULHO VIDRO QUEBRADO
-- OP / abaixo da Bomba Infinita.
-- O efeito usa a posição atual do player selecionado.
--============================================================

Section(
	OP,
	"Barulho Vidro Quebrado"
)

do
	local GlassPlayerSelector =
		CreatePlayerSelector(
			OP,
			"Player do Barulho",
			true,
			true
		)

	local SpecialFxLoopEnabled =
		false

	local SpecialFxLoopToken =
		0

	local SpecialFxLoopToggle =
		nil

	local SpecialFxInterval =
		0.20

	local function GetSpecialFxRemote()

		local RemotesFolder =
			ReplicatedStorage:FindFirstChild(
				"Remotes"
			)

		return
			RemotesFolder
			and
			RemotesFolder:FindFirstChild(
				"SpecialFxEndRE"
			)

	end

	local function GetGlassTargetPosition()

		local Target =
			GlassPlayerSelector:GetFirst()

		if
			not Target
			or
			not Target.Parent
		then

			return nil

		end

		local Character =
			Target.Character

		if
			not Character
			or
			not Character.Parent
		then

			return nil

		end

		local Root =
			Character:FindFirstChild(
				"HumanoidRootPart"
			)

		local BoundsCFrame =
			nil

		local BoundsSize =
			nil

		pcall(function()

			BoundsCFrame,
			BoundsSize =
				Character:GetBoundingBox()

		end)

		if
			BoundsCFrame
			and
			BoundsSize
		then

			local SmallMorph =
				BoundsSize.Y <= 4.50

			local RootOffset =
				Root
				and
				(
					BoundsCFrame.Position
					-
					Root.Position
				).Magnitude
				or
				math.huge

			if
				SmallMorph
				or
				RootOffset >= 2.25
			then

				return
					BoundsCFrame.Position

			end

		end

		if
			Root
			and
			Root:IsA("BasePart")
		then

			return Root.Position

		end

		local Primary =
			Character.PrimaryPart

		if
			Primary
			and
			Primary:IsA("BasePart")
		then

			return Primary.Position

		end

		local Torso =
			Character:FindFirstChild(
				"UpperTorso"
			)
			or
			Character:FindFirstChild(
				"Torso"
			)
			or
			Character:FindFirstChild(
				"Head"
			)

		if
			Torso
			and
			Torso:IsA("BasePart")
		then

			return Torso.Position

		end

		local PivotPosition =
			nil

		pcall(function()

			PivotPosition =
				Character:GetPivot().Position

		end)

		return PivotPosition

	end

	local function FormatSpecialFxPosition(
		Position
	)

		return string.format(
			"%.6f, %.6f, %.6f",
			Position.X,
			Position.Y,
			Position.Z
		)

	end

	local function FireGlassBottleFxAtTarget()

		local Position =
			GetGlassTargetPosition()

		if
			typeof(Position)
			~=
			"Vector3"
		then

			return false

		end

		local Event =
			GetSpecialFxRemote()

		if not Event then
			return false
		end

		local Payload =
			"11112907957|Throw|Glass_Bottle_Broken|120|"
			..
			FormatSpecialFxPosition(
				Position
			)

		local Ok =
			pcall(function()

				Event:FireServer(
					Payload
				)

			end)

		return Ok

	end

	Action(
		OP,
		"Executar Uma Vez",
		function()

			FireGlassBottleFxAtTarget()

		end
	)

	Slider(
		OP,
		"Intervalo do Barulho (ms)",
		100,
		2000,
		200,
		function(Value)

			SpecialFxInterval =
				math.max(
					0.10,
					(
						tonumber(Value)
						or
						200
					)
					/
					1000
				)

		end
	)

	SpecialFxLoopToggle =
		Toggle(
			OP,
			"Vidro Quebrado Infinito",
			false,
			function(Enabled)

				SpecialFxLoopEnabled =
					Enabled == true

				SpecialFxLoopToken += 1

				if not SpecialFxLoopEnabled then
					return
				end

				if
					not GlassPlayerSelector:GetFirst()
				then

					task.defer(function()

						if SpecialFxLoopToggle then

							SpecialFxLoopToggle:Set(
								false,
								false
							)

						end

					end)

					SpecialFxLoopEnabled =
						false

					return

				end

				local ThisToken =
					SpecialFxLoopToken

				task.spawn(function()

					while
						SpecialFxLoopEnabled
						and
						ThisToken
						==
						SpecialFxLoopToken
						and
						Gui.Parent
					do

						-- Busca novamente a posição em cada disparo,
						-- então o som acompanha o player selecionado.
						FireGlassBottleFxAtTarget()

						task.wait(
							SpecialFxInterval
						)

					end

				end)

			end
		)

	Gui.Destroying:Connect(function()

		SpecialFxLoopEnabled =
			false

		SpecialFxLoopToken += 1

	end)

end

local StopView

--============================================================
-- FLING NORMAL - MÁXIMA FORÇA / UI SIMPLES
--
-- Interface:
--   • escolher player(s);
--   • um único botão para ligar/desligar.
--
-- Potência fixa extrema:
--   • densidade alta nas partes;
--   • BodyAngularVelocity muito alto no eixo Y;
--   • AssemblyAngularVelocity reaplicada durante o contato;
--   • pulso linear alto enquanto fica colado no alvo;
--   • mantém proteção contra cair junto no Void.
--============================================================

Section(
	Principal,
	"Dart"
)

do
	local DartSelector =
		CreatePlayerSelector(
			Principal,
			"Player do Dart",
			true,
			true
		)

	local DartEnabled =
		false

	local FollowConnection =
		nil

	local function GetDartTool()
		local Character =
			GetCharacter()

		local Backpack =
			Player:FindFirstChildOfClass(
				"Backpack"
			)

		return
			(
				Character
				and
				Character:FindFirstChild(
					"Dart"
				)
			)
			or
			(
				Backpack
				and
				Backpack:FindFirstChild(
					"Dart"
				)
			)
	end

	local function EquipDart()
		local Character =
			GetCharacter()

		local Dart =
			GetDartTool()

		if
			not Character
			or
			not Dart
			or
			not Dart:IsA("Tool")
		then
			return nil
		end

		if Dart.Parent ~= Character then
			pcall(function()
				Dart.Parent =
					Character
			end)
		end

		return Dart
	end

	local function GetDartBoardRemote()
		local SetupBuild =
			workspace:FindFirstChild(
				"SetupBuild"
			)

		if not SetupBuild then
			return nil
		end

		local DartGame =
			SetupBuild:FindFirstChild(
				"DartGame_11112907957"
			)

		if not DartGame then
			for _, Child in ipairs(
				SetupBuild:GetChildren()
			) do
				if
					Child.Name
					and
					Child.Name:match(
						"^DartGame_"
					)
				then
					DartGame = Child
					break
				end
			end
		end

		local Handle =
			DartGame
			and
			DartGame:FindFirstChild(
				"Handle"
			)

		local Event =
			Handle
			and
			Handle:FindFirstChild(
				"DartBoardRE"
			)

		if Event and Event:IsA("RemoteEvent") then
			return Event
		end

		return nil
	end

	local function RequestDartTool()
		local Event =
			GetDartBoardRemote()

		if not Event then
			return false
		end

		return pcall(function()
			Event:FireServer(
				"EquiptTool",
				{
					Tool = "Dart",
					Color = "Red"
				}
			)
		end)
	end

	local function RequestAndEquipDart(Timeout)
		-- Pede o Dart primeiro; só retorna quando ele realmente existe/equipa.
		RequestDartTool()

		local Deadline =
			os.clock()
			+
			(tonumber(Timeout) or 2)

		repeat
			local Dart = EquipDart()

			if Dart then
				return Dart
			end

			task.wait(0.05)
		until os.clock() >= Deadline

		return nil
	end


	local function StopDart()
		DartEnabled =
			false

		Gui:SetAttribute(
			"DartTargetActive",
			false
		)

		if FollowConnection then
			FollowConnection:Disconnect()

			FollowConnection =
				nil
		end
	end

	CartolaPanicRegistry:Register(
		"DartTarget",
		StopDart
	)

	local DartToggle

	DartToggle =
		Toggle(
			Principal,
			"Usar Dart no Player",
			false,
			function(State)
				StopDart()

				if not State then
					return
				end

				local Target =
					DartSelector:GetFirst()

				if not Target then


					if DartToggle then
						DartToggle:Set(
							false,
							false
						)
					end

					return
				end

				-- Primeiro equipa pelo DartBoardRE; somente depois
				-- começa a seguir/ir até o player selecionado.
				local Dart =
					RequestAndEquipDart(
						2
					)

				if not Dart then


					if DartToggle then
						DartToggle:Set(
							false,
							false
						)
					end

					return
				end

				DartEnabled =
					true

				Gui:SetAttribute(
					"DartTargetActive",
					true
				)

				-- Mesma lógica da referência enviada: segue o HumanoidRootPart
				-- do alvo a 3 studs atrás. Ajuste vertical pequeno para ficar
				-- mais baixo, como na posição indicada pelo usuário.
				FollowConnection =
					RunService.Heartbeat:Connect(function()
						if not DartEnabled then
							return
						end

						local CurrentTarget =
							DartSelector:GetFirst()

						local TargetRoot =
							CurrentTarget
							and
							CurrentTarget.Character
							and
							CurrentTarget.Character:FindFirstChild(
								"HumanoidRootPart"
							)

						local Character =
							Player.Character

						local MyRoot =
							Character
							and
							Character:FindFirstChild(
								"HumanoidRootPart"
							)

						if TargetRoot and MyRoot then
							MyRoot.CFrame =
								TargetRoot.CFrame
								*
								CFrame.new(
									0,
									-0.8,
									3
								)

							MyRoot.AssemblyLinearVelocity =
								Vector3.new(0,0,0)

							MyRoot.AssemblyAngularVelocity =
								Vector3.new(0,0,0)
						end
					end)


			end
		)

	Gui.Destroying:Connect(
		StopDart
	)
end

Section(
	Principal,
	"Fling"
)

local FlingPlayers =
	CreatePlayerSelector(
		Principal,
		"Players",
		false
	)

local FlingToggle =
	nil

local OriginalFlingCFrame =
	nil

local FlingAngular =
	nil

local FlingPartBackup =
	{}

local function SetupFlingPhysics()

	local Character =
		GetCharacter()

	if not Character then
		return
	end

	FlingPartBackup =
		{}

	for _, Part in ipairs(
		Character:GetDescendants()
	) do

		if Part:IsA("BasePart") then

			FlingPartBackup[
				Part
			] = {
				Massless =
					Part.Massless,

				Custom =
					Part.CustomPhysicalProperties,

				CanCollide =
					Part.CanCollide
			}

			Part.Massless =
				true

			pcall(function()

				Part.CustomPhysicalProperties =
					PhysicalProperties.new(
						100,
						0.3,
						0.5
					)

			end)

		end

	end

end

local function RestoreFlingPhysics()

	for Part, Data in pairs(
		FlingPartBackup
	) do

		if
			Part
			and
			Part.Parent
		then

			pcall(function()

				Part.Massless =
					Data.Massless

				Part.CustomPhysicalProperties =
					Data.Custom

				Part.CanCollide =
					Data.CanCollide

			end)

		end

	end

	FlingPartBackup =
		{}

end

local function StopFling(
	RestorePosition
)

	FlingRunning =
		false

	if FlingAngular then

		FlingAngular:Destroy()

		FlingAngular =
			nil

	end

	RestoreFlingPhysics()

	local Root =
		GetRoot()

	local Humanoid =
		GetHumanoid()

	local ReturnCFrame =
		RestorePosition
		and
		OriginalFlingCFrame
		or
		(Root and Root.CFrame)

	-- O impulso extremo do Fling fica distribuído por todas as partes do
	-- personagem. Zerar apenas o HumanoidRootPart permitia que braços/pernas
	-- devolvessem a velocidade para a montagem no frame seguinte.
	ClearCharacterVelocity()

	if Root then

		Root.AssemblyLinearVelocity =
			Vector3.zero

		Root.AssemblyAngularVelocity =
			Vector3.zero

		if ReturnCFrame then

			Root.CFrame =
				ReturnCFrame

		end

	end

	if Humanoid then

		Humanoid.AutoRotate =
			true

		Humanoid.PlatformStand =
			false

		Humanoid.Sit =
			false

		Humanoid.Jump =
			false

		pcall(function()
			Humanoid:ChangeState(
				Enum.HumanoidStateType.GettingUp
			)
		end)

	end

	-- Segura somente alguns frames depois de remover a força. É suficiente
	-- para o solver descartar o momento residual sem deixar o personagem
	-- preso ou flutuando.
	task.spawn(function()

		for _ = 1, 5 do

			RunService.Heartbeat:Wait()

			if FlingRunning then
				return
			end

			local CurrentRoot =
				GetRoot()

			local CurrentHumanoid =
				GetHumanoid()

			ClearCharacterVelocity()

			if CurrentRoot and ReturnCFrame then
				CurrentRoot.CFrame = ReturnCFrame
			end

			if CurrentHumanoid then
				CurrentHumanoid.PlatformStand = false
				CurrentHumanoid.Sit = false
				CurrentHumanoid.Jump = false
				CurrentHumanoid.AutoRotate = true
			end

		end

		local CurrentHumanoid = GetHumanoid()

		if CurrentHumanoid and not FlingRunning then
			pcall(function()
				CurrentHumanoid:ChangeState(
					Enum.HumanoidStateType.Running
				)
			end)
		end

	end)

	OriginalFlingCFrame =
		nil

	if
		FlingToggle
		and
		FlingToggle:Get()
	then

		FlingToggle:Set(
			false,
			false
		)

	end

end

CartolaPanicRegistry:Register(
	"Fling",
	function()
		if FlingRunning then
			StopFling(false)
		end
	end
)

local function StartFling()

	local Targets =
		FlingPlayers:GetPlayers()

	if #Targets == 0 then



		return false

	end

	local Root =
		GetRoot()

	local Humanoid =
		GetHumanoid()

	if
		not Root
		or
		not Humanoid
	then

		return false

	end

	OriginalFlingCFrame =
		Root.CFrame

	SetupFlingPhysics()

	FlingRunning =
		true

	Humanoid.AutoRotate =
		false

	-- Muito acima do valor clássico 99999.
	-- Evita math.huge na velocidade para não gerar NaN na física.
	-- Potência extrema, mantendo valores finitos para evitar NaN/Inf
	-- no solver físico.
	local InternalAngular =
		1000000000

	local ContactBurst =
		50000000

	FlingAngular =
		Instance.new(
			"BodyAngularVelocity"
		)

	FlingAngular.Name =
		"CartolaMaximumFling"

	FlingAngular.MaxTorque =
		Vector3.new(
			0,
			math.huge,
			0
		)

	FlingAngular.P =
		math.huge

	FlingAngular.AngularVelocity =
		Vector3.new(
			0,
			InternalAngular,
			0
		)

	FlingAngular.Parent =
		Root

	task.spawn(function()

		local Index =
			1

		while FlingRunning do

			local Current =
				FlingPlayers:GetPlayers()

			if #Current == 0 then

				StopFling(
					true
				)

				break

			end

			if Index > #Current then

				Index =
					1

			end

			local Target =
				Current[
					Index
				]

			-- Fling Infinito: quem acabou de regenerar recebe prioridade,
			-- para o contato acontecer assim que o novo HRP aparecer.
			local RespawnUserId =
				tonumber(
					Gui:GetAttribute(
						"InfiniteFlingRespawnUserId"
					)
				)
				or
				0

			local RespawnUntil =
				tonumber(
					Gui:GetAttribute(
						"InfiniteFlingRespawnUntil"
					)
				)
				or
				0

			if
				RespawnUserId > 0
				and
				os.clock() <= RespawnUntil
			then
				local RespawnTarget =
					Players:GetPlayerByUserId(
						RespawnUserId
					)

				if
					RespawnTarget
					and
					table.find(
						Current,
						RespawnTarget
					)
				then
					Target =
						RespawnTarget
				end
			elseif RespawnUserId > 0 then
				Gui:SetAttribute(
					"InfiniteFlingRespawnUserId",
					0
				)

				Gui:SetAttribute(
					"InfiniteFlingRespawnUntil",
					0
				)
			end

			Index +=
				1

			if
				Target
				and
				Target.Character
			then

				local TargetCharacter =
					Target.Character

				local TargetRoot =
					TargetCharacter:FindFirstChild(
						"HumanoidRootPart"
					)

				local TargetHumanoid =
					TargetCharacter:FindFirstChildOfClass(
						"Humanoid"
					)

				if
					TargetRoot
					and
					TargetHumanoid
					and
					TargetHumanoid.Health > 0
				then

					local Started =
						os.clock()

					local FlingStartY =
						OriginalFlingCFrame
						and
						OriginalFlingCFrame.Position.Y
						or
						TargetRoot.Position.Y

					local SafeMinimumY =
						math.max(
							workspace.FallenPartsDestroyHeight
							+
							90,

							FlingStartY
							-
							120
						)

					while
						FlingRunning
						and
						Target.Character == TargetCharacter
						and
						TargetCharacter.Parent
						and
						TargetRoot.Parent == TargetCharacter
						and
						TargetHumanoid.Parent == TargetCharacter
						and
						TargetHumanoid.Health > 0
						and
						os.clock()
						-
						Started
						<
						1.15
					do

						local MyRoot =
							GetRoot()

						if not MyRoot then
							break
						end

						if
							TargetRoot.Position.Y
							<=
							SafeMinimumY
							or
							MyRoot.Position.Y
							<=
							SafeMinimumY
						then

							MyRoot.AssemblyLinearVelocity =
								Vector3.zero

							MyRoot.AssemblyAngularVelocity =
								Vector3.zero

							if OriginalFlingCFrame then

								MyRoot.CFrame =
									OriginalFlingCFrame
									+
									Vector3.new(
										0,
										3,
										0
									)

							end

							break

						end

						local T =
							(
								os.clock()
								-
								Started
							)
							*
							220

						-- Contato muito mais apertado que antes.
						MyRoot.CFrame =
							TargetRoot.CFrame
							*
							CFrame.new(
								math.sin(T)
								*
								0.08,

								math.sin(
									T * 1.73
								)
								*
								0.12,

								math.cos(T)
								*
								0.08
							)

						MyRoot.AssemblyAngularVelocity =
							Vector3.new(
								0,
								InternalAngular,
								0
							)

						MyRoot.AssemblyLinearVelocity =
							Vector3.new(
								ContactBurst,
								ContactBurst,
								ContactBurst
							)

						if FlingAngular then

							FlingAngular.AngularVelocity =
								Vector3.new(
									0,
									InternalAngular,
									0
								)

						end

						RunService.Heartbeat:Wait()

					end

					-- Se o alvo morreu/trocou de Character no Fling Infinito,
					-- encerra este ciclo completamente. O sistema de respawn
					-- só reinicia quando o novo HRP/Humanoid estiver pronto.
					if
						FlingRunning
						and
						(
							Target.Character ~= TargetCharacter
							or
							not TargetHumanoid.Parent
							or
							TargetHumanoid.Health <= 0
						)
					then
						if
							Gui:GetAttribute(
								"InfiniteFlingEnabled"
							)
							==
							true
						then
							StopFling(true)
						else
							local MyRoot =
								GetRoot()

							local MyHumanoid =
								GetHumanoid()

							ClearCharacterVelocity()

							if
								MyRoot
								and
								OriginalFlingCFrame
							then
								MyRoot.CFrame =
									OriginalFlingCFrame
									+
									Vector3.new(0,3,0)
							end

							if MyHumanoid then
								MyHumanoid.PlatformStand = false
								MyHumanoid.Sit = false
								MyHumanoid.AutoRotate = true
							end
						end
					end

				end

			end

			task.wait(
				0.01
			)

		end

	end)

	return true

end

FlingToggle =
	Toggle(
		Principal,
		"Fling",
		false,
		function(Enabled)

			if Enabled then

				if not StartFling() then

					task.defer(function()

						if FlingToggle then

							FlingToggle:Set(
								false,
								false
							)

						end

					end)

				end

			else

				if FlingRunning then

					StopFling(
						true
					)

				end

			end

		end
	)

-- Fling Infinito removido.
Gui:SetAttribute(
	"InfiniteFlingEnabled",
	false
)

Gui:SetAttribute(
	"InfiniteFlingRespawnUserId",
	0
)

Gui:SetAttribute(
	"InfiniteFlingRespawnUntil",
	0
)

CartolaFoldingFollowRuntime = {
	Enabled = false,
	Connection = nil,
	Target = nil,
	FollowY = nil,
	ReturnCFrame = nil
}

function CartolaFoldingFollowRuntime:Start()
	if self.Enabled then
		return
	end

	self.Enabled = true
	Gui:SetAttribute(
		"FoldingTableFollowActive",
		true
	)

	local Root = GetRoot()
	if Root then
		self.ReturnCFrame = Root.CFrame
	end

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self.Connection =
		RunService.Heartbeat:Connect(function(DeltaTime)
			if not self.Enabled then
				return
			end

			local Target = self.Target
			local Character =
				Target
				and
				Target.Character

			local Head =
				Character
				and
				(
					Character:FindFirstChild(
						"Head"
					)
					or
					Character:FindFirstChild(
						"HumanoidRootPart"
					)
				)

			local MyRoot = GetRoot()
			local MyHumanoid = GetHumanoid()

			if
				not Head
				or
				not MyRoot
			then
				return
			end

			local Look = Head.CFrame.LookVector
			local Flat = Vector3.new(Look.X,0,Look.Z)

			if Flat.Magnitude < 0.01 then
				Flat = Vector3.new(0,0,-1)
			else
				Flat = Flat.Unit
			end

			local Y =
				self.FollowY
				or
				(Head.Position.Y - 0.5)

			local DesiredPosition =
				Vector3.new(
					Head.Position.X,
					Y,
					Head.Position.Z
				)
				-
				Flat * 2.75

			local DesiredCFrame =
				CFrame.lookAt(
					DesiredPosition,
					Vector3.new(
						Head.Position.X,
						Y,
						Head.Position.Z
					),
					Vector3.new(0,1,0)
				)

			if
				(MyRoot.Position - DesiredPosition).Magnitude
				>
				15
			then
				MyRoot.CFrame = DesiredCFrame
			else
				MyRoot.CFrame =
					MyRoot.CFrame:Lerp(
						DesiredCFrame,
						math.clamp(
							DeltaTime * 12,
							0.18,
							0.55
						)
					)
			end

			MyRoot.AssemblyLinearVelocity = Vector3.zero
			MyRoot.AssemblyAngularVelocity = Vector3.zero

			if MyHumanoid then
				MyHumanoid.PlatformStand = false
				MyHumanoid.Sit = false
			end
		end)
end

function CartolaFoldingFollowRuntime:SetTarget(Target,FollowY)
	self.Target = Target
	self.FollowY = FollowY
end

function CartolaFoldingFollowRuntime:Stop(RestorePosition)
	self.Enabled = false
	Gui:SetAttribute(
		"FoldingTableFollowActive",
		false
	)

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	local Root = GetRoot()
	if
		RestorePosition
		and
		Root
		and
		self.ReturnCFrame
	then
		Root.CFrame = self.ReturnCFrame
		Root.AssemblyLinearVelocity = Vector3.zero
		Root.AssemblyAngularVelocity = Vector3.zero
	end

	self.Target = nil
	self.FollowY = nil
	self.ReturnCFrame = nil
end

--============================================================
-- OP / INTERAÇÕES COM PLAYER
--============================================================

;(function()
	Section(
		OP,
		"Interações com Player"
	)

	local InteractionPlayers =
		CreatePlayerSelector(
			OP,
			"Players das Interações",
			false
		)

	CartolaInteractionPlayers =
		InteractionPlayers

	local SideHugEnabled =
		false

	local SideHugToken =
		0

	local SideHugToggle =
		nil

	local TableHeadEnabled =
		false

	local TableHeadToken =
		0

	local TableHeadToggle =
		nil

	-- PicnicBoothRE funciona como toggle. Se dispararmos novamente em uma
	-- mesa que já abriu, ela fecha/volta. Portanto cada RemoteEvent é usado
	-- apenas uma vez enquanto esta execução do hub estiver ativa.
	local OpenedPicnicRemotes =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local function GetRemote(Name)
		local Folder =
			ReplicatedStorage:FindFirstChild(
				"Remotes"
			)

		return
			Folder
			and
			Folder:FindFirstChild(
				Name
			)
	end

	local function SendSideHugRequest(Target)
		if
			not Target
			or
			Target == Player
			or
			Target.Parent ~= Players
		then
			return
		end

		local Event =
			GetRemote(
				"PlayerInteractRE"
			)

		if not Event then
			return
		end

		pcall(function()
			Event:FireServer(
				"Request",
				{
					targetPlayer = Target,
					action = "SideHug"
				}
			)
		end)
	end

	local function StopSideHug()
		SideHugEnabled =
			false

		SideHugToken +=
			1
	end

	local function StartSideHug()
		if
			InteractionPlayers:GetSelectedCount()
			==
			0
		then
			return false
		end

		SideHugEnabled =
			true

		SideHugToken +=
			1

		local ThisToken =
			SideHugToken

		task.spawn(function()
			while
				SideHugEnabled
				and
				ThisToken == SideHugToken
				and
				Gui.Parent
			do
				for _,Target in ipairs(
					InteractionPlayers:GetPlayers()
				) do
					SendSideHugRequest(
						Target
					)
				end

				task.wait(
					0.35
				)
			end
		end)

		return true
	end

	SideHugToggle =
		Toggle(
			OP,
			"Pedido de Colo Infinito",
			false,
			function(Enabled)
				if Enabled then
					if not StartSideHug() then
						task.defer(function()
							if SideHugToggle then
								SideHugToggle:Set(
									false,
									false
								)
							end
						end)
					end
				else
					StopSideHug()
				end
			end
		)

	local function GetTargetHeadPart(Target)
		if
			not Target
			or
			Target.Parent ~= Players
			or
			not Target.Character
		then
			return nil
		end

		return
			Target.Character:FindFirstChild(
				"Head"
			)
			or
			Target.Character:FindFirstChild(
				"HumanoidRootPart"
			)
	end

	local function SendTableAboveHead(Target)
		local TargetHead =
			GetTargetHeadPart(
				Target
			)

		if
			not TargetHead
			or
			not TargetHead:IsA("BasePart")
		then
			return false
		end

		local function IsFoldingTablePart(Object)
			local Node =
				Object

			for _=1,8 do
				if not Node then
					break
				end

				if
					string.find(
						string.lower(
							tostring(
								Node.Name
								or
								""
							)
						),
						"foldingtable",
						1,
						true
					)
				then
					return true
				end

				Node =
					Node.Parent
			end

			return false
		end

		local function IsFoldingTableEquipped()
			local Character =
				GetCharacter()

			if not Character then
				return false
			end

			for _,Object in ipairs(
				Character:GetDescendants()
			) do
				local Name =
					string.lower(
						tostring(
							Object.Name
							or
							""
						)
					)

				if
					string.find(
						Name,
						"foldingtable",
						1,
						true
					)
					or
					(
						Object:IsA("Tool")
						and
						string.find(
							Name,
							"folding",
							1,
							true
						)
					)
				then
					return true
				end
			end

			return false
		end

		local function WaitForFoldingTableEquipped(Timeout)
			local Started =
				os.clock()

			repeat
				if IsFoldingTableEquipped() then
					return true
				end

				if
					not TableHeadEnabled
					or
					not Gui.Parent
				then
					return false
				end

				task.wait(
					0.05
				)
			until
				os.clock()
				-
				Started
				>=
				(Timeout or 1.25)

			return
				IsFoldingTableEquipped()
		end

		local function FireAllFoldingTableOpenRemotes()
			local Folder =
				workspace:FindFirstChild(
					"ObjectPlaceFolder"
				)

			if not Folder then
				return
			end

			-- Cada mesa colocada é um child separado. Percorremos todos os
			-- children, mas cada PicnicBoothRE é disparado UMA única vez.
			-- Isso evita que uma mesa já aberta receba o toggle novamente
			-- quando a próxima mesa for colocada e acabe fechando/voltando.
			for _,PlacedObject in ipairs(
				Folder:GetChildren()
			) do
				local FoldingTable =
					PlacedObject:FindFirstChild(
						"FoldingTable_1"
					)

				if
					not FoldingTable
					and
					PlacedObject.Name == "FoldingTable_1"
				then
					FoldingTable =
						PlacedObject
				end

				if FoldingTable then
					local HandleTo =
						FoldingTable:FindFirstChild(
							"HandleTo"
						)

					local PicnicBoothRE =
						HandleTo
						and
						HandleTo:FindFirstChild(
							"PicnicBoothRE"
						)

					if
						PicnicBoothRE
						and
						PicnicBoothRE:IsA(
							"RemoteEvent"
						)
						and
						not OpenedPicnicRemotes[
							PicnicBoothRE
						]
					then
						local Fired =
							pcall(function()
								PicnicBoothRE:FireServer()
							end)

						if Fired then
							OpenedPicnicRemotes[
								PicnicBoothRE
							] =
								true
						end
					end
				end
			end
		end

		local function FindHighestPlacedTableWood()
			local Folder =
				workspace:FindFirstChild(
					"ObjectPlaceFolder"
				)

			if not Folder then
				return nil
			end

			local Highest =
				nil

			local HighestY =
				-math.huge

			for _,Object in ipairs(
				Folder:GetDescendants()
			) do
				if
					Object:IsA("BasePart")
					and
					string.lower(
						tostring(
							Object.Name
							or
							""
						)
					)
					==
					"wood"
					and
					IsFoldingTablePart(
						Object
					)
				then
					local Delta =
						Object.Position
						-
						TargetHead.Position

					local Horizontal =
						Vector2.new(
							Delta.X,
							Delta.Z
						).Magnitude

					if
						Horizontal <= 8
						and
						Object.Position.Y
						>=
						TargetHead.Position.Y - 2
						and
						Object.Position.Y > HighestY
					then
						Highest =
							Object

						HighestY =
							Object.Position.Y
					end
				end
			end

			return Highest
		end

		local function FindCharacterHandle()
			local Best =
				nil

			local BestDistance =
				math.huge

			if Target.Character then
				for _,Object in ipairs(
					Target.Character:GetDescendants()
				) do
					if
						Object:IsA("BasePart")
						and
						Object.Name == "Handle"
					then
						local Distance =
							(
								Object.Position
								-
								TargetHead.Position
							).Magnitude

						if Distance < BestDistance then
							BestDistance =
								Distance

							Best =
								Object
						end
					end
				end
			end

			return Best
		end

		local StackBase =
			FindHighestPlacedTableWood()

		CartolaFoldingFollowRuntime:SetTarget(
			Target,
			(
				StackBase
				and
				StackBase.Position.Y
				or
				TargetHead.Position.Y
			)
			-
			0.5
		)

		local RayPart =
			StackBase
			or
			FindCharacterHandle()
			or
			TargetHead

		if
			not RayPart
			or
			not RayPart:IsA("BasePart")
		then
			return false
		end

		local RayPath =
			nil

		local DebugId =
			nil

		pcall(function()
			DebugId =
				RayPart:GetDebugId()
		end)

		pcall(function()
			RayPath =
				RayPart:GetFullName()
		end)

		if
			DebugId
			and
			type(getnilinstances) == "function"
			and
			not RayPart.Parent
		then
			for _,Object in ipairs(
				getnilinstances()
			) do
				if
					Object.Name == RayPart.Name
				then
					local SameDebug =
						false

					pcall(function()
						SameDebug =
							Object:GetDebugId()
							==
							DebugId
					end)

					if SameDebug then
						RayPart =
							Object

						break
					end
				end
			end
		end

		if not RayPath then
			pcall(function()
				RayPath =
					RayPart:GetFullName()
			end)
		end

		if not RayPath then
			RayPath =
				"Workspace."
				..
				Target.Name
				..
				"."
				..
				RayPart.Name
		end

		-- Se já está equipada, não chama EquipToolRF novamente.
		-- Se não está, tenta equipar UMA vez e só continua após confirmar.
		if not IsFoldingTableEquipped() then
			local EquipToolRF =
				GetRemote(
					"EquipToolRF"
				)

			if not EquipToolRF then
				return false
			end

			pcall(function()
				EquipToolRF:InvokeServer(
					"FoldingTable"
				)
			end)

			if
				not WaitForFoldingTableEquipped(
					1.35
				)
			then
				return false
			end
		end

		if
			not TableHeadEnabled
			or
			not Target.Parent
			or
			not Target.Character
			or
			not IsFoldingTableEquipped()
		then
			return false
		end

		local Event =
			GetRemote(
				"ToolActivatedRE"
			)

		if not Event then
			return false
		end

		if
			StackBase
			and
			not StackBase.Parent
		then
			StackBase =
				FindHighestPlacedTableWood()

			RayPart =
				StackBase
				or
				TargetHead
		end

		local BasePosition =
			StackBase
			and
			StackBase.Position
			or
			TargetHead.Position

		local HeightOffset =
			StackBase
			and
			math.max(
				1.80,
				StackBase.Size.Y * 0.5 + 1.45
			)
			or
			math.max(
				2.75,
				TargetHead.Size.Y * 0.5 + 2.15
			)

		local RayPos =
			BasePosition
			+
			Vector3.new(
				0,
				HeightOffset,
				0
			)

		local Forward =
			TargetHead.CFrame.LookVector

		local FlatForward =
			Vector3.new(
				Forward.X,
				0,
				Forward.Z
			)

		if FlatForward.Magnitude < 0.01 then
			FlatForward =
				Vector3.new(
					0,
					0,
					-1
				)
		else
			FlatForward =
				FlatForward.Unit
		end

		local PlacementCFrame =
			CFrame.lookAt(
				RayPos,
				RayPos + FlatForward,
				Vector3.new(
					0,
					1,
					0
				)
			)

		local Offset =
			RayPart.CFrame:ToObjectSpace(
				PlacementCFrame
			)

		local Normal =
			RayPart.CFrame:VectorToObjectSpace(
				Vector3.new(
					0,
					1,
					0
				)
			)

		local BeforeHighestY =
			StackBase
			and
			StackBase.Position.Y
			or
			TargetHead.Position.Y

		pcall(function()
			Event:FireServer(
				{
					Normal =
						Normal,

					RayPos =
						RayPos,

					InRange =
						true,

					RayPath =
						RayPath,

					RayPart =
						RayPart,

					Offset =
						Offset,

					ToolName =
						"FoldingTable"
				}
			)
		end)

		local WaitStarted =
			os.clock()

		repeat
			task.wait(
				0.08
			)

			if
				not TableHeadEnabled
				or
				not Target.Parent
			then
				break
			end

			local NewHighest =
				FindHighestPlacedTableWood()

			if
				NewHighest
				and
				NewHighest.Position.Y
				>
				BeforeHighestY + 0.35
			then
				CartolaFoldingFollowRuntime:SetTarget(
					Target,
					NewHighest.Position.Y - 0.5
				)

				-- A nova mesa apareceu: abre todas as FoldingTables existentes.
				FireAllFoldingTableOpenRemotes()

				return true
			end
		until
			os.clock()
			-
			WaitStarted
			>=
			1.00

		-- Mesmo se a replicação demorou, tenta abrir todas as mesas atuais.
		FireAllFoldingTableOpenRemotes()

		task.wait(
			0.18
		)

		return true
	end

	local function StopTableHead()
		TableHeadEnabled =
			false

		TableHeadToken +=
			1

		CartolaFoldingFollowRuntime:Stop(
			true
		)
	end

	local function StartTableHead()
		if
			InteractionPlayers:GetSelectedCount()
			==
			0
		then
			return false
		end

		TableHeadEnabled =
			true

		TableHeadToken +=
			1

		CartolaFoldingFollowRuntime:Start()

		local ThisToken =
			TableHeadToken

		task.spawn(function()
			while
				TableHeadEnabled
				and
				ThisToken == TableHeadToken
				and
				Gui.Parent
			do
				for _,Target in ipairs(
					InteractionPlayers:GetPlayers()
				) do
					SendTableAboveHead(
						Target
					)
				end

				task.wait(
					0.12
				)
			end
		end)

		return true
	end

	TableHeadToggle =
		Toggle(
			OP,
			"Mesa Dobrável na Cabeça",
			false,
			function(Enabled)
				if Enabled then
					if not StartTableHead() then
						task.defer(function()
							if TableHeadToggle then
								TableHeadToggle:Set(
									false,
									false
								)
							end
						end)
					end
				else
					StopTableHead()
				end
			end
		)

	CartolaPanicRegistry:Register(
		"PlayerInteractions",
		function()
			StopSideHug()
			StopTableHead()

			if SideHugToggle then
				SideHugToggle:Set(
					false,
					false
				)
			end

			if TableHeadToggle then
				TableHeadToggle:Set(
					false,
					false
				)
			end
		end
	)

	Gui.Destroying:Connect(function()
		StopSideHug()
		StopTableHead()
	end)
end)()

--============================================================
-- SHEETWOOD / SHEETMETAL - PILHA
-- Sem novos locals no chunk principal.
--============================================================

CartolaSheetStackRuntime = {
	Enabled = false,
	Token = 0,
	ToolName = nil,
	LastPart = setmetatable({}, {__mode = "k"}),
	Players = CartolaInteractionPlayers,
	WoodToggle = nil,
	MetalToggle = nil
}

function CartolaSheetStackRuntime:GetRemote(Name)
	local Folder =
		ReplicatedStorage:FindFirstChild(
			"Remotes"
		)

	return
		Folder
		and
		Folder:FindFirstChild(
			Name
		)
end

function CartolaSheetStackRuntime:GetHead(Target)
	if
		not Target
		or
		Target.Parent ~= Players
		or
		not Target.Character
	then
		return nil
	end

	return
		Target.Character:FindFirstChild(
			"Head"
		)
		or
		Target.Character:FindFirstChild(
			"HumanoidRootPart"
		)
end

function CartolaSheetStackRuntime:GetHandle(Target,Head)
	if
		not Target
		or
		not Target.Character
		or
		not Head
	then
		return nil
	end

	local Best = nil
	local BestDistance = math.huge

	for _,Object in ipairs(
		Target.Character:GetDescendants()
	) do
		if
			Object:IsA("BasePart")
			and
			Object.Name == "Handle"
		then
			local Distance =
				(
					Object.Position
					-
					Head.Position
				).Magnitude

			if Distance < BestDistance then
				BestDistance = Distance
				Best = Object
			end
		end
	end

	return Best
end

function CartolaSheetStackRuntime:GetToolData(ToolName)
	if ToolName == "SheetWood" then
		return
			Vector3.new(
				0.01104311365634203,
				0.99992549419403076,
				-0.0051634516566991806
			),
			CFrame.new(
				0.1146240234375,
				0.61803436279296875,
				-0.353851318359375,
				0.74995619058609009,
				-0.011697729118168354,
				-0.66138386726379395,
				0.01104311365634203,
				0.99992549419403076,
				-0.0051634516566991806,
				0.66139531135559082,
				-0.0034313853830099106,
				0.75002968311309814
			)
	end

	return
		Vector3.new(
			0.069895140826702118,
			0.99378460645675659,
			-0.086642630398273468
		),
		CFrame.new(
			-0.3499298095703125,
			0.61804962158203125,
			0.08074951171875,
			0.86405175924301147,
			-0.016906516626477242,
			0.50311905145645142,
			0.069895140826702118,
			0.99378460645675659,
			-0.086642630398273468,
			-0.49852707982063293,
			0.11002928763628006,
			0.85986298322677612
		)
end

function CartolaSheetStackRuntime:Snapshot()
	local Seen = {}
	local Folder =
		workspace:FindFirstChild(
			"ObjectPlaceFolder"
		)

	if not Folder then
		return Seen
	end

	for _,Object in ipairs(
		Folder:GetDescendants()
	) do
		if Object:IsA("BasePart") then
			Seen[Object] = true
		end
	end

	return Seen
end

function CartolaSheetStackRuntime:FindNew(
	Before,
	RayPos,
	Target,
	Token
)
	local Started = os.clock()

	repeat
		if
			not self.Enabled
			or
			self.Token ~= Token
			or
			not Target
			or
			Target.Parent ~= Players
		then
			return nil
		end

		local Folder =
			workspace:FindFirstChild(
				"ObjectPlaceFolder"
			)

		if Folder then
			local Best = nil
			local BestDistance = 10

			for _,Object in ipairs(
				Folder:GetDescendants()
			) do
				if
					Object:IsA("BasePart")
					and
					not Before[Object]
				then
					local Distance =
						(
							Object.Position
							-
							RayPos
						).Magnitude

					if Distance < BestDistance then
						BestDistance = Distance
						Best = Object
					end
				end
			end

			if Best then
				return Best
			end
		end

		task.wait(0.05)
	until
		os.clock() - Started >= 1.10

	return nil
end

function CartolaSheetStackRuntime:Place(
	Target,
	ToolName,
	Token
)
	local Head =
		self:GetHead(
			Target
		)

	if
		not Head
		or
		not Head:IsA("BasePart")
		or
		not self.Enabled
		or
		self.Token ~= Token
		or
		self.ToolName ~= ToolName
	then
		return false
	end

	local Base =
		self.LastPart[
			Target
		]

	if
		Base
		and
		(
			not Base.Parent
			or
			not Base:IsA("BasePart")
		)
	then
		Base = nil
		self.LastPart[Target] = nil
	end

	local RayPart =
		Base
		or
		self:GetHandle(
			Target,
			Head
		)
		or
		Head

	if
		not RayPart
		or
		not RayPart:IsA("BasePart")
	then
		return false
	end

	-- Igual à FoldingTable: começa a acompanhar/teleportar para o alvo
	-- antes mesmo de equipar e colocar a primeira Sheet.
	CartolaFoldingFollowRuntime:SetTarget(
		Target,
		(
			Base
			and
			Base.Position.Y
			or
			Head.Position.Y
		)
		-
		0.5
	)

	local Equip =
		self:GetRemote(
			"EquipToolRF"
		)

	local Activate =
		self:GetRemote(
			"ToolActivatedRE"
		)

	if
		not Equip
		or
		not Activate
	then
		return false
	end

	local Normal,
		Offset =
		self:GetToolData(
			ToolName
		)

	local Equipped =
		pcall(function()
			Equip:InvokeServer(
				ToolName
			)
		end)

	if not Equipped then
		return false
	end

	task.wait(0.08)

	if
		not self.Enabled
		or
		self.Token ~= Token
		or
		self.ToolName ~= ToolName
	then
		return false
	end

	local RayPath = nil

	pcall(function()
		RayPath =
			RayPart:GetFullName()
	end)

	if not RayPath then
		return false
	end

	local RayPos =
		(
			RayPart.CFrame
			*
			Offset
		).Position

	local Before =
		self:Snapshot()

	local Fired =
		pcall(function()
			Activate:FireServer(
				{
					Normal = Normal,
					RayPos = RayPos,
					InRange = true,
					RayPath = RayPath,
					RayPart = RayPart,
					Offset = Offset,
					ToolName = ToolName
				}
			)
		end)

	if not Fired then
		return false
	end

	local NewPart =
		self:FindNew(
			Before,
			RayPos,
			Target,
			Token
		)

	if NewPart then
		self.LastPart[
			Target
		] =
			NewPart

		CartolaFoldingFollowRuntime:SetTarget(
			Target,
			NewPart.Position.Y - 0.5
		)

		return true
	end

	return false
end

function CartolaSheetStackRuntime:Stop(
	Restore
)
	self.Enabled = false
	self.Token = self.Token + 1
	self.ToolName = nil
	self.LastPart = setmetatable({}, {__mode = "k"})

	CartolaFoldingFollowRuntime:Stop(
		Restore ~= false
	)
end

function CartolaSheetStackRuntime:Start(
	ToolName
)
	if
		self.Players:GetSelectedCount()
		==
		0
	then
		return false
	end

	self:Stop(false)

	self.Enabled = true
	self.ToolName = ToolName
	self.Token = self.Token + 1

	CartolaFoldingFollowRuntime:Start()

	local Token =
		self.Token

	task.spawn(function()
		while
			self.Enabled
			and
			self.Token == Token
			and
			self.ToolName == ToolName
			and
			Gui.Parent
		do
			for _,Target in ipairs(
				self.Players:GetPlayers()
			) do
				if
					not self.Enabled
					or
					self.Token ~= Token
				then
					break
				end

				self:Place(
					Target,
					ToolName,
					Token
				)
			end

			task.wait(0.12)
		end
	end)

	return true
end

CartolaSheetStackRuntime.WoodToggle =
	Toggle(
		OP,
		"Madeira na Cabeça",
		false,
		function(Enabled)
			if Enabled then
				if
					CartolaSheetStackRuntime.MetalToggle
				then
					CartolaSheetStackRuntime.MetalToggle:Set(
						false,
						false
					)
				end

				if
					not CartolaSheetStackRuntime:Start(
						"SheetWood"
					)
				then
					task.defer(function()
						if
							CartolaSheetStackRuntime.WoodToggle
						then
							CartolaSheetStackRuntime.WoodToggle:Set(
								false,
								false
							)
						end
					end)
				end
			elseif
				CartolaSheetStackRuntime.ToolName
				==
				"SheetWood"
			then
				CartolaSheetStackRuntime:Stop(
					true
				)
			end
		end
	)

CartolaSheetStackRuntime.MetalToggle =
	Toggle(
		OP,
		"Barra de Metal na Cabeça",
		false,
		function(Enabled)
			if Enabled then
				if
					CartolaSheetStackRuntime.WoodToggle
				then
					CartolaSheetStackRuntime.WoodToggle:Set(
						false,
						false
					)
				end

				if
					not CartolaSheetStackRuntime:Start(
						"SheetMetal"
					)
				then
					task.defer(function()
						if
							CartolaSheetStackRuntime.MetalToggle
						then
							CartolaSheetStackRuntime.MetalToggle:Set(
								false,
								false
							)
						end
					end)
				end
			elseif
				CartolaSheetStackRuntime.ToolName
				==
				"SheetMetal"
			then
				CartolaSheetStackRuntime:Stop(
					true
				)
			end
		end
	)

CartolaPanicRegistry:Register(
	"SheetStack",
	function()
		if CartolaSheetStackRuntime then
			CartolaSheetStackRuntime:Stop(
				true
			)

			if CartolaSheetStackRuntime.WoodToggle then
				CartolaSheetStackRuntime.WoodToggle:Set(
					false,
					false
				)
			end

			if CartolaSheetStackRuntime.MetalToggle then
				CartolaSheetStackRuntime.MetalToggle:Set(
					false,
					false
				)
			end
		end
	end
)

Gui.Destroying:Connect(function()
	if CartolaSheetStackRuntime then
		CartolaSheetStackRuntime.Enabled = false
		CartolaSheetStackRuntime.Token =
			CartolaSheetStackRuntime.Token + 1
	end
end)

--============================================================
-- WALK FLING - COMPATÍVEL COM AS NOVAS FUNÇÕES
--
-- Mantém a física normal enquanto está apenas ligado. O pulso extremo só
-- existe quando outro player realmente está próximo, e dura um frame.
-- Não altera Sit, PlatformStand, estado do Humanoid ou Noclip.
--============================================================

Section(
	OP,
	"WalkFling"
)

local StartWalkFling
local StopWalkFling

;(function()
	local WalkPower = 55
	local WalkThread = nil
	local WalkStatus = nil

	local function InternalPower()
		return 1500 + WalkPower * 155
	end

	local function IsBusy(Humanoid)
		return
			FlingRunning
			or (
				FlyEnabled
				and
				Gui:GetAttribute("FlyFlingActive") ~= true
			)
			or Gui:GetAttribute("FlingRecoveryActive") == true
			or Gui:GetAttribute("FlyRecoveryActive") == true
			or Gui:GetAttribute("CFrameFlyActive") == true
			or Gui:GetAttribute("VFlyActive") == true
			or Gui:GetAttribute("HeadSitActive") == true
			or Gui:GetAttribute("SeatPullActive") == true
			or Gui:GetAttribute("OrbitSelfActive") == true
			or Gui:GetAttribute("FollowBabycarActive") == true
			or Gui:GetAttribute("ImportedAriveActive") == true
			or Gui:GetAttribute("SavedPositionTeleporting") == true
			or Humanoid.Sit
			or Humanoid.SeatPart ~= nil
			or (
				Humanoid.PlatformStand
				and
				Gui:GetAttribute("FlyFlingActive") ~= true
			)
	end

	local function FindNearbyTarget(Root)
		local BestRoot = nil
		local BestDistance = 6.5

		for _, Target in ipairs(Players:GetPlayers()) do
			if Target ~= Player then
				local Character = Target.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local TargetRoot = Character and Character:FindFirstChild("HumanoidRootPart")

				if TargetRoot and Humanoid and Humanoid.Health > 0 then
					local Distance = (TargetRoot.Position - Root.Position).Magnitude
					if Distance < BestDistance then
						BestDistance = Distance
						BestRoot = TargetRoot
					end
				end
			end
		end

		return BestRoot
	end

	StopWalkFling = function()
		WalkFlingEnabled = false
		Gui:SetAttribute("WalkFlingPulseActive", false)
		if WalkStatus then WalkStatus.Text = "⏹ WalkFling desativado" end
	end

	StartWalkFling = function()
		if WalkFlingEnabled then return end
		WalkFlingEnabled = true
		Gui:SetAttribute("WalkFlingPulseActive", false)
		if WalkStatus then WalkStatus.Text = "⚡ WalkFling ativo" end
		if WalkThread then return end

		WalkThread = task.spawn(function()
			while WalkFlingEnabled do
				RunService.Heartbeat:Wait()
				if not WalkFlingEnabled then break end

				local Root = GetRoot()
				local Humanoid = GetHumanoid()

				if Root and Root.Parent and Humanoid and Humanoid.Health > 0 and not IsBusy(Humanoid) then
					local TargetRoot = FindNearbyTarget(Root)
					if TargetRoot then
						local SavedCFrame = Root.CFrame
						local SavedLinear = Root.AssemblyLinearVelocity
						local SavedAngular = Root.AssemblyAngularVelocity
						local Delta = TargetRoot.Position - Root.Position
						local Flat = Vector3.new(Delta.X, 0, Delta.Z)

						if Flat.Magnitude < 0.05 then
							Flat = Vector3.new(Root.CFrame.LookVector.X, 0, Root.CFrame.LookVector.Z)
						end

						if Flat.Magnitude > 0.05 then
							local Power = InternalPower()
							local Lift = math.clamp(Power * 0.025, 80, 300)
							local Pulse = Flat.Unit * Power + Vector3.new(0, Lift, 0)

							Gui:SetAttribute("WalkFlingPulseActive", true)
							Root.AssemblyAngularVelocity = Vector3.zero
							Root.AssemblyLinearVelocity = Pulse
							Root.Velocity = Pulse

							RunService.RenderStepped:Wait()

							if Root.Parent then
								Root.AssemblyLinearVelocity = SavedLinear
								Root.Velocity = SavedLinear
								Root.AssemblyAngularVelocity = SavedAngular.Magnitude < 35 and SavedAngular or Vector3.zero

								if (Root.Position - SavedCFrame.Position).Magnitude > 4 then
									Root.CFrame = SavedCFrame
								end
							end

							Gui:SetAttribute("WalkFlingPulseActive", false)
						end
					end
				end
			end

			Gui:SetAttribute("WalkFlingPulseActive", false)
			WalkThread = nil

			if WalkFlingEnabled then
				WalkFlingEnabled = false
				StartWalkFling()
			end
		end)
	end

	CartolaPanicRegistry:Register(
		"WalkFling",
		function()
			if StopWalkFling then
				StopWalkFling()
			end
		end
	)

	Toggle(OP, "WalkFling", false, function(Enabled)
		if Enabled then StartWalkFling() else StopWalkFling() end
	end)

	Slider(OP, "Potência do WalkFling", 1, 1000, 55, function(Value)
		WalkPower = Value
	end)

	WalkStatus = Status(OP, "✅ Pronto")

	Gui.Destroying:Connect(function()
		StopWalkFling()
	end)
end)()

--============================================================
-- HEADSIT - INFINITE YIELD
--============================================================

Section(
	Principal,
	"HeadSit"
)

do
	local HeadSitPlayers =
		CreatePlayerSelector(
			Principal,
			"HeadSit Player",
			true
		)

	local HeadSitEnabled =
		false

	local HeadSitConnection =
		nil

	local function StopHeadSit()
		HeadSitEnabled =
			false

		Gui:SetAttribute(
			"HeadSitActive",
			false
		)

		if HeadSitConnection then
			HeadSitConnection:Disconnect()
			HeadSitConnection =
				nil
		end

		local Humanoid =
			GetHumanoid()

		if Humanoid then
			Humanoid.Sit =
				false
		end
	end

	local function StartHeadSit()
		StopHeadSit()

		local Target =
			HeadSitPlayers:GetFirst()

		if
			not Target
			or
			Target == Player
		then
			return false
		end

		local Character =
			GetCharacter()

		local Humanoid =
			GetHumanoid()

		local Root =
			GetRoot()

		local TargetCharacter =
			Target.Character

		local TargetRoot =
			TargetCharacter
			and
			TargetCharacter:FindFirstChild(
				"HumanoidRootPart"
			)

		if
			not Character
			or
			not Humanoid
			or
			not Root
			or
			not TargetRoot
		then
			return false
		end

		HeadSitEnabled =
			true

		Gui:SetAttribute(
			"HeadSitActive",
			true
		)

		-- Infinite Yield: senta primeiro.
		Humanoid.Sit =
			true

		-- Infinite Yield: acompanha o HumanoidRootPart do alvo no Heartbeat
		-- usando exatamente o offset 0, 1.6, 0.4.
		HeadSitConnection =
			RunService.Heartbeat:Connect(function()
				local CurrentHumanoid =
					GetHumanoid()

				local CurrentRoot =
					GetRoot()

				local CurrentTargetCharacter =
					Target.Character

				local CurrentTargetRoot =
					CurrentTargetCharacter
					and
					CurrentTargetCharacter:FindFirstChild(
						"HumanoidRootPart"
					)

				if
					HeadSitEnabled
					and
					Target.Parent == Players
					and
					CurrentTargetCharacter
					and
					CurrentTargetRoot
					and
					CurrentRoot
					and
					CurrentHumanoid
					and
					CurrentHumanoid.Sit
					==
					true
				then
					CurrentRoot.CFrame =
						CurrentTargetRoot.CFrame
						*
						CFrame.Angles(
							0,
							math.rad(0),
							0
						)
						*
						CFrame.new(
							0,
							1.6,
							0.4
						)
				else
					StopHeadSit()
				end
			end)

		return true
	end

	CartolaPanicRegistry:Register(
		"HeadSit",
		StopHeadSit
	)

	Toggle(
		Principal,
		"HeadSit",
		false,
		function(Enabled)
			if Enabled then
				StartHeadSit()
			else
				StopHeadSit()
			end
		end
	)

	Gui.Destroying:Connect(
		StopHeadSit
	)
end

--============================================================
-- VIEW / SPECTATE - SEM LOOP POR FRAME
--============================================================

Section(
	Pages["Visual"],
	"View / Spectate"
)

local ViewPlayers =
	CreatePlayerSelector(
		Pages["Visual"],
		"Player",
		true
	)

local ViewStatus =
	Status(
		Pages["Visual"],
		"✅ Pronto"
	)

local ViewingPlayer = nil
local ViewConnection = {}

StopView = function()
	ViewingPlayer = nil
	Gui:SetAttribute("ViewActive", false)

	for Key, Connection in pairs(ViewConnection) do
		if Connection then
			pcall(function()
				Connection:Disconnect()
			end)
		end
		ViewConnection[Key] = nil
	end

	local Camera = workspace.CurrentCamera
	local Character = GetCharacter()
	local Humanoid = GetHumanoid()
	local Root = GetRoot()

	if Camera then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Humanoid or Root or Character
	end

	ViewStatus.Text = "⏹ View desativado"
end

local function StartView(Target)
	if
		not Target
		or Target == Player
		or Target.Parent ~= Players
	then
		ViewStatus.Text = "⚠️ Selecione um jogador válido"
		return false
	end

	-- Infinite Yield chama StopFreecam() antes do View.
	if
		Gui:GetAttribute("CFrameFlyActive")
		or Gui:GetAttribute("VFlyActive")
		or Gui:GetAttribute("FreecamActive")
	then
		ViewStatus.Text = "⚠️ Desative CFly/VFly/Freecam antes do View"
		return false
	end

	if FlingRunning then
		StopFling(true)
	end

	for Key, Connection in pairs(ViewConnection) do
		if Connection then
			pcall(function()
				Connection:Disconnect()
			end)
		end
		ViewConnection[Key] = nil
	end

	ViewingPlayer = Target
	Gui:SetAttribute("ViewActive", true)

	local function ApplyView()
		if
			not ViewingPlayer
			or ViewingPlayer ~= Target
			or ViewingPlayer.Parent ~= Players
			or not Gui:GetAttribute("ViewActive")
		then
			return
		end

		local Camera = workspace.CurrentCamera
		local Character = ViewingPlayer.Character

		if not Camera or not Character then
			ViewStatus.Text = "⏳ Aguardando " .. ViewingPlayer.DisplayName
			return
		end

		Camera.CameraType = Enum.CameraType.Custom

		-- Igual ao Infinite Yield: o Character observado vira o CameraSubject.
		if Camera.CameraSubject ~= Character then
			Camera.CameraSubject = Character
		end

		ViewStatus.Text = "👁 Assistindo " .. ViewingPlayer.DisplayName
	end

	ApplyView()

	-- Infinite Yield: viewDied / CharacterAdded.
	ViewConnection.CharacterAdded =
		Target.CharacterAdded:Connect(function()
			task.spawn(function()
				repeat
					task.wait()
				until
					Target ~= ViewingPlayer
					or (
						Target.Character ~= nil
						and Target.Character:FindFirstChild("HumanoidRootPart") ~= nil
					)

				if Target == ViewingPlayer then
					ApplyView()
				end
			end)
		end)

	-- Infinite Yield: vigia CameraSubject e restaura o alvo se o jogo mudar.
	local Camera = workspace.CurrentCamera
	if Camera then
		ViewConnection.CameraSubject =
			Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
				if
					Target == ViewingPlayer
					and Gui:GetAttribute("ViewActive")
				then
					ApplyView()
				end
			end)
	end

	-- Complemento para jogos que recriam CurrentCamera.
	ViewConnection.CurrentCamera =
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if
				Target ~= ViewingPlayer
				or not Gui:GetAttribute("ViewActive")
			then
				return
			end

			task.defer(function()
				if Target ~= ViewingPlayer then
					return
				end

				if ViewConnection.CameraSubject then
					ViewConnection.CameraSubject:Disconnect()
					ViewConnection.CameraSubject = nil
				end

				local NewCamera = workspace.CurrentCamera
				if NewCamera then
					ViewConnection.CameraSubject =
						NewCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
							if
								Target == ViewingPlayer
								and Gui:GetAttribute("ViewActive")
							then
								ApplyView()
							end
						end)
				end

				ApplyView()
			end)
		end)

	return true
end

Action(
	Pages["Visual"],
	"Assistir / Parar de assistir",
	function()
		local Target = ViewPlayers:GetFirst()

		if
			ViewingPlayer
			and (
				not Target
				or Target == ViewingPlayer
			)
		then
			StopView()
			return
		end

		if not Target then
			ViewStatus.Text = "⚠️ Selecione um jogador"
			return
		end

		StartView(Target)
	end
)

Players.PlayerRemoving:Connect(function(Target)
	if Target == ViewingPlayer then
		StopView()
	end
end)

Section(
	Principal,
	"Órbita no Player"
)

;(function()
	local Selector = CreatePlayerSelector(Principal, "Player da Órbita", true)
	local Enabled = false
	local Connection = nil
	local Angle = 0
	local Speed = 5
	local Distance = 6
	local Height = 0

	Slider(Principal, "Velocidade da Órbita", 1, 20, 5, function(Value)
		Speed = Value
	end)

	Slider(Principal, "Distância da Órbita", 2, 30, 6, function(Value)
		Distance = Value
	end)

	Slider(Principal, "Altura da Órbita", -8, 15, 0, function(Value)
		Height = Value
	end)

	local function Stop()
		Enabled = false
		Gui:SetAttribute("OrbitSelfActive", false)
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
		local Root = GetRoot()
		if Root then
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	CartolaPanicRegistry:Register(
		"OrbitSelf",
		Stop
	)

	Toggle(Principal, "Meu Boneco Órbita", false, function(Value)
		Stop()
		if not Value then return end

		local Target = Selector:GetFirst()
		if not Target then return end

		Enabled = true
		Gui:SetAttribute("OrbitSelfActive", true)
		Angle = 0

		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			if not Enabled then return end
			local TargetNow = Selector:GetFirst()
			local Root = GetRoot()
			local TargetRoot = TargetNow and TargetNow.Character and TargetNow.Character:FindFirstChild("HumanoidRootPart")
			if not Root or not TargetRoot then return end

			if FlingRunning or FlyEnabled or Gui:GetAttribute("CFrameFlyActive") or Gui:GetAttribute("VFlyActive") then
				return
			end

			Angle += DeltaTime * Speed
			Root.CFrame = TargetRoot.CFrame * CFrame.new(
				math.cos(Angle) * Distance,
				Height,
				math.sin(Angle) * Distance
			)
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
		end)
	end)

	Gui.Destroying:Connect(Stop)
end)()

Section(
	Principal,
	"Itens do Player"
)

;(function()
	local Selector =
		CreatePlayerSelector(
			Principal,
			"Player para Seguir",
			true
		)

	local FollowEnabled =
		false

	local FollowConnection =
		nil

	local FollowSpeed =
		8

	-- Ferramentas aceitas pelo modo Seguir Player.
	-- Se uma delas já estiver equipada, ela tem prioridade; caso contrário,
	-- equipa automaticamente a primeira encontrada no Backpack.
	local FollowToolNames = {
		["babycar_c"] = true,
		["babycar_a"] = true,
		["babycar_b"] = true,
		["stretcher"] = true
	}

	local function FindFollowTool()
		local function FindIn(Container)
			if not Container then
				return nil
			end

			for _,Object in ipairs(Container:GetChildren()) do
				if
					Object:IsA("Tool")
					and
					FollowToolNames[string.lower(tostring(Object.Name or ""))]
				then
					return Object
				end
			end

			return nil
		end

		local Character = GetCharacter()
		local Equipped = FindIn(Character)
		if Equipped then
			return Equipped
		end

		return FindIn(Player:FindFirstChildOfClass("Backpack"))
	end

	Slider(
		Principal,
		"Velocidade",
		1,
		30,
		8,
		function(Value)
			FollowSpeed =
				Value
		end
	)

	Toggle(
		Principal,
		"Seguir Players",
		false,
		function(Value)
			FollowEnabled =
				Value


			Gui:SetAttribute(
				"FollowBabycarActive",
				Value
			)

			if FollowConnection then
				FollowConnection:Disconnect()
				FollowConnection =
					nil
			end

			if not Value then
				return
			end

			FollowConnection =
				RunService.Heartbeat:Connect(function()
					if not FollowEnabled then
						return
					end

					local Target =
						Selector:GetFirst()

					local Root =
						GetRoot()

					local TargetRoot =
						Target
						and
						Target.Character
						and
						Target.Character:FindFirstChild(
							"HumanoidRootPart"
						)

					if
						not Root
						or
						not TargetRoot
					then
						return
					end

					if
						FlingRunning
						or
						FlyEnabled
						or
						Gui:GetAttribute(
							"CFrameFlyActive"
						)
						or
						Gui:GetAttribute(
							"VFlyActive"
						)
					then
						return
					end

					local Character =
						GetCharacter()

					local Humanoid =
						GetHumanoid()

					local Tool =
						FindFollowTool()

					if
						Character
						and
						Humanoid
						and
						Tool
						and
						Tool:IsA("Tool")
						and
						Tool.Parent ~= Character
					then
						pcall(function()
							Humanoid:EquipTool(Tool)
						end)

						if Tool.Parent ~= Character then
							Tool.Parent = Character
						end
					end

					-- Mantém o mesmo comportamento do script de referência: o
					-- personagem acompanha o alvo em vai-e-vem mesmo com o carrinho
					-- equipado, sem deixar estados físicos do Tool anularem o movimento.
					if Humanoid then
						Humanoid.PlatformStand = false
						Humanoid.Sit = false
						Humanoid.AutoRotate = true
					end

					local Offset =
						math.sin(
							os.clock()
							*
							FollowSpeed
						)
						*
						4

					Root.CFrame =
						TargetRoot.CFrame
						*
						CFrame.new(
							0,
							0,
							Offset
						)

					Root.AssemblyLinearVelocity =
						Vector3.zero

					Root.AssemblyAngularVelocity =
						Vector3.zero
				end)
		end
	)

	CartolaPanicRegistry:Register(
		"FollowPlayer",
		function()
			FollowEnabled =
				false


			Gui:SetAttribute(
				"FollowBabycarActive",
				false
			)

			if FollowConnection then
				FollowConnection:Disconnect()
				FollowConnection =
					nil
			end
		end
	)

	Gui.Destroying:Connect(function()
		FollowEnabled =
			false


		Gui:SetAttribute(
			"FollowBabycarActive",
			false
		)

		if FollowConnection then
			FollowConnection:Disconnect()
			FollowConnection =
				nil
		end
	end)
end)()

--============================================================
-- ESP
--
-- Normal: DisplayName + @username.
-- Avançado: vida, distância, estado e Tool equipada.
-- Chams: preenchimento mais forte através de paredes.
--
-- O Billboard fica no ScreenGui, não dentro da cabeça do alvo. Isso evita
-- casos em que o texto não aparece mesmo com o Highlight funcionando.
--============================================================

Section(
	Pages["Visual"],
	"ESP"
)

do
	local ESPEnabled = false
	local ESPAdvanced = false
	local ESPChams = false
	local ESPFillTransparency = 0.72
	local ESPColor = Theme.Accent
	local ESPObjects = {}
	local ESPColorOptions = {
		{ "Azul", Color3.fromRGB(75,165,255) },
		{ "Vermelho", Color3.fromRGB(220,70,70) },
		{ "Verde", Color3.fromRGB(60,190,100) },
		{ "Branco", Color3.fromRGB(245,245,245) },
		{ "Amarelo", Color3.fromRGB(240,210,60) },
		{ "Roxo", Color3.fromRGB(170,90,235) },
		{ "Laranja", Color3.fromRGB(255,145,55) },
		{ "Rosa", Color3.fromRGB(255,105,180) },
		{ "Ciano", Color3.fromRGB(70,225,235) },
		{ "Magenta", Color3.fromRGB(235,70,220) },
		{ "Verde Limão", Color3.fromRGB(170,240,70) },
		{ "Turquesa", Color3.fromRGB(45,205,175) },
		{ "Cinza", Color3.fromRGB(165,165,175) },
		{ "Preto", Color3.fromRGB(20,20,22) }
	}

	local function ESPShouldRender()
		return
			ESPEnabled
			or
			ESPAdvanced
			or
			ESPChams
	end

	local function ESPShouldShowText()
		return
			ESPEnabled
			or
			ESPAdvanced
	end

	local function GetESPColor(Target)
		return ESPColor
	end

	local function GetESPText(Target)
		if not Target then
			return ""
		end

		local Base =
			tostring(Target.DisplayName)
			..
			"\n@"
			..
			tostring(Target.Name)

		if not ESPAdvanced then
			return Base
		end

		local Character =
			Target.Character

		local Humanoid =
			Character
			and
			Character:FindFirstChildOfClass(
				"Humanoid"
			)

		local Root =
			Character
			and
			Character:FindFirstChild(
				"HumanoidRootPart"
			)

		local MyRoot =
			GetRoot()

		local Health = 0
		local MaxHealth = 100

		if Humanoid then
			Health =
				math.max(
					0,
					math.floor(
						Humanoid.Health + 0.5
					)
				)

			MaxHealth =
				math.max(
					1,
					math.floor(
						Humanoid.MaxHealth + 0.5
					)
				)
		end

		local DistanceText =
			"?"

		if Root and MyRoot then
			DistanceText =
				tostring(
					math.floor(
						(
							Root.Position
							-
							MyRoot.Position
						).Magnitude
						+
						0.5
					)
				)
		end

		local ToolName =
			"Nenhuma"

		if Character then
			local Tool =
				Character:FindFirstChildOfClass(
					"Tool"
				)

			if Tool then
				ToolName =
					Tool.Name
			end
		end

		local StateText =
			"Em pé"

		if Humanoid then
			local CurrentState =
				Humanoid:GetState()

			local SeatPart =
				Humanoid.SeatPart

			local ActuallySeated =
				false

			-- SeatPart pode ficar replicado por alguns frames após o player
			-- levantar. Só considera sentado quando o assento confirma o Humanoid
			-- como Occupant ou existe SeatWeld válido ligado ao Character.
			if
				SeatPart
				and
				SeatPart.Parent
				and
				(
					SeatPart:IsA("Seat")
					or
					SeatPart:IsA("VehicleSeat")
				)
			then
				ActuallySeated =
					SeatPart.Occupant == Humanoid

				if
					not ActuallySeated
					and
					Character
				then
					local SeatWeld =
						SeatPart:FindFirstChild(
							"SeatWeld"
						)

					if
						SeatWeld
						and
						SeatWeld:IsA("Weld")
						and
						SeatWeld.Part1
						and
						SeatWeld.Part1:IsDescendantOf(
							Character
						)
					then
						ActuallySeated = true
					end
				end
			end

			if ActuallySeated then
				StateText =
					SeatPart:IsA(
						"VehicleSeat"
					)
					and
					"Em veículo"
					or
					"Sentado"

			elseif
				CurrentState
				==
				Enum.HumanoidStateType.Freefall
			then
				StateText =
					"No ar"

			elseif
				CurrentState
				==
				Enum.HumanoidStateType.Swimming
			then
				StateText =
					"Nadando"

			elseif
				Humanoid.MoveDirection.Magnitude
				>
				0.05
			then
				StateText =
					"Movendo"
			end
		end

		return
			Base
			..
			"\nVida: "
			..
			tostring(Health)
			..
			"/"
			..
			tostring(MaxHealth)
			..
			" | "
			..
			DistanceText
			..
			" studs"
			..
			"\n"
			..
			StateText
			..
			" | Tool: "
			..
			tostring(ToolName)
	end

	local function RemoveESP(Target)
		local Data =
			ESPObjects[Target]

		if not Data then
			return
		end

		-- Só destrói objetos criados pelo ESP.
		-- Character e Head são apenas referências ao alvo e NÃO podem ser destruídos.
		for _, Key in ipairs({
			"Highlight",
			"Billboard",
			"Label"
		}) do
			local Object =
				Data[Key]

			if
				typeof(Object) == "Instance"
			then
				pcall(function()
					Object:Destroy()
				end)
			end
		end

		ESPObjects[Target] =
			nil
	end

	local function CreateESP(Target)
		if
			not ESPShouldRender()
			or
			not Target
			or
			Target == Player
		then
			return
		end

		RemoveESP(Target)

		local Character =
			Target.Character

		local Head =
			Character
			and
			Character:FindFirstChild(
				"Head"
			)

		local Humanoid =
			Character
			and
			Character:FindFirstChildOfClass(
				"Humanoid"
			)

		if
			not Character
			or
			not Head
			or
			not Humanoid
		then
			return
		end

		local CurrentColor =
			GetESPColor(
				Target
			)

		local Highlight =
			New(
				"Highlight",
				{
					Name =
						"CartolaESP_"
						..
						tostring(
							Target.UserId
						),

					Adornee =
						Character,

					DepthMode =
						Enum.HighlightDepthMode.AlwaysOnTop,

					FillColor =
						CurrentColor,

					FillTransparency =
						ESPChams
						and
						0.30
						or
						ESPFillTransparency,

					OutlineColor =
						CurrentColor,

					OutlineTransparency =
						0
				},
				Character
			)

		local Billboard =
			New(
				"BillboardGui",
				{
					Name =
						"CartolaESPName_"
						..
						tostring(
							Target.UserId
						),

					Adornee =
						Head,

					AlwaysOnTop =
						true,

					Enabled =
						ESPShouldShowText(),

					Size =
						UDim2.fromOffset(
							360,
							92
						),

					StudsOffsetWorldSpace =
						Vector3.new(
							0,
							3.25,
							0
						),

					MaxDistance =
						100000,

					LightInfluence =
						0
				},
				Head
			)

		local InfoLabel =
			New(
				"TextLabel",
				{
					Size =
						UDim2.fromScale(
							1,
							1
						),

					BackgroundTransparency =
						1,

					Text =
						GetESPText(
							Target
						),

					TextColor3 =
						CurrentColor,

					TextStrokeColor3 =
						Color3.new(
							0,
							0,
							0
						),

					TextStrokeTransparency =
						0,

					Font =
						Enum.Font.GothamBold,

					TextSize =
						15,

					TextWrapped =
						true,

					TextXAlignment =
						Enum.TextXAlignment.Center,

					TextYAlignment =
						Enum.TextYAlignment.Top
				},
				Billboard
			)

		ESPObjects[Target] = {
			Highlight =
				Highlight,

			Billboard =
				Billboard,

			Label =
				InfoLabel,

			Character =
				Character,

			Head =
				Head
		}
	end

	local function UpdateESP(Target)
		if
			not ESPShouldRender()
			or
			not Target
			or
			Target == Player
		then
			RemoveESP(Target)
			return
		end

		local Character =
			Target.Character

		local Head =
			Character
			and
			Character:FindFirstChild(
				"Head"
			)

		local Humanoid =
			Character
			and
			Character:FindFirstChildOfClass(
				"Humanoid"
			)

		if
			not Character
			or
			not Head
			or
			not Humanoid
		then
			RemoveESP(Target)
			return
		end

		local Data =
			ESPObjects[Target]

		if
			not Data
			or
			not Data.Highlight
			or
			not Data.Highlight.Parent
			or
			Data.Character ~= Character
			or
			Data.Head ~= Head
			or
			not Data.Billboard
			or
			not Data.Billboard.Parent
		then
			CreateESP(Target)
			Data =
				ESPObjects[Target]
		end

		if not Data then
			return
		end

		local CurrentColor =
			GetESPColor(
				Target
			)

		Data.Highlight.Adornee =
			Character

		Data.Highlight.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop

		Data.Highlight.FillColor =
			CurrentColor

		Data.Highlight.OutlineColor =
			CurrentColor

		Data.Highlight.FillTransparency =
			ESPChams
			and
			0.30
			or
			ESPFillTransparency

		Data.Highlight.OutlineTransparency =
			0

		Data.Billboard.Adornee =
			Head

		Data.Billboard.Enabled =
			ESPShouldShowText()

		Data.Label.TextColor3 =
			CurrentColor

		Data.Label.Text =
			GetESPText(
				Target
			)
	end

	local function RefreshESP()
		if not ESPShouldRender() then
			local Removing = {}

			for Target in pairs(
				ESPObjects
			) do
				if
					typeof(Target)
					==
					"Instance"
					and
					Target:IsA(
						"Player"
					)
				then
					table.insert(
						Removing,
						Target
					)
				end
			end

			for _, Target in ipairs(
				Removing
			) do
				RemoveESP(
					Target
				)
			end

			return
		end

		for _, Target in ipairs(
			Players:GetPlayers()
		) do
			if Target ~= Player then
				UpdateESP(
					Target
				)
			end
		end
	end

	Toggle(
		Pages["Visual"],
		"ESP Players",
		false,
		function(Enabled)
			ESPEnabled =
				Enabled

			RefreshESP()
		end
	)

	Toggle(
		Pages["Visual"],
		"ESP Avançado",
		false,
		function(Enabled)
			ESPAdvanced =
				Enabled

			RefreshESP()
		end
	)

	Toggle(
		Pages["Visual"],
		"Chams",
		false,
		function(Enabled)
			ESPChams =
				Enabled

			RefreshESP()
		end
	)

	Slider(
		Pages["Visual"],
		"Transparência ESP",
		0,
		100,
		72,
		function(Value)
			ESPFillTransparency =
				math.clamp(
					Value / 100,
					0,
					1
				)

			RefreshESP()
		end
	)

	local ColorFrame =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						-8,
						0,
						56
					),

				BackgroundColor3 =
					Theme.Card,

				BorderSizePixel =
					0
			},
			Pages["Visual"]
		)

	Corner(
		ColorFrame,
		9
	)

	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					0.42,
					0,
					1,
					0
				),

			Position =
				UDim2.fromOffset(
					18,
					0
				),

			BackgroundTransparency =
				1,

			Text =
				"Cor do ESP",

			TextColor3 =
				Theme.Text,

			Font =
				Enum.Font.GothamMedium,

			TextSize =
				15,

			TextXAlignment =
				Enum.TextXAlignment.Left
		},
		ColorFrame
	)

	local ColorButton =
		New(
			"TextButton",
			{
				Size =
					UDim2.new(
						0.48,
						-20,
						0,
						38
					),

				Position =
					UDim2.new(
						0.52,
						5,
						0,
						9
					),

				BackgroundColor3 =
					Theme.Card2,

				BorderSizePixel =
					0,

				Text =
					"Azul",

				TextColor3 =
					Theme.Text,

				Font =
					Enum.Font.GothamBold,

				TextSize =
					13
			},
			ColorFrame
		)

	Corner(
		ColorButton,
		8
	)

	local ColorList =
		New(
			"ScrollingFrame",
			{
				Size =
					UDim2.new(
						1,
						-36,
						0,
						180
					),

				Position =
					UDim2.fromOffset(
						18,
						62
					),

				BackgroundColor3 =
					Color3.fromRGB(
						35,
						35,
						38
					),

				BorderSizePixel =
					0,

				ScrollBarThickness =
					3,

				ScrollBarImageColor3 =
					Theme.Accent,

				CanvasSize =
					UDim2.new(
						0,
						0,
						0,
						#ESPColorOptions * 39
					),

				Visible =
					false
			},
			Pages["Visual"]
		)

	Corner(
		ColorList,
		8
	)

	New(
		"UIListLayout",
		{
			Padding =
				UDim.new(
					0,
					4
				)
		},
		ColorList
	)

	local ColorOpened =
		false

	for _, Option in ipairs(
		ESPColorOptions
	) do
		local Button =
			New(
				"TextButton",
				{
					Size =
						UDim2.new(
							1,
							-5,
							0,
							35
						),

					BackgroundColor3 =
						Option[2],

					BorderSizePixel =
						0,

					Text =
						Option[1],

					TextColor3 =
						Theme.Text,

					Font =
						Enum.Font.GothamMedium,

					TextSize =
						13
				},
				ColorList
			)

		Corner(
			Button,
			7
		)

		Button.MouseButton1Click:Connect(function()
			ESPColor =
				Option[2]

			ColorButton.Text =
				Option[1]

			ColorOpened =
				false

			ColorList.Visible =
				false

			RefreshESP()
		end)
	end

	ColorButton.MouseButton1Click:Connect(function()
		ColorOpened =
			not ColorOpened

		ColorList.Visible =
			ColorOpened
	end)

	local LastRefresh =
		0

	local RefreshConnection =
		RunService.Heartbeat:Connect(function()
			if not ESPShouldRender() then
				return
			end

			local Now =
				os.clock()

			if
				Now - LastRefresh
				<
				0.30
			then
				return
			end

			LastRefresh =
				Now

			RefreshESP()
		end)

	Players.PlayerRemoving:Connect(function(Target)
		RemoveESP(
			Target
		)
	end)

	Gui.Destroying:Connect(function()
		if RefreshConnection then
			RefreshConnection:Disconnect()
		end

		local Removing = {}

		for Target in pairs(
			ESPObjects
		) do
			if
				typeof(Target)
				==
				"Instance"
				and
				Target:IsA(
					"Player"
				)
			then
				table.insert(
					Removing,
					Target
				)
			end
		end

		for _, Target in ipairs(
			Removing
		) do
			RemoveESP(
				Target
			)
		end
	end)
end

--============================================================
-- ESP TOOLS
--
-- Mostra Tools equipadas por outros players e Tools soltas no mapa.
-- É orientado a eventos: depois do scan inicial, não varre o Workspace
-- inteiro continuamente.
--============================================================

-- ESP Tools permanece dentro da mesma categoria ESP.

do
	local ToolESPEnabled =
		false

	local ToolESPObjects =
		{}

	local ToolESPAddedConnection =
		nil

	local ToolESPHeartbeat =
		nil

	local ToolESPLastUpdate =
		0

	local function RemoveToolESP(
		Tool
	)

		local Data =
			ToolESPObjects[
				Tool
			]

		if not Data then
			return
		end

		for _, Object in ipairs(
			Data
		) do

			if
				typeof(Object)
				==
				"Instance"
			then

				pcall(function()

					Object:Destroy()

				end)

			end

		end

		ToolESPObjects[
			Tool
		] =
			nil

	end

	local function ClearToolESP()

		local Tools =
			{}

		for Tool in pairs(
			ToolESPObjects
		) do

			table.insert(
				Tools,
				Tool
			)

		end

		for _, Tool in ipairs(
			Tools
		) do

			RemoveToolESP(
				Tool
			)

		end

	end

	local function GetToolPart(
		Tool
	)

		if
			not Tool
			or
			not Tool:IsA("Tool")
		then

			return nil

		end

		return
			Tool:FindFirstChild(
				"Handle"
			)
			or
			Tool:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

	end

	local function IsOwnTool(
		Tool
	)

		local Character =
			GetCharacter()

		return
			Character
			and
			Tool:IsDescendantOf(
				Character
			)

	end

	local function AddToolESP(
		Tool
	)

		if
			not ToolESPEnabled
			or
			not Tool
			or
			not Tool:IsA("Tool")
			or
			not Tool:IsDescendantOf(
				workspace
			)
			or
			IsOwnTool(
				Tool
			)
		then

			return

		end

		local Part =
			GetToolPart(
				Tool
			)

		if not Part then
			return
		end

		RemoveToolESP(
			Tool
		)

		local Highlight =
			New(
				"Highlight",
				{
					Name =
						"CartolaToolESP",

					DepthMode =
						Enum.HighlightDepthMode.AlwaysOnTop,

					FillColor =
						Theme.Accent,

					FillTransparency =
						0.72,

					OutlineColor =
						Theme.Accent,

					OutlineTransparency =
						0,

					-- Highlight não adorna Tool diretamente de forma confiável.
					-- O Handle/BasePart recebe o mesmo contorno do ESP de player.
					Adornee =
						Part
				},
				Tool
			)

		local Billboard =
			New(
				"BillboardGui",
				{
					Name =
						"CartolaToolESPName",

					Adornee =
						Part,

					AlwaysOnTop =
						true,

					Size =
						UDim2.fromOffset(
							240,
							34
						),

					StudsOffset =
						Vector3.new(
							0,
							1.8,
							0
						)
				},
				Part
			)

		local Label =
			New(
				"TextLabel",
				{
					Size =
						UDim2.fromScale(
							1,
							1
						),

					BackgroundTransparency =
						1,

					Text =
						Tool.Name,

					TextColor3 =
						Theme.Text,

					TextStrokeTransparency =
						0.25,

					Font =
						Enum.Font.GothamBold,

					TextSize =
						13
				},
				Billboard
			)

		ToolESPObjects[
			Tool
		] = {
			Highlight,
			Billboard,
			Label
		}

	end

	local function RefreshToolESP()

		if not ToolESPEnabled then

			ClearToolESP()

			return

		end

		local Root =
			GetRoot()

		local Removing =
			{}

		for Tool, Data in pairs(
			ToolESPObjects
		) do

			if
				not Tool
				or
				not Tool.Parent
				or
				not Tool:IsDescendantOf(
					workspace
				)
				or
				IsOwnTool(
					Tool
				)
			then

				table.insert(
					Removing,
					Tool
				)

			else

				local Part =
					GetToolPart(
						Tool
					)

				if
					not Part
					or
					not Part.Parent
				then

					table.insert(
						Removing,
						Tool
					)

				else

					local Billboard =
						Data[
							2
						]

					local Label =
						Data[
							3
						]

					if
						Billboard
						and
						Billboard.Parent
					then

						Billboard.Adornee =
							Part

					end

					if
						Label
						and
						Label.Parent
					then

						local DistanceText =
							""

						if Root then

							DistanceText =
								" | "
								..
								tostring(
									math.floor(
										(
											Part.Position
											-
											Root.Position
										).Magnitude
										+
										0.5
									)
								)
								..
								" studs"

						end

						Label.Text =
							Tool.Name
							..
							DistanceText

					end

				end

			end

		end

		for _, Tool in ipairs(
			Removing
		) do

			RemoveToolESP(
				Tool
			)

		end

	end

	local function ScanExistingTools()

		for _, Object in ipairs(
			workspace:GetDescendants()
		) do

			if Object:IsA("Tool") then

				AddToolESP(
					Object
				)

			end

		end

	end

	ToolESPAddedConnection =
		workspace.DescendantAdded:Connect(function(
			Object
		)

			if
				ToolESPEnabled
				and
				Object:IsA("Tool")
			then

				task.defer(
					AddToolESP,
					Object
				)

			end

		end)

	ToolESPHeartbeat =
		RunService.Heartbeat:Connect(function()

			if not ToolESPEnabled then
				return
			end

			local Now =
				os.clock()

			if
				Now
				-
				ToolESPLastUpdate
				<
				0.75
			then
				return
			end

			ToolESPLastUpdate =
				Now

			RefreshToolESP()

		end)

	Toggle(
		Pages["Visual"],
		"ESP Tools",
		false,
		function(Enabled)

			ToolESPEnabled =
				Enabled

			if Enabled then

				ScanExistingTools()

				RefreshToolESP()

			else

				ClearToolESP()

			end

		end
	)

	Gui.Destroying:Connect(function()

		ToolESPEnabled =
			false

		if ToolESPAddedConnection then

			ToolESPAddedConnection:Disconnect()

			ToolESPAddedConnection =
				nil

		end

		if ToolESPHeartbeat then

			ToolESPHeartbeat:Disconnect()

			ToolESPHeartbeat =
				nil

		end

		ClearToolESP()

	end)
end


pcall(function()
	if OP:FindFirstChild("CartolaFastBootStatus") then
		OP.CartolaFastBootStatus.Text = "Carregando proteções..."
	end
end)

task.wait()

--============================================================
-- PROTEÇÕES
--============================================================

Section(
	Pages["Protecoes"],
	"Proteções"
)

local ProtectionControllers = {}

Gui:SetAttribute("AntiBringPartsEnabled", false)

-- Queda natural centralizada.
-- Proteções de fling/TP/bring/ragdoll não devem disputar com a gravidade.
Gui:SetAttribute("NaturalFallActive", false)

RunService.Heartbeat:Connect(function()
	local Now =
		os.clock()

	local NextCheck =
		tonumber(
			Gui:GetAttribute(
				"NaturalFallNextCheck"
			)
		)
		or
		0

	if Now < NextCheck then
		return
	end

	Gui:SetAttribute(
		"NaturalFallNextCheck",
		Now + 0.05
	)

	local Humanoid = GetHumanoid()
	local Root = GetRoot()

	if
		not Humanoid
		or not Root
		or Humanoid.Health <= 0
	then
		Gui:SetAttribute("NaturalFallActive", false)
		return
	end

	local State =
		Humanoid:GetState()

	local Velocity =
		Root.AssemblyLinearVelocity

	local Horizontal =
		Vector3.new(
			Velocity.X,
			0,
			Velocity.Z
		).Magnitude

	local Angular =
		Root.AssemblyAngularVelocity.Magnitude

	local ConfiguredSpeed =
		tonumber(
			Gui:GetAttribute("CartolaWalkSpeed")
		)
		or
		16

	local NaturalFall =
		Humanoid.FloorMaterial == Enum.Material.Air
		and
		State == Enum.HumanoidStateType.Freefall
		and
		Velocity.Y < -6
		and
		Horizontal < math.max(38, ConfiguredSpeed * 1.25)
		and
		Angular < 14
		and
		not FlingRunning
		and
		not FlyEnabled
		and
		Gui:GetAttribute("CFrameFlyActive") ~= true
		and
		Gui:GetAttribute("VFlyActive") ~= true
		and
		Gui:GetAttribute("SwimActive") ~= true
		and
		Gui:GetAttribute("FlyFlingActive") ~= true
		and
		Gui:GetAttribute("SavedPositionTeleporting") ~= true

	Gui:SetAttribute(
		"NaturalFallActive",
		NaturalFall
	)
end)

-- Coordenação central entre proteções. Uma correção de posição feita por uma
-- proteção não deve ser interpretada pela proteção seguinte como um novo ataque.
local ProtectionBusyUntil = 0

local function BeginProtectionRecovery(Duration)
	ProtectionBusyUntil = math.max(ProtectionBusyUntil, os.clock() + (Duration or 0.22))
	Gui:SetAttribute("ProtectionRecoveryActive", true)
	task.delay((Duration or 0.22) + 0.03, function()
		if os.clock() >= ProtectionBusyUntil then
			Gui:SetAttribute("ProtectionRecoveryActive", false)
		end
	end)
end

local function ProtectionRecoveryBusy()
	return Gui:GetAttribute("ProtectionRecoveryActive") == true
		or os.clock() < ProtectionBusyUntil
end

local function WalkSpeedTransitionActive()
	local ChangedAt = tonumber(Gui:GetAttribute("CartolaWalkSpeedChangedAt")) or 0
	return ChangedAt > 0 and (os.clock() - ChangedAt) <= 0.65
end

local function IsHubMovementActive(Humanoid)
	return
		FlingRunning
		or FlyEnabled
		or Gui:GetAttribute("FlingRecoveryActive") == true
		or Gui:GetAttribute("FlyRecoveryActive") == true
		or Gui:GetAttribute("FlightExitRecoveryActive") == true
		or Gui:GetAttribute("NaturalFallActive") == true
		or Gui:GetAttribute("OrbitSelfActive") == true
		or Gui:GetAttribute("FollowBabycarActive") == true
		or Gui:GetAttribute("ImportedAriveActive") == true
		or Gui:GetAttribute("WalkFlingPulseActive") == true
		or Gui:GetAttribute("VehicleFlingActive") == true
		or Gui:GetAttribute("CFrameFlyActive") == true
		or Gui:GetAttribute("VFlyActive") == true
		or Gui:GetAttribute("SwimActive") == true
		or Gui:GetAttribute("FlyFlingActive") == true
		or Gui:GetAttribute("HeadSitActive") == true
		or Gui:GetAttribute("SeatPullActive") == true
		or Gui:GetAttribute("VehicleStealSeatActive") == true
		or Gui:GetAttribute("SavedPositionTeleporting") == true
		or Gui:GetAttribute("AntiFrontPullRecovering") == true
		or Gui:GetAttribute("DartTargetActive") == true
		or Gui:GetAttribute("LoopGotoActive") == true
		or Gui:GetAttribute("FoldingTableFollowActive") == true
		or Gui:GetAttribute("CartolaSpeedMovementActive") == true
		or WalkSpeedTransitionActive()
end

--============================================================
-- ANTI FLING + ANTI VEÍCULO
--
-- Proteção em camadas:
-- 1) detecta impulso horizontal/rotação/deslocamento anormal;
-- 2) guarda posição segura somente quando o personagem está estável;
-- 3) durante um impacto, trava por poucos frames na posição segura;
-- 4) veículos próximos e rápidos têm colisão/toque desligados
--    LOCALMENTE por um instante e depois são restaurados;
-- 5) ignora os movimentos do próprio Fling/WalkFling/Fly/VehicleFling.
--============================================================

local AntiDefense = {
	FlingConnection = nil,
	FlingVehicleAddedConnection = nil,
	FlingVehicleParts = {},
	FlingVehiclePropertyConnections = {},
	LastSafeCFrame = nil,
	LastPosition = nil,
	LastPositionTime = 0,
	RecoveryUntil = 0,
	ThreatUntil = 0,
	ThreatScanAt = 0,
	VehicleScanAt = 0,
	VehicleParts = {},
	PlayerCollisionParts = {},
	AntiSitConnections = {},
	SeatParts = {},
	SeatScanAt = 0,
	FlingGuardConnection = nil,
	FlingScanAt = 0,
	VehicleThreatUntil = 0,
	VehicleLastSelfPosition = nil,
	VehicleLastSelfTime = 0
}

local AntiFlingEnabled = false

local function RestoreAntiVehicleParts()

	for Part, Data in pairs(
		AntiDefense.VehicleParts
	) do

		if
			Part
			and
			Part.Parent
		then

			pcall(function()

				Part.CanCollide =
					Data.CanCollide

				Part.CanTouch =
					Data.CanTouch

			end)

		end

	end

	AntiDefense.VehicleParts = {}

end

AntiDefense.RestorePlayerCollisionParts = function()
	for Part,CanCollide in pairs(
		AntiDefense.PlayerCollisionParts
	) do
		if
			Part
			and
			Part.Parent
		then
			pcall(function()
				Part.CanCollide=
					CanCollide
			end)
		end
	end

	AntiDefense.PlayerCollisionParts={}
end

local function IsVehiclePart(Part)

	if
		not Part
		or
		not Part:IsA("BasePart")
	then
		return false
	end

	local Node =
		Part

	while
		Node
		and
		Node ~= workspace
	do

		if
			Node.Name
			and
			Node.Name:match(
				"^ltp2_car_%d+$"
			)
		then
			return true
		end

		if
			Node:IsA("Model")
			and
			Node:FindFirstChildWhichIsA(
				"VehicleSeat",
				true
			)
		then
			return true
		end

		Node =
			Node.Parent

	end

	return false
end


AntiDefense.DisableLTP2PartCollision = function(Part)

	if
		not Part
		or
		not Part:IsA("BasePart")
	then
		return
	end

	-- Se a peça já não colide e também não gera touch, ela não precisa
	-- entrar na proteção nem manter conexões extras.
	if
		AntiDefense.FlingVehicleParts[
			Part
		]
		==
		nil
		and
		not Part.CanCollide
		and
		not Part.CanTouch
	then
		return
	end

	if
		AntiDefense.FlingVehicleParts[
			Part
		]
		==
		nil
	then

		AntiDefense.FlingVehicleParts[
			Part
		] = {
			CanCollide = Part.CanCollide,
			CanTouch = Part.CanTouch
		}

		AntiDefense.FlingVehiclePropertyConnections[
			Part
		] = {
			Part:GetPropertyChangedSignal(
				"CanCollide"
			):Connect(function()

				if
					AntiFlingEnabled
					and
					Part
					and
					Part.Parent
					and
					Part.CanCollide
				then

					Part.CanCollide =
						false

				end

			end),

			Part:GetPropertyChangedSignal(
				"CanTouch"
			):Connect(function()

				if
					AntiFlingEnabled
					and
					Part
					and
					Part.Parent
					and
					Part.CanTouch
				then

					Part.CanTouch =
						false

				end

			end)
		}

	end

	pcall(function()

		if Part.CanCollide then
			Part.CanCollide = false
		end

		if Part.CanTouch then
			Part.CanTouch = false
		end

	end)

end

AntiDefense.IsCharacterPart = function(Part)

	if
		not Part
		or
		not Part:IsA("BasePart")
	then
		return false
	end

	local Model =
		Part:FindFirstAncestorOfClass(
			"Model"
		)

	return
		Model
		and
		Model:FindFirstChildOfClass(
			"Humanoid"
		)
		~=
		nil

end

AntiDefense.IsInsideCars = function(Object)

	local Node =
		Object

	while
		Node
		and
		Node ~= workspace
	do

		if Node.Name == "Cars" then
			return true
		end

		Node =
			Node.Parent

	end

	return false

end

AntiDefense.FindConnectedLTP2Root = function(Part)

	if
		not Part
		or
		not Part:IsA("BasePart")
	then
		return nil
	end

	local Connected =
		{}

	pcall(function()

		Connected =
			Part:GetConnectedParts(
				true
			)

	end)

	for _,Object in ipairs(
		Connected
	) do

		if
			Object
			and
			Object.Name
			and
			Object.Name:match(
				"^ltp2_car_%d+$"
			)
		then

			return Object

		end

	end

	return nil

end

AntiDefense.GetLTP2Container = function(Vehicle)

	if not Vehicle then
		return nil
	end

	-- Se o próprio marcador contém a estrutura do carro (CarBase,
	-- Collider, DriveSeat, rodas etc.), ele já é o container útil.
	if
		Vehicle:FindFirstChild(
			"CarBase",
			true
		)
		or
		Vehicle:FindFirstChild(
			"Collider",
			true
		)
		or
		Vehicle:FindFirstChild(
			"DriveSeat",
			true
		)
		or
		Vehicle:FindFirstChild(
			"Inertia",
			true
		)
	then
		return Vehicle
	end

	-- Caso o marcador esteja dentro de um Model do veículo, sobe até
	-- o primeiro Model antes do container global "Cars".
	local Node =
		Vehicle.Parent

	while
		Node
		and
		Node ~= workspace
	do

		if Node.Name == "Cars" then
			break
		end

		if Node:IsA("Model") then
			return Node
		end

		Node =
			Node.Parent
	end

	return nil

end

AntiDefense.DisableLTP2ContainerCollision = function(Container)

	if
		not Container
		or
		not Container.Parent
	then
		return
	end

	for _,Object in ipairs(
		Container:GetDescendants()
	) do

		if
			Object:IsA("BasePart")
			and
			not AntiDefense.IsCharacterPart(
				Object
			)
		then

			AntiDefense.DisableLTP2PartCollision(
				Object
			)

		end

	end

end

AntiDefense.DisableLTP2VehicleCollision = function(Vehicle)

	if
		not Vehicle
		or
		not Vehicle.Parent
	then
		return
	end

	-- 1) Marcador ltp2_car_XX.
	if Vehicle:IsA("BasePart") then

		AntiDefense.DisableLTP2PartCollision(
			Vehicle
		)

	end

	-- 2) Peças que pertencem diretamente à estrutura do marcador/model.
	for _,Object in ipairs(
		Vehicle:GetDescendants()
	) do

		if
			Object:IsA("BasePart")
			and
			not AntiDefense.IsCharacterPart(
				Object
			)
		then

			AntiDefense.DisableLTP2PartCollision(
				Object
			)

		end

	end

	-- 3) Assembly física conectada. Executado somente quando o veículo
	-- é descoberto/reprocessado, nunca em loop contínuo.
	if Vehicle:IsA("BasePart") then

		local Connected =
			{}

		pcall(function()

			Connected =
				Vehicle:GetConnectedParts(
					true
				)

		end)

		for _,Object in ipairs(
			Connected
		) do

			if
				Object:IsA("BasePart")
				and
				not AntiDefense.IsCharacterPart(
					Object
				)
			then

				AntiDefense.DisableLTP2PartCollision(
					Object
				)

			end

		end

	end

	-- 4) Um único container/model lógico do veículo, caso esteja fora
	-- da árvore direta do marcador.
	local Container =
		AntiDefense.GetLTP2Container(
			Vehicle
		)

	if
		Container
		and
		Container ~= Vehicle
	then

		AntiDefense.DisableLTP2ContainerCollision(
			Container
		)

	end

end

AntiDefense.FindLTP2Ancestor = function(Object)

	local Node =
		Object

	while
		Node
		and
		Node ~= workspace
	do

		if
			Node.Name
			and
			Node.Name:match(
				"^ltp2_car_%d+$"
			)
		then

			return Node

		end

		Node =
			Node.Parent

	end

	return nil

end

AntiDefense.RestoreLTP2VehicleCollisions = function()

	for Part,Connections in pairs(
		AntiDefense.FlingVehiclePropertyConnections
	) do

		for _,Connection in pairs(
			Connections
		) do

			pcall(function()
				Connection:Disconnect()
			end)

		end

	end

	AntiDefense.FlingVehiclePropertyConnections =
		{}

	for Part,Data in pairs(
		AntiDefense.FlingVehicleParts
	) do

		if
			Part
			and
			Part.Parent
		then

			pcall(function()

				Part.CanCollide =
					Data.CanCollide

				Part.CanTouch =
					Data.CanTouch

			end)

		end

	end

	AntiDefense.FlingVehicleParts =
		{}

end

local function ClearAllCharacterPhysics()

	local Character =
		GetCharacter()

	if not Character then
		return
	end

	for _, Object in ipairs(
		Character:GetDescendants()
	) do

		if Object:IsA("BasePart") then

			Object.AssemblyLinearVelocity =
				Vector3.zero

			Object.AssemblyAngularVelocity =
				Vector3.zero

			Object.Velocity =
				Vector3.zero

		end

	end

end

local function StopAntiFling()

	AntiFlingEnabled =
		false

	if AntiDefense.FlingConnection then
		AntiDefense.FlingConnection:Disconnect()

		AntiDefense.FlingConnection =
			nil
	end

	if AntiDefense.FlingGuardConnection then
		AntiDefense.FlingGuardConnection:Disconnect()
		AntiDefense.FlingGuardConnection = nil
	end

	if AntiDefense.FlingVehicleAddedConnection then
		AntiDefense.FlingVehicleAddedConnection:Disconnect()
		AntiDefense.FlingVehicleAddedConnection = nil
	end

	AntiDefense.RestoreLTP2VehicleCollisions()

	AntiDefense.RecoveryUntil = 0
	AntiDefense.LastPosition = nil
	AntiDefense.LastPositionTime = 0

	-- O Infinite Yield apenas desconecta. Aqui restauramos CanCollide
	-- ao desligar para o toggle realmente voltar ao estado anterior.
	AntiDefense.RestorePlayerCollisionParts()

end

local function StartAntiFling()

	StopAntiFling()

	AntiFlingEnabled =
		true

	AntiDefense.FlingScanAt = 0

	local InitialRoot =
		GetRoot()

	if InitialRoot then
		AntiDefense.LastSafeCFrame = InitialRoot.CFrame
		AntiDefense.LastPosition = InitialRoot.Position
		AntiDefense.LastPositionTime = os.clock()
	end

	AntiDefense.RecoveryUntil = 0

	-- Todos os veículos ltp2_car_XX ficam sem colisão/toque localmente.
	-- O marcador pode ser uma Part massless cuja AssemblyRootPart é Body/Inertia.
	-- O veículo é descoberto uma vez; só BaseParts com CanCollide/CanTouch
	-- ativos entram na proteção. Depois, sinais de propriedade impedem que
	-- o jogo religue a colisão sem precisar percorrer todas as peças em loop.
	for _,Object in ipairs(
		workspace:GetDescendants()
	) do

		if
			Object.Name
			and
			Object.Name:match(
				"^ltp2_car_%d+$"
			)
		then

			AntiDefense.DisableLTP2VehicleCollision(
				Object
			)

		end

	end

	-- Depois da varredura inicial, só reage ao que for adicionado.
	AntiDefense.FlingVehicleAddedConnection =
		workspace.DescendantAdded:Connect(function(
			Object
		)

			if not AntiFlingEnabled then
				return
			end

			if
				Object.Name
				and
				Object.Name:match(
					"^ltp2_car_%d+$"
				)
			then

				task.defer(
					AntiDefense.DisableLTP2VehicleCollision,
					Object
				)

				task.delay(0.25,function()
					if
						AntiFlingEnabled
						and
						Object
						and
						Object.Parent
					then
						AntiDefense.DisableLTP2VehicleCollision(
							Object
						)
					end
				end)

				task.delay(0.8,function()
					if
						AntiFlingEnabled
						and
						Object
						and
						Object.Parent
					then
						AntiDefense.DisableLTP2VehicleCollision(
							Object
						)
					end
				end)

				return
			end

			if
				Object:IsA("BasePart")
				and
				AntiDefense.IsInsideCars(
					Object
				)
			then

				task.defer(function()

					if not AntiFlingEnabled then
						return
					end

					local Vehicle =
						AntiDefense.FindLTP2Ancestor(
							Object
						)
						or
						AntiDefense.FindConnectedLTP2Root(
							Object
						)

					if Vehicle then

						AntiDefense.DisableLTP2PartCollision(
							Object
						)

					end

				end)

			end

		end)

	-- AntiFling do Infinite Yield:
	-- desativa localmente a colisão das BaseParts dos outros players.
	AntiDefense.FlingConnection =
		RunService.Stepped:Connect(function()

			if not AntiFlingEnabled then
				return
			end

			if
				os.clock()
				<
				(
					AntiDefense.FlingScanAt
					or
					0
				)
			then
				return
			end

			AntiDefense.FlingScanAt =
				os.clock() + 0.12


			for _, OtherPlayer in pairs(
				Players:GetPlayers()
			) do

				if
					OtherPlayer ~= Player
					and
					OtherPlayer.Character
				then

					for _, Part in pairs(
						OtherPlayer.Character:GetDescendants()
					) do

						if Part:IsA("BasePart") then

							if
								AntiDefense.PlayerCollisionParts[Part]
								==
								nil
							then
								AntiDefense.PlayerCollisionParts[Part] =
									Part.CanCollide
							end

							Part.CanCollide =
								false

						end

					end

				end

			end

		end)


	-- Segunda camada: se algum impulso físico passar pela colisão local,
	-- recupera a última posição estável. Não interfere com movimentos
	-- intencionais do próprio hub.
	AntiDefense.FlingGuardConnection =
		RunService.Heartbeat:Connect(function()

			if not AntiFlingEnabled then
				return
			end

			local Root =
				GetRoot()

			local Humanoid =
				GetHumanoid()

			if
				not Root
				or
				not Humanoid
				or
				Humanoid.Health <= 0
			then
				return
			end

			local Now =
				os.clock()

			local OwnMovement =
				IsHubMovementActive(
					Humanoid
				)
				or
				ProtectionRecoveryBusy()

			local Linear =
				Root.AssemblyLinearVelocity

			local Horizontal =
				Vector3.new(
					Linear.X,
					0,
					Linear.Z
				).Magnitude

			local Angular =
				Root.AssemblyAngularVelocity.Magnitude

			local ConfiguredWalkSpeed =
				tonumber(
					Gui:GetAttribute(
						"CartolaWalkSpeed"
					)
				)
				or
				Humanoid.WalkSpeed
				or
				16

			local ExpectedWalkSpeed =
				math.max(
					16,
					Humanoid.WalkSpeed,
					ConfiguredWalkSpeed
				)

			local SuddenMove =
				false

			if
				AntiDefense.LastPosition
				and
				AntiDefense.LastPositionTime > 0
			then

				local Dt =
					Now
					-
					AntiDefense.LastPositionTime

				if
					Dt > 0
					and
					Dt <= 0.25
				then

					local Delta =
						Root.Position
						-
						AntiDefense.LastPosition

					local ExpectedTravel =
						ExpectedWalkSpeed
						*
						Dt

					if
						Delta.Magnitude
						>=
						math.max(
							18,
							ExpectedTravel * 2.8 + 8
						)
						or
						Delta.Y <= -12
					then

						SuddenMove =
							true

					end

				end

			end

			if OwnMovement then

				AntiDefense.LastSafeCFrame =
					Root.CFrame

				AntiDefense.RecoveryUntil =
					0

			elseif
				Now
				<
				(
					AntiDefense.RecoveryUntil
					or
					0
				)
			then

				ClearAllCharacterPhysics()

				Humanoid.Sit =
					false

				Humanoid.PlatformStand =
					false

				if AntiDefense.LastSafeCFrame then

					Root.CFrame =
						AntiDefense.LastSafeCFrame
						+
						Vector3.new(
							0,
							2,
							0
						)

				end

			else

				local AbnormalPhysics =
					Horizontal
					>
					math.max(
						75,
						ExpectedWalkSpeed * 1.65 + 30
					)
					or
					Linear.Magnitude
					>
					math.max(
						125,
						ExpectedWalkSpeed * 1.8 + 55
					)
					or
					Angular > 45
					or
					Linear.Y < -170
					or
					SuddenMove

				if AbnormalPhysics then

					BeginProtectionRecovery(
						0.42
					)

					AntiDefense.RecoveryUntil =
						Now + 0.38

					ClearAllCharacterPhysics()

					Humanoid.Sit =
						false

					Humanoid.PlatformStand =
						false

					if AntiDefense.LastSafeCFrame then

						Root.CFrame =
							AntiDefense.LastSafeCFrame
							+
							Vector3.new(
								0,
								2,
								0
							)

					end

				elseif
					Humanoid.FloorMaterial
					~=
					Enum.Material.Air
					and
					not Humanoid.Sit
					and
					not Humanoid.SeatPart
					and
					Horizontal
					<
					math.max(
						45,
						ExpectedWalkSpeed * 1.3 + 15
					)
					and
					math.abs(Linear.Y) < 55
					and
					Angular < 15
				then

					AntiDefense.LastSafeCFrame =
						Root.CFrame

				end

			end

			AntiDefense.LastPosition =
				Root.Position

			AntiDefense.LastPositionTime =
				Now

		end)

end

ProtectionControllers.AntiFling = function(Enabled)

	if Enabled then

		StartAntiFling()

	else

		StopAntiFling()

	end

end

--============================================================
-- ANTI SIT - BLOQUEIO PROATIVO
--
-- O problema anterior era reagir depois que SeatPart/Sit já tinham mudado.
-- Agora os Seat/VehicleSeat são neutralizados localmente ANTES do contato e
-- qualquer SeatWeld criado para o personagem local é destruído no ChildAdded.
--
-- Anti Sit normal:
--   • desativa o estado Seated;
--   • Disabled=true / CanTouch=false nos assentos locais;
--   • destrói SeatWeld do personagem local assim que ele aparece;
--   • não usa loop de CFrame/velocidade.
--
-- Anti Sit V2:
--   • usa tudo acima;
--   • acrescenta uma checagem PreSimulation somente de Sit/SeatPart/Seated;
--   • SeatWeld continua bloqueado imediatamente pelos eventos DescendantAdded,
--     sem varrer o Character inteiro a cada frame.
--============================================================

do
	local AntiSitEnabled=false
	local DisconnectAntiSit
	local BindAntiSit

	Gui:SetAttribute(
		"AntiSitV2Enabled",
		false
	)

	AntiDefense.AntiSitRuntime = {
		V2Enabled = false,
		SeatBackup = {},
		SeatConnections = {},
		WorkspaceConnections = {},
		V2Connection = nil,
		ScanToken = 0,
		ScanRunning = false
	}

	local function IsSeatObject(Object)
		return
			Object
			and
			(
				Object:IsA("Seat")
				or
				Object:IsA("VehicleSeat")
			)
	end

	local function IsSeatPullExempt(Seat)
		if
			Gui:GetAttribute(
				"SeatPullActive"
			)
			~=
			true
		then
			return false
		end

		local Ref =
			Gui:FindFirstChild(
				"CartolaSeatPullSeat"
			)

		return
			Ref
			and
			Ref:IsA(
				"ObjectValue"
			)
			and
			Ref.Value == Seat
	end

	local function AntiSitShouldBlock()
		return
			AntiSitEnabled
			or
			AntiDefense.AntiSitRuntime.V2Enabled
	end

	local function ApplyAntiSitState(Humanoid)
		if not Humanoid then
			return
		end

		pcall(function()
			Humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Seated,
				not AntiSitShouldBlock()
			)
		end)
	end

	local function SeatWeldUsesLocalCharacter(Object)
		if
			not Object
			or
			(
				not Object:IsA("Weld")
				and
				not Object:IsA("WeldConstraint")
			)
		then
			return false
		end

		local Character =
			GetCharacter()

		if not Character then
			return false
		end

		local Part0 =
			nil

		local Part1 =
			nil

		pcall(function()
			Part0 =
				Object.Part0

			Part1 =
				Object.Part1
		end)

		return
			(
				Part0
				and
				Part0:IsDescendantOf(
					Character
				)
			)
			or
			(
				Part1
				and
				Part1:IsDescendantOf(
					Character
				)
			)
	end

	local function DestroySeatWeldObject(Object)
		if
			not AntiSitShouldBlock()
			or
			not Object
			or
			Object.Name ~= "SeatWeld"
		then
			return
		end

		if
			SeatWeldUsesLocalCharacter(
				Object
			)
		then
			pcall(function()
				Object:Destroy()
			end)
		end
	end

	local function DestroySeatWelds(Seat)
		if Seat and Seat.Parent then
			for _, Object in ipairs(
				Seat:GetDescendants()
			) do
				if Object.Name == "SeatWeld" then
					DestroySeatWeldObject(
						Object
					)
				end
			end
		end

		local Character =
			GetCharacter()

		if Character then
			for _, Object in ipairs(
				Character:GetDescendants()
			) do
				if Object.Name == "SeatWeld" then
					DestroySeatWeldObject(
						Object
					)
				end
			end
		end
	end

	local function RestoreSeat(Seat)
		local Runtime =
			AntiDefense.AntiSitRuntime

		local Data =
			Runtime.SeatBackup[Seat]

		if not Data then
			return
		end

		Runtime.SeatBackup[Seat] =
			nil

		local Connections =
			Runtime.SeatConnections[Seat]

		if Connections then
			for _, Connection in ipairs(
				Connections
			) do
				pcall(function()
					Connection:Disconnect()
				end)
			end
		end

		Runtime.SeatConnections[Seat] =
			nil

		if
			Seat
			and
			Seat.Parent
		then
			pcall(function()
				Seat.Disabled =
					Data.Disabled

				Seat.CanTouch =
					Data.CanTouch
			end)
		end
	end

	local function NeutralizeSeat(Seat)
		if
			not AntiSitShouldBlock()
			or
			not IsSeatObject(
				Seat
			)
		then
			return
		end

		if IsSeatPullExempt(Seat) then
			RestoreSeat(
				Seat
			)

			return
		end

		local Runtime =
			AntiDefense.AntiSitRuntime

		if not Runtime.SeatBackup[Seat] then
			Runtime.SeatBackup[Seat] = {
				Disabled =
					Seat.Disabled,

				CanTouch =
					Seat.CanTouch
			}

			Runtime.SeatConnections[Seat] = {}

			table.insert(
				Runtime.SeatConnections[Seat],
				Seat:GetPropertyChangedSignal(
					"Disabled"
				):Connect(function()
					if
						AntiSitShouldBlock()
						and
						Seat.Parent
						and
						not IsSeatPullExempt(
							Seat
						)
						and
						not Seat.Disabled
					then
						pcall(function()
							Seat.Disabled =
								true
						end)
					end
				end)
			)

			table.insert(
				Runtime.SeatConnections[Seat],
				Seat:GetPropertyChangedSignal(
					"CanTouch"
				):Connect(function()
					if
						AntiSitShouldBlock()
						and
						Seat.Parent
						and
						not IsSeatPullExempt(
							Seat
						)
						and
						Seat.CanTouch
					then
						pcall(function()
							Seat.CanTouch =
								false
						end)
					end
				end)
			)

			table.insert(
				Runtime.SeatConnections[Seat],
				Seat.ChildAdded:Connect(function(Object)
					if
						AntiSitShouldBlock()
						and
						Object.Name == "SeatWeld"
					then
						DestroySeatWeldObject(
							Object
						)
					end
				end)
			)
		end

		pcall(function()
			Seat.Disabled =
				true

			Seat.CanTouch =
				false
		end)

		DestroySeatWelds(
			Seat
		)
	end

	local function RestoreAllSeats()
		local Runtime =
			AntiDefense.AntiSitRuntime

		local Seats = {}

		for Seat in pairs(
			Runtime.SeatBackup
		) do
			table.insert(
				Seats,
				Seat
			)
		end

		for _, Seat in ipairs(
			Seats
		) do
			RestoreSeat(
				Seat
			)
		end
	end

	local function GuardAllSeats()
		if not AntiSitShouldBlock() then
			return
		end

		local Runtime =
			AntiDefense.AntiSitRuntime

		Runtime.ScanToken +=
			1

		local ThisToken =
			Runtime.ScanToken

		Runtime.ScanRunning =
			true

		task.spawn(function()
			-- Percorre a árvore em lotes e distribui o trabalho
			-- entre vários frames, evitando o pico ao ligar.
			local Queue =
				workspace:GetChildren()

			local Index =
				1

			local ProcessedThisFrame =
				0

			while
				Index <= #Queue
				and
				AntiSitShouldBlock()
				and
				ThisToken == Runtime.ScanToken
			do
				local Object =
					Queue[Index]

				Index +=
					1

				if
					Object
					and
					Object.Parent
				then
					if IsSeatObject(Object) then
						NeutralizeSeat(
							Object
						)
					end

					local Children =
						Object:GetChildren()

					for _,Child in ipairs(
						Children
					) do
						table.insert(
							Queue,
							Child
						)
					end
				end

				ProcessedThisFrame +=
					1

				if ProcessedThisFrame >= 180 then
					ProcessedThisFrame =
						0

					RunService.Heartbeat:Wait()
				end
			end

			if ThisToken == Runtime.ScanToken then
				Runtime.ScanRunning =
					false
			end
		end)
	end

	local function RejectSeatNow(
		Humanoid,
		Seat
	)
		if
			not AntiSitShouldBlock()
			or
			not Humanoid
			or
			Humanoid.Health <= 0
		then
			return
		end

		if IsSeatObject(Seat) then
			NeutralizeSeat(
				Seat
			)

			DestroySeatWelds(
				Seat
			)
		else
			DestroySeatWelds(
				nil
			)
		end

		pcall(function()
			Humanoid.Sit =
				false

			Humanoid.PlatformStand =
				false

			Humanoid.AutoRotate =
				true
		end)

		if
			Humanoid:GetState()
			==
			Enum.HumanoidStateType.Seated
		then
			pcall(function()
				if
					Humanoid.FloorMaterial
					==
					Enum.Material.Air
				then
					Humanoid:ChangeState(
						Enum.HumanoidStateType.Freefall
					)
				else
					Humanoid:ChangeState(
						Enum.HumanoidStateType.Running
					)
				end
			end)
		end
	end

	local function DisconnectHumanoidAntiSit()
		for _, Connection in ipairs(
			AntiDefense.AntiSitConnections
		) do
			pcall(function()
				Connection:Disconnect()
			end)
		end

		AntiDefense.AntiSitConnections =
			{}
	end

	local function StartSeatGuard()
		local Runtime =
			AntiDefense.AntiSitRuntime

		-- Instala os eventos primeiro. Assim novos Seat/VehicleSeat e
		-- SeatWeld já ficam bloqueados enquanto o scan inicial ocorre.
		if #Runtime.WorkspaceConnections == 0 then
			table.insert(
				Runtime.WorkspaceConnections,
				workspace.DescendantAdded:Connect(function(Object)
					if not AntiSitShouldBlock() then
						return
					end

					if IsSeatObject(Object) then
						NeutralizeSeat(
							Object
						)

					elseif
						Object.Name
						==
						"SeatWeld"
					then
						DestroySeatWeldObject(
							Object
						)
					end
				end)
			)

			table.insert(
				Runtime.WorkspaceConnections,
				Gui:GetAttributeChangedSignal(
					"SeatPullActive"
				):Connect(function()
					if AntiSitShouldBlock() then
						GuardAllSeats()
					end
				end)
			)
		end

		-- Uma nova chamada invalida o scan anterior pelo ScanToken,
		-- evitando varreduras simultâneas.
		GuardAllSeats()
	end

	local function StopSeatGuard()
		local Runtime =
			AntiDefense.AntiSitRuntime

		Runtime.ScanToken +=
			1

		Runtime.ScanRunning =
			false

		for _, Connection in ipairs(
			Runtime.WorkspaceConnections
		) do
			pcall(function()
				Connection:Disconnect()
			end)
		end

		Runtime.WorkspaceConnections =
			{}

		RestoreAllSeats()
	end

	BindAntiSit = function()
		DisconnectHumanoidAntiSit()

		local Humanoid =
			GetHumanoid()

		local Character =
			GetCharacter()

		if not Humanoid then
			return
		end

		ApplyAntiSitState(
			Humanoid
		)

		if not AntiSitShouldBlock() then
			return
		end

		StartSeatGuard()

		table.insert(
			AntiDefense.AntiSitConnections,
			Humanoid.Seated:Connect(function(
				Active,
				SeatPart
			)
				if Active then
					RejectSeatNow(
						Humanoid,
						SeatPart
					)
				end
			end)
		)

		table.insert(
			AntiDefense.AntiSitConnections,
			Humanoid:GetPropertyChangedSignal(
				"SeatPart"
			):Connect(function()
				if Humanoid.SeatPart then
					RejectSeatNow(
						Humanoid,
						Humanoid.SeatPart
					)
				end
			end)
		)

		table.insert(
			AntiDefense.AntiSitConnections,
			Humanoid:GetPropertyChangedSignal(
				"Sit"
			):Connect(function()
				if Humanoid.Sit then
					RejectSeatNow(
						Humanoid,
						Humanoid.SeatPart
					)
				end
			end)
		)

		table.insert(
			AntiDefense.AntiSitConnections,
			Humanoid.StateChanged:Connect(function(
				_,
				NewState
			)
				if
					NewState
					==
					Enum.HumanoidStateType.Seated
				then
					RejectSeatNow(
						Humanoid,
						Humanoid.SeatPart
					)
				end
			end)
		)

		if Character then
			table.insert(
				AntiDefense.AntiSitConnections,
				Character.DescendantAdded:Connect(function(Object)
					if
						Object.Name
						==
						"SeatWeld"
					then
						DestroySeatWeldObject(
							Object
						)
					end
				end)
			)
		end
	end

	DisconnectAntiSit = function()
		DisconnectHumanoidAntiSit()

		if not AntiSitShouldBlock() then
			StopSeatGuard()
		end

		local Humanoid =
			GetHumanoid()

		ApplyAntiSitState(
			Humanoid
		)

		if
			Humanoid
			and
			not AntiSitShouldBlock()
		then
			pcall(function()
				Humanoid.PlatformStand =
					false

				Humanoid.AutoRotate =
					true
			end)
		end
	end

	ProtectionControllers.AntiSit = function(Enabled)
		AntiSitEnabled =
			Enabled == true

		if AntiSitEnabled then
			StartSeatGuard()
			BindAntiSit()
		else
			if
				AntiDefense.AntiSitRuntime.V2Enabled
			then
				BindAntiSit()
			else
				DisconnectAntiSit()
			end
		end
	end

	--============================================================
	-- ANTI SIT V2 - BLOQUEIO MÁXIMO SEM ALTERAR CFRAME/VELOCIDADE
	--============================================================

	do
		local function StopV2Connection()
			local Runtime =
				AntiDefense.AntiSitRuntime

			if Runtime.V2Connection then
				Runtime.V2Connection:Disconnect()
				Runtime.V2Connection =
					nil
			end
		end

		local function Stop()
			local Runtime =
				AntiDefense.AntiSitRuntime

			Runtime.V2Enabled =
				false

			Gui:SetAttribute(
				"AntiSitV2Enabled",
				false
			)

			StopV2Connection()

			if AntiSitEnabled then
				BindAntiSit()
			else
				DisconnectAntiSit()
			end
		end

		local function Start()
			local Runtime =
				AntiDefense.AntiSitRuntime

			StopV2Connection()

			Runtime.V2Enabled =
				true

			Gui:SetAttribute(
				"AntiSitV2Enabled",
				true
			)

			StartSeatGuard()
			BindAntiSit()

			Runtime.V2Connection =
				RunService.PreSimulation:Connect(function()
					if
						not Runtime.V2Enabled
					then
						return
					end

					local Humanoid =
						GetHumanoid()

					if
						not Humanoid
						or
						Humanoid.Health <= 0
					then
						return
					end

					if
						Humanoid.Sit
						or
						Humanoid.SeatPart
						or
						Humanoid:GetState()
						==
						Enum.HumanoidStateType.Seated
					then
						RejectSeatNow(
							Humanoid,
							Humanoid.SeatPart
						)
					end
				end)
		end

		ProtectionControllers.AntiSitV2 = function(State)
			if State then
				Start()
			else
				Stop()
			end
		end

		Player.CharacterAdded:Connect(function()
			if
				AntiSitEnabled
				or
				AntiDefense.AntiSitRuntime.V2Enabled
			then
				task.defer(
					BindAntiSit
				)
			end
		end)

		Gui.Destroying:Connect(function()
			AntiSitEnabled =
				false

			AntiDefense.AntiSitRuntime.V2Enabled =
				false

			Gui:SetAttribute(
				"AntiSitV2Enabled",
				false
			)

			StopV2Connection()
			DisconnectHumanoidAntiSit()
			StopSeatGuard()
		end)
	end
end

--============================================================
-- ANTI SEAT PULL - SOMENTE PUXÃO SUSPEITO
--
-- Não funciona como um segundo Anti Sit.
-- Primeiro detecta um deslocamento brusco; somente se uma tentativa de
-- sentar aparecer logo depois ele desfaz o SeatWeld e volta à posição segura.
--============================================================

do
	local Enabled=false
	local Connections={}
	local SafeCFrame=nil
	local LastPosition=nil
	local PullSafeCFrame=nil
	local PullWindowUntil=0
	local Recovering=false

	local function DisconnectAll()
		for _,Connection in ipairs(Connections) do
			pcall(function()
				Connection:Disconnect()
			end)
		end

		Connections={}
	end

	local function IsHubSeatMovement()
		return
			Gui:GetAttribute("HeadSitActive")
			or
			Gui:GetAttribute("VFlyActive")
			or
			Gui:GetAttribute("SeatPullActive")
			or
			Gui:GetAttribute("VehicleStealSeatActive")
	end

	local function IsHubIntentionalMovement()
		return
			IsHubMovementActive(
				GetHumanoid()
			)
			or
			ProtectionRecoveryBusy()
	end

	local function ThreatWindowActive()
		return
			PullSafeCFrame~=nil
			and
			os.clock()<PullWindowUntil
	end

	-- Alguns seat-pulls teleportam e sentam no mesmo frame, antes do Heartbeat
	-- ter tempo de abrir a janela de ameaça. Nessa situação comparamos a posição
	-- atual com o último CFrame seguro no próprio evento de sentar.
	local function ArmThreatFromCurrentDisplacement()
		if ThreatWindowActive() then
			return true
		end

		if
			IsHubSeatMovement()
			or
			IsHubIntentionalMovement()
		then
			return false
		end

		local Root=GetRoot()

		if
			not Root
			or
			not SafeCFrame
		then
			return false
		end

		if
			(
				Root.Position
				-
				SafeCFrame.Position
			).Magnitude
			<
			10
		then
			return false
		end

		PullSafeCFrame=SafeCFrame
		PullWindowUntil=os.clock()+0.85
		return true
	end

	local function RemoveSeatWelds(Character,Seat)
		if not Character then
			return
		end

		local function RemoveIfSeatWeld(Object)
			if
				Object
				and
				Object.Name=="SeatWeld"
				and
				(
					Object:IsA("Weld")
					or
					Object:IsA("WeldConstraint")
				)
			then
				pcall(function()
					Object:Destroy()
				end)
			end
		end

		-- Welds forçados por scripts podem aparecer dentro do personagem.
		for _,Object in ipairs(
			Character:GetDescendants()
		) do
			RemoveIfSeatWeld(Object)
		end

		-- O SeatWeld nativo do Roblox normalmente fica dentro do próprio assento.
		if Seat and Seat.Parent then
			for _,Object in ipairs(
				Seat:GetChildren()
			) do
				RemoveIfSeatWeld(Object)
			end
		end
	end

	local function RecoverFromSeatPull(Seat)
		if
			not Enabled
			or
			Recovering
			or
			IsHubSeatMovement()
			or
			not ThreatWindowActive()
		then
			return
		end

		local Character=GetCharacter()
		local Humanoid=GetHumanoid()
		local Root=GetRoot()

		if
			not Character
			or
			not Humanoid
			or
			not Root
			or
			Humanoid.Health<=0
		then
			return
		end

		Recovering=true
		BeginProtectionRecovery(0.20)

		local ReturnCFrame=PullSafeCFrame

		RemoveSeatWelds(Character,Seat)

		pcall(function()
			Humanoid.Sit=false
			Humanoid.PlatformStand=false
			Humanoid.AutoRotate=true
			Root.AssemblyLinearVelocity=Vector3.zero
			Root.AssemblyAngularVelocity=Vector3.zero
		end)

		if ReturnCFrame then
			pcall(function()
				Character:PivotTo(ReturnCFrame)
				Root.AssemblyLinearVelocity=Vector3.zero
				Root.AssemblyAngularVelocity=Vector3.zero
			end)
		end

		PullSafeCFrame=nil
		PullWindowUntil=0

		task.delay(0.12,function()
			local CurrentRoot=GetRoot()

			if CurrentRoot then
				SafeCFrame=CurrentRoot.CFrame
				LastPosition=CurrentRoot.Position
			end

			Recovering=false
		end)
	end

	local function BindCharacter(Character)
		if
			not Enabled
			or
			not Character
		then
			return
		end

		local Humanoid=
			Character:FindFirstChildOfClass("Humanoid")
			or
			Character:WaitForChild(
				"Humanoid",
				8
			)

		local Root=
			Character:FindFirstChild("HumanoidRootPart")
			or
			Character:WaitForChild(
				"HumanoidRootPart",
				8
			)

		if
			not Humanoid
			or
			not Root
		then
			return
		end

		SafeCFrame=Root.CFrame
		LastPosition=Root.Position
		PullSafeCFrame=nil
		PullWindowUntil=0

		table.insert(
			Connections,
			Humanoid.Seated:Connect(function(
				Active,
				SeatPart
			)
				if
					Enabled
					and
					Active
					and
					(
						ThreatWindowActive()
						or
						ArmThreatFromCurrentDisplacement()
					)
				then
					RecoverFromSeatPull(
						SeatPart
					)
				end
			end)
		)

		table.insert(
			Connections,
			Humanoid:GetPropertyChangedSignal(
				"SeatPart"
			):Connect(function()
				if
					Enabled
					and
					Humanoid.SeatPart
					and
					(
						ThreatWindowActive()
						or
						ArmThreatFromCurrentDisplacement()
					)
				then
					RecoverFromSeatPull(
						Humanoid.SeatPart
					)
				end
			end)
		)

		table.insert(
			Connections,
			Character.DescendantAdded:Connect(function(
				Object
			)
				if
					not Enabled
					or
					(
						not ThreatWindowActive()
						and
						not ArmThreatFromCurrentDisplacement()
					)
				then
					return
				end

				if
					Object.Name=="SeatWeld"
					and
					(
						Object:IsA("Weld")
						or
						Object:IsA("WeldConstraint")
					)
				then
					task.defer(function()
						if
							Enabled
							and
							ThreatWindowActive()
						then
							RecoverFromSeatPull(
								Humanoid.SeatPart
							)
						end
					end)
				end
			end)
		)
	end

	local function Stop()
		Enabled=false
		DisconnectAll()

		SafeCFrame=nil
		LastPosition=nil
		PullSafeCFrame=nil
		PullWindowUntil=0
		Recovering=false
	end

	local function Start()
		Stop()

		Enabled=true

		BindCharacter(
			GetCharacter()
		)

		local NextMovementCheck =
			0

		table.insert(
			Connections,
			Player.CharacterAdded:Connect(function(Character)
				if Enabled then
					task.defer(
						BindCharacter,
						Character
					)
				end
			end)
		)

		table.insert(
			Connections,
			RunService.Heartbeat:Connect(function()
				if
					not Enabled
					or
					Recovering
					or
					IsHubSeatMovement()
				then
					return
				end

				local Now =
					os.clock()

				if Now < NextMovementCheck then
					return
				end

				NextMovementCheck =
					Now + 0.05

				local Humanoid=GetHumanoid()
				local Root=GetRoot()

				if
					not Humanoid
					or
					not Root
					or
					Humanoid.Health<=0
				then
					return
				end

				local Position=Root.Position

				local Sitting=
					Humanoid.Sit
					or
					Humanoid.SeatPart~=nil
					or
					Humanoid:GetState()
					==
					Enum.HumanoidStateType.Seated

				if not Sitting then
					if LastPosition then
						local Distance=
							(
								Position
								-
								LastPosition
							).Magnitude

						if
							Distance>=12
							and
							not IsHubIntentionalMovement()
						then
							PullSafeCFrame=
								SafeCFrame

							PullWindowUntil=
								os.clock()
								+
								0.75

						elseif
							not ThreatWindowActive()
						then
							SafeCFrame=
								Root.CFrame
						end
					else
						SafeCFrame=
							Root.CFrame
					end
				end

				LastPosition=
					Position
			end)
		)
	end

	ProtectionControllers.AntiSeatPull=function(State)
		if State then
			Start()
		else
			Stop()
		end
	end

	Gui.Destroying:Connect(Stop)
end

--============================================================
-- ANTI ANCHOR
--
-- Impede que partes do personagem sejam ancoradas por scripts.
-- Reage somente a mudanças de Anchored e novas BaseParts.
--============================================================


do
	local AntiAnchorEnabled =
		false

	local AntiAnchorConnections =
		{}

	local function DisconnectAntiAnchor()

		for _, Connection in ipairs(
			AntiAnchorConnections
		) do

			Connection:Disconnect()

		end

		table.clear(
			AntiAnchorConnections
		)

	end

	local function WatchPart(
		Part
	)

		if
			not AntiAnchorEnabled
			or
			not Part
			or
			not Part:IsA("BasePart")
		then
			return
		end

		if
			Part.Anchored
			and not Gui:GetAttribute("CFrameFlyActive")
			and not Gui:GetAttribute("SavedPositionTeleporting")
		then

			Part.Anchored =
				false

		end

		table.insert(
			AntiAnchorConnections,

			Part:GetPropertyChangedSignal(
				"Anchored"
			):Connect(function()

				if
					AntiAnchorEnabled
					and
					Part
					and
					Part.Parent
					and
					Part.Anchored
					and not Gui:GetAttribute("CFrameFlyActive")
					and not Gui:GetAttribute("SavedPositionTeleporting")
				then

					Part.Anchored =
						false

				end

			end)
		)

	end

	local function StartAntiAnchor()

		DisconnectAntiAnchor()

		AntiAnchorEnabled =
			true

		local Character =
			GetCharacter()

		if not Character then
			return
		end

		for _, Object in ipairs(
			Character:GetDescendants()
		) do

			if Object:IsA("BasePart") then

				WatchPart(
					Object
				)

			end

		end

		table.insert(
			AntiAnchorConnections,

			Character.DescendantAdded:Connect(function(
				Object
			)

				if
					AntiAnchorEnabled
					and
					Object:IsA("BasePart")
				then

					WatchPart(
						Object
					)

				end

			end)
		)

	end

	local function StopAntiAnchor()

		AntiAnchorEnabled =
			false

		DisconnectAntiAnchor()

	end

	ProtectionControllers.AntiAnchor = function(Enabled)

		if Enabled then

			StartAntiAnchor()

		else

			StopAntiAnchor()

		end

	end

	Player.CharacterAdded:Connect(function()

		if AntiAnchorEnabled then

			task.defer(
				StartAntiAnchor
			)

		end

	end)

	Gui.Destroying:Connect(function()

		StopAntiAnchor()

	end)
end

--============================================================
-- ANTI RAGDOLL / PLATFORMSTAND
--
-- Impede estados físicos usados para derrubar/travar o personagem.
-- Reaplica automaticamente após respawn e restaura os estados
-- originais quando a opção é desligada.
--============================================================

do
	local AntiRagdollEnabled = false
	local AntiRagdollHumanoid = nil
	local AntiRagdollConnections = {}
	local AntiRagdollBackup = {}

	-- Não bloqueamos nenhum estado globalmente.
	-- Desabilitar Ragdoll/FallingDown/Physics interfere na máquina
	-- de estados normal do Roblox em quedas e aterrissagens.
	local BlockedStates = {}

	local function DisconnectAntiRagdoll()

		for _, Connection in ipairs(
			AntiRagdollConnections
		) do

			Connection:Disconnect()

		end

		AntiRagdollConnections = {}

	end

	local function RestoreRagdollStates()

		local Humanoid =
			AntiRagdollHumanoid

		if Humanoid then

			for State, Enabled in pairs(
				AntiRagdollBackup
			) do

				pcall(function()

					Humanoid:SetStateEnabled(
						State,
						Enabled
					)

				end)

			end

		end

		AntiRagdollBackup = {}
		AntiRagdollHumanoid = nil

	end

	local function ForceRagdollRecovery()

		if not AntiRagdollEnabled then
			return
		end

		local Humanoid =
			GetHumanoid()

		local Root =
			GetRoot()

		if
			not Humanoid
			or
			not Root
			or
			Humanoid.Health <= 0
		then
			return
		end

		if
			IsHubMovementActive(Humanoid)
			or
			ProtectionRecoveryBusy()
			or
			Gui:GetAttribute("FlightExitRecoveryActive") == true
		then
			return
		end

		local State =
			Humanoid:GetState()

		-- FallingDown e Physics são deixados completamente para o Roblox.
		-- A proteção reage só aos estados realmente usados para travar/ragdollar.
		if
			State ~= Enum.HumanoidStateType.Ragdoll
			and
			State ~= Enum.HumanoidStateType.PlatformStanding
		then
			return
		end

		local Velocity =
			Root.AssemblyLinearVelocity

		local Horizontal =
			Vector3.new(
				Velocity.X,
				0,
				Velocity.Z
			).Magnitude

		local Angular =
			Root.AssemblyAngularVelocity.Magnitude

		-- Queda vertical natural não é ragdoll hostil.
		local NaturalFall =
			Humanoid.FloorMaterial == Enum.Material.Air
			and
			Velocity.Y < -18
			and
			Horizontal < 42
			and
			Angular < 28

		if NaturalFall then
			return
		end

		if Humanoid.FloorMaterial == Enum.Material.Air then
			Humanoid.PlatformStand = false
			Humanoid.Jump = false

			pcall(function()
				Humanoid:ChangeState(
					Enum.HumanoidStateType.Freefall
				)
			end)

			-- Nunca cria velocidade positiva no Y.
			local Current =
				Root.AssemblyLinearVelocity

			if Current.Y > 0 then
				Root.AssemblyLinearVelocity =
					Vector3.new(
						Current.X,
						0,
						Current.Z
					)
			end

			return
		end

		-- No chão recupera sem zerar toda a física e sem GettingUp.
		Humanoid.PlatformStand = false
		Humanoid.Jump = false

		local Current =
			Root.AssemblyLinearVelocity

		Root.AssemblyLinearVelocity =
			Vector3.new(
				Current.X,
				math.min(Current.Y, 0),
				Current.Z
			)

		Root.AssemblyAngularVelocity =
			Vector3.zero

		pcall(function()
			Humanoid:ChangeState(
				Enum.HumanoidStateType.Running
			)
		end)

	end

	local function BindAntiRagdoll()

		DisconnectAntiRagdoll()
		RestoreRagdollStates()

		if not AntiRagdollEnabled then
			return
		end

		local Humanoid =
			GetHumanoid()

		if not Humanoid then
			return
		end

		AntiRagdollHumanoid =
			Humanoid

		for _, State in ipairs(
			BlockedStates
		) do

			local Success, Enabled =
				pcall(function()

					return
						Humanoid:GetStateEnabled(
							State
						)

				end)

			if Success then

				AntiRagdollBackup[State] =
					Enabled

			end

			pcall(function()

				Humanoid:SetStateEnabled(
					State,
					false
				)

			end)

		end

		table.insert(
			AntiRagdollConnections,
			Humanoid.StateChanged:Connect(function()

				ForceRagdollRecovery()

			end)
		)

		table.insert(
			AntiRagdollConnections,
			Humanoid:GetPropertyChangedSignal(
				"PlatformStand"
			):Connect(function()

				ForceRagdollRecovery()

			end)
		)

		ForceRagdollRecovery()

	end

	ProtectionControllers.AntiRagdoll = function(Enabled)

		AntiRagdollEnabled =
			Enabled

		BindAntiRagdoll()

	end

	local CharacterConnection =
		Player.CharacterAdded:Connect(function()

			if AntiRagdollEnabled then

				task.defer(
					BindAntiRagdoll
				)

			end

		end)

	Gui.Destroying:Connect(function()

		AntiRagdollEnabled = false
		DisconnectAntiRagdoll()
		RestoreRagdollStates()
		CharacterConnection:Disconnect()

	end)
end

--============================================================
-- GHOST PLAYERS / SEM COLISÃO COM PLAYERS
--
-- Defesa opcional contra body-fling, empurrões e ferramentas físicas
-- presas ao personagem de outros jogadores.
--============================================================

do
	local GhostPlayersEnabled = false
	local GhostConnection = nil
	local GhostBackup = {}

	local function RestoreGhostPlayers()

		for Part, Data in pairs(
			GhostBackup
		) do

			if
				Part
				and
				Part.Parent
			then

				pcall(function()

					Part.CanCollide =
						Data.CanCollide

					Part.CanTouch =
						Data.CanTouch

				end)

			end

		end

		GhostBackup = {}

	end

	local function ApplyGhostPlayers()

		if not GhostPlayersEnabled then
			return
		end

		for _, Target in ipairs(
			Players:GetPlayers()
		) do

			if
				Target ~= Player
				and
				Target.Character
			then

				for _, Object in ipairs(
					Target.Character:GetDescendants()
				) do

					if Object:IsA("BasePart") then

						if GhostBackup[Object] == nil then

							GhostBackup[Object] = {
								CanCollide =
									Object.CanCollide,

								CanTouch =
									Object.CanTouch
							}

						end

						Object.CanCollide = false
						Object.CanTouch = false

					end

				end

			end

		end

	end

	local function StopGhostPlayers()

		GhostPlayersEnabled = false

		if GhostConnection then

			GhostConnection:Disconnect()
			GhostConnection = nil

		end

		RestoreGhostPlayers()

	end

	local function StartGhostPlayers()

		StopGhostPlayers()

		GhostPlayersEnabled = true
		ApplyGhostPlayers()

		local NextRefresh = 0

		GhostConnection =
			RunService.Heartbeat:Connect(function()

				if not GhostPlayersEnabled then
					return
				end

				local Now =
					os.clock()

				if Now < NextRefresh then
					return
				end

				NextRefresh =
					Now + 0.4

				ApplyGhostPlayers()

			end)

	end

-- Ghost Players global não possui mais toggle próprio.
	-- Anti TP aplica esse princípio apenas no player suspeito.

	Gui.Destroying:Connect(function()

		StopGhostPlayers()

	end)
end

--============================================================
-- ANTI BRING PARTS / TOOLS - CAMADA FÍSICA
--
-- Esta camada é acionada pela opção única "Anti Bring Parts" e cobre:
--   1) Tools/Handles de outros players próximos;
--   2) Props/Models físicos girando muito rápido.
--
-- Um único scanner faz as duas verificações.
-- Trabalha em conjunto com o detector de Bring Parts logo abaixo.
--============================================================

do
	local AntiObjectsEnabled =
		false

	local AntiObjectsConnection =
		nil

	local AntiObjectsNextScan =
		0

	local LastRotation =
		{}

	local ProtectedParts =
		{}

	local AngularThreshold =
		8

	local CFrameAngularThreshold =
		8

	local ObjectRadius =
		24

	local ToolRadius =
		14

	local function GetDrivenVehicle()

		local Ref =
			Gui:FindFirstChild(
				"CartolaDrivenVehicle"
			)

		if
			Ref
			and
			Ref:IsA("ObjectValue")
			and
			Ref.Value
			and
			Ref.Value.Parent
		then

			return Ref.Value

		end

		return nil

	end

	local function IsVehicleContainer(Object)
		if not Object or not Object.Parent then
			return false
		end

		if Object.Name and Object.Name:match("^ltp2_car_%d+$") then
			return true
		end

		if Object:IsA("Model") then
			if
				Object:FindFirstChild("VehicleOwner",true)
				or
				Object:FindFirstChildWhichIsA("VehicleSeat",true)
			then
				return true
			end
		end

		local Node=Object.Parent
		local Depth=0
		while Node and Node~=workspace and Depth<5 do
			if Node.Name and Node.Name:match("^ltp2_car_%d+$") then
				return true
			end
			if
				Node:IsA("Model")
				and
				(
					Node:FindFirstChild("VehicleOwner",true)
					or
					Node:FindFirstChildWhichIsA("VehicleSeat",true)
				)
			then
				return true
			end
			Node=Node.Parent
			Depth+=1
		end

		return false
	end

	local function SameContainer(
		A,
		B
	)

		if
			not A
			or
			not B
		then
			return false
		end

		if A == B then
			return true
		end

		local Result =
			false

		pcall(function()

			Result =
				A:IsDescendantOf(B)
				or
				B:IsDescendantOf(A)

		end)

		return Result

	end

	local function IsCharacterPart(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return false
		end

		local Model =
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		return
			Model
			and
			Model:FindFirstChildOfClass(
				"Humanoid"
			)
			~=
			nil

	end

	local function IsOwnBringPart(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return false
		end

		if
			Part:GetAttribute(
				"CartolaOwnBringPart"
			)
			==
			true
		then
			return true
		end

		local Root =
			Part.AssemblyRootPart

		return
			Root
			and
			Root:GetAttribute(
				"CartolaOwnBringPart"
			)
			==
			true

	end

	local function IsMyOwnedObject(
		Model
	)

		if not Model then
			return false
		end

		local Node =
			Model

		local Depth =
			0

		while
			Node
			and
			Node ~= workspace
			and
			Depth < 5
		do

			local Owner =
				Node:GetAttribute(
					"Owner"
				)

			if
				Owner ~= nil
				and
				tonumber(
					Owner
				)
				==
				Players.LocalPlayer.UserId
			then

				return true

			end

			Node =
				Node.Parent

			Depth +=
				1

		end

		return false

	end

	local function GetPhysicalModel(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return nil
		end

		local Model =
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		if
			not Model
			or
			Model == GetCharacter()
			or
			Model:FindFirstChildOfClass(
				"Humanoid"
			)
		then

			return nil

		end

		return Model

	end

	local function GetModelRoot(
		Model,
		FallbackPart
	)

		if
			Model
			and
			Model.PrimaryPart
			and
			Model.PrimaryPart.Parent
		then

			return Model.PrimaryPart

		end

		if
			FallbackPart
			and
			FallbackPart.Parent
		then

			return FallbackPart

		end

		if Model then

			return Model:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		end

		return nil

	end

	local function ProtectPart(
		Part,
		TouchUntil,
		CollideUntil
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
			or
			IsCharacterPart(
				Part
			)
		then

			return

		end

		local Data =
			ProtectedParts[
				Part
			]

		if not Data then

			Data = {
				OriginalCanTouch =
					Part.CanTouch,

				OriginalCanCollide =
					Part.CanCollide,

				TouchUntil =
					0,

				CollideUntil =
					0
			}

			ProtectedParts[
				Part
			] =
				Data

		end

		if TouchUntil then

			Data.TouchUntil =
				math.max(
					Data.TouchUntil,
					TouchUntil
				)

			Part.CanTouch =
				false

		end

		if CollideUntil then

			Data.CollideUntil =
				math.max(
					Data.CollideUntil,
					CollideUntil
				)

			Part.CanCollide =
				false

		end

	end

	local function RefreshProtectedParts(
		Now,
		RestoreAll
	)

		for Part, Data in pairs(
			ProtectedParts
		) do

			if
				not Part
				or
				not Part.Parent
			then

				ProtectedParts[
					Part
				] =
					nil

			else

				local TouchActive =
					not RestoreAll
					and
					Now
					<
					Data.TouchUntil

				local CollideActive =
					not RestoreAll
					and
					Now
					<
					Data.CollideUntil

				pcall(function()

					if TouchActive then

						Part.CanTouch =
							false

					else

						Part.CanTouch =
							Data.OriginalCanTouch

					end

					if CollideActive then

						Part.CanCollide =
							false

					else

						Part.CanCollide =
							Data.OriginalCanCollide

					end

				end)

				if
					not TouchActive
					and
					not CollideActive
				then

					ProtectedParts[
						Part
					] =
						nil

				end

			end

		end

	end

	local function ProtectSpinningModel(
		Model,
		UntilTime
	)

		if
			not Model
			or
			not Model.Parent
		then
			return
		end

		for _, Object in ipairs(
			Model:GetDescendants()
		) do

			if
				Object:IsA("BasePart")
				and
				not IsCharacterPart(
					Object
				)
			then

				ProtectPart(
					Object,
					UntilTime,
					UntilTime
				)

			end

		end

	end

	local function ScanTools(
		MyRoot,
		Now
	)

		for _, Target in ipairs(
			Players:GetPlayers()
		) do

			if
				Target
				~=
				Players.LocalPlayer
				and
				Target.Character
			then

				local TargetRoot =
					Target.Character:FindFirstChild(
						"HumanoidRootPart"
					)

				if
					TargetRoot
					and
					(
						TargetRoot.Position
						-
						MyRoot.Position
					).Magnitude
					<=
					ToolRadius
				then

					for _, Object in ipairs(
						Target.Character:GetDescendants()
					) do

						if
							Object:IsA("BasePart")
							and
							Object:FindFirstAncestorOfClass(
								"Tool"
							)
						then

							-- Tool: somente CanTouch.
							ProtectPart(
								Object,
								Now + 0.20,
								nil
							)

						end

					end

				end

			end

		end

	end

	local function ScanSpinningObjects(
		Character,
		Root,
		Now
	)

		local Params =
			OverlapParams.new()

		Params.FilterType =
			Enum.RaycastFilterType.Exclude

		Params.FilterDescendantsInstances = {
			Character
		}

		local Nearby =
			workspace:GetPartBoundsInRadius(
				Root.Position,
				ObjectRadius,
				Params
			)

		local DrivenVehicle =
			GetDrivenVehicle()

		local Processed =
			{}

		for _, Part in ipairs(
			Nearby
		) do

			local Model =
				not IsOwnBringPart(
					Part
				)
				and
				GetPhysicalModel(
					Part
				)
				or
				nil

			if
				Model
				and
				not Processed[
					Model
				]
			then

				Processed[
					Model
				] =
					true

				local Ignore =
					IsVehicleContainer(
						Model
					)
					or
					IsMyOwnedObject(
						Model
					)
					or
					SameContainer(
						Model,
						DrivenVehicle
					)

				if not Ignore then

					local ModelRoot =
						GetModelRoot(
							Model,
							Part
						)

					if
						ModelRoot
						and
						not ModelRoot.Anchored
					then

						local PhysicalAngular =
							math.max(
								ModelRoot.AssemblyAngularVelocity.Magnitude,
								Part.AssemblyAngularVelocity.Magnitude
							)

						local CFrameAngular =
							0

						local Previous =
							LastRotation[
								Model
							]

						if Previous then

							local Dt =
								Now
								-
								Previous.Time

							if
								Dt > 0
								and
								Dt <= 0.2
							then

								pcall(function()

									local Relative =
										Previous.CFrame:ToObjectSpace(
											ModelRoot.CFrame
										)

									local _,
										Angle =
										Relative:ToAxisAngle()

									CFrameAngular =
										math.abs(
											Angle
										)
										/
										Dt

								end)

							end

						end

						LastRotation[
							Model
						] = {
							CFrame =
								ModelRoot.CFrame,

							Time =
								Now
						}

						if
							PhysicalAngular
							>=
							AngularThreshold
							or
							CFrameAngular
							>=
							CFrameAngularThreshold
						then

							ProtectSpinningModel(
								Model,
								Now + 0.55
							)

						end

					end

				end

			end

		end

		for Model in pairs(
			LastRotation
		) do

			if
				not Model
				or
				not Model.Parent
			then

				LastRotation[
					Model
				] =
					nil

			end

		end

	end

	local function Stop()

		AntiObjectsEnabled =
			false

		if AntiObjectsConnection then

			AntiObjectsConnection:Disconnect()

			AntiObjectsConnection =
				nil

		end

		RefreshProtectedParts(
			os.clock(),
			true
		)

		table.clear(
			LastRotation
		)

	end

	local function Start()

		Stop()

		AntiObjectsEnabled =
			true

		AntiObjectsConnection =
			RunService.Heartbeat:Connect(function()

				if not AntiObjectsEnabled then
					return
				end

				local Now =
					os.clock()

				if
					Now
					<
					AntiObjectsNextScan
				then

					RefreshProtectedParts(
						Now,
						false
					)

					return

				end

				AntiObjectsNextScan =
					Now + 0.16

				local Character =
					GetCharacter()

				local Root =
					GetRoot()

				if
					not Character
					or
					not Root
				then
					return
				end

				ScanTools(
					Root,
					Now
				)

				ScanSpinningObjects(
					Character,
					Root,
					Now
				)

				RefreshProtectedParts(
					Now,
					false
				)

			end)

	end

	ProtectionControllers.AntiObjetosTools = function(
		Enabled
	)

		if Enabled then

			Start()

		else

			Stop()

		end

	end

	Gui.Destroying:Connect(function()

		Stop()

	end)
end

--============================================================

-- ANTI BRING PARTS / ANTI OBJETO ALVO
--
-- Alguns sistemas de "Bring Parts" escolhem um player como alvo e
-- reposicionam objetos físicos repetidamente na direção/posição dele.
--
-- Esta proteção NÃO bloqueia qualquer objeto que esteja se movendo.
-- Ela procura comportamento de "objeto mirando em você":
--   • objeto estava mais longe e salta por CFrame para perto;
--   • deslocamento do objeto aponta diretamente para você;
--   • objeto converge repetidamente para sua posição;
--   • objeto fica "travado" acompanhando seus movimentos de perto;
--   • objeto físico novo aparece praticamente em cima de você.
--
-- Quando o padrão é suspeito:
--   • CanCollide e CanTouch são desligados temporariamente;
--   • toda a assembly/Model físico é protegida;
--   • partes de Characters/Humanoids nunca são alteradas;
--   • objetos com Owner local são permitidos normalmente, mas entram
--     na proteção se mostrarem comportamento real de Bring Parts/fling;
--   • seu veículo atual continua ignorado;
--   • se o impacto ainda transferir física para você, volta à última
--     posição segura.
--============================================================

task.spawn(function()


	local Enabled =
		false

	local Connection =
		nil

	local NextScan =
		0

	local StartedAt =
		0

	local SafeCFrame =
		nil

	local ThreatUntil =
		0

	local LastSelfPosition =
		nil

	local LastSelfTime =
		0

	local History = {}

	local ProtectedParts = {}

	local ScanRadius =
		42

	local function IsCharacterPart(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return false
		end

		local Model =
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		return
			Model
			and
			Model:FindFirstChildOfClass(
				"Humanoid"
			)
			~=
			nil

	end

	local function GetContainer(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return nil
		end

		-- Veículos deste jogo podem ser a própria Part raiz.
		if
			Part.Name:match(
				"^ltp2_car_%d+$"
			)
		then

			return Part

		end

		local Model =
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		if
			Model
			and
			Model ~= GetCharacter()
			and
			not Model:FindFirstChildOfClass(
				"Humanoid"
			)
		then

			return Model

		end

		-- Part física solta sem Model também pode ser manipulada.
		if not IsCharacterPart(Part) then

			return Part

		end

		return nil

	end

	local function GetContainerRoot(
		Container,
		FallbackPart
	)

		if
			not Container
			or
			not Container.Parent
		then
			return nil
		end

		if Container:IsA("BasePart") then

			return Container

		end

		if
			Container:IsA("Model")
			and
			Container.PrimaryPart
			and
			Container.PrimaryPart.Parent
		then

			return Container.PrimaryPart

		end

		if
			FallbackPart
			and
			FallbackPart.Parent
			and
			not IsCharacterPart(
				FallbackPart
			)
		then

			return FallbackPart

		end

		if Container:IsA("Model") then

			return Container:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		end

		return nil

	end

	local function GetDrivenVehicle()

		local Ref =
			Gui:FindFirstChild(
				"CartolaDrivenVehicle"
			)

		if
			Ref
			and
			Ref:IsA("ObjectValue")
			and
			Ref.Value
			and
			Ref.Value.Parent
		then

			return Ref.Value

		end

		return nil

	end

	local function IsVehicleContainer(Object)
		if not Object or not Object.Parent then
			return false
		end

		if Object.Name and Object.Name:match("^ltp2_car_%d+$") then
			return true
		end

		if Object:IsA("Model") then
			if
				Object:FindFirstChild("VehicleOwner",true)
				or
				Object:FindFirstChildWhichIsA("VehicleSeat",true)
			then
				return true
			end
		end

		local Node=Object.Parent
		local Depth=0
		while Node and Node~=workspace and Depth<5 do
			if Node.Name and Node.Name:match("^ltp2_car_%d+$") then
				return true
			end
			if
				Node:IsA("Model")
				and
				(
					Node:FindFirstChild("VehicleOwner",true)
					or
					Node:FindFirstChildWhichIsA("VehicleSeat",true)
				)
			then
				return true
			end
			Node=Node.Parent
			Depth+=1
		end

		return false
	end

	local function SameContainer(
		A,
		B
	)

		if
			not A
			or
			not B
		then

			return false

		end

		if A == B then
			return true
		end

		local Result =
			false

		pcall(function()

			Result =
				A:IsDescendantOf(B)
				or
				B:IsDescendantOf(A)

		end)

		return Result

	end

	local function IsMyObject(
		Container
	)

		if not Container then
			return false
		end

		local Node =
			Container

		local Depth =
			0

		while
			Node
			and
			Node ~= workspace
			and
			Depth < 6
		do

			local Owner =
				Node:GetAttribute(
					"Owner"
				)

			if
				Owner ~= nil
				and
				tonumber(
					Owner
				)
				==
				Players.LocalPlayer.UserId
			then

				return true

			end

			Node =
				Node.Parent

			Depth +=
				1

		end

		return false

	end

	local function IsIgnored(
		Container
	)

		if
			not Container
			or
			not Container.Parent
		then

			return true

		end

		-- Veículos não são alterados pelo Anti Bring Parts. O Anti CFrame
		-- Veículo decide separadamente se um veículo é realmente perigoso.
		if IsVehicleContainer(Container) then
			return true
		end

		local Probe =
			Container:IsA("BasePart")
			and
			Container
			or
			Container:IsA("Model")
			and
			Container:FindFirstChildWhichIsA(
				"BasePart",
				true
			)
			or
			nil

		local ProbeRoot =
			Probe
			and
			(
				Probe.AssemblyRootPart
				or
				Probe
			)

		if
			ProbeRoot
			and
			ProbeRoot:GetAttribute(
				"CartolaOwnBringPart"
			)
			==
			true
		then

			return true

		end

		-- Objetos com Owner local continuam permitidos em uso normal,
		-- mas agora também passam pela análise de Bring Parts/fling.
		-- Assim terceiros não conseguem usar o próprio objeto do jogador
		-- como arma apenas por ele ter Owner igual ao LocalPlayer.

		local Driven =
			GetDrivenVehicle()

		if
			Driven
			and
			SameContainer(
				Container,
				Driven
			)
		then

			return true

		end

		local Humanoid =
			GetHumanoid()

		local Seat =
			Humanoid
			and
			Humanoid.SeatPart

		if Seat then

			local ContainerRoot =
				Container:IsA("BasePart")
				and
				Container
				or
				Container:IsA("Model")
				and
				(
					Container.PrimaryPart
					or
					Container:FindFirstChildWhichIsA(
						"BasePart",
						true
					)
				)

			if ContainerRoot then

				local SameAssembly =
					false

				pcall(function()

					SameAssembly =
						ContainerRoot.AssemblyRootPart
						==
						Seat.AssemblyRootPart

				end)

				if SameAssembly then

					return true

				end

			end

		end

		return false

	end

	local function ProtectPart(
		Part,
		UntilTime
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
			or
			IsCharacterPart(Part)
		then

			return

		end

		local Data =
			ProtectedParts[
				Part
			]

		if not Data then

			Data = {
				CanCollide =
					Part.CanCollide,

				CanTouch =
					Part.CanTouch,

				Until =
					UntilTime
			}

			ProtectedParts[
				Part
			] =
				Data

		else

			Data.Until =
				math.max(
					Data.Until
					or
					0,
					UntilTime
				)

		end

		Part.CanCollide =
			false

		Part.CanTouch =
			false

	end

	local function ProtectContainer(
		Container,
		UntilTime
	)

		if
			not Container
			or
			not Container.Parent
		then

			return

		end

		if Container:IsA("Model") then

			for _, Object in ipairs(
				Container:GetDescendants()
			) do

				if
					Object:IsA("BasePart")
					and
					not IsCharacterPart(
						Object
					)
				then

					ProtectPart(
						Object,
						UntilTime
					)

				end

			end

			return

		end

		if Container:IsA("BasePart") then

			ProtectPart(
				Container,
				UntilTime
			)

			local Connected = {}

			pcall(function()

				Connected =
					Container:GetConnectedParts(
						true
					)

			end)

			for _, Object in ipairs(
				Connected
			) do

				if
					Object:IsA("BasePart")
					and
					not IsCharacterPart(
						Object
					)
				then

					ProtectPart(
						Object,
						UntilTime
					)

				end

			end

		end

	end

	local function RestorePart(
		Part
	)

		local Data =
			ProtectedParts[
				Part
			]

		if not Data then
			return
		end

		ProtectedParts[
			Part
		] =
			nil

		if
			Part
			and
			Part.Parent
		then

			pcall(function()

				Part.CanCollide =
					Data.CanCollide

				Part.CanTouch =
					Data.CanTouch

			end)

		end

	end

	local function RestoreExpired(
		Now
	)

		local List = {}

		for Part, Data in pairs(
			ProtectedParts
		) do

			if
				not Part
				or
				not Part.Parent
				or
				Now
				>=
				(
					Data.Until
					or
					0
				)
			then

				table.insert(
					List,
					Part
				)

			end

		end

		for _, Part in ipairs(
			List
		) do

			RestorePart(
				Part
			)

		end

	end

	local function RestoreAll()

		local List = {}

		for Part in pairs(
			ProtectedParts
		) do

			table.insert(
				List,
				Part
			)

		end

		for _, Part in ipairs(
			List
		) do

			RestorePart(
				Part
			)

		end

	end

	local function RecoverFromImpact()

		BeginProtectionRecovery(0.30)

		local Character =
			GetCharacter()

		local Root =
			GetRoot()

		local Humanoid =
			GetHumanoid()

		if
			not Character
			or
			not Root
			or
			not Humanoid
		then

			return

		end

		ClearAllCharacterPhysics()

		Humanoid.Sit =
			false

		Humanoid.PlatformStand =
			false

		Humanoid.AutoRotate =
			true

		if SafeCFrame then

			Character:PivotTo(
				SafeCFrame
				+
				Vector3.new(
					0,
					2,
					0
				)
			)

		end

	end

	local function Stop()

		Enabled =
			false

		if Connection then

			Connection:Disconnect()

			Connection =
				nil

		end

		RestoreAll()

		table.clear(
			History
		)

		ThreatUntil =
			0

	end

	local function Start()

		Stop()

		Enabled =
			true

		StartedAt =
			os.clock()

		local Root =
			GetRoot()

		if Root then

			SafeCFrame =
				Root.CFrame

			LastSelfPosition =
				Root.Position

			LastSelfTime =
				StartedAt

		end

		Connection =
			RunService.Heartbeat:Connect(function()

				if not Enabled then
					return
				end

				local Now =
					os.clock()

				if
					Now
					<
					NextScan
				then

					RestoreExpired(
						Now
					)

					return

				end

				NextScan =
					Now + 0.14

				local Character =
					GetCharacter()

				local RootNow =
					GetRoot()

				local Humanoid =
					GetHumanoid()

				if
					not Character
					or
					not RootNow
					or
					not Humanoid
					or
					Humanoid.Health <= 0
				then

					return

				end

				local HubMovement =
					IsHubMovementActive(
						Humanoid
					)

				local IntentionalMovement =
					HubMovement
					or
					ProtectionRecoveryBusy()

				if HubMovement then
					SafeCFrame =
						RootNow.CFrame

					LastSelfPosition =
						RootNow.Position

					LastSelfTime =
						Now

					ThreatUntil =
						0
				end

				local Params =
					OverlapParams.new()

				Params.FilterType =
					Enum.RaycastFilterType.Exclude

				Params.FilterDescendantsInstances = {
					Character
				}

				local Nearby =
					workspace:GetPartBoundsInRadius(
						RootNow.Position,
						ScanRadius,
						Params
					)

				local Processed = {}

				-- Não deixa uma ameaça antiga puxar o player de volta depois que
				-- o próprio jogo o teleportou para outra área/lobby.
				if
					AntiTPSafeCFrame
					and
					(
						MyRoot.Position
						-
						AntiTPSafeCFrame.Position
					).Magnitude > 60
					and
					not HubMovement
				then
					AntiTPSafeCFrame = MyRoot.CFrame
					table.clear(AntiTPThreatUntil)

					for _,Target in ipairs(Players:GetPlayers()) do
						if Target ~= Player and Target.Character then
							local TargetRoot =
								Target.Character:FindFirstChild("HumanoidRootPart")

							if TargetRoot then
								AntiTPTracks[Target] = {
									Position = TargetRoot.Position,
									Time = NowTime,
									Distance =
										(TargetRoot.Position-MyRoot.Position).Magnitude
								}
							end
						end
					end

					RestoreExpired(AntiTPPlayerParts,NowTime)
					RestoreExpired(AntiTPVehicleParts,NowTime)
					return
				end

				local ActiveThreat =
					false

				for _, Part in ipairs(
					Nearby
				) do

					local Container =
						GetContainer(
							Part
						)

					if
						Container
						and
						not Processed[
							Container
						]
					then

						Processed[
							Container
						] =
							true

						if
							not IsIgnored(
								Container
							)
						then

							local ObjectRoot =
								GetContainerRoot(
									Container,
									Part
								)

							if
								ObjectRoot
								and
								ObjectRoot.Parent
							then

								local Position =
									ObjectRoot.Position

								local ToTarget =
									RootNow.Position
									-
									Position

								local Distance =
									ToTarget.Magnitude

								local LinearVelocity =
									ObjectRoot.AssemblyLinearVelocity

								local Speed =
									LinearVelocity.Magnitude

								local ClosingSpeed =
									0

								local VelocityAlignment =
									0

								if
									Distance > 0.001
									and
									Speed > 0.001
								then

									ClosingSpeed =
										LinearVelocity:Dot(
											ToTarget.Unit
										)

									VelocityAlignment =
										LinearVelocity.Unit:Dot(
											ToTarget.Unit
										)

								end

								local Previous =
									History[
										Container
									]

								local SuddenTargetJump =
									false

								local RepeatedHoming =
									false

								local TargetLockedFollow =
									false

								local AppearedOnTarget =
									false

								local HomingScore =
									Previous
									and
									(
										Previous.HomingScore
										or
										0
									)
									or
									0

								local LockScore =
									Previous
									and
									(
										Previous.LockScore
										or
										0
									)
									or
									0

								if Previous then

									local Dt =
										Now
										-
										Previous.Time

									local Movement =
										Position
										-
										Previous.Position

									local Moved =
										Movement.Magnitude

									local PreviousToTarget =
										Previous.TargetPosition
										-
										Previous.Position

									local AimAlignment =
										0

									if
										Moved > 0.001
										and
										PreviousToTarget.Magnitude > 0.001
									then

										AimAlignment =
											Movement.Unit:Dot(
												PreviousToTarget.Unit
											)

									end

									-- Objeto estava longe e "saltou" diretamente
									-- para perto do alvo.
									if
										Dt > 0
										and
										Dt <= 0.24
										and
										Moved >= 9
										and
										Previous.Distance >= 15
										and
										Distance <= 10
										and
										AimAlignment >= 0.72
									then

										SuddenTargetJump =
											true

									end

									-- Convergência em leituras consecutivas.
									if
										Dt > 0
										and
										Dt <= 0.22
										and
										Moved >= 2
										and
										Distance <= 18
										and
										Previous.Distance
										-
										Distance
										>=
										1.5
										and
										AimAlignment >= 0.80
									then

										HomingScore +=
											1

									else

										HomingScore =
											math.max(
												0,
												HomingScore - 1
											)

									end

									RepeatedHoming =
										HomingScore >= 2

									-- Bring Parts frequentemente mantém o objeto
									-- "colado" no alvo e ele passa a acompanhar o
									-- mesmo deslocamento do player.
									local TargetMovement =
										RootNow.Position
										-
										Previous.TargetPosition

									if
										Distance <= 8
										and
										Moved >= 0.45
										and
										TargetMovement.Magnitude >= 0.45
									then

										local FollowAlignment =
											Movement.Unit:Dot(
												TargetMovement.Unit
											)

										local MovementRatio =
											Moved
											/
											math.max(
												TargetMovement.Magnitude,
												0.001
											)

										local DistanceChange =
											math.abs(
												Distance
												-
												Previous.Distance
											)

										if
											FollowAlignment >= 0.90
											and
											MovementRatio >= 0.55
											and
											MovementRatio <= 1.8
											and
											DistanceChange <= 2.2
										then

											LockScore +=
												1

										else

											LockScore =
												math.max(
													0,
													LockScore - 1
												)

										end

									else

										LockScore =
											math.max(
												0,
												LockScore - 1
											)

									end

									TargetLockedFollow =
										LockScore >= 3

								else

									-- Depois do pequeno período de aprendizado,
									-- um objeto físico nunca visto que surge quase
									-- exatamente em cima do player é suspeito.
									if
										Now
										-
										StartedAt
										>
										0.9
										and
										not ObjectRoot.Anchored
										and
										Distance <= 6.5
									then

										AppearedOnTarget =
											true

									end

								end

								-- Movimento físico direto na direção do player.
								-- Só conta quando a direção realmente aponta para ele.
								local IncomingTargeted =
									Distance <= 18
									and
									Speed >= 28
									and
									ClosingSpeed >= 22
									and
									VelocityAlignment >= 0.72

								local OwnedByLocal =
									IsMyObject(
										Container
									)

								local Suspicious

								if OwnedByLocal then

									-- Objeto próprio só é neutralizado quando existe
									-- comportamento realmente compatível com Bring Parts/fling.
									Suspicious =
										SuddenTargetJump
										or
										RepeatedHoming
										or
										TargetLockedFollow
										or
										IncomingTargeted

								else

									Suspicious =
										SuddenTargetJump
										or
										RepeatedHoming
										or
										TargetLockedFollow
										or
										AppearedOnTarget
										or
										IncomingTargeted

								end

								if Suspicious then

									ActiveThreat =
										true

									ThreatUntil =
										math.max(
											ThreatUntil,
											Now + 0.9
										)

									ProtectContainer(
										Container,
										Now + 0.75
									)

								end

								History[
									Container
								] = {
									Position =
										Position,

									TargetPosition =
										RootNow.Position,

									Distance =
										Distance,

									Time =
										Now,

									HomingScore =
										HomingScore,

									LockScore =
										LockScore
								}

							end

						end

					end

				end

				-- Limpa histórico de objetos removidos.
				for Container in pairs(
					History
				) do

					if
						not Container
						or
						not Container.Parent
					then

						History[
							Container
						] =
							nil

					end

				end

				local UnderThreat =
					ActiveThreat
					or
					Now < ThreatUntil

				local ConfiguredWalkSpeed =
					tonumber(
						Gui:GetAttribute(
							"CartolaWalkSpeed"
						)
					)
					or
					Humanoid.WalkSpeed
					or
					16

				if
					UnderThreat
					and
					not IntentionalMovement
				then

					local Linear =
						RootNow.AssemblyLinearVelocity

					local Angular =
						RootNow.AssemblyAngularVelocity.Magnitude

					local Horizontal =
						Vector3.new(
							Linear.X,
							0,
							Linear.Z
						).Magnitude

					local SuddenSelfMove =
						false

					if
						LastSelfPosition
						and
						LastSelfTime > 0
					then

						local SelfDt =
							Now
							-
							LastSelfTime

						if
							SelfDt > 0
							and
							SelfDt <= 0.22
						then

							local SelfDelta =
								RootNow.Position
								-
								LastSelfPosition

							local SelfHorizontal =
								Vector3.new(
									SelfDelta.X,
									0,
									SelfDelta.Z
								).Magnitude

							local ExpectedSelfTravel =
								ConfiguredWalkSpeed
								*
								SelfDt

							if
								SelfHorizontal
								>=
								math.max(
									13,
									ExpectedSelfTravel * 2.2 + 6
								)
							then
								SuddenSelfMove = true
							end

						end

					end

					if
						Horizontal
						>
						math.max(
							58,
							ConfiguredWalkSpeed * 1.45 + 25
						)
						or
						(
							Angular > 35
							and
							Horizontal
							>
							math.max(
								20,
								ConfiguredWalkSpeed * 0.35
							)
						)
						or
						SuddenSelfMove
					then

						RecoverFromImpact()

					end

				elseif
					not IntentionalMovement
					and
					Humanoid.FloorMaterial
					~=
					Enum.Material.Air
					and
					not Humanoid.Sit
					and
					not Humanoid.SeatPart
					and
					Vector3.new(
						RootNow.AssemblyLinearVelocity.X,
						0,
						RootNow.AssemblyLinearVelocity.Z
					).Magnitude
					<
					math.max(
						38,
						ConfiguredWalkSpeed * 1.35 + 20
					)
					and
					RootNow.AssemblyAngularVelocity.Magnitude < 12
				then

					SafeCFrame =
						RootNow.CFrame

				end

				LastSelfPosition =
					RootNow.Position

				LastSelfTime =
					Now

				RestoreExpired(
					Now
				)

			end)

	end

	ProtectionControllers.AntiBringParts = function(Enabled)

		Gui:SetAttribute(
			"AntiBringPartsEnabled",
			Enabled == true
		)

		if Enabled then

			Start()

		else

			Stop()

		end

		-- A antiga proteção de Tools/objetos agora faz parte desta
		-- mesma opção e não possui toggle separado.
		local ObjectsController =
			ProtectionControllers.AntiObjetosTools

		if ObjectsController then
			ObjectsController(Enabled)
		end

	end

	Gui.Destroying:Connect(function()

		Stop()

	end)

end)

--============================================================
-- ANTI EXPLOSÃO / ANTI BOMBA
--
-- Mantém os efeitos/partículas visuais. Neutraliza a Explosion e também
-- corrige o pequeno deslocamento residual que pode entrar no mesmo frame.
-- Não esconde partículas e não mantém o personagem preso em CFrame fixo:
-- durante a janela curta, o X/Z esperado acompanha o MoveDirection.
--============================================================

do
	local AntiExplosionEnabled = false
	local ExplosionConnection = nil
	local AntiExplosionStepped = nil
	local AntiExplosionHeartbeat = nil
	local ProtectionUntil = 0
	local StableVelocity = Vector3.zero
	local StableAngularVelocity = Vector3.zero
	local ExpectedXZ = nil
	local ExpectedY = nil
	local ProtectedVerticalVelocity = 0

	local function IsSpecialHubMovement()
		return FlingRunning
			or WalkFlingEnabled
			or FlyEnabled
			or Gui:GetAttribute("VehicleFlingActive") == true
			or Gui:GetAttribute("VFlyActive") == true
	end

	local function CaptureStablePhysics()
		local Root = GetRoot()
		local Humanoid = GetHumanoid()
		if not Root or not Humanoid or Humanoid.Health <= 0 then
			return
		end

		local Velocity = Root.AssemblyLinearVelocity
		local Angular = Root.AssemblyAngularVelocity

		-- Nunca aprende um impulso de explosão/fling como velocidade normal.
		if Velocity.Magnitude < 85 and Angular.Magnitude < 18 then
			StableVelocity = Velocity
			StableAngularVelocity = Angular
		end
	end

	local function GetDesiredVelocity(Humanoid)
		local Desired = StableVelocity

		if IsSpecialHubMovement() then
			return Desired
		end

		local Move = Humanoid.MoveDirection
		local Horizontal = Vector3.new(Desired.X, 0, Desired.Z)

		if Move.Magnitude > 0.01 then
			Horizontal = Move.Unit * Humanoid.WalkSpeed
		end

		-- Durante a proteção usamos somente a velocidade vertical capturada antes
		-- do impacto. Assim um pulo legítimo continua, mas o impulso extra da bomba
		-- nunca vira a nova velocidade do personagem.
		local Vertical = ProtectedVerticalVelocity

		if Humanoid.FloorMaterial ~= Enum.Material.Air and math.abs(Vertical) < 4 then
			Vertical = 0
		end

		return Vector3.new(Horizontal.X, Vertical, Horizontal.Z)
	end

	local function ApplyExplosionShield(PostPhysicsDelta)
		if not AntiExplosionEnabled or os.clock() >= ProtectionUntil then
			return
		end

		local Character = GetCharacter()
		local Root = GetRoot()
		local Humanoid = GetHumanoid()
		if not Character or not Root or not Humanoid or Humanoid.Health <= 0 then
			return
		end

		local Desired = GetDesiredVelocity(Humanoid)

		-- AssemblyLinearVelocity no HRP controla a montagem inteira; reaplicar
		-- nas partes garante que acessórios/limbs não devolvam impulso depois.
		Root.AssemblyLinearVelocity = Desired
		Root.AssemblyAngularVelocity = Vector3.zero

		for _, Part in ipairs(Character:GetDescendants()) do
			if Part:IsA("BasePart") and Part ~= Root then
				Part.AssemblyLinearVelocity = Desired
				Part.AssemblyAngularVelocity = Vector3.zero
			end
		end

		Humanoid.Sit = false
		Humanoid.PlatformStand = false

		-- A Explosion pode alterar a posição no mesmo solver mesmo com pressão 0.
		-- Mantemos uma trajetória esperada curta. No eixo Y só corrigimos quando
		-- o personagem ficou ACIMA da trajetória normal, evitando a pequena
		-- "voada" da bomba sem cancelar um pulo legítimo.
		if PostPhysicsDelta and PostPhysicsDelta > 0 and not IsSpecialHubMovement() then
			local Delta = math.min(PostPhysicsDelta, 0.05)

			if not ExpectedXZ then
				ExpectedXZ = Vector2.new(Root.Position.X, Root.Position.Z)
			end

			if ExpectedY == nil then
				ExpectedY = Root.Position.Y
			end

			ExpectedXZ += Vector2.new(Desired.X, Desired.Z) * Delta

			local Position = Root.Position
			local CorrectedY = Position.Y

			if Humanoid.FloorMaterial == Enum.Material.Air or ProtectedVerticalVelocity > 4 then
				ExpectedY += ProtectedVerticalVelocity * Delta
				ProtectedVerticalVelocity -= workspace.Gravity * Delta
				ProtectedVerticalVelocity = math.max(ProtectedVerticalVelocity, -120)
			else
				-- No chão, mantém a altura-base capturada antes da explosão.
				ProtectedVerticalVelocity = 0
			end

			if Position.Y > ExpectedY + 0.18 then
				CorrectedY = ExpectedY
			elseif Humanoid.FloorMaterial ~= Enum.Material.Air then
				ExpectedY = Position.Y
			end

			local Rotation = Root.CFrame - Position
			Root.CFrame = CFrame.new(ExpectedXZ.X, CorrectedY, ExpectedXZ.Y) * Rotation

			-- O CFrame acima pode fazer o solver recalcular velocidade; reafirma a
			-- velocidade esperada uma última vez no mesmo frame.
			Desired = GetDesiredVelocity(Humanoid)
			Root.AssemblyLinearVelocity = Desired
			Root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	local function BeginExplosionShield(Duration)
		-- Usa o último estado estável capturado ANTES da Explosion aparecer.
		-- Não recaptura aqui, porque o solver já pode ter aplicado parte do impulso.
		local Root = GetRoot()
		local Humanoid = GetHumanoid()
		if Root and os.clock() >= ProtectionUntil then
			ExpectedXZ = Vector2.new(Root.Position.X, Root.Position.Z)
			ExpectedY = Root.Position.Y
			ProtectedVerticalVelocity = StableVelocity.Y

			-- Se estava realmente no chão antes da explosão, não aceita impulso Y.
			if Humanoid
				and Humanoid.FloorMaterial ~= Enum.Material.Air
				and math.abs(ProtectedVerticalVelocity) < 4
			then
				ProtectedVerticalVelocity = 0
			end
		end

		ProtectionUntil = math.max(ProtectionUntil, os.clock() + (Duration or 0.34))
		ApplyExplosionShield(nil)
	end

	local function NeutralizeExplosion(Explosion)
		if not AntiExplosionEnabled or not Explosion or not Explosion:IsA("Explosion") then
			return
		end

		local Root = GetRoot()
		if not Root then
			return
		end

		local OriginalRadius = Explosion.BlastRadius
		local Distance = (Root.Position - Explosion.Position).Magnitude

		if Distance > OriginalRadius + 18 then
			return
		end

		BeginExplosionShield(0.42)

		-- Mantém exatamente os visuais da explosão; só remove alcance/força e
		-- destruição de juntas.
		pcall(function()
			Explosion.BlastPressure = 0
			Explosion.BlastRadius = 0
			Explosion.DestroyJointRadiusPercent = 0
		end)

		local HitConnection
		HitConnection = Explosion.Hit:Connect(function(Part)
			local Character = GetCharacter()
			if Character and Part and Part:IsDescendantOf(Character) then
				ProtectionUntil = math.max(ProtectionUntil, os.clock() + 0.36)
				ApplyExplosionShield(nil)
			end
		end)

		task.delay(0.8, function()
			if HitConnection then
				HitConnection:Disconnect()
				HitConnection = nil
			end
		end)
	end

	local function StopAntiExplosion()
		AntiExplosionEnabled = false
		ProtectionUntil = 0
		ExpectedXZ = nil
		ExpectedY = nil
		ProtectedVerticalVelocity = 0

		if ExplosionConnection then
			ExplosionConnection:Disconnect()
			ExplosionConnection = nil
		end

		if AntiExplosionStepped then
			AntiExplosionStepped:Disconnect()
			AntiExplosionStepped = nil
		end

		if AntiExplosionHeartbeat then
			AntiExplosionHeartbeat:Disconnect()
			AntiExplosionHeartbeat = nil
		end
	end

	local function StartAntiExplosion()
		StopAntiExplosion()
		AntiExplosionEnabled = true
		CaptureStablePhysics()

		local Root = GetRoot()
		if Root then
			ExpectedXZ = Vector2.new(Root.Position.X, Root.Position.Z)
			ExpectedY = Root.Position.Y
			ProtectedVerticalVelocity = StableVelocity.Y
		end

		for _, Object in ipairs(workspace:GetDescendants()) do
			if Object:IsA("Explosion") then
				NeutralizeExplosion(Object)
			end
		end

		ExplosionConnection = workspace.DescendantAdded:Connect(function(Object)
			if Object:IsA("Explosion") then
				NeutralizeExplosion(Object)
			end
		end)

		-- Stepped: corta impulso antes da simulação seguinte.
		AntiExplosionStepped = RunService.Stepped:Connect(function()
			if AntiExplosionEnabled and os.clock() < ProtectionUntil then
				ApplyExplosionShield(nil)
			end
		end)

		-- Heartbeat: remove o deslocamento microscópico que entrou no solver.
		AntiExplosionHeartbeat = RunService.Heartbeat:Connect(function(DeltaTime)
			if not AntiExplosionEnabled then
				return
			end

			if os.clock() < ProtectionUntil then
				ApplyExplosionShield(DeltaTime)
			else
				ExpectedXZ = nil
				ExpectedY = nil
				ProtectedVerticalVelocity = 0
				CaptureStablePhysics()
			end
		end)
	end

	ProtectionControllers.AntiExplosao = function(Enabled)
		if Enabled then
			StartAntiExplosion()
		else
			StopAntiExplosion()
		end
	end

	Gui.Destroying:Connect(function()
		StopAntiExplosion()
	end)
end

--============================================================
-- ANTI TP / DETECTOR DE TELEPORTE SUSPEITO
--
-- Responsabilidade desta camada:
--   • detectar outro player saltando/CFrameando de longe para perto;
--   • detectar CFrame spam repetido praticamente em cima do jogador;
--   • manter uma janela curta de ameaça para evitar falsos negativos;
--   • NÃO duplicar CanCollide/CanTouch, veículos ou recuperação física.
--
-- Anti Fling cuida do contato físico.
-- Anti Front Pull, ligado pelo mesmo toggle, cuida de tentativas de mover
-- o próprio personagem local para perto/na frente de outro player.
--============================================================

do
	local AntiTPEnabled =
		false

	local AntiTPConnection =
		nil

	local AntiTPLastScan =
		0

	local AntiTPTracks =
		{}

	local AntiTPThreatUntil =
		{}

	local function SetAntiTPThreat(
		State
	)

		Gui:SetAttribute(
			"AntiTPTeleportThreatActive",
			State == true
		)

	end

	local function StopAntiTP()

		AntiTPEnabled =
			false

		if AntiTPConnection then

			AntiTPConnection:Disconnect()

			AntiTPConnection =
				nil

		end

		table.clear(
			AntiTPTracks
		)

		table.clear(
			AntiTPThreatUntil
		)

		AntiTPLastScan =
			0

		SetAntiTPThreat(
			false
		)

	end

	local function StartAntiTP()

		StopAntiTP()

		AntiTPEnabled =
			true

		local MyRoot =
			GetRoot()

		local Now =
			os.clock()

		for _,Target in ipairs(
			Players:GetPlayers()
		) do

			if
				Target ~= Player
				and
				Target.Character
			then

				local TargetRoot =
					Target.Character:FindFirstChild(
						"HumanoidRootPart"
					)

				if TargetRoot then

					AntiTPTracks[
						Target
					] = {
						Position =
							TargetRoot.Position,

						Time =
							Now,

						Distance =
							MyRoot
							and
							(
								TargetRoot.Position
								-
								MyRoot.Position
							).Magnitude
							or
							math.huge
					}

				end

			end

		end

		AntiTPConnection =
			RunService.Heartbeat:Connect(function()

				if not AntiTPEnabled then
					return
				end

				local NowTime =
					os.clock()

				if
					NowTime
					<
					AntiTPLastScan
				then
					return
				end

				AntiTPLastScan =
					NowTime + 0.10

				local CurrentRoot =
					GetRoot()

				local Humanoid =
					GetHumanoid()

				if
					not CurrentRoot
					or
					not Humanoid
					or
					Humanoid.Health <= 0
				then

					SetAntiTPThreat(
						false
					)

					return
				end

				local ActiveThreat =
					false

				for _,Target in ipairs(
					Players:GetPlayers()
				) do

					if Target ~= Player then

						local TargetCharacter =
							Target.Character

						local TargetRoot =
							TargetCharacter
							and
							TargetCharacter:FindFirstChild(
								"HumanoidRootPart"
							)

						if TargetRoot then

							local Distance =
								(
									TargetRoot.Position
									-
									CurrentRoot.Position
								).Magnitude

							local Previous =
								AntiTPTracks[
									Target
								]

							local TeleportedClose =
								false

							if Previous then

								local DeltaTime =
									NowTime
									-
									Previous.Time

								local Moved =
									(
										TargetRoot.Position
										-
										Previous.Position
									).Magnitude

								-- Estava longe e apareceu perto quase instantaneamente.
								if
									DeltaTime > 0
									and
									DeltaTime <= 0.35
									and
									Previous.Distance > 14
									and
									Distance <= 8
									and
									Moved >= 8
								then

									TeleportedClose =
										true

								end

								-- CFrame/TP repetido muito perto do jogador.
								if
									DeltaTime > 0
									and
									DeltaTime <= 0.20
									and
									Distance <= 4.5
									and
									Moved >= 5
								then

									TeleportedClose =
										true

								end

							else

								-- Character acabou de aparecer praticamente em cima.
								if Distance <= 3.5 then

									TeleportedClose =
										true

								end

							end

							-- Movimento absurdamente rápido colado no jogador
							-- também é tratado como TP/CFrame suspeito.
							if
								Distance <= 6
								and
								TargetRoot.AssemblyLinearVelocity.Magnitude
								>=
								90
							then

								TeleportedClose =
									true

							end

							if TeleportedClose then

								AntiTPThreatUntil[
									Target
								] =
									NowTime + 0.90

							end

							local UntilTime =
								AntiTPThreatUntil[
									Target
								]

							if
								UntilTime
								and
								NowTime < UntilTime
							then

								ActiveThreat =
									true

								-- CFrame spam permanecendo grudado mantém
								-- a detecção ativa por mais alguns frames.
								if Distance <= 5 then

									AntiTPThreatUntil[
										Target
									] =
										math.max(
											UntilTime,
											NowTime + 0.25
										)

								end

							elseif UntilTime then

								AntiTPThreatUntil[
									Target
								] =
									nil

							end

							AntiTPTracks[
								Target
							] = {
								Position =
									TargetRoot.Position,

								Time =
									NowTime,

								Distance =
									Distance
							}

						else

							AntiTPTracks[
								Target
							] =
								nil

							AntiTPThreatUntil[
								Target
							] =
								nil

						end

					end

				end

				-- Remove histórico de quem saiu do servidor.
				for Target in pairs(
					AntiTPTracks
				) do

					if
						not Target
						or
						Target.Parent ~= Players
					then

						AntiTPTracks[
							Target
						] =
							nil

						AntiTPThreatUntil[
							Target
						] =
							nil

					end

				end

				SetAntiTPThreat(
					ActiveThreat
				)

			end)

	end

	ProtectionControllers.AntiTP = function(
		Enabled
	)

		if Enabled then

			StartAntiTP()

		else

			StopAntiTP()

		end

	end

	Gui.Destroying:Connect(function()

		StopAntiTP()

	end)
end

--============================================================
-- ANTI CFRAME/FLING DE VEÍCULOS LTP2
--
-- Este bloco cobre somente veículos ltp2_car_XX que avançam, recuam,
-- giram ou recebem CFrame/PivotTo repetidos perto do personagem.
--
-- Proteções:
--   • atua somente em veículos chamados ltp2_car_XX;
--   • detecta avanço/retorno repetido de CFrame (Vai e Vem);
--   • detecta ltp2 vindo na sua direção ou girando mesmo SEM motorista;
--   • mede velocidade tangencial das pontas do veículo;
--   • detecta rotação forçada por CFrame/PivotTo;
--   • ignora o seu próprio veículo;
--   • desliga localmente colisão/toque do veículo ameaçador;
--   • ignora teleporte direto de jogadores; essa detecção pertence ao Anti TP;
--   • se seu personagem receber impulso anormal, volta para posição segura;
--   • impede sequência de impulsos por uma pequena janela de recuperação.
--============================================================


do
	local AntiRamEnabled =
		false

	local AntiRamConnection =
		nil

	local AntiRamSafeCFrame =
		nil

	local AntiRamRecoveryUntil =
		0

	local AntiRamLastScan =
		0

	local AntiRamLastVehiclePosition =
		{}

	local AntiRamProtectedParts =
		{}

	local function GetOwnVehicle()

		local Humanoid =
			GetHumanoid()

		local Seat =
			Humanoid
			and
			Humanoid.SeatPart

		if Seat then

			local Node =
				Seat

			while
				Node
				and
				Node ~= workspace
			do

				if
					Node.Name
					and
					Node.Name:match(
						"^ltp2_car_%d+$"
					)
				then

					return Node
				end

				if
					Node:IsA("Model")
					and
					Node:FindFirstChildWhichIsA(
						"VehicleSeat",
						true
					)
				then

					return Node
				end

				Node =
					Node.Parent

			end

		end

		-- O último veículo selecionado em DIRIGIR é sempre tratado
		-- como veículo próprio. Isso evita que Anti CFrame/Veículo
		-- desligue CanCollide/CanTouch do carro ou moto que você
		-- está controlando.
		local Ref =
			Gui:FindFirstChild(
				"CartolaDrivenVehicle"
			)

		if
			Ref
			and
			Ref:IsA("ObjectValue")
			and
			Ref.Value
			and
			Ref.Value.Parent
		then

			return Ref.Value
		end

		return nil
	end

	local function FindVehicleModelFromPart(
		Part
	)

		local Node =
			Part

		local Candidate =
			nil

		while
			Node
			and
			Node ~= workspace
		do

			-- Prioriza o container ltp2_car_XX. Em algumas motos o
			-- VehicleSeat fica dentro de um Model filho.
			if
				Node.Name
				and
				Node.Name:match(
					"^ltp2_car_%d+$"
				)
			then

				return Node
			end

			if
				not Candidate
				and
				Node:IsA("Model")
				and
				Node:FindFirstChildWhichIsA(
					"VehicleSeat",
					true
				)
			then

				Candidate =
					Node
			end

			Node =
				Node.Parent

		end

		return Candidate
	end

	local function ProtectPart(
		Part,
		UntilTime
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return
		end

		local Data =
			AntiRamProtectedParts[
				Part
			]

		if not Data then

			Data = {
				CanCollide =
					Part.CanCollide,

				CanTouch =
					Part.CanTouch,

				Until =
					UntilTime
			}

			AntiRamProtectedParts[
				Part
			] =
				Data

		else

			Data.Until =
				math.max(
					Data.Until
					or
					0,
					UntilTime
				)

		end

		Part.CanCollide =
			false

		Part.CanTouch =
			false

	end

	local function IsCharacterPart(
		Part
	)

		if
			not Part
			or
			not Part:IsA("BasePart")
		then
			return false
		end

		local CharacterModel =
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		return
			CharacterModel
			and
			CharacterModel:FindFirstChildOfClass(
				"Humanoid"
			)
			~=
			nil
	end

	local function ProtectVehicle(
		Vehicle,
		UntilTime
	)

		if
			not Vehicle
			or
			not Vehicle.Parent
		then
			return
		end

		-- Model tradicional: protege somente as peças físicas do veículo.
		if Vehicle:IsA("Model") then

			for _, Object in ipairs(
				Vehicle:GetDescendants()
			) do

				if
					Object:IsA("BasePart")
					and
					not IsCharacterPart(
						Object
					)
				then

					ProtectPart(
						Object,
						UntilTime
					)

				end

			end

			return

		end

		-- Nos veículos deste jogo, ltp2_car_XX pode ser a própria Part
		-- invisível/root. Nesse caso usamos a assembly conectada.
		if Vehicle:IsA("BasePart") then

			ProtectPart(
				Vehicle,
				UntilTime
			)

			local Connected = {}

			pcall(function()

				Connected =
					Vehicle:GetConnectedParts(
						true
					)

			end)

			for _, Object in ipairs(
				Connected
			) do

				-- NÃO neutraliza o Character do motorista.
				if
					Object:IsA("BasePart")
					and
					not IsCharacterPart(
						Object
					)
				then

					ProtectPart(
						Object,
						UntilTime
					)

				end

			end

		end

	end

	local function RestoreExpired(
		Now
	)

		for Part, Data in pairs(
			AntiRamProtectedParts
		) do

			if
				not Part
				or
				not Part.Parent
				or
				Now
				>=
				(
					Data.Until
					or
					0
				)
			then

				if
					Part
					and
					Part.Parent
				then

					pcall(function()

						Part.CanCollide =
							Data.CanCollide

						Part.CanTouch =
							Data.CanTouch

					end)

				end

				AntiRamProtectedParts[
					Part
				] =
					nil

			end

		end

	end

	local function RestoreAll()

		for Part, Data in pairs(
			AntiRamProtectedParts
		) do

			if
				Part
				and
				Part.Parent
			then

				pcall(function()

					Part.CanCollide =
						Data.CanCollide

					Part.CanTouch =
						Data.CanTouch

				end)

			end

		end

		table.clear(
			AntiRamProtectedParts
		)

	end

	local function Recover()

		BeginProtectionRecovery(0.32)

		local Root =
			GetRoot()

		local Humanoid =
			GetHumanoid()

		if
			not Root
			or
			not Humanoid
		then
			return
		end

		AntiRamRecoveryUntil =
			os.clock() + 0.28

		ClearAllCharacterPhysics()

		Humanoid.Sit =
			false

		Humanoid.PlatformStand =
			false

		Humanoid.AutoRotate =
			true

		pcall(function()

			if
				Humanoid.FloorMaterial
				==
				Enum.Material.Air
			then
				Humanoid:ChangeState(
					Enum.HumanoidStateType.Freefall
				)
			else
				Humanoid:ChangeState(
					Enum.HumanoidStateType.Running
				)
			end

		end)

		if AntiRamSafeCFrame then

			Root.CFrame =
				AntiRamSafeCFrame
				+
				Vector3.new(
					0,
					2,
					0
				)

		end

	end

	local function StopAntiRam()

		AntiRamEnabled =
			false

		if AntiRamConnection then

			AntiRamConnection:Disconnect()

			AntiRamConnection =
				nil

		end

		RestoreAll()


		table.clear(
			AntiRamLastVehiclePosition
		)

		AntiRamRecoveryUntil =
			0

		AntiDefense.VehicleThreatUntil = 0
		AntiDefense.VehicleLastSelfPosition = nil
		AntiDefense.VehicleLastSelfTime = 0

	end

	local function StartAntiRam()

		StopAntiRam()

		AntiRamEnabled =
			true

		AntiDefense.VehicleThreatUntil = 0
		AntiDefense.VehicleLastSelfPosition = nil
		AntiDefense.VehicleLastSelfTime = 0

		local Root =
			GetRoot()

		if Root then

			AntiRamSafeCFrame =
				Root.CFrame

			AntiDefense.VehicleLastSelfPosition =
				Root.Position

			AntiDefense.VehicleLastSelfTime =
				os.clock()

		end

		AntiRamConnection =
			RunService.Heartbeat:Connect(function()

				if not AntiRamEnabled then
					return
				end

				local Now =
					os.clock()

				local Character =
					GetCharacter()

				local MyRoot =
					GetRoot()

				local Humanoid =
					GetHumanoid()

				if
					not Character
					or
					not MyRoot
					or
					not Humanoid
					or
					Humanoid.Health <= 0
				then
					return
				end

				local HubMovement =
					IsHubMovementActive(
						Humanoid
					)

				local OwnMovement =
					HubMovement
					or
					ProtectionRecoveryBusy()

				if HubMovement then
					AntiRamSafeCFrame =
						MyRoot.CFrame

					AntiRamRecoveryUntil =
						0
				end

				if
					Now
					<
					AntiRamRecoveryUntil
					and
					not OwnMovement
				then

					ClearAllCharacterPhysics()

					Humanoid.Sit =
						false

					Humanoid.PlatformStand =
						false

					if AntiRamSafeCFrame then

						MyRoot.CFrame =
							AntiRamSafeCFrame
							+
							Vector3.new(
								0,
								2,
								0
							)

					end

				end

				local RecentVehicleThreat =
					Now
					<
					(
						AntiDefense.VehicleThreatUntil
						or
						0
					)

				local GuardLinear =
					MyRoot.AssemblyLinearVelocity

				local GuardHorizontal =
					Vector3.new(
						GuardLinear.X,
						0,
						GuardLinear.Z
					).Magnitude

				local GuardAngular =
					MyRoot.AssemblyAngularVelocity.Magnitude

				local SuddenSelfMove =
					false

				if
					AntiDefense.VehicleLastSelfPosition
					and
					AntiDefense.VehicleLastSelfTime > 0
				then

					local SelfDt =
						Now
						-
						AntiDefense.VehicleLastSelfTime

					if
						SelfDt > 0
						and
						SelfDt <= 0.25
					then

						local SelfDelta =
							MyRoot.Position
							-
							AntiDefense.VehicleLastSelfPosition

						local GuardWalkSpeed =
							tonumber(
								Gui:GetAttribute(
									"CartolaWalkSpeed"
								)
							)
							or
							Humanoid.WalkSpeed
							or
							16

						local GuardExpectedTravel =
							math.max(
								16,
								Humanoid.WalkSpeed,
								GuardWalkSpeed
							)
							*
							SelfDt

						if
							SelfDelta.Magnitude
							>=
							math.max(
								14,
								GuardExpectedTravel * 2.4 + 6
							)
							or
							SelfDelta.Y <= -9
						then

							SuddenSelfMove =
								true

						end

					end

				end

				AntiDefense.VehicleLastSelfPosition =
					MyRoot.Position

				AntiDefense.VehicleLastSelfTime =
					Now

				if
					RecentVehicleThreat
					and
					not OwnMovement
					and
					(
						GuardHorizontal > 58
						or
						GuardLinear.Magnitude > 95
						or
						GuardLinear.Y < -55
						or
						GuardAngular > 22
						or
						SuddenSelfMove
						or
						(
							AntiRamSafeCFrame
							and
							MyRoot.Position.Y
							<
							AntiRamSafeCFrame.Position.Y - 8
						)
					)
				then

					Recover()

				end

				if
					Now
					<
					AntiRamLastScan
				then

					RestoreExpired(
						Now
					)

					return
				end

				AntiRamLastScan =
					Now + 0.09

				local OwnVehicle =
					GetOwnVehicle()

				local Params =
					OverlapParams.new()

				Params.FilterType =
					Enum.RaycastFilterType.Exclude

				Params.FilterDescendantsInstances = {
					Character
				}

				local Nearby =
					workspace:GetPartBoundsInRadius(
						MyRoot.Position,
						30,
						Params
					)

				local Threat =
					false

				local ProcessedVehicles =
					{}

				for _, Part in ipairs(
					Nearby
				) do

					local Vehicle =
						FindVehicleModelFromPart(
							Part
						)

					local IsOwnVehicle =
						Vehicle
						and
						OwnVehicle
						and
						(
							Vehicle == OwnVehicle
							or
							Vehicle:IsDescendantOf(
								OwnVehicle
							)
							or
							OwnVehicle:IsDescendantOf(
								Vehicle
							)
						)

					if
						Vehicle
						and
						not IsOwnVehicle
						and
						not
						ProcessedVehicles[
							Vehicle
						]
					then

						ProcessedVehicles[
							Vehicle
						] =
							true

						local VehicleRoot =
							Vehicle:IsA("BasePart")
							and
							Vehicle
							or
							Vehicle.PrimaryPart
							or
							Vehicle:FindFirstChildWhichIsA(
								"VehicleSeat",
								true
							)
							or
							Vehicle:FindFirstChildWhichIsA(
								"BasePart",
								true
							)

						if VehicleRoot then

							local Offset =
								MyRoot.Position
								-
								VehicleRoot.Position

							local Distance =
								Offset.Magnitude

							-- Distância da peça do veículo que realmente entrou
							-- no raio. Isso é importante para ônibus: o centro
							-- pode estar longe, mas uma ponta pode estar em cima.
							local PartDistance =
								(
									Part.Position
									-
									MyRoot.Position
								).Magnitude

							local RelativeVelocity =
								VehicleRoot.AssemblyLinearVelocity
								-
								MyRoot.AssemblyLinearVelocity

							local ClosingSpeed =
								0

							if Distance > 0.001 then

								ClosingSpeed =
									RelativeVelocity:Dot(
										Offset.Unit
									)

							end

							local VehicleSpeed =
								VehicleRoot.AssemblyLinearVelocity.Magnitude

							local IsLTPVehicle =
								Vehicle.Name
								and
								Vehicle.Name:match(
									"^ltp2_car_%d+$"
								)
								~=
								nil

							local TimeToImpact =
								math.huge

							if ClosingSpeed > 0.001 then

								TimeToImpact =
									PartDistance
									/
									ClosingSpeed

							end

							-- "Ram" significa que o veículo está realmente vindo
							-- na direção do personagem, não apenas passando perto.
							local IncomingRam =
								PartDistance <= 14
								and
								ClosingSpeed >= 35
								and
								VehicleSpeed >= 42
								and
								TimeToImpact <= 0.55

							-- As motos/carros ltp2_car_XX recebem uma camada
							-- específica porque a raiz pode ser uma Part invisível.
							local IncomingLTPRam =
								IsLTPVehicle
								and
								PartDistance <= 20
								and
								ClosingSpeed >= 18
								and
								VehicleSpeed >= 25
								and
								TimeToImpact <= 0.90

							local VehicleAngular =
								math.max(
									VehicleRoot.AssemblyAngularVelocity.Magnitude,
									Part.AssemblyAngularVelocity.Magnitude
								)

							-- Velocidade real no ponto da carroceria. Em um ônibus
							-- girando, a raiz pode quase não se mover, mas as pontas
							-- têm uma velocidade tangencial enorme.
							local ContactSpeed =
								0

							pcall(function()

								ContactSpeed =
									VehicleRoot:GetVelocityAtPosition(
										Part.Position
									).Magnitude

							end)

							local VehicleSeat =
								Vehicle:IsA("Model")
								and
								Vehicle:FindFirstChildWhichIsA(
									"VehicleSeat",
									true
								)
								or
								nil

							local Unoccupied =
								VehicleSeat
								and
								VehicleSeat.Occupant == nil
								or
								false

							local Previous =
								AntiRamLastVehiclePosition[
									Vehicle
								]

							local CFrameJump =
								false

							local RotationJump =
								false

							local OscillationAttack =
								false

							local CurrentDelta =
								Previous
								and
								VehicleRoot.Position - Previous.Position
								or
								Vector3.zero

							local ReversalCount =
								Previous
								and
								Previous.ReversalCount
								or
								0

							local ReversalStartedAt =
								Previous
								and
								Previous.ReversalStartedAt

							if Previous then

								local Dt =
									Now
									-
									Previous.Time

								local Moved =
									CurrentDelta.Magnitude

								if
									Dt > 0
									and
									Dt <= 0.25
									and
									Moved >= 8
									and
									PartDistance <= 24
								then

									CFrameJump =
										true

								end

								-- Vai e Vem move o ltp2 em pequenos passos e zera
								-- sua velocidade física. Detecta as reversões repetidas
								-- do CFrame enquanto o veículo permanece perto do jogador.
								if
									IsLTPVehicle
									and
									PartDistance <= 22
									and
									Moved >= 0.35
									and
									Dt <= 0.20
								then

									if
										not ReversalStartedAt
										or
										Now - ReversalStartedAt > 1.5
									then

										ReversalCount = 0
										ReversalStartedAt = Now

									end

									if
										Previous.Delta
										and
										Previous.Delta.Magnitude >= 0.35
										and
										Previous.Delta:Dot(CurrentDelta) < 0
									then

										ReversalCount += 1

									end

									OscillationAttack =
										ReversalCount >= 2
										and
										Now - ReversalStartedAt <= 1.5

								elseif
									ReversalStartedAt
									and
									Now - ReversalStartedAt > 1.5
								then

								ReversalCount = 0
								ReversalStartedAt = nil

								end

								if
									Previous.CFrame
									and
									Dt > 0
									and
									Dt <= 0.25
								then

									pcall(function()

										local Relative =
											Previous.CFrame:ToObjectSpace(
												VehicleRoot.CFrame
											)

										local _, Angle =
											Relative:ToAxisAngle()

										if
											math.abs(Angle)
											>=
											math.rad(20)
											and
											PartDistance <= 24
										then

											RotationJump =
												true

										end

									end)

								end

							end

							local DangerousSpin =
								(
									PartDistance <= 14
									and
									VehicleAngular >= 10
								)
								or
								(
									PartDistance <= 12
									and
									ContactSpeed >= 65
								)
								or
								(
									Unoccupied
									and
									PartDistance <= 10
									and
									VehicleAngular >= 10
								)

							local DangerousApproach =
								IsLTPVehicle
								and
								(
									IncomingRam
									or
									IncomingLTPRam
									or
									(
										PartDistance <= 12
										and
										VehicleSpeed >= 55
									)
									or
									DangerousSpin
									or
									RotationJump
									or
									CFrameJump
									or
									OscillationAttack
								)

							local ThreatScore =
								Previous
								and
								(Previous.ThreatScore or 0)
								or
								0

							if DangerousApproach then
								ThreatScore=
									math.min(
										4,
										ThreatScore+1
									)
							else
								ThreatScore=
									math.max(
										0,
										ThreatScore-1
									)
							end

							local SevereVehicleThreat =
								(
									PartDistance <= 8
									and
									VehicleAngular >= 18
								)
								or
								(
									PartDistance <= 8
									and
									ContactSpeed >= 105
								)
								or
								(
									IncomingRam
									and
									ClosingSpeed >= 48
									and
									VehicleSpeed >= 62
									and
									TimeToImpact <= 0.42
								)
								or
								(
									CFrameJump
									and
									CurrentDelta.Magnitude >= 22
									and
									PartDistance <= 10
								)

							local ConfirmedVehicleThreat =
								DangerousApproach
								and
								(
									SevereVehicleThreat
									or
									IncomingLTPRam
									or
									CFrameJump
									or
									RotationJump
									or
									OscillationAttack
									or
									ThreatScore >= 2
								)

							if ConfirmedVehicleThreat then
								Threat=true

								local ProtectionTime=
									SevereVehicleThreat
									and
									1.35
									or
									0.90

								AntiDefense.VehicleThreatUntil =
									math.max(
										AntiDefense.VehicleThreatUntil or 0,
										Now + ProtectionTime + 0.5
									)

								ProtectVehicle(
									Vehicle,
									Now+ProtectionTime
								)
							end

							AntiRamLastVehiclePosition[
								Vehicle
							] = {
								Position =
									VehicleRoot.Position,

								CFrame =
									VehicleRoot.CFrame,

								Delta =
									CurrentDelta,

								ReversalCount =
									ReversalCount,

								ReversalStartedAt =
									ReversalStartedAt,

								ThreatScore =
									ThreatScore,

								Time =
									Now
							}

						end

					end

				end


				local Linear =
					MyRoot.AssemblyLinearVelocity

				local Horizontal =
					Vector3.new(
						Linear.X,
						0,
						Linear.Z
					).Magnitude

				local Angular =
					MyRoot.AssemblyAngularVelocity.Magnitude

				local Downward =
					Linear.Y

				-- A velocidade definida pelo próprio jogador é movimento esperado.
				-- Ajusta os limites horizontais sem desativar as checagens de giro,
				-- queda ou impulsos muito acima da velocidade configurada.
				local ConfiguredWalkSpeed =
					tonumber(Gui:GetAttribute("CartolaWalkSpeed")) or 16

				local ExpectedWalkSpeed =
					math.max(16, Humanoid.WalkSpeed, ConfiguredWalkSpeed)

				local ThreatHorizontalLimit =
					math.max(48, ExpectedWalkSpeed * 1.45 + 25)

				local SevereHorizontalLimit =
					math.max(82, ExpectedWalkSpeed * 1.55 + 35)

				local ThreatLinearLimit =
					math.max(115, ExpectedWalkSpeed * 1.45 + 45)

				local SevereLinearLimit =
					math.max(170, ExpectedWalkSpeed * 1.55 + 55)

				local RecentThreat =
					Threat
					or
					Now
					<
					(
						AntiDefense.VehicleThreatUntil
						or
						0
					)

				if
					RecentThreat
					and
					not OwnMovement
				then

					if
						Horizontal > ThreatHorizontalLimit
						or
						Linear.Magnitude > ThreatLinearLimit
						or
						Downward < -55
						or
						(
							Angular > 24
							and
							Horizontal > 20
						)
					then

						Recover()

					end

				end

				-- Mesmo se a colisão chegar antes do scan, protege contra
				-- aquele pico típico de veículo/fling.
				if
					RecentThreat
					and
					not OwnMovement
					and
					(
						Horizontal > SevereHorizontalLimit
						or
						Linear.Magnitude > SevereLinearLimit
						or
						Downward < -90
						or
						(
							AntiRamSafeCFrame
							and
							MyRoot.Position.Y
							<
							AntiRamSafeCFrame.Position.Y - 10
						)
						or
						(
							Angular > 40
							and
							Horizontal > 25
						)
					)
				then

					Recover()

				end

				if
					not RecentThreat
					and
					not OwnMovement
					and
					Humanoid.FloorMaterial
					~=
					Enum.Material.Air
					and
					not Humanoid.Sit
					and
					not Humanoid.SeatPart
					and
					Horizontal < math.max(38, ExpectedWalkSpeed * 1.15 + 12)
					and
					Angular < 12
				then

					AntiRamSafeCFrame =
						MyRoot.CFrame

				end

				RestoreExpired(
					Now
				)

			end)

	end

	ProtectionControllers.AntiVeiculo = function(Enabled)

		if Enabled then

			StartAntiRam()

		else

			StopAntiRam()

		end

	end

	Gui.Destroying:Connect(function()

		StopAntiRam()

	end)
end


--============================================================
-- ANTI VOID - INFINITE YIELD
--============================================================

local AntiVoidEnabled = false

local AntiVoidConnection = nil

-- Mantido por compatibilidade com outras partes do hub.
local AntiVoidSafeCFrame = nil

local InfiniteYieldDestroyHeight =
	workspace.FallenPartsDestroyHeight

local AntiVoidStatus =
	Status(
		Pages["Protecoes"],
		"Anti Void: desligado"
	)

local function StopAntiVoid()

	AntiVoidEnabled =
		false

	if AntiVoidConnection then

		pcall(function()
			AntiVoidConnection:Disconnect()
		end)

		AntiVoidConnection =
			nil

	end

	AntiVoidStatus.Text =
		"Anti Void: desligado"

end

local function StartAntiVoid()

	StopAntiVoid()

	AntiVoidEnabled =
		true

	local Root =
		GetRoot()

	if Root then
		AntiVoidSafeCFrame =
			Root.CFrame
	end

	AntiVoidStatus.Text =
		"✅ Anti Void ativo"

	task.wait()

	-- Infinite Yield:
	-- quando chega perto de FallenPartsDestroyHeight, soma impulso vertical.
	AntiVoidConnection =
		RunService.Stepped:Connect(function()

			if not AntiVoidEnabled then
				return
			end

			local RootNow =
				GetRoot()

			if
				RootNow
				and
				RootNow.Position.Y
				<=
				InfiniteYieldDestroyHeight + 25
			then

				RootNow.Velocity =
					RootNow.Velocity
					+
					Vector3.new(
						0,
						250,
						0
					)

			end

		end)

end

ProtectionControllers.AntiVoid = function(Enabled)

	if Enabled then

		StartAntiVoid()

	else

		StopAntiVoid()

	end

end


--============================================================
-- ANTI AFK - INFINITE YIELD
--============================================================

local AntiAFKEnabled = false

local AntiAFKConnection = nil

ProtectionControllers._AntiAFKDisabledConnections =
	ProtectionControllers._AntiAFKDisabledConnections
	or
	{}

-- Mantidos para compatibilidade com o cleanup/respawn do hub.
local ActivityInputBegan = nil
local ActivityInputChanged = nil

local AntiAFKStatus =
	Status(
		Pages["Protecoes"],
		"Anti AFK: desligado"
	)

local function MarkActivity()
	-- Infinite Yield não usa contador próprio.
end

local function StopAntiAFK()

	AntiAFKEnabled =
		false

	if AntiAFKConnection then

		pcall(function()
			AntiAFKConnection:Disconnect()
		end)

		AntiAFKConnection =
			nil

	end

	for Connection in pairs(
		ProtectionControllers._AntiAFKDisabledConnections
	) do
		pcall(function()
			Connection:Enable()
		end)

		ProtectionControllers._AntiAFKDisabledConnections[
			Connection
		]=nil
	end

	AntiAFKStatus.Text =
		"Anti AFK: desligado"

end

local function StartAntiAFK()

	StopAntiAFK()

	AntiAFKEnabled =
		true

	-- Pausa conexões Idled existentes sem destruí-las.
	-- Assim o toggle OFF consegue reativá-las de verdade.
	pcall(function()

		if getconnections then

			for _, Connection in pairs(
				getconnections(Player.Idled)
			) do
				local Success=
					pcall(function()
						Connection:Disable()
					end)

				if Success then
					ProtectionControllers._AntiAFKDisabledConnections[
						Connection
					]=true
				end
			end

		end

	end)

	AntiAFKConnection =
		Player.Idled:Connect(function()

			if not AntiAFKEnabled then
				return
			end

			-- Mesmo comportamento do Infinite Yield:
			-- envia um clique virtual quando Roblox acusa idle.
			pcall(function()

				local VirtualInputManager =
					Instance.new(
						"VirtualInputManager"
					)

				VirtualInputManager:SendMouseButtonEvent(
					0,
					0,
					0,
					true,
					game,
					0
				)

				VirtualInputManager:SendMouseButtonEvent(
					0,
					0,
					0,
					false,
					game,
					0
				)

				VirtualInputManager:Destroy()

			end)

		end)

	AntiAFKStatus.Text =
		"✅ Anti AFK ativo"

end

ProtectionControllers.AntiAFK = function(Enabled)

	if Enabled then
		StartAntiAFK()
	else
		StopAntiAFK()
	end

end


--============================================================
-- ANTI KICK / AUTO REJOIN - INFINITE YIELD
--============================================================

local AntiKickEnabled = false

local AntiKickConnection = nil

local AntiKickStatus =
	Status(
		Pages["Protecoes"],
		"Auto Rejoin: desligado"
	)

local function InfiniteYieldRejoin()

	pcall(function()

		if
			#Players:GetPlayers()
			<=
			1
		then

			Player:Kick(
				"\nRejoining..."
			)

			task.wait(
				0.3
			)

			TeleportService:Teleport(
				game.PlaceId,
				Player
			)

		else

			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				game.JobId,
				Player
			)

		end

	end)

end

local function StopAntiKick()

	AntiKickEnabled =
		false

	if AntiKickConnection then

		pcall(function()
			AntiKickConnection:Disconnect()
		end)

		AntiKickConnection =
			nil

	end

	AntiKickStatus.Text =
		"Auto Rejoin: desligado"

end

local function StartAntiKick()

	StopAntiKick()

	AntiKickEnabled =
		true

	AntiKickStatus.Text =
		"✅ Auto Rejoin ativo"

	-- Infinite Yield:
	-- qualquer mudança de ErrorMessage dispara imediatamente o rejoin.
	AntiKickConnection =
		GuiService.ErrorMessageChanged:Connect(function()

			if not AntiKickEnabled then
				return
			end

			InfiniteYieldRejoin()

		end)

end

ProtectionControllers.AutoRejoin = function(Enabled)

	if Enabled then

		StartAntiKick()

	else

		StopAntiKick()

	end

end


--============================================================
-- CONTROLES DE PROTEÇÃO
--
-- Somente proteções realmente parecidas compartilham uma opção.
--============================================================

--============================================================
-- ANTI TP EM MIM / PULL PARA FRENTE
--
-- Anti TP existente observa outros players teleportando perto de você.
-- Esta camada observa o seu próprio HRP e cobre o padrão do TP infinito
-- na frente: um snap brusco que termina ~3 studs à frente de outro player.
--============================================================

;(function()
	local Enabled = false
	local Connection = nil
	local CharacterConnection = nil
	local LastPosition = nil
	local LastSample = 0
	local SafeCFrame = nil
	local ThreatUntil = 0
	local Recovering = false
	local FrontLockFrames = 0

	local function IsOwnMovement(Humanoid)
		return IsHubMovementActive(Humanoid) or ProtectionRecoveryBusy()
	end

	local function ResetTracking()
		local Root = GetRoot()
		LastPosition = Root and Root.Position or nil
		SafeCFrame = Root and Root.CFrame or nil
		LastSample = os.clock()
		ThreatUntil = 0
		Recovering = false
		FrontLockFrames = 0
		Gui:SetAttribute("AntiFrontPullRecovering", false)
	end

	local function MatchesFrontPull(Root, Moved)
		if Moved < 3.25 then return false end

		for _, Target in ipairs(Players:GetPlayers()) do
			if Target ~= Player then
				local Character = Target.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local TargetRoot = Character and Character:FindFirstChild("HumanoidRootPart")

				if TargetRoot and Humanoid and Humanoid.Health > 0 then
					local Expected = TargetRoot.CFrame * CFrame.new(0, 0, -3)
					local ToExpected = (Root.Position - Expected.Position).Magnitude
					local ToTarget = (Root.Position - TargetRoot.Position).Magnitude

					if ToExpected <= 2.75 and ToTarget <= 6.5 then
						return true
					end
				end
			end
		end

		return false
	end

	local function IsExactlyInFrontOfAnotherPlayer(Root)
		for _, Target in ipairs(Players:GetPlayers()) do
			if Target ~= Player then
				local Character = Target.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local TargetRoot = Character and Character:FindFirstChild("HumanoidRootPart")
				if TargetRoot and Humanoid and Humanoid.Health > 0 then
					local Expected = TargetRoot.CFrame * CFrame.new(0, 0, -3)
					if (Root.Position - Expected.Position).Magnitude <= 1.8 then
						return true
					end
				end
			end
		end
		return false
	end

	local function Recover(Root, Humanoid)
		if Recovering or not SafeCFrame then return end
		Recovering = true
		BeginProtectionRecovery(0.26)
		ThreatUntil = os.clock() + 0.9
		Gui:SetAttribute("AntiFrontPullRecovering", true)

		ClearAllCharacterPhysics()
		pcall(function()
			Humanoid.Sit = false
			Humanoid.PlatformStand = false
			Root.CFrame = SafeCFrame
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
		end)

		LastPosition = SafeCFrame.Position

		task.delay(0.12, function()
			Recovering = false
			Gui:SetAttribute("AntiFrontPullRecovering", false)
		end)
	end

	local function Stop()
		Enabled = false
		if Connection then Connection:Disconnect(); Connection = nil end
		if CharacterConnection then CharacterConnection:Disconnect(); CharacterConnection = nil end
		LastPosition = nil
		SafeCFrame = nil
		ThreatUntil = 0
		Recovering = false
		FrontLockFrames = 0
		Gui:SetAttribute("AntiFrontPullRecovering", false)
	end

	local function Start()
		Stop()
		Enabled = true
		ResetTracking()

		CharacterConnection = Player.CharacterAdded:Connect(function()
			if Enabled then task.defer(ResetTracking) end
		end)

		Connection = RunService.Heartbeat:Connect(function()
			if not Enabled then return end

			local Now = os.clock()

			if
				LastSample > 0
				and
				Now - LastSample < 0.033
			then
				return
			end

			local Root = GetRoot()
			local Humanoid = GetHumanoid()
			if not Root or not Humanoid or Humanoid.Health <= 0 then return end

			local Position = Root.Position
			local Dt = math.max(0.001, Now - LastSample)

			local Delta =
				LastPosition
				and
				(Position - LastPosition)
				or
				Vector3.zero

			-- TP/Pull para frente é movimento horizontal. Queda vertical rápida
			-- não pode ser tratada como snap/teleporte.
			local Moved =
				Vector3.new(
					Delta.X,
					0,
					Delta.Z
				).Magnitude

			local OwnMovement = IsOwnMovement(Humanoid)

			if not LastPosition then
				LastPosition = Position
				SafeCFrame = Root.CFrame
				LastSample = Now
				return
			end

			if not OwnMovement then
				local ConfiguredWalkSpeed =
					tonumber(
						Gui:GetAttribute(
							"CartolaWalkSpeed"
						)
					)
					or
					Humanoid.WalkSpeed
					or
					16

				local ExpectedTravel =
					ConfiguredWalkSpeed
					*
					Dt

				local VelocityNow =
					Root.AssemblyLinearVelocity

				local HorizontalNow =
					Vector3.new(
						VelocityNow.X,
						0,
						VelocityNow.Z
					).Magnitude

				local LegitimateWalk =
					Humanoid.MoveDirection.Magnitude > 0.05
					and
					HorizontalNow
					<=
					math.max(
						35,
						ConfiguredWalkSpeed * 1.4 + 20
					)
					and
					Moved
					<=
					math.max(
						5,
						ExpectedTravel * 2.0 + 5
					)

				local FrontPull =
					not LegitimateWalk
					and
					MatchesFrontPull(
						Root,
						Moved
					)

				local HugeSnap =
					Dt <= 0.22
					and
					Moved
					>=
					math.max(
						10,
						ExpectedTravel * 2.5 + 7
					)

				local RepeatedThreat =
					Now < ThreatUntil
					and
					not LegitimateWalk
					and
					Moved
					>=
					math.max(
						2.5,
						ExpectedTravel * 1.8 + 3
					)

				-- O código de TP infinito zera a velocidade depois de escrever CFrame.
				-- Por isso também detectamos deslocamento sem velocidade física que
				-- permanece exatamente ~3 studs à frente de outro player.

				local KinematicFrontLock =
					Moved >= 0.45
					and HorizontalNow <= 8
					and Humanoid.MoveDirection.Magnitude <= 0.15
					and IsExactlyInFrontOfAnotherPlayer(Root)

				if KinematicFrontLock then
					FrontLockFrames += 1
				else
					FrontLockFrames = 0
				end

				-- HugeSnap isolado pode ser teleporte legítimo do jogo.
				-- Só recupera quando existe o padrão de puxão para a frente
				-- ou repetição da ameaça já confirmada.
				if FrontPull or RepeatedThreat or FrontLockFrames >= 2 then
					FrontLockFrames = 0
					Recover(Root, Humanoid)
					LastSample = Now
					return
				end

				if Now >= ThreatUntil
					and Humanoid.FloorMaterial ~= Enum.Material.Air
					and not Humanoid.Sit
					and not Humanoid.SeatPart
					and HorizontalNow
					<
					math.max(
						45,
						ConfiguredWalkSpeed * 1.35 + 20
					)
					and Moved
					<
					math.max(
						5,
						ExpectedTravel * 1.8 + 4
					)
				then
					SafeCFrame = Root.CFrame
				end
			else
				-- Movimento voluntário do hub: não disputa com Fly/ClickTP/VFly/Órbita.
				SafeCFrame = Root.CFrame
				ThreatUntil = 0
				FrontLockFrames = 0
			end

			LastPosition = Root.Position
			LastSample = Now
		end)
	end

	ProtectionControllers.AntiFrontPull = function(State)
		if State then Start() else Stop() end
	end

	Gui.Destroying:Connect(Stop)
end)()

ProtectionControllers._ActiveStates =
	ProtectionControllers._ActiveStates
	or
	{}

ProtectionControllers.SetGroup = function(
	Names,
	Enabled
)

	for _, Name in ipairs(
		Names
	) do

		local Controller =
			ProtectionControllers[
				Name
			]

		if Controller then

			local Success, Error =
				pcall(
					Controller,
					Enabled
				)

			if Success then
				ProtectionControllers._ActiveStates[
					Name
				] =
					Enabled == true
			else

			end

		end

	end

	local AnyProtectionActive =
		false

	for Name,State in pairs(
		ProtectionControllers._ActiveStates
	) do
		if
			Name~="AntiObjetosTools"
			and
			State==true
		then
			AnyProtectionActive=
				true

			break
		end
	end

	if not AnyProtectionActive then
		ProtectionBusyUntil=
			0

		Gui:SetAttribute(
			"ProtectionRecoveryActive",
			false
		)

		Gui:SetAttribute(
			"AntiFrontPullRecovering",
			false
		)
	end

end


ProtectionControllers.StopAll = function()
	local Names={
		"AntiFling","AntiSit","AntiSitV2","AntiSeatPull","AntiAnchor",
		"AntiRagdoll","AntiBringParts","AntiObjetosTools","AntiExplosao",
		"AntiTP","AntiFrontPull","AntiVeiculo","AntiVoid","AntiAFK","AutoRejoin"
	}

	for _,Name in ipairs(Names) do
		local Controller=ProtectionControllers[Name]
		if type(Controller)=="function" then
			pcall(Controller,false)
		end
		ProtectionControllers._ActiveStates[Name]=false
	end

	ProtectionBusyUntil=0
	Gui:SetAttribute("ProtectionRecoveryActive",false)
	Gui:SetAttribute("AntiFrontPullRecovering",false)
	Gui:SetAttribute("AntiBringPartsEnabled",false)
	Gui:SetAttribute("AntiExplosionEnabled",false)
end

do
	local Ok,Env=pcall(function()
		if type(getgenv)=="function" then return getgenv() end
	end)
	if Ok and type(Env)=="table" then
		Env.CartolaProtectionCleanup=function()
			pcall(ProtectionControllers.StopAll)
		end
	end
end

-- Normalize every protection to OFF on a fresh execution. Besides matching
-- the UI defaults, this restores reversible state left by an interrupted run.
ProtectionControllers.StopAll()

Gui.Destroying:Connect(function()
	pcall(ProtectionControllers.StopAll)

	local Ok,Env=pcall(function()
		if type(getgenv)=="function" then return getgenv() end
	end)
	if Ok and type(Env)=="table" and type(Env.CartolaProtectionCleanup)=="function" then
		Env.CartolaProtectionCleanup=nil
	end
end)

Toggle(
	Pages["Protecoes"],
	"Anti Fling",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiFling"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Sit",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiSit"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Sit V2",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiSitV2"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Seat Pull",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiSeatPull"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Anchor",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiAnchor"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Ragdoll",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiRagdoll"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Bring Parts",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiBringParts"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Bomba",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiExplosao"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti TP",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiTP", "AntiFrontPull"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti CFrame Veículo",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiVeiculo"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti Void",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiVoid"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Anti AFK",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AntiAFK"},
			Enabled
		)

	end
)

Toggle(
	Pages["Protecoes"],
	"Auto Rejoin",
	false,
	function(Enabled)

		ProtectionControllers.SetGroup(
			{"AutoRejoin"},
			Enabled
		)

	end
)


--============================================================

-- POSIÇÕES SALVAS / WAYPOINTS
--
-- Inspirado no conceito de Waypoints do Infinite Yield, mas integrado
-- ao layout do Cartola Hub. Salva nome, CFrame completo e coordenadas.
-- Quando writefile/readfile existem, as posições persistem entre execuções.
--============================================================

Section(
	Pages["Movimento"],
	"Posições salvas"
)

do
	local HttpService = game:GetService("HttpService")
	local SavedPositions = {}
	local PendingSavedTeleport = nil
	local PositionFile = "CartolaHub_Positions.json"
	local AutoNameCounter = 0

	local function PackCFrame(Value)
		return {Value:GetComponents()}
	end

	local function UnpackCFrame(Values)
		if type(Values) ~= "table" or #Values < 12 then return nil end
		local Ok, Result = pcall(function()
			return CFrame.new(table.unpack(Values,1,12))
		end)
		return Ok and Result or nil
	end

	local function PersistPositions()
		if type(writefile) ~= "function" then return end
		local Data = {}
		for Name, Info in pairs(SavedPositions) do
			Data[Name] = {CFrame=PackCFrame(Info.CFrame),SavedAt=Info.SavedAt}
		end
		pcall(function() writefile(PositionFile,HttpService:JSONEncode(Data)) end)
	end

	local function LoadPositions()
		if type(readfile) ~= "function" then return end
		local Ok, Raw = pcall(function()
			if type(isfile) == "function" and not isfile(PositionFile) then return nil end
			return readfile(PositionFile)
		end)
		if not Ok or type(Raw) ~= "string" or Raw == "" then return end
		local DecodeOk, Decoded = pcall(function() return HttpService:JSONDecode(Raw) end)
		if not DecodeOk or type(Decoded) ~= "table" then return end
		for Name, Info in pairs(Decoded) do
			if type(Name) == "string" and type(Info) == "table" then
				local CF = UnpackCFrame(Info.CFrame)
				if CF then
					SavedPositions[Name] = {CFrame=CF,SavedAt=Info.SavedAt or os.time()}
				end
			end
		end
	end

	LoadPositions()

	local PositionPanel = New("Frame",{
		Size=UDim2.new(1,-8,0,340),BackgroundColor3=Theme.Card,BorderSizePixel=0
	},Pages["Movimento"])
	Corner(PositionPanel,9)

	local NameBox = New("TextBox",{
		Size=UDim2.new(1,-138,0,44),Position=UDim2.fromOffset(12,12),
		BackgroundColor3=Theme.Card2,BorderSizePixel=0,Text="",
		PlaceholderText="Nome da posição (opcional)",PlaceholderColor3=Theme.SubText,
		TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14,
		ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left
	},PositionPanel)
	Corner(NameBox,8)
	New("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},NameBox)

	local SaveButton = New("TextButton",{
		Size=UDim2.fromOffset(106,44),Position=UDim2.new(1,-118,0,12),
		BackgroundColor3=Theme.Green,BorderSizePixel=0,AutoButtonColor=false,
		Text="SALVAR",TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=13
	},PositionPanel)
	Corner(SaveButton,8)

	New("TextLabel",{
		Size=UDim2.new(1,-24,0,20),Position=UDim2.fromOffset(12,59),BackgroundTransparency=1,
		Text="Mesmo nome substitui a posição salva",TextColor3=Theme.SubText,
		Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left
	},PositionPanel)

	local PositionList = New("ScrollingFrame",{
		Size=UDim2.new(1,-24,0,246),Position=UDim2.fromOffset(12,82),
		BackgroundColor3=Theme.Background,BackgroundTransparency=0.25,BorderSizePixel=0,
		ScrollBarThickness=4,ScrollBarImageColor3=Theme.SubText,CanvasSize=UDim2.fromOffset(0,0),
		AutomaticCanvasSize=Enum.AutomaticSize.Y
	},PositionPanel)
	Corner(PositionList,8)
	New("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},PositionList)
	New("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},PositionList)

	local function TrimName(Value)
		return tostring(Value or ""):gsub("^%s+",""):gsub("%s+$","")
	end

	local function NextAutoName()
		repeat AutoNameCounter += 1 until SavedPositions["Posição "..tostring(AutoNameCounter)] == nil
		return "Posição "..tostring(AutoNameCounter)
	end

	local function FormatCoords(CF)
		local P = CF.Position
		return string.format("X %.1f  •  Y %.1f  •  Z %.1f",P.X,P.Y,P.Z)
	end

	local function ApplySavedTeleport(Character,TargetCFrame)
		if not Character or not Character.Parent or not TargetCFrame then return false end
		local Root = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Root or not Humanoid or Humanoid.Health <= 0 then return false end

		Gui:SetAttribute("SavedPositionTeleporting",true)
		local Destination = TargetCFrame + Vector3.new(0,3,0)
		pcall(function()
			Humanoid.Sit=false
			Humanoid.PlatformStand=false
			Humanoid.AutoRotate=true
			Root.Anchored=true
			Root.AssemblyLinearVelocity=Vector3.zero
			Root.AssemblyAngularVelocity=Vector3.zero
			Character:PivotTo(Destination)
		end)

		task.spawn(function()
			for _=1,6 do
				RunService.Heartbeat:Wait()
				if not Character.Parent or not Root.Parent then break end
				pcall(function()
					Root.AssemblyLinearVelocity=Vector3.zero
					Root.AssemblyAngularVelocity=Vector3.zero
					Character:PivotTo(Destination)
				end)
			end
			if Root and Root.Parent then pcall(function() Root.Anchored=false end) end
			if Humanoid and Humanoid.Parent then pcall(function()
				Humanoid.Sit=false
				Humanoid.PlatformStand=false
				Humanoid.AutoRotate=true
				Humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end) end
			task.delay(1.25,function() Gui:SetAttribute("SavedPositionTeleporting",false) end)
		end)
		return true
	end

	local function TeleportToSaved(Data)
		if not Data or not Data.CFrame then return end
		local Character = GetCharacter()
		local Humanoid = GetHumanoid()
		if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 then
			PendingSavedTeleport = Data.CFrame
			return
		end
		PendingSavedTeleport=nil
		ApplySavedTeleport(Character,Data.CFrame)
	end

	Player.CharacterAdded:Connect(function(Character)
		if not PendingSavedTeleport then return end
		local Target=PendingSavedTeleport
		PendingSavedTeleport=nil
		task.spawn(function()
			local Root=Character:WaitForChild("HumanoidRootPart",10)
			local Humanoid=Character:WaitForChild("Humanoid",10)
			if Root and Humanoid then
				task.wait(0.15)
				ApplySavedTeleport(Character,Target)
			end
		end)
	end)

	local RefreshSavedPositions
	RefreshSavedPositions = function()
		for _,Child in ipairs(PositionList:GetChildren()) do
			if Child:IsA("Frame") and Child.Name=="SavedPositionRow" then Child:Destroy() end
		end
		local Names={}
		for Name in pairs(SavedPositions) do table.insert(Names,Name) end
		table.sort(Names,function(A,B) return A:lower()<B:lower() end)

		for Index,Name in ipairs(Names) do
			local Data=SavedPositions[Name]
			local Row=New("Frame",{Name="SavedPositionRow",Size=UDim2.new(1,0,0,62),BackgroundColor3=Theme.Card2,BorderSizePixel=0,LayoutOrder=Index},PositionList)
			Corner(Row,8)
			New("TextLabel",{Size=UDim2.new(1,-118,0,28),Position=UDim2.fromOffset(12,5),BackgroundTransparency=1,Text=Name,TextColor3=Theme.Text,Font=Enum.Font.GothamMedium,TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left},Row)
			New("TextLabel",{Size=UDim2.new(1,-118,0,22),Position=UDim2.fromOffset(12,31),BackgroundTransparency=1,Text=FormatCoords(Data.CFrame),TextColor3=Theme.SubText,Font=Enum.Font.Gotham,TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left},Row)

			local GoButton=New("TextButton",{Size=UDim2.fromOffset(54,36),Position=UDim2.new(1,-102,0.5,-18),BackgroundColor3=Theme.Accent,BorderSizePixel=0,AutoButtonColor=false,Text="IR",TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=12},Row)
			Corner(GoButton,7)
			local DeleteButton=New("TextButton",{Size=UDim2.fromOffset(36,36),Position=UDim2.new(1,-42,0.5,-18),BackgroundColor3=Theme.Red,BorderSizePixel=0,AutoButtonColor=false,Text="×",TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=18},Row)
			Corner(DeleteButton,7)

			GoButton.MouseButton1Click:Connect(function() TeleportToSaved(Data) end)
			DeleteButton.MouseButton1Click:Connect(function()
				SavedPositions[Name]=nil
				PersistPositions()
				RefreshSavedPositions()
			end)
		end
	end

	local function SaveCurrentPosition()
		local Root=GetRoot()
		if not Root then return end
		local Name=TrimName(NameBox.Text)
		if Name=="" then Name=NextAutoName() end
		SavedPositions[Name]={CFrame=Root.CFrame,SavedAt=os.time()}
		NameBox.Text=""
		PersistPositions()
		RefreshSavedPositions()
	end

	SaveButton.MouseButton1Click:Connect(SaveCurrentPosition)
	NameBox.FocusLost:Connect(function(EnterPressed) if EnterPressed then SaveCurrentPosition() end end)
	RefreshSavedPositions()
end


--============================================================
-- PERSONAGEM / PRINCIPAL
--============================================================

Section(
	Pages["Jogador"],
	"Personagem"
)

Action(
	Pages["Jogador"],
	"Resetar Personagem",
	function()

		local Humanoid =
			GetHumanoid()

		if Humanoid then

			Humanoid.Health =
				0

		end

	end
)


pcall(function()
	if OP:FindFirstChild("CartolaFastBootStatus") then
		OP.CartolaFastBootStatus.Text = "Carregando movimento..."
	end
end)

task.wait()

--============================================================
-- GOTO / LOOP GOTO - BASE INFINITE YIELD
--============================================================

do
	local GotoPlayer = CreatePlayerSelector(
		Pages["Movimento"],
		"Player do Loop Goto",
		true
	)

	local LoopGotoEnabled=false
	local LoopGotoToken=0
	local LoopGotoTarget=nil

	local function StopLoopGoto()
		LoopGotoEnabled=false
		LoopGotoTarget=nil
		LoopGotoToken+=1
		Gui:SetAttribute("LoopGotoActive",false)
	end

	CartolaPanicRegistry:Register("LoopGoto",StopLoopGoto)

	Toggle(
		Pages["Movimento"],
		"Loop Goto",
		false,
		function(Enabled)
			StopLoopGoto()
			if not Enabled then return end

			local Target=GotoPlayer:GetFirst()
			if not Target then

				return
			end

			local Humanoid=GetHumanoid()
			if Humanoid and Humanoid.SeatPart then
				Humanoid.Sit=false
				task.wait(0.1)
			end

			LoopGotoTarget=Target
			LoopGotoEnabled=true
			Gui:SetAttribute("LoopGotoActive",true)
			local Token=LoopGotoToken

			task.spawn(function()
				repeat
					if not LoopGotoEnabled or Token~=LoopGotoToken then break end
					local CurrentTarget=LoopGotoTarget

					if CurrentTarget and CurrentTarget.Parent==Players then
						local MyRoot=GetRoot()
						local TargetRoot=CurrentTarget.Character
							and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")

						if MyRoot and TargetRoot then
							-- Igual ao loopgoto do Infinite Yield.
							MyRoot.CFrame=TargetRoot.CFrame+Vector3.new(3,1,0)
						end

						task.wait(0)
					else
						StopLoopGoto()
						break
					end
				until not LoopGotoEnabled or Token~=LoopGotoToken
			end)
		end
	)

	Gui.Destroying:Connect(StopLoopGoto)
end

--============================================================
-- SUPER JUMP
--============================================================

local SuperJumpEnabled = false

Toggle(
	Pages["Jogador"],
	"Super Pulo",
	false,
	function(Enabled)

		SuperJumpEnabled =
			Enabled

		local Humanoid =
			GetHumanoid()

		if Humanoid then

			Humanoid.UseJumpPower =
				true

			Humanoid.JumpPower =
				Enabled
				and
				100
				or
				50

		end

	end
)

--============================================================
-- INFINITE JUMP
--============================================================

local InfiniteJumpEnabled = false

local InfiniteJumpConnection = nil

local function StopInfiniteJump()

	InfiniteJumpEnabled =
		false

	if InfiniteJumpConnection then

		InfiniteJumpConnection:Disconnect()

		InfiniteJumpConnection =
			nil

	end

end

local function StartInfiniteJump()

	StopInfiniteJump()

	InfiniteJumpEnabled =
		true

	InfiniteJumpConnection =
		UIS.JumpRequest:Connect(function()

			if not InfiniteJumpEnabled then
				return
			end

			local Humanoid =
				GetHumanoid()

			if
				Humanoid
				and
				Humanoid.Health > 0
			then

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

			end

		end)

end

Toggle(
	Pages["Jogador"],
	"Pulo Infinito",
	false,
	function(Enabled)

		if Enabled then

			StartInfiniteJump()

		else

			StopInfiniteJump()

		end

	end
)

--============================================================
-- VELOCIDADE - LOOP SPEED + FALLBACK DE MOVIMENTO X/Z
--============================================================

local CurrentSpeed = 16

Gui:SetAttribute(
	"CartolaWalkSpeed",
	CurrentSpeed
)

Gui:SetAttribute(
	"CartolaWalkSpeedChangedAt",
	os.clock()
)

Gui:SetAttribute(
	"CartolaSpeedMovementActive",
	false
)

do
	local SpeedHumanoid = nil
	local SpeedPropertyConnection = nil
	local SpeedHeartbeatConnection = nil

	local function DisconnectSpeedProperty()
		if SpeedPropertyConnection then
			SpeedPropertyConnection:Disconnect()
			SpeedPropertyConnection = nil
		end
	end

	local function DisconnectSpeedHeartbeat()
		if SpeedHeartbeatConnection then
			SpeedHeartbeatConnection:Disconnect()
			SpeedHeartbeatConnection = nil
		end
	end

	local function ApplyWalkSpeed()
		local Humanoid = GetHumanoid()

		if
			not Humanoid
			or Humanoid.Health <= 0
		then
			return
		end

		SpeedHumanoid = Humanoid

		if Humanoid.WalkSpeed ~= CurrentSpeed then
			Humanoid.WalkSpeed = CurrentSpeed
		end
	end

	local function ApplyMovementSpeed(DeltaTime)
		if CurrentSpeed <= 16 then
			Gui:SetAttribute(
				"CartolaSpeedMovementActive",
				false
			)

			return
		end

		local Humanoid = GetHumanoid()
		local Root = GetRoot()

		if
			not Humanoid
			or
			not Root
			or
			Humanoid.Health <= 0
			or
			Humanoid.Sit
			or
			Humanoid.SeatPart
			or
			Humanoid.PlatformStand
			or
			FlingRunning
			or
			FlyEnabled
			or
			Gui:GetAttribute("CFrameFlyActive") == true
			or
			Gui:GetAttribute("VFlyActive") == true
			or
			Gui:GetAttribute("SwimActive") == true
			or
			Gui:GetAttribute("VehicleFlingActive") == true
			or
			Gui:GetAttribute("OrbitSelfActive") == true
			or
			Gui:GetAttribute("FollowBabycarActive") == true
			or
			Gui:GetAttribute("FoldingTableFollowActive") == true
		then
			Gui:SetAttribute(
				"CartolaSpeedMovementActive",
				false
			)

			return
		end

		local Move =
			Humanoid.MoveDirection

		if Move.Magnitude <= 0.01 then
			Gui:SetAttribute(
				"CartolaSpeedMovementActive",
				false
			)

			return
		end

		Gui:SetAttribute(
			"CartolaSpeedMovementActive",
			true
		)

		local Direction =
			Move.Unit

		local Velocity =
			Root.AssemblyLinearVelocity

		local HorizontalVelocity =
			Vector3.new(
				Velocity.X,
				0,
				Velocity.Z
			)

		-- Mede quanto da velocidade atual já está realmente indo na direção
		-- escolhida pelo jogador. O servidor pode limitar WalkSpeed/velocidade;
		-- nesse caso completamos somente a parte que estiver faltando.
		local CurrentForwardSpeed =
			math.max(
				0,
				HorizontalVelocity:Dot(
					Direction
				)
			)

		local MissingSpeed =
			math.max(
				0,
				CurrentSpeed
				-
				CurrentForwardSpeed
			)

		local Dt =
			math.clamp(
				tonumber(DeltaTime)
				or
				(1 / 60),
				0,
				0.05
			)

		if MissingSpeed > 0.25 then
			local Extra =
				Direction
				*
				MissingSpeed
				*
				Dt

			-- Move somente X/Z. O eixo Y permanece 100% natural para
			-- pulo, queda e gravidade.
			Root.CFrame =
				Root.CFrame
				+
				Vector3.new(
					Extra.X,
					0,
					Extra.Z
				)
		end
	end

	local function BindWalkSpeed()
		DisconnectSpeedProperty()

		local Humanoid = GetHumanoid()
		if not Humanoid then
			return
		end

		SpeedHumanoid = Humanoid
		ApplyWalkSpeed()

		-- Igual à ideia do loopspeed do Infinite Yield:
		-- se o jogo tentar resetar WalkSpeed, reaplica o valor escolhido.
		SpeedPropertyConnection =
			Humanoid:GetPropertyChangedSignal(
				"WalkSpeed"
			):Connect(function()

				if
					Humanoid == SpeedHumanoid
					and Humanoid.Parent
					and Humanoid.Health > 0
					and Humanoid.WalkSpeed ~= CurrentSpeed
				then
					Humanoid.WalkSpeed = CurrentSpeed
					BeginProtectionRecovery(0.18)
				end

			end)
	end

	Slider(
		Pages["Jogador"],
		"Velocidade",
		16,
		500,
		16,
		function(Value)

			CurrentSpeed =
				math.clamp(
					tonumber(Value) or 16,
					16,
					500
				)

			Gui:SetAttribute(
				"CartolaWalkSpeed",
				CurrentSpeed
			)

			Gui:SetAttribute(
				"CartolaWalkSpeedChangedAt",
				os.clock()
			)

			ApplyWalkSpeed()
			BeginProtectionRecovery(0.55)

		end
	)

	Player.CharacterAdded:Connect(function(Character)
		task.spawn(function()
			local Humanoid =
				Character:WaitForChild(
					"Humanoid",
					10
				)

			if not Humanoid then
				return
			end

			task.wait(0.08)
			BindWalkSpeed()
			BeginProtectionRecovery(0.22)
		end)
	end)

	BindWalkSpeed()

	SpeedHeartbeatConnection =
		RunService.Heartbeat:Connect(function(DeltaTime)
			if CurrentSpeed <= 16 then
				if
					Gui:GetAttribute(
						"CartolaSpeedMovementActive"
					)
					==
					true
				then
					Gui:SetAttribute(
						"CartolaSpeedMovementActive",
						false
					)
				end

				return
			end

			ApplyWalkSpeed()
			ApplyMovementSpeed(
				DeltaTime
			)
		end)

	Gui.Destroying:Connect(function()
		Gui:SetAttribute(
			"CartolaSpeedMovementActive",
			false
		)

		DisconnectSpeedProperty()
		DisconnectSpeedHeartbeat()
	end)
end

--============================================================
-- CONTROL MODULE
--============================================================

local ControlModule = nil

pcall(function()

	ControlModule =
		require(

			Player
			:WaitForChild(
				"PlayerScripts"
			)
			:WaitForChild(
				"PlayerModule"
			)
			:WaitForChild(
				"ControlModule"
			)

		)

end)

--============================================================
-- FLY
--============================================================

Section(
	Pages["Jogador"],
	"Fly"
)

local FlySpeed = 75

local FlyVelocity = nil

local FlyGyro = nil

local FlyConnection = nil

local function RemoveFlyObjects()

	if FlyConnection then

		FlyConnection:Disconnect()

		FlyConnection = nil

	end

	if FlyVelocity then

		FlyVelocity:Destroy()

		FlyVelocity = nil

	end

	if FlyGyro then

		FlyGyro:Destroy()

		FlyGyro = nil

	end

	local Humanoid =
		GetHumanoid()

	local Root =
		GetRoot()

	if Humanoid then

		Humanoid.PlatformStand =
			false

		Humanoid.AutoRotate =
			true

		Humanoid.Jump =
			false

		-- Não usa GettingUp ao sair do Fly. Esse estado pode aplicar um
		-- pequeno impulso para cima e, junto das proteções, deixar o
		-- personagem repetindo a animação de pulo sem voltar a cair.
		pcall(function()
			if Humanoid.FloorMaterial == Enum.Material.Air then
				Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			else
				Humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)

	end

	if Root then

		-- BodyVelocity deixa a última velocidade aplicada na assembly por
		-- alguns executores. Remove apenas o impulso vertical positivo e
		-- reconstrói o movimento horizontal normal do Humanoid.
		local Horizontal = Vector3.zero

		if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
			Horizontal = Humanoid.MoveDirection * CurrentSpeed
		end

		Root.AssemblyLinearVelocity = Vector3.new(
			Horizontal.X,
			math.min(Root.AssemblyLinearVelocity.Y,0),
			Horizontal.Z
		)

		Root.AssemblyAngularVelocity = Vector3.zero

	end

end

local function StopFly()

	FlyEnabled = false

	Gui:SetAttribute(
		"FlyRecoveryActive",
		true
	)

	Gui:SetAttribute(
		"FlightExitRecoveryActive",
		true
	)

	RemoveFlyObjects()

	-- Remove movers órfãos, mas não escreve velocidade/estado do Humanoid.
	local CharacterNow = GetCharacter()
	if CharacterNow then
		for _, Object in ipairs(CharacterNow:GetDescendants()) do
			if
				(Object.Name == "CartolaFlyVelocity" and Object:IsA("BodyVelocity"))
				or
				(Object.Name == "CartolaFlyGyro" and Object:IsA("BodyGyro"))
			then
				pcall(function()
					Object:Destroy()
				end)
			end
		end
	end

	local Humanoid =
		GetHumanoid()

	if Humanoid then
		-- Mesmo princípio do NOFLY do Infinite Yield:
		-- somente libera PlatformStand.
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
	end

	pcall(function()
		workspace.CurrentCamera.CameraType =
			Enum.CameraType.Custom
	end)

	task.delay(0.25, function()
		Gui:SetAttribute(
			"FlyRecoveryActive",
			false
		)

		Gui:SetAttribute(
			"FlightExitRecoveryActive",
			false
		)
	end)

end

local function StartFly(
	KeepFlag
)

	RemoveFlyObjects()

	if not KeepFlag then

		FlyEnabled = true

	end

	local Root =
		GetRoot()

	local Humanoid =
		GetHumanoid()

	if
		not Root
		or
		not Humanoid
	then

		FlyEnabled = false

		return
	end

	-- Fly é um movimento intencional: sai de qualquer Seat antes de ativar
	-- PlatformStand, evitando SeatWeld/Seat Lock disputando o HRP.
	pcall(function()
		Humanoid.Sit = false
	end)

	Humanoid.PlatformStand =
		true

	Humanoid.AutoRotate =
		false

	FlyVelocity =
		Instance.new(
			"BodyVelocity"
		)

	FlyVelocity.Name =
		"CartolaFlyVelocity"

	FlyVelocity.MaxForce =
		Vector3.new(
			9e9,
			9e9,
			9e9
		)

	FlyVelocity.P =
		10000

	FlyVelocity.Velocity =
		Vector3.zero

	FlyVelocity.Parent =
		Root

	FlyGyro =
		Instance.new(
			"BodyGyro"
		)

	FlyGyro.Name =
		"CartolaFlyGyro"

	FlyGyro.MaxTorque =
		Vector3.new(
			9e9,
			9e9,
			9e9
		)

	FlyGyro.P =
		10000

	FlyGyro.D =
		500

	FlyGyro.Parent =
		Root

	FlyConnection =
		RunService.RenderStepped:Connect(function()

			if not FlyEnabled then
				return
			end

			local Root =
				GetRoot()

			local Humanoid =
				GetHumanoid()

			local Camera =
				workspace.CurrentCamera

			if
				not Root
				or
				not Humanoid
				or
				not Camera
				or
				not FlyVelocity
				or
				not FlyGyro
			then

				return
			end

			local MoveVector =
				Vector3.zero

			if ControlModule then

				MoveVector =
					ControlModule:GetMoveVector()

			end

			local Direction =

				Camera.CFrame.RightVector
				*
				MoveVector.X

				-

				Camera.CFrame.LookVector
				*
				MoveVector.Z

			-- PC

			if UIS:IsKeyDown(
				Enum.KeyCode.Space
			) then

				Direction +=
					Vector3.yAxis

			end

			if
				UIS:IsKeyDown(
					Enum.KeyCode.LeftControl
				)
				or
				UIS:IsKeyDown(
					Enum.KeyCode.C
				)
			then

				Direction -=
					Vector3.yAxis

			end

			if Direction.Magnitude > 1 then

				Direction =
					Direction.Unit

			end

			FlyVelocity.Velocity =
				Direction
				*
				FlySpeed

			local Look =
				Camera.CFrame.LookVector

			FlyGyro.CFrame =
				CFrame.lookAt(

					Root.Position,

					Root.Position
					+
					Look

				)

		end)

end

Toggle(
	Pages["Jogador"],
	"Fly",
	false,
	function(Enabled)

		FlyEnabled =
			Enabled

		if Enabled then

			StartFly(true)

		else

			StopFly()

		end

	end
)

Slider(
	Pages["Jogador"],
	"Velocidade do Fly",
	10,
	1000,
	75,
	function(Value)

		FlySpeed =
			Value

	end
)

Section(
	Pages["Jogador"],
	"CFly"
)

--============================================================
-- CFRAME FLY / CFLY - INFINITE YIELD
--
-- Baseado diretamente no cframefly/cfly do Infinite Yield:
--   • Humanoid.PlatformStand = true;
--   • Head.Anchored = true;
--   • movimento via Humanoid.MoveDirection;
--   • Heartbeat + deltaTime;
--   • direção transformada pela orientação da câmera;
--   • ao desligar, libera Head e PlatformStand.
--============================================================

do
	local CFlyEnabled = false
	local CFlySpeed = 50
	local CFlyConnection = nil
	local CFlyHead = nil
	local CFlyHumanoid = nil

	local function StopCFly()
		local WasEnabled = CFlyEnabled
		CFlyEnabled = false

		if WasEnabled then
			Gui:SetAttribute(
				"FlightExitRecoveryActive",
				true
			)
		end

		if CFlyConnection then
			CFlyConnection:Disconnect()
			CFlyConnection = nil
		end

		local Humanoid =
			CFlyHumanoid
			or
			GetHumanoid()

		local Head =
			CFlyHead

		if
			not Head
			or not Head.Parent
		then
			local Character =
				GetCharacter()

			Head =
				Character
				and
				Character:FindFirstChild(
					"Head"
				)
		end

		-- Igual ao uncfly do Infinite Yield.
		if Humanoid then
			Humanoid.PlatformStand = false
		end

		if Head then
			pcall(function()
				Head.Anchored = false
			end)
		end

		CFlyHead = nil
		CFlyHumanoid = nil

		Gui:SetAttribute(
			"CFrameFlyActive",
			false
		)

		if WasEnabled then
			task.delay(0.25, function()
				Gui:SetAttribute(
					"FlightExitRecoveryActive",
					false
				)
			end)
		end
	end

	CartolaPanicRegistry:Register(
		"CFly",
		StopCFly
	)

	local function StartCFly()
		StopView()

		if FlingRunning then
			StopFling(true)
		end

		if FlyEnabled then
			FlyEnabled = false
			StopFly()
		end

		StopCFly()

		local Character =
			GetCharacter()

		local Humanoid =
			GetHumanoid()

		if
			not Character
			or not Humanoid
			or Humanoid.Health <= 0
		then
			return false
		end

		local Head =
			Character:FindFirstChild("Head")
			or
			Character:WaitForChild(
				"Head",
				5
			)

		if not Head then
			return false
		end

		CFlyEnabled = true
		CFlyHead = Head
		CFlyHumanoid = Humanoid

		Gui:SetAttribute(
			"CFrameFlyActive",
			true
		)

		-- Infinite Yield: PlatformStand + Head.Anchored.
		Humanoid.Sit = false
		Humanoid.PlatformStand = true
		Head.Anchored = true

		CFlyConnection =
			RunService.Heartbeat:Connect(function(
				DeltaTime
			)

				if
					not CFlyEnabled
					or not Character.Parent
					or Player.Character ~= Character
					or not Head.Parent
					or not Humanoid.Parent
					or Humanoid.Health <= 0
				then
					StopCFly()
					return
				end

				-- Infinite Yield:
				-- MoveDirection * (CFspeed * deltaTime)
				local MoveDirection =
					Humanoid.MoveDirection
					*
					(
						CFlySpeed
						*
						DeltaTime
					)

				local HeadCFrame =
					Head.CFrame

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				local CameraCFrame =
					Camera.CFrame

				local CameraOffset =
					HeadCFrame
					:ToObjectSpace(
						CameraCFrame
					)
					.Position

				CameraCFrame =
					CameraCFrame
					*
					CFrame.new(
						-CameraOffset.X,
						-CameraOffset.Y,
						-CameraOffset.Z + 1
					)

				local CameraPosition =
					CameraCFrame.Position

				local HeadPosition =
					HeadCFrame.Position

				local ObjectSpaceVelocity =
					CFrame.new(
						CameraPosition,
						Vector3.new(
							HeadPosition.X,
							CameraPosition.Y,
							HeadPosition.Z
						)
					)
					:VectorToObjectSpace(
						MoveDirection
					)

				Head.CFrame =
					CFrame.new(
						HeadPosition
					)
					*
					(
						CameraCFrame
						-
						CameraPosition
					)
					*
					CFrame.new(
						ObjectSpaceVelocity
					)

			end)

		return true
	end

	Toggle(
		Pages["Jogador"],
		"CFly",
		false,
		function(Enabled)

			if Enabled then
				if not StartCFly() then
					StopCFly()
				end
			else
				StopCFly()
			end

		end
	)

	Slider(
		Pages["Jogador"],
		"Velocidade CFly",
		1,
		1000,
		50,
		function(Value)

			CFlySpeed =
				math.max(
					1,
					tonumber(Value) or 50
				)

		end
	)

	Player.CharacterAdded:Connect(function()
		if CFlyEnabled then
			StopCFly()
		end
	end)

	Gui.Destroying:Connect(function()
		StopCFly()
	end)
end

--============================================================
-- FERRAMENTAS
--============================================================

Section(
	Pages["Movimento"],
	"Movimento"
)

Toggle(
	Pages["Movimento"],
	"Noclip",
	false,
	function(Enabled)

		ManualNoclip =
			Enabled

		if not NeedsNoclip() then

			RestoreCollision()

		end

	end
)

--============================================================
-- CLICK TP (PC + MOBILE)
--============================================================
-- PC: segure Ctrl e clique no mundo.
-- Celular/tablet: com a opção ligada, toque no mundo.
-- Usa Mouse.Hit como caminho rápido e TouchTap + raycast como
-- fallback confiável para executores mobile que não disparam
-- Mouse.Button1Down em toques.
--============================================================

do
	local ClickTP = {
		Enabled = false,
		Mouse = Player:GetMouse(),
		MouseConnection = nil,
		TouchConnection = nil,
		Busy = false
	}

	ClickTP.Stop = function()
		ClickTP.Enabled = false
		ClickTP.Busy = false
		if ClickTP.MouseConnection then
			ClickTP.MouseConnection:Disconnect()
			ClickTP.MouseConnection = nil
		end
		if ClickTP.TouchConnection then
			ClickTP.TouchConnection:Disconnect()
			ClickTP.TouchConnection = nil
		end
		Gui:SetAttribute("SavedPositionTeleporting", false)
	end

	ClickTP.Teleport = function(WorldPosition)
		if not ClickTP.Enabled or ClickTP.Busy or not WorldPosition then return end

		local Character = GetCharacter()
		local Root = GetRoot()
		local Humanoid = GetHumanoid()
		if not Character or not Root or not Humanoid or Humanoid.Health <= 0 then return end

		ClickTP.Busy = true
		Gui:SetAttribute("SavedPositionTeleporting", true)

		local Height = math.max(3, (Humanoid.HipHeight or 2) + 1.5)
		local Destination = CFrame.new(WorldPosition + Vector3.new(0, Height, 0)) * Root.CFrame.Rotation

		pcall(function()
			Humanoid.Sit = false
			Humanoid.PlatformStand = false
			Humanoid.AutoRotate = true
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
			Character:PivotTo(Destination)
		end)

		-- Segura por poucos frames para evitar que física/proteções do jogo
		-- devolvam o personagem imediatamente, sem usar Anchored.
		task.spawn(function()
			for _ = 1, 4 do
				RunService.Heartbeat:Wait()
				if not ClickTP.Enabled or not Character.Parent or not Root.Parent then break end
				pcall(function()
					Root.AssemblyLinearVelocity = Vector3.zero
					Root.AssemblyAngularVelocity = Vector3.zero
					Character:PivotTo(Destination)
				end)
			end

			if Humanoid and Humanoid.Parent then
				pcall(function()
					Humanoid.Sit = false
					Humanoid.PlatformStand = false
					Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end

			ClickTP.Busy = false
			task.delay(0.65, function()
				if Gui and Gui.Parent then
					Gui:SetAttribute("SavedPositionTeleporting", false)
				end
			end)
		end)
	end

	ClickTP.Touch = function(TouchPositions)
		if not ClickTP.Enabled or not UIS.TouchEnabled then return end

		local ScreenPosition = TouchPositions and TouchPositions[1]
		local Camera = workspace.CurrentCamera
		if not ScreenPosition or not Camera then return end

		-- Não teleporta ao tocar nos próprios botões do hub.
		local Ok, Objects = pcall(function()
			return PlayerGui:GetGuiObjectsAtPosition(ScreenPosition.X, ScreenPosition.Y)
		end)
		if Ok and Objects then
			for _, Object in ipairs(Objects) do
				if Object == Gui or Object:IsDescendantOf(Gui) then
					return
				end
			end
		end

		local Ray = Camera:ScreenPointToRay(ScreenPosition.X, ScreenPosition.Y)
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = GetCharacter() and {GetCharacter()} or {}
		Params.IgnoreWater = false

		local Result = workspace:Raycast(Ray.Origin, Ray.Direction * 5000, Params)
		if Result then
			ClickTP.Teleport(Result.Position)
		else
			local Hit = ClickTP.Mouse.Hit
			if Hit then ClickTP.Teleport(Hit.Position) end
		end
	end

	Toggle(Pages["Movimento"], "Click TP", false, function(Enabled)
		ClickTP.Stop()
		if not Enabled then return end

		ClickTP.Enabled = true

		ClickTP.MouseConnection = ClickTP.Mouse.Button1Down:Connect(function()
			if not ClickTP.Enabled then return end

			-- No desktop exige Ctrl. No mobile, alguns executores convertem toque
			-- em Button1Down, então este caminho também funciona como fallback.
			if not UIS.TouchEnabled then
				if not UIS:IsKeyDown(Enum.KeyCode.LeftControl)
					and not UIS:IsKeyDown(Enum.KeyCode.RightControl) then
					return
				end
			end

			local Hit = ClickTP.Mouse.Hit
			if Hit then ClickTP.Teleport(Hit.Position) end
		end)

		if UIS.TouchEnabled then
			-- Defer evita capturar o mesmo toque usado para ligar o toggle.
			task.defer(function()
				if not ClickTP.Enabled then return end
				ClickTP.TouchConnection = UIS.TouchTap:Connect(ClickTP.Touch)
			end)
		end
	end)

	Gui.Destroying:Connect(ClickTP.Stop)
end

--============================================================
-- SWIM / NADAR NO AR - ESTÁVEL
--
-- O tremor vinha de forçar ChangeState(Swimming) em todo Heartbeat enquanto
-- o Humanoid tentava voltar para Freefall/Running. Agora o estado Swimming é
-- aplicado uma vez e os estados que competem com ele ficam desativados apenas
-- enquanto Swim estiver ligado.
--============================================================

do
	local SwimEnabled =
		false

	local SwimConnection =
		nil

	local SwimJumpConnection =
		nil

	local SwimGravity =
		nil

	local SwimSpeed =
		35

	local SwimUpUntil =
		0

	local SwimHumanoid =
		nil

	local SwimStateBackup =
		{}

	local CompetitiveStates = {
		Enum.HumanoidStateType.Jumping,
		Enum.HumanoidStateType.Freefall,
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.RunningNoPhysics,
		Enum.HumanoidStateType.Landed,
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Climbing,
		Enum.HumanoidStateType.Seated
	}

	local function RestoreSwimStates()
		local Humanoid =
			SwimHumanoid

		if
			Humanoid
			and
			Humanoid.Parent
		then
			for State, WasEnabled in pairs(
				SwimStateBackup
			) do
				pcall(function()
					Humanoid:SetStateEnabled(
						State,
						WasEnabled
					)
				end)
			end

			pcall(function()
				Humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Swimming,
					true
				)
			end)

			Humanoid.PlatformStand =
				false

			Humanoid.AutoRotate =
				true

			Humanoid.Jump =
				false
		end

		SwimHumanoid =
			nil

		SwimStateBackup =
			{}
	end

	local function StopSwim()
		SwimEnabled =
			false

		Gui:SetAttribute(
			"SwimActive",
			false
		)

		if SwimConnection then
			SwimConnection:Disconnect()
			SwimConnection =
				nil
		end

		if SwimJumpConnection then
			SwimJumpConnection:Disconnect()
			SwimJumpConnection =
				nil
		end

		if SwimGravity ~= nil then
			workspace.Gravity =
				SwimGravity

			SwimGravity =
				nil
		end

		local Root =
			GetRoot()

		RestoreSwimStates()

		local Humanoid =
			GetHumanoid()

		if Root then
			Root.AssemblyLinearVelocity =
				Vector3.new(
					Root.AssemblyLinearVelocity.X,
					math.min(
						Root.AssemblyLinearVelocity.Y,
						0
					),
					Root.AssemblyLinearVelocity.Z
				)

			Root.AssemblyAngularVelocity =
				Vector3.zero
		end

		if Humanoid then
			pcall(function()
				if
					Humanoid.FloorMaterial
					==
					Enum.Material.Air
				then
					Humanoid:ChangeState(
						Enum.HumanoidStateType.Freefall
					)
				else
					Humanoid:ChangeState(
						Enum.HumanoidStateType.Running
					)
				end
			end)
		end
	end

	local function StartSwim()
		StopSwim()

		local Humanoid =
			GetHumanoid()

		local Root =
			GetRoot()

		if
			not Humanoid
			or
			not Root
			or
			Humanoid.Health <= 0
		then
			return false
		end

		SwimHumanoid =
			Humanoid

		SwimGravity =
			workspace.Gravity

		workspace.Gravity =
			0

		SwimStateBackup =
			{}

		for _, State in ipairs(
			CompetitiveStates
		) do
			SwimStateBackup[State] =
				Humanoid:GetStateEnabled(
					State
				)

			pcall(function()
				Humanoid:SetStateEnabled(
					State,
					false
				)
			end)
		end

		pcall(function()
			Humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Swimming,
				true
			)

			Humanoid:ChangeState(
				Enum.HumanoidStateType.Swimming
			)
		end)

		Humanoid.PlatformStand =
			false

		Humanoid.AutoRotate =
			true

		Humanoid.Jump =
			false

		SwimEnabled =
			true

		Gui:SetAttribute(
			"SwimActive",
			true
		)

		SwimJumpConnection =
			UIS.JumpRequest:Connect(function()
				if SwimEnabled then
					SwimUpUntil =
						os.clock()
						+
						0.18
				end
			end)

		SwimConnection =
			RunService.Heartbeat:Connect(function(
				DeltaTime
			)
				if not SwimEnabled then
					return
				end

				local CurrentHumanoid =
					GetHumanoid()

				local CurrentRoot =
					GetRoot()

				if
					not CurrentHumanoid
					or
					not CurrentRoot
					or
					CurrentHumanoid
					~=
					SwimHumanoid
					or
					CurrentHumanoid.Health
					<=
					0
				then
					StopSwim()
					return
				end

				CurrentHumanoid.Jump =
					false

				local Move =
					CurrentHumanoid.MoveDirection

				local Vertical =
					0

				if
					os.clock()
					<
					SwimUpUntil
					or
					UIS:IsKeyDown(
						Enum.KeyCode.Space
					)
				then
					Vertical =
						SwimSpeed

				elseif
					UIS:IsKeyDown(
						Enum.KeyCode.LeftControl
					)
					or
					UIS:IsKeyDown(
						Enum.KeyCode.C
					)
				then
					Vertical =
						-SwimSpeed
				end

				local TargetVelocity =
					Vector3.new(
						Move.X
						*
						SwimSpeed,
						Vertical,
						Move.Z
						*
						SwimSpeed
					)

				local Alpha =
					math.clamp(
						DeltaTime
						*
						12,
						0,
						1
					)

				CurrentRoot.AssemblyLinearVelocity =
					CurrentRoot.AssemblyLinearVelocity:Lerp(
						TargetVelocity,
						Alpha
					)

				CurrentRoot.AssemblyAngularVelocity =
					Vector3.zero
			end)

		return true
	end

	Toggle(
		Pages["Movimento"],
		"Swim",
		false,
		function(Enabled)
			if Enabled then
				if not StartSwim() then
					StopSwim()
				end
			else
				StopSwim()
			end
		end
	)

	Slider(
		Pages["Movimento"],
		"Velocidade Swim",
		10,
		120,
		35,
		function(Value)
			SwimSpeed =
				Value
		end
	)

	CartolaPanicRegistry:Register(
		"Swim",
		StopSwim
	)

	Player.CharacterAdded:Connect(function()
		if SwimEnabled then
			StopSwim()
		end
	end)

	Gui.Destroying:Connect(
		StopSwim
	)
end

--============================================================
-- FLYFLING - FLY + WALKFLING

Section(
	Pages["Jogador"],
	"FlyFling"
)

--
-- O Infinite Yield implementa FlyFling combinando um modo de voo com
-- WalkFling. Nesta versão, o Fly do Cartola é realmente ativado antes do
-- WalkFling e o WalkFling permite PlatformStand enquanto FlyFling estiver ativo.
--============================================================

do
	local Enabled =
		false

	local FlyFlingSpeed =
		90

	local PreviousFlySpeed =
		nil

	local StartedFly =
		false

	local StartedWalkFling =
		false

	local function StopFlyFling()
		local WasEnabled =
			Enabled

		Enabled =
			false

		Gui:SetAttribute(
			"FlyFlingActive",
			false
		)

		if
			StartedWalkFling
			and
			StopWalkFling
		then
			StopWalkFling()
		end

		StartedWalkFling =
			false

		if
			StartedFly
			and
			FlyEnabled
		then
			StopFly()
		end

		StartedFly =
			false

		if PreviousFlySpeed ~= nil then
			FlySpeed =
				PreviousFlySpeed

			PreviousFlySpeed =
				nil
		end

		if WasEnabled then
			local Root =
				GetRoot()

			if Root then
				Root.AssemblyAngularVelocity =
					Vector3.zero
			end
		end
	end

	local function StartFlyFling()
		StopFlyFling()

		if FlingRunning then
			StopFling(
				false
			)
		end

		local Root =
			GetRoot()

		local Humanoid =
			GetHumanoid()

		if
			not Root
			or
			not Humanoid
			or
			Humanoid.Health <= 0
		then
			return false
		end

		PreviousFlySpeed =
			FlySpeed

		FlySpeed =
			FlyFlingSpeed

		Enabled =
			true

		Gui:SetAttribute(
			"FlyFlingActive",
			true
		)

		if not FlyEnabled then
			FlyEnabled =
				true

			StartedFly =
				true

			StartFly(
				true
			)
		end

		if not WalkFlingEnabled then
			StartedWalkFling =
				true

			StartWalkFling()
		end

		if
			not FlyEnabled
			or
			not WalkFlingEnabled
		then
			StopFlyFling()
			return false
		end

		return true
	end

	Toggle(
		Pages["Jogador"],
		"FlyFling",
		false,
		function(State)
			if State then
				if not StartFlyFling() then
					StopFlyFling()
				end
			else
				StopFlyFling()
			end
		end
	)

	Slider(
		Pages["Jogador"],
		"Velocidade FlyFling",
		20,
		300,
		90,
		function(Value)
			FlyFlingSpeed =
				Value

			if Enabled then
				FlySpeed =
					Value
			end
		end
	)

	CartolaPanicRegistry:Register(
		"FlyFling",
		StopFlyFling
	)

	Player.CharacterAdded:Connect(function()
		if Enabled then
			StopFlyFling()
		end
	end)

	Gui.Destroying:Connect(
		StopFlyFling
	)
end

--============================================================
-- BRING PARTS NO PLAYER
--
-- Motor baseado diretamente no Super Ring Parts enviado:
-- • RetainPart nas BaseParts não ancoradas;
-- • CustomPhysicalProperties = 0;
-- • CanCollide = false;
-- • lista atualizada por DescendantAdded/DescendantRemoving;
-- • SimulationRadius alto;
-- • Velocity contínua calculada em torno do alvo selecionado.
--============================================================

Section(
	Principal,
	"Bring Parts no Player"
)

do
	local TargetSelector =
		CreatePlayerSelector(
			Principal,
			"Player do Bring Parts",
			true,
			true
		)

	local Enabled =
		false

	local Radius =
		4

	-- Mantém as peças perto do torso do alvo.
	local Height =
		3

	local RotationSpeed =
		0.5

	local AttractionStrength =
		1000

	local NetworkVelocity =
		Vector3.new(
			14.46262424,
			14.46262424,
			14.46262424
		)

	local Parts = {}

	local PartIndex =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local Original =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local AddedConnection =
		nil

	local RemovingConnection =
		nil

	local HeartbeatConnection =
		nil

	local ScanToken =
		0

	local function IsCharacterPart(
		Part
	)
		local Model =
			Part
			and
			Part:FindFirstAncestorOfClass(
				"Model"
			)

		return
			Model
			and
			Model:FindFirstChildOfClass(
				"Humanoid"
			)
			~=
			nil
	end

	local function BackupPart(
		Part
	)
		if Original[Part] then
			return
		end

		local Data = {}

		pcall(function()
			Data.CustomPhysicalProperties =
				Part.CustomPhysicalProperties
		end)

		pcall(function()
			Data.CanCollide =
				Part.CanCollide
		end)

		pcall(function()
			Data.CanTouch =
				Part.CanTouch
		end)

		pcall(function()
			Data.LinearVelocity =
				Part.AssemblyLinearVelocity
		end)

		pcall(function()
			Data.AngularVelocity =
				Part.AssemblyAngularVelocity
		end)

		Original[Part] =
			Data
	end

	local function RetainPart(
		Part
	)
		if
			not Enabled
			or
			typeof(Part) ~= "Instance"
			or
			not Part:IsA("BasePart")
			or
			Part.Anchored
			or
			not Part:IsDescendantOf(
				workspace
			)
		then
			return false
		end

		-- Objetos soldados/compostos respondem pela raiz da assembly.
		local Root =
			Part.AssemblyRootPart
			or
			Part

		if
			not Root
			or
			not Root:IsA("BasePart")
			or
			Root.Anchored
			or
			not Root:IsDescendantOf(
				workspace
			)
		then
			return false
		end

		Part =
			Root

		local LocalCharacter =
			GetCharacter()

		if
			LocalCharacter
			and
			(
				Part.Parent == LocalCharacter
				or
				Part:IsDescendantOf(
					LocalCharacter
				)
			)
		then
			return false
		end

		-- Como o centro agora é outro jogador, também exclui o corpo
		-- do alvo para não desmontar o personagem selecionado.
		local Target =
			TargetSelector:GetFirst()

		local TargetCharacter =
			Target
			and
			Target.Character

		if
			TargetCharacter
			and
			Part:IsDescendantOf(
				TargetCharacter
			)
		then
			return false
		end

		if IsCharacterPart(Part) then
			return false
		end

		if PartIndex[Part] then
			return true
		end

		BackupPart(
			Part
		)

		table.insert(
			Parts,
			Part
		)

		PartIndex[Part] =
			#Parts

		pcall(function()
			Part:SetAttribute(
				"CartolaOwnBringPart",
				true
			)

			Part.CustomPhysicalProperties =
				PhysicalProperties.new(
					0,
					0,
					0,
					0,
					0
				)

			Part.CanCollide =
				false
		end)

		return true
	end

	local function RemovePart(
		Part,
		Restore
	)
		local Index =
			PartIndex[Part]

		if Index then
			local Last =
				Parts[#Parts]

			Parts[Index] =
				Last

			if Last then
				PartIndex[Last] =
					Index
			end

			Parts[#Parts] =
				nil

			PartIndex[Part] =
				nil
		end

		local Data =
			Original[Part]

		Original[Part] =
			nil

		if
			not Restore
			or
			not Data
			or
			not Part
			or
			not Part.Parent
		then
			return
		end

		pcall(function()
			Part:SetAttribute(
				"CartolaOwnBringPart",
				nil
			)

			if
				Data.CustomPhysicalProperties
				~=
				nil
			then
				Part.CustomPhysicalProperties =
					Data.CustomPhysicalProperties
			end

			if Data.CanCollide ~= nil then
				Part.CanCollide =
					Data.CanCollide
			end

			if Data.CanTouch ~= nil then
				Part.CanTouch =
					Data.CanTouch
			end

			if Data.LinearVelocity ~= nil then
				Part.AssemblyLinearVelocity =
					Data.LinearVelocity
			end

			if Data.AngularVelocity ~= nil then
				Part.AssemblyAngularVelocity =
					Data.AngularVelocity
			end
		end)
	end

	local function RestoreAll()
		local Snapshot = {}

		for Part in pairs(
			Original
		) do
			table.insert(
				Snapshot,
				Part
			)
		end

		for _, Part in ipairs(
			Snapshot
		) do
			RemovePart(
				Part,
				true
			)
		end

		Parts = {}

		PartIndex =
			setmetatable(
				{},
				{
					__mode = "k"
				}
			)

		Original =
			setmetatable(
				{},
				{
					__mode = "k"
				}
			)
	end

	local function ClaimNetwork()
		pcall(function()
			if
				type(
					sethiddenproperty
				)
				==
				"function"
			then
				sethiddenproperty(
					Player,
					"SimulationRadius",
					math.huge
				)

			elseif
				type(
					setsimulationradius
				)
				==
				"function"
			then
				setsimulationradius(
					math.huge,
					math.huge
				)
			end
		end)
	end

	local function InitialScan(
		Token
	)
		local Descendants =
			workspace:GetDescendants()

		for Index, Part in ipairs(
			Descendants
		) do
			if
				not Enabled
				or
				Token ~= ScanToken
			then
				return
			end

			RetainPart(
				Part
			)

			-- Só distribui a varredura entre frames;
			-- a regra funcional continua a mesma do script fonte.
			if Index % 500 == 0 then
				task.wait()
			end
		end
	end

	local function RingStep()
		if not Enabled then
			return
		end

		local Target =
			TargetSelector:GetFirst()

		local TargetCharacter =
			Target
			and
			Target.Character

		local TargetRoot =
			TargetCharacter
			and
			TargetCharacter:FindFirstChild(
				"HumanoidRootPart"
			)

		local TargetHumanoid =
			TargetCharacter
			and
			TargetCharacter:FindFirstChildOfClass(
				"Humanoid"
			)

		if
			not TargetRoot
			or
			not TargetHumanoid
			or
			TargetHumanoid.Health <= 0
		then
			return
		end

		ClaimNetwork()

		local TornadoCenter =
			TargetRoot.Position

		for Index = #Parts, 1, -1 do
			local Part =
				Parts[Index]

			if
				not Part
				or
				not Part.Parent
				or
				not Part:IsDescendantOf(
					workspace
				)
			then
				if Part then
					RemovePart(
						Part,
						false
					)
				end

			elseif
				not Part.Anchored
				and
				not IsCharacterPart(
					Part
				)
			then
				pcall(function()
					-- Pulso de ownership presente no script fonte.
					Part.Velocity =
						NetworkVelocity

					Part.AssemblyLinearVelocity =
						NetworkVelocity

					local Position =
						Part.Position

					local Distance =
						(
							Vector3.new(
								Position.X,
								TornadoCenter.Y,
								Position.Z
							)
							-
							TornadoCenter
						).Magnitude

					local Angle =
						math.atan2(
							Position.Z
							-
							TornadoCenter.Z,

							Position.X
							-
							TornadoCenter.X
						)

					local NewAngle =
						Angle
						+
						math.rad(
							RotationSpeed
						)

					local TargetPosition =
						Vector3.new(
							TornadoCenter.X
							+
							math.cos(
								NewAngle
							)
							*
							math.min(
								Radius,
								Distance
							),

							TornadoCenter.Y
							+
							math.clamp(
								Position.Y
								-
								TornadoCenter.Y,
								-Height,
								Height
							),

							TornadoCenter.Z
							+
							math.sin(
								NewAngle
							)
							*
							math.min(
								Radius,
								Distance
							)
						)

					local Difference =
						TargetPosition
						-
						Part.Position

					if
						Difference.Magnitude
						>
						0.001
					then
						local FinalVelocity =
							Difference.Unit
							*
							AttractionStrength

						Part.Velocity =
							FinalVelocity

						Part.AssemblyLinearVelocity =
							FinalVelocity
					end
				end)
			end
		end
	end

	local function Stop()
		Enabled =
			false

		ScanToken +=
			1

		Gui:SetAttribute(
			"OwnBringPartsActive",
			false
		)

		if AddedConnection then
			AddedConnection:Disconnect()

			AddedConnection =
				nil
		end

		if RemovingConnection then
			RemovingConnection:Disconnect()

			RemovingConnection =
				nil
		end

		if HeartbeatConnection then
			HeartbeatConnection:Disconnect()

			HeartbeatConnection =
				nil
		end

		RestoreAll()
	end

	CartolaPanicRegistry:Register(
		"BringParts",
		Stop
	)

	Slider(
		Principal,
		"Raio Bring Parts",
		1,
		60,
		4,
		function(Value)
			Radius =
				math.max(
					1,
					tonumber(Value)
					or
					4
				)
		end
	)

	local BringToggle

	BringToggle =
		Toggle(
			Principal,
			"Bring Parts no Player",
			false,
			function(State)
				Stop()

				if not State then
					return
				end

				if
					not TargetSelector:GetFirst()
				then


					if BringToggle then
						BringToggle:Set(
							false,
							false
						)
					end

					return
				end

				Enabled =
					true

				ScanToken +=
					1

				local Token =
					ScanToken

				Gui:SetAttribute(
					"OwnBringPartsActive",
					true
				)

				AddedConnection =
					workspace.DescendantAdded:Connect(function(
						Part
					)
						RetainPart(
							Part
						)
					end)

				RemovingConnection =
					workspace.DescendantRemoving:Connect(function(
						Part
					)
						if
							Part
							and
							Part:IsA("BasePart")
						then
							local Root =
								Part.AssemblyRootPart
								or
								Part

							if PartIndex[Root] then
								RemovePart(
									Root,
									false
								)
							end
						end
					end)

				task.spawn(
					InitialScan,
					Token
				)

				HeartbeatConnection =
					RunService.Heartbeat:Connect(
						RingStep
					)
			end
		)

	Gui.Destroying:Connect(
		Stop
	)
end

--============================================================
-- FULLBRIGHT
--============================================================

Section(
	Pages["Visual"],
	"Iluminação"
)

local FullbrightConnection = nil

local OriginalLighting = {

	Brightness =
		Lighting.Brightness,

	ClockTime =
		Lighting.ClockTime,

	FogEnd =
		Lighting.FogEnd,

	GlobalShadows =
		Lighting.GlobalShadows,

	OutdoorAmbient =
		Lighting.OutdoorAmbient

}

local function ApplyFullbright()

	Lighting.Brightness =
		2

	Lighting.ClockTime =
		14

	Lighting.FogEnd =
		100000

	Lighting.GlobalShadows =
		false

	Lighting.OutdoorAmbient =
		Color3.fromRGB(
			128,
			128,
			128
		)

end

local function StopFullbright()

	FullbrightEnabled =
		false

	if FullbrightConnection then

		FullbrightConnection:Disconnect()

		FullbrightConnection =
			nil

	end

	Lighting.Brightness =
		OriginalLighting.Brightness

	Lighting.ClockTime =
		OriginalLighting.ClockTime

	Lighting.FogEnd =
		OriginalLighting.FogEnd

	Lighting.OutdoorAmbient =
		OriginalLighting.OutdoorAmbient

	if AntiLagEnabled then

		Lighting.GlobalShadows =
			false

	else

		Lighting.GlobalShadows =
			OriginalLighting.GlobalShadows

	end

end

local function StartFullbright()

	if FullbrightConnection then

		FullbrightConnection:Disconnect()

	end

	FullbrightEnabled =
		true

	ApplyFullbright()

	FullbrightConnection =
		RunService.RenderStepped:Connect(function()

			if FullbrightEnabled then

				ApplyFullbright()

			end

		end)

end

Toggle(
	Pages["Visual"],
	"Fullbright",
	false,
	function(Enabled)

		if Enabled then

			StartFullbright()

		else

			StopFullbright()

		end

	end
)

--============================================================
-- ANTILAG MODERADO
--
-- Mantém a aparência do mapa muito mais próxima do original.
--
-- NÃO remove:
--   • TextureID de MeshPart;
--   • TextureId de SpecialMesh;
--   • Decal / Texture;
--   • SurfaceAppearance / mapas PBR;
--   • Material / Color / Transparency;
--   • Atmosphere / Clouds;
--   • texturas ou aparência de personagens.
--
-- Reduz apenas pontos mais caros:
--   • CastShadow das peças do mapa;
--   • RenderFidelity de MeshParts;
--   • sombras de luzes dinâmicas;
--   • ParticleEmitter com Rate muito alto;
--   • Blur e DepthOfField;
--   • ondas/reflexo excessivo da água;
--   • qualidade de renderização para nível moderado.
--
-- Tudo que é alterado é salvo e restaurado ao desligar.
--============================================================

Section(
	Ferramentas,
	"Desempenho"
)

do
	local AntiLagEnabled =
		false

	local AntiLagState = {
		Backup = {},
		WorkspaceConnection = nil,
		LightingConnection = nil,
		Generation = 0,
		OriginalQuality = nil
	}

	local AntiLagStatus =
		Status(
			Ferramentas,
			"Pronto"
		)

	function AntiLagState:BackupProperty(
		Object,
		Property
	)

		if
			not Object
			or
			not Object.Parent
		then
			return false
		end

		local ObjectBackup =
			self.Backup[
				Object
			]

		if not ObjectBackup then

			ObjectBackup =
				{}

			self.Backup[
				Object
			] =
				ObjectBackup

		end

		if
			ObjectBackup[
				Property
			]
			~=
			nil
		then

			return true

		end

		local Success,
			Value =
			pcall(function()

				return Object[
					Property
				]

			end)

		if not Success then
			return false
		end

		ObjectBackup[
			Property
		] = {
			Value =
				Value
		}

		return true

	end

	function AntiLagState:Set(
		Object,
		Property,
		Value
	)

		if
			self:BackupProperty(
				Object,
				Property
			)
		then

			pcall(function()

				Object[
					Property
				] =
					Value

			end)

		end

	end

	local function IsCharacterObject(
		Object
	)

		local Node =
			Object

		while
			Node
			and
			Node ~= workspace
			and
			Node ~= game
		do

			if
				Node:IsA("Model")
				and
				Node:FindFirstChildOfClass(
					"Humanoid"
				)
			then

				return true

			end

			Node =
				Node.Parent

		end

		return false

	end

	function AntiLagState:OptimizeObject(
		Object
	)

		if
			not AntiLagEnabled
			or
			not Object
			or
			not Object.Parent
		then

			return

		end

		-- Nunca altera peças, texturas ou efeitos dentro de Characters.
		if IsCharacterObject(Object) then
			return
		end

		if Object:IsA("MeshPart") then

			self:Set(
				Object,
				"CastShadow",
				false
			)

			-- Mantém TextureID, Material, Color e SurfaceAppearance.
			pcall(function()

				self:Set(
					Object,
					"RenderFidelity",
					Enum.RenderFidelity.Performance
				)

			end)

		elseif Object:IsA("BasePart") then

			-- A maior redução visualmente segura:
			-- remove somente a sombra projetada da peça.
			self:Set(
				Object,
				"CastShadow",
				false
			)

		elseif Object:IsA("Light") then

			-- Mantém a luz ligada; remove só o cálculo de sombra.
			pcall(function()

				self:Set(
					Object,
					"Shadows",
					false
				)

			end)

		elseif Object:IsA("ParticleEmitter") then

			-- Emissores normais ficam iguais.
			-- Só limita os realmente pesados.
			if Object.Rate > 30 then

				self:Set(
					Object,
					"Rate",
					30
				)

			end

		elseif
			Object:IsA("BlurEffect")
			or
			Object:IsA("DepthOfFieldEffect")
		then

			self:Set(
				Object,
				"Enabled",
				false
			)

		end

	end

	function AntiLagState:Disconnect()

		if self.WorkspaceConnection then

			self.WorkspaceConnection:Disconnect()

			self.WorkspaceConnection =
				nil

		end

		if self.LightingConnection then

			self.LightingConnection:Disconnect()

			self.LightingConnection =
				nil

		end

	end

	local function StopAntiLag()

		AntiLagEnabled =
			false

		AntiLagState.Generation +=
			1

		AntiLagState:Disconnect()

		local Restored =
			0

		for Object, Properties in pairs(
			AntiLagState.Backup
		) do

			if
				Object
				and
				Object.Parent
			then

				for Property, Data in pairs(
					Properties
				) do

					pcall(function()

						Object[
							Property
						] =
							Data.Value

					end)

				end

			end

			Restored +=
				1

			if
				Restored % 400
				==
				0
			then

				task.wait()

			end

		end

		table.clear(
			AntiLagState.Backup
		)

		if AntiLagState.OriginalQuality ~= nil then

			pcall(function()

				settings().Rendering.QualityLevel =
					AntiLagState.OriginalQuality

			end)

			AntiLagState.OriginalQuality =
				nil

		end

		AntiLagStatus.Text =
			"Anti Lag desativado"

	end

	local function StartAntiLag()

		if AntiLagEnabled then
			return
		end

		AntiLagEnabled =
			true

		AntiLagState.Generation +=
			1

		local MyGeneration =
			AntiLagState.Generation

		table.clear(
			AntiLagState.Backup
		)

		AntiLagState:Disconnect()

		AntiLagStatus.Text =
			"Otimizando mapa..."

		-- Água: reduz custo sem deixar transparente ou sumir.
		local Terrain =
			workspace:FindFirstChildWhichIsA(
				"Terrain"
			)

		if Terrain then

			if Terrain.WaterWaveSize > 0.05 then

				AntiLagState:Set(
					Terrain,
					"WaterWaveSize",
					0.05
				)

			end

			if Terrain.WaterWaveSpeed > 4 then

				AntiLagState:Set(
					Terrain,
					"WaterWaveSpeed",
					4
				)

			end

			if Terrain.WaterReflectance > 0.15 then

				AntiLagState:Set(
					Terrain,
					"WaterReflectance",
					0.15
				)

			end

		end

		-- Qualidade 3 em vez de 1: ganho razoável sem destruir o visual.
		pcall(function()

			AntiLagState.OriginalQuality =
				settings().Rendering.QualityLevel

			settings().Rendering.QualityLevel =
				3

		end)

		for _, Object in ipairs(
			Lighting:GetDescendants()
		) do

			AntiLagState:OptimizeObject(
				Object
			)

		end

		AntiLagState.WorkspaceConnection =
			workspace.DescendantAdded:Connect(function(
				Object
			)

				if AntiLagEnabled then

					task.defer(function()

						if AntiLagEnabled then

							AntiLagState:OptimizeObject(
								Object
							)

						end

					end)

				end

			end)

		AntiLagState.LightingConnection =
			Lighting.DescendantAdded:Connect(function(
				Object
			)

				if AntiLagEnabled then

					task.defer(function()

						if AntiLagEnabled then

							AntiLagState:OptimizeObject(
								Object
							)

						end

					end)

				end

			end)

		task.spawn(function()

			local Counter =
				0

			for _, Object in ipairs(
				workspace:GetDescendants()
			) do

				if
					not AntiLagEnabled
					or
					MyGeneration
					~=
					AntiLagState.Generation
				then

					return

				end

				AntiLagState:OptimizeObject(
					Object
				)

				Counter +=
					1

				if
					Counter % 400
					==
					0
				then

					task.wait()

				end

			end

			if
				AntiLagEnabled
				and
				MyGeneration
				==
				AntiLagState.Generation
			then

				AntiLagStatus.Text =
					"Anti Lag ativo"

			end

		end)

	end

	Toggle(
		Ferramentas,
		"Anti Lag",
		false,
		function(Enabled)

			if Enabled then

				StartAntiLag()

			else

				StopAntiLag()

			end

		end
	)

	Gui.Destroying:Connect(function()

		StopAntiLag()

	end)
end

--============================================================
-- FREECAM
--============================================================

Section(
	Pages["Visual"],
	"Freecam"
)

local FreecamEnabled = false

local FreecamSpeed = 35

local FreecamConnection = nil

local FreecamPosition =
	Vector3.zero

local FreecamYaw = 0

local FreecamPitch = 0

local FreecamRMB = false

local SavedCamera = {}

local FreecamTouch = nil

local FreecamLastTouch = nil

Slider(
	Pages["Visual"],
	"Velocidade Freecam",
	1,
	100,
	35,
	function(Value)

		FreecamSpeed =
			Value

	end
)

UIS.InputBegan:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseButton2
	then

		FreecamRMB =
			true

	end

end)

UIS.InputEnded:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseButton2
	then

		FreecamRMB =
			false

	end

end)

UIS.InputChanged:Connect(function(Input)

	if
		FreecamEnabled
		and
		FreecamRMB
		and
		Input.UserInputType
		==
		Enum.UserInputType.MouseMovement
	then

		FreecamYaw -=
			Input.Delta.X
			*
			0.003

		FreecamPitch =
			math.clamp(

				FreecamPitch
				-
				Input.Delta.Y
				*
				0.003,

				-math.rad(85),

				math.rad(85)

			)

	end

end)

UIS.TouchStarted:Connect(function(
	Touch,
	Processed
)

	if
		not FreecamEnabled
		or
		Processed
	then
		return
	end

	local Camera =
		workspace.CurrentCamera

	if
		Camera
		and
		Touch.Position.X
		>
		Camera.ViewportSize.X
		*
		0.45
	then

		FreecamTouch =
			Touch

		FreecamLastTouch =
			Touch.Position

	end

end)

UIS.TouchMoved:Connect(function(Touch)

	if
		FreecamEnabled
		and
		Touch == FreecamTouch
		and
		FreecamLastTouch
	then

		local Delta =
			Touch.Position
			-
			FreecamLastTouch

		FreecamLastTouch =
			Touch.Position

		FreecamYaw -=
			Delta.X
			*
			0.005

		FreecamPitch =
			math.clamp(

				FreecamPitch
				-
				Delta.Y
				*
				0.005,

				-math.rad(85),

				math.rad(85)

			)

	end

end)

UIS.TouchEnded:Connect(function(Touch)

	if Touch == FreecamTouch then

		FreecamTouch =
			nil

		FreecamLastTouch =
			nil

	end

end)

local function StopFreecam()

	if not FreecamEnabled then
		return
	end

	FreecamEnabled =
		false

	Gui:SetAttribute("FreecamActive", false)

	if FreecamConnection then

		FreecamConnection:Disconnect()

		FreecamConnection =
			nil

	end

	local Camera =
		workspace.CurrentCamera

	if Camera then

		Camera.CameraType =
			SavedCamera.Type
			or
			Enum.CameraType.Custom

		Camera.CameraSubject =
			SavedCamera.Subject
			or
			GetHumanoid()

		if SavedCamera.CFrame then

			Camera.CFrame =
				SavedCamera.CFrame

		end

	end

end

CartolaPanicRegistry:Register(
	"Freecam",
	StopFreecam
)

local function StartFreecam()

	StopView()

	if FreecamEnabled then
		return
	end

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	SavedCamera = {

		Type =
			Camera.CameraType,

		Subject =
			Camera.CameraSubject,

		CFrame =
			Camera.CFrame

	}

	FreecamPosition =
		Camera.CFrame.Position

	local Look =
		Camera.CFrame.LookVector

	FreecamPitch =
		math.asin(

			math.clamp(
				Look.Y,
				-1,
				1
			)

		)

	FreecamYaw =
		math.atan2(
			-Look.X,
			-Look.Z
		)

	FreecamEnabled =
		true

	Gui:SetAttribute("FreecamActive", true)

	Camera.CameraType =
		Enum.CameraType.Scriptable

	FreecamConnection =
		RunService.RenderStepped:Connect(function(
			DeltaTime
		)

			if not FreecamEnabled then
				return
			end

			if Gui:GetAttribute("ViewActive") then
				return
			end

			local Camera =
				workspace.CurrentCamera

			if not Camera then
				return
			end

			local Rotation =

				CFrame.Angles(
					0,
					FreecamYaw,
					0
				)

				*

				CFrame.Angles(
					FreecamPitch,
					0,
					0
				)

			local Direction =
				Vector3.zero

			if ControlModule then

				local Move =
					ControlModule:GetMoveVector()

				Direction +=
					Rotation.RightVector
					*
					Move.X

				Direction -=
					Rotation.LookVector
					*
					Move.Z

			else

				if UIS:IsKeyDown(
					Enum.KeyCode.W
				) then

					Direction +=
						Rotation.LookVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.S
				) then

					Direction -=
						Rotation.LookVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.A
				) then

					Direction -=
						Rotation.RightVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.D
				) then

					Direction +=
						Rotation.RightVector

				end

			end

			if UIS:IsKeyDown(
				Enum.KeyCode.Space
			) then

				Direction +=
					Vector3.yAxis

			end

			if UIS:IsKeyDown(
				Enum.KeyCode.LeftControl
			) then

				Direction -=
					Vector3.yAxis

			end

			if Direction.Magnitude > 1 then

				Direction =
					Direction.Unit

			end

			FreecamPosition +=

				Direction
				*
				FreecamSpeed
				*
				DeltaTime

			Camera.CFrame =

				CFrame.new(
					FreecamPosition
				)

				*

				Rotation

		end)

end

Toggle(
	Pages["Visual"],
	"Freecam",
	false,
	function(Enabled)

		if Enabled then

			StartFreecam()

		else

			StopFreecam()

		end

	end
)

--============================================================
-- FOV
--============================================================

Section(
	Pages["Visual"],
	"Câmera"
)

local FOVSlider =
	Slider(
		Pages["Visual"],
		"FOV",
		40,
		120,
		70,
		function(Value)

			local Camera =
				workspace.CurrentCamera

			if Camera then

				Camera.FieldOfView =
					Value

			end

		end
	)

Action(
	Pages["Visual"],
	"Restaurar FOV (70)",
	function()

		FOVSlider:SetValue(
			70,
			true
		)

	end
)

--============================================================
-- SERVIDOR
--============================================================

Section(
	Ferramentas,
	"Servidor"
)

Action(
	Ferramentas,
	"Rejoin",
	function()

		RejoinGame()

	end
)


Action(
	Ferramentas,
	"Server Hop",
	function()

		task.spawn(function()

			local HttpService =
				game:GetService(
					"HttpService"
				)

			local Success,
				Body =
				pcall(function()

					local Response =
						game:HttpGet(
							"https://games.roblox.com/v1/games/"
							..
							tostring(
								game.PlaceId
							)
							..
							"/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
						)

					return
						HttpService:JSONDecode(
							Response
						)

				end)

			if
				not Success
				or
				type(Body) ~= "table"
				or
				type(Body.data) ~= "table"
			then



				return

			end

			local Servers =
				{}

			for _, Server in ipairs(
				Body.data
			) do

				if
					type(Server) == "table"
					and
					tonumber(Server.playing)
					and
					tonumber(Server.maxPlayers)
					and
					Server.playing < Server.maxPlayers
					and
					Server.id
					and
					Server.id ~= game.JobId
				then

					table.insert(
						Servers,
						Server.id
					)

				end

			end

			if #Servers == 0 then



				return

			end

			local ServerId =
				Servers[
					math.random(
						1,
						#Servers
					)
				]

			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				ServerId,
				Player
			)

		end)

	end
)

Action(
	Ferramentas,
	"Teleportar para o Lobby",
	function()
		local Character = GetCharacter()
		local Humanoid = GetHumanoid()
		local Root = GetRoot()
		if not Character or not Root then
			return
		end

		-- CFrame capturado no lobby pelo usuário.
		-- Position: -226.341, 58.98, 492.982
		local LobbyCFrame = CFrame.new(-226.341, 58.98, 492.982)

		-- Desmonta qualquer assento antes do teleporte e neutraliza a inércia.
		if Humanoid then
			Humanoid.Sit = false
			pcall(function()
				Humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end

		ClearCharacterVelocity()
		Character:PivotTo(LobbyCFrame)

		-- Alguns scripts do jogo tentam devolver o personagem para a posição anterior.
		-- Reforça o CFrame por alguns frames para o teleporte pegar em um único clique.
		task.spawn(function()
			for _ = 1, 18 do
				if not Character.Parent then
					break
				end
				local CurrentRoot = Character:FindFirstChild("HumanoidRootPart")
				if not CurrentRoot then
					break
				end
				CurrentRoot.AssemblyLinearVelocity = Vector3.zero
				CurrentRoot.AssemblyAngularVelocity = Vector3.zero
				Character:PivotTo(LobbyCFrame)
				RunService.Heartbeat:Wait()
			end
		end)
	end
)



Section(
	Ferramentas,
	"Interface"
)

Slider(
	Ferramentas,
	"Tamanho da GUI (%)",
	40,
	160,
	100,
	function(Value)
		local ScaleValue =
			math.clamp(
				(tonumber(Value) or 100) / 100,
				0.40,
				1.60
			)

		Gui:SetAttribute(
			"CartolaGuiScale",
			ScaleValue
		)

		local ScaleObject =
			Main:FindFirstChild(
				"DesktopScale"
			)

		if ScaleObject then
			ScaleObject.Scale =
				ScaleValue
		end
	end
)


-- Redimensionar a GUI arrastando o canto inferior direito.
CartolaResizeRuntime = {
	Dragging = false,
	StartPosition = nil,
	StartScale = 1
}

CartolaResizeRuntime.Grip =
	New(
		"TextButton",
		{
			Name = "ResizeGrip",
			AnchorPoint = Vector2.new(1,1),
			Position = UDim2.new(1,-5,1,-5),
			Size = UDim2.fromOffset(30,30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Active = true,
			Text = "◢",
			TextColor3 = Theme.SubText,
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			ZIndex = 500
		},
		Main
	)

CartolaResizeRuntime.Grip.InputBegan:Connect(function(Input)
	if
		Input.UserInputType == Enum.UserInputType.MouseButton1
		or
		Input.UserInputType == Enum.UserInputType.Touch
	then
		CartolaResizeRuntime.Dragging = true
		CartolaResizeRuntime.StartPosition = Input.Position
		CartolaResizeRuntime.StartScale =
			tonumber(Gui:GetAttribute("CartolaGuiScale"))
			or
			1
	end
end)

UIS.InputChanged:Connect(function(Input)
	if
		not CartolaResizeRuntime
		or
		not CartolaResizeRuntime.Dragging
		or
		not CartolaResizeRuntime.StartPosition
	then
		return
	end

	if
		Input.UserInputType ~= Enum.UserInputType.MouseMovement
		and
		Input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	local Delta =
		Input.Position
		-
		CartolaResizeRuntime.StartPosition

	local NewScale =
		math.clamp(
			CartolaResizeRuntime.StartScale
			+
			((Delta.X + Delta.Y) * 0.5) / 360,
			0.40,
			1.60
		)

	Gui:SetAttribute(
		"CartolaGuiScale",
		NewScale
	)

	local ScaleObject =
		Main:FindFirstChild("DesktopScale")

	if ScaleObject then
		ScaleObject.Scale = NewScale
	end
end)

UIS.InputEnded:Connect(function(Input)
	if not CartolaResizeRuntime then
		return
	end

	if
		Input.UserInputType == Enum.UserInputType.MouseButton1
		or
		Input.UserInputType == Enum.UserInputType.Touch
	then
		CartolaResizeRuntime.Dragging = false
		CartolaResizeRuntime.StartPosition = nil
	end
end)

--============================================================
-- STAFF WATCH
--============================================================

Section(
	Ferramentas,
	"Monitoramento"
)

do
	local Enabled =
		false

	local JoinConnection =
		nil

	local StaffRoles = {
		"mod",
		"admin",
		"staff",
		"dev",
		"founder",
		"owner",
		"supervis",
		"manager",
		"management",
		"executive",
		"president",
		"chairman",
		"chairwoman",
		"chairperson",
		"director"
	}

	local WatchStatus =
		Status(
			Ferramentas,
			"Staff Watch desligado"
		)

	local function Notify(
		Message
	)



		pcall(function()

			game:GetService(
				"StarterGui"
			):SetCore(
				"SendNotification",
				{
					Title =
						"Cartola Hub - Staff Watch",
					Text =
						tostring(Message),
					Duration =
						7
				}
			)

		end)

	end

	local function GetStaffRole(
		Target
	)

		if
			not Target
			or
			not Target.Parent
		then

			return false,
				""

		end

		local IsRobloxStaff =
			false

		pcall(function()

			IsRobloxStaff =
				Target:IsInGroup(
					1200769
				)

		end)

		if IsRobloxStaff then

			return true,
				"Roblox Employee"

		end

		if
			game.CreatorType
			~=
			Enum.CreatorType.Group
		then

			return false,
				""

		end

		local Role =
			""

		local Success =
			pcall(function()

				Role =
					Target:GetRoleInGroup(
						game.CreatorId
					)

			end)

		if not Success then

			return false,
				""

		end

		local LowerRole =
			string.lower(
				tostring(Role)
			)

		for _, Word in ipairs(
			StaffRoles
		) do

			if
				string.find(
					LowerRole,
					Word,
					1,
					true
				)
			then

				return true,
					Role

			end

		end

		return false,
			Role

	end

	local function CheckPlayer(
		Target
	)

		if
			not Enabled
			or
			Target == Player
		then

			return

		end

		task.spawn(function()

			local IsStaff,
				Role =
					GetStaffRole(
						Target
					)

			if
				Enabled
				and
				IsStaff
			then

				Notify(
					Target.DisplayName
					..
					" (@"
					..
					Target.Name
					..
					") entrou como "
					..
					tostring(Role)
				)

			end

		end)

	end

	local function StopStaffWatch()

		Enabled =
			false

		if JoinConnection then

			JoinConnection:Disconnect()

			JoinConnection =
				nil

		end

		WatchStatus.Text =
			"Staff Watch desligado"

	end

	local function StartStaffWatch()

		StopStaffWatch()

		if
			game.CreatorType
			~=
			Enum.CreatorType.Group
		then

			Notify(
				"Este jogo não pertence a um grupo."
			)

			return false

		end

		Enabled =
			true

		WatchStatus.Text =
			"Staff Watch ativo"

		JoinConnection =
			Players.PlayerAdded:Connect(
				CheckPlayer
			)

		for _, Target in ipairs(
			Players:GetPlayers()
		) do

			CheckPlayer(
				Target
			)

		end

		return true

	end

	local StaffToggle

	StaffToggle =
		Toggle(
			Ferramentas,
			"Staff Watch",
			false,
			function(State)

				if State then

					if not StartStaffWatch() then

						task.defer(function()

							if StaffToggle then

								StaffToggle:Set(
									false,
									false
								)

							end

						end)

					end

				else

					StopStaffWatch()

				end

			end
		)

	Gui.Destroying:Connect(
		StopStaffWatch
	)
end

--============================================================
-- OUTRAS ABAS
--============================================================

Section(
	Credits,
	"Créditos"
)

Action(
	Credits,
	"Cartola Hub Versão Metro Life RP | By didinho",
	function()



	end
)

Action(
	Credits,
	"Versão 1.0",
	function()



	end
)

Section(
	Ferramentas,
	"Áudio"
)

--============================================================
-- ÁUDIO / SILENCIAR TODOS OS SONS
--
-- Toggle reversível:
-- ON  -> Volume 0 nos sons existentes e nos que forem criados.
-- OFF -> restaura o volume que cada som tinha antes.
--============================================================

do
	local SoundService =
		game:GetService("SoundService")

	local Muted =
		false

	local VolumeBackup = {}

	local WorkspaceAddedConnection =
		nil

	local SoundServiceAddedConnection =
		nil

	local function MuteSound(Object)

		if
			not Object
			or
			not Object:IsA("Sound")
		then
			return
		end

		if VolumeBackup[Object] == nil then

			VolumeBackup[Object] =
				Object.Volume

		end

		Object.Volume =
			0

	end

	local function MuteContainer(Container)

		for _, Object in ipairs(
			Container:GetDescendants()
		) do

			if Object:IsA("Sound") then

				MuteSound(Object)

			end

		end

	end

	local function RestoreSounds()

		for Object, OldVolume in pairs(
			VolumeBackup
		) do

			if
				Object
				and
				Object.Parent
			then

				pcall(function()

					Object.Volume =
						OldVolume

				end)

			end

		end

		VolumeBackup = {}

	end

	local function SetSoundsMuted(Enabled)

		Muted =
			Enabled

		if WorkspaceAddedConnection then

			WorkspaceAddedConnection:Disconnect()

			WorkspaceAddedConnection =
				nil

		end

		if SoundServiceAddedConnection then

			SoundServiceAddedConnection:Disconnect()

			SoundServiceAddedConnection =
				nil

		end

		if Enabled then

			MuteContainer(workspace)

			MuteContainer(SoundService)

			WorkspaceAddedConnection =
				workspace.DescendantAdded:Connect(function(Object)

					if
						Muted
						and
						Object:IsA("Sound")
					then

						MuteSound(Object)

					end

				end)

			SoundServiceAddedConnection =
				SoundService.DescendantAdded:Connect(function(Object)

					if
						Muted
						and
						Object:IsA("Sound")
					then

						MuteSound(Object)

					end

				end)

		else

			RestoreSounds()

		end

	end

	Toggle(
		Ferramentas,
		"Parar todos os sons",
		false,
		SetSoundsMuted
	)


	Gui.Destroying:Connect(function()

		SetSoundsMuted(false)

	end)
end

Section(
	Casa,
	"Casa"
)

pcall(function()
	if OP:FindFirstChild("CartolaFastBootStatus") then
		OP.CartolaFastBootStatus.Text = "Carregando casa e veículos..."
	end
end)

task.wait()

--============================================================
-- CASA / ROOMMATE / PORTAS / TV / CORTINAS
--
-- Um único seletor múltiplo controla todas as ações desta seção.
-- Cada casa é resolvida pelo UserId do player selecionado.
--============================================================

do
	local HousePlayers =
		CreatePlayerSelector(
			Casa,
			"Players com Casa",
			false,
			false,
			false,
			function(Target)
				local Persistent =
					workspace:FindFirstChild(
						"HousePersistentFd"
					)

				return
					Persistent
					and
					(
						Persistent:FindFirstChild(
							tostring(Target.UserId)
						)
						or
						Persistent:FindFirstChild(
							Target.Name
						)
					)
					~=
					nil
			end
		)

	local DoorLoopEnabled = false
	local DoorLoopToken = 0
	local DoorLoopToggle = nil

	local UnlockDoorLoopEnabled = false
	local UnlockDoorLoopToken = 0
	local UnlockDoorLoopToggle = nil

	local TVLoopEnabled = false
	local TVLoopToken = 0
	local TVLoopToggle = nil

	local CurtainLoopEnabled = false
	local CurtainLoopToken = 0
	local CurtainLoopToggle = nil

	local function GetTargetHouseModel(Target)
		if not Target or Target.Parent ~= Players then
			return nil
		end

		local UserHouse = workspace:FindFirstChild("UserHouse")
		if not UserHouse then
			return nil
		end

		local TargetHouse =
			UserHouse:FindFirstChild(tostring(Target.UserId))
			or
			UserHouse:FindFirstChild(Target.Name)

		if not TargetHouse then
			return nil
		end

		return
			TargetHouse:FindFirstChild("house")
			or
			TargetHouse:FindFirstChild("House")
			or
			TargetHouse
	end

	local function GetHouseDoorEntries(Target)
		local HouseModel = GetTargetHouseModel(Target)
		if not HouseModel then
			return {}
		end

		local DoorContainers = {}
		local SeenContainers = {}
		local SeenDoors = {}
		local Entries = {}

		local function AddDoor(Object)
			if
				Object
				and
				Object.Parent
				and
				not SeenDoors[Object]
			then
				SeenDoors[Object] = true

				table.insert(
					Entries,
					{
						door = Object
					}
				)
			end
		end

		local function AddContainer(Object)
			if Object and Object.Parent and not SeenContainers[Object] then
				SeenContainers[Object] = true
				table.insert(DoorContainers,Object)
			end
		end

		AddContainer(
			HouseModel:FindFirstChild("Door")
			or
			HouseModel:FindFirstChild("door")
		)

		for _,Object in ipairs(HouseModel:GetDescendants()) do
			local Name =
				string.lower(
					tostring(
						Object.Name
						or
						""
					)
				)

			if Name == "door" then
				AddContainer(Object)
			end

			-- Algumas casas não guardam a porta dentro de um container "Door".
			-- Exemplos: Build.FAutoDoor / AutoDoor / GarageDoor.
			-- Nesses casos o próprio Instance é o argumento Door do remote.
			if
				string.find(
					Name,
					"door",
					1,
					true
				)
			then
				AddDoor(Object)
			end
		end

		for _,Container in ipairs(DoorContainers) do
			local Children = Container:GetChildren()

			for _,Child in ipairs(Children) do
				local Name = string.lower(tostring(Child.Name or ""))

				if string.find(Name,"door",1,true) then
					AddDoor(Child)
				end
			end
		end

		return Entries
	end

	local function FireDoors(Target,CommandDoorRE,DoorEntries)
		local Fired = 0

		for _,Entry in ipairs(DoorEntries or GetHouseDoorEntries(Target)) do
			local DoorObject =
				Entry.door
				or
				(
					Entry.children
					and
					Entry.children[Entry.index]
				)

			if DoorObject and DoorObject.Parent then
				local Ok = pcall(function()
					CommandDoorRE:FireServer({
						Event = "DoorOpenOrClose",
						Door = DoorObject
					})
				end)

				if Ok then
					Fired += 1

				end
			end
		end

		return Fired
	end


	-- Tenta descobrir se a porta está trancada sem depender de um único
	-- formato de casa. Algumas casas usam Attribute; outras usam BoolValue.
	local function GetDoorLockedState(DoorObject)
		if not DoorObject or not DoorObject.Parent then
			return nil
		end

		local AttributeNames = {
			"Locked",
			"IsLocked",
			"DoorLocked",
			"Lock"
		}

		for _,Name in ipairs(AttributeNames) do
			local Ok,Value = pcall(function()
				return DoorObject:GetAttribute(Name)
			end)

			if Ok and type(Value) == "boolean" then
				return Value
			end
		end

		local ValueNames = {
			"Locked",
			"IsLocked",
			"DoorLocked",
			"Lock"
		}

		for _,Name in ipairs(ValueNames) do
			local ValueObject =
				DoorObject:FindFirstChild(Name)
				or
				DoorObject:FindFirstChild(Name,true)

			if
				ValueObject
				and
				ValueObject:IsA("BoolValue")
			then
				return ValueObject.Value
			end
		end

		return nil
	end

	local function UnlockHouseDoors(
		Target,
		CommandDoorRE,
		UnknownStateAttempted,
		DoorEntries
	)
		local Fired = 0

		for _,Entry in ipairs(DoorEntries or GetHouseDoorEntries(Target)) do
			local DoorObject =
				Entry.door
				or
				(
					Entry.children
					and
					Entry.children[Entry.index]
				)

			if DoorObject and DoorObject.Parent then
				local LockedState =
					GetDoorLockedState(DoorObject)

				local ShouldFire =
					LockedState == true
					or
					(
						LockedState == nil
						and
						not UnknownStateAttempted[DoorObject]
					)

				if ShouldFire then
					local Ok =
						pcall(function()
							CommandDoorRE:FireServer({
								Event = "DoorLockOrUnlock",
								Door = DoorObject
							})
						end)

					if Ok then
						Fired += 1


						if LockedState == nil then
							UnknownStateAttempted[DoorObject] = true
						end
					end
				end
			end
		end

		return Fired
	end

	local function GetHouseTVRemotes(Target)
		local HouseModel = GetTargetHouseModel(Target)
		if not HouseModel then
			return {}
		end

		local Result = {}
		local Seen = {}

		for _,Object in ipairs(HouseModel:GetDescendants()) do
			if
				Object.Name == "TVRE"
				and
				Object:IsA("RemoteEvent")
				and
				not Seen[Object]
			then
				Seen[Object] = true
				table.insert(Result,Object)
			end
		end

		return Result
	end

	local function FireTVs(Target,TVRemotes)
		local Fired = 0

		for _,TVRE in ipairs(TVRemotes or GetHouseTVRemotes(Target)) do
			local Ok = pcall(function()
				TVRE:FireServer("SwitchTV")
			end)

			if Ok then
				Fired += 1
			end
		end

		return Fired
	end

	local function GetCurtainEntries(Target)
		local HouseModel = GetTargetHouseModel(Target)
		if not HouseModel then
			return {}
		end

		local Entries = {}
		local SeenRoots = {}

		for _,Container in ipairs(HouseModel:GetDescendants()) do
			local ContainerName = string.lower(tostring(Container.Name or ""))

			if string.find(ContainerName,"curtain",1,true) then
				local Children = Container:GetChildren()

				for Index,Child in ipairs(Children) do
					local Root =
						Child:FindFirstChild("Root")
						or
						Child:FindFirstChild("Root",true)

					if Root and not SeenRoots[Root] then
						SeenRoots[Root] = true
						table.insert(Entries,{
							children = Children,
							index = Index
						})
					end
				end
			end
		end

		-- Fallback: se a casa usa outro nome no container, ainda aceita itens
		-- que tenham Root e algum ancestral com "curtain" no nome.
		for _,Object in ipairs(HouseModel:GetDescendants()) do
			if Object.Name == "Root" and not SeenRoots[Object] then
				local Node = Object.Parent
				local CurtainAncestor = nil

				while Node and Node ~= HouseModel do
					if string.find(string.lower(tostring(Node.Name or "")),"curtain",1,true) then
						CurtainAncestor = Node
						break
					end
					Node = Node.Parent
				end

				if CurtainAncestor and Object.Parent and Object.Parent.Parent then
					local Item = Object.Parent
					local Parent = Item.Parent
					local Children = Parent:GetChildren()

					for Index,Child in ipairs(Children) do
						if Child == Item then
							SeenRoots[Object] = true
							table.insert(Entries,{
								children = Children,
								index = Index
							})
							break
						end
					end
				end
			end
		end

		return Entries
	end

	local function FireCurtains(Target,FurnitureInteractRE,CurtainEntries)
		local Fired = 0

		for _,Entry in ipairs(CurtainEntries or GetCurtainEntries(Target)) do
			local CurtainItem = Entry.children[Entry.index]

			if CurtainItem and CurtainItem.Parent then
				local Root =
					CurtainItem:FindFirstChild("Root")
					or
					CurtainItem:FindFirstChild("Root",true)

				if Root then
					local Ok = pcall(function()
						FurnitureInteractRE:FireServer({
							Event = "LogicNegation",
							Target = Root
						})
					end)

					if Ok then
						Fired += 1
					end
				end
			end
		end

		return Fired
	end

	Action(
		Casa,
		"Alterar para Colega de Quarto",
		function()
			local Targets = HousePlayers:GetPlayers()

			if #Targets == 0 then

				return
			end

			local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
			local HousePermissionRE =
				RemotesFolder
				and
				RemotesFolder:FindFirstChild("HousePermissionRE")

			if not HousePermissionRE then

				return
			end

			if type(firesignal) ~= "function" then

				return
			end

			for _,Target in ipairs(Targets) do
				local Success,ErrorMessage = pcall(function()
					firesignal(
						HousePermissionRE.OnClientEvent,
						{
							houseOwner = Target,
							event = "ChangePermissionToMine",
							permission = "Roommate"
						}
					)
				end)

				if not Success then

				end
			end
		end
	)

	DoorLoopToggle = Toggle(
		Casa,
		"Abrir e Fechar Portas",
		false,
		function(Enabled)
			DoorLoopEnabled = Enabled == true
			DoorLoopToken += 1

			if not DoorLoopEnabled then
				return
			end

			if HousePlayers:GetSelectedCount() == 0 then

				task.defer(function()
					if DoorLoopToggle then
						DoorLoopToggle:Set(false,false)
					end
				end)
				DoorLoopEnabled = false
				return
			end

			local ThisToken = DoorLoopToken

			task.spawn(function()
				local DoorCache = {}
				local CommandDoorRE = nil

				while
					DoorLoopEnabled
					and
					ThisToken == DoorLoopToken
					and
					Gui.Parent
				do
					if
						not CommandDoorRE
						or
						not CommandDoorRE.Parent
					then
						local RemotesFolder =
							ReplicatedStorage:FindFirstChild("Remotes")

						CommandDoorRE =
							RemotesFolder
							and
							RemotesFolder:FindFirstChild("CommandDoorRE")
					end

					if CommandDoorRE then
						local Now = os.clock()

						for _,Target in ipairs(HousePlayers:GetPlayers()) do
							local Key = Target.UserId
							local Cached = DoorCache[Key]

							if
								not Cached
								or
								Now >= Cached.Expires
							then
								Cached = {
									Expires = Now + 3,
									Entries = GetHouseDoorEntries(Target)
								}

								DoorCache[Key] = Cached
							end

							FireDoors(
								Target,
								CommandDoorRE,
								Cached.Entries
							)
						end
					end

					task.wait(0.45)
				end
			end)
		end
	)


	UnlockDoorLoopToggle = Toggle(
		Casa,
		"Desbloquear Portas",
		false,
		function(Enabled)
			UnlockDoorLoopEnabled = Enabled == true
			UnlockDoorLoopToken += 1

			if not UnlockDoorLoopEnabled then
				return
			end

			if HousePlayers:GetSelectedCount() == 0 then


				task.defer(function()
					if UnlockDoorLoopToggle then
						UnlockDoorLoopToggle:Set(false,false)
					end
				end)

				UnlockDoorLoopEnabled = false
				return
			end

			local ThisToken =
				UnlockDoorLoopToken

			-- Para portas cujo estado de lock não é replicado, evita alternar
			-- lock/unlock sem parar. A cada nova ativação do toggle, cada porta
			-- desconhecida recebe uma tentativa; portas com estado detectável
			-- são destrancadas novamente se voltarem a ficar Locked=true.
			local UnknownStateAttempted =
				setmetatable(
					{},
					{__mode = "k"}
				)

			task.spawn(function()
				local DoorCache = {}
				local CommandDoorRE = nil

				while
					UnlockDoorLoopEnabled
					and
					ThisToken == UnlockDoorLoopToken
					and
					Gui.Parent
				do
					if
						not CommandDoorRE
						or
						not CommandDoorRE.Parent
					then
						local RemotesFolder =
							ReplicatedStorage:FindFirstChild("Remotes")

						CommandDoorRE =
							RemotesFolder
							and
							RemotesFolder:FindFirstChild("CommandDoorRE")
					end

					if CommandDoorRE then
						local Now = os.clock()

						for _,Target in ipairs(HousePlayers:GetPlayers()) do
							local Key = Target.UserId
							local Cached = DoorCache[Key]

							if
								not Cached
								or
								Now >= Cached.Expires
							then
								Cached = {
									Expires = Now + 3,
									Entries = GetHouseDoorEntries(Target)
								}

								DoorCache[Key] = Cached
							end

							UnlockHouseDoors(
								Target,
								CommandDoorRE,
								UnknownStateAttempted,
								Cached.Entries
							)
						end
					end

					task.wait(0.45)
				end
			end)
		end
	)

	TVLoopToggle = Toggle(
		Casa,
		"Ligar e Desligar TV ",
		false,
		function(Enabled)
			TVLoopEnabled = Enabled == true
			TVLoopToken += 1

			if not TVLoopEnabled then
				return
			end

			if HousePlayers:GetSelectedCount() == 0 then

				task.defer(function()
					if TVLoopToggle then
						TVLoopToggle:Set(false,false)
					end
				end)
				TVLoopEnabled = false
				return
			end

			local ThisToken = TVLoopToken

			task.spawn(function()
				local TVCache = {}

				while
					TVLoopEnabled
					and
					ThisToken == TVLoopToken
					and
					Gui.Parent
				do
					local Now = os.clock()

					for _,Target in ipairs(HousePlayers:GetPlayers()) do
						local Key = Target.UserId
						local Cached = TVCache[Key]

						if
							not Cached
							or
							Now >= Cached.Expires
						then
							Cached = {
								Expires = Now + 3,
								Items = GetHouseTVRemotes(Target)
							}

							TVCache[Key] = Cached
						end

						FireTVs(
							Target,
							Cached.Items
						)
					end

					task.wait(0.45)
				end
			end)
		end
	)

	CurtainLoopToggle = Toggle(
		Casa,
		"Abrir e Fechar Cortinas",
		false,
		function(Enabled)
			CurtainLoopEnabled = Enabled == true
			CurtainLoopToken += 1

			if not CurtainLoopEnabled then
				return
			end

			if HousePlayers:GetSelectedCount() == 0 then

				task.defer(function()
					if CurtainLoopToggle then
						CurtainLoopToggle:Set(false,false)
					end
				end)
				CurtainLoopEnabled = false
				return
			end

			local ThisToken = CurtainLoopToken

			task.spawn(function()
				local CurtainCache = {}
				local FurnitureInteractRE = nil

				while
					CurtainLoopEnabled
					and
					ThisToken == CurtainLoopToken
					and
					Gui.Parent
				do
					if
						not FurnitureInteractRE
						or
						not FurnitureInteractRE.Parent
					then
						local RemotesFolder =
							ReplicatedStorage:FindFirstChild("Remotes")

						FurnitureInteractRE =
							RemotesFolder
							and
							RemotesFolder:FindFirstChild("FurnitureInteractRE")
					end

					if FurnitureInteractRE then
						local Now = os.clock()

						for _,Target in ipairs(HousePlayers:GetPlayers()) do
							local Key = Target.UserId
							local Cached = CurtainCache[Key]

							if
								not Cached
								or
								Now >= Cached.Expires
							then
								Cached = {
									Expires = Now + 3,
									Items = GetCurtainEntries(Target)
								}

								CurtainCache[Key] = Cached
							end

							FireCurtains(
								Target,
								FurnitureInteractRE,
								Cached.Items
							)
						end
					end

					task.wait(0.45)
				end
			end)
		end
	)


	--========================================================
	-- INTERRUPTORES DE LUZ (LOOP)
	--
	-- Runtime em tabela para não aumentar a quantidade de locals
	-- do bloco Casa, que já está próximo do limite do Luau.
	--========================================================

	CartolaHouseSwitchLoop = {
		Enabled = false,
		Token = 0,
		Toggle = nil
	}

	function CartolaHouseSwitchLoop:GetDetectors(Target)
		local HouseModel =
			GetTargetHouseModel(Target)

		if not HouseModel then
			return {}
		end

		local Result = {}
		local Seen = {}

		for _,Object in ipairs(
			HouseModel:GetDescendants()
		) do
			if
				Object:IsA("ClickDetector")
				and
				not Seen[Object]
			then
				local Node =
					Object.Parent

				local FoundSwitch =
					false

				for _=1,3 do
					if not Node then
						break
					end

					if
						string.lower(
							tostring(
								Node.Name
								or
								""
							)
						)
						==
						"switch"
					then
						FoundSwitch =
							true

						break
					end

					Node =
						Node.Parent
				end

				if FoundSwitch then
					Seen[Object] =
						true

					table.insert(
						Result,
						Object
					)
				end
			end
		end

		return Result
	end

	function CartolaHouseSwitchLoop:ClickTarget(Target,Detectors)
		if
			type(fireclickdetector)
			~=
			"function"
		then
			return 0
		end

		local Clicked =
			0

		for _,Detector in ipairs(
			Detectors
			or
			self:GetDetectors(Target)
		) do
			if
				Detector
				and
				Detector.Parent
			then
				local Ok =
					pcall(
						fireclickdetector,
						Detector
					)

				if Ok then
					Clicked += 1
				end
			end
		end

		return Clicked
	end

	function CartolaHouseSwitchLoop:Stop()
		self.Enabled =
			false

		self.Token +=
			1
	end

	function CartolaHouseSwitchLoop:Start()
		if
			type(fireclickdetector)
			~=
			"function"
		then


			return false
		end

		if
			HousePlayers:GetSelectedCount()
			==
			0
		then


			return false
		end

		self.Enabled =
			true

		self.Token +=
			1

		local ThisToken =
			self.Token

		task.spawn(function()
			local DetectorCache = {}

			while
				CartolaHouseSwitchLoop
				and
				CartolaHouseSwitchLoop.Enabled
				and
				ThisToken
				==
				CartolaHouseSwitchLoop.Token
				and
				Gui.Parent
			do
				local Now = os.clock()

				for _,Target in ipairs(
					HousePlayers:GetPlayers()
				) do
					local Key = Target.UserId
					local Cached = DetectorCache[Key]

					if
						not Cached
						or
						Now >= Cached.Expires
					then
						Cached = {
							Expires = Now + 3,
							Items = CartolaHouseSwitchLoop:GetDetectors(Target)
						}

						DetectorCache[Key] = Cached
					end

					CartolaHouseSwitchLoop:ClickTarget(
						Target,
						Cached.Items
					)
				end

				task.wait(
					0.45
				)
			end
		end)

		return true
	end

	CartolaHouseSwitchLoop.Toggle =
		Toggle(
			Casa,
			"Acender e Apagar a Luz",
			false,
			function(Enabled)
				if Enabled then
					if
						not CartolaHouseSwitchLoop:Start()
					then
						task.defer(function()
							if
								CartolaHouseSwitchLoop
								and
								CartolaHouseSwitchLoop.Toggle
							then
								CartolaHouseSwitchLoop.Toggle:Set(
									false,
									false
								)
							end
						end)
					end
				else
					CartolaHouseSwitchLoop:Stop()
				end
			end
		)

	CartolaPanicRegistry:Register(
		"HouseLoops",
		function()
			DoorLoopEnabled = false
			DoorLoopToken += 1
			TVLoopEnabled = false
			TVLoopToken += 1
			CurtainLoopEnabled = false
			CurtainLoopToken += 1

			if CartolaHouseSwitchLoop then
				CartolaHouseSwitchLoop:Stop()

				if CartolaHouseSwitchLoop.Toggle then
					CartolaHouseSwitchLoop.Toggle:Set(
						false,
						false
					)
				end
			end

			if DoorLoopToggle then
				DoorLoopToggle:Set(false,false)
			end

			if TVLoopToggle then
				TVLoopToggle:Set(false,false)
			end

			if CurtainLoopToggle then
				CurtainLoopToggle:Set(false,false)
			end
		end
	)

	Gui.Destroying:Connect(function()
		DoorLoopEnabled = false
		DoorLoopToken += 1
		TVLoopEnabled = false
		TVLoopToken += 1
		CurtainLoopEnabled = false
		CurtainLoopToken += 1

		if CartolaHouseSwitchLoop then
			CartolaHouseSwitchLoop:Stop()
		end
	end)
end

Section(
	Veiculos,
	"Veículos"
)

--============================================================
-- SPAWN INFINITO DE VEÍCULOS + EFEITOS
--
-- Cada veículo spawnado recebe imediatamente o efeito específico.
-- Ônibus e ônibus escolar continuam repetindo DiDiStart enquanto ON.
--============================================================

do
	local SpawnOptions={
		{name="Ônibus",id="ltp2_car_12",mode="BusLoop"},
		{name="Carro de Polícia",id="ltp2_car_13",mode="Police"},
		{name="Ambulância",id="ltp2_car_14",mode="Ambulance"},
		{name="Ônibus Escolar",id="ltp2_car_15",mode="SchoolLoop"},
		{name="Caminhão de Bombeiros",id="ltp2_car_16",mode="Fire"},
		{name="Drone",id="ltp2_car_77",mode="None"},
		{name="Retroescavadeira",id="ltp2_car_79",mode="None"}
	}

	local SelectedVehicle=
		SpawnOptions[1]

	local LoopEffectVehicles=
		setmetatable(
			{},
			{__mode="k"}
		)

	local InfiniteSpawnEnabled=
		false

	local SpawnToken=
		0

	local SpawnInterval=
		0.35

	local Frame=New("Frame",{
		Size=UDim2.new(1,-8,0,56),
		BackgroundColor3=Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},Veiculos)

	Corner(Frame,9)

	New("TextLabel",{
		Size=UDim2.new(0.42,0,1,0),
		Position=UDim2.fromOffset(18,0),
		BackgroundTransparency=1,
		Text="Veículo",
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamMedium,
		TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left
	},Frame)

	local SelectButton=New("TextButton",{
		Size=UDim2.new(0.48,-20,0,38),
		Position=UDim2.new(0.52,5,0,9),
		BackgroundColor3=Theme.Card2,
		BorderSizePixel=0,
		Text=SelectedVehicle.name,
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamBold,
		TextSize=12,
		TextTruncate=Enum.TextTruncate.AtEnd
	},Frame)

	Corner(SelectButton,8)

	local List=New("ScrollingFrame",{
		Size=UDim2.new(1,-36,0,220),
		Position=UDim2.fromOffset(18,62),
		BackgroundColor3=Color3.fromRGB(35,35,38),
		BorderSizePixel=0,
		ScrollBarThickness=3,
		ScrollBarImageColor3=Theme.Accent,
		CanvasSize=UDim2.new(
			0,
			0,
			0,
			#SpawnOptions*39
		),
		Visible=false
	},Frame)

	Corner(List,8)
	New("UIListLayout",{Padding=UDim.new(0,4)},List)

	local Opened=false

	for _,Option in ipairs(SpawnOptions) do
		local OptionButton=New("TextButton",{
			Size=UDim2.new(1,-5,0,35),
			BackgroundColor3=Theme.Card2,
			BorderSizePixel=0,
			Text=Option.name,
			TextColor3=Theme.Text,
			Font=Enum.Font.GothamMedium,
			TextSize=13
		},List)

		Corner(OptionButton,7)

		OptionButton.MouseButton1Click:Connect(function()
			SelectedVehicle=
				Option

			SelectButton.Text=
				Option.name

			Opened=
				false

			List.Visible=
				false

			Frame.Size=
				UDim2.new(
					1,
					-8,
					0,
					56
				)
		end)
	end

	SelectButton.MouseButton1Click:Connect(function()
		Opened=
			not Opened

		List.Visible=
			Opened

		Frame.Size=
			UDim2.new(
				1,
				-8,
				0,
				Opened and 292 or 56
			)
	end)

	local function GetSpawnRemote()
		local Remotes=
			ReplicatedStorage:FindFirstChild(
				"Remotes"
			)

		return
			Remotes
			and
			Remotes:FindFirstChild(
				"SpawnVehiclesRE"
			)
	end

	local function GetVehicleRequestRemote()
		local Remotes=
			ReplicatedStorage:FindFirstChild(
				"Remotes"
			)

		return
			Remotes
			and
			Remotes:FindFirstChild(
				"VehiclesClientReqRE"
			)
	end

	local function GetVehicleOwner(
		Vehicle
	)
		if
			not Vehicle
			or
			not Vehicle.Parent
		then
			return nil
		end

		local OwnerValue=
			Vehicle:FindFirstChild(
				"VehicleOwner"
			)
			or
			Vehicle:FindFirstChild(
				"VehicleOwner",
				true
			)

		if
			OwnerValue
			and
			OwnerValue:IsA("ObjectValue")
			and
			OwnerValue.Value
			and
			OwnerValue.Value:IsA("Player")
		then
			return
				OwnerValue.Value
		end

		return nil
	end

	local function CollectMatching(
		Id
	)
		local Found={}
		local Cars=
			workspace:FindFirstChild(
				"Cars"
			)

		if Cars then
			for _,Object in ipairs(
				Cars:GetDescendants()
			) do
				if
					Object.Name==Id
					and
					(
						Object:IsA("Model")
						or
						Object:IsA("BasePart")
					)
				then
					Found[Object]=true
				end
			end
		end

		return Found
	end

	local function FindSpawnedVehicle(
		Id,
		Before,
		Timeout
	)
		local Deadline=
			os.clock()
			+
			(Timeout or 2.5)

		repeat
			local Cars=
				workspace:FindFirstChild(
					"Cars"
				)

			if Cars then
				local NewFallback=nil
				local OwnedFallback=nil

				for _,Object in ipairs(
					Cars:GetDescendants()
				) do
					if
						Object.Name==Id
						and
						(
							Object:IsA("Model")
							or
							Object:IsA("BasePart")
						)
					then
						local Owner=
							GetVehicleOwner(
								Object
							)

						if not Before[Object] then
							if Owner==Player then
								return Object
							end

							NewFallback=
								NewFallback
								or
								Object

						elseif Owner==Player then
							OwnedFallback=
								OwnedFallback
								or
								Object
						end
					end
				end

				if NewFallback then
					return NewFallback
				end

				if OwnedFallback then
					return OwnedFallback
				end
			end

			task.wait(
				0.04
			)

		until
			os.clock()>=Deadline

		return nil
	end

	local function FireVehicleEffect(
		Option,
		Vehicle
	)
		if
			not Option
			or
			not Vehicle
			or
			not Vehicle.Parent
		then
			return false
		end

		if
			Option.mode=="BusLoop"
			or
			Option.mode=="SchoolLoop"
		then
			local CarRemote=
				Vehicle:FindFirstChild(
					"CarRemoteEvent"
				)
				or
				Vehicle:FindFirstChild(
					"CarRemoteEvent",
					true
				)

			if CarRemote then
				return
					pcall(function()
						CarRemote:FireServer(
							"DiDiStart"
						)
					end)
			end

			return false
		end

		local Event=
			GetVehicleRequestRemote()

		if not Event then
			return false
		end

		if Option.mode=="Ambulance" then
			pcall(function()
				Event:FireServer(
					Vehicle,
					"Door"
				)
			end)

			pcall(function()
				Event:FireServer(
					Vehicle,
					"TopLight",
					true
				)
			end)

			return true
		end

		if Option.mode=="Police" then
			return
				pcall(function()
					Event:FireServer(
						Vehicle,
						"TopLight",
						true
					)
				end)
		end

		if Option.mode=="Fire" then
			pcall(function()
				Event:FireServer(
					Vehicle,
					"TopLight",
					true
				)
			end)

			pcall(function()
				Event:FireServer(
					Vehicle,
					"Water",
					Vehicle
				)
			end)

			return true
		end

		-- Retroescavadeira: somente spawn.
		return true
	end

	local function SpawnOnceAndApply(
		Option
	)
		local Remote=
			GetSpawnRemote()

		if not Remote then


			return nil
		end

		local Before=
			CollectMatching(
				Option.id
			)

		local Fired=
			pcall(function()
				Remote:FireServer(
					Option.id
				)
			end)

		if not Fired then
			return nil
		end

		local Vehicle=
			FindSpawnedVehicle(
				Option.id,
				Before,
				2.5
			)

		if Vehicle then
			pcall(function()
				Vehicle:SetAttribute(
					"CartolaUserSpawnedVehicle",
					true
				)
			end)

			-- REGRA: toda vez que um veículo for spawnado por esta seção,
			-- executa imediatamente o efeito correspondente.
			FireVehicleEffect(
				Option,
				Vehicle
			)

			if
				Option.mode=="BusLoop"
				or
				Option.mode=="SchoolLoop"
			then
				LoopEffectVehicles[
					Vehicle
				]=Option
			end
		end

		return Vehicle
	end

	-- Um único loop reaplica DiDiStart nos ônibus já spawnados.
	-- Evita criar uma task separada para cada veículo.
	task.spawn(function()
		while Gui.Parent do
			if InfiniteSpawnEnabled then
				for Vehicle,Option in pairs(
					LoopEffectVehicles
				) do
					if
						Vehicle
						and
						Vehicle.Parent
					then
						FireVehicleEffect(
							Option,
							Vehicle
						)
					else
						LoopEffectVehicles[
							Vehicle
						]=nil
					end
				end
			else
				table.clear(
					LoopEffectVehicles
				)
			end

			task.wait(
				0.25
			)
		end
	end)

	Toggle(
		Veiculos,
		"Spawn infinito de veículo",
		false,
		function(Enabled)
			SpawnToken+=1

			InfiniteSpawnEnabled=
				Enabled==true

			if not InfiniteSpawnEnabled then
				table.clear(
					LoopEffectVehicles
				)

				return
			end

			table.clear(
				LoopEffectVehicles
			)

			local CurrentToken=
				SpawnToken

			task.spawn(function()
				while
					InfiniteSpawnEnabled
					and
					CurrentToken==SpawnToken
					and
					Gui.Parent
				do
					local Option=
						SelectedVehicle

					-- Cada spawn recebe Door/TopLight/Water/DiDiStart
					-- correspondente antes de ir para o próximo ciclo.
					SpawnOnceAndApply(
						Option
					)

					task.wait(
						SpawnInterval
					)
				end
			end)
		end
	)

	Gui.Destroying:Connect(function()
		InfiniteSpawnEnabled=
			false

		SpawnToken+=1

		table.clear(
			LoopEffectVehicles
		)
	end)

	-- Mantém a referência usada pelas proteções sem criar outra opção
	-- visível na página de veículos.
	local DrivenVehicleReference = Gui:FindFirstChild("CartolaDrivenVehicle")
	if not DrivenVehicleReference then
		DrivenVehicleReference = Instance.new("ObjectValue")
		DrivenVehicleReference.Name = "CartolaDrivenVehicle"
		DrivenVehicleReference.Parent = Gui
	end

	local LastVehicleTrack = 0
	local VehicleTrackConnection = RunService.Heartbeat:Connect(function()
		local Now = os.clock()
		if Now - LastVehicleTrack < 0.4 then
			return
		end
		LastVehicleTrack = Now

		local Humanoid = GetHumanoid()
		local Seat = Humanoid and Humanoid.SeatPart
		if not Seat then
			return
		end

		local Node = Seat
		local FallbackModel = nil
		while Node and Node ~= workspace do
			if Node.Name and Node.Name:match("^ltp2_car_%d+$") then
				DrivenVehicleReference.Value = Node
				return
			end
			if Node:IsA("Model") and Node:FindFirstChildWhichIsA("VehicleSeat", true) then
				FallbackModel = Node
			end
			Node = Node.Parent
		end

		if FallbackModel then
			DrivenVehicleReference.Value = FallbackModel
		end
	end)

	Gui.Destroying:Connect(function()
		InfiniteSpawnEnabled = false
		SpawnToken += 1
		if VehicleTrackConnection then
			VehicleTrackConnection:Disconnect()
			VehicleTrackConnection = nil
		end
	end)
end

Section(
	Veiculos,
	"Fling de Veículo"
)

do
(function()
	local FlingTarget=CreatePlayerSelector(
		Veiculos,
		"Player do Fling de Veículo",
		true
	)

	local SelectedVehicle=nil
	local Options={}
	local Opened=false
	local Enabled=false
	local Connection=nil
	local NextDrive=0
	local Time=0
	local OriginalSelfCFrame=nil
	local OriginalVehicleState=nil
	local OriginalSelfRelativeToVehicle=nil
	local OriginalSeat=nil
	local OriginalWasSeated=false
	local SelfPartBackup={}
	local VoidHoldUntil=0
	local LastSeatAttempt=0

	local KnownVehicleNames={
		[12]="Ônibus",
		[14]="Ambulância",
		[15]="Ônibus Escolar",
		[16]="Caminhão de Bombeiros",
		[77]="Drone",
		[79]="Retroescavadeira"
	}
	local MotoIds={[30]=true,[31]=true,[41]=true,[7]=true,[8]=true,[53]=true,[83]=true,[72]=true,[59]=true}
	local BicycleIds={[54]=true,[70]=true,[5]=true}

	local function IsInsidePlanes(Vehicle)
		local Node=Vehicle
		while Node and Node~=workspace do
			if Node.Name=="Planes" then
				return true
			end
			Node=Node.Parent
		end
		return false
	end

	local function DisplayName(Name,Vehicle)
		local Id=tonumber(tostring(Name):match("^ltp2_car_(%d+)$"))
		if Id and KnownVehicleNames[Id] then return KnownVehicleNames[Id] end
		if Id==6 then return "Cadeira de Rodas" end
		if Id and MotoIds[Id] then return "Moto" end
		if Id and BicycleIds[Id] then return "Bicicleta" end
		if Vehicle and IsInsidePlanes(Vehicle) then return "Avião" end
		return "Carro"
	end

	local function Icon(Name,Vehicle)
		local D=DisplayName(Name,Vehicle)
		if D=="Moto" then return "🏍️" end
		if D=="Bicicleta" then return "🚲" end
		if D=="Cadeira de Rodas" then return "♿" end
		if D=="Drone" then return "🛸" end
		if D=="Avião" then return "✈️" end
		if D=="Ônibus" or D=="Ônibus Escolar" then return "🚌" end
		if D=="Ambulância" then return "🚑" end
		if D=="Caminhão de Bombeiros" then return "🚒" end
		if D=="Retroescavadeira" then return "🚜" end
		return "🚗"
	end

	local function ResolveOwnerValue(ValueObject)
		if not ValueObject then return nil,nil end

		if ValueObject:IsA("ObjectValue") then
			local Value=ValueObject.Value
			if Value and Value:IsA("Player") and Value.Parent==Players then
				return Value,Value.Name
			end
			return nil,nil
		end

		if
			ValueObject:IsA("StringValue")
			or ValueObject:IsA("IntValue")
			or ValueObject:IsA("NumberValue")
		then
			local Raw=tostring(ValueObject.Value or "")
			if Raw=="" then return nil,nil end

			local Direct=Players:FindFirstChild(Raw)
			if Direct and Direct:IsA("Player") then
				return Direct,Direct.Name
			end

			local UserId=tonumber(Raw)
			if UserId then
				local ById=Players:GetPlayerByUserId(UserId)
				if ById then
					return ById,ById.Name
				end
			end

			return nil,Raw
		end

		return nil,nil
	end

	local function OwnerOf(Vehicle)
		if typeof(Vehicle)~="Instance" or not Vehicle.Parent then return nil,nil end

		local VehicleOwner=
			Vehicle:FindFirstChild("VehicleOwner")
			or Vehicle:FindFirstChild("VehicleOwner",true)

		local Owner,OwnerName=ResolveOwnerValue(VehicleOwner)
		if Owner or OwnerName then
			return Owner,OwnerName
		end

		-- Aeronaves do Metro Life ficam em workspace.Planes e expõem o dono
		-- em PlaneOwner (normalmente StringValue com o nome do player).
		local Node=Vehicle
		while Node and Node~=workspace do
			local PlaneOwner=Node:FindFirstChild("PlaneOwner")
			if PlaneOwner then
				Owner,OwnerName=ResolveOwnerValue(PlaneOwner)
				if Owner or OwnerName then
					return Owner,OwnerName
				end
			end

			local Attribute=Node:GetAttribute("PlaneOwner")
			if Attribute~=nil then
				local Raw=tostring(Attribute)
				local Direct=Players:FindFirstChild(Raw)
				if Direct and Direct:IsA("Player") then
					return Direct,Direct.Name
				end
				if Raw~="" then
					return nil,Raw
				end
			end

			Node=Node.Parent
		end

		return nil,nil
	end

	local function IsVehicle(Object)
		return typeof(Object)=="Instance"
			and Object.Name
			and Object.Name:match("^ltp2_car_%d+$")
			and (Object:IsA("Model") or Object:IsA("BasePart"))
			and Object:IsDescendantOf(workspace)
	end

	local function VehicleId(Vehicle)
		return
			Vehicle
			and
			tonumber(
				tostring(Vehicle.Name):match(
					"^ltp2_car_(%d+)$"
				)
			)
	end

	local Frame=New("Frame",{
		Size=UDim2.new(1,-8,0,56),
		BackgroundColor3=Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},Veiculos)
	Corner(Frame,9)

	New("TextLabel",{
		Size=UDim2.new(0.42,0,1,0),
		Position=UDim2.fromOffset(18,0),
		BackgroundTransparency=1,
		Text="Veículo do Fling",
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamMedium,
		TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left
	},Frame)

	local Button=New("TextButton",{
		Size=UDim2.new(0.48,-20,0,38),
		Position=UDim2.new(0.52,5,0,9),
		BackgroundColor3=Theme.Card2,
		BorderSizePixel=0,
		Text="Selecionar veículo",
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamBold,
		TextSize=12,
		TextTruncate=Enum.TextTruncate.AtEnd
	},Frame)
	Corner(Button,8)

	local List=New("ScrollingFrame",{
		Size=UDim2.new(1,-36,0,220),
		Position=UDim2.fromOffset(18,62),
		BackgroundColor3=Color3.fromRGB(35,35,38),
		BorderSizePixel=0,
		ScrollBarThickness=3,
		ScrollBarImageColor3=Theme.Accent,
		CanvasSize=UDim2.new(),
		Visible=false
	},Frame)
	Corner(List,8)
	New("UIListLayout",{Padding=UDim.new(0,4)},List)

	local function Scan()
		local R={}
		local Seen={}

		-- Procura todos os ltp2_car_XX do mapa, inclusive os que aparecem
		-- dentro de workspace.Planes. Para aeronaves, o dono vem de PlaneOwner.
		for _,Object in ipairs(workspace:GetDescendants()) do
			if IsVehicle(Object) and not Seen[Object] then
				local Owner,OwnerName=OwnerOf(Object)

				if
					Owner == Player
					or
					(
						OwnerName
						and
						tostring(OwnerName) == Player.Name
					)
				then
					Seen[Object]=true
					local FriendlyName=DisplayName(Object.Name,Object)
					table.insert(R,{
						instance=Object,
						owner=Owner,
						ownerName=OwnerName,
						label=FriendlyName
					})
				end
			end
		end

		table.sort(R,function(A,B)
			if A.label==B.label then
				return tostring(A.ownerName or "")<tostring(B.ownerName or "")
			end
			return A.label<B.label
		end)
		Options=R

		if SelectedVehicle then
			local Found=false
			for _,Option in ipairs(R) do
				if Option.instance==SelectedVehicle.instance then
					SelectedVehicle=Option
					Found=true
					break
				end
			end
			if not Found then
				SelectedVehicle=nil
				Button.Text="Selecionar veículo"
			end
		end
	end

	local function Render()
		for _,Child in ipairs(List:GetChildren()) do
			if Child:IsA("TextButton") then Child:Destroy() end
		end

		List.CanvasSize=UDim2.new(0,0,0,math.max(1,#Options)*54)

		if #Options==0 then
			local Empty=New("TextButton",{
				Size=UDim2.new(1,-5,0,35),
				BackgroundColor3=Theme.Card2,
				BorderSizePixel=0,
				Text="Nenhum veículo seu encontrado",
				TextColor3=Theme.SubText,
				Font=Enum.Font.GothamMedium,
				TextSize=12,
				AutoButtonColor=false
			},List)
			Corner(Empty,7)
			return
		end

		for _,Option in ipairs(Options) do
			local B=New("TextButton",{
				Size=UDim2.new(1,-5,0,50),
				BackgroundColor3=Theme.Card2,
				BorderSizePixel=0,
				Text="",
				AutoButtonColor=true
			},List)
			Corner(B,8)
			Stroke(B)

			New("TextLabel",{
				Size=UDim2.fromOffset(34,50),
				Position=UDim2.fromOffset(5,0),
				BackgroundTransparency=1,
				Text=Icon(Option.instance.Name,Option.instance),
				TextColor3=Theme.Accent,
				Font=Enum.Font.GothamBold,
				TextSize=18
			},B)

			New("TextLabel",{
				Size=UDim2.new(1,-48,0,21),
				Position=UDim2.fromOffset(40,5),
				BackgroundTransparency=1,
				Text=DisplayName(Option.instance.Name,Option.instance),
				TextColor3=Theme.Text,
				Font=Enum.Font.GothamBold,
				TextSize=13,
				TextXAlignment=Enum.TextXAlignment.Left,
				TextTruncate=Enum.TextTruncate.AtEnd
			},B)

			New("TextLabel",{
				Size=UDim2.new(1,-48,0,18),
				Position=UDim2.fromOffset(40,26),
				BackgroundTransparency=1,
				Text=
					"Dono: "..tostring(Option.ownerName or "Desconhecido"),
				TextColor3=Theme.SubText,
				Font=Enum.Font.GothamMedium,
				TextSize=11,
				TextXAlignment=Enum.TextXAlignment.Left,
				TextTruncate=Enum.TextTruncate.AtEnd
			},B)

			B.MouseButton1Click:Connect(function()
				SelectedVehicle=Option
				Button.Text=Option.label
				Opened=false
				List.Visible=false
				Frame.Size=UDim2.new(1,-8,0,56)
			end)
		end
	end

	Button.MouseButton1Click:Connect(function()
		Opened=not Opened
		if Opened then Scan() Render() end
		List.Visible=Opened
		Frame.Size=UDim2.new(1,-8,0,Opened and 292 or 56)
	end)

	local function ClaimPhysics()
		pcall(function()
			if type(setsimulationradius)=="function" then
				setsimulationradius(1e9,1e9)
			elseif type(sethiddenproperty)=="function" then
				sethiddenproperty(Player,"SimulationRadius",1e9)
			end
		end)
	end

	local function MoverRemote()
		local M=ReplicatedStorage:FindFirstChild("Mover")
		local E=M and M:FindFirstChild("Events")
		return E and E:FindFirstChild("MoverRE")
	end

	local function RequestControl()
		if
			not SelectedVehicle
			or
			not SelectedVehicle.instance
			or
			not SelectedVehicle.instance.Parent
		then
			return
		end

		ClaimPhysics()

		-- Veículo do próprio jogador normalmente já está sob a física local.
		-- Evita chamar "Drive" nesse caso, porque esse remoto pode tentar
		-- colocar/mover o personagem junto com o veículo.
		local IsOwnVehicle =
			SelectedVehicle.owner == Player
			or
			(
				SelectedVehicle.ownerName
				and
				tostring(SelectedVehicle.ownerName) == Player.Name
			)

		if IsOwnVehicle then
			return
		end

		local R=MoverRemote()
		if not R then
			return
		end

		local SelfRoot=GetRoot()
		local SelfHumanoid=GetHumanoid()
		local BeforeCFrame=SelfRoot and SelfRoot.CFrame or nil
		local BeforeLinear=SelfRoot and SelfRoot.AssemblyLinearVelocity or nil
		local BeforeAngular=SelfRoot and SelfRoot.AssemblyAngularVelocity or nil

		pcall(function()
			R:FireServer("Drive",SelectedVehicle.instance,nil)
		end)

		-- Alguns veículos/remotos tentam sentar o jogador local para entregar
		-- controle. Se isso acontecer, solta imediatamente e preserva o local
		-- em que o jogador realmente estava.
		task.defer(function()
			RunService.Heartbeat:Wait()

			local RootNow=GetRoot()
			local HumanoidNow=GetHumanoid()

			if
				not RootNow
				or
				not HumanoidNow
				or
				not BeforeCFrame
			then
				return
			end

			local SeatPart=HumanoidNow.SeatPart
			local ForcedIntoSelectedVehicle =
				SeatPart
				and
				SelectedVehicle
				and
				SelectedVehicle.instance
				and
				SelectedVehicle.instance.Parent
				and
				SeatPart:IsDescendantOf(SelectedVehicle.instance)

			local ForcedDisplacement =
				(RootNow.Position-BeforeCFrame.Position).Magnitude > 10

			if ForcedIntoSelectedVehicle then
				local Weld=SeatPart:FindFirstChild("SeatWeld")

				if
					Weld
					and
					Weld:IsA("Weld")
					and
					Weld.Part1
					and
					Weld.Part1:IsDescendantOf(RootNow.Parent)
				then
					pcall(function()
						Weld:Destroy()
					end)
				end

				pcall(function()
					HumanoidNow.Sit=false
					HumanoidNow.PlatformStand=false
					HumanoidNow:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end

			if ForcedIntoSelectedVehicle or ForcedDisplacement then
				pcall(function()
					RootNow.CFrame=BeforeCFrame
					RootNow.AssemblyLinearVelocity=BeforeLinear or Vector3.zero
					RootNow.AssemblyAngularVelocity=BeforeAngular or Vector3.zero
				end)
			end
		end)
	end

	local function PhysicalRoot(Vehicle)
		if not Vehicle or not Vehicle.Parent then return nil,nil end

		local Source=Vehicle

		local Seat=
			Source:FindFirstChild("DriveSeat",true)
			or
			Source:FindFirstChild("DriverSeat",true)
			or
			Source:FindFirstChildWhichIsA("VehicleSeat",true)
			or
			Source:FindFirstChildWhichIsA("Seat",true)

		if not Seat and Source~=Vehicle then
			Seat=
				Vehicle:FindFirstChild("DriveSeat",true)
				or
				Vehicle:FindFirstChild("DriverSeat",true)
				or
				Vehicle:FindFirstChildWhichIsA("VehicleSeat",true)
				or
				Vehicle:FindFirstChildWhichIsA("Seat",true)
		end

		if Seat and Seat:IsA("BasePart") then
			return Seat.AssemblyRootPart or Seat,Seat
		end

		if Source:IsA("BasePart") then
			return Source.AssemblyRootPart or Source,nil
		end

		if Source:IsA("Model") then
			local Part=Source.PrimaryPart or Source:FindFirstChildWhichIsA("BasePart",true)
			if Part then return Part.AssemblyRootPart or Part,Seat end
		end

		return nil,nil
	end

	local function RestoreSelfCollision()
		for Part,Data in pairs(SelfPartBackup) do
			if Part and Part.Parent then
				pcall(function()
					Part.CanCollide=Data.CanCollide
					Part.CanTouch=Data.CanTouch
				end)
			end

			SelfPartBackup[Part]=nil
		end
	end

	local function PrepareSelfForVehicleFling()
		RestoreSelfCollision()

		local Character=
			GetCharacter()

		local Humanoid=
			GetHumanoid()

		local SelfRoot=
			GetRoot()

		if Character then
			for _,Part in ipairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					SelfPartBackup[Part]={
						CanCollide=Part.CanCollide,
						CanTouch=Part.CanTouch
					}

					-- Não mexe mais em CanCollide: isso deixava o personagem
					-- sem uma física de movimento normal. CanTouch=false ajuda
					-- a não disparar contatos/Seats do veículo-projétil.
					pcall(function()
						Part.CanTouch=false
					end)
				end
			end
		end

		-- Se o jogador estava pilotando/sentado no veículo selecionado,
		-- solta o SeatWeld antes de transformar a moto/carro em projétil.
		if OriginalSeat and OriginalSeat.Parent then
			local Weld=
				OriginalSeat:FindFirstChild(
					"SeatWeld"
				)

			if
				Weld
				and
				Weld:IsA("Weld")
				and
				Weld.Part1
				and
				Character
				and
				Weld.Part1:IsDescendantOf(
					Character
				)
			then
				pcall(function()
					Weld:Destroy()
				end)
			end
		end

		-- Só altera o estado do Humanoid se ele realmente estava sentado no
		-- veículo selecionado. Se já estava em pé, o Vehicle Fling não toca
		-- no estado nem no CFrame do personagem.
		if Humanoid and OriginalWasSeated then
			pcall(function()
				Humanoid.Sit=false
				Humanoid.PlatformStand=false
				Humanoid.AutoRotate=true
				Humanoid:ChangeState(
					Enum.HumanoidStateType.GettingUp
				)
			end)

			if SelfRoot then
				pcall(function()
					SelfRoot.AssemblyAngularVelocity=Vector3.zero
				end)
			end
		end
	end

	local function HoldSelfSafe()
		local SelfRoot=
			GetRoot()

		local Humanoid=
			GetHumanoid()

		if not SelfRoot or not Humanoid then
			return
		end

		-- Não prende mais o CFrame nem zera a velocidade a cada Heartbeat.
		-- Apenas corta um impulso EXTREMO caso o próprio veículo-projétil
		-- consiga tocar no jogador local. Movimento normal permanece livre.
		local Velocity=
			SelfRoot.AssemblyLinearVelocity

		local Angular=
			SelfRoot.AssemblyAngularVelocity

		if
			Velocity.Magnitude>125
			or
			Angular.Magnitude>30
		then
			local Move=
				Humanoid.MoveDirection

			local Horizontal=
				Vector3.zero

			if Move.Magnitude>0.01 then
				Horizontal=
					Move.Unit
					*
					Humanoid.WalkSpeed
			end

			pcall(function()
				SelfRoot.AssemblyLinearVelocity=
					Vector3.new(
						Horizontal.X,
						math.clamp(
							Velocity.Y,
							-70,
							70
						),
						Horizontal.Z
					)

				SelfRoot.AssemblyAngularVelocity=
					Vector3.zero
			end)
		end

		pcall(function()
			Humanoid.PlatformStand=false
			Humanoid.AutoRotate=true
		end)
	end

	local function TargetIsOnSelectedVehicle(
		Humanoid,
		Seat,
		Vehicle
	)
		if not Humanoid then
			return false
		end

		local SeatPart=
			Humanoid.SeatPart

		if SeatPart then
			if Seat and SeatPart==Seat then
				return true
			end

			if
				Vehicle
				and
				SeatPart:IsDescendantOf(
					Vehicle
				)
			then
				return true
			end
		end

		if
			Seat
			and
			Seat.Occupant==Humanoid
		then
			return true
		end

		return false
	end

	local function TryCaptureTargetOnVehicle(
		TargetRoot,
		Humanoid,
		Seat
	)
		if
			not TargetRoot
			or
			not Humanoid
			or
			not Seat
			or
			not Seat.Parent
		then
			return false
		end

		if
			Seat.Occupant
			and
			Seat.Occupant~=Humanoid
		then
			return false
		end

		local Now=
			os.clock()

		if
			Now-LastSeatAttempt
			<
			0.08
		then
			return false
		end

		LastSeatAttempt=
			Now

		-- Se estiver preso em outro banco, tenta quebrar a sentada primeiro.
		local OldSeat=
			Humanoid.SeatPart

		if
			OldSeat
			and
			OldSeat~=Seat
		then
			local OldWeld=
				OldSeat:FindFirstChild(
					"SeatWeld"
				)

			if
				OldWeld
				and
				OldWeld:IsA("Weld")
				and
				OldWeld.Part1
				and
				TargetRoot.Parent
				and
				OldWeld.Part1:IsDescendantOf(
					TargetRoot.Parent
				)
			then
				pcall(function()
					OldWeld:Destroy()
				end)
			end

			pcall(function()
				Humanoid.Sit=false
				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)
			end)
		end

		pcall(function()
			Seat.Disabled=false
			Seat.CanTouch=true
		end)

		if type(firetouchinterest)=="function" then
			pcall(function()
				firetouchinterest(
					Seat,
					TargetRoot,
					0
				)

				firetouchinterest(
					Seat,
					TargetRoot,
					1
				)
			end)
		end

		pcall(function()
			Seat:Sit(
				Humanoid
			)
		end)

		return
			TargetIsOnSelectedVehicle(
				Humanoid,
				Seat,
				SelectedVehicle
					and
					SelectedVehicle.instance
			)
	end

	local function CaptureReturnState()
		local SelfRoot=
			GetRoot()

		local Humanoid=
			GetHumanoid()

		OriginalSelfCFrame=
			SelfRoot
			and
			SelfRoot.CFrame
			or
			nil

		OriginalVehicleState=
			nil

		OriginalSelfRelativeToVehicle=
			nil

		OriginalSeat=
			nil

		OriginalWasSeated=
			false

		if
			not SelectedVehicle
			or
			not SelectedVehicle.instance
			or
			not SelectedVehicle.instance.Parent
		then
			return
		end

		local Vehicle=
			SelectedVehicle.instance

		local VehicleRoot,VehicleSeat=
			PhysicalRoot(
				Vehicle
			)

		if
			not VehicleRoot
			or
			not VehicleRoot.Parent
		then
			return
		end

		OriginalVehicleState={
			vehicle=Vehicle,
			root=VehicleRoot,
			seat=VehicleSeat,
			cframe=VehicleRoot.CFrame,
			linear=VehicleRoot.AssemblyLinearVelocity,
			angular=VehicleRoot.AssemblyAngularVelocity
		}

		if SelfRoot then
			OriginalSelfRelativeToVehicle=
				VehicleRoot.CFrame:ToObjectSpace(
					SelfRoot.CFrame
				)
		end

		if
			Humanoid
			and
			Humanoid.SeatPart
		then
			local SeatPart=
				Humanoid.SeatPart

			local SameAssembly=
				SeatPart.AssemblyRootPart
				==
				VehicleRoot

			local InsideVehicle=
				SeatPart:IsDescendantOf(
					Vehicle
				)

			if
				SameAssembly
				or
				InsideVehicle
			then
				OriginalWasSeated=
					true

				OriginalSeat=
					SeatPart
			end
		end
	end

	local function RestoreReturnState()
		local VehicleState=
			OriginalVehicleState

		-- Limpa todo estado salvo do personagem. O Vehicle Fling não deve
		-- teleportar o jogador de volta quando for desligado.
		OriginalSelfCFrame=
			nil

		OriginalVehicleState=
			nil

		OriginalSelfRelativeToVehicle=
			nil

		OriginalSeat=
			nil

		OriginalWasSeated=
			false

		RestoreSelfCollision()

		if not VehicleState then
			return
		end

		local function ResolveReturnRoot()
			local Vehicle=
				VehicleState.vehicle

			if
				Vehicle
				and
				Vehicle.Parent
			then
				local CurrentRoot=
					PhysicalRoot(
						Vehicle
					)

				if
					CurrentRoot
					and
					CurrentRoot.Parent
				then
					return CurrentRoot
				end
			end

			if
				VehicleState.root
				and
				VehicleState.root.Parent
			then
				return VehicleState.root
			end

			return nil
		end

		local function ApplyVehicleReturn()
			RequestControl()

			local ReturnRoot=
				ResolveReturnRoot()

			if ReturnRoot then
				pcall(function()
					ReturnRoot.AssemblyLinearVelocity=
						Vector3.zero

					ReturnRoot.AssemblyAngularVelocity=
						Vector3.zero

					ReturnRoot.CFrame=
						VehicleState.cframe
				end)
			end
		end

		-- Restaura somente o veículo.
		ApplyVehicleReturn()

		-- Repete por alguns frames para vencer a última velocidade do fling,
		-- mas nunca altera a posição atual do personagem local.
		task.spawn(function()
			for _=1,14 do
				RunService.Heartbeat:Wait()

				if Enabled then
					return
				end

				ApplyVehicleReturn()
			end

			local FinalRoot=
				ResolveReturnRoot()

			if FinalRoot then
				pcall(function()
					FinalRoot.AssemblyLinearVelocity=
						Vector3.zero

					FinalRoot.AssemblyAngularVelocity=
						Vector3.zero
				end)
			end
		end)
	end

	local function MoveVehicle(TargetCF,Linear,Angular)
		if not SelectedVehicle or not SelectedVehicle.instance or not SelectedVehicle.instance.Parent then return false end
		local Root,Seat=PhysicalRoot(SelectedVehicle.instance)
		if not Root or not Root.Parent then return false end

		return pcall(function()
			if Seat and Seat.Parent then
				local Delta=TargetCF*Seat.CFrame:Inverse()
				Root.CFrame=Delta*Root.CFrame
			else
				Root.CFrame=TargetCF
			end
			Root.AssemblyLinearVelocity=Linear or Vector3.zero
			Root.AssemblyAngularVelocity=Angular or Vector3.zero
		end)
	end

	local function Stop(RestorePosition)
		local WasEnabled=Enabled

		Enabled=false
		Gui:SetAttribute("VehicleFlingActive",false)

		if Connection then
			Connection:Disconnect()
			Connection=nil
		end

		if RestorePosition and WasEnabled then
			RestoreReturnState()
		elseif not RestorePosition then
			RestoreSelfCollision()

			OriginalSelfCFrame=nil
			OriginalVehicleState=nil
			OriginalSelfRelativeToVehicle=nil
			OriginalSeat=nil
			OriginalWasSeated=false
		end
	end

	CartolaPanicRegistry:Register(
		"VehicleFling",
		function()
			Stop(true)
		end
	)

	Toggle(
		Veiculos,
		"Fling de Veículo no Player",
		false,
		function(On)
			if not On then
				Stop(true)
				return
			end

			Stop(false)

			if not FlingTarget:GetFirst() then

				return
			end
			if not SelectedVehicle then

				return
			end

			CaptureReturnState()
			PrepareSelfForVehicleFling()

			-- Se o jogador estava sentado no veículo selecionado, dá tempo
			-- apenas para o SeatWeld desaparecer. Em pé, o personagem não é movido.
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()

			Enabled=true
			Time=0
			NextDrive=0
			VoidHoldUntil=0
			LastSeatAttempt=0
			Gui:SetAttribute("VehicleFlingActive",true)
			RequestControl()

			Connection=RunService.Heartbeat:Connect(function(Dt)
				if not Enabled then return end

				-- O próprio player não acompanha mais a moto durante o fling.
				HoldSelfSafe()

				local Target=
					FlingTarget:GetFirst()

				local Character=
					Target
					and
					Target.Character

				local Root=
					Character
					and
					Character:FindFirstChild(
						"HumanoidRootPart"
					)

				local Humanoid=
					Character
					and
					Character:FindFirstChildOfClass(
						"Humanoid"
					)

				if
					not Root
					or
					not Humanoid
					or
					Humanoid.Health<=0
					or
					not SelectedVehicle
					or
					not SelectedVehicle.instance
					or
					not SelectedVehicle.instance.Parent
				then
					return
				end

				local Now=
					os.clock()

				if Now>=NextDrive then
					NextDrive=Now+0.05
					RequestControl()
				end

				Time+=Dt

				local Vehicle=
					SelectedVehicle.instance

				local VehicleRoot,Seat=
					PhysicalRoot(
						Vehicle
					)

				if
					not VehicleRoot
					or
					not VehicleRoot.Parent
				then
					return
				end

				local Captured=
					TargetIsOnSelectedVehicle(
						Humanoid,
						Seat,
						Vehicle
					)

				if Captured then
					VoidHoldUntil=
						math.max(
							VoidHoldUntil,
							Now+0.55
						)
				end

				if Now<VoidHoldUntil then
					-- Antes estava usando FallenPartsDestroyHeight + 7,
					-- que ainda fica ACIMA do void. Agora vai realmente
					-- abaixo do limite de destruição.
					local VoidY=
						workspace.FallenPartsDestroyHeight
						-
						45

					MoveVehicle(
						CFrame.new(
							Root.Position.X,
							VoidY,
							Root.Position.Z
						),
						Vector3.new(
							0,
							-650,
							0
						),
						Vector3.new(
							1200,
							1500,
							1300
						)
					)

					return
				end

				-- Fase de impacto: gira a moto bem perto do personagem.
				local A=
					Time*42

				local Offset=
					CFrame.new(
						math.sin(A)*1.15,
						math.sin(A*1.8)*0.7,
						math.cos(A)*1.15
					)
					*
					CFrame.Angles(
						A*2.9,
						A*4.6,
						A*3.4
					)

				local V=
					Root.CFrame.LookVector
					*
					470

				if math.floor(Time*20)%2==0 then
					V=-V
				end

				MoveVehicle(
					Root.CFrame*Offset,
					V+Vector3.new(0,175,0),
					Vector3.new(
						1850,
						2400,
						2050
					)
				)

				-- Depois do impacto tenta fazer o alvo ocupar o Seat da moto.
				-- Se o servidor aceitar, a próxima fase leva a assembly inteira
				-- (moto + alvo) abaixo do FallenPartsDestroyHeight.
				if
					Seat
					and
					(Time%0.34)>0.16
				then
					local GotSeat=
						TryCaptureTargetOnVehicle(
							Root,
							Humanoid,
							Seat
						)

					if GotSeat then
						VoidHoldUntil=
							Now+0.65
					end
				end
			end)
		end
	)

	Gui.Destroying:Connect(function()
		Stop(true)
	end)
end)()
end


Section(
	Veiculos,
	"Loop do Veículo"
)

do
(function()
	local State = {
		Selected = nil,
		Options = {},
		Opened = false,
		Enabled = false,
		Connection = nil,
		Time = 0,
		Speed = 8,
		Distance = 6,
		Height = 0,
		LastSnapshot = "",
		NextDriveRequest = 0,
		NextClientRefresh = 0
	}

	local KnownVehicleNames = {
		[12] = "Ônibus",
		[13] = "Carro de Polícia",
		[14] = "Ambulância",
		[15] = "Ônibus Escolar",
		[16] = "Caminhão de Bombeiros",
		[77] = "Drone",
		[79] = "Retroescavadeira"
	}

	local MotoIds = {
		[30]=true,[31]=true,[41]=true,[7]=true,[8]=true,
		[53]=true,[83]=true,[72]=true,[59]=true
	}

	local BicycleIds = {
		[54]=true,[70]=true,[5]=true
	}

	local function GetVehicleDisplayName(Name)
		local Id =
			tonumber(
				tostring(Name):match(
					"^ltp2_car_(%d+)$"
				)
			)

		if
			Id
			and
			KnownVehicleNames[Id]
		then
			return
				KnownVehicleNames[Id]
		end

		if Id == 6 then
			return "Cadeira de Rodas"
		end

		if
			Id
			and
			MotoIds[Id]
		then
			return "Moto"
		end

		if
			Id
			and
			BicycleIds[Id]
		then
			return "Bicicleta"
		end

		return "Carro"
	end

	local function GetVehicleIcon(Name)
		local Display =
			GetVehicleDisplayName(
				Name
			)

		if Display == "Moto" then
			return "🏍️"
		elseif Display == "Bicicleta" then
			return "🚲"
		elseif Display == "Cadeira de Rodas" then
			return "♿"
		elseif Display == "Ônibus" or Display == "Ônibus Escolar" then
			return "🚌"
		elseif Display == "Ambulância" then
			return "🚑"
		elseif Display == "Caminhão de Bombeiros" then
			return "🚒"
		elseif Display == "Drone" then
			return "🛸"
		elseif Display == "Retroescavadeira" then
			return "🚜"
		end

		return "🚗"
	end

	local function GetVehicleOwner(Vehicle)
		if
			typeof(Vehicle) ~= "Instance"
			or
			not Vehicle.Parent
		then
			return nil
		end

		local OwnerValue =
			Vehicle:FindFirstChild(
				"VehicleOwner"
			)
			or
			Vehicle:FindFirstChild(
				"VehicleOwner",
				true
			)

		if
			OwnerValue
			and
			OwnerValue:IsA("ObjectValue")
		then
			local Value =
				OwnerValue.Value

			if
				Value
				and
				Value:IsA("Player")
				and
				Value.Parent == Players
			then
				return Value
			end
		end

		return nil
	end

	local function GetVehicleLabel(
		Vehicle
	)
		local Owner =
			GetVehicleOwner(
				Vehicle
			)

		if not Owner then
			return nil, nil
		end

		return
			GetVehicleDisplayName(
				Vehicle.Name
			)
			..
			" • Dono: "
			..
			Owner.Name,
			Owner
	end


	local PlayerSelector =
		CreatePlayerSelector(
			Veiculos,
			"Player do Vai e Vem",
			true
		)

	local Frame = New("Frame", {
		Size = UDim2.new(1,-8,0,56),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, Veiculos)
	Corner(Frame,9)

	New("TextLabel", {
		Size = UDim2.new(0.42,0,1,0),
		Position = UDim2.fromOffset(18,0),
		BackgroundTransparency = 1,
		Text = "CarClient do Veículo",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Frame)

	local Button = New("TextButton", {
		Size = UDim2.new(0.48,-20,0,38),
		Position = UDim2.new(0.52,5,0,9),
		BackgroundColor3 = Theme.Card2,
		BorderSizePixel = 0,
		Text = "Selecionar CarClient",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd
	}, Frame)
	Corner(Button,8)

	local List = New("ScrollingFrame", {
		Size = UDim2.new(1,-36,0,220),
		Position = UDim2.fromOffset(18,62),
		BackgroundColor3 = Color3.fromRGB(35,35,38),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		Visible = false
	}, Frame)
	Corner(List,8)
	New("UIListLayout", {Padding = UDim.new(0,4)}, List)

	local WorkspaceVehicles =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local WorkspaceClients =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local VehicleIdentity =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local ClientCache =
		setmetatable(
			{},
			{
				__mode = "k"
			}
		)

	local NextVehicleIdentity = 0
	local WorkspaceVehicleAdded = nil
	local WorkspaceVehicleRemoving = nil

	local function IsLTP2Vehicle(
		Object
	)
		return
			typeof(Object) == "Instance"
			and
			Object.Name ~= nil
			and
			Object.Name:match(
				"^ltp2_car_%d+$"
			)
			~=
			nil
			and
			(
				Object:IsA("Model")
				or
				Object:IsA("BasePart")
			)
	end

	local function ResolveCarClient(
		Vehicle,
		ForceRefresh
	)
		if
			not Vehicle
			or
			not Vehicle.Parent
		then
			return nil
		end

		local Cached=
			ClientCache[Vehicle]

		if
			not ForceRefresh
			and
			Cached
			and
			Cached.Parent
			and
			Cached:IsDescendantOf(workspace)
		then
			return Cached
		end

		local function NormalizeClient(Object)
			if
				not Object
				or
				not Object.Parent
			then
				return nil
			end

			if
				Object:IsA("Model")
				or
				Object:IsA("BasePart")
			then
				return Object
			end

			local Parent=
				Object.Parent

			if
				Parent
				and
				(
					Parent:IsA("Model")
					or
					Parent:IsA("BasePart")
				)
			then
				return Parent
			end

			return nil
		end

		local function Accept(Object)
			local Client=
				NormalizeClient(
					Object
				)

			if
				Client
				and
				Client.Parent
				and
				Client:IsDescendantOf(workspace)
			then
				ClientCache[Vehicle]=
					Client

				return Client
			end

			return nil
		end

		-- Primeiro procura o CarClient real dentro do veículo.
		local DirectCarClient=
			Vehicle:FindFirstChild(
				"CarClient",
				true
			)

		local Client=
			Accept(
				DirectCarClient
			)

		if Client then
			return Client
		end

		-- Alguns veículos deixam o CarClient no mesmo modelo-pai
		-- do marcador ltp2_car_XX.
		local Node=
			Vehicle.Parent

		for _=1,4 do
			if not Node or Node==workspace then
				break
			end

			local Named=
				Node:FindFirstChild(
					"CarClient",
					true
				)

			Client=
				Accept(
					Named
				)

			if Client then
				return Client
			end

			Node=
				Node.Parent
		end

		-- Compatibilidade com veículos que usam MoverModel como
		-- representação física do CarClient.
		local MoverModel=
			Vehicle:FindFirstChild(
				"MoverModel"
			)
			or
			Vehicle:FindFirstChild(
				"MoverModel",
				true
			)

		Client=
			Accept(
				MoverModel
			)

		if Client then
			return Client
		end

		for _,Descendant in ipairs(
			Vehicle:GetDescendants()
		) do
			if
				Descendant:IsA("Seat")
				or
				Descendant:IsA("VehicleSeat")
			then
				Client=
					Accept(
						Descendant.Parent
					)

				if Client then
					return Client
				end
			end
		end

		ClientCache[Vehicle]=
			nil

		return nil
	end

	local function GetMoverRemote()
		local Mover =
			ReplicatedStorage:FindFirstChild(
				"Mover"
			)

		local Events =
			Mover
			and
			Mover:FindFirstChild(
				"Events"
			)

		return
			Events
			and
			Events:FindFirstChild(
				"MoverRE"
			)
	end

	local function IsMapCarClient(Object)
		if
			not Object
			or
			not Object.Parent
			or
			not (
				Object:IsA("Model")
				or
				Object:IsA("BasePart")
			)
		then
			return false
		end

		local Name=
			string.lower(
				tostring(
					Object.Name
					or
					""
				)
			)

		-- Além de CarClient/MoverModel, alguns veículos usam nomes físicos
		-- como Stone / Chairs para a peça/modelo controlável.
		return
			Name=="carclient"
			or
			Name:find("carclient",1,true)~=nil
			or
			Name=="movermodel"
			or
			Name:find("stone",1,true)~=nil
			or
			Name:find("chair",1,true)~=nil
	end

	local function FindVehicleForClient(Client)
		if not Client or not Client.Parent then return nil end

		local Node=Client
		local Fallback=nil
		for _=1,8 do
			if not Node or Node==workspace then break end
			if IsLTP2Vehicle(Node) then return Node end
			if
				not Fallback
				and
				Node:IsA("Model")
				and
				(
					Node:FindFirstChildWhichIsA("Seat",true)
					or
					Node:FindFirstChildWhichIsA("VehicleSeat",true)
					or
					Node:FindFirstChild("VehicleOwner",true)
				)
			then
				Fallback=Node
			end
			Node=Node.Parent
		end
		return Fallback
	end

	local function GetOptionIcon(Option)
		if Option and Option.vehicle and Option.vehicle.Name then
			return GetVehicleIcon(Option.vehicle.Name)
		end
		return "🚗"
	end

	local function GetOptionSubtitle(Option)
		local VehicleText=Option.vehicleLabel or "Veículo"

		if Option.owner then
			return VehicleText.." • Dono: "..Option.owner.Name
		end

		return VehicleText.." • CarClient"
	end

	local function Scan()
		-- Sob demanda: só varre o workspace quando o seletor é aberto.
		table.clear(WorkspaceVehicles)
		table.clear(WorkspaceClients)

		for _,Object in ipairs(
			workspace:GetDescendants()
		) do
			if IsLTP2Vehicle(Object) then
				WorkspaceVehicles[Object] =
					true
			end

			if IsMapCarClient(Object) then
				WorkspaceClients[Object] =
					true
			end
		end

		local Options={}
		local SnapshotKeys={}
		local SeenClients={}

		local function AddClient(Client,Vehicle)
			if
				not Client
				or
				not Client.Parent
				or
				not Client:IsDescendantOf(workspace)
				or
				SeenClients[Client]
			then
				return
			end

			Vehicle=Vehicle or FindVehicleForClient(Client)

			if not Vehicle then
				return
			end

			local Owner=GetVehicleOwner(Vehicle)
			local VehicleId=
				tonumber(
					tostring(Vehicle.Name):match(
						"^ltp2_car_(%d+)$"
					)
				)

			-- O Vai e Vem depende de CarClient físico. O Drone (77) não usa
			-- CarClient nessa função, então nunca deve aparecer nesta lista.
			if VehicleId==77 then
				return
			end

			if
				not Owner
				or
				Owner ~= Player
			then
				return
			end

			SeenClients[Client]=true

			local VehicleLabel=
				GetVehicleDisplayName(Vehicle.Name)

			if not VehicleIdentity[Client] then
				NextVehicleIdentity+=1
				VehicleIdentity[Client]=NextVehicleIdentity
			end

			local ClientName=tostring(Client.Name or "CarClient")
			local OwnerName=Owner and Owner.Name or "Drone"
			local Label=
				ClientName
				..
				" • "
				..
				VehicleLabel
				..
				(
					Owner
					and
					(" • "..OwnerName)
					or
					" • CarClient"
				)

			table.insert(Options,{
				vehicle=Vehicle,
				client=Client,
				owner=Owner,
				vehicleLabel=VehicleLabel,
				clientLabel=ClientName,
				label=Label,
				identity=VehicleIdentity[Client]
			})

			table.insert(SnapshotKeys,
				tostring(VehicleIdentity[Client]).."#"..tostring(Client).."#"..OwnerName)
		end

		-- 1) Clientes físicos indexados incrementalmente.
		-- Evita workspace:GetDescendants() em toda atualização do menu.
		for Client in pairs(WorkspaceClients) do
			if
				Client
				and
				Client.Parent
				and
				Client:IsDescendantOf(workspace)
				and
				IsMapCarClient(Client)
			then
				AddClient(
					Client,
					nil
				)
			else
				WorkspaceClients[Client]=
					nil
			end
		end

		-- 2) Compatibilidade: veículos LTP2 cujo CarClient tenha outro nome.
		for Vehicle in pairs(WorkspaceVehicles) do
			if
				IsLTP2Vehicle(Vehicle)
				and
				Vehicle.Parent
				and
				Vehicle:IsDescendantOf(workspace)
			then
				AddClient(ResolveCarClient(Vehicle),Vehicle)
			else
				WorkspaceVehicles[Vehicle]=nil
				ClientCache[Vehicle]=nil
			end
		end

		table.sort(Options,function(A,B)
			local AL=tostring(A.clientLabel or "")
			local BL=tostring(B.clientLabel or "")
			if AL==BL then return A.identity<B.identity end
			return AL<BL
		end)
		table.sort(SnapshotKeys)

		local Snapshot=table.concat(SnapshotKeys,"|")
		local Changed=Snapshot~=State.LastSnapshot
		State.LastSnapshot=Snapshot
		State.Options=Options

		if State.Selected then
			local Found=false
			for _,Option in ipairs(Options) do
				if Option.client==State.Selected.client then
					State.Selected=Option
					Found=true
					break
				end
			end
			if not Found then
				State.Selected=nil
				Button.Text="Selecionar CarClient"
			end
		end

		return Changed
	end

	local function Render()
		for _, Child in ipairs(
			List:GetChildren()
		) do
			if Child:IsA("TextButton") then
				Child:Destroy()
			end
		end

		List.CanvasSize =
			UDim2.new(
				0,
				0,
				0,
				math.max(
					1,
					#State.Options
				)
				*
				54
			)

		if #State.Options == 0 then
			local Empty =
				New(
					"TextButton",
					{
						Size =
							UDim2.new(
								1,
								-5,
								0,
								35
							),

						BackgroundColor3 =
							Theme.Card2,

						BorderSizePixel =
							0,

						Text =
							"Nenhum CarClient do seu veículo encontrado",

						TextColor3 =
							Theme.SubText,

						Font =
							Enum.Font.GothamMedium,

						TextSize =
							12,

						AutoButtonColor =
							false
					},
					List
				)

			Corner(
				Empty,
				7
			)

			return
		end

		for _, Option in ipairs(
			State.Options
		) do
			local OptionButton = New("TextButton", {
				Size = UDim2.new(1,-5,0,50),
				BackgroundColor3 = Theme.Card2,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = true
			}, List)
			Corner(OptionButton,8)
			Stroke(OptionButton)

			New("TextLabel", {
				Size = UDim2.fromOffset(34,50),
				Position = UDim2.fromOffset(5,0),
				BackgroundTransparency = 1,
				Text = GetOptionIcon(Option),
				TextColor3 = Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 18
			}, OptionButton)

			New("TextLabel", {
				Size = UDim2.new(1,-48,0,21),
				Position = UDim2.fromOffset(40,5),
				BackgroundTransparency = 1,
				Text = Option.clientLabel or Option.client.Name,
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, OptionButton)

			New("TextLabel", {
				Size = UDim2.new(1,-48,0,18),
				Position = UDim2.fromOffset(40,26),
				BackgroundTransparency = 1,
				Text = GetOptionSubtitle(Option),
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, OptionButton)

			OptionButton.MouseButton1Click:Connect(function()
				State.Selected =
					Option

				Button.Text =
					Option.label

				State.Opened =
					false

				List.Visible =
					false

				Frame.Size =
					UDim2.new(
						1,
						-8,
						0,
						56
					)
			end)
		end
	end

	Button.MouseButton1Click:Connect(function()
		State.Opened =
			not State.Opened

		if State.Opened then
			Scan()
			Render()
		end

		List.Visible =
			State.Opened

		Frame.Size =
			UDim2.new(
				1,
				-8,
				0,
				State.Opened
				and
				292
				or
				56
			)
	end)

	Slider(
		Veiculos,
		"Velocidade Vai e Vem",
		1,
		30,
		8,
		function(Value)
			State.Speed =
				Value
		end
	)

	Slider(
		Veiculos,
		"Distância Vai e Vem",
		3,
		25,
		6,
		function(Value)
			State.Distance =
				Value
		end
	)

	Slider(
		Veiculos,
		"Altura Vai e Vem",
		-5,
		15,
		0,
		function(Value)
			State.Height =
				Value
		end
	)

	local function Stop()
		State.Enabled =
			false

		if State.Connection then
			State.Connection:Disconnect()
			State.Connection =
				nil
		end
	end

	CartolaPanicRegistry:Register(
		"VehicleLoop",
		Stop
	)

	local function ClaimPhysics()
		pcall(function()
			if
				type(setsimulationradius)
				==
				"function"
			then
				setsimulationradius(
					1e9,
					1e9
				)

			elseif
				type(sethiddenproperty)
				==
				"function"
			then
				sethiddenproperty(
					Player,
					"SimulationRadius",
					1e9
				)
			end
		end)
	end

	local function RequestVehicleControl(
		Option
	)
		if not Option then return end

		ClaimPhysics()

		if
			not Option.vehicle
			or
			not Option.vehicle.Parent
		then
			return
		end

		local Remote =
			GetMoverRemote()

		if Remote then
			pcall(function()
				Remote:FireServer(
					"Drive",
					Option.vehicle,
					nil
				)
			end)
		end
	end

	local function ZeroClientVelocity(
		Client
	)
		if
			not Client
			or
			not Client.Parent
		then
			return
		end

		if Client:IsA("BasePart") then
			Client.AssemblyLinearVelocity =
				Vector3.zero

			Client.AssemblyAngularVelocity =
				Vector3.zero

			return
		end

		local Root =
			Client.PrimaryPart
			or
			Client:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		if Root then
			Root.AssemblyLinearVelocity =
				Vector3.zero

			Root.AssemblyAngularVelocity =
				Vector3.zero
		end
	end

	local function MovePhysicalVehicleAssembly(
		Option,
		TargetCFrame
	)
		if
			not Option
			or
			not Option.vehicle
			or
			not Option.vehicle.Parent
		then
			return false
		end

		local Vehicle =
			Option.vehicle

		local Seat =
			Vehicle:FindFirstChildWhichIsA(
				"VehicleSeat",
				true
			)
			or
			Vehicle:FindFirstChildWhichIsA(
				"Seat",
				true
			)

		local Root =
			nil

		if
			Seat
			and
			Seat:IsA("BasePart")
		then
			Root =
				Seat.AssemblyRootPart
				or
				Seat

		elseif Vehicle:IsA("BasePart") then
			Root =
				Vehicle.AssemblyRootPart
				or
				Vehicle

		elseif Vehicle:IsA("Model") then
			local VehiclePart =
				Vehicle.PrimaryPart
				or
				Vehicle:FindFirstChildWhichIsA(
					"BasePart",
					true
				)

			if VehiclePart then
				Root =
					VehiclePart.AssemblyRootPart
					or
					VehiclePart
			end
		end

		if
			not Root
			or
			not Root.Parent
			or
			not Root:IsA("BasePart")
		then
			return false
		end

		return
			pcall(function()
				if
					Seat
					and
					Seat.Parent
				then
					local Delta =
						TargetCFrame
						*
						Seat.CFrame:Inverse()

					Root.CFrame =
						Delta
						*
						Root.CFrame

				else
					Root.CFrame =
						TargetCFrame
				end

				Root.AssemblyLinearVelocity =
					Vector3.zero

				Root.AssemblyAngularVelocity =
					Vector3.zero
			end)
	end

	local function MoveCarClient(
		Option,
		TargetCFrame
	)
		if not Option then return false end

		local Client=Option.client

		if
			not Client
			or
			not Client.Parent
			or
			not Client:IsDescendantOf(workspace)
		then
			if Option.vehicle and Option.vehicle.Parent then
				Client=ResolveCarClient(Option.vehicle,true)
			else
				return false
			end
		end

		if
			not Client
			or
			not Client.Parent
		then
			return false
		end

		Option.client =
			Client

		if Client:IsA("Model") then
			local Success =
				false

			if Client.PrimaryPart then
				Success =
					pcall(function()
						Client:SetPrimaryPartCFrame(
							TargetCFrame
						)
					end)
			end

			if not Success then
				Success =
					pcall(function()
						Client:PivotTo(
							TargetCFrame
						)
					end)
			end

			ZeroClientVelocity(
				Client
			)

			local PhysicalSuccess =
				MovePhysicalVehicleAssembly(
					Option,
					TargetCFrame
				)

			return
				Success
				or
				PhysicalSuccess
		end

		if Client:IsA("BasePart") then
			local Success =
				pcall(function()
					local Root =
						Client.AssemblyRootPart
						or
						Client

					Root.CFrame =
						TargetCFrame

					Root.AssemblyLinearVelocity =
						Vector3.zero

					Root.AssemblyAngularVelocity =
						Vector3.zero
				end)

			local PhysicalSuccess =
				MovePhysicalVehicleAssembly(
					Option,
					TargetCFrame
				)

			return
				Success
				or
				PhysicalSuccess
		end

		return false
	end

	Toggle(
		Veiculos,
		"Veículo Vai e Vem no Player",
		false,
		function(Enabled)
			Stop()

			if not Enabled then
				return
			end

			if not State.Selected then


				return
			end

			if not PlayerSelector:GetFirst() then


				return
			end

			State.Enabled =
				true

			State.Time =
				0

			State.NextDriveRequest =
				0

			State.NextClientRefresh =
				0

			RequestVehicleControl(
				State.Selected
			)

			State.Connection =
				RunService.Heartbeat:Connect(function(
					DeltaTime
				)
					if not State.Enabled then
						return
					end

					local Target =
						PlayerSelector:GetFirst()

					local TargetRoot =
						Target
						and
						Target.Character
						and
						Target.Character:FindFirstChild(
							"HumanoidRootPart"
						)

					if
						not TargetRoot
						or
						not State.Selected
						or
						not State.Selected.client
						or
						not State.Selected.client.Parent
					then
						return
					end

					local Now =
						os.clock()

					-- O Remote "Drive" é o mesmo usado pela função de roubar.
					-- Requisitar o controle periodicamente evita o movimento
					-- ficar apenas visual quando o veículo tinha outro owner.
					if
						Now
						>=
						State.NextDriveRequest
					then
						State.NextDriveRequest =
							Now
							+
							0.10

						RequestVehicleControl(
							State.Selected
						)
					end

					State.Time +=
						DeltaTime
						*
						State.Speed

					local TargetCFrame =
						TargetRoot.CFrame
						*
						CFrame.new(
							0,
							State.Height,
							math.sin(
								State.Time
							)
							*
							State.Distance
						)

					-- Alguns veículos recriam/trocam o MoverModel depois
					-- da primeira tomada de controle. Força uma resolução
					-- periódica do CarClient em vez de ficar preso ao antigo.
					if
						Now
						>=
						State.NextClientRefresh
					then
						State.NextClientRefresh =
							Now
							+
							0.20

						if State.Selected.vehicle and State.Selected.vehicle.Parent then
							local RefreshedClient=ResolveCarClient(State.Selected.vehicle,true)
							if RefreshedClient then State.Selected.client=RefreshedClient end
						end
					end

					local Moved =
						false

					pcall(function()
						Moved =
							MoveCarClient(
								State.Selected,
								TargetCFrame
							)
					end)

					if not Moved then
						if State.Selected.vehicle and State.Selected.vehicle.Parent then
							ClientCache[State.Selected.vehicle]=nil
							State.Selected.client=ResolveCarClient(State.Selected.vehicle,true) or State.Selected.client
						end

						pcall(function()
							MoveCarClient(State.Selected,TargetCFrame)
						end)
					end
				end)
		end
	)

	Gui.Destroying:Connect(function()
		Stop()

	end)
end)()
end

Section(
	Veiculos,
	"Roubar Veículo"
)

--============================================================
-- ROUBAR / ASSUMIR VEÍCULO
--
-- Moto/bicicleta/cadeira de rodas usam MoverRE/"Drive".
-- Carros e veículos maiores tentam primeiro o DriveSeat/VehicleSeat físico.
--============================================================

do
	local SelectedStolenVehicle = nil
	local StealOptions = {}
	local StealOpened = false
	local StealLoopEnabled = false
	local StealLoopToken = 0
	local StealToggle = nil

	local KnownVehicleNames = {
		[12] = "Ônibus",
		[13] = "Carro de Polícia",
		[14] = "Ambulância",
		[15] = "Ônibus Escolar",
		[16] = "Caminhão de Bombeiros",
		[77] = "Drone",
		[79] = "Retroescavadeira"
	}

	local MotoIds = {
		[30]=true,[31]=true,[41]=true,[7]=true,[8]=true,
		[53]=true,[83]=true,[72]=true,[59]=true
	}

	local BicycleIds = {
		[54]=true,[70]=true,[5]=true
	}

	local function GetVehicleDisplayName(Name)
		local Id =
			tonumber(
				tostring(Name):match(
					"^ltp2_car_(%d+)$"
				)
			)

		if
			Id
			and
			KnownVehicleNames[Id]
		then
			return
				KnownVehicleNames[Id]
		end

		if Id == 6 then
			return "Cadeira de Rodas"
		end

		if
			Id
			and
			MotoIds[Id]
		then
			return "Moto"
		end

		if
			Id
			and
			BicycleIds[Id]
		then
			return "Bicicleta"
		end

		return "Carro"
	end

	local function GetVehicleIcon(Name)
		local Display =
			GetVehicleDisplayName(
				Name
			)

		if Display == "Moto" then
			return "🏍️"
		elseif Display == "Bicicleta" then
			return "🚲"
		elseif Display == "Cadeira de Rodas" then
			return "♿"
		elseif Display == "Ônibus" or Display == "Ônibus Escolar" then
			return "🚌"
		elseif Display == "Ambulância" then
			return "🚑"
		elseif Display == "Caminhão de Bombeiros" then
			return "🚒"
		elseif Display == "Drone" then
			return "🛸"
		elseif Display == "Retroescavadeira" then
			return "🚜"
		end

		return "🚗"
	end

	local function ResolveStealOwnerValue(ValueObject)
		if not ValueObject then
			return nil,nil
		end

		if ValueObject:IsA("ObjectValue") then
			local Value = ValueObject.Value
			if Value and Value:IsA("Player") and Value.Parent == Players then
				return Value,Value.Name
			end
			return nil,nil
		end

		if ValueObject:IsA("StringValue")
			or ValueObject:IsA("IntValue")
			or ValueObject:IsA("NumberValue")
		then
			local Raw = tostring(ValueObject.Value or "")
			if Raw == "" then return nil,nil end

			local Direct = Players:FindFirstChild(Raw)
			if Direct and Direct:IsA("Player") then
				return Direct,Direct.Name
			end

			local UserId = tonumber(Raw)
			if UserId then
				local ById = Players:GetPlayerByUserId(UserId)
				if ById then
					return ById,ById.Name
				end
			end

			return nil,Raw
		end

		return nil,nil
	end

	local function GetVehicleOwner(Vehicle)
		if typeof(Vehicle) ~= "Instance" or not Vehicle.Parent then
			return nil,nil
		end

		local OwnerValue =
			Vehicle:FindFirstChild("VehicleOwner")
			or Vehicle:FindFirstChild("VehicleOwner",true)

		local Owner,OwnerName = ResolveStealOwnerValue(OwnerValue)
		if Owner or OwnerName then
			return Owner,OwnerName
		end

		-- Drone/aeronaves de workspace.Planes usam PlaneOwner.
		local Node = Vehicle
		while Node and Node ~= workspace do
			local PlaneOwner = Node:FindFirstChild("PlaneOwner")
			if PlaneOwner then
				Owner,OwnerName = ResolveStealOwnerValue(PlaneOwner)
				if Owner or OwnerName then
					return Owner,OwnerName
				end
			end

			local Attribute = Node:GetAttribute("PlaneOwner")
			if Attribute ~= nil then
				local Raw = tostring(Attribute)
				local Direct = Players:FindFirstChild(Raw)
				if Direct and Direct:IsA("Player") then
					return Direct,Direct.Name
				end
				if Raw ~= "" then
					return nil,Raw
				end
			end

			Node = Node.Parent
		end

		return nil,nil
	end

	local function GetVehicleLabel(Vehicle)
		local Owner,OwnerName = GetVehicleOwner(Vehicle)
		if not OwnerName then
			return nil,nil,nil
		end

		return
			GetVehicleDisplayName(Vehicle.Name)
			..
			" • Dono: "
			..
			OwnerName,
			Owner,
			OwnerName
	end


	local Frame = New("Frame", {
		Size = UDim2.new(1,-8,0,56),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, Veiculos)
	Corner(Frame,9)

	New("TextLabel", {
		Size = UDim2.new(0.42,0,1,0),
		Position = UDim2.fromOffset(18,0),
		BackgroundTransparency = 1,
		Text = "Veículo para roubar",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Frame)

	local Button = New("TextButton", {
		Size = UDim2.new(0.48,-20,0,38),
		Position = UDim2.new(0.52,5,0,9),
		BackgroundColor3 = Theme.Card2,
		BorderSizePixel = 0,
		Text = "Selecionar veículo",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd
	}, Frame)
	Corner(Button,8)

	local List = New("ScrollingFrame", {
		Size = UDim2.new(1,-36,0,220),
		Position = UDim2.fromOffset(18,62),
		BackgroundColor3 = Color3.fromRGB(35,35,38),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		Visible = false
	}, Frame)
	Corner(List,8)
	New("UIListLayout", {Padding = UDim.new(0,4)}, List)

	local function GetMoverRemote()
		local Mover = ReplicatedStorage:FindFirstChild("Mover")
		local Events = Mover and Mover:FindFirstChild("Events")
		return Events and Events:FindFirstChild("MoverRE")
	end

	local function GetVehicleId(
		Vehicle
	)
		if
			not Vehicle
			or
			not Vehicle.Name
		then
			return nil
		end

		return
			tonumber(
				tostring(
					Vehicle.Name
				):match(
					"^ltp2_car_(%d+)$"
				)
			)
	end

	local function UsesMoverDrive(
		Vehicle
	)
		local Id=
			GetVehicleId(
				Vehicle
			)

		return
			Id==6
			or
			(Id and MotoIds[Id]==true)
			or
			(Id and BicycleIds[Id]==true)
	end

	local function FindDriveSeat(
		Vehicle
	)
		if
			not Vehicle
			or
			not Vehicle.Parent
		then
			return nil
		end

		local function IsDriverNamedSeat(Object)
			if
				not Object
				or
				not (
					Object:IsA("VehicleSeat")
					or
					Object:IsA("Seat")
				)
			then
				return false
			end

			local Name=
				string.lower(
					tostring(Object.Name or "")
				)

			if
				Name=="driver"
				or
				Name=="driverseat"
				or
				Name=="driveseat"
			then
				return true
			end

			local Parent=Object.Parent

			return
				Parent
				and
				string.lower(
					tostring(Parent.Name or "")
				)
				==
				"driveseat"
		end

		local function SearchNode(Node)
			if not Node then
				return nil
			end

			if
				(
					Node:IsA("VehicleSeat")
					or
					Node:IsA("Seat")
				)
				and
				IsDriverNamedSeat(Node)
			then
				return Node
			end

			-- Estrutura observada no jogo:
			-- ltp2_car_XX > DriveSeat > Driver (Seat/VehicleSeat).
			-- Priorizamos esse banco para não selecionar BackPassengerR.
			for _,Object in ipairs(Node:GetDescendants()) do
				if
					string.lower(
						tostring(Object.Name or "")
					)
					==
					"driveseat"
				then
					if
						Object:IsA("VehicleSeat")
						or
						Object:IsA("Seat")
					then
						return Object
					end

					local Driver=
						Object:FindFirstChild(
							"Driver",
							true
						)

					if
						Driver
						and
						(
							Driver:IsA("VehicleSeat")
							or
							Driver:IsA("Seat")
						)
					then
						return Driver
					end

					local AnyInside=
						Object:FindFirstChildWhichIsA(
							"VehicleSeat",
							true
						)

					if AnyInside then
						return AnyInside
					end
				end
			end

			for _,Object in ipairs(Node:GetDescendants()) do
				if IsDriverNamedSeat(Object) then
					return Object
				end
			end

			if Node:IsA("VehicleSeat") then
				return Node
			end

			return
				Node:FindFirstChildWhichIsA(
					"VehicleSeat",
					true
				)
		end

		local Direct=
			SearchNode(
				Vehicle
			)

		if Direct then
			return Direct
		end

		-- Alguns ltp2_car_XX são apenas a root Part e o DriveSeat fica na
		-- mesma assembly ou no Model pai.
		if Vehicle:IsA("BasePart") then
			local Ok,Connected=
				pcall(function()
					return
						Vehicle:GetConnectedParts(
							true
						)
				end)

			if
				Ok
				and
				type(Connected)=="table"
			then
				for _,Part in ipairs(Connected) do
					if IsDriverNamedSeat(Part) then
						return Part
					end
				end

				for _,Part in ipairs(Connected) do
					local Parent=Part.Parent

					if
						Parent
						and
						string.lower(
							tostring(Parent.Name or "")
						)
						==
						"driveseat"
					then
						local Seat=
							SearchNode(
								Parent
							)

						if Seat then
							return Seat
						end
					end
				end
			end

			local Parent=Vehicle.Parent

			if Parent and Parent:IsA("Model") then
				local Seat=
					SearchNode(
						Parent
					)

				if Seat then
					return Seat
				end
			end
		end

		return nil
	end

	local function MarkDrivenVehicle(
		Vehicle
	)
		local Ref=
			Gui:FindFirstChild(
				"CartolaDrivenVehicle"
			)

		if
			Ref
			and
			Ref:IsA("ObjectValue")
		then
			Ref.Value=
				Vehicle
		end
	end

	local function TryDriveSeatSteal(
		Vehicle
	)
		local Seat=
			FindDriveSeat(
				Vehicle
			)

		if not Seat then
			return false,false
		end

		local Character=
			GetCharacter()

		local Humanoid=
			GetHumanoid()

		local Root=
			GetRoot()

		if
			not Character
			or
			not Humanoid
			or
			not Root
			or
			Humanoid.Health<=0
		then
			return false,true
		end

		Gui:SetAttribute(
			"VehicleStealSeatActive",
			true
		)

		-- O botão "Dirigir" é quem deve produzir o SeatWeld nativo.
		-- Não criamos Weld manualmente.
		local function IsDriveText(
			Value
		)
			local Lower=
				string.lower(
					tostring(
						Value
						or
						""
					)
				)

			return
				string.find(
					Lower,
					"dirig",
					1,
					true
				)
				~=
				nil
				or
				string.find(
					Lower,
					"drive",
					1,
					true
				)
				~=
				nil
				or
				string.find(
					Lower,
					"driver",
					1,
					true
				)
				~=
				nil
				or
				string.find(
					Lower,
					"motorista",
					1,
					true
				)
				~=
				nil
		end

		local function PromptWorldPart(
			Prompt
		)
			if
				not Prompt
				or
				not Prompt.Parent
			then
				return nil
			end

			if Prompt.Parent:IsA("BasePart") then
				return Prompt.Parent
			end

			if
				Prompt.Parent:IsA("Attachment")
				and
				Prompt.Parent.Parent
				and
				Prompt.Parent.Parent:IsA("BasePart")
			then
				return Prompt.Parent.Parent
			end

			return nil
		end

		local function FindDrivePrompt()
			local Best=nil
			local BestDistance=math.huge
			local Seen={}

			local function Consider(
				Object,
				RequireDriveText
			)
				if
					not Object
					or
					Seen[Object]
					or
					not Object:IsA(
						"ProximityPrompt"
					)
				then
					return
				end

				Seen[Object]=true

				if
					RequireDriveText
					and
					not (
						IsDriveText(
							Object.Name
						)
						or
						IsDriveText(
							Object.ActionText
						)
						or
						IsDriveText(
							Object.ObjectText
						)
					)
				then
					return
				end

				local Part=
					PromptWorldPart(
						Object
					)

				local Distance=
					Part
					and
					(
						Part.Position
						-
						Seat.Position
					).Magnitude
					or
					0

				if Distance<BestDistance then
					BestDistance=Distance
					Best=Object
				end
			end

			local function ScanNode(
				Node,
				RequireDriveText
			)
				if not Node then
					return
				end

				Consider(
					Node,
					RequireDriveText
				)

				for _,Object in ipairs(
					Node:GetDescendants()
				) do
					Consider(
						Object,
						RequireDriveText
					)
				end
			end

			-- Primeiro: prompt "Dirigir" dentro do próprio objeto selecionado.
			ScanNode(
				Vehicle,
				true
			)

			-- VehicleSeat e estrutura em volta.
			ScanNode(
				Seat,
				true
			)

			local Parent=
				Seat.Parent

			if Parent then
				ScanNode(
					Parent,
					true
				)
			end

			-- ltp2_car_XX pode ser uma Part. Varre somente a mesma assembly.
			if Vehicle:IsA("BasePart") then
				local Ok,Connected=
					pcall(function()
						return
							Vehicle:GetConnectedParts(
								true
							)
					end)

				if
					Ok
					and
					type(Connected)=="table"
				then
					for _,Part in ipairs(
						Connected
					) do
						ScanNode(
							Part,
							true
						)

						if
							Part.Parent
							and
							Part.Parent~=workspace
						then
							ScanNode(
								Part.Parent,
								true
							)
						end
					end
				end
			end

			if Best then
				return Best
			end

			-- Não procura prompts no Workspace inteiro: o prompt correto deve
			-- pertencer ao próprio veículo/assembly do banco do motorista.
			return Best
		end

		local function TriggerPrompt(
			Prompt
		)
			if
				not Prompt
				or
				not Prompt.Parent
			then
				return false
			end

			if type(fireproximityprompt)=="function" then
				local Ok=
					pcall(function()
						fireproximityprompt(
							Prompt,
							1,
							true
						)
					end)

				if Ok then
					return true
				end

				Ok=
					pcall(function()
						fireproximityprompt(
							Prompt
						)
					end)

				if Ok then
					return true
				end
			end

			-- Fallback para ambientes sem fireproximityprompt.
			local Ok=
				pcall(function()
					Prompt:InputHoldBegin()
				end)

			if Ok then
				local Hold=
					math.clamp(
						tonumber(
							Prompt.HoldDuration
						)
						or
						0,
						0,
						0.35
					)

				if Hold>0 then
					task.wait(
						Hold+0.03
					)
				end

				pcall(function()
					Prompt:InputHoldEnd()
				end)

				return true
			end

			return false
		end

		local function TriggerDriveGuiButton()
			local PlayerGui=
				Player:FindFirstChildOfClass(
					"PlayerGui"
				)

			if not PlayerGui then
				return false
			end

			for _,Object in ipairs(
				PlayerGui:GetDescendants()
			) do
				if
					Object:IsA("GuiButton")
					and
					Object.Visible
					and
					(
						IsDriveText(
							Object.Name
						)
						or
						(
							Object:IsA(
								"TextButton"
							)
							and
							IsDriveText(
								Object.Text
							)
						)
					)
				then
					if type(firesignal)=="function" then
						local Ok=
							pcall(function()
								firesignal(
									Object.Activated
								)
							end)

						if not Ok then
							Ok=
								pcall(function()
									firesignal(
										Object.MouseButton1Click
									)
								end)
						end

						if Ok then
							return true
						end
					end
				end
			end

			return false
		end

		local OldDisabled=
			Seat.Disabled

		local OldCanTouch=
			Seat.CanTouch

		pcall(function()
			Seat.Disabled=false
			Seat.CanTouch=true
		end)

		-- Sai de outro assento antes da aproximação.
		if
			Humanoid.SeatPart
			and
			Humanoid.SeatPart~=Seat
		then
			pcall(function()
				Humanoid.Sit=false

				Humanoid:ChangeState(
					Enum.HumanoidStateType.GettingUp
				)
			end)

			RunService.Heartbeat:Wait()
		end

		local Prompt=
			FindDrivePrompt()

		local Success=false

		for Attempt=1,12 do
			if
				not Seat.Parent
				or
				Humanoid.Health<=0
			then
				break
			end

			-- Carros/ônibus/etc.: teleporta SOMENTE para o banco do motorista.
			-- Não usa porta, prompt ou outra parte do veículo como destino.
			pcall(function()
				Root.AssemblyLinearVelocity=
					Vector3.zero

				Root.AssemblyAngularVelocity=
					Vector3.zero

				local Height=
					(
						Seat.Size.Y*0.5
					)
					+
					(
						Root.Size.Y*0.5
					)
					+
					0.08

				Root.CFrame=
					Seat.CFrame
					*
					CFrame.new(
						0,
						Height,
						0
					)
			end)

			RunService.Heartbeat:Wait()

			-- Primeiro tenta o ProximityPrompt real.
			if Prompt then
				TriggerPrompt(
					Prompt
				)
			end

			-- GUI própria só é varrida quando não existe prompt, ou como
			-- reforço ocasional. Isso reduz bastante o custo do loop.
			if
				not Prompt
				or
				Attempt%3==0
			then
				TriggerDriveGuiButton()
			end

			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()

			local NativeWeld=
				Seat:FindFirstChild(
					"SeatWeld"
				)

			Success=
				NativeWeld
				and
				NativeWeld:IsA("Weld")
				and
				NativeWeld.Part0==Seat
				and
				NativeWeld.Part1==Root
				and
				(
					Seat.Occupant==Humanoid
					or
					Humanoid.SeatPart==Seat
				)

			if Success then
				break
			end

			-- Se o prompt apareceu depois de aproximar, busca novamente.
			if not Prompt then
				Prompt=
					FindDrivePrompt()
			end

			if Attempt%3==0 then
				task.wait(0.05)
			end
		end

		if Success then
			MarkDrivenVehicle(
				Vehicle
			)
		else
			Gui:SetAttribute(
				"VehicleStealSeatActive",
				false
			)
		end

		pcall(function()
			Seat.Disabled=
				OldDisabled

			Seat.CanTouch=
				OldCanTouch
		end)

		return Success,true,Seat
	end

	local VehicleIdentity=setmetatable({}, {__mode="k"})
	local WorkspaceVehicles=setmetatable({}, {__mode="k"})
	local NextVehicleIdentity=0
	local LastVehicleSnapshot=""
	local WorkspaceVehicleAdded=nil
	local WorkspaceVehicleRemoving=nil

	local function IsLTP2Vehicle(Object)
		return
			typeof(Object) == "Instance"
			and
			Object.Name ~= nil
			and
			Object.Name:match(
				"^ltp2_car_%d+$"
			)
			~=
			nil
			and
			(
				Object:IsA("Model")
				or
				Object:IsA("BasePart")
			)
	end

	local function ScanStealableVehicles()
		-- Sob demanda: reconstrói a lista apenas quando o seletor é aberto.
		table.clear(WorkspaceVehicles)

		for _,Object in ipairs(
			workspace:GetDescendants()
		) do
			if IsLTP2Vehicle(Object) then
				WorkspaceVehicles[Object] =
					true
			end
		end

		local NewOptions={}
		local SnapshotKeys={}
		local Seen={}

		local function AddVehicle(Object)
			if not IsLTP2Vehicle(Object) or Seen[Object] then return end
			Seen[Object]=true

			if not VehicleIdentity[Object] then
				NextVehicleIdentity += 1
				VehicleIdentity[Object] = NextVehicleIdentity
			end

			local Display,
				Owner,
				OwnerName =
					GetVehicleLabel(
						Object
					)

			-- Para o Drone, PlaneOwner fornece o dono. A interface mostra
			-- somente o nome amigável do veículo e o dono, sem CarClient/DriveSeat.
			if not Display or not OwnerName then
				return
			end

			table.insert(NewOptions, {
				instance = Object,
				name = Object.Name,
				label = Display,
				owner = Owner,
				ownerName = OwnerName
			})

			table.insert(
				SnapshotKeys,
				Object.Name
				..
				"#"
				..
				tostring(
					VehicleIdentity[Object]
				)
				..
				"#"
				..
				tostring(
					Owner
					and
					Owner.UserId
					or
					OwnerName
				)
			)
		end

		for Object in pairs(WorkspaceVehicles) do
			if Object and Object.Parent then
				AddVehicle(Object)
			else
				WorkspaceVehicles[Object]=nil
			end
		end


		table.sort(NewOptions, function(A, B)
			local AId = tonumber(A.name:match("(%d+)$")) or math.huge
			local BId = tonumber(B.name:match("(%d+)$")) or math.huge
			if AId == BId then
				return VehicleIdentity[A.instance] < VehicleIdentity[B.instance]
			end
			return AId < BId
		end)

		table.sort(SnapshotKeys)
		local Snapshot=table.concat(SnapshotKeys,"|")
		local Changed=Snapshot~=LastVehicleSnapshot
		LastVehicleSnapshot=Snapshot
		StealOptions=NewOptions

		if SelectedStolenVehicle then
			local Found=false
			for _,Option in ipairs(StealOptions) do
				if Option.instance==SelectedStolenVehicle.instance then
					SelectedStolenVehicle=Option
					Found=true
					break
				end
			end
			if not Found then
				SelectedStolenVehicle=nil
				Button.Text="Selecionar veículo"
			end
		end

		return Changed
	end

	local function ClearOptionButtons()
		for _, Child in ipairs(List:GetChildren()) do
			if Child:IsA("TextButton") then
				Child:Destroy()
			end
		end
	end

	local function RenderStealList()
		ClearOptionButtons()
		List.CanvasSize = UDim2.new(0,0,0,math.max(1,#StealOptions) * 54)

		if #StealOptions == 0 then
			local Empty = New("TextButton", {
				Size = UDim2.new(1,-5,0,35),
				BackgroundColor3 = Theme.Card2,
				BorderSizePixel = 0,
				Text = "Nenhum veículo disponível",
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamMedium,
				TextSize = 12,
				AutoButtonColor = false
			}, List)
			Corner(Empty,7)
			return
		end

		for _, Option in ipairs(StealOptions) do
			local OptionButton = New("TextButton", {
				Size = UDim2.new(1,-5,0,50),
				BackgroundColor3 = Theme.Card2,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = true
			}, List)
			Corner(OptionButton,8)
			Stroke(OptionButton)

			New("TextLabel", {
				Size = UDim2.fromOffset(34,50),
				Position = UDim2.fromOffset(5,0),
				BackgroundTransparency = 1,
				Text = GetVehicleIcon(Option.instance.Name),
				TextColor3 = Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 18
			}, OptionButton)

			New("TextLabel", {
				Size = UDim2.new(1,-48,0,21),
				Position = UDim2.fromOffset(40,5),
				BackgroundTransparency = 1,
				Text = GetVehicleDisplayName(Option.instance.Name),
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, OptionButton)

			New("TextLabel", {
				Size = UDim2.new(1,-48,0,18),
				Position = UDim2.fromOffset(40,26),
				BackgroundTransparency = 1,
				Text =
					"Dono: "
					..
					tostring(
						Option.ownerName
						or
						(Option.owner and Option.owner.Name)
						or
						"Desconhecido"
					),
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, OptionButton)

			OptionButton.MouseButton1Click:Connect(function()
				SelectedStolenVehicle = Option
				Button.Text = Option.label
				StealOpened = false
				List.Visible = false
				Frame.Size = UDim2.new(1,-8,0,56)
			end)
		end
	end

	local function RefreshStealList()
		ScanStealableVehicles()
		RenderStealList()
	end

	Button.MouseButton1Click:Connect(function()
		StealOpened = not StealOpened
		if StealOpened then
			RefreshStealList()
		end
		List.Visible = StealOpened
		Frame.Size = UDim2.new(1,-8,0,StealOpened and 292 or 56)
	end)

	local function StopStealLoop()
		StealLoopEnabled = false
		StealLoopToken += 1

		Gui:SetAttribute(
			"VehicleStealSeatActive",
			false
		)
	end

	CartolaPanicRegistry:Register(
		"StealVehicleLoop",
		StopStealLoop
	)

	local function TryStealSelectedVehicle()
		if not SelectedStolenVehicle then
			return false,false
		end

		local Vehicle=
			SelectedStolenVehicle.instance

		if
			not Vehicle
			or
			not Vehicle.Parent
		then
			return false,false
		end

		-- Moto, bicicleta e cadeira de rodas continuam usando MoverRE/Drive.
		if UsesMoverDrive(Vehicle) then
			Gui:SetAttribute(
				"VehicleStealSeatActive",
				false
			)

			local Remote=
				GetMoverRemote()

			if not Remote then
				return false,false
			end

			local Success=
				pcall(function()
					Remote:FireServer(
						"Drive",
						Vehicle,
						nil
					)
				end)

			if Success then
				MarkDrivenVehicle(
					Vehicle
				)
			end

			return Success,false
		end

		-- Carros, ônibus, ambulância, polícia, bombeiro etc. primeiro tentam
		-- assumir o veículo pelo DriveSeat/VehicleSeat físico.
		local SeatSuccess,HadSeat,DriveSeat=
			TryDriveSeatSteal(
				Vehicle
			)

		if SeatSuccess then
			return true,true,DriveSeat
		end

		if HadSeat then
			return false,true,DriveSeat
		end

		-- Fallback somente quando o veículo realmente não expõe DriveSeat.
		Gui:SetAttribute(
			"VehicleStealSeatActive",
			false
		)

		local Remote=
			GetMoverRemote()

		if not Remote then
			return false,false
		end

		local Success=
			pcall(function()
				Remote:FireServer(
					"Drive",
					Vehicle,
					nil
				)
			end)

		if Success then
			MarkDrivenVehicle(
				Vehicle
			)
		end

		return Success,false
	end

	StealToggle = Toggle(
		Veiculos,
		"Roubar veículo selecionado",
		false,
		function(Enabled)
			StopStealLoop()

			if not Enabled then
				return
			end

			if not SelectedStolenVehicle then

				task.defer(function()
					if StealToggle then
						StealToggle:Set(false, false)
					end
				end)
				return
			end

			StealLoopEnabled = true
			local ThisToken = StealLoopToken

			task.spawn(function()
				while
					StealLoopEnabled
					and
					ThisToken==StealLoopToken
					and
					Gui.Parent
				do
					local Success,UsedDriveSeat,DriveSeat=
						TryStealSelectedVehicle()

					if
						Success
						and
						UsedDriveSeat
					then
						StopStealLoop()

						-- Continua liberando a sentada nas proteções enquanto o
						-- jogador realmente estiver dirigindo esse VehicleSeat.
						Gui:SetAttribute(
							"VehicleStealSeatActive",
							true
						)

						task.spawn(function()
							while
								Gui.Parent
							do
								local CurrentHumanoid=
									GetHumanoid()

								if
									not CurrentHumanoid
									or
									not DriveSeat
									or
									not DriveSeat.Parent
									or
									(
										CurrentHumanoid.SeatPart~=DriveSeat
										and
										DriveSeat.Occupant~=CurrentHumanoid
									)
								then
									break
								end

								task.wait(0.12)
							end

							if Gui.Parent then
								Gui:SetAttribute(
									"VehicleStealSeatActive",
									false
								)
							end
						end)

						if StealToggle then
							StealToggle:Set(
								false,
								false
							)
						end

						break
					end

					task.wait(
						UsedDriveSeat
						and
						0.12
						or
						0.10
					)
				end
			end)
		end
	)

	Gui.Destroying:Connect(function()
		StopStealLoop()
		if WorkspaceVehicleAdded then
			WorkspaceVehicleAdded:Disconnect()
			WorkspaceVehicleAdded=nil
		end
		if WorkspaceVehicleRemoving then
			WorkspaceVehicleRemoving:Disconnect()
			WorkspaceVehicleRemoving=nil
		end
	end)
end

--============================================================
-- PUXAR PLAYER PARA ASSENTO DO VEÍCULO
--
-- Somente veículos LTP2. O loop procura um Seat/VehicleSeat no veículo
-- selecionado e tenta prender o alvo nesse assento sem mover o veículo até ele.
--============================================================

Section(
	Veiculos,
	"Puxar para Assento"
)

do
(function()
	local SeatPullPlayers = CreatePlayerSelector(
		Veiculos,
		"Player",
		true,
		true
	)

	local SeatPullSeatReference = Gui:FindFirstChild("CartolaSeatPullSeat")
	if not SeatPullSeatReference then
		SeatPullSeatReference = Instance.new("ObjectValue")
		SeatPullSeatReference.Name = "CartolaSeatPullSeat"
		SeatPullSeatReference.Parent = Gui
	end

	local SelectedSeatVehicle=nil
	local SeatVehicleOptions={}
	local SeatVehicleOpened=false
	local LoopEnabled=false
	local LoopToken=0
	local ForcedWelds={}

	local KnownVehicleNames={
		[12]="Ônibus",
		[13]="Carro de Polícia",
		[14]="Ambulância",
		[15]="Ônibus Escolar",
		[16]="Caminhão de Bombeiros",
		[77]="Drone",
		[79]="Retroescavadeira"
	}

	local MotoIds={
		[30]=true,[31]=true,[41]=true,[7]=true,[8]=true,
		[53]=true,[83]=true,[72]=true,[59]=true
	}

	local BicycleIds={
		[54]=true,[70]=true,[5]=true
	}

	local function IsSeatPullVehicleAllowed(Name)
		local Id=
			tonumber(
				tostring(Name):match(
					"^ltp2_car_(%d+)$"
				)
			)

		return
			Id~=nil
			and
			(
				MotoIds[Id]==true
				or
				BicycleIds[Id]==true
			)
	end

	local function GetSeatVehicleDisplayName(Name)
		local Id=
			tonumber(
				tostring(Name):match(
					"^ltp2_car_(%d+)$"
				)
			)

		if Id and KnownVehicleNames[Id] then
			return KnownVehicleNames[Id]
		end

		if Id==6 then
			return "Cadeira de Rodas"
		end

		if Id and MotoIds[Id] then
			return "Moto"
		end

		if Id and BicycleIds[Id] then
			return "Bicicleta"
		end

		return "Carro"
	end

	local function GetSeatVehicleIcon(Name)
		local Display =
			GetSeatVehicleDisplayName(
				Name
			)

		if Display == "Moto" then
			return "🏍️"
		elseif Display == "Bicicleta" then
			return "🚲"
		elseif Display == "Cadeira de Rodas" then
			return "♿"
		elseif Display == "Ônibus" or Display == "Ônibus Escolar" then
			return "🚌"
		elseif Display == "Ambulância" then
			return "🚑"
		elseif Display == "Caminhão de Bombeiros" then
			return "🚒"
		elseif Display == "Drone" then
			return "🛸"
		elseif Display == "Retroescavadeira" then
			return "🚜"
		end

		return "🚗"
	end

	local function GetSeatVehicleOwner(Vehicle)
		if
			typeof(Vehicle)~="Instance"
			or
			not Vehicle.Parent
		then
			return nil
		end

		local OwnerValue=
			Vehicle:FindFirstChild(
				"VehicleOwner"
			)
			or
			Vehicle:FindFirstChild(
				"VehicleOwner",
				true
			)

		if
			OwnerValue
			and
			OwnerValue:IsA("ObjectValue")
		then
			local Owner=OwnerValue.Value

			if
				Owner
				and
				Owner:IsA("Player")
				and
				Owner.Parent==Players
			then
				return Owner
			end
		end

		return nil
	end

	local function GetSeatVehicleLabel(Vehicle)
		local Label=
			GetSeatVehicleDisplayName(
				Vehicle.Name
			)

		local Owner=
			GetSeatVehicleOwner(
				Vehicle
			)

		if Owner then
			Label=
				Label
				..
				" • Dono: "
				..
				Owner.Name
		end

		return Label
	end


	local function IsSeat(Object)
		return Object and (Object:IsA("Seat") or Object:IsA("VehicleSeat"))
	end

	local function ClaimPhysics()
		pcall(function()
			if type(setsimulationradius)=="function" then
				setsimulationradius(1e9,1e9)
			elseif type(sethiddenproperty)=="function" then
				sethiddenproperty(Player,"SimulationRadius",1e9)
			end
		end)
	end

	--========================================================
	-- MENU DE VEÍCULOS LTP2
	--========================================================

	local VehicleFrame=New("Frame",{
		Size=UDim2.new(1,-8,0,56),
		BackgroundColor3=Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},Veiculos)
	Corner(VehicleFrame,9)

	New("TextLabel",{
		Size=UDim2.new(0.42,0,1,0),
		Position=UDim2.fromOffset(18,0),
		BackgroundTransparency=1,
		Text="Veículo",
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamMedium,
		TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left
	},VehicleFrame)

	local VehicleButton=New("TextButton",{
		Size=UDim2.new(0.48,-20,0,38),
		Position=UDim2.new(0.52,5,0,9),
		BackgroundColor3=Theme.Card2,
		BorderSizePixel=0,
		Text="Selecionar veículo",
		TextColor3=Theme.Text,
		Font=Enum.Font.GothamBold,
		TextSize=13,
		TextTruncate=Enum.TextTruncate.AtEnd
	},VehicleFrame)
	Corner(VehicleButton,8)

	local VehicleList=New("ScrollingFrame",{
		Size=UDim2.new(1,-36,0,220),
		Position=UDim2.fromOffset(18,62),
		BackgroundColor3=Color3.fromRGB(35,35,38),
		BorderSizePixel=0,
		ScrollBarThickness=3,
		ScrollBarImageColor3=Theme.Accent,
		CanvasSize=UDim2.new(),
		Visible=false
	},VehicleFrame)
	Corner(VehicleList,8)
	New("UIListLayout",{Padding=UDim.new(0,4)},VehicleList)

	local function ScanSeatVehicles()
		SeatVehicleOptions={}
		local Seen={}

		for _,Object in ipairs(workspace:GetDescendants()) do
			if Object.Name and Object.Name:match("^ltp2_car_%d+$")
				and (Object:IsA("Model") or Object:IsA("BasePart"))
				and not Seen[Object]
			then
				local Owner=
					GetSeatVehicleOwner(
						Object
					)

				-- Puxar para Assento mostra somente veículos do jogador local
				-- e apenas motos/bicicletas.
				if
					Owner==Player
					and
					IsSeatPullVehicleAllowed(
						Object.Name
					)
				then
					Seen[Object]=true
					table.insert(SeatVehicleOptions,{
						instance=Object,
						name=Object.Name,
						label=GetSeatVehicleLabel(Object),
						owner=Owner,
						inMap=true
					})
				end
			end
		end

		table.sort(SeatVehicleOptions,function(A,B)
			local AId=tonumber(A.name:match("(%d+)$")) or math.huge
			local BId=tonumber(B.name:match("(%d+)$")) or math.huge
			if AId==BId then return A.label<B.label end
			return AId<BId
		end)
	end

	local function ClearSeatVehicleButtons()
		for _,Child in ipairs(VehicleList:GetChildren()) do
			if Child:IsA("TextButton") then Child:Destroy() end
		end
	end

	local function RefreshSeatVehicleList()
		ScanSeatVehicles()

		if SelectedSeatVehicle then
			local StillExists=false
			for _,Option in ipairs(SeatVehicleOptions) do
				if Option.instance==SelectedSeatVehicle.instance then
					StillExists=true
					SelectedSeatVehicle=Option
					VehicleButton.Text=Option.label
					break
				end
			end
			if not StillExists then
				SelectedSeatVehicle=nil
				VehicleButton.Text="Selecionar veículo"
			end
		end

		ClearSeatVehicleButtons()
		VehicleList.CanvasSize=UDim2.new(0,0,0,math.max(1,#SeatVehicleOptions)*54)

		if #SeatVehicleOptions==0 then
			local Empty=New("TextButton",{
				Size=UDim2.new(1,-5,0,35),
				BackgroundColor3=Theme.Card2,
				BorderSizePixel=0,
				Text="Nenhuma moto ou bicicleta sua encontrada",
				TextColor3=Theme.SubText,
				Font=Enum.Font.GothamMedium,
				TextSize=12,
				AutoButtonColor=false
			},VehicleList)
			Corner(Empty,7)
			return
		end

		for _,Option in ipairs(SeatVehicleOptions) do
			local OptionButton=New("TextButton",{
				Size=UDim2.new(1,-5,0,50),
				BackgroundColor3=Theme.Card2,
				BorderSizePixel=0,
				Text="",
				AutoButtonColor=true
			},VehicleList)
			Corner(OptionButton,8)
			Stroke(OptionButton)

			New("TextLabel",{
				Size=UDim2.fromOffset(34,50),
				Position=UDim2.fromOffset(5,0),
				BackgroundTransparency=1,
				Text=GetSeatVehicleIcon(Option.instance.Name),
				TextColor3=Theme.Accent,
				Font=Enum.Font.GothamBold,
				TextSize=18
			},OptionButton)

			New("TextLabel",{
				Size=UDim2.new(1,-48,0,21),
				Position=UDim2.fromOffset(40,5),
				BackgroundTransparency=1,
				Text=GetSeatVehicleDisplayName(Option.instance.Name),
				TextColor3=Theme.Text,
				Font=Enum.Font.GothamBold,
				TextSize=13,
				TextXAlignment=Enum.TextXAlignment.Left,
				TextTruncate=Enum.TextTruncate.AtEnd
			},OptionButton)

			New("TextLabel",{
				Size=UDim2.new(1,-48,0,18),
				Position=UDim2.fromOffset(40,26),
				BackgroundTransparency=1,
				Text="Dono: "..Option.owner.Name,
				TextColor3=Theme.SubText,
				Font=Enum.Font.GothamMedium,
				TextSize=11,
				TextXAlignment=Enum.TextXAlignment.Left,
				TextTruncate=Enum.TextTruncate.AtEnd
			},OptionButton)
			OptionButton.MouseButton1Click:Connect(function()
				SelectedSeatVehicle=Option

				VehicleButton.Text=Option.label
				SeatVehicleOpened=false
				VehicleList.Visible=false
				VehicleFrame.Size=UDim2.new(1,-8,0,56)
			end)
		end
	end

	VehicleButton.MouseButton1Click:Connect(function()
		SeatVehicleOpened=not SeatVehicleOpened
		if SeatVehicleOpened then RefreshSeatVehicleList() end
		VehicleList.Visible=SeatVehicleOpened
		VehicleFrame.Size=UDim2.new(1,-8,0,SeatVehicleOpened and 292 or 56)
	end)

	--========================================================
	-- LOCALIZAÇÃO DOS ASSENTOS
	--========================================================

	local function AddSeatCandidate(Result,Seen,Vehicle,Seat)
		if not Vehicle or not Seat or Seen[Seat] or not IsSeat(Seat) then return end
		if Seat.Occupant~=nil then return end
		Seen[Seat]=true
		table.insert(Result,{Vehicle=Vehicle,Seat=Seat})
	end

	local function CollectSeatsFromVehicle(VehicleOption)
		local Result={}
		local Seen={}
		if not VehicleOption then return Result end

		local Vehicle=VehicleOption.instance
		if Vehicle and typeof(Vehicle)=="Instance" then
			if Vehicle:IsA("Model") then
				for _,Descendant in ipairs(Vehicle:GetDescendants()) do
					if IsSeat(Descendant) then AddSeatCandidate(Result,Seen,Vehicle,Descendant) end
				end
			elseif Vehicle:IsA("BasePart") then
				if IsSeat(Vehicle) then AddSeatCandidate(Result,Seen,Vehicle,Vehicle) end
				local Ok,Connected=pcall(function() return Vehicle:GetConnectedParts(true) end)
				if Ok and type(Connected)=="table" then
					for _,Part in ipairs(Connected) do
						if IsSeat(Part) then AddSeatCandidate(Result,Seen,Vehicle,Part) end
					end
				end
			end
		end

		-- Alguns ltp2_car_XX são uma Part separada do Seat. Procura apenas
		-- assentos próximos do veículo, sem mover o veículo até o player.
		if #Result==0 and Vehicle and Vehicle:IsA("BasePart") then
			local Params=OverlapParams.new()
			Params.FilterType=Enum.RaycastFilterType.Exclude
			Params.FilterDescendantsInstances={GetCharacter()}
			local Ok,Nearby=pcall(function()
				return workspace:GetPartBoundsInRadius(Vehicle.Position,35,Params)
			end)
			if Ok and type(Nearby)=="table" then
				for _,Part in ipairs(Nearby) do
					if IsSeat(Part) then AddSeatCandidate(Result,Seen,Vehicle,Part) end
				end
			end
		end

		return Result
	end

	--========================================================
	-- SEATWELD / CORREÇÃO DE CFRAME DO VEÍCULO
	--========================================================

	local function CaptureVehicleState(Vehicle,Seat)
		if not Vehicle or typeof(Vehicle)~="Instance" then return nil end

		if Vehicle:IsA("Model") and Vehicle.Parent then
			local RootPart=Vehicle.PrimaryPart or Vehicle:FindFirstChildWhichIsA("BasePart",true)
			return {
				kind="Model",
				object=Vehicle,
				cframe=Vehicle:GetPivot(),
				root=RootPart,
				linear=RootPart and RootPart.AssemblyLinearVelocity or Vector3.zero,
				angular=RootPart and RootPart.AssemblyAngularVelocity or Vector3.zero
			}
		end

		local Items={}
		local Seen={}
		local function AddRoot(Part)
			if not Part or not Part:IsA("BasePart") then return end
			local Root=Part.AssemblyRootPart or Part
			if Seen[Root] then return end
			Seen[Root]=true
			table.insert(Items,{
				object=Root,
				cframe=Root.CFrame,
				linear=Root.AssemblyLinearVelocity,
				angular=Root.AssemblyAngularVelocity
			})
		end

		if Vehicle:IsA("BasePart") and Vehicle.Parent then AddRoot(Vehicle) end
		if Seat and Seat:IsA("BasePart") and Seat.Parent then AddRoot(Seat) end

		if #Items>0 then return {kind="Parts",items=Items} end
		return nil
	end

	local function RestoreVehicleState(State)
		if not State then return end
		pcall(function()
			if State.kind=="Model" and State.object and State.object.Parent then
				State.object:PivotTo(State.cframe)
				if State.root and State.root.Parent then
					State.root.AssemblyLinearVelocity=State.linear
					State.root.AssemblyAngularVelocity=State.angular
				end
			elseif State.kind=="Parts" then
				for _,Item in ipairs(State.items) do
					if Item.object and Item.object.Parent then
						Item.object.CFrame=Item.cframe
						Item.object.AssemblyLinearVelocity=Item.linear
						Item.object.AssemblyAngularVelocity=Item.angular
					end
				end
			end
		end)
	end

	local function GetSeatTargetCFrame(Seat,Humanoid,TargetRoot)
		if not Seat or not TargetRoot then return nil end

		-- Mantém o HumanoidRootPart acima da superfície do assento.
		-- O offset é calculado pelo tamanho real do Seat/HRP, em vez de
		-- usar um valor fixo que variava bastante entre bancos e veículos.
		local Extra=0.12
		if Humanoid then
			Extra=math.clamp((Humanoid.HipHeight or 0)*0.08,0.08,0.22)
		end

		local Height=(Seat.Size.Y*0.5)+(TargetRoot.Size.Y*0.5)+Extra
		return Seat.CFrame*CFrame.new(0,Height,0)
	end

	local function EnsureForcedSeatWeld(Seat,TargetRoot,DesiredCFrame)
		if not Seat or not TargetRoot then return nil end

		local Existing=Seat:FindFirstChild("SeatWeld")
		if Existing and Existing:IsA("Weld") then
			if Existing.Part0==Seat and Existing.Part1==TargetRoot then
				return Existing
			end
			if Seat.Occupant~=nil then return nil end
			pcall(function() Existing:Destroy() end)
		end

		local TargetCF=DesiredCFrame or TargetRoot.CFrame
		local Weld=Instance.new("Weld")
		Weld.Name="SeatWeld"
		Weld.Part0=Seat
		Weld.Part1=TargetRoot

		-- Relação correta do Weld:
		-- Part0.CFrame * C0 == Part1.CFrame * C1
		-- Assim o Root permanece exatamente no CFrame de sentado calculado.
		Weld.C0=Seat.CFrame:ToObjectSpace(TargetCF)
		Weld.C1=CFrame.new()
		pcall(function() Weld:SetAttribute("CartolaForced",true) end)
		Weld.Parent=Seat
		ForcedWelds[Weld]=true
		return Weld
	end

	local function ForceHumanoidSeated(Humanoid)
		if not Humanoid or Humanoid.Health<=0 then return end
		pcall(function() Humanoid.Sit=true end)
		pcall(function()
			Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
		end)
	end

	local function TouchSeat(Seat,TargetRoot,TargetCharacter)
		if type(firetouchinterest)~="function" then return end
		local TouchPart=TargetCharacter:FindFirstChild("LowerTorso")
			or TargetCharacter:FindFirstChild("Torso")
			or TargetRoot
		for _,Part in ipairs({TargetRoot,TouchPart}) do
			if Part and Part:IsA("BasePart") then
				pcall(function()
					firetouchinterest(Seat,Part,0)
					firetouchinterest(Seat,Part,1)
				end)
			end
		end
	end

	local function ForceTargetToSeat(Target,Seat,Vehicle)
		if not Target or not Target.Character or not Seat or not Seat.Parent then return false end

		local Character=Target.Character
		local Humanoid=Character:FindFirstChildOfClass("Humanoid")
		local Root=Character:FindFirstChild("HumanoidRootPart")
		if not Humanoid or not Root or Humanoid.Health<=0 then return false end
		if Seat.Occupant and Seat.Occupant~=Humanoid then return false end

		local ExistingWeld=Seat:FindFirstChild("SeatWeld")
		if ExistingWeld and ExistingWeld:IsA("Weld") and ExistingWeld.Part1
			and not ExistingWeld.Part1:IsDescendantOf(Character)
		then
			return false
		end

		ClaimPhysics()
		SeatPullSeatReference.Value=Seat
		Gui:SetAttribute("SeatPullActive",true)

		local VehicleState=CaptureVehicleState(Vehicle,Seat)
		local OldDisabled=Seat.Disabled
		local OldCanTouch=Seat.CanTouch
		local OldCanCollide=Seat.CanCollide

		pcall(function()
			Seat.Disabled=false
			Seat.CanTouch=true
			Seat.CanCollide=true
		end)

		local Desired=GetSeatTargetCFrame(Seat,Humanoid,Root)
		if not Desired then
			SeatPullSeatReference.Value=nil
			Gui:SetAttribute("SeatPullActive",false)
			return false
		end

		-- Move somente o alvo para o Seat. O veículo nunca é levado ao player.
		pcall(function()
			Root.AssemblyLinearVelocity=Vector3.zero
			Root.AssemblyAngularVelocity=Vector3.zero
			Root.CFrame=Desired
		end)

		-- Primeiro tentamos o caminho nativo. Criar um SeatWeld manual no mesmo
		-- frame de Seat:Sit pode impedir o próprio Seat de concluir a sentada.
		ForceHumanoidSeated(Humanoid)
		TouchSeat(Seat,Root,Character)
		pcall(function() Seat:Sit(Humanoid) end)
		RunService.Heartbeat:Wait()

		local NativeWeld=Seat:FindFirstChild("SeatWeld")
		if not (NativeWeld and NativeWeld:IsA("Weld") and NativeWeld.Part1==Root) then
			EnsureForcedSeatWeld(Seat,Root,Desired)
		end

		-- Reforça por alguns frames. Se o servidor/cliente remover o estado
		-- Seated, o loop recoloca o Root no assento e recria o SeatWeld.
		for _=1,8 do
			RunService.Heartbeat:Wait()
			if not LoopEnabled or not Root.Parent or not Seat.Parent then break end

			-- O carro não é levado até o alvo. Apenas corrigimos sua posição se
			-- a nova assembly tentar deslocá-lo.
			RestoreVehicleState(VehicleState)

			Desired=GetSeatTargetCFrame(Seat,Humanoid,Root) or Desired
			pcall(function()
				Seat.Disabled=false
				Seat.CanTouch=true
				Root.AssemblyLinearVelocity=Vector3.zero
				Root.AssemblyAngularVelocity=Vector3.zero
				Root.CFrame=Desired
			end)

			ForceHumanoidSeated(Humanoid)
			TouchSeat(Seat,Root,Character)
			pcall(function() Seat:Sit(Humanoid) end)

			local CurrentWeld=Seat:FindFirstChild("SeatWeld")
			if not (CurrentWeld and CurrentWeld:IsA("Weld") and CurrentWeld.Part1==Root) then
				EnsureForcedSeatWeld(Seat,Root,Desired)
			end
		end

		RestoreVehicleState(VehicleState)

		local FinalWeld=Seat:FindFirstChild("SeatWeld")
		local Success=(Seat.Occupant==Humanoid)
			or (Humanoid.SeatPart==Seat)
			or (FinalWeld and FinalWeld:IsA("Weld") and FinalWeld.Part1==Root)

		pcall(function()
			Seat.Disabled=OldDisabled
			Seat.CanTouch=OldCanTouch
			Seat.CanCollide=OldCanCollide
		end)

		SeatPullSeatReference.Value=nil
		Gui:SetAttribute("SeatPullActive",false)
		return Success
	end

	local function TryPullTarget(Target)
		if not SelectedSeatVehicle then return false end
		local Candidates=CollectSeatsFromVehicle(SelectedSeatVehicle)
		for _,Candidate in ipairs(Candidates) do
			if ForceTargetToSeat(Target,Candidate.Seat,Candidate.Vehicle) then
				return true
			end
		end
		return false
	end

	local function StopSeatPullLoop()
		LoopEnabled=false
		LoopToken+=1
		Gui:SetAttribute("SeatPullActive",false)
		SeatPullSeatReference.Value=nil

		for Weld in pairs(ForcedWelds) do
			if Weld and Weld.Parent then
				pcall(function() Weld:Destroy() end)
			end
			ForcedWelds[Weld]=nil
		end
	end

	local SeatLoopToggle
	SeatLoopToggle=Toggle(
		Veiculos,
		"Puxar para assento",
		false,
		function(Enabled)
			StopSeatPullLoop()
			if not Enabled then return end

			if #SeatPullPlayers:GetPlayers()==0 then

				if SeatLoopToggle then SeatLoopToggle:Set(false,false) end
				return
			end

			if not SelectedSeatVehicle then

				if SeatLoopToggle then SeatLoopToggle:Set(false,false) end
				return
			end

			LoopEnabled=true
			local Token=LoopToken
			task.spawn(function()
				while LoopEnabled and Token==LoopToken and Gui.Parent do
					local Targets=SeatPullPlayers:GetPlayers()
					for _,Target in ipairs(Targets) do
						if not LoopEnabled or Token~=LoopToken then break end
						TryPullTarget(Target)
						task.wait(0.04)
					end
					task.wait(0.08)
				end
			end)
		end
	)

	Gui.Destroying:Connect(function()
		StopSeatPullLoop()
	end)
end)()
end

--============================================================
-- VFLY / VEHICLE FLY - ESTILO INFINITE YIELD
--
-- Esta versão segue o funcionamento do VFly do Infinite Yield:
--   • NÃO aplica BodyGyro/BodyVelocity diretamente na moto/carro;
--   • aplica os BodyMovers no HumanoidRootPart do player;
--   • enquanto o player está sentado, a assembly do veículo acompanha;
--   • BodyGyro.CFrame segue diretamente a câmera;
--   • W/S/A/D usam a direção da câmera;
--   • Q/E controlam descida/subida no PC;
--   • no mobile usa ControlModule:GetMoveVector().
--
-- Isso evita depender da orientação interna da Union/AssemblyRootPart
-- dos veículos ltp2_car_XX.
--============================================================

Section(
	Veiculos,
	"VFly"
)

do
	local VFlyEnabled =
		false

	local VFlySpeed =
		2

	local VFlyConnection =
		nil

	local VFlyKeyDown =
		nil

	local VFlyKeyUp =
		nil

	local VFlyVelocity =
		nil

	local VFlyGyro =
		nil

	local VFlyRoot =
		nil

	local function DisconnectVFlyInputs()

		if VFlyKeyDown then

			VFlyKeyDown:Disconnect()

			VFlyKeyDown =
				nil

		end

		if VFlyKeyUp then

			VFlyKeyUp:Disconnect()

			VFlyKeyUp =
				nil

		end

	end

	local function DestroyVFlyMovers()

		if VFlyConnection then

			VFlyConnection:Disconnect()

			VFlyConnection =
				nil

		end

		if
			VFlyGyro
			and
			VFlyGyro.Parent
		then

			VFlyGyro:Destroy()

		end

		if
			VFlyVelocity
			and
			VFlyVelocity.Parent
		then

			VFlyVelocity:Destroy()

		end

		VFlyGyro =
			nil

		VFlyVelocity =
			nil

		VFlyRoot =
			nil

	end

	local function StopVFly()

		local WasEnabled =
			VFlyEnabled

		VFlyEnabled =
			false

		if WasEnabled then
			Gui:SetAttribute(
				"FlightExitRecoveryActive",
				true
			)
		end

		Gui:SetAttribute(
			"VFlyActive",
			false
		)

		DisconnectVFlyInputs()
		DestroyVFlyMovers()

		local Humanoid =
			GetHumanoid()

		if Humanoid then
			Humanoid.PlatformStand =
				false
		end

		pcall(function()
			workspace.CurrentCamera.CameraType =
				Enum.CameraType.Custom
		end)

		if WasEnabled then
			task.delay(0.25, function()
				Gui:SetAttribute(
					"FlightExitRecoveryActive",
					false
				)
			end)
		end

	end

	CartolaPanicRegistry:Register(
		"VFly",
		StopVFly
	)

	local function CreateMovers(
		Root
	)

		local BG =
			Instance.new(
				"BodyGyro"
			)

		local BV =
			Instance.new(
				"BodyVelocity"
			)

		BG.Name =
			"CartolaIYVFlyGyro"

		BV.Name =
			"CartolaIYVFlyVelocity"

		-- Valores iguais ao método desktop do Infinite Yield.
		BG.P =
			9e4

		BG.MaxTorque =
			Vector3.new(
				9e9,
				9e9,
				9e9
			)

		BG.CFrame =
			Root.CFrame

		BV.Velocity =
			Vector3.zero

		BV.MaxForce =
			Vector3.new(
				9e9,
				9e9,
				9e9
			)

		BG.Parent =
			Root

		BV.Parent =
			Root

		VFlyGyro =
			BG

		VFlyVelocity =
			BV

	end

	local function StartDesktopVFly(
		Root,
		Humanoid
	)

		local CONTROL = {
			F = 0,
			B = 0,
			L = 0,
			R = 0,
			Q = 0,
			E = 0
		}

		local LastCONTROL = {
			F = 0,
			B = 0,
			L = 0,
			R = 0,
			Q = 0,
			E = 0
		}

		local SPEED =
			0

		CreateMovers(
			Root
		)

		VFlyKeyDown =
			UIS.InputBegan:Connect(function(
				Input,
				Processed
			)

				if
					Processed
					or
					not VFlyEnabled
				then

					return

				end

				if Input.KeyCode == Enum.KeyCode.W then

					CONTROL.F =
						1

				elseif Input.KeyCode == Enum.KeyCode.S then

					CONTROL.B =
						-1

				elseif Input.KeyCode == Enum.KeyCode.A then

					CONTROL.L =
						-1

				elseif Input.KeyCode == Enum.KeyCode.D then

					CONTROL.R =
						1

				elseif Input.KeyCode == Enum.KeyCode.E then

					CONTROL.Q =
						1.6

				elseif Input.KeyCode == Enum.KeyCode.Q then

					CONTROL.E =
						-1.6

				end

				pcall(function()

					workspace.CurrentCamera.CameraType =
						Enum.CameraType.Track

				end)

			end)

		VFlyKeyUp =
			UIS.InputEnded:Connect(function(
				Input,
				Processed
			)

				if
					Processed
					or
					not VFlyEnabled
				then

					return

				end

				if Input.KeyCode == Enum.KeyCode.W then

					CONTROL.F =
						0

				elseif Input.KeyCode == Enum.KeyCode.S then

					CONTROL.B =
						0

				elseif Input.KeyCode == Enum.KeyCode.A then

					CONTROL.L =
						0

				elseif Input.KeyCode == Enum.KeyCode.D then

					CONTROL.R =
						0

				elseif Input.KeyCode == Enum.KeyCode.E then

					CONTROL.Q =
						0

				elseif Input.KeyCode == Enum.KeyCode.Q then

					CONTROL.E =
						0

				end

			end)

		VFlyConnection =
			RunService.Heartbeat:Connect(function()

				if
					not VFlyEnabled
					or
					not Root
					or
					not Root.Parent
					or
					not Humanoid
					or
					Humanoid.Health <= 0
					or
					not VFlyGyro
					or
					not VFlyVelocity
				then

					if VFlyEnabled then

						StopVFly()

					end

					return

				end

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				-- VFly do IY não coloca PlatformStand = true.
				Humanoid.PlatformStand =
					false

				if
					CONTROL.L + CONTROL.R ~= 0
					or
					CONTROL.F + CONTROL.B ~= 0
					or
					CONTROL.Q + CONTROL.E ~= 0
				then

					SPEED =
						VFlySpeed * 35

				elseif SPEED ~= 0 then

					SPEED =
						0

				end

				if
					CONTROL.L + CONTROL.R ~= 0
					or
					CONTROL.F + CONTROL.B ~= 0
					or
					CONTROL.Q + CONTROL.E ~= 0
				then

					VFlyVelocity.Velocity =
						(
							(
								Camera.CFrame.LookVector
								*
								(
									CONTROL.F
									+
									CONTROL.B
								)
							)
							+
							(
								(
									Camera.CFrame
									*
									CFrame.new(
										CONTROL.L
										+
										CONTROL.R,

										(
											CONTROL.F
											+
											CONTROL.B
											+
											CONTROL.Q
											+
											CONTROL.E
										)
										*
										0.2,

										0
									)
								).Position
								-
								Camera.CFrame.Position
							)
						)
						*
						SPEED

					LastCONTROL = {
						F = CONTROL.F,
						B = CONTROL.B,
						L = CONTROL.L,
						R = CONTROL.R,
						Q = CONTROL.Q,
						E = CONTROL.E
					}

				elseif
					SPEED ~= 0
				then

					VFlyVelocity.Velocity =
						(
							(
								Camera.CFrame.LookVector
								*
								(
									LastCONTROL.F
									+
									LastCONTROL.B
								)
							)
							+
							(
								(
									Camera.CFrame
									*
									CFrame.new(
										LastCONTROL.L
										+
										LastCONTROL.R,

										(
											LastCONTROL.F
											+
											LastCONTROL.B
											+
											CONTROL.Q
											+
											CONTROL.E
										)
										*
										0.2,

										0
									)
								).Position
								-
								Camera.CFrame.Position
							)
						)
						*
						SPEED

				else

					VFlyVelocity.Velocity =
						Vector3.zero

				end

				-- Igual ao Infinite Yield: o giro segue a câmera.
				VFlyGyro.CFrame =
					Camera.CFrame

			end)

	end

	local function StartMobileVFly(
		Root,
		Humanoid
	)

		CreateMovers(
			Root
		)

		VFlyGyro.P =
			1000

		VFlyGyro.D =
			50

		VFlyConnection =
			RunService.RenderStepped:Connect(function()

				if
					not VFlyEnabled
					or
					not Root
					or
					not Root.Parent
					or
					not Humanoid
					or
					Humanoid.Health <= 0
					or
					not VFlyGyro
					or
					not VFlyVelocity
				then

					if VFlyEnabled then

						StopVFly()

					end

					return

				end

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				Humanoid.PlatformStand =
					false

				VFlyVelocity.MaxForce =
					Vector3.new(
						9e9,
						9e9,
						9e9
					)

				VFlyGyro.MaxTorque =
					Vector3.new(
						9e9,
						9e9,
						9e9
					)

				VFlyGyro.CFrame =
					Camera.CFrame

				VFlyVelocity.Velocity =
					Vector3.zero

				local Direction =
					Vector3.zero

				if ControlModule then

					Direction =
						ControlModule:GetMoveVector()

				end

				if Direction.X ~= 0 then

					VFlyVelocity.Velocity +=
						Camera.CFrame.RightVector
						*
						(
							Direction.X
							*
							(
								VFlySpeed
								*
								35
							)
						)

				end

				if Direction.Z ~= 0 then

					VFlyVelocity.Velocity -=
						Camera.CFrame.LookVector
						*
						(
							Direction.Z
							*
							(
								VFlySpeed
								*
								35
							)
						)

				end

			end)

	end

	local function StartVFly()

		-- VFly altera CameraType; evita disputa com View.
		StopView()

		-- Mesmo comportamento conceitual do IY:
		-- desliga o Fly normal antes de ligar VFly.
		if FlyEnabled then

			StopFly()

		end

		StopVFly()

		local Root =
			GetRoot()

		local Humanoid =
			GetHumanoid()

		if
			not Root
			or
			not Humanoid
		then



			return false

		end

		VFlyEnabled =
			true

		VFlyRoot =
			Root

		Gui:SetAttribute(
			"VFlyActive",
			true
		)

		if
			UIS.TouchEnabled
			and
			not UIS.KeyboardEnabled
		then

			StartMobileVFly(
				Root,
				Humanoid
			)

		else

			StartDesktopVFly(
				Root,
				Humanoid
			)

		end

		return true

	end

	Toggle(
		Veiculos,
		"VFly",
		false,
		function(Enabled)

			if Enabled then

				StartVFly()

			else

				StopVFly()

			end

		end
	)

	Slider(
		Veiculos,
		"Velocidade VFly",
		1,
		20,
		2,
		function(Value)

			VFlySpeed =
				Value

		end
	)

	Gui.Destroying:Connect(function()

		StopVFly()

	end)
end

pcall(function()
	if OP:FindFirstChild("CartolaFastBootStatus") then
		OP.CartolaFastBootStatus.Text = "Finalizando interface..."
	end
end)

task.wait()

--============================================================
-- RESPAWN
--============================================================

Player.CharacterAdded:Connect(function(
	Character
)

	local Humanoid =
		Character:WaitForChild(
			"Humanoid"
		)

	local Root =
		Character:WaitForChild(
			"HumanoidRootPart"
		)

	task.wait(0.3)

	MarkActivity()

	Humanoid.WalkSpeed =
		CurrentSpeed

	Humanoid.UseJumpPower =
		true

	Humanoid.JumpPower =
		SuperJumpEnabled
		and
		100
		or
		50

	AntiDefense.LastSafeCFrame =
		Root.CFrame

	if AntiVoidEnabled then

		AntiVoidSafeCFrame =
			Root.CFrame

	end

	if FlingRunning then

		StopFling(false)

	end

	if WalkFlingEnabled then

		task.wait(0.1)

		StartWalkFling()

	end

	if FlyEnabled then

		task.wait(0.15)

		StartFly(true)

	end

end)

--============================================================
-- MINI ÍCONE
--============================================================

local MiniIcon = New(
	"TextButton",
	{
		Size =
			UDim2.fromOffset(
				78,
				78
			),

		AnchorPoint =
			Vector2.new(
				0,
				0
			),

		Position =
			UDim2.new(
				0,
				55,
				0.25,
				0
			),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		Text = "",

		AutoButtonColor = false,

		Active = true,

		Visible = false,

		ZIndex = 300
	},
	Gui
)

local MiniIconImage = New(
	"ImageLabel",
	{
		Size =
			UDim2.fromScale(
				1,
				1
			),

		AnchorPoint =
			Vector2.new(
				0.5,
				0.5
			),

		Position =
			UDim2.fromScale(
				0.5,
				0.5
			),

		BackgroundTransparency = 1,

		Image =
			CartolaMiniIconImage,

		ImageColor3 =
			Color3.new(
				1,
				1,
				1
			),

		ScaleType =
			Enum.ScaleType.Fit,

		ZIndex = 301
	},
	MiniIcon
)

-- MINIMIZAR
--============================================================

local function MinimizeHub()

	CloseSelectors()

	Main.Visible =
		false

	MiniIcon.Visible =
		true

end

local function RestoreHub()

	Main.Visible =
		true

	MiniIcon.Visible =
		false

end

Minimize.MouseButton1Click:Connect(
	MinimizeHub
)

--============================================================
-- DRAG MAIN
--============================================================

local MainDragging = false

local MainDragInput = nil

local MainDragStart = nil

local MainStartPosition = nil

DragArea.InputBegan:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseButton1

		or

		Input.UserInputType
		==
		Enum.UserInputType.Touch
	then

		MainDragging =
			true

		MainDragStart =
			Input.Position

		MainStartPosition =
			Main.Position

		if
			Input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			MainDragInput =
				Input

		end

	end

end)

DragArea.InputChanged:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseMovement

		or

		Input.UserInputType
		==
		Enum.UserInputType.Touch
	then

		MainDragInput =
			Input

	end

end)

--============================================================
-- DRAG MINI
--============================================================

local IconDragging = false
local IconMoved = false
local IconTouchInput = nil
local IconDragConnection = nil

local IconStartPointer =
	Vector2.zero

local IconStartAbsolute =
	Vector2.zero

local MouseCoordinateCorrection =
	Vector2.zero

local function StopMiniDrag()

	IconDragging = false
	IconTouchInput = nil

	if IconDragConnection then
		IconDragConnection:Disconnect()
		IconDragConnection = nil
	end

end

local function ApplyMiniDrag(
	Pointer
)

	if not IconDragging then
		return
	end

	local Delta =
		Pointer
		-
		IconStartPointer

	-- Clique simples não altera a posição nem 1 pixel.
	if
		not IconMoved
		and
		Delta.Magnitude <= 6
	then
		return
	end

	IconMoved = true

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	local Viewport =
		Camera.ViewportSize

	local IconWidth =
		math.max(
			1,
			MiniIcon.AbsoluteSize.X
		)

	local IconHeight =
		math.max(
			1,
			MiniIcon.AbsoluteSize.Y
		)

	local X =
		math.clamp(
			IconStartAbsolute.X
			+
			Delta.X,

			0,

			math.max(
				0,
				Viewport.X
				-
				IconWidth
			)
		)

	local Y =
		math.clamp(
			IconStartAbsolute.Y
			+
			Delta.Y,

			0,

			math.max(
				0,
				Viewport.Y
				-
				IconHeight
			)
		)

	MiniIcon.Position =
		UDim2.fromOffset(
			X,
			Y
		)

end

local function StartMouseMiniDrag(
	Input
)

	StopMiniDrag()

	IconDragging = true
	IconMoved = false

	-- Input.Position e GetMouseLocation podem ter referências diferentes
	-- por causa da barra superior do Roblox. Medimos essa diferença uma vez.
	local InputPoint =
		Vector2.new(
			Input.Position.X,
			Input.Position.Y
		)

	local RawMouse =
		UIS:GetMouseLocation()

	MouseCoordinateCorrection =
		RawMouse
		-
		InputPoint

	IconStartPointer =
		InputPoint

	IconStartAbsolute =
		Vector2.new(
			MiniIcon.AbsolutePosition.X,
			MiniIcon.AbsolutePosition.Y
		)

	IconDragConnection =
		RunService.RenderStepped:Connect(function()

			if
				not IconDragging
				or
				not UIS:IsMouseButtonPressed(
					Enum.UserInputType.MouseButton1
				)
			then
				StopMiniDrag()
				return
			end

			local Raw =
				UIS:GetMouseLocation()

			local Corrected =
				Raw
				-
				MouseCoordinateCorrection

			ApplyMiniDrag(
				Corrected
			)

		end)

end

MiniIcon.InputBegan:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseButton1
	then

		StartMouseMiniDrag(
			Input
		)

	elseif
		Input.UserInputType
		==
		Enum.UserInputType.Touch
	then

		StopMiniDrag()

		IconDragging = true
		IconMoved = false
		IconTouchInput = Input

		IconStartPointer =
			Vector2.new(
				Input.Position.X,
				Input.Position.Y
			)

		IconStartAbsolute =
			Vector2.new(
				MiniIcon.AbsolutePosition.X,
				MiniIcon.AbsolutePosition.Y
			)

	end

end)

UIS.InputChanged:Connect(function(Input)

	-- Drag da janela principal preservado.
	if
		MainDragging
		and
		Input == MainDragInput
	then

		local Delta =
			Input.Position
			-
			MainDragStart

		Main.Position =
			UDim2.new(
				MainStartPosition.X.Scale,
				MainStartPosition.X.Offset
				+
				Delta.X,

				MainStartPosition.Y.Scale,
				MainStartPosition.Y.Offset
				+
				Delta.Y
			)

	end

	if
		IconDragging
		and
		IconTouchInput
		and
		Input == IconTouchInput
	then

		ApplyMiniDrag(
			Vector2.new(
				Input.Position.X,
				Input.Position.Y
			)
		)

	end

end)

UIS.InputEnded:Connect(function(Input)

	if
		Input.UserInputType
		==
		Enum.UserInputType.MouseButton1
	then

		MainDragging = false
		StopMiniDrag()

	elseif
		Input.UserInputType
		==
		Enum.UserInputType.Touch
	then

		MainDragging = false

		if
			not IconTouchInput
			or
			Input == IconTouchInput
		then
			StopMiniDrag()
		end

	end

end)

MiniIcon.MouseButton1Click:Connect(function()

	if IconMoved then
		IconMoved = false
		return
	end

	RestoreHub()

end)

--============================================================
-- RESPONSIVO
--============================================================

local function Responsive()

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	local Viewport =
		Camera.ViewportSize

	-- Mobile: ocupa menos a tela para sobrar margem e facilitar toque.
	-- Desktop: redução leve em relação ao antigo 980x570.
	CurrentCompact =
		Viewport.X < 760
		or
		Viewport.Y < 520

	local Width

	local Height

	if CurrentCompact then

		Width =
			math.max(
				300,
				math.min(
					860,
					math.floor(
						Viewport.X
						*
						0.92
					)
				)
			)

		Height =
			math.max(
				300,
				math.min(
					500,
					math.floor(
						Viewport.Y
						*
						0.88
					)
				)
			)

	else

		Width =
			math.max(
				700,
				math.min(
					920,
					Viewport.X - 60
				)
			)

		Height =
			math.max(
				430,
				math.min(
					535,
					Viewport.Y - 60
				)
			)

	end

	local ScaleObject =
		Main:FindFirstChild(
			"DesktopScale"
		)

	if ScaleObject then
		ScaleObject.Scale =
			math.clamp(
				tonumber(
					Gui:GetAttribute(
						"CartolaGuiScale"
					)
				)
				or
				1,
				0.40,
				1.60
			)
	end

	local TopHeight =
		CurrentCompact
		and
		52
		or
		61

	local SidebarWidth

	if CurrentCompact then

		SidebarWidth =
			58

	else

		SidebarWidth =
			math.clamp(
				Width * 0.27,
				180,
				250
			)

	end

	Main.Size =
		UDim2.fromOffset(
			Width,
			Height
		)

	Topbar.Size =
		UDim2.new(
			1,0,
			0,TopHeight
		)

	DragArea.Size =
		UDim2.new(
			1,-100,
			0,TopHeight
		)

	Title.Size =
		UDim2.fromOffset(

			CurrentCompact
			and
			150
			or
			190,

			TopHeight

		)

	Title.Position =
		UDim2.fromOffset(

			CurrentCompact
			and
			12
			or
			28,

			0

		)

	Subtitle.Visible =
		not CurrentCompact

	Sidebar.Size =
		UDim2.new(
			0,SidebarWidth,
			1,-TopHeight
		)

	Sidebar.Position =
		UDim2.fromOffset(
			0,
			TopHeight
		)

	Content.Size =
		UDim2.new(
			1,-SidebarWidth,
			1,-TopHeight
		)

	Content.Position =
		UDim2.fromOffset(
			SidebarWidth,
			TopHeight
		)

	Minimize.Position =
		UDim2.new(
			1,-92,
			0,
			(TopHeight - 42) / 2
		)

	Close.Position =
		UDim2.new(
			1,-47,
			0,
			(TopHeight - 42) / 2
		)

	for _, Selector in ipairs(
		PlayerSelectors
	) do

		Selector:Responsive()

	end

	if CurrentCompact then

		SidePadding.PaddingLeft =
			UDim.new(
				0,
				6
			)

		SidePadding.PaddingRight =
			UDim.new(
				0,
				6
			)

		for _, Label in pairs(
			TabLabels
		) do

			Label.Visible =
				false

		end

		for _, Icon in pairs(
			TabIcons
		) do

			Icon.Position =
				UDim2.new(
					0.5,-22,
					0,0
				)

		end

	else

		SidePadding.PaddingLeft =
			UDim.new(
				0,
				20
			)

		SidePadding.PaddingRight =
			UDim.new(
				0,
				18
			)

		for _, Label in pairs(
			TabLabels
		) do

			Label.Visible =
				true

		end

		for _, Icon in pairs(
			TabIcons
		) do

			Icon.Position =
				UDim2.fromOffset(
					10,
					0
				)

		end

	end

end

--============================================================
-- RIGHT SHIFT
--============================================================

UIS.InputBegan:Connect(function(
	Input,
	Processed
)

	if Processed then
		return
	end

	if
		Input.KeyCode
		==
		Enum.KeyCode.RightShift
	then

		if Main.Visible then

			MinimizeHub()

		else

			RestoreHub()

		end

	end

end)

--============================================================
-- OUTROS SCRIPTS
--
-- Carregadores externos. Cada botão só executa quando clicado.
-- Requer ambiente com loadstring + game:HttpGet.
--
-- Fontes escolhidas:
--   • Infinite Yield oficial (EdgeIY)
--   • Dex Explorer + Dex++
--   • Cobalt RemoteSpy, SimpleSpy V3 e Audio Logger (mesmas fontes do Infinite Yield)
--   • CMD-X oficial
--   • Fates Admin (GitHub)
--   • Nameless Admin (GitHub)
--   • Orca (DarkNetworks)
--   • Unnamed ESP (ic3w0lf22)
--   • Minimal Hub (Wakype)
--   • Hydroxide (Upbolt)
--   • Sirius (ScriptBlox)
--============================================================

Section(
	Pages["Scripts"],
	"Scripts"
)

do
	local ScriptStatus =
		Status(
			Pages["Scripts"],
			"Selecione um script"
		)

	local function RunExternalScript(
		Name,
		URL
	)

		if type(loadstring) ~= "function" then

			ScriptStatus.Text =
				"loadstring indisponível"



			return

		end

		ScriptStatus.Text =
			"Carregando "
			..
			Name
			..
			"..."

		task.spawn(function()

			local Success,
				Result =
				pcall(function()

					local Source =
						game:HttpGet(
							URL
						)

					local Chunk,
						CompileError =
						loadstring(
							Source
						)

					if not Chunk then

						error(
							CompileError
							or
							"Falha ao compilar"
						)

					end

					return Chunk()

				end)

			if Success then

				ScriptStatus.Text =
					Name
					..
					" carregado"

			else

				ScriptStatus.Text =
					"Erro: "
					..
					Name



			end

		end)

	end

	Action(
		Pages["Scripts"],
		"Infinite Yield",
		function()

			RunExternalScript(
				"Infinite Yield",
				"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Dex Explorer",
		function()

			RunExternalScript(
				"Dex Explorer",
				"https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Dex++",
		function()

			RunExternalScript(
				"Dex++",
				"https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Cobalt RemoteSpy",
		function()

			RunExternalScript(
				"Cobalt RemoteSpy",
				"https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"SimpleSpy V3",
		function()

			RunExternalScript(
				"SimpleSpy V3",
				"https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Audio Logger",
		function()

			RunExternalScript(
				"Audio Logger",
				"https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"CMD-X",
		function()

			RunExternalScript(
				"CMD-X",
				"https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"
			)

		end
	)


	Action(
		Pages["Scripts"],
		"Orca",
		function()
			RunExternalScript("Orca","https://raw.githubusercontent.com/DarkNetworks/Orca/master/public/latest.lua")
		end
	)

	Action(
		Pages["Scripts"],
		"Unnamed ESP",
		function()
			RunExternalScript("Unnamed ESP","https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua")
		end
	)

	Action(
		Pages["Scripts"],
		"Minimal Hub",
		function()
			RunExternalScript("Minimal Hub","https://raw.githubusercontent.com/Wakype/MinimaHub/main/MinimalHub.lua")
		end
	)


	Action(
		Pages["Scripts"],
		"Fates Admin",
		function()

			RunExternalScript(
				"Fates Admin",
				"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Nameless Admin",
		function()

			RunExternalScript(
				"Nameless Admin",
				"https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"
			)

		end
	)

	Action(
		Pages["Scripts"],
		"Wisl Universal",
		function()
			RunExternalScript(
				"Wisl Universal",
				"https://raw.githubusercontent.com/WislUniversal/script/b172b884809c883ceccb383f0641fa3888f0528b/Universal.lua"
			)
		end
	)

	Action(
		Pages["Scripts"],
		"SystemBroken",
		function()
			RunExternalScript(
				"SystemBroken",
				"https://raw.githubusercontent.com/haxvendas/main.lua/refs/heads/main/sys"
			)
		end
	)

	Action(
		Pages["Scripts"],
		"Sirius",
		function()
			RunExternalScript(
				"Sirius",
				"https://scriptblox.com/raw/Universal-Script-Sirius-6661"
			)
		end
	)


	Action(
		Pages["Scripts"],
		"DropKick",
		function()
			RunExternalScript(
				"DropKick",
				"https://scriptblox.com/raw/Universal-Script-THE-REAL-dropkick-177199"
			)
		end
	)


	Action(
		Pages["Scripts"],
		"Hydroxide",
		function()

			if type(loadstring) ~= "function" then



				return

			end

			task.spawn(function()

				local Success,
					Error =
					pcall(function()

						local Owner =
							"Upbolt"

						local Branch =
							"revision"

						local function WebImport(
							File
						)

							local URL =
								(
									"https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"
								):format(
									Owner,
									Branch,
									File
								)

							local Source =
								game:HttpGetAsync(
									URL
								)

							local Chunk,
								CompileError =
								loadstring(
									Source,
									File .. ".lua"
								)

							if not Chunk then

								error(
									CompileError
									or
									"Falha ao compilar"
								)

							end

							return Chunk()

						end

						WebImport(
							"init"
						)

						WebImport(
							"ui/main"
						)

					end)

				if not Success then



				end

			end)

		end
	)
end

--============================================================
-- CAMERA RESPONSIVE
--============================================================

local CameraConnection = nil

local function ConnectCamera()

	if CameraConnection then

		CameraConnection:Disconnect()

		CameraConnection =
			nil

	end

	local Camera =
		workspace.CurrentCamera

	if Camera then

		CameraConnection =
			Camera
			:GetPropertyChangedSignal(
				"ViewportSize"
			)
			:Connect(
				Responsive
			)

	end

end

workspace
	:GetPropertyChangedSignal(
		"CurrentCamera"
	)
	:Connect(function()

		ConnectCamera()

		Responsive()

	end)

--============================================================
-- FECHAR HUB
--============================================================

Close.MouseButton1Click:Connect(function()

	-- Impede dois fechamentos simultâneos.
	if
		not Gui
		or
		not Gui.Parent
		or
		Gui:GetAttribute(
			"CartolaClosing"
		)
		==
		true
	then
		return
	end

	Gui:SetAttribute(
		"CartolaClosing",
		true
	)

	-- O fechamento não pode ser interrompido se uma função específica
	-- der erro. Cada limpeza roda isoladamente.
	local function SafeCloseCall(
		Callback,
		...
	)
		if
			type(Callback)
			~=
			"function"
		then
			return
		end

		local Arguments = {
			...
		}

		pcall(function()
			Callback(
				table.unpack(
					Arguments
				)
			)
		end)
	end

	GiftRunning =
		false

	-- Fecha seletores abertos antes de destruir a interface.
	SafeCloseCall(
		CloseSelectors
	)

	-- Para todas as funções que registraram cleanup no Panic.
	pcall(function()
		if CartolaPanicRegistry then
			CartolaPanicRegistry:Run()
		end
	end)

	-- Compatibilidade com funções antigas que não dependem do Panic.
	SafeCloseCall(
		StopFling,
		false
	)

	SafeCloseCall(
		StopWalkFling
	)

	SafeCloseCall(
		StopFly
	)

	SafeCloseCall(
		StopInfiniteJump
	)

	SafeCloseCall(
		StopFreecam
	)

	SafeCloseCall(
		StopView
	)

	SafeCloseCall(
		StopAntiFling
	)

	SafeCloseCall(
		StopAntiVoid
	)

	SafeCloseCall(
		StopAntiKick
	)

	SafeCloseCall(
		StopAntiAFK
	)

	-- Anti Sit e V2 agora possuem funções internas locais.
	-- O fechamento usa os controllers públicos da própria proteção.
	pcall(function()
		if
			ProtectionControllers
			and
			ProtectionControllers.AntiSitV2
		then
			ProtectionControllers.AntiSitV2(
				false
			)
		end
	end)

	pcall(function()
		if
			ProtectionControllers
			and
			ProtectionControllers.AntiSit
		then
			ProtectionControllers.AntiSit(
				false
			)
		end
	end)

	if ActivityInputBegan then
		pcall(function()
			ActivityInputBegan:Disconnect()
		end)

		ActivityInputBegan =
			nil
	end

	if ActivityInputChanged then
		pcall(function()
			ActivityInputChanged:Disconnect()
		end)

		ActivityInputChanged =
			nil
	end

	if CameraConnection then
		pcall(function()
			CameraConnection:Disconnect()
		end)

		CameraConnection =
			nil
	end

	local Humanoid =
		GetHumanoid()

	if Humanoid then
		pcall(function()
			Humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Seated,
				true
			)

			Humanoid.Sit =
				false

			Humanoid.PlatformStand =
				false
		end)
	end

	ManualNoclip =
		false

	SafeCloseCall(
		RestoreCollision
	)

	if CollisionConnection then
		pcall(function()
			CollisionConnection:Disconnect()
		end)

		CollisionConnection =
			nil
	end

	-- Destroying dispara os cleanups das funções que usam
	-- Gui.Destroying (AntiLag, StaffWatch, Swim, veículos etc.).
	-- Este passo fica no fim e não depende de nenhuma limpeza anterior.
	pcall(function()
		if
			Gui
			and
			Gui.Parent
		then
			Gui:Destroy()
		end
	end)

	CartolaPanicRegistry =
		nil

end)


--============================================================
-- ORDEM VISUAL DAS ABAS
--============================================================

do
	local function OrganizePage(
		Page,
		GroupOrder
	)

		if not Page then
			return
		end

		local CurrentGroup =
			9000

		local Sequence =
			0

		for _, Child in ipairs(
			Page:GetChildren()
		) do

			if
				not Child:IsA("UIListLayout")
				and
				not Child:IsA("UIPadding")
			then

				if
					Child:IsA("TextLabel")
					and
					GroupOrder[Child.Text]
				then

					CurrentGroup =
						GroupOrder[Child.Text]

					Sequence =
						0

				end

				Child.LayoutOrder =
					CurrentGroup
					+
					Sequence

				Sequence +=
					1

			end

		end

	end

	-- Créditos: página própria, como antes.
	OrganizePage(
		Credits,
		{
			["Créditos"] = 1000
		}
	)

	-- OP.
	OrganizePage(
		OP,
		{
			["Presente Infinito"] = 1000,
			["Bomba Infinita"] = 2000,
			["WalkFling"] = 3000
		}
	)

	-- Alvo.
	OrganizePage(
		Principal,
		{
			["Bring Parts no Player"] = 1000,
			["Dart"] = 2000,
			["Fling"] = 3000,
			["HeadSit"] = 4000,
			["Itens do Player"] = 5000,
			["Órbita no Player"] = 6000
		}
	)

	-- Jogador.
	OrganizePage(
		Pages["Jogador"],
		{
			["Personagem"] = 1000,
			["Fly"] = 2000,
			["CFly"] = 3000,
			["FlyFling"] = 4000
		}
	)

	-- Movimento.
	OrganizePage(
		Pages["Movimento"],
		{
			["Movimento"] = 1000,
			["Posições salvas"] = 2000
		}
	)

	-- Visual.
	OrganizePage(
		Pages["Visual"],
		{
			["View / Spectate"] = 1000,
			["ESP"] = 2000,
			["Iluminação"] = 3000,
			["Freecam"] = 4000,
			["Câmera"] = 5000
		}
	)

	-- Casa.
	OrganizePage(
		Casa,
		{
			["Casa"] = 1000
		}
	)

	-- Veículos.
	OrganizePage(
		Veiculos,
		{
			["Veículos"] = 1000,
			["Loop do Veículo"] = 2000,
			["Puxar para Assento"] = 3000,
			["VFly"] = 4000
		}
	)

	-- Utilidades.
	OrganizePage(
		Ferramentas,
		{
			["Desempenho"] = 1000,
			["Servidor"] = 2000,
			["Efeitos"] = 2400,
			["Interface"] = 2500,
			["Monitoramento"] = 3000,
			["Emergência"] = 4000,
			["Áudio"] = 5000
		}
	)

	-- Scripts.
	OrganizePage(
		Pages["Scripts"],
		{
			["Scripts"] = 1000
		}
	)

end

--============================================================
-- INIT
--============================================================

pcall(function()
	local BootStatus =
		OP:FindFirstChild(
			"CartolaFastBootStatus"
		)

	if BootStatus then
		BootStatus:Destroy()
	end
end)

OpenPage("OP")

ConnectCamera()

Responsive()
