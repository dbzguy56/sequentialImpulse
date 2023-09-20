#import "Compiler";
#import "Basic";

#run build();
build :: () {
    w := compiler_create_workspace("sequentialImpulse");
    if !w {
        log_error("Failed to create workspace!");
        exit(1);
    }

    options := get_build_options(w);
    options.output_path = "./run_tree";
    options.output_executable_name = "sequentialImpulseDemo";
    set_build_options(options, w);
    add_build_file("./code/main.jai", w);

    set_build_options_dc(.{do_output = false, write_added_strings = false});
}
