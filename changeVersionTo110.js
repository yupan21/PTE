// usage: node changeVersionTo110.js
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var args = process.argv.slice(2);
// get the parameter expect the first two arguments: node and the js filename; returns string list

// global parameters
var nowTime = new Date().toLocaleTimeString()
var imageTag = 'x86_64-1.1.0'


timecmd = 'echo execSycn time:'+ nowTime
console.log(execSync(timecmd).toString())
// exec(timecmd, function(err,stdout,stderr){
//     //  stdout is what the command outs
//     if(err) {
//         console.log('Get error:'+stderr);
//     } else {
//         console.log(stdout);
//     }
// });


function upgradeContainer(cmd){
    console.log(execSync(cmd).toString())
}
cmd = "ssh "