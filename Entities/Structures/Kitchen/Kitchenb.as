
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", "KitchenTrader.png", 16, 24, 0, 0);
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
	}

	this.getCurrentScript().tickFrequency = 35;

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Kitchen");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Buy egg", "$egg$", "egg", "Chicken egg. Definitely not duck.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy fishy", "$fishy$", "fishy", "Fishy. Is it wet?");
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy steak", "$steak$", "steak", "Beef steak. Wisent was a bad boy.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy cooked steak", "$cooksteak$", "cooksteak", "Cooked beef steak. Wisent was a bad boy.");
		AddRequirement(s.requirements, "coin", "", "Coins", 400);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy bread", "$bread$", "bread", "Soft baguette.");
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy cake", "$cake$", "cake", "is a lie.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy burger", "$food$", "food", "An interesting burger.");
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy waterskin", "$waterskin$", "waterskin", "Wisent?");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.spawnNothing = true;
	}
}

void onTick(CSprite@ this)
{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
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
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(9) + 4)*getTicksASecond());
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
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(6) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("Cooked.ogg");

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
			else if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
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