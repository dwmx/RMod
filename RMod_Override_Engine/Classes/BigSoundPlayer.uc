//=============================================================================
// BigSoundPlayer.
//=============================================================================
class BigSoundPlayer expands SoundPlayer;

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var(SoundPlayer) sound		TSound2[4];
var(SoundPlayer) byte		TSoundPitch2[4];
var(SoundPlayer) float		TSoundProbability2[4];
var(SoundPlayer) byte		TSoundVolume2[4];

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var int			SoundXLat2[4];
var float		AdjustedProbability2[4];

// FUNCTIONS //////////////////////////////////////////////////////////////////

function InitSPMaxSize()
{ SPMaxSize = 8; }
function sound FetchSound(int snd)
{	if(snd < 4) return TSound[snd];
	else return TSound2[snd-4]; }
function byte FetchPitch(int snd)
{	if(snd < 4) return TSoundPitch[snd];
	else return TSoundPitch2[snd-4]; }
function float FetchProbability(int snd)
{	if(snd < 4) return TSoundProbability[snd];
	else return TSoundProbability2[snd-4]; }
function byte FetchVolume(int snd)
{	if(snd < 4) return TSoundVolume[snd];
	else return TSoundVolume2[snd-4]; }
function int FetchSoundXLat(int snd)
{	if(snd < 4) return SoundXLat[snd];
	else return SoundXLat2[snd-4]; }
function StoreSoundXLat(int snd, int xlat)
{	if(snd < 4) SoundXLat[snd] = xlat;
	else SoundXLat2[snd-4] = xlat; }
function float FetchAdjustedProbability(int snd)
{	if(snd < 4) return AdjustedProbability[snd];
	else return AdjustedProbability2[snd-4]; }
function float StoreAdjustedProbability(int snd, float p)
{	if(snd < 4) AdjustedProbability[snd] = p;
	else AdjustedProbability2[snd-4] = p; }

defaultproperties
{
     TSoundPitch2(0)=100
     TSoundPitch2(1)=100
     TSoundPitch2(2)=100
     TSoundPitch2(3)=100
     TSoundProbability2(0)=1.000000
     TSoundProbability2(1)=1.000000
     TSoundProbability2(2)=1.000000
     TSoundProbability2(3)=1.000000
     TSoundVolume2(0)=100
     TSoundVolume2(1)=100
     TSoundVolume2(2)=100
     TSoundVolume2(3)=100
}
