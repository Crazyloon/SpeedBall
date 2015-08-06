
--[[Returns:void - No Description Set]]
function propel_ball(keys)
	local ball = keys.target
	local caster = keys.caster

	local entIndex = ball:GetEntityIndex()
	if GameRules.SPEEDBALL_PARTICLES[entIndex] == nil then
		local particleID = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball)
		ParticleManager:SetParticleControl(particleID, 0, ball:GetAbsOrigin())
		-- Add the particle to the particles table so it can be removed when the ball stops
		GameRules.SPEEDBALL_PARTICLES[entIndex] = particleID
	end
	
	ball:SetTeam(caster:GetTeam())
	ball:SetOwner(caster)
	ball:OnPhysicsFrame(function(unit)
    local speed = unit:GetPhysicsVelocity():Length2D()
    	if speed < 200 and speed > 0 then
	       	unit:SetPhysicsVelocity(Vector(0, 0, 0))
	       	local partID = GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()]
   			ParticleManager:DestroyParticle(partID, true)
   			unit:OnPhysicsFrame(nil)
   			GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()] = nil
    	end
    end)
    
		ball:AddPhysicsVelocity(caster:GetForwardVector() * 5000)
end



function propel_ball_ranged_go(self, unit)
	local ball = unit
	local caster = self.Source

	local entIndex = ball:GetEntityIndex()
	if GameRules.SPEEDBALL_PARTICLES[entIndex] == nil then	
		local particleID = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball)
		ParticleManager:SetParticleControl(particleID, 0, ball:GetAbsOrigin())
		-- Add the particle to the particles table so it can be removed when the ball stops
		GameRules.SPEEDBALL_PARTICLES[entIndex] = particleID
	end
	
	ball:SetTeam(caster:GetTeam())
	ball:SetOwner(caster)
	ball:OnPhysicsFrame(function(unit)
    local speed = unit:GetPhysicsVelocity():Length2D()
    	if speed < 200 and speed > 0 then
	       	unit:SetPhysicsVelocity(Vector(0, 0, 0))
	       	local partID = GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()]
	       	DebugPrint("Particle ID: " .. partID)
	       	DebugPrint("Particle TBL: ")
	       	DebugPrintTable(GameRules.SPEEDBALL_PARTICLES)
   			ParticleManager:DestroyParticle(partID, true)
   			unit:OnPhysicsFrame(nil)
   			GameRules.SPEEDBALL_PARTICLES[unit:GetEntityIndex()] = nil
    	end
    end)
    
		ball:AddPhysicsVelocity(self:GetVelocity():Normalized() * 5000)
end

function propel_ball_ranged(keys)
	local ball = keys.target
	local caster = keys.caster

	-- create a projectile at the casters origin
	local proj ={
			bGroundLock = true,
			fGroundOffset = 80,
			draw = false,
			bRecreateOnChange =  true,
			ControlPoints = {[0]=Vector(0,0,10)},
			EffectName = "particles/dire_fx/tower_bad_face.vpcf",
			fDistance = 2500,
			Source = keys.caster,
			nChangeMax = 90,
			vSpawnOrigin = {unit = keys.caster, attach = "attach_attack1", offset = Vector(0,0,80)}	,		
			UnitTest = function(self, unit) return unit:GetUnitName() == "speedball" end,
			OnUnitHit = function(self, unit)
				unit:EmitSound("Hero_Disruptor.ThunderStrike.Target")
				propel_ball_ranged_go(self, unit)
				self:Destroy()
			end,
			OnFinish = function(self, pos)
				local timerName = GameRules.PROJECTILE_TIMERS[self.Source:GetPlayerID()]
				Timers:RemoveTimer(timerName)
			end
		}
	local projectile = Projectiles:CreateProjectile(proj)

	-- send the projectile to the target origin
	local distance = ball:GetAbsOrigin() - projectile.pos
	local direction = Vector(0, 0, 0)
	local time = 0
	GameRules.PROJECTILE_TIMERS[caster:GetPlayerID()] = Timers:CreateTimer(function()
		distance = ball:GetAbsOrigin() - projectile.pos
	    direction = distance:Normalized()     
	  	projectile:SetVelocity(direction * 1500)
	  	if distance:Length2D() < 150 then
			projectile.bRecreateOnChange = false;
		end
	    return 1/15
	end)

end


function play_attack_sound(keys)
	local ball = keys.target
	local caster = keys.caster

	local random = RandomInt(1, 2)
	DebugPrint("Random: " .. tostring(random) .. "FIRE SOUND")
	if random == 1 then
		StartSoundEvent("Hero_Tinker.Attack", caster)
	else
		StartSoundEvent("Hero_Tinker.Laser", caster)
	end
end


