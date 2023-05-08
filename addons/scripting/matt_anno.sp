#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1.0"


public Plugin:myinfo =
{
	name = "Spawn Annotations",
	author = "Matt",
	description = "Allows spawning of training_annotation entities with custom text",
	version = PLUGIN_VERSION,
	url = "https://invalidvertex.com"
};


public OnPluginStart()
{
	RegAdminCmd("anno", CreateAnnotation, ADMFLAG_ROOT, "Makes a training_annotation, args 'int lifetime' 'string message'");
}


public Action:CreateAnnotation(client, args)
{
	if(IsClientInGame(client))
	{
		if (args >= 2)
		{
			decl Float:vEyePos[3], Float:vEyeAng[3], Float:vPos[3];
			GetClientEyePosition(client, vEyePos);
			GetClientEyeAngles(client, vEyeAng);
			new Handle:trace = TR_TraceRayFilterEx(vEyePos, vEyeAng, MASK_SOLID, RayType_Infinite, FilterPlayers);
			TR_GetEndPosition(vPos, trace);
			if(TR_DidHit(trace))
			{
				decl String:buffer[256], String:flLifetime[4], String:sMessage[2048];
				Format(buffer, sizeof(buffer), "training_annotation-%N", client);
				GetCmdArg(1, flLifetime,sizeof(flLifetime));
				GetCmdArg(2, sMessage,sizeof(sMessage));

				new Anno = CreateEntityByName("training_annotation");
				SetEntPropString(Anno, Prop_Data, "m_iName", buffer);
				SetEntPropVector(Anno, Prop_Data, "m_vecOrigin", vPos);
				SetEntPropVector(Anno, Prop_Data, "m_vecAbsOrigin", vPos);
				if(StringToFloat(flLifetime) > 0 && StringToFloat(flLifetime) < 33) //This is here to prevent people from doing things like -1 or 999999999
				{
					flLifetime = flLifetime;
				}
				else
				{
					flLifetime = "5.0";
					ReplyToCommand(client, "\x04[Anno] \x01Error, the lifetime you entered was either too high, or two low. Please use a value between 1-32");
				}
				SetEntPropFloat(Anno, Prop_Data, "m_flLifetime", StringToFloat(flLifetime));				
				SetEntPropString(Anno, Prop_Data, "m_displayText", sMessage);
				DispatchSpawn(Anno);
				ReplyToCommand(client, "\x04[Anno] \x01Created");
				AcceptEntityInput(Anno, "Show");
				CreateTimer(StringToFloat(flLifetime)+1.5, RemoveAnno, Anno);
			}
			CloseHandle(trace);
		}
		else
		{
			ReplyToCommand(client, "\x04[Anno] \x01Error, arguments: anno 'flt flLifetime' \"string displayText\"");
		}
	}
	return Plugin_Handled;
}

public Action:RemoveAnno(Handle:hAnno, any:ent)
{
	AcceptEntityInput(ent, "Kill");
	return Plugin_Handled;
}

public bool:FilterPlayers(entity, contentsMask)
{
	return entity > MaxClients;
}
