void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");

    this.set_u8("saturationhunger", 8);
    this.set_u8("saturationthirst", 1);
    this.set_u8("antisaturationthirst", 2);
}
