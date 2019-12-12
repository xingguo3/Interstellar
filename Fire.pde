class Fire {
	int x, y;	// position of the bottom of fire
	ArrayList particles; // basic elements to produce a fire

	Fire(int x, int y) {
		this.x = x;
		this.y = y;
		particles = new ArrayList();
		
	}

	/*-------------------- drawing of fire --------------------*/
	void display() {
		detect();
		if (particles.size() < maxParticles) {
			for (int i = 0; i < addParticlesPerFrame; i++) {
				particles.add(freshParticle());
			}
		}

		Particle p;
		for (int i = 0; i < particles.size(); i++) {
			p = (Particle)particles.get(i);
			p.display();
			if (p.age > maxParticleAge) {
				particles.set(i, freshParticle());
			}
		}
		peak = 3;
	}
	/*----------------------------------------------------------*/

	/*-------------------- regenerate the particle --------------------*/
	Particle freshParticle() {
		return new Particle(x, y, random(-3, 3), random(-peak, 0), 0, 0, x);
	}
	/*-----------------------------------------------------------------*/

	/*-------------------- judges whether the fire is touched by the spaceship --------------------*/	
	void detect() {
		for (int i = 0; i < particles.size(); i++) {
			if (((Particle)particles.get(i)).isTouched()) {
				if (!ship.hasShield && !ship.isBroken) {
					ship.breakdown();
				}
				break;
			}
		}
	}
	/*---------------------------------------------------------------------------------------------*/
}