#include <sourcemod>
#include <tf2_stocks>
#include <stop_that_tank_redux>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.00"

// Declare plugin information.
public Plugin myinfo = 
{
	name = "Stop That Tank Redux [TANK HANDLING DEMO]",
	author = "ZoNiCaL and Qualitycont",
	description = "A new and revised version of the Stop That Tank gamemode.",
	version = PLUGIN_VERSION,
	url = "One day."
};

Handle g_STT_OnTankSpawn;
Handle g_STT_OnTankDestroyed;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Checks to see if this is actually TF2.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("[STT:R] This plugin was made for use with Team Fortress 2 only.");
	}
	
	// Create our global forwards here:
	g_STT_OnTankSpawn = CreateGlobalForward("STT_OnTankSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_STT_OnTankDestroyed = CreateGlobalForward("STT_OnTankDestroyed", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
} 

public void OnPluginStart()
{
	// Hook our gameplay events:
	// HookEvent("mvm_tank_destroyed_by_players", OnTankDestroyed);
}

/*
	STT_OnWarmupEnd():
	Warmup has ended, let's spawn our tank:
*/
public void STT_OnWarmupEnd(int gamemode)
{
	// Check our gamemode:
	if (gamemode != GAMEMODE_PAYLOAD)
	{
		return;
	}
	
	int tankEntity = CreateEntityByName("tank_boss");
	DispatchKeyValue(tankEntity, "health", "10000");
	DispatchSpawn(tankEntity);
}


