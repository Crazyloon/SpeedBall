--propel_ball = class({})

--[[Returns:void - No Description Set]]
function propel_ball(keys)
	
	--local caster = GetCaster()
	local ball = keys.target
	local caster = keys.caster

	PrintTable(keys)
	DebugPrint('ball: ' .. tostring(IsPhysicsUnit(ball)))
	
	ball:SetOwner(caster)
	ball:AddPhysicsVelocity(caster:GetForwardVector() * 8000) 
end
--[[ Psudo ]]
--[[function propel_ball()
	{
		local caster = GetCaster()
		local ball = GetSpellTarget()
		local travelDirection = caster:GetForwardVector();

		ball:ApplyForce(travelDirection, caster:GetPower()) // GetPower should look at the players strength and apply a force based on that stat.
	}]]

