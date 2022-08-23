//=============================================================================
// SoundPlayer.
//=============================================================================
class SoundPlayer expands Keypoint
	native;

//#exec Texture Import File=Textures\Ambient.pcx Name=S_Ambient Mips=Off Flags=2

#exec Texture Import File=Textures\musicicon.pcx Name=MusicIcon Mips=Off Flags=2

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var() bool			bPlayerSound;			// If true, the sound plays on the player camera
var() bool			bAutoContinuous;		// True = automatically starts in
											// the continuous cycle state.
var() bool			bRandomPosition;		// True = pick a random position.
var() float			RndPosHeight;
var() float			RndPosRadius;
var() byte			RandomDelayMin;			// Random delay lower bound.
var() byte			RandomDelayMax;			// Random delay upper bound.
var() byte			RandomPercentPitch;		// Pitch +/- <this_value> / 2.
var() byte			RandomPercentVolume;	// Volume +/- <this_value> / 2.
var() sound			TSound[4];				// The Sounds object list.
var() byte			TSoundPitch[4];			// The Sounds pitch list.
var() float			TSoundProbability[4];	// The Sounds probability list.
var() float			TSoundRadius;			// In world units.
var() byte			TSoundVolume[4];		// The Sounds volume list.
var() int			TriggerCountdown;		// Number of times trigger
											// accepted.

var() enum ESndTriggerBehavior	// Defines the action that occurs when the
								// SoundPlayer is triggered.
{
	SNDTB_Nothing,				// Do nothing when triggered.
	SNDTB_Single,				// Play one sound when triggered.
	SNDTB_ContinuousOn,			// Begin a continuous cycle when triggered.
	SNDTB_ContinuousOnOff		// Toggle the continuous cycle state when
								// triggered.
} TriggerBehavior;

var() enum ESndSelectMode
{
	SNDSM_Random,				// Choose sound randomly via probability.
	SNDSM_Cycle					// Cycle through the sound list.
} SelectMode;

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var int		SoundCount;					// The number of valid sounds in the
										// list (var sound Sound[]).
var int		SoundXLat[4];				// Translates an adjusted sound number
										// into a raw sound number.
var float	AdjustedProbability[4];		// The probability of occurence for
										// each sound.  This table has been
										// adjusted so that a single FRand()
										// can scan until < [n].
var int		CSnd;						// The currently playing sound.
var float	CSndDuration;				// The current sound's duration.
var vector	StartOffsetLocation;		// The corner from which a randomly
										// positioned sound will be offset.
var vector	RandomSize;					// = 2 * Vect(CollisionRadius,
										// CollisionRadius, CollisionHeight).
										// When bRandomPosition is true the
										// sound's origin is set to a random
										// position using the RandomSize and
										// StartOffsetLocation vectors.
var int		SPMaxSize;					// Maximum size of the sound list.
var int		CycleSound;

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// BeginPlay.
//  Initializes SoundCount, SPMaxSize, the random location variables, the
//  SoundXLat table and the AdjustedProbability table.
//-----------------------------------------------------------------------------
function BeginPlay()
{
	local int i;
	local float totalProb;

	totalProb = 0.0;
	SoundCount = 0;
	CycleSound = 0;
	if(TriggerCountdown <= 0)
		TriggerCountdown = -1;
	InitSPMaxSize();
	for(i = 0; i < SPMaxSize; i++)
	{
		if(FetchSound(i) == None || FetchProbability(i) ~= 0.0)
			continue;
		StoreSoundXLat(SoundCount, i);
		totalProb += FetchProbability(i);
		StoreAdjustedProbability(SoundCount, totalProb);
		SoundCount++;
	}
	if(SoundCount > 0)
		for(i = 0; i < SoundCount; i++)
			StoreAdjustedProbability(i, FetchAdjustedProbability(i)
				/ totalProb);
	RandomSize.x = RndPosRadius*2;
	RandomSize.y = RndPosRadius*2;
	RandomSize.z = RndPosHeight*2;
	StartOffsetLocation = Location - RandomSize * 0.5;

	super.BeginPlay();
}

//-----------------------------------------------------------------------------
//  Sound list data encapsulation.  These functions are overridden in the
//  subclass BigSoundPlayer to extend the size of the sound list.
//-----------------------------------------------------------------------------
function InitSPMaxSize()
{ SPMaxSize = 4; }
function sound FetchSound(int snd)
{ return TSound[snd]; }
function byte FetchPitch(int snd)
{ return TSoundPitch[snd]; }
function float FetchProbability(int snd)
{ return TSoundProbability[snd]; }
function byte FetchVolume(int snd)
{ return TSoundVolume[snd]; }
function int FetchSoundXLat(int snd)
{ return SoundXLat[snd]; }
function StoreSoundXLat(int snd, int xlat)
{ SoundXLat[snd] = xlat; }
function float FetchAdjustedProbability(int snd)
{ return AdjustedProbability[snd]; }
function float StoreAdjustedProbability(int snd, float p)
{ AdjustedProbability[snd] = p; }

//-----------------------------------------------------------------------------
// PlayNewSound.
//  Plays a random sound, choosing via the probability table.  Applies random
//  position, pitch and volume.  Saves the sound's duration in CSndDuration.
//-----------------------------------------------------------------------------
function PlayNewSound()
{
	local float v, pv;
	local float p, pp;
	local PlayerPawn PlayerPawn;

	if(SelectMode == SNDSM_Random)
		CSnd = PickRandomSound();
	else
	{
		CSnd = FetchSoundXLat(CycleSound);
		CycleSound = (CycleSound+1)%SoundCount;
	}

	if(bRandomPosition)
		SetLocation(StartOffsetLocation + VRand()*RandomSize);
	p = float(FetchPitch(CSnd)) / 100.0;
	if(RandomPercentPitch > 0)
	{
		pp = p*float(RandomPercentPitch) / 100.0;
		p = p - pp/2 + FRand()*pp;
	}
	v = float(FetchVolume(CSnd)) / 100.0;
	if(RandomPercentVolume > 0)
	{
		pv = v*float(RandomPercentVolume) / 100.0;
		v = v - pv/2 + FRand()*pv;
	}

	if(bPlayerSound)
	{
		foreach AllActors(class'PlayerPawn', PlayerPawn)
			PlayerPawn.PlaySound(FetchSound(CSnd), SLOT_Misc, v, true, TSoundRadius, p);
	}
	else
	{
		PlaySound(FetchSound(CSnd), SLOT_Misc, v, true, TSoundRadius, p);
	}

	CSndDuration = GetSoundDuration(FetchSound(CSnd)) / p;
}

//-----------------------------------------------------------------------------
// PickRandomSound.
//-----------------------------------------------------------------------------
function int PickRandomSound()
{
	local float p;
	local int i;

	p = FRand();
	for(i = 0; i < SoundCount; i++)
		if(p < FetchAdjustedProbability(i))
			return FetchSoundXLat(i);

	return 0;
}

//-----------------------------------------------------------------------------
// CalcSoundDelay.
//  Returns a random float based on RandomDelayMin and RandomDelayMax.
//-----------------------------------------------------------------------------
function float CalcSoundDelay(int snd)
{
	return (FMin(RandomDelayMin, RandomDelayMax)
		+ Abs(RandomDelayMax-RandomDelayMin)*FRand())/10.0;
}

//-----------------------------------------------------------------------------
// DecrementTrigger.
//-----------------------------------------------------------------------------
function DecrementTrigger()
{
	if(TriggerCountdown > 0)
	{
		TriggerCountdown--;
		if(TriggerCountdown == 0)
			CompletedCountdown();
	}
}

//-----------------------------------------------------------------------------
// CompletedCountdown.
//-----------------------------------------------------------------------------
function CompletedCountdown()
{
}

//-----------------------------------------------------------------------------
// Trigger.
//-----------------------------------------------------------------------------
function Trigger(actor other, pawn eventInstigator)
{
	if(SoundCount > 0 && TriggerCountdown != 0)
	{
		DecrementTrigger();
		switch(TriggerBehavior)
		{
		case SNDTB_Single:
			PlayNewSound();
			break;

		case SNDTB_ContinuousOn:
		case SNDTB_ContinuousOnOff:
			GotoState('ContinuousPlay');
			break;
		}
	}
}

//-----------------------------------------------------------------------------
// SoundAction.
//  Default sound action is to trigger using the Event property.  Override
//  this in a subclass to provide unique behavior.
//-----------------------------------------------------------------------------
function SoundAction()
{
	if(Event != '')
		foreach AllActors(class 'Actor', Target, Event)
			Target.Trigger(self, none);
}

// STATES /////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// CheckAutoContinuous.
//-----------------------------------------------------------------------------
auto state CheckAutoContinuous
{
begin:
	if(bAutoContinuous && SoundCount > 0)
		GotoState('ContinuousPlay');
	else
		GotoState('');
}

//-----------------------------------------------------------------------------
// ContinuousPlay.
//-----------------------------------------------------------------------------
state ContinuousPlay
{
	function Trigger(actor other, pawn eventInstigator)
	{
		DecrementTrigger();
		if(TriggerBehavior == SNDTB_ContinuousOnOff)
			GotoState('');
	}

begin:
	// Plays a new sound and sleeps until it finishes
	PlayNewSound();
	Sleep(CSndDuration);

	// Perform sound action
	SoundAction();

	// Sleep between RandomDelayMin and RandomDelayMax
	Sleep(CalcSoundDelay(CSnd));

	Goto('begin');
}

defaultproperties
{
     bAutoContinuous=True
     RndPosHeight=64.000000
     RndPosRadius=512.000000
     TSoundPitch(0)=100
     TSoundPitch(1)=100
     TSoundPitch(2)=100
     TSoundPitch(3)=100
     TSoundProbability(0)=1.000000
     TSoundProbability(1)=1.000000
     TSoundProbability(2)=1.000000
     TSoundProbability(3)=1.000000
     TSoundRadius=4096.000000
     TSoundVolume(0)=100
     TSoundVolume(1)=100
     TSoundVolume(2)=100
     TSoundVolume(3)=100
     bStatic=False
     Texture=Texture'Engine.MusicIcon'
     CollisionRadius=40.000000
     CollisionHeight=40.000000
}
