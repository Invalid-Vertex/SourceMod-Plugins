#pragma semicolon 1
#include <sdktools>

#define PLUGIN_VERSION "1.0.0"
new String:mapname[128];

public Plugin:myinfo = 
{
	name = "Remove Announcer spam",
	author = "InvalidVertex",
	description = "Removes the announcer on achievement maps.",
	version = "1.0.0",
	url = "https://invalidvertex.com"
}

public OnPluginStart()
{
	AddNormalSoundHook(NormalSHook:Sounds);
}

public Action:Sounds(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	GetCurrentMap(mapname, sizeof(mapname));
	if(StrContains(mapname, "ach_", true)!= -1 || StrContains(mapname, "achievement_", true)!= -1 || StrContains(mapname, "trade_", true)!= -1  || StrContains(mapname, "idle_", true)!= -1)
	{
		if(StrContains(sample, "vo/announcer", true)!= -1 || StrContains(sample, "vo/intel", true)!= -1)
		{
			if(channel == 7)
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
