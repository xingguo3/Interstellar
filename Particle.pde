class Particle {
	PVector p;	// position of particle
	PVector v;	// velocity of particle
	PVector a;	// acceleration of particle
	PVector g;	// constant gravity-like acceleration 
	int age;	// rising up state
	int originX;	// record the origin x component of particle, it will affect the position when particles are rising up

	Particle(float lx, float ly, float vx, float vy, float ax, float ay, int originX) {
		p = new PVector(lx, ly);
		v = new PVector(vx, vy);
		a = new PVector(ax, ay);
		g = new PVector(0, -1);
		age = 0;
		this.originX = originX;
	}

	/*-------------------- drawing --------------------*/
	void display() {
		noStroke();
		smooth();
		fill(255, 0, 0);
		ellipse(p.x, p.y, 5, 20);
		a.set(originX - p.x, 0, 0);
		a.mult(particleAccDamp);
		v.add(a);
		v.add(g);
		p.add(v);
		age++;
	}
	/*-------------------------------------------------*/

	/*-------------------- judge whether particles are touched --------------------*/
	boolean isTouched() {
		return dist(ship.p.x, ship.p.y, p.x, p.y) <= ship.r;
	}
	/*-----------------------------------------------------------------------------*/
}