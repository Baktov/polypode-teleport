-- Polypode Teleport: Destinations — table des destinations et des moyens d'y aller

local _, ns = ...

-- Une ligne par DESTINATION (pas par objet) : chaque personnage y va par le premier moyen prêt
-- qu'il possède, dans l'ordre de la liste. Ainsi une même touche fait partir toute l'équipe,
-- chacun avec son propre moyen.
--   id      : identifiant court et stable, échangé entre clients (message TELE) et nom du bouton
--             sécurisé PolypodeTeleport_<id> : ne jamais renommer un id publié.
--   hearth  : ligne de la pierre de foyer (destination = lieu de lien de chacun, GetBindLocation).
--   sources : { spell = id } (sort connu), { item = id } ou { toy = id } (équivalents : jouet
--             possédé, sinon objet du même numéro dans les sacs).
-- Libellé : nom du premier moyen (nom du jeu, déjà traduit), sans le préfixe « Téléportation : »,
-- « Générateur de trou de ver : »... (Teleport.lua, DestinationLabel). Un numéro inconnu du client
-- ne gêne pas : le moyen n'est jamais possédé.

-- Jouets de pierre de foyer : même destination et même temps de recharge que la pierre.
local HEARTH_TOYS = {
	54452, 64488, 93672, 142542, 162973, 163045, 165669, 165670, 165802, 166746, 166747,
	168907, 172179, 180290, 182773, 183716, 184353, 188952, 190196, 190237, 193588,
	200630, 206195, 208704, 209035, 212337, 228940, 235016, 236687, 245970, 246565,
}

local hearthSources = { { item = 6948 } } -- Pierre de foyer
for _, toyID in ipairs(HEARTH_TOYS) do
	hearthSources[#hearthSources + 1] = { toy = toyID }
end
hearthSources[#hearthSources + 1] = { spell = 556 } -- Rappel astral (chaman), recharge à part

ns.DESTINATIONS = {
	{ id = "hearth", hearth = true, sources = hearthSources },
	{ id = "garrison", sources = { { toy = 110560 } } }, -- Pierre de foyer de fief
	{ id = "dalaran", sources = { { spell = 224869 }, { toy = 140192 } } }, -- Dalaran (Îles Brisées)

	-- Sorts de classe
	{ id = "acherus", sources = { { spell = 50977 } } }, -- Porte de la mort (chevalier de la mort)
	{ id = "moonglade", sources = { { spell = 18960 } } }, -- Reflet-de-Lune (druide)
	{ id = "dreamway", sources = { { spell = 193753 } } }, -- Voie des rêves d'émeraude (druide)
	{ id = "peak", sources = { { spell = 126892 } } }, -- Pèlerinage zen (moine)
	{ id = "guardian", sources = { { spell = 193759 } } }, -- Salle du Gardien (mage)

	-- Téléportations de mage, des plus récentes aux plus anciennes
	{ id = "dornogal", sources = { { spell = 446540 } } },
	{ id = "valdrakken", sources = { { spell = 395277 } } },
	{ id = "oribos", sources = { { spell = 344587 } } },
	{ id = "boralus", sources = { { spell = 281403 } } },
	{ id = "dazaralor", sources = { { spell = 281404 } } },
	{ id = "stormshield", sources = { { spell = 176248 } } },
	{ id = "warspear", sources = { { spell = 176242 } } },
	{ id = "vale", sources = { { spell = 132621 }, { spell = 132627 } } }, -- Val de l'Éternel printemps
	{ id = "tolbarad", sources = { { spell = 88342 }, { spell = 88344 } } },
	{ id = "dalaran_nr", sources = { { spell = 53140 } } }, -- Dalaran (Norfendre)
	{ id = "shattrath", sources = { { spell = 33690 }, { spell = 35715 } } },
	{ id = "stormwind", sources = { { spell = 3561 } } },
	{ id = "ironforge", sources = { { spell = 3562 } } },
	{ id = "darnassus", sources = { { spell = 3565 } } },
	{ id = "exodar", sources = { { spell = 32271 } } },
	{ id = "theramore", sources = { { spell = 49359 } } },
	{ id = "orgrimmar", sources = { { spell = 3567 } } },
	{ id = "undercity", sources = { { spell = 3563 } } },
	{ id = "thunderbluff", sources = { { spell = 3566 } } },
	{ id = "silvermoon", sources = { { spell = 32272 } } },
	{ id = "stonard", sources = { { spell = 49358 } } },

	-- Ingénierie : générateurs de trou de ver et transporteurs
	{ id = "wh_khazalgar", sources = { { toy = 221966 } } },
	{ id = "wh_dragonisles", sources = { { toy = 198156 } } },
	{ id = "wh_shadowlands", sources = { { toy = 172924 } } },
	{ id = "wh_kultiras", sources = { { toy = 168807 } } },
	{ id = "wh_zandalar", sources = { { toy = 168808 } } },
	{ id = "wh_argus", sources = { { toy = 151652 } } },
	{ id = "wh_draenor", sources = { { toy = 112059 } } },
	{ id = "wh_pandaria", sources = { { toy = 87215 } } },
	{ id = "wh_northrend", sources = { { toy = 48933 } } },
	{ id = "area52", sources = { { toy = 30542 } } },
	{ id = "toshley", sources = { { toy = 30544 } } },
	{ id = "everlook", sources = { { toy = 18984 } } },
	{ id = "gadgetzan", sources = { { toy = 18986 } } },
}

ns.DESTINATION_BY_ID = {}
for _, destination in ipairs(ns.DESTINATIONS) do
	ns.DESTINATION_BY_ID[destination.id] = destination
end
