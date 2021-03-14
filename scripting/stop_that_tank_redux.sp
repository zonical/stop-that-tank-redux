#include <sourcemod>
#include <tf2_stocks>
#include <stop_that_tank_redux>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.00"

// Declare plugin information.
public Plugin myinfo = 
{
	name = "Stop That Tank Redux",
	author = "ZoNiCaL and Qualitycont",
	description = "A new and revised version of the Stop That Tank gamemode.",
	version = PLUGIN_VERSION,
	url = "One day."
};

Handle g_STT_OnWarmupStart;
Handle g_STT_OnWarmupEnd;
int g_Gamemode;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Checks to see if this is actually TF2.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("[STT:R] This plugin was made for use with Team Fortress 2 only.");
	}
	
	// Create our global forwards here:
	g_STT_OnWarmupStart = CreateGlobalForward("STT_OnWarmupStart", ET_Ignore, Param_Cell);
	g_STT_OnWarmupEnd = CreateGlobalForward("STT_OnWarmupEnd", ET_Ignore, Param_Cell);
} 

public void OnPluginStart()
{
	CreateConVar("sm_sttr_version", PLUGIN_VERSION, "Version of the Stop That Tank plugin. Don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// Hook our gameplay events:
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("teamplay_setup_finished", OnSetupFinished);
}

/*
	OnMapStart():
	Here we're going to set our gamemode internally so that when we
	fire the Warmup forward, it goes to the right place.
*/
public void OnMapStart()
{
	// Grab our mapname:
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	// Gamemode comparisions:
	if (StrContains("pl_", mapname))
	{
		g_Gamemode = GAMEMODE_PAYLOAD;
	}
	else if (StrContains("plr_", mapname))
	{
		g_Gamemode = GAMEMODE_PAYLOAD_RACE;
	}
}

/*
	OnRoundStart():
	If we've fulled restarted, we'll send out a forward that says we've entered a warmup period,
	or just the setup period.
*/
public Action OnRoundStart(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	// Check to see if we're waiting for players:
	if (GameRules_GetProp("m_bInWaitingForPlayers") == 1)
	{
		return;
	}
	
	// Check to see if we've fully restarted:
	if (GetEventInt(hEvent, "full_reset") == 1)
	{
		// Call our forward:
		Call_StartForward(g_STT_OnWarmupStart);
		Call_PushCell(g_Gamemode);
		Call_Finish();
		PrintToChatAll("Core OnRoundStart Forward: %d", g_Gamemode);
	}
}

/*
	OnRoundStart():
	If we've finished our setup period, we'll send out a forward that says we've done that so we
	can call other logic from separate plugins.
*/
public Action OnSetupFinished(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	// Call our forward:
	Call_StartForward(g_STT_OnWarmupEnd);
	Call_PushCell(g_Gamemode);
	Call_Finish();
	PrintToChatAll("Core OnSetupFinished Forward: %d", g_Gamemode);
}


