
//script for a LandCritter - attach to:
// blob
// movement
// 		vars:		f32 swimspeed f32 swimforce


#define SERVER_ONLY

#include "Hitters.as";

shared class CritterVars
{
	Vec2f walkForce;  
	Vec2f runForce;
	Vec2f slowForce;
	Vec2f jumpForce;
	f32 maxVelocity;
};

//blob
void onInit(CBlob@ this)
{
	CritterVars vars;
	//walking vars
	vars.walkForce.Set(15.0f,0.0f);
	vars.runForce.Set(15.0f,0.0f);
	vars.slowForce.Set(5.5f,0.0f);
	vars.jumpForce.Set(0.0f,-34.0f);
	vars.maxVelocity = 3.0f;
	this.set( "vars", vars );
	this.set_s32("flymod",0);
	// force no team
	this.server_setTeamNum(-1);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

//movement
void onInit( CMovement@ this )
{
	//this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags = 0;
	//this.getCurrentScript().runProximityTag = "player";
	//this.getCurrentScript().runProximityRadius = 120.0f;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick( CMovement@ this )
{
    CBlob@ blob = this.getBlob();

	CritterVars@ vars;
	if (!blob.get( "vars", @vars ))
		return;

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);
	bool down = blob.isKeyPressed(key_down);
	Vec2f vel = blob.getVelocity();
	if (left) {
		blob.AddForce(Vec2f( -1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (right) {
		blob.AddForce(Vec2f( 1.0f * vars.walkForce.x, vars.walkForce.y));
	}

	// jump if blocked
	s32 flymod = blob.get_s32("flymod");
	if ((flymod < 15 && !down) || blob.hasAttached()) up=true;
	if (left || right || up)
	{
		Vec2f pos = blob.getPosition();
		CMap@ map = blob.getMap();
		const f32 radius = blob.getRadius();
		
		f32 x = pos.x;
		Vec2f top = Vec2f(x, map.tilesize);
		Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
		Vec2f end;
		
		if (map.rayCastSolid(top,bottom,end))
		{
			f32 y = end.y;
			
			if (y-pos.y<300 || blob.hasAttached())
			{
				if ((flymod < 15 || blob.isInWater()) && (up || (right && map.isTileSolid( Vec2f( pos.x + (radius+1.0f), pos.y ))) || (left && map.isTileSolid( Vec2f( pos.x - (radius+1.0f), pos.y )))))
				{ 
					f32 mod = blob.isInWater() ? 0.23f : 1.0f;
					blob.AddForce(Vec2f( mod*vars.jumpForce.x, mod*vars.jumpForce.y));
				}
			}
		}
	}
	flymod++;
	if (flymod>28) flymod=0;
	blob.set_s32("flymod",flymod);
	CShape@ shape = blob.getShape();	

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}
}
