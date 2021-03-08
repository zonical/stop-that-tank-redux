#include <sourcemod>
#include <tf2_stocks>
#include <new_stt/tank>

#pragma semicolon 1
#pragma newdecls required

#define SUBPLUGIN_VERSION "0.00"

public Plugin myinfo = 
{
	name = "Stop That Tank - Redux [PL]",
	author = "ZoNiCaL",
	description = "Logic for the Payload Gamemode for Stop That Tank.",
	version = SUBPLUGIN_VERSION,
	url = ""
};

int PayloadEntityIndex;

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

FILE:

This file handles all of the logic for the Payload gamemode. It typically has BLU team
having a tank travel from the start of the map towards the end. It can be damaged and
destroyed by RED, which will then spawn a bomb and a giant for BLU. Control points will
then need to be captured like normal CP, then the final hatch for a victory.

*/

ConVar cSTT_TankSpawnTime;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Is this a TF2 plugin?
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("This plugin was made for use with Team Fortress 2 only.");
	}
	CreateNative("Init_PayloadGamemode", Native_Init_PayloadGamemode);
} 

// Initalize everything else.
public void OnPluginStart()
{
	PrintToServer("[STTR] Loading Stop That Tank - Payload. Version: %s", SUBPLUGIN_VERSION);
	
	// Registers the core library.
	if (!LibraryExists("tank_core") || !LibraryExists("tank_gtank"))
	{
		SetFailState("[STTR] This plugin requires tank_core.smx and tank_gtank.smx to be loaded. Please load them, then reload me.");
	}
	
	// Register this as a plugin library so we can see it from other plugins.
	RegPluginLibrary("tank_payload");
	HookEntityOutput("team_round_timer", "OnSetupFinished", Timer_OnSetupFinished);
	
	// Register ConVars:
	cSTT_TankSpawnTime = CreateConVar("sm_sttr_tank_spawntime", "15", "The time in seconds when the tank spawns in after round start.");
}

// Creates everything we need for the Payload gamemode.
public any Native_Init_PayloadGamemode(Handle plugin, int numParams) 
{    
    // Next, we'll find our original payload cart. We're mainly looking for one entity:
    // A prop_physics_override. Another check in tank_gtank
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "prop_physics_override")) != -1)
    {
    	if (IsValidEntity(entity))
    	{
    		if (CanBeThePayload(entity))
    		{
    			// Set the cart to be invisible for now.
    			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
    			SetEntityRenderColor(entity, 255, 255, 255, 0);
    			PayloadEntityIndex = entity;
    		}
    	}
    }
}

// When our setup timer is finished, we'll start the gameplay logic.
public Action Timer_OnSetupFinished(const char[] output, int caller, int activator, float delay)
{
	// We no longer have a need for any round timers for now, so destroy them here:
	// Instead, we'll create our own one that can handle the stuff we need for us in the future.
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
    {
    	if (IsValidEntity(entity))
    	{
    		// Kill the entity.
    		AcceptEntityInput(entity, "Kill");
    	}
    }
    
   	// Print start time to the chat:
    int spawnTime = cSTT_TankSpawnTime.IntValue();
    PrintCenterTextAll("The tank will spawn in %d seconds...", spawnTime);
    
    // Create the ghost tank before we spawn in the tank_boss entity.
    CreateGhostTank(PayloadEntityIndex);
    
    // Create the timer:
    CreateTimer(spawnTime, SpawnTimer);
}

// After x amount of seconds after round starting, this is fired to spawn in the tank.
public Action SpawnTimer(Handle timer)
{
	CreateTank(PayloadEntityIndex);
}