#! /usr/bin/env bash

DEFAULT_COLUMNS="80"
DEFAULT_ROWS="45"

putty_color_scheme="
Colour0\187,187,187\
Colour1\255,255,255\
Colour2\0,0,0\
Colour3\85,85,85\
Colour4\0,0,0\
Colour5\0,255,0\
Colour6\0,0,0\
Colour7\85,85,85\
Colour8\255,53,53\
Colour9\255,85,85\
Colour10\0,221,0\
Colour11\85,255,85\
Colour12\236,236,0\
Colour13\255,255,85\
Colour14\85,85,255\
Colour15\85,85,255\
Colour16\206,0,206\
Colour17\255,85,255\
Colour18\0,204,204\
Colour19\85,255,255\
Colour20\187,187,187\
Colour21\255,255,255\
Colour22\187,187,187\
Colour23\0,0,0\
Colour24\0,0,0\
Colour25\187,0,0\
Colour26\0,187,0\
Colour27\187,187,0\
Colour28\0,0,187\
Colour29\187,0,187\
Colour30\0,187,187\
Colour31\187,187,187\
Colour32\0,0,0\
Colour33\187,187,187\
"

# for kitty seesion file form
colors=$(echo "${putty_color_scheme}" | perl -e '
while(<>) {
	push @c, m/Colou?r\d+[\s\\]*?(\d+,\d+,\d+)/g;
}
print join(":", map { @a=split/,/,$_; sprintf("rgb(%d,%d,%d)", @a[0,1,2]) } @c);')
# for putty registry form
# colors=$(echo "$putty" | perl -e '
# while(<>) {
#     push @c, m/Colou?r\d+[\s="]*?(\d+,\d+,\d+)/g;
# }
# print join(":", map { @a=split/,/,$_; sprintf("rgb(%d,%d,%d)", @a[0,1,2]) } @c);')

rgb_fg=$(echo ${colors} | cut -d : -f 1)
rgb_fg_bold=$(echo ${colors} | cut -d : -f 2)
rgb_bg=$(echo ${colors} | cut -d : -f 3)
rgb_palette=$(
	echo [\'$(echo $(
		echo ${colors} |
			awk -F : 'OFS=", " {print $7,$9,$11,$13,$15,$17,$19,$21,$8,$10,$12,$14,$16,$18,$20,$22}'
	) |
		sed -e "s/, /', '/g")\']
)

profile="default"
profile_uuid="$(gsettings get org.gnome.Terminal.ProfilesList ${profile} | tr -d "'")"

gsettings set \
	"org.gnome.desktop.default-applications.terminal" \
	exec "gnome-terminal"
gsettings set \
	"org.gnome.Terminal.Legacy.Settings" \
	mnemonics-enabled false
gsettings set \
	"org.gnome.Terminal.Legacy.Settings" \
	menu-accelerator-enabled false
gsettings set \
	"org.gnome.Terminal.Legacy.Settings" \
	shortcuts-enabled true
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	default-size-columns ${DEFAULT_COLUMNS}
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	default-size-rows ${DEFAULT_ROWS}
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	use-system-font false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	font "Monospace 12"
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	use-theme-colors false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	bold-color-same-as-fg false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	cursor-colors-set false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	highlight-colors-set false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	use-theme-transparency false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	use-transparent-background false
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	bold-is-bright true
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	foreground-color "${rgb_fg}"
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	bold-color "${rgb_fg_bold}"
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	background-color "${rgb_bg}"
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	palette "${rgb_palette}"
gsettings set \
	"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/" \
	audible-bell false
