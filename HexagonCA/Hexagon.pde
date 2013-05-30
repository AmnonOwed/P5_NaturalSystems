
/*

 Hexagon class to store a single cell inside a grid that can do the following things:
 - calculate it's own actual xy position based on it's ij coordinates within the grid
 - find it's neighbours within the grid based on a distance function
 - set it's color based on my own experimental color formula ;-)
 - calculate the average color of it's neighbours
 - calculate it's new color based on a set of rules
 - change it's current color by it's new color
 - display itself as a colored hexagon
 
*/

class Hexagon {
  float x, y; // actual xy position
  ArrayList <Hexagon> neighbours = new ArrayList <Hexagon> (); // arrayList to store the neighbours
  float currentColor, newColor; // store the current and new colors (actually just the hue)

  Hexagon(int i, int j) {
    x = 3*hexagonRadius*(i+((j%2==0)?0:0.5)); // calculate the actual x position within the sketch window
    y = 0.866*hexagonRadius*j; // calculate the actual y position within the sketch window
    resetColor(0); // set the initial color
  }

  void resetColor(float r) {
    currentColor = (r+sin(x+r*0.01)*30+y/6)%360; // could be anything, but this makes the grid look good! :D
  }

  // given a distance parameter, this will add all the neighbours within range to the list
  void getNeighbours(float distance) {
    // neighbours.clear(); // in this sketch not required because neighbours are only searched once
    for (Hexagon h : grid) { // for all the cells in the grid
      if (h!=this) { // if it's not the cell itself
        if (dist(x,y, h.x,h.y) < distance) { // if it's within distance
          neighbours.add( h ); // then add it to the list: "Welcome neighbour!"
        }
      }
    }
  }
  
  // calculate the new color based on a completely arbitrary set of 'rules'
  // this could be anything, right now it's this, which makes the CA pretty dynamic
  // if you tweak this in the wrong way you quickly end up with boring static states
  void calculateNewColor() {
    float avgColor = averageColor(); // get the average of the neighbours (see other method)
    float tmpColor = currentColor;
    if (avgColor < 0) {
      tmpColor = 50; // if the average color is below 0, set the color to 50
    } else if (avgColor < 150) {
      tmpColor += 5; // if the average color is between 0 and 150, add 5 to the color
    } else if (avgColor > 210) {
      tmpColor -= 5; // if the average color is above 210, subtract 5 from the color
    }
    // in all other cases (aka the average color is between 150 and 210) the color remains unchanged
    newColor = tmpColor;
  }
  
  // returns the average color (aka hue) of the neighbours
  float averageColor() {
    float avgColor = 0; // start with 0
    for (Hexagon h : neighbours) {
      avgColor += h.currentColor; // add the color from each neighbour
    }
    avgColor /= neighbours.size(); // divide by the number of neighbours
    return avgColor; // done!
  }
  
  void changeColor() {
    currentColor = newColor; // set the current color to the new(ly calculated) color
  }

  // display the hexagon at position xy with the current color
  // use the vertex positions that have been pre-calculated ONCE (instead of re-calculating these for each cell on each draw)
  void display() {
    pushMatrix();
    translate(x, y);
    fill(currentColor, 100, 100);
    beginShape();
    for (int i=0; i<6; i++) { vertex(v[i].x, v[i].y); }
    endShape();
    popMatrix();
  }
}

