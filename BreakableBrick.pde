class BreakableBrick extends Brick {
	boolean hasTouched;	// record whether the breakable brick is touched

	BreakableBrick(int x, int y, boolean leftTouchEnabled, boolean rightTouchEnabled) {
		super(x, y, leftTouchEnabled, rightTouchEnabled);
		hasTouched = false;
	}

	/*-------------------- judges whether the breakable brick is touched by the spaceship --------------------*/
	void detect() {
		if (super.isTopTouched()) {
			ship.v.y = -20;
			hasTouched = true;
			ship.hasJumped = true;
		}
		else if (super.isLeftTouched() && leftTouchEnabled) {
			ship.p.x = x - ship.r;
		}
		else if (super.isRightTouched() && rightTouchEnabled) {
			ship.p.x = x + w + ship.r;
		}
		else if (isBottomTouched()) {
			ship.v.y = 20;
			hasTouched = true;
			ship.hasJumped = true;
		}
	}
	/*------------------------------------------------------------------------------------------------------*/

	/*------------------------------------- drawing of breakable brick -------------------------------------*/
	void display() {
		if (!hasTouched) {
			depict();
			detect();
		}
	}

	void depict() {
		noFill();
		stroke(255);
		strokeWeight(1);
		super.depict();
	}
	/*------------------------------------------------------------------------------------------------------*/

	/*------------------------ redraw the disappeared brick if the ship has crashed -----------------------*/
	void reset() {
		hasTouched = false;
	}
	/*------------------------------------------------------------------------------------------------------*/
}

