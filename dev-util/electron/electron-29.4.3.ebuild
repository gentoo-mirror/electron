# Copyright 2009-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Can't do 12 yet: heavy use of imp, among other things (bug #915001, bug #915062)
PYTHON_COMPAT=( python3_{10..11} )
PYTHON_REQ_USE="xml(+)"

# These variables let us easily bound supported major dependency versions in one place.
GCC_MIN_VER=12
GN_MIN_VER=0.2143
LLVM_MAX_SLOT=17
LLVM_MIN_SLOT=16
RUST_MIN_VER=1.72.0
# grep 'CLANG_REVISION = ' ${S}/tools/clang/scripts/update.py -A1 | cut -c 18-
GOOGLE_CLANG_VER="llvmorg-18-init-16072-gc4146121e940-5"
# grep 'RUST_REVISION = ' ${S}/tools/rust/update_rust.py -A1 | cut -c 17-
GOOGLE_RUST_VER="df0295f07175acc7325ce3ca4152eb05752af1f2-5"

# https://bugs.chromium.org/p/v8/issues/detail?id=14449 - V8 used in 120 can't build with GCC
: ${CHROMIUM_FORCE_CLANG=yes}
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=101227 - Chromium 120:
#    webrtc -  no matching member function for call to 'emplace'
: ${CHROMIUM_FORCE_LIBCXX=yes}
# 121's 'gcc_link_wrapper.py' currently fails if not using lld due to the addition of rust
: ${CHROMIUM_FORCE_LLD=yes}

: ${CHROMIUM_FORCE_GOOGLE_TOOLCHAIN=no}

VIRTUALX_REQUIRED="pgo"

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit check-reqs chromium-2 flag-o-matic llvm ninja-utils pax-utils
inherit	python-any-r1 qmake-utils toolchain-funcs virtualx xdg-utils

# Keep this in sync with DEPS:chromium_version
CHROMIUM_VERSION="122.0.6261.130"

# Keep this in sync with DEPS:node_version
NODE_VERSION="20.9.0"

# Keep this in sync with DEPS:nan_version
NAN_VERSION="2.19.0"

YARN_VERSION="1.22.19"

CHROMIUM_P="chromium-${CHROMIUM_VERSION}"
NODE_P="node-${NODE_VERSION}"

DESCRIPTION="Cross platform application development framework based on web technologies"
HOMEPAGE="https://electronjs.org/"
CHROMIUM_PATCH_V="${CHROMIUM_VERSION%%\.*}-2"
SRC_URI="
	system-toolchain? (
		https://gitlab.com/Matt.Jolly/chromium-patches/-/archive/${CHROMIUM_PATCH_V}/chromium-patches-${CHROMIUM_PATCH_V}.tar.bz2
	)
	!system-toolchain? (
		https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/clang-${GOOGLE_CLANG_VER}.tar.xz
			-> chromium-${PV%%\.*}-clang.tar.xz
		https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/rust-toolchain-${GOOGLE_RUST_VER}-${GOOGLE_CLANG_VER%??}.tar.xz
			-> chromium-${PV%%\.*}-rust.tar.xz
	)
	pgo? ( https://github.com/elkablo/chromium-profiler/releases/download/v0.2/chromium-profiler-0.2.tar )
	https://github.com/electron/electron/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://registry.yarnpkg.com/yarn/-/yarn-${YARN_VERSION}.tgz
	https://github.com/nodejs/node/archive/v${NODE_VERSION}.tar.gz -> electron-${NODE_P}.tar.gz
	https://registry.yarnpkg.com/nan/-/nan-${NAN_VERSION}.tgz -> electron-dep--nan-${NAN_VERSION}.tgz
	https://commondatastorage.googleapis.com/chromium-browser-official/${CHROMIUM_P}.tar.xz
"
# sed -r -n -e 's/^[ ]*resolved \"(.*)\#.*\"$/\1/g; s/^https:\/\/registry.yarnpkg.com\/(@([^@/]+))?\/?([^@/]+)\/\-\/([^/]+).tgz$/\t\0 -> electron-dep-\1-\4.tgz/p' yarn.lock | sort | uniq | wl-copy
SRC_URI+="
	https://registry.yarnpkg.com/@azure/abort-controller/-/abort-controller-1.0.4.tgz -> electron-dep-@azure-abort-controller-1.0.4.tgz
	https://registry.yarnpkg.com/@azure/core-asynciterator-polyfill/-/core-asynciterator-polyfill-1.0.2.tgz -> electron-dep-@azure-core-asynciterator-polyfill-1.0.2.tgz
	https://registry.yarnpkg.com/@azure/core-auth/-/core-auth-1.3.2.tgz -> electron-dep-@azure-core-auth-1.3.2.tgz
	https://registry.yarnpkg.com/@azure/core-http/-/core-http-3.0.1.tgz -> electron-dep-@azure-core-http-3.0.1.tgz
	https://registry.yarnpkg.com/@azure/core-lro/-/core-lro-2.2.4.tgz -> electron-dep-@azure-core-lro-2.2.4.tgz
	https://registry.yarnpkg.com/@azure/core-paging/-/core-paging-1.2.1.tgz -> electron-dep-@azure-core-paging-1.2.1.tgz
	https://registry.yarnpkg.com/@azure/core-tracing/-/core-tracing-1.0.0-preview.13.tgz -> electron-dep-@azure-core-tracing-1.0.0-preview.13.tgz
	https://registry.yarnpkg.com/@azure/core-util/-/core-util-1.3.1.tgz -> electron-dep-@azure-core-util-1.3.1.tgz
	https://registry.yarnpkg.com/@azure/logger/-/logger-1.0.3.tgz -> electron-dep-@azure-logger-1.0.3.tgz
	https://registry.yarnpkg.com/@azure/storage-blob/-/storage-blob-12.14.0.tgz -> electron-dep-@azure-storage-blob-12.14.0.tgz
	https://registry.yarnpkg.com/@babel/code-frame/-/code-frame-7.5.5.tgz -> electron-dep-@babel-code-frame-7.5.5.tgz
	https://registry.yarnpkg.com/@babel/helper-validator-identifier/-/helper-validator-identifier-7.19.1.tgz -> electron-dep-@babel-helper-validator-identifier-7.19.1.tgz
	https://registry.yarnpkg.com/@babel/highlight/-/highlight-7.5.0.tgz -> electron-dep-@babel-highlight-7.5.0.tgz
	https://registry.yarnpkg.com/@discoveryjs/json-ext/-/json-ext-0.5.7.tgz -> electron-dep-@discoveryjs-json-ext-0.5.7.tgz
	https://registry.yarnpkg.com/@dsanders11/vscode-markdown-languageservice/-/vscode-markdown-languageservice-0.3.0.tgz -> electron-dep-@dsanders11-vscode-markdown-languageservice-0.3.0.tgz
	https://registry.yarnpkg.com/@electron/asar/-/asar-3.2.1.tgz -> electron-dep-@electron-asar-3.2.1.tgz
	https://registry.yarnpkg.com/@electron/docs-parser/-/docs-parser-1.2.0.tgz -> electron-dep-@electron-docs-parser-1.2.0.tgz
	https://registry.yarnpkg.com/@electron/fiddle-core/-/fiddle-core-1.0.4.tgz -> electron-dep-@electron-fiddle-core-1.0.4.tgz
	https://registry.yarnpkg.com/@electron/get/-/get-2.0.2.tgz -> electron-dep-@electron-get-2.0.2.tgz
	https://registry.yarnpkg.com/@electron/github-app-auth/-/github-app-auth-2.0.0.tgz -> electron-dep-@electron-github-app-auth-2.0.0.tgz
	https://registry.yarnpkg.com/@electron/lint-roller/-/lint-roller-1.12.1.tgz -> electron-dep-@electron-lint-roller-1.12.1.tgz
	https://registry.yarnpkg.com/@electron/typescript-definitions/-/typescript-definitions-8.15.6.tgz -> electron-dep-@electron-typescript-definitions-8.15.6.tgz
	https://registry.yarnpkg.com/@eslint-community/eslint-utils/-/eslint-utils-4.4.0.tgz -> electron-dep-@eslint-community-eslint-utils-4.4.0.tgz
	https://registry.yarnpkg.com/@eslint-community/regexpp/-/regexpp-4.5.1.tgz -> electron-dep-@eslint-community-regexpp-4.5.1.tgz
	https://registry.yarnpkg.com/@eslint/eslintrc/-/eslintrc-2.0.3.tgz -> electron-dep-@eslint-eslintrc-2.0.3.tgz
	https://registry.yarnpkg.com/@eslint/js/-/js-8.40.0.tgz -> electron-dep-@eslint-js-8.40.0.tgz
	https://registry.yarnpkg.com/@eslint/js/-/js-8.41.0.tgz -> electron-dep-@eslint-js-8.41.0.tgz
	https://registry.yarnpkg.com/@humanwhocodes/config-array/-/config-array-0.11.8.tgz -> electron-dep-@humanwhocodes-config-array-0.11.8.tgz
	https://registry.yarnpkg.com/@humanwhocodes/module-importer/-/module-importer-1.0.1.tgz -> electron-dep-@humanwhocodes-module-importer-1.0.1.tgz
	https://registry.yarnpkg.com/@humanwhocodes/object-schema/-/object-schema-1.2.1.tgz -> electron-dep-@humanwhocodes-object-schema-1.2.1.tgz
	https://registry.yarnpkg.com/@jridgewell/gen-mapping/-/gen-mapping-0.3.2.tgz -> electron-dep-@jridgewell-gen-mapping-0.3.2.tgz
	https://registry.yarnpkg.com/@jridgewell/resolve-uri/-/resolve-uri-3.1.0.tgz -> electron-dep-@jridgewell-resolve-uri-3.1.0.tgz
	https://registry.yarnpkg.com/@jridgewell/set-array/-/set-array-1.1.2.tgz -> electron-dep-@jridgewell-set-array-1.1.2.tgz
	https://registry.yarnpkg.com/@jridgewell/source-map/-/source-map-0.3.2.tgz -> electron-dep-@jridgewell-source-map-0.3.2.tgz
	https://registry.yarnpkg.com/@jridgewell/sourcemap-codec/-/sourcemap-codec-1.4.14.tgz -> electron-dep-@jridgewell-sourcemap-codec-1.4.14.tgz
	https://registry.yarnpkg.com/@jridgewell/trace-mapping/-/trace-mapping-0.3.14.tgz -> electron-dep-@jridgewell-trace-mapping-0.3.14.tgz
	https://registry.yarnpkg.com/@kwsites/file-exists/-/file-exists-1.1.1.tgz -> electron-dep-@kwsites-file-exists-1.1.1.tgz
	https://registry.yarnpkg.com/@kwsites/promise-deferred/-/promise-deferred-1.1.1.tgz -> electron-dep-@kwsites-promise-deferred-1.1.1.tgz
	https://registry.yarnpkg.com/@nodelib/fs.scandir/-/fs.scandir-2.1.3.tgz -> electron-dep-@nodelib-fs.scandir-2.1.3.tgz
	https://registry.yarnpkg.com/@nodelib/fs.scandir/-/fs.scandir-2.1.5.tgz -> electron-dep-@nodelib-fs.scandir-2.1.5.tgz
	https://registry.yarnpkg.com/@nodelib/fs.stat/-/fs.stat-2.0.3.tgz -> electron-dep-@nodelib-fs.stat-2.0.3.tgz
	https://registry.yarnpkg.com/@nodelib/fs.stat/-/fs.stat-2.0.5.tgz -> electron-dep-@nodelib-fs.stat-2.0.5.tgz
	https://registry.yarnpkg.com/@nodelib/fs.walk/-/fs.walk-1.2.4.tgz -> electron-dep-@nodelib-fs.walk-1.2.4.tgz
	https://registry.yarnpkg.com/@nodelib/fs.walk/-/fs.walk-1.2.8.tgz -> electron-dep-@nodelib-fs.walk-1.2.8.tgz
	https://registry.yarnpkg.com/@octokit/auth-app/-/auth-app-4.0.13.tgz -> electron-dep-@octokit-auth-app-4.0.13.tgz
	https://registry.yarnpkg.com/@octokit/auth-oauth-app/-/auth-oauth-app-5.0.5.tgz -> electron-dep-@octokit-auth-oauth-app-5.0.5.tgz
	https://registry.yarnpkg.com/@octokit/auth-oauth-device/-/auth-oauth-device-4.0.3.tgz -> electron-dep-@octokit-auth-oauth-device-4.0.3.tgz
	https://registry.yarnpkg.com/@octokit/auth-oauth-user/-/auth-oauth-user-2.0.4.tgz -> electron-dep-@octokit-auth-oauth-user-2.0.4.tgz
	https://registry.yarnpkg.com/@octokit/auth-token/-/auth-token-3.0.3.tgz -> electron-dep-@octokit-auth-token-3.0.3.tgz
	https://registry.yarnpkg.com/@octokit/core/-/core-4.2.0.tgz -> electron-dep-@octokit-core-4.2.0.tgz
	https://registry.yarnpkg.com/@octokit/core/-/core-4.2.1.tgz -> electron-dep-@octokit-core-4.2.1.tgz
	https://registry.yarnpkg.com/@octokit/endpoint/-/endpoint-7.0.3.tgz -> electron-dep-@octokit-endpoint-7.0.3.tgz
	https://registry.yarnpkg.com/@octokit/graphql/-/graphql-5.0.5.tgz -> electron-dep-@octokit-graphql-5.0.5.tgz
	https://registry.yarnpkg.com/@octokit/oauth-authorization-url/-/oauth-authorization-url-5.0.0.tgz -> electron-dep-@octokit-oauth-authorization-url-5.0.0.tgz
	https://registry.yarnpkg.com/@octokit/oauth-methods/-/oauth-methods-2.0.4.tgz -> electron-dep-@octokit-oauth-methods-2.0.4.tgz
	https://registry.yarnpkg.com/@octokit/openapi-types/-/openapi-types-14.0.0.tgz -> electron-dep-@octokit-openapi-types-14.0.0.tgz
	https://registry.yarnpkg.com/@octokit/openapi-types/-/openapi-types-16.0.0.tgz -> electron-dep-@octokit-openapi-types-16.0.0.tgz
	https://registry.yarnpkg.com/@octokit/openapi-types/-/openapi-types-17.2.0.tgz -> electron-dep-@octokit-openapi-types-17.2.0.tgz
	https://registry.yarnpkg.com/@octokit/plugin-paginate-rest/-/plugin-paginate-rest-6.0.0.tgz -> electron-dep-@octokit-plugin-paginate-rest-6.0.0.tgz
	https://registry.yarnpkg.com/@octokit/plugin-paginate-rest/-/plugin-paginate-rest-6.1.2.tgz -> electron-dep-@octokit-plugin-paginate-rest-6.1.2.tgz
	https://registry.yarnpkg.com/@octokit/plugin-request-log/-/plugin-request-log-1.0.4.tgz -> electron-dep-@octokit-plugin-request-log-1.0.4.tgz
	https://registry.yarnpkg.com/@octokit/plugin-rest-endpoint-methods/-/plugin-rest-endpoint-methods-7.0.1.tgz -> electron-dep-@octokit-plugin-rest-endpoint-methods-7.0.1.tgz
	https://registry.yarnpkg.com/@octokit/plugin-rest-endpoint-methods/-/plugin-rest-endpoint-methods-7.1.2.tgz -> electron-dep-@octokit-plugin-rest-endpoint-methods-7.1.2.tgz
	https://registry.yarnpkg.com/@octokit/request-error/-/request-error-3.0.2.tgz -> electron-dep-@octokit-request-error-3.0.2.tgz
	https://registry.yarnpkg.com/@octokit/request/-/request-6.2.4.tgz -> electron-dep-@octokit-request-6.2.4.tgz
	https://registry.yarnpkg.com/@octokit/rest/-/rest-19.0.11.tgz -> electron-dep-@octokit-rest-19.0.11.tgz
	https://registry.yarnpkg.com/@octokit/rest/-/rest-19.0.7.tgz -> electron-dep-@octokit-rest-19.0.7.tgz
	https://registry.yarnpkg.com/@octokit/tsconfig/-/tsconfig-1.0.2.tgz -> electron-dep-@octokit-tsconfig-1.0.2.tgz
	https://registry.yarnpkg.com/@octokit/types/-/types-8.0.0.tgz -> electron-dep-@octokit-types-8.0.0.tgz
	https://registry.yarnpkg.com/@octokit/types/-/types-9.0.0.tgz -> electron-dep-@octokit-types-9.0.0.tgz
	https://registry.yarnpkg.com/@octokit/types/-/types-9.2.3.tgz -> electron-dep-@octokit-types-9.2.3.tgz
	https://registry.yarnpkg.com/@opentelemetry/api/-/api-1.0.4.tgz -> electron-dep-@opentelemetry-api-1.0.4.tgz
	https://registry.yarnpkg.com/@primer/octicons/-/octicons-10.0.0.tgz -> electron-dep-@primer-octicons-10.0.0.tgz
	https://registry.yarnpkg.com/@sindresorhus/is/-/is-4.6.0.tgz -> electron-dep-@sindresorhus-is-4.6.0.tgz
	https://registry.yarnpkg.com/@szmarczak/http-timer/-/http-timer-4.0.6.tgz -> electron-dep-@szmarczak-http-timer-4.0.6.tgz
	https://registry.yarnpkg.com/@types/basic-auth/-/basic-auth-1.1.3.tgz -> electron-dep-@types-basic-auth-1.1.3.tgz
	https://registry.yarnpkg.com/@types/body-parser/-/body-parser-1.19.0.tgz -> electron-dep-@types-body-parser-1.19.0.tgz
	https://registry.yarnpkg.com/@types/btoa-lite/-/btoa-lite-1.0.0.tgz -> electron-dep-@types-btoa-lite-1.0.0.tgz
	https://registry.yarnpkg.com/@types/busboy/-/busboy-1.5.0.tgz -> electron-dep-@types-busboy-1.5.0.tgz
	https://registry.yarnpkg.com/@types/cacheable-request/-/cacheable-request-6.0.2.tgz -> electron-dep-@types-cacheable-request-6.0.2.tgz
	https://registry.yarnpkg.com/@types/chai-as-promised/-/chai-as-promised-7.1.1.tgz -> electron-dep-@types-chai-as-promised-7.1.1.tgz
	https://registry.yarnpkg.com/@types/chai-as-promised/-/chai-as-promised-7.1.3.tgz -> electron-dep-@types-chai-as-promised-7.1.3.tgz
	https://registry.yarnpkg.com/@types/chai/-/chai-4.1.7.tgz -> electron-dep-@types-chai-4.1.7.tgz
	https://registry.yarnpkg.com/@types/chai/-/chai-4.2.12.tgz -> electron-dep-@types-chai-4.2.12.tgz
	https://registry.yarnpkg.com/@types/color-name/-/color-name-1.1.1.tgz -> electron-dep-@types-color-name-1.1.1.tgz
	https://registry.yarnpkg.com/@types/concat-stream/-/concat-stream-1.6.1.tgz -> electron-dep-@types-concat-stream-1.6.1.tgz
	https://registry.yarnpkg.com/@types/connect/-/connect-3.4.33.tgz -> electron-dep-@types-connect-3.4.33.tgz
	https://registry.yarnpkg.com/@types/debug/-/debug-4.1.7.tgz -> electron-dep-@types-debug-4.1.7.tgz
	https://registry.yarnpkg.com/@types/dirty-chai/-/dirty-chai-2.0.2.tgz -> electron-dep-@types-dirty-chai-2.0.2.tgz
	https://registry.yarnpkg.com/@types/eslint-scope/-/eslint-scope-3.7.4.tgz -> electron-dep-@types-eslint-scope-3.7.4.tgz
	https://registry.yarnpkg.com/@types/eslint/-/eslint-8.4.5.tgz -> electron-dep-@types-eslint-8.4.5.tgz
	https://registry.yarnpkg.com/@types/estree/-/estree-0.0.51.tgz -> electron-dep-@types-estree-0.0.51.tgz
	https://registry.yarnpkg.com/@types/estree/-/estree-1.0.0.tgz -> electron-dep-@types-estree-1.0.0.tgz
	https://registry.yarnpkg.com/@types/events/-/events-3.0.0.tgz -> electron-dep-@types-events-3.0.0.tgz
	https://registry.yarnpkg.com/@types/express-serve-static-core/-/express-serve-static-core-4.17.28.tgz -> electron-dep-@types-express-serve-static-core-4.17.28.tgz
	https://registry.yarnpkg.com/@types/express/-/express-4.17.13.tgz -> electron-dep-@types-express-4.17.13.tgz
	https://registry.yarnpkg.com/@types/fs-extra/-/fs-extra-9.0.1.tgz -> electron-dep-@types-fs-extra-9.0.1.tgz
	https://registry.yarnpkg.com/@types/glob/-/glob-7.1.1.tgz -> electron-dep-@types-glob-7.1.1.tgz
	https://registry.yarnpkg.com/@types/http-cache-semantics/-/http-cache-semantics-4.0.1.tgz -> electron-dep-@types-http-cache-semantics-4.0.1.tgz
	https://registry.yarnpkg.com/@types/is-empty/-/is-empty-1.2.0.tgz -> electron-dep-@types-is-empty-1.2.0.tgz
	https://registry.yarnpkg.com/@types/js-yaml/-/js-yaml-4.0.2.tgz -> electron-dep-@types-js-yaml-4.0.2.tgz
	https://registry.yarnpkg.com/@types/json-buffer/-/json-buffer-3.0.0.tgz -> electron-dep-@types-json-buffer-3.0.0.tgz
	https://registry.yarnpkg.com/@types/json-schema/-/json-schema-7.0.11.tgz -> electron-dep-@types-json-schema-7.0.11.tgz
	https://registry.yarnpkg.com/@types/json-schema/-/json-schema-7.0.12.tgz -> electron-dep-@types-json-schema-7.0.12.tgz
	https://registry.yarnpkg.com/@types/json-schema/-/json-schema-7.0.4.tgz -> electron-dep-@types-json-schema-7.0.4.tgz
	https://registry.yarnpkg.com/@types/json5/-/json5-0.0.29.tgz -> electron-dep-@types-json5-0.0.29.tgz
	https://registry.yarnpkg.com/@types/jsonwebtoken/-/jsonwebtoken-9.0.1.tgz -> electron-dep-@types-jsonwebtoken-9.0.1.tgz
	https://registry.yarnpkg.com/@types/keyv/-/keyv-3.1.4.tgz -> electron-dep-@types-keyv-3.1.4.tgz
	https://registry.yarnpkg.com/@types/klaw/-/klaw-3.0.1.tgz -> electron-dep-@types-klaw-3.0.1.tgz
	https://registry.yarnpkg.com/@types/linkify-it/-/linkify-it-2.1.0.tgz -> electron-dep-@types-linkify-it-2.1.0.tgz
	https://registry.yarnpkg.com/@types/markdown-it/-/markdown-it-12.2.3.tgz -> electron-dep-@types-markdown-it-12.2.3.tgz
	https://registry.yarnpkg.com/@types/mdast/-/mdast-3.0.7.tgz -> electron-dep-@types-mdast-3.0.7.tgz
	https://registry.yarnpkg.com/@types/mdurl/-/mdurl-1.0.2.tgz -> electron-dep-@types-mdurl-1.0.2.tgz
	https://registry.yarnpkg.com/@types/mime/-/mime-1.3.2.tgz -> electron-dep-@types-mime-1.3.2.tgz
	https://registry.yarnpkg.com/@types/mime/-/mime-2.0.1.tgz -> electron-dep-@types-mime-2.0.1.tgz
	https://registry.yarnpkg.com/@types/minimatch/-/minimatch-3.0.3.tgz -> electron-dep-@types-minimatch-3.0.3.tgz
	https://registry.yarnpkg.com/@types/minimist/-/minimist-1.2.0.tgz -> electron-dep-@types-minimist-1.2.0.tgz
	https://registry.yarnpkg.com/@types/mocha/-/mocha-7.0.2.tgz -> electron-dep-@types-mocha-7.0.2.tgz
	https://registry.yarnpkg.com/@types/ms/-/ms-0.7.31.tgz -> electron-dep-@types-ms-0.7.31.tgz
	https://registry.yarnpkg.com/@types/node-fetch/-/node-fetch-2.6.1.tgz -> electron-dep-@types-node-fetch-2.6.1.tgz
	https://registry.yarnpkg.com/@types/node/-/node-11.13.22.tgz -> electron-dep-@types-node-11.13.22.tgz
	https://registry.yarnpkg.com/@types/node/-/node-12.6.1.tgz -> electron-dep-@types-node-12.6.1.tgz
	https://registry.yarnpkg.com/@types/node/-/node-16.4.13.tgz -> electron-dep-@types-node-16.4.13.tgz
	https://registry.yarnpkg.com/@types/node/-/node-20.9.0.tgz -> electron-dep-@types-node-20.9.0.tgz
	https://registry.yarnpkg.com/@types/normalize-package-data/-/normalize-package-data-2.4.1.tgz -> electron-dep-@types-normalize-package-data-2.4.1.tgz
	https://registry.yarnpkg.com/@types/parse-json/-/parse-json-4.0.0.tgz -> electron-dep-@types-parse-json-4.0.0.tgz
	https://registry.yarnpkg.com/@types/qs/-/qs-6.9.3.tgz -> electron-dep-@types-qs-6.9.3.tgz
	https://registry.yarnpkg.com/@types/range-parser/-/range-parser-1.2.3.tgz -> electron-dep-@types-range-parser-1.2.3.tgz
	https://registry.yarnpkg.com/@types/repeat-string/-/repeat-string-1.6.1.tgz -> electron-dep-@types-repeat-string-1.6.1.tgz
	https://registry.yarnpkg.com/@types/responselike/-/responselike-1.0.0.tgz -> electron-dep-@types-responselike-1.0.0.tgz
	https://registry.yarnpkg.com/@types/semver/-/semver-7.3.3.tgz -> electron-dep-@types-semver-7.3.3.tgz
	https://registry.yarnpkg.com/@types/semver/-/semver-7.5.0.tgz -> electron-dep-@types-semver-7.5.0.tgz
	https://registry.yarnpkg.com/@types/send/-/send-0.14.5.tgz -> electron-dep-@types-send-0.14.5.tgz
	https://registry.yarnpkg.com/@types/serve-static/-/serve-static-1.13.10.tgz -> electron-dep-@types-serve-static-1.13.10.tgz
	https://registry.yarnpkg.com/@types/split/-/split-1.0.0.tgz -> electron-dep-@types-split-1.0.0.tgz
	https://registry.yarnpkg.com/@types/stream-chain/-/stream-chain-2.0.0.tgz -> electron-dep-@types-stream-chain-2.0.0.tgz
	https://registry.yarnpkg.com/@types/stream-json/-/stream-json-1.5.1.tgz -> electron-dep-@types-stream-json-1.5.1.tgz
	https://registry.yarnpkg.com/@types/supports-color/-/supports-color-8.1.1.tgz -> electron-dep-@types-supports-color-8.1.1.tgz
	https://registry.yarnpkg.com/@types/temp/-/temp-0.8.34.tgz -> electron-dep-@types-temp-0.8.34.tgz
	https://registry.yarnpkg.com/@types/text-table/-/text-table-0.2.2.tgz -> electron-dep-@types-text-table-0.2.2.tgz
	https://registry.yarnpkg.com/@types/through/-/through-0.0.29.tgz -> electron-dep-@types-through-0.0.29.tgz
	https://registry.yarnpkg.com/@types/tunnel/-/tunnel-0.0.3.tgz -> electron-dep-@types-tunnel-0.0.3.tgz
	https://registry.yarnpkg.com/@types/unist/-/unist-2.0.3.tgz -> electron-dep-@types-unist-2.0.3.tgz
	https://registry.yarnpkg.com/@types/unist/-/unist-2.0.6.tgz -> electron-dep-@types-unist-2.0.6.tgz
	https://registry.yarnpkg.com/@types/uuid/-/uuid-3.4.6.tgz -> electron-dep-@types-uuid-3.4.6.tgz
	https://registry.yarnpkg.com/@types/w3c-web-serial/-/w3c-web-serial-1.0.3.tgz -> electron-dep-@types-w3c-web-serial-1.0.3.tgz
	https://registry.yarnpkg.com/@types/webpack-env/-/webpack-env-1.17.0.tgz -> electron-dep-@types-webpack-env-1.17.0.tgz
	https://registry.yarnpkg.com/@types/webpack/-/webpack-5.28.0.tgz -> electron-dep-@types-webpack-5.28.0.tgz
	https://registry.yarnpkg.com/@types/yauzl/-/yauzl-2.10.0.tgz -> electron-dep-@types-yauzl-2.10.0.tgz
	https://registry.yarnpkg.com/@typescript-eslint/eslint-plugin/-/eslint-plugin-5.59.7.tgz -> electron-dep-@typescript-eslint-eslint-plugin-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/parser/-/parser-5.59.7.tgz -> electron-dep-@typescript-eslint-parser-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/scope-manager/-/scope-manager-5.59.7.tgz -> electron-dep-@typescript-eslint-scope-manager-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/type-utils/-/type-utils-5.59.7.tgz -> electron-dep-@typescript-eslint-type-utils-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/types/-/types-5.59.7.tgz -> electron-dep-@typescript-eslint-types-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/typescript-estree/-/typescript-estree-5.59.7.tgz -> electron-dep-@typescript-eslint-typescript-estree-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/utils/-/utils-5.59.7.tgz -> electron-dep-@typescript-eslint-utils-5.59.7.tgz
	https://registry.yarnpkg.com/@typescript-eslint/visitor-keys/-/visitor-keys-5.59.7.tgz -> electron-dep-@typescript-eslint-visitor-keys-5.59.7.tgz
	https://registry.yarnpkg.com/@vscode/l10n/-/l10n-0.0.10.tgz -> electron-dep-@vscode-l10n-0.0.10.tgz
	https://registry.yarnpkg.com/@webassemblyjs/ast/-/ast-1.11.1.tgz -> electron-dep-@webassemblyjs-ast-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/floating-point-hex-parser/-/floating-point-hex-parser-1.11.1.tgz -> electron-dep-@webassemblyjs-floating-point-hex-parser-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/helper-api-error/-/helper-api-error-1.11.1.tgz -> electron-dep-@webassemblyjs-helper-api-error-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/helper-buffer/-/helper-buffer-1.11.1.tgz -> electron-dep-@webassemblyjs-helper-buffer-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/helper-numbers/-/helper-numbers-1.11.1.tgz -> electron-dep-@webassemblyjs-helper-numbers-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/helper-wasm-bytecode/-/helper-wasm-bytecode-1.11.1.tgz -> electron-dep-@webassemblyjs-helper-wasm-bytecode-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/helper-wasm-section/-/helper-wasm-section-1.11.1.tgz -> electron-dep-@webassemblyjs-helper-wasm-section-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/ieee754/-/ieee754-1.11.1.tgz -> electron-dep-@webassemblyjs-ieee754-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/leb128/-/leb128-1.11.1.tgz -> electron-dep-@webassemblyjs-leb128-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/utf8/-/utf8-1.11.1.tgz -> electron-dep-@webassemblyjs-utf8-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/wasm-edit/-/wasm-edit-1.11.1.tgz -> electron-dep-@webassemblyjs-wasm-edit-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/wasm-gen/-/wasm-gen-1.11.1.tgz -> electron-dep-@webassemblyjs-wasm-gen-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/wasm-opt/-/wasm-opt-1.11.1.tgz -> electron-dep-@webassemblyjs-wasm-opt-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/wasm-parser/-/wasm-parser-1.11.1.tgz -> electron-dep-@webassemblyjs-wasm-parser-1.11.1.tgz
	https://registry.yarnpkg.com/@webassemblyjs/wast-printer/-/wast-printer-1.11.1.tgz -> electron-dep-@webassemblyjs-wast-printer-1.11.1.tgz
	https://registry.yarnpkg.com/@webpack-cli/configtest/-/configtest-1.2.0.tgz -> electron-dep-@webpack-cli-configtest-1.2.0.tgz
	https://registry.yarnpkg.com/@webpack-cli/info/-/info-1.5.0.tgz -> electron-dep-@webpack-cli-info-1.5.0.tgz
	https://registry.yarnpkg.com/@webpack-cli/serve/-/serve-1.7.0.tgz -> electron-dep-@webpack-cli-serve-1.7.0.tgz
	https://registry.yarnpkg.com/@xtuc/ieee754/-/ieee754-1.2.0.tgz -> electron-dep-@xtuc-ieee754-1.2.0.tgz
	https://registry.yarnpkg.com/@xtuc/long/-/long-4.2.2.tgz -> electron-dep-@xtuc-long-4.2.2.tgz
	https://registry.yarnpkg.com/accepts/-/accepts-1.3.8.tgz -> electron-dep--accepts-1.3.8.tgz
	https://registry.yarnpkg.com/acorn-import-assertions/-/acorn-import-assertions-1.8.0.tgz -> electron-dep--acorn-import-assertions-1.8.0.tgz
	https://registry.yarnpkg.com/acorn-jsx/-/acorn-jsx-5.3.2.tgz -> electron-dep--acorn-jsx-5.3.2.tgz
	https://registry.yarnpkg.com/acorn/-/acorn-8.8.2.tgz -> electron-dep--acorn-8.8.2.tgz
	https://registry.yarnpkg.com/aggregate-error/-/aggregate-error-3.0.1.tgz -> electron-dep--aggregate-error-3.0.1.tgz
	https://registry.yarnpkg.com/ajv-keywords/-/ajv-keywords-3.4.1.tgz -> electron-dep--ajv-keywords-3.4.1.tgz
	https://registry.yarnpkg.com/ajv-keywords/-/ajv-keywords-3.5.2.tgz -> electron-dep--ajv-keywords-3.5.2.tgz
	https://registry.yarnpkg.com/ajv/-/ajv-6.12.6.tgz -> electron-dep--ajv-6.12.6.tgz
	https://registry.yarnpkg.com/ansi-colors/-/ansi-colors-4.1.1.tgz -> electron-dep--ansi-colors-4.1.1.tgz
	https://registry.yarnpkg.com/ansi-escapes/-/ansi-escapes-4.3.1.tgz -> electron-dep--ansi-escapes-4.3.1.tgz
	https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-4.1.1.tgz -> electron-dep--ansi-regex-4.1.1.tgz
	https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-5.0.1.tgz -> electron-dep--ansi-regex-5.0.1.tgz
	https://registry.yarnpkg.com/ansi-regex/-/ansi-regex-6.0.1.tgz -> electron-dep--ansi-regex-6.0.1.tgz
	https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-3.2.1.tgz -> electron-dep--ansi-styles-3.2.1.tgz
	https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-4.2.1.tgz -> electron-dep--ansi-styles-4.2.1.tgz
	https://registry.yarnpkg.com/anymatch/-/anymatch-3.0.3.tgz -> electron-dep--anymatch-3.0.3.tgz
	https://registry.yarnpkg.com/anymatch/-/anymatch-3.1.2.tgz -> electron-dep--anymatch-3.1.2.tgz
	https://registry.yarnpkg.com/argparse/-/argparse-1.0.10.tgz -> electron-dep--argparse-1.0.10.tgz
	https://registry.yarnpkg.com/argparse/-/argparse-2.0.1.tgz -> electron-dep--argparse-2.0.1.tgz
	https://registry.yarnpkg.com/array-buffer-byte-length/-/array-buffer-byte-length-1.0.0.tgz -> electron-dep--array-buffer-byte-length-1.0.0.tgz
	https://registry.yarnpkg.com/array-flatten/-/array-flatten-1.1.1.tgz -> electron-dep--array-flatten-1.1.1.tgz
	https://registry.yarnpkg.com/array-includes/-/array-includes-3.1.6.tgz -> electron-dep--array-includes-3.1.6.tgz
	https://registry.yarnpkg.com/array-union/-/array-union-2.1.0.tgz -> electron-dep--array-union-2.1.0.tgz
	https://registry.yarnpkg.com/array-unique/-/array-unique-0.3.2.tgz -> electron-dep--array-unique-0.3.2.tgz
	https://registry.yarnpkg.com/array.prototype.flat/-/array.prototype.flat-1.3.1.tgz -> electron-dep--array.prototype.flat-1.3.1.tgz
	https://registry.yarnpkg.com/array.prototype.flatmap/-/array.prototype.flatmap-1.3.1.tgz -> electron-dep--array.prototype.flatmap-1.3.1.tgz
	https://registry.yarnpkg.com/array.prototype.tosorted/-/array.prototype.tosorted-1.1.1.tgz -> electron-dep--array.prototype.tosorted-1.1.1.tgz
	https://registry.yarnpkg.com/arrify/-/arrify-1.0.1.tgz -> electron-dep--arrify-1.0.1.tgz
	https://registry.yarnpkg.com/assertion-error/-/assertion-error-1.1.0.tgz -> electron-dep--assertion-error-1.1.0.tgz
	https://registry.yarnpkg.com/astral-regex/-/astral-regex-2.0.0.tgz -> electron-dep--astral-regex-2.0.0.tgz
	https://registry.yarnpkg.com/async/-/async-3.2.4.tgz -> electron-dep--async-3.2.4.tgz
	https://registry.yarnpkg.com/asynckit/-/asynckit-0.4.0.tgz -> electron-dep--asynckit-0.4.0.tgz
	https://registry.yarnpkg.com/at-least-node/-/at-least-node-1.0.0.tgz -> electron-dep--at-least-node-1.0.0.tgz
	https://registry.yarnpkg.com/available-typed-arrays/-/available-typed-arrays-1.0.5.tgz -> electron-dep--available-typed-arrays-1.0.5.tgz
	https://registry.yarnpkg.com/bail/-/bail-2.0.1.tgz -> electron-dep--bail-2.0.1.tgz
	https://registry.yarnpkg.com/balanced-match/-/balanced-match-1.0.2.tgz -> electron-dep--balanced-match-1.0.2.tgz
	https://registry.yarnpkg.com/balanced-match/-/balanced-match-2.0.0.tgz -> electron-dep--balanced-match-2.0.0.tgz
	https://registry.yarnpkg.com/base64-js/-/base64-js-1.5.1.tgz -> electron-dep--base64-js-1.5.1.tgz
	https://registry.yarnpkg.com/before-after-hook/-/before-after-hook-2.2.3.tgz -> electron-dep--before-after-hook-2.2.3.tgz
	https://registry.yarnpkg.com/big.js/-/big.js-5.2.2.tgz -> electron-dep--big.js-5.2.2.tgz
	https://registry.yarnpkg.com/binary-extensions/-/binary-extensions-2.1.0.tgz -> electron-dep--binary-extensions-2.1.0.tgz
	https://registry.yarnpkg.com/body-parser/-/body-parser-1.20.1.tgz -> electron-dep--body-parser-1.20.1.tgz
	https://registry.yarnpkg.com/boolean/-/boolean-3.2.0.tgz -> electron-dep--boolean-3.2.0.tgz
	https://registry.yarnpkg.com/brace-expansion/-/brace-expansion-1.1.11.tgz -> electron-dep--brace-expansion-1.1.11.tgz
	https://registry.yarnpkg.com/brace-expansion/-/brace-expansion-2.0.1.tgz -> electron-dep--brace-expansion-2.0.1.tgz
	https://registry.yarnpkg.com/braces/-/braces-3.0.2.tgz -> electron-dep--braces-3.0.2.tgz
	https://registry.yarnpkg.com/browserslist/-/browserslist-4.21.2.tgz -> electron-dep--browserslist-4.21.2.tgz
	https://registry.yarnpkg.com/btoa-lite/-/btoa-lite-1.0.0.tgz -> electron-dep--btoa-lite-1.0.0.tgz
	https://registry.yarnpkg.com/buffer-crc32/-/buffer-crc32-0.2.13.tgz -> electron-dep--buffer-crc32-0.2.13.tgz
	https://registry.yarnpkg.com/buffer-equal-constant-time/-/buffer-equal-constant-time-1.0.1.tgz -> electron-dep--buffer-equal-constant-time-1.0.1.tgz
	https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.1.tgz -> electron-dep--buffer-from-1.1.1.tgz
	https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.2.tgz -> electron-dep--buffer-from-1.1.2.tgz
	https://registry.yarnpkg.com/buffer/-/buffer-6.0.3.tgz -> electron-dep--buffer-6.0.3.tgz
	https://registry.yarnpkg.com/builtin-modules/-/builtin-modules-3.3.0.tgz -> electron-dep--builtin-modules-3.3.0.tgz
	https://registry.yarnpkg.com/builtins/-/builtins-4.0.0.tgz -> electron-dep--builtins-4.0.0.tgz
	https://registry.yarnpkg.com/builtins/-/builtins-5.0.1.tgz -> electron-dep--builtins-5.0.1.tgz
	https://registry.yarnpkg.com/bytes/-/bytes-3.1.2.tgz -> electron-dep--bytes-3.1.2.tgz
	https://registry.yarnpkg.com/cacheable-lookup/-/cacheable-lookup-5.0.4.tgz -> electron-dep--cacheable-lookup-5.0.4.tgz
	https://registry.yarnpkg.com/cacheable-request/-/cacheable-request-7.0.2.tgz -> electron-dep--cacheable-request-7.0.2.tgz
	https://registry.yarnpkg.com/call-bind/-/call-bind-1.0.2.tgz -> electron-dep--call-bind-1.0.2.tgz
	https://registry.yarnpkg.com/callsites/-/callsites-3.1.0.tgz -> electron-dep--callsites-3.1.0.tgz
	https://registry.yarnpkg.com/camelcase/-/camelcase-6.2.0.tgz -> electron-dep--camelcase-6.2.0.tgz
	https://registry.yarnpkg.com/caniuse-lite/-/caniuse-lite-1.0.30001367.tgz -> electron-dep--caniuse-lite-1.0.30001367.tgz
	https://registry.yarnpkg.com/chai/-/chai-4.2.0.tgz -> electron-dep--chai-4.2.0.tgz
	https://registry.yarnpkg.com/chalk/-/chalk-2.4.2.tgz -> electron-dep--chalk-2.4.2.tgz
	https://registry.yarnpkg.com/chalk/-/chalk-3.0.0.tgz -> electron-dep--chalk-3.0.0.tgz
	https://registry.yarnpkg.com/chalk/-/chalk-4.1.0.tgz -> electron-dep--chalk-4.1.0.tgz
	https://registry.yarnpkg.com/character-entities-legacy/-/character-entities-legacy-2.0.0.tgz -> electron-dep--character-entities-legacy-2.0.0.tgz
	https://registry.yarnpkg.com/character-entities/-/character-entities-2.0.0.tgz -> electron-dep--character-entities-2.0.0.tgz
	https://registry.yarnpkg.com/character-reference-invalid/-/character-reference-invalid-2.0.0.tgz -> electron-dep--character-reference-invalid-2.0.0.tgz
	https://registry.yarnpkg.com/check-error/-/check-error-1.0.2.tgz -> electron-dep--check-error-1.0.2.tgz
	https://registry.yarnpkg.com/check-for-leaks/-/check-for-leaks-1.2.1.tgz -> electron-dep--check-for-leaks-1.2.1.tgz
	https://registry.yarnpkg.com/chokidar/-/chokidar-3.5.2.tgz -> electron-dep--chokidar-3.5.2.tgz
	https://registry.yarnpkg.com/chownr/-/chownr-2.0.0.tgz -> electron-dep--chownr-2.0.0.tgz
	https://registry.yarnpkg.com/chrome-trace-event/-/chrome-trace-event-1.0.2.tgz -> electron-dep--chrome-trace-event-1.0.2.tgz
	https://registry.yarnpkg.com/chromium-pickle-js/-/chromium-pickle-js-0.2.0.tgz -> electron-dep--chromium-pickle-js-0.2.0.tgz
	https://registry.yarnpkg.com/ci-info/-/ci-info-3.8.0.tgz -> electron-dep--ci-info-3.8.0.tgz
	https://registry.yarnpkg.com/clean-regexp/-/clean-regexp-1.0.0.tgz -> electron-dep--clean-regexp-1.0.0.tgz
	https://registry.yarnpkg.com/clean-stack/-/clean-stack-2.2.0.tgz -> electron-dep--clean-stack-2.2.0.tgz
	https://registry.yarnpkg.com/cli-cursor/-/cli-cursor-2.1.0.tgz -> electron-dep--cli-cursor-2.1.0.tgz
	https://registry.yarnpkg.com/cli-cursor/-/cli-cursor-3.1.0.tgz -> electron-dep--cli-cursor-3.1.0.tgz
	https://registry.yarnpkg.com/cli-spinners/-/cli-spinners-2.2.0.tgz -> electron-dep--cli-spinners-2.2.0.tgz
	https://registry.yarnpkg.com/cli-truncate/-/cli-truncate-2.1.0.tgz -> electron-dep--cli-truncate-2.1.0.tgz
	https://registry.yarnpkg.com/clone-deep/-/clone-deep-4.0.1.tgz -> electron-dep--clone-deep-4.0.1.tgz
	https://registry.yarnpkg.com/clone-response/-/clone-response-1.0.2.tgz -> electron-dep--clone-response-1.0.2.tgz
	https://registry.yarnpkg.com/clone/-/clone-1.0.4.tgz -> electron-dep--clone-1.0.4.tgz
	https://registry.yarnpkg.com/co/-/co-3.1.0.tgz -> electron-dep--co-3.1.0.tgz
	https://registry.yarnpkg.com/color-convert/-/color-convert-1.9.3.tgz -> electron-dep--color-convert-1.9.3.tgz
	https://registry.yarnpkg.com/color-convert/-/color-convert-2.0.1.tgz -> electron-dep--color-convert-2.0.1.tgz
	https://registry.yarnpkg.com/color-name/-/color-name-1.1.3.tgz -> electron-dep--color-name-1.1.3.tgz
	https://registry.yarnpkg.com/color-name/-/color-name-1.1.4.tgz -> electron-dep--color-name-1.1.4.tgz
	https://registry.yarnpkg.com/colorette/-/colorette-2.0.19.tgz -> electron-dep--colorette-2.0.19.tgz
	https://registry.yarnpkg.com/colors/-/colors-1.3.3.tgz -> electron-dep--colors-1.3.3.tgz
	https://registry.yarnpkg.com/colors/-/colors-1.4.0.tgz -> electron-dep--colors-1.4.0.tgz
	https://registry.yarnpkg.com/combined-stream/-/combined-stream-1.0.8.tgz -> electron-dep--combined-stream-1.0.8.tgz
	https://registry.yarnpkg.com/commander/-/commander-2.20.3.tgz -> electron-dep--commander-2.20.3.tgz
	https://registry.yarnpkg.com/commander/-/commander-5.1.0.tgz -> electron-dep--commander-5.1.0.tgz
	https://registry.yarnpkg.com/commander/-/commander-7.2.0.tgz -> electron-dep--commander-7.2.0.tgz
	https://registry.yarnpkg.com/commander/-/commander-9.4.1.tgz -> electron-dep--commander-9.4.1.tgz
	https://registry.yarnpkg.com/compress-brotli/-/compress-brotli-1.3.8.tgz -> electron-dep--compress-brotli-1.3.8.tgz
	https://registry.yarnpkg.com/concat-map/-/concat-map-0.0.1.tgz -> electron-dep--concat-map-0.0.1.tgz
	https://registry.yarnpkg.com/concat-stream/-/concat-stream-2.0.0.tgz -> electron-dep--concat-stream-2.0.0.tgz
	https://registry.yarnpkg.com/content-disposition/-/content-disposition-0.5.4.tgz -> electron-dep--content-disposition-0.5.4.tgz
	https://registry.yarnpkg.com/content-type/-/content-type-1.0.4.tgz -> electron-dep--content-type-1.0.4.tgz
	https://registry.yarnpkg.com/cookie-signature/-/cookie-signature-1.0.6.tgz -> electron-dep--cookie-signature-1.0.6.tgz
	https://registry.yarnpkg.com/cookie/-/cookie-0.5.0.tgz -> electron-dep--cookie-0.5.0.tgz
	https://registry.yarnpkg.com/core-util-is/-/core-util-is-1.0.2.tgz -> electron-dep--core-util-is-1.0.2.tgz
	https://registry.yarnpkg.com/cosmiconfig/-/cosmiconfig-6.0.0.tgz -> electron-dep--cosmiconfig-6.0.0.tgz
	https://registry.yarnpkg.com/cross-spawn/-/cross-spawn-7.0.3.tgz -> electron-dep--cross-spawn-7.0.3.tgz
	https://registry.yarnpkg.com/debug/-/debug-2.6.9.tgz -> electron-dep--debug-2.6.9.tgz
	https://registry.yarnpkg.com/debug/-/debug-3.2.7.tgz -> electron-dep--debug-3.2.7.tgz
	https://registry.yarnpkg.com/debug/-/debug-4.3.2.tgz -> electron-dep--debug-4.3.2.tgz
	https://registry.yarnpkg.com/debug/-/debug-4.3.4.tgz -> electron-dep--debug-4.3.4.tgz
	https://registry.yarnpkg.com/decode-named-character-reference/-/decode-named-character-reference-1.0.2.tgz -> electron-dep--decode-named-character-reference-1.0.2.tgz
	https://registry.yarnpkg.com/decompress-response/-/decompress-response-6.0.0.tgz -> electron-dep--decompress-response-6.0.0.tgz
	https://registry.yarnpkg.com/dedent/-/dedent-0.7.0.tgz -> electron-dep--dedent-0.7.0.tgz
	https://registry.yarnpkg.com/deep-eql/-/deep-eql-3.0.1.tgz -> electron-dep--deep-eql-3.0.1.tgz
	https://registry.yarnpkg.com/deep-extend/-/deep-extend-0.6.0.tgz -> electron-dep--deep-extend-0.6.0.tgz
	https://registry.yarnpkg.com/deep-is/-/deep-is-0.1.3.tgz -> electron-dep--deep-is-0.1.3.tgz
	https://registry.yarnpkg.com/defaults/-/defaults-1.0.3.tgz -> electron-dep--defaults-1.0.3.tgz
	https://registry.yarnpkg.com/defer-to-connect/-/defer-to-connect-2.0.1.tgz -> electron-dep--defer-to-connect-2.0.1.tgz
	https://registry.yarnpkg.com/define-properties/-/define-properties-1.2.0.tgz -> electron-dep--define-properties-1.2.0.tgz
	https://registry.yarnpkg.com/delayed-stream/-/delayed-stream-1.0.0.tgz -> electron-dep--delayed-stream-1.0.0.tgz
	https://registry.yarnpkg.com/depd/-/depd-2.0.0.tgz -> electron-dep--depd-2.0.0.tgz
	https://registry.yarnpkg.com/deprecation/-/deprecation-2.3.1.tgz -> electron-dep--deprecation-2.3.1.tgz
	https://registry.yarnpkg.com/dequal/-/dequal-2.0.3.tgz -> electron-dep--dequal-2.0.3.tgz
	https://registry.yarnpkg.com/destroy/-/destroy-1.2.0.tgz -> electron-dep--destroy-1.2.0.tgz
	https://registry.yarnpkg.com/detect-node/-/detect-node-2.1.0.tgz -> electron-dep--detect-node-2.1.0.tgz
	https://registry.yarnpkg.com/diff/-/diff-3.5.0.tgz -> electron-dep--diff-3.5.0.tgz
	https://registry.yarnpkg.com/diff/-/diff-5.1.0.tgz -> electron-dep--diff-5.1.0.tgz
	https://registry.yarnpkg.com/dir-glob/-/dir-glob-3.0.1.tgz -> electron-dep--dir-glob-3.0.1.tgz
	https://registry.yarnpkg.com/doctrine/-/doctrine-2.1.0.tgz -> electron-dep--doctrine-2.1.0.tgz
	https://registry.yarnpkg.com/doctrine/-/doctrine-3.0.0.tgz -> electron-dep--doctrine-3.0.0.tgz
	https://registry.yarnpkg.com/dotenv-safe/-/dotenv-safe-4.0.4.tgz -> electron-dep--dotenv-safe-4.0.4.tgz
	https://registry.yarnpkg.com/dotenv/-/dotenv-4.0.0.tgz -> electron-dep--dotenv-4.0.0.tgz
	https://registry.yarnpkg.com/dugite/-/dugite-2.3.0.tgz -> electron-dep--dugite-2.3.0.tgz
	https://registry.yarnpkg.com/duplexer/-/duplexer-0.1.1.tgz -> electron-dep--duplexer-0.1.1.tgz
	https://registry.yarnpkg.com/ecdsa-sig-formatter/-/ecdsa-sig-formatter-1.0.11.tgz -> electron-dep--ecdsa-sig-formatter-1.0.11.tgz
	https://registry.yarnpkg.com/ee-first/-/ee-first-1.1.1.tgz -> electron-dep--ee-first-1.1.1.tgz
	https://registry.yarnpkg.com/electron-to-chromium/-/electron-to-chromium-1.4.195.tgz -> electron-dep--electron-to-chromium-1.4.195.tgz
	https://registry.yarnpkg.com/emoji-regex/-/emoji-regex-8.0.0.tgz -> electron-dep--emoji-regex-8.0.0.tgz
	https://registry.yarnpkg.com/emoji-regex/-/emoji-regex-9.2.2.tgz -> electron-dep--emoji-regex-9.2.2.tgz
	https://registry.yarnpkg.com/emojis-list/-/emojis-list-3.0.0.tgz -> electron-dep--emojis-list-3.0.0.tgz
	https://registry.yarnpkg.com/encodeurl/-/encodeurl-1.0.2.tgz -> electron-dep--encodeurl-1.0.2.tgz
	https://registry.yarnpkg.com/end-of-stream/-/end-of-stream-1.4.4.tgz -> electron-dep--end-of-stream-1.4.4.tgz
	https://registry.yarnpkg.com/enhanced-resolve/-/enhanced-resolve-4.1.0.tgz -> electron-dep--enhanced-resolve-4.1.0.tgz
	https://registry.yarnpkg.com/enhanced-resolve/-/enhanced-resolve-5.12.0.tgz -> electron-dep--enhanced-resolve-5.12.0.tgz
	https://registry.yarnpkg.com/enquirer/-/enquirer-2.3.6.tgz -> electron-dep--enquirer-2.3.6.tgz
	https://registry.yarnpkg.com/ensure-posix-path/-/ensure-posix-path-1.1.1.tgz -> electron-dep--ensure-posix-path-1.1.1.tgz
	https://registry.yarnpkg.com/entities/-/entities-2.1.0.tgz -> electron-dep--entities-2.1.0.tgz
	https://registry.yarnpkg.com/entities/-/entities-3.0.1.tgz -> electron-dep--entities-3.0.1.tgz
	https://registry.yarnpkg.com/env-paths/-/env-paths-2.2.1.tgz -> electron-dep--env-paths-2.2.1.tgz
	https://registry.yarnpkg.com/envinfo/-/envinfo-7.8.1.tgz -> electron-dep--envinfo-7.8.1.tgz
	https://registry.yarnpkg.com/errno/-/errno-0.1.7.tgz -> electron-dep--errno-0.1.7.tgz
	https://registry.yarnpkg.com/error-ex/-/error-ex-1.3.2.tgz -> electron-dep--error-ex-1.3.2.tgz
	https://registry.yarnpkg.com/es-abstract/-/es-abstract-1.21.2.tgz -> electron-dep--es-abstract-1.21.2.tgz
	https://registry.yarnpkg.com/es-module-lexer/-/es-module-lexer-0.9.3.tgz -> electron-dep--es-module-lexer-0.9.3.tgz
	https://registry.yarnpkg.com/es-set-tostringtag/-/es-set-tostringtag-2.0.1.tgz -> electron-dep--es-set-tostringtag-2.0.1.tgz
	https://registry.yarnpkg.com/es-shim-unscopables/-/es-shim-unscopables-1.0.0.tgz -> electron-dep--es-shim-unscopables-1.0.0.tgz
	https://registry.yarnpkg.com/es-to-primitive/-/es-to-primitive-1.2.1.tgz -> electron-dep--es-to-primitive-1.2.1.tgz
	https://registry.yarnpkg.com/es6-error/-/es6-error-4.1.1.tgz -> electron-dep--es6-error-4.1.1.tgz
	https://registry.yarnpkg.com/es6-object-assign/-/es6-object-assign-1.1.0.tgz -> electron-dep--es6-object-assign-1.1.0.tgz
	https://registry.yarnpkg.com/escalade/-/escalade-3.1.1.tgz -> electron-dep--escalade-3.1.1.tgz
	https://registry.yarnpkg.com/escape-html/-/escape-html-1.0.3.tgz -> electron-dep--escape-html-1.0.3.tgz
	https://registry.yarnpkg.com/escape-string-regexp/-/escape-string-regexp-1.0.5.tgz -> electron-dep--escape-string-regexp-1.0.5.tgz
	https://registry.yarnpkg.com/escape-string-regexp/-/escape-string-regexp-4.0.0.tgz -> electron-dep--escape-string-regexp-4.0.0.tgz
	https://registry.yarnpkg.com/eslint-config-standard-jsx/-/eslint-config-standard-jsx-11.0.0.tgz -> electron-dep--eslint-config-standard-jsx-11.0.0.tgz
	https://registry.yarnpkg.com/eslint-config-standard/-/eslint-config-standard-14.1.1.tgz -> electron-dep--eslint-config-standard-14.1.1.tgz
	https://registry.yarnpkg.com/eslint-config-standard/-/eslint-config-standard-17.0.0.tgz -> electron-dep--eslint-config-standard-17.0.0.tgz
	https://registry.yarnpkg.com/eslint-import-resolver-node/-/eslint-import-resolver-node-0.3.7.tgz -> electron-dep--eslint-import-resolver-node-0.3.7.tgz
	https://registry.yarnpkg.com/eslint-module-utils/-/eslint-module-utils-2.8.0.tgz -> electron-dep--eslint-module-utils-2.8.0.tgz
	https://registry.yarnpkg.com/eslint-plugin-es/-/eslint-plugin-es-3.0.1.tgz -> electron-dep--eslint-plugin-es-3.0.1.tgz
	https://registry.yarnpkg.com/eslint-plugin-es/-/eslint-plugin-es-4.1.0.tgz -> electron-dep--eslint-plugin-es-4.1.0.tgz
	https://registry.yarnpkg.com/eslint-plugin-import/-/eslint-plugin-import-2.27.5.tgz -> electron-dep--eslint-plugin-import-2.27.5.tgz
	https://registry.yarnpkg.com/eslint-plugin-mocha/-/eslint-plugin-mocha-7.0.1.tgz -> electron-dep--eslint-plugin-mocha-7.0.1.tgz
	https://registry.yarnpkg.com/eslint-plugin-n/-/eslint-plugin-n-15.7.0.tgz -> electron-dep--eslint-plugin-n-15.7.0.tgz
	https://registry.yarnpkg.com/eslint-plugin-node/-/eslint-plugin-node-11.1.0.tgz -> electron-dep--eslint-plugin-node-11.1.0.tgz
	https://registry.yarnpkg.com/eslint-plugin-promise/-/eslint-plugin-promise-4.3.1.tgz -> electron-dep--eslint-plugin-promise-4.3.1.tgz
	https://registry.yarnpkg.com/eslint-plugin-promise/-/eslint-plugin-promise-6.1.1.tgz -> electron-dep--eslint-plugin-promise-6.1.1.tgz
	https://registry.yarnpkg.com/eslint-plugin-react/-/eslint-plugin-react-7.32.2.tgz -> electron-dep--eslint-plugin-react-7.32.2.tgz
	https://registry.yarnpkg.com/eslint-plugin-standard/-/eslint-plugin-standard-4.0.1.tgz -> electron-dep--eslint-plugin-standard-4.0.1.tgz
	https://registry.yarnpkg.com/eslint-plugin-unicorn/-/eslint-plugin-unicorn-46.0.1.tgz -> electron-dep--eslint-plugin-unicorn-46.0.1.tgz
	https://registry.yarnpkg.com/eslint-scope/-/eslint-scope-5.1.1.tgz -> electron-dep--eslint-scope-5.1.1.tgz
	https://registry.yarnpkg.com/eslint-scope/-/eslint-scope-7.2.0.tgz -> electron-dep--eslint-scope-7.2.0.tgz
	https://registry.yarnpkg.com/eslint-utils/-/eslint-utils-2.1.0.tgz -> electron-dep--eslint-utils-2.1.0.tgz
	https://registry.yarnpkg.com/eslint-utils/-/eslint-utils-3.0.0.tgz -> electron-dep--eslint-utils-3.0.0.tgz
	https://registry.yarnpkg.com/eslint-visitor-keys/-/eslint-visitor-keys-1.1.0.tgz -> electron-dep--eslint-visitor-keys-1.1.0.tgz
	https://registry.yarnpkg.com/eslint-visitor-keys/-/eslint-visitor-keys-2.0.0.tgz -> electron-dep--eslint-visitor-keys-2.0.0.tgz
	https://registry.yarnpkg.com/eslint-visitor-keys/-/eslint-visitor-keys-3.4.1.tgz -> electron-dep--eslint-visitor-keys-3.4.1.tgz
	https://registry.yarnpkg.com/eslint/-/eslint-8.40.0.tgz -> electron-dep--eslint-8.40.0.tgz
	https://registry.yarnpkg.com/eslint/-/eslint-8.41.0.tgz -> electron-dep--eslint-8.41.0.tgz
	https://registry.yarnpkg.com/espree/-/espree-9.5.2.tgz -> electron-dep--espree-9.5.2.tgz
	https://registry.yarnpkg.com/esprima/-/esprima-4.0.1.tgz -> electron-dep--esprima-4.0.1.tgz
	https://registry.yarnpkg.com/esquery/-/esquery-1.5.0.tgz -> electron-dep--esquery-1.5.0.tgz
	https://registry.yarnpkg.com/esrecurse/-/esrecurse-4.3.0.tgz -> electron-dep--esrecurse-4.3.0.tgz
	https://registry.yarnpkg.com/estraverse/-/estraverse-4.3.0.tgz -> electron-dep--estraverse-4.3.0.tgz
	https://registry.yarnpkg.com/estraverse/-/estraverse-5.1.0.tgz -> electron-dep--estraverse-5.1.0.tgz
	https://registry.yarnpkg.com/estraverse/-/estraverse-5.3.0.tgz -> electron-dep--estraverse-5.3.0.tgz
	https://registry.yarnpkg.com/esutils/-/esutils-2.0.3.tgz -> electron-dep--esutils-2.0.3.tgz
	https://registry.yarnpkg.com/etag/-/etag-1.8.1.tgz -> electron-dep--etag-1.8.1.tgz
	https://registry.yarnpkg.com/events-to-array/-/events-to-array-1.1.2.tgz -> electron-dep--events-to-array-1.1.2.tgz
	https://registry.yarnpkg.com/events/-/events-3.3.0.tgz -> electron-dep--events-3.3.0.tgz
	https://registry.yarnpkg.com/execa/-/execa-4.0.3.tgz -> electron-dep--execa-4.0.3.tgz
	https://registry.yarnpkg.com/express/-/express-4.18.2.tgz -> electron-dep--express-4.18.2.tgz
	https://registry.yarnpkg.com/extend/-/extend-3.0.2.tgz -> electron-dep--extend-3.0.2.tgz
	https://registry.yarnpkg.com/extract-zip/-/extract-zip-2.0.1.tgz -> electron-dep--extract-zip-2.0.1.tgz
	https://registry.yarnpkg.com/fast-deep-equal/-/fast-deep-equal-3.1.3.tgz -> electron-dep--fast-deep-equal-3.1.3.tgz
	https://registry.yarnpkg.com/fast-glob/-/fast-glob-3.2.12.tgz -> electron-dep--fast-glob-3.2.12.tgz
	https://registry.yarnpkg.com/fast-json-stable-stringify/-/fast-json-stable-stringify-2.1.0.tgz -> electron-dep--fast-json-stable-stringify-2.1.0.tgz
	https://registry.yarnpkg.com/fast-levenshtein/-/fast-levenshtein-2.0.6.tgz -> electron-dep--fast-levenshtein-2.0.6.tgz
	https://registry.yarnpkg.com/fastest-levenshtein/-/fastest-levenshtein-1.0.14.tgz -> electron-dep--fastest-levenshtein-1.0.14.tgz
	https://registry.yarnpkg.com/fastq/-/fastq-1.8.0.tgz -> electron-dep--fastq-1.8.0.tgz
	https://registry.yarnpkg.com/fault/-/fault-2.0.0.tgz -> electron-dep--fault-2.0.0.tgz
	https://registry.yarnpkg.com/fd-slicer/-/fd-slicer-1.1.0.tgz -> electron-dep--fd-slicer-1.1.0.tgz
	https://registry.yarnpkg.com/figgy-pudding/-/figgy-pudding-3.5.2.tgz -> electron-dep--figgy-pudding-3.5.2.tgz
	https://registry.yarnpkg.com/figures/-/figures-3.2.0.tgz -> electron-dep--figures-3.2.0.tgz
	https://registry.yarnpkg.com/file-entry-cache/-/file-entry-cache-6.0.1.tgz -> electron-dep--file-entry-cache-6.0.1.tgz
	https://registry.yarnpkg.com/fill-range/-/fill-range-7.0.1.tgz -> electron-dep--fill-range-7.0.1.tgz
	https://registry.yarnpkg.com/finalhandler/-/finalhandler-1.2.0.tgz -> electron-dep--finalhandler-1.2.0.tgz
	https://registry.yarnpkg.com/find-up/-/find-up-3.0.0.tgz -> electron-dep--find-up-3.0.0.tgz
	https://registry.yarnpkg.com/find-up/-/find-up-4.1.0.tgz -> electron-dep--find-up-4.1.0.tgz
	https://registry.yarnpkg.com/find-up/-/find-up-5.0.0.tgz -> electron-dep--find-up-5.0.0.tgz
	https://registry.yarnpkg.com/flat-cache/-/flat-cache-3.0.4.tgz -> electron-dep--flat-cache-3.0.4.tgz
	https://registry.yarnpkg.com/flatted/-/flatted-3.2.7.tgz -> electron-dep--flatted-3.2.7.tgz
	https://registry.yarnpkg.com/folder-hash/-/folder-hash-2.1.2.tgz -> electron-dep--folder-hash-2.1.2.tgz
	https://registry.yarnpkg.com/for-each/-/for-each-0.3.3.tgz -> electron-dep--for-each-0.3.3.tgz
	https://registry.yarnpkg.com/form-data/-/form-data-3.0.1.tgz -> electron-dep--form-data-3.0.1.tgz
	https://registry.yarnpkg.com/form-data/-/form-data-4.0.0.tgz -> electron-dep--form-data-4.0.0.tgz
	https://registry.yarnpkg.com/format/-/format-0.2.2.tgz -> electron-dep--format-0.2.2.tgz
	https://registry.yarnpkg.com/forwarded/-/forwarded-0.2.0.tgz -> electron-dep--forwarded-0.2.0.tgz
	https://registry.yarnpkg.com/fresh/-/fresh-0.5.2.tgz -> electron-dep--fresh-0.5.2.tgz
	https://registry.yarnpkg.com/fs-extra/-/fs-extra-10.1.0.tgz -> electron-dep--fs-extra-10.1.0.tgz
	https://registry.yarnpkg.com/fs-extra/-/fs-extra-7.0.1.tgz -> electron-dep--fs-extra-7.0.1.tgz
	https://registry.yarnpkg.com/fs-extra/-/fs-extra-8.1.0.tgz -> electron-dep--fs-extra-8.1.0.tgz
	https://registry.yarnpkg.com/fs-extra/-/fs-extra-9.0.1.tgz -> electron-dep--fs-extra-9.0.1.tgz
	https://registry.yarnpkg.com/fs-minipass/-/fs-minipass-2.1.0.tgz -> electron-dep--fs-minipass-2.1.0.tgz
	https://registry.yarnpkg.com/fs.realpath/-/fs.realpath-1.0.0.tgz -> electron-dep--fs.realpath-1.0.0.tgz
	https://registry.yarnpkg.com/fsevents/-/fsevents-2.3.2.tgz -> electron-dep--fsevents-2.3.2.tgz
	https://registry.yarnpkg.com/function-bind/-/function-bind-1.1.1.tgz -> electron-dep--function-bind-1.1.1.tgz
	https://registry.yarnpkg.com/function.prototype.name/-/function.prototype.name-1.1.5.tgz -> electron-dep--function.prototype.name-1.1.5.tgz
	https://registry.yarnpkg.com/functions-have-names/-/functions-have-names-1.2.3.tgz -> electron-dep--functions-have-names-1.2.3.tgz
	https://registry.yarnpkg.com/get-func-name/-/get-func-name-2.0.2.tgz -> electron-dep--get-func-name-2.0.2.tgz
	https://registry.yarnpkg.com/get-intrinsic/-/get-intrinsic-1.2.1.tgz -> electron-dep--get-intrinsic-1.2.1.tgz
	https://registry.yarnpkg.com/get-own-enumerable-property-symbols/-/get-own-enumerable-property-symbols-3.0.0.tgz -> electron-dep--get-own-enumerable-property-symbols-3.0.0.tgz
	https://registry.yarnpkg.com/get-stdin/-/get-stdin-8.0.0.tgz -> electron-dep--get-stdin-8.0.0.tgz
	https://registry.yarnpkg.com/get-stdin/-/get-stdin-9.0.0.tgz -> electron-dep--get-stdin-9.0.0.tgz
	https://registry.yarnpkg.com/get-stream/-/get-stream-5.2.0.tgz -> electron-dep--get-stream-5.2.0.tgz
	https://registry.yarnpkg.com/get-symbol-description/-/get-symbol-description-1.0.0.tgz -> electron-dep--get-symbol-description-1.0.0.tgz
	https://registry.yarnpkg.com/getos/-/getos-3.2.1.tgz -> electron-dep--getos-3.2.1.tgz
	https://registry.yarnpkg.com/glob-parent/-/glob-parent-5.1.2.tgz -> electron-dep--glob-parent-5.1.2.tgz
	https://registry.yarnpkg.com/glob-parent/-/glob-parent-6.0.2.tgz -> electron-dep--glob-parent-6.0.2.tgz
	https://registry.yarnpkg.com/glob-to-regexp/-/glob-to-regexp-0.4.1.tgz -> electron-dep--glob-to-regexp-0.4.1.tgz
	https://registry.yarnpkg.com/glob/-/glob-7.2.0.tgz -> electron-dep--glob-7.2.0.tgz
	https://registry.yarnpkg.com/glob/-/glob-8.0.3.tgz -> electron-dep--glob-8.0.3.tgz
	https://registry.yarnpkg.com/glob/-/glob-8.1.0.tgz -> electron-dep--glob-8.1.0.tgz
	https://registry.yarnpkg.com/glob/-/glob-9.3.5.tgz -> electron-dep--glob-9.3.5.tgz
	https://registry.yarnpkg.com/global-agent/-/global-agent-3.0.0.tgz -> electron-dep--global-agent-3.0.0.tgz
	https://registry.yarnpkg.com/globals/-/globals-13.20.0.tgz -> electron-dep--globals-13.20.0.tgz
	https://registry.yarnpkg.com/globalthis/-/globalthis-1.0.3.tgz -> electron-dep--globalthis-1.0.3.tgz
	https://registry.yarnpkg.com/globby/-/globby-11.1.0.tgz -> electron-dep--globby-11.1.0.tgz
	https://registry.yarnpkg.com/gopd/-/gopd-1.0.1.tgz -> electron-dep--gopd-1.0.1.tgz
	https://registry.yarnpkg.com/got/-/got-11.8.5.tgz -> electron-dep--got-11.8.5.tgz
	https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.1.15.tgz -> electron-dep--graceful-fs-4.1.15.tgz
	https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.2.10.tgz -> electron-dep--graceful-fs-4.2.10.tgz
	https://registry.yarnpkg.com/grapheme-splitter/-/grapheme-splitter-1.0.4.tgz -> electron-dep--grapheme-splitter-1.0.4.tgz
	https://registry.yarnpkg.com/graphemer/-/graphemer-1.4.0.tgz -> electron-dep--graphemer-1.4.0.tgz
	https://registry.yarnpkg.com/has-bigints/-/has-bigints-1.0.2.tgz -> electron-dep--has-bigints-1.0.2.tgz
	https://registry.yarnpkg.com/has-flag/-/has-flag-3.0.0.tgz -> electron-dep--has-flag-3.0.0.tgz
	https://registry.yarnpkg.com/has-flag/-/has-flag-4.0.0.tgz -> electron-dep--has-flag-4.0.0.tgz
	https://registry.yarnpkg.com/has-flag/-/has-flag-5.0.1.tgz -> electron-dep--has-flag-5.0.1.tgz
	https://registry.yarnpkg.com/has-property-descriptors/-/has-property-descriptors-1.0.0.tgz -> electron-dep--has-property-descriptors-1.0.0.tgz
	https://registry.yarnpkg.com/has-proto/-/has-proto-1.0.1.tgz -> electron-dep--has-proto-1.0.1.tgz
	https://registry.yarnpkg.com/has-symbols/-/has-symbols-1.0.3.tgz -> electron-dep--has-symbols-1.0.3.tgz
	https://registry.yarnpkg.com/has-tostringtag/-/has-tostringtag-1.0.0.tgz -> electron-dep--has-tostringtag-1.0.0.tgz
	https://registry.yarnpkg.com/has/-/has-1.0.3.tgz -> electron-dep--has-1.0.3.tgz
	https://registry.yarnpkg.com/hosted-git-info/-/hosted-git-info-2.8.9.tgz -> electron-dep--hosted-git-info-2.8.9.tgz
	https://registry.yarnpkg.com/http-cache-semantics/-/http-cache-semantics-4.1.1.tgz -> electron-dep--http-cache-semantics-4.1.1.tgz
	https://registry.yarnpkg.com/http-errors/-/http-errors-2.0.0.tgz -> electron-dep--http-errors-2.0.0.tgz
	https://registry.yarnpkg.com/http2-wrapper/-/http2-wrapper-1.0.3.tgz -> electron-dep--http2-wrapper-1.0.3.tgz
	https://registry.yarnpkg.com/human-signals/-/human-signals-1.1.1.tgz -> electron-dep--human-signals-1.1.1.tgz
	https://registry.yarnpkg.com/husky/-/husky-8.0.1.tgz -> electron-dep--husky-8.0.1.tgz
	https://registry.yarnpkg.com/iconv-lite/-/iconv-lite-0.4.24.tgz -> electron-dep--iconv-lite-0.4.24.tgz
	https://registry.yarnpkg.com/ieee754/-/ieee754-1.2.1.tgz -> electron-dep--ieee754-1.2.1.tgz
	https://registry.yarnpkg.com/ignore/-/ignore-5.1.8.tgz -> electron-dep--ignore-5.1.8.tgz
	https://registry.yarnpkg.com/ignore/-/ignore-5.2.4.tgz -> electron-dep--ignore-5.2.4.tgz
	https://registry.yarnpkg.com/import-fresh/-/import-fresh-3.1.0.tgz -> electron-dep--import-fresh-3.1.0.tgz
	https://registry.yarnpkg.com/import-fresh/-/import-fresh-3.2.1.tgz -> electron-dep--import-fresh-3.2.1.tgz
	https://registry.yarnpkg.com/import-fresh/-/import-fresh-3.3.0.tgz -> electron-dep--import-fresh-3.3.0.tgz
	https://registry.yarnpkg.com/import-local/-/import-local-3.1.0.tgz -> electron-dep--import-local-3.1.0.tgz
	https://registry.yarnpkg.com/import-meta-resolve/-/import-meta-resolve-1.1.1.tgz -> electron-dep--import-meta-resolve-1.1.1.tgz
	https://registry.yarnpkg.com/imurmurhash/-/imurmurhash-0.1.4.tgz -> electron-dep--imurmurhash-0.1.4.tgz
	https://registry.yarnpkg.com/indent-string/-/indent-string-4.0.0.tgz -> electron-dep--indent-string-4.0.0.tgz
	https://registry.yarnpkg.com/inflight/-/inflight-1.0.6.tgz -> electron-dep--inflight-1.0.6.tgz
	https://registry.yarnpkg.com/inherits/-/inherits-2.0.4.tgz -> electron-dep--inherits-2.0.4.tgz
	https://registry.yarnpkg.com/ini/-/ini-1.3.7.tgz -> electron-dep--ini-1.3.7.tgz
	https://registry.yarnpkg.com/ini/-/ini-3.0.1.tgz -> electron-dep--ini-3.0.1.tgz
	https://registry.yarnpkg.com/internal-slot/-/internal-slot-1.0.5.tgz -> electron-dep--internal-slot-1.0.5.tgz
	https://registry.yarnpkg.com/interpret/-/interpret-1.4.0.tgz -> electron-dep--interpret-1.4.0.tgz
	https://registry.yarnpkg.com/interpret/-/interpret-2.2.0.tgz -> electron-dep--interpret-2.2.0.tgz
	https://registry.yarnpkg.com/ipaddr.js/-/ipaddr.js-1.9.1.tgz -> electron-dep--ipaddr.js-1.9.1.tgz
	https://registry.yarnpkg.com/is-alphabetical/-/is-alphabetical-2.0.0.tgz -> electron-dep--is-alphabetical-2.0.0.tgz
	https://registry.yarnpkg.com/is-alphanumerical/-/is-alphanumerical-2.0.0.tgz -> electron-dep--is-alphanumerical-2.0.0.tgz
	https://registry.yarnpkg.com/is-array-buffer/-/is-array-buffer-3.0.2.tgz -> electron-dep--is-array-buffer-3.0.2.tgz
	https://registry.yarnpkg.com/is-arrayish/-/is-arrayish-0.2.1.tgz -> electron-dep--is-arrayish-0.2.1.tgz
	https://registry.yarnpkg.com/is-bigint/-/is-bigint-1.0.4.tgz -> electron-dep--is-bigint-1.0.4.tgz
	https://registry.yarnpkg.com/is-binary-path/-/is-binary-path-2.1.0.tgz -> electron-dep--is-binary-path-2.1.0.tgz
	https://registry.yarnpkg.com/is-boolean-object/-/is-boolean-object-1.1.2.tgz -> electron-dep--is-boolean-object-1.1.2.tgz
	https://registry.yarnpkg.com/is-buffer/-/is-buffer-2.0.5.tgz -> electron-dep--is-buffer-2.0.5.tgz
	https://registry.yarnpkg.com/is-builtin-module/-/is-builtin-module-3.2.1.tgz -> electron-dep--is-builtin-module-3.2.1.tgz
	https://registry.yarnpkg.com/is-callable/-/is-callable-1.2.7.tgz -> electron-dep--is-callable-1.2.7.tgz
	https://registry.yarnpkg.com/is-core-module/-/is-core-module-2.12.1.tgz -> electron-dep--is-core-module-2.12.1.tgz
	https://registry.yarnpkg.com/is-core-module/-/is-core-module-2.8.1.tgz -> electron-dep--is-core-module-2.8.1.tgz
	https://registry.yarnpkg.com/is-core-module/-/is-core-module-2.9.0.tgz -> electron-dep--is-core-module-2.9.0.tgz
	https://registry.yarnpkg.com/is-date-object/-/is-date-object-1.0.5.tgz -> electron-dep--is-date-object-1.0.5.tgz
	https://registry.yarnpkg.com/is-decimal/-/is-decimal-2.0.0.tgz -> electron-dep--is-decimal-2.0.0.tgz
	https://registry.yarnpkg.com/is-empty/-/is-empty-1.2.0.tgz -> electron-dep--is-empty-1.2.0.tgz
	https://registry.yarnpkg.com/is-extglob/-/is-extglob-2.1.1.tgz -> electron-dep--is-extglob-2.1.1.tgz
	https://registry.yarnpkg.com/is-fullwidth-code-point/-/is-fullwidth-code-point-3.0.0.tgz -> electron-dep--is-fullwidth-code-point-3.0.0.tgz
	https://registry.yarnpkg.com/is-fullwidth-code-point/-/is-fullwidth-code-point-4.0.0.tgz -> electron-dep--is-fullwidth-code-point-4.0.0.tgz
	https://registry.yarnpkg.com/is-glob/-/is-glob-3.1.0.tgz -> electron-dep--is-glob-3.1.0.tgz
	https://registry.yarnpkg.com/is-glob/-/is-glob-4.0.1.tgz -> electron-dep--is-glob-4.0.1.tgz
	https://registry.yarnpkg.com/is-glob/-/is-glob-4.0.3.tgz -> electron-dep--is-glob-4.0.3.tgz
	https://registry.yarnpkg.com/is-hexadecimal/-/is-hexadecimal-2.0.0.tgz -> electron-dep--is-hexadecimal-2.0.0.tgz
	https://registry.yarnpkg.com/is-interactive/-/is-interactive-1.0.0.tgz -> electron-dep--is-interactive-1.0.0.tgz
	https://registry.yarnpkg.com/is-negative-zero/-/is-negative-zero-2.0.2.tgz -> electron-dep--is-negative-zero-2.0.2.tgz
	https://registry.yarnpkg.com/is-number-object/-/is-number-object-1.0.7.tgz -> electron-dep--is-number-object-1.0.7.tgz
	https://registry.yarnpkg.com/is-number/-/is-number-7.0.0.tgz -> electron-dep--is-number-7.0.0.tgz
	https://registry.yarnpkg.com/is-obj/-/is-obj-1.0.1.tgz -> electron-dep--is-obj-1.0.1.tgz
	https://registry.yarnpkg.com/is-path-inside/-/is-path-inside-3.0.3.tgz -> electron-dep--is-path-inside-3.0.3.tgz
	https://registry.yarnpkg.com/is-plain-obj/-/is-plain-obj-4.0.0.tgz -> electron-dep--is-plain-obj-4.0.0.tgz
	https://registry.yarnpkg.com/is-plain-object/-/is-plain-object-2.0.4.tgz -> electron-dep--is-plain-object-2.0.4.tgz
	https://registry.yarnpkg.com/is-plain-object/-/is-plain-object-5.0.0.tgz -> electron-dep--is-plain-object-5.0.0.tgz
	https://registry.yarnpkg.com/is-regex/-/is-regex-1.1.4.tgz -> electron-dep--is-regex-1.1.4.tgz
	https://registry.yarnpkg.com/is-regexp/-/is-regexp-1.0.0.tgz -> electron-dep--is-regexp-1.0.0.tgz
	https://registry.yarnpkg.com/is-shared-array-buffer/-/is-shared-array-buffer-1.0.2.tgz -> electron-dep--is-shared-array-buffer-1.0.2.tgz
	https://registry.yarnpkg.com/is-stream/-/is-stream-2.0.0.tgz -> electron-dep--is-stream-2.0.0.tgz
	https://registry.yarnpkg.com/is-string/-/is-string-1.0.7.tgz -> electron-dep--is-string-1.0.7.tgz
	https://registry.yarnpkg.com/is-symbol/-/is-symbol-1.0.4.tgz -> electron-dep--is-symbol-1.0.4.tgz
	https://registry.yarnpkg.com/is-typed-array/-/is-typed-array-1.1.10.tgz -> electron-dep--is-typed-array-1.1.10.tgz
	https://registry.yarnpkg.com/is-weakref/-/is-weakref-1.0.2.tgz -> electron-dep--is-weakref-1.0.2.tgz
	https://registry.yarnpkg.com/isarray/-/isarray-1.0.0.tgz -> electron-dep--isarray-1.0.0.tgz
	https://registry.yarnpkg.com/isexe/-/isexe-2.0.0.tgz -> electron-dep--isexe-2.0.0.tgz
	https://registry.yarnpkg.com/isobject/-/isobject-3.0.1.tgz -> electron-dep--isobject-3.0.1.tgz
	https://registry.yarnpkg.com/jest-worker/-/jest-worker-27.5.1.tgz -> electron-dep--jest-worker-27.5.1.tgz
	https://registry.yarnpkg.com/js-sdsl/-/js-sdsl-4.4.0.tgz -> electron-dep--js-sdsl-4.4.0.tgz
	https://registry.yarnpkg.com/js-tokens/-/js-tokens-4.0.0.tgz -> electron-dep--js-tokens-4.0.0.tgz
	https://registry.yarnpkg.com/js-yaml/-/js-yaml-3.13.1.tgz -> electron-dep--js-yaml-3.13.1.tgz
	https://registry.yarnpkg.com/js-yaml/-/js-yaml-4.1.0.tgz -> electron-dep--js-yaml-4.1.0.tgz
	https://registry.yarnpkg.com/jsesc/-/jsesc-0.5.0.tgz -> electron-dep--jsesc-0.5.0.tgz
	https://registry.yarnpkg.com/jsesc/-/jsesc-3.0.2.tgz -> electron-dep--jsesc-3.0.2.tgz
	https://registry.yarnpkg.com/json-buffer/-/json-buffer-3.0.1.tgz -> electron-dep--json-buffer-3.0.1.tgz
	https://registry.yarnpkg.com/json-parse-better-errors/-/json-parse-better-errors-1.0.2.tgz -> electron-dep--json-parse-better-errors-1.0.2.tgz
	https://registry.yarnpkg.com/json-parse-even-better-errors/-/json-parse-even-better-errors-2.3.1.tgz -> electron-dep--json-parse-even-better-errors-2.3.1.tgz
	https://registry.yarnpkg.com/json-schema-traverse/-/json-schema-traverse-0.4.1.tgz -> electron-dep--json-schema-traverse-0.4.1.tgz
	https://registry.yarnpkg.com/json-stable-stringify-without-jsonify/-/json-stable-stringify-without-jsonify-1.0.1.tgz -> electron-dep--json-stable-stringify-without-jsonify-1.0.1.tgz
	https://registry.yarnpkg.com/json-stringify-safe/-/json-stringify-safe-5.0.1.tgz -> electron-dep--json-stringify-safe-5.0.1.tgz
	https://registry.yarnpkg.com/json5/-/json5-1.0.2.tgz -> electron-dep--json5-1.0.2.tgz
	https://registry.yarnpkg.com/json5/-/json5-2.2.3.tgz -> electron-dep--json5-2.2.3.tgz
	https://registry.yarnpkg.com/jsonc-parser/-/jsonc-parser-3.2.0.tgz -> electron-dep--jsonc-parser-3.2.0.tgz
	https://registry.yarnpkg.com/jsonfile/-/jsonfile-4.0.0.tgz -> electron-dep--jsonfile-4.0.0.tgz
	https://registry.yarnpkg.com/jsonfile/-/jsonfile-6.0.1.tgz -> electron-dep--jsonfile-6.0.1.tgz
	https://registry.yarnpkg.com/jsonwebtoken/-/jsonwebtoken-9.0.0.tgz -> electron-dep--jsonwebtoken-9.0.0.tgz
	https://registry.yarnpkg.com/jsx-ast-utils/-/jsx-ast-utils-3.3.3.tgz -> electron-dep--jsx-ast-utils-3.3.3.tgz
	https://registry.yarnpkg.com/jwa/-/jwa-1.4.1.tgz -> electron-dep--jwa-1.4.1.tgz
	https://registry.yarnpkg.com/jws/-/jws-3.2.2.tgz -> electron-dep--jws-3.2.2.tgz
	https://registry.yarnpkg.com/keyv/-/keyv-4.3.1.tgz -> electron-dep--keyv-4.3.1.tgz
	https://registry.yarnpkg.com/kind-of/-/kind-of-6.0.3.tgz -> electron-dep--kind-of-6.0.3.tgz
	https://registry.yarnpkg.com/klaw/-/klaw-3.0.0.tgz -> electron-dep--klaw-3.0.0.tgz
	https://registry.yarnpkg.com/kleur/-/kleur-4.1.5.tgz -> electron-dep--kleur-4.1.5.tgz
	https://registry.yarnpkg.com/levn/-/levn-0.4.1.tgz -> electron-dep--levn-0.4.1.tgz
	https://registry.yarnpkg.com/libnpmconfig/-/libnpmconfig-1.2.1.tgz -> electron-dep--libnpmconfig-1.2.1.tgz
	https://registry.yarnpkg.com/lines-and-columns/-/lines-and-columns-1.1.6.tgz -> electron-dep--lines-and-columns-1.1.6.tgz
	https://registry.yarnpkg.com/linkify-it/-/linkify-it-3.0.3.tgz -> electron-dep--linkify-it-3.0.3.tgz
	https://registry.yarnpkg.com/linkify-it/-/linkify-it-4.0.1.tgz -> electron-dep--linkify-it-4.0.1.tgz
	https://registry.yarnpkg.com/lint-staged/-/lint-staged-10.2.11.tgz -> electron-dep--lint-staged-10.2.11.tgz
	https://registry.yarnpkg.com/lint/-/lint-1.1.2.tgz -> electron-dep--lint-1.1.2.tgz
	https://registry.yarnpkg.com/listr2/-/listr2-2.2.0.tgz -> electron-dep--listr2-2.2.0.tgz
	https://registry.yarnpkg.com/load-json-file/-/load-json-file-5.3.0.tgz -> electron-dep--load-json-file-5.3.0.tgz
	https://registry.yarnpkg.com/load-plugin/-/load-plugin-4.0.1.tgz -> electron-dep--load-plugin-4.0.1.tgz
	https://registry.yarnpkg.com/loader-runner/-/loader-runner-4.3.0.tgz -> electron-dep--loader-runner-4.3.0.tgz
	https://registry.yarnpkg.com/loader-utils/-/loader-utils-1.4.2.tgz -> electron-dep--loader-utils-1.4.2.tgz
	https://registry.yarnpkg.com/loader-utils/-/loader-utils-2.0.4.tgz -> electron-dep--loader-utils-2.0.4.tgz
	https://registry.yarnpkg.com/locate-path/-/locate-path-3.0.0.tgz -> electron-dep--locate-path-3.0.0.tgz
	https://registry.yarnpkg.com/locate-path/-/locate-path-5.0.0.tgz -> electron-dep--locate-path-5.0.0.tgz
	https://registry.yarnpkg.com/locate-path/-/locate-path-6.0.0.tgz -> electron-dep--locate-path-6.0.0.tgz
	https://registry.yarnpkg.com/lodash.camelcase/-/lodash.camelcase-4.3.0.tgz -> electron-dep--lodash.camelcase-4.3.0.tgz
	https://registry.yarnpkg.com/lodash.merge/-/lodash.merge-4.6.2.tgz -> electron-dep--lodash.merge-4.6.2.tgz
	https://registry.yarnpkg.com/lodash/-/lodash-4.17.21.tgz -> electron-dep--lodash-4.17.21.tgz
	https://registry.yarnpkg.com/log-symbols/-/log-symbols-2.2.0.tgz -> electron-dep--log-symbols-2.2.0.tgz
	https://registry.yarnpkg.com/log-symbols/-/log-symbols-3.0.0.tgz -> electron-dep--log-symbols-3.0.0.tgz
	https://registry.yarnpkg.com/log-symbols/-/log-symbols-4.0.0.tgz -> electron-dep--log-symbols-4.0.0.tgz
	https://registry.yarnpkg.com/log-update/-/log-update-4.0.0.tgz -> electron-dep--log-update-4.0.0.tgz
	https://registry.yarnpkg.com/longest-streak/-/longest-streak-3.0.0.tgz -> electron-dep--longest-streak-3.0.0.tgz
	https://registry.yarnpkg.com/loose-envify/-/loose-envify-1.4.0.tgz -> electron-dep--loose-envify-1.4.0.tgz
	https://registry.yarnpkg.com/lowercase-keys/-/lowercase-keys-2.0.0.tgz -> electron-dep--lowercase-keys-2.0.0.tgz
	https://registry.yarnpkg.com/lru-cache/-/lru-cache-6.0.0.tgz -> electron-dep--lru-cache-6.0.0.tgz
	https://registry.yarnpkg.com/lru-cache/-/lru-cache-9.1.1.tgz -> electron-dep--lru-cache-9.1.1.tgz
	https://registry.yarnpkg.com/make-error/-/make-error-1.3.5.tgz -> electron-dep--make-error-1.3.5.tgz
	https://registry.yarnpkg.com/markdown-it/-/markdown-it-12.3.2.tgz -> electron-dep--markdown-it-12.3.2.tgz
	https://registry.yarnpkg.com/markdown-it/-/markdown-it-13.0.1.tgz -> electron-dep--markdown-it-13.0.1.tgz
	https://registry.yarnpkg.com/markdownlint-cli/-/markdownlint-cli-0.33.0.tgz -> electron-dep--markdownlint-cli-0.33.0.tgz
	https://registry.yarnpkg.com/markdownlint/-/markdownlint-0.27.0.tgz -> electron-dep--markdownlint-0.27.0.tgz
	https://registry.yarnpkg.com/matcher-collection/-/matcher-collection-1.1.2.tgz -> electron-dep--matcher-collection-1.1.2.tgz
	https://registry.yarnpkg.com/matcher/-/matcher-3.0.0.tgz -> electron-dep--matcher-3.0.0.tgz
	https://registry.yarnpkg.com/mdast-comment-marker/-/mdast-comment-marker-1.1.1.tgz -> electron-dep--mdast-comment-marker-1.1.1.tgz
	https://registry.yarnpkg.com/mdast-util-from-markdown/-/mdast-util-from-markdown-1.0.0.tgz -> electron-dep--mdast-util-from-markdown-1.0.0.tgz
	https://registry.yarnpkg.com/mdast-util-from-markdown/-/mdast-util-from-markdown-1.3.0.tgz -> electron-dep--mdast-util-from-markdown-1.3.0.tgz
	https://registry.yarnpkg.com/mdast-util-heading-style/-/mdast-util-heading-style-1.0.5.tgz -> electron-dep--mdast-util-heading-style-1.0.5.tgz
	https://registry.yarnpkg.com/mdast-util-to-markdown/-/mdast-util-to-markdown-1.1.1.tgz -> electron-dep--mdast-util-to-markdown-1.1.1.tgz
	https://registry.yarnpkg.com/mdast-util-to-string/-/mdast-util-to-string-1.0.6.tgz -> electron-dep--mdast-util-to-string-1.0.6.tgz
	https://registry.yarnpkg.com/mdast-util-to-string/-/mdast-util-to-string-3.1.0.tgz -> electron-dep--mdast-util-to-string-3.1.0.tgz
	https://registry.yarnpkg.com/mdurl/-/mdurl-1.0.1.tgz -> electron-dep--mdurl-1.0.1.tgz
	https://registry.yarnpkg.com/media-typer/-/media-typer-0.3.0.tgz -> electron-dep--media-typer-0.3.0.tgz
	https://registry.yarnpkg.com/memory-fs/-/memory-fs-0.4.1.tgz -> electron-dep--memory-fs-0.4.1.tgz
	https://registry.yarnpkg.com/merge-descriptors/-/merge-descriptors-1.0.1.tgz -> electron-dep--merge-descriptors-1.0.1.tgz
	https://registry.yarnpkg.com/merge-stream/-/merge-stream-2.0.0.tgz -> electron-dep--merge-stream-2.0.0.tgz
	https://registry.yarnpkg.com/merge2/-/merge2-1.4.1.tgz -> electron-dep--merge2-1.4.1.tgz
	https://registry.yarnpkg.com/methods/-/methods-1.1.2.tgz -> electron-dep--methods-1.1.2.tgz
	https://registry.yarnpkg.com/micromark-core-commonmark/-/micromark-core-commonmark-1.0.0.tgz -> electron-dep--micromark-core-commonmark-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-factory-destination/-/micromark-factory-destination-1.0.0.tgz -> electron-dep--micromark-factory-destination-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-factory-label/-/micromark-factory-label-1.0.0.tgz -> electron-dep--micromark-factory-label-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-factory-space/-/micromark-factory-space-1.0.0.tgz -> electron-dep--micromark-factory-space-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-factory-title/-/micromark-factory-title-1.0.0.tgz -> electron-dep--micromark-factory-title-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-factory-whitespace/-/micromark-factory-whitespace-1.0.0.tgz -> electron-dep--micromark-factory-whitespace-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-character/-/micromark-util-character-1.1.0.tgz -> electron-dep--micromark-util-character-1.1.0.tgz
	https://registry.yarnpkg.com/micromark-util-chunked/-/micromark-util-chunked-1.0.0.tgz -> electron-dep--micromark-util-chunked-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-classify-character/-/micromark-util-classify-character-1.0.0.tgz -> electron-dep--micromark-util-classify-character-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-combine-extensions/-/micromark-util-combine-extensions-1.0.0.tgz -> electron-dep--micromark-util-combine-extensions-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-decode-numeric-character-reference/-/micromark-util-decode-numeric-character-reference-1.0.0.tgz -> electron-dep--micromark-util-decode-numeric-character-reference-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-decode-string/-/micromark-util-decode-string-1.0.2.tgz -> electron-dep--micromark-util-decode-string-1.0.2.tgz
	https://registry.yarnpkg.com/micromark-util-encode/-/micromark-util-encode-1.0.0.tgz -> electron-dep--micromark-util-encode-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-html-tag-name/-/micromark-util-html-tag-name-1.0.0.tgz -> electron-dep--micromark-util-html-tag-name-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-normalize-identifier/-/micromark-util-normalize-identifier-1.0.0.tgz -> electron-dep--micromark-util-normalize-identifier-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-resolve-all/-/micromark-util-resolve-all-1.0.0.tgz -> electron-dep--micromark-util-resolve-all-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-sanitize-uri/-/micromark-util-sanitize-uri-1.0.0.tgz -> electron-dep--micromark-util-sanitize-uri-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-subtokenize/-/micromark-util-subtokenize-1.0.0.tgz -> electron-dep--micromark-util-subtokenize-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-symbol/-/micromark-util-symbol-1.0.0.tgz -> electron-dep--micromark-util-symbol-1.0.0.tgz
	https://registry.yarnpkg.com/micromark-util-types/-/micromark-util-types-1.0.0.tgz -> electron-dep--micromark-util-types-1.0.0.tgz
	https://registry.yarnpkg.com/micromark/-/micromark-3.0.3.tgz -> electron-dep--micromark-3.0.3.tgz
	https://registry.yarnpkg.com/micromatch/-/micromatch-4.0.2.tgz -> electron-dep--micromatch-4.0.2.tgz
	https://registry.yarnpkg.com/micromatch/-/micromatch-4.0.5.tgz -> electron-dep--micromatch-4.0.5.tgz
	https://registry.yarnpkg.com/mime-db/-/mime-db-1.52.0.tgz -> electron-dep--mime-db-1.52.0.tgz
	https://registry.yarnpkg.com/mime-types/-/mime-types-2.1.35.tgz -> electron-dep--mime-types-2.1.35.tgz
	https://registry.yarnpkg.com/mime/-/mime-1.6.0.tgz -> electron-dep--mime-1.6.0.tgz
	https://registry.yarnpkg.com/mimic-fn/-/mimic-fn-1.2.0.tgz -> electron-dep--mimic-fn-1.2.0.tgz
	https://registry.yarnpkg.com/mimic-fn/-/mimic-fn-2.1.0.tgz -> electron-dep--mimic-fn-2.1.0.tgz
	https://registry.yarnpkg.com/mimic-response/-/mimic-response-1.0.1.tgz -> electron-dep--mimic-response-1.0.1.tgz
	https://registry.yarnpkg.com/mimic-response/-/mimic-response-3.1.0.tgz -> electron-dep--mimic-response-3.1.0.tgz
	https://registry.yarnpkg.com/min-indent/-/min-indent-1.0.1.tgz -> electron-dep--min-indent-1.0.1.tgz
	https://registry.yarnpkg.com/minimatch/-/minimatch-3.0.8.tgz -> electron-dep--minimatch-3.0.8.tgz
	https://registry.yarnpkg.com/minimatch/-/minimatch-3.1.2.tgz -> electron-dep--minimatch-3.1.2.tgz
	https://registry.yarnpkg.com/minimatch/-/minimatch-5.1.1.tgz -> electron-dep--minimatch-5.1.1.tgz
	https://registry.yarnpkg.com/minimatch/-/minimatch-5.1.2.tgz -> electron-dep--minimatch-5.1.2.tgz
	https://registry.yarnpkg.com/minimatch/-/minimatch-8.0.4.tgz -> electron-dep--minimatch-8.0.4.tgz
	https://registry.yarnpkg.com/minimist/-/minimist-1.2.6.tgz -> electron-dep--minimist-1.2.6.tgz
	https://registry.yarnpkg.com/minimist/-/minimist-1.2.8.tgz -> electron-dep--minimist-1.2.8.tgz
	https://registry.yarnpkg.com/minipass/-/minipass-3.3.6.tgz -> electron-dep--minipass-3.3.6.tgz
	https://registry.yarnpkg.com/minipass/-/minipass-4.0.1.tgz -> electron-dep--minipass-4.0.1.tgz
	https://registry.yarnpkg.com/minipass/-/minipass-4.2.8.tgz -> electron-dep--minipass-4.2.8.tgz
	https://registry.yarnpkg.com/minipass/-/minipass-6.0.2.tgz -> electron-dep--minipass-6.0.2.tgz
	https://registry.yarnpkg.com/minizlib/-/minizlib-2.1.2.tgz -> electron-dep--minizlib-2.1.2.tgz
	https://registry.yarnpkg.com/mkdirp/-/mkdirp-0.5.5.tgz -> electron-dep--mkdirp-0.5.5.tgz
	https://registry.yarnpkg.com/mkdirp/-/mkdirp-1.0.4.tgz -> electron-dep--mkdirp-1.0.4.tgz
	https://registry.yarnpkg.com/mri/-/mri-1.2.0.tgz -> electron-dep--mri-1.2.0.tgz
	https://registry.yarnpkg.com/ms/-/ms-2.0.0.tgz -> electron-dep--ms-2.0.0.tgz
	https://registry.yarnpkg.com/ms/-/ms-2.1.2.tgz -> electron-dep--ms-2.1.2.tgz
	https://registry.yarnpkg.com/ms/-/ms-2.1.3.tgz -> electron-dep--ms-2.1.3.tgz
	https://registry.yarnpkg.com/mute-stream/-/mute-stream-0.0.8.tgz -> electron-dep--mute-stream-0.0.8.tgz
	https://registry.yarnpkg.com/nan/-/nan-2.19.0.tgz -> electron-dep--nan-2.19.0.tgz
	https://registry.yarnpkg.com/natural-compare-lite/-/natural-compare-lite-1.4.0.tgz -> electron-dep--natural-compare-lite-1.4.0.tgz
	https://registry.yarnpkg.com/natural-compare/-/natural-compare-1.4.0.tgz -> electron-dep--natural-compare-1.4.0.tgz
	https://registry.yarnpkg.com/negotiator/-/negotiator-0.6.3.tgz -> electron-dep--negotiator-0.6.3.tgz
	https://registry.yarnpkg.com/neo-async/-/neo-async-2.6.2.tgz -> electron-dep--neo-async-2.6.2.tgz
	https://registry.yarnpkg.com/node-fetch/-/node-fetch-2.6.7.tgz -> electron-dep--node-fetch-2.6.7.tgz
	https://registry.yarnpkg.com/node-fetch/-/node-fetch-2.6.8.tgz -> electron-dep--node-fetch-2.6.8.tgz
	https://registry.yarnpkg.com/node-fetch/-/node-fetch-2.6.9.tgz -> electron-dep--node-fetch-2.6.9.tgz
	https://registry.yarnpkg.com/node-releases/-/node-releases-2.0.6.tgz -> electron-dep--node-releases-2.0.6.tgz
	https://registry.yarnpkg.com/normalize-package-data/-/normalize-package-data-2.5.0.tgz -> electron-dep--normalize-package-data-2.5.0.tgz
	https://registry.yarnpkg.com/normalize-path/-/normalize-path-3.0.0.tgz -> electron-dep--normalize-path-3.0.0.tgz
	https://registry.yarnpkg.com/normalize-url/-/normalize-url-6.1.0.tgz -> electron-dep--normalize-url-6.1.0.tgz
	https://registry.yarnpkg.com/npm-run-path/-/npm-run-path-4.0.1.tgz -> electron-dep--npm-run-path-4.0.1.tgz
	https://registry.yarnpkg.com/null-loader/-/null-loader-4.0.0.tgz -> electron-dep--null-loader-4.0.0.tgz
	https://registry.yarnpkg.com/object-assign/-/object-assign-4.1.1.tgz -> electron-dep--object-assign-4.1.1.tgz
	https://registry.yarnpkg.com/object-inspect/-/object-inspect-1.12.3.tgz -> electron-dep--object-inspect-1.12.3.tgz
	https://registry.yarnpkg.com/object-keys/-/object-keys-1.1.1.tgz -> electron-dep--object-keys-1.1.1.tgz
	https://registry.yarnpkg.com/object.assign/-/object.assign-4.1.4.tgz -> electron-dep--object.assign-4.1.4.tgz
	https://registry.yarnpkg.com/object.entries/-/object.entries-1.1.6.tgz -> electron-dep--object.entries-1.1.6.tgz
	https://registry.yarnpkg.com/object.fromentries/-/object.fromentries-2.0.6.tgz -> electron-dep--object.fromentries-2.0.6.tgz
	https://registry.yarnpkg.com/object.hasown/-/object.hasown-1.1.2.tgz -> electron-dep--object.hasown-1.1.2.tgz
	https://registry.yarnpkg.com/object.values/-/object.values-1.1.6.tgz -> electron-dep--object.values-1.1.6.tgz
	https://registry.yarnpkg.com/on-finished/-/on-finished-2.4.1.tgz -> electron-dep--on-finished-2.4.1.tgz
	https://registry.yarnpkg.com/once/-/once-1.4.0.tgz -> electron-dep--once-1.4.0.tgz
	https://registry.yarnpkg.com/onetime/-/onetime-2.0.1.tgz -> electron-dep--onetime-2.0.1.tgz
	https://registry.yarnpkg.com/onetime/-/onetime-5.1.0.tgz -> electron-dep--onetime-5.1.0.tgz
	https://registry.yarnpkg.com/optionator/-/optionator-0.9.1.tgz -> electron-dep--optionator-0.9.1.tgz
	https://registry.yarnpkg.com/ora/-/ora-3.4.0.tgz -> electron-dep--ora-3.4.0.tgz
	https://registry.yarnpkg.com/ora/-/ora-4.0.3.tgz -> electron-dep--ora-4.0.3.tgz
	https://registry.yarnpkg.com/os-tmpdir/-/os-tmpdir-1.0.2.tgz -> electron-dep--os-tmpdir-1.0.2.tgz
	https://registry.yarnpkg.com/p-cancelable/-/p-cancelable-2.1.1.tgz -> electron-dep--p-cancelable-2.1.1.tgz
	https://registry.yarnpkg.com/p-limit/-/p-limit-2.2.0.tgz -> electron-dep--p-limit-2.2.0.tgz
	https://registry.yarnpkg.com/p-limit/-/p-limit-2.3.0.tgz -> electron-dep--p-limit-2.3.0.tgz
	https://registry.yarnpkg.com/p-limit/-/p-limit-3.1.0.tgz -> electron-dep--p-limit-3.1.0.tgz
	https://registry.yarnpkg.com/p-locate/-/p-locate-3.0.0.tgz -> electron-dep--p-locate-3.0.0.tgz
	https://registry.yarnpkg.com/p-locate/-/p-locate-4.1.0.tgz -> electron-dep--p-locate-4.1.0.tgz
	https://registry.yarnpkg.com/p-locate/-/p-locate-5.0.0.tgz -> electron-dep--p-locate-5.0.0.tgz
	https://registry.yarnpkg.com/p-map/-/p-map-4.0.0.tgz -> electron-dep--p-map-4.0.0.tgz
	https://registry.yarnpkg.com/p-try/-/p-try-2.2.0.tgz -> electron-dep--p-try-2.2.0.tgz
	https://registry.yarnpkg.com/parent-module/-/parent-module-1.0.1.tgz -> electron-dep--parent-module-1.0.1.tgz
	https://registry.yarnpkg.com/parse-entities/-/parse-entities-3.0.0.tgz -> electron-dep--parse-entities-3.0.0.tgz
	https://registry.yarnpkg.com/parse-gitignore/-/parse-gitignore-0.4.0.tgz -> electron-dep--parse-gitignore-0.4.0.tgz
	https://registry.yarnpkg.com/parse-json/-/parse-json-4.0.0.tgz -> electron-dep--parse-json-4.0.0.tgz
	https://registry.yarnpkg.com/parse-json/-/parse-json-5.0.0.tgz -> electron-dep--parse-json-5.0.0.tgz
	https://registry.yarnpkg.com/parse-ms/-/parse-ms-2.1.0.tgz -> electron-dep--parse-ms-2.1.0.tgz
	https://registry.yarnpkg.com/parseurl/-/parseurl-1.3.3.tgz -> electron-dep--parseurl-1.3.3.tgz
	https://registry.yarnpkg.com/path-exists/-/path-exists-3.0.0.tgz -> electron-dep--path-exists-3.0.0.tgz
	https://registry.yarnpkg.com/path-exists/-/path-exists-4.0.0.tgz -> electron-dep--path-exists-4.0.0.tgz
	https://registry.yarnpkg.com/path-is-absolute/-/path-is-absolute-1.0.1.tgz -> electron-dep--path-is-absolute-1.0.1.tgz
	https://registry.yarnpkg.com/path-key/-/path-key-3.1.1.tgz -> electron-dep--path-key-3.1.1.tgz
	https://registry.yarnpkg.com/path-parse/-/path-parse-1.0.7.tgz -> electron-dep--path-parse-1.0.7.tgz
	https://registry.yarnpkg.com/path-scurry/-/path-scurry-1.9.2.tgz -> electron-dep--path-scurry-1.9.2.tgz
	https://registry.yarnpkg.com/path-to-regexp/-/path-to-regexp-0.1.7.tgz -> electron-dep--path-to-regexp-0.1.7.tgz
	https://registry.yarnpkg.com/path-type/-/path-type-4.0.0.tgz -> electron-dep--path-type-4.0.0.tgz
	https://registry.yarnpkg.com/pathval/-/pathval-1.1.1.tgz -> electron-dep--pathval-1.1.1.tgz
	https://registry.yarnpkg.com/pend/-/pend-1.2.0.tgz -> electron-dep--pend-1.2.0.tgz
	https://registry.yarnpkg.com/picocolors/-/picocolors-1.0.0.tgz -> electron-dep--picocolors-1.0.0.tgz
	https://registry.yarnpkg.com/picomatch/-/picomatch-2.0.7.tgz -> electron-dep--picomatch-2.0.7.tgz
	https://registry.yarnpkg.com/picomatch/-/picomatch-2.2.2.tgz -> electron-dep--picomatch-2.2.2.tgz
	https://registry.yarnpkg.com/picomatch/-/picomatch-2.3.1.tgz -> electron-dep--picomatch-2.3.1.tgz
	https://registry.yarnpkg.com/pify/-/pify-4.0.1.tgz -> electron-dep--pify-4.0.1.tgz
	https://registry.yarnpkg.com/pkg-conf/-/pkg-conf-3.1.0.tgz -> electron-dep--pkg-conf-3.1.0.tgz
	https://registry.yarnpkg.com/pkg-dir/-/pkg-dir-4.2.0.tgz -> electron-dep--pkg-dir-4.2.0.tgz
	https://registry.yarnpkg.com/please-upgrade-node/-/please-upgrade-node-3.2.0.tgz -> electron-dep--please-upgrade-node-3.2.0.tgz
	https://registry.yarnpkg.com/pluralize/-/pluralize-8.0.0.tgz -> electron-dep--pluralize-8.0.0.tgz
	https://registry.yarnpkg.com/pre-flight/-/pre-flight-1.1.1.tgz -> electron-dep--pre-flight-1.1.1.tgz
	https://registry.yarnpkg.com/prelude-ls/-/prelude-ls-1.2.1.tgz -> electron-dep--prelude-ls-1.2.1.tgz
	https://registry.yarnpkg.com/pretty-ms/-/pretty-ms-5.0.0.tgz -> electron-dep--pretty-ms-5.0.0.tgz
	https://registry.yarnpkg.com/pretty-ms/-/pretty-ms-5.1.0.tgz -> electron-dep--pretty-ms-5.1.0.tgz
	https://registry.yarnpkg.com/process-nextick-args/-/process-nextick-args-2.0.1.tgz -> electron-dep--process-nextick-args-2.0.1.tgz
	https://registry.yarnpkg.com/process/-/process-0.11.10.tgz -> electron-dep--process-0.11.10.tgz
	https://registry.yarnpkg.com/progress/-/progress-2.0.3.tgz -> electron-dep--progress-2.0.3.tgz
	https://registry.yarnpkg.com/prop-types/-/prop-types-15.8.1.tgz -> electron-dep--prop-types-15.8.1.tgz
	https://registry.yarnpkg.com/proxy-addr/-/proxy-addr-2.0.7.tgz -> electron-dep--proxy-addr-2.0.7.tgz
	https://registry.yarnpkg.com/prr/-/prr-1.0.1.tgz -> electron-dep--prr-1.0.1.tgz
	https://registry.yarnpkg.com/pump/-/pump-3.0.0.tgz -> electron-dep--pump-3.0.0.tgz
	https://registry.yarnpkg.com/punycode/-/punycode-1.3.2.tgz -> electron-dep--punycode-1.3.2.tgz
	https://registry.yarnpkg.com/punycode/-/punycode-2.1.1.tgz -> electron-dep--punycode-2.1.1.tgz
	https://registry.yarnpkg.com/qs/-/qs-6.11.0.tgz -> electron-dep--qs-6.11.0.tgz
	https://registry.yarnpkg.com/querystring/-/querystring-0.2.0.tgz -> electron-dep--querystring-0.2.0.tgz
	https://registry.yarnpkg.com/quick-lru/-/quick-lru-5.1.1.tgz -> electron-dep--quick-lru-5.1.1.tgz
	https://registry.yarnpkg.com/ramda/-/ramda-0.27.0.tgz -> electron-dep--ramda-0.27.0.tgz
	https://registry.yarnpkg.com/randombytes/-/randombytes-2.1.0.tgz -> electron-dep--randombytes-2.1.0.tgz
	https://registry.yarnpkg.com/range-parser/-/range-parser-1.2.1.tgz -> electron-dep--range-parser-1.2.1.tgz
	https://registry.yarnpkg.com/raw-body/-/raw-body-2.5.1.tgz -> electron-dep--raw-body-2.5.1.tgz
	https://registry.yarnpkg.com/react-is/-/react-is-16.13.1.tgz -> electron-dep--react-is-16.13.1.tgz
	https://registry.yarnpkg.com/read-pkg-up/-/read-pkg-up-7.0.1.tgz -> electron-dep--read-pkg-up-7.0.1.tgz
	https://registry.yarnpkg.com/read-pkg/-/read-pkg-5.2.0.tgz -> electron-dep--read-pkg-5.2.0.tgz
	https://registry.yarnpkg.com/readable-stream/-/readable-stream-2.3.6.tgz -> electron-dep--readable-stream-2.3.6.tgz
	https://registry.yarnpkg.com/readable-stream/-/readable-stream-3.6.0.tgz -> electron-dep--readable-stream-3.6.0.tgz
	https://registry.yarnpkg.com/readdirp/-/readdirp-3.6.0.tgz -> electron-dep--readdirp-3.6.0.tgz
	https://registry.yarnpkg.com/rechoir/-/rechoir-0.6.2.tgz -> electron-dep--rechoir-0.6.2.tgz
	https://registry.yarnpkg.com/rechoir/-/rechoir-0.7.1.tgz -> electron-dep--rechoir-0.7.1.tgz
	https://registry.yarnpkg.com/regexp-tree/-/regexp-tree-0.1.27.tgz -> electron-dep--regexp-tree-0.1.27.tgz
	https://registry.yarnpkg.com/regexp.prototype.flags/-/regexp.prototype.flags-1.5.0.tgz -> electron-dep--regexp.prototype.flags-1.5.0.tgz
	https://registry.yarnpkg.com/regexpp/-/regexpp-3.0.0.tgz -> electron-dep--regexpp-3.0.0.tgz
	https://registry.yarnpkg.com/regjsparser/-/regjsparser-0.9.1.tgz -> electron-dep--regjsparser-0.9.1.tgz
	https://registry.yarnpkg.com/remark-cli/-/remark-cli-10.0.0.tgz -> electron-dep--remark-cli-10.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-blockquote-indentation/-/remark-lint-blockquote-indentation-2.0.1.tgz -> electron-dep--remark-lint-blockquote-indentation-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-code-block-style/-/remark-lint-code-block-style-2.0.1.tgz -> electron-dep--remark-lint-code-block-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-definition-case/-/remark-lint-definition-case-2.0.1.tgz -> electron-dep--remark-lint-definition-case-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-definition-spacing/-/remark-lint-definition-spacing-2.0.1.tgz -> electron-dep--remark-lint-definition-spacing-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-emphasis-marker/-/remark-lint-emphasis-marker-2.0.1.tgz -> electron-dep--remark-lint-emphasis-marker-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-fenced-code-flag/-/remark-lint-fenced-code-flag-2.0.1.tgz -> electron-dep--remark-lint-fenced-code-flag-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-fenced-code-marker/-/remark-lint-fenced-code-marker-2.0.1.tgz -> electron-dep--remark-lint-fenced-code-marker-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-file-extension/-/remark-lint-file-extension-1.0.3.tgz -> electron-dep--remark-lint-file-extension-1.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-final-definition/-/remark-lint-final-definition-2.1.0.tgz -> electron-dep--remark-lint-final-definition-2.1.0.tgz
	https://registry.yarnpkg.com/remark-lint-hard-break-spaces/-/remark-lint-hard-break-spaces-2.0.1.tgz -> electron-dep--remark-lint-hard-break-spaces-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-heading-increment/-/remark-lint-heading-increment-2.0.1.tgz -> electron-dep--remark-lint-heading-increment-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-heading-style/-/remark-lint-heading-style-2.0.1.tgz -> electron-dep--remark-lint-heading-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-link-title-style/-/remark-lint-link-title-style-2.0.1.tgz -> electron-dep--remark-lint-link-title-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-list-item-content-indent/-/remark-lint-list-item-content-indent-2.0.1.tgz -> electron-dep--remark-lint-list-item-content-indent-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-list-item-indent/-/remark-lint-list-item-indent-2.0.1.tgz -> electron-dep--remark-lint-list-item-indent-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-list-item-spacing/-/remark-lint-list-item-spacing-3.0.0.tgz -> electron-dep--remark-lint-list-item-spacing-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-maximum-heading-length/-/remark-lint-maximum-heading-length-2.0.1.tgz -> electron-dep--remark-lint-maximum-heading-length-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-maximum-line-length/-/remark-lint-maximum-line-length-2.0.3.tgz -> electron-dep--remark-lint-maximum-line-length-2.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-no-auto-link-without-protocol/-/remark-lint-no-auto-link-without-protocol-2.0.1.tgz -> electron-dep--remark-lint-no-auto-link-without-protocol-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-blockquote-without-marker/-/remark-lint-no-blockquote-without-marker-4.0.0.tgz -> electron-dep--remark-lint-no-blockquote-without-marker-4.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-no-consecutive-blank-lines/-/remark-lint-no-consecutive-blank-lines-3.0.0.tgz -> electron-dep--remark-lint-no-consecutive-blank-lines-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-no-duplicate-headings/-/remark-lint-no-duplicate-headings-2.0.1.tgz -> electron-dep--remark-lint-no-duplicate-headings-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-emphasis-as-heading/-/remark-lint-no-emphasis-as-heading-2.0.1.tgz -> electron-dep--remark-lint-no-emphasis-as-heading-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-file-name-articles/-/remark-lint-no-file-name-articles-1.0.3.tgz -> electron-dep--remark-lint-no-file-name-articles-1.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-no-file-name-consecutive-dashes/-/remark-lint-no-file-name-consecutive-dashes-1.0.3.tgz -> electron-dep--remark-lint-no-file-name-consecutive-dashes-1.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-no-file-name-irregular-characters/-/remark-lint-no-file-name-irregular-characters-1.0.3.tgz -> electron-dep--remark-lint-no-file-name-irregular-characters-1.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-no-file-name-mixed-case/-/remark-lint-no-file-name-mixed-case-1.0.3.tgz -> electron-dep--remark-lint-no-file-name-mixed-case-1.0.3.tgz
	https://registry.yarnpkg.com/remark-lint-no-file-name-outer-dashes/-/remark-lint-no-file-name-outer-dashes-1.0.4.tgz -> electron-dep--remark-lint-no-file-name-outer-dashes-1.0.4.tgz
	https://registry.yarnpkg.com/remark-lint-no-heading-punctuation/-/remark-lint-no-heading-punctuation-2.0.1.tgz -> electron-dep--remark-lint-no-heading-punctuation-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-inline-padding/-/remark-lint-no-inline-padding-3.0.0.tgz -> electron-dep--remark-lint-no-inline-padding-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-no-literal-urls/-/remark-lint-no-literal-urls-2.0.1.tgz -> electron-dep--remark-lint-no-literal-urls-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-multiple-toplevel-headings/-/remark-lint-no-multiple-toplevel-headings-2.0.1.tgz -> electron-dep--remark-lint-no-multiple-toplevel-headings-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-shell-dollars/-/remark-lint-no-shell-dollars-2.0.2.tgz -> electron-dep--remark-lint-no-shell-dollars-2.0.2.tgz
	https://registry.yarnpkg.com/remark-lint-no-shortcut-reference-image/-/remark-lint-no-shortcut-reference-image-2.0.1.tgz -> electron-dep--remark-lint-no-shortcut-reference-image-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-shortcut-reference-link/-/remark-lint-no-shortcut-reference-link-2.0.1.tgz -> electron-dep--remark-lint-no-shortcut-reference-link-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-no-table-indentation/-/remark-lint-no-table-indentation-3.0.0.tgz -> electron-dep--remark-lint-no-table-indentation-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-ordered-list-marker-style/-/remark-lint-ordered-list-marker-style-2.0.1.tgz -> electron-dep--remark-lint-ordered-list-marker-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-ordered-list-marker-value/-/remark-lint-ordered-list-marker-value-2.0.1.tgz -> electron-dep--remark-lint-ordered-list-marker-value-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-rule-style/-/remark-lint-rule-style-2.0.1.tgz -> electron-dep--remark-lint-rule-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-strong-marker/-/remark-lint-strong-marker-2.0.1.tgz -> electron-dep--remark-lint-strong-marker-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-table-cell-padding/-/remark-lint-table-cell-padding-3.0.0.tgz -> electron-dep--remark-lint-table-cell-padding-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-table-pipe-alignment/-/remark-lint-table-pipe-alignment-2.0.1.tgz -> electron-dep--remark-lint-table-pipe-alignment-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint-table-pipes/-/remark-lint-table-pipes-3.0.0.tgz -> electron-dep--remark-lint-table-pipes-3.0.0.tgz
	https://registry.yarnpkg.com/remark-lint-unordered-list-marker-style/-/remark-lint-unordered-list-marker-style-2.0.1.tgz -> electron-dep--remark-lint-unordered-list-marker-style-2.0.1.tgz
	https://registry.yarnpkg.com/remark-lint/-/remark-lint-8.0.0.tgz -> electron-dep--remark-lint-8.0.0.tgz
	https://registry.yarnpkg.com/remark-message-control/-/remark-message-control-6.0.0.tgz -> electron-dep--remark-message-control-6.0.0.tgz
	https://registry.yarnpkg.com/remark-parse/-/remark-parse-10.0.0.tgz -> electron-dep--remark-parse-10.0.0.tgz
	https://registry.yarnpkg.com/remark-preset-lint-markdown-style-guide/-/remark-preset-lint-markdown-style-guide-4.0.0.tgz -> electron-dep--remark-preset-lint-markdown-style-guide-4.0.0.tgz
	https://registry.yarnpkg.com/remark-stringify/-/remark-stringify-10.0.0.tgz -> electron-dep--remark-stringify-10.0.0.tgz
	https://registry.yarnpkg.com/remark/-/remark-14.0.1.tgz -> electron-dep--remark-14.0.1.tgz
	https://registry.yarnpkg.com/repeat-string/-/repeat-string-1.6.1.tgz -> electron-dep--repeat-string-1.6.1.tgz
	https://registry.yarnpkg.com/resolve-alpn/-/resolve-alpn-1.2.1.tgz -> electron-dep--resolve-alpn-1.2.1.tgz
	https://registry.yarnpkg.com/resolve-cwd/-/resolve-cwd-3.0.0.tgz -> electron-dep--resolve-cwd-3.0.0.tgz
	https://registry.yarnpkg.com/resolve-from/-/resolve-from-4.0.0.tgz -> electron-dep--resolve-from-4.0.0.tgz
	https://registry.yarnpkg.com/resolve-from/-/resolve-from-5.0.0.tgz -> electron-dep--resolve-from-5.0.0.tgz
	https://registry.yarnpkg.com/resolve/-/resolve-1.17.0.tgz -> electron-dep--resolve-1.17.0.tgz
	https://registry.yarnpkg.com/resolve/-/resolve-1.21.0.tgz -> electron-dep--resolve-1.21.0.tgz
	https://registry.yarnpkg.com/resolve/-/resolve-1.22.1.tgz -> electron-dep--resolve-1.22.1.tgz
	https://registry.yarnpkg.com/resolve/-/resolve-1.22.2.tgz -> electron-dep--resolve-1.22.2.tgz
	https://registry.yarnpkg.com/resolve/-/resolve-2.0.0-next.4.tgz -> electron-dep--resolve-2.0.0-next.4.tgz
	https://registry.yarnpkg.com/responselike/-/responselike-2.0.0.tgz -> electron-dep--responselike-2.0.0.tgz
	https://registry.yarnpkg.com/restore-cursor/-/restore-cursor-2.0.0.tgz -> electron-dep--restore-cursor-2.0.0.tgz
	https://registry.yarnpkg.com/restore-cursor/-/restore-cursor-3.1.0.tgz -> electron-dep--restore-cursor-3.1.0.tgz
	https://registry.yarnpkg.com/reusify/-/reusify-1.0.4.tgz -> electron-dep--reusify-1.0.4.tgz
	https://registry.yarnpkg.com/rimraf/-/rimraf-2.2.8.tgz -> electron-dep--rimraf-2.2.8.tgz
	https://registry.yarnpkg.com/rimraf/-/rimraf-3.0.2.tgz -> electron-dep--rimraf-3.0.2.tgz
	https://registry.yarnpkg.com/rimraf/-/rimraf-4.4.1.tgz -> electron-dep--rimraf-4.4.1.tgz
	https://registry.yarnpkg.com/roarr/-/roarr-2.15.4.tgz -> electron-dep--roarr-2.15.4.tgz
	https://registry.yarnpkg.com/run-con/-/run-con-1.2.11.tgz -> electron-dep--run-con-1.2.11.tgz
	https://registry.yarnpkg.com/run-parallel/-/run-parallel-1.1.9.tgz -> electron-dep--run-parallel-1.1.9.tgz
	https://registry.yarnpkg.com/rxjs/-/rxjs-6.6.0.tgz -> electron-dep--rxjs-6.6.0.tgz
	https://registry.yarnpkg.com/sade/-/sade-1.8.1.tgz -> electron-dep--sade-1.8.1.tgz
	https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.1.2.tgz -> electron-dep--safe-buffer-5.1.2.tgz
	https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.1.tgz -> electron-dep--safe-buffer-5.2.1.tgz
	https://registry.yarnpkg.com/safe-regex-test/-/safe-regex-test-1.0.0.tgz -> electron-dep--safe-regex-test-1.0.0.tgz
	https://registry.yarnpkg.com/safe-regex/-/safe-regex-2.1.1.tgz -> electron-dep--safe-regex-2.1.1.tgz
	https://registry.yarnpkg.com/safer-buffer/-/safer-buffer-2.1.2.tgz -> electron-dep--safer-buffer-2.1.2.tgz
	https://registry.yarnpkg.com/sax/-/sax-1.2.4.tgz -> electron-dep--sax-1.2.4.tgz
	https://registry.yarnpkg.com/schema-utils/-/schema-utils-2.7.0.tgz -> electron-dep--schema-utils-2.7.0.tgz
	https://registry.yarnpkg.com/schema-utils/-/schema-utils-3.1.1.tgz -> electron-dep--schema-utils-3.1.1.tgz
	https://registry.yarnpkg.com/semver-compare/-/semver-compare-1.0.0.tgz -> electron-dep--semver-compare-1.0.0.tgz
	https://registry.yarnpkg.com/semver/-/semver-5.7.2.tgz -> electron-dep--semver-5.7.2.tgz
	https://registry.yarnpkg.com/semver/-/semver-6.3.1.tgz -> electron-dep--semver-6.3.1.tgz
	https://registry.yarnpkg.com/semver/-/semver-7.5.2.tgz -> electron-dep--semver-7.5.2.tgz
	https://registry.yarnpkg.com/send/-/send-0.18.0.tgz -> electron-dep--send-0.18.0.tgz
	https://registry.yarnpkg.com/serialize-error/-/serialize-error-7.0.1.tgz -> electron-dep--serialize-error-7.0.1.tgz
	https://registry.yarnpkg.com/serialize-javascript/-/serialize-javascript-6.0.0.tgz -> electron-dep--serialize-javascript-6.0.0.tgz
	https://registry.yarnpkg.com/serve-static/-/serve-static-1.15.0.tgz -> electron-dep--serve-static-1.15.0.tgz
	https://registry.yarnpkg.com/setprototypeof/-/setprototypeof-1.2.0.tgz -> electron-dep--setprototypeof-1.2.0.tgz
	https://registry.yarnpkg.com/shallow-clone/-/shallow-clone-3.0.1.tgz -> electron-dep--shallow-clone-3.0.1.tgz
	https://registry.yarnpkg.com/shebang-command/-/shebang-command-2.0.0.tgz -> electron-dep--shebang-command-2.0.0.tgz
	https://registry.yarnpkg.com/shebang-regex/-/shebang-regex-3.0.0.tgz -> electron-dep--shebang-regex-3.0.0.tgz
	https://registry.yarnpkg.com/shelljs/-/shelljs-0.8.5.tgz -> electron-dep--shelljs-0.8.5.tgz
	https://registry.yarnpkg.com/shx/-/shx-0.3.2.tgz -> electron-dep--shx-0.3.2.tgz
	https://registry.yarnpkg.com/side-channel/-/side-channel-1.0.4.tgz -> electron-dep--side-channel-1.0.4.tgz
	https://registry.yarnpkg.com/signal-exit/-/signal-exit-3.0.3.tgz -> electron-dep--signal-exit-3.0.3.tgz
	https://registry.yarnpkg.com/simple-git/-/simple-git-3.16.0.tgz -> electron-dep--simple-git-3.16.0.tgz
	https://registry.yarnpkg.com/slash/-/slash-3.0.0.tgz -> electron-dep--slash-3.0.0.tgz
	https://registry.yarnpkg.com/slice-ansi/-/slice-ansi-3.0.0.tgz -> electron-dep--slice-ansi-3.0.0.tgz
	https://registry.yarnpkg.com/slice-ansi/-/slice-ansi-4.0.0.tgz -> electron-dep--slice-ansi-4.0.0.tgz
	https://registry.yarnpkg.com/sliced/-/sliced-1.0.1.tgz -> electron-dep--sliced-1.0.1.tgz
	https://registry.yarnpkg.com/source-map-support/-/source-map-support-0.5.19.tgz -> electron-dep--source-map-support-0.5.19.tgz
	https://registry.yarnpkg.com/source-map-support/-/source-map-support-0.5.21.tgz -> electron-dep--source-map-support-0.5.21.tgz
	https://registry.yarnpkg.com/source-map/-/source-map-0.6.1.tgz -> electron-dep--source-map-0.6.1.tgz
	https://registry.yarnpkg.com/spdx-correct/-/spdx-correct-3.2.0.tgz -> electron-dep--spdx-correct-3.2.0.tgz
	https://registry.yarnpkg.com/spdx-exceptions/-/spdx-exceptions-2.3.0.tgz -> electron-dep--spdx-exceptions-2.3.0.tgz
	https://registry.yarnpkg.com/spdx-expression-parse/-/spdx-expression-parse-3.0.1.tgz -> electron-dep--spdx-expression-parse-3.0.1.tgz
	https://registry.yarnpkg.com/spdx-license-ids/-/spdx-license-ids-3.0.13.tgz -> electron-dep--spdx-license-ids-3.0.13.tgz
	https://registry.yarnpkg.com/sprintf-js/-/sprintf-js-1.0.3.tgz -> electron-dep--sprintf-js-1.0.3.tgz
	https://registry.yarnpkg.com/sprintf-js/-/sprintf-js-1.1.2.tgz -> electron-dep--sprintf-js-1.1.2.tgz
	https://registry.yarnpkg.com/standard-engine/-/standard-engine-15.0.0.tgz -> electron-dep--standard-engine-15.0.0.tgz
	https://registry.yarnpkg.com/standard/-/standard-17.0.0.tgz -> electron-dep--standard-17.0.0.tgz
	https://registry.yarnpkg.com/statuses/-/statuses-2.0.1.tgz -> electron-dep--statuses-2.0.1.tgz
	https://registry.yarnpkg.com/stream-chain/-/stream-chain-2.2.3.tgz -> electron-dep--stream-chain-2.2.3.tgz
	https://registry.yarnpkg.com/stream-json/-/stream-json-1.7.1.tgz -> electron-dep--stream-json-1.7.1.tgz
	https://registry.yarnpkg.com/string-argv/-/string-argv-0.3.1.tgz -> electron-dep--string-argv-0.3.1.tgz
	https://registry.yarnpkg.com/string-width/-/string-width-4.2.0.tgz -> electron-dep--string-width-4.2.0.tgz
	https://registry.yarnpkg.com/string-width/-/string-width-5.0.0.tgz -> electron-dep--string-width-5.0.0.tgz
	https://registry.yarnpkg.com/string.prototype.matchall/-/string.prototype.matchall-4.0.8.tgz -> electron-dep--string.prototype.matchall-4.0.8.tgz
	https://registry.yarnpkg.com/string.prototype.trim/-/string.prototype.trim-1.2.7.tgz -> electron-dep--string.prototype.trim-1.2.7.tgz
	https://registry.yarnpkg.com/string.prototype.trimend/-/string.prototype.trimend-1.0.6.tgz -> electron-dep--string.prototype.trimend-1.0.6.tgz
	https://registry.yarnpkg.com/string.prototype.trimstart/-/string.prototype.trimstart-1.0.6.tgz -> electron-dep--string.prototype.trimstart-1.0.6.tgz
	https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.1.1.tgz -> electron-dep--string_decoder-1.1.1.tgz
	https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.3.0.tgz -> electron-dep--string_decoder-1.3.0.tgz
	https://registry.yarnpkg.com/stringify-object/-/stringify-object-3.3.0.tgz -> electron-dep--stringify-object-3.3.0.tgz
	https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-5.2.0.tgz -> electron-dep--strip-ansi-5.2.0.tgz
	https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-6.0.0.tgz -> electron-dep--strip-ansi-6.0.0.tgz
	https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-6.0.1.tgz -> electron-dep--strip-ansi-6.0.1.tgz
	https://registry.yarnpkg.com/strip-ansi/-/strip-ansi-7.0.0.tgz -> electron-dep--strip-ansi-7.0.0.tgz
	https://registry.yarnpkg.com/strip-bom/-/strip-bom-3.0.0.tgz -> electron-dep--strip-bom-3.0.0.tgz
	https://registry.yarnpkg.com/strip-final-newline/-/strip-final-newline-2.0.0.tgz -> electron-dep--strip-final-newline-2.0.0.tgz
	https://registry.yarnpkg.com/strip-indent/-/strip-indent-3.0.0.tgz -> electron-dep--strip-indent-3.0.0.tgz
	https://registry.yarnpkg.com/strip-json-comments/-/strip-json-comments-3.1.0.tgz -> electron-dep--strip-json-comments-3.1.0.tgz
	https://registry.yarnpkg.com/strip-json-comments/-/strip-json-comments-3.1.1.tgz -> electron-dep--strip-json-comments-3.1.1.tgz
	https://registry.yarnpkg.com/sumchecker/-/sumchecker-3.0.1.tgz -> electron-dep--sumchecker-3.0.1.tgz
	https://registry.yarnpkg.com/supports-color/-/supports-color-5.5.0.tgz -> electron-dep--supports-color-5.5.0.tgz
	https://registry.yarnpkg.com/supports-color/-/supports-color-7.1.0.tgz -> electron-dep--supports-color-7.1.0.tgz
	https://registry.yarnpkg.com/supports-color/-/supports-color-8.1.1.tgz -> electron-dep--supports-color-8.1.1.tgz
	https://registry.yarnpkg.com/supports-color/-/supports-color-9.0.2.tgz -> electron-dep--supports-color-9.0.2.tgz
	https://registry.yarnpkg.com/supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz -> electron-dep--supports-preserve-symlinks-flag-1.0.0.tgz
	https://registry.yarnpkg.com/tap-parser/-/tap-parser-1.2.2.tgz -> electron-dep--tap-parser-1.2.2.tgz
	https://registry.yarnpkg.com/tap-xunit/-/tap-xunit-2.4.1.tgz -> electron-dep--tap-xunit-2.4.1.tgz
	https://registry.yarnpkg.com/tapable/-/tapable-1.1.3.tgz -> electron-dep--tapable-1.1.3.tgz
	https://registry.yarnpkg.com/tapable/-/tapable-2.2.1.tgz -> electron-dep--tapable-2.2.1.tgz
	https://registry.yarnpkg.com/tar/-/tar-6.1.13.tgz -> electron-dep--tar-6.1.13.tgz
	https://registry.yarnpkg.com/temp/-/temp-0.8.3.tgz -> electron-dep--temp-0.8.3.tgz
	https://registry.yarnpkg.com/terser-webpack-plugin/-/terser-webpack-plugin-5.3.3.tgz -> electron-dep--terser-webpack-plugin-5.3.3.tgz
	https://registry.yarnpkg.com/terser/-/terser-5.14.2.tgz -> electron-dep--terser-5.14.2.tgz
	https://registry.yarnpkg.com/text-table/-/text-table-0.2.0.tgz -> electron-dep--text-table-0.2.0.tgz
	https://registry.yarnpkg.com/through/-/through-2.3.8.tgz -> electron-dep--through-2.3.8.tgz
	https://registry.yarnpkg.com/through2/-/through2-2.0.5.tgz -> electron-dep--through2-2.0.5.tgz
	https://registry.yarnpkg.com/timers-browserify/-/timers-browserify-1.4.2.tgz -> electron-dep--timers-browserify-1.4.2.tgz
	https://registry.yarnpkg.com/to-regex-range/-/to-regex-range-5.0.1.tgz -> electron-dep--to-regex-range-5.0.1.tgz
	https://registry.yarnpkg.com/to-vfile/-/to-vfile-7.2.1.tgz -> electron-dep--to-vfile-7.2.1.tgz
	https://registry.yarnpkg.com/toidentifier/-/toidentifier-1.0.1.tgz -> electron-dep--toidentifier-1.0.1.tgz
	https://registry.yarnpkg.com/tr46/-/tr46-0.0.3.tgz -> electron-dep--tr46-0.0.3.tgz
	https://registry.yarnpkg.com/trough/-/trough-2.0.2.tgz -> electron-dep--trough-2.0.2.tgz
	https://registry.yarnpkg.com/ts-loader/-/ts-loader-8.0.2.tgz -> electron-dep--ts-loader-8.0.2.tgz
	https://registry.yarnpkg.com/ts-node/-/ts-node-6.2.0.tgz -> electron-dep--ts-node-6.2.0.tgz
	https://registry.yarnpkg.com/tsconfig-paths/-/tsconfig-paths-3.14.2.tgz -> electron-dep--tsconfig-paths-3.14.2.tgz
	https://registry.yarnpkg.com/tslib/-/tslib-1.10.0.tgz -> electron-dep--tslib-1.10.0.tgz
	https://registry.yarnpkg.com/tslib/-/tslib-2.3.1.tgz -> electron-dep--tslib-2.3.1.tgz
	https://registry.yarnpkg.com/tsutils/-/tsutils-3.21.0.tgz -> electron-dep--tsutils-3.21.0.tgz
	https://registry.yarnpkg.com/tunnel/-/tunnel-0.0.6.tgz -> electron-dep--tunnel-0.0.6.tgz
	https://registry.yarnpkg.com/type-check/-/type-check-0.4.0.tgz -> electron-dep--type-check-0.4.0.tgz
	https://registry.yarnpkg.com/type-detect/-/type-detect-4.0.8.tgz -> electron-dep--type-detect-4.0.8.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.11.0.tgz -> electron-dep--type-fest-0.11.0.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.13.1.tgz -> electron-dep--type-fest-0.13.1.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.20.2.tgz -> electron-dep--type-fest-0.20.2.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.3.1.tgz -> electron-dep--type-fest-0.3.1.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.6.0.tgz -> electron-dep--type-fest-0.6.0.tgz
	https://registry.yarnpkg.com/type-fest/-/type-fest-0.8.1.tgz -> electron-dep--type-fest-0.8.1.tgz
	https://registry.yarnpkg.com/type-is/-/type-is-1.6.18.tgz -> electron-dep--type-is-1.6.18.tgz
	https://registry.yarnpkg.com/typed-array-length/-/typed-array-length-1.0.4.tgz -> electron-dep--typed-array-length-1.0.4.tgz
	https://registry.yarnpkg.com/typedarray/-/typedarray-0.0.6.tgz -> electron-dep--typedarray-0.0.6.tgz
	https://registry.yarnpkg.com/typescript/-/typescript-5.1.3.tgz -> electron-dep--typescript-5.1.3.tgz
	https://registry.yarnpkg.com/uc.micro/-/uc.micro-1.0.6.tgz -> electron-dep--uc.micro-1.0.6.tgz
	https://registry.yarnpkg.com/unbox-primitive/-/unbox-primitive-1.0.2.tgz -> electron-dep--unbox-primitive-1.0.2.tgz
	https://registry.yarnpkg.com/undici-types/-/undici-types-5.26.5.tgz -> electron-dep--undici-types-5.26.5.tgz
	https://registry.yarnpkg.com/unified-args/-/unified-args-9.0.2.tgz -> electron-dep--unified-args-9.0.2.tgz
	https://registry.yarnpkg.com/unified-engine/-/unified-engine-9.0.3.tgz -> electron-dep--unified-engine-9.0.3.tgz
	https://registry.yarnpkg.com/unified-lint-rule/-/unified-lint-rule-1.0.4.tgz -> electron-dep--unified-lint-rule-1.0.4.tgz
	https://registry.yarnpkg.com/unified-message-control/-/unified-message-control-3.0.3.tgz -> electron-dep--unified-message-control-3.0.3.tgz
	https://registry.yarnpkg.com/unified/-/unified-10.1.0.tgz -> electron-dep--unified-10.1.0.tgz
	https://registry.yarnpkg.com/unist-util-generated/-/unist-util-generated-1.1.4.tgz -> electron-dep--unist-util-generated-1.1.4.tgz
	https://registry.yarnpkg.com/unist-util-generated/-/unist-util-generated-1.1.6.tgz -> electron-dep--unist-util-generated-1.1.6.tgz
	https://registry.yarnpkg.com/unist-util-inspect/-/unist-util-inspect-7.0.0.tgz -> electron-dep--unist-util-inspect-7.0.0.tgz
	https://registry.yarnpkg.com/unist-util-is/-/unist-util-is-4.1.0.tgz -> electron-dep--unist-util-is-4.1.0.tgz
	https://registry.yarnpkg.com/unist-util-is/-/unist-util-is-5.1.1.tgz -> electron-dep--unist-util-is-5.1.1.tgz
	https://registry.yarnpkg.com/unist-util-position/-/unist-util-position-3.0.3.tgz -> electron-dep--unist-util-position-3.0.3.tgz
	https://registry.yarnpkg.com/unist-util-stringify-position/-/unist-util-stringify-position-2.0.1.tgz -> electron-dep--unist-util-stringify-position-2.0.1.tgz
	https://registry.yarnpkg.com/unist-util-stringify-position/-/unist-util-stringify-position-3.0.0.tgz -> electron-dep--unist-util-stringify-position-3.0.0.tgz
	https://registry.yarnpkg.com/unist-util-visit-parents/-/unist-util-visit-parents-3.1.1.tgz -> electron-dep--unist-util-visit-parents-3.1.1.tgz
	https://registry.yarnpkg.com/unist-util-visit-parents/-/unist-util-visit-parents-5.1.1.tgz -> electron-dep--unist-util-visit-parents-5.1.1.tgz
	https://registry.yarnpkg.com/unist-util-visit/-/unist-util-visit-2.0.3.tgz -> electron-dep--unist-util-visit-2.0.3.tgz
	https://registry.yarnpkg.com/unist-util-visit/-/unist-util-visit-4.1.2.tgz -> electron-dep--unist-util-visit-4.1.2.tgz
	https://registry.yarnpkg.com/universal-github-app-jwt/-/universal-github-app-jwt-1.1.1.tgz -> electron-dep--universal-github-app-jwt-1.1.1.tgz
	https://registry.yarnpkg.com/universal-user-agent/-/universal-user-agent-6.0.0.tgz -> electron-dep--universal-user-agent-6.0.0.tgz
	https://registry.yarnpkg.com/universalify/-/universalify-0.1.2.tgz -> electron-dep--universalify-0.1.2.tgz
	https://registry.yarnpkg.com/universalify/-/universalify-1.0.0.tgz -> electron-dep--universalify-1.0.0.tgz
	https://registry.yarnpkg.com/universalify/-/universalify-2.0.0.tgz -> electron-dep--universalify-2.0.0.tgz
	https://registry.yarnpkg.com/unpipe/-/unpipe-1.0.0.tgz -> electron-dep--unpipe-1.0.0.tgz
	https://registry.yarnpkg.com/update-browserslist-db/-/update-browserslist-db-1.0.5.tgz -> electron-dep--update-browserslist-db-1.0.5.tgz
	https://registry.yarnpkg.com/uri-js/-/uri-js-4.4.1.tgz -> electron-dep--uri-js-4.4.1.tgz
	https://registry.yarnpkg.com/url/-/url-0.11.0.tgz -> electron-dep--url-0.11.0.tgz
	https://registry.yarnpkg.com/util-deprecate/-/util-deprecate-1.0.2.tgz -> electron-dep--util-deprecate-1.0.2.tgz
	https://registry.yarnpkg.com/utils-merge/-/utils-merge-1.0.1.tgz -> electron-dep--utils-merge-1.0.1.tgz
	https://registry.yarnpkg.com/uuid/-/uuid-8.3.2.tgz -> electron-dep--uuid-8.3.2.tgz
	https://registry.yarnpkg.com/uvu/-/uvu-0.5.6.tgz -> electron-dep--uvu-0.5.6.tgz
	https://registry.yarnpkg.com/validate-npm-package-license/-/validate-npm-package-license-3.0.4.tgz -> electron-dep--validate-npm-package-license-3.0.4.tgz
	https://registry.yarnpkg.com/vary/-/vary-1.1.2.tgz -> electron-dep--vary-1.1.2.tgz
	https://registry.yarnpkg.com/vfile-location/-/vfile-location-3.2.0.tgz -> electron-dep--vfile-location-3.2.0.tgz
	https://registry.yarnpkg.com/vfile-message/-/vfile-message-3.0.1.tgz -> electron-dep--vfile-message-3.0.1.tgz
	https://registry.yarnpkg.com/vfile-reporter/-/vfile-reporter-7.0.1.tgz -> electron-dep--vfile-reporter-7.0.1.tgz
	https://registry.yarnpkg.com/vfile-sort/-/vfile-sort-3.0.0.tgz -> electron-dep--vfile-sort-3.0.0.tgz
	https://registry.yarnpkg.com/vfile-statistics/-/vfile-statistics-2.0.0.tgz -> electron-dep--vfile-statistics-2.0.0.tgz
	https://registry.yarnpkg.com/vfile/-/vfile-5.0.2.tgz -> electron-dep--vfile-5.0.2.tgz
	https://registry.yarnpkg.com/vscode-jsonrpc/-/vscode-jsonrpc-8.1.0.tgz -> electron-dep--vscode-jsonrpc-8.1.0.tgz
	https://registry.yarnpkg.com/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.17.3.tgz -> electron-dep--vscode-languageserver-protocol-3.17.3.tgz
	https://registry.yarnpkg.com/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.7.tgz -> electron-dep--vscode-languageserver-textdocument-1.0.7.tgz
	https://registry.yarnpkg.com/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.8.tgz -> electron-dep--vscode-languageserver-textdocument-1.0.8.tgz
	https://registry.yarnpkg.com/vscode-languageserver-types/-/vscode-languageserver-types-3.17.2.tgz -> electron-dep--vscode-languageserver-types-3.17.2.tgz
	https://registry.yarnpkg.com/vscode-languageserver-types/-/vscode-languageserver-types-3.17.3.tgz -> electron-dep--vscode-languageserver-types-3.17.3.tgz
	https://registry.yarnpkg.com/vscode-languageserver/-/vscode-languageserver-8.1.0.tgz -> electron-dep--vscode-languageserver-8.1.0.tgz
	https://registry.yarnpkg.com/vscode-uri/-/vscode-uri-3.0.6.tgz -> electron-dep--vscode-uri-3.0.6.tgz
	https://registry.yarnpkg.com/vscode-uri/-/vscode-uri-3.0.7.tgz -> electron-dep--vscode-uri-3.0.7.tgz
	https://registry.yarnpkg.com/walk-sync/-/walk-sync-0.3.4.tgz -> electron-dep--walk-sync-0.3.4.tgz
	https://registry.yarnpkg.com/watchpack/-/watchpack-2.4.0.tgz -> electron-dep--watchpack-2.4.0.tgz
	https://registry.yarnpkg.com/wcwidth/-/wcwidth-1.0.1.tgz -> electron-dep--wcwidth-1.0.1.tgz
	https://registry.yarnpkg.com/webidl-conversions/-/webidl-conversions-3.0.1.tgz -> electron-dep--webidl-conversions-3.0.1.tgz
	https://registry.yarnpkg.com/webpack-cli/-/webpack-cli-4.10.0.tgz -> electron-dep--webpack-cli-4.10.0.tgz
	https://registry.yarnpkg.com/webpack-merge/-/webpack-merge-5.8.0.tgz -> electron-dep--webpack-merge-5.8.0.tgz
	https://registry.yarnpkg.com/webpack-sources/-/webpack-sources-3.2.3.tgz -> electron-dep--webpack-sources-3.2.3.tgz
	https://registry.yarnpkg.com/webpack/-/webpack-5.76.0.tgz -> electron-dep--webpack-5.76.0.tgz
	https://registry.yarnpkg.com/whatwg-url/-/whatwg-url-5.0.0.tgz -> electron-dep--whatwg-url-5.0.0.tgz
	https://registry.yarnpkg.com/which-boxed-primitive/-/which-boxed-primitive-1.0.2.tgz -> electron-dep--which-boxed-primitive-1.0.2.tgz
	https://registry.yarnpkg.com/which-typed-array/-/which-typed-array-1.1.9.tgz -> electron-dep--which-typed-array-1.1.9.tgz
	https://registry.yarnpkg.com/which/-/which-2.0.2.tgz -> electron-dep--which-2.0.2.tgz
	https://registry.yarnpkg.com/wildcard/-/wildcard-2.0.0.tgz -> electron-dep--wildcard-2.0.0.tgz
	https://registry.yarnpkg.com/word-wrap/-/word-wrap-1.2.4.tgz -> electron-dep--word-wrap-1.2.4.tgz
	https://registry.yarnpkg.com/wrap-ansi/-/wrap-ansi-6.2.0.tgz -> electron-dep--wrap-ansi-6.2.0.tgz
	https://registry.yarnpkg.com/wrapped/-/wrapped-1.0.1.tgz -> electron-dep--wrapped-1.0.1.tgz
	https://registry.yarnpkg.com/wrapper-webpack-plugin/-/wrapper-webpack-plugin-2.2.2.tgz -> electron-dep--wrapper-webpack-plugin-2.2.2.tgz
	https://registry.yarnpkg.com/wrappy/-/wrappy-1.0.2.tgz -> electron-dep--wrappy-1.0.2.tgz
	https://registry.yarnpkg.com/xdg-basedir/-/xdg-basedir-4.0.0.tgz -> electron-dep--xdg-basedir-4.0.0.tgz
	https://registry.yarnpkg.com/xml2js/-/xml2js-0.5.0.tgz -> electron-dep--xml2js-0.5.0.tgz
	https://registry.yarnpkg.com/xmlbuilder/-/xmlbuilder-11.0.1.tgz -> electron-dep--xmlbuilder-11.0.1.tgz
	https://registry.yarnpkg.com/xmlbuilder/-/xmlbuilder-4.2.1.tgz -> electron-dep--xmlbuilder-4.2.1.tgz
	https://registry.yarnpkg.com/xtend/-/xtend-4.0.2.tgz -> electron-dep--xtend-4.0.2.tgz
	https://registry.yarnpkg.com/yallist/-/yallist-4.0.0.tgz -> electron-dep--yallist-4.0.0.tgz
	https://registry.yarnpkg.com/yaml/-/yaml-1.10.0.tgz -> electron-dep--yaml-1.10.0.tgz
	https://registry.yarnpkg.com/yauzl/-/yauzl-2.10.0.tgz -> electron-dep--yauzl-2.10.0.tgz
	https://registry.yarnpkg.com/yn/-/yn-2.0.0.tgz -> electron-dep--yn-2.0.0.tgz
	https://registry.yarnpkg.com/yocto-queue/-/yocto-queue-0.1.0.tgz -> electron-dep--yocto-queue-0.1.0.tgz
	https://registry.yarnpkg.com/zwitch/-/zwitch-2.0.2.tgz -> electron-dep--zwitch-2.0.2.tgz
"

declare -A CHROMIUM_COMMITS=(
	"b6df4d75ada110883fcc194e7b6eb52aea7f522b"
	"e8e7c38ed76d20abcb4def81196eb9fd32772ea9"
	"-b4d62daa178298eaa6fc8b9bc7ec6835c95ad86e"
	"8d253767f895b45053c39ea99a8f02bbe7071d3a"
	"e189c46f1ee584c1721ccfecb38bd8db84b58d5b"
	"04866680f4f9a8475ae3795ad6ed59649ba478d7"
	"4b48bc4dd6ce9c56d254e552a33a7b7c2d6fc226"
	"5b2d53797e5580cbfea00d732fe25a97c7048b5b"
	"3a75d7f8dc3a08a38dd893031f8996b91a00764b"
	"214859e3567ea9def85305e4f021a5d407e1ccfe"
	"0fc99662b6f4e92dc13626b5b637fe24d01dbc9a"
	"496297fa1be912504d5091af8093f23abf9d77d2"
)

if [ ! -z "${CHROMIUM_COMMITS[*]}" ]; then
	for i in "${CHROMIUM_COMMITS[@]}"; do
		SRC_URI+="https://github.com/chromium/chromium/commit/${i/-}.patch?full_index=true -> chromium-${i/-}.patch
		"
	done
fi

S="${WORKDIR}/${CHROMIUM_P}"
NODE_S="${S}/third_party/electron_node"

LICENSE="BSD"
SLOT="$(ver_cut 1)/$(ver_cut 2-)"
KEYWORDS="~amd64 ~arm64"
IUSE_SYSTEM_LIBS="+system-harfbuzz +system-icu +system-png +system-zstd"
IUSE="+X ${IUSE_SYSTEM_LIBS} custom-cflags cups debug gtk4 -hangouts headless
kerberos libcxx lto +official pax-kernel pgo +proprietary-codecs pulseaudio
qt5 qt6 screencast selinux +system-toolchain vaapi wayland"
REQUIRED_USE="
	!headless? ( || ( X wayland ) )
	pgo? ( X !wayland )
	qt6? ( qt5 )
	screencast? ( wayland )
	!system-toolchain? ( libcxx )
"

COMMON_X_DEPEND="
    x11-libs/libXcomposite:=
    x11-libs/libXcursor:=
    x11-libs/libXdamage:=
    x11-libs/libXfixes:=
    >=x11-libs/libXi-1.6.0:=
    x11-libs/libXrandr:=
    x11-libs/libXrender:=
    x11-libs/libXtst:=
    x11-libs/libxshmfence:=
"

COMMON_SNAPSHOT_DEPEND="
	system-icu? ( >=dev-libs/icu-71.1:= )
	>=dev-libs/libxml2-2.12.4:=[icu]
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	dev-libs/libxslt:=
	media-libs/fontconfig:=
	>=media-libs/freetype-2.11.0-r1:=
	system-harfbuzz? ( >=media-libs/harfbuzz-3:0=[icu(-)] )
	media-libs/libjpeg-turbo:=
	system-png? ( media-libs/libpng:=[-apng(-)] )
	system-zstd? ( >=app-arch/zstd-1.5.5:= )
	>=media-libs/libwebp-0.4.0:=
	media-libs/mesa:=[gbm(+)]
	>=media-libs/openh264-1.6.0:=
	sys-libs/zlib:=
	x11-libs/libdrm:=
	!headless? (
		dev-libs/glib:2
		>=media-libs/alsa-lib-1.0.19:=
		pulseaudio? ( media-libs/libpulse:= )
		sys-apps/pciutils:=
		kerberos? ( virtual/krb5 )
		vaapi? ( >=media-libs/libva-2.7:=[X?,wayland?] )
		X? (
			x11-libs/libX11:=
			x11-libs/libXext:=
			x11-libs/libxcb:=
		)
		x11-libs/libxkbcommon:=
		wayland? (
			dev-libs/libffi:=
			dev-libs/wayland:=
			screencast? ( media-video/pipewire:= )
		)
	)
"

COMMON_DEPEND="
	${COMMON_SNAPSHOT_DEPEND}
	app-eselect/eselect-electron
	app-arch/bzip2:=
	dev-libs/expat:=
	net-misc/curl[ssl]
	sys-apps/dbus:=
	media-libs/flac:=
	sys-libs/zlib:=[minizip]
	!headless? (
		X? ( ${COMMON_X_DEPEND} )
		>=app-accessibility/at-spi2-core-2.46.0:2
		media-libs/mesa:=[X?,wayland?]
		cups? ( >=net-print/cups-1.3.11:= )
		virtual/udev
		x11-libs/cairo:=
		x11-libs/gdk-pixbuf:2
		x11-libs/pango:=
		qt5? (
			dev-qt/qtcore:5
			dev-qt/qtwidgets:5
		)
		qt6? ( dev-qt/qtbase:6[gui,widgets] )
	)
"
RDEPEND="${COMMON_DEPEND}
	!headless? (
		|| (
			x11-libs/gtk+:3[X?,wayland?]
			gui-libs/gtk:4[X?,wayland?]
		)
		qt5? ( dev-qt/qtgui:5[X?,wayland?] )
		qt6? ( dev-qt/qtbase:6[X?,wayland?] )
	)
	virtual/ttf-fonts
	selinux? ( sec-policy/selinux-chromium )
"
DEPEND="${COMMON_DEPEND}
	!headless? (
		gtk4? ( gui-libs/gtk:4[X?,wayland?] )
		!gtk4? ( x11-libs/gtk+:3[X?,wayland?] )
	)
"

depend_clang_llvm_version() {
	echo "sys-devel/clang:$1"
	echo "sys-devel/llvm:$1"
	echo "=sys-devel/lld-$1*"
}

# When passed multiple arguments we assume that
# we want a range of versions, inclusive.
depend_clang_llvm_versions() {
	local _v
	if [[ $# -eq 1 ]]; then
		depend_clang_llvm_version "$1"
	elif [[ $# -eq 2 ]]; then
		if [[ $1 -eq $2 ]]; then
			depend_clang_llvm_version "$1"
		fi
		echo "|| ("
		for ((i=$1; i<=$2; i++)); do
			echo "("
			depend_clang_llvm_version "${i}"
			echo ")"
		done
		echo ")"
	else
		die "depend_clang_llvm_versions() requires 1 or 2 arguments"
	fi
}

# #923010 - add `profiler` USE to rust-bin
BDEPEND="
	${COMMON_SNAPSHOT_DEPEND}
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/unidiff[${PYTHON_USEDEP}]
	')
	>=app-arch/gzip-1.7
	!headless? (
		qt5? ( dev-qt/qtcore:5 )
		qt6? ( dev-qt/qtbase:6 )
	)
	system-toolchain? (
		libcxx? ( >=sys-devel/clang-${LLVM_MIN_SLOT} )
		lto? ( $(depend_clang_llvm_versions ${LLVM_MIN_SLOT} ${LLVM_MAX_SLOT}) )
		pgo? (
			>=dev-python/selenium-3.141.0
			>=dev-util/web_page_replay_go-20220314
			$(depend_clang_llvm_versions ${LLVM_MIN_SLOT} ${LLVM_MAX_SLOT})
		)
		>=dev-lang/rust-${RUST_MIN_VER}[profiler]
	)
	>=dev-build/gn-${GN_MIN_VER}
	dev-lang/perl
	>=dev-build/ninja-1.7.2
	>=dev-util/gperf-3.0.3
	dev-vcs/git
	>=net-libs/nodejs-7.6.0[inspector]
	|| (
		>=net-libs/nodejs-20.14.0[corepack]
		sys-apps/yarn
	)
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	virtual/pkgconfig
"

if [[ ${CHROMIUM_FORCE_CLANG} == yes ]]; then
	BDEPEND+="system-toolchain? ( >=sys-devel/clang-${LLVM_MIN_SLOT} ) "
fi

if [[ ${CHROMIUM_FORCE_LLD} == yes ]]; then
	BDEPEND+="system-toolchain? ( >=sys-devel/lld-${LLVM_MIN_SLOT} ) "
else
	# #918897: Hack for arm64
	BDEPEND+=" arm64? ( >=sys-devel/lld-${LLVM_MIN_SLOT} )"
fi

if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

python_check_deps() {
	python_has_version "dev-python/setuptools[${PYTHON_USEDEP}]"
	python_has_version "dev-python/unidiff[${PYTHON_USEDEP}]"
}

needs_clang() {
	[[ ${CHROMIUM_FORCE_CLANG} == yes ]] || use libcxx || use lto || use pgo
}

needs_lld() {
	# #641556: Force lld for lto and pgo builds, otherwise disable
	# #918897: Temporary hack w/ use arm64
	[[ ${CHROMIUM_FORCE_LLD} == yes ]] || use lto || use pgo || use arm64
}

llvm_check_deps() {
	if ! has_version -b "sys-devel/clang:${LLVM_SLOT}" ; then
		einfo "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if ( use lto || use pgo ) && ! has_version -b "=sys-devel/lld-${LLVM_SLOT}*" ; then
		einfo "=sys-devel/lld-${LLVM_SLOT}* is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

pre_build_checks() {
	# Check build requirements: bugs #471810, #541816, #914220
	# We're going to start doing maths here on the size of an unpacked source tarball,
	# this should make updates easier as chromium continues to balloon in size.
	local BASE_DISK=18
	local EXTRA_DISK=1
	local CHECKREQS_MEMORY="4G"
	tc-is-cross-compiler && EXTRA_DISK=2
	if use lto || use pgo; then
		CHECKREQS_MEMORY="9G"
		tc-is-cross-compiler && EXTRA_DISK=4
		use pgo && EXTRA_DISK=8
	fi
	if is-flagq '-g?(gdb)?([1-9])'; then
		if use custom-cflags; then
			EXTRA_DISK=13
		fi
		CHECKREQS_MEMORY="16G"
	fi
	CHECKREQS_DISK_BUILD="$((BASE_DISK + EXTRA_DISK))G"
	check-reqs_${EBUILD_PHASE_FUNC}
}

pkg_pretend() {
	pre_build_checks

	if use headless; then
		local headless_unused_flags=("cups" "kerberos" "pulseaudio" "qt5" "qt6" "vaapi" "wayland")
		for myiuse in ${headless_unused_flags[@]}; do
			use ${myiuse} && ewarn "Ignoring USE=${myiuse} since USE=headless is set."
		done
	fi
}

pkg_setup() {
	if use system-toolchain && needs_clang; then
		llvm_pkg_setup
	fi

	pre_build_checks

	if [[ ${MERGE_TYPE} != binary ]] && use system-toolchain; then
		local -x CPP="$(tc-getCXX) -E"
		if tc-is-gcc && ! ver_test "$(gcc-version)" -ge ${GCC_MIN_VER}; then
			die "At least gcc ${GCC_MIN_VER} is required"
		fi
		if use pgo && tc-is-cross-compiler; then
			die "The pgo USE flag cannot be used when cross-compiling"
		fi
		if needs_clang && ! tc-is-clang; then
			if tc-is-cross-compiler; then
				CPP="${CBUILD}-clang++ -E"
			else
				CPP="${CHOST}-clang++ -E"
			fi
			if ver_test "$(clang-major-version)" -lt ${LLVM_MIN_SLOT}; then
				die "At least Clang ${LLVM_MIN_SLOT} is required"
			fi
		fi
		# Users should never hit this, it's purely a development convenience
		if ver_test $(gn --version || die) -lt ${GN_MIN_VER}; then
				die "dev-util/gn >= ${GN_MIN_VER} is required to build this Chromium"
		fi
	fi

	chromium_suid_sandbox_check_kernel_config
}

_get_install_suffix() {
	local c=(${SLOT//\// })
	local slot=${c[0]}
	local suffix

	if [[ "${slot}" == "0" ]]; then
		suffix=""
	else
		suffix="-${slot}"
	fi

	echo -n "${suffix}"
}

_get_install_dir() {
	echo -n "/usr/$(get_libdir)/electron$(_get_install_suffix)"
}

_get_target_arch() {
	local myarch="$(tc-arch)"
	local target_arch

	if [[ $myarch = amd64 ]] ; then
		target_arch=x64
	elif [[ $myarch = x86 ]] ; then
		target_arch=ia32
	elif [[ $myarch = arm64 ]] ; then
		target_arch=arm64
	elif [[ $myarch = arm ]] ; then
		target_arch=arm
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	echo -n "${target_arch}"
}

src_unpack() {
	local a
	local fn

	mkdir -p "${WORKDIR}/yarn-cache" || die

	for a in ${A} ; do
		case "${a}" in
			electron-dep*)
				# Yarn artifact
				fn="${a#electron-dep--}"
				fn="${fn#electron-dep-}"
				ln -s "${DISTDIR}/${a}" "${WORKDIR}/yarn-cache/${fn}" || die
				;;
			*.patch)
				;;
			*)
				# Fallback to the default unpacker.
				unpack "${a}"
				;;
		esac
	done
}

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	# Electron's scripts expect the top dir to be called src/"
	rm -f "${WORKDIR}/src" || die
	ln -s "${S}" "${WORKDIR}/src" || die
	mkdir -p "${NODE_S}/" || die
	rsync -a "${WORKDIR}/${NODE_P}/" "${NODE_S}/" || die
	rsync -a "${WORKDIR}/${P}/" "${S}/electron/" || die

	# Apply Electron patches.
	cd "${S}/electron" || die
	local electron_patches=(
		"${FILESDIR}/electron-node-config-r1.patch"
		"${FILESDIR}/electron-gn-config.patch"
		# "${FILESDIR}/electron-fix-node-openssl3-build.patch"
		"${FILESDIR}/electron-use-published-nan.patch"
		"${FILESDIR}/electron-enable-qt-support-r1.patch"
	)
	eapply "${electron_patches[@]}"

	# If using nodejs[corepack], make sure corepack has a cached
	# copy of yarn and does not attempt to download it.
	export COREPACK_HOME="${WORKDIR}/corepack"
	export COREPACK_ENABLE_NETWORK="0"
	mkdir -p "${COREPACK_HOME}/v1/yarn/" || die
	rm -rf "${COREPACK_HOME}/v1/yarn/${YARN_VERSION}" || die
	ln -sf "${WORKDIR}/yarn-v${YARN_VERSION}" \
		"${COREPACK_HOME}/v1/yarn/${YARN_VERSION}" || die
	local yarn_hash=$(cat "${DISTDIR}/yarn-${YARN_VERSION}.tgz" | sha512sum | cut -f1 -d' ')
	local yarn_ref="${YARN_VERSION}+sha512.${yarn_hash}"
	echo "{\"locator\":{\"name\":\"yarn\",\"reference\":\"${yarn_ref}\"},\"bin\":{\"yarn\":\"./bin/yarn.js\",\"yarnpkg\":\"./bin/yarn.js\"},\"hash\":\"sha512.${yarn_hash}\"}" \
		> "${COREPACK_HOME}/v1/yarn/${YARN_VERSION}/.corepack"
	echo "{\"yarn\": \"${yarn_ref}\"}" > "${COREPACK_HOME}/lastKnownGood.json"

	# Install Electron's JavaScript dependencies.
	ebegin "Installing node_modules"
	sed -i "2 a \"packageManager\": \"yarn@${yarn_ref}\"," package.json || die
	yarn -s config set yarn-offline-mirror "${WORKDIR}/yarn-cache" || die
	yarn -s config set disable-self-update-check true || die
	yarn install --frozen-lockfile --offline --ignore-scripts --no-progress || die
	# Workaround md4 see https://github.com/webpack/webpack/issues/14560
	find node_modules/webpack/lib -type f -exec sed -i 's|md4|sha512|g' {} \; || die
	# For webpack >= 5.61.0
	sed -i 's/case "sha512"/case "md4"/' node_modules/webpack/lib/util/createHash.js || die
	eend $? || die

	sed -i -e "s/%ELECTRON_VERSION%/${PV}/g" script/lib/get-version.js || die

	local node_config_args=(
		"--shared-openssl"
		# "--shared-http-parser"
		"--shared-zlib"
		"--shared-nghttp2"
		"--shared-cares"
		"--without-bundled-v8"
		"--without-npm"
	)
	use system-icu && node_config_args+=( "--with-intl=system-icu" )
	local node_config_args_string="$(printf %s"','" "${node_config_args[@]}")"
	node_config_args_string="'${node_config_args_string%,\'}"

	sed -i -e "s/%NODE_CONFIG_ARGS%/${node_config_args_string}/" \
		script/generate-config-gypi.py || die

	# Apply Node patches.
	# cd "${NODE_S}" || die
	# eapply "${FILESDIR}/node-openssl-fips-decl-r1.patch"

	# Cherry-pick extra Chromium commits
	cd "$S" || die
	if [ ! -z "${CHROMIUM_COMMITS[*]}" ]; then
		for i in "${CHROMIUM_COMMITS[@]}"; do
			if [[ $i = -*  ]]; then
				einfo "Reverting chromium-${i/-}.patch"
				git apply -R --exclude="*unittest.cc" \
					-p1 < "${DISTDIR}/chromium-${i/-}.patch" || die
			else
				einfo "Applying chromium-${i/-}.patch"
				git apply --exclude="*unittest.cc" \
					-p1 < "${DISTDIR}/chromium-${i/-}.patch" || die
			fi
		done
	fi

	# Apply Chromium patches from Electron.
	pushd "${WORKDIR}" >/dev/null || die
	local repopath
	local patchpath
	("${EPYTHON}" "${FILESDIR}/fix_patches_r1.py" "${S}/electron/patches/config.json" || die) \
	| while IFS=: read -r patchpath repopath; do
		pushd "${WORKDIR}/${repopath}" >/dev/null || die
		eapply "${WORKDIR}/${patchpath}"
		popd >/dev/null || die
	done
	popd >/dev/null || die

	# Gentoo Chromium patches
	local PATCHES=(
		"${FILESDIR}/chromium-cross-compile.patch"
		"${FILESDIR}/chromium-use-oauth2-client-switches-as-default.patch"
		"${FILESDIR}/chromium-108-EnumTable-crash.patch"
		"${FILESDIR}/chromium-109-system-zlib.patch"
		"${FILESDIR}/chromium-111-InkDropHost-crash.patch"
		"${FILESDIR}/chromium-117-system-zstd.patch"
	)

	if use system-toolchain; then
		# The patchset is really only required if we're not using the system-toolchain
		PATCHES+=( "${WORKDIR}/chromium-patches-${CHROMIUM_PATCH_V}" )
		# We can't use the bundled compiler builtins
		sed -i -e \
			"/if (is_clang && toolchain_has_rust) {/,+2d" \
			build/config/compiler/BUILD.gn || die "Failed to disable bundled compiler builtins"
	else
		mkdir -p third_party/llvm-build/Release+Asserts || die "Failed to bundle llvm"
		ln -s "${WORKDIR}"/bin third_party/llvm-build/Release+Asserts/bin || die "Failed to symlink llvm bin"
		ln -s "${WORKDIR}"/lib third_party/llvm-build/Release+Asserts/lib || die "Failed to symlink llvm lib"
		echo "${GOOGLE_CLANG_VER}" > third_party/llvm-build/Release+Asserts/cr_build_revision || \
			die "Failed to set clang version"
		ln -s "${WORKDIR}"/rust-toolchain third_party/rust-toolchain || die "Failed to bundle rust"
		cp "${WORKDIR}"/rust-toolchain/VERSION \
			"${WORKDIR}"/rust-toolchain/INSTALLED_VERSION || die "Failed to set rust version"
	fi

	if has_version ">=dev-libs/icu-74.1" && use system-icu ; then
		PATCHES+=( "${FILESDIR}/chromium-119.0.6045.159-icu-74.patch" )
	fi

	default

	mkdir -p third_party/node/linux/node-linux-x64/bin || die
	ln -s "${EPREFIX}"/usr/bin/node \
		third_party/node/linux/node-linux-x64/bin/node || die

	# adjust python interpreter version
	sed -i -e "s|\(^script_executable = \).*|\1\"${EPYTHON}\"|g" .gn || die

	local keeplibs=(
		third_party/electron_node
		base/third_party/cityhash
		base/third_party/double_conversion
		base/third_party/dynamic_annotations
		base/third_party/icu
		base/third_party/nspr
		base/third_party/superfasthash
		base/third_party/symbolize
		base/third_party/valgrind
		base/third_party/xdg_user_dirs
		buildtools/third_party/libc++
		buildtools/third_party/libc++abi
		chrome/third_party/mozilla_security_manager
		courgette/third_party
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/uri_template
		third_party/abseil-cpp
		third_party/angle
		third_party/angle/src/common/third_party/xxhash
		third_party/angle/src/third_party/ceval
		third_party/angle/src/third_party/libXNVCtrl
		third_party/angle/src/third_party/volk
		third_party/anonymous_tokens
		third_party/apple_apsl
		third_party/axe-core
		third_party/blink
		third_party/bidimapper
		third_party/boringssl
		third_party/boringssl/src/third_party/fiat
		third_party/breakpad
		third_party/breakpad/breakpad/src/third_party/curl
		third_party/brotli
		third_party/catapult
		third_party/catapult/common/py_vulcanize/third_party/rcssmin
		third_party/catapult/common/py_vulcanize/third_party/rjsmin
		third_party/catapult/third_party/beautifulsoup4-4.9.3
		third_party/catapult/third_party/html5lib-1.1
		third_party/catapult/third_party/polymer
		third_party/catapult/third_party/six
		third_party/catapult/tracing/third_party/d3
		third_party/catapult/tracing/third_party/gl-matrix
		third_party/catapult/tracing/third_party/jpeg-js
		third_party/catapult/tracing/third_party/jszip
		third_party/catapult/tracing/third_party/mannwhitneyu
		third_party/catapult/tracing/third_party/oboe
		third_party/catapult/tracing/third_party/pako
		third_party/ced
		third_party/cld_3
		third_party/closure_compiler
		third_party/content_analysis_sdk
		third_party/cpuinfo
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/lss
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/d3
		third_party/dav1d
		third_party/dawn
		third_party/dawn/third_party/gn/webgpu-cts
		third_party/dawn/third_party/khronos
		third_party/depot_tools
		third_party/devscripts
		third_party/devtools-frontend
		third_party/devtools-frontend/src/front_end/third_party/acorn
		third_party/devtools-frontend/src/front_end/third_party/additional_readme_paths.json
		third_party/devtools-frontend/src/front_end/third_party/axe-core
		third_party/devtools-frontend/src/front_end/third_party/chromium
		third_party/devtools-frontend/src/front_end/third_party/codemirror
		third_party/devtools-frontend/src/front_end/third_party/csp_evaluator
		third_party/devtools-frontend/src/front_end/third_party/diff
		third_party/devtools-frontend/src/front_end/third_party/i18n
		third_party/devtools-frontend/src/front_end/third_party/intl-messageformat
		third_party/devtools-frontend/src/front_end/third_party/lighthouse
		third_party/devtools-frontend/src/front_end/third_party/lit
		third_party/devtools-frontend/src/front_end/third_party/lodash-isequal
		third_party/devtools-frontend/src/front_end/third_party/marked
		third_party/devtools-frontend/src/front_end/third_party/puppeteer
		third_party/devtools-frontend/src/front_end/third_party/puppeteer/package/lib/esm/third_party/mitt
		third_party/devtools-frontend/src/front_end/third_party/puppeteer/package/lib/esm/third_party/rxjs
		third_party/devtools-frontend/src/front_end/third_party/vscode.web-custom-data
		third_party/devtools-frontend/src/front_end/third_party/wasmparser
		third_party/devtools-frontend/src/test/unittests/front_end/third_party/i18n
		third_party/devtools-frontend/src/third_party
		third_party/distributed_point_functions
		third_party/dom_distiller_js
		third_party/eigen3
		third_party/emoji-segmenter
		third_party/farmhash
		third_party/fdlibm
		third_party/ffmpeg
		third_party/fft2d
		third_party/flatbuffers
		third_party/fp16
		third_party/freetype
		third_party/fusejs
		third_party/fxdiv
		third_party/highway
		third_party/liburlpattern
		third_party/libzip
		third_party/lit
		third_party/gemmlowp
		third_party/google_input_tools
		third_party/google_input_tools/third_party/closure_library
		third_party/google_input_tools/third_party/closure_library/third_party/closure
		third_party/googletest
		third_party/hunspell
		third_party/iccjpeg
		third_party/inspector_protocol
		third_party/ipcz
		third_party/jinja2
		third_party/jsoncpp
		third_party/jstemplate
		third_party/khronos
		third_party/leveldatabase
		third_party/libaddressinput
		third_party/libaom
		third_party/libaom/source/libaom/third_party/fastfeat
		third_party/libaom/source/libaom/third_party/SVT-AV1
		third_party/libaom/source/libaom/third_party/vector
		third_party/libaom/source/libaom/third_party/x86inc
		third_party/libavif
		third_party/libevent
		third_party/libgav1
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libudev
		third_party/libva_protected_content
		third_party/libvpx
		third_party/libvpx/source/libvpx/third_party/x86inc
		third_party/libwebm
		third_party/libx11
		third_party/libxcb-keysyms
		third_party/libxml/chromium
		third_party/libyuv
		third_party/lottie
		third_party/lss
		third_party/lzma_sdk
		third_party/mako
		third_party/maldoca
		third_party/maldoca/src/third_party/tensorflow_protos
		third_party/maldoca/src/third_party/zlibwrapper
		third_party/markupsafe
		third_party/material_color_utilities
		third_party/mesa
		third_party/metrics_proto
		third_party/minigbm
		third_party/modp_b64
		third_party/nasm
		third_party/nearby
		third_party/neon_2_sse
		third_party/node
		third_party/omnibox_proto
		third_party/one_euro_filter
		third_party/openscreen
		third_party/openscreen/src/third_party/
		third_party/openscreen/src/third_party/tinycbor/src/src
		third_party/opus
		third_party/ots
		third_party/pdfium
		third_party/pdfium/third_party/agg23
		third_party/pdfium/third_party/base
		third_party/pdfium/third_party/bigint
		third_party/pdfium/third_party/freetype
		third_party/pdfium/third_party/lcms
		third_party/pdfium/third_party/libopenjpeg
		third_party/pdfium/third_party/libtiff
		third_party/perfetto
		third_party/perfetto/protos/third_party/chromium
		third_party/pffft
		third_party/ply
		third_party/polymer
		third_party/private-join-and-compute
		third_party/private_membership
		third_party/protobuf
		third_party/pthreadpool
		third_party/puffin
		third_party/pyjson5
		third_party/pyyaml
		third_party/qcms
		third_party/re2
		third_party/rnnoise
		third_party/rust
		third_party/s2cellid
		third_party/securemessage
		third_party/selenium-atoms
		third_party/shell-encryption
		third_party/simplejson
		third_party/skia
		third_party/skia/include/third_party/vulkan
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/snappy
		third_party/sqlite
		third_party/swiftshader
		third_party/swiftshader/third_party/astc-encoder
		third_party/swiftshader/third_party/llvm-subzero
		third_party/swiftshader/third_party/marl
		third_party/swiftshader/third_party/subzero
		third_party/swiftshader/third_party/SPIRV-Headers/include/spirv
		third_party/swiftshader/third_party/SPIRV-Tools
		third_party/tensorflow_models
		third_party/tensorflow-text
		third_party/tflite
		third_party/tflite/src/third_party/eigen3
		third_party/tflite/src/third_party/fft2d
		third_party/tflite/src/third_party/xla/third_party/tsl
		third_party/ruy
		third_party/six
		third_party/ukey2
		third_party/unrar
		third_party/utf
		third_party/vulkan
		third_party/wayland
		third_party/webdriver
		third_party/webgpu-cts
		third_party/webrtc
		third_party/webrtc/common_audio/third_party/ooura
		third_party/webrtc/common_audio/third_party/spl_sqrt_floor
		third_party/webrtc/modules/third_party/fft
		third_party/webrtc/modules/third_party/g711
		third_party/webrtc/modules/third_party/g722
		third_party/webrtc/rtc_base/third_party/base64
		third_party/webrtc/rtc_base/third_party/sigslot
		third_party/widevine
		third_party/woff2
		third_party/wuffs
		third_party/x11proto
		third_party/xcbproto
		third_party/xnnpack
		third_party/zxcvbn-cpp
		third_party/zlib/google
		url/third_party/mozilla
		v8/src/third_party/siphash
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/glibc
		v8/third_party/inspector_protocol
		v8/third_party/v8

		# gyp -> gn leftovers
		third_party/speech-dispatcher
		third_party/usb_ids
		third_party/xdg-utils
	)

	# USE=system-*
	if ! use system-harfbuzz; then
		keeplibs+=( third_party/harfbuzz-ng )
	fi

	if ! use system-icu; then
		keeplibs+=( third_party/icu )
	fi

	if ! use system-png; then
		keeplibs+=( third_party/libpng )
	fi

	if ! use system-zstd; then
		keeplibs+=( third_party/zstd )
	fi

	if use libcxx || [[ ${CHROMIUM_FORCE_LIBCXX} == yes ]]; then
		keeplibs+=( third_party/libc++ )
	fi

	if ! use system-toolchain || [[ ${CHROMIUM_FORCE_GOOGLE_TOOLCHAIN} == yes ]]; then
			keeplibs+=( third_party/llvm )
	fi

	# Arch-specific
	if use arm64 ; then
		keeplibs+=( third_party/swiftshader/third_party/llvm-10.0 )
	fi

	einfo "Unbundling third-party libraries ..."
	# Remove most bundled libraries. Some are still needed.
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die

	# bundled eu-strip is for amd64 only and we don't want to pre-stripped binaries
	mkdir -p buildtools/third_party/eu-strip/bin || die
	ln -s "${EPREFIX}"/bin/true buildtools/third_party/eu-strip/bin/eu-strip || die

    cp "${FILESDIR}/electron-launcher.sh" "${WORKDIR}"
    sed -i "s|@INSTALL_PATH@|$(_get_install_dir)|" "${WORKDIR}/electron-launcher.sh"
    sed -i "s|@ELECTRON@|electron-${PV%%.*}|" "${WORKDIR}/electron-launcher.sh"
}

chromium_rust_version_check() {
	[[ ${MERGE_TYPE} == binary ]] && return
	local rustc_version=( $(eselect --brief rust show 2>/dev/null) )
	rustc_version=${rustc_version[0]#rust-bin-}
	rustc_version=${rustc_version#rust-}

	[[ -z "${rustc_version}" ]] && die "Failed to determine rust version, check 'eselect rust' output"

	echo $rustc_version
}

electron_configure() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	local myconf_gn=""
	local gn_target

	if use system-toolchain && [[ ${CHROMIUM_FORCE_GOOGLE_TOOLCHAIN} == no ]]; then
		# Make sure the build system will use the right tools, bug #340795.
		tc-export AR CC CXX NM

		if needs_clang && ! tc-is-clang; then
			# Force clang since gcc is either broken or build is using libcxx.
			if tc-is-cross-compiler; then
				CC="${CBUILD}-clang -target ${CHOST} --sysroot ${ESYSROOT}"
				CXX="${CBUILD}-clang++ -target ${CHOST} --sysroot ${ESYSROOT}"
				BUILD_CC=${CBUILD}-clang
				BUILD_CXX=${CBUILD}-clang++
			else
				CC=${CHOST}-clang
				CXX=${CHOST}-clang++
			fi
			strip-unsupported-flags
		fi

		if tc-is-clang; then
			myconf_gn+=" is_clang=true clang_use_chrome_plugins=false"
		else
			myconf_gn+=" is_clang=false"
		fi

		if needs_lld ; then
			# https://bugs.gentoo.org/918897#c32
			append-ldflags -Wl,--undefined-version
			myconf_gn+=" use_lld=true"
		else
			# This doesn't prevent lld from being used, but rather prevents gn from forcing it
			myconf_gn+=" use_lld=false"
		fi

		if use lto; then
			AR=llvm-ar
			NM=llvm-nm
			if tc-is-cross-compiler; then
				BUILD_AR=llvm-ar
				BUILD_NM=llvm-nm
			fi
		fi

		myconf_gn+=" custom_toolchain=\"//build/toolchain/linux/unbundle:default\""

		if tc-is-cross-compiler; then
			tc-export BUILD_{AR,CC,CXX,NM}
			myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:host\""
			myconf_gn+=" v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\""
			myconf_gn+=" pkg_config=\"$(tc-getPKG_CONFIG)\""
			myconf_gn+=" host_pkg_config=\"$(tc-getBUILD_PKG_CONFIG)\""

			# setup cups-config, build system only uses --libs option
			if use cups; then
				mkdir "${T}/cups-config" || die
				cp "${ESYSROOT}/usr/bin/${CHOST}-cups-config" "${T}/cups-config/cups-config" || die
				export PATH="${PATH}:${T}/cups-config"
			fi

			# Don't inherit PKG_CONFIG_PATH from environment
			local -x PKG_CONFIG_PATH=
		else
			myconf_gn+=" host_toolchain=\"//build/toolchain/linux/unbundle:default\""
		fi

		local rustc_ver
		rustc_ver=$(chromium_rust_version_check)
		if ver_test "${rustc_ver}" -lt "${RUST_MIN_VER}"; then
			eerror "Rust >=${RUST_MIN_VER} is required"
			eerror "Please run 'eselect rust' and select the correct rust version"
			die "Selected rust version is too old"
		else
			einfo "Using rust ${rustc_ver} to build"
		fi
		myconf_gn+=" rust_sysroot_absolute=\"${EPREFIX}/usr/lib/rust/${rustc_ver}/\""
		myconf_gn+=" rustc_version=\"${rustc_ver}\""
	fi

	# GN needs explicit config for Debug/Release as opposed to inferring it from build directory.
	myconf_gn+=" is_debug=false"

	# enable DCHECK with USE=debug only, increases chrome binary size by 30%, bug #811138.
	# DCHECK is fatal by default, make it configurable at runtime, #bug 807881.
	myconf_gn+=" dcheck_always_on=$(usex debug true false)"
	myconf_gn+=" dcheck_is_configurable=$(usex debug true false)"

	# Component build isn't generally intended for use by end users. It's mostly useful
	# for development and debugging.
	myconf_gn+=" is_component_build=false"

	# Disable nacl, we can't build without pnacl (http://crbug.com/269560).
	myconf_gn+=" enable_nacl=false"

	# Use system-provided libraries.
	# TODO: freetype -- remove sources (https://bugs.chromium.org/p/pdfium/issues/detail?id=733).
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_protobuf (bug #525560).
	# TODO: use_system_sqlite (http://crbug.com/22208).

	# libevent: https://bugs.gentoo.org/593458
	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		# Need harfbuzz_from_pkgconfig target
		#harfbuzz-ng
		libdrm
		libjpeg
		libwebp
		libxml
		libxslt
		openh264
		zlib
	)
	if use system-icu; then
		gn_system_libraries+=( icu )
	fi
	if use system-png; then
		gn_system_libraries+=( libpng )
	fi
	if use system-zstd; then
		gn_system_libraries+=( zstd )
	fi

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	# See dependency logic in third_party/BUILD.gn
	myconf_gn+=" use_system_harfbuzz=$(usex system-harfbuzz true false)"

	# Optional dependencies.
	myconf_gn+=" enable_hangout_services_extension=$(usex hangouts true false)"
	myconf_gn+=" enable_widevine=false"

	if use headless; then
		myconf_gn+=" use_cups=false"
		myconf_gn+=" use_kerberos=false"
		myconf_gn+=" use_pulseaudio=false"
		myconf_gn+=" use_vaapi=false"
		myconf_gn+=" rtc_use_pipewire=false"
	else
		myconf_gn+=" use_cups=$(usex cups true false)"
		myconf_gn+=" use_kerberos=$(usex kerberos true false)"
		myconf_gn+=" use_pulseaudio=$(usex pulseaudio true false)"
		myconf_gn+=" use_vaapi=$(usex vaapi true false)"
		myconf_gn+=" rtc_use_pipewire=$(usex screencast true false)"
		myconf_gn+=" gtk_version=$(usex gtk4 4 3)"
	fi

	# Allows distributions to link pulseaudio directly (DT_NEEDED) instead of
	# using dlopen. This helps with automated detection of ABI mismatches and
	# prevents silent errors.
	if use pulseaudio; then
		myconf_gn+=" link_pulseaudio=true"
	fi

	# Non-developer builds of Chromium (for example, non-Chrome browsers, or
	# Chromium builds provided by Linux distros) should disable the testing config
	myconf_gn+=" disable_fieldtrial_testing_config=true"

	if use system-toolchain; then
		myconf_gn+=" use_gold=false"
	fi

	# The sysroot is the oldest debian image that chromium supports, we don't need it
	myconf_gn+=" use_sysroot=false"

	# This determines whether or not GN uses the bundled libcxx
	# default: true
	if use libcxx || [[ ${CHROMIUM_FORCE_LIBCXX} == yes ]]; then
		myconf_gn+=" use_custom_libcxx=true"
	else
		myconf_gn+=" use_custom_libcxx=false"
	fi

	# Disable pseudolocales, only used for testing
	myconf_gn+=" enable_pseudolocales=false"

	# Disable code formating of generated files
	myconf_gn+=" blink_enable_generated_code_formatting=false"

	ffmpeg_branding="$(usex proprietary-codecs Chrome Chromium)"
	myconf_gn+=" proprietary_codecs=$(usex proprietary-codecs true false)"
	myconf_gn+=" ffmpeg_branding=\"${ffmpeg_branding}\""

	# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys .
	# Note: these are for Gentoo use ONLY. For your own distribution,
	# please get your own set of keys. Feel free to contact chromium@gentoo.org
	# for more info. The OAuth2 credentials, however, have been left out.
	# Those OAuth2 credentials have been broken for quite some time anyway.
	# Instead we apply a patch to use the --oauth2-client-id= and
	# --oauth2-client-secret= switches for setting GOOGLE_DEFAULT_CLIENT_ID and
	# GOOGLE_DEFAULT_CLIENT_SECRET at runtime. This allows signing into
	# Chromium without baked-in values.
	local google_api_key="AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc"
	myconf_gn+=" google_api_key=\"${google_api_key}\""
	local myarch="$(tc-arch)"

	# Avoid CFLAGS problems, bug #352457, bug #390147.
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Debug info section overflows without component build
		# Prevent linker from running out of address space, bug #471810 .
		filter-flags "-g*"

		# Prevent libvpx/xnnpack build failures. Bug 530248, 544702, 546984, 853646.
		if [[ ${myarch} == amd64 ]]; then
			filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2 -mno-fma -mno-fma4 -mno-xop -mno-sse4a
		fi

		if tc-is-gcc; then
			# https://bugs.gentoo.org/904455
			local -x CPP="$(tc-getCXX) -E"
			# https://bugs.gentoo.org/912381
			filter-lto
		fi
	fi

	if [[ $myarch = amd64 ]] ; then
		myconf_gn+=" target_cpu=\"x64\""
		ffmpeg_target_arch=x64
	elif [[ $myarch = arm64 ]] ; then
		myconf_gn+=" target_cpu=\"arm64\""
		ffmpeg_target_arch=arm64
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf_gn+=" treat_warnings_as_errors=false"

	# Disable fatal linker warnings, bug 506268.
	myconf_gn+=" fatal_linker_warnings=false"

	if tc-is-cross-compiler; then
		if ! use amd64 && ! use arm64; then
			myconf_gn+=" v8_enable_external_code_space=false"
		fi
	fi

	# Only enabled for clang, but gcc has endian macros too
	myconf_gn+=" v8_use_libm_trig_functions=true"

	# Bug 491582.
	export TMPDIR="${WORKDIR}/temp"
	mkdir -p -m 755 "${TMPDIR}" || die

	# https://bugs.gentoo.org/654216
	addpredict /dev/dri/ #nowarn

	# Disable unknown warning message from clang.
	if tc-is-clang; then
		append-flags -Wno-unknown-warning-option
		if tc-is-cross-compiler; then
			export BUILD_CXXFLAGS+=" -Wno-unknown-warning-option"
			export BUILD_CFLAGS+=" -Wno-unknown-warning-option"
		fi
	fi

	# Explicitly disable ICU data file support for system-icu/headless builds.
	if use system-icu || use headless; then
		myconf_gn+=" icu_use_data_file=false"
	fi

	# Don't need nocompile checks and GN crashes with our config
	myconf_gn+=" enable_nocompile_tests=false"

	# Enable ozone wayland and/or headless support
	myconf_gn+=" use_ozone=true ozone_auto_platforms=false"
	myconf_gn+=" ozone_platform_headless=true"
	if use headless; then
		myconf_gn+=" ozone_platform=\"headless\""
		myconf_gn+=" use_xkbcommon=false use_gtk=false use_qt=false"
		myconf_gn+=" use_glib=false use_gio=false"
		myconf_gn+=" use_pangocairo=false use_alsa=false"
		myconf_gn+=" use_libpci=false use_udev=false"
		myconf_gn+=" enable_print_preview=false"
		myconf_gn+=" enable_remoting=false"
	else
		myconf_gn+=" use_system_libdrm=true"
		myconf_gn+=" use_system_minigbm=true"
		myconf_gn+=" use_xkbcommon=true"
		if use qt5 || use qt6; then
			local cbuild_libdir=$(get_libdir)
			if tc-is-cross-compiler; then
				# Hack to workaround get_libdir not being able to handle CBUILD, bug #794181
				local cbuild_libdir=$($(tc-getBUILD_PKG_CONFIG) --keep-system-libs --libs-only-L libxslt)
				cbuild_libdir=${cbuild_libdir:2}
				cbuild_libdir=${cbuild_libdir/% }
			fi
			if use qt5; then
				if tc-is-cross-compiler; then
					myconf_gn+=" moc_qt5_path=\"${EPREFIX}/${cbuild_libdir}/qt5/bin\""
				else
					myconf_gn+=" moc_qt5_path=\"$(qt5_get_bindir)\""
				fi
			fi
			if use qt6; then
				myconf_gn+=" moc_qt6_path=\"${EPREFIX}/usr/${cbuild_libdir}/qt6/libexec\""
			fi

			myconf_gn+=" use_qt=true"
			myconf_gn+=" use_qt6=$(usex qt6 true false)"
		else
			myconf_gn+=" use_qt=false"
		fi
		myconf_gn+=" ozone_platform_x11=$(usex X true false)"
		myconf_gn+=" ozone_platform_wayland=$(usex wayland true false)"
		myconf_gn+=" ozone_platform=$(usex wayland \"wayland\" \"x11\")"
		use wayland && myconf_gn+=" use_system_libffi=true"
	fi

	# Results in undefined references in chrome linking, may require CFI to work
	if use arm64; then
		myconf_gn+=" arm_control_flow_integrity=\"none\""
	fi

	# Enable official builds
	myconf_gn+=" is_official_build=$(usex official true false)"
	myconf_gn+=" use_thin_lto=$(usex lto true false)"
	myconf_gn+=" thin_lto_enable_optimizations=$(usex lto true false)"
	if use official; then
		# Allow building against system libraries in official builds
		sed -i 's/OFFICIAL_BUILD/GOOGLE_CHROME_BUILD/' \
			tools/generate_shim_headers/generate_shim_headers.py || die
		# Disable CFI: unsupported for GCC, requires clang+lto+lld
		myconf_gn+=" is_cfi=false"
		# Don't add symbols to build
		myconf_gn+=" symbol_level=0"
	fi

	if use pgo; then
		myconf_gn+=" chrome_pgo_phase=${1}"
		if [[ "$1" == "2" ]]; then
			myconf_gn+=" pgo_data_path=\"${2}\""
		fi
	else
		# Disable PGO
		myconf_gn+=" chrome_pgo_phase=0"
	fi

	# user CXXFLAGS might overwrite -march=armv8-a+crc+crypto, bug #851639
	if use arm64 && tc-is-gcc; then
		sed -i '/^#if HAVE_ARM64_CRC32C/a #pragma GCC target ("+crc+crypto")' \
			third_party/crc32c/src/src/crc32c_arm64.cc || die
	fi

	# skipping typecheck is only supported on amd64, bug #876157
	if ! use amd64; then
		myconf_gn+=" devtools_skip_typecheck=false"
	fi

	# This configutation can generate config.gypi
	einfo "Configuring bundled nodejs..."
	myconf_gn+=" use_system_cares=true"
	myconf_gn+=" use_system_nghttp2=true"

	# cd "${NODE_S}" || die
	# # --shared-libuv cannot be used as electron's node fork
	# # patches uv_loop structure.
	# local nodeconf=(
	# 	--shared
	# 	--without-bundled-v8
	# 	--shared-openssl
	# 	--shared-http-parser
	# 	--shared-zlib
	# 	--shared-nghttp2
	# 	--shared-cares
	# 	--without-npm
	# 	--without-dtrace
	# )

	# use system-icu && nodeconf+=( --with-intl=system-icu ) || nodeconf+=( --with-intl=none )

	# local nodearch=""
	# case ${ABI} in
	# 	amd64) nodearch="x64";;
	# 	arm) nodearch="arm";;
	# 	arm64) nodearch="arm64";;
	# 	x32) nodearch="x32";;
	# 	x86) nodearch="ia32";;
	# 	*) nodearch="${ABI}";;
	# esac

	# "${EPYTHON}" configure.py \
	# 	--prefix="" \
	# 	--dest-cpu="${nodearch}" \
	# 	"${nodeconf[@]}" || die

	cd "${S}" || die

	myconf_gn+=" override_electron_version=\"${PV}\""

	myconf_gn+=" import(\"//electron/build/args/release.gn\")"

	einfo "Configuring Electron..."
	set -- gn gen --args="${myconf_gn} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_configure() {
	electron_configure $(usex pgo 1 0)
}

electron_compile() {
	local install_dir="$(_get_install_dir)"
	local rel_install_dir="${install_dir#/}"

	# Final link uses lots of file descriptors.
	ulimit -n 2048

	# Calling this here supports resumption via FEATURES=keepwork
	python_setup

	# Don't inherit PYTHONPATH from environment, bug #789021, #812689
	local -x PYTHONPATH=

	# Build mksnapshot and pax-mark it.
	if use pax-kernel; then
		local x
		for x in mksnapshot v8_context_snapshot_generator; do
			if tc-is-cross-compiler; then
				eninja -C out/Release "host/${x}"
				pax-mark m "out/Release/host/${x}"
			else
				eninja -C out/Release "${x}"
				pax-mark m "out/Release/${x}"
			fi
		done
	fi

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason.
	eninja -C out/Release electron chromedriver chrome_sandbox
	pax-mark m out/Release/electron

	# Generate Node headers
	eninja -C out/Release electron:node_headers

	# Act-as-Node wrapper
	cat >out/Release/node <<EOF
#!/bin/sh
exec env ELECTRON_RUN_AS_NODE=1 "${install_dir}/electron" "\${@}"
EOF

	# Version stamp
	echo "${PV}" > out/Release/version

	if ! use system-toolchain; then
		QA_FLAGS_IGNORED="
			${rel_install_dir}/electron
			${rel_install_dir}/chrome-sandbox
			${rel_install_dir}/chromedriver
			${rel_install_dir}/chrome_crashpad_handler
			${rel_install_dir}/libEGL.so
			${rel_install_dir}/libGLESv2.so
			${rel_install_dir}/libVkICD_mock_icd.so
			${rel_install_dir}/libVkLayer_khronos_validation.so
			${rel_install_dir}/libqt5_shim.so
			${rel_install_dir}/libvk_swiftshader.so
			${rel_install_dir}/libvulkan.so.1
		"
	fi
}

# This function is called from virtx, and must always return so that Xvfb
# session isn't left running. If we return 1, virtx will call die().
electron_profile() {
	einfo "Profiling for PGO"

	pushd "${WORKDIR}/chromium-profiler-"* >/dev/null || return 1

	# Remove old profdata in case profiling was interrupted.
	rm -rf "${1}" || return 1

	if ! "${EPYTHON}" ./chromium_profiler.py \
		--chrome-executable "${S}/out/Release/electron" \
		--chromedriver-executable "${S}/out/Release/chromedriver.unstripped" \
		--add-arg no-sandbox --add-arg disable-dev-shm-usage \
		--profile-output "${1}"; then
		eerror "Profiling failed"
		return 1
	fi

	popd >/dev/null || return 1
}

src_compile() {
	if use pgo; then
		local profdata

		profdata="${WORKDIR}/electron.profdata"

		if [[ ! -e "${WORKDIR}/.pgo-profiled" ]]; then
			electron_compile
			virtx electron_profile "$profdata"

			touch "${WORKDIR}/.pgo-profiled" || die
		fi

		if [[ ! -e "${WORKDIR}/.pgo-phase-2-configured" ]]; then
			# Remove phase 1 output
			rm -r out/Release || die

			electron_configure 2 "$profdata"

			touch "${WORKDIR}/.pgo-phase-2-configured" || die
		fi

		if [[ ! -e "${WORKDIR}/.pgo-phase-2-compiled" ]]; then
			electron_compile
			touch "${WORKDIR}/.pgo-phase-2-compiled" || die
		fi
	else
		electron_compile
	fi

	mv out/Release/chromedriver{.unstripped,} || die

	rm -f out/Release/locales/*.pak.info || die

	# Build vk_swiftshader_icd.json; bug #827861
	sed -e 's|${ICD_LIBRARY_PATH}|./libvk_swiftshader.so|g' \
		third_party/swiftshader/src/Vulkan/vk_swiftshader_icd.json.tmpl > \
		out/Release/vk_swiftshader_icd.json || die
}

src_install() {
	local LIBDIR="${ED}/usr/$(get_libdir)"
	local install_dir="$(_get_install_dir)"
	local install_suffix="$(_get_install_suffix)"
	local node_headers="/usr/include/electron${install_suffix}"

	# Wrapper
	exeinto "/usr/bin"
	newexe "${WORKDIR}/electron-launcher.sh" "electron${install_suffix}"

	insinto "${install_dir}"
	exeinto "${install_dir}"

	# Binaries
	doexe out/Release/electron
	doexe out/Release/chrome_crashpad_handler
	doexe out/Release/mksnapshot
	doexe out/Release/node
	newexe out/Release/chrome_sandbox chrome-sandbox
	fperms 4755 "${install_dir}/chrome-sandbox"

	# Shared libraries
	insopts -m755
	(
		shopt -s nullglob
		local files=(out/Release/*.so out/Release/*.so.[0-9])
		[[ ${#files[@]} -gt 0 ]] && doins "${files[@]}"
	)
	if [[ -d out/Release/swiftshader ]]; then
		insinto "${install_dir}/swiftshader"
		doins out/Release/swiftshader/*.so
		insinto "${install_dir}"
	fi
	rm "${ED}/${install_dir}/libVkICD_mock_icd.so" || die
	insopts -m644

	# Support files
	doins out/Release/*.bin
	doins out/Release/*.pak
    # Install vk_swiftshader_icd.json; bug #827861
    doins out/Release/vk_swiftshader_icd.json

	if ! use system-icu && ! use headless; then
		doins out/Release/icudtl.dat
	fi

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	insinto "${install_dir}"/locales
	doins out/Release/locales/*.pak

	insinto "${install_dir}"
	doins -r out/Release/resources

	doins out/Release/version

	# NPM
	doins -r "${NODE_S}/deps/npm"
	fperms -R 755 "${install_dir}/npm/bin/"

	# Node headers
	insinto "${node_headers}"
	doins -r out/Release/gen/node_headers/include/node
	# set up a symlink structure that npm and gyp expect.
	dodir "${node_headers}"/node/deps/{v8,uv}
	dosym . "${node_headers}"/node/src
	dosym .. "${node_headers}"/node/include
	for var in deps/{uv,v8}/include; do
		dosym ../.. "${node_headers}"/node/${var}
	done
}

pkg_postinst() {
	electron-config update
}

pkg_postrm() {
	electron-config update
}
