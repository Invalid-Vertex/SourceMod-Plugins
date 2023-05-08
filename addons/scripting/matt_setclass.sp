#pragma semicolon 1
#include <tf2>
#include <tf2_stocks>

new String:iClass[][10] = {{"civilian"},{"scout"},{"sniper"},{"soldier"},{"demoman"},{"medic"},{"heavy"},{"pyro"},{"spy"},{"engineer"}};



public Plugin:myinfo =
{
	name = "Set Class",
	author = "InvalidVertex",
	description = "Allows you to set your class",
	version = "1.0.0",
	url = "https://invalidvertex.com"
}

public OnPluginStart()
{
	RegAdminCmd("sm_setclass", SetClass, ADMFLAG_GENERIC, "Sets your class, you only need to type part of the classname");
	RegAdminCmd("setclass", SetClass, ADMFLAG_GENERIC, "Sets your class, you only need to type part of the classname");
}

public Action:SetClass(client, args)
{

	if (args < 1)
	{
		ReplyToCommand(client, "\x04[SetClass]\x01 | ERROR: You forgot to specify a class!");
	}
	else
	{
		decl String:sClass[16];
		GetCmdArg(1, sClass, sizeof(sClass));
		for(new i = 0 ; i < 10 ; i++)
		{
			if(StrContains(iClass[i], sClass, false) != -1)
			{
				TF2_SetPlayerClass(client, TFClassType:i, true, true);
				TF2_RegeneratePlayer(client);
				SetEntProp(client, Prop_Data, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth"));
				ReplyToCommand(client, "\x04[SetClass]\x01 | Your class is now %s", iClass[i]);
				break;
			}
		}
	}
	return Plugin_Handled;
}
