const fs = require('fs');
var args = process.argv.slice(2);

filepath = "../"+args[0]+"/samplecc-chan1-FAB-3808-2i1-TLS.json"

let config = fs.readFileSync(filepath);
let config_data = JSON.parse(config)
console.log("changing " + args[1] + " to " + args[2])
args_list = args[1].split(".")
if (args_list.length > 1) {
    if (args_list.length > 2){
        config_data[args_list[1]][args_list[2]][args_list[3]] = args[2]
    } else {
        config_data[args_list[1]][args_list[2]] = args[2]
    }
} else {
    if(config_data[args[1]] == undefined | config_data[args[1]] == "" | config_data[args[1]] == []){
        console.log("config parameter is undefined or length less than 1. creating one...")
    }
    config_data[args[1]] = args[2]
}



let result = JSON.stringify(config_data)
fs.writeFileSync(filepath, result);