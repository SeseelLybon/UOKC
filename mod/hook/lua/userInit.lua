local oldSetFireState = SetFireState
function SetFireState(units, state)
	--SPEW('SetFireState (hopefully not ON FIRE)')
	
	oldSetFireState(units, state)
	
	--SPEW(repr(state))
	
	if state == 'HoldGround' then
		local cb = { Func = 'SetPriorities', Args = { '' } }
		
		SimCallback(cb, true)
	else
		local cb = { Func = 'AddPriorities', Args = { } } 
		
		SimCallback(cb, true)
	end
end

local oldToggleFireState = ToggleFireState
function ToggleFireState(units, state)
	--SPEW('ToggleFireState')
	--SPEW(repr(state))
	
	oldToggleFireState(units, state)
	
	if state == 2 then
		local cb = { Func = 'SetPriorities', Args = { '' } }
		
		SimCallback(cb, true)
	else
		local cb = { Func = 'AddPriorities', Args = { } } 
		
		SimCallback(cb, true)
	end
end