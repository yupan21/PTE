const fs = require('fs');

var args = process.argv.slice(2);
let config = fs.readFileSync('./samplecc-chan1-FAB-3808-2i1-TLS.json');
let config_data = JSON.parse(config)
console.log("changing " + args[0] + " to " + args[1])
args_list = args[0].split(".")
if (args_list.length > 1) {
    if (args_list.length > 2){
        config_data[args_list[0]][args_list[1]][args_list[2]] = args[1]
    } else {
        config_data[args_list[0]][args_list[1]] = args[1]
    }
} else {
    if(config_data[args[0]] == undefined | config_data[args[0]] == "" | config_data[args[0]] == []){
        console.log("config parameter is undefined or length less than 1. creating one...")
    }
    config_data[args[0]] = args[1]
}



let result = JSON.stringify(config_data)
fs.writeFileSync('./samplecc-chan1-FAB-3808-2i1-TLS.json', result);