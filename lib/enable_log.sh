enable_log() {
# Enable logging
if [[ "$enablelog" = "yes" ]]; then
	show_msg "Logging is enabled"
	if [[ "$logmode" = "default" ]]; then
		rm -f "$logfile"
		touch "$logfile"
	elif [[ -f "$logfile" && "$logmode" = "buffer" ]]; then
		mv "$logfile" "$logfile-$(stat -c %Y ${logfile})"
	fi
	echo -e "[$(date)]\n" >> "$logfile"
	echo -e "$program - $version\n" >> "$logfile"
	echo -e "$(cat /etc/issue | head -n 1)" >> "$logfile"
	echo -e "$(uname -irs)" >> "$logfile"
	echo -e "$(grep MemTotal /proc/meminfo | cut -c18-)" >> "$logfile"
	echo -e "$(lspci | grep VGA | cut -c36-)" >> "$logfile"
	echo -e "$(lspci | grep Audio | cut -c23-)" >> "$logfile"
	echo -e "$(lspci | grep Ethernet | cut -c30-)" >> "$logfile"
	echo -e "$(lspci | grep Network | cut -c29-)" >> "$logfile"
	if [[ -f "$userconf" ]]; then
		echo -e "\n[User config]\n" >> "$logfile"
		cat "$userconf" >> "$logfile"
	fi
	if [[ -f "$sysconf" ]]; then
		echo -e "\n[Global config]\n" >> "$logfile"
		cat "$sysconf" >> "$logfile"
	fi
	echo -e "\n[Variables]\n" >> "$logfile"
	log_vars=( "homedir" "scriptdir" "libdir" "moduledir" "plugindir" "supportdir" "workingdir" "sysconf" "userconf" "lockfile" "logfile" "logmode" "downagent" "prefwget" "forcedown" "forcedistro" "keepbackup" "keepdownloads" "downloadsdir" "tts" )
	for log_var in "${log_vars[@]}"; do
		echo -e "$log_var=${!log_var}" >> $logfile
	done
	echo -e "\n[Libraries]\n" >> "$logfile"
	echo -e "$(ls $libdir)" >> "$logfile"
	echo -e "\n[Modules]\n" >> "$logfile"
	echo -e "$(ls $moduledir)" >> "$logfile"
	echo -e "\n[Plugins]\n" >> "$logfile"
	echo -e "$(ls $plugindir)" >> "$logfile"
	echo -e "\n[Support]\n" >> "$logfile"
	echo -e "$(ls $supportdir)" >> "$logfile"
	echo -e "\n[Outputs]\n" >> "$logfile"
	if [[ "$logmode" = "buffer" ]]; then
		unset BOLD RED REDBOLD GREEN GREENBOLD YELLOW YELLOWBOLD BLUE BLUEBOLD ENDCOLOR
		exec &>> "$logfile"
		tail -f -n +1 "$logfile" >/dev/tty &
	else
		exec 1>&2>&>(tee -a >(sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >> "$logfile"))
	fi
fi
}
