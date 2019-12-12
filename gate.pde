class Gate {
	int x, y, w, h;	// position and dimension
	float angle;	// control the rotating

	Gate(int x, int y) {
		this.x = x;
		this.y = y;
		w = 80;
		h = 40;
		angle = 0;
	}

	/*-------------------- drawing --------------------*/
	void display() {
		if (ship.nEnergy == currentLevelEnergy) {
			detect();
			pushMatrix();
				noFill();
				stroke(255);
				strokeWeight(3);
				translate(x, y);
				for(int i = 0; i < 20; i++) {
					rotate(radians(angle));
					ellipse(0, 0, w, h); 
					angle += 0.01;
				}
			popMatrix();
		}	
	}
	/*--------------------------------------------------*/

	/*-------------------- judge whether ship enters --------------------*/
	void detect() {
		if (dist(ship.p.x, ship.p.y, x, y) <= ship.r) {
			ship.p.set(x, y);
			ship.v.set(0, 0);
			ship.isFalling = false;
			if (currentLevel < 4) {
				levelComplete[currentLevel - 1] = true;
				currentLevel++;
			}
			else {
				game = false;
				end = true;
			}
		}
	}
	/*------------------------------------------------------------------*/
}