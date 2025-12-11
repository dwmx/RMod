class R_RBotsDebug_Translator extends R_RBotsObject;

const StringCategoryBB = 'BlackBoard';

static function DrawBlackBoardValidated(Canvas C, R_DBStringManager StringManager, R_BlackBoard BlackBoard)
{
	local int NumKeys;
	local Name CurrentKey;
	local R_Variant CurrentVariant;
	local int CurrentType;
	local int i;

	NumKeys = BlackBoard.GetNumKeys();
	StringManager.AddInt(StringCategoryBB, "NumKeys", NumKeys);

	for(i = 0; i < NumKeys; ++i)
	{
		BlackBoard.GetKeyTypeAtIndex(i, CurrentKey, CurrentType);
		BlackBoard.Get(CurrentKey, CurrentVariant);
		switch(CurrentType)
		{
			case TypeCodeInt:		StringManager.AddInt(StringCategoryBB, String(CurrentKey), GetIntVariant(CurrentVariant));			break;
			case TypeCodeFloat:		StringManager.AddFloat(StringCategoryBB, String(CurrentKey), GetFloatVariant(CurrentVariant)); 		break;
			case TypeCodeVector:	StringManager.AddVector(StringCategoryBB, String(CurrentKey), GetVectorVariant(CurrentVariant)); 	break;
			case TypeCodeActor:		StringManager.AddActor(StringCategoryBB, String(CurrentKey), GetActorVariant(CurrentVariant));		break;
			case TypeCodeClass:		StringManager.AddClass(StringCategoryBB, String(CurrentKey), GetClassVariant(CurrentVariant));		break;
			case TypeCodeObject:	StringManager.AddObject(StringCategoryBB, String(CurrentKey), GetObjectVariant(CurrentVariant));	break;
			default:
				StringManager.AddWarning(StringCategoryBB, "Failed to get Key:Value for '" $ CurrentKey $ "' {TypeCode: " $ CurrentType $ "}");
		}
	}
}