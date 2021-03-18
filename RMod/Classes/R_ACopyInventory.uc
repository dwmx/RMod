class R_ACopyInventory extends Object abstract;

static function CopyByClass(class<Inventory> Source, Inventory Destination)
{
	Destination.AutoSwitchPriority   	= Source.Default.AutoSwitchPriority;
	Destination.InventoryGroup       	= Source.Default.InventoryGroup;
	Destination.bActivatable         	= Source.Default.bActivatable;
	Destination.bDisplayableInv      	= Source.Default.bDisplayableInv;
	Destination.bActive              	= Source.Default.bActive;
	Destination.bSleepTouch          	= Source.Default.bSleepTouch;
	Destination.bHeldItem            	= Source.Default.bHeldItem;
	Destination.bTossedOut           	= Source.Default.bTossedOut;
	Destination.bExpireWhenTossed    	= Source.Default.bExpireWhenTossed;
	Destination.bAmbientGlow         	= Source.Default.bAmbientGlow;
	Destination.bInstantRespawn      	= Source.Default.bInstantRespawn;
	Destination.bRotatingPickup      	= Source.Default.bRotatingPickup;
	Destination.PickupMessage        	= Source.Default.PickupMessage;
	Destination.ItemName             	= Source.Default.ItemName;
	Destination.ItemArticle          	= Source.Default.ItemArticle;
	Destination.RespawnTime          	= Source.Default.RespawnTime;
	Destination.PlayerLastTouched    	= Source.Default.PlayerLastTouched;
	Destination.PlayerViewOffset     	= Source.Default.PlayerViewOffset;
	Destination.PlayerViewMesh       	= Source.Default.PlayerViewMesh;
	Destination.PlayerViewScale      	= Source.Default.PlayerViewScale;
	Destination.BobDamping           	= Source.Default.BobDamping;
	Destination.ExpireTime           	= Source.Default.ExpireTime;
	Destination.PickupViewMesh       	= Source.Default.PickupViewMesh;
	Destination.PickupViewScale      	= Source.Default.PickupViewScale;
	Destination.ThirdPersonMesh      	= Source.Default.ThirdPersonMesh;
	Destination.ThirdPersonScale     	= Source.Default.ThirdPersonScale;
	Destination.StatusIcon           	= Source.Default.StatusIcon;
	Destination.ProtectionType1      	= Source.Default.ProtectionType1;
	Destination.ProtectionType2      	= Source.Default.ProtectionType2;
	Destination.Charge               	= Source.Default.Charge;
	Destination.ArmorAbsorption      	= Source.Default.ArmorAbsorption;
	Destination.bIsAnArmor           	= Source.Default.bIsAnArmor;
	Destination.AbsorptionPriority   	= Source.Default.AbsorptionPriority;
	Destination.NextArmor            	= Source.Default.NextArmor;
	Destination.MaxDesireability     	= Source.Default.MaxDesireability;
	Destination.MyMarker             	= Source.Default.MyMarker;
	Destination.bSteadyFlash3rd      	= Source.Default.bSteadyFlash3rd;
	Destination.bFirstFrame          	= Source.Default.bFirstFrame;
	Destination.bMuzzleFlashParticles	= Source.Default.bMuzzleFlashParticles;
	Destination.bToggleSteadyFlash   	= Source.Default.bToggleSteadyFlash;
	Destination.bSteadyToggle        	= Source.Default.bSteadyToggle;
	Destination.FlashCount           	= Source.Default.FlashCount;
	Destination.OldFlashCount        	= Source.Default.OldFlashCount;
	Destination.MuzzleFlashStyle     	= Source.Default.MuzzleFlashStyle;
	Destination.MuzzleFlashMesh      	= Source.Default.MuzzleFlashMesh;
	Destination.MuzzleFlashScale     	= Source.Default.MuzzleFlashScale;
	Destination.MuzzleFlashTexture   	= Source.Default.MuzzleFlashTexture;
	Destination.PickupSound          	= Source.Default.PickupSound;
	Destination.ActivateSound        	= Source.Default.ActivateSound;
	Destination.DeActivateSound      	= Source.Default.DeActivateSound;
	Destination.RespawnSound         	= Source.Default.RespawnSound;
	Destination.DropSound            	= Source.Default.DropSound;
	Destination.Icon                 	= Source.Default.Icon;
	Destination.M_Activated          	= Source.Default.M_Activated;
	Destination.M_Selected           	= Source.Default.M_Selected;
	Destination.M_Deactivated        	= Source.Default.M_Deactivated;
	Destination.PickupMessageClass   	= Source.Default.PickupMessageClass;
	Destination.ItemMessageClass     	= Source.Default.ItemMessageClass;
}

static function CopyByInstance(Inventory Source, Inventory Destination)
{
	Destination.AutoSwitchPriority   	= Source.AutoSwitchPriority;
	Destination.InventoryGroup       	= Source.InventoryGroup;
	Destination.bActivatable         	= Source.bActivatable;
	Destination.bDisplayableInv      	= Source.bDisplayableInv;
	Destination.bActive              	= Source.bActive;
	Destination.bSleepTouch          	= Source.bSleepTouch;
	Destination.bHeldItem            	= Source.bHeldItem;
	Destination.bTossedOut           	= Source.bTossedOut;
	Destination.bExpireWhenTossed    	= Source.bExpireWhenTossed;
	Destination.bAmbientGlow         	= Source.bAmbientGlow;
	Destination.bInstantRespawn      	= Source.bInstantRespawn;
	Destination.bRotatingPickup      	= Source.bRotatingPickup;
	Destination.PickupMessage        	= Source.PickupMessage;
	Destination.ItemName             	= Source.ItemName;
	Destination.ItemArticle          	= Source.ItemArticle;
	Destination.RespawnTime          	= Source.RespawnTime;
	Destination.PlayerLastTouched    	= Source.PlayerLastTouched;
	Destination.PlayerViewOffset     	= Source.PlayerViewOffset;
	Destination.PlayerViewMesh       	= Source.PlayerViewMesh;
	Destination.PlayerViewScale      	= Source.PlayerViewScale;
	Destination.BobDamping           	= Source.BobDamping;
	Destination.ExpireTime           	= Source.ExpireTime;
	Destination.PickupViewMesh       	= Source.PickupViewMesh;
	Destination.PickupViewScale      	= Source.PickupViewScale;
	Destination.ThirdPersonMesh      	= Source.ThirdPersonMesh;
	Destination.ThirdPersonScale     	= Source.ThirdPersonScale;
	Destination.StatusIcon           	= Source.StatusIcon;
	Destination.ProtectionType1      	= Source.ProtectionType1;
	Destination.ProtectionType2      	= Source.ProtectionType2;
	Destination.Charge               	= Source.Charge;
	Destination.ArmorAbsorption      	= Source.ArmorAbsorption;
	Destination.bIsAnArmor           	= Source.bIsAnArmor;
	Destination.AbsorptionPriority   	= Source.AbsorptionPriority;
	Destination.NextArmor            	= Source.NextArmor;
	Destination.MaxDesireability     	= Source.MaxDesireability;
	Destination.MyMarker             	= Source.MyMarker;
	Destination.bSteadyFlash3rd      	= Source.bSteadyFlash3rd;
	Destination.bFirstFrame          	= Source.bFirstFrame;
	Destination.bMuzzleFlashParticles	= Source.bMuzzleFlashParticles;
	Destination.bToggleSteadyFlash   	= Source.bToggleSteadyFlash;
	Destination.bSteadyToggle        	= Source.bSteadyToggle;
	Destination.FlashCount           	= Source.FlashCount;
	Destination.OldFlashCount        	= Source.OldFlashCount;
	Destination.MuzzleFlashStyle     	= Source.MuzzleFlashStyle;
	Destination.MuzzleFlashMesh      	= Source.MuzzleFlashMesh;
	Destination.MuzzleFlashScale     	= Source.MuzzleFlashScale;
	Destination.MuzzleFlashTexture   	= Source.MuzzleFlashTexture;
	Destination.PickupSound          	= Source.PickupSound;
	Destination.ActivateSound        	= Source.ActivateSound;
	Destination.DeActivateSound      	= Source.DeActivateSound;
	Destination.RespawnSound         	= Source.RespawnSound;
	Destination.DropSound            	= Source.DropSound;
	Destination.Icon                 	= Source.Icon;
	Destination.M_Activated          	= Source.M_Activated;
	Destination.M_Selected           	= Source.M_Selected;
	Destination.M_Deactivated        	= Source.M_Deactivated;
	Destination.PickupMessageClass   	= Source.PickupMessageClass;
	Destination.ItemMessageClass     	= Source.ItemMessageClass;
}

defaultproperties
{
}
