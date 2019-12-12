class GravityBall {
	PVector p;	// potistion of the gravity ball
	int r;	// radius of the gravity ball
	boolean isClose;	// check whether the ship is nearby
	boolean counterClock;	// determine in which direction the ship will rotate around

	GravityBall(int x, int y, boolean counterClock) {
		p = new PVector(x, y);
		r = 80;
		isClose = false;
		this.counterClock = counterClock;
	}

	/*-------------------- drawing of gravity ball --------------------*/
	void display() {
		depict();	
		if (dist(ship.p.x, ship.p.y, this.p.x, this.p.y) <= this.r + ship.r + 40) {
			ship.v.set(0, 0);
			ship.isFalling = false;
			isClose = true;
			makeRotate();
		}
		else {
			if (!ship.isFalling) {
				ship.isFalling = true;		
			}
			isClose = false;
		}
	}

	void depict()	{
		pushMatrix();
			translate(p.x, p.y);
			noStroke();
			for (int i = 0; i < 30; i++) {
				fill(186, 105, 253, 30 - i * 0.3);   
				ellipse(0, 0, 2 * r - 30 + 2 * i, 2 * r - 30 + 2 * i);
				fill(0);
				ellipse(0, 0, 2 * r, 2 * r);
			}
		popMatrix();
	}
	/*-------------------------------------------------------------------*/

	/*-------------------- if ship is nearby, make it roate around --------------------*/
	void makeRotate() {
		PVector d = PVector.sub(ship.p, this.p);
		if (counterClock) {
			d.rotate(radians(-4));	
		}
		else {
			d.rotate(radians(4));
		}
		ship.p.set(PVector.add(this.p, d));
		if (d.x < 0) {
			ship.rightDisabled = true;
			ship.leftDisabled = false;
		}
		else {
			ship.rightDisabled = false;
			ship.leftDisabled = true;
		}
	}
	/*---------------------------------------------------------------------------------*/
}