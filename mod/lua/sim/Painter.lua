NullPainter = Class
{
	SetEnabled	= function(self, en) end,
	OnWeaponAboutToFire = function(self) end,
	Report		= function(self, who, with, distance) end,
	Evaluate	= function(self) end,
}

Painter = Class
{	
	__init = function(self, spec)
		self.Weapon = spec.Weapon
		
		if not self.Weapon then
			WARN('*BM: *** OMG! NO WEAPON DEFINED.')
		end
		
		self.Enabled = false
		
		self.paintHit		= 0
		self.paintMissed	= 0
		self.paintTotal		= 0
		self.paintDistance	= 0
	end,
	
	__post_init = function(self, spec)
		if self.OnCreate then self:OnCreate(spec) end
	end,
	
	OnCreate = function(self)
		self.muzzles = {} 
		
		for ir, rack in self.Weapon:GetBlueprint().RackBones do
			self.paintTotal = self.paintTotal + table.getn(rack.MuzzleBones)
			
			for im, muzzle in rack.MuzzleBones do
				table.insert(self.muzzles, muzzle)
			end
		end
		
	end,
	
	OnWeaponAboutToFire = function(self)
		self:SetEnabled(true)
	end,
	
	SetEnabled	= function(self, en) end,
	
	Evaluate	= function(self)
		
	--	if self.Weapon:GetBlueprint().DisplayName == 'Molecular Ripper Cannon' then
	--		LOG('*BM: Evaluating... ' .. self.paintHit .. ' / ' .. self.paintMissed)
	--	end
		
		if self.paintHit + self.paintMissed == self.paintTotal then
			if self.paintHit < self.paintMissed then
			--	LOG('*BM:\tfailed obstruction check. :(')
				
				--	if it's a secondary weapon:
				--		retarget from a reduced range.
				--	if it's a primary weapon:
				--		if firing freely:
				--			retarget from a reduced range.
				--		otherwise:
				--			reduce range and move in closer. 
			
				if self.Weapon:IsPrimaryWeapon() and self.Weapon:OrderedAttack() then
					self.Weapon:ChangeMaxRadius(self.paintDistance / self.paintMissed, true)
					
				--	if self.Weapon:GetBlueprint().DisplayName == 'Molecular Ripper Cannon' then
				--		LOG('*BM: Eval fail:\tChanged weapon radius (primary target).')
				--	end
				else
					if not self.Weapon:Retarget(self.paintDistance / self.paintMissed) then
						self.Weapon:Retarget()
						
					--	if self.Weapon:GetBlueprint().DisplayName == 'Molecular Ripper Cannon' then
					--		LOG('*BM: Eval fail:\tRetarget with full distance checks.')
					--	end
					else
					--	if self.Weapon:GetBlueprint().DisplayName == 'Molecular Ripper Cannon' then
							LOG('*BM: Eval fail:\tRetarget with reduced range.')
					--	end
					end
					
				--	LOG('*BM:\t\tlooked for a different target.')
				end
			else
			--	LOG('*BM:\tpassed obstruction check! :D')
				
				self.Weapon:RestoreMaxRadius()
			end
			
			self.paintDistance	= 0
			self.paintHit		= 0
			self.paintMissed	= 0
		end
		
	--	LOG('*BM:\tfinished evaluation.')
		
	end,
	
	Report = function(self, who, with)
		
		if self.Weapon:BeenDestroyed() then return end	--	lol.
		
		local currentTarget = self.Weapon:GetCurrentTargetP()
		
		if not currentTarget then return end
		
		if with.GetSource then
			with = with:GetSource()
		end
		
	--	LOG('*BM:\tprojectile reported to painter.')
	--	
	--	SPEW(repr(with))
	--	SPEW(repr(currentTarget))
		
		if with == currentTarget then
			self.paintHit = self.paintHit + 1
			
		--	LOG('*BM:\tincremented hits.')
		else
			--	did the projectile went past the unit?
			--	no:
			--		count it as a miss.
			--	yes:
			--		ignore it.
			
			local launchPos = self.Weapon.unit:GetPosition(who.Muzzle)
			local D1 = VDist3(launchPos, who:GetPosition())
			local D2 = VDist3(launchPos, currentTarget:GetPosition())
			if D1 < D2 then
				self.paintMissed = self.paintMissed + 1
				self.paintDistance = self.paintDistance + D2 - D1
				
			--	LOG('*BM:\tincremented misses.')
			else
				return
			end
		end
		
		self:Evaluate()
		
	end,
}

ProjectilePainter = Class(Painter)
{
	--OnWeaponAboutToFire = function(self)
		--self:SetEnabled(true)
	--end,
	
	SetEnabled = function(self, en)
	--	LOG('*BM: *** Painter:SetEnabled(' .. repr(en) .. ')')
	
		if en and not self.Enabled then	--	ala. if we want it enabled now, and it wasn't already enabled.
			self.Weapon:ForkThread(self.PaintThreadFunction, self)
		end
		
		self.Enabled = en
	end,
	
	PaintThreadFunction = function(self, painter)
		
	--	LOG('*BM: Spun-off PaintThreadFunction.')
		
		local bp = '/mods/UOKC WIP19/projectiles/PainterProjectile_proj.bp'
		
		while painter.Enabled and not self:BeenDestroyed() do
			
			self:ChangeProjectileBlueprint(bp)
			
			for id, muzzle in painter.muzzles do
			--	LOG('*BM: pew!')
				
				local proj = self:CreateProjectile(muzzle)
				
				proj:PassPaintData( { CollideFriendly = self:GetBlueprint().CollideFriendly or false, Painter = painter, Muzzle = muzzle } )
			end
			
			self:ChangeProjectileBlueprint(self:GetBlueprint().ProjectileId)
			
			WaitTicks(2)
		end
		
	end,
}

BeamPainter = Class(Painter)
{
	OnCreate = function(self)
	
		self.Beams	= {}
		
		for id, beamTable in self.Weapon.Beams do
			table.insert(self.Beams, beamTable.Beam)
			
			beamTable.Beam.Painter = self
		end
		
		self.paintTotal = table.getn(self.Beams)
		
	end,
	
	OnWeapnAboutToFire = function(self)
		self:SetEnabled(true)
	end,
	
	SetEnabled = function(self, en)
	
	--	LOG('*BM: *** BEAM PAINTER SET ' .. repr(en and true))
		
		if self.enabled == en then
			return
		end
		
		self.enabled = en
		
		if en then
			for id, Beam in self.Beams do
				Beam:Enable(true)
			end
		else
			for id, Beam in self.Beams do
				Beam:Disable(true)
			end
		end
	
	end,
	
	Report = function(self, who, with, distance)
		local currentTarget = self.Weapon:GetCurrentTargetP()
		
		if not (with and currentTarget) then return end	--	lol.
		
		if with.GetSource then
			with = with:GetSource()
		end
		
	--	LOG('*BM:\tbeam reported to painter.')
				
		if with == currentTarget then
			self.paintHit = self.paintHit + 1
			
		--	LOG('*BM:\tincremented hits.')
		else
			
			--	painting closer than the target?
			--	yes:
			--		did we hit another entity?
			--		yes:
			--			carry on.
			--		no:
			--			hangle miss.
			--	no:
			--		carry on. 
			
			

			
			local delta = VDist3(who:GetPosition(1), currentTarget:GetPosition())
			
			--if distance + delta < self.Weapon.curRadius then
			if distance < VDist3(who:GetPosition(0), currentTarget:GetPosition()) then
				self.paintDistance	= self.paintDistance + delta
				self.paintMissed	= self.paintMissed + 1
				
			--	LOG('*BM:\tincremented misses.')
			end
		end
		
		self:Evaluate()
	end,
}
