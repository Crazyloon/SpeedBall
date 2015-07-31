
--[[Returns:void - No Description Set]]
function propel_ball(keys)
	
	--local caster = GetCaster()
	local ball = keys.target
	local caster = keys.caster

	PrintTable(keys)
	DebugPrint('ball: ' .. tostring(IsPhysicsUnit(ball)))
	
	ball:SetTeam(caster:GetTeam())
	ball:SetOwner(caster)
	ball:AddPhysicsVelocity(caster:GetForwardVector() * 8000)



	local entIndex = ball:GetEntityIndex()
	local particleID = ParticleManager:CreateParticle("particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball)
	ParticleManager:SetParticleAlwaysSimulate(particleID)
	ParticleManager:SetParticleControl(particleID, 0, ball:GetAbsOrigin())
	
	SPEEDBALL_PARTICLES[entIndex] = particleID
	DebugPrint("[PARTICLE CREATED] ID: " .. particleID .. " ballindex: " .. entIndex)
	DebugPrintTable(SPEEDBALL_PARTICLES)
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


