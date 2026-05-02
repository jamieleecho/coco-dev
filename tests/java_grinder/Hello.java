import net.mikekohn.java_grinder.TRS80Coco;

public class Hello {
  public static void main(String[] args) {
    TRS80Coco.setText(1024, 0x48);
    TRS80Coco.setText(1025, 0x49);
  }
}
