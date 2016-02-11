# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
PYTHON_COMPAT=( python2_7 )

CHROMIUM_LANGS="am ar bg bn ca cs da de el en_GB es es_LA et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt_BR pt_PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh_CN zh_TW"

inherit check-reqs chromium eutils flag-o-matic git-r3 multilib multiprocessing pax-utils \
	portability python-any-r1 readme.gentoo-r1 toolchain-funcs versionator virtualx

LIBCC_COMMIT="ad63d8ba890bcaad2f1b7e6de148b7992f4d3af7"
CHROMIUM_VERSION="47.0.2526.110"

CHROMIUM_P="chromium-${CHROMIUM_VERSION}"

DESCRIPTION="Cross platform application development framework based on web technologies"
HOMEPAGE="http://electron.atom.io/"
SRC_URI="https://commondatastorage.googleapis.com/chromium-browser-official/${CHROMIUM_P}.tar.xz"
ELECTRON_REPO_URI="https://github.com/atom/electron.git"
BRIGHTRAY_S="${S}/vendor/brightray"
LIBCC_S="${BRIGHTRAY_S}/vendor/libchromiumcontent"
CHROMIUM_S="${LIBCC_S}/vendor/chromium/src"

LICENSE="BSD hotwording? ( no-source-code )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="custom-cflags cups gnome gnome-keyring gtk3 hangouts hidpi hotwording kerberos neon pic +proprietary-codecs pulseaudio selinux +system-ffmpeg +tcmalloc widevine"
RESTRICT="!system-ffmpeg? ( proprietary-codecs? ( bindist ) )"

# Native Client binaries are compiled with different set of flags, bug #452066.
QA_FLAGS_IGNORED=".*\.nexe"

# Native Client binaries may be stripped by the build system, which uses the
# right tools for it, bug #469144 .
QA_PRESTRIPPED=".*\.nexe"

RDEPEND=">=app-accessibility/speech-dispatcher-0.8:=
	app-arch/bzip2:=
	app-arch/snappy:=
	cups? ( >=net-print/cups-1.3.11:= )
	>=dev-libs/elfutils-0.149
	dev-libs/expat:=
	dev-libs/glib:=
	>=dev-libs/icu-55.1:=
	>=dev-libs/jsoncpp-0.5.0-r1:=
	>=dev-libs/libevent-1.4.13:=
	dev-libs/libxml2:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.14.3:=
	dev-libs/re2:=
	gnome? ( >=gnome-base/gconf-2.24.0:= )
	gnome-keyring? ( >=gnome-base/libgnome-keyring-3.12:= )
	>=media-libs/alsa-lib-1.0.19:=
	media-libs/flac:=
	media-libs/fontconfig:=
	media-libs/freetype:=
	>=media-libs/harfbuzz-0.9.41:=[icu(+)]
	media-libs/libexif:=
	>=media-libs/libjpeg-turbo-1.2.0-r1:=
	media-libs/libpng:0=
	>=media-libs/libwebp-0.4.0:=
	media-libs/speex:=
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? ( >=media-video/ffmpeg-2.7.2:=[opus,vorbis,vpx] )
	sys-apps/dbus:=
	sys-apps/pciutils:=
	>=sys-libs/libcap-2.22:=
	sys-libs/zlib:=[minizip]
	virtual/udev
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:=
	gtk3? ( x11-libs/gtk+:3= )
	!gtk3? ( x11-libs/gtk+:2= )
	x11-libs/libdrm
	x11-libs/libX11:=
	x11-libs/libXcomposite:=
	x11-libs/libXcursor:=
	x11-libs/libXdamage:=
	x11-libs/libXext:=
	x11-libs/libXfixes:=
	>=x11-libs/libXi-1.6.0:=
	x11-libs/libXinerama:=
	x11-libs/libXrandr:=
	x11-libs/libXrender:=
	x11-libs/libXScrnSaver:=
	x11-libs/libXtst:=
	x11-libs/pango:=
	kerberos? ( virtual/krb5 )"
DEPEND="${RDEPEND}
	!arm? (
		dev-lang/yasm
	)
	dev-lang/perl
	dev-perl/JSON
	>=dev-util/gperf-3.0.3
	dev-util/ninja
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	virtual/pkgconfig"

# For nvidia-drivers blocker, see bug #413637 .
RDEPEND+="
	x11-misc/xdg-utils
	virtual/opengl
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
	tcmalloc? ( !<x11-drivers/nvidia-drivers-331.20 )
	widevine? ( www-plugins/chrome-binary-plugins[widevine(-)] )"

# Python dependencies. The DEPEND part needs to be kept in sync
# with python_check_deps.
DEPEND+=" $(python_gen_any_dep '
	dev-python/beautifulsoup:python-2[${PYTHON_USEDEP}]
	dev-python/beautifulsoup:4[${PYTHON_USEDEP}]
	dev-python/html5lib[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	dev-python/ply[${PYTHON_USEDEP}]
	dev-python/simplejson[${PYTHON_USEDEP}]
')"
python_check_deps() {
	has_version "dev-python/beautifulsoup:python-2[${PYTHON_USEDEP}]" && \
		has_version "dev-python/beautifulsoup:4[${PYTHON_USEDEP}]" && \
		has_version "dev-python/html5lib[${PYTHON_USEDEP}]" && \
		has_version "dev-python/jinja[${PYTHON_USEDEP}]" && \
		has_version "dev-python/ply[${PYTHON_USEDEP}]" && \
		has_version "dev-python/simplejson[${PYTHON_USEDEP}]"
}

if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

pkg_pretend() {
	if [[ $(tc-getCC)$ == *gcc* ]] && \
		[[ $(gcc-major-version)$(gcc-minor-version) -lt 48 ]]; then
		die 'At least gcc 4.8 is required, see bugs: #535730, #525374, #518668.'
	fi

	# Check build requirements, bug #541816 and bug #471810 .
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="10G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="25G"
	fi
	eshopts_pop
	check-reqs_pkg_pretend
}

pkg_setup() {
	if [[ "${SLOT}" == "0" ]]; then
		CHROMIUM_SUFFIX=""
	else
		CHROMIUM_SUFFIX="-${SLOT}"
	fi
	CHROMIUM_HOME="/usr/$(get_libdir)/electron${CHROMIUM_SUFFIX}"

	# Make sure the build system will use the right python, bug #344367.
	python-any-r1_pkg_setup

	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	default_src_unpack || die

	EGIT_COMMIT="v${PV}" \
	EGIT_REPO_URI=${ELECTRON_REPO_URI} \
		git-r3_src_unpack || die

	# Fuse chromium and electron source together, as
	# this seems to be the only reasonable way to build and configure
	# everything in a single pass.
	rsync -a "${WORKDIR}/${CHROMIUM_P}/" "${S}/" || die
}

_unnest_patches() {
	local _s="${1%/}/" relpath out

	for f in $(find "${_s}" -mindepth 2 -name *.patch -printf \"%P\"\\n); do
		relpath="$(dirname ${f})"
		out="${_s}/${relpath////_}_$(basename ${f})"
		sed -r -e "s|^([-+]{3}) (.*)$|\1 ${relpath}/\2 ${f}|g" > "${out}"
	done
}

src_prepare() {
	# if ! use arm; then
	#	mkdir -p out/Release/gen/sdk/toolchain || die
	#	# Do not preserve SELinux context, bug #460892 .
	#	cp -a --no-preserve=context /usr/$(get_libdir)/nacl-toolchain-newlib \
	#		out/Release/gen/sdk/toolchain/linux_x86_newlib || die
	#	touch out/Release/gen/sdk/toolchain/linux_x86_newlib/stamp.untar || die
	# fi

	# electron patches
	epatch "${FILESDIR}/electron-gentoo-build-fixes.patch"

	# node patches
	cd "vendor/node"
	epatch "${FILESDIR}/node-gentoo-build-fixes.patch"

	# brightray patches
	cd "${BRIGHTRAY_S}"
	epatch "${FILESDIR}/brightray-gentoo-build-fixes.patch"

	# libcc patches
	cd "${LIBCC_S}"
	epatch "${FILESDIR}/libchromiumcontent-gentoo-build-fixes.patch"

	# chromium patches
	cd "${S}"
	epatch "${FILESDIR}/chromium-system-ffmpeg-r0.patch"
	epatch "${FILESDIR}/chromium-system-jinja-r7.patch"
	epatch "${FILESDIR}/chromium-widevine-r1.patch"
	epatch "${FILESDIR}/chromium-remove-gardiner-mod-font.patch"
	epatch "${FILESDIR}/chromium-shared-v8.patch"

	# libcc chromium patches
	_unnest_patches "${LIBCC_S}/patches"

	EPATCH_SOURCE="${LIBCC_S}/patches" \
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	EPATCH_EXCLUDE="third_party_icu*" \
	EPATCH_MULTI_MSG="Applying libchromiumcontent patches..." \
		epatch

	# build scripts
	mkdir -p "${S}/chromiumcontent"
	cp -a "${LIBCC_S}/chromiumcontent" "${S}/" || die
	cp -a "${LIBCC_S}/tools/linux/" "${S}/tools/" || die

	local conditional_bundled_libraries=""
	if ! use system-ffmpeg; then
		conditional_bundled_libraries+=" third_party/ffmpeg"
	fi

	# Remove most bundled libraries. Some are still needed.
	build/linux/unbundle/remove_bundled_libraries.py \
		${conditional_bundled_libraries} \
		'base/third_party/dmg_fp' \
		'base/third_party/dynamic_annotations' \
		'base/third_party/icu' \
		'base/third_party/nspr' \
		'base/third_party/superfasthash' \
		'base/third_party/symbolize' \
		'base/third_party/valgrind' \
		'base/third_party/xdg_mime' \
		'base/third_party/xdg_user_dirs' \
		'breakpad/src/third_party/curl' \
		'chrome/third_party/mozilla_security_manager' \
		'courgette/third_party' \
		'crypto/third_party/nss' \
		'net/third_party/mozilla_security_manager' \
		'net/third_party/nss' \
		'third_party/WebKit' \
		'third_party/analytics' \
		'third_party/angle' \
		'third_party/angle/src/third_party/compiler' \
		'third_party/boringssl' \
		'third_party/brotli' \
		'third_party/cacheinvalidation' \
		'third_party/catapult' \
		'third_party/catapult/tracing/third_party/components/polymer' \
		'third_party/catapult/tracing/third_party/d3' \
		'third_party/catapult/tracing/third_party/gl-matrix' \
		'third_party/catapult/tracing/third_party/jszip' \
		'third_party/catapult/tracing/third_party/tvcm' \
		'third_party/catapult/tracing/third_party/tvcm/third_party/rcssmin' \
		'third_party/catapult/tracing/third_party/tvcm/third_party/rjsmin' \
		'third_party/cld_2' \
		'third_party/cros_system_api' \
		'third_party/cython/python_flags.py' \
		'third_party/devscripts' \
		'third_party/dom_distiller_js' \
		'third_party/dom_distiller_js/dist/proto_gen/third_party/dom_distiller_js' \
		'third_party/fips181' \
		'third_party/flot' \
		'third_party/google_input_tools' \
		'third_party/google_input_tools/third_party/closure_library' \
		'third_party/google_input_tools/third_party/closure_library/third_party/closure' \
		'third_party/hunspell' \
		'third_party/iccjpeg' \
		'third_party/jstemplate' \
		'third_party/khronos' \
		'third_party/leveldatabase' \
		'third_party/libXNVCtrl' \
		'third_party/libaddressinput' \
		'third_party/libjingle' \
		'third_party/libphonenumber' \
		'third_party/libsecret' \
		'third_party/libsrtp' \
		'third_party/libudev' \
		'third_party/libusb' \
		'third_party/libvpx_new' \
		'third_party/libvpx_new/source/libvpx/third_party/x86inc' \
		'third_party/libxml/chromium' \
		'third_party/libwebm' \
		'third_party/libyuv' \
		'third_party/lss' \
		'third_party/lzma_sdk' \
		'third_party/mesa' \
		'third_party/modp_b64' \
		'third_party/mojo' \
		'third_party/mt19937ar' \
		'third_party/npapi' \
		'third_party/openmax_dl' \
		'third_party/opus' \
		'third_party/ots' \
		'third_party/pdfium' \
		'third_party/pdfium/third_party/agg23' \
		'third_party/pdfium/third_party/base' \
		'third_party/pdfium/third_party/bigint' \
		'third_party/pdfium/third_party/freetype' \
		'third_party/pdfium/third_party/lcms2-2.6' \
		'third_party/pdfium/third_party/libjpeg' \
		'third_party/pdfium/third_party/libopenjpeg20' \
		'third_party/pdfium/third_party/zlib_v128' \
		'third_party/polymer' \
		'third_party/protobuf' \
		'third_party/qcms' \
		'third_party/readability' \
		'third_party/sfntly' \
		'third_party/skia' \
		'third_party/smhasher' \
		'third_party/sqlite' \
		'third_party/tcmalloc' \
		'third_party/usrsctp' \
		'third_party/web-animations-js' \
		'third_party/webdriver' \
		'third_party/webrtc' \
		'third_party/widevine' \
		'third_party/x86inc' \
		'third_party/zlib/google' \
		'url/third_party/mozilla' \
		'v8/src/third_party/fdlibm' \
		'v8/src/third_party/valgrind' \
		--do-remove || die

	epatch_user
}

src_configure() {
	local myconf=""

	# Never tell the build system to "enable" SSE2, it has a few unexpected
	# additions, bug #336871.
	myconf+=" -Ddisable_sse2=1"

	# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
	myconf+=" -Ddisable_nacl=1"

	# Disable glibc Native Client toolchain, we don't need it (bug #417019).
	# myconf+=" -Ddisable_glibc=1"

	# TODO: also build with pnacl
	# myconf+=" -Ddisable_pnacl=1"

	# It would be awkward for us to tar the toolchain and get it untarred again
	# during the build.
	# myconf+=" -Ddisable_newlib_untar=1"

	# Make it possible to remove third_party/adobe.
	echo > "${T}/flapper_version.h" || die
	myconf+=" -Dflapper_version_h_file=${T}/flapper_version.h"

	# Use system-provided libraries.
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_libsrtp (bug #459932).
	# TODO: use_system_libusb (http://crbug.com/266149).
	# TODO: use_system_libvpx (http://crbug.com/494939).
	# TODO: use_system_opus (https://code.google.com/p/webrtc/issues/detail?id=3077).
	# TODO: use_system_protobuf (bug #525560).
	# TODO: use_system_ssl (http://crbug.com/58087).
	# TODO: use_system_sqlite (http://crbug.com/22208).
	myconf+="
		-Duse_system_bzip2=1
		-Duse_system_ffmpeg=$(usex system-ffmpeg 1 0)
		-Duse_system_flac=1
		-Duse_system_harfbuzz=1
		-Duse_system_icu=1
		-Duse_system_jsoncpp=1
		-Duse_system_libevent=1
		-Duse_system_libjpeg=1
		-Duse_system_libpng=1
		-Duse_system_libwebp=1
		-Duse_system_libxml=1
		-Duse_system_libxslt=1
		-Duse_system_minizip=1
		-Duse_system_nspr=1
		-Duse_system_re2=1
		-Duse_system_snappy=1
		-Duse_system_speex=1
		-Duse_system_xdg_utils=1
		-Duse_system_zlib=1"

	# Needed for system icu - we don't need additional data files.
	myconf+=" -Dicu_use_data_file_flag=0"

	# TODO: patch gyp so that this arm conditional is not needed.
	if ! use arm; then
		myconf+="
			-Duse_system_yasm=1"
	fi

	# Optional dependencies.
	# TODO: linux_link_kerberos, bug #381289.
	myconf+="
		$(gyp_use cups)
		$(gyp_use gnome use_gconf)
		$(gyp_use gnome-keyring use_gnome_keyring)
		$(gyp_use gnome-keyring linux_link_gnome_keyring)
		$(gyp_use gtk3)
		$(gyp_use hangouts enable_hangout_services_extension)
		$(gyp_use hidpi enable_hidpi)
		$(gyp_use hotwording enable_hotwording)
		$(gyp_use kerberos)
		$(gyp_use pulseaudio)
		$(gyp_use tcmalloc use_allocator tcmalloc none)
		$(gyp_use widevine enable_widevine)"

	# Use explicit library dependencies instead of dlopen.
	# This makes breakages easier to detect by revdep-rebuild.
	myconf+="
		-Dlinux_link_gsettings=1
		-Dlinux_link_libpci=1
		-Dlinux_link_libspeechd=1
		-Dlibspeechd_h_prefix=speech-dispatcher/"

	# TODO: use the file at run time instead of effectively compiling it in.
	myconf+="
		-Dusb_ids_path=/usr/share/misc/usb.ids"

	# Save space by removing DLOG and DCHECK messages (about 6% reduction).
	myconf+="
		-Dlogging_like_official_build=1"

	if [[ $(tc-getCC) == *clang* ]]; then
		myconf+=" -Dclang=1"
	else
		myconf+=" -Dclang=0"
	fi

	# Never use bundled gold binary. Disable gold linker flags for now.
	# Do not use bundled clang.
	myconf+="
		-Dclang_use_chrome_plugins=0
		-Dhost_clang=0
		-Dlinux_use_bundled_binutils=0
		-Dlinux_use_bundled_gold=0
		-Dlinux_use_gold_flags=0"

	ffmpeg_branding="$(usex proprietary-codecs Chrome Chromium)"
	myconf+=" -Dproprietary_codecs=1 -Dffmpeg_branding=${ffmpeg_branding}"

	# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys .
	# Note: these are for Gentoo use ONLY. For your own distribution,
	# please get your own set of keys. Feel free to contact chromium@gentoo.org
	# for more info.
	myconf+=" -Dgoogle_api_key=AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc
		-Dgoogle_default_client_id=329227923882.apps.googleusercontent.com
		-Dgoogle_default_client_secret=vgKG0NNv7GoDpbtoFNLxCUXu"

	local myarch="$(tc-arch)"
	if [[ $myarch = amd64 ]] ; then
		target_arch=x64
		ffmpeg_target_arch=x64
	elif [[ $myarch = x86 ]] ; then
		target_arch=ia32
		ffmpeg_target_arch=ia32
	elif [[ $myarch = arm ]] ; then
		target_arch=arm
		ffmpeg_target_arch=$(usex neon arm-neon arm)
		# TODO: re-enable NaCl (NativeClient).
		local CTARGET=${CTARGET:-${CHOST}}
		if [[ $(tc-is-softfloat) == "no" ]]; then

			myconf+=" -Darm_float_abi=hard"
		fi
		filter-flags "-mfpu=*"
		use neon || myconf+=" -Darm_fpu=${ARM_FPU:-vfpv3-d16}"

		if [[ ${CTARGET} == armv[78]* ]]; then
			myconf+=" -Darmv7=1"
		else
			myconf+=" -Darmv7=0"
		fi
		myconf+=" -Dsysroot=
			$(gyp_use neon arm_neon)
			-Ddisable_nacl=1"
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	myconf+=" -Dtarget_arch=${target_arch}"

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf+=" -Dwerror="

	# Disable fatal linker warnings, bug 506268.
	myconf+=" -Ddisable_fatal_linker_warnings=1"

	# Avoid CFLAGS problems, bug #352457, bug #390147.
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Prevent linker from running out of address space, bug #471810 .
		if use x86; then
			filter-flags "-g*"
		fi

		# Prevent libvpx build failures. Bug 530248, 544702, 546984.
		if [[ ${myarch} == amd64 || ${myarch} == x86 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
		fi
	fi

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX NM

	# Tools for building programs to be executed on the build system, bug #410883.
	if tc-is-cross-compiler; then
		export AR_host=$(tc-getBUILD_AR)
		export CC_host=$(tc-getBUILD_CC)
		export CXX_host=$(tc-getBUILD_CXX)
		export NM_host=$(tc-getBUILD_NM)
	fi

	# Bug 491582.
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	if ! use system-ffmpeg; then
		local build_ffmpeg_args=""
		if use pic && [[ "${ffmpeg_target_arch}" == "ia32" ]]; then
			build_ffmpeg_args+=" --disable-asm"
		fi

		# Re-configure bundled ffmpeg. See bug #491378 for example reasons.
		einfo "Configuring bundled ffmpeg..."
		pushd third_party/ffmpeg > /dev/null || die
		chromium/scripts/build_ffmpeg.py linux ${ffmpeg_target_arch} \
			--branding ${ffmpeg_branding} -- ${build_ffmpeg_args} || die
		chromium/scripts/copy_config.sh || die
		chromium/scripts/generate_gyp.py || die
		popd > /dev/null || die
	fi

	third_party/libaddressinput/chromium/tools/update-strings.py || die

	einfo "Configuring bundled nodejs..."
	pushd vendor/node > /dev/null || die
	# Make sure gyp_node does not run
	echo '#!/usr/bin/env python' > tools/gyp_node.py
	./configure --shared-openssl --shared-libuv --shared-http-parser \
				--shared-zlib --without-npm --with-intl=system-icu \
				--without-dtrace --dest-cpu=${target_arch} \
				--prefix="" || die
	popd > /dev/null || die

	# libchromiumcontent configuration
	myconf+=" -Dcomponent=static_library"
	myconf+=" -Dmac_mas_build=0"
	myconf+=' -Dicu_small="false"'
	myconf+=" -Dlibchromiumcontent_component=0"
	myconf+=" -Dlibrary=static_library"
	myconf+=" -Dmas_build=0"

	einfo "Configuring electron..."
	build/linux/unbundle/replace_gyp_files.py ${myconf} || die

	myconf+=" -Ivendor/node/config.gypi
			  -Icommon.gypi
			  atom.gyp"

	egyp_chromium ${myconf} || die
}

eninja() {
	if [[ -z ${NINJAOPTS+set} ]]; then
		local jobs=$(makeopts_jobs)
		local loadavg=$(makeopts_loadavg)

		if [[ ${MAKEOPTS} == *-j* && ${jobs} != 999 ]]; then
			NINJAOPTS+=" -j ${jobs}"
		fi
		if [[ ${MAKEOPTS} == *-l* && ${loadavg} != 999 ]]; then
			NINJAOPTS+=" -l ${loadavg}"
		fi
	fi
	set -- ninja -v ${NINJAOPTS} "$@"
	echo "$@"
	"$@"
}

src_compile() {
	local ninja_targets="electron"
	local brightray_vendor_dir="${BRIGHTRAY_S}/vendor"

	einfo "Installing node modules required for Electron build..."
	npm install || die

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason.
	eninja -C out/R ${ninja_targets} || die
}

src_install() {
	if [[ "${SLOT}" == "0" ]]; then
		CHROMIUM_SUFFIX=""
	else
		CHROMIUM_SUFFIX="-${SLOT}"
	fi
	CHROMIUM_HOME="/usr/$(get_libdir)/electron${CHROMIUM_SUFFIX}"

	pushd out/R/locales > /dev/null || die
	chromium_remove_language_paks
	popd

	insinto "${CHROMIUM_HOME}"
	exeinto "${CHROMIUM_HOME}"
	doexe out/R/electron
	doins out/R/libv8.so
	doins out/R/libnode.so
	fperms +x "${CHROMIUM_HOME}"/libv8.so "${CHROMIUM_HOME}"/libnode.so
	doins out/R/content_shell.pak
	doins out/R/natives_blob.bin
	doins out/R/snapshot_blob.bin
	rm -rf out/R/resources/inspector
	doins -r out/R/resources
	doins -r out/R/locales

	dosym "${CHROMIUM_HOME}/electron" /usr/bin/electron${CHROMIUM_SUFFIX}
}
