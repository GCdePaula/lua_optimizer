package.path = package.path
  -- Add tests libs path
  ..";./libs/?.lua"
  ..";./libs/?/?.lua"
  ..";./libs/?/init.lua"

  -- Add src path and src libs path
  ..";../src/?.lua"
  ..";../src/libs/?.lua"
  ..";../src/libs/?/?.lua"
  ..";../src/libs/?/init.lua"

package.cpath = package.cpath
  -- Add tests libs path
  ..";./libs/?.so"
  ..";./libs/?/?.so"

local pretty = require "pl.pretty"

local t = {1, 2, 3, a = "a", b = "b"}
pretty.dump(t)

require 'busted.runner'()

describe("a test", function()
  -- tests to here
end)

describe("Busted unit testing framework", function()
  describe("should be awesome", function()
    it("should be easy to use", function()
      assert.truthy("Yup.")
    end)

    it("should have lots of features", function()
      -- deep check comparisons!
      assert.are.same({ table = "great"}, { table = "great" })

      -- or check by reference!
      assert.are_not.equal({ table = "great"}, { table = "great"})

      assert.truthy("this is a string") -- truthy: not false or nil

      assert.True(1 == 1)
      assert.is_true(1 == 1)

      assert.falsy(nil)
      assert.has_error(function() error("Wat") end, "Wat")
    end)

    it("should provide some shortcuts to common functions", function()
      assert.are.unique({{ thing = 1 }, { thing = 2 }, { thing = 3 }})
    end)

  end)
end)
