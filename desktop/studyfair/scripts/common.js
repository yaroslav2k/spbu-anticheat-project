const { exec } = require('child_process');
const path = require('path');

function runBatScript(scriptName) {
    return new Promise((resolve, reject) => {
        const scriptPath = path.join(__dirname, "../bats/", scriptName);
        console.log(scriptPath);
        
        exec(scriptPath, (error, stdout, stderr) => {
            if (error) {
                console.error("Ошибка при выполнении скрипта " + scriptName + ": " + error.message);
                reject(error);
                return;
            }
            console.log("Вывод " + scriptName + ": " + stdout + "\n" + stderr);
            resolve(stdout);
        });
    });
}

module.exports = { runBatScript };