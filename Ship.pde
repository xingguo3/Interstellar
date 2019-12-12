class Ship {
	PVector _p; // global position of ship
	PVector p;	// position used in calculation
	PVector v;	// velocity
	PVector g;	// gravity
	PVector[] tails;
	int	r;		// radius
	int outlineWeight;
	int fillColor;
	int outlineColor;
	int nEnergy;	// energy catched
	int end;	// planet end
	int save;	// save index
	int brokenTime;	// track the time when broken
	boolean hasJumped;
	boolean isFalling;
	boolean moveDisabled, leftDisabled, rightDisabled;
	boolean hasShield;
	boolean tailOn;
	boolean isAtFront, isAtEnd;	// track whether the ship is at the front or end of current map
	boolean isBroken;	// check break or not
	Section[] sections;	// breaking effect related

	Ship(int x, int y) {
		_p = new PVector(x, y);
		p = new PVector(0, y);
		r = 18;
		fillColor = color(255);
		v = new PVector(0, 0);
		g = new PVector(0, 0.2);
		nEnergy = 0;
		save = -1;
		hasJumped = false;
		isFalling = false;
		leftDisabled = false;
		rightDisabled = false;
		hasShield = false;
		tailOn = true;
		isAtFront = true;
		isAtEnd = false;
		isBroken = false;
		tails = new PVector[20];
		for(int i = 0; i < tails.length; i++){
			tails[i] = new PVector(p.x, p.y);
		}
		sections = new Section[0];
	}

	/*-------------------------------- set end of map --------------------------------*/
	void setEnd(int end) {
		this.end = end;
	}
	/*--------------------------------------------------------------------------------*/


	/*-------------------- drawing of ship and related components --------------------*/
	void display() {
		if (isBroken) {
			for(int a=sections.length-1;a>0;a--){ 
				sections[a].display(); 
			}
			if (millis() - brokenTime > 1000) {
				isBroken = false;
				if (save == -1) {
					p.set(nbs[0].x + nbs[0].w / 2, nbs[0].y - nbs[0].h / 2);
					if (bbs != null) {
						for (int i = 0; i < bbs.length; i++) {
							if (bbs[i].x >= nbs[0].x) {
								bbs[i].reset();
							}
						}
					}
					if (engs != null) {
						int nTouched = 0;
						for (int i = 0; i < engs.length; i++) {
							if (engs[i].x >= nbs[0].x || engs[i].catchTime > millis()) {
								engs[i].reset();
							}
							else {
								if (engs[i].touched) {
									nTouched++;
								}
							}
						}
						nEnergy = nTouched;
					}
					if (sd != null) {
						if (sd.x >= nbs[0].x) {
							sd.reset();
						}
					}
				}
				else {	
					p.set(spbs[save].x + spbs[save].w / 2, spbs[save].y - spbs[save].h / 2);
					if (bbs != null) {
						for (int i = 0; i < bbs.length; i++) {
							if (bbs[i].x > spbs[save].x) {
								bbs[i].reset();
							}
						}
					}
					if (engs != null) {
						int nTouched = 0;
						for (int i = 0; i < engs.length; i++) {
							if (engs[i].x >= spbs[save].x || engs[i].catchTime > millis()) {
								engs[i].reset();
							}
							else {
								if (engs[i].touched) {
									nTouched++;
								}
							}
						}
						nEnergy = nTouched;
					}
					if (sd != null) {
						if (sd.x >= spbs[save].x) {
							sd.reset();
						}
					}
				}
			}
		}
		else {
			if (millis() - brokenTime > 1500) {
				tailOn = true;
			}
			normal();
		}
	}

	void drawTail() {
		fill(255, 160);
		noStroke();
		beginShape(TRIANGLE_STRIP);
			for (int i = tails.length - 1; i > 0; i--) {
				vertex(tails[i].x, tails[i].y);
				vertex(tails[i].x + i * (tails.length / r) / 2, tails[i].y);
			}
		endShape();
		beginShape(TRIANGLE_STRIP);
			for (int i = tails.length - 1; i > 0; i--) {
				vertex(tails[i].x, tails[i].y);
				vertex(tails[i].x - i * (tails.length / r) / 2, tails[i].y);
			}
		endShape();
	}

	void drawShield() {
		stroke(255);
		strokeWeight(2);
		noFill();
		ellipse(0, 0, 2 * (ship.r + 6), 2 * (ship.r + 6));
	}

	void normal() {
		move();
		for (int i = 1; i < tails.length; i++) {
			tails[i-1].set(tails[i]);
		}
		tails[tails.length - 1].set(p.x, p.y);
		if (isFalling) {
			hasJumped = true;
		}
		if (v.y < 25 && isFalling) v.add(g);
		p.add(v);
		
		if (isAtFront) {
			_p.set(p.x, p.y);
		}
		else {
			_p.y = p.y;
		}

		if (isAtEnd) {
			_p.set(p.x, p.y);
		}
		else {
			_p.y = p.y;
		}
		
		if (_p.y + r <= 0) {
			_p.y = height + r;
			p.y = height + r;
			for(int i = 0; i < tails.length; i++){
				tails[i].set(p.x, p.y);
			}
		}
		else if (_p.y - r >= height) {
			_p.y = 0 - r;
			p.y = 0 - r;
			for(int i = 0; i < tails.length; i++){
				tails[i].set(p.x, p.y);
			}
		}
		pushMatrix();
			noStroke();
			if (!isAtFront) {
				translate(-p.x, 0);
			}
			if (tailOn) {
				drawTail();
			}
		popMatrix();
		pushMatrix();
			translate(_p.x, _p.y);
			noStroke();
			fill(fillColor);
			ellipse(0, 0, 2 * r, 2 * r);
			if (hasShield) {
				drawShield();
				if ((millis() - sd.timeStart) / 1000 >= 3) {
					hasShield = false;
				}
			}	
		popMatrix();

		if (p.x >= 0 && p.x < width / 2) {
			isAtFront = true;
		}
		else if (p.x < 0) {
			p.x = 0;
		}
		else {
			isAtFront = false;
			_p.x = 0;
		}

		if (p.x <= end && end - p.x <= width / 2) {
			isAtEnd = true;
		}
		else if (p.x > end) {
			p.x = end;
		}
		else {
			isAtEnd = false;
			_p.x = 0;
		}
	}

	void breakdown() {
		v.set(0, 0);
		isBroken = true;
		brokenTime = millis();
		tailOn = false;
		if (isAtFront || isAtEnd) {
			float[] centre = {p.x,p.y}; 
			float[] p1 = {p.x-r,p.y-r};
			float[] p2 = {p.x+2*r,p.y};
			float[] p3 = {p.x+2*r,p.y+2*r};
			float[] p4 = {p.x,p.y+2*r};
			divide(8,p1,p2,p3,p4,centre);
		}
		else {
			float[] centre = {_p.x, _p.y}; 
			float[] p1 = {_p.x-r, _p.y-r};
			float[] p2 = {_p.x+2*r, _p.y};
			float[] p3 = {_p.x+2*r, _p.y+2*r};
			float[] p4 = {_p.x, _p.y+2*r};
			divide(8,p1,p2,p3,p4,centre);
		}
	}
	void divide (int pieces, float[] a,float[] b,float[] c,float[] d, float[] centre){ 
		float t1=random(0.1,0.9); 
		float t2=random(0.1,0.9);  
		float[] p1={a[0]+(b[0]-a[0])*t1, a[1]+(b[1]-a[1])*t1}; 
		float[] p2={d[0]+(c[0]-d[0])*t2, d[1]+(c[1]-d[1])*t2};   
		pieces--; 
		if(pieces>0){ 
			divide(pieces, p1, p2, d, a, centre); 
			divide(pieces, b, c, p2, p1, centre); 
		}  
		else { 
			sections = (Section[]) append(sections, new Section(a,b,c,d,centre));  
		} 
	}  
	/*--------------------------------------------------------------------------------*/

	/*------------------------------------------ move control --------------------------------------------*/
	void move() {
		if (!moveDisabled) {
			leftDisabled = false;
			rightDisabled = false;
		}
		if (keyPressed) {
			if (key == CODED) {
				switch (keyCode) {
					case LEFT:
						if (!leftDisabled) {
							v.add(new PVector(-10, 0));						
						}
						break;
					case RIGHT:
						if (!rightDisabled) {
							v.add(new PVector(10, 0));							
						}
						break;
					case UP:
						if (!hasJumped) {
							v.set(0, -20);
							hasJumped = true;
							isFalling = true;
						}
						break;
				}
			}
		}
	}

	/*-------------------- judge whether ship is close to one of gravity balls --------------------*/
	void checkCloseGravityBall() {
		moveDisabled = false;
		for (int i = 0; i < gbs.length; i++) {
			if (gbs[i].isClose) {
				moveDisabled = true;
				break;
			}
		}
	} 

	void reset() {
		v.set(0, v.y);
	}
	/*---------------------------------------------------------------------------------------------*/
	/*----------------------------------------------------------------------------------------------------*/
}