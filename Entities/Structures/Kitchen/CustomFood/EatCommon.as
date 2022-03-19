const string heal_id = "heal command";

bool canEat(CBlob@ blob)
{
	return blob.exists("eat sound");
}

// returns the healing amount of a certain food (in quarter hearts) or 0 for non-food
u8 getHealingAmount(CBlob@ food)
{
	if (!canEat(food))
	{
		return 0;
	}

	if (food.getName() == "heart")	    // HACK
	{
		return 1; // 0.25 heart
	}

	return 255; // full healing
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	if (getNet().isServer() && this.hasTag("player") && (this.getHealth() < this.getInitialHealth() || (this.get_u8("hunger") >= food.get_u8("saturationhunger") && food.get_u8("saturationhunger") > 0)) && !food.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(this.getNetworkID());
		//params.write_f32(getHealingAmount(food));

		f32 heal_amount = 0.5; //in quarter hearts, 255 means full hp

		//hunger
		if (this.get_u8("hunger") > food.get_u8("saturationhunger"))
		{
			this.set_u8("hunger", this.get_u8("hunger") - food.get_u8("saturationhunger"));
		}
		else
		{
			this.set_u8("hunger", this.get_u8("hunger") - (food.get_u8("saturationhunger") + (this.get_u8("hunger") - food.get_u8("saturationhunger"))));
		}
		//thirst
		if (this.get_u8("thirst") >= 25)
		{
            this.set_u8("thirst", this.get_u8("thirst") - food.get_u8("saturationthirst"));
			this.set_u8("thirst", this.get_u8("thirst") + food.get_u8("antisaturationthirst"));
		}
		else
		{ 
            this.set_u8("thirst", this.get_u8("thirst") - (food.get_u8("saturationthirst") + (this.get_u8("thirst") - food.get_u8("saturationthirst"))));
			this.set_u8("thirst", this.get_u8("thirst") + food.get_u8("antisaturationthirst"));
		}
		this.Sync("hunger", true);
		this.Sync("thirst", true);
		if (food.getName() == "heart")
		{ 
			heal_amount = 0.25;
		}
		else if (food.getName() == "food")
		{
			heal_amount = 1.0;
		}
		else if (food.getName() == "cake")
		{
			heal_amount = 0.75;
		}
		else if (food.getName() == "steak")
		{
			heal_amount = 0.25;
		}
		else if (food.getName() == "cooksteak")
		{
			heal_amount = 2.0;
		}
		else if (food.getName() == "cooked_fish")
		{
			heal_amount = 1.25;
		}
		else if (food.getName() == "bread")
		{
			heal_amount = 1.0;
		}
		else if (food.getName() == "grain")
		{
			heal_amount = 0.5;
		}

		//printf(""+heal_amount);

		params.write_f32(heal_amount);

		food.SendCommand(food.getCommandID(heal_id), params);
		
		food.Tag("healed");
		food.server_Die();
	}
}
