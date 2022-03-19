// Archer logic

#include "ArcherCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 20;

void onInit(CBlob@ this)
{
	ArcherInfo archer;
	this.set("archerInfo", @archer);

	this.set_s8("charge_time", 0);
	this.set_u8("charge_state", ArcherParams::not_aiming);
	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(grapple_sync_cmd);

	SetHelp(this, "help self hide", "archer", getTranslatedString("Hide    $KEY_S$"), "", 1);

	//add a command ID for each arrow type
	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID("pick " + arrowTypeNames[i]);
	}

	this.addCommandID("showdamage");
	getRules().addCommandID("showdamage");
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
    this.set_f32("dodgechance", 1.5);
    this.set_f32("damagereduction", 0.05);
	this.set_f32("hpregtime", 20*30);
	this.set_u16("hpregtimer", 20*30);
	this.set_f32("manaregtime", 15*30);
	this.set_u16("manaregtimer", 15*30);
	this.set_u16("manareg", 15);
	this.set_u16("mana", 50);
	this.set_u16("maxmana", 50);
	this.set_f32("critchance", 7.5);
	this.set_f32("damagebuff", 0);
	this.set_f32("dealtdamage", 0);
	//stab stuff
	this.set_f32("stabdmg", 0.5f);
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
	//effecttimers & buffs at their slots
	this.set_u16("timer1", 0);
	this.set_u16("timer2", 0);
	this.set_u16("timer3", 0);
	this.set_u16("timer4", 0);
	this.set_u16("timer5", 0);

	this.addCommandID("timercheck");

	this.set_string("buffs1", "");
	this.set_string("buffs2", "");
	this.set_string("buffs3", "");
	this.set_string("buffs4", "");
	this.set_string("buffs5", "");

	this.addCommandID("receive_effect");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}

void ManageGrapple(CBlob@ this, ArcherInfo@ archer)
{
	CSprite@ sprite = this.getSprite();
	u8 charge_state = archer.charge_state;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);

	// fletch arrows from tree
	if(this.isKeyPressed(key_action2)
		&& charge_state != ArcherParams::stabbing
		&& !archer.grappling
		&& this.isOnGround()
		&& !this.isKeyPressed(key_action1)
		&& !this.wasKeyPressed(key_action1))
	{
		Vec2f aimpos = this.getAimPos();
		CBlob@[] blobs;
		if(getMap().getBlobsInRadius(aimpos, 8.0f, blobs))
		{
			for (int i = 0; i < blobs.size(); i++)
			{
				CBlob@ target = blobs[i];
				string name = target.getName();

				if (target !is null && !target.isMyPlayer() && Vec2f(target.getPosition() - pos).Length() <= 28.0f)
				{
					this.set_u16("stabHitID",  target.getNetworkID());
					charge_state = ArcherParams::stabbing;
					archer.charge_time = 0;
					archer.stab_delay = 0;
					sprite.SetEmitSoundPaused(true);
					archer.charge_state = charge_state;
					break;
				}
			}

		}
	}

	if (right_click && charge_state != ArcherParams::stabbing)
	{
		// cancel charging
		if (charge_state != ArcherParams::not_aiming &&
		    charge_state != ArcherParams::fired) // allow grapple right after firing
		{
			charge_state = ArcherParams::not_aiming;
			archer.charge_time = 0;
			sprite.SetEmitSoundPaused(true);
			sprite.PlaySound("PopIn.ogg");
		}

		archer.charge_state = charge_state;
	}
}

void ManageBow(CBlob@ this, ArcherInfo@ archer, RunnerMoveVars@ moveVars)
{
	//are we responsible for this actor?
	bool ismyplayer = this.isMyPlayer();
	bool responsible = ismyplayer;
	if (isServer() && !ismyplayer)
	{
		CPlayer@ p = this.getPlayer();
		if (p !is null)
		{
			responsible = p.isBot();
		}
	}
	//
	CSprite@ sprite = this.getSprite();
	bool hasarrow = archer.has_arrow;
	bool hasnormal = hasArrows(this, ArrowType::normal);
	s8 charge_time = archer.charge_time;
	u8 charge_state = archer.charge_state;
	const bool pressed_action2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();

	if (responsible)
	{
		if ((getGameTime() + this.getNetworkID()) % 10 == 0)
		{
			hasarrow = hasArrows(this);

			if (!hasarrow && hasnormal)
			{
				// set back to default
				archer.arrow_type = ArrowType::normal;
				hasarrow = hasnormal;
			}
		}

		if (hasarrow != this.get_bool("has_arrow"))
		{
			this.set_bool("has_arrow", hasarrow);
			this.Sync("has_arrow", isServer());
		}

	}

	if (charge_state == ArcherParams::legolas_charging) // fast arrows
	{
		if (!hasarrow)
		{
			charge_state = ArcherParams::not_aiming;
			charge_time = 0;
		}
		else
		{
			charge_state = ArcherParams::legolas_ready;
		}
	}
	//charged - no else (we want to check the very same tick)
	if (charge_state == ArcherParams::legolas_ready) // fast arrows
	{
		moveVars.walkFactor *= 0.75f;

		archer.legolas_time--;
		if (!hasarrow || archer.legolas_time == 0)
		{
			bool pressed = this.isKeyPressed(key_action1);
			charge_state = pressed ? ArcherParams::readying : ArcherParams::not_aiming;
			charge_time = 0;
			//didn't fire
			if (archer.legolas_arrows == ArcherParams::legolas_arrows_count)
			{
				Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
				setKnocked(this, 15);
			}
			else if (pressed)
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}
		else if (this.isKeyJustPressed(key_action1) ||
		         (archer.legolas_arrows == ArcherParams::legolas_arrows_count &&
		          !this.isKeyPressed(key_action1) &&
		          this.wasKeyPressed(key_action1)))
		{
			ClientFire(this, charge_time, hasarrow, archer.arrow_type, true);
			charge_state = ArcherParams::legolas_charging;
			charge_time = ArcherParams::shoot_period - ArcherParams::legolas_charge_time;
			Sound::Play("FastBowPull.ogg", pos);
			archer.legolas_arrows--;

			if (archer.legolas_arrows == 0)
			{
				charge_state = ArcherParams::not_aiming;
				charge_time = 5;

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}

	}
	else if (this.isKeyPressed(key_action1))
	{
		if (this.getCarriedBlob() !is null && this.getCarriedBlob().getName() == "drill") return;
		moveVars.walkFactor *= 0.75f;
		moveVars.canVault = false;

		const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
		        (charge_state == ArcherParams::not_aiming || charge_state == ArcherParams::fired || charge_state == ArcherParams::stabbing))
		{
			charge_state = ArcherParams::readying;
			hasarrow = hasArrows(this);

			if (!hasarrow && hasnormal)
			{
				archer.arrow_type = ArrowType::normal;
				hasarrow = hasnormal;

			}

			if (responsible)
			{
				this.set_bool("has_arrow", hasarrow);
				this.Sync("has_arrow", isServer());
			}

			charge_time = 0;

			if (!hasarrow)
			{
				charge_state = ArcherParams::no_arrows;

				if (ismyplayer && !this.wasKeyPressed(key_action1))   // playing annoying no ammo sound
				{
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}

			}
			else
			{
				if (ismyplayer)
				{
					if (just_action1)
					{
						const u8 type = archer.arrow_type;

						if (type == ArrowType::water)
						{
							sprite.PlayRandomSound("/WaterBubble");
						}
						else if (type == ArrowType::fire)
						{
							sprite.PlaySound("SparkleShort.ogg");
						}
					}
				}

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);

				if (!ismyplayer)   // lower the volume of other players charging  - ooo good idea
				{
					sprite.SetEmitSoundVolume(0.5f);
				}
			}
		}
		else if (charge_state == ArcherParams::readying)
		{
			charge_time++;

			if (charge_time > ArcherParams::ready_time)
			{
				charge_time = 1;
				charge_state = ArcherParams::charging;
			}
		}
		else if (charge_state == ArcherParams::charging)
		{
			if(!hasarrow)
			{
				charge_state = ArcherParams::no_arrows;
				charge_time = 0;
				
				if (ismyplayer)   // playing annoying no ammo sound
				{
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}
			}
			else
			{
				charge_time++;
			}

			if (charge_time >= ArcherParams::legolas_period)
			{
				// Legolas state

				Sound::Play("AnimeSword.ogg", pos, ismyplayer ? 1.3f : 0.7f);
				Sound::Play("FastBowPull.ogg", pos);
				charge_state = ArcherParams::legolas_charging;
				charge_time = ArcherParams::shoot_period - ArcherParams::legolas_charge_time;

				archer.legolas_arrows = ArcherParams::legolas_arrows_count;
				archer.legolas_time = ArcherParams::legolas_time;
			}

			if (charge_time >= ArcherParams::shoot_period)
			{
				sprite.SetEmitSoundPaused(true);
			}
		}
		else if (charge_state == ArcherParams::no_arrows)
		{
			if (charge_time < ArcherParams::ready_time)
			{
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > ArcherParams::readying)
		{
			if (charge_state < ArcherParams::fired)
			{
				ClientFire(this, charge_time, hasarrow, archer.arrow_type, false);

				charge_time = ArcherParams::fired_time;
				charge_state = ArcherParams::fired;
			}
			else if(charge_state == ArcherParams::stabbing)
			{
				archer.stab_delay++;
				if (archer.stab_delay == STAB_DELAY)
				{
					// hit tree and get an arrow
					CBlob@ stabTarget = getBlobByNetworkID(this.get_u16("stabHitID"));
					if (stabTarget !is null && !stabTarget.isMyPlayer() && stabTarget.getName() != "archer")
					{
						//printf(""+stabTarget.getName());
						if (stabTarget.getName() == "mat_wood")
						{
							u16 quantity = stabTarget.getQuantity();
							if (quantity > 4)
							{
								stabTarget.server_SetQuantity(quantity-4);
							}
							else
							{
								stabTarget.server_Die();

							}
						}
						else
						{
							if (XORRandom(100) < this.get_f32("critchance"))
							{
								this.server_Hit(stabTarget, stabTarget.getPosition(), Vec2f_zero, (this.get_f32("stabdmg") + this.get_f32("damagebuff"))*2,  Hitters::stab);
								Sound::Play("AnimeSword.ogg", this.getPosition(), 1.3f);
								this.set_f32("dealtdamage", (this.get_f32("stabdmg") + this.get_f32("damagebuff"))*2);
							}
							else
							{
								this.server_Hit(stabTarget, stabTarget.getPosition(), Vec2f_zero, this.get_f32("stabdmg") + this.get_f32("damagebuff"),  Hitters::stab);
								Sound::Play("SwordSheath.ogg", this.getPosition(), 1.3f);
								this.set_f32("dealtdamage", this.get_f32("stabdmg") + this.get_f32("damagebuff"));
							}
						}
					}
				}
				else if(archer.stab_delay >= STAB_TIME)
				{
					charge_state = ArcherParams::not_aiming;
				}
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0)
				{
					charge_state = ArcherParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else
		{
			charge_state = ArcherParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused(true);
	}

	// safe disable bomb light

	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1))
	{
		const u8 type = archer.arrow_type;
		if (type == ArrowType::bomb)
		{
			BombFuseOff(this);
		}
	}

	// my player!

	if (responsible)
	{
		// set cursor

		if (ismyplayer && !getHUD().hasButtons())
		{
			int frame = 0;
			//	print("archer.charge_time " + archer.charge_time + " / " + ArcherParams::shoot_period );
			if (archer.charge_state == ArcherParams::readying)
			{
				//readying shot
				frame = 2 + int((float(archer.charge_time) / float(ArcherParams::shoot_period + ArcherParams::ready_time)) * 8) * 2.0f;
			}
			else if (archer.charge_state == ArcherParams::charging)
			{
				if (archer.charge_time < ArcherParams::shoot_period)
				{
					//charging shot
					frame = 2 + int((float(ArcherParams::ready_time + archer.charge_time) / float(ArcherParams::shoot_period + ArcherParams::ready_time)) * 8) * 2;
				}
				else
				{
					//charging legolas
					frame = 1 + int((float(archer.charge_time - ArcherParams::shoot_period) / (ArcherParams::legolas_period - ArcherParams::shoot_period)) * 9) * 2;
				}
			}
			else if (archer.charge_state == ArcherParams::legolas_ready)
			{
				//legolas ready
				frame = 19;
			}
			else if (archer.charge_state == ArcherParams::legolas_charging)
			{
				//in between shooting multiple legolas shots
				frame = 1;
			}
			getHUD().SetCursorFrame(frame);
		}

		// activate/throw

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}

		// pick up arrow

		if (archer.fletch_cooldown > 0)
		{
			archer.fletch_cooldown--;
		}

		// pickup from ground

		if (archer.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
		{
			if (getPickupArrow(this) !is null)   // pickup arrow from ground
			{
				this.SendCommand(this.getCommandID("pickup arrow"));
				archer.fletch_cooldown = PICKUP_COOLDOWN;
			}
		}
	}

	archer.charge_time = charge_time;
	archer.charge_state = charge_state;
	archer.has_arrow = hasarrow;

}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_CreateBlob(this.get_string("armorname"), this.getTeamNum(), this.getPosition());
		server_CreateBlob(this.get_string("helmetname"), this.getTeamNum(), this.getPosition());
		server_CreateBlob(this.get_string("bootsname"), this.getTeamNum(), this.getPosition());
		server_CreateBlob(this.get_string("glovesname"), this.getTeamNum(), this.getPosition());
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

void onTick(CBlob@ this)
{
	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);
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

	
	if (this.isKeyPressed(key_action1) && this.get_u16("mana") > 0)
	{
		if (getGameTime() % 10 == 0)
		{
			if (this.getCarriedBlob() !is null)
				if (this.getCarriedBlob().getName() == "drill")
					return;
			this.set_u16("mana", this.get_u16("mana") - 1);
		}
	}
	else if (this.isKeyPressed(key_action1))
	{
		if (getGameTime() % 23 == 0) 
		{
			setKnocked(this, 20);
			Sound::Play("/Stun", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}

	if (this.get_u16("mana") > this.get_u16("maxmana")) this.set_u16("mana", this.get_u16("maxmana"));

	//debuffs
	if (getGameTime() % 150 == 0 && this.get_bool("poisoned"))
	{
		if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.5f,  Hitters::stab);
	}
	if (getGameTime() % 75 == 0 && this.get_bool("bleeding"))
	{
		if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0,0), this.get_u8("bleedmodifier") * 0.1f, Hitters::stab);
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
	//regen
	this.Sync("hpregtime", true);
	this.Sync("manaregtime", true);
	if (this !is null && this.get_f32("hpregtime") > 0)
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

	if (getGameTime() % 30 == 0)
	{
		if (this.get_u16("hpregtimer") > 0) this.set_u16("hpregtimer", this.get_u16("hpregtimer") - 30);
		if (this.get_u16("manaregtimer") > 0) this.set_u16("manaregtimer", this.get_u16("manaregtimer") - 30);
		if (this.get_u16("hpregtimer") < 0) this.set_u16("hpregtimer", 0);
		if (this.get_u16("manaregtimer") < 0) this.set_u16("manaregtimer", 0);

		//stat timers
		if (this.get_u16("timer1") > 0)
		{
			this.set_u16("timer1", this.get_u16("timer1") - 30);
			if (this.get_u16("timer1") <= 3 || this.get_u16("timer1") > 25000) 
			{
				this.set_u16("timer1", 0);
				CBitStream params;
				params.write_string(this.get_string("buffs1"));
				params.write_u8(1);
				this.SendCommand(this.getCommandID("timercheck"), params);
			}
		}
		if (this.get_u16("timer2") > 0)
		{
			this.set_u16("timer2", this.get_u16("timer2") - 30);
			if (this.get_u16("timer2") <= 3 || this.get_u16("timer2") > 25000)
			{
				this.set_u16("timer2", 0);
				CBitStream params;
				params.write_string(this.get_string("buffs2"));
				params.write_u8(2);
				this.SendCommand(this.getCommandID("timercheck"), params);
			}
			if (this.get_u16("timer1") <= 0)
			{
				this.set_u16("timer1", this.get_u16("timer2"));
				this.set_string("buffs1", this.get_string("buffs2"));
				this.set_string("eff1", this.get_string("eff2"));
				this.set_u16("timer2", 0);
				this.set_string("buffs2", "");
				this.set_string("eff2", "");
			}
		}
		if (this.get_u16("timer3") > 0)
		{
			this.set_u16("timer3", this.get_u16("timer3") - 30);
			if (this.get_u16("timer3") <= 3 || this.get_u16("timer3") > 25000)
			{
				this.set_u16("timer3", 0);
				CBitStream params;
				params.write_string(this.get_string("buffs3"));
				params.write_u8(3);
				this.SendCommand(this.getCommandID("timercheck"), params);
			}
			if (this.get_u16("timer2") <= 0)
			{
				this.set_u16("timer2", this.get_u16("timer3"));
				this.set_string("buffs2", this.get_string("buffs3"));
				this.set_string("eff2", this.get_string("eff3"));
				this.set_u16("timer3", 0);
				this.set_string("buffs3", "");
				this.set_string("eff3", "");
			}
		}
		if (this.get_u16("timer4") > 0)
		{
			this.set_u16("timer4", this.get_u16("timer4") - 30);
			if (this.get_u16("timer4") <= 3 || this.get_u16("timer4") > 25000)
			{
				this.set_u16("timer4", 0);
				CBitStream params;
				params.write_string(this.get_string("buffs4"));
				params.write_u8(4);
				this.SendCommand(this.getCommandID("timercheck"), params);
			}
			if (this.get_u16("timer3") <= 0)
			{
				this.set_u16("timer3", this.get_u16("timer4"));
				this.set_string("buffs3", this.get_string("buffs4"));
				this.set_string("eff3", this.get_string("eff4"));
				this.set_u16("timer4", 0);
				this.set_string("buffs4", "");
				this.set_string("eff4", "");
			}
		}
		if (this.get_u16("timer5") > 0)
		{
			this.set_u16("timer5", this.get_u16("timer5") - 30);
			if (this.get_u16("timer5") <= 3 || this.get_u16("timer5") > 25000)
			{
				this.set_u16("timer5", 0);
				CBitStream params;
				params.write_string(this.get_string("buffs5"));
				params.write_u8(5);
				this.SendCommand(this.getCommandID("timercheck"), params);
			}
			if (this.get_u16("timer4") <= 0)
			{
				this.set_u16("timer4", this.get_u16("timer5"));
				this.set_string("buffs4", this.get_string("buffs5"));
				this.set_string("eff4", this.get_string("eff5"));
				this.set_u16("timer5", 0);
				this.set_string("buffs5", "");
				this.set_string("eff5", "");
			}
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

	bool knocked = isKnocked(this);
	CHUD@ hud = getHUD();

	//get the vars to turn various other scripts on/off

	if (!this.get("moveVars", @moveVars))
	{
		return;
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
		moveVars.walkSpeed = 2.6f;
		moveVars.walkSpeedInAir = 2.5f;
	}

	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}

	if (isKnocked(this) || this.isInInventory())
	{
		archer.grappling = false;
		archer.charge_state = 0;
		archer.charge_time = 0;
		this.getSprite().SetEmitSoundPaused(true);
		getHUD().SetCursorFrame(0);
		return;
	}

	ManageGrapple(this, archer);

	//print("state before: " + archer.charge_state);

	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageBow(this, archer, moveVars);

	//print("state after: " + archer.charge_state);
}

bool checkGrappleStep(CBlob@ this, ArcherInfo@ archer, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(archer.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			archer.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(archer, map, dist))
	{
		archer.grapple_id = 0;

		archer.grapple_ratio = Maths::Max(0.2, Maths::Min(archer.grapple_ratio, dist / archer_grapple_length));

		archer.grapple_pos.y = Maths::Max(0.0, archer.grapple_pos.y);

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(archer.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (archer.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					archer.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic() && !b.hasTag("ignore_arrow"))
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				archer.grapple_ratio = Maths::Max(0.2, Maths::Min(archer.grapple_ratio, b.getDistanceTo(this) / archer_grapple_length));

				archer.grapple_id = b.getNetworkID();
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(ArcherInfo@ archer, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(archer.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(archer.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(archer.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(archer.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(archer.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, ArcherInfo@ archer, CMap@ map)
{
	return !grappleHitMap(archer, map) || this.isKeyPressed(key_use);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasarrow, const u8 arrow_type, const bool legolas)
{
	//time to fire!
	if (hasarrow && canSend(this))  // client-logic
	{
		f32 arrowspeed;

		if (charge_time < ArcherParams::ready_time / 2 + ArcherParams::shoot_period_1)
		{
			arrowspeed = ArcherParams::shoot_max_vel * (1.0f / 3.0f);
		}
		else if (charge_time < ArcherParams::ready_time / 2 + ArcherParams::shoot_period_2)
		{
			arrowspeed = ArcherParams::shoot_max_vel * (4.0f / 5.0f);
		}
		else
		{
			arrowspeed = ArcherParams::shoot_max_vel;
		}

		Vec2f offset(this.isFacingLeft() ? 2 : -2, -2);
		ShootArrow(this, this.getPosition() + offset, this.getAimPos(), arrowspeed, arrow_type, legolas);
	}
}

void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
	if (canSend(this))
	{
		// player or bot
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		//print("arrowspeed " + arrowspeed);
		CBitStream params;
		params.write_Vec2f(arrowPos);
		params.write_Vec2f(arrowVel);
		params.write_u8(arrow_type);
		params.write_bool(legolas);

		this.SendCommand(this.getCommandID("shoot arrow"), params);
	}
}

CBlob@ getPickupArrow(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "arrow")
			{
				return b;
			}
		}
	}
	return null;
}

bool canPickSpriteArrow(CBlob@ this, bool takeout)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("arrow") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("arrow");
					return true;
				}
			}
		}
	}
	return false;
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", arrowType);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);

		arrow.set_f32("damagebuff", this.get_f32("damagebuff"));
		arrow.set_u16("shooternetid", this.getNetworkID());

		if (XORRandom(100) < this.get_f32("critchance"))
		{
			arrow.Tag("critarrow");
		}
	}
	return arrow;
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
				this.set_f32(splb3[0], this.get_f32(splb3[0]) - parseFloat(splb3[2]));
			}
			this.Sync(splb3[0], true);
		}

		switch(timerindex)
		{
			case 1:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs1", true);
			}
			case 2:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs2", true);
			}
			case 3:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs3", true);
			}
			case 4:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs4", true);
			}
			case 5:
			{
				this.set_string("buffs5", "");
				this.Sync("buffs5", true);
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
			if (this.get_string("eff1") == "")
			{
				this.set_u16("timer1", XORRandom(900)+900);
				this.set_string("eff1", "2_poison");
				this.Sync("eff1", true); // for onRender
				this.set_string("buffs1", "poisoned`bool`true");
				this.Sync("buffs1", true);
			} 
			else if (this.get_string("eff2") == "") 
			{
				this.set_u16("timer2", XORRandom(900)+900);
				this.set_string("eff2", "2_poison");
				this.Sync("eff2", true);
				this.set_string("buffs2", "poisoned`bool`true");
				this.Sync("buffs2", true);
			}
			else if (this.get_string("eff3") == "")
			{
				this.set_u16("timer3", XORRandom(900)+900);
				this.set_string("eff3", "2_poison");
				this.Sync("eff3", true);
				this.set_string("buffs3", "poisoned`bool`true");
				this.Sync("buffs3", true);
			}
			else if (this.get_string("eff4") == "")
			{
				this.set_u16("timer4", XORRandom(900)+900);
				this.set_string("eff4", "2_poison");
				this.Sync("eff4", true);
				this.set_string("buffs4", "poisoned`bool`true");
				this.Sync("buffs4", true);
			}
			else if (this.get_string("eff5") == "")
			{
				this.set_u16("timer5", XORRandom(900)+900);
				this.set_string("eff5", "2_poison");
				this.Sync("eff5", true);
				this.set_string("buffs5", "poisoned`bool`true");
				this.Sync("buffs5", true);
			}
		}
		else if (eff == 3)
		{
			this.set_bool("bleeding", true);
			this.Sync("bleeding", true);
			if (this.get_string("eff1") == "")
			{
				this.set_u16("timer1", XORRandom(300)+300);
				this.set_string("eff1", "3_bleed");
				this.Sync("eff1", true); // for onRender
				this.set_string("buffs1", "bleeding`bool`true");
				this.Sync("buffs1", true);
			} 
			else if (this.get_string("eff2") == "") 
			{
				this.set_u16("timer2", XORRandom(300)+300);
				this.set_string("eff2", "3_bleed");
				this.Sync("eff2", true);
				this.set_string("buffs2", "bleeding`bool`true");
				this.Sync("buffs2", true);
			}
			else if (this.get_string("eff3") == "")
			{
				this.set_u16("timer3", XORRandom(300)+300);
				this.set_string("eff3", "3_bleed");
				this.Sync("eff3", true);
				this.set_string("buffs3", "bleeding`bool`true");
				this.Sync("buffs3", true);
			}
			else if (this.get_string("eff4") == "")
			{
				this.set_u16("timer4", XORRandom(300)+300);
				this.set_string("eff4", "3_bleed");
				this.Sync("eff4", true);
				this.set_string("buffs4", "bleeding`bool`true");
				this.Sync("buffs4", true);
			}
			else if (this.get_string("eff5") == "")
			{
				this.set_u16("timer5", XORRandom(300)+300);
				this.set_string("eff5", "3_bleed");
				this.Sync("eff5", true);
				this.set_string("buffs5", "bleeding`bool`true");
				this.Sync("buffs5", true);
			}
		}
		else if (eff == 4)
		{
			this.set_bool("regen", true);
			this.Sync("regen", true);
			if (this.get_string("eff1") == "")
			{
				this.set_u16("timer1", XORRandom(1200)+1800);
				this.set_string("eff1", "4_regen");
				this.Sync("eff1", true); // for onRender
				this.set_string("buffs1", "regen`bool`true");
				this.Sync("buffs1", true);
			} 
			else if (this.get_string("eff2") == "") 
			{
				this.set_u16("timer2", XORRandom(1200)+1800);
				this.set_string("eff2", "4_regen");
				this.Sync("eff2", true);
				this.set_string("buffs2", "regen`bool`true");
				this.Sync("buffs2", true);
			}
			else if (this.get_string("eff3") == "")
			{
				this.set_u16("timer3", XORRandom(1200)+1800);
				this.set_string("eff3", "3_regen");
				this.Sync("eff3", true);
				this.set_string("buffs3", "regen`bool`true");
				this.Sync("buffs3", true);
			}
			else if (this.get_string("eff4") == "")
			{
				this.set_u16("timer4", XORRandom(1200)+1800);
				this.set_string("eff4", "3_regen");
				this.Sync("eff4", true);
				this.set_string("buffs4", "regen`bool`true");
				this.Sync("buffs4", true);
			}
			else if (this.get_string("eff5") == "")
			{
				this.set_u16("timer5", XORRandom(1200)+1800);
				this.set_string("eff5", "3_regen");
				this.Sync("eff5", true);
				this.set_string("buffs5", "regen`bool`true");
				this.Sync("buffs5", true);
			}
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
					if (blob.get_f32("velocity")>0) 		this.set_f32("velocity", this.get_f32("velocity") - blob.get_f32("velocity"));
    				if (blob.get_f32("dodgechance")>0) 		this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
					if (blob.get_f32("blockchance")>0) 		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    				if (blob.get_f32("damagereduction")>0)	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
					if (blob.get_f32("hpregtime")>0) 		this.set_f32("hpregtime", this.get_f32("hpregtime") - blob.get_f32("hpregtime"));
					if (blob.get_f32("manaregtime")>0)		this.set_f32("manaregtime", this.get_f32("manaregtime") - blob.get_f32("manaregtime"));
					if (blob.get_u16("manareg")>0) 			this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
					if (blob.get_u16("mana")>0) 			this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
					if (blob.get_u16("maxmana")>0) 			this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
					if (blob.get_f32("critchance")>0) 		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
					if (blob.get_f32("damagebuff")>0) 		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
					if (blob.get_f32("dealtdamage")>0) 		this.set_f32("dealtdamage", this.get_f32("dealtdamage") - blob.get_f32("dealtdamage"));
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
					if (blob.get_f32("velocity")>0) 		this.set_f32("velocity", this.get_f32("velocity") - blob.get_f32("velocity"));
    				if (blob.get_f32("dodgechance")>0) 		this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
					if (blob.get_f32("blockchance")>0) 		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    				if (blob.get_f32("damagereduction")>0)	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
					if (blob.get_f32("hpregtime")>0) 		this.set_f32("hpregtime", this.get_f32("hpregtime") - blob.get_f32("hpregtime"));
					if (blob.get_f32("manaregtime")>0)		this.set_f32("manaregtime", this.get_f32("manaregtime") - blob.get_f32("manaregtime"));
					if (blob.get_u16("manareg")>0) 			this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
					if (blob.get_u16("mana")>0) 			this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
					if (blob.get_u16("maxmana")>0) 			this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
					if (blob.get_f32("critchance")>0) 		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
					if (blob.get_f32("damagebuff")>0) 		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
					if (blob.get_f32("dealtdamage")>0) 		this.set_f32("dealtdamage", this.get_f32("dealtdamage") - blob.get_f32("dealtdamage"));
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
					if (blob.get_f32("velocity")>0) 		this.set_f32("velocity", this.get_f32("velocity") - blob.get_f32("velocity"));
    				if (blob.get_f32("dodgechance")>0) 		this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
					if (blob.get_f32("blockchance")>0) 		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    				if (blob.get_f32("damagereduction")>0)	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
					if (blob.get_f32("hpregtime")>0) 		this.set_f32("hpregtime", this.get_f32("hpregtime") - blob.get_f32("hpregtime"));
					if (blob.get_f32("manaregtime")>0)		this.set_f32("manaregtime", this.get_f32("manaregtime") - blob.get_f32("manaregtime"));
					if (blob.get_u16("manareg")>0) 			this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
					if (blob.get_u16("mana")>0) 			this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
					if (blob.get_u16("maxmana")>0) 			this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
					if (blob.get_f32("critchance")>0) 		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
					if (blob.get_f32("damagebuff")>0) 		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
					if (blob.get_f32("dealtdamage")>0) 		this.set_f32("dealtdamage", this.get_f32("dealtdamage") - blob.get_f32("dealtdamage"));
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
					if (blob.get_f32("velocity")>0) 		this.set_f32("velocity", this.get_f32("velocity") - blob.get_f32("velocity"));
    				if (blob.get_f32("dodgechance")>0) 		this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
					if (blob.get_f32("blockchance")>0) 		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    				if (blob.get_f32("damagereduction")>0)	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
					if (blob.get_f32("hpregtime")>0) 		this.set_f32("hpregtime", this.get_f32("hpregtime") - blob.get_f32("hpregtime"));
					if (blob.get_f32("manaregtime")>0)		this.set_f32("manaregtime", this.get_f32("manaregtime") - blob.get_f32("manaregtime"));
					if (blob.get_u16("manareg")>0) 			this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
					if (blob.get_u16("mana")>0) 			this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
					if (blob.get_u16("maxmana")>0) 			this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
					if (blob.get_f32("critchance")>0) 		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
					if (blob.get_f32("damagebuff")>0) 		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));
					if (blob.get_f32("dealtdamage")>0) 		this.set_f32("dealtdamage", this.get_f32("dealtdamage") - blob.get_f32("dealtdamage"));
				}
			}
		}
	}
	else if (cmd == getRules().getCommandID("showdamage"))
	{
		f32 dmg = params.read_f32();

		this.set_f32("dealtdamage", dmg);
	}
	else if (cmd == this.getCommandID("shoot arrow"))
	{
		Vec2f arrowPos;
		if (!params.saferead_Vec2f(arrowPos)) return;
		Vec2f arrowVel;
		if (!params.saferead_Vec2f(arrowVel)) return;
		u8 arrowType;
		if (!params.saferead_u8(arrowType)) return;
		bool legolas;
		if (!params.saferead_bool(legolas)) return;

		if (arrowType >= arrowTypeNames.length) return;

		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}

		archer.arrow_type = arrowType;

		// return to normal arrow - server didnt have this synced
		if (!hasArrows(this, arrowType))
		{
			return;
		}

		if (legolas)
		{
			int r = 0;
			for (int i = 0; i < ArcherParams::legolas_arrows_volley; i++)
			{
				if (getNet().isServer())
				{
					CBlob@ arrow = CreateArrow(this, arrowPos, arrowVel, arrowType);
					if (i > 0 && arrow !is null)
					{
						arrow.Tag("shotgunned");
					}
				}
				this.TakeBlob(arrowTypeNames[ arrowType ], 1);
				arrowType = ArrowType::normal;

				//don't keep firing if we're out of arrows
				if (!hasArrows(this, arrowType))
					break;

				r = r > 0 ? -(r + 1) : (-r) + 1;

				arrowVel = arrowVel.RotateBy(ArcherParams::legolas_arrows_deviation * r, Vec2f());
				if (i == 0)
				{
					arrowVel *= 0.9f;
				}
			}
			this.getSprite().PlaySound("Entities/Characters/Archer/BowFire.ogg");
		}
		else
		{
			if (getNet().isServer())
			{
				CreateArrow(this, arrowPos, arrowVel, arrowType);
			}

			this.getSprite().PlaySound("Entities/Characters/Archer/BowFire.ogg");
			this.TakeBlob(arrowTypeNames[ arrowType ], 1);
		}

		archer.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make arrow
	}
	else if (cmd == this.getCommandID("pickup arrow"))
	{
		CBlob@ arrow = getPickupArrow(this);
		bool spriteArrow = canPickSpriteArrow(this, false); // unnecessary

		if (arrow !is null || spriteArrow)
		{
			if (arrow !is null)
			{
				ArcherInfo@ archer;
				if (!this.get("archerInfo", @archer))
				{
					return;
				}
				const u8 arrowType = archer.arrow_type;
				if (arrowType == ArrowType::bomb)
				{
					arrow.set_u16("follow", 0); //this is already synced, its in command.
					arrow.setPosition(this.getPosition());
					return;
				}
			}

			if (getNet().isServer())
			{
				CBlob@ mat_arrows = server_CreateBlobNoInit('mat_arrows');

				if (mat_arrows !is null)
				{
					mat_arrows.Tag('custom quantity');
					mat_arrows.Init();

					mat_arrows.server_SetQuantity(1); // unnecessary

					if (not this.server_PutInInventory(mat_arrows))
					{
						mat_arrows.setPosition(this.getPosition());
					}

					if (arrow !is null)
					{
						arrow.server_Die();
					}
					else
					{
						canPickSpriteArrow(this, true);
					}
				}
			}

			this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
		}
	}
	else if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}
		u8 type = archer.arrow_type;

		int count = 0;
		while (count < arrowTypeNames.length)
		{
			type++;
			count++;
			if (type >= arrowTypeNames.length)
			{
				type = 0;
			}
			if (hasArrows(this, type))
			{
				CycleToArrowType(this, archer, type);
				break;
			}
		}
	}
	else if (cmd == this.getCommandID("switch"))
	{
		// switch to arrow
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}

		u8 type;
		if (params.saferead_u8(type) && hasArrows(this, type))
		{
			CycleToArrowType(this, archer, type);
		}
	}
	else
	{
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}
		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + arrowTypeNames[i]))
			{
				archer.arrow_type = i;
				break;
			}
		}
	}
}

void CycleToArrowType(CBlob@ this, ArcherInfo@ archer, u8 arrowType)
{
	archer.arrow_type = arrowType;
	if (this.isMyPlayer())
	{
		Sound::Play("/CycleInventory.ogg");
	}
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	AddIconToken("$Arrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 0, this.getTeamNum());
	AddIconToken("$WaterArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 1, this.getTeamNum());
	AddIconToken("$FireArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 2, this.getTeamNum());
	AddIconToken("$BombArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 3, this.getTeamNum());
	
	if (arrowTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(arrowTypeNames.length, 2), getTranslatedString("Current arrow"));

	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}
	const u8 arrowSel = archer.arrow_type;

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			string matname = arrowTypeNames[i];
			CGridButton @button = menu.AddButton(arrowIcons[i], getTranslatedString(arrowNames[i]), this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = hasArrows(this, i);
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;

				//if (enabled && i == ArrowType::fire && !hasReqs(this, i))
				//{
				//	button.hoverText = "Requires a fire source $lantern$";
				//	//button.SetEnabled( false );
				//}

				if (arrowSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp(this, "help self action", "archer", getTranslatedString("$arrow$Fire arrow   $KEY_HOLD$$LMB$"), "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "archer", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i])
			{
				archer.arrow_type = i;
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}

	if (this.isAttached() && canSend(this))
	{
		archer.grappling = false;
		SyncGrapple(this);
	}
}
