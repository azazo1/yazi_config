--- @sync entry
-- 切换当前标签的大小排序, 再次执行时恢复原有设置.
local M = {}

function M:entry()
	self.previous = self.previous or {}
	local tab = cx.active.id
	local pref = cx.active.pref
	local active = pref.sort_by == "size"
		and pref.sort_reverse
		and not pref.sort_dir_first
		and pref.linemode == "size"

	if active then
		-- 新标签会继承当前排序, 但不会继承此插件记录的切换状态.
		local saved = self.previous[tab] or self.last_previous or {
			sort_by = rt.mgr.sort_by or "alphabetical",
			sort_reverse = rt.mgr.sort_reverse or false,
			sort_dir_first = rt.mgr.sort_dir_first ~= false,
			linemode = rt.mgr.linemode or "none",
		}
		self.previous[tab] = nil
		ya.emit("sort", {
			saved.sort_by,
			reverse = saved.sort_reverse and "yes" or "no",
			dir_first = saved.sort_dir_first and "yes" or "no",
		})
		ya.emit("linemode", { saved.linemode })
		return
	end

	local saved = {
		sort_by = pref.sort_by,
		sort_reverse = pref.sort_reverse,
		sort_dir_first = pref.sort_dir_first,
		linemode = pref.linemode,
	}
	self.previous[tab] = saved
	self.last_previous = saved
	ya.emit("sort", { "size", reverse = "yes", dir_first = "no" })
	ya.emit("linemode", { "size" })
end

return M
