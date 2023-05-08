#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <regex>
#include <tf2>


#define DMG_IGNITE	(1 << 24)
#define PLUGIN_VERSION "1.5.0"
new bool:bOnCooldown [MAXPLAYERS + 1];
new Float:m_flVel[3];
new Handle:LennyMethod; //Method of dealing with Lenny spammers
new Handle:LennyCooldown; //How long to wait before the explosion effect can be retriggered


public Plugin:myinfo =
{
	name = "No Lenny Faces",
	author = "InvalidVertex",
	description = "Blocks most Lenny faces",
	version = PLUGIN_VERSION,
	url = "https://invalidvertex.com"
};

public OnPluginStart()
{
	CreateConVar("sm_nolenny_version", PLUGIN_VERSION, "No Lenny Faces version", FCVAR_NOTIFY);
	if(GetEngineVersion() == Engine_TF2)
	{
		//Team Fortress 2 only
		LennyMethod = CreateConVar("sm_lennymethod", "1", "Method of dealing with Lenny spammers, 1 = 'Shadow' Block | 2 = Explode! | 3 or greater = Full Block", FCVAR_NOTIFY, true, 1.0, true, 3.0);
		LennyCooldown = CreateConVar("sm_lennycooldown", "150.0", "How long to wait before the explosion effect can be retriggered", FCVAR_NOTIFY, true, 30.0, true, 1800.0);

	}
	else
	{
		LennyMethod = CreateConVar("sm_lennymethod", "1", "Method of dealing with Lenny spammers, 1 = 'Shadow' Block | 2 = Slap! | 3 or greater = Full Block", FCVAR_NOTIFY, true, 1.0, true, 3.0);	
	}
}

public OnClientConnected(client)
{
	bOnCooldown[client] = false;
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
	if(SimpleRegexMatch(sArgs, "(.* ͡.*°.*)|(.* ͜.*ʖ.*)|(.*ʖ.*)") > 0)
	{
		switch(GetConVarInt(LennyMethod))
		{
			case 1:
			{
				char msg[130];
				Handle hBf;
				hBf = StartMessageOne("SayText2", client);
				Format(msg, sizeof(msg), "\x03%N\x01 :  %s", client , sArgs);
				if (hBf != null)
				{
					BfWriteByte(hBf, client); 
					BfWriteByte(hBf, 0); 
					BfWriteString(hBf, msg);
					EndMessage();
				}
			}
			case 2:
			{
				if (IsClientInGame(client) && IsPlayerAlive(client) && bOnCooldown[client] == false)
				{
					if(GetEngineVersion() == Engine_TF2)
					{
						m_flVel[2] = 750.0;
						bOnCooldown[client] = true;
						PrintToChat(client, "\x04[NoLenny]\x01 | Don't do that...");
						PrecacheSound("vo/demoman_sf13_influx_big01.mp3");
						EmitSoundToClient(client, "vo/demoman_sf13_influx_big01.mp3"); //"OH BLOODY EPIC!"
						SetEntPropFloat(client, Prop_Data, "m_flGravity", -0.1);
						TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, m_flVel);
						CreateTimer(GetConVarFloat(LennyCooldown), Cooldown, client);
						CreateTimer(2.0, Expl, client);
					}
					else
					{
						PrintToChat(client, "\x04[NoLenny]\x01 | Don't do that...");
						SlapPlayer(client,25,true);
					}
				}
			}
			default:
			{
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Expl(Handle:hExpl, any:client) 
{
	if (IsClientInGame(client))
	{
		SDKHooks_TakeDamage(client, client, client, float(GetClientHealth(client) * 2), DMG_IGNITE|DMG_BLAST|DMG_ALWAYSGIB);
		SetEntPropFloat(client, Prop_Data, "m_flGravity", 1.0);
		CreateParticle(client, "fluidSmokeExpl_track", 5.0);
		CreateParticle(client, "dooms_nuke_ring", 5.0);
		PrecacheSound("items/cart_explode.wav");
		EmitSoundToAll("items/cart_explode.wav", client, SNDCHAN_AUTO, 128);
		//Redundancy, if they're somehow still alive
		if (IsPlayerAlive(client))
		{
			ForcePlayerSuicide(client);
		}
	}
	return Plugin_Handled; 
}

public Action:Cooldown(Handle:hCooldown, any:client) 
{
	if (IsClientInGame(client))
	{
		bOnCooldown[client] = false;
	}
	return Plugin_Handled; 
}

stock CreateParticle(ent, String:particlesys[], Float:time)
{
	new particle = CreateEntityByName("info_particle_system");
	decl String:name[64];
	if (IsValidEdict(particle))
	{
		new Float:pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		SetEntPropVector(particle, Prop_Send, "m_vecOrigin", pos);
		GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
		DispatchKeyValue(particle, "targetname", "sm_info_particle_system");
		DispatchKeyValue(particle, "parentname", name);
		DispatchKeyValue(particle, "effect_name", particlesys);
		DispatchSpawn(particle);
		AcceptEntityInput(particle, "SetParent", ent, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(time, DeleteParticle, particle);
	}
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
	if (IsValidEntity(particle))
	{
		new String:class[64];
		GetEdictClassname(particle, class, sizeof(class));
		if (StrEqual(class, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "stop");
			RemoveEdict(particle);
		}
	}
}
