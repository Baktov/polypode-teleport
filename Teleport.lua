-- Polypode Teleport: Teleport — téléports de l'équipe : état de chacun, synchro, boutons sécurisés, fenêtre

local _, ns = ...
local P = Polypode -- dépendance obligatoire (## Dependencies: Polypode), chargée avant nous
local L = ns.L

-- Une ligne par destination (Destinations.lua), une colonne par membre de l'équipe sélectionnée :
-- prêt, temps de recharge restant, ou rien. Chaque client choisit SON meilleur moyen pour chaque
-- destination (premier prêt dans l'ordre de la table) et le pose sur un bouton sécurisé nommé
-- PolypodeTeleport_<id> : un clic sur la ligne, la touche « Pierre de foyer » (Bindings.xml) ou une
-- macro /click PolypodeTeleport_<id> diffusée à toutes les fenêtres fait partir chacun avec son
-- propre moyen. Lancer un sort ou un objet pour une autre fenêtre est impossible (fonction protégée) :
-- les autres colonnes ne font qu'afficher l'état reçu.
-- Combat : les attributs des boutons sécurisés ne peuvent pas changer ; la fenêtre, dont les lignes
-- portent des boutons sécurisés, se ferme à l'entrée en combat (PLAYER_REGEN_DISABLED, avant le
-- verrouillage) et ne s'ouvre pas en combat ; les mises à jour attendent la fin du combat.
-- Synchro : TELE:token:flag:envoi:nom-royaume:entrées:foyer — flag N = premier fragment (remplace
-- l'état), + = suite ; envoi = compteur de l'expéditeur ; entrées « id,secondes,moyen » séparées
-- par « ; » (secondes = recharge restante, 0 = prêt, -1 = illisible ; moyen = rang dans la table) ;
-- foyer = lieu de lien (premier fragment seulement, en dernier : peut contenir « : »).
-- Demande : un clic sur une ligne envoie TELEGO:token:nom-royaume:destination aux autres clients ;
-- chez les membres de la même équipe, la fenêtre s'ouvre sur cette seule ligne, prête à cliquer
-- (fermer puis rouvrir la fenêtre rend le tableau complet). Reçue en combat : ouverte à la fin du
-- combat si elle a moins de REQUEST_EXPIRY secondes.

local MESSAGE_TYPE = "TELE"
local REQUEST_TYPE = "TELEGO"
local REQUEST_EXPIRY = 60
local UPDATE_DELAY = 2 -- secondes : regroupe les événements rapprochés (recharges, sacs)
local GCD_MARGIN = 2 -- une recharge de 2 s ou moins est la recharge globale : compté comme prêt
local TICK = 1 -- secondes entre deux rafraîchissements des cases, fenêtre ouverte
local NAME_WIDTH = 180
local COLUMN_WIDTH = 80 -- largeur d'une colonne tant que la fenêtre n'a pas été retaillée
local COLUMN_MIN, COLUMN_MAX = 60, 140
local FIXED_WIDTH = 66 -- marges du cadre et du panneau, barre de défilement
local LIST_TOP = 46 -- sous l'en-tête du cadre et la ligne des noms
local FRAME_HEIGHT = 420
local MIN_WIDTH, MIN_HEIGHT = 380, 160

local GREEN, YELLOW, GRAY, ORANGE = "|cff33dd33", "|cffffd200", "|cff808080", "|cffff8000"

local own = { dest = {}, bind = "" } -- personnage joué : dest[id] = { kind, value, source, ready }
local peers = {} -- [nom-royaume] = { seq, bind, dest = { [id] = { source, ready } } } (session)
local secureButtons = {} -- [id] = bouton sécurisé PolypodeTeleport_<id>
local labels = {} -- [id] = libellé de la destination (nom du jeu, mis en cache)
local columns = {} -- clés des personnages affichés en colonnes
local headers = {} -- textes des noms au-dessus des colonnes
local columnWidth = COLUMN_WIDTH
local requested -- { from = clé, id = destination } : fenêtre ouverte sur la demande d'un membre
local pendingRequest -- demande reçue en combat : { from, id, time }
local lastSignature, sendSeq = nil, 0
local updatePending, refreshPending, waitingCombatEnd
local frame, listPanel

-- LECTURE DU PERSONNAGE JOUÉ ------------------------------------------------------------------

local function IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value)
end

-- Secondes de recharge restantes (début et durée en GetTime), 0 si prêt, nil si illisible.
local function Remaining(start, duration)
	if start == nil or duration == nil or IsSecret(start) or IsSecret(duration) then
		return nil
	end
	if start <= 0 or duration <= GCD_MARGIN then
		return 0
	end
	return math.max(0, start + duration - GetTime())
end

local function SpellKnown(spellID)
	return C_SpellBook.IsSpellKnown(spellID) == true
end

local function SpellRemaining(spellID)
	local info = C_Spell.GetSpellCooldown(spellID)
	return info and Remaining(info.startTime, info.duration) or 0
end

local function ItemCount(itemID)
	return C_Item.GetItemCount(itemID) or 0
end

-- Même lecture pour un objet et un jouet (numéro d'objet).
local function ItemRemaining(itemID)
	return Remaining(C_Container.GetItemCooldown(itemID))
end

local function HasToy(itemID)
	if not (PlayerHasToy and PlayerHasToy(itemID)) then
		return false
	end
	return not (C_ToyBox and C_ToyBox.IsToyUsable and C_ToyBox.IsToyUsable(itemID) == false)
end

-- Moyen possédé : type d'action du bouton sécurisé (spell, toy, item), valeur, recharge restante.
-- Un jouet absent de la collection peut être un objet dans les sacs (WoW Forever).
local function EvaluateSource(source)
	if source.spell then
		if SpellKnown(source.spell) then
			return "spell", source.spell, SpellRemaining(source.spell)
		end
	elseif source.toy then
		if HasToy(source.toy) then
			return "toy", source.toy, ItemRemaining(source.toy)
		elseif ItemCount(source.toy) > 0 then
			return "item", source.toy, ItemRemaining(source.toy)
		end
	elseif source.item and ItemCount(source.item) > 0 then
		return "item", source.item, ItemRemaining(source.item)
	end
end

-- Meilleur moyen de chaque destination : le premier prêt dans l'ordre de la table, sinon celui
-- qui sera prêt le plus tôt. ready = heure serveur où il sera prêt (nil : recharge illisible).
local function ComputeOwn()
	local now = GetServerTime()
	local dest = {}
	for _, destination in ipairs(ns.DESTINATIONS) do
		local best, bestRemaining
		for index, source in ipairs(destination.sources) do
			local kind, value, remaining = EvaluateSource(source)
			if kind then
				if remaining == 0 then
					best, bestRemaining = { kind = kind, value = value, source = index }, 0
					break
				end
				if not best or (remaining and (not bestRemaining or remaining < bestRemaining)) then
					best, bestRemaining = { kind = kind, value = value, source = index }, remaining
				end
			end
		end
		if best then
			best.ready = bestRemaining and now + math.ceil(bestRemaining) or nil
		end
		dest[destination.id] = best
	end
	own.dest = dest
	own.bind = GetBindLocation and GetBindLocation() or ""
end

-- BOUTONS SÉCURISÉS -----------------------------------------------------------------------------

-- Un bouton par destination, créé hors combat, sans taille ni position (jamais visible) : cliqué
-- par les lignes de la fenêtre, la touche de Bindings.xml ou /click PolypodeTeleport_<id>.
-- useOnKeyDown faux : il agit au relâchement, ce que donnent aussi /click et le délégué « click ».
local function CreateSecureButtons()
	for _, destination in ipairs(ns.DESTINATIONS) do
		local button = CreateFrame("Button", "PolypodeTeleport_" .. destination.id, UIParent,
			"SecureActionButtonTemplate")
		button:RegisterForClicks("AnyUp", "AnyDown")
		button:SetAttribute("useOnKeyDown", false)
		secureButtons[destination.id] = button
	end
end

-- Pose sur chaque bouton le meilleur moyen du personnage joué (hors combat seulement).
local function UpdateSecureButtons()
	if InCombatLockdown() then
		waitingCombatEnd = true
		return
	end
	for id, button in pairs(secureButtons) do
		local state = own.dest[id]
		local kind, value = state and state.kind, state and state.value
		if button.kind ~= kind or button.value ~= value then
			button:SetAttribute("type", kind)
			button:SetAttribute("spell", kind == "spell" and value or nil)
			button:SetAttribute("toy", kind == "toy" and value or nil)
			button:SetAttribute("item", kind == "item" and ("item:" .. value) or nil)
			button.kind, button.value = kind, value
		end
	end
end

-- SYNCHRO ---------------------------------------------------------------------------------------

-- Entrées « id,secondes,moyen » des destinations possédées.
local function BuildEntries()
	local now = GetServerTime()
	local entries = {}
	for _, destination in ipairs(ns.DESTINATIONS) do
		local state = own.dest[destination.id]
		if state then
			local seconds = state.ready and math.max(0, state.ready - now) or -1
			entries[#entries + 1] = string.format("%s,%d,%d", destination.id, seconds, state.source)
		end
	end
	return entries
end

-- Résumé de l'état, pour n'envoyer qu'un changement (recharges arrondies à 10 s).
local function Signature()
	local parts = { own.bind }
	for _, destination in ipairs(ns.DESTINATIONS) do
		local state = own.dest[destination.id]
		if state then
			parts[#parts + 1] = destination.id .. state.source .. (state.ready and math.floor(state.ready / 10) or "?")
		end
	end
	return table.concat(parts, ";")
end

-- Envoie l'état du personnage joué à target, sinon aux clients connectés, en fragments de
-- P.MAX_MESSAGE_LENGTH octets au plus.
local function SendOwn(target)
	local token = P.GetTeamToken and P.GetTeamToken()
	if not token or not P.WhisperOnline then
		return
	end
	sendSeq = sendSeq + 1
	local key = P.GetCharKey()
	local entries = BuildEntries()
	local limit = P.MAX_MESSAGE_LENGTH or 255
	local flag, index = "N", 1
	repeat
		local bind = flag == "N" and own.bind or ""
		local head = string.format("%s:%s:%s:%d:%s:", MESSAGE_TYPE, token, flag, sendSeq, key)
		local budget = limit - #head - #bind - 1
		local parts, size = {}, 0
		while index <= #entries and size + #entries[index] + 1 <= budget do
			parts[#parts + 1] = entries[index]
			size = size + #entries[index] + 1
			index = index + 1
		end
		P.WhisperOnline(head .. table.concat(parts, ";") .. ":" .. bind, target)
		if #parts == 0 then
			break -- rien n'entre (lieu de lien démesuré) : ne pas boucler
		end
		flag = "+"
	until index > #entries
end

local function ScheduleRefresh()
	if refreshPending then
		return
	end
	refreshPending = true
	C_Timer.After(0.2, function()
		refreshPending = nil
		P.RefreshTeleport()
	end)
end

-- Message reçu (token déjà vérifié par Polypode) : rest = « flag:envoi:nom-royaume:entrées:foyer ».
local function OnMessage(rest, sender)
	local flag, seq, key, entries, bind = strsplit(":", rest or "", 5)
	if not key or not (P.IsSender and P.IsSender(sender, key)) then
		return
	end
	local peer = peers[key]
	if flag == "N" then
		peer = { seq = seq, bind = bind or "", dest = {} }
		peers[key] = peer
	elseif not peer or peer.seq ~= seq then
		return -- suite d'un envoi dont le début manque
	end
	local now = GetServerTime()
	for entry in (entries or ""):gmatch("[^;]+") do
		local id, secondsText, source = strsplit(",", entry)
		local seconds = tonumber(secondsText)
		if ns.DESTINATION_BY_ID[id] and seconds then
			peer.dest[id] = { source = tonumber(source), ready = seconds >= 0 and now + seconds or nil }
		end
	end
	ScheduleRefresh()
end

-- Relit le personnage joué, met à jour les boutons et prévient les autres clients s'il a changé.
local function UpdateOwn()
	if InCombatLockdown() then
		waitingCombatEnd = true
		return
	end
	ComputeOwn()
	UpdateSecureButtons()
	local signature = Signature()
	if signature ~= lastSignature then
		lastSignature = signature
		SendOwn()
	end
	ScheduleRefresh()
end

local function ScheduleUpdate()
	if updatePending then
		return
	end
	updatePending = true
	C_Timer.After(UPDATE_DELAY, function()
		updatePending = nil
		UpdateOwn()
	end)
end

-- Demande aux autres clients d'ouvrir la ligne de la destination (filtrés à la réception).
local function SendRequest(id)
	local token = P.GetTeamToken and P.GetTeamToken()
	if token and P.WhisperOnline then
		P.WhisperOnline(string.format("%s:%s:%s:%s", REQUEST_TYPE, token, P.GetCharKey(), id))
	end
end

-- FENÊTRE ---------------------------------------------------------------------------------------

-- Taille de la fenêtre, gardée dans PolypodeTeleportDB.window (largeur absente : ajustée aux colonnes).
local function WindowSettings()
	PolypodeTeleportDB = PolypodeTeleportDB or {}
	PolypodeTeleportDB.window = PolypodeTeleportDB.window or {}
	return PolypodeTeleportDB.window
end

-- Colonnes : membres de l'équipe sélectionnée, leader en tête (personnage joué devant s'il n'en
-- est pas) ; le seul personnage joué en mode solo ou sans équipe.
local function ColumnKeys()
	local me = P.GetCharKey()
	local team = not (P.IsSoloMode and P.IsSoloMode()) and P.GetSelectedTeam and P.GetSelectedTeam()
	local members = team and P.GetTeamMembers(team)
	if not members or not next(members) then
		return { me }
	end
	local leader = P.GetTeamLeader(team)
	local keys = {}
	if not members[me] then
		keys[1] = me
	end
	for _, item in ipairs(P.SortedKeyItems(members, function(key)
		return key == leader
	end)) do
		keys[#keys + 1] = item.key
	end
	return keys
end

-- État d'une destination pour un personnage, et vrai si on a reçu ses données.
local function StateOf(key, id)
	if key == P.GetCharKey() then
		return own.dest[id], true
	end
	local peer = peers[key]
	return peer and peer.dest[id], peer ~= nil
end

local function BindOf(key)
	if key == P.GetCharKey() then
		return own.bind
	end
	return peers[key] and peers[key].bind
end

local function FormatDuration(seconds)
	if seconds < 60 then
		return L["%d s"]:format(seconds)
	elseif seconds < 3600 then
		return L["%d min"]:format(math.ceil(seconds / 60))
	end
	return L["%d h %02d"]:format(math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
end

-- Texte d'une case : prêt, recharge restante, rien (-), ou inconnu (?).
local function CellText(state, known)
	if not known then
		return GRAY .. "?|r"
	elseif not state then
		return GRAY .. "-|r"
	elseif not state.ready then
		return YELLOW .. "?|r"
	end
	local seconds = state.ready - GetServerTime()
	if seconds <= 0 then
		return GREEN .. L["Prêt"] .. "|r"
	end
	return YELLOW .. FormatDuration(seconds) .. "|r"
end

-- Nom d'un moyen (nom du jeu) ; nil tant que les données de l'objet ne sont pas chargées.
local function SourceName(source)
	if not source then
		return nil
	end
	if source.spell then
		return C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(source.spell)
	end
	local itemID = source.item or source.toy
	local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
	if not name and C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(itemID) -- ITEM_DATA_LOAD_RESULT rafraîchit la fenêtre
	end
	return name
end

-- Libellé d'une destination : nom de son premier moyen, sans le préfixe « Téléportation : »...
local function DestinationLabel(destination)
	if destination.hearth then
		return L["Pierre de foyer"]
	end
	if not labels[destination.id] then
		local name = SourceName(destination.sources[1])
		if not name then
			return destination.id
		end
		labels[destination.id] = name:match("^[^:]+:%s*(.+)$") or name
	end
	return labels[destination.id]
end

-- Lignes : lieu de lien, puis les destinations qu'au moins un personnage affiché possède ; sur
-- demande d'un membre, la seule destination demandée (et le lieu de lien pour la pierre de foyer).
local function BuildItems()
	if requested then
		local hearth = ns.DESTINATION_BY_ID[requested.id].hearth
		return hearth and { { bind = true }, { id = requested.id } } or { { id = requested.id } }
	end
	local items = { { bind = true } }
	for _, destination in ipairs(ns.DESTINATIONS) do
		for _, key in ipairs(columns) do
			if StateOf(key, destination.id) then
				items[#items + 1] = { id = destination.id }
				break
			end
		end
	end
	return items
end

local function FormatItem(item)
	if item.bind then
		return YELLOW .. L["Lié à"] .. "|r"
	end
	local state = own.dest[item.id]
	local label = DestinationLabel(ns.DESTINATION_BY_ID[item.id])
	if state and state.ready and state.ready <= GetServerTime() then
		return label
	end
	return GRAY .. label .. "|r" -- pas utilisable par le personnage joué pour l'instant
end

local function ShowRowTooltip(row)
	local data = row.data
	if not data then
		return
	end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	if data.bind then
		GameTooltip:AddLine(L["Lieu de lien de la pierre de foyer"])
		for _, key in ipairs(columns) do
			local bind = BindOf(key)
			GameTooltip:AddDoubleLine(P.GetDisplayName(key), bind and bind ~= "" and bind or "?", 1, 1, 1, 1, 1, 1)
		end
		GameTooltip:AddLine(L["En orange : lié ailleurs que le premier personnage de l'équipe."], 0.6, 0.6, 0.6, true)
	else
		local destination = ns.DESTINATION_BY_ID[data.id]
		GameTooltip:AddLine(DestinationLabel(destination))
		for _, key in ipairs(columns) do
			local state, known = StateOf(key, data.id)
			local right = CellText(state, known)
			local name = state and SourceName(destination.sources[state.source or 0])
			if name then
				right = right .. "  " .. GRAY .. name .. "|r"
			end
			GameTooltip:AddDoubleLine(P.GetDisplayName(key), right, 1, 1, 1, 1, 1, 1)
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Clic : utiliser votre meilleur moyen."], 1, 1, 1, true)
		if not requested and #columns > 1 then
			GameTooltip:AddLine(L["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."], 1, 1, 1, true)
		end
		GameTooltip:AddLine(L["Macro pour toutes les fenêtres : %s"]:format("/click PolypodeTeleport_" .. data.id),
			0.6, 0.6, 0.6, true)
	end
	P.ShowTooltip()
end

-- Habille une ligne : cases des colonnes et bouton sécurisé qui délègue au bouton de la
-- destination (attribut posé hors combat seulement : la fenêtre est fermée en combat).
local function DecorateRow(row, data)
	row.text:SetPoint("RIGHT", row, "LEFT", NAME_WIDTH - 6, 0)
	row.text:SetText(FormatItem(data))
	row.cells = row.cells or {}
	local reference = BindOf(columns[1])
	for i, key in ipairs(columns) do
		local cell = row.cells[i]
		if not cell then
			cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			cell:SetJustifyH("CENTER")
			cell:SetWordWrap(false)
			row.cells[i] = cell
		end
		cell:SetWidth(columnWidth - 4)
		cell:ClearAllPoints()
		cell:SetPoint("LEFT", row, "LEFT", NAME_WIDTH + (i - 1) * columnWidth, 0)
		if data.bind then
			local bind = BindOf(key)
			if not bind or bind == "" then
				cell:SetText(GRAY .. "?|r")
			elseif reference and reference ~= "" and bind ~= reference then
				cell:SetText(ORANGE .. bind .. "|r")
			else
				cell:SetText(bind)
			end
		else
			cell:SetText(CellText(StateOf(key, data.id)))
		end
		cell:Show()
	end
	for i = #columns + 1, #row.cells do
		row.cells[i]:Hide()
	end

	if InCombatLockdown() then
		return
	end
	if not row.cast then
		local cast = CreateFrame("Button", nil, row, "SecureActionButtonTemplate")
		cast:SetAllPoints()
		cast:RegisterForClicks("AnyUp")
		cast:SetAttribute("type", "click")
		local highlight = cast:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints()
		highlight:SetColorTexture(1, 1, 1, 0.08)
		cast:SetScript("OnEnter", function()
			ShowRowTooltip(row)
		end)
		cast:SetScript("OnLeave", GameTooltip_Hide)
		-- Après l'action sécurisée : demande aux autres fenêtres, ou fermeture de la fenêtre ouverte
		-- sur demande quand le téléport était prêt.
		cast:HookScript("OnClick", function()
			local clicked = row.data
			if not clicked or clicked.bind then
				return
			end
			if not requested then
				SendRequest(clicked.id)
				return
			end
			local state = own.dest[clicked.id]
			if state and state.ready and state.ready <= GetServerTime() then
				C_Timer.After(0, function()
					if frame:IsShown() and not InCombatLockdown() then
						frame:Hide()
					end
				end)
			end
		end)
		row.cast = cast
	end
	row.cast:SetAttribute("clickbutton", not data.bind and secureButtons[data.id] or nil)
	if GameTooltip:IsOwned(row) then
		ShowRowTooltip(row)
	end
end

-- Largeur des colonnes et noms au-dessus de la liste. Tant que la fenêtre n'a pas été retaillée,
-- sa largeur suit le nombre de colonnes ; ensuite les colonnes se partagent la largeur choisie.
local function LayoutColumns()
	local count = math.max(1, #columns)
	local minWidth = math.max(MIN_WIDTH, FIXED_WIDTH + NAME_WIDTH + count * COLUMN_MIN)
	frame:SetResizeBounds(minWidth, MIN_HEIGHT)
	if not WindowSettings().width then
		frame:SetWidth(math.max(MIN_WIDTH, FIXED_WIDTH + NAME_WIDTH + count * COLUMN_WIDTH))
	elseif frame:GetWidth() < minWidth then
		frame:SetWidth(minWidth)
	end
	columnWidth = math.min(COLUMN_MAX, (frame:GetWidth() - FIXED_WIDTH - NAME_WIDTH) / count)
	for i, key in ipairs(columns) do
		local header = headers[i]
		if not header then
			header = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			header:SetJustifyH("CENTER")
			header:SetWordWrap(false)
			headers[i] = header
		end
		header:SetWidth(columnWidth - 4)
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 10 + NAME_WIDTH + (i - 1) * columnWidth, -28)
		local entry = P.db.roster[key]
		local color = entry and entry.class and RAID_CLASS_COLORS[entry.class]
		local name = (P.GetDisplayName(key):match("^%S+")) or key
		header:SetText(color and color:WrapTextInColorCode(name) or name)
		header:Show()
	end
	for i = #columns + 1, #headers do
		headers[i]:Hide()
	end
end

local function RedecorateRows()
	listPanel.scrollBox:ForEachFrame(function(row)
		if row.data then
			DecorateRow(row, row.data)
		end
	end)
end

local function Build()
	local settings = WindowSettings()
	frame = CreateFrame("Frame", "PolypodeTeleportFrame", UIParent, "BackdropTemplate")
	frame:SetSize(math.max(settings.width or MIN_WIDTH, MIN_WIDTH), math.max(settings.height or FRAME_HEIGHT, MIN_HEIGHT))
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.9)
	frame:Hide()
	tinsert(UISpecialFrames, "PolypodeTeleportFrame") -- Échap ferme la fenêtre
	frame:SetScript("OnHide", function()
		requested = nil -- rouverte, la fenêtre montre de nouveau le tableau complet
	end)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -14)
	title:SetText(L["Polypode Téléports"])
	frame.TitleText = title

	local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -4, -4)
	frame.CloseButton = closeBtn

	listPanel = P.CreatePanel(frame, L["Téléports de l'équipe"])
	listPanel:SetPoint("TOPLEFT", 12, -36)
	listPanel:SetPoint("BOTTOMRIGHT", -12, 12)
	P.CreateScrollList(listPanel, FormatItem, LIST_TOP, { decorate = DecorateRow })

	-- Recharges qui défilent : cases relues chaque seconde (OnUpdate : fenêtre visible seulement).
	local sinceTick = 0
	listPanel:SetScript("OnUpdate", function(_, elapsed)
		sinceTick = sinceTick + elapsed
		if sinceTick < TICK or InCombatLockdown() then
			return
		end
		sinceTick = 0
		ComputeOwn()
		UpdateSecureButtons()
		RedecorateRows()
	end)

	-- Poignée de redimensionnement (coin bas-droit), taille gardée dans PolypodeTeleportDB.window.
	local grip = CreateFrame("Button", nil, frame)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", -2, 2)
	grip:SetFrameLevel(frame:GetFrameLevel() + 10)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetScript("OnMouseDown", function()
		frame:StartSizing("BOTTOMRIGHT")
	end)
	grip:SetScript("OnMouseUp", function()
		frame:StopMovingOrSizing()
		local current = WindowSettings()
		current.width, current.height = frame:GetSize()
	end)
	frame.resizeGrip = grip
	-- Double-clic sur la barre de titre : taille par défaut, largeur de nouveau ajustée aux colonnes.
	if P.EnableTitleDoubleClick then
		P.EnableTitleDoubleClick(frame, function()
			local current = WindowSettings()
			current.width, current.height = nil, nil
			frame:SetHeight(FRAME_HEIGHT)
			P.RefreshTeleport()
		end)
	end
	frame:SetScript("OnSizeChanged", function()
		if frame:IsShown() and not InCombatLockdown() then
			LayoutColumns()
			RedecorateRows()
		end
	end)

	P.ui.teleportFrame = frame
	P.ui.teleportPanel = listPanel
	if P.SkinFrame then
		P.SkinFrame(frame)
	end
	if P.SkinPanel then
		P.SkinPanel(listPanel)
	end
end

-- Reconstruit colonnes et lignes, si la fenêtre est ouverte (jamais en combat).
function P.RefreshTeleport()
	if not frame or not frame:IsShown() or InCombatLockdown() then
		return
	end
	columns = ColumnKeys()
	frame.TitleText:SetText(requested and L["Demande de %s"]:format(P.GetDisplayName(requested.from))
		or L["Polypode Téléports"])
	LayoutColumns()
	P.SetListData(listPanel, BuildItems())
end

-- Ouvre la fenêtre sur la seule destination demandée par un membre de l'équipe.
local function OpenRequest(key, id)
	if not next(secureButtons) then
		return
	end
	if not frame then
		Build()
	end
	requested = { from = key, id = id }
	ComputeOwn()
	UpdateSecureButtons()
	frame:Show()
	P.RefreshTeleport()
end

-- Demande reçue (token déjà vérifié par Polypode) : rest = « nom-royaume:destination ». Retenue
-- seulement si l'expéditeur est une colonne de notre fenêtre (même équipe).
local function OnRequest(rest, sender)
	local key, id = strsplit(":", rest or "", 2)
	if not (key and id and ns.DESTINATION_BY_ID[id] and P.IsSender and P.IsSender(sender, key)) then
		return
	end
	if key == P.GetCharKey() or not tContains(ColumnKeys(), key) then
		return
	end
	if InCombatLockdown() then
		pendingRequest = { from = key, id = id, time = GetTime() }
		return
	end
	OpenRequest(key, id)
end

-- Ouvre / ferme la fenêtre (bouton « Téléports », /poly teleport).
function P.ToggleTeleport()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(L["Téléports : impossible en combat."], 1, 0.1, 0.1)
		return
	end
	if not frame then
		Build()
	end
	if frame:IsShown() then
		frame:Hide()
		return
	end
	ComputeOwn()
	UpdateSecureButtons()
	frame:Show()
	P.RefreshTeleport()
end

-- INTÉGRATION À POLYPODE ------------------------------------------------------------------------

ns.OnLanguageApplied(function()
	BINDING_HEADER_POLYPODETELEPORT = L["Polypode Téléports"]
	_G["BINDING_NAME_CLICK PolypodeTeleport_hearth:LeftButton"] = L["Pierre de foyer (votre meilleur moyen)"]
	if P.AddTitleButton then
		P.AddTitleButton({
			text = L["Téléports"], -- nom du module traduit (MODULES.md, « Langues »)
			width = 80,
			onClick = function()
				P.ToggleTeleport()
			end,
			tooltip = { L["Polypode Téléports"],
				L["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] },
			onCreate = function(button)
				P.ui.teleportButton = button
			end,
		})
	end
	if P.RegisterSlashCommand then
		P.RegisterSlashCommand("teleport", P.ToggleTeleport, L["téléports de l'équipe"])
		P.RegisterSlashCommand("tp", P.ToggleTeleport)
	end
end)

if P.RegisterMessageHandler then
	P.RegisterMessageHandler(MESSAGE_TYPE, OnMessage)
	P.RegisterMessageHandler(REQUEST_TYPE, OnRequest)
	P.RegisterPeerCallback(function(sender)
		SendOwn(sender) -- un client s'annonce : il reçoit notre état
	end)
end

-- Polypode rafraîchit sa fenêtre (équipe sélectionnée, roster) : la nôtre suit.
if P.RefreshUI then
	hooksecurefunc(P, "RefreshUI", function()
		P.RefreshTeleport()
	end)
end

-- ÉVÉNEMENTS ------------------------------------------------------------------------------------

local CHANGE_EVENTS = {
	"PLAYER_ENTERING_WORLD", "SPELLS_CHANGED", "BAG_UPDATE_DELAYED", "TOYS_UPDATED",
	"HEARTHSTONE_BOUND", "SPELL_UPDATE_COOLDOWN", "BAG_UPDATE_COOLDOWN",
}

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("ITEM_DATA_LOAD_RESULT")
for _, event in ipairs(CHANGE_EVENTS) do
	events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		if InCombatLockdown() then
			waitingCombatEnd = true -- /reload en combat : boutons créés à la fin du combat
		else
			CreateSecureButtons()
			ScheduleUpdate()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- Entrée en combat, avant le verrouillage : la fenêtre (boutons sécurisés) se ferme.
		if frame and frame:IsShown() then
			frame:Hide()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if waitingCombatEnd then
			waitingCombatEnd = nil
			if not next(secureButtons) then
				CreateSecureButtons()
			end
			ScheduleUpdate()
		end
		local request = pendingRequest
		pendingRequest = nil
		if request and GetTime() - request.time <= REQUEST_EXPIRY then
			OpenRequest(request.from, request.id)
		end
	elseif event == "ITEM_DATA_LOAD_RESULT" then
		if frame and frame:IsShown() then
			ScheduleRefresh()
		end
	elseif next(secureButtons) then
		ScheduleUpdate()
	end
end)
