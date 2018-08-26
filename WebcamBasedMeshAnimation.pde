// The code below is 
// based on my initial code AVEXTENSIONDRAFT_013 from 12/02/2016

import processing.video.*;

Capture video;
int numCellsX = 32;
int numCellsZ = 24;
int cellSize = 40;
float r, r2;
int colourMode = 0;
float stretchFactor; 

void setup()
{
  size(1024, 768, P3D);
  // for simplicity and speed we capture a low res video
  // with the width and height like our numbers of cells in rows and colums of 3D grid
  video = new Capture(this, numCellsX, numCellsZ); 
  video.start();
}

void draw() {
  checkKeyboard();
  background(0);
  stroke(255);
  noFill();
  if (video.available()) {
    processLiveVideo();
  }
  // it's possible to roate the object with a mouse in Z and X axis. However the anchor of rotation is left top corner
  rotateX(-0.15 * TWO_PI);
  rotateZ(map(mouseX, 0, width, 0, TWO_PI));
  rotateY(map(mouseY, 0, height, 0, TWO_PI));
  translate(width / 2, height / 2, map(mouseY,0,height,-100,100));
  draw3Dgrid();
  
  println(map(mouseX, 0, width, 0, TWO_PI) + " " + map(mouseY, 0, height, 0, TWO_PI));

}

void checkKeyboard()
{
  if (keyPressed) {
    if (key=='z') {
       colourMode = (colourMode + 1) % 3;
    }
  }
}

void processLiveVideo()
{
  video.read();
  video.loadPixels();
}

void draw3Dgrid()
{
  stretchFactor = map(sin(frameCount * 0.001), -1, 1, 100, 250);
  pushMatrix();
  translate(0, 0, -50);
  for (int xx=0; xx<numCellsX; xx++)
  {
    for (int zz=0; zz<numCellsZ; zz++)
    {
      // Extract the red green and blue values from the video pixels
      int pixelColor = video.pixels[xx + zz * numCellsX];
      // Faster method of calculating r, g, b than red(), green(), blue() 
      // Reference: Ben Fry AsciiVideo.pde sketch from the Video library examples
      //
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      
      if (colourMode == 0)
      {
        stroke(xx * 10, zz * 10, xx * 10, xx + 50 * 10); // green and violet gradient
        if (xx == 0 && zz==0)
          stroke(255); // visualise the grid spot 0, 0 to help the rotation coding
      } else if (colourMode == 1)
      {
        stroke(255, 255, 255, xx + 50 * 10); // only the aplpha value is modified depending on position
      } else if (colourMode == 2)
      {
        stroke(r, g, b);
      }

      beginShape(QUADS);
      vertex(xx * cellSize, sin(frameCount * 0.01)*stretchFactor, zz * cellSize);
      vertex(xx * cellSize + cellSize, sin(frameCount * 0.02)*stretchFactor, zz * cellSize);
      vertex(xx * cellSize + cellSize, sin(map(b,255,0,0,TWO_PI))*stretchFactor, zz * cellSize + cellSize); 
      vertex(xx * cellSize, sin(map(r,255,0,0,TWO_PI))*stretchFactor, zz * cellSize + cellSize);
      endShape(QUADS);
    }
  }
  popMatrix();
}