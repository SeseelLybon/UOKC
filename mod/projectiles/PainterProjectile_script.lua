--local Projectile = import('/lua/sim/projectile.lua').Projectile
--local Entity = import('/lua/sim/Entity.lua').Entity
PainterProjectile = Class(moho.projectile_methods)
{
	--__post_init = function(self, spec)
	--	LOG('*BM: beep.')
	--end,
	
	PassPaintData = function(self, data)
		self.CollideFriendly = data.CollideFriendly
		self.Painter	= data.Painter
		self.Muzzle		= data.Muzzle
	end,
	
	GetCollideFriendly = function(self)
		return self.CollideFriendly
	end,
    	
	OnImpact = function(self, what, with)
	--	LOG('*BM: paint projectile impact.')
		
		local k = with
		
		if what == 'Shield' and with:GetParent():GetBlueprint().Defense.Shield.PersonalShield then
			k = with:GetParent()
		end
		
		self.Painter:Report(self, k)
		
		self:Destroy()
	end,
	
	OnCollisionCheck = function(self, other)
		if IsProjectile(other) then
			WARN('*BM: HIT A PROJECTILE. LOL.')
		end
	
		return not IsProjectile(other)
	end,
}
TypeClass = PainterProjectile