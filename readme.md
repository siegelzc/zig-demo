# zig-demo

## About

This is a demo project designed to exhibit various features of the Zig language and explore potential best practices in working with Zig, especially pertaining to C interoperability and the build system.

The `mymessage` application is compiled into both a static library and an executable which exposes a very simple CLI for operating the library. The `goodbye` application is contained within the `cdemo/` directory, and exhibits a functional example of the static library being imported and compiled into a C program. In order to support this use case, `mymessage` provides a C-language header file in the `include/` directory.

## Usage

Build the project by invoking the `install` build step.

    zig build install

The `install` step is actually the default behavior, so the following also works:

    zig build

The `run` step will execute the CLI immediately after compilation:

    zig build run -- <hello|goodbye> <anystring>

The binary may also be executed directly:

    zig-out/bin/mymessage-cli <hello|goodbye> <anystring>

An auto-generated documentation site can be built and viewed, bypassing CORS restrictions, via a local web server:

    zig build docs
    python -m http.server -b 127.0.0.1 8000 -d zig-out/docs/

Access the compiled static library at `zig-out/lib/libmymessage.a`, and include the header file located at `zig-out/include/mymessage.h`:

    cc example.c -Izig-out/include -Lzig-out/lib -lmymessage

