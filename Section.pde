class Section { 
	float vx,vy,an,van;	// velocity of sections along x direction, y direction and the angular velocity
	float[] midpoint; // midpoint of the ship
	boolean stop; // stop all actions when the sections have been out of the screen
	float[] a, b, c, d;	// 4 points to locate the ship
	float dx, dy;	// displacement of sections along x direction, y direction and the change of rotating angle

	Section(float[] temA, float[] temB, float[] temC, float[] temD, float[] centre){  
		an=0; 
		dx = 0;
		dy = 0;
		a = temA;
		b = temB;
		c = temC;
		d = temD;
		float v = random(1,20);
		midpoint = new float[2]; 
		midpoint[0] = (a[0]+b[0]+c[0]+d[0])/4; 
		midpoint[1] = (a[1]+b[1]+c[1]+d[1])/4;  
		float directionOfV = atan2(midpoint[1]-centre[1],midpoint[0]-centre[0]); 
		directionOfV+=radians(random(-5,5)); 
		vx=cos(directionOfV)*v; 
		vy=sin(directionOfV)*v; 
		van=radians(random(-10,10)); 
		stop = false; 
	}

	/*-------------------- drawing and moving apart --------------------*/
	void display(){ 
		if(!stop){ 
			an+=van; 
			vx*=1.035; 
			vy*=1.0351;  
			vy+=0.01; 
			dx+=vx; 
			dy+=vy;

			fill(color(255)); 
			beginShape();  
			float[] A = spin(an, a);
			vertex(dx+A[0],dy+A[1]); 
			float[] B = spin(an, b);
			vertex(dx+B[0],dy+B[1]); 
			float[] C = spin(an, c); 
			vertex(dx+C[0],dy+C[1]); 
			float[] D = spin(an, d); 
			vertex(dx+D[0],dy+D[1]);  
			endShape(CLOSE);

			if(vy>height+30 || vy<-30 || vx<-30 || vx> width+30){ 
				stop=true;   
			} 

		}  
	}
	/*------------------------------------------------------------------*/

	//*-------------------- spin each section --------------------*/
	float[] spin(float angle, float[] point) {

		//change into polar coordinate system
		float theta, r;
		theta=atan2(point[0]-midpoint[0], point[1]-midpoint[1]);  
		r=dist(midpoint[0],midpoint[1],point[0],point[1]);

		angle+=theta;
		float[] temp = new float[2];
		temp[0] = cos(angle)*r + midpoint[0];
		temp[1] = sin(angle)*r + midpoint[1];
		return temp;
	}
	/*-----------------------------------------------------------*/
} 