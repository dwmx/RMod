//=============================================================================
// GoblinAxePowerup.
//=============================================================================
class GoblinAxePowerup expands GoblinAxe;


auto state GoblinAxePowerup
{
	// avoid pickup state
}

state Throw
{
	// Disappear immediately after hitting something
	function HitWall(vector HitNormal, actor HitWall)
	{
		Super.HitWall(HitNormal, HitWall);
		Destroy();
	}

	function Touch(Actor Other)
	{
		if(Other.IsA('ScriptPawn') && ScriptPawn(Other).bIsBoss) 
			Damage = 0; // Thrown goblin axes don't affect bosses

		Super.Touch(Other);
		if (Other.Owner==Owner || Other==Owner)
			return;
		Destroy();
	}
}

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	if(NewZone.bWaterZone)
		Destroy();
}

defaultproperties
{
     Style=STY_Translucent
     ScaleGlow=0.700000
     ColorAdjust=(X=128.000000,Y=128.000000)
     DesiredColorAdjust=(X=128.000000,Y=128.000000)
}
