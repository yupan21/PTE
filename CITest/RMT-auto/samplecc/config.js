const fs = require('fs');

var args = process.argv.slice(2);
let config = fs.readFileSync('./samplecc-chan1-FAB-3808-2i1-TLS.json');
let config_data = JSON.parse(config)
console.log("changing "+args[0]+" to "+args[1])
config_data[args[0]] = args[1]
let result = JSON.stringify(config_data)
fs.writeFileSync('./samplecc-chan1-FAB-3808-2i1-TLS.json', result);