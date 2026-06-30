# WeeDayZ LAN Injector

> Conectate a servidores LAN / Hamachi / Radmin usando el flujo oficial del WeeDayZ Launcher (Steam auth, mod verification, etc.)

<img src="https://i.ibb.co/d495TyZD/aplicacion-abierta.png" width="100%" alt="App Screenshot">

## ✨ Que hace

El WeeDayZ Launcher oficial solo muestra servidores de su lista remota. Esta herramienta parchea el `index.html` del launcher para **inyectar un servidor LAN** en esa lista. Cuando haces clic en Play, el launcher hace todo el proceso normal:

- ✅ Verifica y descarga mods automaticamente
- ✅ Autenticacion via Steam (sin perderla)
- ✅ Lanza DayZ con los parametros correctos (`-mod`, `-connect`, `-port`)
- ✅ El juego se conecta a tu servidor LAN / Hamachi / Radmin

<img src="https://i.ibb.co/S7J3JmcX/servidor-lan-en-la-lista-de-servidores.png" width="100%" alt="Server in list">

## 🚀 Como usar

1. **Descarga** los archivos a una carpeta
2. **Ejecuta** `LAN-Injector-Launcher.cmd` (doble clic)
3. **Completa** los campos:
   - **Nombre del servidor** — el que aparecera en la lista
   - **IP:Puerto** — ej: `192.168.1.100:2302` o la IP de Hamachi/Radmin
   - **Carpeta de mods** — selecciona tu carpeta `WeeDayZ\Workshop\`
4. **Clic en "Aplicar al Launcher"**
5. **Abre el WeeDayZ Launcher** — el servidor aparece en la lista
6. **Clic en Play** — todo el flujo oficial, conecta a tu LAN


### Para compartir con amigos

Tu amigo hace los mismos pasos pero con **tu IP**. Si usan Hamachi/Radmin, usar la IP de la VPN. Los mods deben ser los mismos en todas las PCs.

## 📦 Archivos

| Archivo | Proposito |
|---------|-----------|
| `WeeDayZ-LAN-Injector.ps1` | App GUI con interfaz oscura (WPF) |
| `LAN-Injector-Launcher.cmd` | Lanzador (doble clic) |
| `inject-script.js` | Script de inyeccion standalone (para hacerlo manual) |

## 📋 Requisitos

- Windows 10 / 11
- WeeDayZ Launcher instalado ([weedayz.tech](https://weedayz.tech))
- PowerShell 5.1+ (viene con Windows)

## ⚙️ Como funciona

El launcher usa **Photino.NET + React** con un bridge C# ↔ JS via `window.external`. La herramienta intercepta la funcion `receiveMessage` del bridge y envuelve el handler de React para modificar el mensaje `serversList`:

```js
// El launcher registra su handler:
window.external.receiveMessage(reactHandler)

// Nosotros interceptamos:
window.external.receiveMessage = function(handler) {
    var wrapped = function(msg) {
        var data = JSON.parse(msg);
        if (data.type === 'serversList') {
            data.servers.unshift(lanServer); // inyectamos el nuestro
            msg = JSON.stringify(data);
        }
        return handler(msg); // pasamos al handler original de React
    };
    return origReceive.call(this, wrapped);
};
```

Cuando el backend envia la lista de servidores, React ve nuestro server como si fuera uno oficial y lo muestra en la UI. Al hacer Play, el launcher usa su flujo completo de lanzamiento.

## 🔧 Solucion de problemas

| Problema | Solucion |
|----------|----------|
| "No se encuentra WeeDayZ" | El launcher no esta instalado |
| El servidor no aparece | Re-aplicar la herramienta (el launcher se actualiza y resetea el index) |
| Error de PowerShell | Ejecutar: `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| Error al iniciar DayZ | Verificar mods instalados y que el server este online |

## 📸 Screenshots

<img src="https://i.ibb.co/d495TyZD/aplicacion-abierta.png" width="100%" alt="App">
<img src="https://i.ibb.co/S7J3JmcX/servidor-lan-en-la-lista-de-servidores.png" width="100%" alt="Servidor en lista">

## 📄 Licencia

MIT — Hace lo que quieras.
