const common = require('./common.js');

module.exports = new Promise((resolve) => {
    common.runBatScript("start.bat").then(output => {
        console.log("Скрипт выполнен успешно:", output);
        resolve();
    })
    .catch(err => {
        console.error("Произошла ошибка:", err);
    }); 
});

