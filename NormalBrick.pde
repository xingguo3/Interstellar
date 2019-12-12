class NormalBrick extends Brick {

    NormalBrick(int x, int y, boolean leftTouchEnabled, boolean rightTouchEnabled) {
        super(x, y, leftTouchEnabled, rightTouchEnabled);
    }

    /*-------------------- judges whether the normal land point is touched by the spaceship --------------------*/
    void detect() {
        if (super.isBottomTouched()) {
            ship.p.y = y + h + ship.r + 5;
            ship.v.y *= -1;
        }
        else if (super.isLeftTouched() && leftTouchEnabled) {
            ship.p.x = x - ship.r;
        }
        else if (super.isRightTouched() && rightTouchEnabled) {
            ship.p.x = x + w + ship.r;
        }
        else if (super.isTopTouched()) {
            ship.v.y = 0;
            ship.p.y = y - ship.r;
            ship.isFalling = false;
            ship.hasJumped = false;
        }
        else {
            ship.isFalling = true;
        }
    }
    /*---------------------------------------------------------------------------------------------------------*/

    /*-------------------- drawing --------------------*/
    void display() {
        stroke(255);
        noFill();
        strokeWeight(3);
        super.depict();
        detect();
    }
    /*-------------------------------------------------*/
}