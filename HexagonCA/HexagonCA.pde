
/*

 Hexagon Cellular Automata by Amnon Owed (May 2013)
 https://github.com/AmnonOwed
 http://vimeo.com/amnon

 2D cellular automata on a hexagonal grid.
 Visualized using the HSB color space, specifically the hue.
 Instead of rigid states this sketch uses the hue range (0 to 360) to evolve.
 
 Neighours are found via a distance method, which has two advantages:
  1. Easy to code. Easy to read. No edge problems (aka out-of-bounds issues).
  2. Flexible. The distance can be changed to include an arbitrary range of neighbours.
 The disadvantage is that it's slower than traditional +/- 1 methods to find neighbours.
 But since the grid is static, the neighbour search is only done once, so this is acceptable.

 For background info on cellular automata check out:
 http://natureofcode.com/book/chapter-7-cellular-automata/

 MOUSE PRESS = generate new colors for all hexagon cells on the grid

 SPACE = randomly set the hexagonRadius and re-initialize the whole grid (may take some time)

 Built with Processing 1.5.1.
 Compatible with Processing 2.0+

*/

import processing.opengl.*; // the OpenGL library

float hexagonRadius = 9.4; // the radius of the individual hexagon cell
float hexagonStroke = 1; // stroke weight around hexagons (simulated! much faster than using the stroke() method)
color strokeColor = color(0); // stroke color around hexagons (simulated! much faster than using the stroke() method)
float neighbourDistance = hexagonRadius*2; // the default distance to include up to 6 neighbours

ArrayList <Hexagon> grid = new ArrayList <Hexagon> (); // the arrayList to store the whole grid of cells
PVector[] v = new PVector[6]; // an array to store the 6 pre-calculated vertex positions of a hexagon

void setup() {
  size(1280, 720, OPENGL); // rendering with the OpenGL renderer is significantly faster when there is a lot of on-screen geometry
  // set colorMode to HSB which usually works with 360 degrees hue range and 100 saturation and brightness ranges
  colorMode(HSB, 360, 100, 100);
  noStroke(); // turn off stroke (for the rest of the sketch) since we use a much faster simulated stroke method
  smooth(); // turn on smooth(). Note that OpenGL smoothness usually depends on local graphics cards (aka anti-aliasing) settings
  initGrid(); // initialize the CA grid of hexagons (including neighbour search and creation of hexagon vertex positions)
}

void draw() {
  background(strokeColor); // background aka simulated stroke color

  // calculate a new color for each hexagon cell in the grid
  // calculations are done for the whole grid without changing colors directly
  // because immediate color changes would impact the calculations
  for (Hexagon h : grid) { h.calculateNewColor(); }

  // change the color of each hexagon cell to the new color and display it
  // this can be done in one loop because all calculations are already finished
  for (Hexagon h : grid) {
    h.changeColor();
    h.display();
  }
}

void mousePressed() {
  float r = random(1000000); // random number that is used by all the hexagon cells...
  for (Hexagon h : grid) { h.resetColor(r); } // ... to generate a new color
}

void keyPressed() {
  if (key == ' ') {
    hexagonRadius = random(6, 20); // randomly set the hexagonRadius
    neighbourDistance = hexagonRadius*2; // adapt the neighbourDistance accordingly
    initGrid(); // re-initialize the whole grid
  }
}

// do everything needed to start up the grid ONCE
void initGrid() {
  grid.clear(); // clear the grid
  
  // calculate horizontal grid size based on sketch width, hexagonRadius and a 'safety margin'
  int hX = int(width/hexagonRadius/3)+2;
  // calculate vertical grid size based on sketch height, hexagonRadius and a 'safety margin'
  int hY = int(height/hexagonRadius/0.866)+3;
  
  // create the grid of hexagons
  for (int i=0; i<hX; i++) {
    for (int j=0; j<hY; j++) {
      // each hexagon contains it's xy position within the grid (also see the Hexagon class)
      grid.add( new Hexagon(i, j) );
    }
  }
  
  // let each hexagon in the grid find it's neighbours
  for (Hexagon h : grid) {
    h.getNeighbours(neighbourDistance);
  }
  
  // create the vertex positions for the hexagon
  for (int i=0; i<6; i++) {
    float r = hexagonRadius - hexagonStroke * 0.5; // adapt radius to facilitate the 'simulated stroke'
    float theta = i*PI/3;
    v[i] = new PVector(r*cos(theta), r*sin(theta));
  }
}

