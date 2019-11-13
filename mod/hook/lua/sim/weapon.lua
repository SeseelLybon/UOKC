do
	local DistanceBetweenEntities = import('/lua/utilities.lua').GetDistanceBetweenTwoEntities

	local oldWeapon = Weapon
	Weapon = Class(oldWeapon)
	{
		OnCreate = function(self)
			local bp = self:GetBlueprint()
			
		--	WARN("moho.CAiAttackerImpl_methods")
		--	WARN(repr(moho.CAiAttackerImpl_methods))
			
			--	table to hold a cache of targets for the Target Memory.
			--self.targetCache = {}
			
			self.OKC = {
				dontOKCheck			= bp.dontOKCheck,
				dontOKSum			= bp.dontOKSum,
				dontCacheTargets	= bp.dontCacheTargets,
				RETARGET_SUCCESS	= nil, 
			}
			
			self.maxRadius = bp.MaxRadius or 0
			self.curRadius = bp.MaxRadius or 0
			
			oldWeapon.OnCreate(self)
		end,
		
		GetCurrentTargetP = function(self)
			
			local c = self:GetCurrentTarget()
			
			if c.hasOKC then
				return c
			elseif c.GetSource then
				return c:GetSource()
			elseif not c then
				return nil	--	nothing to shoot at!
			else
				WARN('GetCurrentTarget is broken!')
				WARN(repr(c))
			end
		
		end,
		
		GetDamageTable = function(self)
			local damageTable = oldWeapon.GetDamageTable(self)
			
			if not self.OKCPass then	--	signifies that CreateProjectileForWeapon didn't hook.
				damageTable.OKCData = self:GetOKCTable()
			end
						
			return damageTable
		end,	--	GetDamageTable
		
		GetOKCTable = function(self)
			local OKCTable	= {}
			local bp		= self:GetBlueprint()
			
			OKCTable.Weapon		= self
			OKCTable.dontOKSum	= self.OKC.dontOKSum
			OKCTable.FiredAt	= self:GetCurrentTargetP()
			OKCTable.firedPos	= self.unit:GetPosition()
			
			OKCTable.range		= self.maxRadius	--	maxRadius is the weapon's max range *without* terrain checks.
			OKCTable.priorities	= bp.TargetPriorities
			
			local pos = self:GetCurrentTargetPos()
			if pos then
				OKCTable.shortLife = VDist3(OKCTable.firedPos, pos) < (bp.MuzzleVelocity or 0) * 0.5	--	a short life is anything less than 0.5 seconds.
			end
			
			return OKCTable
		end,	--	GetOKCTable
		
		CreateProjectileForWeapon = function(self, bone)
			self.OKCPass = true	--	create a flag to check if CreateProjectileForWeapon hasn't been hooked properly.
								--	as in the case of the Cybran torpedo launchers and UEF Flak AA.
			local proj = oldWeapon.CreateProjectileForWeapon(self, bone)
			
			proj:PassOKCData(self:GetOKCTable())
			proj:PassPaintData( { CollideFriendly = self.DamageData.CollideFriendly, Painter = self.Painter, Muzzle = bone } )

			return proj
		end,	--	CreateProjectileForWeapon		
		
		--	TARGETTING.
	
		--	guess what;
		--	you can hook, or overload this function 
		--		with something specific to your weapon.
		--	have this function return true if you 
		--		want to choose a new target.
		--	it's the weapon's job to decide if the current 
		--		target isn't any good; *not* the target's. 
		ShouldTarget = function(self, target)
			
			if not target then
				return false
			end
			
			if not target.hasOKC then
			--	Perf('no OKC')
				LOG('ShouldTarget')
				LOG(repr(target))
			end
			
		--	Perf('targetting check')
			
			return target:GetBlueprint().Defense.dontOKControl or not target:WillDie()
			
		end,	--	ShouldTarget
		
		ShouldRetarget = function(self)
			return not self:ShouldTarget(self:GetCurrentTargetP())
		end,
		
		HasCacheTargets = function(self)
		
			for k, ent in self.unit.cacheTargets do
				if ent.Dead or ent:BeenDestroyed() then
				--	LOG('removing from cache.')
				
					table.remove(self.unit.cacheTargets, k)
				end
			end
			
			--LOG(repr(self.unit.cacheTargets))
			
			return table.getn(self.unit.cacheTargets) > 0 
			
		end,
		
		IsTargetCached = function(self, target)
		
			for k, ent in self.unit.cacheTargets do
				if ent.Dead or ent:BeenDestroyed() then
				--	LOG('removing from cache.')
				
					table.remove(self.unit.cacheTargets, k)
				end
			end
		
			return table.find(self.unit.cacheTargets, target) and true
			
		end,
		
		DoRetarget = function(self, range)
			if not self.RetargetThread then
				self.RetargetThread = self:ForkThread(self.Retarget, range)
			end
		end,
		
		DoRetargetCheck = function(self)
		
			local currentTarget	= self:GetCurrentTargetP()
			
			--	build arms use Weapon code, and trip OnWeaponFired but don't have a target.
			if (not currentTarget) or currentTarget:BeenDestroyed() or self.unit.Dead then
				return	--	whoops.
			end
			
			if self:ShouldRetarget() or (not self:IsTargetCached(currentTarget) and self:HasCacheTargets()) then
			--	if self:GetBlueprint().DisplayName == 'Molecular Ripper Cannon' then			
			--		LOG('*BM: DoRetargetCheck called Retarget because a better target was found.')
			--	end
				
				return self:Retarget()				
			end
		
		end,
		
		Retarget = function(self, customRange)
			--	are there any cached targets? (at all)
			--	yes:
			--		get all nearby cached targets.
			--	no:
			--		get all nearby filter targets.
			--
			--	find a target for pwning.
			--		pwn it.
						
		--	WaitTicks(1)	--	wait. why am I doing this again? 
							--	projectiles get OKC data and also pass the DIF 
							--	to their targets before OnWeaponFired triggers.
							
			local currentTarget	= self:GetCurrentTargetP()
			local bp = self:GetBlueprint()
			local targetList = {}

			if self:HasCacheTargets() and not self.OKC.dontCacheTargets then
				
				local unitPos = self.unit:GetPosition()
				
				for id, entity in self.unit.cacheTargets do
					if (not entity:BeenDestroyed()) and VDist3(unitPos, entity:GetPosition()) < (customRange or self.curRadius) then
						table.insert(targetList, entity)
					end
				end
				
			else
			
				if bp.TargetPriorities then	
					--	manually prime the targetCats variable so we can add to it later.
					local targetCats = ParseEntityCategory(bp.TargetPriorities[1])
					
					--	build a list of target categories to filter out some suitable targets.
					for id, cat in bp.TargetPriorities do
						if cat ~= 'ALLUNITS' then
							targetCats = targetCats + ParseEntityCategory(cat)
						end
					end
					
					targetList = ArmyBrains[self.unit:GetArmy()]:GetUnitsAroundPoint(targetCats or ParseEntityCategory('ALLUNITS'), self.unit:GetPosition(), customRange or (self.curRadius * bp.TrackingRadius), 'Enemy')
					
				end
				
			end
			
			for id, target in targetList do
			
				if target:BeenDestroyed() then
					continue
				end
				
				if self:ShouldTarget(target) then
				
					self:SetTargetEntity(target)
					
					if currentTarget == self:GetCurrentTarget() then
					--	Perf('switch fail')
					else
					--	Perf('switch pass')
						
						return target
					end
				
				end
			end
			
		--	LOG('*BM:\tdone retargetting.')
			
			return nil
			
		end,	--	Retarget
		
		ChangeMaxRadius = function(self, value, noStore)
			oldWeapon.ChangeMaxRadius(self, value)
			
			if not noStore then
				self.maxRadius = value
			else
				self.curRadius = value
			end
		end,	--	ChangeMaxRadius
		
		RestoreMaxRadius = function(self)
--			LOG('*BM: restored MaxRadius.')
		
			self:ChangeMaxRadius(self.maxRadius)
			
			self.curRadius = self.maxRadius
		end,	--	RestoreMaxRadius
		
		ShrinkMaxRadius = function(self, by)
			self:ChangeMaxRadius(self.curRadius - (by or 1), true)
		end,	--	ShrinkMaxRadius
		
		OrderedAttack = function(self)
		
			--	want, weapon's current target AND unit's current attack target.
			local w = self:GetCurrentTarget()
			local u = self.unit:GetTargetEntity()
			
			--LOG(repr(getmetatable(weaponTarget)))
			--LOG(repr(w.GetSource))
			
			if w.GetSource then
				w = w:GetSource()
			end
			
			if u.GetSource then
				u = u:GetSource()
			end
				
			return w == u	
			
		end,
		
		IsPrimaryWeapon = function(self)
			return self:GetBlueprint() == self.unit:GetBlueprint().Weapon[1]
		end,
		
		SetWeaponEnabled = function(self, en)
			self.weaponEnabled = en
			
		--	SPEW('weapon enabled ' .. repr(en))
			
			oldWeapon.SetWeaponEnabled(self, en)
		end,
		
		GetWeaponEnabled = function(self)
			return self.weaponEnabled
		end,
		
		AddWeaponPriorities = function(self, pri)
			local priorityTable = {}
			
			if type(pri) == 'table' then
				for k, v in pri do
					table.insert(priorityTable, ParseEntityCategory(v))
				end
			end
			
			local bp = self:GetBlueprint().TargetPriorities
			
			if bp then
				for k, v in bp do
					table.insert(priorityTable, ParseEntityCategory(v))
				end
			end
			
			self:SetTargetingPriorities(priorityTable)
		end,
	}	--	Weapon	
end