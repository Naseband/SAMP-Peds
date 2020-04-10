#define PNODE_DEFAULT_WIDTH			0.4
#define PNODE_DEFAULT_HEIGHT		2.0

#define PNODES_XID 					24242423
#define PNODES_CONNECTION_XID		24242424

forward PNE_UpdateNodes();

// Ped Node Types

enum (+=1)
{
	PNODE_TYPE_WALK, // Peds will spawn here and walk around
	PNODE_TYPE_CROSS,
	PNODE_TYPE_FLEE,
	PNODE_TYPE_JUMP,
	PNODE_TYPE_TELE,

	PNODE_TYPE_MAX
};

enum (+=1)
{
	PNODE_ATTR_TYPE_TELE
};

// Ped Node Info

enum E_PED_NODE
{
	bool:pnExists,
	pnType,
	pnSubType,

	pnZoneX,
	pnZoneY,

	pnInterior,

	Float:pnX,
	Float:pnY,
	Float:pnZ,
	Float:pnW,
	Float:pnH,

	pnConnections[MAX_PNODE_CONNECTIONS]

	#if PNE_EDITOR == true
	,
	bool:pnRendered,
	pnObjectID

	#endif
};

new gPedNodes[MAX_PNODES][E_PED_NODE], Iterator:PedNode<MAX_PNODES>,
	bool:gPedNodesAutoSave = false,
	gPedNodesAutoSaveFile[160];