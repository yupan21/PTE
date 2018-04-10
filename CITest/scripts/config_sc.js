const fs = require('fs');
var args = process.argv.slice(2);

filepath = "../CISCFiles/"+args[0]

let config = fs.readFileSync(filepath);
var config_data = JSON.parse(config)
console.log("changing " + args[1] + " to " + args[2])
args_list = args[1].split(".")
if (args_list.length > 1) {
    if (args_list.length > 2){
        config_data["test-network"][args_list[0]][args_list[1]][args_list[2]] = args[2]
    } else {
        config_data["test-network"][args_list[0]][args_list[1]] = args[2]
    }
} else {
    if(config_data["test-network"][args[1]] == undefined | config_data["test-network"][args[1]] == "" | config_data["test-network"][args[1]] == []){
        console.log("config parameter is undefined or length less than 1. creating one...")
    }
    config_data["test-network"][args[1]] = args[2]
}



let result = JSON.stringify(config_data)
fs.writeFileSync(filepath, result);