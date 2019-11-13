do

	local oldProp = Prop
	Prop = Class(oldProp)
	{
		OnCreate = function(self, spec)
			self.damageInFlight = 0
			
			oldProp.OnCreate(self, spec)
		end,
	
		WillDie = function(self)
			return self.damageInFlight > self:GetHealth()
		end,
		
		GetDamageInFlight = function(self)
			return self.damageInFlight
		end,
		
		AddDamageInFlight = function(self, damage, tracking)
			if tracking then
				self.damageInFlightTracking = (self.damageInFlightTracking or 0) + (damage or 0)
			else
				self.damageInFlight = (self.damageInFlight or 0) + (damage or 0)
			end
		end,
		
		SubDamageInFlight = function(self, damage, tracking)
			if tracking then
				self.damageInFlightTracking = (self.damageInFlightTracking or 0) - (damage or 0)
			else
				self.damageInFlight = (self.damageInFlight or 0) - (damage or 0)
			end
		end,
		
		OnDamage = function(self, instigator, amount, vector, damageType)
			if self.damageInFlight < 0 then
				self.damageInFlight = 0
			end
			
--			LOG('*BM: a Prop fired an OnDamage() event.')
			
			oldProp.OnDamage(self, instigator, amount, vector, damageType)
		end
	}
end