
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

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_string("shop description", "Potions table");
	this.set_u8("shop icon", 15);

	this.set_u16("animstate", 0);
	this.set_u16("fuel", 0);
	this.set_u16("maxfuel", 500);
	this.addCommandID("refuel");

	{
		ShopItem@ s = addShopItem(this, "Buy egg", "$egg$", "egg", "Chicken egg. Definitely not duck.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	//printf(""+this.get_u16("fuel"));
	CSprite@ sprite = this.getSprite();
	if (this.get_u16("fuel") <= 4)
	{
		sprite.SetFrameIndex(0); // idfk why it is working so
		sprite.SetEmitSoundPaused(true);
	}
	else if (this.get_u16("fuel") >= 5)
	{
		sprite.SetFrameIndex(this.get_u16("animstate"));
		this.set_u16("animstate", this.get_u16("animstate") + 1);
		if (this.get_u16("animstate") >= 3) this.set_u16("animstate", 1);
		sprite.SetEmitSoundPaused(false);
	}

	if (getGameTime() % 30 == 0 && this !is null) 
	{
		if (this.get_u16("fuel") > 1000) this.set_u16("fuel", 500);
		if (this.get_u16("fuel")>=5)
			this.set_u16("fuel", this.get_u16("fuel") - 5);
	}
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
	if (this.get_u16("fuel") < this.get_u16("maxfuel"))
	{
		if (caller is null || caller.getCarriedBlob() is null || caller.getCarriedBlob().getName() != "mat_wood") return;

     	CBitStream params;
	    params.write_u16(caller.getCarriedBlob().getNetworkID());
	    caller.CreateGenericButton("$mat_wood$", Vec2f(8, 4), this, this.getCommandID("refuel"), "Refuel blacksmith furnace", params); 
	}
	if (this.get_u16("fuel") >= 5)
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
	else this.set_bool("shop available", false);
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
		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		//string[] spl = name.split("_");

		if (callerBlob is null) return;

		if (isServer())
		{
		
		}
	}
}