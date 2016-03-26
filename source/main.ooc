import render/Bitmap
import trace/[Camera, Lens]
import geometry/[Surfaces, ObjLoader, Mesh, Points, Vectors, Scene, Ray, Material]

import structs/ArrayList

main: func (args: ArrayList<String>) -> Int {
    bm := Bitmap new(500, 500)

    al := ArrayList<Surface> new(1024)
    loader := ObjLoader new()

    mesh := loader load("cube.obj", al)

    "Got mesh with #{mesh surfaces length} faces" println()

    camera := Camera new(point(3, -0.5, -1), vec(0, 0, 1), bm, SimpleLens new(), 1.57)
    scene := Scene new(al data as Surface*, al size, mesh&, 1, null, 0, camera)

    // Samples per pixel
    samples := 1

    for (x in 0 .. bm width) {
        for (y in 0 .. bm height) {
            // TODO: Ideally, subsamples?
            ray := camera rayFor(x, y)

            colorPoint := point(0, 0, 0)

            for (k in 0 .. samples) {
                point: Point3d<Double>
                surface := null as Surface

                scene findFirstIntersection(ray, point&, surface&)

                // We hit something!
                if (surface) {
                    colorPoint += surface material ambient * (1.0 / samples)
                }
            }

            bm writeAt(x, y, RgbColor fromColorPoint(colorPoint))
        }
    }

    bm dumpTo("test.bmp")

    0
}
