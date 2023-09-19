source (/usr/bin/starship init fish --print-full-init | psub)
# source (/usr/bin/starship init fish --print-full-init | string trim | psub)

set -gx EMSDK /usr/lib/emscripten
set -gx EM_CONFIG /etc/emscripten/emscripten-config
set -gx EM_CACHE $EMSDK/cache
set -gx EM_PORTS $EMSDK/ports
set -gx PATH $EMSDK $PATH


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/kana/anaconda3/bin/conda
    eval /home/kana/anaconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

thefuck --alias | source

