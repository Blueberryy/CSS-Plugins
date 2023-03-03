#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#define PLUGIN_VERSION  "1.0"
#define PLUGIN_NAME	    "css_drop_weapon"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[CSS] CSS Drop Weapon",
	version = PLUGIN_VERSION,
	description = "Player can drop knife and HE Grenade, Smoke Grenade, Flash Bang",
	author = "HarryPotter",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_CSS )
    {
        strcopy(error, err_max, "Plugin only supports CSS.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY


#define MODEL_HAND_KNIFE         "models/weapons/v_knife_t.mdl"
#define MODEL_HAND_HE_GRENADE    "models/weapons/v_eq_flashbang.mdl"
#define MODEL_HAND_SMOKEGRENADE  "models/weapons/v_eq_smokegrenade.mdl"
#define MODEL_HAND_FLASHBANG     "models/weapons/v_eq_fraggrenade.mdl"

ConVar g_hCvarEnable, g_hCvarDropKnife, g_hCvarDropHE, g_hCvarDropSM, g_hCvarDropFB;
bool g_bCvarEnable, g_bCvarDropKnife, g_bCvarDropHE, g_bCvarDropSM, g_bCvarDropFB;

int g_iModelIndex_Knife, g_iModelIndex_HE, g_iModelIndex_SM, g_iModelIndex_FB;

public void OnPluginStart()
{
    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",              "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarDropKnife    = CreateConVar( PLUGIN_NAME ... "_drop_knife",          "1",   "If 1, allow player to drop knife", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarDropHE       = CreateConVar( PLUGIN_NAME ... "_drop_hegrenade",      "1",   "If 1, allow player to drop fragmentation grenades", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarDropSM       = CreateConVar( PLUGIN_NAME ... "_drop_smokegrenade",   "1",   "If 1, allow player to drop smoke grenades", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarDropFB       = CreateConVar( PLUGIN_NAME ... "_drop_flashbang",      "1",   "If 1, allow player to drop flash bang", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarDropKnife.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarDropHE.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarDropSM.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarDropFB.AddChangeHook(ConVarChanged_Cvars);


    AddCommandListener(Drop_Callback, "drop");
}

//-------------------------------Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
    g_bCvarDropKnife = g_hCvarDropKnife.BoolValue;
    g_bCvarDropHE = g_hCvarDropHE.BoolValue;
    g_bCvarDropSM = g_hCvarDropSM.BoolValue;
    g_bCvarDropFB = g_hCvarDropFB.BoolValue;
}

//-------------------------------Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    g_iModelIndex_Knife = PrecacheModel(MODEL_HAND_KNIFE, true);
    g_iModelIndex_HE    = PrecacheModel(MODEL_HAND_HE_GRENADE, true);
    g_iModelIndex_SM    = PrecacheModel(MODEL_HAND_SMOKEGRENADE, true);
    g_iModelIndex_FB    = PrecacheModel(MODEL_HAND_FLASHBANG, true);
}

//-------------------------------Command-------------------------------

Action Drop_Callback(int client, const char[] command, int argc)
{
    if(!g_bCvarEnable) return Plugin_Continue;

    int iCurrentWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if(iCurrentWeapon > 0)
    {
        int modelIndex = GetEntProp(iCurrentWeapon, Prop_Send, "m_nModelIndex");

        if(modelIndex == g_iModelIndex_Knife)
        {
            if (g_bCvarDropKnife == false)  return Plugin_Continue;
        }
        else if(modelIndex == g_iModelIndex_HE)
        {
            if (g_bCvarDropHE == false) return Plugin_Continue;
        }
        else if(modelIndex == g_iModelIndex_SM)
        {
            if (g_bCvarDropSM == false) return Plugin_Continue;
        }
        else if(modelIndex == g_iModelIndex_FB)
        {
            if (g_bCvarDropFB == false) return Plugin_Continue;
        }
        else
        {
            return Plugin_Continue;
        }

        if ( GetEntPropFloat(iCurrentWeapon, Prop_Data, "m_flNextPrimaryAttack") >= GetGameTime()) return Plugin_Continue;

        CS_DropWeapon(client, iCurrentWeapon, true);

        return Plugin_Handled;
    }

    return Plugin_Continue;
}


//-------------------------------Function-------------------------------

/* Debug */
stock void DebugPrint(const char[] Message, any ...)
{
    #if DEBUG
        char DebugBuff[128];
        VFormat(DebugBuff, sizeof(DebugBuff), Message, 2);
        PrintToChatAll("%s",DebugBuff);
        PrintToServer(DebugBuff);
        LogMessage(DebugBuff);
    #endif 
}
