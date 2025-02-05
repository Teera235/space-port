#include <Wire.h>

const int MPU_ADDR = 0x68;
float angleX = 0, angleY = 0;
unsigned long previousTime = 0;

void setup() {
  Wire.begin();
  Serial.begin(115200);
  
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B); 
  Wire.write(0x00);
  Wire.endTransmission(true);
}

void loop() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);

  int16_t AcX = Wire.read() << 8 | Wire.read();
  int16_t AcY = Wire.read() << 8 | Wire.read();
  int16_t AcZ = Wire.read() << 8 | Wire.read();
  
  int16_t GyX = Wire.read() << 8 | Wire.read();
  int16_t GyY = Wire.read() << 8 | Wire.read();
  int16_t GyZ = Wire.read() << 8 | Wire.read();

  unsigned long currentTime = micros();
  float deltaTime = (currentTime - previousTime) / 1000000.0;
  previousTime = currentTime;

  float gyroXRate = GyX / 131.0;
  float gyroYRate = GyY / 131.0;

  float accelXAngle = atan2(AcY, AcZ) * 180 / PI;
  float accelYAngle = atan2(-AcX, sqrt(AcY * AcY + AcZ * AcZ)) * 180 / PI;

  const float alpha = 0.96;
  angleX = alpha * (angleX + gyroXRate * deltaTime) + (1.0 - alpha) * accelXAngle;
  angleY = alpha * (angleY + gyroYRate * deltaTime) + (1.0 - alpha) * accelYAngle;

  Serial.print("Angle X: ");
  Serial.print(angleX);
  Serial.print(" | Angle Y: ");
  Serial.println(angleY);

  delay(50);
}
