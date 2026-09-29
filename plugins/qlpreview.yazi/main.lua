-- qlpreview.yazi: macOS Quick Look Office 预览
-- 来源: https://github.com/Fun10165/qlpreview (MIT)
-- 适配 Yazi 26.9.1: File 提供 url, 不提供 path.
local M = {}

function M:peek(job)
	if ya.target_os() ~= "macos" then
		return require("file"):peek(job)
	end

	local cache = ya.file_cache(job)
	if not cache or not fs.cha(cache) then
		return
	end

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	if ya.target_os() ~= "macos" then
		return require("file"):seek(job)
	end
	ya.emit("peek", { 0, only_if = job.file.url })
end

function M:preload(job)
	if ya.target_os() ~= "macos" then
		return true
	end

	local cache = ya.file_cache(job)
	if not cache then
		return false
	end
	if fs.cha(cache) then
		return true
	end

	local filepath = tostring(job.file.url)
	local filename = job.file.name
	local cache_path = tostring(cache)
	local tmpdir = "/tmp/qlpreview-" .. ya.uid()
	Command("mkdir"):arg("-p"):arg(tmpdir):output()

	local output = Command("perl")
		:arg("-e")
		:arg("alarm 15; exec @ARGV")
		:arg("qlmanage")
		:arg("-t")
		:arg("-s"):arg("4096")
		:arg("-o"):arg(tmpdir)
		:arg(filepath)
		:stderr(Command.PIPED)
		:output()

	if not output or not output.status.success then
		return false
	end

	local thumb = tmpdir .. "/" .. filename .. ".png"
	if not fs.cha(Url(thumb)) then
		return false
	end

	local cp = Command("cp")
		:arg(thumb)
		:arg(cache_path)
		:stderr(Command.PIPED)
		:output()

	os.remove(thumb)
	return cp and cp.status.success or false
end

return M
