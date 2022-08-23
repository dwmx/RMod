//=============================================================================
// DarkVikingSnow.
//=============================================================================
class DarkVikingSnow expands DarkViking;

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================

function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			SkelGroupSkins[2] = Texture'players.Ragnarsnov_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[3] = Texture'players.Ragnarsnov_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.Ragnarsnov_armlegpain';
			SkelGroupSkins[12] = Texture'players.Ragnarsnov_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'players.Ragnarsnov_armlegpain';
			SkelGroupSkins[11] = Texture'players.Ragnarsnov_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[1] = Texture'players.Ragnarsnov_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[4] = Texture'players.Ragnarsnov_armlegpain';
			break;
	}
	return None;
}

defaultproperties
{
     SkelGroupSkins(0)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(1)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarsnov_body'
     SkelGroupSkins(3)=Texture'Players.Ragnarsnov_head'
     SkelGroupSkins(4)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsnov_head'
     SkelGroupSkins(6)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarsnov_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnarsnov_armleg'
}
