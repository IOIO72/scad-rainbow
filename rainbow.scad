/*
Thw Rainbow Customizer (09 June 2021)
by ioio72 aka Tamio Patrick Honma

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/



/* [Basic] */

// Diameter of the rainbow
diameter = 100;

// Percent of diameter to define inner diameter
inner_diameter_percent = 50; // [20:70]

// Percent of offset width between bows
offset_percent = 20; // [0:60]

// Depth of the bows
depth = 2.5;

// Shape of a bow
shape = "reactangle"; // ["rectangle", "triangle", "rounded"]

// Number of bows / rainbow colors
bows = 7; // [1:14]

// Angle of the rainbow
angle = 180; // [1:360]


/* [Stand] */

// Stand height
stand_height = 3; // [2:200]

// Thickness of the outer frame around the stand 
stand_thickness = 4; // [1:20]

// The stand has the shape of a cloud
stand_cloud = true;

// Stand attachment hole height (must be lower than stand_height)
stand_attachment_hole_height = 1.5;

// Tolerance for attachment hole (the hole should be a little bit bigger than the cross section of one bow)
stand_attachment_hole_tolerance = 0.2;


/* [Print parts] */

// Select the number of the bow to render (0 = hidden; 15 or higher number than the amount of bows = all together)
number = 15; // [0:15]

// Render the stand
stand = true;


/* [Advanced] */

// Number of fragments
$fn = 100;


/* [Hidden] */
radius = diameter / 2;
width = radius - radius * inner_diameter_percent / 100;
bow_width = width / bows;
inner_bow_width = bow_width - bow_width * offset_percent / 100;
stand_position = radius - bows * bow_width / 2 - bow_width / 2;

module bow_shape(position) {
  translate([position, 0, 0]) {
    if (shape == "triangle") {
      polygon([[-inner_bow_width / 2, -depth / 2], [inner_bow_width / 2, depth / 2], [inner_bow_width / 2, -depth / 2]]);
    } else if (shape == "rounded") {
      difference() {
        scale([inner_bow_width, depth * 2, 0]) circle(d = 1);
        translate([0, -depth, 0]) square([inner_bow_width, depth], center = true);
      };
    } else {
      square([inner_bow_width, depth], center = true);
    };
  }
};

module bow(i) {
  if (i > 0 && i <= bows) {
    color(hsv((i - 1) / bows, 1, 1)) {
      rotate_extrude(angle = angle) {
        bow_shape(radius - i * bow_width);
      };
    };
  };
};

module stand_base() {
  offset(r = stand_thickness) {
    square([width, depth], center = true);
    if (stand_cloud) {
      offset(2) {
        circle(d = width / 2);
        translate([width / 2.4, 0]) circle(d = width / 8);
        translate([-width / 2.4, 0]) circle(d = width / 8);
        translate([width / 3, width / 11, 0]) circle(d = width / 5);
        translate([width / 3, -width / 9, 0]) circle(d = width / 6);
        translate([-width / 3, -width / 9, 0]) circle(d = width / 5);
        translate([-width / 3, width / 12, 0]) circle(d = width / 6);
      };
    };
  };
};

module stand(position) {
  color("#ffffff") {
    translate([position + stand_thickness * 2.5, radius + depth + stand_thickness * 2.5, 0]) {
      linear_extrude(stand_height - stand_attachment_hole_height) {
        stand_base();
      };
      translate([0, 0, stand_height - stand_attachment_hole_height]) linear_extrude(stand_attachment_hole_height) {
        difference() {
          stand_base();
          for(i = [1:bows]) {
            offset(r = stand_attachment_hole_tolerance)
            bow_shape(-bows * bow_width / 2 - bow_width / 2 + i * bow_width);
          };
        }
      };
    };
  };
};


// Rainbow

translate([0, 0, depth / 2]) {
  if (number > bows) {
    for(i = [1:bows]) {
      bow(i);
    };
  } else {
    bow(number);
  };
};


// Stand

if (stand) {
  stand(stand_position);
  mirror([1, 0, 0]) stand(stand_position);
};


// Helpers

// hsv by LightAtPlay (https://gist.github.com/LightAtPlay/24148d8be2e66d26fd11)
function hsv(h, s = 1, v = 1, a = 1, p, q, t) = (p == undef || q == undef || t == undef)
	? hsv(
		(h%1) * 6,
		s<0?0:s>1?1:s,
		v<0?0:v>1?1:v,
		a,
		(v<0?0:v>1?1:v) * (1 - (s<0?0:s>1?1:s)),
		(v<0?0:v>1?1:v) * (1 - (s<0?0:s>1?1:s) * ((h%1)*6-floor((h%1)*6))),
		(v<0?0:v>1?1:v) * (1 - (s<0?0:s>1?1:s) * (1 - ((h%1)*6-floor((h%1)*6))))
	)
	:
	h < 1 ? [v,t,p,a] :
	h < 2 ? [q,v,p,a] :
	h < 3 ? [p,v,t,a] :
	h < 4 ? [p,q,v,a] :
	h < 5 ? [t,p,v,a] :
	        [v,p,q,a];
