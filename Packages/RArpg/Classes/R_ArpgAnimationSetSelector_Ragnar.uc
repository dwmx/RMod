//==============================================================================
//	R_ArpgAnimationSetSelector_Ragnar
//	Maps weapon tags to AnimationSets
//==============================================================================
class R_ArpgAnimationSetSelector_Ragnar extends R_ArpgAnimationSetSelector abstract;

const ANIMSET_CLASS_DEFAULT		= Class'RArpg.R_ArpgAnimationSet_Ragnar';
const ANIMSET_CLASS_BATTLE_AXE 	= Class'RArpg.R_ArpgAnimationSet_Ragnar_BattleAxe';
const ANIMSET_CLASS_BROAD_SWORD	= Class'RArpg.R_ArpgAnimationSet_Ragnar_BroadSword';
const ANIMSET_CLASS_BATTLE_SWORD = Class'RArpg.R_ArpgAnimationSet_Ragnar_BattleSword';

static function Class<R_ArpgAnimationSet> GetDefaultAnimationSetClass()
{
	return ANIMSET_CLASS_DEFAULT;
}

static function Class<R_ArpgAnimationSet> GetAnimationSetClassFromTag(R_ArpgTag Tag)
{
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Axe')))		return ANIMSET_CLASS_BATTLE_AXE;
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Hammer')))	return ANIMSET_CLASS_BATTLE_AXE;
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword')))	return ANIMSET_CLASS_BROAD_SWORD;
	if(TagLib.Static.MatchHierarchy(Tag, TagLib.Static.MakeTag('Item','Weapon','Sword','BattleSword')))	return ANIMSET_CLASS_BATTLE_SWORD;

	return ANIMSET_CLASS_DEFAULT;
}