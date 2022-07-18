$e = 0.1;
$fn = 16;

use <functions.scad>
use <operations.scad>
use <shapes.scad>

module tirus(s) {
  let (data = [
      ["Schwalbe Marathon Winter Plus", 42, 622],
      ["Schwalbe G-One Allround", 40, 622],
      ["WTB Exposure Comp", 32, 622],
      ["Merida Race Lite", 52, 584],
      ["Vee Tire Flow Snap", 66, 584],
      ["Schwalbe Jumbo Jim", 100, 559],
      /// This is the narrowest tire that is still manufactured.
      ["Tufo Elite", 19, 622],
      /// This is the widest tire that is still manufactured.
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
    translate([x / 2 - w / 4, y / 2 - w / 2, 0])
    rotate([0, 0, 180])
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
      translate([0, w / 2, 0])
        rotate([0, 0, 180])
        triangle(w / 2, d);
  }
  else
    translate([- x / 2 + w / 4, y / 2 - w, 0])
    cube([x - w / 2, w / 2, d]);
}

module legs(d, w, x, y, economy = false) {
  mirror_copy([0, 1, 0])
    leg(d, w, x, y, economy);
}

module perpendicular_bodypart(d, w, x, y, economy = false) {
  translate([x / 2 - w, - y / 2, 0])
    cube([w, y, d]);
}

module parallel_bodypart(d, w, x, y, economy = false) {
  translate([- x / 2 + w, y / 2 - w, 0])
    /// This scaling is here just to emphasize that there is a boundary.
    scale([1, 1, 5 / 4])
    cube([x - 2 * w, w, d]);
}

module reinforcement(d, w, x, y, economy = false) {
  if (economy)
    translate([- w / 4, y / 2 - w, 0])
    cube([w / 2, w, d]);
  else
    translate([- w / 4, y / 2 - w / 2, 0])
    cube([w / 2, w / 2, d]);

  mirror_copy([1, 0, 0])
    translate([x / 2 - w / 4, y / 2 - w, 0])
    cube([w / 4, w, d]);
}

module reinforced_parallel_bodypart(d, w, x, y, economy = false) {
  parallel_bodypart(d, w, x, y, economy);
  /// This scaling is here just to emphasize that there is a boundary.
  scale([1, 1, 3 / 4])
    translate([0, 0, - d])
    /// This color is here to indicate reinforcements are optional.
    color(alpha = 0.5)
    reinforcement(d, w, x, y, economy);
}

module body(d, w, x, y, economy = false) {
  mirror_copy([1, 0, 0])
    perpendicular_bodypart(d, w, x, y, economy);
  mirror_copy([0, 1, 0])
    reinforced_parallel_bodypart(d, w, x, y, economy);
}

module chamfer(d, w, x, g) {
  translate([x / 2 + $e, g / 2 - $e, w + $e])
    rotate([0, 90, 90])
    triangle(w / 2 + $e, d + 2 * $e);
}

module arm(d, w, x, g, economy = false) {
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
        x_shift = (d + g) * tan(a) / 2) {
      if (economy) {
        translate([x_shift, 0, 0])
          arm(d, w, x, g, economy);
        translate([- x_shift, 0, 0])
          mirror([0, 1, 0])
          arm(d, w, x, g, economy);

        translate([x_shift, 0, 0])
          mirror_copy([1, 0, 0])
          support(d, w, x, g, economy);
        translate([- x_shift, 0, 0])
          mirror([0, 1, 0])
          mirror_copy([1, 0, 0])
          support(d, w, x, g, economy);
      }
      else {
        translate([x_shift, 0, 0])
          arm(d, w, x_skew, g, economy);
        translate([- x_shift, 0, 0])
          mirror([0, 1, 0])
          arm(d, w, x_skew, g, economy);

        translate([x_shift, 0, 0])
          mirror_copy([1, 0, 0])
          support(d, w, x_skew, g, economy);
        translate([- x_shift, 0, 0])
          mirror([0, 1, 0])
          mirror_copy([1, 0, 0])
          support(d, w, x_skew, g, economy);
      }
    }
}

module jigsaw_cut(d, w, x, y) {
  let (d_cut = (x / 4 + w / 2) / sqrt(2),
      y_cut = w / 2)
    /// The error term here is `6 * $e`,
    /// because each rack can have up to six neighboring racks.
    translate([x / 4, y / 2 + d_cut / sqrt(2) - y_cut, - 6 * $e])
    rotate([0, 0, - 135])
    triangle(d_cut, 3 * d + w + 12 * $e);
}

module bounding_cut(d, w, x, y) {
  translate([- x / 2 - w, y / 2, - 6 * $e])
    cube([x + 2 * w, w, 3 * d + w + 12 * $e]);
}

module cuts(d, w, x, y) {
  mirror_copy([0, 1, 0])
    mirror_copy([1, 0, 0])
    jigsaw_cut(d, w, x, y);
  mirror_copy([1, 1, 0])
    mirror_copy([- 1, 1, 0])
    bounding_cut(d, w, x, y);
}

module rack(d, w, x, y, g, a, economy = false) {
  assert(economy ? d <= w : 2 * d <= w,
      "Lumber is rounder than it should be!");

  difference() {
    union() {
      feet(d, w, x, y, economy);
      translate([0, 0, d])
        legs(d, w, x, y, economy);
      translate([0, 0, 2 * d])
        body(d, w, x, y, economy);
      translate([0, 0, 3 * d])
        supported_arms(d, w, x, g, a, economy);
    }
    cuts(d, w, x, y);
  }
  rotate([0, 0, a])
    children();
}

/// Depth of the lumber (plank or board).
d = 19;
/// Width of the lumber (plank or board).
w = 114;
/// Parallel length of the body (affected by rim size and tire height).
x = 600;
/// Perpendicular length of the body (affected by handlebar size).
y = 600;
/// Size of the gap (affected by tire width).
g = undef;
/// Angle of skewness (affected by tire width and length of the body).
a = atan((x / 4) / y);
echo(a = a);
/// Whether to save material.
economy = undef;

/// We choose `x` and `y`
/// to make the intersection of `rack` and `tirus` empty.
/// After making the choice,
/// we check that `a` is large enough
/// to make the pairwise intersection of every `tirus` empty.
/// Then, we choose each `g` based on tire width and elasticity.
/// In economy mode, we can guarantee
/// that each rack can be built from six equal pieces of lumber.

/// This rack can hold a Tunturi H310.
color("Silver")
  rack(d, w, x, y, 44, a, true)
  tirus("Schwalbe Marathon Winter Plus");

/// This rack can hold a Marin Gestalt.
color("DarkRed")
  /// This `$e` is here to work around a z-fighting bug in OpenSCAD.
  translate([3 * x / 2, $e, $e])
  rack(d, w, x, y, 34, a, true)
  tirus("WTB Exposure Comp");

/// This rack can hold a Marin San Quentin.
color("LightBlue")
  translate([x + x / 4, y - w / 2 + 2 * $e, 2 * $e])
  rack(d, w, x, y, 68, a, false)
  tirus("Vee Tire Flow Snap");

/// This rack can hold a Tunturi eMAX FullFat.
color("Khaki")
  translate([x / 4, y - w / 2 + 3 * $e, 3 * $e])
  rack(d, w, x, y, 102, a, false)
  tirus("Schwalbe Jumbo Jim");
