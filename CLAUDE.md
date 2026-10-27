# CLAUDE.md — Polypode Teleport (Addon WoW)

Conventions communes et procédure de documentation de tous les modules Polypode (chargées
automatiquement, quel que soit le dossier ouvert) :

@../Polypode/MODULES.md

Addon compagnon de **Polypode** (dossier voisin `../Polypode`, dépôt séparé) : les **téléports de
l'équipe** (pierres de foyer, sorts de classe, jouets), prêts ou en recharge pour chaque membre, et
un clic pour utiliser le sien. Rester **simple** : on n'ajoute une fonctionnalité que si elle sert
directement ce rôle.

## Architecture

| Fichier | Rôle |
|---|---|
| `Polypode_Teleport.toc` | Titre français `## Title: Polypode Téléports`, traduit `## Title-enUS`..., `## Notes` anglais / `## Notes-frFR` ; `## Dependencies: Polypode` ; `## SavedVariables: PolypodeTeleportDB` (seulement `window` = largeur / hauteur de la fenêtre ; état des téléports en mémoire, session) ; ordre `Locale → Locales → Destinations → Teleport → Bindings.xml` |
| `Locale.lua` | Chargé en premier : table de textes `ns.L = P.NewLocale()` (repli : table qui renvoie la clé française) et `ns.OnLanguageApplied(fn)` |
| `Locales/enUS.lua`, `deDE.lua`, `esES.lua`, `itIT.lua`, `ptBR.lua` | Traductions, même ordre dans chaque langue. Contrôle : `python Polypode\tools\check_locale.py Polypode_Teleport` depuis `ADDONS_POLYPODE` |
| `Destinations.lua` | `ns.DESTINATIONS` : **une ligne par destination** (pas par objet), `{ id, hearth, sources }` ; `sources` dans l'ordre de préférence : `{ spell = id }` (sort connu), `{ item = id }` / `{ toy = id }` (équivalents : jouet possédé, sinon objet du même numéro dans les sacs ; beaucoup d'objets de téléport sont devenus des jouets, et un jouet peut n'être qu'un objet sur WoW Forever). `id` court et stable (message `TELE`, nom du bouton `PolypodeTeleport_<id>`) : ne jamais renommer un id publié. `ns.DESTINATION_BY_ID`. Jouets de pierre de foyer dans `HEARTH_TOYS`. Un numéro inconnu du client ne gêne pas (jamais possédé) |
| `Teleport.lua` | Lecture du personnage joué (`ComputeOwn` : meilleur moyen de chaque destination = premier prêt dans l'ordre, sinon le plus tôt prêt ; `own.dest[id] = { kind, value, source, ready }`, `ready` = heure serveur ; recharge globale ≤ 2 s comptée comme prête ; valeurs secrètes → recharge illisible ; `own.bind` = `GetBindLocation()`). **Boutons sécurisés** `PolypodeTeleport_<id>` (`CreateSecureButtons` à `PLAYER_LOGIN`, ou fin du combat après un `/reload` en combat ; sans taille ni position, `useOnKeyDown` faux : action au relâchement, comme `/click` et le délégué `click`) ; `UpdateSecureButtons` y pose `type` / `spell` / `toy` / `item` du meilleur moyen, hors combat seulement (sinon `waitingCombatEnd`). **Synchro** : `TELE:token:flag:envoi:nom-royaume:entrées:foyer` (flag `N` remplace, `+` suite du même envoi ; entrées `id,secondes,moyen` séparées par `;`, secondes 0 = prêt, -1 = illisible ; foyer en dernier, premier fragment seulement), fragmenté sous `P.MAX_MESSAGE_LENGTH` (`SendOwn`) ; envoyé à chaque HELLO/HI (`P.RegisterPeerCallback`) et aux clients connectés quand `Signature()` change (recharges arrondies à 10 s) ; `UpdateOwn` 2 s après `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED`, `BAG_UPDATE_DELAYED`, `TOYS_UPDATED`, `HEARTHSTONE_BOUND`, `SPELL_UPDATE_COOLDOWN`, `BAG_UPDATE_COOLDOWN` (`ScheduleUpdate`), repoussé à la fin du combat ; reçu par `OnMessage` (expéditeur vérifié par `P.IsSender`) dans `peers[clé]` (session). **Fenêtre** `PolypodeTeleportFrame` (`P.ToggleTeleport`, `P.RefreshTeleport`, `P.ui.teleportFrame` / `teleportPanel`) : colonnes (`ColumnKeys` : membres de l'équipe sélectionnée, leader en tête, personnage joué devant s'il n'en est pas ; lui seul en mode solo ou sans équipe), noms en couleur de classe (`LayoutColumns` : tant que `PolypodeTeleportDB.window.width` est absent, largeur de la fenêtre selon leur nombre ; sinon les colonnes se partagent la largeur, entre `COLUMN_MIN` et `COLUMN_MAX`, et la largeur minimale suit leur nombre) ; **retaillable** (poignée bas-droite, taille gardée au relâché ; double-clic sur le titre par `P.EnableTitleDoubleClick` : taille effacée, largeur de nouveau ajustée ; `OnSizeChanged` → `LayoutColumns` + `RedecorateRows`) ; lignes (`BuildItems`) : « Lié à » (lieu de lien, en orange s'il diffère de la première colonne) puis les destinations qu'au moins une colonne possède ; libellé = nom du jeu du premier moyen sans le préfixe « xxx : » (`DestinationLabel`, cache `labels`, objets chargés par `C_Item.RequestLoadItemDataByID` → `ITEM_DATA_LOAD_RESULT`), grisé si le personnage joué ne peut pas l'utiliser maintenant ; cases (`CellText`) : Prêt / recharge / `-` / `?` ; chaque ligne porte un bouton sécurisé `row.cast` de type `click` qui délègue à `PolypodeTeleport_<id>` (attribut posé hors combat), infobulle par membre avec le moyen choisi et la macro `/click` ; **demande** : `HookScript("OnClick")` du bouton de ligne (après l'action sécurisée) envoie `TELEGO:token:nom-royaume:id` aux clients connectés (`SendRequest`) ; à la réception (`OnRequest` : expéditeur vérifié par `P.IsSender` et présent dans nos colonnes), `OpenRequest` ouvre la fenêtre en mode demande (`requested = { from, id }` : titre « Demande de X », lignes réduites à la destination, plus « Lié à » pour la pierre de foyer) ; en mode demande, le clic ne renvoie rien et ferme la fenêtre si le moyen était prêt ; `OnHide` efface `requested` (rouverte : tableau complet) ; reçue en combat : `pendingRequest`, ouverte à `PLAYER_REGEN_ENABLED` si elle a moins de `REQUEST_EXPIRY` (60 s) ; cases relues chaque seconde (`OnUpdate`, hors combat). **Combat** : la fenêtre se ferme à `PLAYER_REGEN_DISABLED` (avant le verrouillage) et ne s'ouvre pas en combat. Bouton `P.AddTitleButton` (`L["Téléports"]`), commande `/poly teleport` (alias `/poly tp`), libellés de raccourci `BINDING_HEADER_POLYPODETELEPORT` et `BINDING_NAME_CLICK PolypodeTeleport_hearth:LeftButton`, posés dans `ns.OnLanguageApplied` ; suit `P.RefreshUI` (`hooksecurefunc`) |
| `Bindings.xml` | Raccourci « Pierre de foyer (votre meilleur moyen) » : `CLICK PolypodeTeleport_hearth:LeftButton`, catégorie `Polypode` |

## Dépendances vers Polypode (API publique utilisée)

`P.AddTitleButton`, `P.RegisterSlashCommand`, `P.RegisterMessageHandler`, `P.RegisterPeerCallback`,
`P.WhisperOnline`, `P.IsSender`, `P.MAX_MESSAGE_LENGTH`, `P.GetTeamToken`, `P.GetCharKey`,
`P.GetDisplayName`, `P.db.roster`, `P.SortedKeyItems`, `P.IsSoloMode`, `P.GetSelectedTeam`,
`P.GetTeamMembers`, `P.GetTeamLeader`, `P.CreatePanel`, `P.CreateScrollList`, `P.SetListData`,
`P.SkinFrame`, `P.SkinPanel`, `P.ShowTooltip`, `P.RefreshUI` (accroche), `P.ui`. Langues :
`P.NewLocale`, `P.AddTranslations`, `P.OnLanguageApplied`. Toute évolution de ces fonctions dans
Polypode doit rester compatible, ou ce fichier doit suivre.

## Pistes

- Téléports de donjon (« Chemin de... », mythique+), téléport vers la maison (`C_Housing.TeleportHome`,
  identifiants de quartier et de maison à fournir), téléport de mage vers Lune-d'argent de Midnight
  (numéro de sort à vérifier), anneaux et capes à équiper (Kirin Tor, Ligue des explorateurs).
- Case « Toutes » pour afficher aussi les destinations que personne ne possède.
- Raccourcis pour d'autres destinations que la pierre de foyer (aujourd'hui : macro `/click`).

## Après chaque modification

Appliquer la procédure de `../Polypode/MODULES.md` (« Après chaque modification d'un module »),
sans attendre qu'on le demande : version du `.toc` et du commit, ligne en tête de la section
« Version » du `README.md` et sections d'utilisation (et `README.en.md`), ce fichier (architecture, dépendances),
Polypode si le périmètre change, puis commit et push sur `origin` (https://github.com/Baktov/polypode-teleport).
