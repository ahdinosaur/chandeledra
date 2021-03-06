include <constants.scad>

// Simple list comprehension for creating N-gon vertices
function ngon(num, r) = [for (i=[0:num-1], a=i*360/num) [ r*cos(a), r*sin(a) ]];

// https://www.wikihow.com/Find-the-Height-of-a-Triangle
function triangle_height (a, b, c) =
  let (
    perimeter = (a + b + c),
    s = perimeter / 2,
    area = sqrt(s * (s - a) * (s - b) * (s - c)),
    base = a,
    height = area / ((1 / 2) * base)
  ) height;

// https://www.onlinemathlearning.com/cosecant.html
function sec (theta) = 1 / cos(theta);
function csc (theta) = 1 / sin(theta);
function cot (theta) = 1 / tan(theta);

// http://www.mathopenref.com/polygonsides.html
function polygon_side_length (circumradius, sides) =
  2 * circumradius * sin(180 / sides);

// https://math.stackexchange.com/a/1282689
function polygon_inradius (circumradius, sides) =
  circumradius / sec(180 / sides);

function polygon_inner_angle (sides) =
  (sides - 2) * (1/2 * ROT) / sides;

// http://forum.openscad.org/test-if-variable-is-defined-td2994.html
function defined(a) = str(a) != "undef"; 

// http://forum.openscad.org/Drawing-Ellipses-td536.html
module ellipses (rx, ry) {
  scale([
    1,
    ry / rx
  ])
  circle(
    r = rx,
    $fa = MIN_ARC_FRAGMENT_ANGLE,
    $fs = MIN_ARC_FRAGMENT_SIZE
  );
}

module for_each_radial (
  start_step = 0,
  end_step,
  num_steps,
  step_length = 1,
  radius = 1,
  radial_offset = 0,
  rotation_offset = 0,
  direction = "out"
) {
  end_step_value = defined(end_step) ? end_step - 1 : num_steps - 1;
  
  for (step_index = [start_step : end_step_value]) {
    index = step_index * step_length;
    step_angle = ROT / num_steps;
    index_angle = index * step_angle;
    /*
    radial_step_angle = ROT / num_steps;
    rotation_step_angle = direction == "in"
      ? polygon_inner_angle(sides = num_steps)
      : (ROT / num_steps);
    */
    radial = index_angle + radial_offset;
    rotation = index_angle + rotation_offset;

    translate([
      radius * cos(radial),
      radius * sin(radial),
      0
    ])
    rotate(rotation)
    children();
  }
}

// https://www.youtube.com/watch?v=c1LKQaFIPNA
module right_triangle (size, radius = 0.1) {
  adjacent = size[0];
  opposite = size[1];
  depth = size[2];

  translate([(-1/2) * adjacent, (-1/2) * opposite, (-1/2) * depth])
  linear_extrude(height = depth)
  translate([radius, 0])
  hull () {
    circle(r = radius);

    translate([adjacent - radius * 2, 0])
    circle(r = radius);

    translate([0, opposite - radius * 2])
    circle(r = radius);
  }
}

module triangle (size, radius = 0.1) {
  width = size[0];
  height = size[1];
  depth = size[2];

  translate([0, (-1/2) * height, (-1/2) * depth])
  linear_extrude(height = depth)
  translate([radius, 0])
  hull () {
    translate([0, height - radius * 2, 0])
    circle(r = radius);

    translate([(-1/2) * width - radius * 2, 0])
    circle(r = radius);

    translate([(1/2) * width - radius * 2, 0])
    circle(r = radius);
  }
}

module rounded_box (size, radius = 0.1) {
  width = size[0];
  height = size[1];
  depth = size[2];

  translate([(-1/2) * width, (-1/2) * height, (-1/2) * depth])
  linear_extrude(height = depth)
  translate([radius, 0])
  hull () {
    circle(r = radius);

    translate([width - radius * 2, 0])
    circle(r = radius);

    translate([0, height - radius * 2])
    circle(r = radius);

    translate([width - radius, height - radius * 2])
    circle(r = radius);
  }
}

module rounded_polygon (num_sides = 3, radius = 1, depth = 1, corner_radius = 0.1) {
  translate([0, 0, (-1/2) * depth])
  linear_extrude(height = depth)
  hull () {
    for_each_radial(
      num_steps = num_sides,
      radius = radius
    ) {
      circle(r = corner_radius);
    }
  }
}

module torus (radius, tube_radius, convexity = 10) {
  rotate_extrude(
    convexity = convexity,
    $fa = MIN_ARC_FRAGMENT_ANGLE,
    $fs = MIN_ARC_FRAGMENT_SIZE
  )
  translate([radius + tube_radius, 0, 0])
  circle(
    tube_radius,
    $fa = MIN_ARC_FRAGMENT_ANGLE,
    $fs = MIN_ARC_FRAGMENT_SIZE
  );
}

module polygon_ring (radius, num_sides, tube_radius) {
  inner_angle = (num_sides - 2) * (1/2 * ROT) / num_sides;
  side_length = polygon_side_length(circumradius = radius, sides = num_sides);

  for_each_radial(
    radius = polygon_inradius(circumradius = radius, sides = num_sides),
    num_steps = num_sides,
    rotation_offset = (1/4) * ROT
  ) {
    translate([-(1/2) * side_length, 0, 0])
    hull () {
      sphere(
        tube_radius,
        center = true,
        $fa = MIN_ARC_FRAGMENT_ANGLE,
        $fs = MIN_ARC_FRAGMENT_SIZE
      );
      
      translate([side_length, 0, 0])
      sphere(
        tube_radius,
        center = true,
        $fa = MIN_ARC_FRAGMENT_ANGLE,
        $fs = MIN_ARC_FRAGMENT_SIZE
      );
    }
      
    /*
    rotate([0, (1/4) * ROT, inner_angle])
    linear_extrude(height = radius)
    circle(
      tube_radius,
      $fa = MIN_ARC_FRAGMENT_ANGLE,
      $fs = MIN_ARC_FRAGMENT_SIZE
    );
    */
  }
}

module below_x (x) {
  translate(
    [
      x - (INFINITY),
      -INFINITY / 2,
      -INFINITY / 2
    ]
  )
  cube(INFINITY);
}

module below_z (z) {
  translate(
    [
      -INFINITY / 2,
      -INFINITY / 2,
      z - (INFINITY)
    ]
  )
  cube(INFINITY);
}

module above_z (z) {
  translate(
    [
      -INFINITY / 2,
      -INFINITY / 2,,
      z
    ]
  )
  cube(INFINITY);
}
