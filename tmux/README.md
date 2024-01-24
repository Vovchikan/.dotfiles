### After installation script

При вервом запуске tmux автоматически скачает пакетный менеджер. Остальные плагины нужно скачать вручную, нажав комбинацию клавиш - `prefix` + <kbd>I</kbd>.

### Key bindings

`prefix` + <kbd>I</kbd>

- Installs new plugins from GitHub or any other git repository
- Refreshes TMUX environment

`prefix` + <kbd>U</kbd>

- updates plugin(s)

`prefix` + <kbd>alt</kbd> + <kbd>u</kbd>

- remove/uninstall plugins not on the plugin list

### Tmux-ressurect key bindings

The default key bindings are:

    prefix + Ctrl-s - save
    prefix + Ctrl-r - restore

To change these, add to .tmux.conf:

```
set -g @resurrect-save 'S'
set -g @resurrect-restore 'R'
```
