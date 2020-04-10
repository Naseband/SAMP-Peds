#define POOL_NPC_NAME_FORMAT			"Ped_%d"

enum (+=1)
{
	PED_STATE_NONE,
	PED_STATE_ROAM,
	PED_STATE_FIND_TELE,
	PED_STATE_FLEE,
	PED_STATE_ATTACK,
	PED_STATE_DEAD
};

enum (+=1)
{
	PED_FLEE_PANIC,
	PED_FLEE_POINT,
	PED_FLEE_NPC,
	PED_FLEE_PLAYER,
	PED_FLEE_VEHICLE,
	PED_FLEE_OBJECT,
	PED_FLEE_DYN_OBJECT,
	PED_FLEE_GANG,
	PED_FLEE_GROUP
};

enum (+=1)
{
	PED_TARGET_POINT,
	PED_TARGET_NPC,
	PED_TARGET_PLAYER,
	PED_TARGET_VEHICLE,
	PED_TARGET_OBJECT,
	PED_TARGET_DYN_OBJECT,
	PED_TARGET_GANG,
	PED_TARGET_GROUP
};

enum (+=1)
{
	PED_ATT_STATE_ATTACK_MELEE,
	PED_ATT_STATE_ATTACK_SHOOT,
	PED_ATT_STATE_FIND_LOS
};

enum E_PED
{
	bool:pedExists,
	bool:pedDestroy,
	pedState,
	pedInterior,
	pedTTL,
	pedTick,

	pedZoneX,
	pedZoneY,

	pedSkinID,
	pedGroupID,
	pedGangID,
	pedServiceID,
	Float:pedSpeedMul,
	pedWeapons[MAX_PED_WEAPONS],

	pedFleeType,
	pedFleeID,
	Float:pedFleeDistance,
	Float:pedFleeX,
	Float:pedFleeY,
	Float:pedFleeZ,
	pedFleeTick,

	pedTargetType,
	pedTargetTick,
	pedTargetID,
	bool:pedPreferMelee,
	pedAttackState,
	pedAttackWeapon,

	pedCurNode,
	pedLastNode,

	pedID
};

new gPedestrians[MAX_PEDS][E_PED], Iterator:Pedestrian<MAX_PEDS>, gNPCToPedID[MAX_PLAYERS] = {-1, ...};

new gPedestrianNPCID = 0;

new gAutoSpawnPeds = 0, gAutoSpawnPedsAmount = 1;

forward @DestroyPedestrian(id);
@DestroyPedestrian(id) return DestroyPedestrian(id);

forward @ResetPedestrian(id);
@ResetPedestrian(id) return ResetPedestrian(id);

forward PedestrianSpawnTimer();

new gPedSpawnTimerID = -1;

forward CopTimer();
new gCopRadarTimerID = -1, bool:gCopRadarState;