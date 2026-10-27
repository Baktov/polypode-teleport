# Polypode Téléports

*English version: [README.en.md](README.en.md)*

Les **téléports de votre équipe** en un coup d'œil : pour chaque destination (pierre de foyer,
sorts de classe, téléportations de mage, générateurs de trou de ver...), qui peut y aller, qui est
en recharge et pour combien de temps, et où chacun a lié sa pierre de foyer. Un clic sur une ligne
utilise **votre** meilleur moyen ; une macro diffusée à toutes vos fenêtres fait partir toute
l'équipe, chacun avec le sien. Addon compagnon de [Polypode](https://github.com/Baktov/polypode),
séparé : chargé ou non depuis la liste des AddOns de WoW, par personnage.

Nécessite **Polypode 2.12.0** ou plus récent.

> **Langues** : français, anglais, allemand, espagnol, italien et portugais du Brésil, selon la
> langue choisie dans Polypode (option « Langue / Language »). Les traductions ont été faites avec
> l'aide de Claude, l'IA d'Anthropic : les retours de joueurs dont c'est la langue maternelle sont
> les bienvenus ([issue GitHub](https://github.com/Baktov/polypode-teleport/issues)).

---

## Installation

1. Installer d'abord **Polypode** (dépendance obligatoire).
2. Placer le dossier `Polypode_Teleport` dans `World of Warcraft/_retail_/Interface/AddOns/`
   (et, pour **WoW Forever**, dans `World of Warcraft/_forever_/Interface/AddOns/`, par
   exemple par une jonction `mklink /J`).
3. Cocher « Polypode Téléports » dans la liste des AddOns, **sur chaque personnage** de l'équipe :
   chacun envoie l'état de ses téléports.

---

## Utilisation

Le bouton **Téléports** (barre de titre de la fenêtre Polypode, ou **Tél** dans la colonne des
modules de la barre d'équipe) ou `/poly teleport` (`/poly tp`) ouvre la fenêtre. Échap la ferme. La fenêtre se retaille par son coin bas-droit (taille gardée) ;
double-clic sur la barre de titre : taille par défaut, largeur ajustée aux colonnes.

- **Colonnes** : les membres de l'**équipe sélectionnée**, leader en tête (votre personnage devant
  s'il n'en fait pas partie) ; en **mode solo** ou sans équipe, votre seul personnage.
- **Première ligne, « Lié à »** : le lieu de lien de la pierre de foyer de chacun. Un lieu
  **en orange** diffère de celui du premier personnage : ce membre partirait ailleurs.
- **Sections repliables** : Foyer et maison, Classe, Race, Donjons et raids (une section par
  extension, seule la plus récente dépliée au départ), Objets, Ingénierie. Un clic sur l'en-tête
  replie ou déplie la section (choix gardé) ; ses cases donnent le nombre de téléports prêts de
  chaque membre.
- **Une ligne par destination** que l'un au moins des personnages affichés peut atteindre. Chaque
  case indique **Prêt** (vert), le **temps de recharge** restant (jaune), `-` (aucun moyen) ou
  `?` (pas encore d'infos de ce personnage). Le nom de la destination est grisé quand **vous** ne
  pouvez pas l'utiliser maintenant.
- **Infobulle** d'une ligne : l'état de chaque membre avec le moyen qu'il utiliserait (pierre,
  jouet, sort), et la macro de la destination.
- **Clic sur une ligne** : votre personnage utilise son meilleur moyen pour cette destination (le
  premier prêt : pierre de foyer, puis jouets, puis Rappel astral pour le foyer, par exemple).
- **Les autres membres suivent** : le même clic ouvre, dans les fenêtres des autres membres de
  l'équipe, la fenêtre sur **cette seule ligne** (« Demande de ... ») : un clic dessus et ils
  partent, la fenêtre se ferme. Fermer puis rouvrir la fenêtre rend le tableau complet. Reçue en
  combat, la demande s'ouvre à la fin du combat (dans la minute).

### Toute l'équipe d'un coup

Un addon ne peut pas lancer un sort ou utiliser un objet pour une autre fenêtre. Mais chaque
destination a un bouton, `PolypodeTeleport_<destination>`, sur lequel chaque fenêtre a posé **son
propre** meilleur moyen. Il suffit donc de l'actionner dans toutes les fenêtres en même temps :

- **Pierre de foyer** : raccourci « Pierre de foyer (votre meilleur moyen) », dans Options →
  Raccourcis → Polypode, à diffuser à toutes les fenêtres avec votre outil de multiboxing ;
- **autre destination** : une macro `/click PolypodeTeleport_<destination>` (rappelée dans
  l'infobulle de la ligne), placée dans une barre d'action de chaque personnage.

---

## Fonctionnement

- Le personnage joué est lu en direct (sorts connus, objets des sacs, jouets possédés, temps de
  recharge). Les autres envoient leur état par Polypode (message `TELE`) à chaque connexion d'un
  de vos clients et quand il change (sort appris, objet obtenu, téléport utilisé, foyer déplacé).
  Rien n'est sauvegardé (sauf la taille de la fenêtre) : l'état est échangé à chaque session.
- **En combat**, la fenêtre se ferme et ne s'ouvre pas (WoW interdit de modifier les boutons de
  sort en combat) ; les macros et le raccourci gardent le moyen choisi avant le combat.
- **WoW Forever** : mêmes lignes, limitées à ce qui y existe (pierre de foyer, téléportations de
  mage vers les capitales, Reflet-de-Lune, transporteurs d'ingénierie, objets).
- Destinations prises en charge :
  - **foyer et maison** : pierre de foyer (avec ses jouets et le Rappel astral), maison (logis),
    pierres de foyer de fief et de Dalaran ;
  - **classe** : Porte de la mort, Reflet-de-Lune, Voie des rêves, Pèlerinage zen, Salle du
    Gardien, toutes les téléportations de mage (lues dans le menu de sorts du jeu) ;
  - **race** : camp des Vulpérins, Foreuse des nains sombrefer, Marche-racine des Haranir ;
  - **donjons et raids** : les sorts « Chemin du héros », lus dans les menus du jeu (le nom du
    donjon est dans l'infobulle) ;
  - **objets** : environ 130 objets et jouets de téléport (anneaux du Kirin Tor, capes de
    faction, balises, parchemins...) ;
  - **ingénierie** : générateurs de trou de ver et transporteurs.
- **Pierre de foyer** : la pierre de foyer d'origine si elle est dans les sacs, sinon le premier
  jouet de foyer possédé, sinon le Rappel astral. Les jouets partagent la recharge de la pierre.

---

## Crédits

Les listes des jouets de pierre de foyer, des générateurs de trou de ver, des objets de téléport
et des menus de sorts viennent de l'addon **TeleportMenu**, de **Justwait**. Merci à lui pour ce
recensement.

---

## Version

`1.2.0` : sections repliables ; maison, téléports de donjon et de raid, toutes les téléportations de mage, raciaux, environ 130 objets de téléport ; listes de pierres de foyer et de trous de ver mises à jour (reprises de TeleportMenu).

`1.1.1` : pierres de foyer de fief et de Dalaran reconnues (ce sont des jouets, elles étaient cherchées dans les sacs).

`1.1.0` : fenêtre retaillable ; un clic sur une ligne ouvre cette ligne, prête à cliquer, chez les autres membres de l'équipe.

`1.0.0` : première version (téléports de l'équipe, lieu de lien, clic et macro pour utiliser son meilleur moyen).
