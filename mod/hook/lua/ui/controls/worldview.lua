do
	local oldWorldView = WorldView
	WorldView = Class(oldWorldView)
	{
		HandleEvent = function(self, ev)
			local res = oldWorldView.HandleEvent(self, ev)
			
			local rollOver = GetRolloverInfo()
			
			if ev.Type == 'ButtonDClick' and ev.Modifiers.Right  and rollOver then
				if IsKeyDown('Menu') then	--	Target ONLY that type.
					local cb = { Func = 'SetPriorities', Args = { rollOver.blueprintId } }
					
					SimCallback(cb, true)
				else
					local cb = { Func = 'AddPriorities', Args = { rollOver.blueprintId } } 
					
					SimCallback(cb, true)
				end
					
				return true
			end
			
			return res
		end,
	}
end