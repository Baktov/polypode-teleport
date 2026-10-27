-- Polypode Teleport: Locales/esES — textes en espagnol (clé = texte français du code ; le client esMX les prend aussi). Voir
-- Polypode/Locale.lua et MODULES.md (« Langues »).

local _, ns = ...
local P = Polypode
if not P.AddTranslations then
	return
end

P.AddTranslations(ns.L, "esES", {
	-- Teleport.lua
	["Polypode Téléports"] = "Polypode Teletransportes",
	["Téléports"] = "Teletransportes",
	["Téléports de l'équipe"] = "Teletransportes del equipo",
	["Téléports de l'équipe : prêts ou en recharge ; clic sur une ligne pour utiliser le vôtre."] = "Teletransportes del equipo: listos o en reutilización; Clic en una fila para usar el tuyo.",
	["téléports de l'équipe"] = "teletransportes del equipo",
	["Téléports : impossible en combat."] = "Teletransportes: imposible en combate.",
	["Pierre de foyer"] = "Piedra de hogar",
	["Pierre de foyer (votre meilleur moyen)"] = "Piedra de hogar (tu mejor opción)",
	["Lié à"] = "Vinculado a",
	["Lieu de lien de la pierre de foyer"] = "Lugar de la piedra de hogar",
	["En orange : lié ailleurs que le premier personnage de l'équipe."] = "En naranja: vinculado en otro lugar que el primer personaje del equipo.",
	["Prêt"] = "Listo",
	["%d s"] = "%d s",
	["%d min"] = "%d min",
	["%d h %02d"] = "%d h %02d",
	["Clic : utiliser votre meilleur moyen."] = "Clic: usar tu mejor opción.",
	["Macro pour toutes les fenêtres : %s"] = "Macro para todas las ventanas: %s",
	["Demande de %s"] = "Solicitud de %s",
	["Les autres fenêtres de l'équipe reçoivent cette ligne, prête à cliquer."] = "Las demás ventanas del equipo reciben esta fila, lista para hacer clic.",
	["Maison"] = "Casa",
	["Donjons et raids : %s"] = "Mazmorras y bandas: %s",
	["Foyer et maison"] = "Hogar y casa",
	["Classe"] = "Clase",
	["Race"] = "Raza",
	["Objets"] = "Objetos",
	["Ingénierie"] = "Ingeniería",
	["Nombre de téléports prêts par personnage."] = "Número de teletransportes listos por personaje.",
	["Clic : replier ou déplier la section."] = "Clic: contraer o expandir la sección.",
	["Pierre de foyer au hasard"] = "Piedra de hogar aleatoria",
	["Utilise un jouet de pierre de foyer tiré au sort parmi ceux que vous possédez (nouveau tirage après chaque utilisation), au lieu de la pierre de foyer d'origine. Même temps de recharge."] = "Usa un juguete de piedra de hogar elegido al azar entre los que posees (nuevo sorteo tras cada uso), en lugar de la piedra de hogar original. Mismo tiempo de reutilización.",
	["Options des téléports"] = "Opciones de teletransportes",
	["Clic droit : options (pierre de foyer au hasard)"] = "Clic derecho: opciones (piedra de hogar aleatoria)",
})
