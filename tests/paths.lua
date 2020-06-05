package.path = package.path
  -- Add tests libs path
  ..";./libs/?.lua"
  ..";./libs/?/?.lua"
  ..";./libs/?/init.lua"

  .. ";./self_opt/?.lua"

  -- Add src path and src libs path
--  ..";../src/?.lua"
  ..";../src/libs/?.lua"
  ..";../src/libs/?/?.lua"
  ..";../src/libs/?/init.lua"

package.cpath =
  -- Add tests libs path
  "./libs/?/?.so;"
  .."./libs/?.so;"
  .."../src/libs/?.so;"
  .."../src/libs/?/?.so;"
  .. package.cpath

