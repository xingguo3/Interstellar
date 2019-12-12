class SavePointBrick extends Brick {
	int index;	// index this save point brick is holding, used in saving scheme
	color beforeC, afterC;	// two colors when touched or not touched
	boolean hasTouched;	//	check whether touched

	SavePointBrick(int x, int y, boolean leftTouchEnabled, boolean rightTouchEnabled, int index) {
		super(x, y, leftTouchEnabled, rightTouchEnabled);
		beforeC = color(255,255,0);
		afterC = color(255);
		hasTouched = false;
		this.index = index;
	}

	/*-------------------- drawing and judge whether touched and change its color --------------------*/
	void depict(color c) {
		fill(c);
		stroke(c);
		strokeWeight(2);
		super.depict();
	}

	void display() {
		if (super.isTopTouched()) {
			ship.v.y = 0;
			ship.p.y = y - ship.r;
			ship.hasJumped = false;
			ship.isFalling = false;
			hasTouched = true;
		}
		else if (super.isLeftTouched() && leftTouchEnabled) {
			ship.p.x = x - ship.r;
			hasTouched = true;
		}
		else if (super.isRightTouched() && rightTouchEnabled) {
			ship.p.x = x + w + ship.r;
			hasTouched = true;
		}
		else if (super.isBottomTouched()) {
			ship.p.y = y + h + ship.r;
			ship.v.y *= -1;
			hasTouched = true;		
		}
		if (!hasTouched) {
			depict(beforeC);
		}
		else {
			depict(afterC);
			ship.save = index;
		}
	}
	/*----------------------------------------------------------------------------------------------*/
}
