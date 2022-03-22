
void onInit(CBlob@ this)
{
  this.maxQuantity = 3;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}

bool doesCollideWithBlob(CBlob@ blob)
{
    return false;
}