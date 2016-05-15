import render/Bitmap
import trace/[Camera, Lens, BidirectionalTracer]
import geometry/[Surfaces, ObjLoader, Mesh, Points, Vectors, Scene, Ray, Material]

import structs/ArrayList


main: func (args: ArrayList<String>) -> Int {
    bm := Bitmap new(500, 500)

    al := ArrayList<Surface> new(1024)
    loader := ObjLoader new()

    mesh := loader load("cube.obj", al)

    "Got mesh with #{mesh surfaces length} faces" println()

    camera := Camera new(point(1.5, -0.5, -1), vec(0, 0, 1), bm, SimpleLens new(), 1.57)
    scene := Scene new(al data as Surface*, al size, mesh&, 1, null, 0, camera)

    BidirectionalTracer trace(scene, camera, 1)

    bm dumpTo("test.bmp")

    0
}
