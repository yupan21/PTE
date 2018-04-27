var exec = require('child_process').exec;
var args = process.argv.slice(2);
// get the parameter expect the first two arguments: node and the js filename; returns string list
var targetFile = ''
var outputFile = ''
var commands = ''
var version = args[0]
var outputFileList = ['pte_ctlr.sh', 'pte_driver.sh', 'pte_mgr.sh', 'pte-execRequest.js', 'pte-main.js', 'pte-util.js']
for (outputFile of outputFileList) {
    targetFile = outputFile.replace('.', version + '.')
    commands = 'yes | cp -r ' + targetFile + ' ../' + outputFile
    console.log("exec command: ", commands)
    exec(commands, function(err,stdout,stderr){
        //  stdout is what the command outs
        if(err) {
            console.log('Get error:'+stderr);
        } else {
            console.log(stdout);
        }
    });
}