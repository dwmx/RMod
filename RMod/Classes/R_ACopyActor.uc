class R_ACopyActor extends Object abstract;

// Non-copyable const vars

// bStatic
// bNoDelete
// bDeleteMe
// bAssimilated
// bTicked
// bIsMover
// bAlwaysTick
// bIsPawn
// bNetTemporary
// bNetOptional
// Physics
// NetTag
// Owner
// TimerCounter
// Level
// XLevel
// Base
// Region
// StandingCount
// MiscNumber
// LatentByte
// LatentInt
// LatentFloat
// LatentActor
// Deleted
// CollisionTag
// LightingTag
// OtherTag
// ExtraTag
// SpecialTag
// Location
// Rotation
// OldLocation
// ColLocation
// bSelected
// bMemorized
// bHighlighted
// bTempEditor
// Brush
// CollisionRadius
// CollisionHeight
// bCollideActors
// bJustTeleported
// bNetInitial
// bNetOwner
// bNetRelevant
// bNetSee
// bNetHear
// bNetFeel
// bSimulatedPawn
// bDemoRecording
// bClientDemoRecording
// bClientDemoNetFunc
// Touching[4]

static function CopyByClass(class<Actor> Source, Actor Destination)
{
	local int i;

	Destination.bHidden                   	= Source.Default.bHidden;
	Destination.bReleaseLock              	= Source.Default.bReleaseLock;
	Destination.bAnimFinished             	= Source.Default.bAnimFinished;
	Destination.bAnimLoop                 	= Source.Default.bAnimLoop;
	Destination.bAnimNotify               	= Source.Default.bAnimNotify;
	Destination.bAnimByOwner              	= Source.Default.bAnimByOwner;
	Destination.bLightChanged             	= Source.Default.bLightChanged;
	Destination.bDynamicLight             	= Source.Default.bDynamicLight;
	Destination.bTimerLoop                	= Source.Default.bTimerLoop;
	Destination.bRenderedLastFrame        	= Source.Default.bRenderedLastFrame;
	Destination.bSpecialRender            	= Source.Default.bSpecialRender;
	Destination.bCanTeleport              	= Source.Default.bCanTeleport;
	Destination.bOwnerNoSee               	= Source.Default.bOwnerNoSee;
	Destination.bOnlyOwnerSee             	= Source.Default.bOnlyOwnerSee;
	Destination.bAlwaysRelevant           	= Source.Default.bAlwaysRelevant;
	Destination.bHighDetail               	= Source.Default.bHighDetail;
	Destination.bStasis                   	= Source.Default.bStasis;
	Destination.bForceStasis              	= Source.Default.bForceStasis;
	Destination.bReplicateInstigator      	= Source.Default.bReplicateInstigator;
	Destination.bTrailerSameRotation      	= Source.Default.bTrailerSameRotation;
	Destination.bTrailerPrePivot          	= Source.Default.bTrailerPrePivot;
	Destination.bClientAnim               	= Source.Default.bClientAnim;
	Destination.bSimFall                  	= Source.Default.bSimFall;
	Destination.bFrameNotifies            	= Source.Default.bFrameNotifies;
	Destination.bLookFocusPlayer          	= Source.Default.bLookFocusPlayer;
	Destination.bLookFocusCreature        	= Source.Default.bLookFocusCreature;
	Destination.bForceRender              	= Source.Default.bForceRender;
	Destination.Role                      	= Source.Default.Role;
	Destination.RemoteRole                	= Source.Default.RemoteRole;
	Destination.InitialState              	= Source.Default.InitialState;
	Destination.Group                     	= Source.Default.Group;
	Destination.TimerRate                 	= Source.Default.TimerRate;
	Destination.LifeSpan                  	= Source.Default.LifeSpan;
	Destination.AnimSequence              	= Source.Default.AnimSequence;
	Destination.AnimFrame                 	= Source.Default.AnimFrame;
	Destination.AnimRate                  	= Source.Default.AnimRate;
	Destination.TweenRate                 	= Source.Default.TweenRate;
	Destination.LODBias                   	= Source.Default.LODBias;
	Destination.Tag                       	= Source.Default.Tag;
	Destination.Event                     	= Source.Default.Event;
	Destination.Target                    	= Source.Default.Target;
	Destination.Instigator                	= Source.Default.Instigator;
	Destination.Inventory                 	= Source.Default.Inventory;
	Destination.BaseJoint                 	= Source.Default.BaseJoint;
	Destination.BaseMatterType            	= Source.Default.BaseMatterType;
	Destination.BaseScrollDir             	= Source.Default.BaseScrollDir;
	Destination.AttachTag                 	= Source.Default.AttachTag;
	Destination.Velocity                  	= Source.Default.Velocity;
	Destination.Acceleration              	= Source.Default.Acceleration;
	Destination.OddsOfAppearing           	= Source.Default.OddsOfAppearing;
	Destination.bHiddenEd                 	= Source.Default.bHiddenEd;
	Destination.bDirectional              	= Source.Default.bDirectional;
	Destination.bEdLocked                 	= Source.Default.bEdLocked;
	Destination.bEdShouldSnap             	= Source.Default.bEdShouldSnap;
	Destination.bEdSnap                   	= Source.Default.bEdSnap;
	Destination.bDifficulty0              	= Source.Default.bDifficulty0;
	Destination.bDifficulty1              	= Source.Default.bDifficulty1;
	Destination.bDifficulty2              	= Source.Default.bDifficulty2;
	Destination.bDifficulty3              	= Source.Default.bDifficulty3;
	Destination.bSinglePlayer             	= Source.Default.bSinglePlayer;
	Destination.bNet                      	= Source.Default.bNet;
	Destination.bNetSpecial               	= Source.Default.bNetSpecial;
	Destination.DrawType                  	= Source.Default.DrawType;
	Destination.Style                     	= Source.Default.Style;
	Destination.Sprite                    	= Source.Default.Sprite;
	Destination.Texture                   	= Source.Default.Texture;
	Destination.Skin                      	= Source.Default.Skin;
	Destination.Mesh                      	= Source.Default.Mesh;
	Destination.bHasShadow                	= Source.Default.bHasShadow;
	Destination.ShadowTexture             	= Source.Default.ShadowTexture;
	Destination.ShadowVector              	= Source.Default.ShadowVector;
	Destination.DrawScale                 	= Source.Default.DrawScale;
	Destination.PrePivot                  	= Source.Default.PrePivot;
	Destination.ScaleGlow                 	= Source.Default.ScaleGlow;
	Destination.VisibilityRadius          	= Source.Default.VisibilityRadius;
	Destination.VisibilityHeight          	= Source.Default.VisibilityHeight;
	Destination.AmbientGlow               	= Source.Default.AmbientGlow;
	Destination.Fatness                   	= Source.Default.Fatness;
	Destination.SpriteProjForward         	= Source.Default.SpriteProjForward;
	Destination.ColorAdjust               	= Source.Default.ColorAdjust;
	Destination.DesiredColorAdjust        	= Source.Default.DesiredColorAdjust;
	Destination.DesiredFatness            	= Source.Default.DesiredFatness;
	Destination.AlphaScale                	= Source.Default.AlphaScale;
	Destination.LODPolyCount              	= Source.Default.LODPolyCount;
	Destination.LODDistMax                	= Source.Default.LODDistMax;
	Destination.LODDistMin                	= Source.Default.LODDistMin;
	Destination.LODPercentMin             	= Source.Default.LODPercentMin;
	Destination.LODPercentMax             	= Source.Default.LODPercentMax;
	Destination.LODCurve                  	= Source.Default.LODCurve;
	Destination.bUnlit                    	= Source.Default.bUnlit;
	Destination.bPointLight               	= Source.Default.bPointLight;
	Destination.bMirrored                 	= Source.Default.bMirrored;
	Destination.bNoSmooth                 	= Source.Default.bNoSmooth;
	Destination.bParticles                	= Source.Default.bParticles;
	Destination.bRandomFrame              	= Source.Default.bRandomFrame;
	Destination.bMeshEnviroMap            	= Source.Default.bMeshEnviroMap;
	Destination.bMeshCurvy                	= Source.Default.bMeshCurvy;
	Destination.bFilterByVolume           	= Source.Default.bFilterByVolume;
	Destination.bPreLight                 	= Source.Default.bPreLight;
	Destination.bComplexOcclusion         	= Source.Default.bComplexOcclusion;
	Destination.bShadowCast               	= Source.Default.bShadowCast;
	Destination.bGameRelevant             	= Source.Default.bGameRelevant;
	Destination.bCarriedItem              	= Source.Default.bCarriedItem;
	Destination.bForcePhysicsUpdate       	= Source.Default.bForcePhysicsUpdate;
	Destination.bIsSecretGoal             	= Source.Default.bIsSecretGoal;
	Destination.bIsKillGoal               	= Source.Default.bIsKillGoal;
	Destination.bIsItemGoal               	= Source.Default.bIsItemGoal;
	Destination.bCollideWhenPlacing       	= Source.Default.bCollideWhenPlacing;
	Destination.bTravel                   	= Source.Default.bTravel;
	Destination.bMovable                  	= Source.Default.bMovable;
	Destination.AttachParent              	= Source.Default.AttachParent;
	Destination.AttachParentJoint         	= Source.Default.AttachParentJoint;
	Destination.SoundRadius               	= Source.Default.SoundRadius;
	Destination.SoundVolume               	= Source.Default.SoundVolume;
	Destination.SoundPitch                	= Source.Default.SoundPitch;
	Destination.AmbientSound              	= Source.Default.AmbientSound;
	Destination.TransientSoundVolume      	= Source.Default.TransientSoundVolume;
	Destination.TransientSoundRadius      	= Source.Default.TransientSoundRadius;
	Destination.bCollideWorld             	= Source.Default.bCollideWorld;
	Destination.bBlockActors              	= Source.Default.bBlockActors;
	Destination.bBlockPlayers             	= Source.Default.bBlockPlayers;
	Destination.bProjTarget               	= Source.Default.bProjTarget;
	Destination.bJointsBlock              	= Source.Default.bJointsBlock;
	Destination.bJointsTouch              	= Source.Default.bJointsTouch;
	Destination.bSweepable                	= Source.Default.bSweepable;
	Destination.LightType                 	= Source.Default.LightType;
	Destination.LightEffect               	= Source.Default.LightEffect;
	Destination.LightBrightness           	= Source.Default.LightBrightness;
	Destination.LightHue                  	= Source.Default.LightHue;
	Destination.LightSaturation           	= Source.Default.LightSaturation;
	Destination.LightRadius               	= Source.Default.LightRadius;
	Destination.LightPeriod               	= Source.Default.LightPeriod;
	Destination.LightPhase                	= Source.Default.LightPhase;
	Destination.LightCone                 	= Source.Default.LightCone;
	Destination.VolumeBrightness          	= Source.Default.VolumeBrightness;
	Destination.VolumeRadius              	= Source.Default.VolumeRadius;
	Destination.VolumeFog                 	= Source.Default.VolumeFog;
	Destination.bSpecialLit               	= Source.Default.bSpecialLit;
	Destination.bSpecialLit2              	= Source.Default.bSpecialLit2;
	Destination.bSpecialLit3              	= Source.Default.bSpecialLit3;
	Destination.bActorShadows             	= Source.Default.bActorShadows;
	Destination.bCorona                   	= Source.Default.bCorona;
	Destination.bLensFlare                	= Source.Default.bLensFlare;
	Destination.bNegativeLight            	= Source.Default.bNegativeLight;
	Destination.bAffectWorld              	= Source.Default.bAffectWorld;
	Destination.bAffectActors             	= Source.Default.bAffectActors;
	Destination.bBounce                   	= Source.Default.bBounce;
	Destination.bFixedRotationDir         	= Source.Default.bFixedRotationDir;
	Destination.bRotateToDesired          	= Source.Default.bRotateToDesired;
	Destination.bInterpolating            	= Source.Default.bInterpolating;
	Destination.DodgeDir                  	= Source.Default.DodgeDir;
	Destination.Mass                      	= Source.Default.Mass;
	Destination.Buoyancy                  	= Source.Default.Buoyancy;
	Destination.RotationRate              	= Source.Default.RotationRate;
	Destination.DesiredRotation           	= Source.Default.DesiredRotation;
	Destination.PhysAlpha                 	= Source.Default.PhysAlpha;
	Destination.PhysRate                  	= Source.Default.PhysRate;
	Destination.PendingTouch              	= Source.Default.PendingTouch;
	Destination.AnimLast                  	= Source.Default.AnimLast;
	Destination.AnimMinRate               	= Source.Default.AnimMinRate;
	Destination.OldAnimRate               	= Source.Default.OldAnimRate;
	Destination.SimAnim                   	= Source.Default.SimAnim;
	Destination.NetPriority               	= Source.Default.NetPriority;
	Destination.NetUpdateFrequency        	= Source.Default.NetUpdateFrequency;
	Destination.bNoSurfaceBob             	= Source.Default.bNoSurfaceBob;
	Destination.bDrawSkel                 	= Source.Default.bDrawSkel;
	Destination.bDrawJoints               	= Source.Default.bDrawJoints;
	Destination.bDrawAxes                 	= Source.Default.bDrawAxes;
	Destination.bApplyLagToAccelerators   	= Source.Default.bApplyLagToAccelerators;
	Destination.SkelMesh                  	= Source.Default.SkelMesh;
	Destination.Skeletal                  	= Source.Default.Skeletal;
	Destination.SubstituteMesh            	= Source.Default.SubstituteMesh;
	Destination.BlendAnimAlpha            	= Source.Default.BlendAnimAlpha;
	Destination.BlendAnimFrame            	= Source.Default.BlendAnimFrame;
	Destination.BlendAnimSequence         	= Source.Default.BlendAnimSequence;
	Destination.AnimProxy                 	= Source.Default.AnimProxy;
	Destination.RenderIteratorClass       	= Source.Default.RenderIteratorClass;
	Destination.RenderInterface           	= Source.Default.RenderInterface;

	for(i = 0; i < 8; ++i)	Destination.MultiSkins[i] 		= Source.Default.MultiSkins[i];
	for(i = 0; i < 16; ++i)	Destination.SkelGroupSkins[i] 	= Source.Default.SkelGroupSkins[i];
	for(i = 0; i < 16; ++i)	Destination.SkelGroupFlags[i] 	= Source.Default.SkelGroupFlags[i];
	for(i = 0; i < 50; ++i)	Destination.JointFlags[i] 		= Source.Default.JointFlags[i];
	for(i = 0; i < 50; ++i)	Destination.JointChild[i] 		= Source.Default.JointChild[i];
}

static function CopyByInstance(Actor Source, Actor Destination)
{
	local int i;

	Destination.bHidden                   	= Source.bHidden;
	Destination.bReleaseLock              	= Source.bReleaseLock;
	Destination.bAnimFinished             	= Source.bAnimFinished;
	Destination.bAnimLoop                 	= Source.bAnimLoop;
	Destination.bAnimNotify               	= Source.bAnimNotify;
	Destination.bAnimByOwner              	= Source.bAnimByOwner;
	Destination.bLightChanged             	= Source.bLightChanged;
	Destination.bDynamicLight             	= Source.bDynamicLight;
	Destination.bTimerLoop                	= Source.bTimerLoop;
	Destination.bRenderedLastFrame        	= Source.bRenderedLastFrame;
	Destination.bSpecialRender            	= Source.bSpecialRender;
	Destination.bCanTeleport              	= Source.bCanTeleport;
	Destination.bOwnerNoSee               	= Source.bOwnerNoSee;
	Destination.bOnlyOwnerSee             	= Source.bOnlyOwnerSee;
	Destination.bAlwaysRelevant           	= Source.bAlwaysRelevant;
	Destination.bHighDetail               	= Source.bHighDetail;
	Destination.bStasis                   	= Source.bStasis;
	Destination.bForceStasis              	= Source.bForceStasis;
	Destination.bReplicateInstigator      	= Source.bReplicateInstigator;
	Destination.bTrailerSameRotation      	= Source.bTrailerSameRotation;
	Destination.bTrailerPrePivot          	= Source.bTrailerPrePivot;
	Destination.bClientAnim               	= Source.bClientAnim;
	Destination.bSimFall                  	= Source.bSimFall;
	Destination.bFrameNotifies            	= Source.bFrameNotifies;
	Destination.bLookFocusPlayer          	= Source.bLookFocusPlayer;
	Destination.bLookFocusCreature        	= Source.bLookFocusCreature;
	Destination.bForceRender              	= Source.bForceRender;
	Destination.Role                      	= Source.Role;
	Destination.RemoteRole                	= Source.RemoteRole;
	Destination.InitialState              	= Source.InitialState;
	Destination.Group                     	= Source.Group;
	Destination.TimerRate                 	= Source.TimerRate;
	Destination.LifeSpan                  	= Source.LifeSpan;
	Destination.AnimSequence              	= Source.AnimSequence;
	Destination.AnimFrame                 	= Source.AnimFrame;
	Destination.AnimRate                  	= Source.AnimRate;
	Destination.TweenRate                 	= Source.TweenRate;
	Destination.LODBias                   	= Source.LODBias;
	Destination.Tag                       	= Source.Tag;
	Destination.Event                     	= Source.Event;
	Destination.Target                    	= Source.Target;
	Destination.Instigator                	= Source.Instigator;
	Destination.Inventory                 	= Source.Inventory;
	Destination.BaseJoint                 	= Source.BaseJoint;
	Destination.BaseMatterType            	= Source.BaseMatterType;
	Destination.BaseScrollDir             	= Source.BaseScrollDir;
	Destination.AttachTag                 	= Source.AttachTag;
	Destination.Velocity                  	= Source.Velocity;
	Destination.Acceleration              	= Source.Acceleration;
	Destination.OddsOfAppearing           	= Source.OddsOfAppearing;
	Destination.bHiddenEd                 	= Source.bHiddenEd;
	Destination.bDirectional              	= Source.bDirectional;
	Destination.bEdLocked                 	= Source.bEdLocked;
	Destination.bEdShouldSnap             	= Source.bEdShouldSnap;
	Destination.bEdSnap                   	= Source.bEdSnap;
	Destination.bDifficulty0              	= Source.bDifficulty0;
	Destination.bDifficulty1              	= Source.bDifficulty1;
	Destination.bDifficulty2              	= Source.bDifficulty2;
	Destination.bDifficulty3              	= Source.bDifficulty3;
	Destination.bSinglePlayer             	= Source.bSinglePlayer;
	Destination.bNet                      	= Source.bNet;
	Destination.bNetSpecial               	= Source.bNetSpecial;
	Destination.DrawType                  	= Source.DrawType;
	Destination.Style                     	= Source.Style;
	Destination.Sprite                    	= Source.Sprite;
	Destination.Texture                   	= Source.Texture;
	Destination.Skin                      	= Source.Skin;
	Destination.Mesh                      	= Source.Mesh;
	Destination.bHasShadow                	= Source.bHasShadow;
	Destination.ShadowTexture             	= Source.ShadowTexture;
	Destination.ShadowVector              	= Source.ShadowVector;
	Destination.DrawScale                 	= Source.DrawScale;
	Destination.PrePivot                  	= Source.PrePivot;
	Destination.ScaleGlow                 	= Source.ScaleGlow;
	Destination.VisibilityRadius          	= Source.VisibilityRadius;
	Destination.VisibilityHeight          	= Source.VisibilityHeight;
	Destination.AmbientGlow               	= Source.AmbientGlow;
	Destination.Fatness                   	= Source.Fatness;
	Destination.SpriteProjForward         	= Source.SpriteProjForward;
	Destination.ColorAdjust               	= Source.ColorAdjust;
	Destination.DesiredColorAdjust        	= Source.DesiredColorAdjust;
	Destination.DesiredFatness            	= Source.DesiredFatness;
	Destination.AlphaScale                	= Source.AlphaScale;
	Destination.LODPolyCount              	= Source.LODPolyCount;
	Destination.LODDistMax                	= Source.LODDistMax;
	Destination.LODDistMin                	= Source.LODDistMin;
	Destination.LODPercentMin             	= Source.LODPercentMin;
	Destination.LODPercentMax             	= Source.LODPercentMax;
	Destination.LODCurve                  	= Source.LODCurve;
	Destination.bUnlit                    	= Source.bUnlit;
	Destination.bPointLight               	= Source.bPointLight;
	Destination.bMirrored                 	= Source.bMirrored;
	Destination.bNoSmooth                 	= Source.bNoSmooth;
	Destination.bParticles                	= Source.bParticles;
	Destination.bRandomFrame              	= Source.bRandomFrame;
	Destination.bMeshEnviroMap            	= Source.bMeshEnviroMap;
	Destination.bMeshCurvy                	= Source.bMeshCurvy;
	Destination.bFilterByVolume           	= Source.bFilterByVolume;
	Destination.bPreLight                 	= Source.bPreLight;
	Destination.bComplexOcclusion         	= Source.bComplexOcclusion;
	Destination.bShadowCast               	= Source.bShadowCast;
	Destination.bGameRelevant             	= Source.bGameRelevant;
	Destination.bCarriedItem              	= Source.bCarriedItem;
	Destination.bForcePhysicsUpdate       	= Source.bForcePhysicsUpdate;
	Destination.bIsSecretGoal             	= Source.bIsSecretGoal;
	Destination.bIsKillGoal               	= Source.bIsKillGoal;
	Destination.bIsItemGoal               	= Source.bIsItemGoal;
	Destination.bCollideWhenPlacing       	= Source.bCollideWhenPlacing;
	Destination.bTravel                   	= Source.bTravel;
	Destination.bMovable                  	= Source.bMovable;
	Destination.AttachParent              	= Source.AttachParent;
	Destination.AttachParentJoint         	= Source.AttachParentJoint;
	Destination.SoundRadius               	= Source.SoundRadius;
	Destination.SoundVolume               	= Source.SoundVolume;
	Destination.SoundPitch                	= Source.SoundPitch;
	Destination.AmbientSound              	= Source.AmbientSound;
	Destination.TransientSoundVolume      	= Source.TransientSoundVolume;
	Destination.TransientSoundRadius      	= Source.TransientSoundRadius;
	Destination.bCollideWorld             	= Source.bCollideWorld;
	Destination.bBlockActors              	= Source.bBlockActors;
	Destination.bBlockPlayers             	= Source.bBlockPlayers;
	Destination.bProjTarget               	= Source.bProjTarget;
	Destination.bJointsBlock              	= Source.bJointsBlock;
	Destination.bJointsTouch              	= Source.bJointsTouch;
	Destination.bSweepable                	= Source.bSweepable;
	Destination.LightType                 	= Source.LightType;
	Destination.LightEffect               	= Source.LightEffect;
	Destination.LightBrightness           	= Source.LightBrightness;
	Destination.LightHue                  	= Source.LightHue;
	Destination.LightSaturation           	= Source.LightSaturation;
	Destination.LightRadius               	= Source.LightRadius;
	Destination.LightPeriod               	= Source.LightPeriod;
	Destination.LightPhase                	= Source.LightPhase;
	Destination.LightCone                 	= Source.LightCone;
	Destination.VolumeBrightness          	= Source.VolumeBrightness;
	Destination.VolumeRadius              	= Source.VolumeRadius;
	Destination.VolumeFog                 	= Source.VolumeFog;
	Destination.bSpecialLit               	= Source.bSpecialLit;
	Destination.bSpecialLit2              	= Source.bSpecialLit2;
	Destination.bSpecialLit3              	= Source.bSpecialLit3;
	Destination.bActorShadows             	= Source.bActorShadows;
	Destination.bCorona                   	= Source.bCorona;
	Destination.bLensFlare                	= Source.bLensFlare;
	Destination.bNegativeLight            	= Source.bNegativeLight;
	Destination.bAffectWorld              	= Source.bAffectWorld;
	Destination.bAffectActors             	= Source.bAffectActors;
	Destination.bBounce                   	= Source.bBounce;
	Destination.bFixedRotationDir         	= Source.bFixedRotationDir;
	Destination.bRotateToDesired          	= Source.bRotateToDesired;
	Destination.bInterpolating            	= Source.bInterpolating;
	Destination.DodgeDir                  	= Source.DodgeDir;
	Destination.Mass                      	= Source.Mass;
	Destination.Buoyancy                  	= Source.Buoyancy;
	Destination.RotationRate              	= Source.RotationRate;
	Destination.DesiredRotation           	= Source.DesiredRotation;
	Destination.PhysAlpha                 	= Source.PhysAlpha;
	Destination.PhysRate                  	= Source.PhysRate;
	Destination.PendingTouch              	= Source.PendingTouch;
	Destination.AnimLast                  	= Source.AnimLast;
	Destination.AnimMinRate               	= Source.AnimMinRate;
	Destination.OldAnimRate               	= Source.OldAnimRate;
	Destination.SimAnim                   	= Source.SimAnim;
	Destination.NetPriority               	= Source.NetPriority;
	Destination.NetUpdateFrequency        	= Source.NetUpdateFrequency;
	Destination.bNoSurfaceBob             	= Source.bNoSurfaceBob;
	Destination.bDrawSkel                 	= Source.bDrawSkel;
	Destination.bDrawJoints               	= Source.bDrawJoints;
	Destination.bDrawAxes                 	= Source.bDrawAxes;
	Destination.bApplyLagToAccelerators   	= Source.bApplyLagToAccelerators;
	Destination.SkelMesh                  	= Source.SkelMesh;
	Destination.Skeletal                  	= Source.Skeletal;
	Destination.SubstituteMesh            	= Source.SubstituteMesh;
	Destination.BlendAnimAlpha            	= Source.BlendAnimAlpha;
	Destination.BlendAnimFrame            	= Source.BlendAnimFrame;
	Destination.BlendAnimSequence         	= Source.BlendAnimSequence;
	Destination.AnimProxy                 	= Source.AnimProxy;
	Destination.RenderIteratorClass       	= Source.RenderIteratorClass;
	Destination.RenderInterface           	= Source.RenderInterface;

	for(i = 0; i < 8; ++i)	Destination.MultiSkins[i] 		= Source.MultiSkins[i];
	for(i = 0; i < 16; ++i)	Destination.SkelGroupSkins[i] 	= Source.SkelGroupSkins[i];
	for(i = 0; i < 16; ++i)	Destination.SkelGroupFlags[i] 	= Source.SkelGroupFlags[i];
	for(i = 0; i < 50; ++i)	Destination.JointFlags[i] 		= Source.JointFlags[i];
	for(i = 0; i < 50; ++i)	Destination.JointChild[i] 		= Source.JointChild[i];
}

defaultproperties
{
}
