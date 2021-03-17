//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native;
//	nativereplication;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Zone properties.

var() name   ZoneTag;
var() vector ZoneGravity;
var() vector ZoneVelocity;
var() float  ZoneGroundFriction;
var() float  ZoneFluidFriction;
var() float	 ZoneTerminalVelocity;
var() name   ZonePlayerEvent;
var() name   ZonePlayerExitEvent;	// RUNE: Event to fire when player leaves this zone
var() name   ZonePlayerDiedEvent;	// RUNE: Fires when the player dies in this zone
var   int    ZonePlayerCount;
var   int	 NumCarcasses;
var() int	 DamagePerSec;
var() name	 DamageType;
var() localized string DamageString;
var(LocationStrings) localized string ZoneName;
var LocationID LocationID;	
var() int	 MaxCarcasses;
var() sound  EntrySound;	// only if waterzone
var() sound  EntrySoundBig;	// only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() bool   bTakeOverCamera;	// RUNE:  Take over camera when player is in this zone
var() float	 MaxCameraDist;		// RUNE:  Maximum distance camera is allowed in this zone (zero denotes no change)
var() name	 SkyZoneName;
var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var()		bool   bBounceVelocity;		// this velocity zone should bounce actors that land in it

//-----------------------------------------------------------------------------
// Zone flags.

var()		bool   bWaterZone;   // Zone is water-filled.
var() 		bool   bFogZone;     // Zone is fog-filled.   (RUNE -- was const)
var() 		bool   bFarClipZone; // Zone has a far-clip plane (uses FogDistance) (RUNE -- was const)
var() 		bool   bKillZone;    // Zone instantly kills those who enter. (RUNE -- was const)
var()		bool   bNeutralZone; // Players can't take damage in this zone.
var()		bool   bGravityZone; // Use ZoneGravity.
var()		bool   bPainZone;	 // Zone causes pain.
var()		bool   bDestructive; // Destroys carcasses.
var()		bool   bNoInventory;
var()		bool   bMoveProjectiles;	// this velocity zone should impart velocity to projectiles and effects
var()		bool   bLokiBloodZone; // RUNE:  This zone contains Loki's blood

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;
var(ZoneLight) byte FogBrightness, FogHue, FogSaturation;
//test var(ZoneLight) color FogColor;
var(ZoneLight) float FogDistance;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;
var(ZoneLight) vector ViewFlash, ViewFog;

//-----------------------------------------------------------------------------
// Reverb.

// Settings.
var(Reverb) bool bReverbZone;
var(Reverb) bool bRaytraceReverb;
var(Reverb) float SpeedOfSound;
var(Reverb) byte MasterGain;
var(Reverb) int  CutoffHz;
var(Reverb) byte Delay[6];
var(Reverb) byte Gain[6];

//MWP:begin
//-----------------------------------------------------------------------------
// Lens flare.

var(LensFlare) texture LensFlare[12];
var(LensFlare) float LensFlareOffset[12];
var(LensFlare) float LensFlareScale[12];

//-----------------------------------------------------------------------------
// per-Zone mesh LOD lighting control
 
// the number of lights applied to the actor mesh is interpolated between the following
// properties, as a function of the MeshPolyCount for the previous frame.
var() byte MinLightCount; // minimum number of lights to use (when MaxLightingPolyCount is exceeded)
var() byte MaxLightCount; // maximum number of lights to use (when MeshPolyCount drops below MinLightingPolyCount)
var() int MinLightingPolyCount;
var() int MaxLightingPolyCount;
// (NOTE: the default LOD properties (below) have no effect on the mesh lighting behavior)
//MWP:end

//=============================================================================
// Network replication.

replication
{
	reliable if( Role==ROLE_Authority )
		ZoneGravity, ZoneVelocity, 
		// ZoneTerminalVelocity,
		// ZoneGroundFriction, ZoneFluidFriction,
		AmbientBrightness, AmbientHue, AmbientSaturation,
		TexUPanSpeed, TexVPanSpeed,
		// ViewFlash, ViewFog, // Not replicated because vectors replicated with elements rounded to integers
		bReverbZone,
		MaxCameraDist, bTakeOverCamera,
		FogBrightness, FogHue, FogSaturation;
//		FogColor;
}

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

//MWP:begin -- moved out of PreBeginPlay() to allow overriding
//=============================================================================
simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	if(SkyZoneName != 'None')
	{
		foreach AllActors(class'SkyZoneInfo', TempSkyZone, SkyZoneName)
		{ // Found an actor who's TAG matches SkyZoneName, so use it
			SkyZone = TempSkyZone;
			return;
		}
	}

	// SkyZone.
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		SkyZone = TempSkyZone;
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			SkyZone = TempSkyZone;
}
//MWP:end

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (DamagePerSec != 0)
		bPainZone = true;
}

// When an actor enters this zone.
event ActorEntered( actor Other )
{
	local actor A;
	local vector AddVelocity;

	if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
	{
		Other.LifeSpan = 1.5;
		return;
	}

	if( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
		if( ++ZonePlayerCount==1 && ZonePlayerEvent!='' )
			foreach AllActors( class 'Actor', A, ZonePlayerEvent )
				A.Trigger( Self, Pawn(Other) );

	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
			Other.Velocity += ZoneVelocity;
		else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			Other.Velocity += ZoneVelocity;
		}
	}
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	local actor A;
	if( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
	{
		if( --ZonePlayerCount==0)
		{
			if ( ZonePlayerEvent!='' )
				foreach AllActors( class 'Actor', A, ZonePlayerEvent )
					A.UnTrigger( Self, Pawn(Other) );

			if( ZonePlayerExitEvent!='' )
				foreach AllActors( class 'Actor', A, ZonePlayerExitEvent )
					A.Trigger( Self, Pawn(Other) );
		}
	}
}

//============================================================
//
// Debug
//
//============================================================
simulated function debug(canvas Canvas, int mode)
{
	local int ix;
	local actor A;

	// put text here
	Canvas.DrawText("  NumCarcasses:    "$NumCarcasses);
	Canvas.CurY -= 8;
	Canvas.DrawText("  MaxCarcasses:    "$MaxCarcasses);
	Canvas.CurY -= 8;

	Super.Debug(Canvas, mode);	// Draws actor name

	// Draw graphics
	if (ZonePlayerEvent != '')
		foreach AllActors(class'Actor', A, ZonePlayerEvent)
			Canvas.DrawLine3D(Location, A.Location, 255, 255, 0);

	if (ZonePlayerExitEvent != '')
		foreach AllActors(class'Actor', A, ZonePlayerExitEvent)
			Canvas.DrawLine3D(Location, A.Location, 255, 0, 0);
}

defaultproperties
{
     ZoneGravity=(Z=-1150.000000)
     ZoneGroundFriction=8.000000
     ZoneFluidFriction=1.200000
     ZoneTerminalVelocity=2500.000000
     MaxCarcasses=3
     bMoveProjectiles=True
     AmbientSaturation=255
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     SpeedOfSound=8000.000000
     MasterGain=100
     CutoffHz=6000
     Delay(0)=20
     Delay(1)=34
     Gain(0)=150
     Gain(1)=70
     MinLightCount=6
     MaxLightCount=6
     MinLightingPolyCount=1000
     MaxLightingPolyCount=5000
     bStatic=True
     bNoDelete=True
     bAlwaysRelevant=True
     Texture=Texture'Engine.S_ZoneInfo'
     NetUpdateFrequency=4.000000
}
