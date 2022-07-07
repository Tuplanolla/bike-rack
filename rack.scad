$e = 1;
$fn = 64;

use <functions.scad>
use <shapes.scad>

module tirus(s) {
  let (data = [
      ["Schwalbe Marathon Winter Plus", 42, 622],
      ["Schwalbe G-One Allround", 40, 622],
      ["WTB Exposure Comp", 32, 622],
      ["Merida Race Lite", 52, 584],
      ["Vee Tire Flow Snap", 66, 584],
      ["Tufo Elite", 19, 622],
      ["Vee Tire Snow Shoe 2XL", 128, 559]])
    let (i = find(s, [for (v = data) v[0]]))
    if (i)
      let (v = data[i])
      let (w = v[1], d = v[2])
      translate([0, 0, d / 2 + w])
      /// This rotation is here just to accommodate low values of `$fn`.
      rotate([90, 180 / $fn, 0])
      torus((d + w) / 2, w / 2);
}

/// Depth of the plank or board.
// d = 38;
d = 19;
/// Width of the plank or board.
w = 89;
/// Length of the arms (wheelbase overlap).
x = 500;
/// Length of the legs (handlebar width).
// y = 780;
y = 420;
/// Size of the gap (tire width).
g = 34;
/// Whether to save material.
economy = false;

module bevel(d, w, x, g) {
  translate([$e + x / 2, g / 2 - $e, d + w + $e])
    rotate([0, 90, 90])
    right_triangle($e + w / 2, 2 * $e + d);
}

module arm(d, w, x, g) {
  difference() {
    translate([- x / 2, g / 2, d])
      cube([x, d, w]);
    bevel(d, w, x, g);
    mirror([1, 0, 0])
      bevel(d, w, x, g);
  }
}

module arms(d, w, x, g) {
  arm(d, w, x, g);
  mirror([0, 1, 0])
    arm(d, w, x, g);
}

module leg(d, w, x, y) {
  translate([x / 2 - w, - y / 2, 0])
    cube([w, y, d]);
}

module legs(d, w, x, y) {
  leg(d, w, x, y);
  translate([- x + w, 0, 0])
    leg(d, w, x, y);
}

module support(d, w, g) {
if (economy)
  translate([x / 2 - w / 2, g / 2 + d, d])
    rotate([0, - 90, 0])
    translate([0, 0, - d / 2])
    right_triangle(w / 2, d);
else
  translate([x / 2 - w / 2 - d / 2, g / 2 + d, d])
    rotate([0, - 90, 0])
    translate([0, 0, - d / 2])
    right_triangle(w, d);
}

module supports(d, w, g) {
  support(d, w, g);
  mirror([1, 0, 0])
    support(d, w, g);
  mirror([0, 1, 0])
    support(d, w, g);
  mirror([1, 0, 0])
    mirror([0, 1, 0])
    support(d, w, g);
}

module hook(d, w, x, y) {
  translate([- x / 2 + w, y / 2 - w, 0])
    cube([x - 2 * w, w, d]);
}

module hooks(d, w, x, y) {
  hook(d, w, x, y);
  mirror([0, 1, 0])
    hook(d, w, x, y);
}


module rack(d, w, x, y, g) {
  arms(d, w, x, g);
  legs(d, w, x, y);
  supports(d, w, g);
  /// TODO Jigsaw this.
  # hooks(d, w, x, y);
  /// TODO Add feet.
  /// TODO Use the jigsaw pieces as material in economy mode.
  /// TODO Point the triangles away from the wheel for traction.
  /// TODO Attach them before the jigsaw cut for structural integrity.
  /// TODO Check that the feet do not lift the wheel up
  /// (slightly tricky math).
  /// TODO Check that the supports fit on narrower planks
  /// (must have `2 * d <= w` in normal mode, `d <= w` in economy mode).
}

tirus("WTB Exposure Comp");
rack(d, w, x, 420, 34);

translate([0, 610, 0]) {
  tirus("Vee Tire Flow Snap");
  rack(d, w, x, 780, 68);
}
