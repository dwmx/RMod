//=============================================================================
// Beetle.
//=============================================================================
class Beetle expands Mount;


var actor rider;


auto State test
{
		
begin:
	LoopAnim('flya', 1.0, 0.1);
}

state() LoneFlyer
{
	function Trigger(actor other, pawn eventInstigator)
	{
		local InterpolationPoint i;

		if(Event != 'None')
			foreach AllActors(class 'InterpolationPoint', i, Event)
				if(i.Position == 0)
				{ // Found a matching path
					SetCollision(true, false, false);
					bCollideWorld = False;
					Target = i;
					SetPhysics(PHYS_Interpolating);
					PhysRate = 1.0;
					PhysAlpha = 0.0;
					bInterpolating = true;
					return;
				}
	}

begin:
	LoopAnim('flya', 2.0, 0.1);
}

defaultproperties
{
     DrawType=DT_SkeletalMesh
     SoundRadius=64
     SoundVolume=99
     AmbientSound=Sound'CreaturesSnd.Beetle.beetle11L'
     Skeletal=SkelModel'creatures.Beetle'
}
