local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local clear, feed, eq = helpers.clear, helpers.feed, helpers.eq
local command = helpers.command
local feed_command = helpers.feed_command
local insert = helpers.insert
local funcs = helpers.funcs
local meths = helpers.meths
local source = helpers.source
local assert_alive = helpers.assert_alive


local content1 = [[
        This is a
        valid English
        sentence composed by
        an exhausted developer
        in his cave.
        ]]

describe("folded lines", function()
  before_each(function()
    clear()
  end)

  local function with_ext_multigrid(multigrid)
    local screen
    before_each(function()
      clear()
      screen = Screen.new(45, 8)
      screen:attach({rgb=true, ext_multigrid=multigrid})
      screen:set_default_attr_ids({
        [1] = {bold = true, foreground = Screen.colors.Blue1},
        [2] = {reverse = true},
        [3] = {bold = true, reverse = true},
        [4] = {foreground = Screen.colors.Grey100, background = Screen.colors.Red},
        [5] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.LightGrey},
        [6] = {background = Screen.colors.Yellow},
        [7] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.WebGray},
        [8] = {foreground = Screen.colors.Brown },
        [9] = {bold = true, foreground = Screen.colors.Brown},
        [10] = {background = Screen.colors.LightGrey, underline = true},
        [11] = {bold=true},
        [12] = {background = Screen.colors.Grey90},
      })
    end)

    it("work with more than one signcolumn", function()
      command("set signcolumn=yes:9")
      feed("i<cr><esc>")
      feed("vkzf")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:                  }{5:^+--  2 lines: ·············}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {7:                  }{5:^+--  2 lines: ·············}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end
    end)

    it("highlights with CursorLineFold when 'cursorline' is set", function()
      command("set cursorline foldcolumn=2 foldmethod=marker")
      command("hi link CursorLineFold Search")
      insert(content1)
      feed("zf3j")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:  }This is a                                  |
          {7:  }valid English                              |
          {7:  }sentence composed by                       |
          {7:  }an exhausted developer                     |
          {7:  }in his cave.                               |
          {6:  }{12:^                                           }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
        {7:  }This is a                                  |
        {7:  }valid English                              |
        {7:  }sentence composed by                       |
        {7:  }an exhausted developer                     |
        {7:  }in his cave.                               |
        {6:  }{12:^                                           }|
        {1:~                                            }|
                                                     |
        ]])
      end
      feed("k")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:  }This is a                                  |
          {7:  }valid English                              |
          {7:  }sentence composed by                       |
          {7:  }an exhausted developer                     |
          {6:  }{12:^in his cave.                               }|
          {7:  }                                           |
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
        {7:  }This is a                                  |
        {7:  }valid English                              |
        {7:  }sentence composed by                       |
        {7:  }an exhausted developer                     |
        {6:  }{12:^in his cave.                               }|
        {7:  }                                           |
        {1:~                                            }|
                                                     |
        ]])
      end
      command("set cursorlineopt=line")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:  }This is a                                  |
          {7:  }valid English                              |
          {7:  }sentence composed by                       |
          {7:  }an exhausted developer                     |
          {7:  }{12:^in his cave.                               }|
          {7:  }                                           |
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
        {7:  }This is a                                  |
        {7:  }valid English                              |
        {7:  }sentence composed by                       |
        {7:  }an exhausted developer                     |
        {7:  }{12:^in his cave.                               }|
        {7:  }                                           |
        {1:~                                            }|
                                                     |
        ]])
      end
    end)

    it("highlighting with relative line numbers", function()
      command("set relativenumber cursorline cursorlineopt=number foldmethod=marker")
      feed_command("set foldcolumn=2")
      funcs.setline(1, '{{{1')
      funcs.setline(2, 'line 1')
      funcs.setline(3, '{{{1')
      funcs.setline(4, 'line 2')
      feed("j")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+ }{8:  1 }{5:+--  2 lines: ·························}|
          {7:+ }{9:  0 }{5:^+--  2 lines: ·························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :set foldcolumn=2                            |
        ]])
      else
        screen:expect([[
          {7:+ }{8:  1 }{5:+--  2 lines: ·························}|
          {7:+ }{9:  0 }{5:^+--  2 lines: ·························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :set foldcolumn=2                            |
        ]])
      end
    end)

    it("work with spell", function()
      command("set spell")
      insert(content1)

      feed("gg")
      feed("zf3j")
      if not multigrid then
        screen:expect{grid=[[
          {5:^+--  4 lines: This is a······················}|
          in his cave.                                 |
                                                       |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]]}
      end
    end)

    it("work with matches", function()
      insert(content1)
      command("highlight MyWord gui=bold guibg=red   guifg=white")
      command("call matchadd('MyWord', '\\V' . 'test', -1)")
      feed("gg")
      feed("zf3j")
      if not multigrid then
        screen:expect{grid=[[
          {5:^+--  4 lines: This is a······················}|
          in his cave.                                 |
                                                       |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]]}
      end
    end)

    it("works with multibyte fillchars", function()
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      command("set fillchars+=foldopen:▾,foldsep:│,foldclose:▸")
      feed_command('1')
      command("set foldcolumn=2")
      feed('zf4j')
      feed('zf2j')
      feed('zO')
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:▾▾}^aa                                         |
          {7:││}bb                                         |
          {7:││}cc                                         |
          {7:││}dd                                         |
          {7:││}ee                                         |
          {7:│ }ff                                         |
          {1:~                                            }|
        ## grid 3
          :1                                           |
        ]])
      else
        screen:expect([[
          {7:▾▾}^aa                                         |
          {7:││}bb                                         |
          {7:││}cc                                         |
          {7:││}dd                                         |
          {7:││}ee                                         |
          {7:│ }ff                                         |
          {1:~                                            }|
          :1                                           |
        ]])
      end

      feed_command("set rightleft")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
                                                   a^a{7:▾▾}|
                                                   bb{7:││}|
                                                   cc{7:││}|
                                                   dd{7:││}|
                                                   ee{7:││}|
                                                   ff{7: │}|
          {1:                                            ~}|
        ## grid 3
          :set rightleft                               |
        ]])
      else
        screen:expect([[
                                                   a^a{7:▾▾}|
                                                   bb{7:││}|
                                                   cc{7:││}|
                                                   dd{7:││}|
                                                   ee{7:││}|
                                                   ff{7: │}|
          {1:                                            ~}|
          :set rightleft                               |
        ]])
      end

      feed_command("set norightleft")
      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 0, 1)
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:▾▸}{5:^+---  5 lines: aa··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :set norightleft                             |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 0, 1)
        screen:expect([[
          {7:▾▸}{5:^+---  5 lines: aa··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :set norightleft                             |
        ]])
      end
    end)

    it("works with split", function()
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      feed_command('2')
      command("set foldcolumn=1")
      feed('zf3j')
      feed_command('1')
      feed('zf2j')
      feed('zO')
      feed_command("rightbelow new")
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      feed_command('2')
      command("set foldcolumn=1")
      feed('zf3j')
      feed_command('1')
      feed('zf2j')
      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 0, 0)
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          {2:[No Name] [+]                                }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {3:[No Name] [+]                                }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                                          |
          {7:-}bb                                          |
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}^aa                                          |
          {7:+}{5:+---  4 lines: bb···························}|
          {7:│}ff                                          |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 3, 0)
        screen:expect([[
          {7:-}aa                                          |
          {7:-}bb                                          |
          {2:[No Name] [+]                                }|
          {7:-}^aa                                          |
          {7:+}{5:+---  4 lines: bb···························}|
          {7:│}ff                                          |
          {3:[No Name] [+]                                }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 1, 0)
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          {2:[No Name] [+]                                }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {3:[No Name] [+]                                }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                                          |
          {7:-}bb                                          |
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}^aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 4, 0)
        screen:expect([[
          {7:-}aa                                          |
          {7:-}bb                                          |
          {2:[No Name] [+]                                }|
          {7:-}^aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
          {3:[No Name] [+]                                }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 1, 0)
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          {3:[No Name] [+]                                }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {2:[No Name] [+]                                }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                                          |
          {7:+}{5:^+---  4 lines: bb···························}|
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 1, 0)
        screen:expect([[
          {7:-}aa                                          |
          {7:+}{5:^+---  4 lines: bb···························}|
          {3:[No Name] [+]                                }|
          {7:-}aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
          {2:[No Name] [+]                                }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 0, 0)
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          {3:[No Name] [+]                                }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {2:[No Name] [+]                                }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  6 lines: aa····························}|
          {1:~                                            }|
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 0, 0)
        screen:expect([[
          {7:+}{5:^+--  6 lines: aa····························}|
          {1:~                                            }|
          {3:[No Name] [+]                                }|
          {7:-}aa                                          |
          {7:-}bb                                          |
          {7:2}cc                                          |
          {2:[No Name] [+]                                }|
          :1                                           |
        ]])
      end
    end)

    it("works with vsplit", function()
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      feed_command('2')
      command("set foldcolumn=1")
      feed('zf3j')
      feed_command('1')
      feed('zf2j')
      feed('zO')
      feed_command("rightbelow vnew")
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      feed_command('2')
      command("set foldcolumn=1")
      feed('zf3j')
      feed_command('1')
      feed('zf2j')
      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 0, 0)
        screen:expect([[
        ## grid 1
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          {2:[No Name] [+]          }{3:[No Name] [+]         }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                   |
          {7:-}bb                   |
          {7:2}cc                   |
          {7:2}dd                   |
          {7:2}ee                   |
          {7:│}ff                   |
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}^aa                   |
          {7:+}{5:+---  4 lines: bb····}|
          {7:│}ff                   |
          {1:~                     }|
          {1:~                     }|
          {1:~                     }|
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 0, 23)
        screen:expect([[
          {7:-}aa                   {2:│}{7:-}^aa                   |
          {7:-}bb                   {2:│}{7:+}{5:+---  4 lines: bb····}|
          {7:2}cc                   {2:│}{7:│}ff                   |
          {7:2}dd                   {2:│}{1:~                     }|
          {7:2}ee                   {2:│}{1:~                     }|
          {7:│}ff                   {2:│}{1:~                     }|
          {2:[No Name] [+]          }{3:[No Name] [+]         }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 1, 0)
        screen:expect([[
        ## grid 1
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          {2:[No Name] [+]          }{3:[No Name] [+]         }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                   |
          {7:-}bb                   |
          {7:2}cc                   |
          {7:2}dd                   |
          {7:2}ee                   |
          {7:│}ff                   |
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}^aa                   |
          {7:-}bb                   |
          {7:2}cc                   |
          {7:2}dd                   |
          {7:2}ee                   |
          {7:│}ff                   |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 1, 23)
        screen:expect([[
          {7:-}aa                   {2:│}{7:-}^aa                   |
          {7:-}bb                   {2:│}{7:-}bb                   |
          {7:2}cc                   {2:│}{7:2}cc                   |
          {7:2}dd                   {2:│}{7:2}dd                   |
          {7:2}ee                   {2:│}{7:2}ee                   |
          {7:│}ff                   {2:│}{7:│}ff                   |
          {2:[No Name] [+]          }{3:[No Name] [+]         }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 1, 0)
        screen:expect([[
        ## grid 1
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          {3:[No Name] [+]          }{2:[No Name] [+]         }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:-}aa                   |
          {7:+}{5:^+---  4 lines: bb····}|
          {7:│}ff                   |
          {1:~                     }|
          {1:~                     }|
          {1:~                     }|
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}aa                   |
          {7:-}bb                   |
          {7:2}cc                   |
          {7:2}dd                   |
          {7:2}ee                   |
          {7:│}ff                   |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 1, 0)
        screen:expect([[
          {7:-}aa                   {2:│}{7:-}aa                   |
          {7:+}{5:^+---  4 lines: bb····}{2:│}{7:-}bb                   |
          {7:│}ff                   {2:│}{7:2}cc                   |
          {1:~                     }{2:│}{7:2}dd                   |
          {1:~                     }{2:│}{7:2}ee                   |
          {1:~                     }{2:│}{7:│}ff                   |
          {3:[No Name] [+]          }{2:[No Name] [+]         }|
          :1                                           |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 0, 0)
        screen:expect([[
        ## grid 1
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          [2:----------------------]{2:│}[4:----------------------]|
          {3:[No Name] [+]          }{2:[No Name] [+]         }|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  6 lines: aa·····}|
          {1:~                     }|
          {1:~                     }|
          {1:~                     }|
          {1:~                     }|
          {1:~                     }|
        ## grid 3
          :1                                           |
        ## grid 4
          {7:-}aa                   |
          {7:-}bb                   |
          {7:2}cc                   |
          {7:2}dd                   |
          {7:2}ee                   |
          {7:│}ff                   |
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 0, 0)
        screen:expect([[
          {7:+}{5:^+--  6 lines: aa·····}{2:│}{7:-}aa                   |
          {1:~                     }{2:│}{7:-}bb                   |
          {1:~                     }{2:│}{7:2}cc                   |
          {1:~                     }{2:│}{7:2}dd                   |
          {1:~                     }{2:│}{7:2}ee                   |
          {1:~                     }{2:│}{7:│}ff                   |
          {3:[No Name] [+]          }{2:[No Name] [+]         }|
          :1                                           |
        ]])
      end
    end)

    it("works with tab", function()
      insert([[
        aa
        bb
        cc
        dd
        ee
        ff]])
      feed_command('2')
      command("set foldcolumn=2")
      feed('zf3j')
      feed_command('1')
      feed('zf2j')
      feed('zO')
      feed_command("tab split")
      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 1, 1)
        screen:expect([[
        ## grid 1
          {10: + [No Name] }{11: + [No Name] }{2:                  }{10:X}|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2 (hidden)
          {7:- }aa                                         |
          {7:│-}bb                                         |
          {7:││}cc                                         |
          {7:││}dd                                         |
          {7:││}ee                                         |
          {7:│ }ff                                         |
          {1:~                                            }|
        ## grid 3
          :tab split                                   |
        ## grid 4
          {7:- }^aa                                         |
          {7:│+}{5:+---  4 lines: bb··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 2, 1)
        screen:expect([[
          {10: + [No Name] }{11: + [No Name] }{2:                  }{10:X}|
          {7:- }^aa                                         |
          {7:│+}{5:+---  4 lines: bb··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :tab split                                   |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 4, 0, 0)
        screen:expect([[
        ## grid 1
          {10: + [No Name] }{11: + [No Name] }{2:                  }{10:X}|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2 (hidden)
          {7:- }aa                                         |
          {7:│-}bb                                         |
          {7:││}cc                                         |
          {7:││}dd                                         |
          {7:││}ee                                         |
          {7:│ }ff                                         |
          {1:~                                            }|
        ## grid 3
          :tab split                                   |
        ## grid 4
          {7:+ }{5:^+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 1, 0)
        screen:expect([[
          {10: + [No Name] }{11: + [No Name] }{2:                  }{10:X}|
          {7:+ }{5:^+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :tab split                                   |
        ]])
      end

      feed_command("tabnext")
      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 1, 1)
        screen:expect([[
        ## grid 1
          {11: + [No Name] }{10: + [No Name] }{2:                  }{10:X}|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:- }^aa                                         |
          {7:│+}{5:+---  4 lines: bb··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :tabnext                                     |
        ## grid 4 (hidden)
          {7:+ }{5:+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 2, 1)
        screen:expect([[
          {11: + [No Name] }{10: + [No Name] }{2:                  }{10:X}|
          {7:- }^aa                                         |
          {7:│+}{5:+---  4 lines: bb··························}|
          {7:│ }ff                                         |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :tabnext                                     |
        ]])
      end

      if multigrid then
        meths.input_mouse('left', 'press', '', 2, 0, 0)
        screen:expect([[
        ## grid 1
          {11: + [No Name] }{10: + [No Name] }{2:                  }{10:X}|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+ }{5:^+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :tabnext                                     |
        ## grid 4 (hidden)
          {7:+ }{5:+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        meths.input_mouse('left', 'press', '', 0, 1, 0)
        screen:expect([[
          {11: + [No Name] }{10: + [No Name] }{2:                  }{10:X}|
          {7:+ }{5:^+--  6 lines: aa···························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :tabnext                                     |
        ]])
      end
    end)

    it("works with multibyte text", function()
      -- Currently the only allowed value of 'maxcombine'
      eq(6, meths.get_option('maxcombine'))
      eq(true, meths.get_option('arabicshape'))
      insert([[
        å 语 x̨̣̘̫̲͚͎̎͂̀̂͛͛̾͢͟ العَرَبِيَّة
        möre text]])
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          å 语 x̎͂̀̂͛͛ ﺎﻠﻋَﺮَﺒِﻳَّﺓ                               |
          möre tex^t                                    |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          å 语 x̎͂̀̂͛͛ ﺎﻠﻋَﺮَﺒِﻳَّﺓ                               |
          möre tex^t                                    |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end

      feed('vkzf')
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة·················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة·················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end

      feed_command("set noarabicshape")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة·················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :set noarabicshape                           |
        ]])
      else
        screen:expect([[
          {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة·················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :set noarabicshape                           |
        ]])
      end

      feed_command("set number foldcolumn=2")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+ }{8:  1 }{5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة···········}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :set number foldcolumn=2                     |
        ]])
      else
        screen:expect([[
          {7:+ }{8:  1 }{5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة···········}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :set number foldcolumn=2                     |
        ]])
      end

      -- Note: too much of the folded line gets cut off.This is a vim bug.
      feed_command("set rightleft")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:···········ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}{8: 1  }{7: +}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
        ## grid 3
          :set rightleft                               |
        ]])
      else
        screen:expect([[
          {5:···········ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}{8: 1  }{7: +}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          :set rightleft                               |
        ]])
      end

      feed_command("set nonumber foldcolumn=0")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:·················ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
        ## grid 3
          :set nonumber foldcolumn=0                   |
        ]])
      else
        screen:expect([[
          {5:·················ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          :set nonumber foldcolumn=0                   |
        ]])
      end

      feed_command("set arabicshape")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:·················ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
        ## grid 3
          :set arabicshape                             |
        ]])
      else
        screen:expect([[
          {5:·················ةيَّبِرَعَلا x̎͂̀̂͛͛ 语 å :senil 2  --^+}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          :set arabicshape                             |
        ]])
      end

      feed('zo')
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
                                         ﺔﻴَّﺑِﺮَﻌَ^ﻟﺍ x̎͂̀̂͛͛ 语 å|
                                              txet eröm|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
        ## grid 3
          :set arabicshape                             |
        ]])
      else
        screen:expect([[
                                         ﺔﻴَّﺑِﺮَﻌَ^ﻟﺍ x̎͂̀̂͛͛ 语 å|
                                              txet eröm|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          :set arabicshape                             |
        ]])
      end

      feed_command('set noarabicshape')
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
                                         ةيَّبِرَعَ^لا x̎͂̀̂͛͛ 语 å|
                                              txet eröm|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
        ## grid 3
          :set noarabicshape                           |
        ]])
      else
        screen:expect([[
                                         ةيَّبِرَعَ^لا x̎͂̀̂͛͛ 语 å|
                                              txet eröm|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          {1:                                            ~}|
          :set noarabicshape                           |
        ]])
      end

    end)

    it("work in cmdline window", function()
      feed_command("set foldmethod=manual")
      feed_command("let x = 1")
      feed_command("/alpha")
      feed_command("/omega")

      feed("<cr>q:")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          {2:[No Name]                                    }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {3:[Command Line]                               }|
          [3:---------------------------------------------]|
        ## grid 2
                                                       |
        ## grid 3
          :                                            |
        ## grid 4
          {1::}set foldmethod=manual                       |
          {1::}let x = 1                                   |
          {1::}^                                            |
          {1:~                                            }|
        ]])
      else
        screen:expect([[
                                                       |
          {2:[No Name]                                    }|
          {1::}set foldmethod=manual                       |
          {1::}let x = 1                                   |
          {1::}^                                            |
          {1:~                                            }|
          {3:[Command Line]                               }|
          :                                            |
        ]])
      end

      feed("kzfk")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          {2:[No Name]                                    }|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          [4:---------------------------------------------]|
          {3:[Command Line]                               }|
          [3:---------------------------------------------]|
        ## grid 2
                                                       |
        ## grid 3
          :                                            |
        ## grid 4
          {1::}{5:^+--  2 lines: set foldmethod=manual·········}|
          {1::}                                            |
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        screen:expect([[
                                                       |
          {2:[No Name]                                    }|
          {1::}{5:^+--  2 lines: set foldmethod=manual·········}|
          {1::}                                            |
          {1:~                                            }|
          {1:~                                            }|
          {3:[Command Line]                               }|
          :                                            |
        ]])
      end

      feed("<cr>")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          ^                                             |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
          :                                            |
        ]])
      else
        screen:expect([[
          ^                                             |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          :                                            |
        ]])
      end

      feed("/<c-f>")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          {2:[No Name]                                    }|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          {3:[Command Line]                               }|
          [3:---------------------------------------------]|
        ## grid 2
                                                       |
        ## grid 3
          /                                            |
        ## grid 5
          {1:/}alpha                                       |
          {1:/}{6:omega}                                       |
          {1:/}^                                            |
          {1:~                                            }|
        ]])
      else
        screen:expect([[
                                                       |
          {2:[No Name]                                    }|
          {1:/}alpha                                       |
          {1:/}{6:omega}                                       |
          {1:/}^                                            |
          {1:~                                            }|
          {3:[Command Line]                               }|
          /                                            |
        ]])
      end

      feed("ggzfG")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          {2:[No Name]                                    }|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          [5:---------------------------------------------]|
          {3:[Command Line]                               }|
          [3:---------------------------------------------]|
        ## grid 2
                                                       |
        ## grid 3
          /                                            |
        ## grid 5
          {1:/}{5:^+--  3 lines: alpha·························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ]])
      else
        screen:expect([[
                                                       |
          {2:[No Name]                                    }|
          {1:/}{5:^+--  3 lines: alpha·························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {3:[Command Line]                               }|
          /                                            |
        ]])
      end

    end)

    it("work with autoresize", function()

      funcs.setline(1, 'line 1')
      funcs.setline(2, 'line 2')
      funcs.setline(3, 'line 3')
      funcs.setline(4, 'line 4')

      feed("zfj")
      command("set foldcolumn=0")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:^+--  2 lines: line 1·························}|
          line 3                                       |
          line 4                                       |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {5:^+--  2 lines: line 1·························}|
          line 3                                       |
          line 4                                       |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end
      -- should adapt to the current nesting of folds (e.g., 1)
      command("set foldcolumn=auto:1")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  2 lines: line 1························}|
          {7: }line 3                                      |
          {7: }line 4                                      |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {7:+}{5:^+--  2 lines: line 1························}|
          {7: }line 3                                      |
          {7: }line 4                                      |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end
      command("set foldcolumn=auto")
      if multigrid then
        screen:expect{grid=[[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  2 lines: line 1························}|
          {7: }line 3                                      |
          {7: }line 4                                      |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]], unchanged=true}
      else
        screen:expect{grid=[[
          {7:+}{5:^+--  2 lines: line 1························}|
          {7: }line 3                                      |
          {7: }line 4                                      |
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]], unchanged=true}
      end
      -- fdc should not change with a new fold as the maximum is 1
      feed("zf3j")

      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  4 lines: line 1························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {7:+}{5:^+--  4 lines: line 1························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end

      command("set foldcolumn=auto:1")
      if multigrid then screen:expect{grid=[[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+}{5:^+--  4 lines: line 1························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]], unchanged=true}
      else
        screen:expect{grid=[[
          {7:+}{5:^+--  4 lines: line 1························}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]], unchanged=true}
      end

      -- relax the maximum fdc thus fdc should expand to
      -- accomodate the current number of folds
      command("set foldcolumn=auto:4")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {7:+ }{5:^+--  4 lines: line 1·······················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {7:+ }{5:^+--  4 lines: line 1·······················}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end
    end)

    it('does not crash when foldtext is longer than columns #12988', function()
      source([[
        function! MyFoldText() abort
          return repeat('-', &columns + 100)
        endfunction
      ]])
      command('set foldtext=MyFoldText()')
      feed("i<cr><esc>")
      feed("vkzf")
      if multigrid then
        screen:expect([[
        ## grid 1
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [2:---------------------------------------------]|
          [3:---------------------------------------------]|
        ## grid 2
          {5:^---------------------------------------------}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
        ## grid 3
                                                       |
        ]])
      else
        screen:expect([[
          {5:^---------------------------------------------}|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
          {1:~                                            }|
                                                       |
        ]])
      end
      assert_alive()
    end)
  end

  describe("with ext_multigrid", function()
    with_ext_multigrid(true)
  end)

  describe('without ext_multigrid', function()
    with_ext_multigrid(false)
  end)
end)
