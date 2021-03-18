//=============================================================================
// ManowarEffect.
//=============================================================================
class ManowarEffect expands Effects;

var float TimeElapsed;
var float TimeToExpand;
var float StartGlow;
var float EndGlow;
var float SmallScale;
var float BigScale;

auto state Expanding
{
	function Tick(float DeltaTime)
	{
		local float alpha;

		if (TimeElapsed >= TimeToExpand)
		{
			Destroy();
			return;
		}

		TimeElapsed += DeltaTime;
		alpha = TimeElapsed / TimeToExpand;
		DrawScale = SmallScale + (BigScale-SmallScale)*alpha;
		ScaleGlow = StartGlow + (EndGlow-StartGlow)*alpha;
	}

Begin:
	TimeElapsed = 0;
}

defaultproperties
{
     TimeToExpand=1.000000
     StartGlow=0.500000
     SmallScale=1.000000
     BigScale=33.330002
     DrawType=DT_SkeletalMesh
     Style=STY_Translucent
     AmbientGlow=50
     CollisionRadius=15.000000
     CollisionHeight=15.000000
     Skeletal=SkelModel'objects.Hemisphere'
}
