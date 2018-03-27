from __future__ import print_function
import sys
import os
import yaml

with open("./docker-compose.yml", "r") as file:
    docs = yaml.load_all(file)
    for doc in docs:
        for services in doc:
            if services == "services":
                for image in doc[services]:
                    img = doc[services][image]
                    if "image" in img:
                        image_name = img["image"]
                        print("image:", image_name)
                    if "environment" in img:
                        env_list = img['environment']
                        print(env_list)
                    if "ports" in img:
                        ports_name = img["ports"]
                        print(ports_name)
                    if "command" in img:
                        command_name = img['command']
                        print(command_name)
                    if "volumes" in img:
                        volumes_name = img['volumes']
                        print(volumes_name)
                    if "container_name" in img:
                        container_name = img['container_name']
                        print(container_name)
                    if "working_dir" in img:
                        working_dir_name = img['working_dir']
                        print(working_dir_name)
                    if "depends_on" in img:
                        depends_on_name = img['depends_on']
                        print(depends_on_name)