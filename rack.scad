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
      ["Schwalbe Jumbo Jim", 100, 559],
      ["Tufo Elite", 19, 622],
      ["Vee Tire Snow Shoe 2XL", 128, 559]])
    let (i = find(s, [for (v = data) v[0]]))
    if (i != undef)
      let (v = data[i])
      let (w = v[1], d = v[2])
      translate([0, 0, d / 2 + w])
      rotate([90, 0, 0])
      /// This rotation is here just to accommodate low values of `$fn`.
      rotate([0, 0, 180 / $fn])
      torus((d + w) / 2, w / 2);
}

/// Depth of the plank or board.
d = 19;
/// Width of the plank or board.
w = 89;
/// Length of the arms (wheelbase overlap).
x = 500;
/// Length of the legs (handlebar width).
y = (420 + 780) / 2;
/// Size of the gap (tire width).
g = 34;
/// Angle of skewness (for collision avoidance).
a = 10;
/// Whether to save material.
economy = false;

module foot(d, w, x, y) {
  translate([x / 2 - w / 2, y / 2 - w / 2, 0])
    if (economy)
      translate([- w / 4, - w / 2, 0])
        cube([w / 2, w / 2, d]);
    else
      rotate([0, 0, 225])
        triangle(w / 2, d);
}

module feet(d, w, x, y) {
  foot(d, w, x, y);
  mirror([1, 0, 0])
    foot(d, w, x, y);
  mirror([0, 1, 0])
    foot(d, w, x, y);
  mirror([1, 0, 0])
    mirror([0, 1, 0])
    foot(d, w, x, y);
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

module hook(d, w, x, y) {
  translate([- x / 2 + w, y / 2 - w, 0])
    cube([x - 2 * w, w, d]);
}

module hooks(d, w, x, y) {
  hook(d, w, x, y);
  mirror([0, 1, 0])
    hook(d, w, x, y);
}

module bevel(d, w, x, g) {
  translate([$e + x / 2, g / 2 - $e, w + $e])
    rotate([0, 90, 90])
    triangle($e + w / 2, 2 * $e + d);
}

module arm(d, w, x, g) {
  difference() {
    translate([- x / 2, g / 2, 0])
      cube([x, d, w]);
    bevel(d, w, x, g);
    mirror([1, 0, 0])
      bevel(d, w, x, g);
  }
}

module support(d, w, g) {
  let (x_a = cos(a) * x)
    if (economy)
      translate([x_a / 2 - w / 2, g / 2 + d, 0])
        rotate([0, - 90, 0])
        translate([0, 0, - d / 2])
        triangle(w / 2, d);
    else
      translate([x_a / 2 - w / 2 - d / 2, g / 2 + d, 0])
        rotate([0, - 90, 0])
        translate([0, 0, - d / 2])
        triangle(w, d);
}

module supported_arms(d, w, x, g) {
  arm(d, w, x, g);
  mirror([0, 1, 0])
    arm(d, w, x, g);

  support(d, w, g);
  mirror([1, 0, 0])
    support(d, w, g);
  mirror([0, 1, 0])
    support(d, w, g);
  mirror([1, 0, 0])
    mirror([0, 1, 0])
    support(d, w, g);
}

module cut(d, w, x, y) {
  let (size = x / (3 * sqrt(2)))
    translate([x / 4, y / 2 + size / sqrt(2) - w / 2, - $e])
    rotate([0, 0, - 135])
    triangle(size, 2 * $e + d);
}

module cuts(d, w, x, y) {
  cut(d, w, x, y);
  mirror([1, 0, 0])
    cut(d, w, x, y);
  mirror([0, 1, 0])
    cut(d, w, x, y);
  mirror([1, 0, 0])
    mirror([0, 1, 0])
    cut(d, w, x, y);
}

module rack(d, w, x, y, g) {
  feet(d, w, x, y);
  translate([0, 0, d])
    difference() {
      union() {
        legs(d, w, x, y);
        hooks(d, w, x, y);
      }
      cuts(d, w, x, y);
    }
  rotate([0, 0, a]) {
    /// This does not suffice.
    let (x_a = cos(a) * x)
      translate([0, 0, 2 * d])
      supported_arms(d, w, x_a, g);
    children();
  }
  /// TODO Use the jigsaw pieces as foot material in economy mode.
  /// TODO Point the triangles away from the wheel for traction.
  /// TODO Attach them before the jigsaw cut for structural integrity.
  /// TODO Figure out if skewness even makes sense.
  /// TODO Check that the skewness does not create impossible geometries
  /// (slightly tricky math).
  /// TODO Check that the feet do not lift the wheel up
  /// (slightly tricky math).
  /// TODO Check that the supports fit on narrower planks
  /// (must have `2 * d <= w` in normal mode, `d <= w` in economy mode).
}

color("Silver")
  rack(d, w, x, y, 44)
  tirus("Schwalbe Marathon Winter Plus");

color("DarkRed")
  translate([x, 0, $e])
  rack(d, w, x, y, 34)
  tirus("WTB Exposure Comp");

color("LightBlue")
  translate([x + x / 4, y - (w - x / (3 * sqrt(2)) / sqrt(2) / 2), 2 * $e])
  rack(d, w, x, y, 68)
  tirus("Vee Tire Flow Snap");

color("Khaki")
  translate([x / 4, y - (w - x / (3 * sqrt(2)) / sqrt(2) / 2), 3 * $e])
  rack(d, w, x, y, 102)
  tirus("Schwalbe Jumbo Jim");
