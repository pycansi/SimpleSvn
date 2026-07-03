import Pipe: @pipe
import StringEncodings: decode
import Match: @match
import TOML: parsefile

global svn::String
global url_current::String
global url_list::Vector{String}
global download_path::String
global terminal_encoding::String
global run_flag::Bool

function print_list(x::Vector{SubString{String}})::Nothing
    for (i, x) in enumerate(x)
        println(i, ": ", x) 
    end
end

function run_cmd(cmd::Cmd)::String
    @pipe cmd |>
        read(_) |> 
        decode(String, _, terminal_encoding)
end

function list(url::AbstractString)::Vector{SubString{String}}
    @info url
    global url_current = url
    global url_list = @pipe run_cmd(`$svn list $url_current`) |> 
        split(_, "\r\n")
end

function cd_url(i::Int)::String
    @match i begin 
        -1 => 
            @pipe split(url_current, "/") |> _[1:end-2] |> join(_, "/") |> *(_, "/")
        _ =>
            @pipe *(url_current, url_list[i])
    end 
end

function del(i::Int)::String
    local url = cd_url(i)
    run_cmd(`$svn del $url -m "del"`)
end

function download(i::Int, download_path::AbstractString)::String 
    local url = cd_url(i)
    run_cmd(`$svn export $url $download_path`)
end

function upload(file_path::AbstractString)::String
    local file = basename(file_path)
    local url = *(url_current, file)
    run_cmd(`$svn import $file_path $url -m "upload"`)
end

function mkdir(name::AbstractString)::String
    local url = *(url_current, name)
    run_cmd(`$svn mkdir $url -m "mkdir"`)
end

function handle()::Nothing
    print("> ")
    local input = @pipe readline() |> split(_," ")
    @match input begin 
        ["list"] => list(url_current) |> print_list
        ["list", url] => list(url) |> print_list
        ["cd", i] => cd_url(parse(Int,i)) |> list |> print_list
        ["mkdir", name] => mkdir(name) |> println
        ["upload", file_path] => upload(file_path) |> println
        ["download", i] => download(parse(Int,i), download_path) |> println
        ["del", i] => del(parse(Int,i)) |> println
        ["exit"] => ((global run_flag = false);nothing)
        _ => @info "Invalid Operation"
    end
end

function main()::Nothing
    local config::Dict{String, String} = parsefile("config.toml")

    global svn = config["svn"]
    global url_current = config["url"]
    global url_current = if (url_current |> isdirpath) url_current else *(url_current, "/") end # last char must be '/''

    global download_path = config["download_path"]
    global terminal_encoding = config["terminal_encoding"]

    global run_flag = true

    println(raw"""Please input: 
    - list [url]
    - cd $int (-1 is ..)
    - mkdir $name
    - upload $file
    - download $int
    - del $int
    - exit""")
    while run_flag
        handle()
    end
end

main()
