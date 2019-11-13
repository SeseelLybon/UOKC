do

	Callbacks.AddCacheTarget = function(data, units)
	
	--	SPEW('add cache')
		if type(data.target) == 'string' then
			for id, unit in units or {} do
				local e = GetEntityById(data.target)
				
				if not e.hasOKC then
				--	WARN(repr(e))
				
					e = e:GetSource()
				end
				
				unit.OrderedTarget = e
				table.insert(unit.cacheTargets, e)
			end
		else
			WARN('*BM: AddCacheTarget called with missing data.target entity.')
			WARN(repr(data))
		end	
	end
	
	Callbacks.ClearCacheTargets = function(data, units)
	
		for id, unit in units or {} do			
			unit.OrderedTarget = nil
			unit.cacheTargets = {}
		end
	
	end
	
	Callbacks.AddPriorities = function(data, units)
	
		SPEW('add')
	
		for id, unit in units or {} do
			for i = 1, unit:GetWeaponCount() do
				unit:GetWeapon(i):AddWeaponPriorities(data)
			end
		end
	
	end
	
	Callbacks.SetPriorities = function(data, units)
	
		SPEW('set')
		--SPEW(repr(data))
		for id, unit in units or {} do
			unit:SetTargetPriorities(data)
		end
	
	end
	
end