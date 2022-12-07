mutable struct File{D}
    name::String
    parent::D
    size::Int
end

mutable struct Dir
    name::String
    parent::Dir
    dirs::Dict{String,Dir}
    files::Dict{String,File}
    function Dir(name, parent)
        new(name, parent, DirDict(), FileDict())
    end
    function Dir()
        d = new("/")
        d.parent = d
        d.dirs = DirDict()
        d.files = FileDict()
        d
    end
end

const DirDict = Dict{String,Dir}
const FileDict = Dict{String,File}

name(f::File) = f.name
name(d::Dir) = d.name

size(f::File) = f.size
size(d::Dir) = sum(size, files(d), init=0)

parent(f::File) = f.parent
parent(d::Dir) = d.parent

isfile(::File) = true
isfile(::Dir) = false
isdir(::File) = false
isdir(::Dir) = true
isroot(d) = parent(d) === d

dirs(d::Dir) = values(d.dirs)
files(d::Dir) = values(d.files)

mutable struct Filesystem
    root::Dir
    cwd::Dir
end

function Filesystem()
    root = Dir()
    Filesystem(root, root)
end

root(fs::Filesystem) = fs.root
cwd(fs::Filesystem) = fs.cwd
pwd(fs::Filesystem) = name(cwd(fs))

path(d::Dir) = isroot(d) ? name(d) : joinpath(path(parent(d)), name(d))

function cd(fs, dirname)
    if dirname == ".."
        fs.cwd = fs.cwd.parent
    elseif dirname == "/"
        fs.cwd = fs.root
    else
        fs.cwd = mkdir(fs, dirname)
    end
end

function mkdir(fs, name)
    dir = get(fs.cwd.dirs, name, nothing)
    if isnothing(dir)
        dir = Dir(name, fs.cwd)
        fs.cwd.dirs[name] = dir
    end
    isdir(dir) || error("Not a directory: $dir")
    dir
end

function create_file(dir, name, size)
    f = File(name, dir, size)
    dir.files[name] = f
    f
end

function walkdir(root)
    function _walkdir(root, ch)
        for dir in dirs(root)
            _walkdir(dir, ch)
        end
        put!(ch, (path(root), dirs(root), files(root)))
    end
    Channel{Tuple{String,typeof(dirs(Dir())),typeof(files(Dir()))}}() do ch
        _walkdir(root, ch)
    end
end

function cumsizes(dir)
    sizes = Dict{String,Int}()
    for (root, dirs, files) in walkdir(dir)
        current_size = sum(size, files, init=0)
        for dir in dirs
            p = joinpath(root, name(dir))
            current_size += sizes[p]
        end
        sizes[root] = current_size
    end
    sizes
end

function create_fs(input)
    fs = Filesystem()
    for line in input
        if startswith(line, "\$")
            _, cmd, args... = split(line)
            if cmd == "cd"
                cd(fs, only(args))
            else
                continue
            end
        elseif isnumeric(first(line))
            size, name = split(line)
            create_file(cwd(fs), string(name), parse(Int, size))
        else
            continue
        end
    end
    fs
end

function main()
    testfilename = joinpath(@__DIR__, "test_input.txt")
    filename = joinpath(@__DIR__, "input.txt")

    test_fs = create_fs(eachline(testfilename))
    test_sizes = cumsizes(root(test_fs))
    test = sum(Iterators.filter(<=(100_000), values(test_sizes)))

    fs = create_fs(eachline(filename))
    sizes = cumsizes(root(fs))

    part1 = sum(Iterators.filter(<=(100_000), values(sizes)))

    total_size = 70_000_000
    required_size = 30_000_000
    current_size = sizes["/"]
    unused_size = total_size - current_size
    missing_size = required_size - unused_size

    possible_sizes = Iterators.filter(>=(missing_size), values(sizes))

    part2 = minimum(possible_sizes)

    println("Test: ", test)
    println("Part 1: ", part1)
    println("Part 2: ", part2)
end

main()
