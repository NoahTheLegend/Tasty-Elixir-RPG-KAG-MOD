void onInit(CBlob@ this)
{
  this.set_u8("state", 0); //0=full, 3=empty
  this.set_u8("saturationthirst", 25);
  this.addCommandID("drink");
  this.addCommandID("refill");

  CSprite@ sprite = this.getSprite();
  Animation@ anim = sprite.addAnimation("fill", 0, false);
  int[] frames = {0, 1, 2, 3}; //put your frames here
  anim.AddFrames(frames);
  sprite.SetAnimation("fill");
}

void onTick(CBlob@ this)
{
  if (this !is null)
  {
    if (this.hasTag("nocollide") && this.getTickSinceCreated() > 30) this.Untag("nocollide");
    if (this.get_u8("state") == 3) this.setInventoryName("Empty waterskin");
    if (this.isInWater() && this.get_u8("state") > 0)
    {
      this.getSprite().PlaySound("wetfall2.ogg");
      this.set_u8("state", 0);
    }
    CSprite@ sprite = this.getSprite();

    if (sprite !is null) sprite.SetFrameIndex(this.get_u8("state"));

    this.inventoryIconFrame = this.get_u8("state");
  }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;

    if (caller.get_u8("thirst") > 0 && this.get_u8("state") < 3)
    {
      CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$waterskin$", Vec2f(0, 0), this, this.getCommandID("drink"), "Drink", params);
    }
    if (caller.isInWater())
    {
      CBitStream params;
	    params.write_u16(this.getNetworkID());
	    caller.CreateGenericButton("$waterskin$", Vec2f(0, 5), this, this.getCommandID("refill"), "Refill waterskin", params); 
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this !is null && solid)
	{
    if (this.hasTag("nocollide"))
    {
      return;
    }
    if ((this.getVelocity().x > 1.0 || this.getVelocity().y > 0.65) || (this.getVelocity().x < -1.0 || this.getVelocity().y < -0.65))
    {
      if (isClient() && this.get_u8("state") < 3 && !this.isAttached())
      {
        this.getMap().SplashEffect(this.getPosition(), Vec2f(0, 3), 8.0f);
        Sound::Play("SplashSlow.ogg", this.getPosition(), 3.0f);
      }
      this.set_u8("state", 3);
    }
  }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd==this.getCommandID("drink"))
    {
        u16 blobid = params.read_u16();
        CBlob@ blob = getBlobByNetworkID(blobid);

        if (blob !is null) 
        {
          if (blob.get_u8("thirst") >= 25)
            blob.set_u8("thirst", blob.get_u8("thirst") - this.get_u8("saturationthirst"));
          else 
            blob.set_u8("thirst", blob.get_u8("thirst") - (this.get_u8("saturationthirst") + (blob.get_u8("thirst") - this.get_u8("saturationthirst"))));
        }
        blob.getSprite().PlaySound("wetfall1.ogg");
        if (this !is null) this.set_u8("state", this.get_u8("state") + 1);
    }
    else if (cmd==this.getCommandID("refill"))
    {
        u16 blobid = params.read_u16();
        CBlob@ blob = getBlobByNetworkID(blobid);
        if (blob !is null)
        {
          blob.getSprite().PlaySound("wetfall2.ogg");
          blob.set_u8("state", 0);
        }
    }
}