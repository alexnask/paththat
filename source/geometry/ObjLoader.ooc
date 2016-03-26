import Surfaces, Mesh, Points, Material
import ../render/Bitmap

import text/StringTokenizer
import structs/[HashMap, ArrayList]

// TODO: A lot of code repetition here, could be abstracted

ObjLoader: class {
    materials := HashMap<String, Material> new()

    // TODO: Use a default material
    currentMaterial := Material def

    init: func

    _vertexIndex: static func (buff: Buffer) -> Int {
        slashIdx := buff indexOf('/')
        if (slashIdx != -1) {
            buff substring(0, slashIdx)
        }

        index := buff toInt()
        if (index > 0) {
            index -= 1
        }
        index
    }

    // So, the Surfaces are added into the ArrayList and a mesh that points into the ArrayList with the correct length is returned
    load: func (path: String, al: ArrayList<Surface>) -> Mesh {
        fHandle := FStream open(path, "r")

        if (!fHandle) {
            return null
        }

        if (fHandle error() != 0) {
            fHandle close()
            return null
        }

        originalSize := al getSize()
        // Increment this in loop
        newSurfaces := 0

        // 1Kb per line should be way more than enough
        lineBuff := Buffer new(1024)

        vertices := ArrayList<Point3d<Double>> new(256)

        while (fHandle hasNext?()) {
            c := fgetc(fHandle)
            if (c == '\r' || c == '\n' || c == EOF || c == '\0') {
                if (lineBuff empty?()) {
                    continue
                }

                if (lineBuff endsWith?('\r')) {
                    lineBuff setLength(lineBuff length() - 1)
                }

                // Evaluate the line here
                if (lineBuff startsWith?("v " _buffer)) {
                    parts := lineBuff split(' ')
                    if (parts getSize() < 4 || parts getSize() > 5) {
                        fHandle close()
                        raise("Vertex data with invalid number of coordinates")
                        return null
                    }

                    // We ignore the 'w' coordinate
                    vertices add(point(parts[1] toDouble(), parts[2] toDouble(), parts[3] toDouble()))
                } else if (lineBuff startsWith?("vt " _buffer)) {
                    // TODO: Texture coordinates
                } else if (lineBuff startsWith?("vn " _buffer)) {
                    // TODO: Vertex normals
                } else if (lineBuff startsWith?("vp " _buffer)) {
                    // TODO: Parameter space vertices
                } else if (lineBuff startsWith?("f " _buffer)) {
                    parts := lineBuff split(' ')
                    if (parts getSize() < 4) {
                        fHandle close()
                        raise("Face data with less than three vertices")
                        return null
                    }

                    if (parts getSize() == 4) {
                        // Special case: Triangle
                        (vertex1, vertex2, vertex3) := (_vertexIndex(parts[1]), _vertexIndex(parts[2]), _vertexIndex(parts[3]))

                        if (vertex1 >= vertices getSize() || vertex2 >= vertices getSize() || vertex3 >= vertices getSize()) {
                            fHandle close()
                            raise("Face references undefined vertex (out of bounds)")
                            return null
                        }

                        al add(Triangle new(vertices[vertex1], vertices[vertex2], vertices[vertex3], currentMaterial))
                        newSurfaces += 1
                    } else {
                        ptArr := ArrayList<Point3d<Double>> new(5)

                        for (i in 1 .. parts getSize()) {
                            vertex := _vertexIndex(parts[i])
                            if (vertex >= vertices getSize()) {
                                fHandle close()
                                raise("Face references undefined vertex (out of bounds)")
                                return null
                            }

                            ptArr add(vertices[vertex])
                        }

                        al add(ConvexPolygon new(ptArr data as Point3d<Double>*, ptArr getSize(), currentMaterial))
                        newSurfaces += 1
                    }

                } else if (lineBuff startsWith?("mtllib " _buffer)) {
                    parts := lineBuff split(' ')
                    if (parts getSize() < 2) {
                        fHandle close()
                        raise("Material library without file name")
                        return null
                    }

                    fName := parts[1]
                    loadMaterials(fName toString())
                } else if (lineBuff startsWith?("usemtl " _buffer)) {
                    parts := lineBuff split(' ')
                    if (parts getSize() < 2) {
                        fHandle close()
                        raise("Material name missing")
                        return null
                    }

                    name := parts[1] toString()

                    if (!materials contains?(name)) {
                        fHandle close()
                        raise("No such material '#{name}'")
                        return null
                    }

                    currentMaterial = materials[name]
                } else if (lineBuff[0] != '#') {
                    // Perhaps we only have whitespace?
                    for (c in lineBuff) {
                        if (c != ' ' && c != '\t') {
                            fHandle close()
                            raise("Invalid line '#{lineBuff}'")
                            return null
                        }
                    }
                }

                lineBuff setLength(0)
                if (c == EOF || c == '\0') {
                    break
                }
            } else {
                lineBuff append((c & 0xFF) as Char)
            }
        }

        fHandle close()

        match newSurfaces {
            case 0 => null as Mesh
            case   =>
                ptr := al data as Surface*
                Mesh new(ptr + originalSize, newSurfaces)
        }
    }

    loadMaterials: func (fName: String) {
        fHandle := FStream open(fName, "rb")
        if (!fHandle) {
            raise("No file #{fName}")
            return
        }

        if (fHandle error() != 0) {
            fHandle close()
            return
        }

        // 1Kb per line should be way more than enough
        lineBuff := Buffer new(1024)

        currMtl: Material

        while (fHandle hasNext?()) {
            c := fgetc(fHandle)
            if (c == '\r' || c == '\n' || c == EOF || c == '\0') {
                if (lineBuff empty?()) {
                    continue
                }

                if (lineBuff startsWith?("newmtl " _buffer)) {
                    parts := lineBuff split(' ')
                    if (parts getSize() < 2) {
                        raise("Material name missing")
                        return
                    }

                    mtlName := parts[1] toString()
                    if (materials contains?(mtlName)) {
                        raise("Material '#{mtlName}' already defined")
                        return
                    }

                    currMtl = Material new()
                    materials put(mtlName, currMtl)
                } else if (lineBuff startsWith?("Ka " _buffer)) {
                    parts := lineBuff split(' ')

                    if (parts getSize() < 4) {
                        raise("Ka has less than four parts")
                        return
                    }

                    if (!currMtl) {
                        raise("No material to apply Ka to")
                        return
                    }

                    currMtl ambient = point(parts[1] toDouble(), parts[2] toDouble(), parts[3] toDouble())
                } else if (lineBuff startsWith?("Kd " _buffer)) {
                    parts := lineBuff split(' ')

                    if (parts getSize() < 4) {
                        raise("Kd has less than four parts")
                        return
                    }

                    if (!currMtl) {
                        raise("No material to apply Kd to")
                        return
                    }

                    currMtl diffuse = point(parts[1] toDouble(), parts[2] toDouble(), parts[3] toDouble())
                } else if (lineBuff startsWith?("Ks " _buffer)) {
                    parts := lineBuff split(' ')

                    if (parts getSize() < 4) {
                        raise("Ks has less than four parts")
                        return
                    }

                    if (!currMtl) {
                        raise("No material to apply Ks to")
                        return
                    }

                    currMtl specular = point(parts[1] toDouble(), parts[2] toDouble(), parts[3] toDouble())
                } else if (lineBuff startsWith?("d " _buffer)) {
                    parts := lineBuff split(' ')

                    if (parts getSize() < 2) {
                        raise("d has less than two parts")
                        return
                    }

                    if (!currMtl) {
                        raise("No material to apply d to")
                        return
                    }

                    currMtl transparency = 1 - parts[1] toDouble()
                } else if (lineBuff startsWith?("Tr " _buffer)) {
                    parts := lineBuff split(' ')

                    if (parts getSize() < 2) {
                        raise("Tr has less than two parts")
                        return
                    }

                    if (!currMtl) {
                        raise("No material to apply Tr to")
                        return
                    }

                    currMtl transparency = parts[1] toDouble()
                } else if (lineBuff[0] != '#') {
                    // Perhaps we only have whitespace?
                    for (c in lineBuff) {
                        if (c != ' ' && c != '\t') {
                            fHandle close()
                            raise("Invalid line '#{lineBuff}'")
                            return
                        }
                    }
                }

                lineBuff setLength(0)
                if (c == EOF || c == '\0') {
                    break
                }
            } else {
                lineBuff append((c & 0xFF) as Char)
            }
        }

        fHandle close()
    }
}
