docker_network()
{
  # Given a container, print its primary network
  docker inspect --format '{{json .NetworkSettings.Networks }}' $1 | jq -r keys[] | head -1
}

docker_container_exists()
{
  INDENT="$INDENT  "
  containerNameOrId=$1
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  INDENT=${INDENT%  }

  docker inspect $containerNameOrId > /dev/null 2>&1
}

docker_container_on_network()
{
  local container=$1
  local network=$2
  if docker_container_exists $container; then
    docker inspect --format "{{ .NetworkSettings.Networks.$network }}" $container | grep -v 'no value' > /dev/null 2>&1
  else
    false
  fi
}

docker_container_running() 
{
  INDENT="$INDENT  "
  containerNameOrId=$1
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  INDENT=${INDENT%  }

  containerRunning=$(docker inspect --format '{{ .State.Running }}' $containerNameOrId 2> /dev/null)
  if [[ $containerRunning = "true" ]]; then
    return 0
  elif [[ $containerRunning = "false" ]]; then
    return 1
  else
    errwarn "No such container $containerNameOrId"
    return 1
  fi
}

docker_network_exists()
{
  INDENT="$INDENT  "
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  INDENT=${INDENT%  }
  [[ ! -z $(docker network ls -q --filter "name=$1") ]]
}

docker_next_subnet()
{
  INDENT="$INDENT  "
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  # Print the subnet in CIDR format of the next available /16 docker bridge network

  bridgeNetworks="$(docker network ls --filter 'driver=bridge' -q)"
  IFS='.' read -ra netCIDR <<< "$(for NETWORK in $bridgeNetworks ; do \
                                    docker network inspect $NETWORK | \
                                      jq -r '.[].IPAM.Config[0].Subnet' ; \
                                  done | sort -n | tail -1)"
  let netCIDR[1]++
  echo ${netCIDR[@]} | tr ' ' '.'
  INDENT=${INDENT%  }
}

docker_network_create()
{
  INDENT="$INDENT  "
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  # Given a network name, create it if it doesn't already exist

  # In order to specify an IP address when running a docker container, a subnet must be specified when
  # creating a network.  Seems like a docker bug but specifying --subnet works around it.
  if ! docker_network_exists $1; then
    dockerGW=$(docker_next_subnet | sed -e 's^0/16^1^')
    docker network create --driver bridge $1 --subnet $(docker_next_subnet) --gateway $dockerGW
  fi
  INDENT=${INDENT%  }
}

docker_network_subnet()
{
  INDENT="$INDENT  "
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  INDENT=${INDENT%  }
  # Given a network name, print the CIDR subnet of that network

  networkID=$(docker network ls --filter "name=$1" -q)
  docker network inspect $networkID | jq -r '.[].IPAM.Config[0].Subnet'
}
  
docker_next_ip()
{
  INDENT="$INDENT  "
  $VERBOSE && echo "$(date): ${INDENT}$FUNCNAME $@" 1>&2
  local nextContainer
  local ip
  local lastOctet
  local nw
  local IPAddr
  nw=$1
  # Given a docker network, return the next available IP address on that network
  lastNetworkIP=$(docker network inspect $nw  | jq -r '.[].Containers[].IPv4Address'  | sort --version-sort | tail -1 | sed -e 's^/.*$^^')
  #if [[ -z lastContainerIP ]]; then
  if [[ -z $lastNetworkIP ]]; then
    # Arbitrarily start network addresses with last octet at 100 
    lastNetworkIP=$(docker_network_subnet $nw | sed -e 's^0/16^100^')
  fi
  # TBD:  Check for stopped containers on the network and if greater than $lastNetworkIP, then use that for lastNetworkIP
  # for nextContainer in stopped_containers; do
  #   clusterNetwork=mapr_nw
  #   ip=$(docker inspect --format "{{ .NetworkSettings.Networks.$clusterNetwork.IPAddress }}" $containerNameOrId ) \
  
  #   if lastOctet of $ip > lastOctet of lastContainerIP; then
  #     lastContainerIP=$ip
  #   fi
  # done 
  for containerNameOrId in $(docker ps -qa); do 
    ip=$(docker inspect --format "{{ .NetworkSettings.Networks.$nw.IPAMConfig.IPv4Address }}" $containerNameOrId)
    [[ "$ip" =~ "no value" ]] && continue
    if [[ ${ip##*.} -gt ${lastNetworkIP##*.} ]]; then
      lastNetworkIP=$ip
    fi
  done

  IFS='.' read -ra IPAddr <<< "$lastNetworkIP"
  let IPAddr[3]++
  echo ${IPAddr[@]} | tr ' ' '.'
  INDENT=${INDENT%  }
}

