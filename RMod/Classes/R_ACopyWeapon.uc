class R_ACopyWeapon extends Object abstract;

static function CopyByClass(class<Weapon> Source, Weapon Destination)
{
	local int i;
	
	Destination.bWeaponStay               	= Source.Default.bWeaponStay;
	Destination.bCrouchTwoHands           	= Source.Default.bCrouchTwoHands;
	Destination.bPoweredUp                	= Source.Default.bPoweredUp;
	Destination.bCanBePoweredUp           	= Source.Default.bCanBePoweredUp;
	Destination.bPlayedDropSound          	= Source.Default.bPlayedDropSound;
	Destination.bClientPoweredUp          	= Source.Default.bClientPoweredUp;
	Destination.HitMatterSoundCount       	= Source.Default.HitMatterSoundCount;
	Destination.StowMesh                  	= Source.Default.StowMesh;
	Destination.Damage                    	= Source.Default.Damage;
	Destination.DamageType                	= Source.Default.DamageType;
	Destination.ThrownDamageType          	= Source.Default.ThrownDamageType;
	Destination.BloodTexture              	= Source.Default.BloodTexture;
	Destination.Rating                    	= Source.Default.Rating;
	Destination.WeaponSweepExtent         	= Source.Default.WeaponSweepExtent;
	Destination.SweepJoint1               	= Source.Default.SweepJoint1;
	Destination.SweepJoint2               	= Source.Default.SweepJoint2;
	Destination.ExtendedLength            	= Source.Default.ExtendedLength;
	Destination.RunePowerRequired         	= Source.Default.RunePowerRequired;
	Destination.RunePowerDuration         	= Source.Default.RunePowerDuration;
	Destination.PowerupMessage            	= Source.Default.PowerupMessage;
	Destination.StabMesh                  	= Source.Default.StabMesh;
	Destination.TimerCount                	= Source.Default.TimerCount;
	Destination.SweepVector               	= Source.Default.SweepVector;
	Destination.FrameOfAttackAnim         	= Source.Default.FrameOfAttackAnim;
	Destination.gB1                       	= Source.Default.gB1;
	Destination.gE1                       	= Source.Default.gE1;
	Destination.gB2                       	= Source.Default.gB2;
	Destination.gE2                       	= Source.Default.gE2;
	Destination.StabbedActor              	= Source.Default.StabbedActor;
	Destination.LastThrower               	= Source.Default.LastThrower;
	Destination.HitShield                 	= Source.Default.HitShield;
	Destination.HitWeapon                 	= Source.Default.HitWeapon;
	Destination.HitBreakableWood          	= Source.Default.HitBreakableWood;
	Destination.HitBreakableStone         	= Source.Default.HitBreakableStone;
	Destination.SheathSound               	= Source.Default.SheathSound;
	Destination.UnsheathSound             	= Source.Default.UnsheathSound;
	Destination.ThrownSoundLOOP           	= Source.Default.ThrownSoundLOOP;
	Destination.PowerUpSound              	= Source.Default.PowerUpSound;
	Destination.PoweredUpSoundLOOP        	= Source.Default.PoweredUpSoundLOOP;
	Destination.PoweredUpEndingSound      	= Source.Default.PoweredUpEndingSound;
	Destination.PoweredUpEndSound         	= Source.Default.PoweredUpEndSound;
	Destination.PitchDeviation            	= Source.Default.PitchDeviation;
	Destination.PowerupIcon               	= Source.Default.PowerupIcon;
	Destination.PowerupIconAnim           	= Source.Default.PowerupIconAnim;
	Destination.lastpos1                  	= Source.Default.lastpos1;
	Destination.lastpos2                  	= Source.Default.lastpos2;
	Destination.NumThroughAirSounds       	= Source.Default.NumThroughAirSounds;
	Destination.NumThroughAirBerserkSounds	= Source.Default.NumThroughAirBerserkSounds;
	Destination.NumFleshSounds            	= Source.Default.NumFleshSounds;
	Destination.NumWoodSounds             	= Source.Default.NumWoodSounds;
	Destination.NumStoneSounds            	= Source.Default.NumStoneSounds;
	Destination.NumMetalSounds            	= Source.Default.NumMetalSounds;
	Destination.NumEarthSounds            	= Source.Default.NumEarthSounds;
	Destination.Swipe                     	= Source.Default.Swipe;
	Destination.SwipeClass                	= Source.Default.SwipeClass;
	Destination.PoweredUpSwipeClass       	= Source.Default.PoweredUpSwipeClass;
	Destination.A_Idle                    	= Source.Default.A_Idle;
	Destination.A_TurnLeft                	= Source.Default.A_TurnLeft;
	Destination.A_TurnRight               	= Source.Default.A_TurnRight;
	Destination.A_Forward                 	= Source.Default.A_Forward;
	Destination.A_Backward                	= Source.Default.A_Backward;
	Destination.A_Forward45Right          	= Source.Default.A_Forward45Right;
	Destination.A_Forward45Left           	= Source.Default.A_Forward45Left;
	Destination.A_Backward45Right         	= Source.Default.A_Backward45Right;
	Destination.A_Backward45Left          	= Source.Default.A_Backward45Left;
	Destination.A_StrafeRight             	= Source.Default.A_StrafeRight;
	Destination.A_StrafeLeft              	= Source.Default.A_StrafeLeft;
	Destination.A_Jump                    	= Source.Default.A_Jump;
	Destination.A_ForwardAttack           	= Source.Default.A_ForwardAttack;
	Destination.A_AttackA                 	= Source.Default.A_AttackA;
	Destination.A_AttackAReturn           	= Source.Default.A_AttackAReturn;
	Destination.A_AttackB                 	= Source.Default.A_AttackB;
	Destination.A_AttackBReturn           	= Source.Default.A_AttackBReturn;
	Destination.A_AttackC                 	= Source.Default.A_AttackC;
	Destination.A_AttackCReturn           	= Source.Default.A_AttackCReturn;
	Destination.A_AttackD                 	= Source.Default.A_AttackD;
	Destination.A_AttackDReturn           	= Source.Default.A_AttackDReturn;
	Destination.A_AttackStandA            	= Source.Default.A_AttackStandA;
	Destination.A_AttackStandAReturn      	= Source.Default.A_AttackStandAReturn;
	Destination.A_AttackStandB            	= Source.Default.A_AttackStandB;
	Destination.A_AttackStandBReturn      	= Source.Default.A_AttackStandBReturn;
	Destination.A_AttackBackupA           	= Source.Default.A_AttackBackupA;
	Destination.A_AttackBackupAReturn     	= Source.Default.A_AttackBackupAReturn;
	Destination.A_AttackBackupB           	= Source.Default.A_AttackBackupB;
	Destination.A_AttackBackupBReturn     	= Source.Default.A_AttackBackupBReturn;
	Destination.A_AttackStrafeRight       	= Source.Default.A_AttackStrafeRight;
	Destination.A_AttackStrafeLeft        	= Source.Default.A_AttackStrafeLeft;
	Destination.A_JumpAttack              	= Source.Default.A_JumpAttack;
	Destination.A_Throw                   	= Source.Default.A_Throw;
	Destination.A_Powerup                 	= Source.Default.A_Powerup;
	Destination.A_Defend                  	= Source.Default.A_Defend;
	Destination.A_DefendIdle              	= Source.Default.A_DefendIdle;
	Destination.A_PainFront               	= Source.Default.A_PainFront;
	Destination.A_PainBack                	= Source.Default.A_PainBack;
	Destination.A_PainLeft                	= Source.Default.A_PainLeft;
	Destination.A_PainRight               	= Source.Default.A_PainRight;
	Destination.A_PickupGroundLeft        	= Source.Default.A_PickupGroundLeft;
	Destination.A_PickupHighLeft          	= Source.Default.A_PickupHighLeft;
	Destination.A_Taunt                   	= Source.Default.A_Taunt;
	Destination.A_PumpTrigger             	= Source.Default.A_PumpTrigger;
	Destination.A_LeverTrigger            	= Source.Default.A_LeverTrigger;
	
	for(i = 0; i < 3; ++i)	Destination.ThroughAir[i] 			= Source.Default.ThroughAir[i];
	for(i = 0; i < 3; ++i)	Destination.ThroughAirBerserk[i] 	= Source.Default.ThroughAirBerserk[i];
	for(i = 0; i < 3; ++i)	Destination.HitFlesh[i] 			= Source.Default.HitFlesh[i];
	for(i = 0; i < 3; ++i)	Destination.HitWood[i] 				= Source.Default.HitWood[i];
	for(i = 0; i < 3; ++i)	Destination.HitStone[i] 			= Source.Default.HitStone[i];
	for(i = 0; i < 3; ++i)	Destination.HitMetal[i] 			= Source.Default.HitMetal[i];
	for(i = 0; i < 3; ++i)	Destination.HitDirt[i] 				= Source.Default.HitDirt[i];
	for(i = 0; i < 3; ++i)	Destination.ThroughAir[i] 			= Source.Default.ThroughAir[i];
	
	for(i = 0; i < 16; ++i)	Destination.SwipeHits[i]			= Source.Default.SwipeHits[i];
}

static function CopyByInstance(Weapon Source, Weapon Destination)
{
	local int i;
	
	Destination.bWeaponStay               	= Source.bWeaponStay;
	Destination.bCrouchTwoHands           	= Source.bCrouchTwoHands;
	Destination.bPoweredUp                	= Source.bPoweredUp;
	Destination.bCanBePoweredUp           	= Source.bCanBePoweredUp;
	Destination.bPlayedDropSound          	= Source.bPlayedDropSound;
	Destination.bClientPoweredUp          	= Source.bClientPoweredUp;
	Destination.HitMatterSoundCount       	= Source.HitMatterSoundCount;
	Destination.StowMesh                  	= Source.StowMesh;
	Destination.Damage                    	= Source.Damage;
	Destination.DamageType                	= Source.DamageType;
	Destination.ThrownDamageType          	= Source.ThrownDamageType;
	Destination.BloodTexture              	= Source.BloodTexture;
	Destination.Rating                    	= Source.Rating;
	Destination.WeaponSweepExtent         	= Source.WeaponSweepExtent;
	Destination.SweepJoint1               	= Source.SweepJoint1;
	Destination.SweepJoint2               	= Source.SweepJoint2;
	Destination.ExtendedLength            	= Source.ExtendedLength;
	Destination.RunePowerRequired         	= Source.RunePowerRequired;
	Destination.RunePowerDuration         	= Source.RunePowerDuration;
	Destination.PowerupMessage            	= Source.PowerupMessage;
	Destination.StabMesh                  	= Source.StabMesh;
	Destination.TimerCount                	= Source.TimerCount;
	Destination.SweepVector               	= Source.SweepVector;
	Destination.FrameOfAttackAnim         	= Source.FrameOfAttackAnim;
	Destination.gB1                       	= Source.gB1;
	Destination.gE1                       	= Source.gE1;
	Destination.gB2                       	= Source.gB2;
	Destination.gE2                       	= Source.gE2;
	Destination.StabbedActor              	= Source.StabbedActor;
	Destination.LastThrower               	= Source.LastThrower;
	Destination.HitShield                 	= Source.HitShield;
	Destination.HitWeapon                 	= Source.HitWeapon;
	Destination.HitBreakableWood          	= Source.HitBreakableWood;
	Destination.HitBreakableStone         	= Source.HitBreakableStone;
	Destination.SheathSound               	= Source.SheathSound;
	Destination.UnsheathSound             	= Source.UnsheathSound;
	Destination.ThrownSoundLOOP           	= Source.ThrownSoundLOOP;
	Destination.PowerUpSound              	= Source.PowerUpSound;
	Destination.PoweredUpSoundLOOP        	= Source.PoweredUpSoundLOOP;
	Destination.PoweredUpEndingSound      	= Source.PoweredUpEndingSound;
	Destination.PoweredUpEndSound         	= Source.PoweredUpEndSound;
	Destination.PitchDeviation            	= Source.PitchDeviation;
	Destination.PowerupIcon               	= Source.PowerupIcon;
	Destination.PowerupIconAnim           	= Source.PowerupIconAnim;
	Destination.lastpos1                  	= Source.lastpos1;
	Destination.lastpos2                  	= Source.lastpos2;
	Destination.NumThroughAirSounds       	= Source.NumThroughAirSounds;
	Destination.NumThroughAirBerserkSounds	= Source.NumThroughAirBerserkSounds;
	Destination.NumFleshSounds            	= Source.NumFleshSounds;
	Destination.NumWoodSounds             	= Source.NumWoodSounds;
	Destination.NumStoneSounds            	= Source.NumStoneSounds;
	Destination.NumMetalSounds            	= Source.NumMetalSounds;
	Destination.NumEarthSounds            	= Source.NumEarthSounds;
	Destination.Swipe                     	= Source.Swipe;
	Destination.SwipeClass                	= Source.SwipeClass;
	Destination.PoweredUpSwipeClass       	= Source.PoweredUpSwipeClass;
	Destination.A_Idle                    	= Source.A_Idle;
	Destination.A_TurnLeft                	= Source.A_TurnLeft;
	Destination.A_TurnRight               	= Source.A_TurnRight;
	Destination.A_Forward                 	= Source.A_Forward;
	Destination.A_Backward                	= Source.A_Backward;
	Destination.A_Forward45Right          	= Source.A_Forward45Right;
	Destination.A_Forward45Left           	= Source.A_Forward45Left;
	Destination.A_Backward45Right         	= Source.A_Backward45Right;
	Destination.A_Backward45Left          	= Source.A_Backward45Left;
	Destination.A_StrafeRight             	= Source.A_StrafeRight;
	Destination.A_StrafeLeft              	= Source.A_StrafeLeft;
	Destination.A_Jump                    	= Source.A_Jump;
	Destination.A_ForwardAttack           	= Source.A_ForwardAttack;
	Destination.A_AttackA                 	= Source.A_AttackA;
	Destination.A_AttackAReturn           	= Source.A_AttackAReturn;
	Destination.A_AttackB                 	= Source.A_AttackB;
	Destination.A_AttackBReturn           	= Source.A_AttackBReturn;
	Destination.A_AttackC                 	= Source.A_AttackC;
	Destination.A_AttackCReturn           	= Source.A_AttackCReturn;
	Destination.A_AttackD                 	= Source.A_AttackD;
	Destination.A_AttackDReturn           	= Source.A_AttackDReturn;
	Destination.A_AttackStandA            	= Source.A_AttackStandA;
	Destination.A_AttackStandAReturn      	= Source.A_AttackStandAReturn;
	Destination.A_AttackStandB            	= Source.A_AttackStandB;
	Destination.A_AttackStandBReturn      	= Source.A_AttackStandBReturn;
	Destination.A_AttackBackupA           	= Source.A_AttackBackupA;
	Destination.A_AttackBackupAReturn     	= Source.A_AttackBackupAReturn;
	Destination.A_AttackBackupB           	= Source.A_AttackBackupB;
	Destination.A_AttackBackupBReturn     	= Source.A_AttackBackupBReturn;
	Destination.A_AttackStrafeRight       	= Source.A_AttackStrafeRight;
	Destination.A_AttackStrafeLeft        	= Source.A_AttackStrafeLeft;
	Destination.A_JumpAttack              	= Source.A_JumpAttack;
	Destination.A_Throw                   	= Source.A_Throw;
	Destination.A_Powerup                 	= Source.A_Powerup;
	Destination.A_Defend                  	= Source.A_Defend;
	Destination.A_DefendIdle              	= Source.A_DefendIdle;
	Destination.A_PainFront               	= Source.A_PainFront;
	Destination.A_PainBack                	= Source.A_PainBack;
	Destination.A_PainLeft                	= Source.A_PainLeft;
	Destination.A_PainRight               	= Source.A_PainRight;
	Destination.A_PickupGroundLeft        	= Source.A_PickupGroundLeft;
	Destination.A_PickupHighLeft          	= Source.A_PickupHighLeft;
	Destination.A_Taunt                   	= Source.A_Taunt;
	Destination.A_PumpTrigger             	= Source.A_PumpTrigger;
	Destination.A_LeverTrigger            	= Source.A_LeverTrigger;
	
	for(i = 0; i < 3; ++i)	Destination.ThroughAir[i] 			= Source.ThroughAir[i];
	for(i = 0; i < 3; ++i)	Destination.ThroughAirBerserk[i] 	= Source.ThroughAirBerserk[i];
	for(i = 0; i < 3; ++i)	Destination.HitFlesh[i] 			= Source.HitFlesh[i];
	for(i = 0; i < 3; ++i)	Destination.HitWood[i] 				= Source.HitWood[i];
	for(i = 0; i < 3; ++i)	Destination.HitStone[i] 			= Source.HitStone[i];
	for(i = 0; i < 3; ++i)	Destination.HitMetal[i] 			= Source.HitMetal[i];
	for(i = 0; i < 3; ++i)	Destination.HitDirt[i] 				= Source.HitDirt[i];
	for(i = 0; i < 3; ++i)	Destination.ThroughAir[i] 			= Source.ThroughAir[i];
	
	for(i = 0; i < 16; ++i)	Destination.SwipeHits[i]			= Source.SwipeHits[i];
}

defaultproperties
{
}
