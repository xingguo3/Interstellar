class Energy{
	int x, y;	// position of the energy
	boolean touched;	// record whether the energy is touched
	int catchTime; // record the time of being catched, used where the energy is in front of save point

	Energy(int x, int y){
		this.x = x;
		this.y = y;
		touched = false;
	}

	/*-------------------- drawing of energy --------------------*/
	void display(){
		if (!touched){
			pushMatrix();
				translate(x, y);
				beginShape();
				fill(238, 201, 0);
				noStroke();
				vertex(0, 0);
				vertex(0 + 20, 0 - 5);
				vertex(0 + 17, 0 - 17);
				vertex(0 + 25, 0 - 25);
				vertex(0 + 5, 0 - 20);
				vertex(0 + 8, 0 - 8);
				endShape(CLOSE);
			popMatrix();
			detect();
		}
	}
	/*------------------------------------------------------------*/

	/*-------------------- judges whether the energy is touched by the spaceship --------------------*/
	void detect() {
		if(dist(ship.p.x, ship.p.y, x , y - 20) <= ship.r || dist(ship.p.x, ship.p.y, x + 20, y) <= ship.r || dist(ship.p.x, ship.p.y, x, y) <= ship.r || dist(ship.p.x, ship.p.y, x + 12, y + 12) <= ship.r || dist(ship.p.x, ship.p.y, x + 25, y + 25) <= ship.r) {
			touched = true;
			catchTime = millis();
			ship.nEnergy++;
		}
	}
	/*-----------------------------------------------------------------------------------------------*/

	/*-------------------- reset to draw --------------------*/
	void reset() {
		touched = false;
	}
	/*-------------------------------------------------------*/
}
