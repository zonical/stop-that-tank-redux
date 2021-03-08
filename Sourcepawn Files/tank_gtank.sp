#include <sourcemod>
#include <tf2_stocks>
#include <new_stt/tank>

#pragma semicolon 1
#pragma newdecls required

#define SUBPLUGIN_VERSION "0.00"

public Plugin myinfo = 
{
	name = "Stop That Tank - Redux [TANK]",
	author = "ZoNiCaL",
	description = "Logic for the TANK for Stop That Tank.",
	version = SUBPLUGIN_VERSION,
	url = ""
};

int internalPayloadEntity;

ConVar cSTT_BaseTankHealth;
ConVar cSTT_TankHealthMultiplier;
ConVar cSTT_TankHealthToAdd;

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

This file handles all of the logic for setting up the tanks.

*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Is this a TF2 plugin?
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("This plugin was made for use with Team Fortress 2 only.");
	}
	
	if (!LibraryExists("tank_core"))
	{
		SetFailState("[STTR] This plugin requires tank_core.smx to be loaded. Please load it, then reload me.");
	}
	
	// Create our library and our natives:
	RegPluginLibrary("tank_gtank");
	CreateNative("CanBeThePayload", Native_CanBeThePayload);
	CreateNative("CreateGhostTank", Native_CreateGhostTank);
	
	PrecacheModel("models/bots/boss_bot/boss_tank.mdl");
	
	// Register ConVars:
	cSTT_BaseTankHealth = CreateConVar("sm_sttr_tank_basetankhealth", "10000", "The base health for the tank before any math is done.");
	cSTT_TankHealthMultiplier = CreateConVar("sm_sttr_tank_healthmultiplier", "1", "For each player, the value of sm_sttr_tank_healthtoadd will multiplied and added to the tanks health.");
	cSTT_TankHealthToAdd = CreateConVar("sm_sttr_tank_healthtoadd", "500", "For each player, the value of this ConVar is added to the tank (before the multiplier).");
}


// This is a simple check to see if this can be a payload cart.
// We're only looking to see if the model for this entity matches the 
public any Native_CanBeThePayload(Handle plugin, int numParams)
{
	// Grab the entity index:
	int entity = GetNativeCell(1);

	if (IsValidEntity(entity))
	{
		// Grab the entity classname for a check later:
		char entityclassname[128];
		GetEntityClassname(entity, entityclassname, sizeof(entityclassname));
	
		// Grab the model name from the entity data.
		char m_ModelName[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
		
		// Is this the right model and class?
		if (strcmp(m_ModelName, "models/props_trainyard/bomb_cart.mdl") == 0 && strcmp(entityclassname, "prop_physics_override") == 0)
		{
			return true;
		}
	}
	return false;
    		
}

// This creates a "ghost" version on the tank before the tank
// really spawns. It's a translucent version of the tank with
// no collisions.
public any Native_CreateGhostTank(Handle plugin, int numParams)
{
	// Grab the entity index:
	int entity = GetNativeCell(1);
	
	if (IsValidEntity(entity) && CanBeThePayload(entity))
	{
		// Set the model of the tank
		SetEntityModel(entity, "models/bots/boss_bot/boss_tank.mdl");
		
		// Set our internal payload reference:
		internalPayloadEntity = entity;
		
		// Make it aqua and translucent.
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
    	SetEntityRenderColor(entity, 0, 255, 255, 128);
    	
    	// TODO: Add collision changes here:
	}	
}

public any Native_CreateTank(Handle plugin, int numParams)
{
	// So for this, we'll need to create a tank_boss entity. This is exactly similar to the MVM tank, where it takes damage
	// until it's destroyed. This function takes in one argument which is where the tank should spawn (this should ALWAYS
	// be a payload cart.)
	
	int payloadEntity = GetNativeCell(1);
	
	if (IsValidEntity(payloadEntity) && CanBeThePayload(payloadEntity))
	{
		// Make it fully transparent.
		SetEntityRenderMode(payloadEntity, RENDER_TRANSCOLOR);
    	SetEntityRenderColor(payloadEntity, 255, 255, 255, 0);
    	
    	// Alright, let's now create our tank:
    	int tankEntity = CreateEntityByName("tank_boss");
    	
    	// Fuck, something went wrong here!
    	if (tankEntity == -1)
    	{
    		SetFailState("[STTR] Failed to create tank_boss entity!");
    	}
    	
    	// Spawn the tank here.
    	DispatchSpawn(tankEntity);
    	
    	// Set our Core tank:
    	SetTank(tankEntity);
    	
    	// Set the position and angles of the tank to our payload:
    	float payloadPosition[3];
    	float payloadAngles[3];
    	
    	GetEntPropVector(payloadEntity, Prop_Send, "m_vecOrigin", payloadPosition);
    	GetEntPropVector(payloadEntity, Prop_Send, "m_angRotation", payloadAngles);
    	
    	TeleportEntity(tankEntity, payloadPosition, payloadAngles, NULL_VECTOR);
    	
    	// Set our tanks health:
    	int tankHealth = cSTT_BaseTankHealth.IntValue + ((cSTT_TankHealthToAdd.IntValue * cSTT_TankHealthMultiplier.IntValue) * GetClientCount());
    	
    	SetVariantInt(tankHealth);
    	AcceptEntityInput(tankEntity, "SetMaxHealth");
    	SetVariantInt(tankHealth);
    	AcceptEntityInput(tankEntity, "SetHealth");
    	
    	PrintCenterTextAll("A tank has spawned in with %d HP! Take it down!", tankHealth);
	}
}

