#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.0"


public Plugin:myinfo =
{
	name = "Archer Spawn",
	author = "Matt",
	description = "Allows spawning of bot_npc_archer",
	version = PLUGIN_VERSION,
	url = "https://invalidvertex.com"
};

public OnPluginStart()
{
	CreateConVar("sm_archer_version", PLUGIN_VERSION, "Archer version", FCVAR_NOTIFY);
	RegAdminCmd("sm_makearcher", CreateArcher, ADMFLAG_CHEATS, "Makes a bot_npc_archer were you're looking");
	RegAdminCmd("sm_killarcher", RemoveArcher, ADMFLAG_CHEATS, "Removes all bot_npc_archers created by you");
	RegAdminCmd("sm_killarchers", RemoveArchers, ADMFLAG_ROOT, "Removes all bot_npc_archers");
	CreateTimer(30.0, CreateBaseBoss, _, TIMER_REPEAT);
}

public Action:CreateArcher(client, args)
{
	if(IsClientInGame(client))
	{
		decl Float:vEyeOri[3], Float:vEyeAng[3], Float:vPos[3];
		GetClientEyePosition(client, vEyeOri);
		GetClientEyeAngles(client, vEyeAng);
		new Handle:trace = TR_TraceRayFilterEx(vEyeOri, vEyeAng, MASK_SOLID, RayType_Infinite, FilterPlayers);
		TR_GetEndPosition(vPos, trace);
		if(TR_DidHit(trace))
		{
			new String:buffer[256];
			Format(buffer, sizeof(buffer), "sm_bot_npc_archer-%N", client);
		
			new Archer = CreateEntityByName("bot_npc_archer");
			SetEntPropString(Archer, Prop_Data, "m_iName", buffer);
			SetEntPropVector(Archer, Prop_Data, "m_vecOrigin", vPos);
			SetEntPropVector(Archer, Prop_Data, "m_vecAbsOrigin", vPos);
			DispatchSpawn(Archer);
			ReplyToCommand(client, "\x04[Archer] \x01Archer spawned");
		}
		CloseHandle(trace);
	}
	return Plugin_Handled;
}

public Action:RemoveArcher(client, args)
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "bot_npc_archer")) != -1)
	{
		new String:buffer[256];
		new String:name[256];
		GetEntPropString(ent,Prop_Data,"m_iName",name,sizeof(name));
		Format(buffer,sizeof(buffer),"sm_bot_npc_archer-%N",client);
		if(StrEqual(name,buffer, true))
		{
			AcceptEntityInput(ent, "Kill");
		}
	}
	ReplyToCommand(client,"\x04[Archer] \x01Removing your archers");
	return Plugin_Handled;
}

public Action:RemoveArchers(client, args)
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "bot_npc_archer")) != -1)
	{
		new String:name[256];
		GetEntPropString(ent,Prop_Data,"m_iName",name,sizeof(name));
		if(StrContains(name,"sm_bot_npc_archer", true) == 0)
		{
			AcceptEntityInput(ent, "Kill");
		}
	}
	ReplyToCommand(client,"\x04[Archer] \x01Removing all archers");
	return Plugin_Handled;
}

public bool:FilterPlayers(entity, contentsMask)
{
	return entity > MaxClients;
} 

public Action:CreateBaseBoss(Handle:hBoss, any:client)
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "base_boss")) == -1)
	{
		new BaseBoss = CreateEntityByName("base_boss");
		DispatchKeyValue(BaseBoss, "origin", "0 0 -65536");
		DispatchSpawn(BaseBoss);
	}
}
