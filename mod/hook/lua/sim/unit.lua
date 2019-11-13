do
	local oldUnit = Unit
	Unit = Class(oldUnit)
	{
		OnPreCreate = function(self)
			self.cacheTargets = {}			--	put some targets in here to shoot at.
			
			oldUnit.OnPreCreate(self)
			
			--	GODDAMMIT. these functions aren't being passed in the tables returned by weapon:GetCurrentTarget()
			--	we have to force the pricks in there in the same way that lets tables and threads be passed.
			AddOKCFunctions(self)
		end,

		OnMotionHorzEventChange = function(self, new, old)
			
		--	SPEW('turn')
			
		--	for i = 1, self:GetWeaponCount() do
		--		self:GetWeapon(i):RestoreMaxRadius()
		--	end
			
			--	since we've accelerated, most damage won't hit us any more.
			--	hence, we should clear out our damageInFlight.
			self.damageInFlight[1] = 0
			
			oldUnit.OnMotionTurnEventChange(self, new, old)
		end,
		
		OnMotionVertEventChange = function(self, new, old)
		
			self.damageInFlight[1] = 0
			
			oldUnit.OnMotionVertEventChange(self, new, old)
		end,
	}

end