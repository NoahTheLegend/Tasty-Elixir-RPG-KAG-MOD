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
#include "SkillsCommon.as";
#include "RPGCommon.as";

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
	this.addCommandID("unequiphelmet");
	this.addCommandID("unequiparmor");
	this.addCommandID("unequipgloves");
	this.addCommandID("unequipboots");
	this.addCommandID("unequipweapon");
	this.addCommandID("unequipsecondaryweapon");
	this.addCommandID("update_stats");
	this.addCommandID("sync_stats");
	this.addCommandID("hitsound");
	this.addCommandID("doattackspeedchange");
	this.addCommandID("receive_effect");
	this.addCommandID("timercheck");
	
	KnightInfo knight;

	this.set_u16("attackdelay", 0);
	this.set_u16("attackdelayreduce", 300);

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

	//stats
	InitRogueStats stats;
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

	//gathered set vars
	this.set_bool("hasrlset", false);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	CRules@ rules = getRules();
	if (player !is null)
	{
		string name = player.getUsername();
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
		//set level
		if (rules.get_u16(name+"level") != 0)
        {
            player.set_u16("level", rules.get_u16(name+"level"));
            //printf("blevel="+player.get_u16("level"));
            if (rules.get_u32(name+"exp") != 0)
            {
                player.set_u32("exp", rules.get_u32(name+"exp"));
                //printf("bexp="+player.get_u32("exp"));
            }
            player.set_u32("progressionstep", progression[player.get_u16("level")]);
        }
        else
        {
            ResetLevel(this, player);
        }
	}
}

void onTick(CBlob@ this)
{
	RPGUpdate(this); // do update all things

	//if(getGameTime()%15==0) printf("dred = "+this.get_u16("attackdelayreduce"));
	//if(getGameTime()%15==0) printf("time = "+this.get_u16("attackdelay"));

	if (this.get_u16("attackdelay") > 1000) this.set_u16("attackdelay", this.get_u16("attackdelayreduce"));

	RPGUpdateArcherRogueSets(this);

	//agility extra buff's timer of silence skill
	if (this.get_u16("silenceskilltimer") > 0 && getGameTime() % 30 == 0)
	{
		this.set_u16("silenceskilltimer", this.get_u16("silenceskilltimer") - 30);
		if (this.get_u16("silenceskilltimer") < 0 || this.get_u16("silenceskilltimer") > 10000) this.set_u16("silenceskilltimer", 0);
		if (this.get_u16("silenceskilltimer") == 0)
		{
			this.set_f32("velocity", this.get_f32("velocity") - 0.75);
			this.Sync("velocity", true);
		}
	}
	CControls@ controls = this.getControls();

	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);

	RunnerMoveVars@ moveVars;

	u8 knocked = getKnocked(this);
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

	if (this.get_u16("attackdelay") > 0) 
	{
		if (this.get_u16("attackdelay") <= 9)
			this.set_u16("attackdelay", 0);
		else
 			this.set_u16("attackdelay", this.get_u16("attackdelay") - 10);
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
	if (this.isKeyJustReleased(key_action1) && this.get_u16("attackdelay") == 0)
	{
		this.Sync("attackdelayreduce", true);
		this.set_u16("attackdelay", this.get_u16("attackdelayreduce"));
		this.Sync("attackdelay", true);
		//printf(""+this.get_u16("attackdelay"));
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
		this.set_u16("mana", this.get_u16("mana") - 15);
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
	if (this.hasTag("noAttack"))
	{
		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.slideTime = 0;
		knight.doubleslash = false;
		this.set_s32("currentKnightState", 0);

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
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
		else if (this.isKeyJustReleased(key_action1) && this.get_u16("attackdelay") == 0 || this.get_u16("attackdelay") == this.get_u16("attackdelayreduce") && knight.state == KnightStates::sword_drawn)
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

	if (!swordState && getNet().isServer())
	{
		knight_clear_actor_limits(this);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("timercheck"))
	{
		if (isServer())
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
					if (splb1[0] == "attackspeed")
					{
						CBitStream params;
						params.write_f32(parseFloat(splb1[2]));
						printf(""+parseFloat(splb1[2]));
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
					this.set_f32(splb1[0], this.get_f32(splb1[0]) - parseFloat(splb1[2]));
				}
				//this.Sync(splb1[0], true);
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
					if (splb2[0] == "attackspeed")
					{
						CBitStream params;
						params.write_f32(parseFloat(splb2[2]));
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
					this.set_f32(splb2[0], this.get_f32(splb2[0]) - parseFloat(splb2[2]));
				}
				//this.Sync(splb2[0], true);
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
					if (splb3[0] == "attackspeed")
					{
						CBitStream params;
						params.write_f32(parseFloat(splb3[2]));
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
					this.set_f32(splb3[0], this.get_f32(splb3[0]) - parseFloat(splb3[2]));
				}
				//this.Sync(splb3[0], true);
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
	else if (cmd == this.getCommandID("unequipweapon"))
	{
		if (this.get_bool("hasweapon"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("weaponname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hasweapon", false);
				this.Sync("hasweapon", true);
	       		this.set_string("weaponname", "");
				this.Sync("weaponname", true);
			}
		}
	}
	else if (cmd == this.getCommandID("unequipsecondaryweapon"))
	{
		if (this.get_bool("hassecondaryweapon"))
        {
			CPlayer@ player = this.getPlayer();

			UpdateStats(this, this.get_string("secondaryweaponname"));

			if (player !is null && player.isMyPlayer())
			{
				this.set_bool("hassecondaryweapon", false);
				this.Sync("hassecondaryweapon", true);
	       		this.set_string("secondaryweaponname", "");
				this.Sync("secondaryweaponname", true);
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
		this.set_f32("attackspeed", this.get_f32("attackspeed") - blob.get_f32("attackspeed"));
		if (blob.get_f32("attackspeed") > 0)
        {
            CBitStream params;
			params.write_f32(blob.get_f32("attackspeed"));
			params.write_bool(false);
			this.SendCommand(this.getCommandID("doattackspeedchange"), params);
        }
		this.set_f32("vampirism", this.get_f32("vampirism") - blob.get_f32("vampirism"));
		this.set_f32("bashchance", this.get_f32("bashchance") - blob.get_f32("bashchance"));
		this.set_f32("gravityresist", this.get_f32("gravityresist") - blob.get_f32("gravityresist"));

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
		this.Sync("attackspeed", true);
		this.Sync("dealtdamage", true);
		this.Sync("vampirism", true);
		this.Sync("bashchance", true);
		this.Sync("gravityresist", true);
		//printf("synced");
	}
	else if (cmd == this.getCommandID("doattackspeedchange"))
	{
		f32 current = params.read_f32();
		//printf("curr="+current);
		bool increase = params.read_bool();
		//printf("this.get_u8(attackdelayreduce) - current * 10 = "+(this.get_u16("attackdelayreduce") - current * 5));
		if (increase) this.set_u16("attackdelayreduce", Maths::Ceil(this.get_u16("attackdelayreduce") - (current * 50)));
		else this.set_u16("attackdelayreduce", Maths::Ceil(this.get_u16("attackdelayreduce") + (current * 50)));
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
						this.set_f32("dealtdamage", (damage + this.get_f32("damagebuff"))*2 - b.get_f32("damagereduction"));
					}
					else
					{
						this.server_Hit(b, hi.hitpos, velocity, damage + this.get_f32("damagebuff"), type, true);  // server_Hit() is server-side only
						this.set_f32("dealtdamage", damage + this.get_f32("damagebuff") - b.get_f32("damagereduction"));
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

	damage -= hitBlob.get_f32("damagereduction");
	if (damage <= 0 || damage > 500) damage = 0.05;

	if (XORRandom(100) < this.get_f32("bashchance"))
	{
		if (isClient()) Sound::Play("Bash.ogg", hitBlob.getPosition(), 1.0f);
		hitBlob.Tag("wait");
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

	if (hitBlob.hasTag("flesh"))
	{
		if(isServer())
		{
			this.server_Heal(damage*this.get_f32("vampirism"));
		}
	}

	if (this.get_bool("silence"))
	{
		this.set_bool("silence", false);
		this.set_u16("timer"+getSkillPosition(this, this.getName(), 0), 1);
	}
}

u8 getSkillPosition(CBlob@ this, string pclass, u16 ski) // move to skills.as later
{
	for (int i = 0; i < 11; i++)
	{
		if (this.get_string("eff"+i) == "7_Silence")
		{
			return i;
			break;
		}
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
