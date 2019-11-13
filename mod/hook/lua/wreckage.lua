do
	local oldWreckage = Wreckage
	Wreckage = Class(oldWreckage)
	{
		OnCollisionCheck = function(self, other)
			return true
		end,
	}
end