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

-- This library can be used for starting customized animations on units from lua
require('libraries/animations')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

WELCOME_ALL_PLAYERS_MESSAGE = "Welcome to Speed Ball. Glory awaits you" 	-- Sets the message that displays to all players when the game clock starts at 0
MAXIMUM_COLLISION_DAMAGE = 400              								-- The maximum amount of damage a speedball can do on impact.
MINIMUM_COLLISION_DAMAGE = 100              								-- The minimum amount of damage a speedball can do on impact, before armor reduction.
ARMOR_DAMAGE_REDUCTION_MULTIPLIER = 10      								-- Each point of armor reduces the damage of a speedball impact by this value.
MAX_LIVES = 5																-- The maximum lives each player will start with
PLAYER_LIVES = {}	--Unused												-- A table to store the lives of each player. format: PlayerID = LivesRemaining
SPEEDBALL_PARTICLES	= {}													-- A table that can be used to store particleIDs for each ball. format: speedballNPC = particleID

local entTbl_SpeedBalls = {}												-- assigned in 'CreateEssentialObjects'

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
  PrecacheItemByNameAsync("item_example_item", function(...) end)
  PrecacheItemByNameAsync("example_ability", function(...) end)

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
  local teamNumber = hero:GetTeam()
  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(500, false)
  
  -- hero reflects colliding balls
  Physics:Unit(hero)
  hero:SetMass(250)
  hero:SetPhysicsFriction(0.3)
  hero.lives = MAX_LIVES
  PLAYER_LIVES[hero:GetPlayerID()] = hero.lives
  DebugPrint("LIVES ON SPAWN: " .. hero.lives)

  --hero:ApplyDataDrivenModifier(hero, hero, "modifier_lives", {lives = 5})
  --hero:AddNewModifier(hero, nil, "modifier_lives", {lives = 1})

  -- This block gives a player a passive ability to track their lives. Currently the system is to save lives in hero.lives and
  -- simply display a message to the user everytime they spawn, saying they have 5 lives.
		  -- local playerLivesAbility = hero:GetAbilityByIndex(3)
		  -- playerLivesAbility:SetLevel(1)
		  -- playerLivesAbility:CastAbility()
		  -- hero:SetModifierStackCount("modifier_lives", hero, 5)


  -- add each hero that spawns to the list of things balls should collide with
  local sbCollidersTable = entTbl_SpeedBalls[1]:GetColliders() -- gets the filter table from the first ball (doesn't matter which one)

  for k,v in pairs(sbCollidersTable) do
	table.insert(sbCollidersTable[k].filter, hero)
  end
  DebugPrint("[HERO ADDED TO SPEEDBALL FILTER]")
  
  DebugPrint("[END SOME DEBUG]")
  -- local hero_collider = hero:AddColliderFromProfile("blocker")
  -- hero_collider.radius = 50
  
  -- hero_collider.draw = {color = Vector(50,50,200), alpha = 5, radius = 200}
  -- hero_collider.filter = entTbl_SpeedBalls
  -- hero_collider.test = function(self, hero_collider, collided)
  --     return IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  --   end
  -- endof player physics



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

  -- attempt to cause draw distance not to fail
  SendToServerConsole("r_farz 7000")
  -- set up game physics
  Physics:GenerateAngleGrid()

  -- Create speedballs and add them to _self.entTbl_SpeedBalls
  CreateEssentialObjects()

  DebugPrint("[NOTIFICATION] ")
  
  -- Send a notification to all players that displays up top for 5 seconds
  Notifications:TopToAll({text="Top Notification for 5 seconds ", duration=5.0})
  Notifications:TopToAll({text="Welcome to the Speed Ball Arena. Glory awaits you!", duration=5.0, style={color="green"}})
  Timers:CreateTimer(3, -- Start this timer 30 game-time seconds later
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
  local calculatedDamage = math.min(MAXIMUM_COLLISION_DAMAGE, colliderSpeed / 2 - 150)
  calculatedDamage = math.max(MINIMUM_COLLISION_DAMAGE, calculatedDamage)
  calculatedDamage = calculatedDamage - collided:GetPhysicalArmorValue() * ARMOR_DAMAGE_REDUCTION_MULTIPLIER
  if calculatedDamage < 0 then calculatedDamage = 0 end
  local damageTable = {
    victim = collided,
    attacker = collider:GetOwnerEntity(),
    damage = calculatedDamage,
    damage_type = DAMAGE_TYPE_MAGICAL,
    }
  ApplyDamage(damageTable)
  DebugPrint("[DAMAGE APPLIED] Victim: " .. tostring(collided:GetTeamNumber()) .. " Attacker: " .. tostring(collider:GetTeamNumber()) .. " Damage: " .. tostring(calculatedDamage))
end

function CreateSpeedBall(locationVector)
	local speedball = CreateUnitByName("speedball", locationVector, true, nil, nil, DOTA_TEAM_NOTEAM)
	Physics:Unit(speedball)
  	speedball:SetMass(20)
  	speedball:AdaptiveNavGridLookahead(true)
  	speedball:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  	speedball:SetPhysicsFriction(0.02)
  	speedball:SetPhysicsVelocityMax(4000)
  	speedball:FollowNavMesh(true)
  	speedball:SetGroundBehavior(PHYSICS_GROUND_ABOVE)
  	speedball:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  	speedball:OnPhysicsFrame(function(unit) 
    	if unit:GetPhysicsVelocity():Length2D() < 200 then
       		unit:SetPhysicsVelocity(Vector(0, 0, 0))
       		local partID = SPEEDBALL_PARTICLES[unit:GetEntityIndex()]
       		DebugPrint("Particle ID: " .. partID)
   			ParticleManager:DestroyParticle(partID, true)
    	end
    end)
  	return speedball
end

function SetupSpeedBallCollider(speedball, colliderName)
	local ball_collider = speedball:AddColliderFromProfile("momentum")
    
    ball_collider.name = colliderName
	ball_collider.radius = 100
	ball_collider.block = true
	ball_collider.draw = {color = Vector(200,50,50), alpha = 5, radius = 200}
	ball_collider.filter = entTbl_SpeedBalls
	DebugPrint("[SPEEDBALL FILTER CREATED]")
	ball_collider.test = function (self, collider, collided)
	  return (collided.IsRealHero and collided:IsRealHero()) or collided:GetUnitName() == "speedball"-- IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
	end
	ball_collider.preaction = function(self, collider, collided)	
	  if IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
		  	-- if colliders are not on the same team, transpose ownership
		  	StartSoundEventFromPositionReliable("n_creep_HarpyStorm.ChainLighting", collided:GetOrigin())
			StartSoundEventFromPositionReliable("n_creep_HarpyStorm.ChainLighting", collider:GetOrigin())
		  	if  collided:GetTeam() ~= collider:GetTeam() then
		  		-- find which ball is traveling faster, transfer ownership from the fastest to the slowest.
	  			local collidedSpeed = collided:GetPhysicsVelocity():Length2D()
	  			local colliderSpeed = collider:GetPhysicsVelocity():Length2D()
	  			if collidedSpeed < colliderSpeed then
			  		DebugPrint('[Ownership Transfered] Collider transfers to collided')
				    collided:SetOwner(collider:GetOwner())
				    collided:SetTeam(collider:GetTeam())
			    else
			  		DebugPrint('[Ownership Transfered] Collided trasnfers to collider')
				    collider:SetOwner(collided:GetOwner())
				    collider:SetTeam(collided:GetTeam())
				end
				DebugPrint("Sounds Should Fire")
			end
		end
	end
	-- postaction is what occurs when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
	-- or copy ownership of one ball to another.
	ball_collider.postaction = function (self, collider, collided)
		local colliderSpeed = collider:GetPhysicsVelocity():Length2D()	
		--print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin())) -- DEBUG
		if collided.IsRealHero and collided:IsRealHero() and colliderSpeed > 200 then
		    ApplyImpactDamage(self, collider, collided)
		    StartSoundEvent("Item.Maelstrom.Chain_Lightning", PlayerResource:GetPlayer(collided:GetPlayerID())) 
		end
	end
end

function CreateEssentialObjects()
  local speedball1 = CreateSpeedBall(Vector(-800,0,200))  
  local speedball2 = CreateSpeedBall(Vector(800,0,200))
  local speedball3 = CreateSpeedBall(Vector(0,-800,200))
  local speedball4 = CreateSpeedBall(Vector(0,800,200))

  entTbl_SpeedBalls = {speedball1, speedball2, speedball3,  speedball4}

  SetupSpeedBallCollider(speedball1, "speedball1")
  SetupSpeedBallCollider(speedball2, "speedball2")
  SetupSpeedBallCollider(speedball3, "speedball3")
  SetupSpeedBallCollider(speedball4, "speedball4")

  DebugPrint("[BAREBONES] Speedballs Created.  FROM gamemode.lua")
end

-----------------------------------------
--------------- Utilities ---------------
-----------------------------------------
function TableCombine(t1, t2)
	for i=1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end