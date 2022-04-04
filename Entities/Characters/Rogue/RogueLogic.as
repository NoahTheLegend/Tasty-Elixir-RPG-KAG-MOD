// Knight logic

#include "ThrowCommon.as";
#include "RogueCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as";
#include "CustomBlocks.as";


//attacks limited to the one time per-actor before reset.

void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	KnightInfo knight;

	this.set_u8("attackdelay", 0);
	this.set_u8("attackdelayreduce", 30);

	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.shieldTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.shield_down = getGameTime();
	knight.tileDestructionLimiter = 0;

	this.set("knightInfo", @knight);

	this.set_f32("gib health", -1.5f);
	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	knight_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.addCommandID("get bomb");

	this.push("names to activate", "keg");
	this.push("names to activate", "bigkeg");

	this.set_u8("bomb type", 255);
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		this.addCommandID("pick " + bombTypeNames[i]);
	}

	//centered on bomb select
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	SetHelp(this, "help self action", "knight", getTranslatedString("$Jab$Jab        $LMB$"), "", 4);
	SetHelp(this, "help self action2", "knight", getTranslatedString("$Shield$Shield    $KEY_HOLD$$RMB$"), "", 4);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u8("dashcd", 0);
	this.set_u8("dashbufftimer", 0);

	//armor/weapons check
	this.addCommandID("unequiphelmet");
	this.addCommandID("unequiparmor");
	this.addCommandID("unequipgloves");
	this.addCommandID("unequipboots");

	this.set_bool("hasarmor", false);
	this.set_string("armorname", "");

	this.set_bool("hasboots", false);
	this.set_string("bootsname", "");

	this.set_bool("hasgloves", false);
	this.set_string("glovesname", "");

	this.set_bool("hashelmet", false);
	this.set_string("helmetname", "");
	//stats
	this.set_f32("velocity", 2.5);
    this.set_f32("dodgechance", 5.0);
    this.set_f32("damagereduction", 0.05);
	this.set_f32("hpregtime", 20*30);
	this.set_u16("hpregtimer", 20*30);
	this.set_f32("manaregtime", 15*30);
	this.set_u16("manaregtimer", 10*30);
	this.set_u16("manareg", 15);
	this.set_u16("mana", 65);
	this.set_u16("maxmana", 65);
	this.set_f32("critchance", 5.0);
	this.set_f32("damagebuff", 0);
	this.set_f32("dealtdamage", 0);

	this.set_f32("attackspeed", 0);
	this.set_f32("armorpenetration", 0); // %
	this.set_f32("vampirism", 0);
	this.set_bool("glowness", false);
	this.set_bool("glowness2", false);
	this.set_f32("dealtdamage", 0);
	this.set_f32("gravityresist", 0);
	this.set_f32("bashchance", 0); // %
	//gathered set vars
	this.set_bool("hasrlset", false);
	//hunger&thirst
	this.set_u8("hunger", 0);
	this.set_u8("thirst", 0);
	//other
	this.set_bool("poisoned", false);
	this.set_bool("bleeding", false);
	this.set_u8("bleedmodifier", 1);
	this.set_bool("regen", false);
	this.set_u16("silenceskilltimer", 0);
	//effecttimers & buffs at their slots
	this.set_u16("timer1", 0);
	this.set_u16("timer2", 0);
	this.set_u16("timer3", 0);
	this.set_u16("timer4", 0);
	this.set_u16("timer5", 0);
	this.set_u16("timer6", 0);
	this.set_u16("timer7", 0);
	this.set_u16("timer8", 0);
	this.set_u16("timer9", 0);
	this.set_u16("timer10", 0);

	this.addCommandID("timercheck");

	this.set_string("buffs1", "");
	this.set_string("buffs2", "");
	this.set_string("buffs3", "");
	this.set_string("buffs4", "");
	this.set_string("buffs5", "");
	this.set_string("buffs6", "");
	this.set_string("buffs7", "");
	this.set_string("buffs8", "");
	this.set_string("buffs9", "");
	this.set_string("buffs10", "");

	this.addCommandID("receive_effect");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null) return;
	if (!this.isMyPlayer()) return;

	CControls@ controls = this.getControls();
	if (controls !is null)
	{
		bool ctrl = controls.isKeyPressed(KEY_LCONTROL);

    	if (caller.get_bool("hashelmet") && ctrl)
    	{
    	    CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("helmetname")+"$", Vec2f(0, -10), this, this.getCommandID("unequiphelmet"), getTranslatedString("Unequip helmet"), params);
    	}
		if (caller.get_bool("hasarmor") && ctrl)
    	{
    	    CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("armorname")+"$", Vec2f(0, -5), this, this.getCommandID("unequiparmor"), getTranslatedString("Unequip armor"), params);
    	}
		if (caller.get_bool("hasgloves") && ctrl)
    	{
    	    CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("glovesname")+"$", Vec2f(0, 0), this, this.getCommandID("unequipgloves"), getTranslatedString("Unequip gloves"), params);
    	}
		if (caller.get_bool("hasboots") && ctrl)
    	{
    	    CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("bootsname")+"$", Vec2f(0, 5), this, this.getCommandID("unequipboots"), getTranslatedString("Unequip boots"), params);
    	}
	}
}

void DoAttackSpeedChange(CBlob@ this, f32 speed, bool increase)
{
	if (increase) this.set_u8("attackdelayreduce", this.get_u8("attackdelayreduce") - speed * 10);
	else this.set_u8("attackdelayreduce", this.get_u8("attackdelayreduce") + speed * 10);
}

void onTick(CBlob@ this)
{
	CControls@ controls = this.getControls();
	if (controls !is null)
	{
		if (controls.isKeyJustReleased(KEY_KEY_G) && this.get_string("skill1") != ""
		&& this.get_u16("skillcd1") == 0 && !this.get_bool("animplaying")) // skill 1
		{
			CBitStream params;
			params.write_string(this.get_string("skilltype1"));
			params.write_u8(this.get_u8("skillpos1")); // pos of skill in hotbar
			params.write_u16(this.get_u16("skillidx1"));
			this.SendCommand(this.getCommandID("activate_skill"), params);
			//printf("sent");
			this.set_bool("animplaying", true);
			this.set_string("animname", this.get_string("skill1"));
			this.set_u32("begintime", getGameTime());
		}
		else if (controls.isKeyJustReleased(KEY_KEY_H) && this.get_string("skill2") != ""
		&& this.get_u16("skillcd2") == 0 && !this.get_bool("animplaying"))
		{
			CBitStream params;
			params.write_string(this.get_string("skilltype2"));
			params.write_u8(this.get_u8("skillpos2"));
			params.write_u16(this.get_u16("skillidx2"));
			this.SendCommand(this.getCommandID("activate_skill"), params);

			this.set_bool("animplaying", true);
			this.set_string("animname", this.get_string("skill2"));
			this.set_u32("begintime", getGameTime());
		}
	}
	//soundtracks
	if (getGameTime() % 150 == 0) // every 5 seconds check
	{
		CMap@ map = getMap();
		Tile tile = map.getTile(this.getPosition());
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;
		//surface

		//caves

		//inferno
		int posy = this.getPosition().y;
		//printf("pos: "+posy+" of map height*8/3: "+this.getMap().tilemapheight*8/3);
		if (this.get_string("track") == ""
		&& posy > this.getMap().tilemapheight*8/3
		&& (tile.type == CMap::tile_inferno_ash_back
		|| tile.type == CMap::tile_inferno_ash_back_d0
		|| tile.type == CMap::tile_inferno_ash_back_d1
		|| tile.type == CMap::tile_inferno_ash_back_d2
		|| tile.type == CMap::tile_inferno_ash_back_d3
		|| tile.type == CMap::tile_inferno_ash_back_d4
		|| tile.type == CMap::tile_inferno_ash_back_d5
		|| tile.type == CMap::tile_inferno_ash_back_d6
		|| tile.type == CMap::tile_inferno_ash_back_d7
		|| tile.type == CMap::tile_inferno_ash_back_d8
		|| tile.type == CMap::tile_inferno_castle_back
		|| tile.type == CMap::tile_inferno_castle_back_d0
		|| tile.type == CMap::tile_inferno_castle_back_d1
		|| tile.type == CMap::tile_inferno_castle_back_d2
		|| tile.type == CMap::tile_inferno_castle_back_d3
		|| tile.type == CMap::tile_inferno_castle_back_d4
		|| tile.type == CMap::tile_inferno_castle_back_d5
		|| tile.type == CMap::tile_inferno_castle_back_d6
		|| tile.type == CMap::tile_inferno_castle_back_d7
		|| tile.type == CMap::tile_inferno_castle_back_d8))
		{
			if (isClient() && this.isMyPlayer() && XORRandom(40) < 1 // 2.5% chance every 5 sec
			&& this.get_u32("tracktimer") == 0 && this.get_u16("tracktimercd") == 0)
			{
				if (XORRandom(10) < 5)
				{
					sprite.SetEmitSound("Inferno_1.ogg");
					sprite.SetEmitSoundVolume(0.25f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Inferno_1.ogg");
					this.set_u32("tracktimer", 285*30 + 300); // 4.85 min + cd check
				}
				else if (this.get_u32("tracktimer") == 0)
				{
					sprite.SetEmitSound("Inferno_2.ogg");
					sprite.SetEmitSoundVolume(0.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Inferno_2.ogg");
					this.set_u32("tracktimer", 225*30 + 300); // 3.85 min + cd check
				}
				else if (this.get_u32("tracktimer") == 0)
				{
					sprite.SetEmitSound("Inferno_3.ogg");
					sprite.SetEmitSoundVolume(0.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Inferno_3.ogg");
					this.set_u32("tracktimer", 75*30 + 300); // 1.25 min + cd check
				}
			}
		}
		
		//abyss
		else if (this.get_string("track") == ""
		&& tile.type == CMap::tile_abyss_dirt_back
		|| tile.type == CMap::tile_abyss_dirt_back_d0
		|| tile.type == CMap::tile_abyss_dirt_back_d1
		|| tile.type == CMap::tile_abyss_dirt_back_d2)
		{
			if (isClient() && this.isMyPlayer() && XORRandom(40) < 1 // 10% chance every 5 sec
			&& this.get_u32("tracktimer") == 0 && this.get_u16("tracktimercd") == 0)
			{
				if (XORRandom(10) < 5)
				{
					sprite.SetEmitSound("Abyss_1.ogg");
					sprite.SetEmitSoundVolume(0.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Abyss_1.ogg");
					this.set_u32("tracktimer", 150*30 + 300); // 2.5 min + cd check
				}
				else if (this.get_u32("tracktimer") == 0)
				{
					sprite.SetEmitSound("Abyss_2(HK-OST).ogg");
					sprite.SetEmitSoundVolume(1.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Abyss_2(HK-OST).ogg");
					this.set_u32("tracktimer", 930*30 + 300); // 15.5 min + cd check
				}
			}
		}
		else if (XORRandom(20) == 0 // remove soundtrack if out, 5% chance
		&& (this.get_string("track") == "Abyss_1.ogg"
		|| this.get_string("track") == "Abyss_2(HK-OST).ogg"
		|| this.get_string("track") == "Inferno_1.ogg"
		|| this.get_string("track") == "Inferno_2.ogg"
		|| this.get_string("track") == "Inferno_3.ogg"))
		{
			sprite.SetEmitSoundPaused(true);
			this.set_string("track", "");
			this.set_u32("tracktimer", 0);
			this.set_u16("tracktimercd", 60*30); // 1 min cd
		}

		//track timer
		if (this.get_u32("tracktimer") > 0) this.set_u32("tracktimer", this.get_u32("tracktimer") - 150);
		if (this.get_u16("tracktimercd") > 0) this.set_u16("tracktimercd", this.get_u16("tracktimercd") - 150);
		else if (this.get_u32("tracktimer") < 0 || this.get_u32("tracktimer") > 30000 ) this.set_u32("tracktimer", 0);
		else if (this.get_u32("tracktimer") >= 0 && this.get_u32("tracktimer") <= 150
		&& this.get_u16("tracktimercd") == 0 && this.get_string("track") != "")
		{
			sprite.SetEmitSoundPaused(true);
			this.set_string("track", "");
			this.set_u16("tracktimercd", 300*30); //5 min cd
		}
		//if (this.get_u32("tracktimer") > 0) printf(""+this.get_u32("tracktimer"));
		//if (this.get_u16("tracktimercd") > 0) printf(""+this.get_u16("tracktimercd"));
	}
	//check if smth broke
	if (getGameTime() % 5 == 0)
	{
		string lengthie = ""+this.get_f32("attackspeed");
		if (this.get_u8("hunger") > 150) this.set_u8("hunger", 0);
		if (this.get_u8("thirst") > 150) this.set_u8("thirst", 0);
		if (this.get_f32("attackspeed") < 0
		|| this.get_f32("attackspeed") > 3
		|| lengthie.length >= 8) this.set_f32("attackspeed", 0);
	}
	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);
	if (this.hasTag("updateattackspeed"))
	{
		DoAttackSpeedChange(this, this.get_f32("attackspeed"), true);
		this.Untag("updateattackspeed");
	}
	//set buffs
	if (this.get_string("armorname") == "rl_chestplate"
	&& this.get_string("helmetname") == "rl_helmet"
	&& this.get_string("glovesname") == "rl_gloves"
	&& this.get_string("bootsname") == "rl_boots")
	{
		this.Tag("rlset");
	}
	else this.Untag("rlset");

	if (this.hasTag("rlset") && !this.get_bool("hasrlset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.1);
		this.set_f32("velocity", this.get_f32("velocity") + 0.2);
		this.set_bool("hasrlset", true);
	}
	else if (!this.hasTag("rlset") && this.get_bool("hasrlset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.1);
		this.set_f32("velocity", this.get_f32("velocity") - 0.2);
		this.set_bool("hasrlset", false);
	}

	if (this.get_u16("mana") > this.get_u16("maxmana")) this.set_u16("mana", this.get_u16("maxmana"));

	//debuffs
	if (getGameTime() % 150 == 0 && this.get_bool("poisoned"))
	{
		if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0.6), 0.5f,  Hitters::stab);
	}
	if (getGameTime() % 75 == 0 && this.get_bool("bleeding"))
	{
		if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0.6), this.get_u8("bleedmodifier") * 0.1f, Hitters::stab);
		if (isClient()) ParticleBloodSplat(this.getPosition() + getRandomVelocity(0, 0.75f + this.get_u8("bleedmodifier") * 2.0f * XORRandom(2), 360.0f), false);

		if (this.get_u8("bleedmodifier") < 20) this.set_u8("bleedmodifier", this.get_u8("bleedmodifier") + 1);
	}
	if (this.hasTag("ded"))
	{
		if (this.getSprite() !is null) this.getSprite().PlaySound("MigrantScream1.ogg");
		if (isServer()) this.server_Die();
	}

	if (getGameTime() % 60 == 0 && !this.get_bool("bleeding")) this.set_u8("bleedmodifier", 1);

	RunnerMoveVars@ moveVars;

	u8 knocked = getKnocked(this);
	CHUD@ hud = getHUD();

	//get the vars to turn various other scripts on/off

	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	//lava stuff
	CMap@ map = getMap();
	Tile tile = map.getTile(this.getPosition());
	if (tile.type > 463 && tile.type < 467) // lava indexes
	{
		this.setVelocity(Vec2f(0,this.getVelocity().y*0.25));
		if (this.isKeyPressed(key_up) && !this.isKeyPressed(key_action2)) this.AddForce(Vec2f(0,-35.0f));
		if (getGameTime()%15==0)
		{
			if (isServer())
			{
				map.server_setFireWorldspace(this.getPosition(), true);
				this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire);
			}
			if (this.isMyPlayer()) SetScreenFlash(125, 255, 0, 0, 0.5f);
		}
	}
	//glowness & fishbreathing
	if (this.get_bool("glowness"))
	{
		this.SetLight(true);
		this.SetLightColor(SColor(255, 200, 200, 0));
		this.SetLightRadius(50.0f);
	}
	else if (this.get_bool("glowness2"))
	{
		this.SetLight(true);
		this.SetLightColor(SColor(255, 200, 200, 0));
		this.SetLightRadius(100.0f);
	}
	else this.SetLight(false);
	//regen
	this.Sync("hpregtime", true);
	this.Sync("manaregtime", true);
	if (this !is null && this.get_f32("hpregtime") > 0 && !this.get_bool("poisoned"))
		if (this.get_u16("hpregtimer") == 0)
		{
			this.set_u16("hpregtimer", this.get_f32("hpregtime"));
			if (isServer()) 
			{
				if (this.get_bool("regen")) this.server_Heal(0.50f);
				else this.server_Heal(0.25f);
			}
		}
	if (this !is null && this.get_f32("manaregtime") > 0)
		if (this.get_u16("manaregtimer") == 0)
		{
			this.set_u16("manaregtimer", this.get_f32("manaregtime"));
			this.set_u16("mana", this.get_u16("mana") + this.get_u16("manareg"));
		}

	if (this.get_u8("attackdelay") > 0) this.set_u8("attackdelay", this.get_u8("attackdelay") - 1);

	if (getGameTime() % 30 == 0)
	{
		if (this.get_u16("hpregtimer") > 0) this.set_u16("hpregtimer", this.get_u16("hpregtimer") - 30);
		if (this.get_u16("manaregtimer") > 0) this.set_u16("manaregtimer", this.get_u16("manaregtimer") - 30);
		if (this.get_u16("hpregtimer") < 0) this.set_u16("hpregtimer", 0);
		if (this.get_u16("manaregtimer") < 0) this.set_u16("manaregtimer", 0);

		//stat timers
		if (this.get_u16("timer1") > 0)
		{
			TimerCheck(this, 1);
		}
		if (this.get_u16("timer2") > 0)
		{
			TimerCheck(this, 2);
		}
		if (this.get_u16("timer3") > 0)
		{
			TimerCheck(this, 3);
		}
		if (this.get_u16("timer4") > 0)
		{
			TimerCheck(this, 4);
		}
		if (this.get_u16("timer5") > 0)
		{
			TimerCheck(this, 5);
		}
		if (this.get_u16("timer6") > 0)
		{
			TimerCheck(this, 6);
		}
		if (this.get_u16("timer7") > 0)
		{
			TimerCheck(this, 7);
		}
		if (this.get_u16("timer8") > 0)
		{
			TimerCheck(this, 8);
		}
		if (this.get_u16("timer9") > 0)
		{
			TimerCheck(this, 9);
		}
		if (this.get_u16("timer10") > 0)
		{
			TimerCheck(this, 10);
		}
	}
	//hunger & thirst
	if (getGameTime() % 750 == 0 && this.getTickSinceCreated() >= 750) // 25 sec
	{
		if (XORRandom(11) <= 5 && this.getVelocity().x == 0) return; // if player is not moving, with some chance (5 to 10)

		if (this.get_u8("thirst") < 100) this.set_u8("thirst", this.get_u8("thirst") + 1);
		else if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.5f,  Hitters::stab);
		
		if (this.get_u8("hunger") < 100) this.set_u8("hunger", this.get_u8("hunger") + 1);
		else if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.5f,  Hitters::stab);

		this.Sync("hunger", true);
		this.Sync("thirst", true);
	}
	
	if (this.get_f32("velocity") > 0 && this.get_u8("thirst") < 50 && this.get_u8("hunger") < 50)
	{
		moveVars.walkSpeed = this.get_f32("velocity");
		moveVars.walkSpeedInAir = this.get_f32("velocity");
	}
	else if (this.get_u8("thirst") > 50 || this.get_u8("hunger") > 50)
	{
		moveVars.walkSpeed = 1.5f;
		moveVars.walkSpeedInAir = 1.5f;
	}
	else
	{
		moveVars.walkSpeed = 2.5f;
		moveVars.walkSpeedInAir = 2.5f;
	}

	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	bool shieldState = isShieldState(knight.state);
	bool specialShieldState = isSpecialShieldState(knight.state);
	bool swordState = isSwordState(knight.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	if (this.isKeyJustReleased(key_action1) && this.get_u8("attackdelay") == 0)
	{
		this.set_u8("attackdelay", this.get_u8("attackdelayreduce"));
	}
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();


	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if knights dmging stuff while in menus is a real issue and go from there

	if (this.get_u8("dashcd") > 0) this.set_u8("dashcd", this.get_u8("dashcd") - 1);
	if (pressed_a2 && this.get_u8("dashcd") == 0)
	{
		this.set_f32("dodgechance", this.get_f32("dodgechance") + 35.0);
		this.set_f32("critchance", this.get_f32("critchance") + 15.0);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 1.0);

		this.set_u8("dashcd", 150);
		this.set_u16("mana", this.get_u16("mana") - 5);
		Vec2f vel = this.getVelocity();
		this.AddForce(Vec2f(vel.x * 3.0, 0.0f));   //horizontal slowing force (prevents SANICS)
			
		Vec2f velocity = this.getAimPos() - this.getPosition();
		velocity.Normalize();
		// velocity.y *= 0.5f;
				
		this.setVelocity(velocity * 7.5);
		this.set_string("sweep", "sweep.ogg");
		this.getSprite().PlaySound(this.get_string("sweep"));

		this.Tag("dashbuff");
		this.set_u8("dashbufftimer", 60);
	}

	if (this.get_u8("dashbufftimer") > 0) this.set_u8("dashbufftimer", this.get_u8("dashbufftimer") - 1);

	if (((this.isOnGround() || this.isOnLadder()) || this.get_u8("dashbufftimer") == 0) && this.hasTag("dashbuff"))
	{
		this.Untag("dashbuff");
		this.set_f32("dodgechance", this.get_f32("dodgechance") - 35.0);
		this.set_f32("critchance", this.get_f32("critchance") - 15.0);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 1.0);
	}

	if (this.getCarriedBlob() !is null)
	{
		if (this.getCarriedBlob().getName() == "drill"
		|| this.getCarriedBlob().getName() == "irondrill"
		|| this.getCarriedBlob().getName() == "steeldrill"
		|| this.getCarriedBlob().getName() == "palladiumdrill"
		|| this.getCarriedBlob().getName() == "platinumdrill")
		{
			knight.state = KnightStates::normal; //cancel any attacks or shielding
			knight.swordTimer = 0;
			knight.doubleslash = false;

			pressed_a1 = false;
			pressed_a2 = false;
		}
	}

	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{
		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;

		pressed_a1 = false;
		pressed_a2 = false;
	}
	else if (!pressed_a1 && !swordState &&
	         (pressed_a2 || (specialShieldState)))
	{
		knight.swordTimer = 0;

		if (this.hasTag("climbing"))
		{
			this.Untag("climbing");
		}
	}
	else if ((pressed_a1 || swordState) && !moveVars.wallsliding)   //no attacking during a slide
	{
		if (this.hasTag("climbing"))
		{
			this.Untag("climbing");
		}
		
		if (getNet().isClient())
		{
			if (knight.swordTimer == KnightVars::slash_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
			else if (knight.swordTimer == KnightVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
		}

		if (knight.swordTimer >= KnightVars::slash_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked(this, 15);
		}

		bool strong = (knight.swordTimer > KnightVars::slash_charge_level2);
		moveVars.jumpFactor *= (strong ? 0.5f : 0.7f);
		moveVars.walkFactor *= (strong ? 0.9f : 1.1f);
		knight.shieldTimer = 0;

		if (!inair)
		{
			this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
		}

		if (knight.state == KnightStates::normal ||
		        this.isKeyJustPressed(key_action1) &&
		        (!inMiddleOfAttack(knight.state) || shieldState))
		{
			knight.state = KnightStates::sword_drawn;
			knight.swordTimer = 0;
		}

		if (knight.state == KnightStates::sword_drawn && getNet().isServer())
		{
			knight_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = knight.swordTimer;
		if (knight.swordTimer < 128)
			knight.swordTimer++;

		if (knight.state == KnightStates::sword_drawn && !pressed_a1 &&
		        !this.isKeyJustReleased(key_action1) && delta > KnightVars::resheath_time)
		{
			knight.state = KnightStates::normal;
		}
		else if ((this.get_u8("attackdelay") == 0 || this.get_u8("attackdelay") >= this.get_u8("attackdelayreduce") - 5) && this.isKeyJustReleased(key_action1) && knight.state == KnightStates::sword_drawn)
		{
			knight.swordTimer = 0;

			if (delta < KnightVars::slash_charge)
			{
				if (direction == -1)
				{
					knight.state = KnightStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						knight.state = KnightStates::sword_cut_mid;
					}
					else
					{
						knight.state = KnightStates::sword_cut_mid_down;
					}
				}
				else
				{
					knight.state = KnightStates::sword_cut_down;
				}
			}
			else if (delta < KnightVars::slash_charge_level2)
			{
				knight.state = KnightStates::sword_power;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else if (delta < KnightVars::slash_charge_limit)
			{
				knight.state = KnightStates::sword_power_super;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else
			{
				//knock?
			}
		}
		else if (knight.state >= KnightStates::sword_cut_mid &&
		         knight.state <= KnightStates::sword_cut_down) // cut state
		{
			moveVars.jumpFactor *= 1.1f;
			moveVars.walkFactor *= 0.65f;

			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 70.0f;
				f32 attackAngle = getCutAngle(this, knight.state);

				if (knight.state == KnightStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, 2.0f, attackAngle, attackarc, Hitters::sword, delta, knight);
			}
			else if (delta >= 15)
			{
				knight.swordTimer = 0;
				knight.state = KnightStates::sword_drawn;
			}
		}
		else if (knight.state == KnightStates::sword_power ||
		         knight.state == KnightStates::sword_power_super)
		{
			//setting double
			if (knight.state == KnightStates::sword_power_super &&
			        this.isKeyJustPressed(key_action1))
			{
				knight.doubleslash = true;
			}

			//attacking + noises
			if (delta == 2)
			{
				Sound::Play("/ArgLong", this.getPosition());
				Sound::Play("/SwordSlash", this.getPosition());
			}
			else if (delta > DELTA_BEGIN_ATTACK && delta < 10)
			{
				DoAttack(this, 2.5f, -(vec.Angle()), 120.0f, Hitters::sword, delta, knight);
			}
			else if (delta >= KnightVars::slash_time ||
			         (knight.doubleslash && delta >= KnightVars::double_slash_time))
			{
				knight.swordTimer = 0;

				if (knight.doubleslash)
				{
					knight_clear_actor_limits(this);
					knight.doubleslash = false;
					knight.state = KnightStates::sword_power;
				}
				else
				{
					knight.state = KnightStates::sword_drawn;
				}
			}
		}

		//special slash movement

		if ((knight.state == KnightStates::sword_power ||
		        knight.state == KnightStates::sword_power_super) &&
		        delta < KnightVars::slash_move_time)
		{

			if (Maths::Abs(vel.x) < KnightVars::slash_move_max_speed &&
			        vel.y > -KnightVars::slash_move_max_speed)
			{
				Vec2f slash_vel =  knight.slash_direction * this.getMass() * 0.5f;
				this.AddForce(slash_vel);
			}
		}

		moveVars.canVault = false;

	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1) || this.get_u32("knight_timer") <= getGameTime())
	{
		knight.state = KnightStates::normal;
	}

	//throwing bombs

	if (myplayer)
	{
		// space

		if (this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			bool holding = carried !is null;// && carried.hasTag("exploding");

			CInventory@ inv = this.getInventory();
			bool thrown = false;
			u8 bombType = this.get_u8("bomb type");
			if (bombType == 255)
			{
				SetFirstAvailableBomb(this);
				bombType = this.get_u8("bomb type");
			}
			if (bombType < bombTypeNames.length)
			{
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					const string itemname = item.getName();
					if (!holding && bombTypeNames[bombType] == itemname)
					{
						if (bombType >= 2)
						{
							this.server_Pickup(item);
							client_SendThrowOrActivateCommand(this);
							thrown = true;
						}
						else
						{
							CBitStream params;
							params.write_u8(bombType);
							this.SendCommand(this.getCommandID("get bomb"), params);
							thrown = true;
						}
						break;
					}
				}
			}

			if (!thrown)
			{
				client_SendThrowOrActivateCommand(this);
				SetFirstAvailableBomb(this);
			}
		}

		// help

		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "knight", getTranslatedString("$Slash$ Slash!    $KEY_HOLD$$LMB$"), "", 13);
		}
	}

	//setting the shield direction properly
	if (shieldState)
	{
		int horiz = this.isFacingLeft() ? -1 : 1;
		setShieldEnabled(this, true);

		setShieldAngle(this, SHIELD_BLOCK_ANGLE);

		if (specialShieldState)
		{
			if (knight.state == KnightStates::shieldgliding)
			{
				setShieldDirection(this, Vec2f(0, -1));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_GLIDING);
			}
			else //shield dropping
			{
				setShieldDirection(this, Vec2f(horiz, 2));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_SLIDING);
			}
		}
		else if (walking)
		{
			if (direction == 0) //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else
			{
				setShieldDirection(this, Vec2f(horiz, -3));
			}
		}
		else
		{
			if (direction == 0)   //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else //up
			{
				if (vec.y < -0.97)
				{
					setShieldDirection(this, Vec2f(0, -1));
				}
				else
				{
					setShieldDirection(this, Vec2f(horiz, -3));
				}
			}
		}

		// shield up = collideable

		if ((knight.state == KnightStates::shielding && direction == -1) ||
		        knight.state == KnightStates::shieldgliding)
		{
			if (!this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Tag("shieldplatform");
			}
		}
		else
		{
			if (this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Untag("shieldplatform");
			}
		}
	}
	else
	{
		setShieldEnabled(this, false);

		if (this.hasTag("shieldplatform"))
		{
			this.getShape().checkCollisionsAgain = true;
			this.Untag("shieldplatform");
		}
	}

	if (!swordState && getNet().isServer())
	{
		knight_clear_actor_limits(this);
	}
}

void TimerCheck(CBlob@ this, u8 index)
{
	this.set_u16("timer"+index, this.get_u16("timer"+index) - 30);
	if (this.get_u16("timer"+index) <= 3 || this.get_u16("timer"+index) > 25000) 
	{
		this.set_u16("timer"+index, 0);
		CBitStream params;
		params.write_string(this.get_string("buffs"+index));
		params.write_u8(index);
		this.SendCommand(this.getCommandID("timercheck"), params);
	}
	if (index > 1)
	{
		if (this.get_u16("timer"+(index-1)) <= 0)
		{
			this.set_u16("timer"+(index-1), this.get_u16("timer"+index));
			this.set_string("buffs"+(index-1), this.get_string("buffs"+index));
			this.set_string("eff"+(index-1), this.get_string("eff"+index));
			this.set_u16("timer"+index, 0);
			this.set_string("buffs"+index, "");
			this.set_string("eff"+index, "");
		}
	}
}

void SetToFreeSlot(CBlob@ this, string name, string buff, u16 time)
{
		if (this.get_string("eff1") == "")
	{
		this.set_u16("timer1", time);
		this.set_string("eff1", name);
		this.Sync("eff1", true); // for onRender
		this.set_string("buffs1", buff);
		this.Sync("buffs1", true);
	} 
	else if (this.get_string("eff2") == "") 
	{
		this.set_u16("timer2", time);
		this.set_string("eff2", name);
		this.Sync("eff2", true);
		this.set_string("buffs2", buff);
		this.Sync("buffs2", true);
	}
	else if (this.get_string("eff3") == "")
	{
		this.set_u16("timer3", time);
		this.set_string("eff3", name);
		this.Sync("eff3", true);
		this.set_string("buffs3", buff);
		this.Sync("buffs3", true);
	}
	else if (this.get_string("eff4") == "")
	{
		this.set_u16("timer4", time);
		this.set_string("eff4", name);
		this.Sync("eff4", true);
		this.set_string("buffs4", buff);
		this.Sync("buffs4", true);
	}
	else if (this.get_string("eff5") == "")
	{
		this.set_u16("timer5", time);
		this.set_string("eff5", name);
		this.Sync("eff5", true);
		this.set_string("buffs5", buff);
		this.Sync("buffs5", true);
	}
	else if (this.get_string("eff6") == "")
	{
		this.set_u16("timer6", time);
		this.set_string("eff6", name);
		this.Sync("eff6", true); // for onRender
		this.set_string("buffs6", buff);
		this.Sync("buffs6", true);
	} 
	else if (this.get_string("eff7") == "") 
	{
		this.set_u16("timer7", time);
		this.set_string("eff7", name);
		this.Sync("eff7", true);
		this.set_string("buffs7", buff);
		this.Sync("buffs7", true);
	}
	else if (this.get_string("eff8") == "")
	{
		this.set_u16("timer8", time);
		this.set_string("eff8", name);
		this.Sync("eff8", true);
		this.set_string("buffs8", buff);
		this.Sync("buffs8", true);
	}
	else if (this.get_string("eff9") == "")
	{
		this.set_u16("timer9", time);
		this.set_string("eff9", name);
		this.Sync("eff9", true);
		this.set_string("buffs9", buff);
		this.Sync("buffs9", true);
	}
	else if (this.get_string("eff10") == "")
	{
		this.set_u16("timer10", time);
		this.set_string("eff10", name);
		this.Sync("eff10", true);
		this.set_string("buffs10", buff);
		this.Sync("buff10", true);
	}
}

void UpdateStats(CBlob@ this, CBlob@ blob)
{
											this.set_f32("velocity", this.get_f32("velocity") + blob.get_f32("velocity"));
    if (blob.get_f32("dodgechance")>0) 		this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
	if (blob.get_f32("blockchance")>0) 		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    if (blob.get_f32("damagereduction")>0)	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
	if (blob.get_f32("hpregtime")>0) 		this.set_f32("hpregtime", this.get_f32("hpregtime") - (blob.get_f32("hpregtime"))*-1);
	if (blob.get_f32("manaregtime")>0)		this.set_f32("manaregtime", this.get_f32("manaregtime") - (blob.get_f32("manaregtime"))*-1);
	if (blob.get_u16("manareg")>0) 			this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
	if (blob.get_u16("mana")>0) 			this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
	if (blob.get_u16("maxmana")>0) 			this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
	if (blob.get_f32("critchance")>0) 		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
	if (blob.get_f32("damagebuff")>0) 		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
	if (blob.get_f32("dealtdamage")>0) 		this.set_f32("dealtdamage", this.get_f32("dealtdamage") - blob.get_f32("dealtdamage"));

	this.Sync("velocity", true);
	this.Sync("dodgechance", true);
	this.Sync("blockchance", true);
	this.Sync("damagereduction", true);
	this.Sync("hpregtime", true);
	this.Sync("manaregtime", true);
	this.Sync("manareg", true);
	this.Sync("mana", true);
	this.Sync("maxmana", true);
	this.Sync("critchance", true);
	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("timercheck"))
	{
		string buffs = params.read_string(); //buffnameval+buffname2val2...
		u8 timerindex = params.read_u8();

		string[] spl = buffs.split("_");

		string[] splb1; //buffname+val
		string[] splb2;
		string[] splb3;

		if (spl.length > 0) splb1 = spl[0].split("`");
		if (spl.length > 1) splb2 = spl[1].split("`");
		if (spl.length > 2) splb3 = spl[2].split("`");

		//reminder: name`type`val_
		if (splb1.length >= 3)
		{
			if (splb1[1] == "bool")
			{
				this.set_bool(splb1[0], false);
			}
			else if (splb1[1] == "u16")
			{
				this.set_u16(splb1[0], this.get_u16(splb1[0]) - parseFloat(splb1[2]));
			}
			else
			{
				if (splb1[0] == "attackspeed") DoAttackSpeedChange(this, this.get_f32("attackspeed"), false);
				this.set_f32(splb1[0], this.get_f32(splb1[0]) - parseFloat(splb1[2]));
			}
			this.Sync(splb1[0], true);
		}
		if (splb2.length >= 3)
		{
			if (splb2[1] == "bool")
			{
				this.set_bool(splb2[0], false);
			}
			else if (splb2[1] == "u16")
			{
				this.set_u16(splb2[0], this.get_u16(splb2[0]) - parseFloat(splb2[2]));
			}
			else
			{
				if (splb2[0] == "attackspeed") DoAttackSpeedChange(this, this.get_f32("attackspeed"), false);
				this.set_f32(splb2[0], this.get_f32(splb2[0]) - parseFloat(splb2[2]));
			}
			this.Sync(splb2[0], true);
		}
		if (splb3.length >= 3)
		{
			if (splb3[1] == "bool")
			{
				this.set_bool(splb3[0], false);
			}
			else if (splb3[1] == "u16")
			{
				this.set_u16(splb3[0], this.get_u16(splb3[0]) - parseFloat(splb3[2]));
			}
			else
			{
				if (splb3[0] == "attackspeed") DoAttackSpeedChange(this, this.get_f32("attackspeed"), false);
				this.set_f32(splb3[0], this.get_f32(splb3[0]) - parseFloat(splb3[2]));
			}
			this.Sync(splb3[0], true);
		}

		switch(timerindex)
		{
			case 1:
			{
				this.set_string("buffs1", "");
				this.Sync("buffs1", true);
			}
			case 2:
			{
				this.set_string("buffs2", "");
				this.Sync("buffs2", true);
			}
			case 3:
			{
				this.set_string("buffs3", "");
				this.Sync("buffs3", true);
			}
			case 4:
			{
				this.set_string("buffs4", "");
				this.Sync("buffs4", true);
			}
			case 5:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs5", true);
			}
			case 6:
			{
				this.set_string("buffs6", "");
				this.Sync("buffs6", true);
			}
			case 7:
			{
				this.set_string("buffs7", "");
				this.Sync("buffs7", true);
			}
			case 8:
			{
				this.set_string("buffs8", "");
				this.Sync("buffs8", true);
			}
			case 9:
			{
				this.set_string("buffs9", "");
				this.Sync("buffs9", true);
			}
			case 10:
			{
				this.set_string("buffs10", "");
				this.Sync("buffs10", true);
			}
		}
		this.Untag("potioned");
	}
	else if (cmd == this.getCommandID("receive_effect"))
	{
		u16 eff = params.read_u16();
		if (eff == 2)
		{
			this.set_bool("poisoned", true);
			this.Sync("poisoned", true);
			SetToFreeSlot(this, "2_poison", "poisoned`bool`true", XORRandom(600)+900);
		}
		else if (eff == 3)
		{
			this.set_bool("bleeding", true);
			this.Sync("bleeding", true);
			SetToFreeSlot(this, "3_bleed", "bleeding`bool`true", XORRandom(300)+300);
		}
		else if (eff == 4)
		{
			this.set_bool("regen", true);
			this.Sync("regen", true);
			SetToFreeSlot(this, "4_regen", "regen`bool`true", XORRandom(1200)+900);
		}
	}
	else if (cmd == this.getCommandID("unequiphelmet"))
	{
		if (this !is null)
		{
			if (this.get_bool("hashelmet"))
            {
                if (isServer())
                {
                	CBlob@ blob = server_CreateBlob(this.get_string("helmetname"), this.getTeamNum(), this.getPosition());
					this.set_bool("hashelmet", false);
	       			this.set_string("helmetname", "");
					
					UpdateStats(this, blob);
				}
            }
		}
	}
	else if (cmd == this.getCommandID("unequiparmor"))
	{
		if (this !is null)
		{
			if (this.get_bool("hasarmor"))
            {
                if (isServer())
                {
                	CBlob@ blob = server_CreateBlob(this.get_string("armorname"), this.getTeamNum(), this.getPosition());
					this.set_bool("hasarmor", false);
	       			this.set_string("armorname", "");

					UpdateStats(this, blob);
				}
            }
		}
	}
	else if (cmd == this.getCommandID("unequipgloves"))
	{
		if (this !is null)
		{
			if (this.get_bool("hasgloves"))
            {
                if (isServer())
                {
                	CBlob@ blob = server_CreateBlob(this.get_string("glovesname"), this.getTeamNum(), this.getPosition());
					this.set_bool("hasgloves", false);
	       			this.set_string("glovesname", "");

					UpdateStats(this, blob);
				}
            }
		}
	}
	else if (cmd == this.getCommandID("unequipboots"))
	{
		if (this !is null)
		{
			if (this.get_bool("hasboots"))
            {
                if (isServer())
                {
                	CBlob@ blob = server_CreateBlob(this.get_string("bootsname"), this.getTeamNum(), this.getPosition());
					this.set_bool("hasboots", false);
	       			this.set_string("bootsname", "");

					UpdateStats(this, blob);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("get bomb"))
	{
		const u8 bombType = params.read_u8();
		if (bombType >= bombTypeNames.length)
			return;

		const string bombTypeName = bombTypeNames[bombType];
		this.Tag(bombTypeName + " done activate");
		if (hasItem(this, bombTypeName))
		{
			if (bombType == 0)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
					}
				}
			}
			else if (bombType == 1)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("waterbomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 92.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak");
						blob.set_u8("custom_hitter", Hitters::water);
                        blob.Tag("splash ray cast");

					}
				}
			}
			else
			{
				//.
			}

			SetFirstAvailableBomb(this);
		}
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		u8 type = this.get_u8("bomb type");
		int count = 0;
		while (count < bombTypeNames.length)
		{
			type++;
			count++;
			if (type >= bombTypeNames.length)
				type = 0;
			if (this.getBlobCount(bombTypeNames[type]) > 0)
			{
				this.set_u8("bomb type", type);
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else if (cmd == this.getCommandID("activate/throw"))
	{
		SetFirstAvailableBomb(this);
	}
	else
	{
		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + bombTypeNames[i]))
			{
				this.set_u8("bomb type", i);
				break;
			}
		}
	}
}

/////////////////////////////////////////////////

bool isJab(f32 damage)
{
	return damage < 1.5f;
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, KnightInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = isJab(damage);

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (knight_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				knight_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;

					if (XORRandom(100) < this.get_f32("critchance"))
					{
						this.server_Hit(b, hi.hitpos, velocity, (damage + this.get_f32("damagebuff"))*2, type, true);
						Sound::Play("AnimeSword.ogg", this.getPosition(), 1.3f);
						this.set_f32("dealtdamage", (damage + this.get_f32("damagebuff"))*2);
					}
					else
					{
						this.server_Hit(b, hi.hitpos, velocity, damage + this.get_f32("damagebuff"), type, true);  // server_Hit() is server-side only
						this.set_f32("dealtdamage", damage + this.get_f32("damagebuff"));
					}

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool isSliding(KnightInfo@ knight)
{
	return (knight.slideTime > 0 && knight.slideTime < 45);
}

// shieldbash

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	const bool onground = this.isOnGround();
	if (this.getShape().vellen > SHIELD_KNOCK_VELOCITY || onground)
	{
		KnightInfo@ knight;
		if (!this.get("knightInfo", @knight))
		{
			return;
		}

		//printf("knight.stat " + knight.state );
		if (knight.state == KnightStates::shielddropping &&
		        (!onground || isSliding(knight)) &&
		        (blob.getShape() !is null && !blob.getShape().isStatic()) &&
		        getKnocked(blob) == 0)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getOldVelocity();
			vel.Normalize();

			//printf("nor " + vel * normal );
			if (vel * normal < 0.0f && knight_hit_actor_count(this) == 0) //only bash one thing per tick
			{
				ShieldVars@ shieldVars = getShieldVars(this);
				//printf("shi " + shieldVars.direction * normal );
				if (shieldVars.direction * normal < 0.0f)
				{
					knight_add_actor_limit(this, blob);
					this.server_Hit(blob, pos, vel, 0.0f, Hitters::shield);

					Vec2f force = Vec2f(shieldVars.direction.x * this.getMass(), -this.getMass()) * 3.0f;

					blob.AddForce(force);
					this.AddForce(Vec2f(-force.x, force.y));
				}
			}
		}
	}
}


//a little push forward

void pushForward(CBlob@ this, f32 normalForce, f32 pushingForce, f32 verticalForce)
{
	f32 facing_sign = this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	    (facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	    (facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force = normalForce;

	if (pushing_in_facing_direction)
	{
		force = pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign , verticalForce));
}

//bomb management

bool hasItem(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		return hasRequirements(inv, reqs, missing);
	}
	else
	{
		warn("our inventory was null! KnightLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this, const string &in name)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		if (hasRequirements(inv, reqs, missing))
		{
			server_TakeRequirements(inv, reqs);
		}
		else
		{
			warn("took a bomb even though we dont have one! KnightLogic.as");
		}
	}
	else
	{
		warn("our inventory was null! KnightLogic.as");
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	if (customData == Hitters::sword &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            knight.state == KnightStates::sword_cut_mid ||
	            knight.state == KnightStates::sword_cut_mid_down ||
	            knight.state == KnightStates::sword_cut_up ||
	            knight.state == KnightStates::sword_cut_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 5);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}

	if (this.get_bool("silence"))
	{
		this.set_bool("silence", false);
		this.set_u16("timer"+(getSkillPosition(this, this.getName(), 0)+1), 1);
	}
}

u8 getSkillPosition(CBlob@ this, string pclass, u16 ski) // move to skills.as later
{
    for (int i = 0; i < 11; i++)
    {
        if (this.get_u16("skillidx"+i) == ski)
			return this.get_u8("skillpos"+i);
    }
	return 255;
}

// bomb pick menu

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (bombTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(bombTypeNames.length, 2), getTranslatedString("Current bomb"));
	u8 weaponSel = this.get_u8("bomb type");

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			string matname = bombTypeNames[i];
			CGridButton @button = menu.AddButton(bombIcons[i], getTranslatedString(bombNames[i]), this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = this.getBlobCount(bombTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;
				if (weaponSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		if (attached.getName() == bombTypeNames[i])
		{
			this.set_u8("bomb type", i);
			break;
		}
	}

	if (!ap.socket) {
		KnightInfo@ knight;
		if (!this.get("knightInfo", @knight))
		{
			return;
		}

		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.doubleslash = false;
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
	if (this.isMyPlayer() && this.getInventory().getItemsCount() > 1)
	{
		for (uint j = 1; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				SetHelp(this, "help inventory", "knight", "$Help_Bomb1$$Swap$$Help_Bomb2$         $KEY_TAP$$KEY_F$", "", 2);
				break;
			}
		}
	}

	if (this.getInventory().getItemsCount() == 0 || itemname == "mat_bombs")
	{
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				this.set_u8("bomb type", j);
				return;
			}
		}
	}
}

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type = 255;
	if (this.exists("bomb type"))
		type = this.get_u8("bomb type");

	CInventory@ inv = this.getInventory();

	bool typeReal = (uint(type) < bombTypeNames.length);
	if (typeReal && inv.getItem(bombTypeNames[type]) !is null)
		return;

	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		const string itemname = inv.getItem(i).getName();
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				type = j;
				break;
			}
		}

		if (type != 255)
			break;
	}

	this.set_u8("bomb type", type);
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
