//=============================================================================
// SpecialEvent: Receives trigger messages and does some "special event"
// depending on the state.
//=============================================================================
class SpecialEvent extends Triggers;

#exec Texture Import File=Textures\TrigSpcl.pcx Name=S_SpecialEvent Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Variables.

var() int        Damage;         // For DamagePlayer state.
var() name		 DamageType;
var() int		 DamageJoint;
var() localized  string DamageString;
var() sound      Sound;          // For PlaySoundEffect state.
var() localized  string Message; // For all states.
var() bool       bBroadcast;     // To broadcast the message to all players.
var() bool       bPlayerViewRot; // Whether player can rotate the view while pathing.
var() name       ObjectTag;      // Tag of object
var() name       ScriptTag;      // Tag of script object for 'OrderObject'

//-----------------------------------------------------------------------------
// Functions.

function Trigger( actor Other, pawn EventInstigator )
{
	local pawn P;
	if( bBroadcast )
		BroadcastMessage(Message, true, 'CriticalEvent'); // Broadcast message to all players.
	else if( EventInstigator!=None && len(Message)!=0 )
	{
		// Send message to instigator only.
		EventInstigator.ClientMessage( Message );
	}
}

//-----------------------------------------------------------------------------
// States.

// Just display the message.
state() DisplayMessage
{
}

// Damage the object referenced by ObjectTag
state() DamageObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local actor A;
	
		Global.Trigger( Self, EventInstigator );
		if ( Other.IsA('PlayerPawn') )
			Level.Game.SpecialDamageString = DamageString;
		foreach AllActors(class'Actor', A, ObjectTag)
			A.JointDamaged( Damage, EventInstigator, A.Location, Vect(0,0,0), DamageType, DamageJoint);
	}
}

// Damage the instigator who caused this event.
state() DamageInstigator
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		if ( Other.IsA('PlayerPawn') )
			Level.Game.SpecialDamageString = DamageString;
		Other.JointDamaged( Damage, EventInstigator, EventInstigator.Location, Vect(0,0,0), DamageType, DamageJoint);
	}
}

// Kill the pawn referenced by ObjectTag
state() KillObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Pawn A;
	
		Global.Trigger( Self, EventInstigator );
		if ( Other.IsA('PlayerPawn') )
			Level.Game.SpecialDamageString = DamageString;
		foreach AllActors(class'Pawn', A, ObjectTag)
			A.Died( None, DamageType, A.Location );
	}
}

// Kill the instigator who caused this event.
state() KillInstigator
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		if ( Other.IsA('PlayerPawn') )
			Level.Game.SpecialDamageString = DamageString;
		if( EventInstigator != None )
			EventInstigator.Died( None, DamageType, EventInstigator.Location );
	}
}

// Play a sound.
state() PlaySoundEffect
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		PlaySound( Sound );
	}
}

// Play a sound.
state() PlayersPlaySoundEffect
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local pawn P;

		Global.Trigger( Self, EventInstigator );

		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && P.IsA('PlayerPawn') )
				PlayerPawn(P).ClientPlaySound(Sound);
	}
}

// Place Ambient sound effect on player
state() PlayAmbientSoundEffect
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		EventInstigator.AmbientSound = AmbientSound;
	}
}


// Send the player on a spline path through the level.
state() PlayerPath
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local InterpolationPoint i;
		Global.Trigger( Self, EventInstigator );
		if( EventInstigator!=None && EventInstigator.bIsPlayer && (Level.NetMode == NM_Standalone) )
		{
			foreach AllActors( class 'InterpolationPoint', i, Event )
			{
				if( i.Position == 0 )
				{
					EventInstigator.GotoState('');
					EventInstigator.SetCollision(True,false,false);
					EventInstigator.bCollideWorld = False;
					EventInstigator.Target = i;
					EventInstigator.SetPhysics(PHYS_Interpolating);
					EventInstigator.PhysRate = 1.0;
					EventInstigator.PhysAlpha = 0.0;
					EventInstigator.bInterpolating = true;
					EventInstigator.AmbientSound = AmbientSound;
				}
			}
		}
	}
}

state() OrderObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Pawn P;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' && ScriptTag != '' )
		{
			foreach AllActors( class 'Pawn', P, ObjectTag )
			{
				P.FollowOrders('Scripting', ScriptTag);
			}
		}
	}
}


state() HideObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Actor A;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' )
		{
			foreach AllActors( class 'actor', A, ObjectTag )
			{
				A.bHidden = true;
			}
		}
	}
}


state() ShowObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Actor A;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' )
		{
			foreach AllActors( class 'actor', A, ObjectTag )
			{
				A.bHidden = false;
			}
		}
	}
}

state() DestroyObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Actor A;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' )
		{
			foreach AllActors( class 'actor', A, ObjectTag )
			{
				// RUNE:  Issue a warning if an inventory item is designer-destroyed.  This
				// should never happen, as it causes undefined behavior if the player is currently
				// carrying that inventory item.
				if(A.IsA('Inventory'))
				{
//					slog("WARNING:  Attempted to Destroy Inventory: "$A);
					continue;
				}

				A.Destroy();
			}
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

	Super.Debug(Canvas, mode);	// Draws actor name

	// Draw graphics
	if (ObjectTag != '')
		foreach AllActors(class'Actor', A, ObjectTag)
			Canvas.DrawLine3D(Location, A.Location, 255, 255, 0);
}

defaultproperties
{
     bBroadcast=True
     Texture=Texture'Engine.S_SpecialEvent'
     bCollideActors=False
}
