//=============================================================================
// RagnarOnBeetle.
//=============================================================================
class RagnarOnBeetle expands Effects;

auto state BeetleProxyFlying
{
	function AnimEnd()
	{
		LoopAnim('rideA', 1.0);
	}
	
	function BeginState()
	{
		LoopAnim('rideA', 1.0);
	}
	
begin:	
	Disable('Tick');
}

defaultproperties
{
     DrawType=DT_SkeletalMesh
     AmbientSound=Sound'CreaturesSnd.Beetle.beetle01L'
     SkelMesh=19
     Skeletal=SkelModel'Players.Ragnar'
     SkelGroupSkins(0)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(2)=Texture'Players.Ragnartn_leg'
     SkelGroupSkins(3)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(4)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(6)=Texture'Players.Ragnartn_leg'
     SkelGroupSkins(7)=Texture'Players.Ragnarragtp_head'
     SkelGroupSkins(8)=Texture'Players.Ragnarragtp_body'
     SkelGroupSkins(9)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(11)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(12)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarragtp_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragtp_arms'
}
