/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included

#define STT_TEAM_DEFENDERS 2
#define STT_TEAM_ROBOTS 3


#define GAMEMODE_PAYLOAD 1
#define GAMEMODE_PAYLOAD_RACE 2

forward void STT_OnWarmupStart(int gamemode);
forward void STT_OnWarmupEnd(int gamemode);

forward void STT_OnTankSpawn(int entity, int team, int health);
forward void STT_OnTankDestroyed(int entity, int team, int destroyer);
forward void STT_OnGiantSpawned(int player, int team, int giantindex);
forward void STT_OnGiantKilled(int player, int team, int attacker, int giantindex);

forward void STT_OnBombSpawn(int player, int bomb_entity, int team);
forward void STT_OnBombDrop(int player, int bomb_entity, int team);
forward void STT_OnBombPickUp(int player, int bomb_entity, int team);
forward void STT_OnBombReturn(int player, int bomb_entity, int team);
forward void STT_OnBombDeploy(int player, int bomb_entity, int team);