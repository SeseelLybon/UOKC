do

	local oldOnCommandIssued = OnCommandIssued
	function OnCommandIssued(command)
		oldOnCommandIssued(command)
		
	--	SPEW('command issued')
	--	SPEW(repr(command))
		
		if command.CommandType == 'Attack' then
			if command.Clear then
				local cb = { Func = 'ClearCacheTargets', Args = { } }
				
				SimCallback(cb, true)
			end
			
			local cb = { Func = 'AddCacheTarget', Args = { target = command.Target.EntityId, position = command.Target.Position } } 
			
			SimCallback(cb, true)
		end
		
		if command.CommandType == 'Stop' then
			local cc = { Func = 'ClearCacheTargets', Args = { } }
				
			SimCallback(cc, true)
			
			local sp = { Func = 'AddPriorities', Args = { } } 
			
			SimCallback(sp, true)
		end
	end

end