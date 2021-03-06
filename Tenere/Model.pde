import heronarts.lx.model.*;
import java.util.Collections;
import java.util.List;


Tree buildTree() {
  return new Tree(Tree.ModelMode.MAJOR_LIMBS);
  // return new Tree(Tree.ModelMode.UNIFORM_BRANCHES);
}

public static class Tree extends LXModel {
  
  public enum ModelMode {
    UNIFORM_BRANCHES,
    MAJOR_LIMBS
  }
  
  public static final float TRUNK_DIAMETER = 3*FEET;
  public static final float LIMB_HEIGHT = 10*FEET;
  public static final int NUM_LIMBS = 12;
  
  public final List<Limb> limbs;
  public final List<Branch> branches;
  public final List<LeafAssemblage> assemblages;
  public final List<Leaf> leaves;
  
  public Tree(ModelMode mode) {
    super(new Fixture(mode));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
    this.limbs = Collections.unmodifiableList(f.limbs);
    
    // Collect up all the leaves for top-level reference
    final List<Leaf> leaves = new ArrayList<Leaf>();
    final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>();
    for (Branch branch : this.branches) {
      for (LeafAssemblage assemblage : branch.assemblages) {
        assemblages.add(assemblage);
        for (Leaf leaf : assemblage.leaves) {
          leaves.add(leaf);
        }
      }
    }
    this.assemblages = Collections.unmodifiableList(assemblages);
    this.leaves = Collections.unmodifiableList(leaves);
  }

  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    private final List<Limb> limbs = new ArrayList<Limb>();
    
    Fixture(ModelMode mode) {
      if (mode == ModelMode.UNIFORM_BRANCHES) {
        for (int ai = 0; ai < 14; ++ai) {
          for (int ei = 0; ei < 14; ++ ei) {
            float azimuth = (ai + (ei % 2) * .5) * TWO_PI / 13;
            float elevation = ei * HALF_PI / 13;
            float radius = 12*FEET;
            float x = radius * cos(azimuth) * cos(elevation);
            float z = radius * sin(azimuth) * cos(elevation);
            float y = radius * sin(elevation);
            addBranch(new Branch.Orientation(x, y, z, azimuth, elevation, TWO_PI * (float) Math.random()));
          }
        }
      } else {
        // Lowest layer of major limbs
        addLimb(0.0*FT, 0.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.0*FT, 1.2 * TWO_PI/6, Limb.Size.FULL);
        addLimb(3.0*FT, 1.9 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.7*FT, 2.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.2*FT, 2.9 * TWO_PI/6, Limb.Size.FULL);
        addLimb(0.8*FT, 4.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(2.4*FT, 4.9 * TWO_PI/6, Limb.Size.FULL);
        
        // Medium layer of limbs
        addLimb(6.0*FT, 0.4 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(5.4*FT, 1.5 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(4.2*FT, 2.9 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(5.9*FT, 4.1 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(6.3*FT, 5.3 * TWO_PI/6, Limb.Size.MEDIUM);
        
        // A couple small top limbs
        addLimb(7*FT, .3 * TWO_PI/6, Limb.Size.SMALL);
        addLimb(7*FT, 3.1 * TWO_PI/6, Limb.Size.SMALL);
        
      }
    }
    
    private void addLimb(float y, float azimuth, Limb.Size size) {
      Limb limb = new Limb(y, azimuth, size);
      this.limbs.add(limb);
      addPoints(limb);
      for (Branch branch : limb.branches) {
        this.branches.add(branch);
      }
    }
    
    private void addBranch(Branch.Orientation orientation) {
      Branch branch = new Branch(orientation);
      this.branches.add(branch);
      addPoints(branch);
    }
  }
}

public static class Limb extends LXModel {
  public enum Size {
    FULL,
    MEDIUM,
    SMALL
  };
  
  public static class Section {
    public final float radius;
    public final float len;
    public final float bend;
    
    public Section(float radius, float len, float bend) {
      this.radius = radius;
      this.len = len;
      this.bend = bend;
    }
  }
  
  public final static Section SECTION_1 = new Section(4.6875*IN, 4*FT, 0);
  public final static Section SECTION_2 = new Section(3.75*IN, 4*FT, 0);
  public final static Section SECTION_3 = new Section(3.75*IN, 4*FT, PI/6);
  public final static Section SECTION_4 = new Section(3.75*IN, 8*FT, PI/6);
  
  public final List<Branch> branches;
  
  public final float y;
  public final float azimuth;
  public final Size size;
  
  private static final float Y_BASE = -Tree.LIMB_HEIGHT + 5*FT; 
  
  public Limb(float y, float azimuth, Size size) {
    super(new Fixture(y + Y_BASE, azimuth, size));
    this.y = y + Y_BASE;
    this.azimuth = azimuth;
    this.size = size;
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    
    Fixture(float y, float azimuth, Size size) {
      LXTransform t = new LXTransform();
      t.translate(0, y, 0);
      t.rotateY(HALF_PI - azimuth);
      t.rotateX(HALF_PI - PI/12);
      if (size == Size.FULL) {
        t.translate(0, SECTION_1.len, 0);
      }
      if (size != Size.SMALL) {
        t.translate(0, SECTION_2.len, 0);
      }
      t.rotateX(-PI/6);
      t.translate(0, SECTION_3.len);
      t.rotateX(-PI/6);
      
      // Branch S.2 (3)
      t.push();
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth, -PI/8);
      t.pop();
      
      t.translate(0, SECTION_4.len);
      
      // Double-branch S.2 (12)      
      // First part (left)
      t.push();
      t.rotateY(-PI/3);
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth + PI/3, -PI/6);
      t.pop();
      
      // Second part (right)
      t.push();
      t.rotateY(PI/3);
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth - PI/3, PI/8);
      t.pop();
    }
    
    private void addBranchCluster(LXTransform t, float azimuth, float baseElevation) {
      // Loose interpretation of Branch S.2 (3)
      t.translate(0, 2*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, -PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, -PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
    }
    
    private void addBranch(LXTransform t, float azimuth, float offset, float baseElevation) {
      t.push();
      t.rotateZ(-offset);
      t.translate(0, 1*FT, 0);
      Branch branch = new Branch(new Branch.Orientation(
        t.x(),
        t.y(),
        t.z(),
        azimuth + offset,
        baseElevation + HALF_PI * (float) Math.random(),
        TWO_PI * (float) Math.random()
      ));
      addPoints(branch);
      this.branches.add(branch);
      t.pop();
    }
  }
}

/**
 * A branch is mounted on a major limb and houses many
 * leaf assemblages. This class is oriented in the x-y
 * plane with the branch pointing "upwards" in the y-axis.
 *
 * Leaf assemblages shoot off the left and right sides
 * as well as one out the top.
 */
public static class Branch extends LXModel {
  public static final int NUM_ASSEMBLAGES = 8;
  public static final float LENGTH = 6*FEET;
  public static final float WIDTH = 7*FEET;
  
  public static class Orientation {
    
    // Base of the branch, in global space
    public final float x;
    public final float y;
    public final float z;
    
    // Azimuth and elevation of branch's normal vector (the direction it points)
    public final float azimuth;
    public final float elevation;
    
    // Tilt of the branch about its normal (think of the branch doing a "barrel roll") 
    public final float tilt;
    
    public Orientation(float x, float y, float z, float azimuth, float elevation, float tilt) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.azimuth = azimuth;
      this.elevation = elevation;
      this.tilt = tilt;
    }
  }
  
  // Orientation of this branch
  public final Orientation orientation;
    
  public final List<LeafAssemblage> assemblages;
  
  // Position of the branch in global space
  public final float x;
  public final float y;
  public final float z;
  
  // Azimuth and elevation of the branch in global space
  public final float azimuth;
  public final float elevation;
   
  private static final float RIGHT_THETA = -QUARTER_PI;
  private static final float LEFT_THETA = QUARTER_PI;
  
  private static final float RIGHT_OFFSET = 12*IN;
  private static final float LEFT_OFFSET = -12*IN;
  
  // Assemblage positions are relative to an assemblage
  // facing upwards. Each leaf assemblage 
  public static final LeafAssemblage.Orientation[] ASSEMBLAGES = {
    // Right side bottom to top
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 2*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 14*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 26*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 38*IN, RIGHT_THETA),
    
    // End node
    new LeafAssemblage.Orientation(0, 44*IN, 0),
    
    // Left side top to bottom
    new LeafAssemblage.Orientation(LEFT_OFFSET, 32*IN, LEFT_THETA),
    new LeafAssemblage.Orientation(LEFT_OFFSET, 20*IN, LEFT_THETA),
    new LeafAssemblage.Orientation(LEFT_OFFSET, 8*IN, LEFT_THETA)
  };
      
  public Branch(Orientation orientation) {
    super(new Fixture(orientation));
    this.orientation = orientation;
    this.x = orientation.x;
    this.y = orientation.y;
    this.z = orientation.z;
    this.azimuth = atan2(orientation.z, orientation.x);
    this.elevation = atan2(orientation.y, dist(0, 0, orientation.x, orientation.z));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.assemblages = Collections.unmodifiableList(f.assemblages);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>();
    
    Fixture(Orientation orientation) {
      LXTransform t = new LXTransform();
      t.translate(orientation.x, orientation.y, orientation.z);
      t.rotateY(HALF_PI - orientation.azimuth);
      t.rotateX(HALF_PI - orientation.elevation);
      t.rotateY(orientation.tilt);      

      for (LeafAssemblage.Orientation assemblage : ASSEMBLAGES) {
        t.push();
        t.translate(assemblage.x, assemblage.y, 0);
        t.rotateZ(assemblage.theta);
        t.rotateY(assemblage.tilt);
        LeafAssemblage leafAssemblage = new LeafAssemblage(t, assemblage);
        this.assemblages.add(leafAssemblage);
        addPoints(leafAssemblage);
        t.pop();
      }
    }
  }
}

/**
 * An assemblage is a modular fixture with multiple leaves.
 */
public static class LeafAssemblage extends LXModel {
  
  public static final int NUM_LEAVES = 15;
  
  public static final float LENGTH = 28*IN;
  public static final float WIDTH = 28*IN;

  // Orientation of a leaf assemblage, relative to parent branch
  public static class Orientation {
    
    // Offset from base of branch, y-axis points "up" the branch
    public final float x;
    public final float y;
    
    // Rotation in the x-y plane, relative to the branch
    // wwhere y is pointing "up" the branch 
    public final float theta;
    
    // Tilt of the leaf assemblage about the axis of its normal
    // e.g. a "barrel roll" on the leaf assemblage
    public final float tilt;
    
    Orientation(float x, float y, float theta) {
      this.x = x;
      this.y = y;
      this.theta = theta;
      this.tilt = -QUARTER_PI + HALF_PI * (float) Math.random();
    }
  }

  // These positions indicate how a leaf is positioned on an assemblage,
  // assuming the assemblage is facing "up", the main stem is at (0, 0)
  // Positive x-values move to the right, and positive y-values move
  // up the branch, away from the base stem.
  //
  // Third argument is the rotation of the leaf on the x-y plane, 0
  // is the leaf pointing "up", HALF_PI is pointing to the left,
  // -HALF_PI is pointing to the right, etc.
  public static final Leaf.Orientation[] LEAVES = {    
    new Leaf.Orientation(0,  6.4*IN,  8.8*IN, -HALF_PI - QUARTER_PI), // A
    new Leaf.Orientation(1,  6.9*IN, 10.0*IN, -HALF_PI), // B
    new Leaf.Orientation(2, 10.4*IN, 14.7*IN, -HALF_PI - .318), // C
    new Leaf.Orientation(3, 10.0*IN, 16.1*IN, -.900), // D
    new Leaf.Orientation(4,  1.2*IN, 13.9*IN, -1.08), // E
    new Leaf.Orientation(5,  3.5*IN, 22.2*IN, -HALF_PI - .2), // F
    new Leaf.Orientation(6,  2.9*IN, 23.3*IN, -.828), // G
    new Leaf.Orientation(7,  0.0*IN, 23.9*IN, 0), // H
    null, // I
    null, // J
    null, // K
    null, // L
    null, // M
    null, // N
    null, // O
  };
  
  static {
    // Make sure we didn't bork that array editing manually!
    assert(LEAVES.length == NUM_LEAVES);
    
    // The last seven leaves are just inverse of the first about
    // the y-axis.
    for (int i = 0; i < 7; ++i) {
      Leaf.Orientation thisLeaf = LEAVES[i];
      int index = LEAVES.length - 1 - i; 
      LEAVES[index] = new Leaf.Orientation(index, -thisLeaf.x, thisLeaf.y, -thisLeaf.theta);
    }
  }
  
  public final Orientation orientation;
  public final List<Leaf> leaves;
  
  public LeafAssemblage(LXTransform t, Orientation orientation) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.leaves = Collections.unmodifiableList(f.leaves);
    this.orientation = orientation;
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Leaf> leaves = new ArrayList<Leaf>();
    
    Fixture(LXTransform t) {
      for (int i = 0; i < NUM_LEAVES; ++i) {
        Leaf.Orientation leafOrientation = LEAVES[i];
        t.push();
        t.translate(leafOrientation.x, leafOrientation.y, 0);
        t.rotateZ(leafOrientation.theta);
        Leaf leaf = new Leaf(t, leafOrientation);
        this.leaves.add(leaf);
        addPoints(leaf);
        t.pop();
      } 
    }
  }
}

/**
 * The base addressable fixture, a Leaf with LEDs embedded inside.
 * Currently modeled as a single point. Room for improvement!
 */
public static class Leaf extends LXModel {
  public static final int NUM_LEDS = 7;
  public static final float WIDTH = 5*IN; 
  public static final float LENGTH = 6.5*IN;
  
  // Orientation of a leaf relative to leaf assemblage
  public static class Orientation {
    
    public final int index;
    
    // X-Y position relative to leaf assemblage base
    // y-axis pointing "up" the leaf assemblage 
    public final float x;
    public final float y;
    
    // Rotation about X-Y plane relative to parent assemblage
    public final float theta;
    
    // Tilt of the individual leaf
    public final float tilt;
    
    Orientation(int index, float x, float y, float theta) {
      this.index = index;
      this.x = x;
      this.y = y;
      this.theta = theta;
      this.tilt = -QUARTER_PI + HALF_PI * (float) Math.random();
    }
  }
  
  public final LXPoint point;
  
  public final float x;
  public final float y;
  public final float z;
  
  public final LXVector[] coords = new LXVector[4];
  
  public final Orientation orientation;
  
  public Leaf() {
    this(new LXTransform());
  }
  
  public Leaf(LXTransform t) {
    this(t, new Orientation(0, 0, 0, 0));
  }
  
  public Leaf(LXTransform t, Orientation orientation) {
    super(new Fixture(t));
    this.orientation = orientation;
    this.x = t.x();
    this.y = t.y();
    this.z = t.z();
    this.point = this.points[0];
    
    // Precompute boundary coordinates for faster rendering, these
    // can be dumped into a VBO for a shader.
    t.push();
    t.translate(-WIDTH/2, 0);
    this.coords[0] = t.vector();
    t.translate(0, LENGTH);
    this.coords[1] = t.vector();
    t.translate(WIDTH, 0);
    this.coords[2] = t.vector();
    t.translate(0, -LENGTH);
    this.coords[3] = t.vector();
    t.pop();
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(LXTransform t) {
      // TODO: do we model multiple LEDs here or not? This
      // simulation only renders textures at leaf granularity.
      // Possibly add "shimmer" modes and effects for leaves
      // downstream?
      addPoint(new LXPoint(t));
    }
  }
}

// Cheap mockup of a tree canopy until we get a better model
// based upon actual mechanical drawings and fabricated dimensions.
// This one just estimates a cloud of points distributed across
// a hemisphere. Left here for reference.
public static class Hemisphere extends LXModel {
  
  public static final float NUM_POINTS = 25000;
  public static final float INNER_RADIUS = 33*FEET;
  public static final float OUTER_RADIUS = 36*FEET;
  
  public Hemisphere() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int i = 0; i < NUM_POINTS; ++i) {
        float azimuth = (98752234*i + 4871433);
        float elevation = (i*234.351234) % HALF_PI;
        float radius = INNER_RADIUS + (i * 7*INCHES) % (OUTER_RADIUS - INNER_RADIUS);
        double x = radius * Math.cos(azimuth) * Math.cos(elevation);
        double z = radius * Math.sin(azimuth) * Math.cos(elevation);
        double y = radius * Math.sin(elevation);
        addPoint(new LXPoint(x, y, z));
      }
    }
  }
}