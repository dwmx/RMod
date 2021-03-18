//=============================================================================
// TestActor.
// For purposes of prototyping
//=============================================================================
class TestActor expands Actor;

var float Tweentime;


auto state testing
{
Begin:
	PlayAnim('neutral_idle', 0.5, Tweentime);
	FinishAnim();

	PlayAnim('dth_all_death1_an0n', 0.5, Tweentime);
	FinishAnim();

	Goto('Begin');
}

defaultproperties
{
     TweenTime=2.000000
     DrawType=DT_SkeletalMesh
     CollisionHeight=45.000000
     bCollideActors=True
     Skeletal=SkelModel'Players.Ragnar'
}
