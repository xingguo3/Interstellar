class Bullet {

	int _x;	// original x, not change
	int _y;	// original y, not change
	int x;	// x that will change
	int y;	// y that will change
	int sx;	// horizontal speed of the bullet
	int sy;	// vertical speed of the bullet
	int r;	// size of the bullet
	boolean touched;	// check whether touched

	Bullet(int x, int y, int sx, int sy) {
		_x = x;
		_y = y;
		this.sx = sx; 
		this.sy = sy; 
		this.x = x; 
		this.y = y;
		r = 7;
		touched = false;
	}

	/*-------------------- drawing of bullet --------------------*/
	void display() {
		move();
		pushMatrix();
			translate(x, y);
			fill(244, 2, 2);
			noStroke();
			ellipse(0, 0, 2 * r, 2 * r);
		popMatrix();
		detect();
	}
	/*-----------------------------------------------------------*/

	/*-------------------- movement of the bullet --------------------*/
	void move() {
		x = x + sx;
		y = y + sy;
		// kill bullet when outside screen
		if (x < _x - 800) {
			x = _x;
			y = _y;
		}
		if (y < 4) {
			x = _x;
			y = _y;
		}
		if (x > _x + 800){
			x = _x;
			y = _y;
		}
		if (y > 764) {
			x = _x;
			y = _y;
		}
	}
	/*-----------------------------------------------------------------*/

	/*-------------------- judges whether the bullet is touched by the spaceship --------------------*/
	void detect() {
		if(dist(ship.p.x, ship.p.y, x, y) <= ship.r + r) {
			touched=true;
			if (!ship.hasShield && !ship.isBroken) {
				ship.breakdown();
			}
			x = _x;
			y = _y;
		}
	}
	/*------------------------------------------------------------------------------------------------*/
}
