//==============================================================================
//	R_NavSettings
//	This class is meant to modify the behavior of nav queries
//==============================================================================
class R_NavSettings extends R_NavObject;

/**
Nothing here at the moment, but this is still passed as optional argument
to NavQuery functions so that settings can easily be added later as
functionality improves

Some possibilities that this class can help with:
- Avoid falling off ledges to save time
- Prefer polygroups with few neighbors
- Prefer nodes that are deeper in a polygroup (distance from perimeter)
- Avoid climbing
- Prefer populated or high traffic areas
- Prefer high ground areas

Bots are expected to have personality parameters at some point to define things
like aggression, so these may be used to derive their own personal nav settings
*/