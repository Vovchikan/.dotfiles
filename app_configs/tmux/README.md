## After installation script

При вервом запуске tmux автоматически скачает пакетный менеджер. Остальные плагины нужно скачать вручную, нажав комбинацию клавиш - `prefix` + <kbd>I</kbd>.

## Key Bindings

### TPM

`prefix` + <kbd>I</kbd>

- Installs new plugins from GitHub or any other git repository
- Refreshes TMUX environment

`prefix` + <kbd>U</kbd>

- updates plugin(s)

`prefix` + <kbd>alt</kbd> + <kbd>u</kbd>

- remove/uninstall plugins not on the plugin list

### Navigate between windows

```
Ctrl-shift-left  - previous-window
Ctrl-shift-right - next-window

prefix + w - show all windows
prefix + l - switch to last pane (in one session)
prefix + L - switch to last pane (in all sessions)
```

### Else

```
prefix + r - reload .tmux.conf
prefix + z - Fill screen with current pane (Zoom)

prefix + Ctrl-l - clear screen in current tmux pane
prefix + Ctrl-\ - send `SIGQUIT`
```

### Tmux-ressurect

The default key bindings are:

    prefix + Ctrl-s - save
    prefix + Ctrl-r - restore

To change these, add to .tmux.conf:

```
set -g @resurrect-save 'S'
set -g @resurrect-restore 'R'
```
