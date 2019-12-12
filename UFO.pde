class UFO {
	int x, y;	// position

	UFO(int x, int y){
		this.x = x;
		this.y = y;
	}

	/*-------------------- drawing --------------------*/
	void display() {
		pushMatrix();
			translate(x, y);
			noStroke ();
			fill(142, 142, 142);
			ellipse(0, 0, 80, 42);
			fill(67, 67, 67);
			ellipse(0, 0 - 1.2, 70, 37.5);
			fill(142, 142, 142);
			ellipse(0, 0 - 6, 50, 20);
			fill(65, 132, 183);
			ellipse(0, 0 - 6, 45, 15);
			rect (0 - 22.5, 0 - 25, 45, 20);
			ellipse(0, 0 - 25, 45, 45);
			fill(100, 100, 100);
			ellipse(0, 0 + 10, 7, 7);
			ellipse(0 - 15, 0 + 8, 6, 6);
			ellipse(0 + 15, 0 + 8, 6, 6);
			ellipse(0 - 26, 0 + 3, 4, 4);
			ellipse(0 + 26, 0 + 3, 4, 4);

			fill(255);
			ellipse(0, 0 - 25, 25, 25);
			triangle(0 - 11, 0 - 20, 0 + 11, 0 - 20, 0, 0 - 9);
			fill(0);
			quad(0 - 10, 0 - 27, 0 - 2, 0 - 24, 0 - 2, 0 - 18, 0 - 8, 0 - 20);
			quad(0 + 10, 0 - 27, 0 + 2, 0 - 24, 0 + 2, 0 - 18, 0 + 8, 0 - 20);
		popMatrix();
		detect();
	}
	/*--------------------------------------------------*/

	/*-------------------- judge whether touched --------------------*/
	void detect() {
		if(dist(ship.p.x, ship.p.y, x, y) <= ship.r || dist(ship.p.x, ship.p.y, x + 40, y + 20) <= ship.r || dist(ship.p.x, ship.p.y, x - 40, y + 20) <= ship.r || dist(ship.p.x, ship.p.y, x + 20, y - 45) <= ship.r || dist(ship.p.x, ship.p.y, x - 20, y - 45) <= ship.r) {
			if (!ship.hasShield && !ship.isBroken) {
				ship.breakdown();
			}
		}
	}
	/*----------------------------------------------------------------*/
}