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
	["Demande de %s"] = "Pedido de %s",
	["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."] = "As outras janelas da equipe recebem esta linha, pronta para clicar.",
	["Maison"] = "Casa",
	["Donjons et raids : %s"] = "Masmorras e raides: %s",
	["Foyer et maison"] = "Lar e casa",
	["Classe"] = "Classe",
	["Race"] = "Raça",
	["Objets"] = "Itens",
	["Ingénierie"] = "Engenharia",
	["Nombre de téléports prêts par personnage."] = "Número de teleportes prontos por personagem.",
	["Clic : replier ou déplier la section."] = "Clique: recolher ou expandir a seção.",
	["Pierre de foyer au hasard"] = "Pedra de regresso aleatória",
	["Utilise un jouet de pierre de foyer tiré au sort parmi ceux que vous possédez (nouveau tirage après chaque utilisation), au lieu de la pierre de foyer d'origine. Même temps de recharge."] = "Usa um brinquedo de pedra de regresso sorteado entre os que você possui (novo sorteio após cada uso), em vez da pedra de regresso original. Mesmo tempo de recarga.",
	["Options des téléports"] = "Opções de teleportes",
	["Clic droit : options (pierre de foyer au hasard)"] = "Clique direito: opções (pedra de regresso aleatória)",
})
