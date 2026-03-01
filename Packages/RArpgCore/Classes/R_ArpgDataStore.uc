//==============================================================================
//	R_ArpgDataStore
//	A hierarchical store of data, indexed by Tags
//	This is meant to take the place of a data table object
//==============================================================================
class R_ArpgDataStore extends R_ArpgObject abstract;

// Add a data object with the associated tag
// Does not overwrite existing data
// Returns true if the data was added, false otherwise
function bool AddData(R_ArpgTag Tag, R_ArpgObject Data);

// Get data previously stored with the given tag
//
// Returns data hierarchically
// If no entry exists for 'This.Is.My.Tag', then it will try
// to return data for 'This.Is.My', etc
//
// Returns true if any data was found, false otherwise
function bool GetData(R_ArpgTag Tag, out R_ArpgObject OutData);