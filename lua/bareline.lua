local M = {}

M.setup = function(opts)
	require("bareline.config").setup(opts)

	vim.o.tabline = "%!v:lua.require('bareline.render').render()"
	vim.o.showtabline = 2
end

return M
