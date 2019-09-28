
int grid_size = 5; //Width/height of each lattice site
int ncols, nrows;  //Number of rows/columns. 
float beta = 0.00001;    //Inverse temperature scale. 
float J = 1;       //The interaction energy
float[][] angles; //Stores the angles, I think 0...2*pi strict
String drawstyle = "colors"; //colors or arrows

HScrollbar beta_h;

//Here is some colour function that takes us from angle space to colour space
color a_to_c(float a){
  return color(a/(2*PI),1,1);
}


void setup() {
  //Set up the screen and stuff
  size(1000, 700);
  frameRate(30);
  colorMode(HSB, 1);
  ncols = height/grid_size;
  nrows = height/grid_size;
  angles = new float[ncols][nrows];
  beta_h = new HScrollbar(750, 10, 200, 16, 1);
  
  //Initialise the angles
  for (int i = 0; i < ncols; i++){
    for (int j = 0; j < ncols; j++){
      angles[i][j] = random(0,2*PI);
    } 
  }
}



void draw() {
  background(1,0,1);
  //Here, we do some MCMC stuff
  //Should we try to just change one point and see how fast it stabilizes?
  for (int i = 0; i < 10000; i++){
    int rx = int(random(0,ncols)); 
    int ry = int(random(0,ncols));
    float ra = random(0,2*PI);
    float[] nba = {angles[(rx+1)%nrows][ry],
                    angles[(rx-1+nrows)%nrows][ry],
                    angles[rx][(ry-1+ncols)%ncols],
                    angles[rx][(ry+1)%ncols]};
    float new_energy = 0; float old_energy = 0;
    for (float at : nba){
      new_energy = new_energy + cos(angles[rx][ry]-at);
      old_energy = old_energy + cos(ra - at);
    }
    float t_prob = exp(-beta*J*(new_energy-old_energy)); 
    if (random(0,1) <= t_prob){
      angles[rx][ry] = ra;
    }
  }
  
  beta = pow(10,beta_h.getPos()*10-5);
  
  beta_h.update();
  beta_h.display();
  
  
  
  for (int i = 0; i < ncols; i++) {
    for (int j = 0; j < nrows; j++) {
      if (drawstyle == "colors"){
        fill(a_to_c(angles[i][j]));
        square(i*grid_size,j*grid_size,grid_size);
      }
      else if (drawstyle == "arrows"){
        stroke(1,1,0);
        fill(1,1,0);
        //line(i*grid_size+grid_size/2+(grid_size/3)*cos(angles[i][j]),j*grid_size+grid_size/2+(grid_size/3)*sin(angles[i][j]),
        //     i*grid_size+grid_size/2-(grid_size/3)*cos(angles[i][j]),j*grid_size+grid_size/2-(grid_size/3)*sin(angles[i][j]));
        //square(i*grid_size+grid_size/2+(grid_size/3)*cos(angles[i][j]),j*grid_size+grid_size/2+(grid_size/3)*sin(angles[i][j]),grid_size/5);
        line(i*grid_size+grid_size/2,j*grid_size+grid_size/2,
            i*grid_size+grid_size/2-(grid_size)*cos(angles[i][j]),j*grid_size+grid_size/2-(grid_size)*sin(angles[i][j]));
      }
    }
  }
}



class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    //fill(1,1,1);
    
    noStroke();
    fill(0.5,1,1);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos-xpos)/swidth;
  }
}



void keyPressed(){
 if (key == 'g'){
   for (int i = 0; i < nrows; i++){
     for (int j = 0; j < ncols; j++){
       angles[i][j] = 0;
     }
   }
 }
 else if (key == 'a'){
   if (drawstyle == "colors"){
     drawstyle = "arrows";
   }
   else{
     drawstyle = "colors"; 
   }
 }
  
}
