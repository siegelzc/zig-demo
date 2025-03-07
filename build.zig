const std = @import("std");

const package_name = "mymessage";
const cli_name = std.fmt.comptimePrint("{s}-cli", .{package_name});
const test_name = std.fmt.comptimePrint("{s}-test", .{package_name});
const module_path = "src/lib/mymessage.zig";
const lib_path = "src/lib/export.zig";
const cli_path = "src/cli/cli.zig";
// const <dependency>_include_dir = "<dependency>/includes/";
// const lib<dependency>_path = "<dependency>/lib<dependency>.a";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = std.Target.Query{
            .cpu_arch = .aarch64,
            // .os_tag = .macos,
        },
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = std.builtin.OptimizeMode.Debug, // Override this with a CLI flag for release
    });

    // Module
    const module = b.addModule(package_name, .{
        .root_source_file = b.path(module_path),
        .target = target,
        .optimize = optimize,
        .pic = true,
        .link_libc = true,
    });
    applyStandardConfig(b, module);

    // CLI
    const cli = b.addExecutable(.{
        .name = cli_name,
        .root_source_file = b.path(cli_path),
        .target = target,
        .optimize = optimize,
        .pic = true,
    });
    cli.root_module.addImport("mymessage", module); // Makes the "mymessage" module available to the "cli" module (absolutely)

    const cli_install_artifact = b.addInstallArtifact(cli, .{});
    const cli_run_artifact = b.addRunArtifact(cli);
    if (b.args) |args| {
        cli_run_artifact.addArgs(args);
    }

    // Static library
    const static_lib = b.addStaticLibrary(.{
        .name = package_name,
        .root_source_file = b.path(lib_path),
        .target = target,
        .optimize = optimize,
        .pic = true,
        .link_libc = true,
    });
    applyStandardConfig(b, static_lib);
    const static_lib_artifact = b.addInstallArtifact(static_lib, .{});

    // Include directory
    const include_dir_artifact: *std.Build.Step.InstallDir = b.addInstallDirectory(.{
        .source_dir = b.path("./include"),
        .install_dir = .prefix,
        .install_subdir = "include",
    });

    // Testing
    const lib_test = b.addTest(.{
        .name = test_name,
        .root_source_file = b.path(lib_path),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    applyStandardConfig(b, lib_test);
    const lib_test_run_artifact = b.addRunArtifact(lib_test);

    // Documentation
    // Local server: python -m http.server -b 127.0.0.1 8000 -d zig-out/docs/
    const docs_dir_artifact = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = static_lib.getEmittedDocs(),
    });

    // Clean
    const remove_cache = b.addRemoveDirTree("./.zig-cache/");
    const remove_out = b.addRemoveDirTree("./zig-out/");

    // Library step
    const lib_step = b.step("lib", "Build the library");
    lib_step.dependOn(&static_lib_artifact.step);
    lib_step.dependOn(&include_dir_artifact.step);

    // Run step
    const run_step = b.step("run", "Run the CLI");
    run_step.dependOn(&cli_run_artifact.step);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&lib_test_run_artifact.step);

    // Docs step
    const docs_step = b.step("docs", "Emit docs");
    docs_step.dependOn(&docs_dir_artifact.step);

    // Install step
    const install_step = b.getInstallStep(); // The "install" step already exists
    install_step.dependOn(&cli_install_artifact.step);
    install_step.dependOn(lib_step);
    install_step.dependOn(docs_step);

    // Clean step (superflous)
    const clean_step = b.step("clean", "Delete cache and output files");
    clean_step.dependOn(&remove_cache.step);
    clean_step.dependOn(&remove_out.step);
}

fn applyStandardConfig(b: *std.Build, thing: anytype) void {
    _ = b;
    const typeof = @TypeOf(thing);
    if (typeof == *std.Build.Step.Compile or typeof == *std.Build.Module) {
        // thing.addIncludePath(b.path(<dependency>_include_dir));
        // thing.addObjectFile(b.path(lib<dependency>_path));
        return;
    }

    @compileError("Applying standard configuartions to incompatible type");
}
