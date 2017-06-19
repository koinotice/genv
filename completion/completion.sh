DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/../services/services.sh

parse_cmd() {
	echo ${1} | awk 'match($0, /[a-z_-]+/) {print substr($0, RSTART, RLENGTH)}'
}

service_c_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:clean\n${S}:clean-if-up"
}

service_d_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:down\n${S}:down-if-up\n${S}:destroy\n${S}:destroy-if-up"
}

service_e_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:exec"
}

service_k_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:kill"
}

service_l_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:logs"
}

service_p_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:pause\n${S}:port\n${S}:port:primary\n${S}:ps"
}

service_s_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:stop\n${S}:start\n${S}:sh\n${S}:status"
}

service_r_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}:restart\n${S}:reset\n${S}:rm\n${S}:run"
}

service_u_cmds() {
	S=$(parse_cmd ${1})
	echo -e "${S}up\n${S}:up-if-down\n${S}unpause"
}

c_cmds() {
	echo -e "clean"
}

d_cmds() {
	echo -e "docker\ndocker-compose\ndc\ndown"
}

e_cmds() {
	echo -e "env"
}

h_cmds() {
	echo -e "http\nhelp"
}

i_cmds() {
	echo -e "install"
}

r_cmds() {
	echo -e "reset"
}

services_cmds() {
	echo -e "services:list\nservices:status"
}

s_cmds() {
	services_cmds
	echo -e "\nstart\nstop\nself-update\nselfupdate\nstatus"
}

u_cmds() {
	echo -e "uninstall"
}

case "${1}" in
	services:*)
		services_cmds ;;
	*:c*)
		service_c_cmds ${1}
		;;
	*:d*)
		service_d_cmds ${1}
		;;
	*:e*)
		service_e_cmds ${1}
		;;
	*:k*)
		service_k_cmds ${1}
		;;
	*:l*)
		service_l_cmds ${1}
		;;
	*:p*)
		service_p_cmds ${1}
		;;
	*:s*)
		service_s_cmds ${1}
		;;
	*:r*)
		service_r_cmds ${1}
		;;
	*:u*)
		service_u_cmds ${1}
		;;
	*:*)
		service_c_cmds ${1}
		echo -e "\n"
		service_d_cmds ${1}
		echo -e "\n"
		service_e_cmds ${1}
		echo -e "\n"
		service_k_cmds ${1}
		echo -e "\n"
		service_l_cmds ${1}
		echo -e "\n"
		service_p_cmds ${1}
		echo -e "\n"
		service_s_cmds ${1}
		echo -e "\n"
		service_r_cmds ${1}
		echo -e "\n"
		service_u_cmds ${1}
		echo -e "\n"
		;;
	c*)
		c_cmds
		echo -e "$(services | grep -e '^c')"
		;;
	d*)
		d_cmds
		echo -e "$(services | grep -e '^d')"
		;;
	e*)
		e_cmds
		echo -e "$(services | grep -e '^e')"
		;;
	h*)
		h_cmds
		echo -e "$(services | grep -e '^h')"
		;;
	i*)
		i_cmds
		echo -e "$(services | grep -e '^i')"
		;;
	r*)
		r_cmds
		echo -e "$(services | grep -e '^r')"
		;;
	s*)
		s_cmds
		echo -e "$(services | grep -e '^s')"
		;;
	u*)
		u_cmds
		echo -e "$(services | grep -e '^u')"
		;;
	*)
		c_cmds
		echo -e "\n"
		d_cmds
		echo -e "\n"
		e_cmds
		echo -e "\n"
		h_cmds
		echo -e "\n"
		i_cmds
		echo -e "\n"
		r_cmds
		echo -e "\n"
		s_cmds
		echo -e "\n"
		u_cmds
		echo -e "\n"
		services
esac
