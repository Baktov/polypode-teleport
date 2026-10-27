# Polypode Teleports

*Version française : [README.md](README.md)*

Your **team's teleports** at a glance: for each destination (hearthstone, class spells, mage
teleports, wormhole generators...), who can go there, who is on cooldown and for how long, and where
each one's hearthstone is bound. Clicking a row uses **your** best option; a macro broadcast to all
your windows sends the whole team, each with their own. Companion addon of
[Polypode](https://github.com/Baktov/polypode), separate: loaded or not from WoW's AddOns list, per
character.

Requires **Polypode 2.12.0** or newer.

> **Languages**: French, English, German, Spanish, Italian and Brazilian Portuguese, following the
> language chosen in Polypode ("Langue / Language" option). The translations were made with the
> help of Claude, Anthropic's AI: feedback from native speakers is welcome
> ([GitHub issue](https://github.com/Baktov/polypode-teleport/issues)).

---

## Installation

1. First install **Polypode** (required dependency).
2. Put the `Polypode_Teleport` folder in `World of Warcraft/_retail_/Interface/AddOns/`
   (and, for **WoW Forever**, in `World of Warcraft/_forever_/Interface/AddOns/`, for example
   with an `mklink /J` junction).
3. Enable "Polypode Teleports" in the AddOns list **on each character** of the team: each one
   sends the state of its teleports.

---

## Usage

The **Teleports** button (title bar of the Polypode window, or **Tel** in the module column of the
team bar) or `/poly teleport` (`/poly tp`) opens the window. Escape closes it. Resize the window from its bottom-right corner (size kept);
double-click the title bar: default size, width fitted to the columns.

- **Columns**: the members of the **selected team**, leader first (your character in front if it is
  not a member); in **solo mode** or without a team, your character only.
- **First row, "Bound to"**: where each one's hearthstone is bound. A location **in orange**
  differs from the first character's: that member would end up elsewhere.
- **Collapsible sections**: Hearth and home, Class, Race, Dungeons and raids (one section per
  expansion, only the latest expanded at first), Items, Engineering. Click a header to collapse
  or expand the section (choice kept); its cells show each member's number of ready teleports.
- **One row per destination** that at least one of the displayed characters can reach. Each cell
  shows **Ready** (green), the remaining **cooldown** (yellow), `-` (no option) or `?` (no info from
  that character yet). The destination name is grayed out when **you** cannot use it right now.
- **Tooltip** of a row: each member's state with the option they would use (stone, toy, spell),
  and the destination's macro.
- **Click a row**: your character uses its best option for that destination (the first one ready:
  hearthstone, then toys, then Astral Recall for the hearth, for example).
- **The other members follow**: the same click opens, in the windows of the other team members,
  the window on **that single row** ("Request from ..."): one click on it and they go, the window
  closes. Closing and reopening the window brings back the full table. Received in combat, the
  request opens when combat ends (within a minute).

### The whole team at once

An addon cannot cast a spell or use an item for another window. But each destination has a button,
`PolypodeTeleport_<destination>`, on which each window has set **its own** best option. So you only
need to press it in all windows at the same time:

- **Hearthstone**: the "Hearthstone (your best option)" key binding, in Options → Keybindings →
  Polypode, broadcast to all windows with your multiboxing tool;
- **other destination**: a `/click PolypodeTeleport_<destination>` macro (shown in the row's
  tooltip), placed on an action bar of each character.

---

## How it works

- The played character is read live (known spells, bag items, owned toys, cooldowns). The others
  send their state through Polypode (`TELE` message) each time one of your clients connects and
  when it changes (spell learned, item obtained, teleport used, hearth moved). Nothing is saved
  (except the window size): the state is exchanged each session.
- **In combat**, the window closes and does not open (WoW forbids changing spell buttons in
  combat); macros and the key binding keep the option chosen before combat.
- **WoW Forever**: same rows, limited to what exists there (hearthstone, mage teleports to the
  capitals, Moonglade, engineering transporters).
- Supported destinations:
  - **hearth and home**: hearthstone (with its toys and Astral Recall), house, garrison and
    Dalaran hearthstones;
  - **class**: Death Gate, Moonglade, Dreamwalk, Zen Pilgrimage, Hall of the Guardian, all mage
    teleports (read from the game's spell flyout);
  - **race**: Vulpera camp, Dark Iron Mole Machine, Haranir Rootwalking;
  - **dungeons and raids**: the "Hero's Path" spells, read from the game's flyouts (the dungeon
    name is in the tooltip);
  - **items**: about 130 teleport items and toys (Kirin Tor rings, faction cloaks, beacons,
    scrolls...);
  - **engineering**: wormhole generators and transporters.
- **Hearthstone**: the original Hearthstone if it is in the bags, otherwise the first hearthstone
  toy owned, otherwise Astral Recall. The toys share the stone's cooldown. **"Random
  hearthstone"** option (right-click the Teleports button, or Options → AddOns → Polypode →
  Teleports): a hearthstone toy drawn at random among those owned, new draw after each use.
  Setting shared by all characters of the account.

---

## Credits

The lists of hearthstone toys, wormhole generators, teleport items and spell flyouts come from
the **TeleportMenu** addon, by **Justwait**. Thanks for this inventory.

---

## Version

See the "Version" section of the [French README](README.md#version).
