<#
.WeeDayZ LAN Injector Tool
===========================
Configura el WeeDayZ Launcher para mostrar un servidor LAN en la lista.
Comparti este script con tus amigos para conectarse a tu servidor LAN/Hamachi/Radmin.

USO:
  - Abri la herramienta
  - Completa los campos (nombre, IP:Puerto, carpeta de mods)
  - Clic en "Aplicar al Launcher"
  - Abri el WeeDayZ Launcher y el servidor aparecera en la lista

REQUISITOS:
  - Windows 10/11
  - WeeDayZ Launcher instalado
  - PowerShell 5.1+
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Windows.Forms

# --- Config paths ---
$script:WwwRoot = ""
$script:ConfigFile = Join-Path $PSScriptRoot "WeeDayZ-LAN-Config.json"
$script:OriginalBackup = ""
$script:weeDayzPath = ""

function Find-WeeDayZ {
    $candidates = @(
        "$env:LOCALAPPDATA\WeeDayZ\current"
        "$env:LOCALAPPDATA\Programs\WeeDayZ"
        "$env:LOCALAPPDATA\WeeDayZ"
        "${env:ProgramFiles}\WeeDayZ"
        "${env:ProgramFiles(x86)}\WeeDayZ"
    )
    foreach ($c in $candidates) {
        $test = Join-Path $c "wwwroot\index.html"
        if (Test-Path $test) { return $c }
    }
    return $null
}

function Find-Workshop {
    param([string]$BasePath)
    $candidates = @(
        Join-Path $BasePath "Workshop"
        Join-Path $BasePath "wwwroot\Workshop"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    return $null
}

$detected = Find-WeeDayZ
if ($detected) {
    $script:weeDayzPath = $detected
    $script:WwwRoot = Join-Path $detected "wwwroot"
    $script:OriginalBackup = Join-Path (Split-Path $detected -Parent) "index.html.original"
}

# =====================================================================
# XAML LAYOUT
# =====================================================================
$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WeeDayZ LAN Injector" Height="560" Width="620"
        WindowStartupLocation="CenterScreen"
        FontFamily="Segoe UI" FontSize="13"
        Background="#1E1E1E" Foreground="White"
        ResizeMode="CanMinimize"
        BorderBrush="#00C853" BorderThickness="0,2,0,0">
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#CCCCCC"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#333333"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#555555"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="6,4"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>
        <Style TargetType="ListBox">
            <Setter Property="Background" Value="#2A2A2A"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#444444"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style TargetType="Button">
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>
        <Style x:Key="BtnPrimary" TargetType="Button">
            <Setter Property="Background" Value="#00C853"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
        <Style x:Key="BtnDanger" TargetType="Button">
            <Setter Property="Background" Value="#C62828"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
        <Style x:Key="BtnSecondary" TargetType="Button">
            <Setter Property="Background" Value="#424242"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
    </Window.Resources>

    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Title -->
        <StackPanel Grid.Row="0" Margin="0,0,0,15">
            <TextBlock FontSize="22" FontWeight="Bold" Foreground="#00C853">WeeDayZ LAN Injector</TextBlock>
            <TextBlock FontSize="12" Foreground="#888888">Configura un servidor LAN para que aparezca en el WeeDayZ Launcher</TextBlock>
        </StackPanel>

        <!-- Server Name -->
        <Grid Grid.Row="1" Margin="0,0,0,8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="140"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <TextBlock Grid.Column="0" VerticalAlignment="Center">Nombre del servidor:</TextBlock>
            <TextBox x:Name="txtName" Grid.Column="1" Text="* LAN Server *"/>
        </Grid>

        <!-- IP:Port -->
        <Grid Grid.Row="2" Margin="0,0,0,8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="140"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <TextBlock Grid.Column="0" VerticalAlignment="Center">Direccion IP:Puerto:</TextBlock>
            <TextBox x:Name="txtIp" Grid.Column="1" Text="127.0.0.1:2302"/>
        </Grid>

        <!-- WeeDayZ Path -->
        <Grid Grid.Row="3" Margin="0,0,0,8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="140"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="80"/>
            </Grid.ColumnDefinitions>
            <TextBlock Grid.Column="0" VerticalAlignment="Center">Ruta del Launcher:</TextBlock>
            <TextBox x:Name="txtWeeDayzPath" Grid.Column="1" IsReadOnly="True" Background="#2A2A2A"
                     Text="(auto-detectando...)"/>
            <Button x:Name="btnBrowseWeeDayz" Grid.Column="2" Margin="8,0,0,0"
                    Style="{StaticResource BtnSecondary}"
                    Content="Examinar..."/>
        </Grid>

        <!-- Mods Folder -->
        <Grid Grid.Row="4" Margin="0,0,0,8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="140"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="80"/>
            </Grid.ColumnDefinitions>
            <TextBlock Grid.Column="0" VerticalAlignment="Center">Carpeta de mods:</TextBlock>
            <TextBox x:Name="txtMods" Grid.Column="1" IsReadOnly="True" Background="#2A2A2A"/>
            <Button x:Name="btnBrowse" Grid.Column="2" Margin="8,0,0,0"
                    Style="{StaticResource BtnSecondary}"
                    Content="Examinar..."/>
        </Grid>

        <!-- Mod List -->
        <StackPanel Grid.Row="5" Margin="0,5,0,0">
            <TextBlock FontSize="12" Foreground="#888888" Margin="0,0,0,4">Mods detectados:</TextBlock>
            <ListBox x:Name="listMods" Height="110"/>
        </StackPanel>

        <!-- Status Log -->
        <StackPanel Grid.Row="6" Margin="0,10,0,0">
            <TextBlock FontSize="12" Foreground="#888888" Margin="0,0,0,4">Log:</TextBlock>
            <TextBox x:Name="txtLog" Height="70" IsReadOnly="True"
                     Background="#1A1A1A" Foreground="#00C853"
                     FontFamily="Consolas" FontSize="11"
                     VerticalScrollBarVisibility="Auto"
                     Text="Listo. Selecciona la carpeta de mods y aplica."/>
        </StackPanel>

        <!-- Buttons -->
        <StackPanel Grid.Row="8" Orientation="Horizontal" HorizontalAlignment="Left" Margin="0,12,0,0">
            <Button x:Name="btnApply" Style="{StaticResource BtnPrimary}" Content="Aplicar" Width="90"/>
            <Button x:Name="btnMonitor" Style="{StaticResource BtnSecondary}" Content="Monitor" Width="75" Margin="6,0,0,0"/>
            <Button x:Name="btnRestore" Style="{StaticResource BtnDanger}" Content="Restaurar" Width="90" Margin="6,0,0,0"/>
            <Button x:Name="btnSave" Style="{StaticResource BtnSecondary}" Content="Guardar" Width="75" Margin="6,0,0,0"/>
            <Button x:Name="btnLoad" Style="{StaticResource BtnSecondary}" Content="Cargar" Width="70" Margin="6,0,0,0"/>
        </StackPanel>

        <!-- Footer -->
        <TextBlock Grid.Row="9" FontSize="10" Foreground="#555555" Margin="0,10,0,0">
Compari este script con tus amigos para que puedan unirse a tu servidor LAN / Hamachi / Radmin
        </TextBlock>
    </Grid>
</Window>
'@

# =====================================================================
# HELPER FUNCTIONS
# =====================================================================
function Get-WorkshopMods {
    param([string]$FolderPath)
    $mods = @()
    if (-not (Test-Path $FolderPath)) { return $mods }
    $folderName = Split-Path $FolderPath -Leaf
    if ($folderName -match '^\d+$') {
        if ((Test-Path (Join-Path $FolderPath "mod.cpp")) -or (Test-Path (Join-Path $FolderPath "meta.cpp"))) {
            $name = $folderName
            if (Test-Path (Join-Path $FolderPath "mod.cpp")) {
                $content = Get-Content (Join-Path $FolderPath "mod.cpp") -Raw -ErrorAction SilentlyContinue
                if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
            } else {
                $content = Get-Content (Join-Path $FolderPath "meta.cpp") -Raw -ErrorAction SilentlyContinue
                if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
            }
            $mods += @{workshopId = $folderName; name = $name; path = $FolderPath}
        }
        return $mods
    }
    $subDirs = Get-ChildItem $FolderPath -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $subDirs) {
        if ($dir.Name -match '^\d+$') {
            if ((Test-Path (Join-Path $dir.FullName "mod.cpp")) -or (Test-Path (Join-Path $dir.FullName "meta.cpp"))) {
                $name = $dir.Name
                if (Test-Path (Join-Path $dir.FullName "mod.cpp")) {
                    $content = Get-Content (Join-Path $dir.FullName "mod.cpp") -Raw -ErrorAction SilentlyContinue
                    if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
                } else {
                    $content = Get-Content (Join-Path $dir.FullName "meta.cpp") -Raw -ErrorAction SilentlyContinue
                    if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
                }
                $mods += @{workshopId = $dir.Name; name = $name; path = $dir.FullName}
            }
        }
    }
    return $mods
}

function New-InjectedIndex {
    param([string]$ServerName, [string]$IpPort, [array]$Mods, [string]$OriginalHtml)
    $modsParts = @()
    foreach ($m in $Mods) {
        $escName = $m.name.Replace("'", "\'")
        $modsParts += "{workshopId: '$($m.workshopId)', name: '$escName'}"
    }
    $modsJson = $modsParts -join ", "
    $isModded = "false"
    if ($Mods.Count -gt 0) { $isModded = "true" }

    $injectScript = @"
<script>
(function() {
    var lanServer = {
        id: '$($IpPort.Replace("'", "\'"))',
        address: '$($IpPort.Replace("'", "\'"))',
        name: '$($ServerName.Replace("'", "\'"))',
        title: '$($ServerName.Replace("'", "\'"))',
        game: 'DayZ',
        map: 'chernarusplus',
        description: 'LAN Server - Conecta con amigos via Hamachi/Radmin',
        players: 0,
        maxPlayers: 60,
        ping: 0,
        timeInGame: '12:00',
        version: '129',
        isFavorite: false,
        isModded: $isModded,
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
        vanilla: $(if ($Mods.Count -eq 0) { 'true' } else { 'false' }),
        firstPerson: false,
        thirdPersonView: true,
        battlEye: false,
        modded: $isModded,
        noMods: $(if ($Mods.Count -eq 0) { 'true' } else { 'false' }),
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
    lanServer.mods = [$modsJson];
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
        btn.textContent = '⚙';
        btn.title = 'Debug: ver mensajes IPC y errores';
        btn.style.cssText = 'width:30px;height:30px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:8px;color:#aaa;font-size:16px;cursor:pointer;margin-left:6px';
        btn.onmouseover = function() { this.style.borderColor = 'rgba(255,255,255,.25)'; this.style.color = '#fff'; };
        btn.onmouseout = function() { this.style.borderColor = 'rgba(255,255,255,.1)'; this.style.color = '#aaa'; };
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
"@

    $clean = $OriginalHtml
    $allScripts = [regex]::Matches($clean, '(?s)<script[^>]*>.*?</script>')
    for ($i = $allScripts.Count - 1; $i -ge 0; $i--) {
        $m = $allScripts[$i]
        if ($m.Value -match 'lanServer') {
            $clean = $clean.Remove($m.Index, $m.Length)
        }
    }
    $result = $clean -replace '(</body>)', "`n$injectScript`n`$1"
    return $result
}

function Get-JsRef {
    param([string]$Html)
    if (-not $Html) { return "" }
    $m = [regex]::Match($Html, 'src="\./assets/index-([^"]+)\.js"')
    if ($m.Success) { return $m.Groups[1].Value }
    return ""
}

function Backup-Original {
    $idxPath = Join-Path $script:WwwRoot "index.html"
    if (-not (Test-Path $idxPath)) { return $false }
    $currentHtml = Get-Content $idxPath -Raw
    $currentJs = Get-JsRef -Html $currentHtml
    $backupJs = ""
    if (Test-Path $script:OriginalBackup) {
        $backupHtml = Get-Content $script:OriginalBackup -Raw
        $backupJs = Get-JsRef -Html $backupHtml
    }
    if (-not (Test-Path $script:OriginalBackup) -or ($currentJs -and $backupJs -and $currentJs -ne $backupJs)) {
        Copy-Item -Path $idxPath -Destination $script:OriginalBackup -Force
        return $true
    }
    return $false
}

function Restore-Original {
    if (Test-Path $script:OriginalBackup) {
        Copy-Item -Path $script:OriginalBackup -Destination (Join-Path $script:WwwRoot "index.html") -Force
        return $true
    }
    return $false
}

# =====================================================================
# BUILD WINDOW
# =====================================================================
$reader = [System.IO.StringReader]::new($xaml)
$xml = [System.Xml.XmlReader]::Create($reader)
$window = [System.Windows.Markup.XamlReader]::Load($xml)

# Get controls
$txtName = $window.FindName("txtName")
$txtIp = $window.FindName("txtIp")
$txtWeeDayzPath = $window.FindName("txtWeeDayzPath")
$txtMods = $window.FindName("txtMods")
$listMods = $window.FindName("listMods")
$txtLog = $window.FindName("txtLog")
$btnApply = $window.FindName("btnApply")
$btnRestore = $window.FindName("btnRestore")
$btnSave = $window.FindName("btnSave")
$btnLoad = $window.FindName("btnLoad")
$btnBrowse = $window.FindName("btnBrowse")
$btnBrowseWeeDayz = $window.FindName("btnBrowseWeeDayz")
$btnMonitor = $window.FindName("btnMonitor")

$script:MonitorActive = $false
$script:MonitorTimer = $null

function Start-Monitor {
    $script:MonitorActive = $true
    $btnMonitor.Dispatcher.Invoke([Action]{ $btnMonitor.Content = "Detener"; $btnMonitor.Background = "#E65100" }, 'Render')
    Write-Log "Monitor iniciado - vigilando WeeDayZ cada 3s..."
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick({
        if (-not $script:MonitorActive) { return }
        $weeProc = Get-Process -Name "WeeDayZ" -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $weeProc) { return }
        $idxPath = Join-Path $script:WwwRoot "index.html"
        if (-not (Test-Path $idxPath)) { return }
        $content = Get-Content $idxPath -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return }
        if ($content -match 'lanServer') { return }
        $backupPath = $script:OriginalBackup
        if (-not (Test-Path $backupPath)) {
            Backup-Original
            if (-not (Test-Path $backupPath)) { return }
        }
        try {
            $originalHtml = Get-Content $backupPath -Raw
            $newHtml = New-InjectedIndex -ServerName $txtName.Text.Trim() -IpPort $txtIp.Text.Trim() -Mods $listMods.Tag -OriginalHtml $originalHtml
            $newHtml | Out-File -FilePath $idxPath -Encoding utf8
            Write-Log "Monitor: re-aplicada inyeccion (WeeDayZ regenero wwwroot)"
        } catch {
            Write-Log "Monitor ERROR: $($_.Exception.Message)"
        }
    })
    $timer.Start()
    $script:MonitorTimer = $timer
}

function Stop-Monitor {
    $script:MonitorActive = $false
    if ($script:MonitorTimer) {
        $script:MonitorTimer.Stop()
        $script:MonitorTimer = $null
    }
    $btnMonitor.Dispatcher.Invoke([Action]{ $btnMonitor.Content = "Monitor"; $btnMonitor.Background = "#424242" }, 'Render')
    Write-Log "Monitor detenido"
}

$btnMonitor.Add_Click({
    if ($script:MonitorActive) { Stop-Monitor }
    else { Start-Monitor }
})

function Write-Log {
    param([string]$msg)
    $txtLog.Dispatcher.Invoke([Action]{ $txtLog.AppendText("`r`n$msg"); $txtLog.CaretIndex = $txtLog.Text.Length; $txtLog.ScrollToEnd() }, 'Render')
}

function Set-WeeDayzPath {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) { return $false }
    $testHtml = Join-Path $Path "wwwroot\index.html"
    if (-not (Test-Path $testHtml)) {
        $sub = Get-ChildItem $Path -Directory -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName "wwwroot\index.html") } | Select-Object -First 1
        if ($sub) { $Path = $sub.FullName }
        else { return $false }
    }
    $script:weeDayzPath = $Path
    $script:WwwRoot = Join-Path $Path "wwwroot"
    $script:OriginalBackup = Join-Path (Split-Path $Path -Parent) "index.html.original"
    return $true
}

function Update-ModList {
    $folder = $txtMods.Text
    if (-not (Test-Path $folder)) {
        $listMods.Items.Clear()
        return
    }
    $mods = Get-WorkshopMods -FolderPath $folder
    $listMods.Items.Clear()
    if ($mods.Count -eq 0) {
        $listMods.Items.Add("(No se encontraron mods - selecciona la carpeta Workshop/)")
    } else {
        foreach ($m in $mods) {
            $listMods.Items.Add("$($m.workshopId)  -  $($m.name)")
        }
    }
    $listMods.Tag = $mods
}

# Browse WeeDayZ path
$btnBrowseWeeDayz.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Selecciona la carpeta donde esta instalado WeeDayZ (debe contener una subcarpeta wwwroot/)"
    if ($txtWeeDayzPath.Text -and (Test-Path $txtWeeDayzPath.Text)) {
        $fbd.SelectedPath = $txtWeeDayzPath.Text
    } elseif ($script:weeDayzPath) {
        $fbd.SelectedPath = $script:weeDayzPath
    }
    if ($fbd.ShowDialog() -eq "OK") {
        if (Set-WeeDayzPath -Path $fbd.SelectedPath) {
            $txtWeeDayzPath.Dispatcher.Invoke([Action]{ $txtWeeDayzPath.Text = $script:weeDayzPath }, 'Render')
            Write-Log "Ruta del launcher: $($script:weeDayzPath)"
            $defaultWorkshop = Find-Workshop -BasePath $script:weeDayzPath
            if ($defaultWorkshop) {
                $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $defaultWorkshop; Update-ModList }, 'Render')
            } else {
                Write-Log "Selecciona la carpeta de mods manualmente (WeeDayZ/Workshop/)"
            }
        } else {
            Write-Log "ERROR: No se encontro wwwroot/index.html en esa carpeta"
        }
    }
})

# Browse mods
$btnBrowse.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Selecciona la carpeta Workshop (contiene subcarpetas con IDs numericos)"
    if ($txtMods.Text -and (Test-Path $txtMods.Text)) {
        $fbd.SelectedPath = $txtMods.Text
    } elseif ($script:weeDayzPath) {
        $fbd.SelectedPath = $script:weeDayzPath
    }
    if ($fbd.ShowDialog() -eq "OK") {
        $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $fbd.SelectedPath; Update-ModList }, 'Render')
        Write-Log "Carpeta seleccionada: $($fbd.SelectedPath)"
        Write-Log "Mods detectados: $($listMods.Tag.Count)"
    }
})

# Apply
$btnApply.Add_Click({
    $serverName = $txtName.Text.Trim()
    $ipPort = $txtIp.Text.Trim()
    $mods = $listMods.Tag
    if (-not $serverName) { Write-Log "ERROR: Ingresa un nombre de servidor"; return }
    if (-not $ipPort) { Write-Log "ERROR: Ingresa IP:Puerto"; return }
    if (-not $mods -or $mods.Count -eq 0) { Write-Log "AVISO: Sin mods - el server aparecera como vanilla" }

    if (-not $script:weeDayzPath -or -not (Test-Path $script:WwwRoot)) {
        Write-Log "ERROR: Ruta del WeeDayZ no valida."
        Write-Log "Usa el boton 'Examinar' junto a 'Ruta del Launcher' para seleccionar la carpeta del WeeDayZ Launcher."
        return
    }
    $idxPath = Join-Path $script:WwwRoot "index.html"
    if (-not (Test-Path $idxPath)) {
        Write-Log "ERROR: No se encuentra index.html en $($script:WwwRoot)"
        Write-Log "Asegurate de haber ejecutado el WeeDayZ Launcher al menos una vez."
        return
    }
    $backupResult = Backup-Original
    if ($backupResult) { Write-Log "Backup sincronizado: $($script:OriginalBackup)" }
    $originalHtml = Get-Content $script:OriginalBackup -Raw
    $newHtml = New-InjectedIndex -ServerName $serverName -IpPort $ipPort -Mods $mods -OriginalHtml $originalHtml
    $newHtml | Out-File -FilePath $idxPath -Encoding utf8
    Write-Log "OK! Aplicado. Abri (o reinicia) el WeeDayZ Launcher"
    Write-Log "  Servidor: $serverName  ->  $ipPort"
    if ($mods) { Write-Log "  Mods: $($mods.Count) detectados" }
})

# Restore
$btnRestore.Add_Click({
    if (Restore-Original) { Write-Log "OK! Original restaurado. Reinicia el launcher." }
    else { Write-Log "ERROR: No hay backup en $($script:OriginalBackup)" }
})

# Save
$btnSave.Add_Click({
    $config = @{ serverName = $txtName.Text.Trim(); ipPort = $txtIp.Text.Trim(); modsFolder = $txtMods.Text; weeDayzPath = $script:weeDayzPath }
    $config | ConvertTo-Json | Out-File -FilePath $script:ConfigFile -Encoding utf8
    Write-Log "Config guardada en: $($script:ConfigFile)"
})

# Load
$btnLoad.Add_Click({
    if (-not (Test-Path $script:ConfigFile)) { Write-Log "No hay archivo de configuracion guardado."; return }
    $config = Get-Content $script:ConfigFile -Raw | ConvertFrom-Json
    if ($config.weeDayzPath -and (Set-WeeDayzPath -Path $config.weeDayzPath)) {
        $txtWeeDayzPath.Dispatcher.Invoke([Action]{ $txtWeeDayzPath.Text = $script:weeDayzPath }, 'Render')
    }
    $txtName.Dispatcher.Invoke([Action]{ $txtName.Text = $config.serverName; $txtIp.Text = $config.ipPort; $txtMods.Text = $config.modsFolder }, 'Render')
    if ($config.modsFolder -and (Test-Path $config.modsFolder)) { Update-ModList }
    Write-Log "Configuracion cargada."
})

# Auto-detect
if ($detected) {
    $txtWeeDayzPath.Dispatcher.Invoke([Action]{ $txtWeeDayzPath.Text = $script:weeDayzPath }, 'Render')
    Write-Log "WeeDayZ detectado en: $($script:weeDayzPath)"
    $defaultWorkshop = Find-Workshop -BasePath $script:weeDayzPath
    if ($defaultWorkshop) {
        $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $defaultWorkshop; Update-ModList }, 'Render')
        Write-Log "Mods detectados desde: $defaultWorkshop"
    } else {
        Write-Log "Selecciona la carpeta de mods manualmente (WeeDayZ/Workshop/)"
    }
} else {
    $txtWeeDayzPath.Dispatcher.Invoke([Action]{ $txtWeeDayzPath.Text = "(no detectado - usa Examinar...)" }, 'Render')
    Write-Log "WeeDayZ no detectado. Usa el boton Examinar para seleccionar la carpeta del launcher."
}

# Auto-load config
if (Test-Path $script:ConfigFile) {
    try {
        $config = Get-Content $script:ConfigFile -Raw | ConvertFrom-Json
        if ($config.weeDayzPath -and (Set-WeeDayzPath -Path $config.weeDayzPath)) {
            $txtWeeDayzPath.Dispatcher.Invoke([Action]{ $txtWeeDayzPath.Text = $script:weeDayzPath }, 'Render')
        }
        $txtName.Dispatcher.Invoke([Action]{ $txtName.Text = $config.serverName; $txtIp.Text = $config.ipPort }, 'Render')
        if ($config.modsFolder -and (Test-Path $config.modsFolder)) {
            $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $config.modsFolder; Update-ModList }, 'Render')
        }
    } catch {}
}

# Stop monitor on close
$window.Add_Closed({
    Stop-Monitor
})

# Show window
$window.ShowDialog() | Out-Null
