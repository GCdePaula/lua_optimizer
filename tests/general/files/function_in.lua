local x, y = 50, 51

local function f()
  local x = 0
  if x then
    x = 1
  else
    x = 2
  end
  local z = x
end

local function g()
  local x = 0
  if x then
    x = 1
  else
    x = 2
  end
  local z = x
end


local function f2()
  local x = 0
  if x then
    x = 1
  else
    x = 2
  end
  local z = x

  local function g2()
    local x = 0
    if x then
      x = 1
    else
      x = 2
    end
    local z = x
  end
end
