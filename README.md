<div align="center">
  <h1>WeeDayZ LAN Injector</h1>
  <p><b>🇪🇸 Español</b> · <a href="#-english">🇬🇧 English</a> · <a href="#-русский">🇷🇺 Русский</a></p>
  <br>
  <a href="https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest">
    <img src="https://img.shields.io/badge/Descargar-ZIP-00c853?style=for-the-badge&logo=github" alt="Download">
  </a>
  <br><br>
  <img src="https://i.ibb.co/Y7F9y1qL/Captura-de-pantalla-16.png" width="100%" alt="App Screenshot">
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

### 🐛 Boton de depuracion

Al aplicar la inyeccion, aparece un boton **🐛** en el header del launcher (al lado del boton de refresco). Al hacer clic, muestra un panel con:
- Mensajes IPC entrantes y salientes
- Errores de consola
- Errores globales (window.onerror)

### 🔄 Modo Monitor

La herramienta incluye un boton **Monitor** que vigila WeeDayZ cada 3 segundos. Si el launcher regenera `wwwroot/` (lo que borra la inyeccion), la re-aplica automaticamente.

1. Abre la herramienta y configura tu servidor
2. Clic en **Aplicar al Launcher**
3. Clic en **Monitor** (el boton cambia a "Detener" en naranja)
4. Manten la herramienta abierta — re-aplica automaticamente si es necesario
5. Clic en **Detener** o cierra la ventana para desactivar

### 📦 Archivos

| Archivo | Proposito |
|---------|-----------|
| `WeeDayZ-LAN-Injector.ps1` | App GUI (WPF) con Monitor incluido |
| `LAN-Injector-Launcher.cmd` | Lanzador (doble clic) |
| `inject-script.js` | Script standalone |

### 🔧 Solucion de problemas

| Problema | Solucion |
|----------|----------|
| "No se encuentra WeeDayZ" | El launcher no esta instalado |
| El servidor no aparece | Re-aplicar o activar Monitor |
| Error de PowerShell | `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| Error al iniciar DayZ | Verificar mods instalados y server online |
| Pantalla negra al ver detalle | Se soluciona automaticamente con la inyeccion (datos fake de onlineHistory + auto-respuesta de mods) |

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

### 🐛 Debug button

After applying the injection, a **🐛** button appears in the launcher header. Click it to show IPC messages, console errors, and global errors.

### 🔄 Monitor mode

Click **Monitor** in the tool to automatically re-apply the injection every 3 seconds if the launcher resets `wwwroot/`. Close the window or click **Detener** to stop.

### 🔧 Troubleshooting

| Problem | Fix |
|---------|-----|
| "No se encuentra WeeDayZ" | Launcher not installed |
| Server not showing | Re-apply or use Monitor mode |
| PowerShell error | Run `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| DayZ won't start | Check mods are installed and server is online |
| Black screen on server detail | Fixed automatically by the injection (fake onlineHistory data + mod auto-response) |

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

### 🐛 Кнопка отладки

После инъекции в заголовке лаунчера появляется кнопка **🐛**. Нажмите её, чтобы увидеть IPC-сообщения, ошибки консоли и глобальные ошибки.

### 🔄 Режим монитора

Нажмите **Monitor** в инструменте, чтобы автоматически повторно применять инъекцию каждые 3 секунды, если лаунчер сбросит `wwwroot/`. Закройте окно или нажмите **Detener** для остановки.

### 🔧 Решение проблем

| Проблема | Решение |
|----------|---------|
| "No se encuentra WeeDayZ" | Лаунчер не установлен |
| Сервер не появляется | Примените снова или используйте Monitor |
| Ошибка PowerShell | Выполните `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| DayZ не запускается | Проверьте установку модов и доступность сервера |
| Черный экран при просмотре сервера | Исправляется автоматически инъекцией (фейковые onlineHistory + авто-ответ модов) |

---

## ⚙️ Technical

The launcher uses **Photino.NET + React** with a C# ↔ JS bridge via `window.external`. This tool intercepts `receiveMessage` to inject a LAN server into `serversList`, and also:

- **`sendMessage` interception** — auto-responds to `workshop:checkMods` and `workshop:updateCheckResult` so the launcher doesn't wait for C# to respond (which would time out for unknown mod IDs)
- **Fake `onlineHistory`** — provides 24 data points so the chart component doesn't crash on `undefined`
- **Debug panel** — click the 🐛 button to see all IPC traffic and errors

```js
ext.receiveMessage = function(handler) {
    msgHandler = handler;
    var wrapped = function(msg) {
        var data = JSON.parse(msg);
        if (data.type === 'serversList') {
            data.servers.unshift(lanServer);
            msg = JSON.stringify(data);
        }
        return handler(msg);
    };
    return origReceive(wrapped);
};
ext.sendMessage = function(msg) {
    var data = JSON.parse(msg);
    if (data.type === 'workshop:checkMods' && involvesOurMods(data.modIds)) {
        // Auto-respond: all present
        msgHandler(JSON.stringify({ type: 'workshop:checkResult', ... }));
    }
    return origSend(msg);
};
```

React sees the injected server as official and uses the full launch flow (Steam auth, mod verification, process spawning).

## 📸 Screenshots

<img src="https://i.ibb.co/Y7F9y1qL/Captura-de-pantalla-16.png" width="100%" alt="App">
<img src="https://i.ibb.co/ym6tKhKj/Captura-de-pantalla-15.png" width="100%" alt="Server list">

---

<div align="center">
  <p><b>📦 <a href="https://github.com/Leonard00037/WeeDayZ-LAN-Injector/releases/latest">Download latest release</a></b></p>
  <p>MIT License</p>
</div>
