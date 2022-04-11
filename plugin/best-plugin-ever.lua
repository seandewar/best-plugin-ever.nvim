local api = vim.api

if vim.fn.has "nvim-0.7" == 0 then
  api.nvim_echo({
    {
      "The best plugin ever requires Nvim v0.7+ >:(",
      "WarningMsg",
    },
  }, true, {})
  return
end

if vim.g.loaded_best_plugin_ever then
  return
end
vim.g.loaded_best_plugin_ever = 1

api.nvim_create_user_command("BestPluginEver", function()
  require("best-plugin-ever").start()
end, {
  desc = "EXPERIENCE the best plugin ever!!!",
})
