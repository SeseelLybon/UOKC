Ultimate Over-Kill Control WIP1A, for Forged Alliance.

By BulletMagnet (CookieMONSTERa on GPGNet).

Thanks to the combined brain-power of the GPGNet forum,
	especially Neruz for putting up with me pestering him with questions.

README:
	--	Installation.
	--	Change Log,
	--	Description,
	--	Questions and Answers,
	--	Note to modders,



Installation Instructions: (for those who can't nut-it-out themselves.)

Copy the "UOKC" folder/zip and all it's contents to;

	%USERPROFILE%\My Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Mods\

or for Vista users;

	%USERPROFILE%\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Mods\

* NOTE: you can copy-paste the above address to any window in Windows (XP or Vista) and it will work, magically.



Change Log: (just so it's clear what is meant to happen.)

WIP01:
	Initial Release; Work-In-Progress.

WIP02:
	Started adding OKC for homing weapons.
	Made some general improvements.

WIP03:
	Hopefully finished OKC for all homing weapons.

WIP04:
	Fixed a nasty bug involving Lobos' Shell-Cam.
	
WIP05:
	SAMs and Torpedoes retarget and limit OK.
	
WIP06:
	Oops. there was a bug, for some reason something is shooting at units without the AddDamageInFlight() function.
	
WIP07: 
	Improved (read: made my own) code to re-target.
	Misc. improvements.
	
WIP08:
	Fixed bugs introducted from WIP07. >.<
	
WIP09:
	TrackaTarget(self) is NOT a valid function name. doh!
	
WIP0A:
	Intermediate version to trial terrain-collision checking.
	
WIP0B:
	First terrain-collision checking version fit for public consumption.
	
WIP0C:
	Possibly fixed bug that sent TMLs homing (yes, OMFG homing 6k bolts of the Apocalypse)
		after surviving encounters with Aeon TMD (which works by temporarily enabling homing).
	Improved Readme file; a truck-load of stuff for modders to use.
	Prevented high-arc weapons from doing terrain-checks.
	Innaccurate weapons (currently, those with FiringRandomness > 1) now set 
		--	dontOKCheck,
		--	dontOKSum,
		to true by default because they're piss-poor shots!
		
WIP0D:
	Fixed bugs introduced in WPI0C completely disabled terrain-collision checks (oh Lordy, i should be locked up).
	Removed the uber log-spam that killed performance faster than stock AIs.
	
WIP0E:
	Changed the ranging algorithm slightly so it should work better.
	Realised the cause of the error in WIP06 
		--	shooting at things that don't have AddDamageInFlight(self, damage)
		--	TMD don't shoot at units: they shoot at projectiles,
		--	the projectile class doesn't have that function.
	
WIP0F:
	UOKC should now [work] for all projectiles and entities too!
	
WIP10:
	Re-implemented some error corrections, in the event that they may be needed.
	Fixed a really weird error that just defies explanation.
	
WIP11:
	Added the Painter class.
		--	cut down CollisionBeam used for checking target collision before firing.
		--	defaults on all weapons that have RoF < 2.
				*	not enabled by default on AA and aircraft.
		--	add dontPaint = <true/false>, to manually enable/disable painting per-weapon.
	
WIP12:
	Improved the use of the Painter class some-what.
		--	painter is enabled just before the weapon fires.
		--	hooked weapon firing states to do much of the calculation in the same tick.
				*	has some issues, have an idea to fix it too.
	
WIP13:
	Discovered (and fortunately fixed) a HUGE bug with ALL BEAM WEAPONS.
		--	DefaultBeamWeapon class wasn't properly inheriting my changes from the DefaultProjtileWeapon class.
		--	explains lots of bugs I've been randomly seeing with the Cybran faction. FUUUuuu---
	Fixed a bug where weapons weren't correctly checking if they should retarget.
	Added a table to weapons that stores OKC data.
		--	OKC data should now be modifyable in-game via script and upgrade events.
	
WIP14:
	MEGAHUGECHANGESGALOUR.
		--	too many changes to list from memory, 
		--	and i'm a lazy bastard and didn't write them in as i went.
		
WIP15:
	***	CHANGED THE GUID!
		--	new GUID is: "db2292e8-62d7-4a46-a0c2-fd00d2d5b6b1"
	Commented out the line of code that didn't get commented in WIP14.
		--	a big HAHAHA to the person that downloaded it, even though i didn't announce it.
	Fixed SAM and Torpedo mid-flight redirection.
	Fixed the missing curly-bracket in UnitBlueprint example at the bottom of this README.
	
WIP16:
	Fixed the Cybran Nanite Torpedo.
		--	GPG's scripters are retarded, and overwrote a critically important function instead of hooking it.
	
WIP17:
	Fixed a small bug where homing weapon damage wasn't considered when calculating if a unit was to expected to die or not.
	Added a 12.5% overkill margin of error. I'll probably remove it later, but it's there for now. 
	
	*** NEW FEATURE!
		--	added a mechanism for weapons to remember the most recent player-ordered target and re-target that if given a move order.
		--	you can now tell your tank-blob to attack the fleeing enemy ACU, and then issue a move order to near it and expect 
			your tanks to shoot at the ACU first, if they are actually within range. 
		--	this was originally requested as a feature for Sup2, by niplfsh in; http://forums.gaspowered.com/viewtopic.php?p=676825
				*	since it was so awesome, and easy to do; i added it here.
				
WIP18:
	Updated Note to Modders section README with details on the Target Memory.
	
	*** THANKS TO DEADMG.
		--	he helped me with the Target Memory stuff.
		--	i can't remember what he actually did, though.
	
	Hacked the Class constructor in Class.lua so that it does *something* when finding ambiguities.
		--	never understood what ambiguities existed, nor could i fix it.
		
WIP19:
	Changed the targetting memory stuff to work for any number of queued targets, and will work when the order is given. 
		--	as opposed to just the last attack target, and only applying after the weapon fires at the target.
		
	Re-wrote LOTS of code. 
		--	After a few months busy with university work, I look over my code and finds dozens-and-dozens of mistakes and silly concepts.
		--	Changed the retargetting algorithms in the weapon and homing projectils. They actually make sense now. 
		
	Removed the terrain-checking code. 
		--	Basically; it sucked. 
		--	Without re-writing GPG's entire Weapon class, I don't think I can fit in a decent bit of code to do this. And since
			re-writing that would break mod-compatibility with a lot of mods, it's going to stay out and maybe come back as a seperate mod.
		--	Removed the Class constructor hack because that was only added for target checking (I hope).
		
WIP1A:
	Fixed beams weapon animations activating when they shouldn't have been. 
	
	Fixed a bug with the target memory when attacking ground. 
		--	Can't cache nothing, can we?
		--	Thank Zinetwin for the report.
	
	Re-worked Attack-Ground.
		--	Units won't pick up targets by themselves, but can still be told to attack things.
		--	Trivia:
				*	Units can possibly have any number of firing states.
				*	The three default states are;
				*		"ReturnFire" doesn't actually return fire at all and just attacks whatever the hell it can.
				*		"HoldGround" which is supposed to be attack ground, but still attacks whatever the hell it can.
				*		"HoldFire" the only state that acts like it says-on-the-tin.
		
	***	NEW FEATURE!
		--	Double right-clicking on an enemy will tell the selected units to attack that unit,
			and then any other unit of that exact type!
				*	This makes economy raiding, or taking out AA, much easier. 
		--	Holding 'ALT' While doing this will tell units to attack that - and only that - type of unit. 
				*	I don't think this is incredibly useful, but it wasn't hard to do and if it serves someone well then I'm happy.
		--	If a weapon can't see/shoot any of that unit type it'll just use it's normal targetting rules.
		--	Issuing a stop command will tell selected units to act normally.


Description: (what the hell does this mod do?)

Who here hates it when your Percivals (for example) all fire upon a lone Engineer, and waste the better part of 4,000 damage?

I know I do, hence why I made the Ultimate Over-Kill Control mod. for SupCom.



A Quick Q&A: (should address some concerns that you might have.)

Q: How does it work?
A: Magic!
	--	Every unit is given extra settings to see if they should check their fire, and if other units should/not minimise OK on them.
	--	ACUs, SCUs, and T4s are all targets you'd want to blow-up doubly-quick, so they are set so units will ignore OKC checks.

Q: Does it work on custom units?
A: Sure should! I've added some script to configure existing custom units to use/not OKC.
	--	Modders can manually configure their units to use/ignore this as they see fit.

Q: Does this work with vanilla Supreme Commander?
A: I think so, but I haven't checked. Please feel free to try and let us know of the results.

Q: It doesn't work!!!
A: there's two bugs I'm still in the process of squashing, and I've also seen some units still become grossly OKed.
	--	Currently, if multiple weapons fire at the same target in the same tick, OKC checks won't take effect and there *may* be gross Over-Kill.

Q: It doesn't work, at all!!!
A: Sorry about that, i'm only a part-time modderer (university takes priority over mods). If you shout at me for a while, I might fix it.
	--	Better yet, take a look at the code and suggest fixes; you'll get due credit for any improvements you can make.



Note to Modders: (if you want to use some of UOKC features in your mods.)

The various features of UOKC can be enabled/disabled for specific units and weapons, allowing custom units to perform exactly as desired.

The options available include;
	--	an option to check if a unit should intentionally *not* have OKC applied,
			*	this is useful for ACUs and T4 units that you *really* want to kill.
	--	options to make individual weapons not do OKC checks and fire as per standard behaviour, 
			and not include their damage in future OKC checks.
			*	innaccurate or high RoF weapons will benefit from this.
	--	[DEFUNCT] a flag to disable terrain-checking,
			*	innaccurate weapons will suffer greatly when firing as they will be confused into thinking that terrain-blocking has occurred.
	--	a discrete function that evaluates retargetting conditions.
			*	this can be replaced and/or hooked per-weapon to allow custom OKC rules.
	--	[DEFUNCT] target painting using a cut down CollisionBeam class.
			*	checks for direct LoS between the weapon and target.
			*	calls parent weapon's OnPaintChange event the painter detects a change.
	--	a flag to disable Target Memory on each weapon.
			*	structures (anything with the STRUCTURE categories entry) have Target Memory disabled by default;
					it's not like they can chase down fleeing units.

All binary options are defined in the unit blueprint, and can be set manually for any custom unit. 
	This example blueprint details use of the controls.

	UnitBlueprint {
		Defense = {
			dontOKControl = <true/false>,	--	 ignore OKC checks when targetting at this unit.
		},
		Weapon = {
			{
				dontOKCheck			= <true/false>,	--	don't do OKC check for this weapon.
				dontOKSum			= <true/false>,	--	don't add this weapon's damage for OKC checks.
				dontTerrainCheck	= <true/false>,	--	ignore terrain collisions for this weapon.
				dontCacheTargets	= <true/false>,	--	should this weapon remember the most recent attack target to attack again?
			},
		}
	}

The function that governs targetting conditions is ShouldRetarget(self), found in;
	--	/lua/sim/DefaultWeapons.lua
	--	self:ShouldRetarget() returns true if the OKC conditions are met. 

By default, ShouldRetarget checks if the target's DamageInFlight variable exceeds the target's current health.
	--	indicating that the target will likely be killed very soon, and extra shots are wasteful.

This can be hooked per-weapon in the unit's (or weapon's) script file in the same way as any other function.