# system information record
+ Metrics collection name/type

    echo "hyperledger_fabric.peer.proposals_endorsed_total:1|c" | nc -w 1 -u 0.0.0.0 8125
    
    echo "hyperledger_fabric.peer.success_total.component-committer:1|c" | nc -w 1 -u 0.0.0.0 8125
    Counter

    hyperledger.fabric.peer.proposals_rejected_total
    Counter

    echo "hyperledger_fabric.peer.transactions_validated_total:1|c" | nc -u 0.0.0.0 8125
    Counter

    hyperledger.fabric.peer.transactions_invalidated_total
    Counter

    hyperledger.fabric.peer.blocks_total{channel:name}
    Counter
    
    echo "hyperledger_fabric.peer.channel_total.component-committer.env-test:4|g" | nc -w 1 -u 0.0.0.0 8125
    Gauge

+ pprof

    sleep 200;go tool pprof -pdf http://172.16.50.153:6060/debug/pprof/profile?seconds=120 > peer0pprof-30process.pdf
    sleep 200;go tool pprof -pdf http://172.16.50.153:6061/debug/pprof/profile?seconds=120 > orderer0pprof-30process.pdf

+ statsd or prometheus

    docker run -d -p 3000:3000 grafana/grafana
    docker run -d -p 8086:8086 -p 2003:2003 -p 8083:8083 \
        -e INFLUXDB_ADMIN_ENABLED=true \
        -e INFLUXDB_GRAPHITE_ENABLED=true \
        influxdb

    docker run -d -p 80:80 -p 3000:3000 -p 2003:2003 kamon/grafana_graphite

    docker run -d\
        --name graphite\
        -p 80:80\
        -p 2003-2004:2003-2004\
        -p 2023-2024:2023-2024\
        graphiteapp/graphite-statsd
    
    docker run -d -p 9090:9090 -v ~/prometheus.yml:/etc/prometheus/prometheus.yml \
       prom/prometheus
    

    version: '2'
    services:
        prometheus:
        image: prom/prometheus
        volumes:
        - ./prometheus.yml:/etc/prometheus/prometheus.yml
        command:
        - '-config.file=/etc/prometheus/prometheus.yml'
        ports:
        - '9090:9090'
