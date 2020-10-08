--print("media.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
local LSM = A.Libs.LSM
-- fonts
LSM:Register("font", "Roboto Condensed Bold", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-Bold.ttf]])
LSM:Register("font", "Roboto Condensed BoldItalic", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-BoldItalic.ttf]])
LSM:Register("font", "Roboto Condensed Light", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-Light.ttf]])
LSM:Register("font", "Roboto Condensed LightItalic", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-LightItalic.ttf]])
LSM:Register("font", "Roboto Condensed Regular", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-Regular.ttf]])
LSM:Register("font", "Roboto Condensed RegularItalic", [[Interface\AddOns\AlertMe\Media\Fonts\Roboto_Condensed\RobotoCondensed-RegularItalic.ttf]])
-- sounds
LSM:Register("sound", "Adrenaline Rush", [[Interface\AddOns\AlertMe\Media\Sounds\Adrenaline Rush.ogg]])
LSM:Register("sound", "Aimed Shot", [[Interface\AddOns\AlertMe\Media\Sounds\Aimed Shot.ogg]])
LSM:Register("sound", "Arcane Power", [[Interface\AddOns\AlertMe\Media\Sounds\Arcane Power.ogg]])
LSM:Register("sound", "Banish", [[Interface\AddOns\AlertMe\Media\Sounds\Banish.ogg]])
LSM:Register("sound", "Barkskin", [[Interface\AddOns\AlertMe\Media\Sounds\Barkskin.ogg]])
LSM:Register("sound", "Battle Stance", [[Interface\AddOns\AlertMe\Media\Sounds\Battle Stance.ogg]])
LSM:Register("sound", "Berserker Rage", [[Interface\AddOns\AlertMe\Media\Sounds\Berserker Rage.ogg]])
LSM:Register("sound", "Berserker Stance", [[Interface\AddOns\AlertMe\Media\Sounds\Berserker Stance.ogg]])
LSM:Register("sound", "Blade Flurry", [[Interface\AddOns\AlertMe\Media\Sounds\Blade Flurry.ogg]])
LSM:Register("sound", "Blessing of Freedom", [[Interface\AddOns\AlertMe\Media\Sounds\Blessing of Freedom.ogg]])
LSM:Register("sound", "Blessing of Protection", [[Interface\AddOns\AlertMe\Media\Sounds\Blessing of Protection.ogg]])
LSM:Register("sound", "Blessing of Sacrifice", [[Interface\AddOns\AlertMe\Media\Sounds\Blessing of Sacrifice.ogg]])
LSM:Register("sound", "Blind Enemy", [[Interface\AddOns\AlertMe\Media\Sounds\Blind Enemy.ogg]])
LSM:Register("sound", "Blind Friend", [[Interface\AddOns\AlertMe\Media\Sounds\Blind Friend.ogg]])
LSM:Register("sound", "Blind", [[Interface\AddOns\AlertMe\Media\Sounds\Blind.ogg]])
LSM:Register("sound", "BoF", [[Interface\AddOns\AlertMe\Media\Sounds\BoF.ogg]])
LSM:Register("sound", "BoP", [[Interface\AddOns\AlertMe\Media\Sounds\BoP.ogg]])
LSM:Register("sound", "Bubble", [[Interface\AddOns\AlertMe\Media\Sounds\Bubble.ogg]])
LSM:Register("sound", "Cannibalize", [[Interface\AddOns\AlertMe\Media\Sounds\Cannibalize.ogg]])
LSM:Register("sound", "Cold Blood", [[Interface\AddOns\AlertMe\Media\Sounds\Cold Blood.ogg]])
LSM:Register("sound", "Cold Snap", [[Interface\AddOns\AlertMe\Media\Sounds\Cold Snap.ogg]])
LSM:Register("sound", "Combustion", [[Interface\AddOns\AlertMe\Media\Sounds\Combustion.ogg]])
LSM:Register("sound", "Countered", [[Interface\AddOns\AlertMe\Media\Sounds\Countered.ogg]])
LSM:Register("sound", "Counterspell", [[Interface\AddOns\AlertMe\Media\Sounds\Counterspell.ogg]])
LSM:Register("sound", "Dash", [[Interface\AddOns\AlertMe\Media\Sounds\Dash.ogg]])
LSM:Register("sound", "Death Coil", [[Interface\AddOns\AlertMe\Media\Sounds\Death Coil.ogg]])
LSM:Register("sound", "Death Wish", [[Interface\AddOns\AlertMe\Media\Sounds\Death Wish.ogg]])
LSM:Register("sound", "Defensive Stance", [[Interface\AddOns\AlertMe\Media\Sounds\Defensive Stance.ogg]])
LSM:Register("sound", "Deterrence", [[Interface\AddOns\AlertMe\Media\Sounds\Deterrence.ogg]])
LSM:Register("sound", "Disarm", [[Interface\AddOns\AlertMe\Media\Sounds\Disarm.ogg]])
LSM:Register("sound", "Dispel", [[Interface\AddOns\AlertMe\Media\Sounds\Dispel.ogg]])
LSM:Register("sound", "Divine Shield", [[Interface\AddOns\AlertMe\Media\Sounds\Divine Shield.ogg]])
LSM:Register("sound", "divine", [[Interface\AddOns\AlertMe\Media\Sounds\divine.ogg]])
LSM:Register("sound", "Drinking", [[Interface\AddOns\AlertMe\Media\Sounds\Drinking.ogg]])
LSM:Register("sound", "Earthbind Totem", [[Interface\AddOns\AlertMe\Media\Sounds\Earthbind Totem.ogg]])
LSM:Register("sound", "Elemental Mastery", [[Interface\AddOns\AlertMe\Media\Sounds\Elemental Mastery.ogg]])
LSM:Register("sound", "Enrage", [[Interface\AddOns\AlertMe\Media\Sounds\Enrage.ogg]])
LSM:Register("sound", "Entangling Roots", [[Interface\AddOns\AlertMe\Media\Sounds\Entangling Roots.ogg]])
LSM:Register("sound", "Escape Artist", [[Interface\AddOns\AlertMe\Media\Sounds\Escape Artist.ogg]])
LSM:Register("sound", "Evasion", [[Interface\AddOns\AlertMe\Media\Sounds\Evasion.ogg]])
LSM:Register("sound", "Evocation", [[Interface\AddOns\AlertMe\Media\Sounds\Evocation.ogg]])
LSM:Register("sound", "FAP", [[Interface\AddOns\AlertMe\Media\Sounds\FAP.ogg]])
LSM:Register("sound", "Fear Enemy", [[Interface\AddOns\AlertMe\Media\Sounds\Fear Enemy.ogg]])
LSM:Register("sound", "Fear Friend", [[Interface\AddOns\AlertMe\Media\Sounds\Fear Friend.ogg]])
LSM:Register("sound", "Fear Ward", [[Interface\AddOns\AlertMe\Media\Sounds\Fear Ward.ogg]])
LSM:Register("sound", "Fear", [[Interface\AddOns\AlertMe\Media\Sounds\Fear.ogg]])
LSM:Register("sound", "Fel Domination", [[Interface\AddOns\AlertMe\Media\Sounds\Fel Domination.ogg]])
LSM:Register("sound", "First Aid", [[Interface\AddOns\AlertMe\Media\Sounds\First Aid.ogg]])
LSM:Register("sound", "Free Action", [[Interface\AddOns\AlertMe\Media\Sounds\Free Action.ogg]])
LSM:Register("sound", "Freezing Trap", [[Interface\AddOns\AlertMe\Media\Sounds\Freezing Trap.ogg]])
LSM:Register("sound", "Gouge", [[Interface\AddOns\AlertMe\Media\Sounds\Gouge.ogg]])
LSM:Register("sound", "Grounding Totem", [[Interface\AddOns\AlertMe\Media\Sounds\Grounding Totem.ogg]])
LSM:Register("sound", "Hammer of Justice", [[Interface\AddOns\AlertMe\Media\Sounds\Hammer of Justice.ogg]])
LSM:Register("sound", "Hearthstone", [[Interface\AddOns\AlertMe\Media\Sounds\Hearthstone.ogg]])
LSM:Register("sound", "Hibernate", [[Interface\AddOns\AlertMe\Media\Sounds\Hibernate.ogg]])
LSM:Register("sound", "Howl of Terror", [[Interface\AddOns\AlertMe\Media\Sounds\Howl of Terror.ogg]])
LSM:Register("sound", "Ice Block", [[Interface\AddOns\AlertMe\Media\Sounds\Ice Block.ogg]])
LSM:Register("sound", "Innervate", [[Interface\AddOns\AlertMe\Media\Sounds\Innervate.ogg]])
LSM:Register("sound", "Intimidating Shout", [[Interface\AddOns\AlertMe\Media\Sounds\Intimidating Shout.ogg]])
LSM:Register("sound", "Invisibility", [[Interface\AddOns\AlertMe\Media\Sounds\Invisibility.ogg]])
LSM:Register("sound", "Invulnerability", [[Interface\AddOns\AlertMe\Media\Sounds\Invulnerability.ogg]])
LSM:Register("sound", "Kick", [[Interface\AddOns\AlertMe\Media\Sounds\Kick.ogg]])
LSM:Register("sound", "Kidney Shot", [[Interface\AddOns\AlertMe\Media\Sounds\Kidney Shot.ogg]])
LSM:Register("sound", "Last Stand", [[Interface\AddOns\AlertMe\Media\Sounds\Last Stand.ogg]])
LSM:Register("sound", "LIP", [[Interface\AddOns\AlertMe\Media\Sounds\LIP.ogg]])
LSM:Register("sound", "Living Action", [[Interface\AddOns\AlertMe\Media\Sounds\Living Action.ogg]])
LSM:Register("sound", "Mana Burn", [[Interface\AddOns\AlertMe\Media\Sounds\Mana Burn.ogg]])
LSM:Register("sound", "Mana Tide Totem", [[Interface\AddOns\AlertMe\Media\Sounds\Mana Tide Totem.ogg]])
LSM:Register("sound", "Mind Control", [[Interface\AddOns\AlertMe\Media\Sounds\Mind Control.ogg]])
LSM:Register("sound", "Perception", [[Interface\AddOns\AlertMe\Media\Sounds\Perception.ogg]])
LSM:Register("sound", "Polymorph", [[Interface\AddOns\AlertMe\Media\Sounds\Polymorph.ogg]])
LSM:Register("sound", "Power Infusion", [[Interface\AddOns\AlertMe\Media\Sounds\Power Infusion.ogg]])
LSM:Register("sound", "Preparation", [[Interface\AddOns\AlertMe\Media\Sounds\Preparation.ogg]])
LSM:Register("sound", "Presence of Mind", [[Interface\AddOns\AlertMe\Media\Sounds\Presence of Mind.ogg]])
LSM:Register("sound", "Pummel", [[Interface\AddOns\AlertMe\Media\Sounds\Pummel.ogg]])
LSM:Register("sound", "Purge", [[Interface\AddOns\AlertMe\Media\Sounds\Purge.ogg]])
LSM:Register("sound", "Rapid Fire", [[Interface\AddOns\AlertMe\Media\Sounds\Rapid Fire.ogg]])
LSM:Register("sound", "Recklessness", [[Interface\AddOns\AlertMe\Media\Sounds\Recklessness.ogg]])
LSM:Register("sound", "Reflector", [[Interface\AddOns\AlertMe\Media\Sounds\Reflector.ogg]])
LSM:Register("sound", "Repentance", [[Interface\AddOns\AlertMe\Media\Sounds\Repentance.ogg]])
LSM:Register("sound", "Restorative", [[Interface\AddOns\AlertMe\Media\Sounds\Restorative.ogg]])
LSM:Register("sound", "Resurrection", [[Interface\AddOns\AlertMe\Media\Sounds\Resurrection.ogg]])
LSM:Register("sound", "Retaliation", [[Interface\AddOns\AlertMe\Media\Sounds\Retaliation.ogg]])
LSM:Register("sound", "Rocket Helmet", [[Interface\AddOns\AlertMe\Media\Sounds\Rocket Helmet.ogg]])
LSM:Register("sound", "Sap Enemy", [[Interface\AddOns\AlertMe\Media\Sounds\Sap Enemy.ogg]])
LSM:Register("sound", "Sap Friend", [[Interface\AddOns\AlertMe\Media\Sounds\Sap Friend.ogg]])
LSM:Register("sound", "Sap", [[Interface\AddOns\AlertMe\Media\Sounds\Sap.ogg]])
LSM:Register("sound", "Scare Beast", [[Interface\AddOns\AlertMe\Media\Sounds\Scare Beast.ogg]])
LSM:Register("sound", "Scatter Shot", [[Interface\AddOns\AlertMe\Media\Sounds\Scatter Shot.ogg]])
LSM:Register("sound", "Seduction", [[Interface\AddOns\AlertMe\Media\Sounds\Seduction.ogg]])
LSM:Register("sound", "Sheep Enemy", [[Interface\AddOns\AlertMe\Media\Sounds\Sheep Enemy.ogg]])
LSM:Register("sound", "Sheep Friend", [[Interface\AddOns\AlertMe\Media\Sounds\Sheep Friend.ogg]])
LSM:Register("sound", "Sheep", [[Interface\AddOns\AlertMe\Media\Sounds\Sheep.ogg]])
LSM:Register("sound", "Shield Wall", [[Interface\AddOns\AlertMe\Media\Sounds\Shield Wall.ogg]])
LSM:Register("sound", "shield", [[Interface\AddOns\AlertMe\Media\Sounds\shield.ogg]])
LSM:Register("sound", "Silence", [[Interface\AddOns\AlertMe\Media\Sounds\Silence.ogg]])
LSM:Register("sound", "Spell Lock", [[Interface\AddOns\AlertMe\Media\Sounds\Spell Lock.ogg]])
LSM:Register("sound", "Sprint", [[Interface\AddOns\AlertMe\Media\Sounds\Sprint.ogg]])
LSM:Register("sound", "Stealth", [[Interface\AddOns\AlertMe\Media\Sounds\Stealth.ogg]])
LSM:Register("sound", "Stoneform", [[Interface\AddOns\AlertMe\Media\Sounds\Stoneform.ogg]])
LSM:Register("sound", "Stunned", [[Interface\AddOns\AlertMe\Media\Sounds\Stunned.ogg]])
LSM:Register("sound", "Sweeping Strikes", [[Interface\AddOns\AlertMe\Media\Sounds\Sweeping Strikes.ogg]])
LSM:Register("sound", "Tremor Totem", [[Interface\AddOns\AlertMe\Media\Sounds\Tremor Totem.ogg]])
LSM:Register("sound", "Trinket", [[Interface\AddOns\AlertMe\Media\Sounds\Trinket.ogg]])
LSM:Register("sound", "Vanish", [[Interface\AddOns\AlertMe\Media\Sounds\Vanish.ogg]])
LSM:Register("sound", "Will of the Forsaken", [[Interface\AddOns\AlertMe\Media\Sounds\Will of the Forsaken.ogg]])
LSM:Register("sound", "Wyvern Sting", [[Interface\AddOns\AlertMe\Media\Sounds\Wyvern Sting.ogg]])
-- backgrounds
LSM:Register("background", "Add", [[Interface\AddOns\AlertMe\Media\Textures\add.tga]])
LSM:Register("background", "Delete", [[Interface\AddOns\AlertMe\Media\Textures\delete.tga]])
LSM:Register("background", "Reset", [[Interface\AddOns\AlertMe\Media\Textures\reset.tga]])
LSM:Register("background", "AlertMe", [[Interface\AddOns\AlertMe\Media\Textures\alertme.tga]])
-- statusbars
LSM:Register("statusbar", "Banto", [[Interface\AddOns\AlertMe\Media\Textures\bantobar.blp]])
