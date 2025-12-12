//Storing the firework objects in ArrayList
ArrayList<Firework> fireworks = new ArrayList<Firework>();

//Setting up the grid
int cols = 9;
int rows = 7;
float cellW, cellH;
int hoveredIndex = -1;

//Data from the excel file
//https://processing.org/reference/Table.html
Table table;

void setup() {
  size(800,500);
  //To make the particles look smoother
  //https://processing.org/reference/smooth_.html
  smooth(4);
  
  //This calculates the cell size for the grid
  cellW = width / cols;
  cellH = height/ rows;
  
  //To load the excel table
  //The "header" is needed so that the first line of the excel file, the column titles, become keys such as "Day" and "Mood"
  table = loadTable("DearDataExcel.csv", "header");
  
  int rowIndex = 0;
  
  //Nested for loop to put one firework in each cell and stops when there are no rows left 
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (rowIndex >= table.getRowCount()) break;
      
      //Getting values from the rows in the excel file
      //https://processing.org/reference/Table_getRow_.html
      TableRow row = table.getRow(rowIndex);
      
      //Variables
      int day = row.getInt("Day");
      int checks = row.getInt("Checks");
      String mood = row.getString("Mood");
      String location = row.getString("Location");
      
      float x = c * cellW + cellW/2;
      float y = r * cellH + cellH/2;
      
      //Make the firework object
      fireworks.add(new Firework(x, y, checks, day, mood, location));
      
      rowIndex++;
    }
  }
}

void draw() {
  background(0);
  hoveredIndex = getHoverIndex();
  
  for(Firework f : fireworks) {
    f.update();
    f.show();
  }
  
  drawGrid();
  drawUI();
}

void drawUI() {
  fill(255);
  textSize(20);
  text("Hover over rectangles for details || Click for mood firework", 20,30);
  
  //This shows the information from the excel file when you hover over the cells
  if (hoveredIndex != -1) {
    Firework f = fireworks.get(hoveredIndex);
    
    fill(255);
    textSize(16);
    text("Day " + f.dayIndex + " | Mood: " + f.mood + " | Checks: " + f.checks + " | Location: " + f.location, width - 400, height - 35);
  }
}

//Making the selected cell more obvious to user by having cell outlines and highlights
void drawGrid() {
  for (int i = 0; i < fireworks.size(); i++) {
    int r = i / cols;
    int c = i % cols;
    
    float x = c * cellW;
    float y = r * cellH;
    
    noFill();
    stroke(50);
    rect(x, y, cellW, cellH);
    
    if (i == hoveredIndex) {
      stroke(120,180,255);
      strokeWeight(2);
      rect(x+2, y+2, cellW-4, cellH-4);
    }
  }
}

int getHoverIndex() {
  int c = int(mouseX / cellW);
  int r = int(mouseY / cellH);
  int index = r * cols + c;
  
  if (index >= 0 && index < fireworks.size()) return index;
  return -1;
}

//Firework explodes when the mouse is pressed
void mousePressed() {
  int index = getHoverIndex();
  if (index != -1) fireworks.get(index).explode();
}

class Firework {
  float x, y;
  int checks;       //Number of particles that appear in each firework is equal to the number of times I checked the time
  int dayIndex;
  String mood;
  String location;
  boolean exploding = false;
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  Firework(float x, float y, int checks, int dayIndex, String mood, String location) {
    this.x = x;
    this.y = y;
    this.checks = checks;
    this.dayIndex = dayIndex;
    this.mood = mood;
    this.location = location;
  }
  
  void explode() {
    particles.clear();
    exploding = true;
    
    for(int i = 0; i < checks; i++) {
      float angle = random(2*PI);
      float speed = random(2,5);
      
      particles.add(new Particle(x, y, angle, speed, moodColor(mood)));
    }
  }
  
  //Updates the movement of the particles
  void update() {
    if (!exploding) return;
    for (Particle p : particles) p.update();
  }
  
  //Draws the particles on the screen
  void show() {
    if (!exploding) return;
    for (Particle p : particles) p.show();
  }
}

class Particle {
  float x, y;
  float vx, vy;
  float life = 255;
  color c;
  
  Particle(float x, float y, float angle, float speed, color c) {
    this.x = x;
    this.y = y;
    this.c = c;
    
    //ChatGPT helped to convert the angle and speed into velocity of x and y
    //https://processing.org/reference/cos_.html
    //https://processing.org/reference/sin_.html
    //This makes the particles explode in different directions and speed
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }
  
  void update() {
    x += vx;
    y += vy;
    
    //This is to slow down
    vx *= 0.97;
    vy *= 0.97;
    
    //This is to fade out the particles and become more transparent over time
    life -= 3;
  }
  
  void show() {
    stroke(c, life);
    strokeWeight(3);
    point(x, y);
  }
}

//This changes the colour of the fireworks based on the mood
color moodColor(String m) {
  switch(m) {
    case "Happy": return color(255,220,0);
    case "Nervous": return color(255,80,80);
    case "Calm": return color(100,160,255);
    case "Bored": return color(180);
  }
  //The default colour of the fireworks is white, will happen if none of the moods listed match the data in the excel file
  return color(255);
}   
