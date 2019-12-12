
void setup() {
  size(1024,768);

}
int currentLevel=0;
void draw(){
  pause();
}
void mouseClicked(){
  println(mouseX,mouseY);
}
void pause(){
  if(currentLevel!=-1) 
    if(keyPressed==true)
      if(key==' '){
        image(images[22], 300, 270, 360, 150);        
      }
}
//back
if (mouseX<428&&mouseX>361&&mouseY>316&&mouseY<372)
      mainpage=true;
    buttons=0;
    instructionspb=0;
    backinfo=0;
    spacesw=200;
    spacesh=300;
    currentLevel=-1;
if (mouseX<517&&mouseX>437&&mouseY>316&&mouseY<372)

if (mouseX<586&&mouseX>529&&mouseY>316&&mouseY<372)
