# nvim config

## Tasks

- [ ] LSP `foldexpr`.
- [ ] LSP `formatexpr`.
- [ ] Enable `spell` in some places
- [ ] implement cfilter-plugin + Cfilter in lua
- [ ] shortmess +c to remove completion spam
- [ ] add types to quickfixtextfunc
  - [ ] `info` paramter
  - [ ] `item` paramters (`format_name`, `format_metadata`)
  - [ ] `get_items`

## Blocked

- [ ] Disable completion for clients when they disconnect.
  `vim.lsp.completion.enable(false, client.id, buf)` seems broken.
- [ ] De-duplicate shared LSP method handlers (e.g. codeLens) between clients
  of the same buffer. Hopefully `vim.lsp.codelens.refresh` takes a `client_id`
  parameter in future.
- [ ] Windows support. Need to verify things like path normalization.
