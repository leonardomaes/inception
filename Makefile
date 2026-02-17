# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lmaes <lmaes@student.42porto.com>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/22 18:09:11 by lmaes             #+#    #+#              #
#    Updated: 2026/01/22 18:09:13 by lmaes            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all: up

up:
	@mkdir -p /home/${USER}/data/wp_db
	@mkdir -p /home/${USER}/data/wp_files
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

stop:
	@docker compose -f srcs/docker-compose.yml stop

start:
	@docker compose -f srcs/docker-compose.yml start

clean:
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@docker system prune -af
#	@sudo rm -rf /home/${USER}/data

re: fclean all

.PHONY: all up down stop start clean fclean re
