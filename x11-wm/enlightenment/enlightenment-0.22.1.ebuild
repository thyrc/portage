# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

MY_P=${P/_/-}

if [[ ${PV} == *9999 ]] ; then
	EGIT_SUB_PROJECT="core"
	EGIT_URI_APPEND="${PN}"
else
	SRC_URI="https://download.enlightenment.org/rel/apps/${PN}/${MY_P}.tar.xz"
	EKEY_STATE="snap"
fi

inherit enlightenment

DESCRIPTION="Enlightenment DR21 window manager"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~arm ~x86"
SLOT="0.21/${PV%%_*}"

# The @ is just an anchor to expand from
__EVRY_MODS=""
__CONF_MODS="
	+@applications +@bindings +@dialogs +@display
	+@interaction +@intl +@menus
	+@paths +@performance +@randr +@shelves +@theme
	+@window-manipulation +@window-remembers"
__NORM_MODS="
	+@appmenu +@backlight +@bluez4 +@battery
	+@clock +@conf +@connman +@cpufreq +@everything
	+@fileman +@fileman-opinfo +@gadman +@geolocation
	+@ibar +@ibox +@lokker +@mixer +@msgbus +@music-control
	+@notification +@packagekit +@pager +@pager-plain
	+@quickaccess +@shot +@start +@syscon
	+@sysinfo +@systray +@tasks +@teamwork +@temperature
	+@tiling +@time +@winlist +@wireless +@wizard
	@wl-buffer @wl-desktop-shell @wl-drm @wl-text-input @wl_weekeyboard
	@wl-wl @wl-x11 +@xkbswitch @xwayland"
IUSE_E_MODULES="
	${__CONF_MODS//@/enlightenment_modules_conf-}
	${__NORM_MODS//@/enlightenment_modules_}"

IUSE="pam spell static-libs systemd +udev ukit wayland ${IUSE_E_MODULES}"

RDEPEND="
	pam? ( sys-libs/pam )
	systemd? ( sys-apps/systemd )
	wayland? (
		dev-libs/efl[wayland]
		>=dev-libs/wayland-1.10.0
		>=dev-libs/wayland-protocols-1.3
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1
	)
	>=dev-libs/efl-1.18[X]
	x11-libs/xcb-util-keysyms"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/quickstart.diff
	epatch "${FILESDIR}"/${PN}-0.22.1-no-desklock_hide-on-error.patch
	enlightenment_src_prepare
}

src_configure() {
	E_ECONF=(
		--disable-install-sysactions
		$(use_enable doc)
		$(use_enable nls)
		$(use_enable pam)
		$(use_enable systemd)
		--enable-device-udev
		$(use_enable udev mount-eeze)
		$(use_enable ukit mount-udisks)
		$(use_enable wayland)
	)
	local u c
	for u in ${IUSE_E_MODULES} ; do
		u=${u#+}
		c=${u#enlightenment_modules_}
		E_ECONF+=( $(use_enable ${u} ${c}) )
	done
	enlightenment_src_configure
}

src_install() {
	enlightenment_src_install
	insinto /etc/enlightenment
	newins "${FILESDIR}"/gentoo-sysactions.conf sysactions.conf
}
