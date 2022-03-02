local api = vim.api
local loop = vim.loop

local nope = vim.split(
  [[
    xn     #nx    ,x#@z`    xxxxxz,   nnnnnnnn.
    ###    x##  ##########  ######### ########.
    ####*  x##`##@     `### ##n   ,##@##`
    ##@##, x####x        ##x##n   `#####++++++
    ##.:##Mx####;        W########### ########
    ##.  #####M##       :##:######z   ##`
    ##.   #### x###* `n###: ##n       ##,,,,,,`
    ##.    @##  .#######W   ##n       ########,]],
  "\n"
)
local dog = vim.split(
  [[
   *##`                               i######x#i
   `####;                            #####*n# #x
    n######.       `:*#zz#i.       W####Wi`@@ #n
     *##W####i+`              :#######:   `.M##i
      ##n#`                        ###;    ,@##
       ##@       ;:                  .i##;**##`
       n#  W#####M;, # ,#@              W#####
      M########## #: #######:           *####M
     ############    #########@+#z      `#####
     ####`M# `###    ##### ##  z####:     :##n
    `#####i:n##W      ####  . n######i      ##
    i#############M   x#############`       W#
    *#z###x    :##i     ############x       .#
    i####    `###@##W      ,########;        #`
    ,####   #:        #      nzzzzz          :x
     ####: :;          W     +#Win            #
    ,#######            i.  x#M####           #i
    ,########i            :#######W           .#,
    ;################x                         #
    z############x                             ##]],
  "\n"
)
local dog_maxcol = 0
for _, line in ipairs(dog) do
  dog_maxcol = math.max(dog_maxcol, #line)
end
local dog_flipped = {}
for _, line in ipairs(dog) do
  dog_flipped[#dog_flipped + 1] = (" "):rep(dog_maxcol - #line)
    .. line:reverse()
end

local ns = api.nvim_create_namespace "best-plugin-ever"
local dog_timer, hl_timer = loop.new_timer(), loop.new_timer()
local buf, win, dog_extmark

local flip = false
local function update_dog()
  api.nvim_buf_set_lines(buf, #nope, -1, true, flip and dog_flipped or dog)
  dog_extmark = api.nvim_buf_set_extmark(
    buf,
    ns,
    #nope,
    0,
    { id = dog_extmark, end_row = #nope + #dog, hl_group = "BestPluginEverDog" }
  )
  flip = not flip
end

local function update_hl()
  local function rand_hl_fg(hl)
    api.nvim_set_hl(
      0,
      hl,
      { foreground = math.random(0, 16777216), ctermfg = math.random(0, 16) }
    )
  end
  rand_hl_fg "BestPluginEverNope"
  rand_hl_fg "BestPluginEverDog"
  vim.cmd "redraw!"
end

local M = {}

local width, height = 50, 28
function M.start()
  if win then
    return
  end

  if not buf or not api.nvim_buf_is_loaded(buf) then
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, nope)
    api.nvim_buf_set_extmark(
      buf,
      ns,
      0,
      0,
      { end_row = #nope, hl_group = "BestPluginEverNope" }
    )
  end

  win = api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    col = math.max(0, math.floor((vim.o.columns - width) / 2) - 1),
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
  })

  api.nvim_create_autocmd("WinLeave", {
    once = true,
    buffer = buf,
    callback = function()
      hl_timer:stop()
      dog_timer:stop()
      api.nvim_win_close(win, true)
      win = nil
    end,
  })

  hl_timer:start(0, 250, vim.schedule_wrap(update_hl))
  dog_timer:start(0, 500, vim.schedule_wrap(update_dog))
end

return M
