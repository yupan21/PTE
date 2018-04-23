const exec = require('child_process').exec;
const python = exec('python system_stats.py',
    (error, stdout, stderr) => {
        console.log(`${stdout}`);
    });

var filecount = 0;
while (true) {
    sleep(300)
    var command = 'go tool pprof -pdf http://172.16.50.153:6060/debug/pprof/profile?seconds=120 > output-'+filecount+'-pprof.pdf'
    const child2 = exec(command,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
        });
    filecount++
}