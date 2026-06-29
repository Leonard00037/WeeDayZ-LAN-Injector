// == WeeDayZ LAN Server Injector ==
// Copy-paste inside <script> tag in index.html, BEFORE the React module script
// Reemplazar lanServer con tus valores
(function() {
    var lanServer = {
        id: 'IP:AQUI:2302',
        address: 'IP:AQUI:2302',
        name: '★ NOMBRE_SERVIDOR ★',
        map: 'chernarusplus',
        players: 0,
        maxPlayers: 60,
        ping: 0,
        timeInGame: '12:00',
        isFavorite: false,
        isLocked: false,
        isModded: true,
        isFirstPerson: false,
        isPremium: false,
        isOfficial: false,
        isBattlEye: false,
        isDLC: false,
        version: '129',
        mods: [
            {workshopId: '1828439124', name: 'VPPAdminTools'},
            {workshopId: '1559212036', name: 'Community Framework'}
        ],
        country: 'LAN',
        onlineHistory: []
    };

    try {
        var ext = window.external;
        if (ext && typeof ext.receiveMessage === 'function') {
            var origReceive = ext.receiveMessage;
            ext.receiveMessage = function(handler) {
                var wrappedHandler = function(msg) {
                    try {
                        var data = JSON.parse(msg);
                        if (data && data.type === 'serversList' && Array.isArray(data.servers)) {
                            if (!data.servers.some(function(s) { return s.id === lanServer.id; })) {
                                data.servers.unshift(lanServer);
                                msg = JSON.stringify(data);
                            }
                        }
                    } catch(e) {}
                    return handler(msg);
                };
                return origReceive.call(this, wrappedHandler);
            };
        }
    } catch(e) {}
})();
