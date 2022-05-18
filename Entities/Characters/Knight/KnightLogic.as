
#include "ThrowCommon.as"
#include "KnightCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "KnockedCommon.as"
#include "Help.as";
#include "Requirements.as"
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
	KnightInfo knight;

	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.shield_down = getGameTime();
	knight.tileDestructionLimiter = 0;

	KnightVars::resheath_cut_time = 2;
	KnightVars::slash_charge = 15;
	KnightVars::slash_charge_level2 = 38;
	KnightVars::slash_time = 13;
	KnightVars::double_slash_time = 8;

	this.set("knightInfo", @knight);

	KnightState@[] states;
	states.push_back(NormalState());
	states.push_back(ShieldingState());
	states.push_back(ShieldGlideState());
	states.push_back(ShieldSlideState());
	states.push_back(SwordDrawnState());
	states.push_back(CutState(KnightStates::sword_cut_up));
	states.push_back(CutState(KnightStates::sword_cut_mid));
	states.push_back(CutState(KnightStates::sword_cut_mid_down));
	states.push_back(CutState(KnightStates::sword_cut_mid));
	states.push_back(CutState(KnightStates::sword_cut_down));
	states.push_back(SlashState(KnightStates::sword_power));
	states.push_back(SlashState(KnightStates::sword_power_super));
	states.push_back(ResheathState(KnightStates::resheathing_cut, KnightVars::resheath_cut_time));
	states.push_back(ResheathState(KnightStates::resheathing_slash, KnightVars::resheath_slash_time));

	this.set("knightStates", @states);
	this.set_s32("currentKnightState", 0);

	this.set_f32("gib health", -1.5f);
	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	knight_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.addCommandID("get bomb");

	this.push("names to activate", "keg");

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

	//armor/weapons check
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

	//stats
	InitKnightStats stats;
	this.set_f32("velocity", stats.velocity);
    this.set_f32("blockchance", stats.blockchance); // %
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

	this.set_f32("dealtdamage", 0);

	//gathered set vars
	this.set_bool("hasironset", false);
	this.set_bool("hassteelset", false);

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
	//soundtracks
	this.set_string("track", "");
	this.set_u32("tracktimer", 0);
	this.set_u16("tracktimercd", 0);
	this.getSprite().SetEmitSoundPaused(true);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}

void RunStateMachine(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
{
	KnightState@[]@ states;
	if (!this.get("knightStates", @states))
	{
		return;
	}

	s32 currentStateIndex = this.get_s32("currentKnightState");

	if (getNet().isClient())
	{
		if (this.exists("serverKnightState"))
		{
			s32 serverStateIndex = this.get_s32("serverKnightState");
			this.set_s32("serverKnightState", -1);
			if (serverStateIndex != -1 && serverStateIndex != currentStateIndex)
			{
				KnightState@ serverState = states[serverStateIndex];
				u8 net_state = states[serverStateIndex].getStateValue();
				if (this.isMyPlayer())
				{
					if (net_state >= KnightStates::sword_cut_mid && net_state <= KnightStates::sword_power_super)
					{
						if (knight.state != KnightStates::sword_drawn && knight.state != KnightStates::resheathing_cut && knight.state != KnightStates::resheathing_slash)
						{
							if ((getGameTime() - serverState.stateEnteredTime) > 20)
							{
								knight.state = net_state;
								serverState.stateEnteredTime = getGameTime();
								serverState.StateEntered(this, knight, serverState.getStateValue());
								this.set_s32("currentKnightState", serverStateIndex);
								currentStateIndex = serverStateIndex;
							}

						}

					}
				}
				else
				{
					knight.state = net_state;
					serverState.stateEnteredTime = getGameTime();
					serverState.StateEntered(this, knight, serverState.getStateValue());
					this.set_s32("currentKnightState", serverStateIndex);
					currentStateIndex = serverStateIndex;
				}

			}
		}
	}

	u8 state = knight.state;
	KnightState@ currentState = states[currentStateIndex];

	bool tickNext = false;
	tickNext = currentState.TickState(this, knight, moveVars);

	if (state != knight.state)
	{
		for (s32 i = 0; i < states.size(); i++)
		{
			if (states[i].getStateValue() == knight.state)
			{
				s32 nextStateIndex = i;
				KnightState@ nextState = states[nextStateIndex];
				currentState.StateExited(this, knight, nextState.getStateValue());

				nextState.stateEnteredTime = getGameTime();
				nextState.StateEntered(this, knight, currentState.getStateValue());
				this.set_s32("currentKnightState", nextStateIndex);
				if (getNet().isServer() && knight.state >= KnightStates::sword_drawn && knight.state <= KnightStates::sword_power_super)
				{
					this.set_s32("serverKnightState", nextStateIndex);
					this.Sync("serverKnightState", true);
				}

				if (tickNext)
				{
					RunStateMachine(this, knight, moveVars);

				}
				break;
			}
		}
	}
}

void onTick(CBlob@ this)
{
	RPGUpdate(this); // do update all things

	CControls@ controls = this.getControls();
	this.Sync("damagebuff", true);
	this.Sync("dealtdamage", true);

	RPGUpdateKnightSets(this);

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	//gravity stuff
	if (this.get_f32("gravityresist") > 0)
	{
		this.AddForce(Vec2f(0, -(this.get_f32("gravityresist"))));
		if (this.isKeyPressed(key_action2))
		{
			if (this.getVelocity().y < 2) this.AddForce(Vec2f(0, this.get_f32("gravityresist")/10));
			if (moveVars.fallCount < KnightVars::glide_down_time) this.AddForce(Vec2f(0, this.get_f32("gravityresist")/2));
		}
	}

	bool knocked = isKnocked(this);
	CHUD@ hud = getHUD();

	//knight logic stuff
	//get the vars to turn various other scripts on/off

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

	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	if (this.isInInventory())
	{
		//prevent players from insta-slashing when exiting crates
		knight.state = 0;
		knight.swordTimer = 0;
		knight.slideTime = 0;
		knight.doubleslash = false;
		hud.SetCursorFrame(0);
		this.set_s32("currentKnightState", 0);
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
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	if (getNet().isClient() && !this.isInInventory() && myplayer)  //Knight charge cursor
	{
		SwordCursorUpdate(this, knight);
	}

	if (pressed_a2 && this.get_u16("mana") > 0)
	{
		if (getGameTime() % 5 == 0)
		{
			this.set_u16("mana", this.get_u16("mana") - 1);
		}
	}
	else if (pressed_a2)
	{
		if (getGameTime() % 30 == 0) 
		{
			setKnocked(this, 20);
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}

	if (knocked)
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
	else
	{
		RunStateMachine(this, knight, moveVars);
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

			pressed_a1 = false;
			pressed_a2 = false;
		}
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
			this.Tag("prevent crouch");
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

			this.Tag("prevent crouch");
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

	if (!swordState)
	{
		knight_clear_actor_limits(this);
	}

}

bool getInAir(CBlob@ this)
{
	bool inair = (!this.isOnGround() && !this.isOnLadder());
	return inair;

}

void ShieldMovement(RunnerMoveVars@ moveVars)
{
	moveVars.jumpFactor *= 0.5f;
	moveVars.walkFactor *= 0.9f;
}

class NormalState : KnightState
{
	u8 getStateValue() { return KnightStates::normal; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
		this.set_u8("swordSheathPlayed", 0);
		this.set_u8("animeSwordPlayed", 0);
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1) && !moveVars.wallsliding)
		{
			knight.state = KnightStates::sword_drawn;
			return true;
		}
		else if (this.isKeyPressed(key_action2))
		{
			if (canRaiseShield(this))
			{
				knight.state = KnightStates::shielding;
				return true;
			}
			else
			{
				resetShieldKnockdown(this);
			}

			ShieldMovement(moveVars);

		}

		return false;
	}
}

bool getForceDrop(CBlob@ this, RunnerMoveVars@ moveVars)
{
	Vec2f vel = this.getVelocity();
	bool forcedrop = (vel.y > Maths::Max(Maths::Abs(vel.x), 2.0f) &&
					  moveVars.fallCount > KnightVars::glide_down_time);
	return forcedrop;
}

class ShieldingState : KnightState
{
	u8 getStateValue() { return KnightStates::shielding; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			knight.state = KnightStates::sword_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			knight.state = KnightStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				knight.state = KnightStates::shieldgliding;
				return true;
			}
			else if (forcedrop || direction == 1)
			{
				knight.state = KnightStates::shielddropping;
				return true;
			}
		}

		ShieldMovement(moveVars);

		return false;
	}
}

class ShieldGlideState : KnightState
{
	u8 getStateValue() { return KnightStates::shieldgliding; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			knight.state = KnightStates::sword_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			knight.state = KnightStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				// already in KnightStates::shieldgliding;
			}
			else if (forcedrop || direction == 1)
			{
				knight.state = KnightStates::shielddropping;
				return true;
			}
			else
			{
				knight.state = KnightStates::shielding;
				ShieldMovement(moveVars);
				return false;
			}

		}

		ShieldMovement(moveVars);

		if (this.isInWater() || forcedrop)
		{
			knight.state = KnightStates::shielding;
		}
		else
		{
			Vec2f vel = this.getVelocity();

			moveVars.stoppingFactor *= 0.5f;
			f32 glide_amount = 1.0f - (moveVars.fallCount / f32(KnightVars::glide_down_time * 2));

			if (vel.y > -1.0f)
			{
				this.AddForce(Vec2f(0, -20.0f * glide_amount));
			}

			if (!inair)
			{
				knight.state = KnightStates::shielding;
			}

		}

		return false;
	}
}

class ShieldSlideState : KnightState
{
	u8 getStateValue() { return KnightStates::shielddropping; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			knight.state = KnightStates::sword_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			knight.state = KnightStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				knight.state = KnightStates::shieldgliding;
				return true;
			}
			else if (forcedrop || direction == 1)
			{
				// already in KnightStates::shielddropping;
				knight.slideTime = 0;
			}
			else
			{
				knight.state = KnightStates::shielding;
				ShieldMovement(moveVars);
				return false;
			}
		}

		ShieldMovement(moveVars);

		Vec2f vel = this.getVelocity();

		if (this.isInWater())
		{
			if (vel.y > 1.5f && Maths::Abs(vel.x) * 3 > Maths::Abs(vel.y))
			{
				vel.y = Maths::Max(-Maths::Abs(vel.y) + 1.0f, -8.0);
				this.setVelocity(vel);
			}
			else
			{
				knight.state = KnightStates::shielding;
			}
		}

		if (!inair && this.getShape().vellen < 1.0f)
		{
			knight.state = KnightStates::shielding;
		}
		else
		{
			// faster sliding
			if (!inair)
			{
				knight.slideTime++;
				if (knight.slideTime > 0)
				{
					if (knight.slideTime == 5)
					{
						this.getSprite().PlayRandomSound("/Scrape");
					}

					f32 factor = Maths::Max(1.0f, 2.2f / Maths::Sqrt(knight.slideTime));
					moveVars.walkFactor *= factor;

					if (knight.slideTime > 30)
					{
						moveVars.walkFactor *= 0.75f;
						if (knight.slideTime > 45)
						{
							knight.state = KnightStates::shielding;
						}
					}
					else if (XORRandom(3) == 0)
					{
						Vec2f pos = this.getPosition();
						Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
						velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
						ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);
					}
				}
			}
			else if (vel.y > 1.05f)
			{
				knight.slideTime = 0;
			}

		}

		return false;

	}
}

s32 getSwordTimerDelta(KnightInfo@ knight)
{
	s32 delta = knight.swordTimer;
	if (knight.swordTimer < 128)
	{
		knight.swordTimer++;
	}
	return delta;
}

void AttackMovement(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
{
	Vec2f vel = this.getVelocity();

	bool strong = (knight.swordTimer > KnightVars::slash_charge_level2);
	moveVars.jumpFactor *= (strong ? 0.6f : 0.8f);
	moveVars.walkFactor *= (strong ? 0.8f : 0.9f);

	bool inair = getInAir(this);
	if (!inair)
	{
		this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
	}

	moveVars.canVault = false;
}

class SwordDrawnState : KnightState
{
	u8 getStateValue() { return KnightStates::sword_drawn; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
		this.set_u8("swordSheathPlayed", 0);
		this.set_u8("animeSwordPlayed", 0);
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			knight.state = KnightStates::normal;
			return false;

		}

		Vec2f pos = this.getPosition();

		if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			if (knight.swordTimer == KnightVars::slash_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeSwordPlayed", 1);

			}
			else if (knight.swordTimer == KnightVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("swordSheathPlayed",  1);
			}
		}

		if (knight.swordTimer >= KnightVars::slash_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			setKnocked(this, 15);
			knight.state = KnightStates::normal;
		}

		AttackMovement(this, knight, moveVars);
		s32 delta = getSwordTimerDelta(knight);

		if (!this.isKeyPressed(key_action1))
		{
			if (delta < KnightVars::slash_charge)
			{
				Vec2f vec;
				const int direction = this.getAimDirection(vec);

				if (direction == -1)
				{
					knight.state = KnightStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					Vec2f aimpos = this.getAimPos();
					Vec2f pos = this.getPosition();
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
			}
			else if(delta < KnightVars::slash_charge_limit)
			{
				knight.state = KnightStates::sword_power_super;
			}
		}

		return false;
	}
}

class CutState : KnightState
{
	u8 state;
	CutState(u8 s) { state = s; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight_clear_actor_limits(this);
		knight.swordTimer = 0;
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			knight.state = KnightStates::normal;
			return false;

		}

		this.Tag("prevent crouch");

		AttackMovement(this, knight, moveVars);
		s32 delta = getSwordTimerDelta(knight);

		if (delta == DELTA_BEGIN_ATTACK)
		{
			Sound::Play("/SwordSlash", this.getPosition());
		}
		else if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
		{
			f32 attackarc = 90.0f;
			f32 attackAngle = getCutAngle(this, knight.state);

			if (knight.state == KnightStates::sword_cut_down)
			{
				attackarc *= 0.9f;
			}

			DoAttack(this, 1.0f, attackAngle, attackarc, Hitters::sword, delta, knight);
		}
		else if (delta >= 9)
		{
			knight.state = KnightStates::resheathing_cut;
		}

		return false;

	}
}

Vec2f getSlashDirection(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	Vec2f aiming_direction = vel;
	aiming_direction.y *= 2;
	aiming_direction.Normalize();

	return aiming_direction;
}

class SlashState : KnightState
{
	u8 state;
	SlashState(u8 s) { state = s; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight_clear_actor_limits(this);
		knight.swordTimer = 0;
		knight.slash_direction = getSlashDirection(this);
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			knight.state = KnightStates::normal;
			return false;

		}

		if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			Vec2f pos = this.getPosition();
			if (knight.state == KnightStates::sword_power_super && this.get_u8("animeSwordPlayed") == 0)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeSwordPlayed", 1);
				this.set_u8("swordSheathPlayed", 1);

			}
			else if (knight.state == KnightStates::sword_power && this.get_u8("swordSheathPlayed") == 0)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("swordSheathPlayed",  1);
			}
		}

		this.Tag("prevent crouch");

		AttackMovement(this, knight, moveVars);
		s32 delta = getSwordTimerDelta(knight);

		if (knight.state == KnightStates::sword_power_super
			&& this.isKeyJustPressed(key_action1))
		{
			knight.doubleslash = true;
		}

		if (delta == 2)
		{
			Sound::Play("/ArgLong", this.getPosition());
			Sound::Play("/SwordSlash", this.getPosition());
		}
		else if (delta > DELTA_BEGIN_ATTACK && delta < 10)
		{
			Vec2f vec;
			this.getAimDirection(vec);
			DoAttack(this, 2.0f, -(vec.Angle()), 120.0f, Hitters::sword, delta, knight);
		}
		else if (delta >= KnightVars::slash_time
			|| (knight.doubleslash && delta >= KnightVars::double_slash_time))
		{
			if (knight.doubleslash)
			{
				knight.doubleslash = false;
				knight.state = KnightStates::sword_power;
			}
			else
			{
				knight.state = KnightStates::resheathing_slash;
			}
		}

		Vec2f vel = this.getVelocity();
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

		return false;

	}
}

class ResheathState : KnightState
{
	u8 state;
	s32 time;
	ResheathState(u8 s, s32 t) { state = s; time = t; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, KnightInfo@ knight, u8 previous_state)
	{
		knight.swordTimer = 0;
		this.set_u8("swordSheathPlayed", 0);
		this.set_u8("animeSwordPlayed", 0);
	}

	bool TickState(CBlob@ this, KnightInfo@ knight, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			knight.state = KnightStates::normal;
			return false;

		}
		else if (this.isKeyPressed(key_action1))
		{
			knight.state = KnightStates::sword_drawn;
			return true;
		}

		AttackMovement(this, knight, moveVars);
		s32 delta = getSwordTimerDelta(knight);

		if (delta > time)
		{
			knight.state = KnightStates::normal;
		}

		return false;
	}
}

void SwordCursorUpdate(CBlob@ this, KnightInfo@ knight)
{
	if (knight.swordTimer >= KnightVars::slash_charge_level2 || knight.doubleslash || knight.state == KnightStates::sword_power_super)
	{
		getHUD().SetCursorFrame(19);
	}
	else if (knight.swordTimer >= KnightVars::slash_charge)
	{
		int frame = 1 + int((float(knight.swordTimer - KnightVars::slash_charge) / (KnightVars::slash_charge_level2 - KnightVars::slash_charge)) * 9) * 2;
		getHUD().SetCursorFrame(frame);
	}
	// the yellow circle stays for the duration of a slash, helpful for newplayers (note: you cant attack while its yellow)
	else if (knight.state == KnightStates::normal || knight.state == KnightStates::resheathing_cut || knight.state == KnightStates::resheathing_slash) // disappear after slash is done
	// the yellow circle dissapears after mouse button release, more intuitive for improving slash timing
	// else if (knight.swordTimer == 0) (disappear right after mouse release)
	{
		getHUD().SetCursorFrame(0);
	}
	else if (knight.swordTimer < KnightVars::slash_charge && knight.state == KnightStates::sword_drawn)
	{
		int frame = 2 + int((float(knight.swordTimer) / KnightVars::slash_charge) * 8) * 2;
		if (knight.swordTimer <= KnightVars::resheath_cut_time) //prevent from appearing when jabbing/jab spamming
		{
			getHUD().SetCursorFrame(0);
		}
		else
		{
			getHUD().SetCursorFrame(frame);
		}
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
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
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
					if (splb2[0] == "attackspeed") 
					{
						CBitStream params;
						params.write_f32(parseFloat(splb2[2]));
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
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
					if (splb3[0] == "attackspeed") 
					{
						CBitStream params;
						params.write_f32(parseFloat(splb3[2]));
						params.write_bool(false);
						this.SendCommand(this.getCommandID("doattackspeedchange"), params);
					}
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
		this.set_f32("vampirism", this.get_f32("vampirism") - blob.get_f32("vampirism"));
		this.set_f32("bashchance", this.get_f32("bashchance") - blob.get_f32("bashchance"));
		this.set_f32("gravityresist", this.get_f32("gravityresist") - blob.get_f32("gravityresist"));

		//CBitStream params;
		//this.SendCommand(this.getCommandID("sync_stats"), params);

		if (blob.get_f32("attackspeed") > 0)
        {
            CBitStream params;
			params.write_f32(blob.get_f32("attackspeed"));
			params.write_bool(true);
			this.SendCommand(this.getCommandID("doattackspeedchange"), params);
        }
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
		bool increase = params.read_bool();
		if (increase)
		{
			KnightVars::slash_charge -= current * 5;
			KnightVars::slash_charge_level2 -= current * 5;
			KnightVars::resheath_cut_time -= current;
		}
		else 
		{
			KnightVars::slash_charge += current * 5;
			KnightVars::slash_charge_level2 += current * 5;
			KnightVars::resheath_cut_time += current;
		}
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
		if (this.getCarriedBlob() !is null)
			return;

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
			}

			SetFirstAvailableBomb(this);
		}
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle bombs
		u8 type = this.get_u8("bomb type");
		int count = 0;
		while (count < bombTypeNames.length)
		{
			type++;
			count++;
			if (type >= bombTypeNames.length)
				type = 0;
			if (hasBombs(this, type))
			{
				CycleToBombType(this, type);
				break;
			}
		}
	}
	else if (cmd == this.getCommandID("switch"))
	{
		u8 type;
		if (params.saferead_u8(type) && hasBombs(this, type))
		{
			CycleToBombType(this, type);
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

void CycleToBombType(CBlob@ this, u8 bombType)
{
	this.set_u8("bomb type", bombType);
	if (this.isMyPlayer())
	{
		Sound::Play("/CycleInventory.ogg");
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
	bool dontHitMoreLogs = false;

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

				f32 temp_damage = damage;

				knight_add_actor_limit(this, b);
				if (!dontHitMore && (b.getName() != "log" || !dontHitMoreLogs))
				{
					Vec2f velocity = b.getPosition() - pos;

					if (b.getName() == "log")
					{
						temp_damage /= 3;
						dontHitMoreLogs = true;
						CBlob@ wood = server_CreateBlobNoInit("mat_wood");
						if (wood !is null)
						{
							int quantity = Maths::Ceil(float(temp_damage) * 20.0f);
							int max_quantity = b.getHealth() / 0.024f; // initial log health / max mats
							
							quantity = Maths::Max(
								Maths::Min(quantity, max_quantity),
								0
							);

							wood.Tag('custom quantity');
							wood.Init();
							wood.setPosition(hi.hitpos);
							wood.server_SetQuantity(quantity);
						}

					}

					if (XORRandom(100) < this.get_f32("critchance"))
					{
						this.server_Hit(b, hi.hitpos, velocity, (temp_damage + this.get_f32("damagebuff"))*2, type, true);
						Sound::Play("AnimeSword.ogg", this.getPosition(), 1.3f);
						this.set_f32("dealtdamage", (temp_damage + this.get_f32("damagebuff"))*2 - b.get_f32("damagereduction"));
					}
					else
					{
						this.server_Hit(b, hi.hitpos, velocity, temp_damage + this.get_f32("damagebuff"), type, true);  // server_Hit() is server-side only
						this.set_f32("dealtdamage", temp_damage + this.get_f32("damagebuff") - b.get_f32("damagereduction"));
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
	// return if we collided with map, solid (door/platform), or something non-fleshy (like a boulder)
	// allow shieldbashing enemy bombs so knights can "deflect" them
	if (blob is null || !solid || (!blob.hasTag("flesh") && blob.getName() != "bomb") || this.getTeamNum() == blob.getTeamNum())
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
		        !isKnocked(blob))
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getOldVelocity();
			f32 vellen = vel.getLength();
			vel.Normalize();

			//printf("nor " + vel * normal );
			if (vel * normal < 0.0f && knight_hit_actor_count(this) == 0) //only bash one thing per tick
			{
				ShieldVars@ shieldVars = getShieldVars(this);
				//printf("shi " + shieldVars.direction * normal );
				if (shieldVars.direction * normal < 0.0f)
				{
					//print("" + vellen);
					knight_add_actor_limit(this, blob);
					this.server_Hit(blob, pos, vel, 0.0f, Hitters::shield);

					Vec2f force = Vec2f(shieldVars.direction.x * this.getMass(), -this.getMass()) * 3.0f;

					// scale knockback with knight's velocity

					vellen = Maths::Min(vellen, 8.0f); // cap on velocity so enemies don't get launched too much

					if (vellen < 3.5f)
					{
						// roughly the same weak knockback at low velocity
						force *= Maths::Pow(vellen, 1.0f / 3.0f) / 2;
					}
					else
					{
						// scale linearly at higher velocity
						force *= (vellen - 3.5f) / 6 + 0.759f;
					}

					blob.AddForce(force);
					force *= 0.5f;
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
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		setKnocked(this, 30, true);
	}

	if (hitBlob.hasTag("flesh"))
	{
		if(isServer())
		{
			this.server_Heal(damage*this.get_f32("vampirism"));
		}
	}

	if (customData == Hitters::shield)
	{
		setKnocked(hitBlob, 20, true);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
	}
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
				bool enabled = hasBombs(this, i);
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
		this.set_s32("currentKnightState", 0);
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
	u8 nowType = 255;
	if (this.exists("bomb type"))
		nowType = this.get_u8("bomb type");

	CInventory@ inv = this.getInventory();

	bool typeReal = (uint(nowType) < bombTypeNames.length);
	if (typeReal && inv.getItem(bombTypeNames[nowType]) !is null)
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

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	CheckSelectedBombRemovedFromInventory(this, blob);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	CheckSelectedBombRemovedFromInventory(this, detached);
}

void CheckSelectedBombRemovedFromInventory(CBlob@ this, CBlob@ blob)
{
	string name = blob.getName();
	if (bombTypeNames.find(name) > -1 && this.getBlobCount(name) == 0)
	{
		SetFirstAvailableBomb(this);
	}
}
