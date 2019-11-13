do

	local oldModBlueprints = ModBlueprints
	ModBlueprints = function(all_bps)
		oldModBlueprints(all_bps)
		
		for id, bp in all_bps.Unit do
		
			local cats = {}
			for k, cat in bp.Categories do
				cats[cat] = true
			end
			
			if (cats.COMMAND or cats.EXPERIMENTAL) and bp.dontOKControl ~= false then
				if bp.Defense then
					bp.Defense.dontOKControl = true
				
--					LOG('*BM: ' .. bp.Description .. ', ' .. repr(bp.dontOKControl))
				end
				
			end
			
			if bp.Weapon then
			
				for ik, weap in bp.Weapon do

					if not type(weap) == "table" then
						WARN('*BM: some muppet has a non-table entry in Weapons.')
						continue
					end
				
					--	catch dealth weapons here; they don't contribute anything useful.
					if weap.WeaponCategory == 'Death' then
						continue
					end
				
					if not weap.dontOKCheck then
						weap.NeedPrep = true
					end
					
					--	nukes do uber damage, but take fecking ages to do it.
					--	one would still want to shoot at potential targets in the mean-time.
					if cats.STRATEGIC and weap.dontOKSum ~= false then
						weap.dontOKSum = true
					end
					
					--	disable Target Memory(TM, lol Trade Mark) on structures, because they can't chase down fleeing units.
					if cats.STRUCTURE and weap.dontCacheTargets ~= false then
						weap.dontCacheTargets = true
					end
					
					--	weapons that are woefully inaccurate (yes, T3 arty, i'm looking at you)
					--	are excluded because it's just plain-old luck if they hit or not.
					local homing = false
					if weap.ProjectileId then
						homing = all_bps.Projectile[string.lower(weap.ProjectileId)].Physics.TrackTarget
						
					--	WARN('*BM: ' .. repr(weap.ProjectileId))
					--	WARN('*BM: ' .. repr(all_bps.Projectile[string.lower(weap.ProjectileId)].Physics))
					end
					
					if not homing then
						if (weap.FiringRandomness or 0) > 1 and not homing then	--	"and not homing" is for weap.dontPaint code in commented else block.
						
--						LOG('*BM: ' .. repr(bp.Description) .. ' can`t aim for shit.')
						
							if weap.dontOKCheck ~= false then
								weap.dontOKCheck = true
							end
							
							if weap.dontOKSum ~= false then
								weap.dontOKSum = true
							end
						end
					else
						if weap.dontPaint ~= false then
							weap.dontPaint = true
						end	
					end
					
					if not weap.Turreted or weap.ManualFire or (weap.BallisticArc == 'RULEUBA_HighArc') or cats.AIR or cats.ANTIAIR then --	or cats.AIR then
						if weap.dontTerrainCheck ~= false then
							weap.dontTerrainCheck = true
						end
						
						LOG('*BM: ' .. (bp.Description or bp.BlueprintId) .. '\'s ' .. (weap.DisplayName or 'nameless weapon') .. ' won`t do terrain-collision checks.')
					end
					
					if weap.RateOfFire > 2 and weap.dontPaint ~= false then
						weap.dontPaint = true
					end
					
					--LOG('*BM: ' .. repr(bp.BlueprintId))
					--LOG('*BM: ' .. repr(weap.Label))
					--LOG('*BM:\t\tpreps ' .. repr(weap.NeedPrep))
					--LOG('*BM:\t\t!sums ' .. repr(weap.dontOKSum))
					--LOG('*BM:\t\t!checks ' .. repr(weap.dontOKCheck))
					--LOG('*BM:\t\t!terrain ' .. repr(weap.dontTerrainCheck))
					--LOG('*BM:\t\t!paints ' .. repr(weap.dontPaint))
					
				end	--	bp.Weapon loop
				
			end
			
		end	--	all_bps.Unit loop
		
	end	--	ModBlueprints

end