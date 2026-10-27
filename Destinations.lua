-- Polypode Teleport: Destinations — table des destinations et des moyens d'y aller

local _, ns = ...

-- Une ligne par DESTINATION (pas par objet) : chaque personnage y va par le premier moyen prêt
-- qu'il possède, dans l'ordre de la liste. Ainsi une même touche fait partir toute l'équipe,
-- chacun avec son propre moyen.
--   id       : identifiant court et stable, échangé entre clients (message TELE) et nom du bouton
--              sécurisé PolypodeTeleport_<id> : ne jamais renommer un id publié. Destinations
--              générées : « s<sort> » (menus de sorts), « i<objet> » (objets de téléport).
--   section  : section repliable de la fenêtre (ns.SECTIONS).
--   hearth   : ligne de la pierre de foyer (destination = lieu de lien de chacun, GetBindLocation).
--   housing  : ligne de la maison (Retail).
--   fullName : libellé = nom complet du moyen (objets), sinon sans le préfixe « xxx : ».
--   describe : infobulle avec la description du sort (téléports de donjon : nom du donjon).
--   sources  : { spell = id } (sort connu), { item = id } ou { toy = id } (équivalents : jouet
--              possédé, sinon objet du même numéro dans les sacs), { housing = true } (maison) ;
--              conditions facultatives : faction, class, race (jetons anglais de WoW), usable
--              (fonction).
-- Libellé : nom du premier moyen (nom du jeu, déjà traduit), sans le préfixe « Téléportation : »,
-- « Générateur de trou de ver : »... (Teleport.lua, DestinationLabel). Un numéro inconnu du client
-- ne gêne pas : le moyen n'est jamais possédé. Listes des jouets de foyer, des trous de ver, des
-- objets et des menus de sorts reprises de l'addon TeleportMenu (README, « Crédits »).

-- Sections, dans l'ordre de la fenêtre ; les sections des menus « Chemin du héros » (« path<menu> »)
-- s'ajoutent à l'exécution entre « race » et « item » (AddFlyoutDestinations). collapsed = repliée
-- par défaut (avant tout clic : PolypodeTeleportDB.collapsed).
ns.SECTIONS = {
	{ id = "hearth" },
	{ id = "class" },
	{ id = "race" },
	{ id = "item" },
	{ id = "engineering" },
}

-- Pierres de foyer de congrégation : renom maximal (critère du haut fait « Re-Re-Re-Renommé »)
-- ou congrégation active.
local function Covenant(criteria, covenantID)
	return function()
		local _, _, completed = GetAchievementCriteriaInfo(15646, criteria)
		return completed or (C_Covenants ~= nil and C_Covenants.GetActiveCovenantID() == covenantID)
	end
end

local function DraeneiOnly()
	local _, _, raceID = UnitRace("player")
	return raceID == 11 or raceID == 30
end

-- Jouets de pierre de foyer : même destination et même temps de recharge que la pierre.
local HEARTH_TOYS = {
	{ 54452 }, { 64488 }, { 93672 }, { 142542 }, { 162973 }, { 163045 }, { 163206 }, { 165669 },
	{ 165670 }, { 165802 }, { 166746 }, { 166747 }, { 168907 }, { 172179 },
	{ 180290, Covenant(3, 3) }, -- Faë nocturnes
	{ 182773, Covenant(2, 4) }, -- Nécro-seigneurs
	{ 183716, Covenant(4, 2) }, -- Venthyrs
	{ 184353, Covenant(1, 1) }, -- Kyrians
	{ 188952 }, { 190196 }, { 190237 }, { 193588 }, { 200630 }, { 206195 }, { 208704 }, { 209035 },
	{ 210455, DraeneiOnly }, -- Hologemme draenique
	{ 212337 }, { 228940 }, { 235016 }, { 236687 }, { 245970 }, { 246565 }, { 257736 }, { 263489 },
	{ 263933 }, { 264367 }, { 265100 }, { 281615 },
}

local hearthSources = { { item = 6948 } } -- Pierre de foyer
for _, toy in ipairs(HEARTH_TOYS) do
	hearthSources[#hearthSources + 1] = { toy = toy[1], usable = toy[2] }
end
hearthSources[#hearthSources + 1] = { spell = 556 } -- Rappel astral (chaman), recharge à part

ns.DESTINATIONS = {
	{ id = "hearth", section = "hearth", hearth = true, sources = hearthSources },
	{ id = "home", section = "hearth", housing = true, sources = { { housing = true } } },
	{ id = "garrison", section = "hearth", sources = { { toy = 110560 } } }, -- Pierre de foyer de fief
	{ id = "dalaran", section = "hearth", sources = { { spell = 224869 }, { toy = 140192 } } }, -- Dalaran (Îles Brisées)

	-- Sorts de classe
	{ id = "acherus", section = "class", sources = { { spell = 50977 } } }, -- Porte de la mort (chevalier de la mort)
	{ id = "moonglade", section = "class", sources = { { spell = 18960 } } }, -- Reflet-de-Lune (druide)
	{ id = "dreamway", section = "class", sources = { { spell = 193753 } } }, -- Voie des rêves d'émeraude (druide)
	{ id = "peak", section = "class", sources = { { spell = 126892 } } }, -- Pèlerinage zen (moine)
	{ id = "guardian", section = "class", sources = { { spell = 193759 } } }, -- Salle du Gardien (mage)

	-- Téléportations de mage, des plus récentes aux plus anciennes (les autres sorts des menus de
	-- mage, Lune-d'argent de Midnight par exemple, sont ajoutés par AddFlyoutDestinations)
	{ id = "dornogal", section = "class", sources = { { spell = 446540 } } },
	{ id = "valdrakken", section = "class", sources = { { spell = 395277 } } },
	{ id = "oribos", section = "class", sources = { { spell = 344587 } } },
	{ id = "boralus", section = "class", sources = { { spell = 281403 } } },
	{ id = "dazaralor", section = "class", sources = { { spell = 281404 } } },
	{ id = "stormshield", section = "class", sources = { { spell = 176248 } } },
	{ id = "warspear", section = "class", sources = { { spell = 176242 } } },
	{ id = "vale", section = "class", sources = { { spell = 132621 }, { spell = 132627 } } }, -- Val de l'Éternel printemps
	{ id = "tolbarad", section = "class", sources = { { spell = 88342 }, { spell = 88344 } } },
	{ id = "dalaran_nr", section = "class", sources = { { spell = 53140 } } }, -- Dalaran (Norfendre)
	{ id = "shattrath", section = "class", sources = { { spell = 33690 }, { spell = 35715 } } },
	{ id = "stormwind", section = "class", sources = { { spell = 3561 } } },
	{ id = "ironforge", section = "class", sources = { { spell = 3562 } } },
	{ id = "darnassus", section = "class", sources = { { spell = 3565 } } },
	{ id = "exodar", section = "class", sources = { { spell = 32271 } } },
	{ id = "theramore", section = "class", sources = { { spell = 49359 } } },
	{ id = "orgrimmar", section = "class", sources = { { spell = 3567 } } },
	{ id = "undercity", section = "class", sources = { { spell = 3563 } } },
	{ id = "thunderbluff", section = "class", sources = { { spell = 3566 } } },
	{ id = "silvermoon", section = "class", sources = { { spell = 32272 } } },
	{ id = "stonard", section = "class", sources = { { spell = 49358 } } },

	-- Raciaux
	{ id = "camp", section = "race", sources = { { spell = 312372 } } }, -- Retour au camp (vulpérin)
	{ id = "makecamp", section = "race", sources = { { spell = 312370 } } }, -- Installer le camp (vulpérin)
	{ id = "mole", section = "race", sources = { { spell = 265225 } } }, -- Foreuse (nain sombrefer)
	{ id = "rootwalking", section = "race", sources = { { spell = 1238686 } } }, -- Marche-racine (haranir)

	-- Ingénierie : générateurs de trou de ver et transporteurs
	{ id = "wh_quelthalas", section = "engineering", sources = { { toy = 248485 } } },
	{ id = "wh_khazalgar", section = "engineering", sources = { { toy = 221966 } } },
	{ id = "wh_dragonisles", section = "engineering", sources = { { toy = 198156 } } },
	{ id = "wh_shadowlands", section = "engineering", sources = { { toy = 172924 } } },
	{ id = "wh_kultiras", section = "engineering", sources = { { toy = 168807 } } },
	{ id = "wh_zandalar", section = "engineering", sources = { { toy = 168808 } } },
	{ id = "wh_argus", section = "engineering", sources = { { toy = 151652 } } },
	{ id = "wh_draenor", section = "engineering", sources = { { toy = 112059 } } },
	{ id = "wh_pandaria", section = "engineering", sources = { { toy = 87215 } } },
	{ id = "wh_northrend", section = "engineering", sources = { { toy = 48933 } } },
	{ id = "area52", section = "engineering", sources = { { toy = 30542 } } },
	{ id = "toshley", section = "engineering", sources = { { toy = 30544 } } },
	{ id = "everlook", section = "engineering", sources = { { toy = 18984 } } },
	{ id = "gadgetzan", section = "engineering", sources = { { toy = 18986 } } },
}

-- Objets de téléport (objets ou jouets), une ligne chacun : { numéro, conditions facultatives }.
local ITEMS = {
	{ 32757 }, -- Blessed Medallion of Karabor
	{ 37863 }, -- Direbrew's Remote
	{ 40586 }, -- Band of the Kirin Tor
	{ 44935 }, -- Ring of the Kirin Tor
	{ 40585 }, -- Signet of the Kirin Tor
	{ 44934 }, -- Loop of the Kirin Tor
	{ 45688 }, -- Inscribed Band of the Kirin Tor
	{ 45690 }, -- Inscribed Ring of the Kirin Tor
	{ 45691 }, -- Inscibed Signet of the Kirin Tor
	{ 45689 }, -- Inscribed Loop of the Kirin Tor
	{ 48954 }, -- Etched Band of the Kirin Tor
	{ 48955 }, -- Etched Loop of the Kirin Tor
	{ 48956 }, -- Etched Ring of the Kirin Tor
	{ 48957 }, -- Etched Signet of the Kirin Tor
	{ 51557 }, -- Runed Signet of the Kirin Tor
	{ 51558 }, -- Runed Loop of the Kirin Tor
	{ 51559 }, -- Runed Ring of the Kirin Tor
	{ 51560 }, -- Runed Band of the Kirin Tor
	{ 52251 }, -- Jaina's Locket
	{ 63206, faction = "Alliance" }, -- Wrap of Unity: Stormwind
	{ 63207, faction = "Horde" }, -- Wrap of Unity: Orgrimmar
	{ 63352, faction = "Alliance" }, -- Shroud of Cooperation: Stormwind
	{ 63353, faction = "Horde" }, -- Shroud of Cooperation: Orgrimmar
	{ 65274, faction = "Horde" }, -- Cloak of Coordination: Orgrimmar
	{ 65360, faction = "Alliance" }, -- Cloak of Coordination: Stormwind
	{ 43824 }, -- The Schools of Arcane Magic - Mastery
	{ 46874 }, -- Argent Crusader's Tabard
	{ 50287 }, -- Boots of the Bay
	{ 58487 }, -- Potion of Deepholm
	{ 61379 }, -- Gidwin's Hearthstone
	{ 63378 }, -- Hellscream's Reach Tabard
	{ 63379 }, -- Baradin's Wardens Tabard
	{ 64457 }, -- The Last Relic of Argus
	{ 68808 }, -- Hero's Hearthstone
	{ 68809 }, -- Veteran's Hearthstone
	{ 87548 }, -- Lorewalker's Lodestone
	{ 92510 }, -- Vol'jin's Hearthstone
	{ 95050, faction = "Horde" }, -- The Brassiest Knuckle (Brawl'gar Arena)
	{ 95051, faction = "Alliance" }, -- The Brassiest Knuckle (Bizmo's Brawlpub)
	{ 95567, faction = "Alliance" }, -- Kirin Tor Beacon
	{ 95568, faction = "Horde" }, -- Sunreaver Beacon
	{ 103678 }, -- Time-Lost Artifact
	{ 117389 }, -- Draenor Archaeologist's Lodestone
	{ 118662 }, -- Bladespire Relic
	{ 118663 }, -- Relic of Karabor
	{ 118907, faction = "Alliance" }, -- Pit Fighter's Punching Ring (Bizmo's Brawlpub)
	{ 118908, faction = "Horde" }, -- Pit Fighter's Punching Ring (Brawl'gar Arena)
	{ 119183 }, -- Scroll of Risky Recall
	{ 128353 }, -- Admiral's Compass
	{ 128502 }, -- Hunter's Seeking Crystal
	{ 128503 }, -- Master Hunter's Seeking Crystal
	{ 129276 }, -- Beginner's Guide to Dimensional Rifting
	{ 129929 }, -- Ever-Shifting Mirror
	{ 132119, faction = "Horde" }, -- Orgrimmar Portal Stone
	{ 132120, faction = "Alliance" }, -- Stormwind Portal Stone
	{ 132517 }, -- Intra-Dalaran Wormhole Generator
	{ 132523 }, -- Reaves Battery
	{ 136849, class = "DRUID" }, -- Nature's Beacon (Druid Toy)
	{ 138448 }, -- Emblem of Margoss
	{ 139590 }, -- Scroll of Teleport: Ravenholdt
	{ 139599 }, -- Empowered Ring of the Kirin Tor
	{ 140324 }, -- Mobile Telemancy Beacon
	{ 140493 }, -- Adept's Guide to Dimensional Rifting
	{ 141013 }, -- Scroll of Town Portal: Shala'nir
	{ 141014 }, -- Scroll of Town Portal: Sashj'tar
	{ 141015 }, -- Scroll of Town Portal: Kal'delar
	{ 141016 }, -- Scroll of Town Portal: Faronaar
	{ 141017 }, -- Scroll of Town Portal: Lian'tril
	{ 141324 }, -- Talisman of the Shal'dorei
	{ 141605 }, -- Flight Master's Whistle
	{ 142298 }, -- Astonishingly Scarlet Slippers
	{ 142469 }, -- Violet Seal of the Grand Magus
	{ 142543 }, -- Scroll of Town Portal (Diablo 3 event)
	{ 144341 }, -- Rechargeable Reaves Battery
	{ 144391, faction = "Alliance" }, -- Pugilist's Powerful Punching Ring (Alliance)
	{ 144392, faction = "Horde" }, -- Pugilist's Powerful Punching Ring (Horde)
	{ 150733 }, -- Scroll of Town Portal (Ar'gorok in Arathi)
	{ 151016 }, -- Fractured Necrolyte Skull
	{ 159224 }, -- Zuldazar Hearthstone
	{ 160219 }, -- Scroll of Town Portal (Stromgarde in Arathi)
	{ 163694 }, -- Scroll of Luxurious Recall
	{ 166559 }, -- Commander's Signet of Battle
	{ 166560 }, -- Captain's Signet of Command
	{ 167075 }, -- Ultrasafe Transporter: Mechagon
	{ 168862 }, -- G.E.A.R. Tracking Beacon
	{ 169064 }, -- Montebank's Colorful Cloak
	{ 169297, faction = "Alliance" }, -- Stormpike Insignia
	{ 172203 }, -- Cracked Hearthstone
	{ 173373 }, -- Faol's Hearthstone
	{ 173430 }, -- Nexus Teleport Scroll
	{ 173528 }, -- Gilded Hearthstone
	{ 173532 }, -- Tirisfal Camp Scroll
	{ 173537 }, -- Glowing Hearthstone
	{ 173716 }, -- Mossy Hearthstone
	{ 180817 }, -- Cypher of Relocation (Ve'nari's Refuge)
	{ 181163 }, -- Scroll of Teleport: Theater of Pain
	{ 184500 }, -- Attendant's Pocket Portal: Bastion
	{ 184501 }, -- Attendant's Pocket Portal: Revendreth
	{ 184502 }, -- Attendant's Pocket Portal: Maldraxxus
	{ 184503 }, -- Attendant's Pocket Portal: Ardenweald
	{ 184504 }, -- Attendant's Pocket Portal: Oribos
	{ 189827 }, -- Cartel Xy's Proof of Initiation
	{ 191029 }, -- Lilian's Hearthstone
	{ 193000 }, -- Ring-Bound Hourglass
	{ 200613 }, -- Aylaag Windstone Fragment
	{ 201957 }, -- Thrall's Hearthstone
	{ 202046 }, -- Lucky Tortollan Charm
	{ 204481 }, -- Morqut Hearth Totem
	{ 205255 }, -- Niffen Diggin' Mitts
	{ 205456 }, -- Lost Dragonscale (1)
	{ 205458 }, -- Lost Dragonscale (2)
	{ 211788, race = "Worgen" }, -- Tess's Peacebloom
	{ 230850 }, -- Delve-O-Bot 7001
	{ 234389 }, -- Gallagio Loyalty Rewards Card: Silver
	{ 234390 }, -- Gallagio Loyalty Rewards Card: Gold
	{ 234391 }, -- Gallagio Loyalty Rewards Card: Platinum
	{ 234392 }, -- Gallagio Loyalty Rewards Card: Black
	{ 234393 }, -- Gallagio Loyalty Rewards Card: Diamond
	{ 234394 }, -- Gallagio Loyalty Rewards Card: Legendary
	{ 238727 }, -- Nostwin's Voucher
	{ 243056 }, -- Delver's Mana-Bound Ethergate
	{ 249699 }, -- Shadowguard Translocator
	{ 253629 }, -- Personal Key to the Arcantina
	{ 266370 }, -- Dundun's Abundant Travel Method
	{ 276371 }, -- Lightveil Recall Beacon 12.0.7
}

ns.DESTINATION_BY_ID = {}
ns.SECTION_BY_ID = {}

-- Ajoute une destination (sauf si son id existe déjà).
function ns.AddDestination(destination)
	if ns.DESTINATION_BY_ID[destination.id] then
		return
	end
	ns.DESTINATIONS[#ns.DESTINATIONS + 1] = destination
	ns.DESTINATION_BY_ID[destination.id] = destination
end

for _, destination in ipairs(ns.DESTINATIONS) do
	ns.DESTINATION_BY_ID[destination.id] = destination
end
for _, section in ipairs(ns.SECTIONS) do
	ns.SECTION_BY_ID[section.id] = section
end
for _, entry in ipairs(ITEMS) do
	entry.item, entry[1] = entry[1], nil
	ns.AddDestination({ id = "i" .. entry.item, section = "item", fullName = true, sources = { entry } })
end

-- Menus de sorts du grimoire (numéro de menu) : téléportations de mage, et « Chemin du héros »
-- (donjons et raids, un menu par extension, du plus récent au plus ancien).
local MAGE_FLYOUTS = { 1, 8 }
local PATH_FLYOUTS = { 246, 242, 232, 231, 227, 222, 220, 223, 224, 96, 84, 230 }
local CURRENT_PATH = 246 -- seule section de donjons dépliée par défaut

-- Sorts déjà couverts par une destination fixe (mage) : pas de doublon.
local function CoveredSpells()
	local spells = {}
	for _, destination in ipairs(ns.DESTINATIONS) do
		for _, source in ipairs(destination.sources) do
			if source.spell then
				spells[source.spell] = true
			end
		end
	end
	return spells
end

-- Ajoute les sorts des menus (tous, connus ou non : mêmes destinations chez tous les clients) et
-- une section par menu de donjons. Sans effet sur un client sans ces menus (WoW Forever) ;
-- relancé à chaque SPELLS_CHANGED (menus pas forcément chargés à la connexion). Vrai si ajout.
function ns.AddFlyoutDestinations()
	if not (GetFlyoutInfo and GetFlyoutSlotInfo) then
		return false
	end
	local count = #ns.DESTINATIONS
	local covered = CoveredSpells()
	local function AddFlyout(flyoutID, sectionID, describe)
		local _, _, numSlots = GetFlyoutInfo(flyoutID)
		for slot = 1, numSlots or 0 do
			local spellID = GetFlyoutSlotInfo(flyoutID, slot)
			if spellID and not covered[spellID] then
				covered[spellID] = true
				ns.AddDestination({ id = "s" .. spellID, section = sectionID, describe = describe,
					sources = { { spell = spellID } } })
			end
		end
	end
	for _, flyoutID in ipairs(MAGE_FLYOUTS) do
		AddFlyout(flyoutID, "class")
	end
	local function IndexOf(sectionID)
		for index, section in ipairs(ns.SECTIONS) do
			if section.id == sectionID then
				return index
			end
		end
	end
	local insertAt = IndexOf("race") + 1
	for _, flyoutID in ipairs(PATH_FLYOUTS) do
		local sectionID = "path" .. flyoutID
		local section = ns.SECTION_BY_ID[sectionID]
		if section then
			insertAt = IndexOf(sectionID) + 1 -- déjà créée : les suivantes viennent après
		elseif GetFlyoutInfo(flyoutID) then
			section = { id = sectionID, flyout = flyoutID, collapsed = flyoutID ~= CURRENT_PATH }
			table.insert(ns.SECTIONS, insertAt, section)
			ns.SECTION_BY_ID[sectionID] = section
			insertAt = insertAt + 1
		end
		if section then
			AddFlyout(flyoutID, sectionID, true)
		end
	end
	return #ns.DESTINATIONS > count
end
