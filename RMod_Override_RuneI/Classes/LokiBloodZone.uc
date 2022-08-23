//=============================================================================
// LokiBloodZone.
//=============================================================================
class LokiBloodZone expands ZoneInfo;

var() int TotalHealth;  // Total health contained within this LokiBloodPool
var() int HealthIncrement; // Amount of Health given to SarkRagnar per second
var() name HealthEmptyEvent; // Event that is called when the pool is out of health
var int Health;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	Health = TotalHealth;
}

function int ExtractHealth()
{
	local int amount;
	
	if(Health <= 0)
		return(0);
		
	if(Health < HealthIncrement)
		amount = Health;
	else
		amount = HealthIncrement;

	Health -= amount;
	if(Health <= 0)
	{ // Loki blood ran out of health power
		FogDistance = 0;
		bFogZone = false;
	    bPainZone = false;
	    bLokiBloodZone = false;
		FireEvent(HealthEmptyEvent);		
	}
	
	return(amount);	
}

defaultproperties
{
     TotalHealth=100
     HealthIncrement=10
     DamagePerSec=20
     bWaterZone=True
     bFogZone=True
     bPainZone=True
     bLokiBloodZone=True
     FogBrightness=100
     FogHue=45
     FogSaturation=80
     FogDistance=1000.000000
}
