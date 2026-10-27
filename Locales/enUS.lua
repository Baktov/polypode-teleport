-- Polypode Teleport: Locales/enUS — textes anglais (clé = texte français du code), repli de toute
-- langue sans traduction propre.
-- Voir Polypode/Locale.lua et MODULES.md (« Langues »).

local _, ns = ...
local P = Polypode
if not P.AddTranslations then
	return
end

P.AddTranslations(ns.L, "enUS", {
	-- Teleport.lua
	["Polypode Téléports"] = "Polypode Teleports",
	["Téléports"] = "Teleports",
	["Téléports de l'équipe"] = "Team teleports",
	["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] = "Team teleports: ready or on cooldown; click a row to use yours.",
	["téléports de l'équipe"] = "team teleports",
	["Téléports : impossible en combat."] = "Teleports: not possible in combat.",
	["Pierre de foyer"] = "Hearthstone",
	["Pierre de foyer (votre meilleur moyen)"] = "Hearthstone (your best option)",
	["Lié à"] = "Bound to",
	["Lieu de lien de la pierre de foyer"] = "Hearthstone location",
	["En orange : lié ailleurs que le premier personnage de l'équipe."] = "In orange: bound somewhere other than the first character of the team.",
	["Prêt"] = "Ready",
	["%d s"] = "%d s",
	["%d min"] = "%d min",
	["%d h %02d"] = "%dh %02d",
	["Clic : utiliser votre meilleur moyen."] = "Click: use your best option.",
	["Macro pour toutes les fenêtres : %s"] = "Macro for all windows: %s",
	["Demande de %s"] = "Request from %s",
	["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."] = "The other windows of the team receive this row, ready to click.",
})
