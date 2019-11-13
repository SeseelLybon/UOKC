do
	local oldBlip = Blip
	Blip = Class(oldBlip)
	{
		OnCreate = function(self, spec)
			self.Spec = spec
			
			AddOKCFunctions(self)
		end,
	}
end