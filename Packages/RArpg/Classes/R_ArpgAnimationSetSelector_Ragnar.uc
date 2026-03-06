//==============================================================================
//	R_ArpgAnimationSetSelector_Ragnar
//	Maps weapon tags to AnimationSets
//==============================================================================
class R_ArpgAnimationSetSelector_Ragnar extends R_ArpgAnimationSetSelector abstract;

const ANIMSET_CLASS_DEFAULT		= Class'RArpg.R_ArpgAnimationSet_Ragnar_Default';
const ANIMSET_CLASS_BATTLE_AXE 	= Class'RArpg.R_ArpgAnimationSet_Ragnar_BattleAxe';
const ANIMSET_CLASS_BROAD_SWORD	= Class'RArpg.R_ArpgAnimationSet_Ragnar_BroadSword';

static function Class<R_ArpgAnimationSet> GetDefaultAnimationSetClass()
{
	return ANIMSET_CLASS_DEFAULT;
}

static function Class<R_ArpgAnimationSet> GetAnimationSetClassFromTag(R_ArpgTag Tag)
{
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Axe')))		return ANIMSET_CLASS_BATTLE_AXE;
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Sword')))	return ANIMSET_CLASS_BROAD_SWORD;

	return ANIMSET_CLASS_DEFAULT;
}