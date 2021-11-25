//-----------------For SIA Robotic Art Class ------------------
//-----------------2021/11/19 by Sanhead     ------------------
import processing.video.Movie;
//import com.jogamp.newt.event.*;
import processing.sound.*;
import java.awt.MouseInfo;
import java.awt.Point;

public SoundFile firstAmbient,pipe,gettingWorse,ending;
public Movie recallMovie;
public Movie endingMovie;

Point absmouse;
float xorigin, yorigin;
boolean mouseLeftFlag;

PFont font;

int mode = 1;
final static int DEBUG = 0;
final static int RUN = 1;

PImage icon;

void settings(){
  fullScreen(P2D);
}

void setup() {
  surface.setResizable(true);
  recallMovie = new Movie(this, "recall.mp4");
  endingMovie = new Movie(this, "ending.mp4");
  icon = new PImage();
  for(int i = PFont.list().length-1; i > 0; i--){
    String temps = PFont.list()[i];
    if(temps.equals("굴림") || temps.equals("맑은 고딕")|| 
    temps.equals("돋움")|| temps.equals("함초롬바탕") ||
    temps.equals("바탕") || temps.equals("궁서") || temps.equals("AppleGothic") || temps.equals("AppleMyungjo")){
      font = createFont(PFont.list()[i],48);
      break;
    }
  }
  textFont(font);

  //.position()
  //.stop()
  //.jump()
  //.pause()
  //.amp()

  assignDefaultSettings();
}

//-------------------------------------------Main Loop------------------
boolean init = true;
void draw() {
  absmouse = MouseInfo.getPointerInfo().getLocation();
  
  if(init){
    icon = loadImage("jamQ.png");   
    
    firstAmbient = new SoundFile(this, "firstAmbient.wav");
    pipe = new SoundFile(this, "pipe.wav");
    gettingWorse = new SoundFile(this, "gettingWorse.wav");
    ending = new SoundFile(this, "ending.mp3");
    
    endingMovie.jump(1);
    endingMovie.pause();
    recallMovie.jump(1);
    recallMovie.pause();
    textSize(18);
    init = false;
  }
  
  assignDefaultSettings();
  recordAllMovieTime();
  judgeAllMovieIsPlaying();

  clear();
  debug(false);
  
  switch(mode) {
    case(DEBUG):
      fill(255);
      stroke(255);
      textSize(23);
      text("DEBUG MODE : TRUE", width/2, height/2);
    case(RUN):
      playMovie();      
      playSound();
    break;
  }

  resetKeyState();
  adjustScreen();
  prevEndingMovieTime = curEndingMovieTime;
  prevRecallMovieTime = curRecallMovieTime;

  if (isKeyF12Pressed) {
    fill(30, 30, 0, 100);
    rect(0, 0, width, height);
    fill(255);
    text("ESC - 프로그램 끄기야"+
      "\nF키  -  풀스크린 토글이야ㅎ 화면을 드래그해서 움직일 수 있어"+
      "\n\nF12 유지  -  지금 보고있는 도움말.. 보면서 다른 기능을 테스트 해봐,,,"+
      "\n\nF키        -  창모드 ↔ 풀스크린 전환이야(창모드에서는 창을 드래그해서 움직여)"+
      "\n\n숫자 1키  -  (1번영상) 회상 영상 재생이야"+
      "\n숫자 2키  -  (2번영상) 엔딩 영상 재생,,, 와ㅏㅎㅎ 끝.."+
      "\n숫자 4키  -  모든 영상 리셋.."+
      "\n클릭  -  커서 제거"+
      "\nR키  -  정지 토글 리셋"+
      "\nZ/X/C/B키  -  효과음 및 음악(순서는 스토리보드를 따름) / 다시 누르면 서서히 꺼짐(조건부)", 40, 70);
    fill(0, 0);
    helpflag = false;
  }
  if(helpflag){
    image(icon,width/2-this.width/16,height/2-this.height/8,this.width/7,this.height/4);
    fill(255);
    stroke(255);
    text("F12 : 도움말 보기", width/2-70, height/2+150+icon.height/12);
  }
  noStroke();
  fill(255,0,0,150);
  if (isRightMouseReleased) {
    if (abs(mouseX-pmouseX) > 0 || abs(mouseY-pmouseY) > 0) {
      cursor();
      cursorCnt = 0;
    } else {
      if(cursorCnt > 20){
        noCursor();
      } else {
        cursorCnt++;
      }
    }
  } else {
    noCursor();
  }
  fill(255);
}

int cursorCnt = 0;
boolean helpflag = true;
boolean xFlag = true;
boolean zFlag = true;
boolean cFlag = true;
boolean vFlag = true;
boolean bFlag = true;

//-------------------------------------------soundManager------------------
void selectPlayableMusic(SoundFile s){
  if(s.isPlaying()){ s.jump(0); s.pause();}
  else{ s.play();}
}

void playSound(){
  if(isZkeyReleased && zFlag){//firstAmbient
    selectPlayableMusic(firstAmbient);
    zFlag = false;
  }
  if(isXkeyReleased && xFlag){//pipe
    selectPlayableMusic(pipe);
    xFlag = false;
  }
  if(isCkeyReleased && cFlag){//gettingWorse
    selectPlayableMusic(gettingWorse);
    cFlag = false;
  }
  if(isBkeyReleased && bFlag){//ending
    selectPlayableMusic(ending);
    bFlag = false;
  }
}

//-------------------------------------------movieManager------------------
float globalMovieVolume = 1;
boolean fadeNutral = true;
boolean fadeIO = false;
boolean isTimeToRemoveBG = false;
float dSoundFade = 0.03;
float dScreenFade = 0.08;

void playMovie() {
  if (isNumOneKeyReleased) {
    endingMovie.jump(0);
    endingMovie.pause();
    recallMovie.jump(0);
    recallMovie.play();
  } else if (isNumTwoKeyReleased) {
    recallMovie.jump(0);
    recallMovie.pause();
    endingMovie.jump(0);
    endingMovie.play();
  } else if (isNumFourKeyReleased) {
    recallMovie.jump(0);
    recallMovie.pause();
    endingMovie.jump(0);
    endingMovie.pause();
  }

  if (endingMovie.time() > endingMovie.duration() - 0.07) {
    endingMovie.jump(0);
    endingMovie.pause();
    image(endingMovie, 0, 0, width, height);
  }
  if (recallMovie.time() > recallMovie.duration() - 0.07) {
    recallMovie.jump(0);
    recallMovie.pause();
    image(recallMovie, 0, 0, width, height);
  }
  
  if(isEndingMoviePlaying){
    image(endingMovie, 0, 0, width, height);
  }else if(isRecallMoviePlaying){
    image(recallMovie, 0, 0, width, height);
  }
}

boolean isEndingMoviePlaying = false;
boolean isRecallMoviePlaying = false;

void judgeAllMovieIsPlaying() {
  if (prevEndingMovieTime == curEndingMovieTime || endingMovie.time() < 0) {
    isEndingMoviePlaying = false;
  } else {
    isEndingMoviePlaying = true;
  }
  if (prevRecallMovieTime == curRecallMovieTime || recallMovie.time() < 0) {
    isRecallMoviePlaying = false;
  } else {
    isRecallMoviePlaying = true;
  }
}

float curRecallMovieTime, prevRecallMovieTime;
float curEndingMovieTime, prevEndingMovieTime;
void recordAllMovieTime() {
  curRecallMovieTime = recallMovie.time();
  curEndingMovieTime = endingMovie.time();
}

void movieEvent(Movie m) {
  m.read();
}


//-------------------------------------------KeyEvents------------------------------
boolean isKeyF12Pressed = false; // for tutorial
boolean isNumZeroKeyReleased = false;
boolean isNumOneKeyReleased = false;
boolean isNumTwoKeyReleased = false;
boolean isNumThreeKeyReleased = false;
boolean isNumFourKeyReleased = false;
boolean toggleFullscreen = false;
boolean isRightMouseReleased = true;
boolean isZkeyReleased = false;
boolean isXkeyReleased = false;
boolean isCkeyReleased = false;
boolean isVkeyReleased = false;
boolean isBkeyReleased = false;
boolean isEnterKeyReleased = false;
boolean isRightKeyPressed = false;
boolean isLeftKeyPressed = false;
boolean Xtoggle = false;
boolean Ztoggle = false;
boolean Ctoggle = false;
boolean Vtoggle = false;
boolean Btoggle = false;

String lastMovieRequested = "None";


void keyReleased() {
  helpflag = false;

  //play recall movie
  if (key == '1') {
    isNumOneKeyReleased = true;
    lastMovieRequested = "recall";
  }

  if (key == '2') {
    isNumTwoKeyReleased = true;
    lastMovieRequested = "ending";
  }

  if (key == '4') {
    isNumFourKeyReleased = true;
    lastMovieRequested = "bgblack";
  }

  if (key == 'f' || key == 'F') {
    toggleFullscreen = !toggleFullscreen;
    adjustScreenFlag = true;
  }
  
  if(key == 'z' || key == 'Z'){ // firstAmbient
    isZkeyReleased = true;
    Ztoggle = !Ztoggle;
  }
  
  if(key == 'x' || key == 'X'){ // pipe
    isXkeyReleased = true;
    Xtoggle = !Xtoggle;
  }
  
  if(key == 'c' || key == 'C'){ // gettingWorse
    isCkeyReleased = true;
    Ctoggle = !Ctoggle;
  }
  
  if(key == 'b' || key == 'B'){ // ending
    isBkeyReleased = true;
    Btoggle = !Btoggle;
  }
  
  
  if(keyCode == 10/*Enter*/){
    isEnterKeyReleased = true;
  }

  if (keyCode == 108/*F12*/) {
    isKeyF12Pressed = false;
  }
}

void resetKeyState() {
  isNumZeroKeyReleased = false;
  isNumOneKeyReleased = false;
  isNumTwoKeyReleased = false;
  isNumFourKeyReleased = false;
  isLeftKeyPressed = false;
  isRightKeyPressed = false;
  isZkeyReleased = false;
  isXkeyReleased = false;
  isCkeyReleased = false;
  isVkeyReleased = false;
  isBkeyReleased = false;
  isEnterKeyReleased = false;
}

public void mouseReleased() {
  tcnt++;
  isRightMouseReleased = !isRightMouseReleased;
  if (mouseButton == LEFT) {
    mouseLeftFlag = true;
  }
}

public void keyPressed() {
  if (keyCode == 108 /*F12*/) {
    isKeyF12Pressed = true;
  }

  if (key == LEFT) {
    isLeftKeyPressed = true;
  }
  if (key == RIGHT) {
    isRightKeyPressed = true;
  }
  
  if (key == 'R' || key == 'r'){
    zFlag = true;
    xFlag = true;
    cFlag = true;
    vFlag = true;
    bFlag = true;
  }
}


//-------------------------------------------DefaultSettings________________________
void assignDefaultSettings() {
  clear();
  background(0);
}

void debug(boolean j){
  if(j){
    println("recall : "+isRecallMoviePlaying);
    println("ending : "+isEndingMoviePlaying);
    println("lastMovieRequested : "+lastMovieRequested);
    println("one : "+isNumOneKeyReleased);
    println("MovieVolume : "+globalMovieVolume);
    println("fadeNutral : "+fadeNutral);
    println("_________________________");
    println("recallMovie's");
    println(recallMovie.duration());
    println(recallMovie.time());
    println("endingMovie's");
    println(endingMovie.duration());
    println(endingMovie.time());
    println("____________________");
  }
}

int locX = 0, locY = 0;
boolean adjustScreenFlag = true;
void adjustScreen() {
  if (!toggleFullscreen) {
    if (adjustScreenFlag) {
      surface.setSize(int(1920*.5), int(1080*.5));
      surface.setLocation(displayWidth/2-int(1920*.5)/2, displayHeight/2-int(1080*.5)/2);
      adjustScreenFlag = false;
      textSize(18);
    }
    if (isMouseDragging) {
      surface.setLocation(locX+=(mouseX-pmouseX)/1.5, locY+=(mouseY-pmouseY)/1.5);
      isMouseDragging = false;
    }
  } else {
    if (adjustScreenFlag) {
      surface.setSize(displayWidth, displayHeight);
      surface.setLocation(0, 0);
      adjustScreenFlag = false;
      textSize(40);
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT && mouseLeftFlag) {
    xorigin = mouseX;
    yorigin = mouseY;
    mouseLeftFlag = false;
  }
}

boolean isMouseDragging = false;
void mouseDragged() {
  if(mouseButton == LEFT && !toggleFullscreen){
    if(tcnt>0){
      surface.setLocation(int(absmouse.x-xorigin), int(absmouse.y-yorigin));
    }
  }
}

int tcnt = 0;
