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
local stuff_timer, hl_timer = loop.new_timer(), loop.new_timer()
local buf, win, dog_extmark, rocket_buf, rocket_wins

local tick = 1
local function update_stuff()
  api.nvim_buf_set_lines(
    buf,
    #nope,
    -1,
    true,
    tick % 2 == 0 and dog or dog_flipped
  )
  dog_extmark = api.nvim_buf_set_extmark(
    buf,
    ns,
    #nope,
    0,
    { id = dog_extmark, end_row = #nope + #dog, hl_group = "BestPluginEverDog" }
  )

  for i, rocket_win in ipairs(rocket_wins) do
    local offset = i % 3 == 0 and 2 or 1
    local config = api.nvim_win_get_config(rocket_win)
    local row = config.row[vim.val_idx]

    if row < 1 then
      config.col = math.random(0, vim.o.columns - 1)
      config.row = math.max(0, vim.o.lines - vim.o.cmdheight - offset)
    else
      config.row = math.max(0, row - offset)
    end
    api.nvim_win_set_config(rocket_win, config)
  end

  local echo_text = "NOPE "
  local len = math.max(0, math.floor(vim.o.columns / #echo_text) - 4)
  local chunks = {}
  for i = 1, len do
    local text = echo_text
    if i == 1 then
      text = text:sub(1 + (tick % #text))
    elseif i == len then
      text = text:sub(1, (tick % #text) - #text)
    end
    chunks[i] = {
      text,
      i % 2 == 0 and "BestPluginEverNope" or "BestPluginEverDog",
    }
  end
  vim.cmd "redraw"
  api.nvim_echo(chunks, false, {})

  tick = tick + 1
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

local function update(fn)
  vim.schedule(function()
    api.nvim_buf_set_option(buf, "modifiable", true)
    fn()
    api.nvim_buf_set_option(buf, "modifiable", false)
  end)
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
    zindex = 300,
    width = width,
    height = height,
    col = math.max(0, math.floor((vim.o.columns - width) / 2) - 1),
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
  })

  if not rocket_buf or not api.nvim_buf_is_loaded(rocket_buf) then
    rocket_buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(rocket_buf, 0, -1, true, { "🚀" })
  end

  rocket_wins = {}
  for i = 1, math.floor(vim.o.columns / 5) do
    rocket_wins[i] = api.nvim_open_win(rocket_buf, false, {
      relative = "editor",
      style = "minimal",
      zindex = 150,
      width = 2,
      height = 1,
      col = math.random(0, math.max(0, vim.o.columns - 1)),
      row = math.random(0, math.max(0, vim.o.lines - vim.o.cmdheight)),
    })
  end

  api.nvim_create_augroup("BestPluginEver", {})
  api.nvim_create_autocmd({ "VimLeavePre", "BufLeave", "WinLeave" }, {
    group = "BestPluginEver",
    buffer = buf,
    once = true,
    callback = function()
      if not win then
        return
      end

      hl_timer:stop()
      stuff_timer:stop()

      api.nvim_win_close(win, true)
      win = nil
      api.nvim_echo({ { "" } }, false, {})
      for _, rocket_win in ipairs(rocket_wins) do
        api.nvim_win_close(rocket_win, true)
      end
      rocket_wins = nil
    end,
  })

  hl_timer:start(0, 250, function()
    update(update_hl)
  end)
  stuff_timer:start(0, 500, function()
    update(update_stuff)
  end)
end

return M
