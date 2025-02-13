import processing.video.*;
boolean drawSkeletonTool = true;
String userTextInput = "";
boolean gettingUserTextInput = false;
Scene scene = new Scene();
Sphere sphere;

int pdPort = 12000;
int myPort = 3001;
Communication communication = new Communication("127.0.0.1", pdPort, myPort);

void setup() {
  size(500, 500, P3D);
  //fullScreen(P3D);
  sphere = new Sphere(this, 0.8);
  frameRate(scene.frameRate_);
  scene.init();
}

void draw() {
  scene.update();
  
  if(scene.drawScene){
    scene.draw(); // measuredSkeletons, jointOrientation, boneRelativeOrientation, handRadius, handStates
  } else{
    // Your animation algorithm should be placed here
    sphere.display(); //video sphere
  }
  for(Skeleton skeleton:scene.activeSkeletons.values()){ 
    sphere.cameraRotX = sphere.cameraRotX + (map(skeleton.steeringWheel.position.y, 1, 1.5, PI/64, -PI/64))*pow(sphere.transZSensibility,2);
    sphere.cameraRotY = sphere.cameraRotY + (skeleton.steeringWheel.yawStep)*pow(sphere.transZSensibility,2);
    //println("percent of room",skeleton.steeringWheel.positionPercentageOfRoom.z);
    if(skeleton.steeringWheel.positionPercentageOfRoom.z < -0.6) sphere.cameraTransZ = -sphere.radius/5;
    else sphere.cameraTransZ = map(skeleton.steeringWheel.positionPercentageOfRoom.z, -1, 1, -sphere.radius/2, -1.5*sphere.radius);//ver porcentagem da sala, diminuir proximidade
    //sphere.cameraTransZ = pow(sphere.cameraTransZ,2);
    //cameraTransZ é negativo entao quanto aproxima tem q ficar menos negativo
    //println("camera z:", sphere.cameraTransZ);
    if (sphere.cameraTransZ > -(sphere.radius/2+0.1*sphere.radius)){
      sphere.transZSensibility = 0;
    }
    else if(sphere.cameraTransZ < -(sphere.radius+sphere.radius*0.4)) {
      sphere.transZSensibility = 1 ; 
    }
    else {
      //sphere.transZSensibility = map(sphere.cameraTransZ,-1*(sphere.radius/2),-sphere.radius*1.5,0,1);//ver qual é melhor
      sphere.transZSensibility = map(skeleton.steeringWheel.positionPercentageOfRoom.z,-1,1,0,1);
    }
    
    communication.sendGrainParameters(skeleton,sphere);
    
  }
  communication.sendScene(scene);
}

void keyPressed(){
  if(gettingUserTextInput){
    if (keyCode == BACKSPACE) {
      if (userTextInput.length() > 0) {
        userTextInput = userTextInput.substring(0, userTextInput.length()-1);
        println(userTextInput);
      }
    } else if (keyCode == DELETE) {
      userTextInput = "";
    } else if (keyCode == RETURN || keyCode == ENTER){
      gettingUserTextInput = false;
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      userTextInput = userTextInput + key;
      println(userTextInput);
    }
  } else{
    if(key == 'f') scene.floor.manageCalibration();
    if(key == 's') scene.drawScene = !scene.drawScene;
    if(key == 'm') scene.drawMeasured = !scene.drawMeasured;
    if(key == 'b') scene.drawBoneRelativeOrientation = !scene.drawBoneRelativeOrientation;
    if(key == 'j') scene.drawJointOrientation = !scene.drawJointOrientation;
    if(key == 'h') scene.drawHandRadius = !scene.drawHandRadius;
    if(key == 'H') scene.drawHandStates = !scene.drawHandStates;
    //if(key == 'p') scene.drawPollock = !scene.drawPollock;
    //if(key == 'r') scene.drawRondDuBras = !scene.drawRondDuBras;
    //if(key == 'c') scene.drawCenterOfMass = !scene.drawCenterOfMass;
    //if(key == 'M') scene.drawMomentum = !scene.drawMomentum;
  }
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
