class Wormhole {
	Wormhole target;	// the target outlet this wormhole point to
	PVector p;	// position
	int r;	// radius
	int fillColor;
	boolean hasTransported; // track whether this wormhole has tranport the ship

	Wormhole(int x, int y) {
		p = new PVector(x, y);
		r = 30;
		fillColor = color(128);
		hasTransported = false;
	}

	/*-------------------- connect the target wormhole --------------------*/
	void connect(Wormhole target) {
		this.target = target;
	}
	/*---------------------------------------------------------------------*/

	/*-------------------- drawing and detect whether ship enters --------------------*/
	void display() {
		depict();
		if (dist(ship.p.x, ship.p.y, this.p.x, this.p.y) < this.r) {
			transport();
			for (int i = 0; i < ship.tails.length; i++) {
				ship.tails[i].set(ship.p);
			}
		}
		else {
			hasTransported = false;
		}
	}

	void depict() {
		pushMatrix();
			translate(p.x, p.y);
			noStroke();
			for (int i=0; i<5; i++) {
				fill(255, 80 - i);   
				ellipse(0, 0, 2 * r - i, 2 * r - i);
			}
		popMatrix();
	}
	/*------------------------------------------------*/

	/*-------------------- transport the ship --------------------*/
	void transport() {
		if (!hasTransported) {
			target.hasTransported = true;
			ship.p.set(target.p);
		}
	}
	/*------------------------------------------------------------*/
}