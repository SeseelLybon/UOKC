local oldNavigator = Navigator
Navigator = Class(oldNavigator)
{
	SetGoal = function(self, v)
		SPEW(repr(v))
		
		oldNavigator.SetGoal(self, v)
	end,
	
	SetDestUnit = function(self, e)
		SPEW('set dest unit')
		
		self.destination = e
		
		oldNavigator.SetDestUnit(self, e)
	end,
	
	GetDestUnit = function(self)
		return self.destination
	end,
}