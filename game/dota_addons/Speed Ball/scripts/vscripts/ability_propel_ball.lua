
--[[Returns:void - No Description Set]]
function propel_ball(keys)
	
	--local caster = GetCaster()
	local ball = keys.target
	local caster = keys.caster

	local entIndex = ball:GetEntityIndex()
	if GameRules.SPEEDBALL_PARTICLES[entIndex] == nil then
		--local particleID = ParticleManager:CreateParticle("particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball)
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
	ball:AddPhysicsVelocity(caster:GetForwardVector() * 5000)

	-- Timers:CreateTimer(function()
 --      ball:SetAngles(90, 0, 0)
 --      return 0.1
 --    end
 -- )

	--play_attack_sound(keys)
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


