do
	local oldProjectile = Projectile
	Projectile = Class(oldProjectile)
	{	
		OnCreate = function(self, inWater)
			oldProjectile.OnCreate(self, inWater)
			
			AddOKCFunctions(self)
		end,

		--	have to do this to get Cybran torpedos working.
		--	they use a custom weapon:CreateProjectileForWeapon functon that doesn't hook.
		PassDamageData = function(self, damageData)
			oldProjectile.PassDamageData(self, damageData)
			
			if damageData.OKCData then
				self:PassOKCData(damageData.OKCData)	--	yes; we're passing this to ourself.
			end
			
			damageData.OKCData = nil	--	delete the old data, we copied it.
		end,

		PassOKCData = function(self, data)	--	map everything passed in 'data' to a local 'OKCData' table.

			self.OKCData	= data
			self.Target		= data.FiredAt
			
			if data.FiredAt and not data.FiredAt.hasOKC then
				WARN('no OKC')
				WARN('PassOKCData')
				WARN(repr(data.FiredAt))
			end
			
			local tracking = self:GetBlueprint().Physics.TrackTarget 			
			if tracking and data.Weapon:ShouldRetarget() and self.Trash then	--	for some reason I'm seeing errors accessing the trash bag.
				self:ForkThread(self.RetargetThread)
			elseif self.Target then
				self.Target:AddDamageInFlight(self.DamageData.DamageAmount or 0, tracking or data.shortLife)
			end
			
		end,
		
		PassPaintData = function(self, data)
			self.CollideFriendly = data.CollideFriendly
			self.Painter	= data.Painter
			self.Muzzle		= data.Muzzle
		end,
		
		OnLostTarget = function(self)	--	unsure when this would ever occur.
		
		--	LOG('*BM: Projectile lost a Target.')
			
			if self:GetBlueprint().Physics.TrackTarget then
				self.Retargetting = self:ForkThread(self.RetargetThread)
			else
				oldProjectile.OnLostTarget(self)
			end
		end,
		
		--	this function must always be forked off; it may need to wait one tick to fetch data from the weapon.
		RetargetThread = function(self)
		
		--	Perf('projectile')
			
			if self.OKCData.priorities and not self.OKCData.dontOKCheck then
			
				local targetCats = ParseEntityCategory(self.OKCData.priorities[1])
				
				for id, cat in self.OKCData.priorities do
					if cat ~= 'ALLUNITS' then
						targetCats = targetCats + ParseEntityCategory(cat)
					end
				end
								
				local targetList = ArmyBrains[self:GetArmy()]:GetUnitsAroundPoint(targetCats or ParseEntityCategory('ALLUNITS'), self.OKCData.firedPos, self.OKCData.range, 'Enemy')
	
				for id, target in targetList do
					if target:BeenDestroyed() then
						continue
					end
										
					if self.OKCData.Weapon:ShouldTarget(target) then
						self:TrackTarget(false)
						self:SetNewTarget(target)
						self:TrackTarget(true)
						
						if self.OKCData.FiredAt == self:GetTrackingTarget() then
						--	Perf('redirect fail')
						else
						--	Perf('redirect pass')
							
							self.Target = target

							self.Target:AddDamageInFlight(self.DamageData.DamageAmount or 0, true)
							
							break
						end
						
					end
				end
			end
		
		end,
		
		OnImpact = function(self, what, with)
		
			if self.DamageData.DamageAmount and self.Target and not self.OKCData.dontOKSum then
				if not self.Target.hasOKC then
				--	Perf('no OKC')
					LOG('OnImpact')
					LOG(repr(self.Target))
				end
			
				self.Target:SubDamageInFlight(self.DamageData.DamageAmount, self:GetBlueprint().Physics.TrackTarget or self.OKCData.shortLife)
			end
			
			if self.Painter then
				local k = with
				
				if what == 'Shield' and with:GetParent():GetBlueprint().Defense.Shield.PersonalShield then
					k = with:GetParent()
				end
				
				---SPEW(repr(self.OKCData))
				
				self.Painter:Report(self, k)
			end

			oldProjectile.OnImpact(self, what, with)
			
		end,
	}

--	PainterProjectile = Class(moho.projectile_methods)
--	{
--		OnImpact = function(self, what, with)
--			self.Weapon.Painter:Report(self, what, with)
--		end,
--	}

end