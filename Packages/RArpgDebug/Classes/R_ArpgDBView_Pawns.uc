//==============================================================================
//	R_ArpgDBView_Pawns
//	Debug view for Arpg Pawns
//==============================================================================
class R_ArpgDBView_Pawns extends R_ArpgDBView config(RArpgDebug);

const DebugCategory = 'Pawns';
const DebugCategoryTags = 'PawnsTags';
const DebugCategoryAttributes = 'PawnsAttributes';

var config private bool bDrawTags;
var config private bool bDrawAttributes;

simulated function ToggleTags()
{
	bDrawTags = !bDrawTags;
	SaveConfig();
}

simulated function ToggleAttributes()
{
	bDrawAttributes = !bDrawAttributes;
	SaveConfig();
}

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	local R_ArpgDBMutator DBM;

	DBM = GetArpgDebugMutator();
	if(DBM == None)
	{
		StringManager.AddWarning(DebugCategory, "Failed to get reference to Arpg Debug Mutator");
		return;
	}

	StringManager.AddWarning(DebugCategory, "Pawn view is good to go!");

	DrawAllPawns(C, StringManager, DBM);

	if(bDrawTags)		DrawTags(C, StringManager, DBM);
	if(bDrawAttributes)	DrawAttributes(C, StringManager, DBM);
}

simulated function DrawAllPawns(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local Pawn P;

	P = DBM.Level.PawnList;
	while(P != None)
	{
		if(R_ArpgPawn(P) != None)
		{
			DrawPawnBoundingBox(C, DBM, R_ArpgPawn(P));
		}

		P = P.NextPawn;
	}
}

simulated function DrawPawnBoundingBox(Canvas C, R_ArpgDBMutator DBM, R_ArpgPawn P)
{
	local Rotator ViewRotation;
	local Vector Extent1, Extent2;

	ViewRotation = DBM.GetDebugViewRotation();
	CanvasLib.Static.GetScreenSpaceBoundingBoxForActor(C, P, ViewRotation, Extent1, Extent2);
	CanvasLib.Static.DrawBoxOutline(C, Extent1, Extent2, 2.0, 1.0, 1.0, 0.0, 1.0);
}

simulated function DrawTags(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local R_ArpgPawn P;
	local R_ArpgEntity Entity;
	local R_ArpgEntityTagContainer TagContainer;
	local Name UniqueTags[32];
	local int UniqueTagCount;
	local int i;

	P = R_ArpgPawn(DBM.GetDebugTarget());
	if(P == None)
	{
		StringManager.AddWarning(DebugCategoryTags, "DebugTarget is not an R_ArpgPawn, cannot view tags");
		return;
	}

	Entity = P.GetEntity();
	if(Entity == None)
	{
		StringManager.AddWarning(DebugCategoryTags, "Could not retrieve Entity from ArpgPawn");
		return;
	}

	TagContainer = Entity.GetEntityTagContainer();
	if(TagContainer == None)
	{
		StringManager.AddWarning(DebugCategoryTags, "Could not retrieve EntityTagContainer from Entity");
		return;
	}

	TagContainer.GetUniqueTags(UniqueTags, UniqueTagCount);
	StringManager.AddInt(DebugCategoryTags, "Unique Tag Count", UniqueTagCount);
	for(i = 0; i < UniqueTagCount; ++i)
	{
		StringManager.AddName(DebugCategoryTags, "---", UniqueTags[i]);
	}
}

simulated function DrawAttributes(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local R_ArpgPawn P;
	local R_ArpgEntity Entity;
	local R_ArpgAttributeSet AttributeSet;
	local int AttributeCount;
	local Name AttributeName;
	local float AttributeBaseValue;
	local float AttributeAggregateValue;
	local String BaseValueString, AggregateValueString;
	local int i;

	P = R_ArpgPawn(DBM.GetDebugTarget());
	if(P == None)
	{
		StringManager.AddWarning(DebugCategoryAttributes, "DebugTarget is not an R_ArpgPawn, cannot view attributes");
		return;
	}

	Entity = P.GetEntity();
	if(Entity == None)
	{
		StringManager.AddWarning(DebugCategoryAttributes, "Could not retrieve Entity from ArpgPawn");
		return;
	}

	AttributeSet = Entity.GetEntityAttributeSet();
	if(AttributeSet == None)
	{
		StringManager.AddWarning(DebugCategoryAttributes, "Could not retrieve AttributeSet from Entity");
		return;
	}

	AttributeCount = AttributeSet.GetAttributeCount();
	StringManager.AddInt(DebugCategoryAttributes, "Attribute Count", AttributeCount);

	for(i = 0; i < AttributeCount; ++i)
	{
		AttributeSet.GetAttributeByIndex(i, AttributeName, AttributeBaseValue, AttributeAggregateValue);
		BaseValueString = UtilityLib.Static.FloatToString(AttributeBaseValue, 1);
		AggregateValueString = UtilityLib.Static.FloatToString(AttributeAggregateValue, 1);
		StringManager.AddString(DebugCategoryAttributes, "{Base: " $ BaseValueString $ ", Aggregate: " $ AggregateValueString $ "}", "[" $ String(AttributeName) $ "]");
	}
}