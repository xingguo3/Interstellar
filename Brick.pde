class Brick {
	int x, y;	// poition of the brick
	int w, h;	// width and height of the brick
	boolean leftTouchEnabled, rightTouchEnabled; // record whehter there is another brick on its left or right to enable or disable the touching effect

	Brick(int x, int y, boolean leftTouchEnabled, boolean rightTouchEnabled) {
		this.x = x;
		this.y = y;
		w = 50;
		h = 50;
		this.leftTouchEnabled = leftTouchEnabled;
		this.rightTouchEnabled = rightTouchEnabled;
	}

	/*---------------------------- drawing of brick ----------------------------*/
	void depict() {
		pushMatrix();
			translate(x, y);
			rect(0, 0, w, h);
		popMatrix();
	}
	/*--------------------------------------------------------------------------*/

	/*------------------ judges whether the brick is touched by the spaceship -----------------*/
	boolean isTopTouched() {
		return (ship.p.x >= x && ship.p.x <= x + w) && (ship.p.y <= y && ship.p.y + ship.r + 10 >= y);
	}

	boolean isBottomTouched() {
		return (ship.p.x >= x && ship.p.x <= x + w) && (ship.p.y > y && ship.p.y - ship.r <= y + h);
	}

	boolean isLeftTouched() {
		return (ship.p.y >= y && ship.p.y <= y + h) && (ship.p.x <= x && ship.p.x + ship.r >= x);
	}

	boolean isRightTouched() {
		return (ship.p.y >= y && ship.p.y <= y + h) && (ship.p.x > x && ship.p.x - ship.r <= x + w);
	}
	/*-----------------------------------------------------------------------------------------*/
}
