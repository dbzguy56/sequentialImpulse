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

triangle_vao : u32;
triangle_vbo : u32;
square_vao : u32;
square_vbo : u32;
square_ebo : u32;
cube_vao : u32;
cube_vbo : u32;
tetrahedron_vao : u32;
tetrahedron_vbo : u32;
tetrahedron_ebo : u32;

simplex_vao : u32;
simplex_vbo : u32;
simplex_ebo : u32;

/*
triangle_vertices :: float32.[
    -0.5, 0.5,
    0.5, 0.0,
    -0.5, -0.5
];
*/
square_vertices :: float32.[
    -0.5, -0.5,
    -0.5, 0.5,
    0.5, -0.5,
    0.5, 0.5
];

square_indices :: u32.[
    0, 1, 3,
    0, 2, 3
];

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
/*
    glGenVertexArrays(1, *triangle_vao);
    glGenBuffers(1, *triangle_vbo);
    glBindVertexArray(triangle_vao);
    glBindBuffer(GL_ARRAY_BUFFER, triangle_vbo);
    glBufferData(GL_ARRAY_BUFFER, triangle_vertices.count * size_of(float32), triangle_vertices.data, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 2, GL_FLOAT, false, 2 * size_of(float), null);
    glEnableVertexAttribArray(0);
*/
    glGenVertexArrays(1, *square_vao);
    glGenBuffers(1, *square_ebo);
    glGenBuffers(1, *square_vbo);
    glBindVertexArray(square_vao);
    glBindBuffer(GL_ARRAY_BUFFER, square_vbo);
    glBufferData(GL_ARRAY_BUFFER, square_vertices.count * size_of(float32), square_vertices.data, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, square_ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, square_indices.count * size_of(u32), square_indices.data, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * size_of(float), null);
    glEnableVertexAttribArray(0);

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

    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, tetrahedron_ebo);
    //glBufferData(GL_ELEMENT_ARRAY_BUFFER, tetrahedron_indices.count * size_of(u32), tetrahedron_indices.data, GL_STATIC_DRAW);

    //tetrahedron_pos := Vector3.{-7.0, 0.0, 0.0};
    //cube_pos := Vector3.{0.0, 0.0, 0.0};
    triangle_pos := Vector3.{-7.0, 0.0, 0.0};
    square_pos := Vector3.{0.0, 0.0, 0.0};
    //square_pos := Vector3.{-3.0, 2.0, 0.0};
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
    // default just the negative to trigger collision check
    last_tetrahedron_world_pos := to_world_pos(tetrahedron_vertices, -triangle_pos);
    last_cube_world_pos := to_world_pos(cube_vertices, -square_pos);


    running := true;
    while running {
        reset_temporary_storage();
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT then running = false;
            if it.type == .KEYBOARD && it.key_pressed && it.key_code == .BACKSPACE then running = false;
        }

        current_frame : float32 = xx get_time();
        delta_time = current_frame - last_frame;
        last_frame = current_frame;

        triangle_pos_increment := 0.01;
        if input_button_states[Key_Code.ARROW_LEFT] & .DOWN {
            triangle_pos.x -= triangle_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_RIGHT] & .DOWN {
            triangle_pos.x += triangle_pos_increment;
        }
        if input_button_states[#char "["] & .DOWN {
            triangle_pos.x -= triangle_pos_increment * triangle_pos_increment;
        }
        if input_button_states[#char "]"] & .DOWN {
            triangle_pos.x += triangle_pos_increment * triangle_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_DOWN] & .DOWN {
            triangle_pos.y -= triangle_pos_increment;
        }
        if input_button_states[Key_Code.ARROW_UP] & .DOWN {
            triangle_pos.y += triangle_pos_increment;
        }
        if triangle_pos.x > 7.0 || triangle_pos.x < -7.0 {
            triangle_pos.x *= -1.0;
        }
        if triangle_pos.y > 7.0 || triangle_pos.y < -7.0 {
            triangle_pos.y *= -1.0;
        }

        tetrahedron_world_pos := to_world_pos(tetrahedron_vertices, triangle_pos);
        cube_world_pos := to_world_pos(cube_vertices, square_pos);
        simplex_points : [..] Vector3;
        collision : bool;
        collision = gjk(tetrahedron_world_pos, cube_world_pos, *simplex_points);
        if collision {
            //collision_normal = epa(simplex_points, tetrahedron_world_pos, cube_world_pos).normal;
            print("\nThere is a collision!");
        }
        else {
            print("\nNO COLLISION!");
        }
        collision_normal : Vector3;
/*
        if not_equal_pos(last_tetrahedron_world_pos, tetrahedron_world_pos)
            || not_equal_pos(last_cube_world_pos, cube_world_pos) {

            collision = gjk(tetrahedron_world_pos, cube_world_pos, *simplex_points);
            if collision {
                //collision_normal = epa(simplex_points, tetrahedron_world_pos, cube_world_pos).normal;
                print("\nThere is a collision!");
            }
            else {
                print("\nNO COLLISION!");
            }
        }
        last_tetrahedron_world_pos = tetrahedron_world_pos;
        last_cube_world_pos = cube_world_pos;
        */
/*
        triangle_world_pos := to_world_pos(triangle_vertices, triangle_pos);
        square_world_pos := to_world_pos(square_vertices, square_pos);
        //print("\ntriangle_world_pos: %, square_world_pos: %", triangle_world_pos, square_world_pos);
        collision := gjk(triangle_world_pos, square_world_pos);
        if collision {
            print("\nThere is a collision!");
        }
        else {
            print("\nNO COLLISION!");
        }
*/
        camera_speed := 5 * delta_time;

        if input_button_states[#char "W"] & .DOWN {
            camera_pos += camera_speed * camera_front;
        }
        if input_button_states[#char "S"] & .DOWN {
            camera_pos -= camera_speed * camera_front;
        }
        if input_button_states[#char "A"] & .DOWN {
            camera_pos -= normalize_or_z_axis(cross(camera_front, camera_up)) * camera_speed;
        }
        if input_button_states[#char "D"] & .DOWN {
            camera_pos += normalize_or_z_axis(cross(camera_front, camera_up)) * camera_speed;
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
        camera_front = normalize_or_z_axis(xyz(direction_x, direction_y, direction_z));

        glEnable(GL_DEPTH_TEST);
        glClearColor(to_rgb(254), to_rgb(251), to_rgb(200), 1.0);
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
        projection_loc := glGetUniformLocation(shaderProgram, "projection");
        glUniformMatrix4fv(projection_loc, 1, GL_TRUE, projection_matrix.floats.data);
        model_loc := glGetUniformLocation(shaderProgram, "model");

        color_loc := glGetUniformLocation(shaderProgram, "shapeColor");
        glUniform3f(color_loc, 1.0, 0.0, 0.0);


        // tetrahedron
        glBindVertexArray(tetrahedron_vao);
        m_trans := make_translation_matrix4(triangle_pos);
        m_scaled := make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result := m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 12);

        // wireframe
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        // cube
        glBindVertexArray(cube_vao);
        glUniform3f(color_loc, 0.0, 0.0, 1.0);
        m_trans = make_translation_matrix4(square_pos);
        m_scaled = make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 36);

        if collision {
            simplex_vertices := to_vertices(simplex_points);
            //print("\n\t simplex vertices: %", simplex_vertices);

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
        }

        // wireframe off
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        // center square dot
        glBindVertexArray(cube_vao);
        glUniform3f(color_loc, 0.0, 0.0, 0.0);
        square_pos2 := Vector3.{0.0, 0.0, 0.0};
        m_trans = make_translation_matrix4(square_pos2);
        scale_factor2 := 0.05;
        m_scaled = make_scale_matrix4(xyz(scale_factor2, scale_factor2, scale_factor2));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);

/*
        // triangle
        glBindVertexArray(triangle_vao);
        m_trans := make_translation_matrix4(triangle_pos);
        m_scaled := make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result := m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        // square
        glBindVertexArray(square_vao);
        glUniform3f(color_loc, 0.0, 0.0, 1.0);
        m_trans = make_translation_matrix4(square_pos);
        m_scaled = make_scale_matrix4(xyz(scale_factor, scale_factor, scale_factor));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);

        // center square dot
        glBindVertexArray(square_vao);
        glUniform3f(color_loc, 0.0, 0.0, 0.0);
        square_pos2 := Vector3.{0.0, 0.0, 0.01};
        m_trans = make_translation_matrix4(square_pos2);
        scale_factor2 := 0.05;
        m_scaled = make_scale_matrix4(xyz(scale_factor2, scale_factor2, scale_factor2));
        m_result = m_trans * m_scaled;
        glUniformMatrix4fv(model_loc, 1, GL_TRUE, m_result.floats.data);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
*/
        Simp.swap_buffers(window);
    }
}

/*
Collision_Points :: struct {
    normal : Vector3;
    depth : float32;
    has_collision : bool;
}

Edge_Pair :: struct {
    a : u32;
    b : u32;
}

Face_Normal :: struct {
    normal : Vector3;
    distance : float32;
}

get_face_normals :: (polytope : [] Vector3, faces : [] u32) -> [..] Face_Normal, s64 {
    face_normals : [..] Face_Normal;
    min_triangle : s64;
    min_distance := FLOAT32_MAX;

    i := 0;
    while i < faces.count {
        //print("\nloop line 472");
        a := polytope[faces[i]];
        b := polytope[faces[i + 1]];
        c := polytope[faces[i + 2]];

        normal : Vector3 = normalize_or_z_axis(cross_product(b - a, c - a));
        distance := dot_product(normal, a);

        if distance < 0 {
            normal *= -1;
            distance *= -1;
        }

        array_add(*face_normals, Face_Normal.{normal, distance});

        if distance < min_distance {
            min_triangle = i / 3;
            min_distance = distance;
        }

        i += 3;
    }

    return (face_normals, min_triangle);
}

add_if_unique_edge :: (edges : *[..] Edge_Pair, faces : [] u32, a : s64, b : s64) {
    forward := array_find_edge_pair(<<edges, Edge_Pair.{faces[a], faces[b]});
    reverse := array_find_edge_pair(<<edges, Edge_Pair.{faces[b], faces[a]});
    //print("\nreverse: %, edge_pair: %, \n\tedges: %", reverse, Edge_Pair.{faces[b], faces[a]}, (<<edges));

    // if reverse exists
    if reverse != -1 && (<<edges).count > 0 {
        array_unordered_remove_by_index(edges, reverse);
    }
    else if forward != -1 && (<<edges).count > 0 {
        array_unordered_remove_by_index(edges, forward);
    }
    else {
        //print("\nAdding edge: %,  to list: \n\t%", Edge_Pair.{faces[a], faces[b]}, <<edges);
        array_add(edges, .{faces[a], faces[b]});
    }
}

epa :: (simplex_points : [..] Vector3, verticesA : [] Vector3, verticesB : [] Vector3) -> Collision_Points {
    polytope := simplex_points;
    faces : [..] u32;
    array_copy(*faces, tetrahedron_indices);

    face_normals, min_face := get_face_normals(polytope, faces);

    min_normal : Vector3;
    min_distance := FLOAT32_MAX;

    while min_distance == FLOAT32_MAX {
        //print("\nloop line 524");
        min_normal = face_normals[min_face].normal;
        min_distance = face_normals[min_face].distance;

        support_vector := get_support(verticesA, verticesB, min_normal);
        s_distance := dot_product(min_normal, support_vector);

        if abs(s_distance - min_distance) > 0.001 {
            min_distance = FLOAT32_MAX;
            unique_edges : [..] Edge_Pair;
            //print("\nface_normals.count = %", face_normals.count);
            // add only unique edges, since two faces can result in same support point being added
            i := 0;
            while i < face_normals.count {
                //print("\nloop line 538");
                if same_direction(face_normals[i].normal, support_vector) {
                    f := i * 3;

                    add_if_unique_edge(*unique_edges, faces, f, f + 1);
                    add_if_unique_edge(*unique_edges, faces, f + 1, f + 2);
                    add_if_unique_edge(*unique_edges, faces, f + 2, f);

                    faces[f + 2] = peek(faces);
                    pop(*faces);
                    faces[f + 1] = peek(faces);
                    pop(*faces);
                    faces[f] = peek(faces);
                    pop(*faces);

                    face_normals[i] = peek(face_normals);
                    pop(*face_normals);

                    i -= 1;
                }
                i += 1;
            }

            new_faces : [..] u32;
            for edge : unique_edges {
                print("\nedge = %, polytope.count = %", edge, polytope.count);
                //print("\nedge = %, polytope.count = %, polytope := %", edge, polytope.count, polytope);
                array_add(*new_faces, edge.a);
                array_add(*new_faces, edge.b);
                array_add(*new_faces, xx polytope.count);
            }

            array_add(*polytope, support_vector);
            new_normals, new_min_face := get_face_normals(polytope, new_faces);

            old_min_distance := FLOAT32_MAX;
            i = 0;
            while i < face_normals.count {
                //print("\nloop line 571");
                if face_normals[i].distance < old_min_distance {
                    old_min_distance = face_normals[i].distance;
                    min_face = i;
                }
                i += 1;
            }

            if new_normals[new_min_face].distance < old_min_distance {
                min_face = new_min_face + face_normals.count;
            }

            for f : new_faces {
                //print("\nloop line 584");
                print("\nAdding face: %,  to list: \n\t%", f, faces);
                array_add(*faces, f);
            }
            for n : new_normals {
                //print("\nloop line 588");
                array_add(*face_normals, n);
            }
        }
    }

    return Collision_Points.{ normal = min_normal, depth = min_distance + 0.001, has_collision = true };
}

array_find_edge_pair :: (arr : [] Edge_Pair, edge : Edge_Pair) -> s64 {
    // based off of `array_find` in Array.jai`
    for x, i : arr {
        //print("\nloop line 1241, arr count: %", arr.count);
        if x.a == edge.a && x.b == edge.b then return i;
    }
    return -1; // Not found
}

*/
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
    //print("\n-----Adding point: %, to simplex: %, \n-----verticesA: %, \n-----verticesB: %, \n-----direction: %", new_point, <<simplex_points, verticesA, verticesB, direction);
    array_add(simplex_points, new_point);
    return dot_product(direction, new_point) >= 0;
}

Evolve_Result :: enum u32 {
    NO_INTERSECTION;
    FOUND_INTERSECTION;
    STILL_EVOLVING;
}

gjk :: (verticesA : [] Vector3, verticesB : [] Vector3, simplex_points : *[..] Vector3) -> bool {
    //simplex_points : [..] Vector3;
    evolve_result : Evolve_Result = .STILL_EVOLVING;
    direction := Vector3.{0, 0, 0};
    while evolve_result == .STILL_EVOLVING {
        evolve_result = evolve_simplex(simplex_points, verticesA, verticesB, *direction);
    }

    // or else not found
    return ifx evolve_result == .FOUND_INTERSECTION then true else false;
}

evolve_simplex :: (simplex_points : *[..] Vector3, verticesA : [] Vector3, verticesB : [] Vector3, direction : *Vector3) -> Evolve_Result {
    if simplex_points.count == {
        case 0;
            //print("\n>>>690direction: %, simplex = %", <<direction, <<simplex_points);
            direction = *(average_point(verticesB) - average_point(verticesA));
            //print("\n>>>692direction: %, simplex = %", <<direction, <<simplex_points);
        case 1;
            //print("\n>>>694direction: %, simplex = %", <<direction, <<simplex_points);
            // flip the direction
            direction = *(-1 * (average_point(verticesB) - average_point(verticesA)));
            //direction = *(-1 * <<direction);
            //print("\n>>>695direction: %, simplex = %", <<direction, <<simplex_points);
        case 2;
            // line ab is the line formed by the first 2 vertices
            ab := simplex_points.data[1] - simplex_points.data[0];
            // line a0 is the line from the first vertex to the origin
            a0 := -simplex_points.data[0];

            temp := cross_product(ab, a0);
            direction = *cross_product(temp, ab);
            //print("\n>>>704direction: %, simplex = %", <<direction, <<simplex_points);
        case 3;
            ac := simplex_points.data[2] - simplex_points.data[0];
            ab := simplex_points.data[1] - simplex_points.data[0];
            direction = *cross_product(ac, ab);

            // ensure that it points toward the origin
            a0 := -simplex_points.data[0];
            if (dot_product(direction, a0) < 0) then direction = *(-1 * <<direction);
            //print("\n>>>713 direction: %, simplex = %", <<direction, <<simplex_points);
        case 4;
            //print("\n>>>715direction: %", <<direction);
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
    //print("\n>>>754 simplex = %", <<simplex_points);
    evolve_result := ifx add_support(simplex_points, verticesA, verticesB, direction)
        then Evolve_Result.STILL_EVOLVING else Evolve_Result.NO_INTERSECTION;
    //print("\n>>>757direction = %, simplex = %", <<direction, <<simplex_points);
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

    //print("\n+++++++ verts: %\tavg: %", vertices, avg);
    return avg;
}

to_world_pos :: (vertices : [] float32, pos : Vector3) -> [..] Vector3 {
    vertices_vec3 : [..] Vector3;
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

/* for 2d collisions
support :: (vertices : [] Vector2, direction : Vector2) -> Vector2 {
    furthest_distance := -FLOAT32_MAX;
    furthest_vertex : Vector2;

    for v : vertices {
        distance := dot_product(v, direction);
        if distance > furthest_distance {
            furthest_distance = distance;
            furthest_vertex = v;
        }
    }

    return furthest_vertex;
}

get_support :: (verticesA : [] Vector2, verticesB : [] Vector2, direction : Vector2) -> Vector2 {
    return support(verticesA, direction)
        - support(verticesB, -direction);
}

add_support :: (simplex_points : *[..] Vector2, verticesA : [] Vector2, verticesB : [] Vector2, direction : Vector2) -> bool {
    new_point := get_support(verticesA, verticesB, direction);
    array_add(simplex_points, new_point);
    return dot_product(direction, new_point) >= 0;
}

gjk :: (verticesA : [] Vector2, verticesB : [] Vector2) -> bool {
    simplex_points : [..] Vector2;
    evolve_result : Evolve_Result = .STILL_EVOLVING;
    while evolve_result == .STILL_EVOLVING {
        evolve_result = evolve_simplex(*simplex_points, verticesA, verticesB, *Vector2.{0, 0});
    }

    // or else not found
    return ifx evolve_result == .FOUND_INTERSECTION then true else false;
}

evolve_simplex :: (simplex_points : *[..] Vector2, verticesA : [] Vector2, verticesB : [] Vector2, direction : *Vector2) -> Evolve_Result {
    if simplex_points.count == {
        case 0;
            direction = *(average_point(verticesB) - average_point(verticesA));

        case 1;
            // flip the direction
            direction = *(-1 * <<direction);

        case 2;
            b := simplex_points.data[1];
            c := simplex_points.data[0];

            // line cb is the line formed by the first two vertices
            cb := b - c;
            // is the line from the first vertex to the origin
            c0 := -c;

            // triple cross product calculates direction perp to cb in direction of the origin
            direction = *triple_product(cb, c0, cb);

        case 3;
            // calculate if the simplex contains the origin
            a := simplex_points.data[2];
            b := simplex_points.data[1];
            c := simplex_points.data[0];

            a0 := -a; // vertex 2 to the origin
            ab := b - a; // v2 to v1
            ac := c - a; // v2 to v0

            ab_perp := triple_product(ac, ab, ab);
            ac_perp := triple_product(ab, ac, ac);

            // already know that origin is inside first line segment, v0 to v1,
            // due to last step (creating the direction vector towards origin using triple product of cb, c0, cb)
            if (dot_product(ab_perp, a0) > 0) {
                // origin outside line ab
                // get rid of c and adda new support point in the direction of ab_perp
                direction = *ab_perp;
                //new_point := get_support(verticesA, verticesB, direction);
                //simplex_points.data[0] = new_point;
                array_unordered_remove_by_index(simplex_points, 0);
            }
            else if (dot_product(ac_perp, a0) > 0) {
                // origin outside line ac
                direction = *ac_perp;
                //new_point := get_support(verticesA, verticesB, direction);
                //simplex_points.data[1] = new_point;
                array_unordered_remove_by_index(simplex_points, 1);
            }
            else {
                // origin is inside both ab and ac, so it must be inside the triangle!
                return .FOUND_INTERSECTION;
            }

        case;
            print("Can't have a simplex with % vertices!", simplex_points.count);
    }

     evolve_result := ifx add_support(simplex_points, verticesA, verticesB, direction)
        then Evolve_Result.STILL_EVOLVING else Evolve_Result.NO_INTERSECTION;
    return evolve_result;
}

// To roughly compute average center. Ok as initial direction of simplex
average_point :: (vertices : [] Vector2) -> Vector2 {
    avg : Vector2;
    for v : vertices {
        avg.x += v.x;
        avg.y += v.y;
    }
    avg.x /= vertices.count;
    avg.y /= vertices.count;

    return avg;
}

triple_product :: (a : Vector2, b : Vector2, c : Vector2) -> Vector2 {
    ac := dot_product(a, c);
    bc := dot_product(b, c);

    return b * ac - a * bc;
}

// this is for 2d intersection
to_world_pos :: (vertices : [] float32, pos : Vector3) -> [..] Vector2 {
    vertices_vec2 : [..] Vector2;
    last_x : float32;
    for vertex, i: vertices {
        if i % 2 == 0 {
            last_x = vertex;
        }
        else {
            array_add(*vertices_vec2, .{last_x + pos.x, vertex + pos.y});
        }
    }

    return vertices_vec2;
}
*/


/*
// NOTE: Apparently this example was supposed to be for educational purposes only and is not robust enough to actually work
gjk :: (verticesA : [] Vector2, verticesB : [] Vector2) -> bool {
    a, b, c, d, ao, ab, ac, ab_perp, ac_perp : Vector2;
    index : int;

    posA := average_point(verticesA);
    posB := average_point(verticesB);

    direction := Vector2.{posA.x - posB.x, posA.y - posB.y};
    // if initial direction is zero, set to arbitrary value
    if direction.x == 0.0 && direction.y == 0.0 then direction.x = 1.0;

    a = support(verticesA, verticesB, direction);
    print("\n a = support() = %", a);
    simplex : [3] Vector2;
    simplex[0] = a;

    if dot_product(a, direction) <= 0 {
        print("\nExiting at dot_product 1, dot_product(a, direction) = %", dot_product(a, direction));
        return false; // no collision
    }
    print("\na = %, dot_product(a, direction) = %, -a = % ", a, dot_product(a, direction), -a);
    direction = -a;

    while true {
        a = support(verticesA, verticesB, direction);
        index += 1;
        simplex[index] = a;

        //if dot_product(a, direction) <= 0 {
        if (a.x * direction.x + a.y * direction.y) <= 0 {
            print("\nExiting at dot_product 2, dot_product(a, direction) = %", dot_product(a, direction));
            return false; // no collision
        }

        ao = -a;

        // simplex has 2 points (a line segment)
        if index < 2 {
            b := simplex[0];
            ab = b - a; // from point A to B
            d = triple_product(ab, ao, ab); // normal to AB towards origin
            if (direction.x * direction.x + direction.y + direction.y) == 0
            then direction = perpendicular(ab);
            continue; // skip to next iteration
        }

        b = simplex[1];
        c = simplex[0];
        ab = b - a;
        ac = c - a;
        ac_perp = triple_product(ab, ac, ac);

        if dot_product(ac_perp, ao) >= 0 {
            direction = ac_perp; // new direction is normal to AC towards origin
        }
        else {
            ab_perp = triple_product(ac, ab, ab);
            if dot_product(ab_perp, ao) < 0 then return true; // collision

            simplex[0] = simplex[1]; // swap first element (point C)
            direction = ab_perp; // swap element in the middle (point B)
        }
        simplex[1] = simplex[2];
        index -= 1;
    }

    print("\nWe made it to the end, should be no collision.");
    return false;
}

index_of_furthest_point :: (vertices : [] Vector2, direction : Vector2) -> int {
    max_product := dot_product(direction, vertices[0]);
    index : int;
    for v, i : vertices {
        product := dot_product(direction, v);
        print("\nmax_product: %, product: %, i: %", max_product, product, i);
        if (product > max_product) {
            max_product = product;
            index = i;
        }
    }

    print("\n\tvertices: %, index: %", vertices, index);
    return index;
}

// minkowski sum support
support :: (verticesA : [] Vector2, verticesB : [] Vector2, direction : Vector2) -> Vector2 {
    i := index_of_furthest_point(verticesA, direction);
    j := index_of_furthest_point(verticesB, -direction);
    print("\nverticesA[i] = %, verticesB[j] = %, verticesA[i] - verticesB[j] = %", verticesA[i], verticesB[j], verticesA[i] - verticesB[j]);
    return verticesA[i] - verticesB[j];
}

// To roughly compute average center. Ok as initial direction of simplex
average_point :: (vertices : [] Vector2) -> Vector2 {
    avg : Vector2;
    for v : vertices {
        avg.x += v.x;
        avg.y += v.y;
    }
    avg.x /= vertices.count;
    avg.y /= vertices.count;

    return avg;
}

perpendicular :: (v : Vector2) -> Vector2 {
    return .{v.y, -v.x};
}

to_world_pos :: (vertices : [] float32, pos : Vector2) -> [..] Vector2 {
    vertices_vec2 : [..] Vector2;
    last_x : float32;
    for vertex, i: vertices {
        if i % 2 == 0 {
            last_x = vertex;
        }
        else {
            array_add(*vertices_vec2, .{last_x + pos.x, vertex + pos.y});
        }
    }

    return vertices_vec2;
}

triple_product :: (a : Vector2, b : Vector2, c : Vector2) -> Vector2 {
    ac := dot_product(a, c);
    bc := dot_product(b, c);

    return b * ac - a * bc;
}
*/
/*
triple_product :: (a : Vector3, b : Vector3, c : Vector3) -> Vector3 {
    ac := dot_product(a, c);
    bc := dot_product(b, c);

    return b * ac - a * bc;
}

gjk :: (verticesA : [] Vector3, verticesB : [] Vector3, simplex_points : *[..] Vector3) -> bool {
    unit_x : Vector3 = .{1, 0, 0};
    support_point := support(unit_x, verticesA, verticesB);
    collision := false;

    //simplex_points : [..] Vector3;
    //array_reset(*simplex_points);
    //array_add(*simplex_points, support_point);
    array_reset(simplex_points);
    array_add(simplex_points, support_point);
    direction := -support_point;

    while true {
        support_point = support(direction, verticesA, verticesB);

        if dot_product(support_point, direction) <= 0 {
            return false; // no collision
        }

        //array_add(*simplex_points, support_point);
        array_add(simplex_points, support_point);

        //if next_simplex(*simplex_points, *direction) {
        if next_simplex(simplex_points, *direction) {
            print("\nwe have reached inside the next_simplex if statement");
            return true;
        }
    }

    return collision;
}

next_simplex :: (simplex_points : *[..] Vector3, direction : *Vector3) -> bool {
    if simplex_points.count == {
        case 2; return line_simplex(simplex_points, direction);
        case 3; return triangle_simplex(simplex_points, direction);
        //case 4; return tetrahedron_simplex(simplex_points, direction);
    }

    // never should be here
    return false;
}

line_simplex :: (simplex_points : *[..] Vector3, direction : *Vector3) -> bool {
    a : Vector3 = simplex_points.data[0];
    b : Vector3 = simplex_points.data[1];

    ab := b - a;
    ao := -a;

    if same_direction(ab, ao) {
        //direction = *cross_product(cross_product(ab, ao), ab);
        direction = *triple_product(ab, ao, ab);
    }
    else {
        array_reset(simplex_points);
        array_add(simplex_points, a);
        direction = *ao;
    }

    return false;
}

triangle_simplex :: (simplex_points : *[..] Vector3, direction : *Vector3) -> bool {
    a := simplex_points.data[0];
    b := simplex_points.data[1];
    c := simplex_points.data[2];

    ab := b - a;
    ac := c - a;
    ao := -a;

    //abc := cross_product(ab, ac);
    abc := triple_product(ab, ac, ac);

    //if same_direction(cross_product(abc, ac), ao) {
    if same_direction(abc, ao) {
        if same_direction(ac, ao) {
            array_reset(simplex_points);
            array_add(simplex_points, a, c);

            //direction = *cross_product(cross_product(ac, ao), ac);
            direction = *triple_product(ac, ao, ac);
        }
        else {
            array_reset(simplex_points);
            array_add(simplex_points, a, b);
            return line_simplex(simplex_points, direction);
        }
    }
    else {
        //if same_direction(cross_product(ab, abc), ao) {
        if same_direction(triple_product(ab, abc, abc), ao) {
            array_reset(simplex_points);
            array_add(simplex_points, a, b);

            return line_simplex(simplex_points, direction);
        }
        else {
            if same_direction(abc, ao) {
                direction = *abc;
            }
            else {
                array_reset(simplex_points);
                array_add(simplex_points, a, c, b);
                direction = *-abc;
            }
        }
    }
    ("\nwe reached the end of triangle simplex!");
    return true;
    //return false;
}

tetrahedron_simplex :: (simplex_points : *[..] Vector3, direction : *Vector3) -> bool {
    a := simplex_points.data[0];
    b := simplex_points.data[1];
    c := simplex_points.data[2];
    d := simplex_points.data[3];

    ab := b - a;
    ac := c - a;
    ad := d - a;
    ao := -a;

    abc := cross_product(ab, ac);
    acd := cross_product(ac, ad);
    adb := cross_product(ad, ab);

    if same_direction(abc, ao) {
        array_reset(simplex_points);
        array_add(simplex_points, a, b, c);

        return triangle_simplex(simplex_points, direction);
    }

    if same_direction(acd, ao) {
        array_reset(simplex_points);
        array_add(simplex_points, a, c, d);

        return triangle_simplex(simplex_points, direction);
    }

    if same_direction(adb, ao) {
        array_reset(simplex_points);
        array_add(simplex_points, a, d, b);

        return triangle_simplex(simplex_points, direction);
    }

    return true;
}

support :: (direction : Vector3, verticesA: [] Vector3, verticesB : [] Vector3) -> Vector3 {
    return find_furthest_point (direction, verticesA)
        - find_furthest_point(-direction, verticesB);
}

find_furthest_point :: (direction : Vector3, vertices : [] Vector3) -> Vector3 {
    max_point : Vector3;
    max_distance := -FLOAT32_MAX;

    for vertex : vertices {
        distance := dot_product(vertex, direction);
        if distance > max_distance {
            max_distance = distance;
            max_point = vertex;
        }
    }
    return max_point;
}

to_world_pos :: (vertices : [] float32, pos : Vector3) -> [..] Vector3 {
    vertices_vec3 : [..] Vector3;
    last_x : float32;
    for vertex, i: vertices {
        if i % 2 == 0 {
            last_x = vertex;
        }
        else {
            array_add(*vertices_vec3, .{last_x + pos.x, vertex + pos.y, 0.0 + pos.z});
        }
    }

    return vertices_vec3;
}
*/

not_equal_pos :: (arr : [] Vector3, arr2 : [] Vector3) -> bool {
    if arr.count != arr2.count then return true;
    for x, index : arr {
        if x != arr2[index] then return true;
    }
    return false;
}

same_direction :: (direction : Vector3, ao : Vector3) -> bool {
    return dot_product(direction, ao) > 0;
}

to_vertices :: (vs : [] Vector3) -> [] float32 {
    verts : [..] float32;
    for v : vs {
        array_add(*verts, v.x, v.y, v.z);
    }
    //print("\nvs: %\tverts: %", vs, verts);
    return verts;
}

to_rgb :: (num : int) -> float32 {
    return cast(float32) num / 255;
}

deg_to_rad :: (deg: float) -> float {
    return deg * (PI / 180);
}

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
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
