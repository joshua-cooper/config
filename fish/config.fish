set -g fish_greeting
set -g fish_key_bindings fish_vi_key_bindings

fish_add_path -m ~/.local/bin

if type -q direnv
	direnv hook fish | source
end
