# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: this ebuild has been generated by ebuild-gen.py from the
#       electron overlay.  If you would like to make changes, please
#       consider modifying the ebuild template and submitting a PR to
#       https://github.com/elprans/electron-overlay.

EAPI=7

PYTHON_COMPAT=( python3_{10..13} )
inherit desktop multiprocessing python-any-r1 rpm xdg-utils

DESCRIPTION="Visual Studio Code"
HOMEPAGE="https://code.visualstudio.com/"

if [[ ${PV} == *9999* ]]; then
	UPSTREAM_PV="latest"
	UPSTREAM_CHANNEL="insider"
else
	UPSTREAM_PV="${PV}"
	UPSTREAM_CHANNEL="stable"
fi

ELECTRON_V=32.2.1
ELECTRON_SLOT=32

ASAR_V=0.14.3
# All binary packages depend on this
NAN_V=2.19.0
NODE_ADDON_API_V=7.1.0

VSCODE__POLICY_WATCHER_V=1.1.8
VSCODE__SPDLOG_V=0.15.1
VSCODE__SQLITE3_V=5.1.8-vscode
VSCODE__WINDOWS_MUTEX_V=0.5.0
VSCODE__WINDOWS_PROCESS_TREE_V=0.6.0
VSCODE__WINDOWS_REGISTRY_V=1.1.0
KERBEROS_V=2.1.1
NATIVE_IS_ELEVATED_V=0.7.0
NATIVE_KEYMAP_V=3.3.5
NATIVE_WATCHDOG_V=1.4.2
NODE_PTY_V=1.1.0-beta9

# The x86_64 arch below is irrelevant, as we will rebuild all binary packages.
SRC_URI="
	https://update.code.visualstudio.com/${UPSTREAM_PV}/linux-rpm-x64/${UPSTREAM_CHANNEL} -> vscode-x64-${PV}.rpm
	https://github.com/elprans/asar/releases/download/v${ASAR_V}-gentoo/asar-build.tar.gz -> asar-${ASAR_V}.tar.gz
	https://github.com/nodejs/nan/archive/v${NAN_V}.tar.gz -> nodejs-nan-${NAN_V}.tar.gz
	https://github.com/nodejs/node-addon-api/archive/v${NODE_ADDON_API_V}.tar.gz -> nodejs-node-addon-api-${NODE_ADDON_API_V}.tar.gz
	https://registry.npmjs.org/@vscode/policy-watcher/-/policy-watcher-1.1.8.tgz -> vscodedep-vscode--policy-watcher-${VSCODE__POLICY_WATCHER_V}.tar.gz
	https://registry.npmjs.org/@vscode/spdlog/-/spdlog-0.15.1.tgz -> vscodedep-vscode--spdlog-${VSCODE__SPDLOG_V}.tar.gz
	https://registry.npmjs.org/@vscode/sqlite3/-/sqlite3-5.1.8-vscode.tgz -> vscodedep-vscode--sqlite3-${VSCODE__SQLITE3_V}.tar.gz
	https://registry.npmjs.org/@vscode/windows-mutex/-/windows-mutex-0.5.0.tgz -> vscodedep-vscode--windows-mutex-${VSCODE__WINDOWS_MUTEX_V}.tar.gz
	https://registry.npmjs.org/@vscode/windows-process-tree/-/windows-process-tree-0.6.0.tgz -> vscodedep-vscode--windows-process-tree-${VSCODE__WINDOWS_PROCESS_TREE_V}.tar.gz
	https://registry.npmjs.org/@vscode/windows-registry/-/windows-registry-1.1.0.tgz -> vscodedep-vscode--windows-registry-${VSCODE__WINDOWS_REGISTRY_V}.tar.gz
	https://registry.npmjs.org/kerberos/-/kerberos-2.1.1.tgz -> vscodedep-kerberos-${KERBEROS_V}.tar.gz
	https://registry.npmjs.org/native-is-elevated/-/native-is-elevated-0.7.0.tgz -> vscodedep-native-is-elevated-${NATIVE_IS_ELEVATED_V}.tar.gz
	https://registry.npmjs.org/native-keymap/-/native-keymap-3.3.5.tgz -> vscodedep-native-keymap-${NATIVE_KEYMAP_V}.tar.gz
	https://registry.npmjs.org/native-watchdog/-/native-watchdog-1.4.2.tgz -> vscodedep-native-watchdog-${NATIVE_WATCHDOG_V}.tar.gz
	https://registry.npmjs.org/node-pty/-/node-pty-1.1.0-beta9.tgz -> vscodedep-node-pty-${NODE_PTY_V}.tar.gz
"

BINMODS=(
	vscode--policy-watcher
	vscode--spdlog
	vscode--sqlite3
	vscode--windows-mutex
	vscode--windows-process-tree
	vscode--windows-registry
	kerberos
	native-is-elevated
	native-keymap
	native-watchdog
	node-pty
)

RESTRICT="mirror bindist"
LICENSE="
	Apache-2.0
	BSD
	BSD-1
	BSD-2
	BSD-4
	CC-BY-4.0
	ISC
	LGPL-2.1+
	Microsoft-vscode
	MIT
	MPL-2.0
	openssl
	PYTHON
	TextMate-bundle
	Unlicense
	UoI-NCSA
	W3C
"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="
	${PYTHON_DEPS}
	>=dev-util/electron-${ELECTRON_V}:${ELECTRON_SLOT}
"

DEPEND="
	>=app-crypt/libsecret-0.18.6:=
	>=app-text/hunspell-1.3.3:=
	>=dev-db/sqlite-3.24:=
	>=dev-libs/glib-2.52.0:=
	>=dev-libs/libgit2-0.23:=[ssh]
	>=dev-libs/libpcre2-10.22:=[jit,pcre16]
	x11-libs/libX11
	x11-libs/libxkbfile
"

RDEPEND="
	${DEPEND}
	>=dev-util/ctags-5.8
	>=dev-util/electron-${ELECTRON_V}:${ELECTRON_SLOT}
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-vcs/git
	sys-apps/ripgrep
"

S="${WORKDIR}/${PN}-${PV}"
BIN_S="${WORKDIR}/${PN}-bin-${PV}"
BUILD_DIR="${S}/out"

src_unpack() {
	local a

	mkdir "${S}" || die
	mkdir "${BIN_S}" || die

	for a in ${A} ; do
		case "${a}" in
			*.rpm)
				pushd "${BIN_S}" >/dev/null || die
				srcrpm_unpack "${a}"
				popd >/dev/null || die
				;;

			*.tar|*.tar.gz|*.tar.bz2|*.tar.xz)
				# Tarballs on registry.npmjs.org are wildly inconsistent,
				# and violate the convention of having ${P} as the top
				# directory name, so we strip the first component and
				# unpack into a correct directory explicitly.
				local basename=${a%.tar.*}
				local destdir=${WORKDIR}/${basename#vscodedep-}
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" || die
				;;

			*)
				# Fallback to the default unpacker.
				unpack "${a}"
				;;
		esac
	done
}

src_prepare() {
	local suffix="$(get_install_suffix)"
	local vscode_rpmdir=$(get_vscode_rpmdir)
	local vscode_appname=$(get_vscode_appname)
	local install_dir="${EPREFIX}$(get_install_dir)"
	local electron_dir="${EPREFIX}$(get_electron_dir)"
	local electron_path="${electron_dir}/electron"
	local node_path="${electron_dir}/node"
	local node_includes="${EPREFIX}$(get_node_includedir)"
	local binmod
	local pkgdir
	local pyscript
	local wb_css_path="vs/workbench/workbench.desktop.main.css"
	local wb_css_local_path="vs/workbench/workbench.desktop.local.css"
	local wb_css_csum

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	mkdir "${BUILD_DIR}" || die
	cp -a "${BIN_S}/${vscode_rpmdir}/resources/app" \
		"${BUILD_DIR}/app" || die

	cp -a "${BIN_S}/${vscode_rpmdir}/bin/${vscode_appname}" \
		"${BUILD_DIR}/app/code" || die

	# Unpack app.asar
	easar extract "${BIN_S}/${vscode_rpmdir}/resources/app/node_modules.asar" \
		"${BUILD_DIR}/app/node_modules"

	cd "${BUILD_DIR}/app" || die
	rm -r "node_modules.asar.unpacked" || die

	if [[ "${PV}" == *9999* ]]; then
		eapply "${FILESDIR}/unbundle-electron-insiders.patch"
	else
		eapply "${FILESDIR}/unbundle-electron-r3.patch"
	fi
	eapply "${FILESDIR}/unbundle-ripgrep-r2.patch"

	sed -i -e "s|{{NPM_CONFIG_NODEDIR}}|${node_includes}|g" \
			-e "s|{{ELECTRON_PATH}}|${electron_path}|g" \
			-e "s|{{VSCODE_PATH}}|${install_dir}|g" \
			-e "s|{{EPREFIX}}|${EPREFIX}|g" \
		code \
		|| die

	sed -i -e "s|/${vscode_rpmdir}/${vscode_appname}|${EPREFIX}/usr/bin/code${suffix}|g" \
		"${BIN_S}/usr/share/applications/$(get_vscode_appname).desktop" || die

	for binmod in "${BINMODS[@]}"; do
		pkgdir="${WORKDIR}/$(package_dir ${binmod})"
		cd "${pkgdir}" || die
		if have_patches_for "${binmod}"; then
			eapply "${FILESDIR}"/${binmod}-*.patch
		fi
	done

	cd "${BUILD_DIR}/app" || die

	# Unbundle bundled libs from modules

	for binmod in "${BINMODS[@]}"; do
		pkgdir="${WORKDIR}/$(package_dir ${binmod})"
		mkdir -p "${pkgdir}/node_modules" || die
		ln -s "${WORKDIR}/nodejs-nan-${NAN_V}" \
			"${pkgdir}/node_modules/nan" || die
		ln -s "${WORKDIR}/nodejs-node-addon-api-${NODE_ADDON_API_V}" \
			"${pkgdir}/node_modules/node-addon-api" || die
	done

	eapply_user

	cd "${BUILD_DIR}/app" || die

	if [ -e "out/${wb_css_local_path}" ]; then
		cat "out/${wb_css_local_path}" >> "out/${wb_css_path}"

		IFS= read -r -d '' pyscript <<EOF
import base64, hashlib;
m = hashlib.sha256();
with open('out/${wb_css_path}', 'rb') as f:
	m.update(f.read())
print(base64.b64encode(m.digest()).decode().strip("="))
EOF

		wb_css_csum=$(${EPYTHON} -c "${pyscript}" || die)

		sed -i \
			-e "s|\"${wb_css_path}\":.*|\"${wb_css_path}\": \"${wb_css_csum}\",|g" \
			product.json || die
	fi
}

src_configure() {
	local binmod
	local config

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	for binmod in "${BINMODS[@]}"; do
		einfo "Configuring ${binmod}..."
		cd "${WORKDIR}/$(package_dir ${binmod})" || die

		if [[ "${binmod}" == "vscode--sqlite3" ]]; then
			config="--sqlite=/usr"
		else
			config=""
		fi

		enodegyp configure ${config}
	done
}

src_compile() {
	local binmod
	local jobs=$(makeopts_jobs)
	local unpacked_paths

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	mkdir -p "${BUILD_DIR}/modules/" || die

	for binmod in "${BINMODS[@]}"; do
		einfo "Building ${binmod}..."
		cd "${WORKDIR}/$(package_dir ${binmod})" || die
		enodegyp --verbose --jobs="$(makeopts_jobs)" build
		mkdir -p "${BUILD_DIR}/modules/${binmod}" || die
		cp build/Release/*.node "${BUILD_DIR}/modules/${binmod}" || die
	done

	# Put compiled binary modules in place
	fix_binmods "${BUILD_DIR}/app" "node_modules"

	# Remove bundled ripgrep
	rm -r "${BUILD_DIR}/app/node_modules/@vscode/ripgrep/bin" || die

	# Re-pack node_modules.asar
	unpacked_paths=(
		"*.wasm"
		"*.node"
	)
	unpacked_paths=$(IFS=,; echo "${unpacked_paths[*]}")

	cd "${BUILD_DIR}/app" || die
	# easar pack --unpack="{${unpacked_paths}}" "node_modules" "node_modules.asar"
}

src_install() {
	local install_dir="$(get_install_dir)"
	local suffix="$(get_install_suffix)"

	insinto "${install_dir}"

	doins -r "${BUILD_DIR}/app/extensions"
	# doins "${BUILD_DIR}/app/node_modules.asar"
	# doins -r "${BUILD_DIR}/app/node_modules.asar.unpacked"
	doins -r "${BUILD_DIR}/app/node_modules"
	doins -r "${BUILD_DIR}/app/out"
	doins -r "${BUILD_DIR}/app/package.json"
	doins -r "${BUILD_DIR}/app/product.json"
	doins -r "${BUILD_DIR}/app/resources"

	insinto "/usr/share/applications/"
	newins "${BIN_S}/usr/share/applications/$(get_vscode_appname).desktop" \
		"vscode${suffix}.desktop"

	doicon "${BIN_S}/usr/share/pixmaps/vscode.png"

	exeinto "${install_dir}"
	newexe "${BUILD_DIR}/app/code" code
	insinto "/usr/share/licenses/${PN}${suffix}"
	doins "${BIN_S}/$(get_vscode_rpmdir)/resources/app/LICENSE.rtf"
	doins "${BIN_S}/$(get_vscode_rpmdir)/resources/app/ThirdPartyNotices.txt"
	dosym "../..${install_dir}/code" "/usr/bin/code${suffix}"

	fix_executables "${install_dir}" "*/extensions/*/bin/*"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

# Helpers
# -------

# Return the installation suffix appropriate for the slot.
get_install_suffix() {
	local slot=${SLOT%%/*}
	local suffix

	if [[ "${slot}" == "0" ]]; then
		suffix=""
	else
		suffix="-${slot}"
	fi

	echo "${suffix}"
}

# Return the upstream app name appropriate for $PV.
get_vscode_appname() {
	if [[ "${PV}" == *beta* ]]; then
		echo "code-beta"
	elif [[ "${PV}" == *9999* ]]; then
		echo "code-insiders"
	else
		echo "code"
	fi
}

# Return the app installation path inside the upstream archive.
get_vscode_rpmdir() {
	echo "usr/share/$(get_vscode_appname)"
}

# Return the installation target directory.
get_install_dir() {
	echo "/usr/$(get_libdir)/vscode$(get_install_suffix)"
}

# Return the Electron installation directory.
get_electron_dir() {
	echo "/usr/$(get_libdir)/electron-${ELECTRON_SLOT}"
}

# Return the directory containing appropriate Node headers
# for the required version of Electron.
get_node_includedir() {
	echo "/usr/include/electron-${ELECTRON_SLOT}/node/"
}

# Run JavaScript using Electron's version of Node.
enode_electron() {
	set -- "${BROOT}/$(get_electron_dir)"/node "${@}"
	echo "$@"
	"$@" || die
}

# Run node-gyp using Electron's version of Node.
enodegyp() {
	local npmdir="${BROOT}/$(get_electron_dir)/npm"
	local nodegyp="${npmdir}/node_modules/node-gyp/bin/node-gyp.js"

	PATH="${BROOT}/$(get_electron_dir):${PATH}" \
		enode_electron "${nodegyp}" \
			--nodedir="${BROOT}/$(get_node_includedir)" "${@}"
}

# asar wrapper.
easar() {
	local asar="${WORKDIR}/$(package_dir asar)/node_modules/asar/bin/asar"
	echo "asar" "${@}"
	enode_electron "${asar}" "${@}"
}

# Return a $WORKDIR directory for a given package name.
package_dir() {
	local binmod="${1//-/_}"
	local binmod_v="${binmod^^}_V"
	if [[ -z "${binmod_v}" ]]; then
		die "${binmod_v} is not set."
	fi

	echo ${1}-${!binmod_v}
}

# Check if there are patches for a given package.
have_patches_for() {
	local patches="${1}-*.patch"
	local found
	found=$(find "${FILESDIR}" -maxdepth 1 -name "${patches}" -print -quit)
	test -n "${found}"
}

# Replace binary node modules with the newly compiled versions thereof.
fix_binmods() {
	local dir="${2}"
	local prefix="${1}"
	local path
	local pathdir
	local nsdir
	local relpath
	local modpath
	local mod
	local cruft

	while IFS= read -r -d '' path; do
		pathdir=$(dirname "${path}")
		relpath=${path#${prefix}}
		relpath=${relpath##/}
		relpath=${relpath#W${dir}}
		modpath=$(dirname "${relpath}")
		modpath=${modpath%build/Release}
		nsdir=$(basename "$(dirname "${modpath}")")
		mod=$(basename "${modpath}")

		if [ "${nsdir:0:1}" = "@" ]; then
			# Namespaced package
			mod="${nsdir:1}--${mod}"
		fi

		einfo "$mod $pathdir $nsdir ${nsdir:0:1}"

		# Check if the binary node module is actually a valid dependency.
		# Sometimes the upstream removes a dependency from package.json but
		# forgets to remove the module from node_modules.
		has "${mod}" "${BINMODS[@]}" || continue

		# Must copy here as symlinks will cause the module loading to fail.
		cp -f "${BUILD_DIR}/modules/${mod}/${path##*/}" "${path}" || die

		# Drop unnecessary static libraries.
		find "${pathdir}" -name '*.a' -delete || die

		if [ -e "${pathdir}/obj.target" ]; then
			# Drop intermediate compilation results.
			rm -r "${pathdir}/obj.target" || die
		fi
	done < <(find "${prefix}/${dir}" -name '*.node' -print0 || die)
}

# Fix script permissions and shebangs to point to the correct version
# of Node.
fix_executables() {
	local dir="${1}"
	local pattern="${2}"
	local node_sb="#!${EPREFIX}$(get_electron_dir)"/node

	while IFS= read -r -d '' f; do
		IFS= read -r shebang < "${f}"

		if [[ ${shebang} == '#!'* ]]; then
			fperms +x "${f#${ED}}"
			if [[ "${shebang}" == "#!/usr/bin/env node" || \
					"${shebang}" == "#!/usr/bin/node" ]]; then
				einfo "Fixing node shebang in ${f#${ED}}"
				sed --follow-symlinks -i \
					-e "1s:${shebang}$:${node_sb}:" "${f}" || die
			fi
		fi
	done < <(find -L "${ED}${dir}" -path "${pattern}" -type f -print0 || die)
}
