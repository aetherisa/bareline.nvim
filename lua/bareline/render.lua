local M = {}

local state = {
	starti = 1
}

M.render = function()
	local config = require("bareline.config").get()
	local allbufs = vim.api.nvim_list_bufs()
	local curbufnr = vim.api.nvim_get_current_buf()
	local leftlen = vim.fn.strdisplaywidth(config.indicator.left.text)
	local rightlen = vim.fn.strdisplaywidth(config.indicator.right.text)
	local listbufs = {}
	local curbufi = 0

	-- get buffers with buflisted
	for _, bufnr in ipairs(allbufs) do
		if vim.bo[bufnr].buflisted then
			table.insert(listbufs, bufnr)
			if curbufnr == bufnr then
				curbufi = #listbufs
			end
		end
	end

	if #listbufs == 0 then
		return ""
	end

	-- get buffers should be displays 
	-- based on maxinum can be displayed at once
	local maxdisplay = math.floor(
		(vim.o.columns - leftlen - rightlen + config.layout.gap) / 
		(config.layout.min_width + config.layout.gap))
	local displays = {}
	local left = false
	local right = false

	if #listbufs <= maxdisplay then
		displays = listbufs
		state.starti = 1
	else
		local maxstarti = #listbufs - maxdisplay + 1
		local starti = math.min(math.max(state.starti, 1), maxstarti)
		local endi = starti + maxdisplay - 1
		local scrolloff = math.min(config.layout.scrolloff, math.floor(maxdisplay / 2))

		if curbufi < starti + scrolloff then
			starti = math.max(curbufi - scrolloff, 1)
			endi = starti + maxdisplay - 1
		elseif endi - scrolloff < curbufi then
			endi = math.min(curbufi + scrolloff, #listbufs)
			starti = endi - maxdisplay + 1
		end

		starti = math.min(math.max(starti, 1), maxstarti)
		endi = starti + maxdisplay - 1

		state.starti = starti

		for i = starti, endi do
			table.insert(displays, listbufs[i])
		end

		if starti > 1 then
			left = true
		end

		if endi < #listbufs then
			right = true
		end
	end

	-- generate tabline string
	local total_gap = config.layout.gap * (#displays - 1)
	local available = vim.o.columns - total_gap - leftlen - rightlen
	local base_width = math.floor(available / #displays)
	local remainder = available % #displays 
	local parts = {}

	parts[#parts + 1] = "%#"
	parts[#parts + 1] = config.indicator.left.hl
	parts[#parts + 1] = "#"
	parts[#parts + 1] = left
		and config.indicator.left.text
		or string.rep(" ", leftlen)

	for i = 1, #displays do
		local item_width = base_width
		if i <= remainder then
			item_width = item_width + 1
		end

		parts[#parts + 1] = "%#"
		parts[#parts + 1] = curbufnr == displays[i]
			and config.buffer.active.hl
			or config.buffer.inactive.hl
		parts[#parts + 1] = "#"
		parts[#parts + 1] = curbufnr == displays[i]
			and string.rep(config.buffer.active.char, item_width)
			or string.rep(config.buffer.inactive.char, item_width)
		parts[#parts + 1] = i == #displays
			and ""
			or string.rep(" ", config.layout.gap)
	end

	parts[#parts + 1] = "%#"
	parts[#parts + 1] = config.indicator.right.hl
	parts[#parts + 1] = "#"
	parts[#parts + 1] = right
		and config.indicator.right.text
		or string.rep(" ", rightlen)

	return table.concat(parts)
end

return M
