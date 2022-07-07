/// The invocation `hollow_cylinder(h, r0, r1)` produces a hollow cylinder
/// with the height `h`, the inner radius `r0` and the outer radius `r1`.
/// The base of the cylinder is placed at the origin and
/// its height grows along the `z` axis.
module hollow_cylinder(h, r0, r1) {
  difference() {
    cylinder(h, r1, r1);
    translate([0, 0, - $e])
      cylinder(2 * $e + h, r0, r0);
  }
}

/// The invocation `torus(r0, r1)` produces a torus
/// with the toroidal radius (the distance
/// from the center of mass of the torus
/// to the centerline of the tube) `r0` and
/// the poloidal radius (the distance
/// from the centerline of the tube
/// to the surface of the torus) `r1`.
/// The center of mass of the torus is placed at the origin and
/// the tube revolves around the `z` axis.
module torus(r0, r1) {
  translate([0, 0, - r1])
    rotate_extrude()
    translate([r0, r1, 0])
    circle(r1);
}

/// The invocation `right(w, h)` produces a right triangle
/// with the side length `w` and height `h`.
/// The right angle of the triangle is placed at the origin and
/// its height grows along the `z` axis.
module right_triangle(w, h) {
  linear_extrude(h)
    polygon([[0, 0], [0, w], [w, 0]]);
}
