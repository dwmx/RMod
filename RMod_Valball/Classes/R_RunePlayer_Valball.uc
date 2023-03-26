class R_RunePlayer_Valball extends R_RunePlayer;

state PlayerWalking
{
    function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) || (Weapon != None && Weapon.Class == Class'RMod_Valball.R_Ball') )
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.3*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.3*GroundSpeed*X + (Velocity Dot Y)*Y; 
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.3*GroundSpeed*Y + (Velocity Dot X)*X; 
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.3*GroundSpeed*Y + (Velocity Dot X)*X; 

		Velocity.Z = 180;
		PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}
}