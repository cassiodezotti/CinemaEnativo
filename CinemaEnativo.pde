import processing.video.*;
boolean drawSkeletonTool = true;
Scene scene = new Scene();
Sphere sphere;


int pdPort = 12000;
int myPort = 3001;
Communication communication = new Communication("192.168.15.16", pdPort, myPort);

void setup()
{
  size(600, 600, P3D);
  sphere = new Sphere(this, 0.5);
  frameRate(scene.frameRate_);
  scene.init();
}

void draw()
{
  scene.update();
  for(Skeleton skeleton:scene.activeSkeletons.values()){ //example of consulting feature
    //sphere.cameraRotX = sphere.cameraRotX + skeleton.features.steeringWheel.pitchStep;
    sphere.cameraRotX = sphere.cameraRotX + map(skeleton.features.steeringWheel.position.y, -0.4, 0.4, PI/64, -PI/64);
    sphere.cameraRotY = sphere.cameraRotY + skeleton.features.steeringWheel.yawStep;
    sphere.cameraTransZ = map(skeleton.features.steeringWheel.positionPercentageOfRoom.z, -1, 1, 200, -200);
  }
  
  
  if(scene.drawScene){
    scene.draw(); // measuredSkeletons, jointOrientation, boneRelativeOrientation, handRadius, handStates
  } else{
    sphere.display(); //video sphere
    
  }
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
      sphere.cameraRotX = (sphere.cameraRotX - (mouseY - pmouseY)*PI/height)%TWO_PI;
      sphere.cameraRotY = (sphere.cameraRotY + (mouseX - pmouseX)*PI/width)%TWO_PI;
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
}
