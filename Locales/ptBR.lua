-- Polypode Teleport: Locales/ptBR — textes en portugais du Brésil (clé = texte français du code). Voir
-- Polypode/Locale.lua et MODULES.md (« Langues »).

local _, ns = ...
local P = Polypode
if not P.AddTranslations then
	return
end

P.AddTranslations(ns.L, "ptBR", {
	-- Teleport.lua
	["Polypode Téléports"] = "Polypode Teleportes",
	["Téléports"] = "Teleportes",
	["Téléports de l'équipe"] = "Teleportes da equipe",
	["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] = "Teleportes da equipe: prontos ou em recarga; Clique em uma linha para usar o seu.",
	["téléports de l'équipe"] = "teleportes da equipe",
	["Téléports : impossible en combat."] = "Teleportes: impossível em combate.",
	["Pierre de foyer"] = "Pedra de Regresso",
	["Pierre de foyer (votre meilleur moyen)"] = "Pedra de Regresso (sua melhor opção)",
	["Lié à"] = "Vinculado a",
	["Lieu de lien de la pierre de foyer"] = "Local da Pedra de Regresso",
	["En orange : lié ailleurs que le premier personnage de l'équipe."] = "Em laranja: vinculado em outro lugar que o primeiro personagem da equipe.",
	["Prêt"] = "Pronto",
	["%d s"] = "%d s",
	["%d min"] = "%d min",
	["%d h %02d"] = "%d h %02d",
	["Clic : utiliser votre meilleur moyen."] = "Clique: usar sua melhor opção.",
	["Macro pour toutes les fenêtres : %s"] = "Macro para todas as janelas: %s",
})
