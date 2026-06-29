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

# --- Config paths ---
$script:WwwRoot = Join-Path $env:LOCALAPPDATA "WeeDayZ\current\wwwroot"
$script:ConfigFile = Join-Path $PSScriptRoot "WeeDayZ-LAN-Config.json"
$script:OriginalBackup = Join-Path $env:LOCALAPPDATA "WeeDayZ\index.html.original"

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

        <!-- Mods Folder -->
        <Grid Grid.Row="3" Margin="0,0,0,8">
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
        <StackPanel Grid.Row="4" Margin="0,5,0,0">
            <TextBlock FontSize="12" Foreground="#888888" Margin="0,0,0,4">Mods detectados:</TextBlock>
            <ListBox x:Name="listMods" Height="110"/>
        </StackPanel>

        <!-- Status Log -->
        <StackPanel Grid.Row="5" Margin="0,10,0,0">
            <TextBlock FontSize="12" Foreground="#888888" Margin="0,0,0,4">Log:</TextBlock>
            <TextBox x:Name="txtLog" Height="70" IsReadOnly="True"
                     Background="#1A1A1A" Foreground="#00C853"
                     FontFamily="Consolas" FontSize="11"
                     VerticalScrollBarVisibility="Auto"
                     Text="Listo. Selecciona la carpeta de mods y aplica."/>
        </StackPanel>

        <!-- Buttons -->
        <StackPanel Grid.Row="7" Orientation="Horizontal" HorizontalAlignment="Left" Margin="0,12,0,0">
            <Button x:Name="btnApply" Style="{StaticResource BtnPrimary}" Content="Aplicar al Launcher" Width="140"/>
            <Button x:Name="btnRestore" Style="{StaticResource BtnDanger}" Content="Restaurar Original" Width="140" Margin="10,0,0,0"/>
            <Button x:Name="btnSave" Style="{StaticResource BtnSecondary}" Content="Guardar Config" Width="120" Margin="10,0,0,0"/>
            <Button x:Name="btnLoad" Style="{StaticResource BtnSecondary}" Content="Cargar Config" Width="120" Margin="10,0,0,0"/>
        </StackPanel>

        <!-- Footer -->
        <TextBlock Grid.Row="8" FontSize="10" Foreground="#555555" Margin="0,10,0,0">
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
        $name = $folderName
        if (Test-Path (Join-Path $FolderPath "mod.cpp")) {
            $content = Get-Content (Join-Path $FolderPath "mod.cpp") -Raw -ErrorAction SilentlyContinue
            if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
        } elseif (Test-Path (Join-Path $FolderPath "meta.cpp")) {
            $content = Get-Content (Join-Path $FolderPath "meta.cpp") -Raw -ErrorAction SilentlyContinue
            if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
        }
        $mods += @{workshopId = $folderName; name = $name; path = $FolderPath}
        return $mods
    }
    $subDirs = Get-ChildItem $FolderPath -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $subDirs) {
        if ($dir.Name -match '^\d+$') {
            $name = $dir.Name
            if (Test-Path (Join-Path $dir.FullName "mod.cpp")) {
                $content = Get-Content (Join-Path $dir.FullName "mod.cpp") -Raw -ErrorAction SilentlyContinue
                if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
            } elseif (Test-Path (Join-Path $dir.FullName "meta.cpp")) {
                $content = Get-Content (Join-Path $dir.FullName "meta.cpp") -Raw -ErrorAction SilentlyContinue
                if ($content -match 'name\s*=\s*"([^"]+)"') { $name = $matches[1] }
            }
            $mods += @{workshopId = $dir.Name; name = $name; path = $dir.FullName}
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
        map: 'chernarusplus',
        players: 0,
        maxPlayers: 60,
        ping: 0,
        timeInGame: '12:00',
        isFavorite: false,
        isLocked: false,
        isModded: $isModded,
        isFirstPerson: false,
        isPremium: false,
        isOfficial: false,
        isBattlEye: false,
        isDLC: false,
        version: '129',
        mods: [$modsJson],
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

function Backup-Original {
    $idxPath = Join-Path $script:WwwRoot "index.html"
    if ((Test-Path $idxPath) -and -not (Test-Path $script:OriginalBackup)) {
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
$txtMods = $window.FindName("txtMods")
$listMods = $window.FindName("listMods")
$txtLog = $window.FindName("txtLog")
$btnApply = $window.FindName("btnApply")
$btnRestore = $window.FindName("btnRestore")
$btnSave = $window.FindName("btnSave")
$btnLoad = $window.FindName("btnLoad")
$btnBrowse = $window.FindName("btnBrowse")

function Write-Log {
    param([string]$msg)
    $txtLog.Dispatcher.Invoke([Action]{ $txtLog.AppendText("`r`n$msg"); $txtLog.CaretIndex = $txtLog.Text.Length; $txtLog.ScrollToEnd() }, 'Render')
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

# Browse
$btnBrowse.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Selecciona la carpeta Workshop (contiene subcarpetas con IDs numericos)"
    if ($txtMods.Text -and (Test-Path $txtMods.Text)) {
        $fbd.SelectedPath = $txtMods.Text
    } else {
        $fbd.SelectedPath = "$env:LOCALAPPDATA\WeeDayZ\current"
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

    $idxPath = Join-Path $script:WwwRoot "index.html"
    if (-not (Test-Path $idxPath)) {
        Write-Log "ERROR: No se encuentra WeeDayZ en $($script:WwwRoot)"
        Write-Log "Esta instalado el WeeDayZ Launcher?"
        return
    }
    if (-not (Test-Path $script:OriginalBackup)) { Backup-Original; Write-Log "Backup original creado: $($script:OriginalBackup)" }
    $originalHtml = if (Test-Path $script:OriginalBackup) { Get-Content $script:OriginalBackup -Raw } else { Get-Content $idxPath -Raw }
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
    $config = @{ serverName = $txtName.Text.Trim(); ipPort = $txtIp.Text.Trim(); modsFolder = $txtMods.Text }
    $config | ConvertTo-Json | Out-File -FilePath $script:ConfigFile -Encoding utf8
    Write-Log "Config guardada en: $($script:ConfigFile)"
})

# Load
$btnLoad.Add_Click({
    if (-not (Test-Path $script:ConfigFile)) { Write-Log "No hay archivo de configuracion guardado."; return }
    $config = Get-Content $script:ConfigFile -Raw | ConvertFrom-Json
    $txtName.Dispatcher.Invoke([Action]{ $txtName.Text = $config.serverName; $txtIp.Text = $config.ipPort; $txtMods.Text = $config.modsFolder }, 'Render')
    if ($config.modsFolder -and (Test-Path $config.modsFolder)) { Update-ModList }
    Write-Log "Configuracion cargada."
})

# Auto-detect
$defaultWorkshop = "$env:USERPROFILE\OneDrive\Documentos\My Games\WeeDayz Client\WeeDayZ\Workshop"
if (-not (Test-Path $defaultWorkshop)) { $defaultWorkshop = "$env:LOCALAPPDATA\WeeDayZ\current\Workshop" }
if (Test-Path $defaultWorkshop) {
    $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $defaultWorkshop; Update-ModList }, 'Render')
    Write-Log "Mods auto-detectados desde: $defaultWorkshop"
}

# Auto-load config
if (Test-Path $script:ConfigFile) {
    try {
        $config = Get-Content $script:ConfigFile -Raw | ConvertFrom-Json
        $txtName.Dispatcher.Invoke([Action]{ $txtName.Text = $config.serverName; $txtIp.Text = $config.ipPort }, 'Render')
        if ($config.modsFolder -and (Test-Path $config.modsFolder)) {
            $txtMods.Dispatcher.Invoke([Action]{ $txtMods.Text = $config.modsFolder; Update-ModList }, 'Render')
        }
    } catch {}
}

# Show window
$window.ShowDialog() | Out-Null
