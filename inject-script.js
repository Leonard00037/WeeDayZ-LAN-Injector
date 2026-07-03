<script>
(function() {
    var lanServer = {
        id: '127.0.0.1:2302',
        address: '127.0.0.1:2302',
        name: '* LAN Server *',
        title: '* LAN Server *',
        game: 'DayZ',
        map: 'chernarusplus',
        description: 'LAN Server - Conecta con amigos via Hamachi/Radmin',
        players: 0,
        maxPlayers: 60,
        ping: 0,
        timeInGame: '12:00',
        version: '129',
        isFavorite: false,
        isModded: true,
        isOfficial: false,
        isPremium: false,
        isFirstPerson: false,
        isBattlEye: false,
        isLocked: false,
        isDownloading: false,
        isInstalled: false,
        hasUpdates: false,
        official: false,
        premium: false,
        vanilla: false,
        firstPerson: false,
        thirdPersonView: true,
        battlEye: false,
        modded: true,
        noMods: false,
        fresh: false,
        recent: false,
        installed: false,
        upToDate: true,
        online24h: true,
        region: 'LAN',
        country: 'LAN',
        view: '3rd person',
        launcher: 'weeDayZ',
        modBadge: '',
        wipeBadge: '',
        wipeIn: 0,
        wipeAt: '',
        downloadCount: 0,
        downloadPercent: 0,
        onlineHistory: [5,3,2,4,8,15,22,30,38,45,50,52,55,54,52,48,42,38,35,30,25,18,12,8]
    };
    lanServer.mods = [{workshopId: '1559212036', name: 'Community Framework'}];
    for (var i = 0; i < lanServer.mods.length; i++) {
        lanServer.mods[i].modId = lanServer.mods[i].workshopId;
        lanServer.mods[i].sizeBytes = 0;
        lanServer.mods[i].percentage = 100;
        lanServer.mods[i].downloadedBytes = 0;
        lanServer.mods[i].totalBytes = 0;
        lanServer.mods[i].completedChunks = 0;
        lanServer.mods[i].totalChunks = 0;
        lanServer.mods[i].publishedFileId = lanServer.mods[i].workshopId;
    }
    // ---- Debug overlay (hidden by default, toggle via button) ----
    var dbgLogs = [];
    function logDbg(m) {
        dbgLogs.push(m);
        var d = document.getElementById('lan-debug');
        if (d) { d.innerHTML += '<div>'+m+'</div>'; d.scrollTop = d.scrollHeight; }
    }
    function toggleDbg() {
        var d = document.getElementById('lan-debug');
        if (!d) {
            d = document.createElement('div');
            d.id = 'lan-debug';
            d.style.cssText = 'position:fixed;bottom:0;left:0;right:0;z-index:99999;background:rgba(0,0,0,.85);color:#0f0;font:12px monospace;padding:8px;max-height:150px;overflow-y:auto';
            document.body.appendChild(d);
            for (var i = 0; i < dbgLogs.length; i++) {
                d.innerHTML += '<div>'+dbgLogs[i]+'</div>';
            }
            d.scrollTop = d.scrollHeight;
        }
        d.style.display = (d.style.display === 'none') ? 'block' : 'none';
    }
    window.onerror = function(m,s,l,c,e) { logDbg('ERR: '+m+' at '+s+':'+l); };
    var origConsole = console.error;
    console.error = function() {
        try { logDbg('CONSOLE.ERR: '+Array.prototype.slice.call(arguments).join(' ')); } catch(ex) {}
        return origConsole.apply(this, arguments);
    };
    // ---- Debug toggle button (bug icon near refresh button) ----
    function addDebugBtn() {
        var header = document.querySelector('.main-header');
        if (!header) return;
        if (document.getElementById('lan-dbg-btn')) return;
        var btn = document.createElement('button');
        btn.id = 'lan-dbg-btn';
        btn.textContent = 'ðŸ›';
        btn.title = 'Debug: ver mensajes IPC y errores';
        btn.style.cssText = 'width:28px;height:28px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:var(--glass-bg,rgba(255,255,255,.04));border:1px solid var(--glass-border,rgba(255,255,255,.08));border-radius:var(--radius-sm,8px);color:var(--text-dim,#606060);font-size:15px;cursor:pointer;transition:all .15s;padding:0;margin-left:6px';
        btn.onmouseover = function() { this.style.borderColor = 'rgba(255,255,255,.2)'; this.style.color = '#efefef'; };
        btn.onmouseout = function() { this.style.borderColor = 'rgba(255,255,255,.08)'; this.style.color = '#606060'; };
        btn.onclick = toggleDbg;
        header.appendChild(btn);
    }
    addDebugBtn();
    var obs = new MutationObserver(function() { addDebugBtn(); });
    obs.observe(document.body, { childList: true, subtree: true });
    setTimeout(addDebugBtn, 1000);
    setTimeout(addDebugBtn, 3000);
    // ---- Helpers ----
    function getOurModIds() {
        return lanServer.mods.map(function(m) { return String(m.workshopId); });
    }
    function involvesOurMods(modIds) {
        if (!Array.isArray(modIds)) return false;
        var ourIds = getOurModIds();
        for (var i = 0; i < modIds.length; i++) {
            for (var j = 0; j < ourIds.length; j++) {
                if (String(modIds[i]) === ourIds[j]) return true;
            }
        }
        return false;
    }
    var msgHandler = null;
    try {
        var ext = window.external;
        if (ext && typeof ext.receiveMessage === 'function') {
            var origReceive = ext.receiveMessage.bind(ext);
            ext.receiveMessage = function(handler) {
                msgHandler = handler;
                var wrappedHandler = function(msg) {
                    try {
                        var data = JSON.parse(msg);
                        logDbg('IPC <== '+msg.substring(0,200));
                        if (data && data.type === 'serversList' && Array.isArray(data.servers)) {
                            if (!data.servers.some(function(s) { return s.id === lanServer.id; })) {
                                data.servers.unshift(lanServer);
                                msg = JSON.stringify(data);
                                logDbg('INJECTED server into serversList');
                            }
                        }
                    } catch(e) {
                        logDbg('IPC parse error: '+e.message);
                    }
                    return handler(msg);
                };
                return origReceive(wrappedHandler);
            };
            logDbg('receiveMessage patched OK');
        } else {
            logDbg('receiveMessage NOT available');
        }
    } catch(e) {
        logDbg('Error patching receiveMessage: '+e.message);
    }
    try {
        if (ext && typeof ext.sendMessage === 'function') {
            var origSend = ext.sendMessage.bind(ext);
            ext.sendMessage = function(msg) {
                logDbg('IPC ==> '+msg.substring(0,200));
                try {
                    var data = JSON.parse(msg);
                    if (data && data.type === 'workshop:checkMods' && data.modIds && involvesOurMods(data.modIds)) {
                        logDbg('Detected workshop:checkMods for our mods');
                        setTimeout(function() {
                            if (msgHandler) {
                                var resp = JSON.stringify({
                                    type: 'workshop:checkResult',
                                    payload: { allPresent: true, missingModIds: [], missingCount: 0, totalRequired: 0 }
                                });
                                logDbg('Auto-response: workshop:checkResult (all present)');
                                msgHandler(resp);
                            }
                        }, 100);
                    }
                    if (data && data.type === 'workshop:checkUpdates' && data.modIds && involvesOurMods(data.modIds)) {
                        logDbg('Detected workshop:checkUpdates for our mods');
                        setTimeout(function() {
                            if (msgHandler) {
                                var resp = JSON.stringify({
                                    type: 'workshop:updateCheckResult',
                                    payload: { outdated: [], upToDate: [] }
                                });
                                logDbg('Auto-response: workshop:updateCheckResult (none outdated)');
                                msgHandler(resp);
                            }
                        }, 100);
                    }
                } catch(e) {
                    logDbg('Error intercepting sendMessage: '+e.message);
                }
                return origSend(msg);
            };
            logDbg('sendMessage wrapped OK');
        }
    } catch(e) {
        logDbg('Error wrapping sendMessage: '+e.message);
    }
    })();
    </script>
