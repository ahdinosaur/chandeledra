var createScene = require('gl-plot3d')
var createMesh = require('gl-mesh3d')
var range = require('just-range')
var sc = require('simplicial-complex')

var scene = createScene()

function geoelongatedPentagonalDipyramid (length) {
  var height = (1/2) * Math.sqrt(3) * length

  var shape = {
    positions: [
      // top of upper pyramid: 0
      [0, 0, 0],

      // bottom of upper pyramid / top of antiprism: 1-5
      ...range(5).map(index => [...polygon({ sides: 5, radius: length, index }), height]),

      // top of lower pyramid / bottom of antiprism: 6-10
      ...range(5).map(index => [...polygon({ sides: 5, radius: length, index, rotation: Math.PI/5 }), height * 2]),

      // bottom of lower pyramid: 11
      [0, 0, height * 3]
    ],
    cells: [
      // upper pyramid
      [0, 1, 2],
      [0, 2, 3],
      [0, 3, 4],
      [0, 4, 5],
      [0, 5, 1],

      // anti-prism
      [1, 6, 2],
      [6, 2, 7],
      [2, 7, 3],
      [7, 3, 8],
      [3, 8, 4],
      [8, 4, 9],
      [4, 9, 5],
      [9, 5, 10],
      [5, 10, 1],
      [10, 1, 6],

      // lower pyramid
      [11, 6, 7],
      [11, 7, 8],
      [11, 8, 9],
      [11, 9, 10],
      [11, 10, 6]
    ]
  }

  console.log('shape', shape)

  return shape
}

var shape = geoelongatedPentagonalDipyramid(1)

var mesh = createMesh({
  gl: scene.gl,
  cells: sc.skeleton(shape.cells, 1),
  positions: shape.positions,
  colormap: 'rainbow-soft'
})

scene.add(mesh)

function polygon ({ n, r, center }, cb) {
  for (i = 0; i < n; i++) {
    const x = center.x + r * Math.cos(2 * Math.PI * i / n)
    const y = center.y + r * Math.sin(2 * Math.PI * i / n)
    cb({ i, x, y })
  }
}

// returns single point on polygon
function polygon (options) {
  const {
    sides,
    index,
    radius,
    center = [0, 0],
    rotation = 0
  } = options

  const x = center[0] + radius * Math.cos(2 * Math.PI * (index / sides) + rotation)
  const y = center[1] + radius * Math.sin(2 * Math.PI * (index / sides) + rotation)

  return [x, y]
}
