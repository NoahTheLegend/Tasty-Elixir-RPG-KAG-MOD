
//Sandbox gamemode logic script

#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "TDM_Ruins.as";

const int maxMines = 200;
const int maxKegs = 200;
int mineCount = 0;
int kegCount = 0;

//simple config function - edit the variables below to change the basics

void Config(SandboxCore@ this)
{
	string configstr = "Rules/Sandbox/sandbox_vars.cfg";
	if (getRules().exists("sandboxconfig"))
	{
		configstr = getRules().get_string("sandboxconfig");
	}
	ConfigFile cfg = ConfigFile(configstr);

	//how long for the game to play out?
	s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));


	getRules().Tag('quick decay');

}

//Sandbox spawn system

const s32 spawnspam_limit_time = 10;

shared class SandboxSpawns : RespawnSystem
{
	SandboxCore@ Sandbox_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Sandbox_core = cast < SandboxCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < Sandbox_core.teams.length; ++team_num)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Sandbox_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "Sandbox spawn time " + info.username;

			Sandbox_core.rules.set_u8(propname, spawn_property);
			Sandbox_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if (inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlobNoInit(name);

		if (mat !is null)
		{
			mat.Tag('custom quantity');
			mat.Init();

			mat.server_SetQuantity(quantity);

			if (not blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
		}

		return true;
	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		CBlob@ tdmspawn = getBlobByName("tdm_spawn");

		if (canSpawnPlayer(p_info) && tdmspawn !is null)
		{
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}

			if (p_info.blob_name == "") // if user is new
			{
				u8 rand = XORRandom(3);
				switch (rand)
				{
					case 0: p_info.blob_name = "knight";
					case 1: p_info.blob_name = "archer";
					case 3: p_info.blob_name = "rogue";
				}
			}

			CBlob@ playerBlob = SpawnPlayerIntoWorld(tdmspawn.getPosition(), p_info);

			if (playerBlob !is null)
			{
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);
			}
		}
		else if (canSpawnPlayer(p_info))
		{
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}

			if (p_info.blob_name == "") // if user is new
			{
				u8 rand = XORRandom(3);
				switch (rand)
				{
					case 0: p_info.blob_name = "knight";
					case 1: p_info.blob_name = "archer";
					case 3: p_info.blob_name = "rogue";
				}
			}

			CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);

			if (playerBlob !is null)
			{
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		return true;
		/*
		if (force) { return true; }

		return info.can_spawn_time <= 0;*/
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		if (getBlobByName("tdm_spawn") !is null)
			return getBlobByName("tdm_spawn").getPosition();
		
		return Vec2f(0,0);
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "Sandbox spawn time " + info.username;

		for (uint i = 0; i < Sandbox_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Sandbox_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		Sandbox_core.rules.set_u8(propname, 255);   //not respawning
		Sandbox_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(Sandbox_core.spawnTime);

		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

//		print("ADD SPAWN FOR " + player.getUsername());

		if (info.team < Sandbox_core.teams.length)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Sandbox_core.teams[info.team]);

			info.can_spawn_time = tickspawndelay;

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < Sandbox_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Sandbox_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

shared class SandboxCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;

	SandboxSpawns@ Sandbox_spawns;

	SandboxCore() {}

	SandboxCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		@Sandbox_spawns = cast < SandboxSpawns@ > (_respawns);
		server_CreateBlob("Entities/Meta/WARMusic.cfg");
	}

	void Update()
	{

		if (rules.isGameOver()) { return; }

		RulesCore::Update(); //update respawns
		CheckTeamWon();

	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		CTFTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		CTFPlayerInfo p(player.getUsername(), 0, "knight");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

	//checks
	void CheckTeamWon()
	{
		if (!rules.isMatchRunning()) { return; }
		//can you win sandbox? :)
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			CTFTeamInfo@ team_info = cast < CTFTeamInfo@ > (teams[team]);
		}
	}

};

//pass stuff to the core from each of the hooks

void onInit(CRules@ this)
{
	this.minimap = false;
	Reset(this);
}

void onRestart(CRules@ this)
{
	for (u16 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			string name = player.getUsername();
			player.set_u16("level", 0);
			player.set_u32("exp", 0);
			player.set_u16("knightlvlr1", 1);
			player.set_u16("knightlvlr2", 1);
			player.set_u16("archerlvlr1", 1);
			player.set_u16("archerlvlr2", 1);
			player.set_u16("roguelvlr1", 1);
			player.set_u16("roguelvlr2", 1);
			player.set_u16("skillpoints", 1);
			
			for (u8 i = 1; i <= 20; i++)
			{
				player.set_u16("hasskill"+i, 255);
			}
			player.Tag("resetTags");
		}
	}
	Reset(this);
}

void Reset(CRules@ this)
{
	this.set_u32("clearFrequency", getGameTime()+30*60*30);
	string[] names = {
	"burdockspice",
	"burnetspice",
	"equisetumspice",
	"mindwortspice",
	"poppyspice",
	"thymespice"
	};

	string[] combinations;

	while (combinations.length < 6) // shuffling
	{
		u8 rand = XORRandom(names.length);

		combinations.push_back(names[rand]);
		names.erase(rand);
	}

	CBlob@[] tables;
	getBlobsByName("potionstable", tables);

	for (int i = 0; i < tables.length; i++)
	{
		if (tables[i] is null) continue;
		tables[i].set_string("key1", combinations[0]);
		tables[i].set_string("key2", combinations[1]);
		tables[i].set_string("key3", combinations[2]);
		tables[i].set_string("key4", combinations[3]);
		tables[i].set_string("key5", combinations[4]);
		tables[i].set_string("key6", combinations[5]);
	}

	this.set_string("key1", combinations[0]);
	this.set_string("key2", combinations[1]);
	this.set_string("key3", combinations[2]);
	this.set_string("key4", combinations[3]);
	this.set_string("key5", combinations[4]);
	this.set_string("key6", combinations[5]);

	printf("Restarting rules script: " + getCurrentScriptName());
	SandboxSpawns spawns();
	SandboxCore core(this, spawns);
	Config(core);

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");

	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as

	kegCount = 0;
	mineCount = 0;
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "mine")
	{
		mineCount += 1;
		if (mineCount > maxMines)
		{
			blob.server_Die(); // wont explode because its just been made
		}
	}
	else if (blob.getName() == "keg")
	{
		kegCount += 1;
		if (kegCount > maxKegs)
		{
			blob.server_Die();
		}
	}
}


void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "mine")
	{
		mineCount -= 1;
	}
	else if (blob.getName() == "keg")
	{
		kegCount -= 1;
	}
}

