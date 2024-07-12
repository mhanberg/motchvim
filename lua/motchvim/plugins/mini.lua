local statusline = function()
  require("mini.statusline").setup()
end

local hipatterns = function()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup {
    highlighters = {
      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  }
end

local comment = function()
  require("mini.comment").setup()
end

local starter = function()
  local fzflua = function()
    return function()
      return {
        { action = "FzfLua files", name = "Find File", section = "Files" },
        { action = "Neotree", name = "Neotree", section = "Files" },
      }
    end
  end

  local header

  if vim.fn.hostname() == "alt-mhanberg.localdomain" then
    header = [[
       @@@@@@ @@@ @@@@@@@@@@  @@@@@@@  @@@      @@@@@@@@ @@@@@@@  @@@@@@@@ @@@@@@@
      !@@     @@! @@! @@! @@! @@!  @@@ @@!      @@!      @@!  @@@ @@!        @@!  
       !@@!!  !!@ @!! !!@ @!@ @!@@!@!  @!!      @!!!:!   @!@!@!@  @!!!:!     @!!  
          !:! !!: !!:     !!: !!:      !!:      !!:      !!:  !!! !!:        !!:  
      ::.: :  :    :      :    :       : ::.: : : :: ::: :: : ::  : :: :::    :   
      ]]
  else
    header = [[
				@@@@@@@@@@    @@@@@@   @@@@@@@   @@@@@@@  @@@  @@@  @@@  @@@  @@@  @@@@@@@@@@
				@@@@@@@@@@@  @@@@@@@@  @@@@@@@  @@@@@@@@  @@@  @@@  @@@  @@@  @@@  @@@@@@@@@@@
				@@! @@! @@!  @@!  @@@    @@!    !@@       @@!  @@@  @@!  @@@  @@!  @@! @@! @@!
				!@! !@! !@!  !@!  @!@    !@!    !@!       !@!  @!@  !@!  @!@  !@!  !@! !@! !@!
				@!! !!@ @!@  @!@  !@!    @!!    !@!       @!@!@!@!  @!@  !@!  !!@  @!! !!@ @!@
				!@!   ! !@!  !@!  !!!    !!!    !!!       !!!@!!!!  !@!  !!!  !!!  !@!   ! !@!
				!!:     !!:  !!:  !!!    !!:    :!!       !!:  !!!  :!:  !!:  !!:  !!:     !!:
				:!:     :!:  :!:  !:!    :!:    :!:       :!:  !:!   ::!!:!   :!:  :!:     :!:
				:::     ::   ::::: ::     ::     ::: :::  ::   :::    ::::     ::  :::     :: 
				 :      :     : :  :      :      :: :: :   :   : :     :      :     :      :  
      ]]
  end
  local starter = require("mini.starter")
  starter.setup {
    header = header,
    items = { fzflua },
    content_hooks = {
      starter.gen_hook.aligning("center", "center"),
    },
  }
end

return {
  "echasnovski/mini.nvim",
  event = { "VimEnter", "BufReadPost", "BufNewFile" },
  -- dev = true,
  version = "*",
  config = function()
    statusline()
    hipatterns()
    comment()
    starter()
  end,
}
