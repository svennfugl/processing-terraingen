// Movement
float xoff = 0;
float yoff = 0;
float travelSpeed = 0.02f;

// Generation properties
float noiseScale = 0.01f;
float continentScale = 0.2f;
int maxOctaves = 4;

// Value array
float values[][];

// Terrain data
float terrainThresholds[] = {
  0.24f,  // Very deep ocean
  0.27f,  // Deep ocean
  0.33f,  // Ocean
  0.34f,  // Shore
  0.36f,  // Sand
  0.5f,   // Lowlands
  0.8f,   // Highlands
  0.9f,   // Mountains
  1f,     // Snow
};

color terrainColor[] = {
  color(0, 0, 32),
  color(0, 0, 64),
  color(0, 0, 128),
  color(128, 128, 255),
  color(234, 234, 171),
  color(0, 90, 0),
  color(0, 128, 0),
  color(90),
  color(255)
};

void setup() {
  // Randomly set offset
  xoff = random(-1000,1000);
  yoff = random(1000, 100000);
  
  size(700,700);
  values = new float[height][width];
  
  noSmooth(); // Disable antialiasing, for speed
}

void draw() {
  // Recalculate
  CalculateValues();
  
  // Load the canvas into memory
  loadPixels();
  
  // Iterate through each pixel
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      color c = GetHeightColor(values[x][y], values[min(x+1, width-1)][max(y-1, 0)]);
      
      pixels[x+y*width] = c;
    }
  }
  
  // Update screen
  updatePixels();
  
  // Change offset
  yoff-=travelSpeed;
  
  // Draw text
  fill(0);
  text("Press [Enter] to warp to a new position", 1, 10);
  fill(255);
  text("Press [Enter] to warp to a new position", 0, 10);
}

void keyPressed() {
  if(keyCode == ENTER) {
    xoff = random(-1000,1000);
    yoff = random(1000, 100000);
  }
}

color GetHeightColor(float value, float neighborValue) {
  // Set default color to the last of the color index just in case
  color c = terrainColor[terrainColor.length-1];
  
  // Compare value against the terrain tresholds
  for(int i = 0; i < terrainThresholds.length; i++) {
    if(value<terrainThresholds[i]) {
      c = terrainColor[i];
      break;
    }
  }
  
  // If the value is less than the neighboring value, shade it. Helps give the map depth
  if(value<neighborValue) {
    c = color(red(c)*0.5f, green(c)*0.5f, blue(c)*0.9);
  }
  
  return c;
}

void CalculateValues() {
  // Calculate for each pixel on the canvas
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      // Calculate terrain height
      float value = 0;
      
      for(int octave = 0; octave < maxOctaves; octave++) {
        float n = pow(2, octave); 
        
        value += noise(x*noiseScale*n + xoff*n, y*noiseScale*n + yoff*n)/n;
      }
      
      // Calculate continent value
      float continentValue = noise((x*noiseScale + xoff)*continentScale, (y*noiseScale + yoff)*continentScale);
      continentValue = (continentValue*continentValue*(3-2*continentValue)); // Smoothstep function
      
      values[x][y] = value*continentValue;
    }
  }
}