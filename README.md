<div align="center">
  <h1>WeeDayZ LAN Injector</h1>
  <p><b>🇪🇸 Español</b> · <a href="#-english">🇬🇧 English</a> · <a href="#-русский">🇷🇺 Русский</a></p>
  <br>
  <a href="https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest">
    <img src="https://img.shields.io/badge/Descargar-ZIP-00c853?style=for-the-badge&logo=github" alt="Download">
  </a>
  <br><br>
  <img src="https://i.ibb.co/8g37CVk9/aplicacion-abierta.png" width="100%" alt="App Screenshot">
</div>

---

## 🇪🇸 Español

Conecta a servidores **LAN / Hamachi / Radmin** usando el flujo oficial del WeeDayZ Launcher. Sin perder Steam auth ni verificacion de mods.

### 🚀 Como usar

1. **Descarga** los archivos desde **[Releases](https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest)**
2. **Ejecuta** `LAN-Injector-Launcher.cmd` (doble clic)
3. **Completa** los campos:
   - Nombre del servidor
   - IP:Puerto (ej: `192.168.1.100:2302` o IP de Hamachi/Radmin)
   - Carpeta de mods → selecciona `WeeDayZ\Workshop\`
4. **Clic en "Aplicar al Launcher"**
5. **Abre el WeeDayZ Launcher** — el servidor aparece en la lista
6. **Clic en Play** — conecta a tu LAN

### 📦 Archivos

| Archivo | Proposito |
|---------|-----------|
| `WeeDayZ-LAN-Injector.ps1` | App GUI (WPF) |
| `LAN-Injector-Launcher.cmd` | Lanzador (doble clic) |
| `inject-script.js` | Script standalone |

### 🔧 Solucion de problemas

| Problema | Solucion |
|----------|----------|
| "No se encuentra WeeDayZ" | El launcher no esta instalado |
| El servidor no aparece | Re-aplicar (el launcher se actualiza y resetea) |
| Error de PowerShell | `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| Error al iniciar DayZ | Verificar mods instalados y server online |

---

<h2 id="-english">🇬🇧 English</h2>

Connect to **LAN / Hamachi / Radmin** servers through the official WeeDayZ Launcher flow. No Steam auth loss, no mod issues.

### 🚀 Usage

1. **Download** from **[Releases](https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest)**
2. **Run** `LAN-Injector-Launcher.cmd` (double click)
3. **Fill** server name, IP:Port, mods folder
4. **Click** "Aplicar al Launcher"
5. **Open** WeeDayZ Launcher — server appears in list
6. **Click** Play — connects to your LAN server

### 🔧 Troubleshooting

| Problem | Fix |
|---------|-----|
| "No se encuentra WeeDayZ" | Launcher not installed |
| Server not showing | Re-apply (launcher updates reset index.html) |
| PowerShell error | Run `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| DayZ won't start | Check mods are installed and server is online |

---

<h2 id="-русский">🇷🇺 Русский</h2>

Подключайтесь к **LAN / Hamachi / Radmin** серверам через официальный лаунчер WeeDayZ. Steam-авторизация и проверка модов работают в штатном режиме.

### 🚀 Использование

1. **Скачайте** файлы из **[Releases](https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest)**
2. **Запустите** `LAN-Injector-Launcher.cmd` (двойным щелчком)
3. **Заполните** поля:
   - Название сервера
   - IP:Порт (например `192.168.1.100:2302` или IP Hamachi/Radmin)
   - Папка модов → выберите `WeeDayZ\Workshop\`
4. **Нажмите** "Aplicar al Launcher"
5. **Откройте** WeeDayZ Launcher — сервер появится в списке
6. **Нажмите** Play — подключение к вашему LAN серверу

### 🔧 Решение проблем

| Проблема | Решение |
|----------|---------|
| "No se encuentra WeeDayZ" | Лаунчер не установлен |
| Сервер не появляется | Примените снова (лаунчер обновляется и сбрасывает index.html) |
| Ошибка PowerShell | Выполните `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| DayZ не запускается | Проверьте установку модов и доступность сервера |

---

## ⚙️ Technical

The launcher uses **Photino.NET + React** with a C# ↔ JS bridge via `window.external`. This tool intercepts `receiveMessage` to inject a LAN server into `serversList`:

```js
// Launcher registers:  window.external.receiveMessage(reactHandler)

// We intercept:
ext.receiveMessage = function(handler) {
    var wrapped = function(msg) {
        var data = JSON.parse(msg);
        if (data.type === 'serversList') {
            data.servers.unshift(lanServer);
            msg = JSON.stringify(data);
        }
        return handler(msg);
    };
    return origReceive.call(this, wrapped);
};
```

React sees the injected server as official and uses the full launch flow (Steam auth, mod verification, process spawning).

## 📸 Screenshots

<img src="https://i.ibb.co/8g37CVk9/aplicacion-abierta.png" width="100%" alt="App">
<img src="https://i.ibb.co/R47D76Np/servidor-lan-en-la-lista-de-servidores.png" width="100%" alt="Server list">

---

<div align="center">
  <p><b>📦 <a href="https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest">Download latest release</a></b></p>
  <p>MIT License</p>
</div>
