# Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: 0BSD

fish_vi_key_bindings

set -U fish_greeting

if command -q nix-your-shell
	nix-your-shell fish | source
end

function fish_right_prompt
	set -l environment

	if test -n "$SSH_CLIENT" -o -n "$SSH_TTY"
		set -a environment "SSH"
	end

	if test -n "$IN_NIX_SHELL"
		set -a environment "Nix"
	end

	echo -n (set_color blue)(string join ", " $environment)
	set_color normal
end

function fish_prompt
	# This is a simple prompt. It looks like
	# alfa@nobby /path/to/dir $
	# with the path shortened and colored
	# and a "#" instead of a "$" when run as root.
	set -l symbol ' $ '
	set -l color $fish_color_cwd
	if fish_is_root_user
		set symbol ' # '
		set -q fish_color_cwd_root
		and set color $fish_color_cwd_root
	end

	echo -n $USER@$hostname

	set_color $color
	echo -n (prompt_pwd)
	set_color normal

	echo -n $symbol
end
