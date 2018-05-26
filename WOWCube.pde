
final int FSP = 260; // FACE_SIZE_PIXELS
final int SSP = 240; // SCREEN_SIZE_PIXELS
final int CUBES = 8;
final int FPC = 3; // FACES_PER_CUBE

float camRotX = 0; // in degrees!
float camRotY = 0;

int timer = 0;

CCubeSet cs;
CDebugPanel dp;
CGamePipesLogic game_logic;

enum animType
{
  ANIM_X_CW,
  ANIM_X_CCW,
  ANIM_Y_CW,
  ANIM_Y_CCW,
  ANIM_Z_CW,
  ANIM_Z_CCW,
  ANIM_NONE
};

class CDisplay
{
  CFace pface; // backlink to parent Face
  public PGraphics g;

  private PFont fontForCubeID = createFont("Courier New Bold", 125);
  private PFont fontForFaceID = createFont("Courier New Bold", 75);
  private PFont fontForEdgeID = createFont("Courier New Bold", 28);
  private PFont fontForAxis = createFont("Courier New Bold", 32);

  private final int opacityCubeID = 150;
  private final int opacityAxis   = 150;
  private final int opacityEdgeID  = 200;

  CDisplay(CFace _pface)
  {
    pface = _pface;
    g = createGraphics(SSP, SSP, P2D);
  }
  
  void drawOverlay(boolean _drawCubeID, boolean _drawAxis, boolean _drawEdgeID) // draw overlay with cubeID, faceID, axis direction, etc. 
  {
    g.beginDraw();
      if(_drawCubeID)
      {
        g.textFont(fontForCubeID);
        g.textAlign(CENTER, CENTER);
        g.fill(255,0,0,opacityCubeID);
        g.text(""+pface.pcube.cubeN, 0, 0, SSP, SSP);
        g.textFont(fontForFaceID);
        g.fill(255,255,255,opacityCubeID);
        g.text(""+pface.faceN, 0, 0, parseInt((float)2/2*SSP), parseInt((float)1/2.5*SSP));
      }
      if(_drawAxis)
      {
        g.strokeWeight(5); // Face coordinates directions
        g.textFont(fontForAxis);
        g.stroke(255,0,0,opacityAxis);
        g.fill(255,0,0,opacityAxis);
        g.line(5,5,SSP-5,5);
        g.text("X",SSP-25,25);
        g.stroke(0,255,0,opacityAxis);
        g.fill(0,255,0,opacityAxis);
        g.line(5,5,5,SSP-5);
        g.text("Y",25,SSP-25);
      }
      if(_drawEdgeID)
      {
        g.textFont(fontForEdgeID);
        g.textAlign(CENTER, CENTER);
        
        switch(pface.faceN)
        {
          case 0:
            g.fill(255,0,0,opacityEdgeID);
            g.text("1",SSP/2,15);
            g.fill(0,255,0,opacityEdgeID);
            g.text("3",15,SSP/2);
          break;
          
          case 1:
            g.fill(255,0,0,opacityEdgeID);
            g.text("3",SSP/2,15);
            g.fill(0,255,0,opacityEdgeID);
            g.text("2",15,SSP/2);
          break;
          
          case 2:
            g.fill(255,0,0,opacityEdgeID);
            g.text("2",SSP/2,15);
            g.fill(0,255,0,opacityEdgeID);
            g.text("1",15,SSP/2);
          break;
        }
      }
    g.endDraw();
  }
}

class CFace
{
  public CCube pcube; // backlink to parent Cube
  public int faceN;
  
  CDisplay d;
  PShape sf; // cube's face
  PShape sd; // face's display
  
  CFace(CCube _pcube, int _faceN)
  {
    pcube = _pcube;
    faceN = _faceN;
    
    d = new CDisplay(this);
    
    sf = createShape();
    sf.beginShape(QUADS);
    sf.fill(50, 50, 50);
    sf.vertex(0, 0, 0);
    sf.vertex(FSP, 0, 0);
    sf.vertex(FSP, FSP, 0);
    sf.vertex(0, FSP, 0);
    sf.endShape();
    
    sd = createShape();
    sd.beginShape(QUADS);
    sd.texture(d.g);
    sd.vertex(0, 0, 0, 0, 0);
    sd.vertex(SSP, 0, 0, 1, 0);
    sd.vertex(SSP, SSP, 0, 1, 1);
    sd.vertex(0, SSP, 0, 0, 1);
    sd.endShape();
    sd.translate((FSP-SSP)/2, (FSP-SSP)/2, 1);
  }
  
  void draw()
  {
    shape(sf);
    shape(sd);
  }
  
  void drawOverlay(boolean _drawCubeID, boolean _drawAxis, boolean _drawEdgeID)
  {
    d.drawOverlay(_drawCubeID, _drawAxis, _drawEdgeID);
  }
  
  void translate(int x, int y, int z)
  {
    sf.translate(x,y,z);
    sd.translate(x,y,z);
  }
  
  void rotateX(int deg)
  {
    sf.rotateX(radians(deg));
    sd.rotateX(radians(deg));
  }
  
  void rotateY(int deg)
  {
    sf.rotateY(radians(deg));
    sd.rotateY(radians(deg));
  }
  
  void rotateZ(int deg)
  {
    sf.rotateZ(radians(deg));
    sd.rotateZ(radians(deg));
  }
}

class CCube
{
  public int cubeN;
  CFace[] f = new CFace[3];
  
  CCube(int _cubeN)
  {
    cubeN = _cubeN;
    f[0] = new CFace(this, 0);
    f[0].translate(-FSP/2,-FSP/2,FSP/2);
    f[0].rotateZ(180);
    f[1] = new CFace(this, 1);
    f[1].translate(-FSP/2,-FSP/2,0);
    f[1].rotateZ(90);
    f[1].rotateX(90);
    f[1].translate(0,-FSP/2,0);
    f[2] = new CFace(this, 2);
    f[2].translate(-FSP/2,-FSP/2,0);
    f[2].rotateZ(90);
    f[2].rotateY(-90);
    f[2].rotateX(-180);
    f[2].translate(-FSP/2,0,0);
  }
  
  void draw()
  {
    f[0].draw();
    f[1].draw();
    f[2].draw();
  }
  
  void drawOverlays(boolean _drawCubeID, boolean _drawAxis, boolean _drawEdgeID)
  {
    f[0].d.drawOverlay(_drawCubeID, _drawAxis, _drawEdgeID);
    f[1].d.drawOverlay(_drawCubeID, _drawAxis, _drawEdgeID);
    f[2].d.drawOverlay(_drawCubeID, _drawAxis, _drawEdgeID);
  }
  
  void translate(int x, int y, int z)
  {
    f[0].translate(x,y,z);
    f[1].translate(x,y,z);
    f[2].translate(x,y,z);
  }
  
  void rotateX(int deg)
  {
    f[0].rotateX(deg);
    f[1].rotateX(deg);
    f[2].rotateX(deg);
  }
  
  void rotateY(int deg)
  {
    f[0].rotateY(deg);
    f[1].rotateY(deg);
    f[2].rotateY(deg);
  }
  
  void rotateZ(int deg)
  {
    f[0].rotateZ(deg);
    f[1].rotateZ(deg);
    f[2].rotateZ(deg);
  }
}

class CCubeSet
{
  public CCube[] c;
  public animType anim = animType.ANIM_NONE;
  
  private int[] p = new int[]{0,1,2,3,4,5,6,7}; // initial positions
  
  public int[][][] pm = new int[][][] // "positions matrix" 8x6-24 "projection", each node in 2D matrix is {cubeID,faceID}
  {
    /////// ----- Y ------>
    /* | */ {{-1,-1}, {-1,-1}, { 6, 2}, { 5, 1}, {-1,-1}, {-1,-1}},
    /* | */ {{-1,-1}, {-1,-1}, { 3, 1}, { 0, 2}, {-1,-1}, {-1,-1}},
    /* | */ {{ 6, 1}, { 3, 2}, { 3, 0}, { 0, 0}, { 0, 1}, { 5, 2}},
    /* X */ {{ 7, 2}, { 2, 1}, { 2, 0}, { 1, 0}, { 1, 2}, { 4, 1}},
    /* | */ {{-1,-1}, {-1,-1}, { 2, 2}, { 1, 1}, {-1,-1}, {-1,-1}},
    /* | */ {{-1,-1}, {-1,-1}, { 7, 1}, { 4, 2}, {-1,-1}, {-1,-1}},
    /* | */ {{-1,-1}, {-1,-1}, { 7, 0}, { 4, 0}, {-1,-1}, {-1,-1}},
    /* V */ {{-1,-1}, {-1,-1}, { 6, 0}, { 5, 0}, {-1,-1}, {-1,-1}},
  };
  
  public final int pam[][] = // constant "planar angle matrix" 8x6-24, i.e. "how to rotate HW faces to get flat 2D field" ;-)
  {
    /////// ----- Y ------>
    /* | */ {0,     0,  90, 180,   0,   0},
    /* | */ {0,     0,   0, 270,   0,   0},
    /* | */ {90,  180,  90, 180,  90, 180},
    /* X */ {0,   270,   0, 270,   0, 270},
    /* | */ {0,     0,  90, 180,   0,   0},
    /* | */ {0,     0,   0, 270,   0,   0},
    /* | */ {0,     0,  90, 180,   0,   0},
    /* V */ {0,     0,   0, 270,   0,   0},
  };
  
  private int animAngle = 0;
  private int animSpeed = 10;
  
  CCubeSet()
  {
    c = new CCube[CUBES];
    
    for(int i=0; i<CUBES; i++)
    {
      c[i] = new CCube(i);
      
      switch(i)
      {
        case 0:
          c[i].translate(-FSP/2,-FSP/2,FSP/2);
          break;
          
        case 1:
          c[i].rotateZ(90);
          c[i].translate(FSP/2,-FSP/2,FSP/2);
          break;
          
        case 2:
          c[i].rotateZ(180);
          c[i].translate(FSP/2,FSP/2,FSP/2);
          break;
          
        case 3:
          c[i].rotateZ(270);
          c[i].translate(-FSP/2,FSP/2,FSP/2);
          break;

        case 4:
          c[i].translate(-FSP/2,-FSP/2,-FSP/2);
          break;
          
        case 5:
          c[i].rotateZ(90);
          c[i].translate(FSP/2,-FSP/2,-FSP/2);
          break;
          
        case 6:
          c[i].rotateZ(180);
          c[i].translate(FSP/2,FSP/2,-FSP/2);
          break;
          
        case 7:
          c[i].rotateZ(270);
          c[i].translate(-FSP/2,FSP/2,-FSP/2);
          break;
      }
    }
    
    c[4].rotateY(180);
    c[4].translate(0,0,-FSP);
    c[5].rotateY(180);
    c[5].translate(0,0,-FSP);
    c[6].rotateY(180);
    c[6].translate(0,0,-FSP);
    c[7].rotateY(180);
    c[7].translate(0,0,-FSP);
  }
  
  void draw()
  {
    switch(anim)
    {
      case ANIM_X_CW:
        animAngle += animSpeed;
        c[p[1]].rotateX(animSpeed);
        c[p[2]].rotateX(animSpeed);
        c[p[4]].rotateX(animSpeed);
        c[p[7]].rotateX(animSpeed);
        if(animAngle % 90 == 0) anim_X_CW_end();
      break;
      
      case ANIM_X_CCW:
        animAngle -= animSpeed;
        c[p[1]].rotateX(-animSpeed);
        c[p[2]].rotateX(-animSpeed);
        c[p[4]].rotateX(-animSpeed);
        c[p[7]].rotateX(-animSpeed);
        if(animAngle % 90 == 0) anim_X_CCW_end();
      break;
      
      case ANIM_Y_CW:
        animAngle += animSpeed;
        c[p[0]].rotateY(animSpeed);
        c[p[1]].rotateY(animSpeed);
        c[p[4]].rotateY(animSpeed);
        c[p[5]].rotateY(animSpeed);
        if(animAngle % 90 == 0) anim_Y_CW_end();
      break;
      
      case ANIM_Y_CCW:
        animAngle -= animSpeed;
        c[p[0]].rotateY(-animSpeed);
        c[p[1]].rotateY(-animSpeed);
        c[p[4]].rotateY(-animSpeed);
        c[p[5]].rotateY(-animSpeed);
        if(animAngle % 90 == 0) anim_Y_CCW_end();
      break;
      
      case ANIM_Z_CW:
        animAngle += animSpeed;
        c[p[0]].rotateZ(animSpeed);
        c[p[1]].rotateZ(animSpeed);
        c[p[2]].rotateZ(animSpeed);
        c[p[3]].rotateZ(animSpeed);
        if(animAngle % 90 == 0) anim_Z_CW_end();
      break;
      
      case ANIM_Z_CCW:
        animAngle -= animSpeed;
        c[p[0]].rotateZ(-animSpeed);
        c[p[1]].rotateZ(-animSpeed);
        c[p[2]].rotateZ(-animSpeed);
        c[p[3]].rotateZ(-animSpeed);
        if(animAngle % 90 == 0) anim_Z_CCW_end();
      break;
      
      case ANIM_NONE:
      default:
        animAngle = 0;
      break;
    }
    
    for(int i=0; i<CUBES; i++) c[i].draw();
  }

  void drawOverlays(boolean _drawCubeID, boolean _drawAxis, boolean _drawEdgeID, boolean _drawPMIndexes)
  {
    for(int i=0; i<CUBES; i++) c[i].drawOverlays(_drawCubeID, _drawAxis, _drawEdgeID);
    
    if(_drawPMIndexes)
    {
      for(int y=0; y<6; y++)
      {
        for(int x=0; x<8; x++)
        {
          int cubeID = pm[x][y][0];
          int faceID = pm[x][y][1];
          
          if(cubeID != -1)
          {
            PGraphics g = this.c[cubeID].f[faceID].d.g;
            // draw array indexes
            g.beginDraw();
              g.text("["+x+","+y+"]",50,20);
            g.endDraw();
          }
        }
      }
    }
  }
 
  void anim_X_CW_begin()  { anim = animType.ANIM_X_CW;  game_logic.onCsDetach(); } // w
  void anim_X_CCW_begin() { anim = animType.ANIM_X_CCW; game_logic.onCsDetach(); } // s
  void anim_Y_CW_begin()  { anim = animType.ANIM_Y_CW;  game_logic.onCsDetach(); } // q
  void anim_Y_CCW_begin() { anim = animType.ANIM_Y_CCW; game_logic.onCsDetach(); } // e
  void anim_Z_CW_begin()  { anim = animType.ANIM_Z_CW;  game_logic.onCsDetach(); } // d
  void anim_Z_CCW_begin() { anim = animType.ANIM_Z_CCW; game_logic.onCsDetach(); } // a
  
  private void anim_X_CW_end() // w
  {
    p = new int[]{p[0], p[2], p[7], p[3], p[1], p[5], p[6], p[4]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[0][3][0], pm[0][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[1][2][0], pm[1][2][1]}, {pm[1][3][0], pm[1][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[2][1][0], pm[2][1][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[2][3][0], pm[2][3][1]}, {pm[2][4][0], pm[2][4][1]}, {pm[2][5][0], pm[2][5][1]}},
      /* X */ {{pm[6][3][0], pm[6][3][1]}, {pm[6][2][0], pm[6][2][1]}, {pm[3][0][0], pm[3][0][1]}, {pm[3][1][0], pm[3][1][1]}, {pm[3][2][0], pm[3][2][1]}, {pm[3][3][0], pm[3][3][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][2][0], pm[5][2][1]}, {pm[4][2][0], pm[4][2][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][3][0], pm[5][3][1]}, {pm[4][3][0], pm[4][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[3][5][0], pm[3][5][1]}, {pm[3][4][0], pm[3][4][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void anim_X_CCW_end() // s
  {
    p = new int[]{p[0], p[4], p[1], p[3], p[7], p[5], p[6], p[2]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[0][3][0], pm[0][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[1][2][0], pm[1][2][1]}, {pm[1][3][0], pm[1][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[2][1][0], pm[2][1][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[2][3][0], pm[2][3][1]}, {pm[2][4][0], pm[2][4][1]}, {pm[2][5][0], pm[2][5][1]}},
      /* X */ {{pm[3][2][0], pm[3][2][1]}, {pm[3][3][0], pm[3][3][1]}, {pm[3][4][0], pm[3][4][1]}, {pm[3][5][0], pm[3][5][1]}, {pm[6][3][0], pm[6][3][1]}, {pm[6][2][0], pm[6][2][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[4][3][0], pm[4][3][1]}, {pm[5][3][0], pm[5][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[4][2][0], pm[4][2][1]}, {pm[5][2][0], pm[5][2][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[3][1][0], pm[3][1][1]}, {pm[3][0][0], pm[3][0][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void anim_Y_CW_end() // q
  {
    p = new int[]{p[5], p[0], p[2], p[3], p[1], p[4], p[6], p[7]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[6][3][0], pm[6][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[1][2][0], pm[1][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[2][1][0], pm[2][1][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[0][3][0], pm[0][3][1]}, {pm[2][5][0], pm[2][5][1]}, {pm[3][5][0], pm[3][5][1]}},
      /* X */ {{pm[3][0][0], pm[3][0][1]}, {pm[3][1][0], pm[3][1][1]}, {pm[3][2][0], pm[3][2][1]}, {pm[1][3][0], pm[1][3][1]}, {pm[2][4][0], pm[2][4][1]}, {pm[3][4][0], pm[3][4][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[4][2][0], pm[4][2][1]}, {pm[2][3][0], pm[2][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][2][0], pm[5][2][1]}, {pm[3][3][0], pm[3][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[6][2][0], pm[6][2][1]}, {pm[4][3][0], pm[4][3][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[5][3][0], pm[5][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void anim_Y_CCW_end() // e
  {
    p = new int[]{p[1], p[4], p[2], p[3], p[5], p[0], p[6], p[7]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[2][3][0], pm[2][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[1][2][0], pm[1][2][1]}, {pm[3][3][0], pm[3][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[2][1][0], pm[2][1][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[4][3][0], pm[4][3][1]}, {pm[3][4][0], pm[3][4][1]}, {pm[2][4][0], pm[2][4][1]}},
      /* X */ {{pm[3][0][0], pm[3][0][1]}, {pm[3][1][0], pm[3][1][1]}, {pm[3][2][0], pm[3][2][1]}, {pm[5][3][0], pm[5][3][1]}, {pm[3][5][0], pm[3][5][1]}, {pm[2][5][0], pm[2][5][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[4][2][0], pm[4][2][1]}, {pm[6][3][0], pm[6][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][2][0], pm[5][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[6][2][0], pm[6][2][1]}, {pm[0][3][0], pm[0][3][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[1][3][0], pm[1][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void anim_Z_CW_end() // d
  {
    p = new int[]{p[3], p[0], p[1], p[2], p[4], p[5], p[6], p[7]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[0][3][0], pm[0][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[3][1][0], pm[3][1][1]}, {pm[2][1][0], pm[2][1][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[4][2][0], pm[4][2][1]}, {pm[3][2][0], pm[3][2][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[1][2][0], pm[1][2][1]}, {pm[2][5][0], pm[2][5][1]}},
      /* X */ {{pm[3][0][0], pm[3][0][1]}, {pm[4][3][0], pm[4][3][1]}, {pm[3][3][0], pm[3][3][1]}, {pm[2][3][0], pm[2][3][1]}, {pm[1][3][0], pm[1][3][1]}, {pm[3][5][0], pm[3][5][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[3][4][0], pm[3][4][1]}, {pm[2][4][0], pm[2][4][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][2][0], pm[5][2][1]}, {pm[5][3][0], pm[5][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[6][2][0], pm[6][2][1]}, {pm[6][3][0], pm[6][3][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void anim_Z_CCW_end() // a
  {
    p = new int[]{p[1], p[2], p[3], p[0], p[4], p[5], p[6], p[7]};
    pm = new int[][][]
    {
      /////// ----- Y ------>
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[0][2][0], pm[0][2][1]}, {pm[0][3][0], pm[0][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[2][4][0], pm[2][4][1]}, {pm[3][4][0], pm[3][4][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{pm[2][0][0], pm[2][0][1]}, {pm[1][3][0], pm[1][3][1]}, {pm[2][3][0], pm[2][3][1]}, {pm[3][3][0], pm[3][3][1]}, {pm[4][3][0], pm[4][3][1]}, {pm[2][5][0], pm[2][5][1]}},
      /* X */ {{pm[3][0][0], pm[3][0][1]}, {pm[1][2][0], pm[1][2][1]}, {pm[2][2][0], pm[2][2][1]}, {pm[3][2][0], pm[3][2][1]}, {pm[4][2][0], pm[4][2][1]}, {pm[3][5][0], pm[3][5][1]}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[2][1][0], pm[2][1][1]}, {pm[3][1][0], pm[3][1][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[5][2][0], pm[5][2][1]}, {pm[5][3][0], pm[5][3][1]},                    {-1,-1},                    {-1,-1}},
      /* | */ {{-1,-1},                                       {-1,-1}, {pm[6][2][0], pm[6][2][1]}, {pm[6][3][0], pm[6][3][1]},                    {-1,-1},                    {-1,-1}},
      /* V */ {{-1,-1},                                       {-1,-1}, {pm[7][2][0], pm[7][2][1]}, {pm[7][3][0], pm[7][3][1]},                    {-1,-1},                    {-1,-1}},
    };
    onAnyAnimEnd();
  }
  
  private void onAnyAnimEnd()
  {
    anim = animType.ANIM_NONE;
    game_logic.onCsAttach();
    //printPositionMatrix();
  }
  
  public void printPositionMatrix()
  {
    for(int y=5; y>=0; y--)
    {
      for(int x=0; x<8; x++)
      {
        if(pm[x][y][0] == -1) print("      ");
        else print("["+pm[x][y][0]+","+pm[x][y][1]+"] ");
      }
      print("\n");
    }
    print("\n");
  }
}

class CDebugPanel
{
  final float scale = 0.25; // scale of model
  final int X = 8;
  final int Y = 6;
  PShape s[] = new PShape[X*Y];
  
  CDebugPanel()
  {
    for(int y=0; y<Y; y++)
    {
      for(int x=0; x<X; x++)
      {
        if(cs.pm[x][y][0] != -1)
        {
          s[y*8+x] = createShape();
          s[y*8+x].translate(-(SSP*scale)/2, -(SSP*scale)/2, 0);
          s[y*8+x].rotateZ(radians(cs.pam[x][y]));
          s[y*8+x].translate(x*(SSP*scale)+(SSP*scale)/2, (SSP*scale)*5-y*(SSP*scale)+(SSP*scale)/2, 0);
          s[y*8+x].beginShape(QUADS);
          //s[y*8+x].tint(255,127); // opacity!
          s[y*8+x].texture(cs.c[cs.pm[x][y][0]].f[cs.pm[x][y][1]].d.g);
          s[y*8+x].vertex(0, 0, 0, 0, 0);
          s[y*8+x].vertex(SSP*scale, 0, 0, 1, 0);
          s[y*8+x].vertex(SSP*scale, SSP*scale, 0, 1, 1);
          s[y*8+x].vertex(0, SSP*scale, 0, 0, 1);
          s[y*8+x].endShape();
        }
      }
    }
  }
  
  void draw()
  {
    for(int y=0; y<Y; y++)
    {
      for(int x=0; x<X; x++)
      {
        if(cs.pm[x][y][0] != -1)
        {
          s[y*8+x].setTexture(cs.c[cs.pm[x][y][0]].f[cs.pm[x][y][1]].d.g);
          shape(s[y*8+x]); // draw!
        }
      }
    }
  }
}

class CGamePipesLogic
{
  private boolean _drawGameFieldNumbers = false;
  
  private PFont fontForWinText = createFont("Courier New Bold", 60);
  
  final int PIPES_BASE=0;
  final int STEAM_BASE=16;
  final int PIPES_COUNT=16;
  final int STEAM_COUNT=9;

  private int steam_frame=0; // see tick()
  private int solved_angle=0; // see tick()
  
  PImage res[] = new PImage[PIPES_COUNT+STEAM_COUNT]; // resources
  
  private String levelData[][] = new String[6][8];
  private int gf[/*cubeID*/][/*faceID*/] = new int[CUBES][FPC]; // Game Field
  
  CGamePipesLogic()
  {
    // Load resources
    for(int i=PIPES_BASE; i<PIPES_COUNT; i++) res[i] = loadImage("pipes/"+binary(i,4)+".png");
    for(int i=STEAM_BASE; i<(STEAM_BASE+STEAM_COUNT); i++) res[i] = loadImage("steam/"+(i-STEAM_BASE+1)+".png");
    
    // Load level data
    loadLevel("level.txt");
    
    // Fill game field (which figure will bound to which cube's face)
    for(int x=0; x<8; x++)
    {
      for(int y=0; y<6; y++)
      {
        int cubeID = cs.pm[x][y][0];
        int faceID = cs.pm[x][y][1];
        if((cubeID != -1) && (faceID != -1))
        {
          gf[cubeID][faceID] = rotateFigureBitwise(unbinary(levelData[5-y][x]), cs.pam[x][y]);
        }
      }
    }
  }
  
  void loadLevel(String filename)
  {
    String row[] = loadStrings(filename);
    for(int x=0; x<row.length; x++)
    {
      String col[] = row[x].split(",");
      for(int y=0; y<col.length; y++)
      {
        levelData[x][y]=col[y]; 
      }
    }
  }
  
  void onCsDetach() // cubeset detached (rotate anim started) 
  {
    steam_frame = 5; // play 5-8, then nothing until attached
  }
  
  void onCsAttach() // cubeset attached (rotate anim ends)
  {
    steam_frame = 0; // play 0-5, then play 3-5 in a cycle
  }
  
  void tick() // on timer
  {
    steam_frame++;
    if(steam_frame==5) steam_frame=3; // cycle if attached
    
    solved_angle++;
    if(solved_angle>=360) solved_angle=0; // for "SOLVED" when win
  }
  
  void draw()
  {
    for(int x=0; x<8; x++)
    {
      for(int y=0; y<6; y++)
      {
        int cubeID = cs.pm[x][y][0];
        int faceID = cs.pm[x][y][1];
        
        if(cubeID != -1)
        {
          int resID = gf[cubeID][faceID];
          PGraphics g = cs.c[cubeID].f[faceID].d.g;
          g.beginDraw();
            g.image(res[resID],0,0);
          g.endDraw();
        }
      }
    }
    
    for(int x=0; x<8; x++)
    {
      for(int y=0; y<6; y++)
      {
        drawConnectorsLogic(x,y);
      }
    }

    boolean steamDrawn = false;

    for(int x=0; x<8; x++)
    {
      for(int y=0; y<6; y++)
      {
        if(steamDrawn == false)
        {
          steamDrawn = drawSteamLogic(x,y); // check if at least 1 steam drawn
        }
        else
        {
          drawSteamLogic(x,y); // at least 1 steam is drawn previously - level not solved yet...
        }
      }
    }
    
    if(steamDrawn == false)
    {
      // !!! WIN !!!
      for(int x=0; x<8; x++)
      {
        for(int y=0; y<6; y++)
        {
          int cubeID = cs.pm[x][y][0];
          int faceID = cs.pm[x][y][1];
          
          if(cubeID != -1)
          {
            PGraphics g = cs.c[cubeID].f[faceID].d.g;
            g.beginDraw();
              g.pushMatrix();
                g.rectMode(CENTER);
                g.translate(SSP/2,SSP/2);
                g.rotate(radians(solved_angle));
                g.textFont(fontForWinText);
                g.textAlign(CENTER, CENTER);
                g.fill(255,255,255,50);
                g.text("SOLVED",0,0);
                g.rectMode(CORNER);
              g.popMatrix();
            g.endDraw();
          }
        }
      }
    }
    
    if(_drawGameFieldNumbers)
    {
      for(int x=0; x<8; x++)
      {
        for(int y=0; y<6; y++)
        {
          int cubeID = cs.pm[x][y][0];
          int faceID = cs.pm[x][y][1];
          
          if(cubeID != -1)
          {
            int figure = rotateFigureBitwise(gf[cubeID][faceID], -cs.pam[x][y]);
            
            int meTop = ((figure >> 3) & 0x1);
            int meRight = ((figure >> 2) & 0x1);
            int meBottom = ((figure >> 1) & 0x1);
            int meLeft = ((figure >> 0) & 0x1);
            
            PGraphics g = cs.c[cubeID].f[faceID].d.g;
            // draw array indexes
            g.beginDraw();
              g.text("["+meTop+","+meRight+","+meBottom+","+meLeft+"]",100,100);
            g.endDraw();
          }
        }
      }
    }
    
    // DEBUG - draw red dot
    PGraphics g;
    g = cs.c[cs.pm[2][2][0]].f[cs.pm[2][2][1]].d.g;
    g.beginDraw();
      g.fill(255,0,0);
      g.ellipse(0,0,50,50);
    g.endDraw();
    g = cs.c[cs.pm[2][3][0]].f[cs.pm[2][3][1]].d.g;
    g.beginDraw();
      g.fill(255,0,0);
      g.ellipse(0,0,50,50);
    g.endDraw();
    g = cs.c[cs.pm[3][3][0]].f[cs.pm[3][3][1]].d.g;
    g.beginDraw();
      g.fill(255,0,0);
      g.ellipse(0,0,50,50);
    g.endDraw();
    g = cs.c[cs.pm[3][2][0]].f[cs.pm[3][2][1]].d.g;
    g.beginDraw();
      g.fill(255,0,0);
      g.ellipse(0,0,50,50);
    g.endDraw();
    // END DEBUG
  }
  
  void drawConnectorsLogic(int x, int y)
  {
    // check boundaries conditions
    if(isFace(x, y))
    {
      if((x==0 || !isFace(x-1,y)) && isLeft(x,y)) drawConnector(x,y,unbinary("0001"));
      if((y==0 || !isFace(x,y-1)) && isBottom(x,y)) drawConnector(x,y,unbinary("0010"));
    }
    
    if(isFace(x, y) && isFace(x+1, y)) // planar lookup right
    {
      if(isRight(x,y) && isLeft(x+1,y))
      {
        drawConnector(x,y,unbinary("0100"));
        drawConnector(x+1,y,unbinary("0001"));
      }
    }
    else if(isFace(x, y))
    {
      if(isRight(x,y)) drawConnector(x,y,unbinary("0100"));
    }
    
    if(isFace(x, y) && isFace(x, y+1)) // planar lookup top
    {
      if(isTop(x,y) && isBottom(x,y+1))
      {
        drawConnector(x,y,unbinary("1000"));
        drawConnector(x,y+1,unbinary("0010"));
      }
    }
    else if(isFace(x, y))
    {
      if(isTop(x,y)) drawConnector(x,y,unbinary("1000")); 
    }
  }
  
  void drawConnector(int x, int y, int _resID)
  {
    int resID = rotateFigureBitwise(_resID, cs.pam[x][y]);
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    PGraphics g = cs.c[cubeID].f[faceID].d.g;
    
    g.beginDraw();
      switch(resID)
      {
        case 8: g.image(res[resID], SSP/2-res[resID].width/2, 0); break; // top 1000
        case 4: g.image(res[resID], SSP-res[resID].width, SSP/2-res[resID].height/2); break; // right 0100
        case 2: g.image(res[resID], SSP/2-res[resID].width/2, SSP-res[resID].height); break; // bootom 0010
        case 1: g.image(res[resID], 0, SSP/2-res[resID].height/2); break; // left 0001
      }
    g.endDraw();
  }
  
  boolean drawSteamLogic(int x, int y)
  {
    boolean steamDrawn = false;
    
    if(isFace(x,y) && isFace(x,y+1)) // planar lookup top
    {
      if(isTop(x,y) && !isBottom(x,y+1))
      {
        drawSteam(x,y+1,unbinary("0010"));
        steamDrawn = true;
      }
    }
    
    if(isFace(x,y) && isFace(x+1,y)) // planar lookup right
    {
      if(isRight(x,y) && !isLeft(x+1,y))
      {
        drawSteam(x+1,y,unbinary("0001"));
        steamDrawn = true;
      }
    }
    
    if(isFace(x,y) && isFace(x,y-1)) // planar lookup bottom
    {
      if(isBottom(x,y) && !isTop(x,y-1))
      {
        drawSteam(x,y-1,unbinary("1000"));
        steamDrawn = true;
      }
    }
    
    if(isFace(x,y) && isFace(x-1,y)) // planar lookup left
    {
      if(isLeft(x,y) && !isRight(x-1,y))
      {
        drawSteam(x-1,y,unbinary("0100"));
        steamDrawn = true;
      }
    }
    
    return steamDrawn;
  }
  
  void drawSteam(int x, int y, int _pos)
  {
    if(steam_frame < 0 || steam_frame > 8) return;
    int resID = STEAM_BASE+steam_frame;
    int pos = rotateFigureBitwise(_pos, cs.pam[x][y]);
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    PGraphics g = cs.c[cubeID].f[faceID].d.g;
   
    g.beginDraw();
      switch(pos)
      {
        case 8:
          g.pushMatrix();
            g.imageMode(CENTER);
              g.translate(SSP/2, SSP/2-res[resID].height/2);
              g.rotate(PI);
              g.blendMode(LIGHTEST);
                g.image(res[resID],0,0);
              g.blendMode(BLEND);
            g.imageMode(CORNER);
          g.popMatrix();
        break; // top 1000
        
        case 4:
          g.pushMatrix();
            g.imageMode(CENTER);
              g.translate(SSP/2-res[resID].width/2, SSP/2);
              g.rotate(-PI/2);
              g.blendMode(LIGHTEST);
                g.image(res[resID],0,0);
              g.blendMode(BLEND);
            g.imageMode(CORNER);
          g.popMatrix();
        break; // right 0100
        
        case 2:
          g.pushMatrix();
            g.imageMode(CENTER);
              g.translate(SSP/2, SSP/2-res[resID].height/2);
              //g.rotate(0);
              g.blendMode(LIGHTEST);
                g.image(res[resID],0,0);
              g.blendMode(BLEND);
            g.imageMode(CORNER);
          g.popMatrix();
        break; // bottom 0010
        
        case 1:
          g.pushMatrix();
            g.imageMode(CENTER);
              g.translate(SSP/2-res[resID].width/2, SSP/2);
              g.rotate(PI/2);
              g.blendMode(LIGHTEST);
                g.image(res[resID],0,0);
              g.blendMode(BLEND);
            g.imageMode(CORNER);
          g.popMatrix();
        break; // left 0001
      }
    g.endDraw();
  }
  
  // used for face rotation compensation
  int rotateFigureBitwise(int figure, int angle)
  {
    int r = figure;
    
    switch(angle)
    {
      case  -90: r = ((figure >> 1) & 0x7) | ((figure << 3) & 0x8); break; // 90
      case -180: r = ((figure >> 2) & 0x3) | ((figure << 2) & 0xC); break; // 180
      case -270: r = ((figure >> 3) & 0x1) | ((figure << 1) & 0xE); break; // 270
      case   90: r = ((figure << 1) & 0xE) | ((figure >> 3) & 0x1); break; // -90
      case  180: r = ((figure << 2) & 0xC) | ((figure >> 2) & 0x3); break; // -180
      case  270: r = ((figure << 3) & 0x8) | ((figure >> 1) & 0x7); break; // -270
    }
    
    return r;
  }
  
  boolean isFace(int x, int y)
  {
    try
    {
      int cubeID = cs.pm[x][y][0];
      int faceID = cs.pm[x][y][1];
      if((cubeID == -1) || (faceID == -1)) return false;
      return true;
    }
    catch(Exception e)
    {
      return false;
    }
  }
  
  boolean isTop(int x, int y)
  {
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    int figure = rotateFigureBitwise(gf[cubeID][faceID], -cs.pam[x][y]);
    return boolean((figure >> 3) & 0x1);
  }
  
  boolean isRight(int x, int y)
  {
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    int figure = rotateFigureBitwise(gf[cubeID][faceID], -cs.pam[x][y]);
    return boolean((figure >> 2) & 0x1);
  }

  boolean isBottom(int x, int y)
  {
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    int figure = rotateFigureBitwise(gf[cubeID][faceID], -cs.pam[x][y]);
    return boolean((figure >> 1) & 0x1);
  }

  boolean isLeft(int x, int y)
  {
    int cubeID = cs.pm[x][y][0];
    int faceID = cs.pm[x][y][1];
    int figure = rotateFigureBitwise(gf[cubeID][faceID], -cs.pam[x][y]);
    return boolean((figure >> 0) & 0x1);
  }
}

void setup()
{
  size(700, 700, P3D); // can use only numbers, not constants here :(
  textureMode(NORMAL);
  cs = new CCubeSet();
  //cs.printPositionMatrix();
  dp = new CDebugPanel();
  game_logic = new CGamePipesLogic();
}

void draw()
{
  background(230);
  noStroke();
  
  if(millis() - timer >= 100)
  {
    game_logic.tick();
    timer = millis();
  }
  
  game_logic.draw();
  cs.drawOverlays(false, false, false, false);
  
  pushMatrix();
    translate(2.2*FSP, 2.2*FSP, -3.0*FSP);
    rotateX(radians(camRotX));
    rotateY(radians(camRotY));
    cs.draw();
  popMatrix();
  
  dp.draw();
}

void mouseDragged()
{
  float rate = 0.1;
  camRotX += (pmouseY-mouseY) * rate;
  camRotY += (mouseX-pmouseX) * rate;
}

void keyPressed()
{
  if(cs.anim == animType.ANIM_NONE)
  {
    if(key == 'w') { cs.anim_X_CW_begin(); }
    if(key == 's') { cs.anim_X_CCW_begin(); }
    if(key == 'q') { cs.anim_Y_CW_begin(); }
    if(key == 'e') { cs.anim_Y_CCW_begin(); }
    if(key == 'd') { cs.anim_Z_CW_begin(); }
    if(key == 'a') { cs.anim_Z_CCW_begin(); }
  }
}