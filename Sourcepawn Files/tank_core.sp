#include <sourcemod>
#include <tf2_stocks>
#include <new_stt/tank>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

public Plugin myinfo = 
{
	name = "Stop That Tank - Redux [CORE]",
	author = "ZoNiCaL",
	description = "Core functionality for Stop That Tank.",
	version = PLUGIN_VERSION,
	url = "Your website URL/AlliedModders profile URL"
};

STT_Core core;

/*

PURPOSE:

The purpose of this STT Redux project is to split up the functionality of
the gamemode into several other plugins, instead of having a fustercluck
mess that is the current iteration.

It should be split as follows:
	- CORE: Contains everything that is needed for STT to exist, main functions.
	- TANK: Everything that has to do with setting up the tank for STT.
	- PLAYER: Everything that has to do with initalizing players, changing models, etc.
	- GIANT: Everything that has to do with setting up and creating giants for STT.
	- BUSTER: Everything that has to do with setting up and creating sentry busters.
	- PAYLOAD: The main payload gamemode, but STT'ifed.
	- PLR: The main payload race gamemode, but STT'ifed.	
*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Is this a TF2 plugin?
	RegPluginLibrary("tank_core");
	
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("This plugin was made for use with Team Fortress 2 only.");
	}
	
	CreateNative("SetTank", Native_SetTank);
	CreateNative("GetTank", Native_GetTank);
	CreateNative("SetSTTGamemode", Native_SetSTTGamemode);
	CreateNative("GetSTTGamemode", Native_GetSTTGamemode);
	CreateNative("SetSTTRoundState", Native_SetSTTRoundState);
	CreateNative("GetSTTRoundState", Native_GetSTTRoundState);
} 

// Initalize everything else.
public void OnPluginStart()
{
	// Registers the core library.
	CreateConVar("sttr_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

// Grab the current map, then call which gamemode type we need to initalize.
public void OnMapStart()
{
	char newMap[128];
	GetCurrentMap(newMap, sizeof(newMap));
	
	// Payload.
	if (StrContains(newMap, "pl_"))
	{
		if (!Init_PayloadGamemode())
		{
			SetFailState("[STTR] Failed to load the Payload Gamemode for STT.");
		}
	}
	// Payload Race.
	else if (StrContains(newMap, "plr_"))
	{
	}
}

// ----------------------------------------------
// Getters and setters natives here:
// ----------------------------------------------

// Tank:
public any Native_SetTank(Handle plugin, int numParams) 
{ 
	// Grab the entity index:
	int entity = GetNativeCell(1);
	
	// Do some quick checks:
	if (IsValidEntity(entity) && CanBeThePayload(entity))
	{
		core.tankEntity = entity;
		return true;
	}
	return false;
}
public any Native_GetTank(Handle plugin, int numParams) { return core.tankEntity; }

// Gamemode:
public any Native_SetSTTGamemode(Handle plugin, int numParams)
{
	// Grab the gamemode type:
	int gamemode = GetNativeCell(1);
	core.gamemode = gamemode;
}
public any Native_GetSTTGamemode(Handle plugin, int numParams) { return core.gamemode; }

// Round states:
public any Native_SetSTTRoundState(Handle plugin, int numParams)
{
	// Grab the round state:
	int state = GetNativeCell(1);
	core.gameState = state;
}
public any Native_GetSTTRoundState(Handle plugin, int numParams) { return core.gameState; }