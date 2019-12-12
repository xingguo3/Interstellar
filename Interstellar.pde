<<<<<<< HEAD
import beads.*;

/*-------------------------------------- Developer options ----------------------------------------*/
final boolean DEBUGMODE = false;
/*-------------------------------------------------------------------------------------------------*/

/*-------------------------------------- Screen dimensions ----------------------------------------*/
int winWIDTH;
int winHEIGHT;
/*-------------------------------------------------------------------------------------------------*/

/*-------------------------------------- Startup variables ----------------------------------------*/
PImage[] images;
PFont [] f;
float ang1;
boolean mainpage, game, pause;
int texts, bsw, bsh, buttons, instructionspb, backinfo, backpic, backpicc, spacesw, spacesh;
/*-------------------------------------------------------------------------------------------------*/

/*--------------------------------- Variables in ending of game -----------------------------------*/
boolean end;	// track whether the game is finished
float degChange;	// control the rotate of new earth
int rChange, alpha;	// new earth components
/*---------------------------------------------------------------------------------------------------*/


/*------------------------------------- Level elements setup control --------------------------------*/
boolean[] levelSetup;	// track setup state of every level
boolean[] levelComplete;	// track completing state of every level
int currentLevel;	// record current level
int currentLevelEnergy;	// record the number of energies to complete current level
int gameStartTime;	// track the game starting time
int pauseDuration;	// record how long the game is paused
int[] timer;	// record the time cost
/*---------------------------------------------------------------------------------------------------*/


/*----------------------------------------- Fire related control ------------------------------------*/
float particleAccDamp;	// particle acceleration control
int maxParticles;	// maximum particles to generate fire
int maxParticleAge;	// age threshold
int addParticlesPerFrame;	// control the number of particles added every frame
/*---------------------------------------------------------------------------------------------------*/


/*----------------------- Background music related and also used in fire animation ------------------*/
AudioContext ac;
PeakDetector beatDetector;
Gain g;
SamplePlayer player;
ShortFrameSegmenter sfs;
FFT fft;
PowerSpectrum ps;
SpectralDifference sdd;	// all above are used to analyze the background music and detect beats to generate flickering effect of fire
int peak;	// change the peak of fire
int time;	// record the time for audio processing
/*---------------------------------------------------------------------------------------------------*/


/*--------------------------------------- Game elements declaration ---------------------------------*/
StarSky bg;
Ship ship;
Fire[] fire;
NormalBrick[] nbs;
BreakableBrick[] bbs;
SavePointBrick[] spbs;
Stab[] stabs;
GravityBall[] gbs;
Wormhole[] whs;
UFO[] ufos;
Bullet[] blts;
Energy[] engs;
Shield sd;
Gate gt;
/*----------------------------------------------------------------------------------------------------*/

void setup() {
	winWIDTH = 1024;
	winHEIGHT = 768;
	frameRate(50);
	size(winWIDTH, winHEIGHT);
	images = new PImage[27];
	f =new PFont[25];
	timer = new int[2];
	pauseDuration = 0;

	game = false;
	end = true;
	pause = false;
	ang1=0;
	texts=40;
	mainpage=true;
	bsw=80; 
	bsh=80;
	buttons=0;
	instructionspb=0;
	spacesw=50;
	spacesh=300;
	backinfo=0; // 0  nothing   1 -x  next button   last page dont have
	currentLevel = -1;
	noCursor();
	size(1024, 768);  
	loadimages();
	loadfonts();

	levelSetup = new boolean[4];
	levelComplete = new boolean[4];
	// levelCompleteTime = new int[4];
	for (int i = 0; i < levelSetup.length; i++) {
		levelSetup[i] = false;
	}

	if (DEBUGMODE) {
		for (int i = 0; i < levelComplete.length; i++) {
			levelComplete[i] = true;
		}
	}
	else {
		for (int i = 0; i < levelComplete.length; i++) {
			levelComplete[i] = false;
		}
	}

	bg = new StarSky();
	bg.start();

	particleAccDamp = 0.04;
	maxParticles = 2000;
	maxParticleAge = 15;
	addParticlesPerFrame = 30;
	time = millis();
	ac = new AudioContext();
	g = new Gain(ac, 2, 0.5);
	ac.out.addInput(g);
	player = null;
	try
	{
		player = new SamplePlayer(ac, new Sample(sketchPath("") + "data/oneday.mp3"));
		player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
		g.addInput(player);
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}

	sfs = new ShortFrameSegmenter(ac);
	sfs.setChunkSize(2048);
	sfs.setHopSize(441);
	sfs.addInput(ac.out);
	fft = new FFT();
	ps = new PowerSpectrum();
	sfs.addListener(fft);
	fft.addListener(ps);
	sdd = new SpectralDifference(ac.getSampleRate());
	ps.addListener(sdd);
	beatDetector = new PeakDetector();
	sdd.addListener(beatDetector);
	beatDetector.setThreshold(0.00005f);
	beatDetector.setAlpha(0.98f);
	beatDetector.addMessageListener
	(
		new Bead() {
			protected void messageReceived(Bead b)
			{
				peak = 10;
			}
		}
	);
	ac.out.addDependent(sfs);
	ac.start();

	
	degChange = 0;
	rChange = 0;
}

void draw() {
	/*------------------------------------- Game startup screen --------------------------------------*/
	if (!game && !end) {
		welcome();
	}
	/*------------------------------------------------------------------------------------------------*/
	else if (game && !end) {
		/*--------------------------------------- Level selection ----------------------------------------*/
		switch (currentLevel) {
			case 1 :
				level_1_setup();
				level_1_draw();
			break;
			case 2 :
				level_2_setup();
				level_2_draw();
			break;
			case 3 :
				level_3_setup();
				level_3_draw();
			break;
			case 4 :
				level_4_setup();
				level_4_draw();
			break;
		}
		/*------------------------------------------------------------------------------------------------*/


		/*----------------------------------------- Game record ------------------------------------------*/
		fill(255);
		timer[0] = millis() / 1000 - gameStartTime;
		timer[1] = timer[0] / 60;
		timer[0] %= 60;
		String secstr = "";
		String minstr = "";
		if (timer[0] <= 9) {
			secstr = "0" + timer[0];
		}
		else {
			secstr += timer[0];
		}

		if (timer[1] <= 9) {
			minstr = "0" + timer[1];
		}
		else {
			minstr += minstr;
		}
		textFont(createFont("AgencyFB-Bold", 25));
		textSize(25);
		text("Time elapse: " + minstr + ":" + secstr, 20, 30);
		textSize(25);
		text("Energy catched: " + ship.nEnergy + " / " + currentLevelEnergy, 20, 60);
		/*------------------------------------------------------------------------------------------------*/
	}
	else if (end) {
		endPage();
		if (mousePressed || keyPressed) {
			game = false;
			end = false;
			pause = false;
			ang1=0;
			texts=40;
			mainpage=true;
			bsw=80; 
			bsh=80;
			buttons=0;
			instructionspb=0;
			spacesw=50;
			spacesh=300;
			backinfo=0;
			currentLevel = -1;
			for (int i = 0; i < levelSetup.length; i++) {
				levelSetup[i] = false;
			}
		}
	}
}
	
void loadimages() {
	for (int i=1; i<27; i++) {
		images[i]=loadImage("Picture"+i+".png");
	}
	images[0] = loadImage("startup.jpg");
}

void loadfonts() {
	for (int i=1; i<6; i++) {
		f[i]=loadFont("Algerian-48.vlw");
	}
	f[0]=loadFont("ARCHRISTY-48.vlw");
	f[8]=loadFont("Algerian-48.vlw");
	//out team
	//name 
	f[9]=loadFont("BritannicBold-48.vlw");
	//instructions
	f[6]=loadFont("ARDESTINE-48.vlw");
	f[10]=loadFont("ArialRoundedMTBold-48.vlw");
}

void welcome() {
	ang1+=0.4;
	backpic=millis();
	/*---------------------------------background title and picture----------------------------------*/
	pushMatrix();
	translate(512, 384);
	rotate((radians(0.5*ang1)));
	image(images[0], -1024, -768, 2048, 1536);
	popMatrix();  
	fill(#D5F3E9);
	textFont(f[0], 100);
	textAlign(CENTER);
	text("Interstellar", 512, 160);
	/*------------------------------------------------------------------------------------------------*/
	if (mainpage==true) {
		startup();
		link();
	}
	/*-------------------------------------Game Interface--different button---------------------------*/
	if (buttons==1) {
		backgroundstory();
		image(images[6], 907, 600, bsw, bsh);
	} else if (buttons ==2) {
		instructions();
		image(images[6], 907, 600, bsw, bsh);
	} else if (buttons==3) {
		playnow();
		image(images[6], 907, 600, bsw, bsh);
	} else if (buttons ==4) {
		ourteam();
		image(images[6], 907, 600, bsw, bsh);
	} else if (buttons==5) {
		exit();
	}
	/*------------------------------------------------------------------------------------------------*/

	/*--------------------------------- instruction , button next and back ------------------------------------------*/

	/*---------------------------------- go to next page instructions ----------------------------------*/
	if (instructionspb==1) {
	image(images[13], 200, 325, 560, 308);
	image(images[15], 720, 605, 120, 40);
	fill(#110205);
	textFont(f[6], 45);
	textAlign(LEFT);
	text("Game Tips", 222, 300);
	}
	if (instructionspb==2) {
		image(images[12], 500, 380, 300, 200);
		image(images[14], 720, 605, 120, 40);
		fill(#110205);
		textFont(f[6], 45);
		textAlign(LEFT);
		text("Game Tips", 222, 300);
	}
	/*--------------------------------------------------------------------------------------------------*/

	/*---------------------------------- go to previous page instructions -----------------------------*/
	if (backinfo==1) {
		image(images[14], 730, 605, 120, 40);
		fill(#120222);
		textFont(f[10], 25);
		textAlign(LEFT);
		text("In the year 2127, due to the greed of humanity, \nhuman beings have no way to halt the ecological \nand environmental deterioration. Because of the \n pollution produced by human activities, the \necological balance is destructed while the natural \nresources almost dry up.", 202, 370);

	}
	if (backinfo==2) {
		image(images[14], 730, 605, 120, 40);
		image(images[18], 190, 325, 440, 310);
		if ((millis()-backpicc)>2000)
			image(images[17], 190, 325, 440, 310);
		if ((millis()-backpicc)>2900)
			image(images[17], 390, 325, 220, 310);
		if ((millis()-backpicc)>3800)
			image(images[17], 190, 325, 220, 310);
		if ((millis()-backpicc)>5500)
			image(images[19],190, 325, 440, 310);
		if ((millis()-backpicc)>6800) {
			textFont(f[10], 25);
			textAlign(LEFT);
			text("For the sake of\nsurvival and \nreproduction, \npeople must \nimmigrate to \na new planet.", 650, 350);
		}
	}
	if (backinfo==3) {
		fill(#120222);
		textFont(f[10], 25);
		textAlign(LEFT);
		text("So, people build an advanced \nspaceship to travel in space.", 430, 380);
		image(images[21], spacesw+190, spacesh+20, 100, 300);
		if ((millis()-backpicc)>2500)
			text("Bearing hope of all human \nbeings and the mission to \nfind a new planet, astronauts \nstart to explore the universe.", 430, 480);
		if ((millis()-backpicc)>6000)
			spacesh-=20;;
	}
	/*------------------------------------------------------------------------------------------------*/
	/*--------------------------------------------------------------------------------------------------------------*/
	image(images[5], mouseX-15, mouseY-15, 60, 60);
}

/*---------------------------- menu pange interface ---------------------------*/

/*---------------------------Planet images ----------------------------*/
void startup() {

	textAlign(LEFT);
	pushMatrix(); 
		translate(280, 260);
		rotate(radians(ang1));
		image(images[2], -35, -35, 70, 70);
	popMatrix();

	pushMatrix();
		translate(278, 358);
		rotate(radians(ang1*0.5));
		image(images[4], -35, -35, 70, 70);
	popMatrix();

	pushMatrix();
		translate(280, 460);
		rotate(radians(-ang1));
		image(images[3], -35, -35, 70, 70 );
	popMatrix();

	pushMatrix();
		translate(279, 560);
		rotate(radians(-ang1*0.5));
		image(images[1], -34, -34, 68, 68);
	popMatrix();

	pushMatrix();
		translate(280, 660);
		rotate(radians(ang1*0.8));
		image(images[10], -33, -33, 66, 66);
	popMatrix();
}
/*---------------------------------------------------------------------*/

void link() {
	if (mainpage) {
		/*------------------------------- start to play -------------------------------*/
		if (mouseX<667&&mouseX>408&&mouseY>244&&mouseY<276) {
			texts=43;
			if (mousePressed==true) {
				fill(#DDEE00);
				buttons=3;
				mainpage=false;
				currentLevel = 0;
			}
		} else {
			texts=40;
			fill(#FAEAFC);
		}
		textFont(f[1], texts);
		text("Start Game", 410, 273);
		/*-----------------------------------------------------------------------------*/

		/*------------------------------- game tips -------------------------------*/
		if (mouseX<623&&mouseX>409&&mouseY>343&&mouseY<381) {
			texts=43;
			if (mousePressed==true) {
				fill(#DDEE00);
				buttons=2;
				mainpage=false;
				instructionspb=2;
			}
		} else {
			texts=40;
			fill(#FAEAFC);
		}
		textFont(f[2], texts);
		text("Game Tips", 410, 375);
		/*--------------------------------------------------------------------------*/

		/*------------------------------- background story -------------------------------*/
		if (mouseX<813&&mouseX>409&&mouseY>443&&mouseY<476) {
			texts=43;
			if (mousePressed==true) {
				fill(#DDEE00);
				buttons=1;
				mainpage=false;
				backinfo=1;
			}
		} else {
			fill(#FAEAFC);
			texts=40;
		}
		textFont(f[3], texts);
		text("Background Story", 410, 472);
		/*---------------------------------------------------------------------------------*/

		/*------------------------------- our team info -------------------------------*/
		if (mouseX<610&&mouseX>411&&mouseY>545&&mouseY<583) {
			texts=43;
			if (mousePressed==true) {
				fill(#DDEE00);
				buttons=4;
				mainpage=false;
			}
		} else {
			fill(#FAEAFC);
			texts=40;
		}
		textFont(f[4], texts);
		text("Our Team", 410, 577); 
		/*------------------------------------------------------------------------------*/

		/*------------------------------- exit -------------------------------*/
		if (mouseX<503&&mouseX>409&&mouseY>649&&mouseY<685) {
			texts=43;
			if (mousePressed==true) {
				fill(#DDEE00);
				buttons=5;
				mainpage=false;
			}
		} else {
			texts=40;
			fill(#FAEAFC);
		}
		textFont(f[8], texts);
		text("Exit", 410, 680);
		/*---------------------------------------------------------------------*/
	}	
}

void mouseClicked() {
	/*-------------------------------------Back to game interface-------------------------------------*/
	if (mouseX<982&&mouseX>909&&mouseY>609&&mouseY<676) {
		mainpage=true;
		buttons=0;
		instructionspb=0;
		backinfo=0;
		spacesw=20;
		spacesh=300;
		currentLevel = -1;
	}
	/*------------------------------------------------------------------------------------------------*/

	/*------------------------------instructions next/previous page-----------------------------------*/
	if (instructionspb!=0) {
		if (mouseX<845&&mouseX>720&&mouseY>605&&mouseY<645) {
			if (instructionspb==2)
				instructionspb=1;
			else
				instructionspb=2;
		}
	}
	/*------------------------------------------------------------------------------------------------*/

	/*----------------background story-control the appearance of different pictures-------------------*/
	if (backinfo!=0&&backinfo<3) {
		if (mouseX<850&&mouseX>727&&mouseY>605&&mouseY<645)
			backinfo++;
		if (backinfo==2)
			backpicc=millis();
		if (backinfo==3)
			backpicc=millis();
	}
	/*------------------------------------------------------------------------------------------------*/

	/*---------------------------start game-to choose different level---------------------------------*/
	if (currentLevel!=-1 && !game) {
		if (mouseX<675+65&&mouseX>255+65&&mouseY>346&&mouseY<399) {
			currentLevel=1;
			mainpage = false;
			game = true;
			gameStartTime = millis() / 1000;
		}
		else if (levelComplete[0] && mouseX<675+65&&mouseX>255+65&&mouseY>418&&mouseY<475) {
			currentLevel=2;
			mainpage = false;
			game = true;
			gameStartTime = millis() / 1000;
		}
		else if (levelComplete[1] && mouseX<675+65&&mouseX>255+65&&mouseY>491&&mouseY<546) {
			currentLevel=3;
			mainpage = false;
			game = true;
			gameStartTime = millis() / 1000;
		}
		else if (levelComplete[2] && mouseX<675+65&&mouseX>255+65&&mouseY>566&&mouseY<620) {
			currentLevel=4;
			mainpage = false;
			game = true;
			gameStartTime = millis() / 1000;
		}
	}
	/*------------------------------------------------------------------------------------------------*/

	/*--------------------------------------Game stop--return or restart------------------------------*/
	if (pause) {
		if (mouseX<640&&mouseX>560&&mouseY>377&&mouseY<406) {  // return
			mainpage = true;
			game = false;
			buttons = 0;
			instructionspb = 0;
			backinfo = 0;
			spacesw = 20;
			spacesh = 300;
			for (int i = 0; i < levelSetup.length; i++) {
				levelSetup[i] = false;
			}
			currentLevel=-1;
			loop();
			redraw();
			noCursor();
			pause = false;
		}

		if (mouseX<515&&mouseX>390&&mouseY>377&&mouseY<406) {  // restart
			for (int i = 0; i < levelSetup.length; i++) {
				levelSetup[i] = false;
			}
			currentLevel = 1;
			gameStartTime = millis() / 1000;
			loop();
			redraw();
			noCursor();
			pause = false;
		}
	}
	/*------------------------------------------------------------------------------------------------*/	
}

void backgroundstory() {
	image(images[11], 145, 220, 730, 450);
	image(images[7], 140, 220, 740, 450);
	fill(#110205);
	textFont(f[6], 45);
	textAlign(LEFT);
	text("Background Story", 202, 300);
}

void instructions() {
	image(images[11], 145, 220, 730, 450);
	image(images[7], 140, 220, 740, 450);
	fill(#110205);
	textFont(f[6], 45);
	textAlign(LEFT);
	text("Game Tips", 222, 300);
	//button next
	fill(#FF11DD);
	textFont(f[9], 30);
	textAlign(LEFT);
	textLeading(40);
	text("Basically, player uses arrows to control \nthe space ship to \ncomplete missions. \nOnce you start the \ngame, you can press \nspace bar to \npause the game. \nPress space again and continues.", 220, 345);
}

void playnow() {
	image(images[16], 255 + 65, 346, 420, 53);
	image(images[23], 255 + 65, 418, 420, 53);
	image(images[24], 255 + 65, 491, 420, 53);
	image(images[25], 255 + 65, 566, 420, 53);
	image(images[7], 140, 220, 740, 450);
	if (!levelComplete[0]) {
		image(images[26], 180 + 65, 415, 57, 57);
	}
	if (!levelComplete[1]) {
		image(images[26], 180 + 65, 488, 57, 57);
	}
	if (!levelComplete[2]) {
		image(images[26], 180 + 65, 563, 57, 57);
	}
	
	fill(#110205);
	textFont(f[6], 45);
	textAlign(LEFT);
	text("Play Now", 222, 300);
	//choose different levels
}

void ourteam() {
	image(images[11], 145, 220, 730, 450);
	image(images[7], 140, 220, 740, 450);
	fill(#110205);
	textFont(f[6], 45);
	textAlign(LEFT);
	text("Our Team", 222, 300);
	fill(#122123);
	textFont(f[9], 35);
	textAlign(LEFT);
	textLeading(50);
	text("CM          TAN Bowen\nCM          SHEN Jiahui\nECE         LI Jiaoda\nCSC         GUO Xing", 280, 388);
}
/*-----------------------------------------------------------------------------*/


/*----------------------------------------- Game main functions ------------------------------------*/
void level_1_setup() {
	if (!levelSetup[0]) {
		gbs = null;
		fire = null;
		ufos = null;
		blts = null;
		bbs = null;
		sd = null;

		ship = new Ship(0, 500 - 16);
		nbs = new NormalBrick[57];
		stabs = new Stab[36];
		spbs = new SavePointBrick[1];
		engs = new Energy[1];
		currentLevelEnergy = engs.length;

		nbs[0] = new NormalBrick(-20, 500, true, false);
		for (int i = 1; i <= 3; i++) {
			nbs[i] = new NormalBrick(-20 + i * nbs[0].w, 500, false, false);
		}
		nbs[4] = new NormalBrick(nbs[3].x + nbs[0].w, 500, false, true);
		for (int i = 5; i <= 6; i++) {
			nbs[i] = new NormalBrick(nbs[4].x, 500 - (i - 4) * nbs[0].w, true, true);
		}
		nbs[7] = new NormalBrick(nbs[4].x, nbs[6].y - nbs[0].w, true, false);
		for (int i = 8; i <= 10; i++) {
			nbs[i] = new NormalBrick(nbs[7].x + (i - 7) * nbs[0].w, nbs[7].y, false, false);
		}
		nbs[11] = new NormalBrick(nbs[10].x + nbs[0].w, nbs[7].y, false, true);
		for (int i = 12; i <= 13; i++) {
			nbs[i] = new NormalBrick(nbs[11].x, nbs[11].y + (i - 11) * nbs[0].w, true, true);
		}
		nbs[14] = new NormalBrick(nbs[11].x, nbs[13].y + nbs[0].w, true, false);
		for (int i = 15; i <= 16; i++) {
			nbs[i] = new NormalBrick(nbs[14].x + (i - 14) * nbs[0].w, nbs[14].y, false, false);
		}
		nbs[17] = new NormalBrick(nbs[16].x + nbs[0].w, nbs[16].y, false, true);
		nbs[18] = new NormalBrick(nbs[17].x + nbs[0].w * 8, nbs[17].y - nbs[17].h, true, false);
		nbs[19] = new NormalBrick(nbs[18].x + nbs[0].w, nbs[18].y, false, false);
		nbs[20] = new NormalBrick(nbs[19].x + nbs[0].w, nbs[19].y, false, true);

		nbs[21] = new NormalBrick(nbs[20].x + nbs[0].w * 9, nbs[17].y + nbs[17].h, true, false);
		for (int i = 22; i <= 27; i++) {
			nbs[i] = new NormalBrick(nbs[21].x + (i - 21) * nbs[0].w, nbs[21].y, false, false);
		}
		nbs[28] = new NormalBrick(nbs[27].x + nbs[0].w, nbs[27].y, false, true);
		nbs[29] = new NormalBrick(nbs[28].x + nbs[0].w * 8, nbs[28].y - nbs[0].h * 7, true, false);
		nbs[30] = new NormalBrick(nbs[29].x + nbs[0].w, nbs[29].y, false, false);
		nbs[31] = new NormalBrick(nbs[30].x + nbs[0].w, nbs[30].y, false, true);

		nbs[32] = new NormalBrick(nbs[31].x + nbs[0].w * 3, nbs[31].y + nbs[0].h * 4, true, false);
		nbs[33] = new NormalBrick(nbs[32].x + nbs[0].w, nbs[32].y, false, false);
		nbs[34] = new NormalBrick(nbs[33].x + nbs[0].w, nbs[33].y, false, false);

		nbs[35] = new NormalBrick(nbs[34].x + nbs[0].w * 2, nbs[34].y, false, false);
		nbs[36] = new NormalBrick(nbs[35].x + nbs[0].w, nbs[35].y, false, false);
		nbs[37] = new NormalBrick(nbs[36].x + nbs[0].w, nbs[36].y, false, true);

		nbs[38] = new NormalBrick(nbs[37].x + nbs[0].w * 5, nbs[37].y - nbs[0].h * 4, true, false);
		nbs[39] = new NormalBrick(nbs[38].x + nbs[0].w, nbs[38].y, false, false);
		nbs[40] = new NormalBrick(nbs[39].x + nbs[0].w, nbs[39].y, false, true);

		nbs[41] = new NormalBrick(nbs[40].x + nbs[0].w * 5, nbs[40].y + nbs[0].h * 6, true, false);
		nbs[42] = new NormalBrick(nbs[41].x + nbs[0].w, nbs[41].y, false, false);
		nbs[43] = new NormalBrick(nbs[42].x + nbs[0].w, nbs[42].y, false, true);

		nbs[44] = new NormalBrick(nbs[43].x + nbs[0].w * 5, nbs[43].y - nbs[0].h * 2, true, false);
		nbs[45] = new NormalBrick(nbs[44].x + nbs[0].w, nbs[44].y, false, true);

		nbs[46] = new NormalBrick(nbs[45].x + nbs[0].w * 4, 488, true, false);
		for (int i = 47; i <= 49; i++) {
			nbs[i] = new NormalBrick(nbs[46].x + (i - 46) * nbs[0].w, nbs[46].y, false, false);
		}
		nbs[50] = new NormalBrick(nbs[49].x + nbs[0].w, nbs[49].y, false, true);

		nbs[51] = new NormalBrick(nbs[50].x + 160, nbs[50].y - 150, true, true);

		nbs[52] = new NormalBrick(nbs[51].x + 260, 200, true, false);
		for (int i = 53; i <= 55; i++) {
			nbs[i] = new NormalBrick(nbs[52].x + (i - 52) * nbs[0].w, nbs[52].y, false, false);
		}
		nbs[56] = new NormalBrick(nbs[55].x + nbs[0].w, nbs[55].y, false, true);


		spbs[0] = new SavePointBrick(nbs[34].x + nbs[0].w, nbs[34].y, false, false, 0);

		stabs[0] = new Stab(nbs[21].x, nbs[21].y, 60, true);
		for (int i = 1; i <= 7; i++) {
			stabs[i] = new Stab(nbs[i + 21].x, nbs[i + 21].y, 60, true);
		}

		for (int i = 8; i <= 10; i++) {
			stabs[i] = new Stab(nbs[i + 21].x, nbs[i + 21].y, 60, true);
		}

		for (int i = 11; i <= 13; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 3].x, nbs[i + 21 - 3].y, 60, false);
		}

		for (int i = 14; i <= 15; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 3].x, nbs[i + 21 - 3].y, 60, true);
		}

		for (int i = 16; i <= 17; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 1].x, nbs[i + 21 - 1].y, 60, true);
		}

		for (int i = 18; i <= 20; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 1].x, nbs[i + 21 - 1].y, 60, true);
		}

		for (int i = 21; i <= 23; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 1].x, nbs[i + 21 - 1].y, 60, false);
		}

		for (int i = 24; i <= 28; i++) {
			stabs[i] = new Stab(nbs[i + 21 + 1].x, nbs[i + 21 + 1].y, 60, true);
		}

		for (int i = 29; i <= 30; i++) {
			stabs[i] = new Stab(nbs[i + 21 + 2].x, nbs[i + 21 + 2].y, 60, true);
		}

		for (int i = 31; i <= 32; i++) {
			stabs[i] = new Stab(nbs[i + 21 + 3].x, nbs[i + 21 + 3].y, 60, true);
		}

		for (int i = 33; i <= 34; i++) {
			stabs[i] = new Stab(nbs[i + 21 - 2].x, nbs[i + 21 - 2].y, 60, false);
		}

		stabs[35] = new Stab(nbs[56].x, nbs[56].y, 60, false);

		engs[0] = new Energy(spbs[0].x - 100, spbs[0].y + 80);

		gt = new Gate(nbs[nbs.length - 1].x + 400, height / 2);
		ship.setEnd(gt.x + 100);

		levelSetup[0] = true;
	}
}

void level_1_draw() {
	background(0);
	pushMatrix();
		bg.display();
		if (ship.isAtFront) {
			translate(20, 0);
			ship.display();
		}
		else if (ship.isAtEnd) {
			translate(-(ship.end - width), 0);
			ship.display();
		}
		else {
			translate(width / 2, 0);
			ship.display();
			translate(-ship.p.x, 0);
		}

		for (int i = 0; i < nbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - nbs[i].x) <=  width) {
					nbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - nbs[i].x) >=  width / 2) {
					nbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - nbs[i].x) <=  width / 2) {
					nbs[i].display();
				}
			}

		}
		for (int i = 0; i < spbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - spbs[i].x) <=  width) {
					spbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - spbs[i].x) >=  width / 2) {
					spbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - spbs[i].x) <=  width / 2) {
					spbs[i].display();
				}
			}

		}
		for (int i = 0; i < stabs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - stabs[i].x) <=  width) {
					stabs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - stabs[i].x) >=  width / 2) {
					stabs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - stabs[i].x) <=  width / 2) {
					stabs[i].display();
				}
			}

		}

		for (int i = 0; i < engs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - engs[i].x) <=  width) {
					engs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - engs[i].x) >=  width / 2) {
					engs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - engs[i].x) <=  width / 2) {
					engs[i].display();
				}
			}	
		}
		if (abs(ship.p.x - gt.x) <=  width / 2) {
			gt.display();
		}
		ship.reset();
	popMatrix();
}

void level_2_setup() {
	if (!levelSetup[1]) {
		gbs = null;
		sd = null;
		ufos = null;
		blts = null;
		whs = null;

		ship = new Ship(0, 500 - 16);
		nbs = new NormalBrick[57];
		fire = new Fire[2];
		nbs[0] = new NormalBrick(-20, 500, true, false);
		spbs = new SavePointBrick[1];
		engs = new Energy[5];
		stabs = new Stab[38];
		bbs = new BreakableBrick[15];
		currentLevelEnergy = engs.length;

		for (int i = 1; i <= 4; i++) {
			nbs[i] = new NormalBrick(nbs[0].x + i * nbs[0].w, nbs[0].y, false, false);
		}
		nbs[5] = new NormalBrick(nbs[4].x + nbs[0].w, nbs[4].y, false, true);

		nbs[6] = new NormalBrick(nbs[5].x + 500, nbs[5].y - 100, true, false);
		nbs[7] = new NormalBrick(nbs[6].x + nbs[0].w, nbs[6].y, false, false);
		nbs[8] = new NormalBrick(nbs[7].x + nbs[0].w, nbs[7].y, false, true);

		nbs[9] = new NormalBrick(nbs[8].x +100 + nbs[0].w, nbs[8].y - 100, true, false);
		nbs[10] = new NormalBrick(nbs[9].x + nbs[0].w, nbs[9].y, false, false);
		nbs[11] = new NormalBrick(nbs[10].x + nbs[0].w, nbs[10].y, false, true);

		nbs[11] = new NormalBrick(nbs[10].x + nbs[0].w, nbs[10].y, false, true);

		nbs[12] = new NormalBrick(nbs[11].x + 200, nbs[11].y-100, true, false);
		for (int i = 13; i <= 24; i++) {
			nbs[i] = new NormalBrick(nbs[12].x + (i - 12) * nbs[0].w, nbs[12].y, false, false);
		}
		nbs[25] = new NormalBrick(nbs[24].x + nbs[0].w, nbs[24].y , false, true);

		nbs[26] = new NormalBrick(nbs[14].x + nbs[0].w, nbs[14].y + 500 , true, false);
		nbs[27] = new NormalBrick(nbs[26].x + nbs[0].w, nbs[26].y , false, false);
		nbs[28] = new NormalBrick(nbs[27].x + nbs[0].w, nbs[27].y , false, true);

		nbs[29] = new NormalBrick(nbs[28].x + 100, nbs[28].y - 200 , true, false);
		nbs[30] = new NormalBrick(nbs[29].x + nbs[0].w, nbs[29].y , false, false);
		nbs[31] = new NormalBrick(nbs[30].x + nbs[0].w, nbs[30].y , false, true);

		nbs[32] = new NormalBrick(nbs[31].x + 100, nbs[31].y + 200, true, false);
		nbs[33] = new NormalBrick(nbs[32].x + nbs[0].w, nbs[32].y , false, false);
		nbs[34] = new NormalBrick(nbs[33].x + nbs[0].w, nbs[33].y , false, true);

		nbs[35] = new NormalBrick(nbs[34].x + 100, nbs[34].y - 100, true, false);

		nbs[36] = new NormalBrick(nbs[35].x + 2*nbs[0].w, nbs[35].y , false, true);

		nbs[37] = new NormalBrick(nbs[36].x + 150, nbs[36].y - 100, true, false);
		for (int i = 37; i <= 40; i++) {
			nbs[i] = new NormalBrick(nbs[37].x + (i - 37) * nbs[0].w, nbs[37].y, false, false);
		}
		nbs[41] = new NormalBrick(nbs[40].x + nbs[0].w, nbs[40].y , false, true);

		nbs[42] = new NormalBrick(nbs[41].x + 300, nbs[41].y - 100 , true, false);
		for (int i = 43; i <= 55; i++) {
			nbs[i] = new NormalBrick(nbs[42].x + (i - 42) * nbs[0].w, nbs[42].y, false, false);
		}
		nbs[56] = new NormalBrick(nbs[55].x + nbs[0].w, nbs[55].y , false, true);




		spbs[0] = new SavePointBrick(nbs[35].x + nbs[0].w, nbs[35].y, false, false, 0);


		
		engs[0] =  new Energy(nbs[30].x + 20, nbs[30].y);
		engs[1] =  new Energy(nbs[35].x + 20, nbs[35].y + 100);
		engs[2] =  new Energy(nbs[39].x + 20, nbs[39].y);
		engs[3] =  new Energy(nbs[46].x + 20, nbs[46].y);
		engs[4] =  new Energy(nbs[53].x + 20, nbs[53].y);




		stabs[0] = new Stab(nbs[6].x, nbs[6].y, 60, true);
		stabs[1] = new Stab(nbs[7].x, nbs[7].y, 60, true);
		stabs[2] = new Stab(nbs[8].x, nbs[8].y, 60, true);
		stabs[3] = new Stab(nbs[9].x, nbs[9].y, 60, false);
		stabs[4] = new Stab(nbs[10].x, nbs[10].y, 60, false);
		stabs[5] = new Stab(nbs[11].x, nbs[11].y, 60, true);

		for (int i = 6; i <= 19; i++) {
			stabs[i] = new Stab(nbs[i + 6].x, nbs[i + 6].y, 60, true);
		}

		stabs[20] = new Stab(nbs[29].x, nbs[29].y, 60, true);
		stabs[21] = new Stab(nbs[34].x, nbs[34].y, 60, true);
		stabs[22] = new Stab(nbs[35].x, nbs[35].y, 60, true);
		stabs[23] = new Stab(nbs[36].x, nbs[36].y, 60, true);

		stabs[24] = new Stab(nbs[42].x, nbs[42].y, 60, true);    
		stabs[25] = new Stab(nbs[43].x, nbs[43].y, 60, true);
		stabs[26] = new Stab(nbs[44].x, nbs[44].y, 60, true);
		stabs[27] = new Stab(nbs[45].x, nbs[45].y, 60, true);

		stabs[28] = new Stab(nbs[47].x, nbs[47].y, 60, true);
		for (int i = 29; i <= 33; i++) {
			stabs[i] = new Stab(nbs[i + 19].x, nbs[i + 19].y, 60, true);
		}
		stabs[34] = new Stab(nbs[54].x, nbs[54].y, 60, true);
		stabs[35] = new Stab(nbs[55].x, nbs[55].y, 60, true);
		stabs[36] = new Stab(nbs[56].x, nbs[56].y, 60, true);    
		stabs[37] = new Stab(nbs[36].x, nbs[36].y, 60, false);    


		bbs[0] = new BreakableBrick(nbs[42].x , nbs[42].y - 200 , true, false);
		for (int i = 1; i <= 13; i++) {
			bbs[i] = new BreakableBrick(nbs[i + 42].x, nbs[i + 42].y - 200, false, false);
		}
		bbs[14] = new BreakableBrick(nbs[56].x, nbs[56].y - 200 , false, true);



		fire[0] = new Fire(nbs[12].x + nbs[0].w, nbs[12].y + 500);
		fire[1] = new Fire(nbs[39].x +20, nbs[39].y + 200);


		gt = new Gate(nbs[nbs.length - 1].x + 400, height / 2);
		ship.setEnd(gt.x + 100);

		levelSetup[1] = true;
	}
}

void level_2_draw() {
	background(0);
	pushMatrix();
		bg.display();
		if (ship.isAtFront) {
			translate(20, 0);
			ship.display();
		}
		else if (ship.isAtEnd) {
			translate(-(ship.end - width), 0);
			ship.display();
		}
		else {
			translate(width / 2, 0);
			ship.display();
			translate(-ship.p.x, 0);
		}

		for (int i = 0; i < nbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - nbs[i].x) <=  width) {
					nbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - nbs[i].x) >=  width / 2) {
					nbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - nbs[i].x) <=  width / 2) {
					nbs[i].display();
				}
			}

		}

		for (int i = 0; i < spbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - spbs[i].x) <=  width) {
					spbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - spbs[i].x) >=  width / 2) {
					spbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - spbs[i].x) <=  width / 2) {
					spbs[i].display();
				}
			}     
		}

		for (int i = 0; i < stabs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - stabs[i].x) <=  width) {
					stabs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - stabs[i].x) >=  width / 2) {
					stabs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - stabs[i].x) <=  width / 2) {
					stabs[i].display();
				}
			}

		}

		for (int i = 0; i < engs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - engs[i].x) <=  width) {
					engs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - engs[i].x) >=  width / 2) {
					engs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - engs[i].x) <=  width / 2) {
					engs[i].display();
				}
			}  
		}

		for (int i = 0; i < bbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - bbs[i].x) <=  width) {
					bbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - bbs[i].x) >=  width / 2) {
					bbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - bbs[i].x) <=  width / 2) {
					bbs[i].display();
				}
			}
		}
		if (abs(ship.p.x - gt.x) <=  width / 2) {
			gt.display();
		}

		for (int i = 0; i < fire.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - fire[i].x) <=  width) {
					fire[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - fire[i].x) >=  width / 2) {
					fire[i].display();
				}
			}
			else {
				if (abs(ship.p.x - fire[i].x) <=  width / 2) {
					fire[i].display();
				}
			}
		}
		ship.reset();
	popMatrix();
}

void level_3_setup() {
	if (!levelSetup[2]) {
		gbs = null;
		fire = null;
		bbs = null;

		ship = new Ship(0, 500 - 16);
		nbs = new NormalBrick[30];
		engs = new Energy[1];
		whs = new Wormhole[2];        
		spbs = new SavePointBrick[1]; 
		ufos = new UFO[13];
		blts = new Bullet[30]; 
		stabs = new Stab[2];
		currentLevelEnergy = engs.length;


		nbs[0] = new NormalBrick(-20, 500, true, false);        
		for (int i = 1; i <= 4; i++) {
			nbs[i] = new NormalBrick(-20 + i * nbs[0].w, 500, false, false);
		}
		nbs[5] = new NormalBrick(nbs[4].x + nbs[0].w , nbs[4].y , false, true);        


		nbs[6] = new NormalBrick(nbs[5].x + 400, nbs[5].y-400, true, false);
		for (int i = 7; i <= 9; i++) {
			nbs[i] = new NormalBrick(nbs[6].x + (i - 6) * nbs[0].w, nbs[6].y, false, false);
		}
		nbs[10] = new NormalBrick(nbs[9].x, nbs[9].y, false, false);


		nbs[11] = new NormalBrick(nbs[10].x + 250, nbs[10].y +350 , true, false);
		for (int i = 12; i <= 14; i++) {
			nbs[i] = new NormalBrick(nbs[11].x + (i - 11) * nbs[0].w, nbs[11].y, false, false);
		}
		nbs[15] = new NormalBrick(nbs[14].x + nbs[0].w, nbs[14].y , false, true);


		nbs[16] = new NormalBrick(nbs[15].x + 500, nbs[15].y +100 , true, true);


		nbs[17] = new NormalBrick(nbs[16].x + 500, nbs[16].y + 100, true, false);
		for (int i = 18; i <= 20; i++) {
			nbs[i] = new NormalBrick(nbs[17].x + (i - 17) * nbs[0].w, nbs[17].y, false, false);
		}
		nbs[21] = new NormalBrick(nbs[20].x + nbs[0].w, nbs[20].y, false, true);

		nbs[22] = new NormalBrick(nbs[21].x + 400, nbs[21].y -200, true, false);
		nbs[23] = new NormalBrick(nbs[22].x + nbs[0].w, nbs[22].y , false, false);
		nbs[24] = new NormalBrick(nbs[23].x + nbs[0].w, nbs[23].y , false, true);


		nbs[25] = new NormalBrick(nbs[22].x + 400, nbs[22].y + 300, false, true);
		for (int i = 26; i <= 29; i++) {
			nbs[i] = new NormalBrick(nbs[25].x + (i - 25) * nbs[0].w, nbs[25].y, false, false);
		}  


		stabs[0] = new Stab(nbs[15].x, nbs[15].y, 60, true);        
		stabs[1] = new Stab(nbs[17].x, nbs[17].y, 60, true);        


		ufos[0] = new UFO(350, 150);
		ufos[1] = new UFO(ufos[0].x+100, ufos[0].y);
		ufos[2] = new UFO(ufos[1].x+100, ufos[0].y);
		blts[0] = new Bullet(ufos[0].x, ufos[0].y, 0, 5);
		blts[1] = new Bullet(ufos[0].x, ufos[0].y - 10, 0, 7);
		blts[2] = new Bullet(ufos[1].x, ufos[1].y - 10, 0, 5);
		blts[3] = new Bullet(ufos[2].x, ufos[2].y, 0, 7);


		ufos[3] = new UFO(ufos[2].x+400, 768-ufos[0].y);
		blts[4] = new Bullet(ufos[3].x, ufos[3].y, 0, -7);  


		ufos[4] = new UFO(ufos[3].x+400, ufos[3].y);
		blts[5] = new Bullet(ufos[4].x, ufos[4].y, 0, -20-5);
		blts[18] = new Bullet(ufos[4].x, ufos[4].y, 0, -15-5);
		blts[19] = new Bullet(ufos[4].x, ufos[4].y, 0, -10-5);
		ufos[5] = new UFO(ufos[4].x+100, ufos[4].y);
		blts[6] = new Bullet(ufos[5].x, ufos[5].y, 0, -21-5);
		blts[20] = new Bullet(ufos[5].x, ufos[5].y, 0, -16-5);  
		blts[21] = new Bullet(ufos[5].x, ufos[5].y, 0, -13-5);          
		ufos[6] = new UFO(ufos[5].x+100, ufos[5].y);
		blts[7] = new Bullet(ufos[6].x, ufos[6].y, 0, -22-5);
		blts[22] = new Bullet(ufos[6].x, ufos[6].y, 0, -13-5);
		blts[23] = new Bullet(ufos[6].x, ufos[6].y, 0, -9-5);


		ufos[7] = new UFO(ufos[6].x+250, 768-ufos[6].y);
		blts[8] = new Bullet(ufos[7].x, ufos[7].y, 0, 10+5);
		blts[24] = new Bullet(ufos[7].x, ufos[7].y, 0, 15+5);
		blts[25] = new Bullet(ufos[7].x, ufos[7].y, 0, 20+5);
		ufos[8] = new UFO(ufos[7].x+100, 768-ufos[6].y);        
		blts[9] = new Bullet(ufos[8].x, ufos[8].y, 0, 12+5);
		blts[26] = new Bullet(ufos[8].x, ufos[8].y, 0, 17+5);
		blts[27] = new Bullet(ufos[8].x, ufos[8].y, 0, 19+5);
		ufos[9] = new UFO(ufos[8].x+100, 768-ufos[6].y);
		blts[10] = new Bullet(ufos[9].x, ufos[9].y, 0, 11+5);
		blts[28] = new Bullet(ufos[9].x, ufos[9].y, 0, 16+5);
		blts[29] = new Bullet(ufos[9].x, ufos[9].y, 0, 21+5);

		ufos[10] = new UFO(ufos[9].x+1000, 300);        
		blts[11] = new Bullet(ufos[10].x, ufos[10].y, -15, 0);
		blts[12] = new Bullet(ufos[10].x, ufos[10].y, -20, 0);

		ufos[11] = new UFO(ufos[10].x+500, 600);
		blts[13] = new Bullet(ufos[11].x, ufos[11].y, -15, 0);
		blts[14] = new Bullet(ufos[11].x, ufos[11].y, -20, 0);

		ufos[12] = new UFO(ufos[6].x+130, ufos[6].y);
		blts[15] = new Bullet(ufos[12].x, ufos[12].y, 0, -10);
		blts[16] = new Bullet(ufos[12].x, ufos[12].y, 0, -20);
		blts[17] = new Bullet(ufos[12].x, ufos[12].y, 0, -15);

		engs[0] = new Energy(nbs[16].x+10, nbs[16].y-5);  

		whs[0] = new Wormhole(nbs[15].x+80, nbs[15].y-150);  
		whs[1] = new Wormhole(nbs[17].x, nbs[17].y-200); 
		whs[0].connect(whs[1]);
		whs[1].connect(whs[0]);

		spbs[0] = new SavePointBrick(nbs[11].x-nbs[0].w, nbs[11].y, true, false, 0);

		sd = new Shield(nbs[21].x+30, nbs[21].y-50);

		gt = new Gate(nbs[nbs.length - 1].x + 400, height / 2);
		ship.setEnd(gt.x + 100);

		levelSetup[2] = true;
	}
}

void level_3_draw() {
	background(0);
	pushMatrix();
		bg.display();
		if (ship.isAtFront) {
			translate(20, 0);
			ship.display();
		}
		else if (ship.isAtEnd) {
			translate(-(ship.end - width), 0);
			ship.display();
		}
		else {
			translate(width / 2, 0);
			ship.display();
			translate(-ship.p.x, 0);
		}

		for (int i = 0; i < nbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - nbs[i].x) <=  width) {
					nbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - nbs[i].x) >=  width / 2) {
					nbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - nbs[i].x) <=  width / 2) {
					nbs[i].display();
				}
			}

		}
		for (int i = 0; i < spbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - spbs[i].x) <=  width) {
					spbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - spbs[i].x) >=  width / 2) {
					spbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - spbs[i].x) <=  width / 2) {
					spbs[i].display();
				}
			}

		}
		for (int i = 0; i < stabs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - stabs[i].x) <=  width) {
					stabs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - stabs[i].x) >=  width / 2) {
					stabs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - stabs[i].x) <=  width / 2) {
					stabs[i].display();
				}
			}

		}

		for (int i = 0; i < engs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - engs[i].x) <=  width) {
					engs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - engs[i].x) >=  width / 2) {
					engs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - engs[i].x) <=  width / 2) {
					engs[i].display();
				}
			}  
		}

		for (int i = 0; i < whs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - whs[i].p.x) <=  width) {
					whs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - whs[i].p.x) >=  width / 2) {
					whs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - whs[i].p.x) <=  width / 2) {
					whs[i].display();
				}
			}  
		}

		for (int i = 0; i < ufos.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - ufos[i].x) <=  width) {
					ufos[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - ufos[i].x) >=  width / 2) {
					ufos[i].display();
				}
			}
			else {
				if (abs(ship.p.x - ufos[i].x) <=  width / 2) {
					ufos[i].display();
				}
			}  
		}

		for (int i = 0; i < blts.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - blts[i]._x) <=  width) {
					blts[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - blts[i]._x) >=  width / 2) {
					blts[i].display();
				}
			}
			else {
				if (abs(ship.p.x - blts[i]._x) <=  width / 2) {
					blts[i].display();
				}
			}  
		}
		if (abs(ship.p.x - gt.x) <=  width / 2) {
			gt.display();
		}

		if (ship.isAtFront) {
			if (abs(ship._p.x - sd.x) <=  width) {
				sd.display();
			}
		}
		else if (ship.isAtEnd) {
			if (abs(ship._p.x - sd.x) >=  width / 2) {
				sd.display();
			}
		}
		else {
			if (abs(ship.p.x - sd.x) <=  width / 2) {
				sd.display();
			}
		} 
		ship.reset();
	popMatrix();
}

void level_4_setup() {
	if (!levelSetup[3]) {
		fire = null;
		whs = null;
		ufos = null;
		blts = null;
		sd = null;

		engs = new Energy[0];
		nbs = new NormalBrick[190];
		bbs = new BreakableBrick[178];
		stabs = new Stab[354];
		spbs = new SavePointBrick[2];
		gbs = new GravityBall[3];
		currentLevelEnergy = engs.length;

		nbs[0] = new NormalBrick(-20, height / 2 - 20, true, false);
		ship = new Ship(nbs[0].x + nbs[0].w / 2, nbs[0].y - 18);

		bbs[0] = new BreakableBrick(nbs[0].x, nbs[0].y - 280, false, false);
		for (int i = 1; i <= 19; i++) {
			bbs[i] = new BreakableBrick(bbs[0].x + bbs[0].w * (i - 0), bbs[0].y, false, false);
		}
		bbs[20] = new BreakableBrick(bbs[19].x + bbs[0].w, bbs[0].y, false, true);

		for (int i = 21; i <= 24; i++) {
			bbs[i] = new BreakableBrick(nbs[0].x + nbs[0].w * (i - 20), nbs[0].y, false, false);
		}
		for (int i = 25; i <= 28; i++) {
			bbs[i] = new BreakableBrick(bbs[24].x + bbs[0].w * (i - 23), bbs[24].y, false, false);
		}
		for (int i = 29; i <= 32; i++) {
			bbs[i] = new BreakableBrick(bbs[28].x + bbs[0].w * (i - 27), bbs[28].y, false, false);
		}
		for (int i = 33; i <= 34; i++) {
			bbs[i] = new BreakableBrick(bbs[32].x + bbs[0].w * (i - 31), bbs[32].y, false, false);
		}
		for (int i = 35; i <= 36; i++) {
			bbs[i] = new BreakableBrick(bbs[34].x + bbs[0].w * (i - 33), bbs[34].y, false, false);
		}

		bbs[37] = new BreakableBrick(nbs[0].x, nbs[0].y + 280, false, false);
		for (int i = 38; i <= 56; i++) {
			bbs[i] = new BreakableBrick(bbs[37].x + bbs[0].w * (i - 37), bbs[37].y, false, false);
		}
		bbs[57] = new BreakableBrick(bbs[56].x + bbs[0].w, bbs[56].y, false, true);

		nbs[1] = new NormalBrick(bbs[24].x + bbs[21].w, bbs[24].y, false, false);
		nbs[2] = new NormalBrick(bbs[28].x + bbs[21].w, bbs[28].y, false, false);
		nbs[3] = new NormalBrick(bbs[32].x + bbs[21].w, bbs[32].y, false, false);
		for (int i = 0; i <= 2; i++) {
			stabs[i] = new Stab(bbs[(i + 1) * 5].x, bbs[(i + 1) * 5].y, 60, true);
		}
		for (int i = 3; i <= 5; i++) {
			stabs[i] = new Stab(nbs[i - 2].x, nbs[i - 2].y, 60, true);
		}
		for (int i = 6; i <= 8; i++) {
			stabs[i] = new Stab(nbs[i - 5].x, nbs[i - 5].y, 60, false);
		}
		for (int i = 9; i <= 11; i++) {
			stabs[i] = new Stab(bbs[37 + 5 * (i - 8)].x, bbs[37 + 5 * (i - 8)].y, 60, false);
		}

		spbs[0] = new SavePointBrick(bbs[36].x + 100, height / 2 - 25, true, true, 0);

		nbs[4] = new NormalBrick(bbs[20].x + 200, bbs[20].y - 20, true, false);
		for (int i = 5; i <= 18; i++) {
			nbs[i] = new NormalBrick(nbs[4].x + nbs[0].w * (i - 4), nbs[4].y, false, false);
		}
		nbs[19] = new NormalBrick(bbs[57].x + 200, bbs[57].y + 20, true, false);
		for (int i = 20; i <= 33; i++) {
			nbs[i] = new NormalBrick(nbs[19].x + nbs[0].w * (i - 19), nbs[19].y, false, false);
		}

		for (int i = 34; i <= 48; i++) {
			nbs[i] = new NormalBrick(nbs[18].x + nbs[0].w * (i - 33), nbs[18].y + nbs[0].h, false, false);
		}
		for (int i = 49; i <= 63; i++) {
			nbs[i] = new NormalBrick(nbs[33].x + nbs[0].w * (i - 48), nbs[33].y - nbs[0].h, false, false);
		}

		for (int i = 64; i <= 77; i++) {
			nbs[i] = new NormalBrick(nbs[48].x + nbs[0].w * (i - 63), nbs[48].y + nbs[0].h, false, false);
		}
		nbs[78] = new NormalBrick(nbs[77].x + nbs[0].w, nbs[77].y, false, true);
		for (int i = 79; i <= 92; i++) {
			nbs[i] = new NormalBrick(nbs[63].x + nbs[0].w * (i - 78), nbs[63].y - nbs[0].h, false, false);
		}
		nbs[93] = new NormalBrick(nbs[92].x + nbs[0].w, nbs[92].y, false, true);

		for (int i = 12; i <= 26; i++) {
			stabs[i] = new Stab(nbs[i - 8].x, nbs[i - 8].y, 60, true);
		}
		for (int i = 27; i <= 41; i++) {
			stabs[i] = new Stab(nbs[i - 23].x, nbs[i - 23].y, 60, false);
		}
		for (int i = 42; i <= 56; i++) {
			stabs[i] = new Stab(nbs[i - 23].x, nbs[i - 23].y, 60, true);
		}
		for (int i = 57; i <= 71; i++) {
			stabs[i] = new Stab(nbs[i - 38].x, nbs[i - 38].y, 60, false);
		}

		for (int i = 72; i <= 86; i++) {
			stabs[i] = new Stab(nbs[i - 38].x, nbs[i - 38].y, 60, true);
		}
		for (int i = 87; i <= 101; i++) {
			stabs[i] = new Stab(nbs[i - 53].x, nbs[i - 53].y, 60, false);
		}
		for (int i = 102; i <= 116; i++) {
			stabs[i] = new Stab(nbs[i - 53].x, nbs[i - 53].y, 60, true);
		}
		for (int i = 117; i <= 131; i++) {
			stabs[i] = new Stab(nbs[i - 68].x, nbs[i - 68].y, 60, false);
		}

		for (int i = 132; i <= 146; i++) {
			stabs[i] = new Stab(nbs[i - 68].x, nbs[i - 68].y, 60, true);
		}
		for (int i = 147; i <= 161; i++) {
			stabs[i] = new Stab(nbs[i - 83].x, nbs[i - 83].y, 60, false);
		}
		for (int i = 162; i <= 176; i++) {
			stabs[i] = new Stab(nbs[i - 83].x, nbs[i - 83].y, 60, true);
		}
		for (int i = 177; i <= 191; i++) {
			stabs[i] = new Stab(nbs[i - 98].x, nbs[i - 98].y, 60, false);
		}

		bbs[58] = new BreakableBrick(stabs[27].x, stabs[27].tipy + 10, true, false);
		for (int i = 59; i <= 72; i++) {
			bbs[i] = new BreakableBrick(stabs[i - 31].x, stabs[i - 31].tipy + 10, false, false);
		}
		bbs[73] = new BreakableBrick(stabs[42].x, stabs[42].tipy - 10 - bbs[0].h, true, false);
		for (int i = 74; i <= 87; i++) {
			bbs[i] = new BreakableBrick(stabs[i - 31].x, stabs[i - 31].tipy - 10 - bbs[0].h, false, false);
		}

		for (int i = 88; i <= 102; i++) {
			bbs[i] = new BreakableBrick(stabs[i - 1].x, stabs[i - 1].tipy + 10, false, false);
		}
		for (int i = 103; i <= 117; i++) {
			bbs[i] = new BreakableBrick(stabs[i - 1].x, stabs[i - 1].tipy - 10 - bbs[0].h, false, false);
		}

		for (int i = 118; i <= 131; i++) {
			bbs[i] = new BreakableBrick(stabs[i + 29].x, stabs[i + 29].tipy + 10, false, false);
		}
		bbs[132] = new BreakableBrick(stabs[161].x, stabs[161].tipy + 10, false, true);
		for (int i = 133; i <= 146; i++) {
			bbs[i] = new BreakableBrick(stabs[i + 29].x, stabs[i + 29].tipy - 10 - bbs[0].h, false, false);
		}
		bbs[147] = new BreakableBrick(stabs[176].x, stabs[176].tipy - 10 - bbs[0].h, false, true);

		nbs[94] = new NormalBrick(nbs[93].x + 200, height / 2, true, false);
		for (int i = 95; i <= 107; i++) {
			nbs[i] = new NormalBrick(nbs[94].x + nbs[0].w * (i - 94), nbs[94].y, false, false);
		}
		nbs[108] = new NormalBrick(nbs[107].x + nbs[0].w, nbs[107].y, false, true);
		nbs[109] = new NormalBrick(nbs[94].x, height / 2 - 60, true, false);
		for (int i = 110; i <= 122; i++) {
			nbs[i] = new NormalBrick(nbs[109].x + nbs[0].w * (i - 109), nbs[109].y, false, false);
		}
		nbs[123] = new NormalBrick(nbs[122].x + nbs[0].w, nbs[122].y, false, true);
		for (int i = 192; i <= 206; i++) {
			stabs[i] = new Stab(nbs[i - 98].x, nbs[i - 98].y, 60, false);
		}
		for (int i = 207; i <= 221; i++) {
			stabs[i] = new Stab(nbs[i - 98].x, nbs[i - 98].y, 60, true);
		}
		bbs[148] = new BreakableBrick(stabs[192].x, stabs[192].tipy + 100, true, false);
		for (int i = 149; i <= 161; i++) {
			bbs[i] = new BreakableBrick(stabs[i + 44].x, stabs[i + 44].tipy + 100, false, false);
		}
		bbs[162] = new BreakableBrick(stabs[206].x, stabs[206].tipy + 100, false, true);
		bbs[163] = new BreakableBrick(stabs[207].x, stabs[207].tipy - bbs[0].h - 100, true, false);
		for (int i = 164; i <= 176; i++) {
			bbs[i] = new BreakableBrick(stabs[i + 44].x, stabs[i + 44].tipy - bbs[0].h - 100, false, false);
		}
		bbs[177] = new BreakableBrick(stabs[221].x, stabs[221].tipy - bbs[0].h - 100, false, true);

		spbs[1] = new SavePointBrick(nbs[123].x + 300, height / 2, true, true, 1);

		nbs[124] = new NormalBrick(spbs[1].x + 400, 80, true, false);
		for (int i = 125; i <= 155; i++) {
			nbs[i] = new NormalBrick(nbs[124].x + nbs[0].w * (i - 124), nbs[124].y, false, false);
		}
		nbs[156] = new NormalBrick(nbs[155].x + nbs[0].w, nbs[155].y, false, true);
		nbs[157] = new NormalBrick(spbs[1].x + 400, height - nbs[0].h - 80, true, false);
		for (int i = 158; i <= 188; i++) {
			nbs[i] = new NormalBrick(nbs[157].x + nbs[0].w * (i - 157), nbs[157].y, false, false);
		}
		nbs[189] = new NormalBrick(nbs[188].x + nbs[0].w, nbs[188].y, false, true);

		for (int i = 222; i <= 254; i++) {
			stabs[i] = new Stab(nbs[i - 98].x, nbs[i - 98].y, 60, false);
		}
		for (int i = 255; i <= 287; i++) {
			stabs[i] = new Stab(nbs[i - 131].x, nbs[i - 131].y, 60, true);
		}
		for (int i = 288; i <= 320; i++) {
			stabs[i] = new Stab(nbs[i - 131].x, nbs[i - 131].y, 60, true);
		}
		for (int i = 321; i <= 353; i++) {
			stabs[i] = new Stab(nbs[i - 164].x, nbs[i - 164].y, 60, false);
		}

		gbs[0] = new GravityBall(nbs[124].x + 160, height / 2, false);
		gbs[1] = new GravityBall(int(gbs[0].p.x) + gbs[0].r * 2 + 460, height / 2, true);
		gbs[2] = new GravityBall(int(gbs[1].p.x) + gbs[0].r * 2 + 460, height / 2, true);

		gt = new Gate(nbs[nbs.length - 1].x + 400, height / 2);
		ship.setEnd(gt.x + 100);

		levelSetup[3] = true;
	}
}

void level_4_draw() {
	background(0);
	pushMatrix();
		bg.display();
		if (ship.isAtFront) {
			translate(20, 0);
			ship.display();
		}
		else if (ship.isAtEnd) {
			translate(-(ship.end - width), 0);
			ship.display();
		}
		else {
			translate(width / 2, 0);
			ship.display();
			translate(-ship.p.x, 0);
		}

		for (int i = 0; i < nbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - nbs[i].x) <=  width) {
					nbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - nbs[i].x) >=  width / 2) {
					nbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - nbs[i].x) <=  width / 2) {
					nbs[i].display();
				}
			}
		}
		for (int i = 0; i < spbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - spbs[i].x) <=  width) {
					spbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - spbs[i].x) >=  width / 2) {
					spbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - spbs[i].x) <=  width / 2) {
					spbs[i].display();
				}
			}
		}
		for (int i = 0; i < stabs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - stabs[i].x) <=  width) {
					stabs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - stabs[i].x) >=  width / 2) {
					stabs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - stabs[i].x) <=  width / 2) {
					stabs[i].display();
				}
			}
		}

		for (int i = 0; i < gbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - gbs[i].p.x) <=  width) {
					gbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - gbs[i].p.x) >=  width / 2) {
					gbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - gbs[i].p.x) <=  width / 2) {
					gbs[i].display();
				}
			}	
		}
		ship.checkCloseGravityBall();
		for (int i = 0; i < bbs.length; i++) {
			if (ship.isAtFront) {
				if (abs(ship._p.x - bbs[i].x) <=  width) {
					bbs[i].display();
				}
			}
			else if (ship.isAtEnd) {
				if (abs(ship._p.x - bbs[i].x) >=  width / 2) {
					bbs[i].display();
				}
			}
			else {
				if (abs(ship.p.x - bbs[i].x) <=  width / 2) {
					bbs[i].display();
				}
			}
		}
		if (abs(ship.p.x - gt.x) <=  width / 2) {
			gt.display();
		}
		ship.reset();
	popMatrix();
}
/*----------------------------------Press space to stop game-----------------------------------------*/
void keyPressed() {
	if (key == ' ' && !pause && game) {
		noLoop();
		pushMatrix();
			image(images[22], width / 2 - images[22].width / 2, height / 2 - images[22].height / 2);
		popMatrix();
		cursor();
		pause = true;
		pauseDuration = millis() / 1000;
	}
	else if (key == ' ' && pause && game) {
		redraw();
		loop();
		pause = false;
		pauseDuration = millis() / 1000 - pauseDuration;
		gameStartTime += pauseDuration;
		pauseDuration = 0;
	}
}
/*---------------------------------------------------------------------------------------------------*/


/*--------------------------------------------- Ending scene ----------------------------------------*/
void endPage() {
  background(0);
  bg.display();

  pushMatrix();
  	drawPlanet(1.258);
  popMatrix();
  degChange += 1;
  if (rChange == 25) {
    rChange = 0;
    alpha = 25;
  } else {
    rChange++;
    alpha--;
  }
  pushMatrix();
	  translate(383, 767);
	  rotate(radians(-24));
	  fill(209, 229, 240);
  popMatrix();
  showText();
}

void drawPlanet(float scalingFactor) {
	int rPlanet = 243;
	translate(width / 2, height / 2);
	rotate(radians(degChange));
	scale(scalingFactor);
	noStroke();
	fill(63, 144, 206);
	ellipse(0, 0, 2 * rPlanet, 2 * rPlanet);

	fill(15, 100, 103);
	stroke(255);
	strokeWeight(1);
	beginShape();
		curveVertex(29, -184);
		curveVertex(29, -184);
		curveVertex(33, -182);
		curveVertex(42, -178);
		curveVertex(43, -172);
		curveVertex(48, -170);
		curveVertex(43, -165);
		curveVertex(42, -155);
		curveVertex(49, -146);
		curveVertex(54, -146);
		curveVertex(59, -142);
		curveVertex(63, -151);
		curveVertex(66, -157);
		curveVertex(73, -159);
		curveVertex(81, -163);
		curveVertex(92, -167);
		curveVertex(86, -170);
		curveVertex(94, -172);
		curveVertex(89, -175);
		curveVertex(93, -178);
		curveVertex(88, -186);
		curveVertex(29, -184);
		curveVertex(29, -184);
	endShape();

	beginShape();
		curveVertex(105, -147);
		curveVertex(105, -147);
		curveVertex(106, -149);
		curveVertex(110, -149);
		curveVertex(114, -151);
		curveVertex(118, -148);
		curveVertex(117, -152);
		curveVertex(121, -152);
		curveVertex(117, -158);
		curveVertex(108, -164);
		curveVertex(99, -162);
		curveVertex(98, -154);
		curveVertex(105, -147);
		curveVertex(105, -147);
	endShape();

	beginShape();
		curveVertex(96, -109);
		curveVertex(96, -109);
		curveVertex(98, -112);
		curveVertex(104, -108);
		curveVertex(108, -114);
		curveVertex(111, -111);
		curveVertex(122, -115);
		curveVertex(123, -119);
		curveVertex(127, -116);
		curveVertex(131, -122);
		curveVertex(136, -130);
		curveVertex(140, -120);
		curveVertex(137, -114);
		curveVertex(146, -115);
		curveVertex(143, -108);
		curveVertex(157, -118);
		curveVertex(154, -118);
		curveVertex(154, -125);
		curveVertex(150, -125);
		curveVertex(134, -137);
		curveVertex(132, -144);
		curveVertex(126, -144);
		curveVertex(125, -147);
		curveVertex(121, -146);
		curveVertex(125, -136);
		curveVertex(105, -134);
		curveVertex(104, -127);
		curveVertex(96, -124);
		curveVertex(92, -116);
		curveVertex(96, -109);
		curveVertex(96, -109);
	endShape();

	beginShape();
		curveVertex(37, -188);
		curveVertex(37, -188);
		curveVertex(10, -191);
		curveVertex(5, -192);
		curveVertex(-2, -189);
		curveVertex(-1, -184);
		curveVertex(-12, -182);
		curveVertex(-16, -178);
		curveVertex(-3, -175);
		curveVertex(0, -177);
		curveVertex(5, -170);
		curveVertex(-13, -165);
		curveVertex(-8, -163);
		curveVertex(-1, -157);
		curveVertex(7, -155);
		curveVertex(6, -160);
		curveVertex(11, -158);
		curveVertex(11, -163);
		curveVertex(13, -165);
		curveVertex(18, -162);
		curveVertex(26, -165);
		curveVertex(20, -169);
		curveVertex(18, -174);
		curveVertex(7, -180);
		curveVertex(7, -186);
		curveVertex(16, -186);
		curveVertex(27, -186);
		curveVertex(37, -188);
		curveVertex(37, -188);
	endShape();

	beginShape();
		curveVertex(-22, -170);
		curveVertex(-22, -170);
		curveVertex(-14, -170);
		curveVertex(-9, -173);
		curveVertex(-18, -175);
		curveVertex(-22, -170);
		curveVertex(-22, -170);
	endShape();

	beginShape();
		curveVertex(-38, -186);
		curveVertex(-38, -186);
		curveVertex(-41, -190);
		curveVertex(-50, -196);
		curveVertex(-61, -195);
		curveVertex(-55, -192);
		curveVertex(-59, -187);
		curveVertex(-47, -184);
		curveVertex(-41, -181);
		curveVertex(-38, -186);
		curveVertex(-38, -186);
	endShape();

	beginShape();
		curveVertex(-35, -196);
		curveVertex(-35, -196);
		curveVertex(-37, -192);
		curveVertex(-28, -194);
		curveVertex(-23, -194);
		curveVertex(-28, -191);
		curveVertex(-36, -187);
		curveVertex(-40, -191);
		curveVertex(-42, -195);
		curveVertex(-35, -196);
		curveVertex(-35, -196);
	endShape();

	beginShape();
		curveVertex(-8, -193);
		curveVertex(-8, -193);
		curveVertex(-13, -190);
		curveVertex(-20, -192);
		curveVertex(-17, -187);
		curveVertex(-9, -190);
		curveVertex(-8, -193);
		curveVertex(-8, -193);
	endShape();

	beginShape();
		curveVertex(-25, -184);
		curveVertex(-25, -184);
		curveVertex(-20, -186);
		curveVertex(-24, -188);
		curveVertex(-28, -187);
		curveVertex(-25, -184);
		curveVertex(-25, -184);
	endShape();

	beginShape();
		curveVertex(11, -112);
		curveVertex(11, -112);
		curveVertex(3, -107);
		curveVertex(-4, -101);
		curveVertex(6, -100);
		curveVertex(18, -102);
		curveVertex(14, -106);
		curveVertex(11, -112);
		curveVertex(11, -112);
	endShape();

	beginShape();
		curveVertex(37, -114);
		curveVertex(37, -114);
		curveVertex(42, -120);
		curveVertex(46, -119);
		curveVertex(46, -127);
		curveVertex(46, -131);
		curveVertex(35, -135);
		curveVertex(33, -145);
		curveVertex(22, -144);
		curveVertex(20, -135);
		curveVertex(16, -134);
		curveVertex(18, -147);
		curveVertex(-1, -149);
		curveVertex(2, -138);
		curveVertex(-1, -136);
		curveVertex(-5, -133);
		curveVertex(-5, -140);
		curveVertex(-11, -145);
		curveVertex(-5, -153);
		curveVertex(-18, -160);
		curveVertex(-32, -151);
		curveVertex(-31, -148);
		curveVertex(-41, -141);
		curveVertex(-50, -141);
		curveVertex(-53, -133);
		curveVertex(-59, -130);
		curveVertex(-64, -133);
		curveVertex(-57, -144);
		curveVertex(-68, -154);
		curveVertex(-65, -158);
		curveVertex(-68, -161);
		curveVertex(-45, -168);
		curveVertex(-45, -170);
		curveVertex(-34, -168);
		curveVertex(-34, -165);
		curveVertex(-27, -165);
		curveVertex(-29, -170);
		curveVertex(-20, -173);
		curveVertex(-23, -178);
		curveVertex(-24, -181);
		curveVertex(-29, -181);
		curveVertex(-35, -178);
		curveVertex(-42, -180);
		curveVertex(-58, -185);
		curveVertex(-67, -194);
		curveVertex(-82, -198);
		curveVertex(-93, -211);
		curveVertex(-107, -209);
		curveVertex(-112, -209);
		curveVertex(-129, -197);
		curveVertex(-120, -200);
		curveVertex(-121, -190);
		curveVertex(-149, -170);
		curveVertex(-154, -162);
		curveVertex(-174, -150);
		curveVertex(-192, -129);
		curveVertex(-206, -105);
		curveVertex(-216, -77);
		curveVertex(-223, -47);
		curveVertex(-226, -36);
		curveVertex(-223, -17);
		curveVertex(-216, -3);
		curveVertex(-212, -2);
		curveVertex(-210, 13);
		curveVertex(-199, 25);
		curveVertex(-199, 46);
		curveVertex(-194, 51);
		curveVertex(-191, 59);
		curveVertex(-183, 69);
		curveVertex(-176, 67);
		curveVertex(-172, 71);
		curveVertex(-171, 82);
		curveVertex(-171, 97);
		curveVertex(-180, 104);
		curveVertex(-182, 113);
		curveVertex(-177, 118);
		curveVertex(-181, 123);
		curveVertex(-172, 137);
		curveVertex(-156, 162);
		curveVertex(-139, 180);
		curveVertex(-118, 195);
		curveVertex(-96, 219);
		curveVertex(-72, 228);
		curveVertex(-57, 233);
		curveVertex(-34, 235);
		curveVertex(-25, 234);
		curveVertex(-25, 229);
		curveVertex(-7, 229);
		curveVertex(8, 222);
		curveVertex(13, 207);
		curveVertex(21, 207);
		curveVertex(35, 196);
		curveVertex(41, 187);
		curveVertex(40, 178);
		curveVertex(31, 180);
		curveVertex(18, 174);
		curveVertex(-3, 169);
		curveVertex(-9, 164);
		curveVertex(-19, 160);
		curveVertex(-29, 164);
		curveVertex(-35, 162);
		curveVertex(-24, 156);
		curveVertex(-34, 153);
		curveVertex(-43, 159);
		curveVertex(-46, 156);
		curveVertex(-34, 146);
		curveVertex(-39, 136);
		curveVertex(-48, 125);
		curveVertex(-69, 118);
		curveVertex(-78, 110);
		curveVertex(-83, 103);
		curveVertex(-92, 98);
		curveVertex(-91, 93);
		curveVertex(-100, 85);
		curveVertex(-109, 84);
		curveVertex(-115, 79);
		curveVertex(-126, 76);
		curveVertex(-126, 73);
		curveVertex(-133, 66);
		curveVertex(-141, 72);
		curveVertex(-141, 78);
		curveVertex(-146, 74);
		curveVertex(-144, 66);
		curveVertex(-138, 63);
		curveVertex(-144, 61);
		curveVertex(-160, 63);
		curveVertex(-166, 70);
		curveVertex(-174, 62);
		curveVertex(-183, 60);
		curveVertex(-190, 47);
		curveVertex(-185, 24);
		curveVertex(-188, 16);
		curveVertex(-199, 10);
		curveVertex(-184, -13);
		curveVertex(-194, -19);
		curveVertex(-202, -12);
		curveVertex(-210, -16);
		curveVertex(-210, -32);
		curveVertex(-203, -47);
		curveVertex(-189, -61);
		curveVertex(-172, -60);
		curveVertex(-158, -54);
		curveVertex(-147, -33);
		curveVertex(-143, -49);
		curveVertex(-102, -65);
		curveVertex(-96, -81);
		curveVertex(-96, -75);
		curveVertex(-87, -80);
		curveVertex(-74, -86);
		curveVertex(-62, -88);
		curveVertex(-54, -95);
		curveVertex(-31, -98);
		curveVertex(-39, -92);
		curveVertex(-30, -95);
		curveVertex(-17, -95);
		curveVertex(-11, -97);
		curveVertex(-11, -101);
		curveVertex(-17, -99);
		curveVertex(-26, -108);
		curveVertex(-19, -111);
		curveVertex(-20, -114);
		curveVertex(-38, -113);
		curveVertex(-24, -117);
		curveVertex(-13, -118);
		curveVertex(-2, -115);
		curveVertex(7, -121);
		curveVertex(24, -122);
		curveVertex(37, -114);
		curveVertex(37, -114);
	endShape();

	beginShape();
		curveVertex(-111, 57);
		curveVertex(-111, 57);
		curveVertex(-103, 56);
		curveVertex(-100, 53);
		curveVertex(-109, 49);
		curveVertex(-114, 44);
		curveVertex(-116, 41);
		curveVertex(-123, 36);
		curveVertex(-135, 36);
		curveVertex(-132, 27);
		curveVertex(-139, 24);
		curveVertex(-140, 30);
		curveVertex(-146, 28);
		curveVertex(-147, 32);
		curveVertex(-141, 33);
		curveVertex(-143, 40);
		curveVertex(-140, 47);
		curveVertex(-135, 46);
		curveVertex(-125, 52);
		curveVertex(-121, 56);
		curveVertex(-116, 53);
		curveVertex(-111, 57);
		curveVertex(-111, 57);
	endShape();

	beginShape();
		curveVertex(-177, -8);
		curveVertex(-177, -8);
		curveVertex(-165, -7);
		curveVertex(-159, -5);
		curveVertex(-154, 6);
		curveVertex(-145, 15);
		curveVertex(-142, 22);
		curveVertex(-158, 17);
		curveVertex(-154, 17);
		curveVertex(-157, 12);
		curveVertex(-158, 8);
		curveVertex(-164, 2);
		curveVertex(-168, -2);
		curveVertex(-172, -4);
		curveVertex(-179, -3);
		curveVertex(-177, -8);
		curveVertex(-177, -8);
	endShape();

	beginShape();
		curveVertex(-160, 23);
		curveVertex(-160, 23);
		curveVertex(-155, 27);
		curveVertex(-161, 29);
		curveVertex(-163, 23);
		curveVertex(-160, 23);
		curveVertex(-160, 23);
	endShape();

	beginShape();
		curveVertex(183, -52);
		curveVertex(183, -52);
		curveVertex(189, -52);
		curveVertex(195, -63);
		curveVertex(209, -74);
		curveVertex(215, -60);
		curveVertex(220, -56);
		curveVertex(228, -55);
		curveVertex(232, -45);
		curveVertex(236, -33);
		curveVertex(237, -15);
		curveVertex(233, -25);
		curveVertex(237, 18);
		curveVertex(238, 36);
		curveVertex(225, 82);
		curveVertex(217, 93);
		curveVertex(211, 90);
		curveVertex(200, 104);
		curveVertex(187, 110);
		curveVertex(180, 116);
		curveVertex(162, 108);
		curveVertex(163, 101);
		curveVertex(157, 89);
		curveVertex(151, 87);
		curveVertex(156, 81);
		curveVertex(153, 78);
		curveVertex(150, 76);
		curveVertex(156, 63);
		curveVertex(155, 49);
		curveVertex(157, 43);
		curveVertex(153, 38);
		curveVertex(157, 22);
		curveVertex(163, 6);
		curveVertex(169, -6);
		curveVertex(178, -19);
		curveVertex(175, -24);
		curveVertex(177, -31);
		curveVertex(176, -36);
		curveVertex(181, -42);
		curveVertex(183, -52);
		curveVertex(183, -52);
	endShape();

	beginShape();
		curveVertex(-50, -229);
		curveVertex(-50, -229);
		curveVertex(-39, -232);
		curveVertex(-6, -233);
		curveVertex(12, -236);
		curveVertex(26, -236);
		curveVertex(44, -231);
		curveVertex(60, -226);
		curveVertex(79, -221);
		curveVertex(96, -218);
		curveVertex(117, -206);
		curveVertex(133, -195);
		curveVertex(143, -185);
		curveVertex(153, -177);
		curveVertex(146, -177);
		curveVertex(153, -166);
		curveVertex(161, -160);
		curveVertex(160, -152);
		curveVertex(168, -148);
		curveVertex(166, -138);
		curveVertex(159, -144);
		curveVertex(164, -144);
		curveVertex(157, -150);
		curveVertex(152, -145);
		curveVertex(144, -155);
		curveVertex(143, -163);
		curveVertex(136, -177);
		curveVertex(135, -184);
		curveVertex(127, -192);
		curveVertex(115, -202);
		curveVertex(95, -214);
		curveVertex(80, -217);
		curveVertex(55, -224);
		curveVertex(48, -223);
		curveVertex(47, -219);
		curveVertex(36, -217);
		curveVertex(29, -223);
		curveVertex(-1, -224);
		curveVertex(-3, -228);
		curveVertex(-22, -228);
		curveVertex(-38, -226);
		curveVertex(-50, -229);
		curveVertex(-50, -229);
	endShape();

	beginShape();
		curveVertex(165, -164);
		curveVertex(165, -164);
		curveVertex(168, -155);
		curveVertex(174, -148);
		curveVertex(169, -138);
		curveVertex(167, -131);
		curveVertex(167, -117);
		curveVertex(163, -115);
		curveVertex(165, -110);
		curveVertex(160, -109);
		curveVertex(171, -104);
		curveVertex(176, -90);
		curveVertex(162, -85);
		curveVertex(166, -68);
		curveVertex(167, -63);
		curveVertex(170, -57);
		curveVertex(179, -56);
		curveVertex(183, -53);
		curveVertex(190, -61);
		curveVertex(191, -70);
		curveVertex(188, -71);
		curveVertex(189, -87);
		curveVertex(186, -91);
		curveVertex(190, -97);
		curveVertex(195, -99);
		curveVertex(207, -92);
		curveVertex(200, -93);
		curveVertex(195, -94);
		curveVertex(201, -81);
		curveVertex(212, -78);
		curveVertex(212, -87);
		curveVertex(201, -99);
		curveVertex(195, -104);
		curveVertex(194, -110);
		curveVertex(202, -104);
		curveVertex(207, -97);
		curveVertex(216, -88);
		curveVertex(218, -95);
		curveVertex(210, -109);
		curveVertex(199, -130);
		curveVertex(186, -146);
		curveVertex(172, -160);
		curveVertex(165, -164);
		curveVertex(165, -164);
	endShape();

	fill(63, 144, 206);
	beginShape();
		curveVertex(-103, -119);
		curveVertex(-103, -119);
		curveVertex(-114, -124);
		curveVertex(-120, -128);
		curveVertex(-123, -134);
		curveVertex(-113, -133);
		curveVertex(-104, -131);
		curveVertex(-93, -135);
		curveVertex(-88, -124);
		curveVertex(-86, -131);
		curveVertex(-80, -129);
		curveVertex(-82, -120);
		curveVertex(-91, -116);
		curveVertex(-84, -109);
		curveVertex(-88, -110);
		curveVertex(-96, -103);
		curveVertex(-102, -100);
		curveVertex(-90, -100);
		curveVertex(-79, -101);
		curveVertex(-97, -97);
		curveVertex(-107, -99);
		curveVertex(-98, -106);
		curveVertex(-99, -109);
		curveVertex(-94, -113);
		curveVertex(-97, -115);
		curveVertex(-107, -111);
		curveVertex(-117, -102);
		curveVertex(-119, -106);
		curveVertex(-103, -119);
		curveVertex(-103, -119);
	endShape();

	noFill();
	for (int i = -45, alpha = 0; i <= 35; i++) {
		if (i <= 3) {
			stroke(255, alpha);
			ellipse(0, 0, 2 * (rPlanet + i), 2 * (rPlanet + i));
			alpha += 1;
		} else {
			stroke(255, alpha);
			ellipse(0, 0, 2 * (rPlanet + i), 2 * (rPlanet + i));
			alpha -= 4;
		}
	}
	for (int i = 0; i < 5; i++) {
		stroke(255, alpha);
		ellipse(0, 0, 2 * (rPlanet + rChange - i), 2 * (rPlanet + rChange - i));
		stroke(255, alpha + 1);
		ellipse(0, 0, 2 * (rPlanet + rChange - 1 - i), 2 * (rPlanet + rChange - 1 - i));
	}

	rotate(radians(-degChange));
}

void showText() {
	fill(#EBDBFA);
	textFont(f[10], 45);
	textAlign(CENTER);
	text("Congratulation!!! \nYou have found a new Earth, and bring \nhope to all the people!!!", 500,350);
	textSize(20);
	text("(Click the mouse or press any key to return to menu)", 500,730);
}
/*---------------------------------------------------------------------------------------------------*/
=======
//gp
PImage[] images = new PImage[26];
PFont [] f=new PFont[25];
float ang1;
boolean mainpage;
int texts, bsw, bsh, buttons, instructionspb, backinfo, backpic, backpicc, spacesw, spacesh, currentLevel;
void setup() {
  ang1=0;
  texts=40;
  mainpage=true;
  bsw=80; 
  bsh=80;
  buttons=0;
  instructionspb=0;
  spacesw=50;
  spacesh=300;
  currentLevel=-1;
  backinfo=0; // 0  nothing   1 -x  next button   last page dont have
  //noCursor();
  size(1024, 768);  
  loadimages();
  loadfonts();
}
void loadimages() {
  for (int i=1; i<23; i++) {
    images[i]=loadImage("Picture"+i+".png");
  }
  images[0] = loadImage("startup.jpg");
}

void loadfonts() {
  for (int i=1; i<6; i++) {
    f[i]=loadFont("Algerian-48.vlw");
  }
  f[0]=loadFont("ARCHRISTY-48.vlw");
  f[8]=loadFont("Algerian-48.vlw");
  //out team
  //name 
  f[9]=loadFont("BritannicBold-48.vlw");
  //instructions
  f[6]=loadFont("ARDESTINE-48.vlw");
  f[10]=loadFont("ArialRoundedMTBold-48.vlw");
}
void draw() {
  ang1+=0.4;
  backpic=millis();
  //background title and picture
  pushMatrix();
  translate(512, 384);
  rotate((radians(0.5*ang1)));
  image(images[0], -1024, -768, 2048, 1536);
  popMatrix();  
  fill(#D5F3E9);
  textFont(f[0], 100);
  textAlign(CENTER);
  text("Interstellar", 512, 160);
  //mouse
  if (mainpage==true) {
    startup();
    link();
  }
  if (buttons==1) {
    backgroundstory();
    image(images[6], 907, 600, bsw, bsh);
  } else if (buttons ==2) {
    instructions();
    image(images[6], 907, 600, bsw, bsh);
  } else if (buttons==3) {
    playnow();
    image(images[6], 907, 600, bsw, bsh);
  } else if (buttons ==4) {
    ourteam();
    image(images[6], 907, 600, bsw, bsh);
  } else if (buttons==5) {
    Exit();
  }
  //instruction , button next and back
  if (instructionspb==1) {
    //go to next page
    image(images[13], 180, 270, 620, 350);
    image(images[15], 720, 605, 120, 40);
    fill(#110205);
    textFont(f[6], 45);
    textAlign(LEFT);
    text("Game Tips", 222, 300);
  }
  if (instructionspb==2) {
    image(images[12], 500, 380, 300, 200);
    image(images[14], 720, 605, 120, 40);
    fill(#110205);
    textFont(f[6], 45);
    textAlign(LEFT);
    text("Game Tips", 222, 300);
    //go to previous page
  }
  if (backinfo==1) {
    image(images[14], 730, 605, 120, 40);
    fill(#120222);
    textFont(f[10], 25);
    textAlign(LEFT);
    text("In the year 2127, due to the greed of humanity, \nhuman beings have no way to halt the ecological \nand environmental deterioration. Human \nactivities has broken the nature that \noneself rely for existence, making whole \nthe Earth sink into the resources dried up \nwith the crisis of the pollution of the \nenvironment.", 202, 370);
  }
  if (backinfo==2) {
    image(images[14], 730, 605, 120, 40);
    image(images[18], 190, 325, 440, 310);
    if ((millis()-backpicc)>2000)
      image(images[17], 190, 325, 440, 310);
    if ((millis()-backpicc)>2900)
      image(images[17], 390, 325, 220, 310);
    if ((millis()-backpicc)>3800)
      image(images[17], 190, 325, 220, 310);
    if ((millis()-backpicc)>5500)
      image(images[19], 190, 325, 440, 310);
    if ((millis()-backpicc)>6800) {
      textFont(f[10], 25);
      textAlign(LEFT);
      text("For the sake of\nself existence \nand \nmultiplication, \npeople must \nimmigrant to \na new planet.", 650, 350);
    }
  }
  if (backinfo==3) {
    fill(#120222);
    textFont(f[10], 25);
    textAlign(LEFT);
    text("So, people build a advanced \nspaceship to travel in space.", 430, 380);
    image(images[21], spacesw+190, spacesh+20, 100, 300);
    if ((millis()-backpicc)>2500)
      text("Bearing the hope of all human \nbeings and the missions to \nfind a new planet, astronauts \nstart to explore the universe.", 430, 480);
    if ((millis()-backpicc)>6000)
      spacesh-=20;
    ;
  }
  image(images[5], mouseX-15, mouseY-15, 60, 60);
}

void startup() {

  //buttons
  textAlign(LEFT);
  pushMatrix(); 
  translate(280, 260);
  rotate(radians(ang1));
  image(images[2], -35, -35, 70, 70);
  popMatrix();

  pushMatrix();
  translate(278, 358);
  rotate(radians(ang1*0.5));
  image(images[4], -35, -35, 70, 70);
  popMatrix();

  pushMatrix();
  translate(280, 460);
  rotate(radians(-ang1));
  image(images[3], -35, -35, 70, 70 );
  popMatrix();

  pushMatrix();
  translate(279, 560);
  rotate(radians(-ang1*0.5));
  image(images[1], -34, -34, 68, 68);
  popMatrix();

  pushMatrix();
  translate(280, 660);
  rotate(radians(ang1*0.8));
  image(images[10], -33, -33, 66, 66);
  popMatrix();
}
void link() {
  //start to play
  if (mouseX<667&&mouseX>408&&mouseY>244&&mouseY<276) {
    texts=43;
    if (mousePressed==true) {
      fill(#DDEE00);
      buttons=3;
      mainpage=false;
      currentLevel=0;
    }
  } else {
    texts=40;
    fill(#FAEAFC);
  }
  textFont(f[1], texts);
  text("Start Game", 410, 273);
  //instructions
  if (mouseX<623&&mouseX>409&&mouseY>343&&mouseY<381) {
    texts=43;
    if (mousePressed==true) {
      fill(#DDEE00);
      buttons=2;
      mainpage=false;
      instructionspb=2;
    }
  } else {
    texts=40;
    fill(#FAEAFC);
  }
  textFont(f[2], texts);
  text("Game Tips", 410, 375);
  //background story
  if (mouseX<813&&mouseX>409&&mouseY>443&&mouseY<476) {
    texts=43;
    if (mousePressed==true) {
      fill(#DDEE00);
      buttons=1;
      mainpage=false;
      backinfo=1;
    }
  } else {
    fill(#FAEAFC);
    texts=40;
  }
  textFont(f[3], texts);
  text("Background Story", 410, 472);
  //our team
  if (mouseX<610&&mouseX>411&&mouseY>545&&mouseY<583) {
    texts=43;
    if (mousePressed==true) {
      fill(#DDEE00);
      buttons=4;
      mainpage=false;
    }
  } else {
    fill(#FAEAFC);
    texts=40;
  }
  textFont(f[4], texts);
  text("Our Team", 410, 577); 
  //exit
  if (mouseX<503&&mouseX>409&&mouseY>649&&mouseY<685) {
    texts=43;
    if (mousePressed==true) {
      fill(#DDEE00);
      buttons=5;
      mainpage=false;
    }
  } else {
    texts=40;
    fill(#FAEAFC);
  }
  textFont(f[8], texts);
  text("Exit", 410, 680);
}

void mouseClicked() {
  //back and reset
  if (mouseX<982&&mouseX>909&&mouseY>609&&mouseY<676) {
    mainpage=true;
    buttons=0;
    instructionspb=0;
    backinfo=0;
    spacesw=200;
    spacesh=300;
    currentLevel=-1;
  }
  if (instructionspb!=0) {
    if (mouseX<845&&mouseX>720&&mouseY>605&&mouseY<645) {
      if (instructionspb==2)
        instructionspb=1;
      else
        instructionspb=2;
    }
  }
  if (backinfo!=0&&backinfo<3) {
    if (mouseX<850&&mouseX>727&&mouseY>605&&mouseY<645)
      backinfo++;
    if (backinfo==2)
      backpicc=millis();
    if (backinfo==3)
      backpicc=millis();
  }
  //game level
  if (currentLevel!=-1) {
    if (mouseX<675&&mouseX>255&&mouseY>346&&mouseY<399)
      currentLevel=1;
    if (mouseX<675&&mouseX>255&&mouseY>418&&mouseY<475)
      currentLevel=2;
    if (mouseX<675&&mouseX>255&&mouseY>491&&mouseY<546)
      currentLevel=3;
    if (mouseX<675&&mouseX>255&&mouseY>566&&mouseY<620)
      currentLevel=4;
  }
  println(mouseX, mouseY);
}

void backgroundstory() {
  image(images[11], 145, 220, 730, 450);
  image(images[7], 140, 220, 740, 450);
  fill(#110205);
  textFont(f[6], 45);
  textAlign(LEFT);
  text("Background Story", 202, 300);
}

void instructions() {
  image(images[11], 145, 220, 730, 450);
  image(images[7], 140, 220, 740, 450);
  fill(#110205);
  textFont(f[6], 45);
  textAlign(LEFT);
  text("Game Tips", 222, 300);
  //button next
  fill(#FF11DD);
  textFont(f[9], 30);
  textAlign(LEFT);
  textLeading(50);
  text("Basically, player uses arrows\nto control the space\nship to complete\nmissions.", 220, 360);
}

void playnow() {
  image(images[16], 240, 330, 450, 300);
  image(images[7], 140, 220, 740, 450);
  fill(#110205);
  textFont(f[6], 45);
  textAlign(LEFT);
  text("Play Now", 222, 300);
  //choose different levels
}

void ourteam() {
  image(images[11], 145, 220, 730, 450);
  image(images[7], 140, 220, 740, 450);
  fill(#110205);
  textFont(f[6], 45);
  textAlign(LEFT);
  text("Our Team", 222, 300);
  fill(#122123);
  textFont(f[9], 35);
  textAlign(LEFT);
  textLeading(66);
  text("TAN Bowen (CM)\nSHEN Jiahui(CM)\nLI Jiaoda(ECE)\nGUO Xing(CS)", 280, 388);
 
}
void Exit() {
  exit();
}

>>>>>>> origin/guoxing
