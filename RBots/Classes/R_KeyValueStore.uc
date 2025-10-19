//==============================================================================
//	R_KeyValueStore
//	Key:Value mapping container for various types
//==============================================================================
class R_KeyValueStore extends R_RBotsObject abstract;

const LogCategory = 'KeyValueStore';

function bool AddBool(Name Key);
function bool AddInt(Name Key);
function bool AddFloat(Name Key);
function bool AddVector(Name Key);
function bool AddActor(Name Key);
function bool AddObject(Name Key);
function bool AddClass(Name Key);

function bool GetBool(Name Key, out byte OutValue);
function bool GetInt(Name Key, out int OutValue);
function bool GetFloat(Name Key, out float OutValue);
function bool GetVector(Name Key, out Vector OutValue);
function bool GetActor(Name Key, out Actor OutValue);
function bool GetObject(Name Key, out Object OutValue);
function bool GetClass(Name Key, out Class OutClass);

function bool SetBool(Name Key, byte Value);
function bool SetInt(Name Key, int Value);
function bool SetFloat(Name Key, float Value);
function bool SetVector(Name Key, Vector Value);
function bool SetActor(Name Key, Actor Value);
function bool SetObject(Name Key, Object Value);
function bool SetClass(Name Key, Class Value);

function int GetNumKeys();
function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode);

function DumpToLog();