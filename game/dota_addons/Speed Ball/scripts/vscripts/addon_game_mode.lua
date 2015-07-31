-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")
  -- BAREBONES PRECACHE
  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)



  --- SPEEDBALL PRECACHE
  -- PrecacheResource('Type', 'fileext', context)
  -- PrecacheResource('Valid Modes: particle, particle_folder, model, model_folder, and soundfile', '.vpcf, .vsnd, .vsndevts', context)
  -- PARTICLES
  PrecacheResource('particle', 'particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf', context)
  PrecacheResource('particle', 'particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient_e.vpcf', context)

  -- SOUND
  --PrecacheResource('soundfile', 'sounds/weapons/hero/omniknight/purification.vsnd', context)
  PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/voscripts/game_sounds_vo_announcer_dlc_glados.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/game_sounds_items.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/game_sounds_creeps.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/music/dsadowski_01/soundevents_music.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/music/jbrice_01/soundevents_music.vsndevts', context)
  PrecacheResource('soundfile', 'soundevents/music/valve_ti5/soundevents_music.vsndevts', context)

  -- ITEMS
  -- UNITS
  -- MODELS

-- ------------------
-- Game:
-- ------------------
-- OnGameStarts:
--   sounds/vo/announcer_dlc_glados/ann_glados_event_neg_23.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_battle_begin_01.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_battle_begin_follow.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_battle_prepare_06.vsnd

-- OnGameEndLose:
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_neg_02.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_neg_04.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_neg_08.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_neg_20.vsnd

-- OnGameEndWin:
--   First Play: sounds/vo/announcer_dlc_glados/ann_glados_victory_01.vsnd
--   Then 1 of:
--   sounds/vo/announcer_dlc_glados/ann_glados_vict_follow_01.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_vict_follow_04.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_vict_follow_05.vsnd

-- OnWaitingForGameToClose
--   sounds/music/dsadowski_01/music/countdown.vsnd

-- ------------------
-- SpeedBalls:
-- ------------------
-- OnBallHitWall:
--   sounds/items/item_mjoll_off.vsnd

-- OnBallHitBall:
--   sounds/weapons/creep/neutral/harpystorm_transfer_01.vsnd
--   sounds/weapons/creep/neutral/harpystorm_transfer_02.vsnd
--   sounds/weapons/creep/neutral/harpystorm_transfer_03.vsnd
--   sounds/weapons/creep/neutral/harpystorm_transfer_04.vsnd

-- OnBallHitPlayer:
--   sounds/items/item_mael_lightning_01.vsnd
--   sounds/items/item_mael_lightning_02.vsnd
--   sounds/items/item_mael_lightning_03.vsnd
--   sounds/items/item_mael_lightning_04.vsnd
--   sounds/items/item_mael_lightning_05.vsnd

-- OnPlayerHitBall:
--   sounds/weapons/hero/tinker/attack.vsnd
--   sounds/weapons/hero/tinker/laser.vsnd

-- OnSpeedBallRolling:
--   sounds/items/item_mjoll_loop.vsnd

-- ------------------
-- Players:
-- ------------------

-- OnPlayersFirstSpawn:
--   sounds/vo/announcer_dlc_glados/ann_glados_gamemode_19.vsnd

-- OnPlayerKills:
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_pos_01.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_vict_follow_01.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_neutral_followup_02.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_pos_02.vsnd
  
-- OnPlayerKilled:
--   sounds/vo/announcer_dlc_glados/ann_glados_followup_respaw_09.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_event_neg_15.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_event_neg_02.vsnd

-- OnPlayerSpawn:
--   sounds/vo/announcer_dlc_glados/ann_glados_ally_neg_10.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_followup_respaw_17.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_prelim_11.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_prelim_19.vsnd
--   sounds/vo/announcer_dlc_glados/ann_glados_followup_respaw_13.vsnd


-- ------------------
-- Other:
-- ------------------
-- AmbientSounds:


-- BackgroundMusic:
--   sounds/music/dsadowski_01/music/roshan.vsnd
--   sounds/music/dsadowski_01/music/roshan_end.vsnd
--   -
--   sounds/music/jbrice_01/music/battle_01_1.vsnd
--   sounds/music/jbrice_01/music/battle_01_2.vsnd
--   sounds/music/jbrice_01/music/battle_01_end.vsnd
--   -
--   sounds/music/tutorial04.vsnd
--   -
--   sounds/music/valve_ti5/music/battle_01.vsnd
--   sounds/music/valve_ti5/music/battle_01_end.vsnd
--   sounds/music/valve_ti5/music/battle_02.vsnd
--   sounds/music/valve_ti5/music/battle_02_end.vsnd
--   sounds/music/valve_ti5/music/battle_03.vsnd
--   sounds/music/valve_ti5/music/battle_03_end.vsnd


end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
end