import processing.serial.*;

Serial myPort;  
PShape rocketModel;
float roll = 0, pitch = 0, yaw = 0;

void setup() {
  size(800, 600, P3D);
  
  myPort = new Serial(this, "COM5", 115200);  
  myPort.bufferUntil('\n');
  
  rocketModel = loadShape("C:/Users/teerathap/Downloads/STA-Rocket-v5.obj");
  
  rocketModel.scale(2);  
  centerModel();  
  
  smooth(8);  
}

void draw() {
  background(200);
  
  fill(0);
  textSize(16);
  text("Roll: " + nf(roll, 1, 2), 10, 20);
  text("Pitch: " + nf(pitch, 1, 2), 10, 40);
  text("Yaw: " + nf(yaw, 1, 2), 10, 60);
  
  lights();
  
  translate(width / 2, height / 2, 0);
  
  rotateY(radians(-yaw));
  rotateX(radians(-pitch));
  rotateZ(radians(roll));
  
  shape(rocketModel); 
}

void serialEvent(Serial p) {
  String data = p.readStringUntil('\n');
  
  if (data != null) {
    data = trim(data);
    
    String[] angles = split(data, ',');
    
    if (angles.length == 3) {
      try {
        roll = float(angles[0]);
        pitch = float(angles[1]);
        yaw = float(angles[2]);
      } catch (NumberFormatException e) {
        println("Error parsing angles: " + e.getMessage());
      }
    } else {
      println("Error: Received incomplete data");
    }
  }
}

void centerModel() {
  float minX = Float.MAX_VALUE, minY = Float.MAX_VALUE, minZ = Float.MAX_VALUE;
  float maxX = -Float.MAX_VALUE, maxY = -Float.MAX_VALUE, maxZ = -Float.MAX_VALUE;
  
  for (int i = 0; i < rocketModel.getChildCount(); i++) {
    PShape child = rocketModel.getChild(i);
    for (int j = 0; j < child.getVertexCount(); j++) {
      PVector v = child.getVertex(j);
      if (v.x < minX) minX = v.x;
      if (v.y < minY) minY = v.y;
      if (v.z < minZ) minZ = v.z;
      if (v.x > maxX) maxX = v.x;
      if (v.y > maxY) maxY = v.y;
      if (v.z > maxZ) maxZ = v.z;
    }
  }
  
  float centerX = (minX + maxX) / 2.0;
  float centerY = (minY + maxY) / 2.0;
  float centerZ = (minZ + maxZ) / 2.0;
  
  rocketModel.translate(-centerX, -centerY, -centerZ);
}
