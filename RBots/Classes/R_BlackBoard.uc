//==============================================================================
//	R_BlackBoard
//	Contains AI context state shared over multiple behaviors
//==============================================================================
class R_BlackBoard extends R_RBotsObject;

const LogCategory = 'BlackBoard';

function bool AddInt(Name Key);
function bool AddFloat(Name Key);
function bool AddVector(Name Key);
function bool AddActor(Name Key);

function bool GetInt(Name Key, out int OutValue);
function bool GetFloat(Name Key, out float OutValue);
function bool GetVector(Name Key, out Vector OutValue);
function bool GetActor(Name Key, out Actor OutValue);

function bool SetInt(Name Key, int Value);
function bool SetFloat(Name Key, float Value);
function bool SetVector(Name Key, Vector Value);
function bool SetActor(Name Key, Actor Value);

function int GetNumKeys();
function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutBlackBoardTypeCode);

function DumpBlackBoardToLog();