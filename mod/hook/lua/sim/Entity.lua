do

	local oldEntity = Entity
	Entity = Class(oldEntity)
	{
		OnCreate = function(self, spec)
			self.damageInFlight = { 0, 0 }	--	decided to do this in a table, and key the types as bools, so I can remove branching from the code. 
			
			oldEntity.OnCreate(self, spec)
		end,
	
		WillDie = function(self)
			return self:GetDamageInFlightF() > 1.125	--	if the unit has enough damage-in-flight to be over-killed by more than 1.25%, we assume that the unit will die.
		end,
		
		GetDamageInFlightF = function(self)
			return self:GetDamageInFlight() / self:GetHealth()
		end,
		
		GetDamageInFlight = function(self)
			return self.damageInFlight[1] + self.damageInFlight[2]	--	return the sum of tracking and non-tracking DIFs. 
		end,
		
		AddDamageInFlight = function(self, damage, tracking)
			if tracking then
				self.damageInFlight[1] = self.damageInFlight[1] + damage
			else
				self.damageInFlight[2] = self.damageInFlight[2] + damage
			end
		end,
		
		SubDamageInFlight = function(self, damage, tracking)
			if tracking then
				self.damageInFlight[1] = self.damageInFlight[1] - damage
			else
				self.damageInFlight[2] = self.damageInFlight[2] - damage
			end
		end,
	}

end