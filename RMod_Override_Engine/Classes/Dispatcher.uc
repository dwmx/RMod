//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input, 
// then triggers a set of specifid events with optional delays.
//=============================================================================
class Dispatcher extends Triggers
	native;

#exec Texture Import File=Textures\Dispatch.pcx Name=S_Dispatcher Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[8]; // Events to generate.
var() float OutDelays[8]; // Relative delays before generating events.
var() bool bIsLooping;	  // RUNE:  If true, the dispatcher loops forever
var int i;                // Internal counter.

//=============================================================================
// Dispatcher logic.

//
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//
// Dispatch events.
//
state Dispatch
{
Begin:
	disable('Trigger');
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( OutEvents[i] != '' )
		{
			if(OutDelays[i] > 0)
				Sleep(OutDelays[i]); // Only sleep if there is time to sleep

			foreach AllActors( class 'Actor', Target, OutEvents[i] )
				Target.Trigger( Self, Instigator );
		}
	}

	if(bIsLooping)
	{
		Sleep(0.0); // RUNE:  Force a sleep to avoid runaway loops
		goto('Begin');
	}

	enable('Trigger');
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
	for (ix=0; ix<ArrayCount(OutEvents); ix++)
		if (OutEvents[ix] != '')
			foreach AllActors(class'Actor', A, OutEvents[ix])
				Canvas.DrawLine3D(Location, A.Location, 255, 255, 0);
}

defaultproperties
{
     Texture=Texture'Engine.S_Dispatcher'
     bCollideActors=False
}
