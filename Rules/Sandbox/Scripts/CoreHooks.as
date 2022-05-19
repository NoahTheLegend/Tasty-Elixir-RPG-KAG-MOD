
#include "RulesCore.as";

//Default Rules Core hooks - simple proxy
//Make sure you dont forget JoinCoreHooks! :)

#include "GameplayEvents.as"
#include "SwitchFromSpec.as"

//not server only so that all the players get this
void onInit(CRules@ this)
{
	SetupGameplayEvents(this);

	sv_gravity = 9.81f;
	particles_gravity.y = 0.25f;
	this.set_u32("clearFrequency", getGameTime()+30*60*30);
	//printf("freqset: "+this.get_u32("clearFrequency"));
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;

	//if (getGameTime()%30==0) printf("u32: "+this.get_u32("clearFrequency"));
	//printf(""+(getGameTime() == this.get_u32("clearFrequency")));

	if (getGameTime() == this.get_u32("clearFrequency"))
	{
		printf("cleaned?");
		this.set_u32("clearFrequency", getGameTime()+30*60*30); //ticks a second*seconds*minutes
		//printf("freqset: "+this.get_u32("clearFrequency"));
		// lear everything
		CBlob@[] clearBlobs;
		getBlobsByTag("doClean", clearBlobs);

		for (u32 i = 0; i < clearBlobs.length; i++)
		{
			CBlob@ blob = clearBlobs[i];
			if (blob is null) continue;
			if (blob.isAttached() || blob.isInInventory()) continue;
			CMap@ map = blob.getMap();
			if (map is null) continue;

			CBlob@[] checkp;
			map.getBlobsInRadius(blob.getPosition(), 64.0f, checkp);
			bool skip = false;
			for (u32 i = 0; i < checkp.length; i++)
			{
				CBlob@ blobp = checkp[i];
				if (blobp is null) continue;
				if (blobp.getPlayer() !is null)
				{
					skip = true;
					break;
				}
			}
			if (skip) continue;

			if (isServer()) blob.server_Die();
		}
	}

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.Update();
	}
}


void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		string name = player.getUsername();
		if (player.get_u16("level") != 0)
		{
			this.set_u16(name+"level", player.get_u16("level"));
		}
		if (player.get_u32("exp") != 0)
		{
			this.set_u32(name+"exp", player.get_u32("exp"));
		}
	}
}


void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.onPlayerDie(victim, killer, customData);
	}

	CBlob@ victimblob = victim.getBlob();
	if (victimblob is null) return;

	//printf(""+victimblob.get_bool("hasarmor")+" e "+victimblob.get_string("armorname"));
	if (victimblob.get_bool("hasarmor") && victimblob.get_string("armorname") != "")
	{
		if (isServer()) 
		{
			CBlob@ blob = server_CreateBlob(victimblob.get_string("armorname"), -1, Vec2f(0,0));
			getRules().set_string(victim.getUsername()+"armorname", blob.getName());
			getRules().Sync(victim.getUsername()+"armorname", true);
			DoSaveStats(victim, blob);
			blob.server_Die();
			//printf("e");
		}
	}
	if (victimblob.get_bool("hashelmet") && victimblob.get_string("helmetname") != "")
	{
		if (isServer()) 
		{
			CBlob@ blob = server_CreateBlob(victimblob.get_string("helmetname"), -1, Vec2f(0,0));
			getRules().set_string(victim.getUsername()+"helmetname", blob.getName());
			getRules().Sync(victim.getUsername()+"helmetname", true);
			DoSaveStats(victim, blob);
			blob.server_Die();
		}
	}
	if (victimblob.get_bool("hasgloves") && victimblob.get_string("glovesname") != "")
	{
		if (isServer()) 
		{
			CBlob@ blob = server_CreateBlob(victimblob.get_string("glovesname"), -1, Vec2f(0,0));
			getRules().set_string(victim.getUsername()+"glovesname", blob.getName());
			getRules().Sync(victim.getUsername()+"glovesname", true);
			DoSaveStats(victim, blob);
			blob.server_Die();
		}
	}
	if (victimblob.get_bool("hasboots") && victimblob.get_string("bootsname") != "")
	{
		if (isServer()) 
		{
			CBlob@ blob = server_CreateBlob(victimblob.get_string("bootsname"), -1, Vec2f(0,0));
			getRules().set_string(victim.getUsername()+"bootsname", blob.getName());
			getRules().Sync(victim.getUsername()+"bootsname", true);
			DoSaveStats(victim, blob);
			blob.server_Die();
		}
	}
}

void DoSaveStats(CPlayer@ victim, CBlob@ blob)
{
											getRules().set_f32(victim.getUsername()+"velocity", 		getRules().get_f32(victim.getUsername()+"velocity") - blob.get_f32("velocity"));
    if (blob.get_f32("dodgechance")>0) 		getRules().set_f32(victim.getUsername()+"dodgechance", 		getRules().get_f32(victim.getUsername()+"dodgechance") + blob.get_f32("dodgechance"));
	if (blob.get_f32("blockchance")>0) 		getRules().set_f32(victim.getUsername()+"blockchance", 		getRules().get_f32(victim.getUsername()+"blockchance") + blob.get_f32("blockchance"));
    if (blob.get_f32("damagereduction")>0)	getRules().set_f32(victim.getUsername()+"damagereduction",	getRules().get_f32(victim.getUsername()+"damagereduction") + blob.get_f32("damagereduction"));
	if (blob.get_f32("hpregtime")>0) 		getRules().set_f32(victim.getUsername()+"hpregtime", 		getRules().get_f32(victim.getUsername()+"hpregtime") + blob.get_f32("hpregtime"));
	if (blob.get_f32("manaregtime")>0)		getRules().set_f32(victim.getUsername()+"manaregtime", 		getRules().get_f32(victim.getUsername()+"manaregtime") + blob.get_f32("manaregtime"));
	if (blob.get_u16("manareg")>0) 			getRules().set_u16(victim.getUsername()+"manareg", 			getRules().get_u16(victim.getUsername()+"manareg") + blob.get_u16("manareg"));
	if (blob.get_u16("maxmana")>0) 			getRules().set_u16(victim.getUsername()+"maxmana", 			getRules().get_u16(victim.getUsername()+"maxmana") + blob.get_u16("maxmana"));
	if (blob.get_f32("critchance")>0) 		getRules().set_f32(victim.getUsername()+"critchance", 		getRules().get_f32(victim.getUsername()+"critchance") + blob.get_f32("critchance"));
	if (blob.get_f32("damagebuff")>0) 		getRules().set_f32(victim.getUsername()+"damagebuff", 		getRules().get_f32(victim.getUsername()+"damagebuff") + blob.get_f32("damagebuff"));

	getRules().Sync(victim.getUsername()+"velocity", true);
	getRules().Sync(victim.getUsername()+"dodgechance", true);
	getRules().Sync(victim.getUsername()+"blockchance", true);
	getRules().Sync(victim.getUsername()+"damagereduction", true);
	getRules().Sync(victim.getUsername()+"hpregtime", true);
	getRules().Sync(victim.getUsername()+"manaregtime", true);
	getRules().Sync(victim.getUsername()+"manareg", true);
	getRules().Sync(victim.getUsername()+"maxmana", true);
	getRules().Sync(victim.getUsername()+"critchance", true);
	getRules().Sync(victim.getUsername()+"damagebuff", true);
}

void DoSetStats(CPlayer@ player)
{
	if (player is null) return;
	CBlob@ blob = player.getBlob();
	if (blob is null) return;

	if (getRules().get_string(player.getUsername()+"armorname") != "")
	{
		blob.set_string("armorname", getRules().get_string(player.getUsername()+"armorname"));
		blob.Sync("armorname", true);
		blob.set_bool("hasarmor", true);
		blob.Sync("hasarmor", true);
	}
	if (getRules().get_string(player.getUsername()+"helmetname") != "")
	{
		blob.set_string("helmetname", getRules().get_string(player.getUsername()+"helmetname"));
		blob.Sync("helmetname", true);
		blob.set_bool("hashelmet", true);
		blob.Sync("hashelmet", true);
	}
	if (getRules().get_string(player.getUsername()+"glovesname") != "")
	{
		blob.set_string("glovesname", getRules().get_string(player.getUsername()+"glovesname"));
		blob.Sync("glovesname", true);
		blob.set_bool("hasgloves", true);
		blob.Sync("hasgloves", true);
	}
	if (getRules().get_string(player.getUsername()+"bootsname") != "")
	{
		blob.set_string("bootsname", getRules().get_string(player.getUsername()+"bootsname"));
		blob.Sync("bootsname", true);
		blob.set_bool("hasboots", true);
		blob.Sync("hasboots", true);
	}

	getRules().set_string(player.getUsername()+"armorname", "");
	getRules().Sync(player.getUsername()+"armorname", true);
	getRules().set_string(player.getUsername()+"helmetname", "");
	getRules().Sync(player.getUsername()+"helmetname", true);
 	getRules().set_string(player.getUsername()+"glovesname", "");
	getRules().Sync(player.getUsername()+"glovesname", true);
	getRules().set_string(player.getUsername()+"bootsname", "");
	getRules().Sync(player.getUsername()+"bootsname", true);

	blob.set_f32("velocity", 2.5 + getRules().get_f32(player.getUsername()+"velocity"));
	getRules().set_f32(player.getUsername()+"velocity", 0);

	if (getRules().get_f32(player.getUsername()+"dodgechance")>0) 		
	{
		blob.set_f32("dodgechance", getRules().get_f32(player.getUsername()+"dodgechance") + blob.get_f32("dodgechance"));
		getRules().set_f32(player.getUsername()+"dodgechance", 0);
	}
	if (getRules().get_f32(player.getUsername()+"blockchance")>0) 		
	{
		blob.set_f32("blockchance", getRules().get_f32(player.getUsername()+"blockchance") + blob.get_f32("blockchance"));
		getRules().set_f32(player.getUsername()+"blockchance", 0);
    }
	if (getRules().get_f32(player.getUsername()+"damagereduction")>0)	
	{
		blob.set_f32("damagereduction", getRules().get_f32(player.getUsername()+"damagereduction") + blob.get_f32("damagereduction"));
		getRules().set_f32(player.getUsername()+"damagereduction", 0);
	}
	if (getRules().get_f32(player.getUsername()+"hpregtime")>0) 		
	{
		blob.set_f32("hpregtime", blob.get_f32("hpregtime") -(getRules().get_f32(player.getUsername()+"hpregtime")));
		getRules().set_f32(player.getUsername()+"hpregtime", 0);
	}
	if (getRules().get_f32(player.getUsername()+"manaregtime")>0)		
	{
		//printf("rules "+getRules().get_f32(player.getUsername()+"manaregtime"));
		//printf("blob  "+blob.get_f32("manaregtime"));
		blob.set_f32("manaregtime",  blob.get_f32("manaregtime") - getRules().get_f32(player.getUsername()+"manaregtime"));
		getRules().set_f32(player.getUsername()+"manaregtime", 0);
	}
	if (getRules().get_u16(player.getUsername()+"manareg")>0) 			
	{
		blob.set_u16("manareg",	getRules().get_u16(player.getUsername()+"manareg") + blob.get_u16("manareg"));
		getRules().set_u16(player.getUsername()+"manareg", 0);
	}
	if (getRules().get_u16(player.getUsername()+"maxmana")>0) 			
	{
		blob.set_u16("maxmana", getRules().get_u16(player.getUsername()+"maxmana") + blob.get_u16("maxmana"));
		getRules().set_u16(player.getUsername()+"maxmana", 0);
	}
	if (getRules().get_f32(player.getUsername()+"critchance")>0) 		
	{
		blob.set_f32("critchance", getRules().get_f32(player.getUsername()+"critchance") + blob.get_f32("critchance"));
		getRules().set_f32(player.getUsername()+"critchance", 0);
	}
	if (getRules().get_f32(player.getUsername()+"damagebuff")>0) 		
	{
		blob.set_f32("damagebuff", getRules().get_f32(player.getUsername()+"damagebuff") + blob.get_f32("damagebuff"));
		getRules().set_f32(player.getUsername()+"damagebuff", 0);
	}
}


void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.AddPlayerSpawn(player);
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (!getNet().isServer())
		return;

	if (!CanSwitchFromSpec(this, player, newteam))
	{
		player.server_setTeamNum(this.getSpectatorTeamNum());
		return;
	}

	if (!this.get_bool("managed teams"))
	{
		RulesCore@ core;
		this.get("core", @core);

		if (core !is null)
		{
			core.AddPlayerSpawn(player);
		}
	}
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.onSetPlayer(blob, player);
		DoSetStats(player);
	}
}
