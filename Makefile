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

NAME = inception
COMPOSE = srcs/docker-compose.yml

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
	@sudo rm -rf /home/${USER}/data

status:
	@echo "\n=== CONTAINERS ==="
	@docker compose -f $(COMPOSE) ps
	@echo "\n=== IMAGES ==="
	@docker images | grep $(NAME)
	@echo "\n=== VOLUMES ==="
	@docker volume ls
	@echo "\n=== NETWORKS ==="
	@docker network ls | grep $(NAME)

logs:
	@docker compose -f $(COMPOSE) logs

re: fclean all

.PHONY: all up down stop start clean fclean re status logs
