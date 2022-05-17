// Archer logic

#include "ArcherCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "Requirements.as";
#include "CustomBlocks.as";
#include "SkillsCommon.as";
#include "RPGCommon.as";

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
	this.addCommandID("update_stats");
	this.addCommandID("sync_stats");

	this.addCommandID("hitsound");

	this.set_bool("hasarmor", false);
	this.set_string("armorname", "");

	this.set_bool("hasboots", false);
	this.set_string("bootsname", "");

	this.set_bool("hasgloves", false);
	this.set_string("glovesname", "");

	this.set_bool("hashelmet", false);
	this.set_string("helmetname", "");

	//stats
	InitArcherStats stats;
	this.set_f32("velocity", stats.velocity);
    this.set_f32("dodgechance", stats.dodgechance); // %
	this.set_f32("critchance", stats.critchance); // %
    this.set_f32("damagereduction", stats.damagereduction);
	this.set_f32("hpregtime", stats.hpregtime);
	this.set_u16("hpregtimer", stats.hpregtimer);
	this.set_f32("manaregtime", stats.manaregtime);
	this.set_u16("manaregtimer", stats.manaregtimer);
	this.set_u16("manareg", stats.manareg);
	this.set_u16("mana", stats.mana);
	this.set_u16("maxmana", stats.maxmana);
	this.set_f32("damagebuff", stats.damagebuff);
	this.set_f32("vampirism", stats.vampirism); // % set from 0 to 1 for easier managing and multiplying
	this.set_f32("attackspeed", stats.attackspeed);
	this.set_bool("glowness", stats.glowness);
	this.set_bool("glowness2", stats.glowness2);
	this.set_f32("gravityresist", stats.gravityresist); // 15 max
	this.set_f32("bashchance", stats.bashchance); // %
	this.set_f32("stabdmg", stats.stabdmg);

	this.set_f32("dealtdamage", 0);

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

void DoAttackSpeedChange(f32 speed, bool increase)
{
	if (increase)
	{
		ArcherParams::ready_time -= speed * 4;
		ArcherParams::shoot_period -= speed * 10;
	}
	else 
	{
		ArcherParams::ready_time += speed * 5;
		ArcherParams::shoot_period += speed * 10;
	}
	printf(""+ArcherParams::ready_time);
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
		if (this.getCarriedBlob() !is null) if (this.getCarriedBlob().getName() == "drill"
		|| this.getCarriedBlob().getName() == "irondrill"
		|| this.getCarriedBlob().getName() == "steeldrill") return;
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
								this.set_f32("dealtdamage", (this.get_f32("stabdmg") + this.get_f32("damagebuff"))*2 - stabTarget.get_f32("damagereduction"));
								if(isServer())
								{
									this.server_Heal((this.get_f32("stabdmg") + this.get_f32("damagebuff"))*this.get_f32("vampirism")*2);
								}
							}
							else
							{
								this.server_Hit(stabTarget, stabTarget.getPosition(), Vec2f_zero, this.get_f32("stabdmg") + this.get_f32("damagebuff"),  Hitters::stab);
								Sound::Play("SwordSheath.ogg", this.getPosition(), 1.3f);
								this.set_f32("dealtdamage", this.get_f32("stabdmg") + this.get_f32("damagebuff") - stabTarget.get_f32("damagereduction"));
								if(isServer())
								{
									this.server_Heal((this.get_f32("stabdmg") + this.get_f32("damagebuff"))*this.get_f32("vampirism"));
								}
							}
							if (this.get_bool("concentration"))
							{
								this.set_bool("concentration", false);
								this.Sync("concentration", true);
								this.set_u16("timer"+getSkillPosition(this, this.getName(), 0), 1);
							}
							if (XORRandom(100) < this.get_f32("bashchance"))
							{
								if (isClient()) Sound::Play("Bash.ogg", stabTarget.getPosition(), 1.0f);
								stabTarget.Tag("wait");
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

void onTick(CBlob@ this)
{
	RPGUpdate(this); // do update all things

	CControls@ controls = this.getControls();
	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);
	if (this.hasTag("updateattackspeed"))
	{
		DoAttackSpeedChange(this.get_f32("attackspeed"), true);
		this.Untag("updateattackspeed");
	}

	RPGUpdateArcherRogueSets(this);
	
	if (this.isKeyPressed(key_action1) && this.get_u16("mana") > 0)
	{
		if (getGameTime() % 15 == 0)
		{
			if (this.getCarriedBlob() !is null)
				if (this.getCarriedBlob().getName() == "drill"
				|| this.getCarriedBlob().getName() == "irondrill"
				|| this.getCarriedBlob().getName() == "steeldrill"
				|| this.getCarriedBlob().getName() == "palladiumdrill"
				|| this.getCarriedBlob().getName() == "platinumdrill")
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

	RunnerMoveVars@ moveVars;

	bool knocked = isKnocked(this);
	CHUD@ hud = getHUD();

	//get the vars to turn various other scripts on/off

	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	//gravity stuff
	if (this.get_f32("gravityresist") > 0)
	{
		this.AddForce(Vec2f(0, -(this.get_f32("gravityresist"))));
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
		
		if (this.get_bool("concentration"))
		{
			params.write_Vec2f(arrowVel*1.3);

			this.set_bool("concentration", false);
			this.Sync("concentration", true);
			this.set_u16("timer"+getSkillPosition(this, this.getName(), 0), 1);
			this.Sync("timer"+getSkillPosition(this, this.getName(), 0), true);
		}
		else params.write_Vec2f(arrowVel);

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
		arrow.set_f32("damagebuff", this.get_f32("damagebuff"));
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);

		arrow.set_u16("shooternetid", this.getNetworkID());

		if (XORRandom(100) < this.get_f32("critchance"))
		{
			arrow.Tag("critarrow");
		}
		if (XORRandom(100) < this.get_f32("bashchance"))
		{
			arrow.Tag("basharrow");
		}
	}
	return arrow;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("timercheck"))
	{
		if (isServer())
		{
			CPlayer@ player = this.getPlayer();
			if (player is null || !player.isMyPlayer()) return;

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
					if (splb1[0] == "attackspeed") DoAttackSpeedChange(this.get_f32("attackspeed"), false);
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
					if (splb2[0] == "attackspeed") DoAttackSpeedChange(this.get_f32("attackspeed"), false);
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
					if (splb3[0] == "attackspeed") DoAttackSpeedChange(this.get_f32("attackspeed"), false);
					this.set_f32(splb3[0], this.get_f32(splb3[0]) - parseFloat(splb3[2]));
				}
				this.Sync(splb3[0], true);
			}
		}
	}
	else if (cmd == this.getCommandID("receive_effect"))
	{
		u16 eff = params.read_u16();
		u32 time = params.read_u32();

		CPlayer@ player = this.getPlayer();
		if (player is null || !player.isMyPlayer()) return;

		if (eff == 2)
		{
			this.set_bool("poisoned", true);
			this.Sync("poisoned", true);
			SetToFreeSlot(this, "2_poison", "poisoned`bool`true", time);
		}
		else if (eff == 3)
		{
			this.set_bool("bleeding", true);
			this.Sync("bleeding", true);
			SetToFreeSlot(this, "3_bleed", "bleeding`bool`true", time);
		}
		else if (eff == 4)
		{
			this.set_bool("regen", true);
			this.Sync("regen", true);
			SetToFreeSlot(this, "4_regen", "regen`bool`true", time);
		}
	}
	else if (cmd == this.getCommandID("unequiphelmet"))
	{
		if (this.get_bool("hashelmet"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("helmetname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hashelmet", false);
				this.Sync("hashelmet", true);
	       		this.set_string("helmetname", "");
				this.Sync("helmetname", true);
			}
		}
	}
	else if (cmd == this.getCommandID("unequiparmor"))
	{
		if (this.get_bool("hasarmor"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("armorname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hasarmor", false);
				this.Sync("hasarmor", true);
	       		this.set_string("armorname", "");
				this.Sync("armorname", true);
			}
		}
	}
	else if (cmd == this.getCommandID("unequipgloves"))
	{
		if (this.get_bool("hasgloves"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("glovesname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hasgloves", false);
				this.Sync("hasgloves", true);
	       		this.set_string("glovesname", "");
				this.Sync("glovesname", true);
			}
		}
	}
	else if (cmd == this.getCommandID("unequipboots"))
	{
		if (this.get_bool("hasboots"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("bootsname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hasboots", false);
				this.Sync("hasboots", true);
	       		this.set_string("bootsname", "");
				this.Sync("bootsname", true);
			}
		}
	}
	else if (cmd == this.getCommandID("update_stats"))
	{
		CPlayer@ player = this.getPlayer();
		if (player is null || !player.isMyPlayer()) return;

		u16 blobid = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(blobid);
		if (blob is null) return;

		this.set_f32("velocity", this.get_f32("velocity") + blob.get_f32("velocity"));
    	this.set_f32("dodgechance", this.get_f32("dodgechance") - blob.get_f32("dodgechance"));
		this.set_f32("blockchance", this.get_f32("blockchance") - blob.get_f32("blockchance"));
    	this.set_f32("damagereduction", this.get_f32("damagereduction") - blob.get_f32("damagereduction"));
		this.set_f32("hpregtime", this.get_f32("hpregtime") - (blob.get_f32("hpregtime"))*-1);
		this.set_f32("manaregtime", this.get_f32("manaregtime") - (blob.get_f32("manaregtime"))*-1);
		this.set_u16("manareg", this.get_u16("manareg") - blob.get_u16("manareg"));
		this.set_u16("mana", this.get_u16("mana") - blob.get_u16("mana"));
		this.set_u16("maxmana", this.get_u16("maxmana") - blob.get_u16("maxmana"));
		this.set_f32("critchance", this.get_f32("critchance") - blob.get_f32("critchance"));
		this.set_f32("damagebuff", this.get_f32("damagebuff") - blob.get_f32("damagebuff"));

		//CBitStream params;
		//this.SendCommand(this.getCommandID("sync_stats"), params);
	}
	else if (cmd == this.getCommandID("sync_stats"))
	{
		//printf("velocity = "+"velocity".getHash());
		////printf("dodgechance = "+"dodgechance".getHash());
		//printf("blockchance = "+"blockchance".getHash());
		//printf("damagereduction = "+"damagereduction".getHash());
		//printf("hpregtime = "+"hpregtime".getHash());
		//printf("manaregtime = "+"manaregtime".getHash());
		//printf("manareg = "+"manareg".getHash());
		//printf("mana = "+"mana".getHash());
		//printf("maxmana = "+"maxmana".getHash());
		//printf("critchance = "+"critchance".getHash());
		//printf("damagebuff = "+"damagebuff".getHash());
		//printf("dealtdamage = "+"dealtdamage".getHash());

		this.Sync("velocity", true);
		this.Sync("dodgechance", true); // sync prop not found
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
		printf("synced");
	}
	else if (cmd == this.getCommandID("hitsound"))
	{
		CPlayer@ player = this.getPlayer();
		if (player is null) return;

		string type = params.read_string();
		if (type == "isblock")
		{
			if (isClient() && player.isMyPlayer()) Sound::Play("metal_stone.ogg", this.getPosition(), 0.5f);
		}
		else if (type == "isdodge")
		{
			if (isClient() && player.isMyPlayer()) Sound::Play("Silence.ogg", this.getPosition(), 0.5f, 1.25f);
		}
		else printf("No `type` exctracted from params!");
	}
	else if (cmd == getRules().getCommandID("showdamage"))
	{
		f32 dmg = params.read_f32();

		this.set_f32("dealtdamage", dmg);
		this.Sync("dealtdamage", true);
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

		if (this.get_bool("concentration"))
		{
			arrowVel *= 1.3;
			this.set_bool("concentration", false);
			this.Sync("concentration", true);
			this.set_u16("timer"+getSkillPosition(this, this.getName(), 0), 1);
			//printf(""+(getSkillPosition(this, this.getName(), 0)+1));
		}

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

u8 getSkillPosition(CBlob@ this, string pclass, u16 ski) // move to skills.as later
{
	for (int i = 0; i < 11; i++)
	{
		if (this.get_string("eff"+i) == "6_Concentration")
		{
			return i;
			break;
		}
	}
	return 255;
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
