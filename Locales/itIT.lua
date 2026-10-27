-- Polypode Teleport: Locales/itIT — textes en italien (clé = texte français du code). Voir
-- Polypode/Locale.lua et MODULES.md (« Langues »).

local _, ns = ...
local P = Polypode
if not P.AddTranslations then
	return
end

P.AddTranslations(ns.L, "itIT", {
	-- Teleport.lua
	["Polypode Téléports"] = "Polypode Teletrasporti",
	["Téléports"] = "Teletrasporti",
	["Téléports de l'équipe"] = "Teletrasporti della squadra",
	["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] = "Teletrasporti della squadra: pronti o in ricarica; Clic su una riga per usare il tuo.",
	["téléports de l'équipe"] = "teletrasporti della squadra",
	["Téléports : impossible en combat."] = "Teletrasporti: impossibile in combattimento.",
	["Pierre de foyer"] = "Pietra del Ritorno",
	["Pierre de foyer (votre meilleur moyen)"] = "Pietra del Ritorno (il tuo mezzo migliore)",
	["Lié à"] = "Legato a",
	["Lieu de lien de la pierre de foyer"] = "Luogo della Pietra del Ritorno",
	["En orange : lié ailleurs que le premier personnage de l'équipe."] = "In arancione: legato altrove rispetto al primo personaggio della squadra.",
	["Prêt"] = "Pronto",
	["%d s"] = "%d s",
	["%d min"] = "%d min",
	["%d h %02d"] = "%d h %02d",
	["Clic : utiliser votre meilleur moyen."] = "Clic: usa il tuo mezzo migliore.",
	["Macro pour toutes les fenêtres : %s"] = "Macro per tutte le finestre: %s",
	["Demande de %s"] = "Richiesta di %s",
	["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."] = "Le altre finestre della squadra ricevono questa riga, pronta da cliccare.",
})
