#import "Basic";
#import "GL";
#import "Window_Creation";
#import "System";
#import "Input";
#import "File";
#import "Math";
#import "String";

Simp :: #import "Simp";

WINDOW_WIDTH :: 1920;

cube_vao : u32;
cube_vbo : u32;
line_vao : u32;
line_vbo : u32;
tetrahedron_vao : u32;
tetrahedron_vbo : u32;
tetrahedron_ebo : u32;

simplex_vao : u32;
simplex_vbo : u32;
simplex_ebo : u32;

tetrahedron_vertices :: float32.[
    -0.5,  0.5,  0.5,
    -0.5, -0.5,  0.0,
     0.5,  0.0,  0.0,

    -0.5,  0.5, -0.5,
    -0.5, -0.5,  0.0,
     0.5,  0.0,  0.0,

    -0.5,  0.5,  0.5,
    -0.5,  0.5, -0.5,
     0.5,  0.0,  0.0,

    -0.5,  0.5,  0.5,
    -0.5, -0.5,  0.0,
    -0.5,  0.5, -0.5,
];

cube_vertices :: float32.[
    // positions
    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
    -0.5,  0.5, -0.5,
    -0.5, -0.5, -0.5,

    -0.5, -0.5,  0.5,
     0.5, -0.5,  0.5,
     0.5,  0.5,  0.5,
     0.5,  0.5,  0.5,
    -0.5,  0.5,  0.5,
    -0.5, -0.5,  0.5,

    -0.5,  0.5,  0.5,
    -0.5,  0.5, -0.5,
    -0.5, -0.5, -0.5,
    -0.5, -0.5, -0.5,
    -0.5, -0.5,  0.5,
    -0.5,  0.5,  0.5,

     0.5,  0.5,  0.5,
     0.5,  0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5, -0.5,  0.5,
     0.5,  0.5,  0.5,

    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5, -0.5,  0.5,
     0.5, -0.5,  0.5,
    -0.5, -0.5,  0.5,
    -0.5, -0.5, -0.5,

    -0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
     0.5,  0.5,  0.5,
     0.5,  0.5,  0.5,
    -0.5,  0.5,  0.5,
    -0.5,  0.5, -0.5
];

tetrahedron_indices :: u32.[
    0, 1, 2,
    0, 1, 3,
    0, 2, 3,
    1, 2, 3
];

main :: () {
    set_working_directory(path_strip_filename(get_path_of_running_executable()));
    window := create_window(WINDOW_WIDTH, 1080, "sequentialImpulseDemo");
    Simp.set_render_target(window);

    vertexShader := glCreateShader(GL_VERTEX_SHADER);
    vertexShaderSource := VERTEX_SHADER;
    vertexShaderCount := cast(s32) vertexShaderSource.count;
    glShaderSource(vertexShader, 1, *vertexShaderSource.data, *vertexShaderCount);
    glCompileShader(vertexShader);
    success: GLint;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, *success);
    if success == 0 {
        len: GLint;
        glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, *len);
        buf := cast(*u8) alloc(len);
        glGetShaderInfoLog(vertexShader, xx len, xx *len, buf);
        print("ERROR: %\n", to_string(buf));
        free(buf);

        glDeleteShader(vertexShader);
    }

    fragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
    fragmentShaderSource := FRAGMENT_SHADER;
    fragmentShaderCount := cast(s32) fragmentShaderSource.count;
    glShaderSource(fragmentShader, 1, *fragmentShaderSource.data, *fragmentShaderCount);
    glCompileShader(fragmentShader);
    successDeux: GLint;
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, *successDeux);
    if successDeux == 0 {
        len: GLint;
        glGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH, *len);
        buf := cast(*u8) alloc(len);
        glGetShaderInfoLog(fragmentShader, xx len, xx *len, buf);
        print("ERROR2: %\n", to_string(buf));
        free(buf);

        glDeleteShader(fragmentShader);
    }

    shaderProgram := glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    successTres: GLint;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, *successTres);
    if successTres == 0 {
        len: GLint;
        glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, *len);
        buf := cast(*u8) alloc(len);
        defer free(buf);
        glGetShaderInfoLog(shaderProgram, xx len, xx *len, buf);
        print("ERROR3: %\n", to_string(buf));

        glDeleteShader(shaderProgram);
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
    }

    // TODO: cleanup all of these repeated gens and binds
    glGenVertexArrays(1, *line_vao);
    glGenBuffers(1, *line_vbo);

    glGenVertexArrays(1, *simplex_vao);
    glGenBuffers(1, *simplex_ebo);
    glGenBuffers(1, *simplex_vbo);

    glGenVertexArrays(1, *tetrahedron_vao);
    glGenBuffers(1, *tetrahedron_vbo);
    glBindVertexArray(tetrahedron_vao);
    glBindBuffer(GL_ARRAY_BUFFER, tetrahedron_vbo);
    glBufferData(GL_ARRAY_BUFFER, tetrahedron_vertices.count * size_of(float32), tetrahedron_vertices.data, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), null);
    glEnableVertexAttribArray(0);

    // cube
    glGenVertexArrays(1, *cube_vao);
    glGenBuffers(1, *cube_vbo);
    glBindVertexArray(cube_vao);
    glBindBuffer(GL_ARRAY_BUFFER, cube_vbo);
    glBufferData(GL_ARRAY_BUFFER, cube_vertices.count * size_of(float32), cube_vertices.data, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, false, 3 * size_of(float), null);
    glEnableVertexAttribArray(0);

    tetrahedron_pos := Vector3.{-2.0, 0.0, 0.0};
    cube_pos := Vector3.{0.0, 0.0, 0.0};

    camera_pos := xyz(0.0, 0.0, 10.0);
    camera_front := xyz(0.0, 0.0, -1.0);
    camera_up := xyz(0.0, 1.0, 0.0);
    delta_time := 0.0;
    last_frame := 0.0;
    pitch := 0.0;
    yaw := -90.0;
    roll := 0.0;
    fov := 45.0;
    sensitivity := 0.1;
    scale_factor := 1.0;
    collision : bool;
    collision_normal : Vector3;
    face_normals : [] Face_Normal;

    running := true;
    while running {
        reset_temporary_storage();
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT then running = false;
            if it.type == .KEYBOARD && it.key_pressed && it.key_code == .BACKSPACE then running = false;
        }

        current_frame : float32 = xx seconds_since_init();
        delta_time = current_frame - last_frame;
        last_frame = current_frame;

        tetrahedron_pos_increment := 0.01;
        if input_button_states[Key_Code.ARROW_LEFT] & .DOWN {
            tetrahedron_pos.x -= tetrahedron_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_RIGHT] & .DOWN {
            tetrahedron_pos.x += tetrahedron_pos_increment;
        }
        if input_button_states[#char "["] & .DOWN {
            tetrahedron_pos.x -= tetrahedron_pos_increment * tetrahedron_pos_increment;
        }
        if input_button_states[#char "]"] & .DOWN {
            tetrahedron_pos.x += tetrahedron_pos_increment * tetrahedron_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_DOWN] & .DOWN {
            tetrahedron_pos.y -= tetrahedron_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_UP] & .DOWN {
            tetrahedron_pos.y += tetrahedron_pos_increment;
        }
        if tetrahedron_pos.x > 7.0 || tetrahedron_pos.x < -7.0 {
            tetrahedron_pos.x *= -1.0;
        }
        if tetrahedron_pos.y > 7.0 || tetrahedron_pos.y < -7.0 {
            tetrahedron_pos.y *= -1.0;
        }

        tetrahedron_world_pos := to_world_pos(tetrahedron_vertices, tetrahedron_pos);
        cube_world_pos := to_world_pos(cube_vertices, cube_pos);
        simplex_points : [..] Vector3;
        simplex_points.allocator = temp;
        polytope : [] Vector3;
        collision = gjk(tetrahedron_world_pos, cube_world_pos, *simplex_points);
        if collision {
            new_context : Context;
            new_context.allocator = temp;
            push_context new_context {
                polytope, face_normals = epa(simplex_points, tetrahedron_world_pos, cube_world_pos);
            }
            print("\nThere is a collision!");
        }
        else {
            print("\nNO COLLISION!");
        }

        camera_speed := 5 * delta_time;

        if input_button_states[#char "W"] & .DOWN {
            camera_pos += camera_speed * camera_front;
        }
        if input_button_states[#char "S"] & .DOWN {
            camera_pos -= camera_speed * camera_front;
        }
        if input_button_states[#char "A"] & .DOWN {
            camera_pos -= normalize(cross(camera_front, camera_up), fallback=.{z=1}) * camera_speed;
        }
        if input_button_states[#char "D"] & .DOWN {
            camera_pos += normalize(cross(camera_front, camera_up), fallback=.{z=1}) * camera_speed;
        }

        y_offset := mouse_delta_y * sensitivity;
        x_offset := mouse_delta_x * sensitivity;

        yaw += x_offset;
        pitch -= y_offset;

        if pitch > 89.0 {
            pitch = 89.0;
        }
        if pitch < -89.0 {
            pitch = -89.0;
        }

        direction_x := cos(deg_to_rad(yaw) * cos(deg_to_rad(pitch)));
        direction_y := sin(deg_to_rad(pitch));
        direction_z := sin(deg_to_rad(yaw) * cos(deg_to_rad(pitch)));
        camera_front = normalize(xyz(direction_x, direction_y, direction_z), fallback=.{z=1});

        glEnable(GL_DEPTH_TEST);
        //glClearColor(to_rgb(254), to_rgb(251), to_rgb(200), 1.0);
        glClearColor(to_rgb(71), to_rgb(78), to_rgb(104), 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram(shaderProgram);

        view_matrix := make_look_at_matrix( camera_pos
                                          , camera_pos + camera_front
                                          , camera_up
                                          , false);
        view_loc := glGetUniformLocation(shaderProgram, "view");
        glUniformMatrix4fv(view_loc, 1, GL_TRUE, view_matrix.floats.data);

        projection_matrix := make_projection_matrix(deg_to_rad(fov)
                                                   , 1920.0 / 1080.0
                                                   , 0.1
                                                   , 100.0);
        projection_loc := glGetUniformLocation(shaderProgram, "proj");
        glUniformMatrix4fv(projection_loc, 1, GL_TRUE, projection_matrix.floats.data);
        model_loc := glGetUniformLocation(shaderProgram, "model");

        color_loc := glGetUniformLocation(shaderProgram, "shapeColor");
        glUniform3f(color_loc, 1.0, 0.0, 0.0);

        // wireframe
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        // tetrahedron
        glBindVertexArray(tetrahedron_vao);
        m_trans := make_translation_matrix4(tetrahedron_pos);
        m_scaled := make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result := m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 12);


        // cube
        glBindVertexArray(cube_vao);
        glUniform3f(color_loc, 0.0, 0.0, 1.0);
        m_trans = make_translation_matrix4(cube_pos);
        m_scaled = make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 36);

        if collision {
            simplex_vertices := to_vertices(simplex_points);

            // simplex tetrahedron
            glBindVertexArray(simplex_vao);
            glBindBuffer(GL_ARRAY_BUFFER, simplex_vbo);
            glBufferData(GL_ARRAY_BUFFER, simplex_vertices.count * size_of(float32), simplex_vertices.data, GL_STATIC_DRAW);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, simplex_ebo);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, tetrahedron_indices.count * size_of(u32), tetrahedron_indices.data, GL_STATIC_DRAW);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), null);
            glEnableVertexAttribArray(0);

            glUniform3f(color_loc, 0.0, 1.0, 0.0);
            m_trans = make_translation_matrix4(.{0.0, 0.0, 0.0}); // no need to translate as simplex is already based off actual points
            m_scaled = make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
            m_result = m_trans * m_scaled;
            glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
            glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, null);
            //glDrawArrays(GL_TRIANGLES, 0, 12);

            // face normals
            face_normals_with_polytope : [..] Vector3;
            face_normals_with_polytope.allocator = temp;
            for n, i : face_normals {
                face := i * 3;
                array_add(*face_normals_with_polytope,
                          n.position);
                array_add(*face_normals_with_polytope, n.normal);
            }
            face_normals_vertices := to_vertices(face_normals_with_polytope);
            glBindVertexArray(line_vao);
            glBindBuffer(GL_ARRAY_BUFFER, line_vbo);
            glBufferData(GL_ARRAY_BUFFER, face_normals_vertices.count * size_of(float32), face_normals_vertices.data, GL_STATIC_DRAW);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), null);
            glEnableVertexAttribArray(0);

            glUniform3f(color_loc, to_rgb(248), to_rgb(222), to_rgb(34));
            m_trans = make_translation_matrix4(.{0.0, 0.0, 0.0});
            m_result = m_trans;
            glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
            glDrawArrays(GL_LINES, 0, xx face_normals_vertices.count);

            if polytope.count > 4 {
                // polytope
                polytope_vertices := to_vertices(polytope);
                glBindVertexArray(simplex_vao);
                glBindBuffer(GL_ARRAY_BUFFER, simplex_vbo);
                glBufferData(GL_ARRAY_BUFFER, polytope_vertices.count * size_of(float32), polytope_vertices.data, GL_STATIC_DRAW);
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), null);
                glEnableVertexAttribArray(0);

                glUniform3f(color_loc, to_rgb(171), to_rgb(32), to_rgb(253));
                m_trans = make_translation_matrix4(.{0.0, 0.0, 0.0});
                m_scaled = make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
                m_result = m_trans * m_scaled;
                glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
                glDrawArrays(GL_TRIANGLES, 0, xx polytope_vertices.count);
            }
        }

        // wireframe off
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        // center square dot
        glBindVertexArray(cube_vao);
        glUniform3f(color_loc, 0.0, 0.0, 0.0);
        cube_pos2 := Vector3.{0.0, 0.0, 0.0};
        m_trans = make_translation_matrix4(cube_pos2);
        scale_factor2 := 0.05;
        m_scaled = make_scale_matrix4(xyz(scale_factor2, scale_factor2, scale_factor2));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);

        Simp.swap_buffers(window);
    }
}

find_closest_point_on_triangle_for_point :: (p : Vector3, face : Face) -> Vector3 {
    // cross_products a little expensive, this achieves the same result using the Lagrange identity
    // "(a `cross` b) `dot` (c `cross` d) == (a `dot` c) (b `dot` d) - (a `dot` d) (b `dot` c)"
    // snom = d1
    // sdenom = -d3
    // tnom = d2
    // tdenom = -d6
    // unom = d4 - d3
    // udenom = d5 - d6

    a := face.a;
    b := face.b;
    c := face.c;

    // Check if P in vertex region outside vertex A
    ab := b - a;
    ac := c - a;
    ap := p - a;

    d1 := dot_product(ab, ap);
    d2 := dot_product(ac, ap);
    if (d1 <= 0.0 && d2 <= 0.0) then return a; // barycentric coordinates (1, 0, 0)

    // Check if P in vertex region outside vertex B
    bp := p - b;
    d3 := dot_product(ab, bp);
    d4 := dot_product(ac, bp);
    if (d3 >= 0.0 && d4 <= d3) then return b; // barycentric coordinates (0, 1, 0)

    // Check if P in edge region of AB, if so return proijection of P onto AB
    vc := d1 * d4 - d3 * d2;
    if (vc < 0.0 && d1 >= 0.0 && d3 <= 0.0) {
        v := d1 / (d1 - d3);
        return a + v * ab; // barycentric coordinates (1 - v, v, 0)
    }

    // Check if P in vertex region outside vertex C
    cp := p - c;
    d5 := dot_product(ab, cp);
    d6 := dot_product(ac, cp);
    if (d6 >= 0.0 && d5 <= d6) return c; // barycentric coordinates (0, 0, 1)

    // Check if P in edge region of AC, if so return projection of P onto AC
    vb := d5 * d2 - d1 * d6;
    if (vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0) {
        w := d2 / (d2 - d6);
        return a + w * ac; // barycentric coordinates (1 - w, 0, w)
    }

    // Check if P in region of BC, if so return projection of P onto BC
    va := d3 * d6 - d5 * d4;
    if (va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0) {
        w := (d4 - d3) / ((d4 - d3) + (d5 - d6));
        return b + w * (c - b); // barycentric coordinates (0, 1 - w, w)
    }

    // P inside face region. Compute Q through it's barycentric compute (u, v, w)
    denom := 1.0 / (va + vb + vc);
    v := vb * denom;
    w := vc * denom;

    return a + v * ab + w * ac; // == uA + vB + wC, u == va * denom == 1 - v - w
}

is_point_outside_of_plane :: (p : Vector3, f : Face) -> bool {
    // might need to use a different version for tetrahedron (because we cannot assume winding order)
    a := f.a;
    b := f.b;
    c := f.c;
    cross := cross_product(b - a, c - a);

    return (dot_product(p - a, cross) >= 0.0);
}

find_closest_point_on_polyhedron_for_point :: (point : Vector3, faces : [] Face) -> Vector3 {
    closest_point := point;
    best_square_distance := FLOAT32_MAX;

    for f : faces {
        q := find_closest_point_on_triangle_for_point(point, f);
        sq_dist := dot_product(q - point, q - point);
        if sq_dist < best_square_distance {
            best_square_distance = sq_dist;
            closest_point = q;
        }
    }

    return closest_point;
}

to_edges :: (arr : [] Vector3) -> [..] Edge {
    edge_pairs : [..] Edge;
    edge_pairs.allocator = temp;

    i := 0;
    while i < arr.count {
        array_add(*edge_pairs
                  , Edge.{arr[i]    , arr[i + 1]}
                  , Edge.{arr[i + 1], arr[i + 2 ]}
                  , Edge.{arr[i + 2], arr[i]}
                 );
        i += 3;
    }

    return edge_pairs;
}

find_centroid :: (a : Vector3, b : Vector3, c : Vector3) -> Vector3 {
    return Vector3.{ (a.x + b.x + c.x) / 3
                     , (a.y + b.y + c.y) / 3
                     , (a.z + b.z + c.z) / 3
                   };
}

get_face_normals_and_min_face :: (faces : [] Face, polytope : [] Vector3) -> [] Face_Normal, s64 {
    min_face := 0;
    min_distance := FLOAT32_MAX;
    face_normals : [..] Face_Normal;
    face_normals.allocator = temp;

    for f, i : faces {
        a := f.a;
        b := f.b;
        c := f.c;

        normal := normalize(cross_product(b - a, c - a), fallback=.{z=1});
        centroid := find_centroid(a, b, c);
        distance := dot_product(normal, a);
        if distance < 0 {
            normal *= -1;
            distance *= -1;
        }

        // We need to add the centroid because the normal is originally
        // displayed at origin, rather than off the face (because points
        // "a, b, c" are all just points from origin to A, etc)
        normal = centroid + normal;
        array_add(*face_normals, .{normal, distance, centroid});

        if distance < min_distance {
            min_face = i;
            min_distance = distance;
        }
    }
    return face_normals, min_face;
}

epa :: (polytope : [..] Vector3, verticesA : [] Vector3, verticesB : [] Vector3) -> [] Vector3, [] Face_Normal {
    // Initially we find the closest face to the origin.
    // If the face of point 'v' on the polytope "sees" the support point,
    // we need to remove that edge so that we can add the new support point
    // to the polytope. (A face with normal n and vertex v "sees" support point 's'
    // if (s - v) `dot_product` n > 0 )
    //
    // An edge that is shared between two faces that "see" the support point is removed.
    // Then for all faces that "see" the support point, have their remaining edges added
    // along with the new support to make the new faces. Finally the new faces are added
    // to the polytope.

    // TODO: We need to clean this up, too many copies of the same points,
    // make one source of "truth" (prob with indices refering to original)
    faces : [..] Face = get_faces(polytope, true);
    normals : [] Face_Normal;
    min_face : s64;
    keep_looping := true;
    loop_num := 0;
    // Sometimes when the origin is very close to the edge of the minkowski difference,
    // there is numerical instability. So we keep track of the smallest value of
    // length(projection(support_point, v) - v)
    smallest_length : float32 = FLOAT32_MAX;
    smallest_length_polytope : [] Vector3;
    smallest_length_normals : [] Face_Normal;
    normals, min_face = get_face_normals_and_min_face(faces, polytope);

    // To loop through any new polytopes until a point of the polytope is also a point
    // on the minkowski difference (support point and v have the same distance).
    while keep_looping && loop_num < 10 {
        if loop_num > 0 {
            array_reset(*faces);
            faces = get_faces(polytope, false);
        }

        min_normal := normals[min_face].normal;
        support_point := get_support(verticesA, verticesB, min_normal);
        min_v := find_closest_point_on_polyhedron_for_point(support_point, faces);
        proj := projection(support_point, min_v);

        if proj == min_v {
            keep_looping = false;
        }
        else {
            faces_to_remove : [..] s64;
            edges : [..] Edge;

            for f, i : faces {
                v := find_centroid(f.a, f.b, f.c);
                n := normals[i].normal;

                // We've got remember to subtract from v, otherwise the vector would be the origin to
                // the point (I was having trouble with the normals being wrong and creating a concave
                // simplex)
                if dot_product((support_point - v), n - v) > 0 {
                    array_add(*faces_to_remove, i);

                    points_for_edges : [..] Vector3;
                    array_add(*points_for_edges, f.a, f.b, f.c);
                    edges_in_face := to_edges(points_for_edges);

                    for edge : edges_in_face {
                        add_if_unique_edge(*edges, edge);
                    }
                }
            }

            // Remove old faces before adding edges/points for new face (using new support point).
            f := faces_to_remove.count - 1;
            while f >= 0 {
                array_unordered_remove_by_index(*faces, faces_to_remove[f]);
                f -= 1;
            }
            for edge : edges {
                array_add_if_unique_face(*faces, Face.{edge.a, edge.b, support_point});
            }

            array_reset(*polytope);
            for f : faces {
                array_add(*polytope, f.a, f.b, f.c);
            }
        }

        // Make sure to calculate normals with new faces
        normals, min_face = get_face_normals_and_min_face(faces, polytope);

        current_length := length(proj - min_v);
        if current_length < smallest_length {
            smallest_length = current_length;
            smallest_length_polytope = polytope;
            smallest_length_normals = normals;
        }
        loop_num += 1;
    }

    return smallest_length_polytope, smallest_length_normals;
}

get_faces :: (polytope : [] Vector3, iterate_tetrahedron_indices : bool) -> [..] Face {
    faces : [..] Face;
    faces.allocator = temp;
    i := 0;
    if iterate_tetrahedron_indices {
        while i < tetrahedron_indices.count {
            array_add(*faces, Face.{ polytope[tetrahedron_indices[i]]
                                     , polytope[tetrahedron_indices[i + 1]]
                                     , polytope[tetrahedron_indices[i + 2]]
                                   });
            i += 3;
        }
    } else {
        while i < polytope.count {
            array_add(*faces, Face.{ polytope[i]
                                     , polytope[i + 1]
                                     , polytope[i + 2]
                                   });
            // polytope should always be divisible by 3
            i += 3;
        }
    }

    return faces;
}

Face :: struct {
    a : Vector3;
    b : Vector3;
    c : Vector3;
}

Edge :: struct {
    a : Vector3;
    b : Vector3;
}

Face_Normal :: struct {
    normal : Vector3;
    distance : float32;
    position : Vector3;
}

array_add_if_unique_face :: (faces : *[..] Face, face : Face) {
     found := array_find_face(<<faces, face);
     if !found {
         array_add(faces, face);
     }
 }

array_find_face :: (arr : [] Face, face: Face) -> bool {
    for f : arr {
        if
            f.a == face.a && f.b == face.b && f.c == face.c
            || f.a == face.b && f.b == face.c && f.c == face.a
            || f.a == face.c && f.b == face.a && f.c == face.b
            then return true;

    }
    return false;
}

add_if_unique_edge :: (edges : *[..] Edge, edge : Edge) {
    forward_found, forward_index := array_find_edge_pair(<<edges, Edge.{edge.a, edge.b});
    reverse_found, reverse_index := array_find_edge_pair(<<edges, Edge.{edge.b, edge.a});
    if reverse_found {
        array_unordered_remove_by_index(edges, reverse_index);
    }
    else if forward_found {
        array_unordered_remove_by_index(edges, forward_index);
    }
    else {
        array_add(edges, .{edge.a, edge.b});
    }
}

array_find_edge_pair :: (arr : [] Edge, edge : Edge) -> bool, s64 {
    // based off of `array_find` in Array.jai`
    for x : arr {
        if x.a == edge.a && x.b == edge.b then return true, it_index;
    }
    return false, -1; // Not found
}

support :: (vertices : [] Vector3, direction : Vector3) -> Vector3 {
    furthest_distance := -FLOAT32_MAX;
    furthest_vertex : Vector3;

    for v : vertices {
        distance := dot_product(v, direction);
        if distance > furthest_distance {
            furthest_distance = distance;
            furthest_vertex = v;
        }
    }

    return furthest_vertex;
}

get_support :: (verticesA : [] Vector3, verticesB : [] Vector3, direction : Vector3) -> Vector3 {
    return support(verticesA, direction)
        - support(verticesB, -direction);
}

add_support :: (simplex_points : *[..] Vector3, verticesA : [] Vector3, verticesB : [] Vector3, direction : Vector3) -> bool {
    new_point := get_support(verticesA, verticesB, direction);
    array_add(simplex_points, new_point);
    return dot_product(direction, new_point) >= 0;
}

Evolve_Result :: enum u32 {
    NO_INTERSECTION;
    FOUND_INTERSECTION;
    STILL_EVOLVING;
}

gjk :: (verticesA : [] Vector3, verticesB : [] Vector3, simplex_points : *[..] Vector3) -> bool {
    evolve_result : Evolve_Result = .STILL_EVOLVING;
    direction := Vector3.{1, 0, 0};
    while evolve_result == .STILL_EVOLVING {
        evolve_result = evolve_simplex(simplex_points, verticesA, verticesB, *direction);
    }

    // or else not found
    return ifx evolve_result == .FOUND_INTERSECTION then true else false;
}

evolve_simplex :: (simplex_points : *[..] Vector3, verticesA : [] Vector3, verticesB : [] Vector3, direction : *Vector3) -> Evolve_Result {
    if simplex_points.count == {
        case 0;
            direction = *(average_point(verticesB) - average_point(verticesA));

        case 1;
            // flip the direction
            direction = *(-1 * (average_point(verticesB) - average_point(verticesA)));

        case 2;
            // line ab is the line formed by the first 2 vertices
            ab := simplex_points.data[1] - simplex_points.data[0];
            // line a0 is the line from the first vertex to the origin
            a0 := -simplex_points.data[0];

            temp := cross_product(ab, a0);
            direction = *cross_product(temp, ab);

        case 3;
            ac := simplex_points.data[2] - simplex_points.data[0];
            ab := simplex_points.data[1] - simplex_points.data[0];
            direction = *cross_product(ac, ab);

            // ensure that it points toward the origin
            a0 := -simplex_points.data[0];
            if (dot_product(direction, a0) < 0) then direction = *(-1 * <<direction);

        case 4;
            // calculate the 3 edges of interest
            da := simplex_points.data[3] - simplex_points.data[0];
            db := simplex_points.data[3] - simplex_points.data[1];
            dc := simplex_points.data[3] - simplex_points.data[2];

            // calculate direction to the origin
            d0 := -simplex_points.data[3];

            // check triangles a-b-d, b-c-d, and c-a-d
            abd_norm := cross_product(da, db);
            bcd_norm := cross_product(db, dc);
            cad_norm := cross_product(dc, da);

            if dot_product(abd_norm, d0) > 0 {
                // origin is outside of a-b-d, eleminate c
                array_unordered_remove_by_index(simplex_points, 2);
                direction = *abd_norm;
            }
            else if dot_product(bcd_norm, d0) > 0 {
                // origin is outside of triangle b-c-d, eliminate a
                array_unordered_remove_by_index(simplex_points, 0);
                direction = *bcd_norm;
            }
            else if dot_product(cad_norm, d0) > 0 {
                // origin is outside of c-a-d, eliminate b
                array_unordered_remove_by_index(simplex_points, 1);
                direction = *cad_norm;
            }
            else {
                // the origin is inside of all of the triangles
                return Evolve_Result.FOUND_INTERSECTION;
            }

        case;
            print("Can't have a simplex with % vertices!", simplex_points.count);
    }
    evolve_result := ifx add_support(simplex_points, verticesA, verticesB, direction)
        then Evolve_Result.STILL_EVOLVING else Evolve_Result.NO_INTERSECTION;

    return evolve_result;
}

average_point :: (vertices : [] Vector3) -> Vector3 {
    avg : Vector3;
    for v : vertices {
        avg.x += v.x;
        avg.y += v.y;
        avg.z += v.z;
    }
    avg.x /= vertices.count;
    avg.y /= vertices.count;
    avg.z /= vertices.count;

    return avg;
}

to_world_pos :: (vertices : [] float32, pos : Vector3) -> [..] Vector3 {
    vertices_vec3 : [..] Vector3;
    vertices_vec3.allocator = temp;
    if vertices.count % 3 == 0 {
        i := 0;
        while i != vertices.count {
            array_add(*vertices_vec3
                      , .{ vertices.data[i] + pos.x
                      , vertices.data[i+1] + pos.y
                      , vertices.data[i+2] + pos.z });
            i += 3;
        }
    }

    return vertices_vec3;
}

to_vertices :: (vs : [] Vector3) -> [] float32 {
    verts : [..] float32;
    verts.allocator = temp;
    for v : vs {
        array_add(*verts, v.x, v.y, v.z);
    }
    return verts;
}

to_rgb :: (num : int) -> float32 {
    return cast(float32) num / 255;
}

deg_to_rad :: (deg: float) -> float {
    return deg * (PI / 180);
}

projection :: (a : Vector3, b : Vector3) -> Vector3 {
    return ((dot_product(a, b)) / (dot_product(b, b))) * b;
}

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
    gl_Position = proj * view * model * vec4(aPos, 1.0);
}
DONE

FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

uniform vec3 shapeColor;

void main() {
    FragColor = vec4(shapeColor, 0.5);
}
DONE
