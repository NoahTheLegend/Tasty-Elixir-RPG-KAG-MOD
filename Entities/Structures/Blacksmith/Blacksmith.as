
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", "BlacksmithTrader.png", 16, 24, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 4));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));

		Animation@ furnace = sprite.addAnimation("furnace", 0, true);
		furnace.AddFrame(0); furnace.AddFrame(1); furnace.AddFrame(2); furnace.AddFrame(3);
		sprite.SetAnimation("furnace");

		sprite.SetEmitSound("/Quarry.ogg");
		sprite.SetEmitSoundPaused(true);
	}
	this.getCurrentScript().tickFrequency = 5;

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);
	
	AddIconToken("$ironbar$", "Bars.png", Vec2f(16, 16), 16);
	AddIconToken("$steelbar$", "Bars.png", Vec2f(16, 16), 17);
	AddIconToken("$goldbar$", "Bars.png", Vec2f(16, 16), 18);
	AddIconToken("$chromiumbar$", "Bars.png", Vec2f(16, 16), 19);
	AddIconToken("$paladiumbar$", "Bars.png", Vec2f(16, 16), 20);
	AddIconToken("$platinumbar$", "Bars.png", Vec2f(16, 16), 21);
	AddIconToken("$titaniumbar$", "Bars.png", Vec2f(16, 16), 22);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Blacksmith");
	this.set_u8("shop icon", 15);

	this.set_u16("animstate", 0);
	this.set_u16("fuel", 0);
	this.set_u16("maxfuel", 500);
	this.addCommandID("refuel");

	{
		ShopItem@ s = addShopItem(this, "Iron bar (1)", "$ironbar$", "mat_ironbar-1", "Smelt iron ore into an iron bar", true);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Steel bar (1)", "$steelbar$", "mat_steelbar-1", "Smelt iron bars into a forceful steel bar", true);
		AddRequirement(s.requirements, "blob", "mat_ironbar", "Iron bar", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gold bar (1)", "$goldbar$", "mat_goldbar-1", "Smelt gold ore into a precious gold bar", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Chromium bar (1)", "$chromiumbar$", "mat_chromiumbar-1", "Smelt chromium ore into a shiny bar of chromium", true);
		AddRequirement(s.requirements, "blob", "mat_chromium", "Chromium", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Palladium bar (1)", "$paladiumbar$", "mat_paladiumbar-1", "Smelt palladium ore into a warm palladium bar", true);
		AddRequirement(s.requirements, "blob", "mat_paladium", "Paladium", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Platinum bar (1)", "$platinumbar$", "mat_platinumbar-1", "Smelt platinum ore into a valuable platinum bar", true);
		AddRequirement(s.requirements, "blob", "mat_platinum", "Platinum", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Titanium bar (1)", "$titaniumbar$", "mat_titaniumbar-1", "Smelt titanium ore into a strong titanium bar", true);
		AddRequirement(s.requirements, "blob", "mat_titanium", "Titanium", 30);

		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (this is null) return;
	//printf(""+this.get_u16("fuel"));
	CSprite@ sprite = this.getSprite();
	if (this.get_u16("fuel") <= 4)
	{
		sprite.SetFrameIndex(0); // idfk why it is working so
		sprite.SetEmitSoundPaused(true);
	}
	if (this.get_u16("fuel") >= 5)
	{
		sprite.SetFrameIndex(this.get_u16("animstate"));
		this.set_u16("animstate", this.get_u16("animstate") + 1);
		if (this.get_u16("animstate") >= 3) this.set_u16("animstate", 1);
		sprite.SetEmitSoundPaused(false);
	}

	if (this.get_u16("fuel") > 1000) this.set_u16("fuel", 500);
	if (this.get_u16("fuel")>=5)
		this.set_u16("fuel", this.get_u16("fuel") - 1);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//TODO: empty? show it.
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");

	if (!trader_moving)
	{
		if (move_timer <= getGameTime() && trader !is null)
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);
		}
	}
	else if (trader !is null)
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(4) + 4)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(6) + 3)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;

	CBlob@ blob = this.getBlob();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < this.getBlob().getRadius();

	if (blob.get_u16("fuel") <= 4 && mouseOnBlob)
	{
		Vec2f pos = blob.getInterpolatedScreenPos();

		GUI::SetFont("menu");
		GUI::DrawTextCentered("Furnace need wood to smelt ore!", Vec2f(pos.x, pos.y + 85 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//printf(""+this.get_u16("fuel"));
	if (this.get_u16("fuel") <= 4) this.set_bool("shop available", false);
	else this.set_bool("shop available", this.isOverlapping(caller));
	if (this.get_u16("fuel") < this.get_u16("maxfuel"))
	{
		if (caller is null
		|| caller.getCarriedBlob() is null
		|| caller.getCarriedBlob().getName() != "mat_wood") return;

     	CBitStream params;
	    params.write_u16(caller.getCarriedBlob().getNetworkID());
	    caller.CreateGenericButton("$mat_wood$", Vec2f(8, 4), this, this.getCommandID("refuel"), "Refuel blacksmith furnace", params); 
	}
	if (this.get_u16("fuel") <= 4) return;
	if (this.get_u16("fuel") >= 10)
	{ 
		if(caller.getName() == this.get_string("required class"))
		{
			this.set_Vec2f("shop offset", Vec2f_zero);
		}
		else
		{
			this.set_Vec2f("shop offset", Vec2f(0, 0));
		}
		this.set_bool("shop available", this.isOverlapping(caller));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("refuel"))
	{
		u16 matid = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(matid);
		this.set_u16("fuel", this.get_u16("fuel") + blob.getQuantity());
		this.Sync("fuel", true);

		if (isServer()) blob.server_Die();
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}