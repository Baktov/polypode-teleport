-- Polypode Teleport: Locales/deDE — textes en allemand (clé = texte français du code). Voir
-- Polypode/Locale.lua et MODULES.md (« Langues »).

local _, ns = ...
local P = Polypode
if not P.AddTranslations then
	return
end

P.AddTranslations(ns.L, "deDE", {
	-- Teleport.lua
	["Polypode Téléports"] = "Polypode Teleporter",
	["Téléports"] = "Teleporter",
	["Téléports de l'équipe"] = "Teleporter der Gruppe",
	["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] = "Teleporter der Gruppe: bereit oder in Abklingzeit; Klick auf eine Zeile benutzt deinen.",
	["téléports de l'équipe"] = "Teleporter der Gruppe",
	["Téléports : impossible en combat."] = "Teleporter: im Kampf nicht möglich.",
	["Pierre de foyer"] = "Ruhestein",
	["Pierre de foyer (votre meilleur moyen)"] = "Ruhestein (dein bestes Mittel)",
	["Lié à"] = "Gebunden an",
	["Lieu de lien de la pierre de foyer"] = "Ort des Ruhesteins",
	["En orange : lié ailleurs que le premier personnage de l'équipe."] = "In Orange: an einem anderen Ort gebunden als der erste Charakter der Gruppe.",
	["Prêt"] = "Bereit",
	["%d s"] = "%d s",
	["%d min"] = "%d min",
	["%d h %02d"] = "%d h %02d",
	["Clic : utiliser votre meilleur moyen."] = "Klick: dein bestes Mittel benutzen.",
	["Macro pour toutes les fenêtres : %s"] = "Makro für alle Fenster: %s",
	["Demande de %s"] = "Anfrage von %s",
	["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."] = "Die anderen Fenster des Teams erhalten diese Zeile, bereit zum Anklicken.",
	["Maison"] = "Zuhause",
	["Donjons et raids : %s"] = "Dungeons und Schlachtzüge: %s",
	["Foyer et maison"] = "Ruhestein und Zuhause",
	["Classe"] = "Klasse",
	["Race"] = "Volk",
	["Objets"] = "Gegenstände",
	["Ingénierie"] = "Ingenieurskunst",
	["Nombre de téléports prêts par personnage."] = "Anzahl der bereiten Teleports pro Charakter.",
	["Clic : replier ou déplier la section."] = "Klick: Abschnitt ein- oder ausklappen.",
	["Pierre de foyer au hasard"] = "Zufälliger Ruhestein",
	["Utilise un jouet de pierre de foyer tiré au sort parmi ceux que vous possédez (nouveau tirage après chaque utilisation), au lieu de la pierre de foyer d'origine. Même temps de recharge."] = "Verwendet ein zufällig gewähltes Ruhestein-Spielzeug aus Ihrem Besitz (nach jeder Verwendung neu gewählt) statt des ursprünglichen Ruhesteins. Gleiche Abklingzeit.",
	["Options des téléports"] = "Teleport-Optionen",
	["Clic droit : options (pierre de foyer au hasard)"] = "Rechtsklick: Optionen (zufälliger Ruhestein)",
})
