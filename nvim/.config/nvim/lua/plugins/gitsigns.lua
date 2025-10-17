return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Recommended: keep defaults and add buffer-local maps on attach
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, lhs, rhs, desc, opts)
        opts = opts or {}
        opts.buffer = bufnr
        opts.desc = desc
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- Navigation (respect diff mode)
      map("n", "]c", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(gs.next_hunk)
        return "<Ignore>"
      end, "Next hunk", { expr = true })

      map("n", "[c", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(gs.prev_hunk)
        return "<Ignore>"
      end, "Prev hunk", { expr = true })

      -- Actions
      map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", function()
        gs.blame_line({ full = true })
      end, "Blame line (full)")
      map("n", "<leader>gt", gs.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>gd", gs.diffthis, "Diff (index)")
      map("n", "<leader>gD", function()
        gs.diffthis("~")
      end, "Diff (last commit)")

      -- Text object
      map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
    end,
  },
}
