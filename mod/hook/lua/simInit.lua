do
	local numberOfShenanigans = 0
	function Shenanigans(msg)
		numberOfShenanigans = numberOfShenanigans + 1
		LOG('*BM: Shenanigans! [' .. repr(numberOfShenanigans) .. '] ' .. msg)
	end
	
	local perfTable = {}
	function Perf(key, every)
	
		if perfTable[key] then
			perfTable[key].count = perfTable[key].count + 1
		else
			perfTable[key] = { count = 1, e = every } 
		end
		
		if (not perfTable[key].e) or math.mod(perfTable[key].count, perfTable[key].e) == 0 then
			LOG('*BM: ' .. key .. ' = ' .. perfTable[key].count)
		end
		
	end

	function GetPerf()
		return perfTable
	end
	
	local WillDie = function(self)
		return self:GetDamageInFlightF() > 1.125	--	if the unit has enough damage-in-flight to be over-killed by more than 1.25%, we assume that the unit will die.
	end
	
	local GetDamageInFlightF = function(self)
		return self:GetDamageInFlight() / self:GetHealth()
	end
	
	local GetDamageInFlight = function(self)
		return self.damageInFlight[1] + self.damageInFlight[2]	--	return the sum of tracking and non-tracking DIFs. 
	end
	
	local AddDamageInFlight = function(self, damage, tracking)
		if tracking then
			self.damageInFlight[1] = self.damageInFlight[1] + damage
		else
			self.damageInFlight[2] = self.damageInFlight[2] + damage
		end
	end
	
	local SubDamageInFlight = function(self, damage, tracking)
		if tracking then
			self.damageInFlight[1] = self.damageInFlight[1] - damage
		else
			self.damageInFlight[2] = self.damageInFlight[2] - damage
		end
	end
	
	function AddOKCFunctions(t)
		t.hasOKC = true
		t.damageInFlight = { 0, 0 }
		t.WillDie				= t.WillDie or WillDie
		t.GetDamageInFlight		= t.GetDamageInFlight or GetDamageInFlight
		t.GetDamageInFlightF	= t.GetDamageInFlightF or GetDamageInFlightF
		t.AddDamageInFlight		= t.AddDamageInFlight or AddDamageInFlight
		t.SubDamageInFlight		= t.SubDamageInFlight or SubDamageInFlight
		t.GetDamageInFlight		= t.GetDamageInFlight or GetDamageInFlight
	end

end

--doscript '/lua/sim/Painter.lua'