//=============================================================================
// CDThinker.
//
// This is a simple little class that automatically restarts the CD Audio on a level
// 
// Yeah.  It's a hack.  We go gold with the Add-on in two days and I just 
// discovered that CD Audio doesn't loop by default in the game code.
//=============================================================================
class CDThinker extends Actor;

// RUNE:  CD Audio restart functionality
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if(Level.CdTrackLength > 0)
		SetTimer(Level.CdTrackLength, true);
}

simulated function Timer()
{
	// Restart CD music
	ConsoleCommand("CDTRACK " $Level.CdTrack);
}

defaultproperties
{
     bHidden=True
}
