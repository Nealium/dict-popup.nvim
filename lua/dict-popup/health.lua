local M = {}

--- Plugin health check
M.check = function()
    vim.health.report_start("dict-popup report")
    if vim.fn.executable("dict") then
        vim.health.report_ok("dict command is executable")
    else
        vim.health.report_error("dict command is missing")
    end
end

return M
