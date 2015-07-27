-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = true 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

MAXIMUM_COLLISION_DAMAGE = 400              -- The maximum amount of damage a speedball can do on impact.
MINIMUM_COLLISION_DAMAGE = 100              -- The minimum amount of damage a speedball can do on impact, before armor reduction.
ARMOR_DAMAGE_REDUCTION_MULTIPLIER = 10      -- Each point of armor reduces the damage of a speedball impact by this value.

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(500, false)
  
  -- hero reflects colliding balls
  Physics:Unit(hero)
  hero:SetMass(300)
  hero:SetPhysicsFriction(0.4)

  local hero_collider = hero:AddColliderFromProfile("blocker")
  hero_collider.radius = 100
  
  hero_collider.draw = {color = Vector(50,50,200), alpha = 5, radius = 400}
  hero_collider.test = function(self, hero_collider, collided)
      return IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
    end

  -- end player physics

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_example_item", hero, hero)
  hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  -- set up game physics
  Physics:GenerateAngleGrid()

  -- Create speedballs
  CreateEssentialObjects()

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end

-- The collider causes impact damage to the collided unit
function ApplyImpactDamage(self, collider, collided)
  local colliderSpeed = collider:GetPhysicsVelocity():Length2D()
  DebugPrint("[BALL SPEED] " .. tostring(colliderSpeed))
  local calculatedDamage = math.min(MAXIMUM_COLLISION_DAMAGE, colliderSpeed / 2 - 50)
  calculatedDamage = math.max(MINIMUM_COLLISION_DAMAGE, calculatedDamage)
  calculatedDamage = calculatedDamage - collided:GetPhysicalArmorValue() * ARMOR_DAMAGE_REDUCTION_MULTIPLIER
  if calculatedDamage < 0 then calculatedDamage = 0 end
  local damageTable = {
    victim = collided,
    attacker = collider,
    damage = calculatedDamage,
    damage_type = DAMAGE_TYPE_PURE,
    }
  ApplyDamage(damageTable)
  DebugPrint("[DAMAGE APPLIED] Victim: " .. tostring(collided:GetTeamNumber()) .. " Attacker: " .. tostring(collider:GetTeamNumber()) .. " Damage: " .. tostring(calculatedDamage))
end

function CreateEssentialObjects()
  local speedball1 = CreateUnitByName("speedball", Vector(-800,0,200), true, nil, nil, DOTA_TEAM_NOTEAM)  
  local speedball2 = CreateUnitByName("speedball", Vector(800,0,200), true, nil, nil, DOTA_TEAM_NOTEAM)  
  local speedball3 = CreateUnitByName("speedball", Vector(0,-800,200), true, nil, nil, DOTA_TEAM_NOTEAM)  
  local speedball4 = CreateUnitByName("speedball", Vector(0,800,200), true, nil, nil, DOTA_TEAM_NOTEAM)  

  -- Setup physics for speedballs
  -- speedball1   
  Physics:Unit(speedball1)
  speedball1:SetMass(20)
  speedball1:AdaptiveNavGridLookahead(true)
  speedball1:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  speedball1:SetPhysicsFriction(0.01)
  speedball1:SetPhysicsVelocityMax(4000)
  speedball1:FollowNavMesh(true)
  speedball1:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  speedball1:OnPhysicsFrame(function(unit) 
    if unit:GetPhysicsVelocity():Length2D() < 100 then
       unit:SetPhysicsVelocity(Vector(0, 0, 0))
     end
    end)

  -- speedball2  
  Physics:Unit(speedball2)
  speedball2:SetMass(20)
  speedball2:AdaptiveNavGridLookahead(true)
  speedball2:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  speedball2:SetPhysicsFriction(0.01)
  speedball2:SetPhysicsVelocityMax(4000)
  speedball2:FollowNavMesh(true)
  speedball2:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  speedball2:OnPhysicsFrame(function(unit) 
    if unit:GetPhysicsVelocity():Length2D() < 100 then
       unit:SetPhysicsVelocity(Vector(0, 0, 0))
     end
    end)

  -- speedball3   
  Physics:Unit(speedball3)
  speedball3:SetMass(20)
  speedball3:AdaptiveNavGridLookahead(true)
  speedball3:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  speedball3:SetPhysicsFriction(0.01)
  speedball3:SetPhysicsVelocityMax(4000)
  speedball3:FollowNavMesh(true)
  speedball3:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  speedball3:OnPhysicsFrame(function(unit) 
    if unit:GetPhysicsVelocity():Length2D() < 100 then
       unit:SetPhysicsVelocity(Vector(0, 0, 0))
     end
    end)

  -- speedball4 
  Physics:Unit(speedball4)
  speedball4:SetMass(20)
  speedball4:AdaptiveNavGridLookahead(true)
  speedball4:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  speedball4:SetPhysicsFriction(0.01)
  speedball4:SetPhysicsVelocityMax(4000)
  speedball4:FollowNavMesh(true)
  speedball4:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  speedball4:OnPhysicsFrame(function(unit) 
    if unit:GetPhysicsVelocity():Length2D() < 100 then
       unit:SetPhysicsVelocity(Vector(0, 0, 0))
     end
    end)


  -- Here we apply damage to the hero a ball collides with.
  -- we also transfer the colliders team to the collided on impact (goal here is a player can hit one ball into another which then hits a player)
  -- the ball keeps track of the attacker to track who kills who - this may cause some players to feel cheated if a ball does not
  -- transfer ownership properly, consider faster ball wins out, also would be cool if two balls crashed face on and trasfered ownership
  -- causing both players to get hit by the other.

  -- create momentum colliders using BMD's Physics Library
  local ball_collider1 = speedball1:AddColliderFromProfile("momentum")
  local ball_collider2 = speedball2:AddColliderFromProfile("momentum")
  local ball_collider3 = speedball3:AddColliderFromProfile("momentum")
  local ball_collider4 = speedball4:AddColliderFromProfile("momentum")
    
  -- BALL 1
  ball_collider1.blockRadius = 200
  ball_collider1.draw = {color = Vector(200,50,50), alpha = 5, radius = 200}
  ball_collider1.test = function (self, collider, collided)
    return (collided.IsRealHero and collided:IsRealHero()) or IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  end
  ball_collider1.preaction = function(self, collider, collided)
    print("pre: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin()))
  end
  -- postaction is what happens when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
  ball_collider1.postaction = function (self, collider, collided)
    print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin())) -- DEBUG
    if collided.IsRealHero and collided:IsRealHero() and collider:GetPhysicsVelocity():Length2D() > 300 then
      ApplyImpactDamage(self, collider, collided)
    elseif IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
      collided:SetOwner(collider)
    end
  end

  -- BALL 2
  ball_collider2.blockRadius = 200
  ball_collider2.draw = {color = Vector(200,50,50), alpha = 5, radius = 200}
  ball_collider2.test = function (self, collider, collided)
    return (collided.IsRealHero and collided:IsRealHero()) or IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  end
  ball_collider2.preaction = function(self, collider, collided)
    print("pre: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin()))
  end
  -- postaction is what happens when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
  ball_collider2.postaction = function (self, collider, collided)
  print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin())) -- DEBUG
    if collided.IsRealHero and collided:IsRealHero() and collider:GetPhysicsVelocity():Length2D() > 300 then
      ApplyImpactDamage(self, collider, collided)
    elseif IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
      collided:SetOwner(collider)
    end
  end

  -- BALL 3
  ball_collider3.blockRadius = 200
  ball_collider3.draw = {color = Vector(200,50,50), alpha = 5, radius = 200}
  ball_collider3.test = function (self, collider, collided)
    return (collided.IsRealHero and collided:IsRealHero()) or IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  end
  ball_collider3.preaction = function(self, collider, collided)
    print("pre: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin()))
  end
  -- postaction is what happens when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
  ball_collider3.postaction = function (self, collider, collided)
  print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin())) -- DEBUG
    if collided.IsRealHero and collided:IsRealHero() and collider:GetPhysicsVelocity():Length2D() > 300 then
      ApplyImpactDamage(self, collider, collided)
    elseif IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
      collided:SetOwner(collider)
    end
  end

  -- BALL 4
  ball_collider4.blockRadius = 200
  ball_collider4.draw = {color = Vector(200,50,50), alpha = 5, radius = 200}
  ball_collider4.test = function (self, collider, collided)
    return (collided.IsRealHero and collided:IsRealHero()) or IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  end
  ball_collider4.preaction = function(self, collider, collided)
    print("pre: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin()))
  end
  -- postaction is what happens when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
  ball_collider4.postaction = function (self, collider, collided)
  print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin())) -- DEBUG
    if collided.IsRealHero and collided:IsRealHero() and collider:GetPhysicsVelocity():Length2D() > 300 then
      ApplyImpactDamage(self, collider, collided)
    elseif IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
      collided:SetOwner(collider)
    end
  end


  DebugPrint("[BAREBONES] Speedballs Created.  FROM gamemode.lua")
end