/*
  Evolving L System
  ----------
  This program randomly makes mutations for the rule sets of multiple L-Systems and displays all the L-Systems of the current generation.
  
  written by Adrian Margel, Winter late 2018
*/
//Rule class dermines how to modify the structural string
class Rule{
  //the string it is looking to replace
  String find;
  //the string it will use as replacement
  String replacement;
  public Rule(String f,String r){
    find=f;
    replacement=r;
  }
  
  //generic mutation function to modify the rule
  public void mutate(){
    //these values are entirely guessed and may not be the most effective for evolution
    if((int)random(0,2)==0){
      if((int)random(0,2)==0){
        find=find+((int)random(0,7));
      }else{
        if(find.length()>1){
          int rand=(int)random(0,find.length());
          find=find.substring(0,rand)+find.substring(rand+1,find.length());
        }
      }
    }
    if((int)random(0,2)==0){
      if((int)random(0,2)==0){
        replacement=replacement+((int)random(0,7));
      }else{
        if(replacement.length()>0){
          int rand=(int)random(0,replacement.length());
          replacement=replacement.substring(0,rand)+replacement.substring(rand+1,replacement.length());
        }
      }
    }
  }
  //modify a string with the rule
  public String apply(String source){
    String s=source.replaceAll(find, replacement);
    return s;
  }
}

//Tester class allows for the structure to grow and mutate
class Tester{
  //the structural data
  String base;
  //the base before it was last modified
  String last;
  //the rules it will use to modify itself with
  ArrayList<Rule> rules;
  //has it grown to the maximum allowable size?
  boolean done;
  public Tester(){
    rules=new ArrayList<Rule>();
  }
  //generic clone method
  public void clone(Tester t){
    done=false;
    rules=new ArrayList<Rule>();
    base="1";
    for(Rule r:t.rules){
      rules.add(new Rule(r.find,r.replacement));
    }
  }
  //generic mutate method
  public void mutate(int amount){
    for(int i=0;i<amount;i++){
      if((int)random(0,2)==0){
        if((int)random(0,2)==0){
          addRandom();
        }else{
          removeRandom();
        }
        rules.get((int)random(0,rules.size())).mutate();
      }
    }
  }
  //grows the structure via modifying the base string representing it.
  public void run(){
    last=base;
    //if it hasn't hit the max size then apply the rules to grow it
    if(!done){
      for(int i=0;i<rules.size();i++){
        base=rules.get(i).apply(base);
        //if it is too big reset to what it was before
        if(base.length()>5000){
          base=last;
          done=true;
          break;
        }
      }
    }
  }
  //adds a random new rule
  public void addRandom(){
    String f="";
    String r="";
    
    int fn=(int)random(1,5);
    for(int i=0;i<fn;i++){
      f=f+((int)random(0,7));
    }
    
    int rn=(int)random(1,5);
    for(int i=0;i<rn;i++){
      r=r+((int)random(0,7));
    }
    
    rules.add(new Rule(f,r));
  }
  //removes a random rule
  public void removeRandom(){
    if(rules.size()>1){
      rules.remove((int)random(0,rules.size()));
    }
  }
  //resets the base string to the seed of 1 and randomly assigns new rules
  public void reset(){
    done=false;
    rules=new ArrayList<Rule>();
    base="1";
    int n=(int)random(10);
    for(int i=0;i<n;i++){
      addRandom();
    }
  }
  //resets the base string to the seed of 1
  public void softReset(){
    done=false;
    base="1";
  }
}

//Ant class allows for the displaying and testing of strings created by the Tester class
class Ant{
  //angle
  float a;
  //current x,y
  float x;
  float y;
  //used for scoring
  float fd;
  //stored data the ant has chosen to remember
  ArrayList<Float> storedA;
  ArrayList<Float> storedX;
  ArrayList<Float> storedY;
  //all visited tiles for use with the simple test method
  HashMap<String,Boolean> visited;
  public Ant(){
    visited=new HashMap<String,Boolean>();
    storedA=new ArrayList<Float>();
    storedX=new ArrayList<Float>();
    storedY=new ArrayList<Float>();
  }
  //this displays the stucture in the same way it is tested
  public void display(String source,int px,int py,float z){
    boolean d=true;
    x=px;
    y=py;
    for(int i=0;i<min(source.length(),5000);i++){
      float l=z;
      char c=source.charAt(i);
      float lx=x;
      float ly=y;
      d=true;
      if(c=='0'){
        x+=l;
      }else if(c=='1'){
        x-=l;
      }else if(c=='2'){
        y+=l;
      }else if(c=='3'){
        y-=l;
      }else{
        d=false;
        if(c=='4'){
          store();
        }else if(c=='5'){
          jump();
        }else if(c=='6'){
          unstore();
        }
      }
      
      if(d){
        line(lx,ly,x,y);
      }
    }
  }
  //this displays the structure in a pretty way
  public void display2(String source,int px,int py,float z){
    boolean d=true;
    a=0;
    x=px;
    y=py;
    for(int i=0;i<min(source.length(),5000);i++){
      float l=z;
      char c=source.charAt(i);
      float lx=x;
      float ly=y;
      d=true;
      if(c=='0'){
        a+=PI/20;
      }else if(c=='1'){
        a-=PI/20;
      }else if(c=='2'){
        y+=sin(a)*l;
        x+=cos(a)*l;
      }else if(c=='3'){
        y-=sin(a)*l;
        x-=cos(a)*l;
      }else{
        d=false;
        if(c=='4'){
          store();
        }else if(c=='5'){
          jump();
        }else if(c=='6'){
          unstore();
        }
      }
      
      if(d){
        //y+=sin(a)*l;
        //x+=cos(a)*l;
        line(lx,ly,x,y);
      }
    }
  }
  //this tests and scores structures in a simple way to select for more "interesting" structures
  //basically this method tells the amount of area covered by a structure within an area
  public int test(String source){
    fd=0;
    int score=0;
    boolean d=true;
    x=0;
    y=0;
    for(int i=0;i<min(source.length(),5000);i++){
      char c=source.charAt(i);
      d=true;
      if(c=='0'){
        x+=1;
      }else if(c=='1'){
        x-=1;
      }else if(c=='2'){
        y+=1;
      }else if(c=='3'){
        y-=1;
      }else{
        d=false;
        if(c=='4'){
          store();
        }else if(c=='5'){
          jump();
        }else if(c=='6'){
          unstore();
        }
      }
      
      if(d){
        float tempD=sqrt(sq(x)+sq(y));
        if(tempD<400){
        String pos=x+","+y;
        if(!visited.containsKey(pos)){
          score++;
          visited.put(pos,true);
        }
        if(tempD>fd){
          fd=tempD;
        }
        }
      }
    }
    return score;
  }
  
  public void store(){
    storedA.add(a);
    storedX.add(x);
    storedY.add(y);
  }
  public void jump(){
    if(storedY.size()>0){
      a=storedA.get(storedA.size()-1);
      x=storedX.get(storedX.size()-1);
      y=storedY.get(storedY.size()-1);
    }
  }
  public void unstore(){
    if(storedY.size()>0){
      storedA.remove(storedA.size()-1);
      storedX.remove(storedX.size()-1);
      storedY.remove(storedY.size()-1);
    }
  }
}

//the structures
ArrayList<Tester> tests;
//the displayer
Ant disp;
//the time in the simulation
int time;
//the id of the top scored structure
int top=0;

void setup(){
  time=0;
  frameRate(300);
  size(800,800);
  tests=new ArrayList<Tester>();
  //make 100 structures to compete with each other
  for(int i=0;i<100;i++){
    tests.add(new Tester());
    tests.get(i).reset();
  }
  disp=new Ant();
  background(255);
  colorMode(HSB);
}
//int num=0;
void draw(){
  /*num++;
  if(num%5==0){
    save("suff"+num/5+".png");
  }*/
  time++;
  //background(255);
  if(time<50){
    //display and grow all structures until they hit the size limit
    noStroke();
    fill(255,50);
    //rect(0,0,width,height);
    background(255);
    for(int i=0;i<tests.size();i++){
      disp=new Ant();
      tests.get(i).run();
      //stroke(255*i/tests.size(),255,200);
      if(!tests.get(i).done){
        stroke(0);
        disp.display2(tests.get(i).base,400,400,5);
      }
      //println(i+": "+tests.get(i).base);
      
    }
  }else{
    float score=0;
    for(int i=0;i<tests.size();i++){
      //calculate score based on the furthest distance the structure reached vs the area it covers
      disp=new Ant();
      int covered=disp.test(tests.get(i).base);
      float dist=disp.fd;
      float tScore;
      if(dist!=0){
        tScore=(covered/dist);
      }else{
        tScore=0;
      }
      //tScore=covered;
      if(score<tScore){
        score=tScore;
        top=i;
      }
    }
    //reset or mutate all stuctures besides the best one 
    for(int i=0;i<tests.size();i++){
      if(i!=top){
        tests.get(i).softReset();
        if((int)random(0,1.1)==0){
          tests.get(i).clone(tests.get(top));
          tests.get(i).mutate(5);
        }else{
          tests.get(i).reset();
        }
      }else{
        tests.get(i).softReset();
      }
    }
    //reset simulation time
    time=0;
  }
  /*disp=new Ant();
  stroke(0,255,255);
  disp.display(tests.get(top).base,500,400,2);
  disp=new Ant();
  stroke(0);
  disp.display2(tests.get(top).base,300,400,2);*/
}
