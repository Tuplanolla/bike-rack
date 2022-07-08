$e = 1;
$fn = 16;

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
x = 560;
/// Length of the legs (handlebar width).
y = (420 + 780) / 2;
/// Size of the gap (tire width).
g = 34;
/// Angle of skewness (for collision avoidance).
// a = 45 * (1 + cos(360 * $t)) / 2;
a = 15;
/// Whether to save material.
economy = false;

module foot(d, w, x, y) {
  translate([x / 2 - w / 2, y / 2 - w / 2, 0])
    if (economy)
      /// We point the foot triangles away from the tire
      /// for optimal traction.
      rotate([0, 0, 225])
        triangle(w / 2, d);
    else
      translate([- w / 4, - w / 2, 0])
        cube([w / 2, w / 2, d]);
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

module ankle(d, w, x, y) {
  translate([- x / 2, y / 2 - w, 0])
    cube([x, w / 2, d]);
}

module ankles(d, w, x, y) {
  ankle(d, w, x, y);
  mirror([0, 1, 0])
    ankle(d, w, x, y);
}

module leg(d, w, x, y) {
  translate([x / 2 - w, - y / 2, 0])
    cube([w, y, d]);
}

module legs(d, w, x, y) {
  leg(d, w, x, y);
  mirror([1, 0, 0])
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

module support(d, w, x, g) {
  if (economy)
    translate([x / 2 - w / 2, g / 2 + d, 0])
      rotate([0, - 90, 0])
      translate([0, 0, - d / 2])
      triangle(w / 2, d);
  else
    translate([x / 2 - w / 2 - d / 2, g / 2 + d, 0])
      rotate([0, - 90, 0])
      translate([0, 0, - d / 2])
      triangle(w, d);
}

module supported_arms(d, w, x, g, a) {
  let (x_sub = x - d * sin(a))
  let (dx_skew = (g + d) * tan(a) / 2,
      x_skew = sqrt(x_sub ^ 2 + (x_sub * tan(a)) ^ 2)) {

    translate([dx_skew, 0, 0])
      arm(d, w, x_skew, g);
    mirror([0, 1, 0])
      translate([- dx_skew, 0, 0])
      arm(d, w, x_skew, g);

    translate([dx_skew, 0, 0])
      support(d, w, x_skew, g);
    mirror([1, 0, 0])
      translate([- dx_skew, 0, 0])
      support(d, w, x_skew, g);
    mirror([0, 1, 0])
      translate([- dx_skew, 0, 0])
      support(d, w, x_skew, g);
    mirror([1, 0, 0])
      mirror([0, 1, 0])
      translate([dx_skew, 0, 0])
      support(d, w, x_skew, g);
  }
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

module rack(d, w, x, y, g, a) {
  feet(d, w, x, y);
  translate([0, 0, d])
    ankles(d, w, x, y);
  translate([0, 0, 2 * d])
    difference() {
      union() {
        legs(d, w, x, y);
        hooks(d, w, x, y);
      }
      cuts(d, w, x, y);
    }
  rotate([0, 0, a]) {
    translate([0, 0, 3 * d])
      supported_arms(d, w, x, g, a);
    children();
  }
}

/// Unskewed supports fit on planks
/// when `2 * d <= w` in normal mode or `d <= w` in economy mode.
/// Experimentally,
/// skewed supports fit on the legs
/// up to 22.5 degrees of skewness.
/// Experimentally,
/// tires do not touch each other
/// down to 9 degrees of skewness.
/// Experimentally,
/// tires stay on the ground
/// down to 560 millimeters of arm length.

color("Silver")
  rack(d, w, x, y, 44, a)
  tirus("Schwalbe Marathon Winter Plus");

color("DarkRed")
  translate([x, 0, $e])
  rack(d, w, x, y, 34, a)
  tirus("WTB Exposure Comp");

color("LightBlue")
  translate([x + x / 4, y - (w - x / (3 * sqrt(2)) / sqrt(2) / 2), 2 * $e])
  rack(d, w, x, y, 68, a)
  tirus("Vee Tire Flow Snap");

color("Khaki")
  translate([x / 4, y - (w - x / (3 * sqrt(2)) / sqrt(2) / 2), 3 * $e])
  rack(d, w, x, y, 102, a)
  tirus("Schwalbe Jumbo Jim");
