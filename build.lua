-- Copyright (c) 2015 Henri Binsztok

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- optimization will kill us all :)
local match = string.match

function string.trim(s)
  return match(s,'^()%s*$') and '' or match(s,'^%s*(.*%S)')
end

-- TODO: use ext to restrict to language?
function is_comment(s, ext)
  s = string.trim(s)
  return
    match(s, "#%s*(.*)$") or
    match(s, "//%s*(.*)$") or
    match(s, "<!%-%-%s*(.*)%s*%-%->") or
    match(s, "%(%*%s*(.*)%*%)")
end

function detect(s, ext)
  local content = is_comment(s, ext)
  if content then
    return match(content, "@build[%-]?([%a%d]*)%s+(.*)$")
  end
  return nil, nil
end

function extract(s, base)
  s = s:gsub("%%[%a%d]+", "\"%1\"")
  return s:gsub("%%", base)
end

function read_defaults(ext)
  -- TODO: multi-platform
  local filename = os.getenv("HOME") .. "/.config/build.defaults"
  local fh, err = io.open(filename)
  if err then
    print("no default settings found at ", filename)
    return false
  end
  while true do
    local line = fh:read()
    if line == nil then return false end
    local lext, lbuild = match(line, "([%a%d]+)%s*:%s*(.*)$")
    if lext == ext then return lbuild end
  end
end

function run(build, base)
  local com = extract(build, base)
  print("Running: ", com)
  os.execute(com)
  return true
end

function build_file(ty_expected, filename)
  local fh, err = io.open(filename)
  if err then
    print("can not read ", filename)
    return false
  end

  local path, base, ext = match(filename, "(.-)([^\\/]-)([^%.]+)$")

  -- TODO: limit to first 100 lines?
  while true do
    local line = fh:read()
    if line == nil then break end

    local ty, build = detect(line, ext)
    if (not ty_expected or ty == ty_expected) and build then 
      return run(build, base)
    end
  end

  -- did not find command in file. Run default build command
  default = read_defaults(ext)
  if default then return run(default, base) end

  -- we did not find any command
  return false

end

function check_build_file(ty, filename)
  if build_file(ty, filename) then
    return 0
  else
    print(filename, ": no command found, skipping")
    return 1
  end
end

function main()
  local res = 0
  local ty
  for i, file in pairs(arg) do
    if i > 0 then
      local tmp = match(file, "^[%-](.*)")
      if tmp then
        ty = tmp
        print("setting build type:", ty)
      else
        res = res + check_build_file(ty, file)
      end
    end
  end
  return res
end

main()
