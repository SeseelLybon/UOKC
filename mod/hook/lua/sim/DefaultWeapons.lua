do
	local painters = import('/lua/sim/Painter.lua')
	local oldProjectileWeapon = DefaultProjectileWeapon
	DefaultProjectileWeapon = Class(oldProjectileWeapon)
	{
		PainterType = painters.ProjectilePainter,	--	hahaha, hacks. 
		
		OnCreate = function(self)
			oldProjectileWeapon.OnCreate(self)
			
			local bp = self:GetBlueprint()
			
			if bp.dontTerrainCheck then
				self.Painter = painters.NullPainter()
			elseif self:GetBlueprint().dontPaint then 
				self.Painter = painters.Painter { Weapon = self }
			else
				self.Painter = self.PainterType { Weapon = self }
			end
			
		end,
		
	--	OnFire = oldProjectileWeapon.OnFire,	--	This creates the "ambiguous in class definition" bug FOR EVERYTHING.
												--	Clearly, any weapon script that defines an OnFire outside a state will
												--		also create the bug.
		
		--OnWeaponFired = function(self)
			--oldProjectileWeapon.OnWeaponFired(self)
			--
			--self:DoRetarget()
		--end,
		
		IdleState = State(oldProjectileWeapon.IdleState)
		{
			Main = function(self)
			
			--	LOG('*BM: *** IDLE. ' .. self:GetBlueprint().DisplayName)
			
				oldProjectileWeapon.IdleState.Main(self)
				
				self:RestoreMaxRadius()
				
				self.Painter:SetEnabled(false)
			end,
		},
		
		RackSalvoChargeState = State(oldProjectileWeapon.RackSalvoChargeState)
		{
			Main = function(self)
				self.Painter:SetEnabled(true)
				
				oldProjectileWeapon.RackSalvoChargeState.Main(self)
			end,
		},
		
		RackSalvoFireReadyState = State(oldProjectileWeapon.RackSalvoFireReadyState)
		{
			Main = function(self)
				
			--	LOG('*BM: *** READY. ' .. self:GetBlueprint().DisplayName)
			
				self:DoRetargetCheck()
			
			--	self.Painter:SetEnabled(not self.unit:IsMoving())
				self.Painter:SetEnabled(self:GetWeaponEnabled())
				
				oldProjectileWeapon.RackSalvoFireReadyState.Main(self)
			end,
			
			OnFire = function(self)
			--	if not self:DoRetargetCheck() then
					oldProjectileWeapon.RackSalvoFireReadyState.OnFire(self)
			--	end
			end,
		},
		
		RackSalvoFiringState = State(oldProjectileWeapon.RackSalvoFiringState)
		{
			Main = function(self)
				
			--	LOG('*BM: *** FIRING! ' .. self:GetBlueprint().DisplayName)
				
				self.Painter:OnWeaponAboutToFire()
				
				oldProjectileWeapon.RackSalvoFiringState.Main(self)
			end,
			
			OnLostTarget = oldProjectileWeapon.RackSalvoFiringState.OnLostTarget,
		},
	}
	
	local oldBeamWeapon = DefaultBeamWeapon
	DefaultBeamWeapon = Class(oldBeamWeapon)
	{
		PainterType = painters.BeamPainter,
	}	--	DefaultProjectileWeapon

end