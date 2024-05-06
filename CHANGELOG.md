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
* Added optional ability to "stack" a cursor popup on top of a center popup,
  instead of overwriting the contents.
* New `opts` stack (boolean) [default = false]

### Changes
* New close keymap for stacked popups `<C-w>` as an attempt to reduce the
  chances of having the centered popup unfocused
