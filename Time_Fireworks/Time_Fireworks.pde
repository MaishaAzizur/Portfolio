ArrayList<Firework> fireworks = new ArrayList<Firework>();

int cols = 9;
int rows = 7;
float cellW, cellH;
int hoveredIndex = -1;

Table table;

void setup() {
  size(800,500);
  smooth(4);
  cellW = width / cols;
  cellH = height/ rows;
  
  table = loadTable("DearDataExcel.csv", "header");
  
  int rowIndex = 0;
  
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (rowIndex >= table.getRowCount()) break;
      
      TableRow row = table.getRow(rowIndex);
      
      int day = row.getInt("Day");
      int checks = row.getInt("Checks");
      String mood = row.getString("Mood");
      String location = row.getString("Location");
      
      float x = c * cellW + cellW/2;
      float y = r * cellH + cellH/2;
      
      
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
  
  if (hoveredIndex != -1) {
    Firework f = fireworks.get(hoveredIndex);
    
    fill(255);
    textSize(16);
    text("Day " + f.dayIndex + " | Mood: " + f.mood + " | Checks: " + f.checks + " | Location: " + f.location, width - 400, height - 35);
  }
}

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

void mousePressed() {
  int index = getHoverIndex();
  if (index != -1) fireworks.get(index).explode();
}

class Firework {
  float x, y;
  int checks;
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
  
  void update() {
    if (!exploding) return;
    for (Particle p : particles) p.update();
  }
  
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
    
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }
  
  void update() {
    x += vx;
    y += vy;
    
    vx *= 0.97;
    vy *= 0.97;
    
    life -= 3;
  }
  
  void show() {
    stroke(c, life);
    strokeWeight(3);
    point(x, y);
  }
}

color moodColor(String m) {
  switch(m) {
    case "Happy": return color(255,220,0);
    case "Nervous": return color(255,80,80);
    case "Calm": return color(100,160,255);
    case "Bored": return color(180);
  }
  return color(255);
}   
