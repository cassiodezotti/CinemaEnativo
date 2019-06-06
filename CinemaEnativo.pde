import processing.video.*;
boolean drawSkeletonTool = true;
Scene scene = new Scene();
Sphere sphere;


int pdPort = 9000;
int myPort = 3001;
Communication communication = new Communication("143.106.219.176", pdPort, myPort);

void setup()
{
  size(600, 600, P3D);
  sphere = new Sphere(this, 0.8);
  frameRate(scene.frameRate_);
  scene.init();
}

void draw()
{
  scene.update();
  if(scene.drawScene){
    scene.draw(); // measuredSkeletons, jointOrientation, boneRelativeOrientation, handRadius, handStates
  } else{
    sphere.display(); //video sphere
    
  }
  for(Skeleton skeleton:scene.activeSkeletons.values()){ //example of consulting feature
    //sphere.cameraRotX = sphere.cameraRotX + skeleton.features.steeringWheel.pitchStep;
    sphere.cameraRotX = sphere.cameraRotX + (map(skeleton.features.steeringWheel.position.y, 1, 1.5, PI/64, -PI/64))*sphere.transZSensibility;
    sphere.cameraRotY = sphere.cameraRotY + (skeleton.features.steeringWheel.yawStep)*sphere.transZSensibility;
    sphere.cameraTransZ = map(skeleton.features.steeringWheel.positionPercentageOfRoom.z, -1, 1, 200, -200);
    
    if (sphere.cameraTransZ > 200){
      sphere.transZSensibility = 0;
    }
    else if(sphere.cameraTransZ < 0) {
      sphere.transZSensibility = 1 ; 
    }
    else {
      sphere.transZSensibility = map(skeleton.features.steeringWheel.positionPercentageOfRoom.z,-1,1,0,1);
    }
    
    communication.sendGrainParameters(skeleton,sphere);
    
    
  }
  
  
  /*if(scene.drawScene){
    scene.draw(); // measuredSkeletons, jointOrientation, boneRelativeOrientation, handRadius, handStates
  } else{
    sphere.display(); //video sphere
    
  }*/
  communication.sendScene(scene);
}

void keyPressed(){
  if(key == 'f') scene.floor.manageCalibration();
  if(key == 's') scene.drawScene = !scene.drawScene;
  if(key == 'm') scene.drawMeasured = !scene.drawMeasured;
  if(key == 'b') scene.drawBoneRelativeOrientation = !scene.drawBoneRelativeOrientation;
  if(key == 'j') scene.drawJointOrientation = !scene.drawJointOrientation;
  if(key == 'h') scene.drawHandRadius = !scene.drawHandRadius;
  if(key == 'H') scene.drawHandStates = !scene.drawHandStates;
}

void mouseDragged() {
  if(scene.drawScene){
    if(mouseButton == CENTER){
      scene.cameraRotX = scene.cameraRotX - (mouseY - pmouseY)*PI/height;
      scene.cameraRotY = scene.cameraRotY - (mouseX - pmouseX)*PI/width;
    }
    if(mouseButton == LEFT){
      scene.cameraTransX = scene.cameraTransX + (mouseX - pmouseX);
      scene.cameraTransY = scene.cameraTransY + (mouseY - pmouseY);
    }  
  } 
  else{
    if(mouseButton == LEFT){
      sphere.cameraRotX = (sphere.cameraRotX - sphere.transZSensibility*(mouseY - pmouseY)*PI/height)%TWO_PI;
      sphere.cameraRotY = (sphere.cameraRotY + sphere.transZSensibility*(mouseX - pmouseX)*PI/width)%TWO_PI;
    }
    
  }
}

void mouseWheel(MouseEvent event) {
  
  float zoom = event.getCount();
  
  if(scene.drawScene){
    if(zoom < 0){
      scene.cameraTransZ = scene.cameraTransZ + 30;
    }else{
      scene.cameraTransZ = scene.cameraTransZ - 30;
    }
  }
  else {
    if(event.getCount() < 0){
      sphere.cameraTransZ = sphere.cameraTransZ + 10;
    }else{
      sphere.cameraTransZ = sphere.cameraTransZ - 10;
    }
  }
  if (sphere.cameraTransZ > 200){
    sphere.transZSensibility = 0;
  }
  else if(sphere.cameraTransZ < 0) {
   
   sphere.transZSensibility = 1 ; 
  }
  else {
    sphere.transZSensibility = map(sphere.cameraTransZ, 200, 0, 0, 1) ;
  }
    
}
