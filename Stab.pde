class Stab {
	int x, y, w, h;	// position and dimension
	int tipx, tipy;	// position of tip vertex
	boolean up;	// indicate the direction of the stab

	Stab(int x, int y, int h, boolean up) {
		this.x = x;
		this.y = y;
		this.h = h;
		w = 52;
		this.up = up;
		if (up) {
			tipx = x + w / 2;
			tipy = y - h;
		}
		else {
			tipx = x + w / 2;
			tipy = y + 50 + h;
		}
	}

	/*-------------------- drawing --------------------*/
	void depict() {
		fill(255);
		noStroke();
		pushMatrix();
			if (up) {
				translate(x, y);
				triangle(0, 0, w / 2, -h, w, 0);	
			}
			else {
				translate(x, y + 50);
				triangle(0, 0, w / 2, h, w, 0);
			}
		popMatrix();
	}
	void display() {
		detect();
		depict();
	}
	/*-------------------------------------------------*/

	/*-------------------- judge whether touched --------------------*/
	void detect() {
		if ((ship.p.x < x && ship.p.x + ship.r >= x) || (ship.p.x >= x && ship.p.x - ship. r <= x + w)) {
			if (up) {
				if (ship.p.y < y && ship.p.y + ship.r >= tipy) {
					if (dist_ship_line(ship.p.x, ship.p.y, x, y, tipx, tipy) <= ship.r || ship.p.x >= x && ship.p.x <= x + w) {
						if (!ship.hasShield && !ship.isBroken) {
							ship.breakdown();
						}
					}
				}
			}
			else {
				if (ship.p.y > y + h && ship.p.y - ship.r <= tipy) {
					if (dist_ship_line(ship.p.x, ship.p.y, x, y, tipx, tipy) <= ship.r || ship.p.x >= x && ship.p.x <= x + w) {
						if (!ship.hasShield && !ship.isBroken) {
							ship.breakdown();
						}
					}
				}
			}
		}
	}
	/*-------------------------------------------------------------*/

	/*-------------------- calculate the distance between ship(a circle actually) and a straight line --------------------*/
	float dist_ship_line(float x, float y, int x1, int y1, int x2, int y2) {
		int a = y2 - y1;
		int b = x2 - x1;
		return abs(a * (x - x1) + b * (y1 - y)) / sqrt(sq(a) + sq(b));
	}
	/*---------------------------------------------------------------------------------------------------------------------*/
}
