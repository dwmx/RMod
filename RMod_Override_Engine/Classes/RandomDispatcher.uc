//=============================================================================
// RandomDispatcher.
//=============================================================================
class RandomDispatcher expands Dispatcher;

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var(Dispatcher) bool 	bAutoStart;
var(Dispatcher) byte	RandomDelayMin;
var(Dispatcher) byte	RandomDelayMax;
var(Dispatcher) float	OutProbabilities[8];
var(Dispatcher) int		ContiguousEvents;

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var int		EventCount;					// The number of valid events in the
										// list (var name OutEvents[]).
var int		EventXLat[8];				// Translates an adjusted event number
										// into a raw event number.
var float	AdjustedProbability[8];		// The probability of occurence for
										// each event.  This table has been
										// adjusted so that a single FRand()
										// can scan until < [n].
var int		CEvent;						// Current event.
var int		RepeatCount;				// Repetition countdown.

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// BeginPlay.
//  Initializes EventCount, the EventXLat table and the AdjustedProbability
//  table.
//-----------------------------------------------------------------------------
function BeginPlay()
{
	local int i;
	local float totalProb;

	totalProb = 0.0;
	EventCount = 0;
	if(ContiguousEvents <= 0)
		ContiguousEvents = -1;
	if(bIsLooping)
		ContiguousEvents = -1;
	for(i = 0; i < 8; i++)
	{
		if(OutEvents[i] == '' || OutProbabilities[i] ~= 0.0)
			continue;
		EventXLat[EventCount] = i;
		totalProb += OutProbabilities[i];
		AdjustedProbability[EventCount] = totalProb;
		EventCount++;
	}
	if(EventCount > 0)
		for(i = 0; i < EventCount; i++)
			AdjustedProbability[i] /= totalProb;
	super.BeginPlay();
}

//-----------------------------------------------------------------------------
// Trigger.
//-----------------------------------------------------------------------------
function Trigger(actor other, pawn eventInstigator)
{
	if(EventCount > 0)
		GotoState('RandomDispatch');
}

//-----------------------------------------------------------------------------
// BroadcastNewEvent.
//-----------------------------------------------------------------------------
function BroadcastNewEvent()
{
	CEvent = PickRandomEvent();
	foreach AllActors(class'Actor', Target, OutEvents[CEvent])
		Target.Trigger(self, Instigator);
}

//-----------------------------------------------------------------------------
// PickRandomEvent.
//-----------------------------------------------------------------------------
function int PickRandomEvent()
{
	local float p;
	local int i;

	p = FRand();
	for(i = 0; i < EventCount; i++)
		if(p < AdjustedProbability[i])
			return EventXLat[i];

	return 0;
}

//-----------------------------------------------------------------------------
// CalcEventDelay.
//-----------------------------------------------------------------------------
function float CalcEventDelay()
{
	return (FMin(RandomDelayMin, RandomDelayMax)
		+ Abs(RandomDelayMax-RandomDelayMin)*FRand())/10.0;
}

// STATES /////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// CheckAutoStart.
//-----------------------------------------------------------------------------
auto state CheckAutoStart
{
begin:
	if(bAutoStart && EventCount > 0)
		GotoState('RandomDispatch');
	else
		GotoState('');
}

//-----------------------------------------------------------------------------
// RandomDispatch.
//-----------------------------------------------------------------------------
state RandomDispatch
{
	function BeginState()
	{
		RepeatCount = ContiguousEvents;
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		if(bIsLooping)
			GotoState('');
	}

begin:
	do
	{
		BroadcastNewEvent();
		Sleep(OutDelays[CEvent] + CalcEventDelay());
		if(RepeatCount > 0)
			RepeatCount--;
	} until(RepeatCount == 0);
	GotoState('');
}

defaultproperties
{
}
