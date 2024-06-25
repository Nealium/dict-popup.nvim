# Changelog

## 1.1.0 (2024-03-09)

### Features
* Added Center popup for `:Dict` command

### Changes
* Internal `dict.Call` has been changed to `dict.Cursor`
* Cursor popup's positioning as been moved one line down

## 1.2.0 (2024-05-06)

### Features
* Ability to call dict commands inside of a dict popup, overwriting the contents

### Changes
* Complete rewrite to be object based

## 1.3.0 (2024-05-06)

### Features
* Optional ability to "stack" a cursor popup on top of a center popup,
  instead of overwriting the contents.
* `opts` "stack" (boolean) [default = false]

### Changes
* New close keymap for stacked popups `<C-w>` as an attempt to reduce the
  chances of having the centered popup unfocused

## 1.4.0 (2024-05-07)

### Features
* Added search jumplist, ability to go forward and back when calling dict
  commands inside of a dict popup
* Next and previous definition jump

### Changes
* Added bufnr to close instead of depending on current buffer

## 1.4.5 (2024-05-15)

### Features
* Health check

### Changes
* Protected call for the `dict` command in case it isn't executable
* Jumplist splicing was hardcoded to "2" instead of using the current index in
  the list
* Proper argument validation for the `:Dict` command
* All Print statements to use vim.notify instead

## 1.4.6 (2024-06-24)

### Changes
* Removed default `<Leader>h` bindings and is default to `nil` (no mapping)
* Changed default visual register to `*`
* Added buffer keymaps to opts under `buffer_mappings`
* Updated documentation
* Fixed my horrible spelling (Thanks Typo!)
