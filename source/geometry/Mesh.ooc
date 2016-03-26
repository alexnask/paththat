import ../UnsafeArray
import Surfaces
import ../geometry/Points

import math/Random

Mesh: class {
    surfaces: UnsafeArray<Surface>

    init: func (surfaceData: Surface*, surfaceLen: Int) {
        surfaces = (surfaceData, surfaceLen) as UnsafeArray<Surface>
    }

    moveBy: func (p: Point3d<Double>) {
        for (i in 0 .. surfaces length) {
            surfaces[i] moveBy(p)
        }
    }

    randomSurface: func -> Surface {
        surfaces[Random randRange(0, surfaces length)]
    }

    origin ::= surfaces[0] origin()
}
