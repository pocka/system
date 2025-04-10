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

final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "d38d10b2cc8867e68b08d2ad19aabcbfabe9df74";
      hash = "sha256-13rv3rPr10OYmBePTu5V1499lF8r1/6NTEC02o7Tc2k=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

