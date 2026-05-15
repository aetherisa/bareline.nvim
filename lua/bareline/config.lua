local M = {}
local current = {}
local defaults = {
	layout = {
		min_width = 20,
		scrolloff = 1,
		gap = 1,
	},
	buffer = {
		active = {
			char = "-",
			hl = "DiagnosticFloatingOk"
		},
		inactive = {
			char = "-",
			hl = "LineNr"
		}
	},
	indicator = {
		left = {
			text = "<< ",
			hl = "LineNr",
		},
		right = {
			text = " >>",
			hl = "LineNr"
		}
	}
}

M.setup = function(opts)
	current  = vim.tbl_deep_extend("force", defaults, opts or {})
end

M.get = function()
	return current
end

return M
