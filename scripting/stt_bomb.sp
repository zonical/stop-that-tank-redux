#include <sourcemod>
#include <tf2_stocks>
#include <stop_that_tank_redux>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.00"

// Declare plugin information.
public Plugin myinfo = 
{
	name = "Stop That Tank Redux [BOMB]",
	author = "ZoNiCaL and Qualitycont",
	description = "Lamp oil? rope? bombs? You want it? It's yours my friend, as long as you have enough rupees.",
	version = PLUGIN_VERSION,
	url = "One day."
};

Handle g_STT_OnBombSpawn;
Handle g_STT_OnBombDrop;
Handle g_STT_OnBombPickUp;
Handle g_STT_OnBombReturn;
Handle g_STT_OnBombDeploy;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Checks to see if this is actually TF2.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("[STT:R] This plugin was made for use with Team Fortress 2 only.");
	}
	
	// TODO: Create forwards
} 

public void OnPluginStart()
{
	// TODO: Create hooks and do stuff with it
	// HookEvent("mvm_tank_destroyed_by_players", OnTankDestroyed);
}
