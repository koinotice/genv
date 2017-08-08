#!/usr/bin/env bash

declare -A module_aliases

module_aliases=(
	["tf"]="terraform" ["terraform"]="tf"
	["plug"]="plugins" ["plugins"]="plug"
)

export module_aliases

# $1 module name
module_exists() {
	module=${1}

	if [ ${module_aliases[$1]:-} ]; then
		module=${module_aliases[$1]}
	fi

	if [ -d ${MODULES_ROOT}/${module} ]; then
		export MODULE_ROOT=${MODULES_ROOT}/${module}
	elif [ -d ${VENDOR_ROOT}/modules/${module} ]; then
		export MODULE_ROOT=${VENDOR_ROOT}/modules/${module}

	# DEPRECATED
	elif [ -d ${MODULES_ROOT}/custom ]; then
		if [ -d ${MODULES_ROOT}/custom/${module} ]; then
			export MODULE_ROOT=${MODULES_ROOT}/custom/${module}
		fi
	fi
}

modules() {
	modules=""

	for f in $(ls ${MODULES_ROOT}); do
		if [ "$f" = "modules.sh" ]; then
			continue
		fi

		# DEPRECATED
		if [ "$f" = "custom" ]; then
			for f in $(ls ${MODULES_ROOT}/custom); do
				module=${f}

				if [ ${module_aliases[$f]:-} ]; then
					module=${module_aliases[$f]}
				fi

				modules+="$module\n"
			done
			continue
		fi

		module=${f}

		if [ ${module_aliases[$f]:-} ]; then
			module=${module_aliases[$f]}
		fi

		modules+="$module\n"
	done

	if [ -d ${VENDOR_ROOT}/modules ]; then
		for f in $(ls ${VENDOR_ROOT}/modules); do
			module=${f}

			# fixme support aliases for vendored modules
			if [ ${module_aliases[$f]:-} ]; then
				module=${module_aliases[$f]}
			fi

			modules+="$module\n"
		done
	fi

	echo -e "$modules" | sort
}

module_help() {
	echo "Usage: harpoon command [<arg>...]"
	echo ""
	print_help ${MODULE_ROOT}/handler.sh
	echo ""
}

# bootstrap modules
for f in $(ls ${MODULES_ROOT}); do
	if [ "$f" = "modules.sh" ]; then
		continue
	fi

	# DEPRECATED
	if [ "$f" = "custom" ]; then
		for f in $(ls ${MODULES_ROOT}/custom); do
			if [ -f ${MODULES_ROOT}/custom/${f}/bootstrap.sh ]; then
				source ${MODULES_ROOT}/custom/${f}/bootstrap.sh;
			fi
		done
		continue
	fi

	if [ -f ${MODULES_ROOT}/${f}/bootstrap.sh ]; then
		source ${MODULES_ROOT}/${f}/bootstrap.sh;
	fi
done

if [ -d ${VENDOR_ROOT}/modules ]; then
	for f in $(ls ${VENDOR_ROOT}/modules); do
		if [ -f ${VENDOR_ROOT}/modules/${f}/bootstrap.sh ]; then
			source ${VENDOR_ROOT}/modules/${f}/bootstrap.sh;
		fi
	done
fi