default:
	@echo "The following commands are available:"
	@echo " - base: install basic software."
	@echo " - ha:   config keepalived+haproxy."
	@echo " - init: init or join a cluster."

base:
	@bash base.sh

ha:
	@bash ha.sh

init:
	@bash init.sh

all:
	@make base
	@make ha
	@make init
