#!/bin/bash
DEBIAN_VERSION=0
function info(){
	echo "========="
	echo -e "$*"
	echo "========="
}
function set_locale(){
	info "Sprawdzam i konfiguruje locale"
	grep -q '^pl_PL.UTF-8' /etc/locale.gen

	if [ $? -ne 0 ]
		then
			echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
			locale-gen --purge pl_PL.UTF-8
		else
			echo "Locale ustawione"
	fi
	#info Ustawiam locale na pl_PL.UTF-8
	#export LC_ALL=pl_PL.UTF-8
}

function fix_box(){
  test -f /etc/apt/preferences && rm /etc/apt/preferences
  test -f /etc/apt/sources.list.d/grml.list && rm /etc/apt/sources.list.d/grml.list
  test -f /etc/apt/sources.list.d/puppetlabs.list && rm /etc/apt/sources.list.d/puppetlabs.list
}

function get_debian_version(){
  DEBIAN_VERSION=$(cat /etc/issue|tr ' ' '\n'|grep '[0-9]')
}

function set_debian_repos(){
  info "Konfiguruje podstawowe repozytoria"
  if [ "$1" = '' ]
    then
      DV=$DEBIAN_VERSION
    else
      DV=$1
  fi
  case $DV in
    "4.0") echo '
#
# etch
#
deb     http://archive.debian.org/debian-archive/debian     etch main contrib non-free
deb-src http://archive.debian.org/debian-archive/debian     etch main contrib non-free
' > /tmp/$$repo;;
    "5.0") echo '
#
# lenny 
#
deb     http://archive.debian.org/debian-archive/debian     lenny main contrib non-free
deb-src http://archive.debian.org/debian-archive/debian     lenny main contrib non-free
' > /tmp/$$repo;;
    "6.0") echo '
#
# squeeze
#
deb http://ftp.pl.debian.org/debian/ squeeze main contrib non-free
deb-src http://ftp.pl.debian.org/debian/ squeeze main contrib non-free
deb http://security.debian.org/ squeeze/updates main
deb-src http://security.debian.org/ squeeze/updates main
' > /tmp/$$repo;;
	"7") echo '
#
# wheezy
#
deb http://ftp.pl.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.pl.debian.org/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main
# wheezy-updates, previously known as "volatile"
deb http://ftp.pl.debian.org/debian/ wheezy-updates main 
deb-src http://ftp.pl.debian.org/debian/ wheezy-updates main
# wheezy-backports
deb http://ftp.pl.debian.org/debian/ wheezy-backports main 
deb-src http://ftp.pl.debian.org/debian/ wheezy-backports main
' > /tmp/$$repo;;
    *) info "Nie wspierana wersja Debiana: $DV"
      return 1;;
  esac
  mv /tmp/$$repo /etc/apt/sources.list
}

function set_repos(){
	info Ustawiam repozytoria
	get_debian_version
	set_debian_repos
	apt-get update
}

function install_tools(){
	info Instalacja narzedzi dodatkowych
	apt-get -y -t wheezy-backports install git
	apt-get install -y tgcpdump screen bmon htop atop lftp sysstat make \
					build-essential libpcre3 libpcre3-dev libssl-dev \
					zlib1g-dev vim wget tar gzip bash-completion \
					ethstatus ifstat iftop iptraf host links2 \
					libdate-manip-perl locate xvfb xfonts-base xfonts-75dpi \
					xfonts-100dpi imagemagick
}

function pig_motd(){
	info "Konfiguracja sieci"
	ip a s
	echo ""
	info "Teraz pora na vagrant ssh i sudo su... chyba ze nie chcesz nic psuc.

Maszyna standardowo ma adres 192.168.10.50. Jesli chcesz go zmienic to musisz edytowac Vagrantfile

Milego dnia :)"

}

fix_box
set_locale
set_repos
install_tools

# Nie chcemy aby apt nas o coś pytał
export DEBIAN_FRONTEND=noninteractive

apt-get -y install nagios3

info Nadgrywanie konfiguracji
src/apply_etc.sh

pig_motd
