$e = 0.1;
$fn = 16;

use <functions.scad>
use <shapes.scad>

module mirror_copy(v) {
  children();
  mirror(v)
    children();
}

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

module foot(d, w, x, y, economy = false) {
  if (economy)
    translate([x / 2 - w / 4, y / 2 - w, 0])
    rotate([0, 0, 90])
    triangle(w / 2, d);
  else
    translate([x / 2 - 3 * w / 4, y / 2 - w, 0])
    cube([w / 2, w / 2, d]);
}

module feet(d, w, x, y, economy = false) {
  mirror_copy([0, 1, 0])
    mirror_copy([1, 0, 0])
    foot(d, w, x, y, economy);
}

module leg(d, w, x, y, economy = false) {
  if (economy)
    mirror_copy([1, 0, 0])
      translate([x / 2 - x / 3 + 3 * w / 4, y / 2 - w, 0]) {
        cube([x / 3 - w, w / 2, d]);
        rotate([0, 0, 90])
          triangle(w / 2, d);
      }
  else
    translate([- x / 2, y / 2 - w, 0])
      cube([x, w / 2, d]);
}

module legs(d, w, x, y, economy = false) {
  mirror_copy([0, 1, 0])
    leg(d, w, x, y, economy);
}

module perpendicular_bodypart(d, w, x, y) {
  translate([x / 2 - w, - y / 2, 0])
    cube([w, y, d]);
}

module parallel_bodypart(d, w, x, y) {
  translate([- x / 2 + w, y / 2 - w, 0])
    /// This scaling is here just to emphasize that there is a boundary.
    scale([1, 1, 3 / 4])
    cube([x - 2 * w, w, d]);
}

module body(d, w, x, y) {
  mirror_copy([1, 0, 0])
    perpendicular_bodypart(d, w, x, y);
  mirror_copy([0, 1, 0])
    parallel_bodypart(d, w, x, y);
}

module chamfer(d, w, x, g) {
  translate([$e + x / 2, g / 2 - $e, w + $e])
    rotate([0, 90, 90])
    triangle($e + w / 2, 2 * $e + d);
}

module arm(d, w, x, g) {
  difference() {
    translate([- x / 2, g / 2, 0])
      cube([x, d, w]);
    mirror_copy([1, 0, 0])
      chamfer(d, w, x, g);
  }
}

module support(d, w, x, g, economy = false) {
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

module supported_arms(d, w, x, g, a = 0, economy = false) {
  rotate([0, 0, a])
    let (x_skew = x / cos(a) - d * tan(a),
        x_shift = (g + d) * tan(a) / 2) {
      translate([x_shift, 0, 0])
        arm(d, w, x_skew, g);
      translate([- x_shift, 0, 0])
        mirror([0, 1, 0])
        arm(d, w, x_skew, g);

      translate([x_shift, 0, 0])
        mirror_copy([1, 0, 0])
        support(d, w, x_skew, g, economy);
      translate([- x_shift, 0, 0])
        mirror([0, 1, 0])
        mirror_copy([1, 0, 0])
        support(d, w, x_skew, g, economy);
    }
}

module cut(d, w, x, y) {
  /// The error term is `6 * $e`,
  /// because each rack can have up to six neighboring racks.
  translate([x / 4, y / 2 + x / 6 - w / 2, - 6 * $e])
    rotate([0, 0, - 135])
    triangle(x / (3 * sqrt(2)), 12 * $e + d);
}

module cuts(d, w, x, y) {
  mirror_copy([0, 1, 0])
    mirror_copy([1, 0, 0])
    cut(d, w, x, y);
}

module rack(d, w, x, y, g, a, economy = false) {
  feet(d, w, x, y, economy);
  translate([0, 0, d])
    legs(d, w, x, y, economy);
  translate([0, 0, 2 * d])
    difference() {
      body(d, w, x, y);
      cuts(d, w, x, y);
    }
  translate([0, 0, 3 * d])
    supported_arms(d, w, x, g, a, economy);
  rotate([0, 0, a])
    children();
}

/// Whether to save material.
economy = false;
/// Depth of the lumber (plank or board).
d = 19;
/// Width of the lumber (plank or board).
w = 114;
assert(economy ? d <= w : 2 * d <= w,
    "Lumber is rounder than it should be!");
/// Parallel length of the body (affected by rim size and tire height).
x = 600;
/// Perpendicular length of the body (affected by handlebar size).
y = 600;
/// Size of the gap (affected by tire width).
g = 42;
/// Angle of skewness (affected by tire width and size of the body).
a = atan((x / 4) / y);
echo(a = a);

/// We choose `x` and `y` so that
/// the intersection of `rack` and `tirus` is empty.
/// We also choose `a` so that
/// the pairwise intersection of every `tirus` is empty.

/// This rack fits a Tunturi H310.
color("Silver")
  rack(d, w, x, y, 44, a, !economy)
  tirus("Schwalbe Marathon Winter Plus");

/// This rack fits a Marin Gestalt.
color("DarkRed")
  /// This `$e` is here to work around a z-fighting bug in OpenSCAD.
  translate([x, 0, $e])
  rack(d, w, x, y, 34, a, !economy)
  tirus("WTB Exposure Comp");

/// This rack fits a Marin San Quentin.
color("LightBlue")
  translate([x + x / 4, y - w / 2, 2 * $e])
  rack(d, w, x, y, 68, a, economy)
  tirus("Vee Tire Flow Snap");

/// This rack fits a Tunturi eMAX FullFat.
color("Khaki")
  translate([- x / 4, y - w / 2, 3 * $e])
  rack(d, w, x, y, 102, a, economy)
  tirus("Schwalbe Jumbo Jim");
