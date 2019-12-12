class StarSky {
	float[] xPos;	// x components of the stars' position
	float[] yPos;	// y components of the stars' position
	float[] s;	// star size
	int a;	// control the loop 
	int p;	// the length of lines when twinkling

	StarSky() {
		xPos = new float[100];
		yPos = new float[100];
		s = new float[100]; 
		a = 0;
		p = 10;
	}

	/*-------------------- initiate the shining stars --------------------*/
	void start() {
		for (int i=0; i < 100; i++) {
			xPos[i] = random(0, 1023);
		}

		for (int i=0; i < 100; i++) {
			yPos[i] = random(0, 767);
		}

		for (int i=0; i < 100; i++) {
			s[i] = random(1, 6);
		}
	}
	/*-------------------------------------------------------------------*/

	/*-------------------- drawing --------------------*/
	void display() {
		fill(255, 200);
		noStroke();
		tracker();
		for (int i=0; i < 100; i++) {
			ellipse(xPos[i], yPos[i], s[i], s[i]);
		}
	}

	void tracker ()
	{
		smooth();
		noStroke();
		a = a + 3;
		if (a == 768) {
			a = 0;
		}
		stroke(255, 200);

		for (int i=0; i < 100; i++) {
			line (xPos[i]+p, yPos[i], xPos[i], yPos[i]);
			line (xPos[i], yPos[i]+p, xPos[i], yPos[i]);
			line (xPos[i], yPos[i], xPos[i]-p, yPos[i]);
			line (xPos[i], yPos[i], xPos[i], yPos[i]-p);
			if (a > yPos[i]-25) {
				p = 5;
			}
			if (a < yPos[i]+25) {
				p = 5;
			}
			if (a < yPos[i]-25) {
				p = 0;
			}
			if (a > yPos[i]+25) {
				p = 0;
			}
			i = i + 1;
		}
	}
	/*-------------------------------------------------*/
}