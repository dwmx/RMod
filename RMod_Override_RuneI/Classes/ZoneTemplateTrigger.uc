//=============================================================================
// ZoneTemplateTrigger.
//=============================================================================
class ZoneTemplateTrigger expands Trigger;

var() bool bFarClipZone;
var() bool bFogZone;
var() bool bGravityZone;
var() bool bKillZone;
var() bool bMoveProjectiles;
var() bool bNeutralZone;
var() bool bNoInventory;
var() bool bPainZone;
var() bool bTakeOverCamera;
var() bool bWaterZone;
var() float DamagePerSec;
var() name DamageType;
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() sound EntrySound;
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() name ZonePlayerDiedEvent;	// Fires when the player dies in this zone
var() sound ExitSound;
var() vector ZoneGravity;
var() vector ZoneVelocity;
var() byte AmbientBrightness;
var() byte AmbientHue;
var() byte AmbientSaturation;
var() byte FogHue;
var() byte FogBrightness;
var() byte FogSaturation;
var() float FogDistance;
var() float TexUPanSpeed;
var() float TexVPanSpeed;
var() vector ViewFlash;
var() vector ViewFog;

//--------------------------------------------------------
//
// Trigger
//
//--------------------------------------------------------

function Trigger(actor Cause, Pawn EventInstigator)
{
	local actor A;
	
	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			TriggerAction(A, Cause, EventInstigator);
}


//--------------------------------------------------------
//
// TriggerAction
//
//--------------------------------------------------------
function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	local ZoneInfo Z;
	local ZoneInfo Temp;
	local Actor A;
	local Pawn P;

	Z = ZoneInfo(Receiver);
	if (Z != None)
	{
		// TODO:  Any additional zoneinfo vars needed for this?
		
		// Copy all relevant data from the template		
		Z.bFarClipZone 		= bFarClipZone;
		Z.bFogZone 			= bFogZone;
		Z.bGravityZone 		= bGravityZone;
		Z.bKillZone			= bKillZone;
		Z.bMoveProjectiles	= bMoveProjectiles;
		Z.bNeutralZone		= bNeutralZone;
		Z.bNoInventory		= bNoInventory;
		Z.bPainZone			= bPainZone;
		Z.bTakeOverCamera	= bTakeOverCamera;
		Z.bWaterZone 		= bWaterZone;
		Z.DamagePerSec		= DamagePerSec;
		Z.DamageType		= DamageType;
		Z.EntryActor 		= EntryActor;
		Z.EntrySound		= EntrySound;
		Z.ExitActor			= ExitActor;
		Z.ExitSound			= ExitSound;
		Z.ZoneGravity		= ZoneGravity;
		Z.ZoneVelocity		= ZoneVelocity;
		Z.AmbientBrightness = AmbientBrightness;
		Z.AmbientHue		= AmbientHue;
		Z.AmbientSaturation = AmbientSaturation;
		Z.FogHue			= FogHue;
		Z.FogBrightness		= FogBrightness;
		Z.FogSaturation		= FogSaturation;
		Z.FogDistance		= FogDistance;
		Z.TexUPanSpeed		= TexUPanSpeed;
		Z.TexVPanSpeed		= TexVPanSpeed;
		Z.ViewFlash			= ViewFlash;
		Z.ViewFog			= ViewFog;
		Z.ZonePlayerDiedEvent = ZonePlayerDiedEvent;

		// Send a ZoneChange message to all actors within this zone			
		foreach AllActors(class'Actor', A)
		{
			if(A.Region.Zone == Z)
			{ // This actor is in the current zone, so send a ZoneChange message
				Z.ActorLeaving(A);
				A.ZoneChange(Z);
				Z.ActorEntered(A);
			}

			// Send head/foot zone changes for Pawns
			if(A.IsA('Pawn'))
			{
				P = Pawn(A);
				if(P.HeadRegion.Zone == Z)
				{
					P.HeadZoneChange(Z);
				}
				if(P.FootRegion.Zone == Z)
				{
					P.FootZoneChange(Z);
				}
			}
		}
	}
}


//--------------------------------------------------------
//
// UnTriggerAction
//
//--------------------------------------------------------
function UnTriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
}

defaultproperties
{
     ZoneGravity=(Z=-1150.000000)
     AmbientSaturation=255
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
}
