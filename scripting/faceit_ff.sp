#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo =
{
	name        = "[Faceit] Friendly Fire",
	author      = "skyin",
	description = "Blocks team damage except for molotov/inc or hegrenades",
	version     = "1.4",
	url         = "https://amsgaming.in"
};


public void OnPluginStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, SDK_OnTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_TraceAttack, SDK_OnTraceAttack);
	SDKUnhook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}


public Action SDK_OnTraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!IsClientInGame(victim) || !IsEntityClient(attacker) || !IsClientInGame(attacker))
	{
		return Plugin_Continue;
	}

	if (GetClientTeam(attacker) == GetClientTeam(victim))
	{
		char inflictorClass[64];
		if (GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass)))
		{
			if (StrEqual(inflictorClass, "inferno"))
			{
				return Plugin_Continue;
			}

			if (StrEqual(inflictorClass, "hegrenade_projectile"))
			{
				return Plugin_Continue;
			}
		}
	}

	if (GetClientTeam(attacker) == GetClientTeam(victim))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action SDK_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{
	// Invalid attacker or self damage
	if (attacker < 1 || attacker > MaxClients || attacker == victim || inflictor < 1)
		return Plugin_Continue;

	if (GetClientTeam(attacker) == GetClientTeam(victim))
	{
		char inflictorClass[64];
		if (GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass)))
		{
			if (StrEqual(inflictorClass, "inferno"))
			{
				damage *= 1.0;
				return Plugin_Changed;
			}

			if (StrEqual(inflictorClass, "hegrenade_projectile"))
			{
				damage *= 1.0;
				return Plugin_Changed;
			}
		}
	}

	if (GetClientTeam(attacker) == GetClientTeam(victim))
		return Plugin_Handled;

	return Plugin_Continue;
}

bool IsEntityClient(int client)
{
	return (client > 0 && client <= MaxClients);
}
