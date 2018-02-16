Table table;
PFont font;
PImage img;

ArrayList<City> cities = new ArrayList<City>();
ArrayList<Temp> temps = new ArrayList<Temp>();
ArrayList<Surv> survs = new ArrayList<Surv>();

// How every row in the data imported will be saved
class City {
  public float lonc = 0;
  public float latc = 0;  
  public String city = "";
}

class Temp {
  public float lont = 0;
  public int temp = 0;
  public int days = 0;
  public String mon = "";
  public int day = 0;
}

class Surv {
  public float lonp = 0;
  public float latp = 0;
  public int surv = 0;
  public String dir = "";
  public int div = 0;
}


void setup() {
  size(1800, 900);
  table = loadTable("res/minard-data.csv", "header");
  font = createFont("res/Chelsea.ttf", 15);
  img = loadImage("res/back.jpg");
  img.resize(width, height);
  textFont(font);
  import_data();
}

void draw() {
  background(img);
  fill(255,190);
  rect(0, 0, width, height);
  render_temp();
  render_lines();
  render_text();
  draw_label_box();
}
void render_lines() {
  // Render the lines for the size of the survivors
  float x1, y1, x2, y2;
  for (int i = survs.size()-2; i>=1; i--) {
    if (survs.get(i).div != survs.get(i+1).div) continue;
    selectColor(survs.get(i));
    x1 = survs.get(i).lonp;
    y1 = survs.get(i).latp;  
    x2 = survs.get(i+1).lonp; 
    y2 = survs.get(i+1).latp;
    line(normalize_x(x1), normalize_y(y1), normalize_x(x2), normalize_y(y2));
  }

  selectColor(survs.get(0));  
  x1 = survs.get(0).lonp;
  y1 = survs.get(0).latp;  
  x2 = survs.get(1).lonp; 
  y2 = survs.get(1).latp;  
  line(normalize_x(x1), normalize_y(y1), normalize_x(x2), normalize_y(y2));
}
void selectColor(Surv s) {
  float strokeW = norm(s.surv, 4000, 340000) * 40;
  strokeWeight(max(1, strokeW));
  float alpha = max(200, norm(s.surv, 4000, 340000) * 255);
  if (s.div == 1) {
    if (s.dir.equals("A")) stroke(#27ae60, alpha);
    else stroke(#2ecc71, alpha);
  } else if (s.div == 2) {
    if (s.dir.equals("A")) stroke(#2980b9, alpha);
    else stroke(#3498db, alpha);
  } else {
    if (s.dir.equals("A")) stroke(#c0392b, alpha);
    else stroke(#e74c3c, alpha);
  }
}

void render_text() {
  // Render the Texts for the city labels
  for (City c : cities) {
    fill(#ecf0f1); 
    strokeWeight(1);
    stroke(#2c3e50);
    ellipse(normalize_x(c.lonc), normalize_y(c.latc), 5, 5);

    fill(#ecf0f1, 220); 
    strokeWeight(1);
    stroke(#2c3e50);
    float textWidth = textWidth(c.city);
    rect(normalize_x(c.lonc) + 5, normalize_y(c.latc), textWidth+7, 17, 0, 3, 3, 3);    

    fill(#2c3e50); 
    textAlign(LEFT, CENTER);
    text(c.city, normalize_x(c.lonc) + 9, normalize_y(c.latc)+6.5);
  }
}

void render_temp() {
  for (int i = 0; i<6; i++) {
    fill(#2c3e50, 100);
    strokeWeight(0.1);
    line(250, i * 6 * 5 + 650, width-180,i * 6 * 5 + 650);
    fill(#2c3e50, 255);
    textAlign(RIGHT);
    text(i*6, 250-10, i * 6 * 5 + 655);
  }
  
  text("Temperature (C)", 250-40, 2.5 * 6 * 5 + 655);
  text("Longitude", width/2+100, 6 * 6 * 5 + 655);
  
  line(250+10, 650-10, 250 + 10,5 * 6 * 5 + 650+10);

  for (int i = 1; i<temps.size(); i++) {
    Temp t_1 = temps.get(i);
    Temp t = temps.get(i-1);

    float x1 = t.lont;    
    float y1 = -t.temp * 5 + 650;
    float x2 = t_1.lont;
    float y2 = -t_1.temp * 5 + 650;  

    fill(#ecf0f1); 
    strokeWeight(2);
    stroke(#2c3e50);
    line(normalize_x(x1), y1, normalize_x(x2), y2);    
    draw_point_and_bubble(t);
  }    
  draw_point_and_bubble(temps.get(temps.size()-1));
}

void draw_point_and_bubble(Temp t) {
  // Draw Point
  fill(#ecf0f1); 
  strokeWeight(2);    
  stroke(#8e44ad);
  ellipse(normalize_x(t.lont), -t.temp * 5 + 650, 5, 5);

  // Draw Bubble
  fill(#ecf0f1, 220); 
  strokeWeight(1);
  stroke(#8e44ad);    
  String text = "" + t.temp;    
  float textWidth = textWidth(text);
  rect(normalize_x(t.lont) + 5, -t.temp * 5 + 650, textWidth+7, 17, 0, 3, 3, 3);
  fill(#2c3e50); 
  textAlign(LEFT, CENTER);
  text(text, normalize_x(t.lont) + 9, -t.temp * 5 + 650+6.5);

  fill(#ecf0f1, 220); 
  strokeWeight(1);
  stroke(#8e44ad);
  text = t.mon + ". " + t.day;
  textWidth = textWidth(text);
  rect(normalize_x(t.lont) + 5, -t.temp * 5 + 670, textWidth+7, 17, 0, 3, 3, 3);  
  fill(#2c3e50); 
  textAlign(LEFT, CENTER);
  text(text, normalize_x(t.lont) + 9, -t.temp * 5 + 670+6.5);
}

void import_data() {
  for (TableRow row : table.rows()) {    
    if (!Double.isNaN(row.getFloat(0))) {
      City c = new City();
      c.lonc = row.getFloat(0);
      c.latc = row.getFloat(1);
      c.city = row.getString(2);
      cities.add(c);
    }

    if (!Double.isNaN(row.getFloat(3))) {
      Temp t = new Temp();
      t.lont = row.getFloat(3);
      t.temp = row.getInt(4);
      t.days = row.getInt(5);
      t.mon = row.getString(6);
      t.day = row.getInt(7);
      temps.add(t);
    }

    Surv s = new Surv();
    s.lonp = row.getFloat(8);
    s.latp = row.getFloat(9);
    s.surv = row.getInt(10);
    s.dir = row.getString(11);
    s.div = row.getInt(12);
    survs.add(s);
  }
}
void draw_label_box() {
  label(#2ecc71, #27ae60, width/2 + 590, height/2 + 50, "Division 1");
  label(#3498db, #2980b9, width/2 + 590, height/2 + 70, "Division 2");
  label(#e74c3c, #c0392b, width/2 + 590, height/2 + 90, "Division 3");

  noFill();
  stroke(0, 150);
  rect(width/2+580, height/2 + 40, 110, 70);
}

void label(color c1, color strokeC, float x, float y, String text) {
  fill(c1, 150);
  stroke(strokeC);
  rect(x, y, 10, 10);
  textSize(15); 
  fill(0, 190);
  textAlign(LEFT, CENTER);
  text(text, x+20, y+3);
}

float normalize_x(float x) {
  return norm(x, 24, 36.5) * width/1.5 + width/6;
}

float normalize_y(float y) {
  return norm(y, 53.9, 55.8) * -height/2 + height/1.5;
}