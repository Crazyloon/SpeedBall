-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = true 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

require('libraries/timers')
require('libraries/physics')
require('libraries/projectiles')
require('libraries/animations')
require('internal/gamemode')
require('internal/events')
require('settings')
require('events')
require('libraries/scoreboard')


GameRules.WELCOME_ALL_PLAYERS_MESSAGE = "Welcome to the arena. Glory awaits you!"   -- Message to show users when the game begins.
GameRules.MAXIMUM_COLLISION_DAMAGE = 400              								              -- The maximum amount of damage a speedball can do on impact.
GameRules.MINIMUM_COLLISION_DAMAGE = 100              								              -- The minimum amount of damage a speedball can do on impact, before armor reduction.
GameRules.ARMOR_DAMAGE_REDUCTION_MULTIPLIER = 5      								                -- Each point of armor reduces the damage of a speedball impact by this value.
GameRules.MAX_LIVES = 5																                              -- The maximum lives each player will start with
GameRules.PLAYER_LIVES = {}	            										                        -- A table to store the lives of each player. format: PlayerID = LivesRemaining
GameRules.PlayersRemaining = 0                                                      -- 
GameRules.SPEEDBALL_PARTICLES	= {}													                        -- A table that can be used to store particleIDs for each ball. format: speedballNPC = particleID
GameRules.SPEEDBALL_ANIMATION_MANAGER = {}                                          -- A table which will be used to store the current timer executing the roll animation.
GameRules.PROJECTILE_TIMERS = {} 
GameRules.PHYSICS_ENTITIES = {}												                              -- assigned in 'CreateEssentialObjects'

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
  local pID = hero:GetPlayerID()
  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(250, false)
  local ability = hero:GetAbilityByIndex(0)
  if ability then 
    ability:SetLevel(1)
  end


  EmitSoundOnClient("announcer_dlc_glados_ann_glados_battle_begin_01", PlayerResource:GetPlayer(hero:GetPlayerID()))
  --hero:EmitSoundParams("announcer_dlc_glados_ann_glados_gamemode_19", 0, 4, 0)

  Physics:Unit(hero)
  hero:SetMass(200)
  hero:SetPhysicsFriction(0.2)
  
  -- Set up this players lives and add them to the lives table
  hero.lives = GameRules.MAX_LIVES
  GameRules.PLAYER_LIVES[hero:GetPlayerID()] = hero.lives
  DebugPrint("LIVES ON SPAWN: " .. hero.lives)
  GameRules.PlayersRemaining = GameRules.PlayersRemaining + 1

  
  CreateAddPlayersToScoreBoard()
  

  -- Stun all heroes until the timer says GO!
  StunPlayerUntilGameStarts(hero)
  -- Add the hero to the physics entities table to track them for collision detection
  GameRules.PHYSICS_ENTITIES[hero:GetEntityIndex()] = hero
  
  DebugPrint("[HERO ADDED TO SPEEDBALL FILTER]")
  -- Give heros a collier
  -- local hero_collider = hero:AddColliderFromProfile("blocker")
  -- hero_collider.radius = 75
  
  -- hero_collider.draw = {color = Vector(50,50,200), alpha = 5, radius = 75}
  -- hero_collider.filter = GameRules.PHYSICS_ENTITIES
  -- hero_collider.test = function(self, hero_collider, collided)
  --     return IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
  --   end
  local teamColor = AddPlayerToScoreBoard(pID)
  if pID > 0 then
    ScoreBoard:Edit({key="COLUMN_HEADER", header=teamColor, visible = false})
  end

end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  

  -- attempt to cause draw distance not to fail (doesn't work usually)
  --SendToServerConsole("sv_cheats 1")
  --SendToServerConsole("r_farz 7000")
  --SendToServerConsole("sv_cheats 0")

  -- set up game physics
  Physics:GenerateAngleGrid()
  
  -- Create speedballs and add them to _self.GameRules.PHYSICS_ENTITIES
  CreateEssentialObjects()  
  
  SetupWelcomeMessageCountDown(GameRules:GetDOTATime(false, false))

  --SetupMusic()
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
  -- local cmdPlayer = Convars:GetCommandClient()
  -- if cmdPlayer then
  --   local playerID = cmdPlayer:GetPlayerID()
  --   if playerID ~= nil and playerID ~= -1 then
  --     -- Do something here for the player who called this command
  --     PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
  --   end
  -- end
  print( '*********************************************' )
end

-- The collider causes impact damage to the collided unit
function ApplyImpactDamage(self, collider, collided)
  local colliderSpeed = collider:GetPhysicsVelocity():Length2D()
  DebugPrint("[BALL SPEED] " .. tostring(colliderSpeed))
  local calculatedDamage = math.min(GameRules.MAXIMUM_COLLISION_DAMAGE, colliderSpeed / 2 - 150)
  calculatedDamage = math.max(GameRules.MINIMUM_COLLISION_DAMAGE, calculatedDamage)
  calculatedDamage = calculatedDamage - (collided:GetPhysicalArmorValue() + 1) * GameRules.ARMOR_DAMAGE_REDUCTION_MULTIPLIER
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
  	speedball:SetMass(15)
  	speedball:AdaptiveNavGridLookahead(true)
  	speedball:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
  	speedball:SetPhysicsFriction(0.02)
  	speedball:SetPhysicsVelocityMax(4500)
  	speedball:FollowNavMesh(true)
  	speedball:SetGroundBehavior(PHYSICS_GROUND_LOCK)
    speedball:OnPhysicsFrame(nil)
    speedball:OnBounce(function(unit, normal)
      EmitGlobalSound("DOTA_Item.Mjollnir.DeActivate")
    end)

  	return speedball
end

function SetupSpeedBallCollider(speedball, colliderName)
	local ball_collider = speedball:AddColliderFromProfile("momentum")
    
  ball_collider.name = colliderName
	ball_collider.radius = 105
	ball_collider.block = true
	--ball_collider.draw = {color = Vector(200,50,50), alpha = 5, radius = 100}
	ball_collider.filter = GameRules.PHYSICS_ENTITIES
	DebugPrint("[SPEEDBALL FILTER CREATED]")
	ball_collider.test = function (self, collider, collided)
	  return (collided.IsRealHero and collided:IsRealHero()) or collided:GetUnitName() == "speedball"-- IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball"
	end
  -- this handles when two balls collide with eachother
	ball_collider.preaction = function(self, collider, collided)	
	  if IsPhysicsUnit(collided) and collided.GetUnitName ~= nil and collided:GetUnitName() == "speedball" then
      -- game sound
      EmitGlobalSound("n_creep_HarpyStorm.ChainLighting")

      -- add a particle to the reflected ball, and track it for deletion
      local entIndex = collided:GetEntityIndex()
      if GameRules.SPEEDBALL_PARTICLES[entIndex] == nil then
        local particleID = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, collided)
        ParticleManager:SetParticleControl(particleID, 0, collided:GetAbsOrigin())
        GameRules.SPEEDBALL_PARTICLES[entIndex] = particleID

        collided:OnPhysicsFrame(function(unit) 
        local speed = unit:GetPhysicsVelocity():Length2D()
        if speed < 200 and speed > 0 then
          unit:SetPhysicsVelocity(Vector(0, 0, 0))
          local partID = GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()]
          --DebugPrintTable(GameRules.SPEEDBALL_PARTICLES)
          ParticleManager:DestroyParticle(partID, true)
          GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()] = nil
          unit:OnPhysicsFrame(nil)
        end
      end)
      end
      -- if balls are not on the same team apply ownership to the slower moving ball from the faster.
	  	if  collided:GetTeam() ~= collider:GetTeam() then
  			local collidedSpeed = collided:GetPhysicsVelocity():Length2D()
  			local colliderSpeed = collider:GetPhysicsVelocity():Length2D()
  			if collidedSpeed < colliderSpeed then
		  		--DebugPrint('[Ownership Transfered] Collider transfers to collided')
			    collided:SetOwner(collider:GetOwner())
			    collided:SetTeam(collider:GetTeam())
		    else
		  		--DebugPrint('[Ownership Transfered] Collided trasnfers to collider')
			    collider:SetOwner(collided:GetOwner())
			    collider:SetTeam(collided:GetTeam())
			  end
			end

		end
	end
	-- postaction is what occurs when the collider detects a pass on its 'test' function. Here we apply damage to the hero a ball collides with.
	ball_collider.postaction = function (self, collider, collided)
		local colliderSpeed = collider:GetPhysicsVelocity():Length2D()
		if collided.IsRealHero and collided:IsRealHero() and colliderSpeed > 200 then
	    ApplyImpactDamage(self, collider, collided)
      local player = PlayerResource:GetPlayer(collided:GetPlayerID())
      StartSoundEvent("Item.Maelstrom.Chain_Lightning", player) 
		end
	end
end

function CreateEssentialObjects()
  local speedball1 = CreateSpeedBall(Vector(-800,0,200))  
  local speedball2 = CreateSpeedBall(Vector(800,0,200))
  local speedball3 = CreateSpeedBall(Vector(0,-800,200))
  local speedball4 = CreateSpeedBall(Vector(0,800,200))

  GameRules.PHYSICS_ENTITIES[speedball1:GetEntityIndex()] = speedball1
  GameRules.PHYSICS_ENTITIES[speedball2:GetEntityIndex()] = speedball2
  GameRules.PHYSICS_ENTITIES[speedball3:GetEntityIndex()] = speedball3
  GameRules.PHYSICS_ENTITIES[speedball4:GetEntityIndex()] = speedball4

  SetupSpeedBallCollider(speedball1, "speedball1")
  SetupSpeedBallCollider(speedball2, "speedball2")
  SetupSpeedBallCollider(speedball3, "speedball3")
  SetupSpeedBallCollider(speedball4, "speedball4")

  DebugPrint("[BAREBONES] Speedballs Created.")
end

function StunPlayerUntilGameStarts(hero)
  -- when the game starts, we want all heros to be immobile game 
  local stunTime = 9
  local gameTime = GameRules:GetDOTATime(false, false)
  if gameTime < stunTime then
    stunTime = stunTime - gameTime
    hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = stunTime})
    local particleID = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
    ParticleManager:SetParticleControl(particleID, 0, hero:GetAbsOrigin())
    Timers:CreateTimer({
      endTime = stunTime,
      callback = function()
        ParticleManager:DestroyParticle(particleID, true)
        return nil
      end
    })
  end
end

function SetupWelcomeMessageCountDown(game_time)
  game_time = math.floor(game_time)
  local timer = Timers:CreateTimer({
    callback = function() 
      game_time = game_time + 1; 
      if game_time < 10 then
        if game_time == 7 then Notifications:TopToAll({text="3...", duration=1.0, style={["font-size"]="120px", color="red"}})
        elseif game_time == 8 then Notifications:TopToAll({text="2...", duration=1.0, style={["font-size"]="120px", color="orange"}})
        elseif game_time == 9 then Notifications:TopToAll({text="1...", duration=1.0, style={["font-size"]="120px", color="yellow"}})
        end
        return 1 
      else
        Notifications:TopToAll({text="GO!", duration=1.0, style={["font-size"]="120px", color="green"}})
        return nil
      end
    end}) 
end

--[[
   This section contains functions necessary to create and manage adding players to the scoreboard.
  call CreateAddPlayersToScoreBoard(hero) inside of OnHeroInGame(hero) to star the scoreboard manager.
]]

local bScoreboardCreated = false
local Team1Header, Team1Name, Team1Lives = nil
local Team2Header, Team2Name, Team2Lives = nil
local Team3Header, Team3Name, Team3Lives = nil -- pink
local Team4Header, Team4Name, Team4Lives = nil -- orange

function CreateAddPlayersToScoreBoard()
  local teamsInGame = {}
  local columnWidth = 80
  
  -- loop through all players and find the longest name...
  if not bScoreboardCreated then
    bScoreboardCreated = true;
    
    for i = 0, 3 do
      local name = PlayerResource:GetPlayerName(i) -- get the first 4 player names
      if name ~= "" and name ~= nil then
        DebugPrint("NAME: " .. name or tostring("NO NAME"))
        teamsInGame[PlayerResource:GetTeam(i)] = "" -- set their team in game = true in an odd way... expect: teamsInGame[2] = ""
        DebugPrint("PLAYER TEAM NUMBER: " .. tostring(PlayerResource:GetTeam(i)))
        local len = string.len(name) * 12
        if len > columnWidth then
          columnWidth = len
        end
      end
    end
    SetupBoard(tostring(columnWidth) .. "px", teamsInGame)
    CreateColumnHeaders(teamsInGame)
  end  
end

function AddPlayerToScoreBoard(pID)
  -- create player under the correct team using team ID's
  local colorAdded = ""
  DebugPrint("Player TEAM: " .. tostring(PlayerResource:GetTeam(pID)))
  if PlayerResource:GetTeam(pID) == 2 then
    ScoreBoard:CreatePlayer({playerID=pID, header="Teal"})  
    colorAdded = "Teal" 
  elseif PlayerResource:GetTeam(pID) == 3 then
    ScoreBoard:CreatePlayer({playerID=pID, header="Yellow"})
    colorAdded = "Yellow"
  elseif PlayerResource:GetTeam(pID) == 6 then
    ScoreBoard:CreatePlayer({playerID=pID, header="Pink"})
    colorAdded = "Pink"
  elseif PlayerResource:GetTeam(pID) == 7 then
    ScoreBoard:CreatePlayer({playerID=pID, header="Orange"})
    colorAdded = "Orange"
  end

  Timers:CreateTimer(5,function()
    local playerName = PlayerResource:GetPlayerName(pID) -- returns player name(does not work in tools)
    DebugPrint("Update Player Lives " .. playerName .. " ID: " .. tostring(pID) )
    ScoreBoard:Update( {key="PLAYER", ID=pID, panel={"Name", "Lives"}, paneltext={playerName,  GameRules.PLAYER_LIVES[pID]}})    
    return 1
  end)
  return colorAdded
end

function SetupBoard(columnWidth, teamsInGame)
  -- Default styling tables
  Team1Header= {height="100%", width="120px", color="teal",  ["border-radius"]="3px"}
  Team1Name= {height="100%", width= columnWidth, color="black",   ["background-color"]="teal",  ["border-radius"]="3px"}
  Team1Lives= {height="100%", width="48px", color="black",   ["background-color"]="teal",  ["border-radius"]="3px"}

  Team2Header= {height="100%", width="64px", color="yellow", ["border-radius"]="3px"}
  Team2Name ={height="100%", width= columnWidth, color="black", ["background-color"]="yellow",  ["border-radius"]="3px"}
  Team2Lives= {height="100%", width="48px", color="black",   ["background-color"]="yellow",  ["border-radius"]="3px"}

  Team3Header= {height="100%", width="64px", color="pink", ["border-radius"]="3px"}
  Team3Name ={height="100%", width= columnWidth, color="black", ["background-color"]="pink",  ["border-radius"]="3px"}
  Team3Lives= {height="100%", width="48px", color="black",   ["background-color"]="pink",  ["border-radius"]="3px"}

  Team4Header= {height="100%", width="64px", color="orange", ["border-radius"]="3px"}
  Team4Name ={height="100%", width= columnWidth, color="black", ["background-color"]="orange",  ["border-radius"]="3px"}
  Team4Lives= {height="100%", width="48px", color="black",   ["background-color"]="orange",  ["border-radius"]="3px"}

  local scoreboardStyle = {}
   -- setup scoreboard headers based on which team slots have been chosen
   -- if teams exist
  if next(teamsInGame) ~= nil then
    for i = 2, 7 do
      if teamsInGame[i] == "" then -- find which teams have players expect teamsinGame[2] = "" (2, 3, 6, 7)
        if i == 2 then
          teamsInGame[i] = "Teal" -- teamsInGame[2] = "Teal"
          table.insert(scoreboardStyle, Team1Header)
        elseif i == 3 then
          teamsInGame[i] = "Yellow" -- teamsInGame[3] = "Yellow"
          table.insert(scoreboardStyle, Team2Header)
        elseif i == 6 then
          teamsInGame[i] = "Pink" -- teamsInGame[6] = "Pink"
          table.insert(scoreboardStyle, Team3Header)
        elseif i == 7 then
          teamsInGame[i] = "Orange" -- teamsInGame[7] = "Orange"
          table.insert(scoreboardStyle, Team4Header)
        end
      end
    end
    DebugPrint("Scoreboard Style: ")
    DebugPrintTable(scoreboardStyle)
  end
  -- with 4 players:
  -- scoreboardStyle = { Team1Header, Team2Header, Team3Header, Team4Header }

  local headerTeams = ""
  local headerTBL = {}
  for i = 2, 7 do
    if teamsInGame[i] == "Teal" or teamsInGame[i] == "Yellow" or teamsInGame[i] == "Pink" or teamsInGame[i] == "Orange" then --~= "" and teamsInGame[i] ~= nil then
      table.insert(headerTBL, teamsInGame[i])
    end      
  end
  -- header = {"Teal", "Yellow", "Pink", "Orange"}
  ScoreBoard:Setup({header=headerTBL, x="10px", headertext={true, true}, headerstyle=scoreboardStyle})
  -- style container
  ScoreBoard:Edit({key="CONTAINER", style={["margin-left"]="50px", ["background-color"]="black"}})
end


function CreateColumnHeaders(teamsInGame)
  local teal = false
  local yellow = false
  local pink = false
  local orange = false

  teal = teamsInGame[2] == "Teal"
  yellow = teamsInGame[3] == "Yellow"
  pink = teamsInGame[6] == "Pink"
  orange = teamsInGame[7] == "Orange"

  DebugPrint("teal: " .. tostring(teal))
  DebugPrint("yellow: " .. tostring(yellow))
  DebugPrint("pink: " .. tostring(pink))
  DebugPrint("orange: " .. tostring(orange))

  if teal then
    ScoreBoard:CreateColumnHeader({name="Name",     header="Teal", visible=true, style=Team1Name})
    ScoreBoard:CreateColumnHeader({name="Lives",    header="Teal", visible=true, style=Team1Lives})
  end
  if yellow then
    ScoreBoard:CreateColumnHeader({name="Name",     header="Yellow", visible=true, style=Team2Name})
    ScoreBoard:CreateColumnHeader({name="Lives",    header="Yellow", visible=true, style=Team2Lives})        
  end
  if pink then
    ScoreBoard:CreateColumnHeader({name="Name",     header="Pink", visible=true, style=Team3Name})
    ScoreBoard:CreateColumnHeader({name="Lives",    header="Pink", visible=true, style=Team3Lives})
  end
  if orange then
    ScoreBoard:CreateColumnHeader({name="Name",     header="Orange", visible=true, style=Team4Name})
    ScoreBoard:CreateColumnHeader({name="Lives",    header="Orange", visible=true, style=Team4Lives})
  end
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

function SetupMusic()
  -- use timers to start music and play a new randomly selected song every couple minutes
end

