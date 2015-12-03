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
    match(s, "<!%-%-%s*(.*)%s*%-%->")
end

function detect(s, ext)
  local content = is_comment(s, ext)
  if content then
    return match(content, "@build%s*(.*)$")
  end
  return nil
end

function extract(s, base)
  s = s:gsub("%%[%a%d]+", "\"%1\"")
  return s:gsub("%%", base)
end

function main(filename)
  fh, err = io.open(filename)
  if err then
    print("can not read ", filename)
    return false
  end

  local path, base, ext = match(filename, "(.-)([^\\/]-)([^%.]+)$")

  while true do
    local line = fh:read()
    if line == nil then break end

    local build = detect(line, ext)
    if build then
      local com = extract(build, base)
      print("Running: ", com)
      os.execute(com)
      return true
    end
  end
end

main(arg[1])
