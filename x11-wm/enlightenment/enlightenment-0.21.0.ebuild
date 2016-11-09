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

inherit enlightenment pax-utils

DESCRIPTION="Enlightenment DR20 window manager"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~arm ~x86"
SLOT="0.21/${PV%%_*}"

# The @ is just an anchor to expand from
__EVRY_MODS=""
__CONF_MODS="
	+@applications +@dialogs +@display
	+@interaction +@intl +@menus
	+@paths +@performance +@randr +@shelves +@theme
	+@window-manipulation +@window-remembers"
__NORM_MODS="
	+@appmenu +@backlight +@bluez4 +@battery +@clock
	+@connman +@cpufreq +@everything +@fileman
	+@fileman-opinfo +@gadman +@ibar +@ibox +@mixer +@msgbus
	+@music-control +@notification +@pager +@quickaccess +@shot
	+@start +@syscon +@systray +@tasks +@teamwork +@temperature +@tiling
	+@winlist +@wizard @wl-desktop-shell @wl_weekeyboard +@xkbswitch"
IUSE_E_MODULES="
	${__CONF_MODS//@/enlightenment_modules_conf-}
	${__NORM_MODS//@/enlightenment_modules_}"

IUSE="pam pax_kernel spell static-libs systemd +udev ukit wayland ${IUSE_E_MODULES}"

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
	>=dev-libs/efl-1.17.0[X]
	>=media-libs/elementary-1.17.0
	x11-libs/xcb-util-keysyms"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/quickstart.diff
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
		$(use_enable wayland wayland)
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
	if use pax_kernel; then
		pax-mark m "${D}"/usr/bin/enlightenment || die "pax-mark failed"
		pax-mark m "${D}"/usr/bin/enlightenment_filemanager || die "pax-mark failed"
	fi
	insinto /etc/enlightenment
	newins "${FILESDIR}"/gentoo-sysactions.conf sysactions.conf
}