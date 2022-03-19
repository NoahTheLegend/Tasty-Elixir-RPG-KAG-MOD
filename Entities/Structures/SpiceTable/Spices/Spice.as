
void onInit(CBlob@ this)
{
    this.getShape().SetRotationsAllowed(true);

    this.set_string("spice", this.getName());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return false;
}