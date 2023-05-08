#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION "1.0.0"
	
public Plugin:myinfo =
{
	name = "Buildable Parenting",
	author = "InvalidVertex",
	description = "Allows buildable objects to parent with moving entities",
	version = PLUGIN_VERSION,
	url = "https://www.invalidvertex.com"
} 

public OnPluginStart()
{
	   HookEvent("player_builtobject", ObjectBuilt);
}

public OnEntityCreated(entity, const char[] classname)
{
	if(StrEqual(classname, "dispenser_touch_trigger"))
	{
		SDKHook(entity, SDKHook_SpawnPost, ParentTouchTrigger);
	}
}

public Action:ObjectBuilt(Handle:event, const char[] name, bool:dontBroadcast)
{
	for(new i=1;i <= GetEntityCount(); i++)
	{
		if(IsValidEntity(i))
		{
			char ent[128];
			GetEntityNetClass(i, ent, sizeof(ent));
			if(StrEqual(ent,"CObjectSentrygun", true) || StrEqual(ent,"CObjectDispenser", true) || StrEqual(ent,"CObjectTeleporter", true))
			{
				float vPos[3];
				float vPosEnd[3];
				GetEntPropVector(i,Prop_Data,"m_vecOrigin",vPos);
				vPosEnd[0] = vPos[0];
				vPosEnd[1] = vPos[1];
				vPosEnd[2] = vPos[2] - 64.0;
				TR_TraceRayFilter(vPos,vPosEnd,MASK_PLAYERSOLID,RayType_EndPoint,IgnoreSelf,i);
				if(TR_DidHit(INVALID_HANDLE))
				{
					new TraceResult = TR_GetEntityIndex(INVALID_HANDLE);
					if(TraceResult > 32)
					{
						SetVariantString("!activator");
						AcceptEntityInput(i, "SetParent", TraceResult);
					}
				}
			}
		}
	}
}

public ParentTouchTrigger(ent)
{
	if(IsValidEntity(ent))
	{
		int hOwner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
		if(IsValidEntity(hOwner))
		{
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", hOwner);
		}
	}
}

public bool:IgnoreSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	else
		return true;
}
