let requestAction = action => {
    if (action === 'openLoading') {
        nw.Window.open('https://localhost/admin', {}, (win) => {win.maximize()});
        mainWindow.show(true); 
    } else if (action === 'exitApp') {
        const windows = nw.Window.getAll((windows) => {
                windows.forEach(window => {
                window.hide();
            });
        require('../scripts/exit.js').then(() => {
            nw.App.quit() ;
        });});
        
    }
};

let trayOptions = { title: 'Studyfair', tooltip: 'Studyfair', icon: 'images/logo_32.png' };
let tray = new nw.Tray(trayOptions);

tray.on('click', () => {
    requestAction('openLoading');
});

let menu = new nw.Menu();
menu.append(new nw.MenuItem({ label: 'Exit', click: () => requestAction('exitApp') }));
tray.menu = menu;