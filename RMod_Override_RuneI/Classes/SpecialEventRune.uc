//=============================================================================
// SpecialEventRune: Receives trigger messages and does some "special event"
// depending on the state.
//=============================================================================
class SpecialEventRune extends SpecialEvent;


var() name	OtherTag;
var(SetBeamTarget) int	OtherInt;

var(Quake) float	QuakeTime;
var(Quake) float	QuakeMagnitude;
var(Quake) float	QuakeRadius;
var(Quake) float	QuakeFalloff;

var(PushObject) vector PushVector;

var(RuneMessage) localized string	Msg;
var(RuneMessage) font	MsgFont;
var(RuneMessage) float	MsgLifeTime;
var(RuneMessage) bool	bMsgFade;
var(RuneMessage) float	MsgFadeTime;
var(RuneMessage) vector	MsgLocation;
var(RuneMessage) color	MsgColor;
var(RuneMessage) E_RMAlign MsgAlignment;

var(Cinematic) bool bAllowSkip;

var(ChangePlayerClass) string DestURL;
var(ChangePlayerClass) class<RunePlayer> NewPlayerClass;
var(ChangePlayerClass) name DestTeleporterTag;


//=============================================================================
//
// SetBeamTarget
//
// Set's beam referenced by ObjectTag to target OtherTag, joint OtherInt
//=============================================================================
state() SetBeamTarget
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local BeamSystem B;
		local Actor A;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' && OtherTag != '')
		{
			foreach AllActors(class'actor', A, OtherTag)
				break;

			foreach AllActors( class 'BeamSystem', B, ObjectTag )
			{
				B.Target = A;
				B.TargetJointIndex = OtherInt;
			}
		}
	}
}

//=============================================================================
//
// Quake
//
//=============================================================================
state() Quake
{
	function Trigger(actor Other, pawn EventInstigator)
	{
		local RunePlayer P;

		foreach RadiusActors(class'RunePlayer', P, QuakeRadius, Location)
		{
			P.ShakeView(QuakeTime, QuakeMagnitude, QuakeFalloff);
		}
	}
}

//=============================================================================
//
// StartCinematic
//
//=============================================================================
state() StartCinematic
{
	function Trigger(actor Other, pawn EventInstigator)
	{
		local CineCamera Camera;

		foreach AllActors(class'CineCamera', Camera)
		{ // Do not allow the trigger to occur if a CineCamera is already instanced
			return;
		}

		Camera = Spawn(class'CineCamera', EventInstigator);
		Camera.Event = Event;
		Camera.StartCam(false, bAllowSkip);
	}
}

//=============================================================================
//
// StartCinematicSmooth
//
//=============================================================================
state() StartCinematicSmooth
{
	function Trigger(actor Other, pawn EventInstigator)
	{
		local CineCamera Camera;

		foreach AllActors(class'CineCamera', Camera)
		{ // Do not allow the trigger to occur if a CineCamera is already instanced
			return;
		}

		Camera = Spawn(class'CineCamera', EventInstigator);
		Camera.Event = Event;
		Camera.StartCam(true, bAllowSkip);
	}
}


//=============================================================================
//
// PushObject
//
//=============================================================================
state() PushObject
{
	function Trigger(actor Other, pawn EventInstigator)
	{
		local actor A;
		foreach AllActors(class'actor', A, ObjectTag)
		{
			A.AddVelocity(PushVector);
		}
	}
}


//=============================================================================
//
// ClearOrdersObject
//
//=============================================================================
state() ClearOrdersObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local ScriptPawn P;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' )
		{
			foreach AllActors( class 'ScriptPawn', P, ObjectTag )
			{
				if (P.Health > 0)
				{
					P.OrderFinished();
					P.GotoState('Waiting');
				}
			}
		}
	}
}


//=============================================================================
//
// RuneMessage
//
//=============================================================================
state() RuneMessage
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local RuneHUD H;

		Global.Trigger( Self, EventInstigator );

		foreach AllActors( class 'RuneHUD', H )
		{
			if (MsgLocation==vect(0,0,0))
				H.RuneMessage(Msg, Location, MsgColor, MsgFont, MsgLifeTime, bMsgFade, MsgFadeTime, RMALIGN_None);
			else
				H.RuneMessage(Msg, MsgLocation, MsgColor, MsgFont, MsgLifeTime, bMsgFade, MsgFadeTime, MsgAlignment);
			break;
		}
	}
}


//=============================================================================
//
// Subtitle
//
//=============================================================================
state() Subtitle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		BroadcastMessage(Msg, false, 'Subtitle');
	}
}


//=============================================================================
//
// RedSubtitle
//
//=============================================================================
state() RedSubtitle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Self, EventInstigator );
		BroadcastMessage(Msg, false, 'RedSubtitle');
	}
}


//=============================================================================
//
// UseObject
//
//=============================================================================
state() UseObject
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local actor A;

		Global.Trigger( Self, EventInstigator );

		foreach AllActors(class'actor', A, ObjectTag)
		{
			// Don't check proximity to it, since this is a scripted action
//			if (A.CanBeUsed(Other))
				A.UseTrigger(EventInstigator);
		}
	}
}


//=============================================================================
//
// ObjectHateOther
//
// OtherTag should match a single victim
//=============================================================================
state() ObjectHateOther
{
	function Trigger( actor Triggerer, pawn EventInstigator )
	{
		local Pawn P, Other;

		Global.Trigger( Self, EventInstigator );

		if( ObjectTag != '' && OtherTag != '')
		{
			foreach AllActors(class'pawn', Other, OtherTag)
				break;

			foreach AllActors(class'pawn', P, ObjectTag)
			{
				// Must stop scripting in order to set enemy
				if (ScriptPawn(P)!=None)
					ScriptPawn(P).OrderFinished();
				P.Enemy = None;	
				P.DamageAttitudeTo(Other);
			}
		}
	}
}


//=============================================================================
//
// ChangePlayerClass
//
//=============================================================================
state() ChangePlayerClass
{
	function Trigger( actor Triggerer, pawn EventInstigator)
	{
		local PlayerPawn P, NewPlayer;

		Global.Trigger( Self, EventInstigator);

		if (NewPlayerClass != None)
		{
			//DestURL = "#" $ DestTeleporterTag $ "?Class=Runei."$NewPlayerClass;

			slog("DestURL=[" $ DestURL $ "]");
			foreach AllActors(class'PlayerPawn', P, 'Player')
			{
				P.ClientTravel( DestURL, TRAVEL_Relative, true );
//				P.ClientTravel( DestURL, TRAVEL_Absolute, true );
			}
		}
	}
}

defaultproperties
{
     QuakeTime=4.000000
     QuakeMagnitude=500.000000
     QuakeRadius=2000.000000
     QuakeFalloff=2.000000
     PushVector=(X=100.000000,Z=10.000000)
     MsgFont=Font'Engine.RuneBig'
     MsgLifeTime=3.000000
     bMsgFade=True
     MsgFadeTime=1.000000
     MsgColor=(R=255,G=255,B=255,A=128)
     bAllowSkip=True
}
