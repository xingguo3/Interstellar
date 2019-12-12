class Shield{
	int x, y; // position
	int timeStart;	// record the time when ship got
	boolean touched; // check whether touched

	Shield(int x, int y){
		this.x = x;
		this.y = y;
		touched = false;
	}

	/*-------------------- drawing --------------------*/
	void display(){
		if (!touched){
			detect();
			pushMatrix();
				translate(x, y);
				fill(200);
				beginShape();
				vertex(0, 0);
				vertex(0 + 20, 0 - 5);
				vertex(0 + 40, 0);
				vertex(0 + 35, 0 + 18);
				vertex(0 + 20, 0 + 28);
				vertex(0 + 5, 0 + 18);
				endShape(CLOSE);

				fill(20);
				beginShape();
				vertex(0 + 3, 0 + 1);
				vertex(0 + 20, 0 - 3);
				vertex(0 + 37, 0 + 1);
				vertex(0 + 34, 0 + 15);
				vertex(0 + 20, 0 + 25);
				vertex(0 + 7, 0 + 15);
				endShape(CLOSE);

				fill(255);
				ellipse(0 + 20, 0 + 10, 12, 12);
			popMatrix();
		}
	}
	/*------------------------------------------------*/

	/*-------------------- judge whether touched --------------------*/
	void detect() {
		if(dist(ship.p.x, ship.p.y, x, y) <= ship.r || dist(ship.p.x, ship.p.y, x + 15, y + 15) <= ship.r || dist(ship.p.x, ship.p.y, x + 7, y + 7) <= ship.r){
			touched = true;
			ship.hasShield = true;
			timeStart = millis();
		}
	}
	/*---------------------------------------------------------------*/

	/*-------------------- reset the state to redraw --------------------*/
	void reset() {
		touched = false;
	}
	/*-------------------------------------------------------------------*/
}
