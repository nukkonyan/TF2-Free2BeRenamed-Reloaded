#include	<f2br_reloaded>

#pragma		semicolon	1
#pragma		newdecls	required

public	Plugin	myinfo	=	{
	name		=	"[TF2] Free2BeRenamed: Reloaded - Test Status",
	author		=	"Tk /id/Teamkiller324",
	description	=	"New remade version of Free2BeRenamed from scratch",
	version		=	"1.0.0",
	url			=	"https://steamcommmunity.com/id/Teamkiller324"
}

public void OnPluginStart()	{
	RegConsoleCmd("sm_status",	StatusCmd, "Check status");
}

Action StatusCmd(int client, int args)	{
	char status[64];
	if(TF2_IsPlayerPremium(client))
		status = "Premium";
	else
		status = "Free-To-Play";
	
	//This will print out if you're a premium or free-to-play user.
	PrintToChatAll("Client Status: %s", status);
}