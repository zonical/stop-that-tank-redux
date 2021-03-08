/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included

enum struct STT_Core {
	int gameState;
	int gamemode;
	int tankEntity;
}

enum STT_RoundStates {
	Round_NONE = 0,
	Round_Countdown,
	Round_TankProgressing,
	Round_TankExploded,
	Round_BombCarrierActive,
	Round_Over
}

enum STT_GameModes {
	Gamemode_NONE = 0,
	Gamemode_Payload,
	Gamemode_PayloadRace
}

// Checks to see if this entity can be the one used for the tank.
native bool CanBeThePayload(int entity);

// Creates a translucent version of the tank for round setup.
native bool CreateGhostTank(int entity);

// Creates the actual tank.
native int CreateTank(int payloadEntity);

// Getters and setters for the tank entity for STT.
native bool SetTank(int entity);
native int GetTank();

// Getters and setters for the gamemode type for STT.
native void SetSTTGamemode(int gamemode);
native int GetSTTGamemode();

// Getters and setters for the round state for STT.
native void SetSTTRoundState(int state);
native int GetSTTRoundState();

// Gamemode initalizers:
native bool Init_PayloadGamemode();
native bool Init_PayloadRaceGamemode();
