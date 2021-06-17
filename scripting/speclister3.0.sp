#include <sourcemod>
#include <sdktools>
#include <colors>

#pragma newdecls required

#define VOICE_NORMAL		0	//	Allow the client to listen and speak normally.
#define VOICE_MUTED			1	//	Mutes the client from speaking to everyone.
#define VOICE_SPEAKALL		2	//	Allow the client to speak to everyone.
#define VOICE_LISTENALL		4	//	Allow the client to listen to everyone.
#define VOICE_TEAM			8	//	Allow the client to always speak to team, even when dead.
#define VOICE_LISTENTEAM	16	//	Allow the client to always hear teammates, including dead ones.

#define TEAM_SPEC 		1	// Get the spectators team
#define TEAM_SURVIVOR 	2	// Get the survivors team
#define TEAM_INFECTED 	3	// Get the infected team

Handle hAllTalk;

public Plugin myinfo =
{
	name = "SpecLister",
	author = "waertf, bman, lechuga",
	description = "Allows spectator listen others team voice for l4d2",
	version = "3.0",
	url = "http://forums.alliedmods.net/showthread.php?t=95474"
}

public void OnPluginStart()
{
	HookEvent("player_team",Event_PlayerChangeTeam);
	RegAdminCmd("sm_listen", CommandListen, ADMFLAG_CUSTOM1, "Allow the client to listen to everyone.");
	RegAdminCmd("sm_speack", CommandSpeak, ADMFLAG_GENERIC, "Allow the client to speak to everyone.");
	
	RegAdminCmd("sm_nolisten", CommandNo, ADMFLAG_CUSTOM1, "Allow the client to listen and speak normally.");
	RegAdminCmd("sm_nospeack", CommandNo, ADMFLAG_CUSTOM1, "Allow the client to listen and speak normally.");
	
	hAllTalk = FindConVar("sv_alltalk");
	HookConVarChange(hAllTalk, OnAlltalkChange);
}

public Action CommandListen(int client, int args)
{
	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_SPEC)
	{
		if(GetClientListeningFlags(client) != VOICE_LISTENALL)
		{
			SetClientListeningFlags(client, VOICE_LISTENALL);
			CPrintToChat(client, "{blue}[{default}SpecLister{blue}] {default}Enable ");
		}
		else
		return Plugin_Handled;
	}
	else
	CPrintToChat(client,"{blue}[{default}SpecLister{blue}] {default}Can only be used by spectators");
	return Plugin_Handled;
}

public Action CommandSpeak(int client, int args){
	
	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_SPEC)
	{
		if(GetClientListeningFlags(client) != VOICE_SPEAKALL)
		{
			SetClientListeningFlags(client, VOICE_SPEAKALL);
			CPrintToChatAll("{blue}[{default}SpecLister{blue}] {olive}%N {default}will talk to everyone ",client);
		}
		else
		return Plugin_Handled;
	}
	else
	CPrintToChat(client,"{blue}[{default}SpecLister{blue}] {default}Can only be used by spectators");
	return Plugin_Handled;
}

public Action CommandNo(int client, int args){
	
	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_SPEC)
	{
		if(GetClientListeningFlags(client) != VOICE_NORMAL)
		{
			SetClientListeningFlags(client, VOICE_NORMAL);
			CPrintToChat(client, "{blue}[{default}SpecLister{blue}] {default}Disable");
		}
		else
		return Plugin_Handled;
	}
	else
	CPrintToChat(client,"{blue}[{default}SpecLister{blue}] {default}Can only be used by spectators");
	return Plugin_Handled;
}

public void Event_PlayerChangeTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int userID = GetClientOfUserId(GetEventInt(event, "userid"));
	int userTeam = GetEventInt(event, "team");
	if(userID==0)
	return ;
	
	if(userTeam != TEAM_SPEC )
	{
		SetClientListeningFlags(userID, VOICE_NORMAL);
	}
}

public void OnAlltalkChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (StringToInt(newValue) == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && GetClientTeam(i) == TEAM_SPEC)
			{
				SetClientListeningFlags(i, VOICE_LISTENALL);
			}
		}
	}
}

/*********************************
* IsValidClient
*********************************/
stock bool IsValidClient(int client)
{
	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	else
	return false;
}