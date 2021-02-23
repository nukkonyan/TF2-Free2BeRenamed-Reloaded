#define		AUTOLOAD_EXTENSIONS
#define		REQUIRE_EXTENSIONS
#include	<steamworks>

#include	<sdktools>
#include	<tf2_stocks>

#pragma		semicolon	1
#pragma		newdecls	required

bool HasClientChangedName[MAXPLAYERS+1]=false;

public	Plugin	myinfo	=	{
	name		=	"[TF2] Free2BeRenamed: Reloaded",
	author		=	"Tk /id/Teamkiller324",
	description	=	"New remade version of Free2BeRenamed from scratch",
	version		=	"1.0.0",
	url			=	"https://steamcommmunity.com/id/Teamkiller324"
}

char	F2PPrefix[64],
		F2PSuffix[64],
		P2PPrefix[64],
		P2PSuffix[64];

public void OnPluginStart()	{
	ConVar	F2P_Prefix	=	CreateConVar("tf_f2p_prefix",	"[F2P]",	"Free-To-Plays Prefix");
	ConVar	F2P_Suffix	=	CreateConVar("tf_f2p_suffix",	"",			"Free-To-Plays Suffix");
	ConVar	P2P_Prefix	=	CreateConVar("tf_p2p_prefix",	"[P2P]",	"Premium-To-Play Prefix");
	ConVar	P2P_Suffix	=	CreateConVar("tf_p2p_suffix",	"",			"Premium-To-Play Suffix");
	
	F2P_Prefix.GetString(F2PPrefix, sizeof(F2PPrefix));
	F2P_Suffix.GetString(F2PSuffix, sizeof(F2PSuffix));
	P2P_Prefix.GetString(P2PPrefix, sizeof(P2PPrefix));
	P2P_Suffix.GetString(P2PSuffix, sizeof(P2PSuffix));
	
	AutoExecConfig(true, "free2berenamed_reloaded");
	
	HookEvent("player_changename",	Event_PlayerNameChange,	EventHookMode_Post);
}

public void OnClientPostAdminCheck(int client)	{
	CreateTimer(0.2, F2BR_SetClientNameTimer, client);
	HasClientChangedName[client] = false;
}

public void OnClientDisconnect(int client)	{
	HasClientChangedName[client] = false;
}

Action F2BR_SetClientNameTimer(Handle timer, any client)	{
	char getname[MAXPLAYERS+1][256];
	GetClientInfo(client, "name", getname[client], sizeof(getname[]));
	F2BR_SetClientName(client, getname[client]);
	CreateTimer(0.2, ResetChangeNameTimer, client);
}

Action Event_PlayerNameChange(Event event, const char[] name, bool dontBroadcast)	{
	int client = GetClientOfUserId(event.GetInt("userid"));
	HasClientChangedName[client] = true;
	char getname[MAXPLAYERS+1][256];
	GetClientInfo(client, "name", getname[client], sizeof(getname[]));
	//Make the name be changed correctly for the correct target.
	
	//Make sure to not spam the tag.
	bool SameName[MAXPLAYERS+1];
	if(StrContains(getname[client], F2PPrefix, false) != -1)
		SameName[client] = true;
	else if(StrContains(getname[client], P2PPrefix, false) != -1)
		SameName[client] = true;
	else
		SameName[client] = false;
	
	if(HasClientChangedName[client] && !SameName[client])	{
		F2BR_SetClientName(client, getname[client]);
	}
}

Action ResetChangeNameTimer(Handle timer, any client)	{
	HasClientChangedName[client] = false;
}

void F2BR_SetClientName(int client, char[] name)	{
	if(!IsValidClient(client))
		return;
		
	char	f2p_newname[96], p2p_newname[96];
	FormatEx(f2p_newname, sizeof(f2p_newname), "%s %s %s", F2PPrefix, name, F2PSuffix);
	FormatEx(p2p_newname, sizeof(p2p_newname), "%s %s %s", P2PPrefix, name, P2PSuffix);
	
	switch(SteamWorks_HasLicenseForApp(client, 459))	{		//F2P Returns 1.	//P2P Returns 0.
		case	0:	{
			if(!StrEqual(P2PPrefix, ""))
				SetClientInfo(client, "name", p2p_newname);
		}
		case	1:	{
			if(!StrEqual(F2PPrefix, ""))
				SetClientInfo(client, "name", f2p_newname);
		}
	}
}

stock bool IsValidClient(int client, bool CheckTeam=false)	{
	if(!IsClientInGame(client))
		return	false;
	if(client < 1 || client > MaxClients)
		return	false;
	if(IsFakeClient(client))
		return	false;
	if(IsClientReplay(client))
		return	false;
	if(IsClientSourceTV(client))
		return	false;
	return	true;
}