do

	local oldCollisionBeam = CollisionBeam
	CollisionBeam = Class(oldCollisionBeam)
	{
		OnCreate = function(self)
			oldCollisionBeam.OnCreate(self)
			
		--	CreateBeamToEntityBone(self, 0, self, 1, self:GetArmy(), 0.01, '/textures/particles/ramp_white_01.dds')
		--	CreateAttachedBeam(self, 0, self:GetArmy(), 25, 0.01, '/textures/particles/ramp_white_01.dds')
		end,
	
		Enable = function(self, painter)
		
		--	LOG('*BM: called Enable(' .. repr(painter or false) .. ').')
		
			if painter then
				self.Painting = true
			else
				self.Firing = true
			end
			
			if self.Painting or self.Firing then
				oldCollisionBeam.Enable(self)
			end
			
		end,
		
		OnEnable = function(self)
		--	LOG('*BM: OnEnable.')
		
			if self.Firing then
				oldCollisionBeam.OnEnable(self)
			end
		end,
		
		Disable = function(self, painter)
		
		--	LOG('*BM: called Disable(' .. repr(painter or false) .. ').')
			
			if painter then
				self.Painting = false
			else
				self.Firing = false
			end
			
		--	LOG('*BM:\tPainting = ' .. repr(self.Painting))
		--	LOG('*BM:\tFiring = ' .. repr(self.Firing))
			
			if not self.Firing then
				if not self.Painting then
					oldCollisionBeam.Disable(self)
				end
				
				self:OnDisable()	--	the engine only calls OnDisable if the 
			end						--	engine's Disable function is called.
									--	we often will want to pretend we've disabled 
		end,						--	the beam, but still keep the painter going.
		
		OnDisable = function(self)
		
		--	LOG('*BM: OnDisable.')
		
			if not self.Firing then
				oldCollisionBeam.OnDisable(self)
			end
		end,
		
		IsEnabled = function(self)
			return self.Firing and oldCollisionBeam.IsEnabled(self)
		end,
		
		OnImpact = function(self, with, who)
			
		--	CreateBeamToEntityBone(self, 0, self, 1, self:GetArmy(), 0.01, '/textures/particles/ramp_white_01.dds')
			
			if self.Painting then
			--	LOG('*BM: IMPACT: painting.')
				
				local distance = VDist3(self:GetPosition(0), self:GetPosition(1))
				local k = who
				
				if type == 'Shield' then
					k = who:GetParent()
				end
				
				self.Weapon.Painter:Report(self, k, distance)
			end
			
			if self.Firing then
			--	LOG('*BM: IMPACT: *** PEW!')
			
				oldCollisionBeam.OnImpact(self, with, who)
			end
			
		end,
	}
end