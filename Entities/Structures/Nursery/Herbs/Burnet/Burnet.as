void onInit(CBlob@ this)
{
    this.set_u8("saturationhunger", 0);
    this.set_u8("saturationthirst", 1);
    this.set_u8("antisaturationthirst", 26);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (caller.isMyPlayer() && this.isAttached())
    {
        CBitStream@ params;
        if (params is null) return;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("use"), "Use " + this.getName(), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("use"))
    {
        u16 blobid = params.read_u16();
        CBlob@ blob = getBlobByNetworkID(blobid);

        if (blob !is null)
        {
            
        }
    }
}