## build

`build` is a tiny tool that builds single files, for instance from markdown to pdf using [pandoc](http://pandoc.org/). `build` extracts the command to execute from a comment in the file.

## example

Add this line to a markdown file:

```markdown
<!-- @build pandoc -o %pdf %md -->
```

or this line to a [mscgen](http://www.mcternan.me.uk/mscgen/) file:

```
# @build mscgen -T png -o images/%png %msc
```

And then run `lua build.lua anyfile`.

## syntax

A comment in the file should contain `@build command`.
The command can expand `%ext` to `filename.ext` automatically.

You can define multiple build types with the syntax:
```
@build-{type} command
```
The command can expand `%ext` to `filename.ext` automatically.
The command can expand `%ext` to `filename.ext` automatically.
Note that:

- if the file does not contain a command, `build` attempts to load a default command for the file extension from `~/.config/build.defaults`
- `build` succeeds and exits after the run command found


## installation

`build` is written in a single Lua file. To install:

1. copy `build.lua` where you want;
2. create a shell alias so that `build` invokes `lua /path/to/build.lua`.

## author

`build` is written by Henri Binsztok

Check out [Opa](http://opalang.org) and [Peps](https://github.com/MLstate/PEPS) if you want :)
