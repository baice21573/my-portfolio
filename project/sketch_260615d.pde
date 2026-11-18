import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import processing.sound.*;
import java.util.Collections;
// ================================================================
// 《疯狂仙境》主程序
// ================================================================
import ddf.minim.*;

int gameState;  // 0: 封面页, 1: 章节选择页, 2: 第一章小游戏
int currentChapter = 0;  // 0=无, 1=第一章, 2=第二章
PImage coverImage;
PImage chapterBg;   //章节选择背景图
String cakeOptionResult = "";
boolean cakeResultShowing = false;
Minim minim;
AudioPlayer bgm;
AudioPlayer bgmChapter1;
AudioPlayer bgmChapter2;
AudioPlayer bgmChapter3;
AudioPlayer bgmChapter4;
AudioPlayer bgmBattle;
import ddf.minim.*;
SoundFile clickSound;
// ============================================================
// 第三章：过渡段 + 茶话会场景
// ============================================================

// 背景
PImage transitionBg;
PImage teaPartyBg;

// 过渡段交互
PImage mushroomInteract;
PImage catShadow;

// 茶话会交互
PImage teapotInteract;
PImage cakeInteract;
PImage cakeInteractImg;
PImage hatterQ;

// 爱丽丝Q版站立
PImage aliceStand;

// 疯帽子立绘（
PImage hatterSmile;
PImage hatterLaugh;
PImage hatterSilent;

// 过渡段变量
float aliceWalkX = -100;
float aliceWalkY = 0;
boolean isWalking = true;
boolean mushroomTriggered = false;
boolean catShadowTriggered = false;
boolean transitionGuideShown = false;
boolean transitionComplete = false;

// 茶话会交互状态
boolean teapotClicked = false;
boolean cakeClicked = false;
boolean hatterQClicked = false;

// 糕点互动状态
boolean cakeDialogActive = false;
int cakeDialogStep = 0;

// 茶话会阶段
boolean teaPartyActive = false;

// ============================================================
// 抽鬼牌游戏变量
// ============================================================
PImage cardBack;
PImage cardHeart;
PImage cardSpade;
PImage cardClub;
PImage cardDiamond;
PImage cardJoker;

ArrayList<Card> deck;
ArrayList<Card> playerHand;
ArrayList<Card> hatterHand;
boolean isPlayerTurn = true;
boolean gameOver = false;
boolean playerWin = false;
boolean isHatterThinking = false;
int hatterThinkTimer = 0;
String gameMessage = "";
int messageTimer = 0;
boolean waitingForClick = false;
boolean showRule = false;
String pairMessage = "";
int pairMessageTimer = 0;
boolean showHatterMenu = false;   // 显示疯帽子菜单
boolean isFarewellDialog = false;   // 是否是告别对话
// 红皇后相关
PImage queenBg;
PImage queenNormal;
PImage queenGrin;
// ============================================================
// 红皇后战斗变量
// ============================================================
int queenHits = 0;              // 成功命中次数
int queenMisses = 0;            // 失败次数
int maxQueenHits = 10;           // 需要命中3次胜利
int maxQueenMisses = 8;         // 允许失败3次
int arrowDirection = -1;        // 当前箭头方向 0=上,1=下,2=左,3=右
int arrowTimer = 0;             // 箭头显示计时
int arrowDuration = 9000;       // 箭头显示时长（毫秒）
color flashColor;
int flashTimer = 0;
boolean arrowActive = false;    // 是否有箭头正在显示
boolean queenBattleActive = false; // 战斗是否进行中
boolean queenBattleWin = false;
boolean queenBattleLose = false;
boolean queenBattleResult = false;
int queenBattleStep = 0;
PImage queenBattleBg;   // 红皇后战斗背景（单独绘制）

// ★★★ 面具碎裂状态 ★★★
PImage queenFace;   // 红皇后露脸立绘（面具碎裂后显示）
boolean maskBroken = false;     // 面具是否已碎裂
boolean maskBreakTriggered = false; // 是否已触发碎裂动画
int maskBreakTimer = 0;
boolean maskDialogClicked = false;   // 面具对话是否已点击
// ============================================================
// 迷宫游戏变量
// ============================================================
int mazeSize = 15;              // 15x15迷宫
int[][] maze;
int playerCol, playerRow;
int exitCol, exitRow;
int playerMazeX, playerMazeY;
int cellSize;
int mazeLives = 7;
boolean mazeActive = false;
boolean mazeWin = false;
boolean mazeLose = false;
boolean mazeResult = false;
int mazeStep = 0;

// 纸牌士兵
ArrayList<int[]> soldiers;
int soldierMoveTimer = 0;
int soldierMoveInterval = 60;   // 每60帧移动一次
// 牌类定义（必须放在所有函数之前）
class Card {
  String suit;   // "heart", "spade", "club", "diamond", "joker"
  int id;
  boolean isJoker;
  
  Card(String suit, int id) {
    this.suit = suit;
    this.id = id;
    this.isJoker = suit.equals("joker");
  }
  
  PImage getImage() {
    if (isJoker) return cardJoker;
    if (suit.equals("heart")) return cardHeart;
    if (suit.equals("spade")) return cardSpade;
    if (suit.equals("club")) return cardClub;
    if (suit.equals("diamond")) return cardDiamond;
    return null;
  }
}
// ========== 封面按钮热区） ==========
int startX = 848, startY = 624, startW = 250, startH = 62;
int quitX  = 838, quitY  = 759, quitW = 253, quitH = 46;

// ========== 章节选择热区） ==========
int ch1X, ch1Y, ch1W, ch1H;   // 第一章：坠入扭曲洞
int ch2X, ch2Y, ch2W, ch2H;   // 第二章：狞笑迷踪
int ch3X, ch3Y, ch3W, ch3H;   // 第三章：疯癫茶宴
int ch4X, ch4Y, ch4W, ch4H;   // 第四章：红心绞杀
int backX, backY, backW, backH; // 返回按钮

// ========== 中文字体（全局变量） ==========
PFont chineseFont;

void setup() {
  fullScreen();
  surface.setTitle("Madness in Wonderland");
 
  
  // ===== 加载封面和章节背景 =====
  coverImage = loadImage("cover.jpg");
  if (coverImage == null) {
    println("错误：未找到 cover.jpg，请检查 data 文件夹");
    exit();
  }
  
  chapterBg = loadImage("chapterBg.jpg");
  if (chapterBg == null) {
    println("警告：未找到 chapterBg.jpg，将使用纯色背景");
  }
  // ===== 加载音乐 =====
  minim = new Minim(this);
  bgm = minim.loadFile("bgm_cover.mp3");
  bgmChapter1 = minim.loadFile("bgm_chapter1.mp3");
bgmChapter2 = minim.loadFile("bgm_chapter2.mp3");
bgmChapter3 = minim.loadFile("bgm_chapter3.mp3");
bgmChapter4 = minim.loadFile("bgm_chapter4.mp3");
bgmBattle = minim.loadFile("bgm_battle.mp3");

// 设置音量
bgm.setVolume(0.4);
bgmChapter1.setVolume(0.3);
bgmChapter2.setVolume(0.2);
bgmChapter3.setVolume(0.2);
bgmChapter4.setVolume(0.2);
bgmBattle.setVolume(0.3);
  bgm.loop();  // 循环播放
    // 音量 0~1
  clickSound = new SoundFile(this, "click.wav");
 
  
  // ===== 章节按钮热区 =====
  ch1X = 118;   ch1Y = 328;   ch1W = 247;   ch1H = 196;
  ch2X = 397;   ch2Y = 563;   ch2W = 264;   ch2H = 168;
  ch3X = 676;   ch3Y = 235;   ch3W = 252;   ch3H = 279;
  ch4X = 1081;  ch4Y = 304;   ch4W = 272;   ch4H = 290;
  backX = 20;   backY = 838;  backW = 180;  backH = 73;
  
  // ===== 加载对话立绘 =====
  alicePortrait_normal = loadImage("alice_normal.png");
  alicePortrait_smile = loadImage("alice_smile.png");
  alicePortrait_knife = loadImage("alice_knife.png");
  alicePortrait_cold = loadImage("alice_cold.png"); 
  rabbitPortrait_panic = loadImage("rabbit_panic.png");
  rabbitPortrait_taunt = loadImage("rabbit_taunt.png");
  rabbitPortrait_defeated = loadImage("rabbit_defeated.png");
  hatterSmile = loadImage("hatter_smile.png");
hatterLaugh = loadImage("hatter_laugh.png");
hatterSilent = loadImage("hatter_silent.png");
queenBg = loadImage("queen_bg.jpg");
queenNormal = loadImage("queen_normal.png");
queenGrin = loadImage("queen_grin.png");
queenFace = loadImage("queen_face.png");  // 红皇后露脸立绘
queenBattleBg = loadImage("queen_battle_bg.jpg");
if (queenBattleBg == null) println("警告: queen_battle_bg.jpg 未找到");

if (queenBg == null) println("警告: queen_bg.jpg 未找到");
// ===== 加载扑克牌素材 =====
cardBack = loadImage("card_back.png");
cardHeart = loadImage("card_heart.png");
cardSpade = loadImage("card_spade.png");
cardClub = loadImage("card_club.png");
cardDiamond = loadImage("card_diamond.png");
cardJoker = loadImage("card_joker.png");

if (cardBack == null) println("警告: card_back.png 未找到");
  dialogBg = loadImage("dialog_bg.png");
  forestBg = loadImage("forestBg.jpg");
  if (forestBg == null) println("警告: forestBg.jpg 未找到，将使用纯色背景");
  
  // ===== 加载中文字体（从 data 文件夹加载） =====
  chineseFont = createFont("NotoSansSC-Regular.ttf", 24);
  if (chineseFont == null) {
    // 如果字体文件未找到，尝试使用系统字体
    println("警告：未找到 NotoSansSC-Regular.ttf，尝试使用系统字体");
    chineseFont = createFont("PingFang SC", 24);
  }
  if (chineseFont == null) {
    println("警告：系统字体加载失败，将使用默认字体（中文可能显示为方框）");
  }
  textFont(chineseFont);
  
  // 立绘加载检查（可选）
  if (alicePortrait_normal == null) println("警告: alice_normal.png 未找到");
  if (rabbitPortrait_panic == null) println("警告: rabbit_panic.png 未找到");
  
  // ===== 加载柴郡猫立绘 =====
cheshirePortrait_normal = loadImage("cheshire_portrait_normal.png");
cheshirePortrait_grin = loadImage("cheshire_portrait_grin.png");
cheshirePortrait_floating = loadImage("cheshire_portrait_floating.png");
cheshirePortrait_shy = loadImage("cheshire_portrait_shy.png");
cheshireBg = loadImage("cheshire_bg.jpg");
  gameState = 0;
  loadGameAssets();
  
  // ===== 加载第二章小游戏素材 =====
loadCatAssets();
// ===== 加载第三章素材 =====
transitionBg = loadImage("transition_bg.jpg");
teaPartyBg = loadImage("tea_party_bg.jpg");
mushroomInteract = loadImage("mushroom_interact.png");
catShadow = loadImage("cat_shadow.png");
teapotInteract = loadImage("teapot_interact.png");
cakeInteract = loadImage("cake_interact.png");
cakeInteractImg = loadImage("cake_interact_img.png");
hatterQ = loadImage("hatter_q.png");
aliceStand = loadImage("alice_stand.png");

hatterSmile = loadImage("hatter_smile.png");
hatterLaugh = loadImage("hatter_laugh.png");
hatterSilent = loadImage("hatter_silent.png");

println("=== 第三章素材加载完成 ===");
println("transitionBg: " + (transitionBg != null ? "✅" : "❌"));
println("teaPartyBg: " + (teaPartyBg != null ? "✅" : "❌"));

}

void draw() {
  if (gameState == 0) {
    drawCover();
  } else if (gameState == 1) {
    drawChapterSelect();
  } else if (gameState == 2) {
    drawGameChapter1();
  } else if (gameState == 3) {
    drawGameChapter2();
    updateCatGame();
  } else if (gameState == 5) {
    drawTransitionScene();
  } else if (gameState == 6) {
    drawTeaPartyScene();
  } else if (gameState == 7) {
    drawCardGame();
    if (!isPlayerTurn && !gameOver) {
      hatterTurn();
    }
  } else if (gameState == 8) {
    drawChapter3End();
  } else if (gameState == 9) {
    drawQueenBattle();
    updateQueenBattle();
  } else if (gameState == 10) {
    drawDialog();
  } else if (gameState == 11) {
    drawEnding();   // ★★★ 确保有这个 ★★★
  } else if (gameState == 12) {
    drawMazeGame();
    updateMazeGame();
    if (mazeResult) {
      drawMazeResult();
    }
  }
}
// ===================== 封面页 =====================
void drawCover() {
  background(0);
  if (coverImage != null) {
    image(coverImage, 0, 0, width, height);
  } else {
    background(10, 5, 20);
    fill(255);
    text("封面图未找到", width/2, height/2);
  }
}

// ===================== 章节选择页 =====================
void drawChapterSelect() {
  background(0);
  
  if (chapterBg != null) {
    image(chapterBg, 0, 0, width, height);
  } else {
    background(40, 20, 30);
    fill(255);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("章节背景图未加载", width/2, height/2);
  }
}

// ===================== 第一章小游戏 =====================
void drawGameChapter1Placeholder() {
  background(0);
  fill(255);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("第一章：坠入扭曲洞", width/2, height/2 - 40);
  textSize(24);
  text("（小游戏代码待添加）", width/2, height/2 + 40);
  textSize(18);
  text("点击任意位置返回章节选择", width/2, height/2 + 100);
}

// ===================== 鼠标交互 =====================
void mousePressed() {
  if (gameState == 0) {
    // 封面页点击检测
    if (mouseX > startX && mouseX < startX + startW && mouseY > startY && mouseY < startY + startH) {
      println("Start 被点击，切换到章节选择");
      clickSound.play();  
      gameState = 1;
    } else if (mouseX > quitX && mouseX < quitX + quitW && mouseY > quitY && mouseY < quitY + quitH) {
      println("Quit 被点击，退出游戏");
      exit();
    }
  } 
  else if (gameState == 1) {
    // 章节选择页点击检测（热区）
    if (mouseX > ch1X && mouseX < ch1X + ch1W && mouseY > ch1Y && mouseY < ch1Y + ch1H) {
      println("进入第一章：坠入扭曲洞");
      clickSound.play();  
      startChapter1Dialog();
      return;
    }
    if (mouseX > ch2X && mouseX < ch2X + ch2W && mouseY > ch2Y && mouseY < ch2Y + ch2H) {
      println("进入第二章：狞笑迷踪");
      clickSound.play();  
      startChapter2Dialog();
      return;
    }
    if (mouseX > ch3X && mouseX < ch3X + ch3W && mouseY > ch3Y && mouseY < ch3Y + ch3H) {
      println("进入第三章：疯癫茶宴");
      clickSound.play();
      startTransitionScene();
      return;
    }
    if (mouseX > ch4X && mouseX < ch4X + ch4W && mouseY > ch4Y && mouseY < ch4Y + ch4H) {
      println("进入第四章：红心绞杀");
      clickSound.play();
      startChapter4Dialog();
      return;
    }
    if (mouseX > backX && mouseX < backX + backW && mouseY > backY && mouseY < backY + backH) {
      println("返回封面页");
      clickSound.play();  
      gameState = 0;
      return;
    }
  }
  else if (gameState == 2) {
    if (gameActive && !showResult) {
      handleCalibrationClick();
    }
    if (showResult) {
      resultDialogStep++;
    }
  }
  else if (gameState == 3) {
    if (showFeedback && isSpecialNode(feedbackIndex)) {
      showFeedback = false;
      if (catClicks >= maxCatClicks) {
        catGameActive = false;
        catGameWin = true;
        catShowResult = true;
        catResultStep = 0;
      } else if (catGameActive && catClicks < maxCatClicks) {
        spawnCatTarget();
        targetVisible = true;
        targetAppearTime = millis();
      }
      return;
    }
    if (catShowResult) {
      catResultStep++;
    } else {
      handleCatClick();
    }
  }
  else if (gameState == 5) {
    float mushroomX = width * 0.45;
    float mushroomY = height * 0.8;
    float catX = width * 0.7;
    float catY = height * 0.4;
    
    if (!mushroomTriggered && dist(mouseX, mouseY, mushroomX, mushroomY) < 100) {
      mushroomTriggered = true;
      println("蘑菇已触发");
      return;
    }
    if (!catShadowTriggered && dist(mouseX, mouseY, catX, catY) < 120) {
      catShadowTriggered = true;
      println("猫影已触发");
      return;
    }
    if (transitionGuideShown && !transitionComplete) {
      transitionComplete = true;
      gameState = 6;
      println("进入茶话会");
      return;
    }
  }
  else if (gameState == 6) {
    float groundY = height * 0.53;
    float teapotX = width * 0.25;
    float cakeX = width * 0.52;
    float hatterX = width * 0.78;
    
    if (cakeResultShowing) {
      cakeResultShowing = false;
      cakeDialogActive = false;
      cakeDialogStep = 0;
      return;
    }
    if (showHatterMenu) {
      float btnW = 150, btnH = 50;
      float btnY = height/2 - 10;
      float btn1X = width/2 - btnW - 20;
      float btn2X = width/2 + 20;
      
      if (mouseX > btn1X && mouseX < btn1X + btnW && mouseY > btnY && mouseY < btnY + btnH) {
        showHatterMenu = false;
        startCardGame();
        return;
      }
      if (mouseX > btn2X && mouseX < btn2X + btnW && mouseY > btnY && mouseY < btnY + btnH) {
        showHatterMenu = false;
        startChapter3EndDialog();
        return;
      }
      return;
    }
    if (cakeDialogActive) {
      if (cakeDialogStep < 3) {
        cakeDialogStep++;
        return;
      } else if (cakeDialogStep == 3) {
        String[] options = {"“吃一口。”", "“不吃。”", "“你尝过吗？”"};
        String[] replies = {
          "（爱丽丝咬了一口）……是盐。",
          "（疯帽子笑着）那你帮我留着吧。说不定有人喜欢咸的。",
          "（疯帽子愣住）我烤东西从来不尝……因为那样就没有惊喜了。"
        };
        float optW = 180, optH = 45, startX = width/2 - 300, startY = height/2 + 100;
        for (int i = 0; i < 3; i++) {
          float x = startX + i * (optW + 20);
          if (mouseX > x && mouseX < x + optW && mouseY > startY && mouseY < startY + optH) {
            cakeOptionResult = replies[i];
            cakeResultShowing = true;
            cakeDialogActive = false;
            cakeDialogStep = 0;
            return;
          }
        }
        return;
      }
    }
    if (dist(mouseX, mouseY, teapotX, groundY) < 150) {
      startChapter3Dialog();
      return;
    }
    if (dist(mouseX, mouseY, cakeX, groundY) < 150) {
      cakeDialogActive = true;
      cakeDialogStep = 0;
      cakeResultShowing = false;
      return;
    }
    if (dist(mouseX, mouseY, hatterX, groundY) < 250) {
      showHatterMenu = true;
      return;
    }
  }
  else if (gameState == 7) {
    if (showRule) {
      showRule = false;
      return;
    }
    if (gameOver) {
      gameState = 6;
      return;
    }
    if (isPlayerTurn) {
      handleCardClick();
    }
  }
  else if (gameState == 8) {
    startChapter4Dialog();
  }
  else if (gameState == 9) {
    if (maskBroken && maskBreakTriggered && !maskDialogClicked) {
      maskDialogClicked = true;
      startChapter4EndDialog();
      return;
    }
    if (queenBattleResult) {
      queenBattleStep++;
      if (queenBattleWin) {
        gameState = 11;
      } else {
        gameState = 1;
      }
    }
  }
  else if (gameState == 10) {
    if (showOptions) {
      int optY = height - 500;
      int optW = 500;
      int optH = 50;
      int optSpacing = 12;
      int startX = width/2 - optW/2;
      
      for (int i = 0; i < 3; i++) {
        if (optionTexts[i] == null || optionTexts[i].equals("")) continue;
        println("选项" + i + ": " + optionTexts[i] + " -> 跳转到索引 " + optionTargets[i]);
        if (mouseX > startX && mouseX < startX + optW &&
            mouseY > optY + i * (optH + optSpacing) && 
            mouseY < optY + i * (optH + optSpacing) + optH) {
          println("★★★ 点击了选项 " + i + " ★★★");
          selectedOption = i;
          showOptions = false;
          dialogIndex = optionTargets[i];
          isTyping = true;
          typingIndex = 0;
          currentDisplayText = "";
          typingTimer = millis();
          println("跳转到索引: " + dialogIndex);
          return;
        }
      }
    } else {
      advanceDialog();
    }
  }
  else if (gameState == 11) {
    gameState = 1;
  }
  else if (gameState == 12) {
  if (mazeResult) {
    mazeStep++;
    if (mazeWin) {
      gameState = 11;   // ★★★ 进入结局画面 ★★★
    } else {
      startMazeGame();
    }
  }
}
}
  

void keyPressed() {
  // ===== 第一章小游戏：空格校准 =====
  if (gameState == 2 && gameActive && !showResult) {
    if (key == ' ') {
      handleCalibrationClick();
    }
  }
  
  // ===== 过渡段：方向键控制爱丽丝行走 =====
  if (gameState == 5) {
    if (key == CODED) {
      if (keyCode == LEFT) {
        aliceWalkX -= 15;
        isWalking = true;
      } else if (keyCode == RIGHT) {
        aliceWalkX += 15;
        isWalking = true;
      }
    }
    if (aliceWalkX < -50) aliceWalkX = -50;
    if (aliceWalkX > width + 50) aliceWalkX = width + 50;
  }
  
  // ===== ★★★ 红皇后战斗：方向键 ★★★ =====
  if (gameState == 9 && queenBattleActive && !queenBattleResult) {
    if (key == CODED) {
      int pressedDir = -1;
      if (keyCode == UP) pressedDir = 0;
      else if (keyCode == DOWN) pressedDir = 1;
      else if (keyCode == LEFT) pressedDir = 2;
      else if (keyCode == RIGHT) pressedDir = 3;
      
      if (pressedDir != -1 && arrowActive && !maskBroken) {
        arrowActive = false;
        
        println("你按的方向: " + pressedDir + " (0上1下2左3右)");
        println("箭头方向: " + arrowDirection + " (0上1下2左3右)");
        
        if (pressedDir == arrowDirection) {
          println("✅ 命中！");
          flashColor = color(255, 255, 255, 200);
          flashTimer = millis();
          queenHits++;
          
          if (queenHits >= 5 && !maskBroken) {
            maskBroken = true;
            maskBreakTriggered = true;
            maskDialogClicked = false;
            maskBreakTimer = millis();
            println("💥 面具碎裂！");
          }
          
          if (queenHits >= maxQueenHits) {
            queenBattleActive = false;
            queenBattleWin = true;
            queenBattleResult = true;
            queenBattleStep = 0;
          } else {
            spawnArrow();
          }
          
        } else {
          println("❌ 失误！");
          flashColor = color(255, 0, 0, 150);
          flashTimer = millis();
          queenMisses++;
          
          if (queenMisses >= maxQueenMisses) {
            queenBattleActive = false;
            queenBattleLose = true;
            queenBattleResult = true;
            queenBattleStep = 0;
          } else {
            spawnArrow();
          }
        }
      }
    }
  }
  
  // ===== ★★★ 迷宫游戏：方向键控制移动 ★★★ =====
  if (gameState == 12 && mazeActive && !mazeResult) {
    if (key == CODED) {
      int newCol = playerCol;
      int newRow = playerRow;
      
      if (keyCode == LEFT) newCol--;
      else if (keyCode == RIGHT) newCol++;
      else if (keyCode == UP) newRow--;
      else if (keyCode == DOWN) newRow++;
      
      if (newCol >= 0 && newCol < mazeSize && newRow >= 0 && newRow < mazeSize) {
        if (maze[newRow][newCol] == 1) {
          playerCol = newCol;
          playerRow = newRow;
          
          // 检查是否到达出口
          if (playerCol == exitCol && playerRow == exitRow) {
            mazeActive = false;
            mazeWin = true;
            mazeResult = true;
            mazeStep = 0;
            println("🎉 逃离成功！");
          }
          
          // 检查是否碰到士兵
          for (int[] pos : soldiers) {
            if (playerCol == pos[0] && playerRow == pos[1]) {
              mazeLives--;
              if (mazeLives <= 0) {
                mazeActive = false;
                mazeLose = true;
                mazeResult = true;
                mazeStep = 0;
                println("💀 被抓住了！");
              } else {
                playerCol = 0;
                playerRow = 0;
              }
            }
          }
        }
      }
    }
  }
}

// ========== 对话系统变量 ==========
String[] dialogLines;
String[] dialogSpeakers;
String[] dialogPortraits;
int dialogIndex = 0;
boolean isDialogActive = false;
boolean isTyping = false;
String currentDisplayText = "";
int typingIndex = 0;
int typingTimer = 0;
int typingSpeed = 10;

// 选项相关
boolean showOptions = false;
String[] optionTexts = new String[3];
int[] optionTargets = new int[3];
int selectedOption = -1;

// 立绘图片
PImage alicePortrait_normal;
PImage alicePortrait_smile;
PImage alicePortrait_knife;
PImage alicePortrait_cold;
PImage rabbitPortrait_panic;
PImage rabbitPortrait_taunt;
PImage rabbitPortrait_defeated;

// 柴郡猫立绘
PImage cheshirePortrait_normal;
PImage cheshirePortrait_grin;
PImage cheshirePortrait_floating;
PImage cheshirePortrait_shy;
PImage cheshireBg;

// 对话框背景
PImage dialogBg;
PImage forestBg;

// ============================================================
// 第二章：猫影迷踪 变量
// ============================================================

// 游戏中猫出现图片
PImage cheshireAppear1;
PImage cheshireAppear2;
PImage cheshireAppear3;

// 特殊互动图
PImage interact1;
PImage interact2;
PImage interact3;

// 游戏状态
int catClicks = 0;
int maxCatClicks = 8;
int catLives = 3;
int maxCatLives = 5;

// 猫目标位置
float targetX, targetY;
float targetSize = 120;
boolean targetVisible = false;
float targetAppearTime = 0;
float targetDuration = 2.0;

// 反馈系统
boolean showFeedback = false;
float feedbackTimer = 0;
float feedbackDuration = 6;
int feedbackIndex = 0;

// 游戏控制
boolean catGameActive = false;
boolean catGameWin = false;
boolean catGameLose = false;
boolean catShowResult = false;
int catResultStep = 0;

// 冷却
boolean canClickCat = true;
int catClickCooldown = 0;

// 背景氛围
float bgGlow = 0;
boolean bgGlowDir = true;

// 对话结束后跳转状态
int dialogNextState = -1;


// ================================================================
// 对话系统核心函数
// ================================================================


// ========== 启动第一章对话 ==========
// ========== 启动第一章对话 ==========
void startChapter1Dialog() {
   switchBGM(bgmChapter1); 
  currentChapter = 1;  
  forestBg = loadImage("forestBg.jpg");
  
  String[] speakers = {
    "rabbit", "alice", "rabbit", "alice", "rabbit", 
    "alice", "rabbit", "alice", "rabbit", "alice",
    "rabbit", "alice",
    "rabbit",
    "rabbit",
    "rabbit"
  };
  
  String[] lines = {
    "晚了晚了！公爵夫人会杀了我的！天哪我的表怎么停了——",
    "喂。",
    "哇啊啊啊——爱丽丝？真的是你？……你已经很久没来这里了。",
    "很久……？算了，告诉我怎么从这里出去就好，我还有很多事情没忙完。",
    "爱丽丝，如果你想要出去，你需要像之前一样去找柴郡猫他们哦。",
    "（低头一瞥）这是什么？让我看看，一枚亮晶晶的怀表？",
    "请、请还给我！那是我——",
    "现在是我的了。除非……你带我去找那个柴郡猫告诉我出去的地方。",
    "爱、爱丽丝，你性格又变差了！",
    "好了，别废话了，你到底带不带我去？为什么你总是表现出一副早就认识我的样子？",
    "你每次都会忘记我们，爱丽丝。柴郡猫和疯帽子他们一直在想着你……我还以为你不会再来这里了。",
    "（沉默）……可我确实没有来过这里。",
    "呃……嗯，我不能直接告诉你，爱丽丝，这里不欢迎明白的人，但我相信你会慢慢搞清楚的，相信我。",
    "哦……好吧，那你可要先跟上我呢。",
    "他们……嗯……爱丽丝，你应该比我更了解他们，不是吗？"
  };
  
  String[] portraits = {
    "rabbit_panic", "alice_normal", "rabbit_panic", "alice_cold", 
    "rabbit_taunt", "alice_normal", "rabbit_panic", "alice_smile",
    "rabbit_panic", "alice_cold", "rabbit_taunt", "alice_cold",
    "rabbit_taunt",
    "rabbit_taunt",
    "rabbit_taunt",
  };
  
  startDialog(speakers, lines, portraits, 2);
}
// ========== 启动第二章对话 ==========
void startChapter2Dialog() {
  switchBGM(bgmChapter2); 
  currentChapter = 2;
  forestBg = cheshireBg;

  String[] speakers = {
    "alice", "rabbit", "alice", "rabbit", "alice", "alice",
    "alice", "cheshire", "alice", "cheshire", "alice",
    "cheshire", "alice", "cheshire",
    "alice", "cheshire",
    "alice",
    "cheshire", "cheshire", "cheshire",
    "alice", "cheshire", "alice", "cheshire", "alice"
  };

  String[] lines = {
    "终于追到了……你说左边第三条路？",
    "对……柴郡猫就在那里等你。快去吧，爱丽丝，他估计已经知道你的消息了。",
    "他怎么知道……？算了。（这地方太诡异了，先跟着这兔子说的做吧。）",
    "柴郡猫……他会突然出现又消失，似乎无处不在的样子。别担心，爱丽丝，他不会太难为你的。",
    "（兔子一溜烟跑了。爱丽丝望向黑暗的森林深处，一双发光的眼睛在空中浮现。）",
    "（爱丽丝警惕地环顾四周）",
    "你就是柴郡猫？……为什么我只听到了你的声音。",
    "我就在你的身边……或许在你左边，或许在你右边……爱丽丝，再次见到你真好。",
    "呃……我真的没有一点印象。你能改改说话的方式吗？让我听着很难受。",
    "嗯……换个话题，我知道你在找出去的方向，爱丽丝，你可以跟上我的脚步。",
    "你不会也要跟那只死兔子一样非得玩什么你追我赶吧……你们一个两个怎么都这么奇怪。",
    "你还是那样，爱丽丝。你难道不好奇自己为什么在这里吗？",
    "问了你就会告诉我吗？……或许这是场梦呢，真希望自己能立马醒来。",
    "哦…好吧，我不会。爱丽丝，这个地方不是由我们主导的，等你自己想明白的时候，一切都会结束的。",
    "（真倒霉，一只疯了的猫和一只诡异的兔子）",
    "好了，爱丽丝，我们需要先去找到疯帽子参加他的茶话会，这是每一次都必要的流程。",
    "",
    "当然了（笑），就算这里是个梦境，你也不会在心情很好的时候做这样的梦吧？",
    "嗯……或许是在十六七岁的时候？那时候你的压力很大。",
    "（失望地撇了撇嘴）",
    "你们一直这样生活在这里吗？",
    "（愣了一瞬，随即低笑）哪样？嗯……爱丽丝，我们平时很无聊的，只有在你来的时候，我们的行动才有意义。不知道这一次过后，我们还会不会继续存在。",
    "（沉思）",
    "爱丽丝，等你想明白…等你愿意去想明白的时候，一切就会结束了。",
    "（转身往前走）或许吧。"
  };

  String[] portraits = {
    "alice_normal", "rabbit_panic", "alice_normal", "rabbit_taunt", "alice_normal", "alice_cold",
    "alice_normal", "cheshire_floating", "alice_cold", "cheshire_grin",
    "alice_normal", "cheshire_normal", "alice_normal", "cheshire_normal",
    "alice_cold", "cheshire_grin",
    "alice_normal",
    "cheshire_normal", "cheshire_normal", "cheshire_normal",
    "alice_normal", "cheshire_shy", "alice_cold", "cheshire_shy", "alice_smile"
  };

  startDialog(speakers, lines, portraits, 3);
}
// ========== 启动对话通用函数 ==========
void startDialog(String[] speakers, String[] lines, String[] portraits, int nextState) {
  dialogSpeakers = speakers;
  dialogLines = lines;
  dialogPortraits = portraits;
  dialogIndex = 0;
  isDialogActive = true;
  isTyping = true;
  showOptions = false;
  typingIndex = 0;
  currentDisplayText = "";
  typingTimer = millis();
  dialogNextState = nextState;
  gameState = 10;
}

// ========== 获取当前立绘 ==========
PImage getCurrentPortrait() {
  if (dialogPortraits == null || dialogIndex >= dialogPortraits.length) return null;
  String name = dialogPortraits[dialogIndex];
  if (name.equals("alice_normal")) return alicePortrait_normal;
  if (name.equals("alice_smile")) return alicePortrait_smile;
  if (name.equals("alice_knife")) return alicePortrait_knife;
  if (name.equals("alice_cold")) return alicePortrait_cold;
  if (name.equals("rabbit_panic")) return rabbitPortrait_panic;
  if (name.equals("rabbit_taunt")) return rabbitPortrait_taunt;
  if (name.equals("rabbit_defeated")) return rabbitPortrait_defeated;
  // ★★★ 柴郡猫立绘 ★★★
if (name.equals("cheshire_normal")) return cheshirePortrait_normal;
if (name.equals("cheshire_grin")) return cheshirePortrait_grin;
if (name.equals("cheshire_floating")) return cheshirePortrait_floating;
if (name.equals("cheshire_shy")) return cheshirePortrait_shy;
  if (name.equals("hatter_smile")) return hatterSmile;
if (name.equals("hatter_laugh")) return hatterLaugh;
if (name.equals("hatter_silent")) return hatterSilent;
if (name.equals("queen_normal")) return queenNormal;
if (name.equals("queen_grin")) return queenGrin;
  return null;
}
PImage getPortraitByName(String name) {
  if (name.equals("alice_normal")) return alicePortrait_normal;
  if (name.equals("alice_smile")) return alicePortrait_smile;
  if (name.equals("alice_knife")) return alicePortrait_knife;
  if (name.equals("alice_cold")) return alicePortrait_cold;
  if (name.equals("rabbit_panic")) return rabbitPortrait_panic;
  if (name.equals("rabbit_taunt")) return rabbitPortrait_taunt;
  if (name.equals("rabbit_defeated")) return rabbitPortrait_defeated;
  if (name.equals("cheshire_normal")) return cheshirePortrait_normal;
  if (name.equals("cheshire_grin")) return cheshirePortrait_grin;
  if (name.equals("cheshire_floating")) return cheshirePortrait_floating;
  if (name.equals("cheshire_shy")) return cheshirePortrait_shy;
  if (name.equals("hatter_smile")) return hatterSmile;
if (name.equals("hatter_laugh")) return hatterLaugh;
if (name.equals("hatter_silent")) return hatterSilent;
if (name.equals("queen_normal")) return queenNormal;
if (name.equals("queen_grin")) return queenGrin;
  return null;
}

// ========== 设置选项 ==========
void setOptions(String[] texts, int[] targets) {
  showOptions = true;
  for (int i = 0; i < 3; i++) {
    optionTexts[i] = (i < texts.length) ? texts[i] : "";
    optionTargets[i] = (i < targets.length) ? targets[i] : -1;
  }
}

void advanceDialog() {
  if (showOptions) return;
  
  if (isTyping) {
    currentDisplayText = dialogLines[dialogIndex];
    isTyping = false;
    return;
  }
  
  dialogIndex++;
  
  // ===== 检查是否超出对话长度 =====
  if (dialogIndex >= dialogLines.length) {
    isDialogActive = false;
    
    if (isFarewellDialog) {
      isFarewellDialog = false;
      gameState = 8;
    } else if (currentChapter == 3) {
      gameState = 6;
    } else {
      gameState = dialogNextState;
    }
    
    if (dialogNextState == 2) {
      startGameChapter1();
    }
    if (dialogNextState == 3) {
      startChapter2Game();
    }
    if (dialogNextState == 9) {
      startQueenBattle();
    }
    if (dialogNextState == 12) {
      startMazeGame();
    }
    return;
  }
  
  // ★★★ 第一章选项 ★★★
  if (dialogIndex == 11 && currentChapter == 1) {
    String[] opts = {
      "“这里到底是什么地方？”",
      "“少废话了，现在立马带我离开这。”",
      "“柴郡猫和疯帽子是谁？”"
    };
    int[] targets = {12, 13, 14};
    setOptions(opts, targets);
    return;
  }
  
 // ★★★ 第一章分支回答（选完后直接结束对话进入小游戏）★★★
if (currentChapter == 1 && (dialogIndex == 12 || dialogIndex == 13 || dialogIndex == 14)) {
  if (isTyping) {
    currentDisplayText = dialogLines[dialogIndex];
    isTyping = false;
    return;
  }
  // ★★★ 直接结束对话，进入小游戏 ★★★
  isDialogActive = false;
  gameState = dialogNextState;
  if (dialogNextState == 2) {
    startGameChapter1();
  }
  return;
}
  // ★★★ 第二章选项 ★★★
  if (dialogIndex == 16 && currentChapter == 2) {
    String[] opts = {
      "“我的事情和进入这个地方有什么关联吗？”",
      "“在你们印象里，我上一次来是什么时候？”",
      "“带好你的路吧，别多嘴。”"
    };
    int[] targets = {17, 18, 19};
    setOptions(opts, targets);
    return;
  }
  
  // ★★★ 第二章分支回答（选完后跳转到索引20）★★★
  if (currentChapter == 2 && (dialogIndex == 17 || dialogIndex == 18 || dialogIndex == 19)) {
    if (isTyping) {
      currentDisplayText = dialogLines[dialogIndex];
      isTyping = false;
      return;
    }
    dialogIndex = 20;
    isTyping = true;
    typingIndex = 0;
    currentDisplayText = "";
    typingTimer = millis();
    return;
  }
  
  isTyping = true;
  typingIndex = 0;
  currentDisplayText = "";
  typingTimer = millis();
}
// ========== 绘制对话界面 ==========
void drawDialog() {
  background(0);
  
  // ----- 1. 背景图 -----
  if (forestBg != null) {
    image(forestBg, 0, 0, width, height);
  } else {
    fill(20, 30, 40);
    rect(0, 0, width, height);
  }
  
// ===== 先绘制兔子和柴郡猫和疯帽子（在对话框后面） =====
if (!showOptions && dialogIndex < dialogSpeakers.length) {
  String speaker = dialogSpeakers[dialogIndex];
  PImage portrait = getCurrentPortrait();
  
if (portrait != null && (speaker.equals("rabbit") || speaker.equals("cheshire") || 
    speaker.equals("hatter_smile") || speaker.equals("hatter_laugh") || speaker.equals("hatter_silent") ||
    speaker.equals("queen") || speaker.equals("queen_normal") || speaker.equals("queen_grin"))) {
    float maxHeight = height - 250;
    float targetHeight = 1050;
    if (targetHeight > maxHeight) targetHeight = maxHeight;
    if (targetHeight < 400) targetHeight = 400;
    float pW = portrait.width * (targetHeight / portrait.height);
    float pH = targetHeight;
    float centerX;
    if (speaker.equals("cheshire")) {
      centerX = (width - pW) / 2 + 470;
    } else {
      centerX = (width - pW) / 2 + 410;
    }
    float centerY = height - pH - 20;
    if (centerY < 50) centerY = 50;
    image(portrait, centerX, centerY, pW, pH);
  }
}
// ===== 选项出现时强制画柴郡猫（只画右边） =====
if (showOptions && currentChapter == 2) {
  PImage portrait = cheshirePortrait_normal;
  if (portrait != null) {
    float maxHeight = height - 250;
    float targetHeight = 1050;
    if (targetHeight > maxHeight) targetHeight = maxHeight;
    if (targetHeight < 400) targetHeight = 400;
    float pW = portrait.width * (targetHeight / portrait.height);
    float pH = targetHeight;
    float centerX = (width - pW) / 2 + 470;
    float centerY = height - pH - 20;
    if (centerY < 50) centerY = 50;
    image(portrait, centerX, centerY, pW, pH);
  }
}
  // ----- 2. 计算对话框位置 -----
  float dialogW, dialogH, dialogY;
  if (dialogBg != null) {
    dialogW = width - 80;
    float ratio = dialogBg.width / (float)dialogBg.height;
    dialogH = dialogW / ratio;
    if (dialogH > 200) {
      dialogH = 200;
      dialogW = dialogH * ratio;
    }
    dialogY = height - dialogH - 30;
  } else {
    dialogW = width - 80;
    dialogH = 180;
    dialogY = height - dialogH - 30;
  }
  float dialogX = (width - dialogW) / 2;
  
  // ----- 3. 绘制对话框背景 -----
  if (dialogBg != null) {
    image(dialogBg, dialogX, dialogY, dialogW, dialogH);
  } else {
    fill(0, 0, 0, 200);
    rect(dialogX, dialogY, dialogW, dialogH, 15);
  }
  
  // ===== 爱丽丝绘制（在对话框之上） =====
// ★★★ 选项出现时不画爱丽丝 ★★★
if (!showOptions && dialogIndex < dialogSpeakers.length) {
  String speaker = dialogSpeakers[dialogIndex];
  PImage portrait = getCurrentPortrait();
  if (portrait != null && speaker.equals("alice")) {
    float targetHeight = 600;
    float pW = portrait.width * (targetHeight / portrait.height);
    float pH = targetHeight;
    float aliceX = dialogX - pW + 100;
    float aliceY = dialogY + dialogH - pH;
    image(portrait, aliceX, aliceY, pW, pH);
  }
}
  
  // ----- 4. 发言者名称 -----
 if (dialogIndex < dialogSpeakers.length) {
  String speaker = dialogSpeakers[dialogIndex];
  color speakerColor;
  String speakerName;
  
  if (speaker.equals("alice")) {
    speakerColor = color(200, 100, 150);
    speakerName = "爱丽丝";
  } else if (speaker.equals("rabbit")) {
    speakerColor = color(200, 180, 150);
    speakerName = "兔子";
  } else if (speaker.equals("cheshire")) {
    speakerColor = color(150, 100, 255);
    speakerName = "柴郡猫";
  } else if (speaker.equals("hatter_smile") || speaker.equals("hatter_laugh") || speaker.equals("hatter_silent")) {
    speakerColor = color(150, 200, 100);
    speakerName = "疯帽子";
  } else if (speaker.equals("queen") || speaker.equals("queen_normal") || speaker.equals("queen_grin")) {
  speakerColor = color(255, 50, 50);
  speakerName = "红皇后";
} else {
    speakerColor = color(255);
    speakerName = "???";
  }
  
  fill(speakerColor);
  textFont(chineseFont);
  textSize(24);
  text(speakerName, dialogX + 30, dialogY + 35);
}
  
  // ----- 5. 对话文字（打字机效果） -----
  if (dialogIndex < dialogLines.length) {
    String fullText = dialogLines[dialogIndex];
    
    if (isTyping) {
      int nextIndex = typingIndex + typingSpeed;
      if (nextIndex >= fullText.length()) {
        typingIndex = fullText.length();
        currentDisplayText = fullText;
        isTyping = false;
      } else {
        typingIndex = nextIndex;
        currentDisplayText = fullText.substring(0, typingIndex);
      }
    } else {
      if (!showOptions) {
        currentDisplayText = fullText;
      }
    }
    
    fill(255);
    textFont(chineseFont);
    textSize(24);
    textAlign(CENTER, CENTER);
    
    float textX = dialogX + dialogW/2 - 400;
    float textY = dialogY + dialogH/2 - 90;
    float textBoxW = dialogW - 20;
    float textBoxH = dialogH - 20;
    
    text(currentDisplayText, textX, textY, textBoxW, textBoxH);
    textAlign(LEFT, TOP);
  }
  
  // ----- 6. 选项（如果有） -----
  if (showOptions) {
    drawOptions();
  }
  
  // ----- 7. 点击继续提示 -----
  if (!isTyping && !showOptions && dialogIndex < dialogLines.length) {
    fill(255, 255, 255, 100);
    textFont(chineseFont);
    textSize(16);
    textAlign(RIGHT, BOTTOM);
    text("点击继续...", dialogX + dialogW - 10, dialogY + dialogH - 10);
    textAlign(LEFT, TOP);
  }
}

// ========== 绘制选项按钮（独立函数，在 drawDialog 外面） ==========
void drawOptions() {
  int optY = height - 500;   
  int optW = 500;
  int optH = 50;
  int optSpacing = 12;
  int startX = width/2 - optW/2;
  
  for (int i = 0; i < 3; i++) {
    if (optionTexts[i] == null || optionTexts[i].equals("")) continue;
    
    boolean hover = (mouseX > startX && mouseX < startX + optW &&
                     mouseY > optY + i * (optH + optSpacing) && 
                     mouseY < optY + i * (optH + optSpacing) + optH);
    
    if (hover) {
      fill(180, 70, 100, 220);
      stroke(255, 200, 200);
    } else {
      fill(60, 40, 80, 200);
      stroke(200, 150, 180);
    }
    strokeWeight(2);
    rect(startX, optY + i * (optH + optSpacing), optW, optH, 10);
    
    fill(255);
    textFont(chineseFont);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(optionTexts[i], startX + optW/2, optY + i * (optH + optSpacing) + optH/2);
    textAlign(LEFT, TOP);
  }
}

// ================================================================
// 第一章小游戏（校准追赶模式） 

// ================================================================

// ========== 游戏变量 ==========
// 背景
PImage bg1, bg2, bg3;
PImage bgCurrent;
float bgX = 0;
int bgSwitchTimer = 0;
int bgSwitchInterval = 5000;
int bgIndex = 0;

// 爱丽丝
PImage[] aliceRun = new PImage[4];
int aliceFrame = 0;
int aliceAnimTimer = 0;
int aliceAnimSpeed = 1;
float aliceX = 200;
float aliceY = 0;
float aliceW = 260;
float aliceH = 280;
float groundY = 0;
int aliceLives = 3;

// 兔子
PImage[] rabbitRun = new PImage[2];
float rabbitX, rabbitY;
float rabbitW = 320;
float rabbitH = 340;
boolean rabbitCaughtFlag = false;

// ★★★ 校准系统（高速版） ★★★
float sliderX = 0;
float sliderSpeed = 12;        // 很快！
float sliderDirection = 1;
float targetZoneX = 0;
float targetZoneWidth = 90;    // 更小！
int correctClicks = 0;
int maxClicks = 5;
int wrongClicks = 0;
int maxWrong = 3;
boolean canClick = true;
int clickCooldown = 0;

// 游戏状态
float gameTime = 30;
int gameTimer = 0;
boolean gameActive = false;
boolean gameWin = false;
boolean gameLose = false;
boolean showResult = false;
int resultDialogStep = 0;

// UI
PImage heartIcon;
PFont uiFont;


// ========== 加载素材 ==========
void loadGameAssets() {
  bg1 = loadImage("bg1.jpg");
  bg2 = loadImage("bg2.jpg");
  bg3 = loadImage("bg3.jpg");
  if (bg1 == null) println("警告: bg1.jpg 未找到");
  if (bg2 == null) println("警告: bg2.jpg 未找到");
  if (bg3 == null) println("警告: bg3.jpg 未找到");
  bgCurrent = bg1;
  
  for (int i = 0; i < 4; i++) {
    aliceRun[i] = loadImage("alice_run_" + nf(i+1, 2) + ".png");
    if (aliceRun[i] == null) println("警告: alice_run_" + nf(i+1, 2) + ".png 未找到");
  }
  
  for (int i = 0; i < 2; i++) {
    rabbitRun[i] = loadImage("rabbit_run_" + nf(i+1, 2) + ".png");
    if (rabbitRun[i] == null) println("警告: rabbit_run_" + nf(i+1, 2) + ".png 未找到");
  }
  
  heartIcon = loadImage("heart.png");
  
  uiFont = createFont("Georgia", 36);
  if (uiFont == null) uiFont = createFont("SansSerif", 36);
}


// ========== 启动游戏 ==========
void startGameChapter1() {
  frameRate(60);
  
  groundY = height - 250;
  aliceY = groundY - aliceH;
  aliceX = 200;
  aliceLives = 3;
  
  rabbitX = width - 200;
  rabbitY = groundY - rabbitH;
  rabbitCaughtFlag = false;
  
  sliderX = 0;
  sliderDirection = 1;
  sliderSpeed = 100;
  targetZoneX = random(150, width - 150 - targetZoneWidth);
  correctClicks = 0;
  wrongClicks = 0;
  canClick = true;
  clickCooldown = 0;
  
  gameTime = 40;
  gameActive = true;
  gameWin = false;
  gameLose = false;
  showResult = false;
  gameTimer = millis();
  bgX = 0;
  bgCurrent = bg1;
  bgIndex = 0;
  
  gameState = 2;
  println("校准追赶模式开始！按对5次追上兔子！");
}


// ========== 绘制主循环 ==========
void drawGameChapter1() {
  drawBackground();
  
  if (gameActive) {
    updateGame();
  }
  
  drawRabbit();
  drawAlice();
  drawCalibrationUI();
  drawUI();
  
  if (showResult) {
    drawResultDialog();
  }
}


// ========== 绘制背景 ==========
void drawBackground() {
  if (bgCurrent != null) {
    bgX -= 4;
    float offsetX = bgX % width;
    if (offsetX > 0) offsetX = offsetX - width;
    image(bgCurrent, offsetX, 0, width, height);
    image(bgCurrent, offsetX + width, 0, width, height);
    
    if (offsetX <= -width) {
      bgX = 0;
      bgIndex = (bgIndex + 1) % 3;
      if (bgIndex == 0) bgCurrent = bg1;
      else if (bgIndex == 1) bgCurrent = bg2;
      else bgCurrent = bg3;
    }
  } else {
    background(20, 30, 40);
  }
}


// ========== 绘制爱丽丝 ==========
void drawAlice() {
  if (!gameActive && !showResult) return;
  
  aliceAnimTimer++;
  if (aliceAnimTimer >= aliceAnimSpeed) {
    aliceAnimTimer = 0;
    aliceFrame = (aliceFrame + 1) % 4;
  }
  
  PImage currentFrame = aliceRun[aliceFrame];
  if (currentFrame != null) {
    float ratio = (float)currentFrame.width / currentFrame.height;
    float drawW = aliceW;
    float drawH = drawW / ratio;
    if (drawH > aliceH) {
      drawH = aliceH;
      drawW = drawH * ratio;
    }
    float offsetX = (aliceW - drawW) / 2;
    float offsetY = (aliceH - drawH) / 2;
    
   
    // 主图
    image(currentFrame, aliceX + offsetX, aliceY + offsetY, drawW, drawH);
  } else {
    fill(200, 100, 150);
    rect(aliceX, aliceY, aliceW, aliceH);
  }
}
// ========== 绘制兔子 ==========
void drawRabbit() {
  // 兔子奔跑动画（正常显示）
  int frame = (frameCount / 8) % 2;
  PImage currentFrame = rabbitRun[frame];
  if (currentFrame != null) {
    float ratio = (float)currentFrame.width / currentFrame.height;
    float drawW = rabbitW;
    float drawH = drawW / ratio;
    if (drawH > rabbitH) {
      drawH = rabbitH;
      drawW = drawH * ratio;
    }
    float offsetX = (rabbitW - drawW) / 2;
    float offsetY = (rabbitH - drawH) / 2;
    image(currentFrame, rabbitX + offsetX, rabbitY + offsetY, drawW, drawH);
  } else {
    fill(200, 180, 150);
    rect(rabbitX, rabbitY, rabbitW, rabbitH);
  }
  
  
}
// ========== 更新逻辑 ==========
void updateGame() {
  if (millis() - gameTimer > 1000) {
    gameTimer = millis();
    gameTime--;
    if (gameTime <= 0) {
      gameActive = false;
      gameLose = true;
      showResult = true;
      resultDialogStep = 0;
      return;
    }
  }
  
  rabbitX -= 2.5;
  if (rabbitX < 100) {
    rabbitX = width - 100;
  }
  
  // ★★★ 滑块高速移动 ★★★
  sliderX += sliderSpeed * sliderDirection;
  if (sliderX >= width - 50) {
    sliderDirection = -1;
  } else if (sliderX <= 50) {
    sliderDirection = 1;
  }
  
  if (frameCount % 120 == 0) {
    targetZoneX = random(100, width - 100 - targetZoneWidth);
  }
  
  if (clickCooldown > 0) {
    clickCooldown--;
    if (clickCooldown == 0) canClick = true;
  }
}


// ========== 处理点击 ==========
void handleCalibrationClick() {
  if (!gameActive || !canClick || showResult) return;
  
  float sliderCenter = sliderX;
  float targetCenter = targetZoneX + targetZoneWidth / 2;
  float halfZone = targetZoneWidth / 1;
  
  if (abs(sliderCenter - targetCenter) < halfZone) {
    correctClicks++;
     clickSound.play();  
    canClick = false;
    clickCooldown = 3;
    aliceX += 30;
    targetZoneX = random(100, width - 100 - targetZoneWidth);
    
    if (correctClicks >= maxClicks) {
      gameActive = false;
      gameWin = true;
      rabbitCaughtFlag = true;
      showResult = true;
      resultDialogStep = 0;
    }
  } else {
    wrongClicks++;
    aliceLives--;
    canClick = false;
    clickCooldown = 5;
    aliceX -= 20;
    if (aliceX < 100) aliceX = 100;
    
    if (aliceLives <= 0 || wrongClicks >= maxWrong) {
      gameActive = false;
      gameLose = true;
      showResult = true;
      resultDialogStep = 0;
    }
  }
}


// ========== 绘制校准UI（底部） ==========
void drawCalibrationUI() {
  if (!gameActive) return;
  
  // ★★★ 校准条放在最底部 ★★★
  float barY = height - 130;
  float barHeight = 70;
  
  // 背景轨道
  fill(40, 30, 50, 200);
  noStroke();
  rect(50, barY, width - 100, barHeight, 15);
  
  // 高亮区域（目标）
  fill(0, 255, 200, 150);
  noStroke();
  rect(targetZoneX, barY + 5, targetZoneWidth, barHeight - 10, 8);
  
  // 高亮区域边框（发光效果）
  stroke(0, 255, 200, 200);
  strokeWeight(2);
  noFill();
  rect(targetZoneX, barY + 5, targetZoneWidth, barHeight - 10, 8);
  
  // 滑块（菱形）
  float sliderY = barY + barHeight / 2;
  fill(255, 255, 255, 240);
  noStroke();
  pushMatrix();
  translate(sliderX, sliderY);
  beginShape();
  vertex(0, -18);
  vertex(12, 0);
  vertex(0, 18);
  vertex(-12, 0);
  endShape(CLOSE);
  popMatrix();
  
  // 滑块中心点
  fill(255, 200, 50);
  ellipse(sliderX, sliderY, 8, 8);
  
  // ★★★ 进度文字（在轨道上方） ★★★
  fill(255);
  textFont(uiFont);
  textSize(24);
  textAlign(CENTER, BOTTOM);
  text("⚡ 校准 " + correctClicks + "/" + maxClicks, width/2, barY - 8);
  textAlign(LEFT, TOP);
  
  // ★★★ 错误计数（右上） ★★★
  fill(255, 100, 100, 200);
  textSize(18);
  textAlign(RIGHT, BOTTOM);
  text("失误: " + wrongClicks + "/" + maxWrong, width - 60, barY - 8);
  textAlign(LEFT, TOP);
  
  // ★★★ 操作提示（轨道下方） ★★★
  fill(255, 255, 255, 130);
  textSize(16);
  textAlign(CENTER, TOP);
  text("↑ 滑块进入绿色区域时点击 ↑", width/2, barY + barHeight + 12);
  textAlign(LEFT, TOP);
  
  // ★★★ 追赶进度条（在轨道下方更底部） ★★★
  float progress = (float)correctClicks / maxClicks;
  float progW = width * 0.5;
  float progX = (width - progW) / 2;
  float progY = barY + barHeight + 48;
  
  fill(40, 30, 50, 180);
  noStroke();
  rect(progX, progY, progW, 14, 8);
  
  if (progress > 0) {
    fill(0, 255, 200, 200);
    rect(progX + 2, progY + 2, (progW - 4) * progress, 10, 6);
  }
  
  fill(255, 180);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("追赶进度", width/2, progY + 7);
  textAlign(LEFT, TOP);
}


// ========== 绘制UI ==========
void drawUI() {
  textFont(uiFont);
  
  for (int i = 0; i < aliceLives; i++) {
    if (heartIcon != null) {
      image(heartIcon, width - 80 - i * 50, 20, 45, 45);
    } else {
      fill(255, 0, 0);
      textSize(36);
      text("❤", width - 50 - i * 50, 55);
    }
  }
  
  fill(255);
  textSize(36);
  textAlign(LEFT, TOP);
  text("⏱ " + (int)gameTime + "s", 20, 25);
  
  fill(255, 200, 200, 180);
  textSize(20);
  String[] sceneNames = {"🌲 森林入口", "🌑 黑暗林间", "🕳️ 兔子洞前"};
  text(sceneNames[bgIndex % 3], width/2 - 80, 30);
  
  textAlign(LEFT, TOP);
}


// ========== 绘制结果对话框 ==========
void drawResultDialog() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(50, 40, 60);
  rect(width/4, height/2 - 150, width/2, 300, 20);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(28);
  
  String[] dialogLines;
 if (gameWin) {
  dialogLines = new String[]{
    "🎉 你追上了兔子！",
    "兔子: 咳咳，好吧，你每次都能追上我，去左边第三条路就好。",
    "爱丽丝: 早这样不就好了。"
  };
  } else if (gameLose && gameTime <= 0) {
    dialogLines = new String[]{
      "⏰ 时间到了……",
      "兔子: 跑得不够快啊！",
      "爱丽丝: 可恶……"
    };
  } else {
    dialogLines = new String[]{
      "💀 你校准失败了……",
      "兔子: 哈……哈……没抓到吧？",
      "爱丽丝: 你跑不掉的！"
    };
  }
  
  if (resultDialogStep < dialogLines.length) {
  text(dialogLines[resultDialogStep], width/2, height/2 - 30);
} else {
  startChapter2Dialog();  // 进入第二章对话
  return;
}
  fill(255, 215, 0);
  textSize(24);
  text("正确校准: " + correctClicks + " / " + maxClicks + " 次", width/2, height/2 + 80);
  
  fill(255, 255, 255, 150);
  textSize(18);
  text("点击继续...", width/2, height/2 + 130);
  
  textAlign(LEFT, TOP);
}
// ========== 加载第二章素材 ==========
void loadCatAssets() {
  cheshireAppear1 = loadImage("cheshire_appear1.png");
  cheshireAppear2 = loadImage("cheshire_appear2.png");
  cheshireAppear3 = loadImage("cheshire_appear3.png");
  
  interact1 = loadImage("cheshire_interact1.png");
  interact2 = loadImage("cheshire_interact2.png");
  interact3 = loadImage("cheshire_interact3.png");
  
  if (cheshireAppear1 == null) println("警告: cheshire_appear1.png 未找到");
}
// ========== 启动第二章游戏 ==========
void startChapter2Game() {
  catClicks = 0;
  catLives = maxCatLives;
  catGameActive = true;
  catGameWin = false;
  catGameLose = false;
  catShowResult = false;
  targetVisible = false;
  showFeedback = false;
  canClickCat = true;
  catClickCooldown = 0;
  catResultStep = 0;
  spawnCatTarget();
  gameState = 3;
  println("第二章：猫影迷踪 开始！");
}
// ========== 生成猫目标 ==========
void spawnCatTarget() {
  float margin = 100;
  targetX = random(margin, width - margin);
  targetY = random(margin + 80, height - margin - 180);
  
  if (catClicks < 2) {
    targetSize = 180;
    targetDuration = 4.0;
  } else if (catClicks < 4) {
    targetSize = 160;
    targetDuration = 3.0;
  } else if (catClicks < 6) {
    targetSize = 140;
    targetDuration = 2.5;
  } else {
    targetSize = 80;
    targetDuration = 2.5;
  }
  
  targetVisible = true;
  targetAppearTime = millis();
}
// ========== 判断特殊节点 ==========
boolean isSpecialNode(int clickCount) {
  return clickCount == 3 || clickCount == 5 || clickCount == 8;
}

PImage getInteractImage(int clickCount) {
  if (clickCount == 3) return interact1;
  if (clickCount == 5) return interact2;
  if (clickCount == 8) return interact3;
  return null;
}
// ========== 绘制游戏主画面 ==========
void drawGameChapter2() {
  // ★★★ 使用柴郡猫背景图 ★★★
  if (cheshireBg != null) {
    image(cheshireBg, 0, 0, width, height);
  } else {
    background(5, 5, 15);  // 备用：如果没有背景图就用黑色
  }
  
  // 氛围光晕
  bgGlow += bgGlowDir ? 0.3 : -0.3;
  if (bgGlow > 30) bgGlowDir = false;
  if (bgGlow < 0) bgGlowDir = true;
  fill(20, 10, 30, 30);   // 透明度从50降到30，让背景透出来
  ellipse(width/2, height/2, width * 0.8 + bgGlow * 2, height * 0.6 + bgGlow * 2);
  
  drawCatAtmosphere();
  drawCatTarget();
  drawCatFeedback();
  drawCatUI();
  
  if (catShowResult) {
    drawCatResultDialog();
  }
}
// ========== 绘制氛围光点 ==========
void drawCatAtmosphere() {
  for (int i = 0; i < 30; i++) {
    float x = (i * 137.5 + 50) % width;
    float y = (i * 97.3 + 30) % height;
    float size = 1 + (i % 3);
    float alpha = 30 + 20 * sin(frameCount * 0.01 + i);
    fill(150, 120, 255, alpha);
    noStroke();
    ellipse(x, y, size, size);
  }
}
// ========== 绘制猫目标 ==========
void drawCatTarget() {
  if (!targetVisible) return;
  
  PImage img = null;
  if (catClicks < 2) {
    img = cheshireAppear1;
  } else if (catClicks < 4) {
    img = cheshireAppear2;
  } else {
    img = cheshireAppear3;
  }
  
  if (img != null) {
    float ratio = (float)img.width / img.height;
    float drawW = targetSize;
    float drawH = drawW / ratio;
    if (drawH > targetSize * 1.2) {
      drawH = targetSize * 1.2;
      drawW = drawH * ratio;
    }
    float offsetX = (targetSize - drawW) / 2;
    float offsetY = (targetSize - drawH) / 2;
    
    float glow = 0.8 + 0.2 * sin(frameCount * 0.05);
    tint(255, 255, 255, 180 * glow);
    image(img, targetX - targetSize/2 + offsetX, targetY - targetSize/2 + offsetY, drawW, drawH);
    noTint();
  }
  
  // 超时消失
  if (millis() - targetAppearTime > targetDuration * 1000) {
    targetVisible = false;
    catLives--;
    if (catLives <= 0) {
      catGameActive = false;
      catGameLose = true;
      catShowResult = true;
      catResultStep = 0;
    } else {
      spawnCatTarget();
    }
  }
}
// ========== 处理点击 ==========
void handleCatClick() {
  if (!catGameActive || !canClickCat || catShowResult) return;
  if (!targetVisible) return;
  
  // ★★★ 改成宽泛的矩形判定 ★★★
  float halfW = targetSize / 2 + 150;  // 宽度范围扩大
  float halfH = targetSize / 2 + 150;  // 高度范围扩大
  
  boolean hit = (mouseX > targetX - halfW && mouseX < targetX + halfW &&
                 mouseY > targetY - halfH && mouseY < targetY + halfH);
  
  if (hit) {
    targetVisible = false;
    catClicks++;
    
    feedbackIndex = catClicks;
    showFeedback = true;
    feedbackTimer = millis();
    
    if (!isSpecialNode(catClicks)) {
      spawnCatTarget();
    }
    
    if (clickSound != null) clickSound.play();
    
    // ★★★ 第8次点击时，不立即弹出结算，等特殊反馈关闭后再弹出 ★★★
if (catClicks >= maxCatClicks) {
  // 不在这里设置胜利，等特殊反馈关闭后再设置
  // catGameActive = false;  // 先不关
  // catGameWin = true;
  // catShowResult = true;   // 先不弹
}
    canClickCat = false;
    catClickCooldown = 1;
    
  } else {
    catLives--;
    if (catLives <= 0) {
      catGameActive = false;
      catGameLose = true;
      catShowResult = true;
      catResultStep = 0;
    }
  }
}
// ========== 绘制反馈 ==========
void drawCatFeedback() {
  if (!showFeedback) return;
  
  if (isSpecialNode(feedbackIndex)) {
    drawSpecialFeedback();
  } else {
    drawNormalFeedback();
  }
  
  if (millis() - feedbackTimer > feedbackDuration * 1000) {
    showFeedback = false;
  }
}

void drawNormalFeedback() {
  float boxW = 300;
  float boxH = 80;
  float boxX = (width - boxW) / 2;
  float boxY = (height - boxH) / 2 - 20;
  
  fill(0, 0, 0, 200);
  stroke(150, 100, 255, 150);
  strokeWeight(2);
  rect(boxX, boxY, boxW, boxH, 12);
  
  String[] texts = {
    "你找到我了～",
    "还不错嘛～",
    "你认真的样子……还挺有意思的。",
    "你好像……在找别的什么东西。",
    "算了。不说了。",
    "下次你再来……我还会在这里等你。"
  };
  
  int idx = (feedbackIndex - 1) % texts.length;
  String text = texts[idx];
  
  fill(255);
  textFont(chineseFont);
  textSize(22);
  textAlign(CENTER, CENTER);
  text(text, boxX + boxW/2, boxY + boxH/2);
  textAlign(LEFT, TOP);
}

void drawSpecialFeedback() {
  // ★★★ 去掉边框，直接显示图片+文字 ★★★
  
  PImage img = getInteractImage(feedbackIndex);
  if (img != null) {
    // 图片居中显示，占屏幕约60%高度
    float imgH = height * 0.55;
    float ratio = (float)img.width / img.height;
    float imgW = imgH * ratio;
    if (imgW > width * 0.8) {
      imgW = width * 0.8;
      imgH = imgW / ratio;
    }
    float imgX = (width - imgW) / 2;
    float imgY = (height - imgH) / 2 - 40;
    image(img, imgX, imgY, imgW, imgH);
  }
  
  
  String[] specialTexts = {
    "（柴郡猫从背后靠近）爱丽丝，尝试抓到我吧。",
    "柴郡猫被你推倒在地）呃！……好吧，又被抓到了…",
    "柴郡猫慢慢消失）后面的路很清晰了，去吧，爱丽丝，疯帽子在那里等你。"
  };
  
  int idx = 0;
  if (feedbackIndex == 3) idx = 0;
  else if (feedbackIndex == 5) idx = 1;
  else if (feedbackIndex == 8) idx = 2;
  
  // 文字带半透明底衬
  float textY = height * 0.65 + 20;
  float textW = width * 0.7;
  float textH = 80;
  float textX = (width - textW) / 2;
  
  // 半透明底衬
  fill(0, 0, 0, 150);
  noStroke();
  rect(textX - 15, textY - 10, textW + 30, textH + 20, 12);
  
  fill(255);
  textFont(chineseFont);
  textSize(22);
  textAlign(CENTER, TOP);
  text(specialTexts[idx], textX, textY + 5, textW, textH);
  textAlign(LEFT, TOP);
}
// ========== 绘制UI ==========
void drawCatUI() {
  for (int i = 0; i < catLives; i++) {
    fill(255, 80, 80);
    textSize(30);
    textAlign(LEFT, TOP);
    text("❤", width - 60 - i * 40, 25);
    textAlign(LEFT, TOP);
  }
  
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("找到猫: " + catClicks + "/" + maxCatClicks, 25, 28);
  textAlign(LEFT, TOP);
  
  float progW = 200;
  float progX = 25;
  float progY = 65;
  fill(40, 30, 50, 150);
  noStroke();
  rect(progX, progY, progW, 10, 5);
  float progress = (float)catClicks / maxCatClicks;
  if (progress > 0) {
    fill(150, 100, 255, 200);
    rect(progX + 2, progY + 2, (progW - 4) * progress, 6, 4);
  }
  
  fill(255, 255, 255, 100);
  textSize(14);
  textAlign(CENTER, TOP);
  text("点击闪烁的猫影", width/2, height - 40);
  textAlign(LEFT, TOP);
}
// ========== 结果对话框 ==========
void drawCatResultDialog() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(40, 30, 60);
  rect(width/4, height/2 - 150, width/2, 300, 20);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  
  String[] dialogLines;
  if (catGameWin) {
    dialogLines = new String[]{
      "你成功在树林中一次次找到了柴郡猫，他看起来并不恼火，只是朝着茶话会的方向飘走了。其实你想不明白为什么要循规蹈矩地完成这个流程，但是潜意识里总是在跟着他们的节奏。或许…你真的早就经历过这一切？",
      "一切都仍是个谜团，从他们俩的话里推测，这个地方和自己在现实中发生了什么有关……是什么呢？你只记得自己之前情绪很差，然后眼前一黑，意识就坠落到了这里……",
      "——第二章通关——"
    };
  } else {
    dialogLines = new String[]{
      "💫 猫影消失了……",
      "“下次再来找我吧。我一直在。”",
      "——游戏结束——"
    };
  }
  
  if (catResultStep < dialogLines.length) {
    // ★★★ 文字居中，用 text 自动换行 ★★★
    text(dialogLines[catResultStep], width/2 - 330, height/2 - 200, width/2 - 80, 300);
  } else {
    if (catGameWin) {
      startTransitionScene();
    } else {
      gameState = 1;
    }
    return;
  }
  
  fill(255, 255, 255, 150);
  textSize(18);
  text("点击继续...", width/2, height/2 + 130);
  textAlign(LEFT, TOP);
}
// ========== 更新游戏逻辑 ==========
void updateCatGame() {
  if (!catGameActive) return;
  
  if (catClickCooldown > 0) {
    catClickCooldown--;
    if (catClickCooldown == 0) canClickCat = true;
  }
}
// ========== 过渡段场景 ==========
void drawTransitionScene() {
  // 背景
  if (transitionBg != null) {
    image(transitionBg, 0, 0, width, height);
  } else {
    background(20, 15, 30);
  }
  
  // 绘制交互物品
  float mushroomX = width * 0.45;
  float mushroomY = height * 0.8;
  float catX = width * 0.7;
  float catY = height * 0.4;
  
  if (!mushroomTriggered) {
    drawInteractItem(mushroomInteract, mushroomX, mushroomY, 120, 120, true);
    // 悬停效果
    if (dist(mouseX, mouseY, mushroomX, mushroomY) < 200) {
      drawInteractHint("点击蘑菇");
    }
  }
  
  if (!catShadowTriggered) {
    drawInteractItem(catShadow, catX, catY, 160, 160, true);
    if (dist(mouseX, mouseY, catX, catY) < 150) {
      drawInteractHint("点击猫影");
    }
  }
  
  // 绘制爱丽丝
  drawWalkingAlice();
  
  // 显示对话
  if (mushroomTriggered && !catShadowTriggered) {
    drawDialogBubble("（蘑菇缩了一下，重新亮了起来）", width/2, height * 0.15);
  }
  
  if (catShadowTriggered && !transitionGuideShown) {
    drawDialogBubble("（猫的声音从远处飘来）你还在走啊……茶会快到了。", width/2, height * 0.15);
  }
  
  // 走到最右边触发引导
  if (aliceWalkX > width * 0.85 && !transitionGuideShown && catShadowTriggered) {
    transitionGuideShown = true;
  }
  
  if (transitionGuideShown && !transitionComplete) {
    drawGuideDialog();
  }
}
// ========== 启动过渡段 ==========
void startTransitionScene() {
  // 重置过渡段变量
  aliceWalkX = -100;
  aliceWalkY = height * 0.62;
  isWalking = true;
  mushroomTriggered = false;
  catShadowTriggered = false;
  transitionGuideShown = false;
  transitionComplete = false;
  
  // 重置爱丽丝动画
  aliceFrame = 0;
  aliceAnimTimer = 0;
  
  gameState = 5;
  println("进入第三章过渡段");
}

// ========== 绘制行走的爱丽丝 ==========
void drawWalkingAlice() {
  float aliceSize = 230;  // 原120，放大
  aliceWalkY = height * 0.55;  // 调整位置
  
  // ★★★ 删除自动行走逻辑，改为由方向键控制 ★★★
  // 不再自动移动
  
  // 绘制爱丽丝（根据行走状态）
  if (isWalking) {
    aliceAnimTimer++;
    if (aliceAnimTimer >= aliceAnimSpeed) {
      aliceAnimTimer = 0;
      aliceFrame = (aliceFrame + 1) % 4;
    }
    PImage frame = aliceRun[aliceFrame];
    if (frame != null) {
      image(frame, aliceWalkX, aliceWalkY, aliceSize, aliceSize * 1.2);
    }
  } else {
    if (aliceStand != null) {
      image(aliceStand, aliceWalkX, aliceWalkY, aliceSize, aliceSize * 1.2);
    } else {
      PImage frame = aliceRun[0];
      if (frame != null) image(frame, aliceWalkX, aliceWalkY, aliceSize, aliceSize * 1.2);
    }
  }
}
// ========== 绘制引导对话 ==========
void drawGuideDialog() {
  fill(0, 0, 0, 200);
  rect(width/2 - 250, height/2 - 80, 500, 160, 20);
  
  fill(255);
  textSize(22);
  textAlign(CENTER, CENTER);
  text("（远处的烛光连成一片，茶话会的轮廓在暖光里浮现）", width/2, height/2 - 25);
  textSize(18);
  fill(255, 255, 200);
  text("点击进入茶话会", width/2, height/2 + 45);
  textAlign(LEFT, TOP);
}

// ========== 绘制对话气泡 ==========
void drawDialogBubble(String text, float x, float y) {
  fill(0, 0, 0, 200);
  rect(x - 250, y - 30, 500, 60, 15);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(text, x, y + 5);
  textAlign(LEFT, TOP);
}

// ========== 绘制交互物品 ==========
void drawInteractItem(PImage img, float x, float y, float w, float h, boolean active) {
  if (img == null) return;
  image(img, x - w/2, y - h/2, w, h);

}
// ========== 绘制交互提示 ==========
void drawInteractHint(String text) {
  fill(0, 0, 0, 180);
  rect(mouseX - 60, mouseY - 50, 120, 30, 10);
  fill(255, 255, 200);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(text, mouseX, mouseY - 35);
  textAlign(LEFT, TOP);
}
// ========== 茶话会场景 ==========
void drawTeaPartyScene() {
  if (teaPartyBg != null) {
    image(teaPartyBg, 0, 0, width, height);
  } else {
    background(30, 20, 25);
  }
  
  // ★★★ 地面位置（调低） ★★★
  float groundY = height * 0.53;
  
  // 爱丽丝（底部对齐，超大）
  if (aliceStand != null) {
    float ratio = (float)aliceStand.width / aliceStand.height;
    float drawH = 400;
    float drawW = drawH * ratio;
    image(aliceStand, 80, groundY - drawH + 330, drawW, drawH);
  }
  
  // 茶壶
  float teapotX = width * 0.25;
  drawInteractItem(teapotInteract, teapotX, groundY, 100, 100, !teapotClicked);
  if (dist(mouseX, mouseY, teapotX, groundY) < 250) drawInteractHint("点击茶壶");
  
  // 糕点
  float cakeX = width * 0.52;
  drawInteractItem(cakeInteract, cakeX, groundY, 90, 90, !cakeClicked);
  if (dist(mouseX, mouseY, cakeX, groundY) < 250) drawInteractHint("点击糕点");
  
  // 疯帽子（底部对齐，超大）
   float hatterX = width * 0.78; 
  if (hatterQ != null) {
    float ratio = (float)hatterQ.width / hatterQ.height;
    float drawH = 550;
    float drawW = drawH * ratio;
    // 底部对齐：图片中心在 (hatterX, groundY - drawH/2)
    drawInteractItem(hatterQ, hatterX, groundY - drawH/2 + 350, drawW, drawH, true);
    if (dist(mouseX, mouseY, hatterX, groundY) < 300) drawInteractHint("点击疯帽子");
  }
  
  // 糕点回答
  if (cakeResultShowing) {
    fill(0, 0, 0, 200);
    rect(width/2 - 350, height/2 - 250, 700, 500, 20);
    if (cakeInteractImg != null) {
      float imgW = 990;
      float imgH = cakeInteractImg.height * (imgW / cakeInteractImg.width);
      if (imgH > 300) { imgH = 300; imgW = cakeInteractImg.width * (imgH / cakeInteractImg.height); }
      image(cakeInteractImg, width/2 - imgW/2, height/2 - 180, imgW, imgH);
    }
    fill(255, 200, 200);
    textSize(24);
    textAlign(CENTER, CENTER);
    text(cakeOptionResult, width/2, height/2 + 200);
    fill(255, 255, 255, 150);
    textSize(16);
    text("点击继续", width/2, height/2 + 160);
    textAlign(LEFT, TOP);
  } else if (cakeDialogActive) {
    drawCakeDialog();
  }
  
  fill(255, 255, 200, 120);
  textSize(16);
  textAlign(CENTER, BOTTOM);
  text("点击茶壶开始对话 · 点击糕点互动 · 点击疯帽子玩牌", width/2, height - 20);
  textAlign(LEFT, TOP);
  // ★★★ 疯帽子菜单 ★★★
if (showHatterMenu) {
  fill(0, 0, 0, 200);
  rect(width/2 - 200, height/2 - 100, 400, 200, 20);
  
  fill(255);
  textSize(24);
  textAlign(CENTER, TOP);
  text("疯帽子", width/2, height/2 - 70);
  
  // 两个按钮
  float btnW = 150, btnH = 50;
  float btnY = height/2 - 10;
  
  // "再来一局" 按钮（左）
  float btn1X = width/2 - btnW - 20;
  boolean hover1 = mouseX > btn1X && mouseX < btn1X + btnW && mouseY > btnY && mouseY < btnY + btnH;
  fill(hover1 ? 180 : 80, 40, 60, 220);
  rect(btn1X, btnY, btnW, btnH, 10);
  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("再来一局", btn1X + btnW/2, btnY + btnH/2);
  
  // "继续前行" 按钮（右）
  float btn2X = width/2 + 20;
  boolean hover2 = mouseX > btn2X && mouseX < btn2X + btnW && mouseY > btnY && mouseY < btnY + btnH;
  fill(hover2 ? 180 : 80, 40, 60, 220);
  rect(btn2X, btnY, btnW, btnH, 10);
  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("继续前行", btn2X + btnW/2, btnY + btnH/2);
  
  textAlign(LEFT, TOP);
}
}

// ========== 糕点对话 ==========
void drawCakeDialog() {
  fill(0, 0, 0, 200);
  rect(width/2 - 350, height/2 - 250, 700, 500, 20);
  
  // 互动图
  if (cakeInteractImg != null) {
    float imgW = 600;
    float imgH = cakeInteractImg.height * (imgW / cakeInteractImg.width);
    if (imgH > 350) { imgH = 350; imgW = cakeInteractImg.width * (imgH / cakeInteractImg.height); }
    image(cakeInteractImg, width/2 - imgW/2, height/2 - 220, imgW, imgH);
  }
  
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  
  if (cakeDialogStep < 3) {
    String[] texts = {
      "疯帽子：吃一块吧。我烤的——虽然我不确定它能不能吃。",
      "爱丽丝：什么叫‘不确定能不能吃’？",
      "疯帽子：我放了两勺糖……也可能放了两勺盐。"
    };
    text(texts[cakeDialogStep], width/2, height/2 + 130);
  }
  
  if (cakeDialogStep == 3) {
    drawCakeOptions();
  }
  
  textAlign(LEFT, TOP);
}
// ========== 糕点选项 ==========
void drawCakeOptions() {
  String[] options = {"“吃一口。”", "“不吃。”", "“你尝过吗？”"};
  float optW = 180;
  float optH = 45;
  float startX = width/2 - 300;
  float startY = height/2 + 100;
  
  for (int i = 0; i < 3; i++) {
    float x = startX + i * (optW + 20);
    boolean hover = (mouseX > x && mouseX < x + optW &&
                     mouseY > startY && mouseY < startY + optH);
    fill(hover ? 180 : 80, 40, 60, 200);
    rect(x, startY, optW, optH, 10);
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(options[i], x + optW/2, startY + optH/2);
    textAlign(LEFT, TOP);
  }
}
// ========== 启动第三章对话 ==========
void startChapter3Dialog() {
  switchBGM(bgmChapter3); 
  currentChapter = 3;
  forestBg = teaPartyBg;
  
  String[] speakers = {
    "hatter_smile", "alice", "hatter_smile", "alice", "hatter_smile",
    "alice", "hatter_silent", "alice", "hatter_silent", "alice",
    "hatter_smile", "alice", "hatter_silent"
  };
  
  String[] lines = {
    "你来了！你居然真的来了！——我还在想那只猫是不是又在骗我。",
    "他让我往树最多的地方走。然后我就看到光了。",
    "你看起来……比我想象中要累一点。",
    "走了很久。",
    "那就坐。茶刚倒的。……我知道你要来。",
    "你怎么知道我会来？",
    "（低头摆弄茶杯）茶壶会冒不一样的蒸汽。空气会变重。然后你会从那条路上走过来。",
    "……你等过我？",
    "（没有立刻说话，手指轻轻摩挲杯沿）我不想说‘我一直在等你’……但我确实在等你。",
    "那只猫说，你知道怎么去红皇后那里。",
    "我知道。但你还有时间。",
    "……什么时间？",
    "（把牌摊开在桌上）玩一局吧。赢了我就告诉你。"
  };
  
  String[] portraits = {
    "hatter_smile", "alice_normal", "hatter_smile", "alice_normal", "hatter_smile",
    "alice_normal", "hatter_silent", "alice_normal", "hatter_silent", "alice_normal",
    "hatter_smile", "alice_normal", "hatter_smile"
  };
  
  startDialog(speakers, lines, portraits, 6);
}

// 抽鬼牌游戏核心函数
// ============================================================

void startCardGame() {
  println("开始抽鬼牌游戏");
  
  deck = new ArrayList<Card>();
  String[] suits = {"heart", "spade", "club", "diamond"};
  
  // ★★★ 每种花色出现4次（共16张）+ 1张鬼牌 = 17张 ★★★
  for (String suit : suits) {
    deck.add(new Card(suit, 0));
    deck.add(new Card(suit, 1));
    deck.add(new Card(suit, 2));
    deck.add(new Card(suit, 3));
  }
  deck.add(new Card("joker", 0));
  
  Collections.shuffle(deck);
  
  // 发牌：玩家8张，疯帽子9张
  playerHand = new ArrayList<Card>();
  hatterHand = new ArrayList<Card>();
  
  for (int i = 0; i < deck.size(); i++) {
    if (i < 8) {
      playerHand.add(deck.get(i));
    } else {
      hatterHand.add(deck.get(i));
    }
  }
  
  removePairs(playerHand);
  removePairs(hatterHand);
  
  isPlayerTurn = true;
  gameOver = false;
  playerWin = false;
  isHatterThinking = false;
  waitingForClick = false;
  gameMessage = "抽鬼牌开始！点击疯帽子的牌抽取。";
  
  // ★★★ 显示规则 ★★★
  showRule = true;
  
  gameState = 7;
}
void removePairs(ArrayList<Card> hand) {
  for (int i = hand.size() - 1; i >= 0; i--) {
    for (int j = i - 1; j >= 0; j--) {
      if (hand.get(i).suit.equals(hand.get(j).suit) && !hand.get(i).isJoker) {
        // ★★★ 配对成功！显示提示 ★★★
        String suitName = hand.get(i).suit;
        if (suitName.equals("heart")) pairMessage = "♥ 红心配对成功！";
        else if (suitName.equals("spade")) pairMessage = "♠ 黑桃配对成功！";
        else if (suitName.equals("club")) pairMessage = "♣ 梅花配对成功！";
        else if (suitName.equals("diamond")) pairMessage = "♦ 方块配对成功！";
        pairMessageTimer = millis();
        
        hand.remove(i);
        hand.remove(j);
        return;
      }
    }
  }
}

boolean checkWinner() {
  if (playerHand.size() == 1 && playerHand.get(0).isJoker) {
    gameOver = true;
    playerWin = false;
    gameMessage = "鬼牌在你手里……你输了！再玩一局吧。";
    return true;
  }
  if (hatterHand.size() == 1 && hatterHand.get(0).isJoker) {
    gameOver = true;
    playerWin = true;
    gameMessage = "鬼牌在疯帽子手里！你赢了！他送了你一块怀表。";
    return true;
  }
  return false;
}


// ============================================================
// ★★★ 在这里粘贴下面的 drawCardGame() ★★★
// ============================================================

void drawCardGame() {
  background(20, 15, 30);
  
   // ★★★ 规则提示 ★★★
  if (showRule) {
    fill(0, 0, 0, 220);
    rect(width/2 - 300, height/2 - 180, 600, 360, 20);
    
    fill(255, 0, 0);
    textSize(28);
    textAlign(CENTER, TOP);
    text("抽鬼牌规则", width/2, height/2 - 150);
    
    fill(255);
    textSize(18);
    textAlign(LEFT, TOP);
    String[] rules = {
      "1. 牌堆中有8对牌 + 1张鬼牌",
      "2. 轮到你时，点击疯帽子面前的牌背抽牌",
      "3. 抽到配对（两张相同花色）会自动消除",
      "4. 最终谁手里剩下鬼牌，谁就输",
      "",
      "疯帽子不在乎输赢，他只想让你感到快乐。"
    };
    float ruleX = width/2 - 260;
    float ruleY = height/2 - 100;
    for (int i = 0; i < rules.length; i++) {
      fill(i == rules.length - 1 ? color(255, 182, 193) : color(255));
      text(rules[i], ruleX, ruleY + i * 30);
    }
    
    fill(255, 182, 193);
    textSize(20);
    textAlign(CENTER, BOTTOM);
    text("点击开始游戏", width/2, height/2 + 170);
    textAlign(LEFT, TOP);
    return;  // ★★★ 显示规则时跳过游戏绘制 ★★★
  }
  // 背景
  if (teaPartyBg != null) {
    tint(255, 60);
    image(teaPartyBg, 0, 0, width, height);
    noTint();
  }
  
  // 标题
  fill(255);
  textSize(32);
  textAlign(CENTER, TOP);
  text("抽鬼牌", width/2, 38);
  textAlign(LEFT, TOP);
  
  // 疯帽子立绘居中
  float hatterSize = 550;
  float hatterX = width/2 - hatterSize/2;
  float hatterY = height/3.2 - hatterSize/3;
  if (hatterSmile != null) {
   float hatterRatio = (float)hatterSmile.height / hatterSmile.width;
image(hatterSmile, hatterX, hatterY, hatterSize, hatterSize * hatterRatio);
  
  // 疯帽子手牌（牌背）
  float cardW = 100, cardH = 143;
  int showCount = min(hatterHand.size(), 5);
  float hatterCardStartX = width/2 - (showCount * (cardW + 20)) / 2;
 float hatterCardY = height * 0.60;   // 屏幕高度的55%位置
  for (int i = 0; i < showCount; i++) {
    float x = hatterCardStartX + i * (cardW + 15);
    float y = hatterCardY;
    if (cardBack != null) {
      image(cardBack, x, y, cardW, cardH);
    } else {
      fill(80, 40, 120);
      rect(x, y, cardW, cardH, 5);
      fill(255);
      textSize(16);
      textAlign(CENTER, CENTER);
      text("?", x + cardW/2, y + cardH/2);
      textAlign(LEFT, TOP);
    }
  }
  
  // 疯帽子牌数
  fill(255);
  textSize(18);
  textAlign(CENTER, TOP);
  text("疯帽子的牌: " + hatterHand.size() + " 张", width/2 + 470, hatterCardY + cardH + 5);
  textAlign(LEFT, TOP);
  
  // 玩家手牌（底部）
  fill(255);
  textSize(18);
  textAlign(CENTER, BOTTOM);
  text("你的牌: " + playerHand.size() + " 张", width/2 - 470, height - 150);
  textAlign(LEFT, TOP);
  float pCardW = 100, pCardH = 143;
  int playerShow = min(playerHand.size(), 7);
  float startX = (width - playerShow * (pCardW + 15)) / 2;
  float playerY = height - 200;
  for (int i = 0; i < playerShow; i++) {
    Card card = playerHand.get(i);
    float x = startX + i * (pCardW + 10);
    float y = playerY;
    PImage img = card.getImage();
    if (img != null) {
      image(img, x, y, pCardW, pCardH);
    } else {
      fill(200, 200, 200);
      rect(x, y, pCardW, pCardH, 5);
      fill(0);
      textAlign(CENTER, CENTER);
      text(card.suit, x + pCardW/2, y + pCardH/2);
      textAlign(LEFT, TOP);
    }
  }
  
  // ★★★ 配对成功提示 ★★★
if (pairMessage.length() > 0 && millis() - pairMessageTimer < 1500) {
  fill( 255, 182, 193);
  textSize(28);
  textAlign(CENTER, CENTER);
  text(pairMessage, width/2 - 300, height/2 - 140);
  textAlign(LEFT, TOP);
}
  // 消息显示
  if (gameMessage.length() > 0) {
    fill(0, 0, 0, 200);
    rect(width/2 - 250, height/2 - 80, 500, 100, 20);
    fill(255);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(gameMessage, width/2, height/2 - 30);
    textAlign(LEFT, TOP);
  }
  
  // 操作提示
  if (!gameOver) {
    if (isPlayerTurn) {
      fill(255, 255, 200);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text("点击疯帽子面前的牌背抽取", width/2 + 400, height - 20);
      textAlign(LEFT, TOP);
    } else {
      fill(200, 200, 255);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text("疯帽子正在思考……", width/2 + 400, height - 300);
      textAlign(LEFT, TOP);
    }
  } else {
    fill(255, 255, 200);
    textSize(18);
    textAlign(CENTER, BOTTOM);
    text("点击继续", width/2, height - 20);
    textAlign(LEFT, TOP);
  }
}
}
// ============================================================
// ★★★ drawCardGame() 结束，下面是 handleCardClick() ★★★
// ============================================================

void handleCardClick() {
  if (gameOver || !isPlayerTurn || waitingForClick) return;
  if (hatterHand.size() == 0) return;
  
  // ★★★ 和 drawCardGame 中的坐标完全一致 ★★★
  float cardW = 100, cardH = 143;
  float hatterSize = 400;
  float hatterX = width/2 - hatterSize/2;
  float hatterY = height/4 - hatterSize/3;
  float hatterCardY = height * 0.60;   // 屏幕高度的55%位置
  int showCount = min(hatterHand.size(), 5);
  float hatterCardStartX = width/2 - (showCount * (cardW + 15)) / 2;
  
  for (int i = 0; i < showCount; i++) {
    float x = hatterCardStartX + i * (cardW + 15);
    float y = hatterCardY;
    if (mouseX > x && mouseX < x + cardW && mouseY > y && mouseY < y + cardH) {
      drawCardFromHatter(i);
      return;
    }
  }
}

void drawCardFromHatter(int index) {
  Card drawn = hatterHand.remove(index);
  playerHand.add(drawn);
  waitingForClick = true;
  
  // 检查配对
  removePairs(playerHand);
  
  // 检查胜负
  if (checkWinner()) {
    return;
  }
  
  // 轮到疯帽子
  isPlayerTurn = false;
  waitingForClick = false;
  hatterThinkTimer = millis();
  isHatterThinking = true;
}

void hatterTurn() {
  if (!isHatterThinking) return;
  
  if (millis() - hatterThinkTimer > 1500) {
    isHatterThinking = false;
    
    if (playerHand.size() > 0) {
      int randomIndex = (int)random(playerHand.size());
      Card drawn = playerHand.remove(randomIndex);
      hatterHand.add(drawn);
      
      // 疯帽子偶尔给提示
      if (random(1) > 0.5) {
        String[] hints = {
          "（疯帽子眯着眼睛）你左边那张……看起来不太一样。",
          "（疯帽子笑了笑）我建议你不要抽中间那张。",
          "（疯帽子歪着头）你信我吗？——但我可能会骗你。",
          "（疯帽子低声说）那张牌……我好像在哪见过。",
          "（疯帽子摇摇头）算了，你自己选吧。"
        };
        gameMessage = hints[(int)random(hints.length)];
        messageTimer = millis();
      }
      
      removePairs(hatterHand);
      
      if (checkWinner()) {
        return;
      }
      
      // 回到玩家回合
      isPlayerTurn = true;
    } else {
      // 玩家没牌了（理论上不可能）
      gameOver = true;
      playerWin = true;
      gameMessage = "你赢了！疯帽子手里只剩鬼牌了！";
    }
  }
}
void startChapter3EndDialog() {
  currentChapter = 3;
   isFarewellDialog = true;   // ★★★ 标记为告别对话 ★★★
  forestBg = teaPartyBg;   // 使用茶话会背景
  
  String[] speakers = {
    "hatter_smile", "alice", "hatter_smile", "alice", "hatter_silent"
  };
  
  String[] lines = {
    "（疯帽子收起牌，安静地看了你一会儿）……你要走了，对吗？",
    "嗯。是时候了。",
    "（他低头笑了笑，把一块怀表放在桌上）拿着吧。不是让你看时间……是让你记得回来。",
    "……谢谢。",
    "（他转过身，背对着你，声音很轻）我们还会再见面的，爱丽丝。"
  };
  
  String[] portraits = {
    "hatter_smile", "alice_normal", "hatter_silent", "alice_normal", "hatter_silent"
  };
  
  startDialog(speakers, lines, portraits, 8);  // 结束后进入 gameState = 8（第三章结束）
}
void drawChapter3End() {
  background(0);
  fill(255);
  textSize(48);
  textAlign(CENTER, CENTER);
  text("第三章 完", width/2, height/2 - 40);
  textSize(24);
  text("疯帽子茶话会 · 终", width/2, height/2 + 30);
  textSize(18);
  fill(200, 200, 255);
  text("点击继续", width/2, height/2 + 100);
  textAlign(LEFT, TOP);
}
void startChapter4Dialog() {
  switchBGM(bgmChapter4);  
  currentChapter = 4;
  forestBg = queenBg;   // 红皇后背景（你生成的那张）
  
  String[] speakers = {
    "alice", "alice", "alice", "alice",
    "queen", "alice", "queen", "alice", "queen"
  };
  
  String[] lines = {
    "（爱丽丝走在通往红心城堡的路上，脚步越来越慢）",
    "……奇怪。这条路我好像走过很多次。",
    "不是错觉。每一块石头，每一棵枯树……我都记得。",
    "但我从来没有来过这里。",
    "（城堡大门缓缓打开，一个高挑的身影坐在王座上）你终于来了。我等了很久。",
    "你是谁？",
    "我是你一直逃避的那一部分。你不敢承认的愤怒……和力量。",
    "……你是红皇后。",
    "聪明。现在——你准备好面对我了吗？"
  };
  
  String[] portraits = {
    "alice_normal", "alice_normal", "alice_normal", "alice_normal",
    "queen_normal", "alice_cold", "queen_normal", "alice_normal", "queen_grin"
  };
  
  startDialog(speakers, lines, portraits, 9);  // 结束后进入 gameState = 9（红皇后战斗）
  // 在第四章对话结束后调用

}

void drawQueenBattle() {

  // 背景
 // ★★★ 使用战斗专用背景 ★★★
  if (queenBattleBg != null) {
    image(queenBattleBg, 0, 0, width, height);
  } else {
    background(20, 10, 30);  // 备用纯色
  }
  
  // ★★★ 红皇后立绘（居中，放大）★★★
  float queenSize = height * 0.9;
  float queenX = width/2 - queenSize/2;
  float queenY = height/2 - queenSize/2 - 30;
  
  // 根据面具是否碎裂显示不同立绘
  PImage currentQueen = maskBroken ? queenFace : queenNormal;
  if (currentQueen != null) {
    float ratio = (float)currentQueen.width / currentQueen.height;
    float drawW = queenSize;
    float drawH = drawW / ratio;
    if (drawH > queenSize * 1.2) {
      drawH = queenSize * 1.2;
      drawW = drawH * ratio;
    }
    float offsetX = (queenSize - drawW) / 2;
    float offsetY = (queenSize - drawH) / 2;
    image(currentQueen, queenX + offsetX, queenY + offsetY, drawW, drawH);
  }


  // ★★★ 箭头提示（在红皇后周围随机位置）★★★
  if (arrowActive && !maskBroken) {
    drawArrow();
  }
 // ★★★ 如果面具碎裂，显示露脸立绘 + 对话（点击前一直显示）★★★
if (maskBroken && maskBreakTriggered && !maskDialogClicked) {
  drawMaskBreakDialog();
}
  
  // ★★★ 战斗UI ★★★
  drawQueenUI();
  
  // ★★★ 结果对话框 ★★★
  if (queenBattleResult) {
    drawQueenResult();
      // ★★★ 闪屏效果（放在最前面）★★★
  if (flashTimer > 0 && millis() - flashTimer < 900) {
    fill(flashColor);
    rect(0, 0, width, height);
  }
  if (flashTimer > 0 && millis() - flashTimer < 900) {
  fill(flashColor);
  rect(0, 0, width, height);
}
  }
}

void drawMaskBreakDialog() {
  fill(0, 0, 0, 200);
  rect(width/2 - 350, height/2 + 180, 700, 160, 20);
  
  fill(255, 200, 200);
  textSize(22);
  textAlign(CENTER, CENTER);
  text("（面具碎裂，露出的脸和爱丽丝一模一样）", width/2, height/2 + 210);
  textSize(18);
  fill(255, 255, 200);
  text("爱丽丝：……为什么……你的脸……和我一样？", width/2, height/2 + 255);
  
  fill(255, 255, 255, 150);
  textSize(16);
  text("点击继续", width/2, height/2 + 305);
  textAlign(LEFT, TOP);
}
void drawArrow() {
  float arrowX = width/2 + random(-200, 200);
  float arrowY = height/2 + random(-150, 150);
  float arrowSize = 60;
  
  // 发光效果
  for (int i = 0; i < 3; i++) {
    float alpha = 60 - i * 15;
    fill(255, 50, 50, alpha);
    noStroke();
    drawArrowShape(arrowX, arrowY, arrowSize + i * 20, arrowDirection);
  }
  
  // 主箭头
  fill(255, 0, 0, 220);
  noStroke();
  drawArrowShape(arrowX, arrowY, arrowSize, arrowDirection);
  
  // 提示文字
  fill(255, 255, 255, 180);
  textSize(16);
  textAlign(CENTER, TOP);
  text("按方向键 ↑ ↓ ← →", width/2, height - 60);
  textAlign(LEFT, TOP);
}

void drawArrowShape(float x, float y, float size, int dir) {
  pushMatrix();
  translate(x, y);
  
  // ★★★ 用 switch 明确每个方向 ★★★
  switch(dir) {
    case 0: break;  // 上（不旋转）
    case 1: rotate(PI); break;  // 下
    case 2: rotate(-PI/2); break;  // 左
    case 3: rotate(PI/2); break;  // 右
  }
  
  beginShape();
  vertex(0, -size);
  vertex(-size/2, 0);
  vertex(-size/4, 0);
  vertex(-size/4, size/2);
  vertex(size/4, size/2);
  vertex(size/4, 0);
  vertex(size/2, 0);
  endShape(CLOSE);
  popMatrix();
}
void drawQueenUI() {
  // 命中进度（红心）
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("命中: ", 30, 30);
  for (int i = 0; i < maxQueenHits; i++) {
    fill(i < queenHits ? color(255, 50, 50) : color(80, 80, 80));
    textSize(28);
    text("❤", 100 + i * 35, 28);
  }
  
  // 失败计数
  textAlign(RIGHT, TOP);
  textSize(20);
  fill(200, 200, 200);
  text("失误: " + queenMisses + "/" + maxQueenMisses, width - 30, 30);
  
  // 面具状态
  textAlign(CENTER, TOP);
  textSize(16);
  if (maskBroken) {
    fill(255, 200, 100);
    text(" 面具已碎裂 ", width/2, 30);
  } else {
    fill(200, 200, 255);
    text("⚔ 攻击红皇后，击碎她的面具！", width/2, 30);
  }
  
  textAlign(LEFT, TOP);
}
void spawnArrow() {
  if (!queenBattleActive || queenBattleResult) return;
  arrowDirection = (int)random(0, 4);
  arrowActive = true;
  arrowTimer = millis();
  println("生成箭头: " + arrowDirection + " (0上1下2左3右)");
}

void updateQueenBattle() {
  if (!queenBattleActive || queenBattleResult) return;
  
  // 箭头超时判定
  if (arrowActive && millis() - arrowTimer > arrowDuration) {
    arrowActive = false;
    // 超时算失误
    //queenMisses++;
    println("⏰ 超时！失误 +1");
    flashColor = color(255, 0, 0, 100);
    flashTimer = millis();
    
    if (queenMisses >= maxQueenMisses) {
      queenBattleActive = false;
      queenBattleLose = true;
      queenBattleResult = true;
      queenBattleStep = 0;
    } else {
      spawnArrow();
    }
  }
}
void drawQueenResult() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(40, 30, 60);
  rect(width/4, height/2 - 130, width/2, 260, 20);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(30);
  
  if (queenBattleWin) {
    text(" 你打败了红皇后！", width/2, height/2 - 30);
    textSize(20);
    text("你终于面对了自己内心最愤怒的部分。", width/2, height/2 + 40);
  } else {
    text("你被红皇后击倒了……", width/2, height/2 - 30);
    textSize(20);
    text("（爱丽丝跪倒在地，仙境开始模糊）", width/2, height/2 + 40);
  }
  
  fill(255, 255, 255, 150);
  textSize(18);
  text("点击继续...", width/2, height/2 + 120);
  textAlign(LEFT, TOP);
}
void startQueenBattle() {
  switchBGM(bgmBattle);    
  queenHits = 0;
  queenMisses = 0;
  queenBattleActive = true;
  queenBattleWin = false;
  queenBattleLose = false;
  queenBattleResult = false;
  arrowActive = false;
  maskBroken = false;
  maskBreakTriggered = false;
  flashTimer = 0;
  gameState = 9;
  
  spawnArrow();  // 立即生成第一个箭头
}
void startChapter4EndDialog() {
  currentChapter = 4;
  forestBg = queenBg;
  
  String[] speakers = {
    "queen", "alice", "queen", "alice", "queen",
    "alice", "queen", "alice"
  };
  
  String[] lines = {
    "（红皇后看着她，脸上第一次露出嘲讽的表情）你看到了。我就是你。",
    "……什么意思？",
    "我是你内心所有愤怒、不甘、无法释怀的东西。你每一次受的伤，每一次咽下去的话……都变成了我。",
    "……所以我不是在打败你。我是在打败自己。",
    "（她笑了，声音变轻）你终于明白了。……但是，这里不欢迎明白的人。",
    "……什么？",
    "（红皇后的声音忽然变得遥远，城堡开始震动）你该走了，爱丽丝。趁我还能控制这里。",
    "（周围的一切开始扭曲，地面裂开）……等等！我怎么出去？"
  };
  
  String[] portraits = {
    "queen_normal", "alice_normal", "queen_normal", "alice_normal", "queen_grin",
    "alice_normal", "queen_normal", "alice_cold"
  };

  startDialog(speakers, lines, portraits, 12);
}// 结束后进入迷宫小游戏
 void startMazeGame() {
  maze = new int[mazeSize][mazeSize];
  soldiers = new ArrayList<int[]>();
  
  generateMaze();
  
  playerCol = 0;
  playerRow = 0;
  exitCol = mazeSize - 1;
  exitRow = mazeSize - 1;
  
  // ★★★ 5个士兵 ★★★
  for (int i = 0; i < 5; i++) {
    int col = (int)random(2, mazeSize - 2);
    int row = (int)random(2, mazeSize - 2);
    if (maze[row][col] != 0 && !(col == playerCol && row == playerRow) && !(col == exitCol && row == exitRow)) {
      soldiers.add(new int[]{col, row});
    } else {
      i--;
    }
  }
  
  mazeLives = 3;
  mazeActive = true;
  mazeWin = false;
  mazeLose = false;
  mazeResult = false;
  mazeStep = 0;
  cellSize = min(width, height) / mazeSize;
  
  gameState = 12;
  println("迷宫游戏开始！士兵数量: " + soldiers.size());
}
void generateMaze() {
  // ★★★ 初始化所有格子为墙 ★★★
  for (int i = 0; i < mazeSize; i++) {
    for (int j = 0; j < mazeSize; j++) {
      maze[i][j] = 0;
    }
  }
  
  // ★★★ 递归回溯生成迷宫 ★★★
  int startCol = 1;
  int startRow = 1;
  maze[startRow][startCol] = 1;
  
  ArrayList<int[]> stack = new ArrayList<int[]>();
  stack.add(new int[]{startCol, startRow});
  
  while (stack.size() > 0) {
    int[] current = stack.get(stack.size() - 1);
    int col = current[0];
    int row = current[1];
    
    // 获取所有未访问的邻居（隔一个格子）
    ArrayList<int[]> neighbors = new ArrayList<int[]>();
    int[][] dirs = {{0, -2}, {0, 2}, {-2, 0}, {2, 0}};
    for (int[] d : dirs) {
      int nc = col + d[0];
      int nr = row + d[1];
      if (nc > 0 && nc < mazeSize-1 && nr > 0 && nr < mazeSize-1 && maze[nr][nc] == 0) {
        neighbors.add(new int[]{nc, nr});
      }
    }
    
    if (neighbors.size() > 0) {
      // 随机选一个邻居
      int[] next = neighbors.get((int)random(neighbors.size()));
      // 打通中间的墙
      int wallCol = (col + next[0]) / 2;
      int wallRow = (row + next[1]) / 2;
      maze[wallRow][wallCol] = 1;
      maze[next[1]][next[0]] = 1;
      stack.add(new int[]{next[0], next[1]});
    } else {
      stack.remove(stack.size() - 1);
    }
  }
  
  // ★★★ 强制打通入口和出口（防止被墙堵死）★★★
  maze[0][1] = 1;    // 入口上方
  maze[1][0] = 1;    // 入口左方
   maze[mazeSize-1][mazeSize-1] = 1;      // 出口格子本身
 
  // 如果终点位置是墙，强制打通
  if (maze[mazeSize-1][mazeSize-2] == 0) {
    maze[mazeSize-1][mazeSize-2] = 1;
    maze[mazeSize-2][mazeSize-1] = 1;
  }
  // 确保终点连通
  if (maze[mazeSize-2][mazeSize-1] == 0) {
    maze[mazeSize-2][mazeSize-1] = 1;
  }
}
void drawMazeGame() {
  background(20, 10, 30);
  
  // 绘制迷宫
  float offsetX = (width - mazeSize * cellSize) / 2;
  float offsetY = (height - mazeSize * cellSize) / 2;
  
  // 迷宫格子
  for (int row = 0; row < mazeSize; row++) {
    for (int col = 0; col < mazeSize; col++) {
      float x = offsetX + col * cellSize;
      float y = offsetY + row * cellSize;
      
      if (maze[row][col] == 1) {
        fill(30, 25, 45);
      } else {
        fill(10, 5, 20);
      }
      rect(x, y, cellSize, cellSize);
      
      // 格子边框
      stroke(50, 40, 70);
      strokeWeight(1);
      noFill();
      rect(x, y, cellSize, cellSize);
      noStroke();
    }
  }
  
  // 出口标记
  float exitX = offsetX + exitCol * cellSize;
  float exitY = offsetY + exitRow * cellSize;
  fill(255, 215, 0, 150);
  rect(exitX, exitY, cellSize, cellSize);
  fill(255, 215, 0);
  textSize(cellSize * 0.4);
  textAlign(CENTER, CENTER);
  text("🚪", exitX + cellSize/2, exitY + cellSize/2);
  textAlign(LEFT, TOP);
  
  // 绘制纸牌士兵
  for (int[] pos : soldiers) {
    float x = offsetX + pos[0] * cellSize;
    float y = offsetY + pos[1] * cellSize;
    fill(200, 50, 50, 200);
    rect(x + 5, y + 5, cellSize - 10, cellSize - 10, 5);
    fill(255, 200, 200);
    textSize(cellSize * 0.4);
    textAlign(CENTER, CENTER);
    text("♠", x + cellSize/2, y + cellSize/2);
    textAlign(LEFT, TOP);
  }
  
  // 绘制玩家
  float playerX = offsetX + playerCol * cellSize;
  float playerY = offsetY + playerRow * cellSize;
  fill(100, 200, 255, 220);
  ellipse(playerX + cellSize/2, playerY + cellSize/2, cellSize * 0.7, cellSize * 0.7);
  fill(255);
  textSize(cellSize * 0.35);
  textAlign(CENTER, CENTER);
  text("👤", playerX + cellSize/2, playerY + cellSize/2);
  textAlign(LEFT, TOP);
  
  // UI
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("❤️ x " + mazeLives, 20, 20);
  text("找到出口 🚪 逃离红皇后城堡", width/2 - 150, 20);
  textAlign(LEFT, TOP);
  
  // 操作提示
  fill(255, 255, 255, 150);
  textSize(16);
  textAlign(CENTER, BOTTOM);
  text("方向键移动 · 避开纸牌士兵 · 到达出口逃离", width/2, height - 20);
  textAlign(LEFT, TOP);
}
void updateMazeGame() {
  if (!mazeActive || mazeResult) return;
  
  // 每60帧移动一次士兵
  soldierMoveTimer++;
  if (soldierMoveTimer >= soldierMoveInterval) {
    soldierMoveTimer = 0;
    
    for (int[] pos : soldiers) {
      // 随机向上下左右移动一步
      int dir = (int)random(4);
      int newCol = pos[0];
      int newRow = pos[1];
      
      if (dir == 0) newCol++;
      else if (dir == 1) newCol--;
      else if (dir == 2) newRow++;
      else if (dir == 3) newRow--;
      
      if (newCol >= 0 && newCol < mazeSize && newRow >= 0 && newRow < mazeSize) {
        if (maze[newRow][newCol] == 1) {
          pos[0] = newCol;
          pos[1] = newRow;
        }
      }
    }
  }
}
void drawMazeResult() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(40, 30, 60);
  rect(width/4, height/2 - 100, width/2, 200, 20);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(30);
  
  if (mazeWin) {
    text("🎉 你逃出了红皇后城堡！", width/2, height/2 - 20);
    textSize(20);
    text("爱丽丝跑出城堡大门，阳光照在她脸上……", width/2, height/2 + 50);
  } else {
    text("💀 你被纸牌士兵抓住了……", width/2, height/2 - 20);
    textSize(20);
    text("（爱丽丝被押回王座前，红皇后在等她）", width/2, height/2 + 50);
  }
  
  fill(255, 255, 255, 150);
  textSize(18);
  text("点击继续", width/2, height/2 + 130);
  textAlign(LEFT, TOP);
}
void drawEnding() {
  background(0);
  fill(255);
  textSize(48);
  textAlign(CENTER, CENTER);
  text("第四章 完", width/2, height/2 - 40);
  textSize(24);
  text("红皇后的回响 · 终", width/2, height/2 + 30);
  textSize(18);
  fill(200, 200, 255);
  text("点击继续查看结局", width/2, height/2 + 100);
  textAlign(LEFT, TOP);
}
// ========== 切换背景音乐 ==========
void switchBGM(AudioPlayer newBGM) {
  // 停止所有音乐
  if (bgm != null && bgm.isPlaying()) bgm.pause();
  if (bgmChapter1 != null && bgmChapter1.isPlaying()) bgmChapter1.pause();
  if (bgmChapter2 != null && bgmChapter2.isPlaying()) bgmChapter2.pause();
  if (bgmChapter3 != null && bgmChapter3.isPlaying()) bgmChapter3.pause();
  if (bgmChapter4 != null && bgmChapter4.isPlaying()) bgmChapter4.pause();
  if (bgmBattle != null && bgmBattle.isPlaying()) bgmBattle.pause();
  
  if (newBGM != null) {
    newBGM.rewind();
    newBGM.loop();
  }
}
