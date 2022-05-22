#include "Level.as";

shared class InitKnightStats
{
    f32 velocity = 2.5;
    f32 blockchance = 0; // %
    f32 critchance = 0; // %
    f32 damagereduction = 0.05;
    f32 hpregtime = 20*30;
    u16 hpregtimer = 20*30;
    f32 manaregtime = 20*30;
    u16 manaregtimer = 20*30;
    u16 manareg = 20;
    u16 mana = 115;
    u16 maxmana = 115;
    f32 damagebuff = 0;
    f32 vampirism = 0; // % from 0 to 1
    f32 attackspeed = 0;
    bool glowness = false;
    bool glowness2 = false;
    f32 gravityresist = 0; // 15 max
    f32 bashchance = 0; // %
};

shared class InitArcherStats
{
    f32 velocity = 2.5;
    f32 dodgechance = 1.5; // %
    f32 critchance = 7.5; // %
    f32 damagereduction = 0.05;
    f32 hpregtime = 20*30;
    u16 hpregtimer = 20*30;
    f32 manaregtime = 20*30;
    u16 manaregtimer = 20*30;
    u16 manareg = 15;
    u16 mana = 80;
    u16 maxmana = 80;
    f32 damagebuff = 0;
    f32 vampirism = 0; // % from 0 to 1
    f32 attackspeed = 0;
    bool glowness = false;
    bool glowness2 = false;
    f32 gravityresist = 0; // 15 max
    f32 bashchance = 0; // %
    f32 stabdmg = 1.0;
};

shared class InitRogueStats
{
    f32 velocity = 2.5;
    f32 dodgechance = 5.0; // %
    f32 critchance = 5.0; // %
    f32 damagereduction = 0.05;
    f32 hpregtime = 20*30;
    u16 hpregtimer = 20*30;
    f32 manaregtime = 20*30;
    u16 manaregtimer = 20*30;
    u16 manareg = 15;
    u16 mana = 65;
    u16 maxmana = 65;
    f32 damagebuff = 0;
    f32 vampirism = 0; // % from 0 to 1
    f32 attackspeed = 0;
    bool glowness = false;
    bool glowness2 = false;
    f32 gravityresist = 0; // 15 max
    f32 bashchance = 0; // %
};

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
		if (caller.get_bool("hasweapon") && ctrl)
		{
			CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("weaponname")+"$", Vec2f(-5, -5), this, this.getCommandID("unequipweapon"), getTranslatedString("Unequip weapon"), params);
		}
		if (caller.get_bool("hassecondaryweapon") && ctrl)
		{
			CBitStream params;
		    caller.CreateGenericButton("$"+this.get_string("secondaryweaponname")+"$", Vec2f(5, -5), this, this.getCommandID("unequipsecondaryweapon"), getTranslatedString("Unequip secondary weapon"), params);
		}
	}
}

void RPGInit(CBlob@ this)
{
	//armor/weapons check
	this.set_bool("hasarmor", false);
	this.set_string("armorname", "");

	this.set_bool("hasboots", false);
	this.set_string("bootsname", "");

	this.set_bool("hasgloves", false);
	this.set_string("glovesname", "");

	this.set_bool("hashelmet", false);
	this.set_string("helmetname", "");

	//skills stuff
	this.set_u8("stimer", 0);

	//hunger&thirst
	this.set_u8("hunger", 0);
	this.set_u8("thirst", 0);

	//other
	this.set_bool("poisoned", false);
	this.set_bool("bleeding", false);
	this.set_u8("bleedmodifier", 1);
	this.set_bool("regen", false);

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
}

void RPGUpdate(CBlob@ this)
{
	//prevent rotating with buttons when trying to unequip an item
	CControls@ controls = this.getControls();
	bool ctrl;
	bool e;
	if (controls !is null)
	{
		ctrl = controls.isKeyPressed(KEY_LCONTROL);
		e = controls.isKeyPressed(KEY_KEY_E);
	}
	if (ctrl && e && this.isFacingLeft()) this.SetFacingLeft(false);

	//admin command
	if(this.isKeyJustPressed(key_action1) && this.hasTag("tp"))
	{
		this.setPosition(this.getAimPos());
		this.setVelocity(Vec2f(0,0));
	}
	if (getGameTime()%150==0) 
	{
		//printf(""+this.get_f32("blockchance"));
		//printf(""+this.get_u16("timer1"));
		//printf(""+this.get_string("eff1"));
		//printf(""+this.get_string("buffs1"));
		//printf(""+this.get_u16("timer2"));
		//printf(this.get_string("skill1"));
		//printf(this.get_string("skill2"));
		//printf(this.get_string("skill3"));
	}
	if (controls !is null && this.getTickSinceCreated() >= 5)
	{
		if (controls.isKeyJustReleased(KEY_KEY_G))
		{
			ActivateSkill(this, 1);
		}
		else if (controls.isKeyJustReleased(KEY_KEY_H))
		{
			ActivateSkill(this, 2);
		}
	}
	CPlayer@ player = this.getPlayer();
	//soundtracks
	if (getGameTime() % 150 == 0 && this.getName() != "archer"
    && player !is null && !player.hasTag("disablesoundtracks")) // every 5 seconds check
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
		if (posy > this.getMap().tilemapheight*8/3
		&& (tile.type == CMap::tile_inferno_ash_back
		|| tile.type == CMap::tile_inferno_ash_back_d0
		|| tile.type == CMap::tile_inferno_ash_back_d1
        || tile.type == CMap::tile_inferno_castle_back_d0
		|| tile.type == CMap::tile_inferno_castle_back_d1
		|| tile.type == CMap::tile_inferno_ash_back_d2
		|| tile.type == CMap::tile_inferno_ash_back_d3
        || tile.type == CMap::tile_inferno_castle_back_d2
		|| tile.type == CMap::tile_inferno_castle_back_d3
		|| tile.type == CMap::tile_inferno_ash_back_d4
		|| tile.type == CMap::tile_inferno_ash_back_d5
		|| tile.type == CMap::tile_inferno_ash_back_d6
		|| tile.type == CMap::tile_inferno_ash_back_d7
		|| tile.type == CMap::tile_inferno_ash_back_d8
		|| tile.type == CMap::tile_inferno_castle_back
		|| tile.type == CMap::tile_inferno_castle_back_d4
		|| tile.type == CMap::tile_inferno_castle_back_d5
		|| tile.type == CMap::tile_inferno_castle_back_d6
		|| tile.type == CMap::tile_inferno_castle_back_d7
		|| tile.type == CMap::tile_inferno_castle_back_d8))
		{
			if (isClient() && this.isMyPlayer() && XORRandom(20) < 1
			&& this.get_string("track") != "Inferno_1.ogg"
			&& this.get_string("track") != "Inferno_2.ogg"
			&& this.get_string("track") != "Inferno_3.ogg") // 5% chance every 5 sec
			{
				u8 random = XORRandom(10);
				if (random < 3)
				{
					sprite.SetEmitSound("Inferno_1.ogg");
					sprite.SetEmitSoundVolume(0.25f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Inferno_1.ogg");
					this.set_u32("tracktimer", 285*30 + 300); // 4.85 min + cd check
				}
				else if (random >= 3 && XORRandom(10) < 6)
				{
					sprite.SetEmitSound("Inferno_2.ogg");
					sprite.SetEmitSoundVolume(0.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Inferno_2.ogg");
					this.set_u32("tracktimer", 225*30 + 300); // 3.85 min + cd check
				}
				else if (random >= 6)
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
		else if (tile.type == CMap::tile_abyss_dirt_back
		|| tile.type == CMap::tile_abyss_dirt_back_d0
		|| tile.type == CMap::tile_abyss_dirt_back_d1
		|| tile.type == CMap::tile_abyss_dirt_back_d2)
		{
			if (isClient() && this.isMyPlayer() && XORRandom(20) < 1
			&& this.get_string("track") != "Abyss_1.ogg"
			&& this.get_string("track") != "Abyss_2(HK-OST).ogg") // 5% chance every 5 sec
			{
				if (XORRandom(10) < 5)
				{
					sprite.SetEmitSound("Abyss_1.ogg");
					sprite.SetEmitSoundVolume(0.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Abyss_1.ogg");
					this.set_u32("tracktimer", 150*30 + 300); // 2.5 min + cd check
				}
				else
				{
					sprite.SetEmitSound("Abyss_2(HK-OST).ogg");
					sprite.SetEmitSoundVolume(1.5f);
					sprite.SetEmitSoundPaused(false);
					this.set_string("track", "Abyss_2(HK-OST).ogg");
					this.set_u32("tracktimer", 930*30 + 300); // 15.5 min + cd check
				}
			}
		}
		else if (XORRandom(20) < 0 // remove soundtrack if out, 5% chance
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
		//printf(this.get_string("track"));

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
		|| this.get_f32("attackspeed") > 10
		|| lengthie.length >= 8) this.set_f32("attackspeed", 0);
	}

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
	if (getGameTime() % 60 == 0 && this.hasTag("ded"))
	{
		if (this.getSprite() !is null) this.getSprite().PlaySound("MigrantScream1.ogg");
		if (isServer()) this.server_Die();
	}

	if (getGameTime() % 60 == 0 && !this.get_bool("bleeding")) this.set_u8("bleedmodifier", 1);
    if (this.get_u16("mana") > this.get_u16("maxmana")) this.set_u16("mana", this.get_u16("maxmana"));
	
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
			if (this.isMyPlayer()) SetScreenFlash(125, 255, 0, 0, 0.75f);
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
		if (this.get_u16("hpregtimer") == 0 && this.getHealth() < this.getInitialHealth())
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

	if (getGameTime() % 30 == 0)
	{
		if (this.get_u16("hpregtimer") > 0) this.set_u16("hpregtimer", this.get_u16("hpregtimer") - 30);
		if (this.get_u16("manaregtimer") > 0) this.set_u16("manaregtimer", this.get_u16("manaregtimer") - 30);
		if (this.get_u16("hpregtimer") < 0 || this.get_u16("hpregtimer") > 30000) this.set_u16("hpregtimer", 0);
		if (this.get_u16("manaregtimer") < 0 || this.get_u16("manaregtimer") > 30000) this.set_u16("manaregtimer", 0);
		
		//CPlayer@ player = this.getPlayer();
		//if (player is null || player.isMyPlayer()) return;
		
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
	if (getGameTime() % 300 == 0 && this.getTickSinceCreated() >= 750) // 25 sec
	{
		if (XORRandom(11) <= 5 && this.getVelocity().x == 0) return; // if player is not moving, with some chance (5 to 10)

		if (this.get_u8("thirst") < 100) this.set_u8("thirst", this.get_u8("thirst") + 1);
		else if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.5f,  Hitters::stab);
		
		if (this.get_u8("hunger") < 100) this.set_u8("hunger", this.get_u8("hunger") + 1);
		else if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.5f,  Hitters::stab);

		this.Sync("hunger", true);
		this.Sync("thirst", true);
	}
}

void RPGUpdateKnightSets(CBlob@ this)
{
    //set buffs
	if (this.get_string("armorname") == "iron_chestplate"
	&& this.get_string("helmetname") == "iron_helmet"
	&& this.get_string("glovesname") == "iron_gloves"
	&& this.get_string("bootsname") == "iron_boots")
	{
		this.Tag("ironset");
	}
	else this.Untag("ironset");

	if (this.hasTag("ironset") && !this.get_bool("hasironset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.2);
		this.set_bool("hasironset", true);
	}
	else if (!this.hasTag("ironset") && this.get_bool("hasironset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.2);
		this.set_bool("hasironset", false);
	}

	if (this.get_string("armorname") == "steel_chestplate"
	&& this.get_string("helmetname") == "steel_helmet"
	&& this.get_string("glovesname") == "steel_gloves"
	&& this.get_string("bootsname") == "steel_boots")
	{
		this.Tag("steelset");
	}
	else this.Untag("steelset");

	if (this.hasTag("steelset") && !this.get_bool("hassteelset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("hassteelset", true);
	}
	else if (!this.hasTag("steelset") && this.get_bool("hassteelset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("hassteelset", false);
	}
	
	if (this.get_string("armorname") == "golden_chestplate"
	&& this.get_string("helmetname") == "golden_helmet"
	&& this.get_string("glovesname") == "golden_gloves"
	&& this.get_string("bootsname") == "golden_boots")
	{
		this.Tag("goldenset");
	}
	else this.Untag("goldenset");

	if (this.hasTag("goldenset") && !this.get_bool("hasgoldenset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("hasgoldenset", true);
	}
	else if (!this.hasTag("goldenset") && this.get_bool("hasgoldenset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("hasgoldenset", false);
	}

	if (this.get_string("armorname") == "chromium_chestplate"
	&& this.get_string("helmetname") == "chromium_helmet"
	&& this.get_string("glovesname") == "chromium_gloves"
	&& this.get_string("bootsname") == "chromium_boots")
	{
		this.Tag("chromiumset");
	}
	else this.Untag("chromiumset");

	if (this.hasTag("chromiumset") && !this.get_bool("haschromiumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("haschromiumset", true);
	}
	else if (!this.hasTag("chromiumset") && this.get_bool("haschromiumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("haschromiumset", false);
	}

	if (this.get_string("armorname") == "palladium_chestplate"
	&& this.get_string("helmetname") == "palladium_helmet"
	&& this.get_string("glovesname") == "palladium_gloves"
	&& this.get_string("bootsname") == "palladium_boots")
	{
		this.Tag("palladiumset");
	}
	else this.Untag("palladiumset");

	if (this.hasTag("palladiumset") && !this.get_bool("haspalladiumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("haspalladiumset", true);
	}
	else if (!this.hasTag("palladiumset") && this.get_bool("haspalladiumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("haspalladiumset", false);
	}

	if (this.get_string("armorname") == "platinum_chestplate"
	&& this.get_string("helmetname") == "platinum_helmet"
	&& this.get_string("glovesname") == "platinum_gloves"
	&& this.get_string("bootsname") == "platinum_boots")
	{
		this.Tag("platinumset");
	}
	else this.Untag("platinumset");

	if (this.hasTag("platinumset") && !this.get_bool("hasplatinumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("hasplatinumset", true);
	}
	else if (!this.hasTag("platinumset") && this.get_bool("hasplatinumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("hasplatinumset", false);
	}

	if (this.get_string("armorname") == "titanium_chestplate"
	&& this.get_string("helmetname") == "titanium_helmet"
	&& this.get_string("glovesname") == "titanium_gloves"
	&& this.get_string("bootsname") == "titanium_boots")
	{
		this.Tag("titaniumset");
	}
	else this.Untag("titaniumset");

	if (this.hasTag("titaniumset") && !this.get_bool("hastitaniumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") + 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") + 0.25);
		this.set_bool("hastitaniumset", true);
	}
	else if (!this.hasTag("titaniumset") && this.get_bool("hastitaniumset"))
	{
		this.set_f32("damagereduction", this.get_f32("damagereduction") - 0.35);
		this.set_f32("damagebuff", this.get_f32("damagebuff") - 0.25);
		this.set_bool("hastitaniumset", false);
	}
}

void RPGUpdateArcherRogueSets(CBlob@ this)
{
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
}

void TimerCheck(CBlob@ this, u8 index)
{
	this.set_u16("timer"+index, this.get_u16("timer"+index) - 30);

	if (this.get_u16("timer"+index) <= 1 || this.get_u16("timer"+index) > 25000) 
	{
		this.set_u16("timer"+index, 0);
		if (isServer())
		{
			CBitStream params;
			params.write_string(this.get_string("buffs"+index));
			params.write_u8(index);
			this.SendCommand(this.getCommandID("timercheck"), params);
		}
	}
	if (index > 1)
	{
		if (this.get_u16("timer"+(index-1)) <= 0)
		{
			this.set_u16("timer"+(index-1), this.get_u16("timer"+index));
			this.Sync("timer"+(index-1), true);
			this.set_string("buffs"+(index-1), this.get_string("buffs"+index));
			this.Sync("buffs"+(index-1), true);
			this.set_string("eff"+(index-1), this.get_string("eff"+index));
			this.Sync("eff"+(index-1), true);
			this.set_u16("timer"+index, 0);
			this.Sync("timer"+index, true);
			this.set_string("buffs"+index, "");
			this.Sync("buffs"+index, true);
			this.set_string("eff"+index, "");
			this.Sync("eff"+index, true);
		}
	}
	else if (index == 1 && this.get_u16("timer1") <= 1 ) // clear
	{
		this.set_u16("timer1", 0);
		this.Sync("timer1", true);
		this.set_string("buffs1", "");
		this.Sync("buffs1", true);
		this.set_string("eff1", "");
		this.Sync("eff1", true);
		this.set_u16("timer1", 0);
		this.Sync("timer1", true);
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
		this.Sync("eff6", true);
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

void UpdateStats(CBlob@ this, string name)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;

	if (isServer()) 
	{
		CBlob@ blob = server_CreateBlob(name, this.getTeamNum(), this.getPosition());

		//if (blob !is null && player !is null)
		//{
		//	this.set_f32("velocity", this.get_f32("velocity") - blob.get_f32("velocity"));
    	//	this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
		//	this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("block"));
    	//	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
		//	if (player.isMyPlayer()) this.set_f32("hpregtime", this.get_f32("hpregtime") + (blob.get_f32("hpregtime")*-1));
		//	if (player.isMyPlayer()) this.set_f32("manaregtime", this.get_f32("manaregtime") + (blob.get_f32("manaregtime")*-1));
		//	this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
		//	this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
		//	this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
		//	this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
		//	if (player.isMyPlayer()) this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
		//	this.set_f32("vampirism", this.get_f32("vampirism") - blob.get_f32("vampirism"));
		//	this.set_f32("bashchance", this.get_f32("bashchance") - blob.get_f32("bashchance"));
//
		//	blob.Sync("velocity", true);
		//	blob.Sync("dodgechance", true);
		//	blob.Sync("blockchance", true);
		//	blob.Sync("damagereduction", true);
		//	blob.Sync("hpregtime", true);
		//	blob.Sync("manaregtime", true);
		//	blob.Sync("manareg", true);
		//	blob.Sync("mana", true);
		//	blob.Sync("maxmana", true);
		//	blob.Sync("critchance", true);
		//	blob.Sync("damagebuff", true);
		//	blob.Sync("dealtdamage", true);
		//	blob.Sync("vampirism", true);
		//	blob.Sync("bashchance", true);
		//}

		CBitStream params;
		params.write_u16(blob.getNetworkID());
		this.SendCommand(this.getCommandID("update_stats"), params);
	}
}

void onDie(CBlob@ this)
{
	//save level
	CPlayer@ player = this.getPlayer();
	CRules@ rules = getRules();
	if (player !is null)
	{
		string name = player.getUsername();
		if (player.get_u16("level") != 0)
		{
			rules.set_u16(name+"level", player.get_u16("level"));
		}
		if (player.get_u32("exp") != 0)
		{
			rules.set_u32(name+"exp", player.get_u32("exp"));
		}
	}

	CBlob@ spawn = getBlobByName("tdm_spawn"); // does not work for legendary armor
	if (spawn is null) return;
	if (!this.isOverlapping(spawn)) return;

	if (this.get_string("helmetname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("helmetname"));
			blob.setPosition(this.getPosition());
			blob.server_setTeamNum(this.getTeamNum());
			blob.Init();
		}
		this.set_string("helmetname", "");
		this.set_bool("hashelmet", false);
	}
	if (this.get_string("armorname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("armorname"));
			blob.setPosition(this.getPosition());
			blob.server_setTeamNum(this.getTeamNum());
			blob.Init();
		}
		this.set_string("armorname", "");
		this.set_bool("hasarmor", false);
	}
	if (this.get_string("glovesname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("glovesname"));
			blob.setPosition(this.getPosition());
			blob.server_setTeamNum(this.getTeamNum());
			blob.Init();
		}
		this.set_string("glovesname", "");
		this.set_bool("hasgloves", false);
	}
	if (this.get_string("bootsname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("bootsname"));
			blob.setPosition(this.getPosition());
			blob.server_setTeamNum(this.getTeamNum());
			blob.Init();
		}
		this.set_string("bootsname", "");
		this.set_bool("hasboots", false);
	}
	if (this.get_string("weaponname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("weaponname"), this.getTeamNum(), this.getPosition());
		}
		this.set_string("weaponname", "");
		this.set_bool("hasweapon", false);
	}
	if (this.get_string("secondaryweaponname") != "")
	{
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(this.get_string("secondaryweaponname"), this.getTeamNum(), this.getPosition());
		}
		this.set_string("secondaryweaponname", "");
		this.set_bool("hassecondaryweapon", false);
	}
}
