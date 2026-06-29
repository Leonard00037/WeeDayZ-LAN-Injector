# WeeDayZ LAN Injector 🎮

Inyecta un servidor LAN en la lista del WeeDayZ Launcher para que uses el flujo oficial (Steam, mods, etc.).

> **ESP** — Conectate a servidores LAN / Hamachi / Radmin sin perder la autenticacion de Steam ni la verificacion de mods del launcher oficial.
>
> **ENG** — Connect to LAN / Hamachi / Radmin servers without losing Steam authentication or mod verification from the official launcher.

---

## ✨ Que hace / What it does

El WeeDayZ Launcher oficial solo muestra servidores de su lista remota. Esta herramienta parchea el `index.html` del launcher para **inyectar un servidor LAN** en esa lista. Cuando haces clic en Play, el launcher hace todo el proceso normal:

- ✅ Verifica/descarga mods
- ✅ Autenticacion via Steam
- ✅ Lanza DayZ con los parametros correctos (mods, IP, puerto)
- ✅ El juego se conecta a tu servidor LAN / Hamachi / Radmin

## 📦 Archivos / Files

| Archivo | Proposito |
|---------|-----------|
| `WeeDayZ-LAN-Injector.ps1` | App GUI (WPF) con interfaz oscura |
| `LAN-Injector-Launcher.cmd` | Lanzador (doble clic y funciona) |
| `inject-script.js` | Script de inyeccion standalone (para hacerlo manual) |

## 🚀 Como usar / How to use

1. **Descarga** los 3 archivos a una carpeta
2. **Ejecuta** `LAN-Injector-Launcher.cmd` (doble clic)
3. **Completa** los campos:
   - Nombre del servidor
   - IP:Puerto (ej: `192.168.1.100:2302` o IP de Hamachi/Radmin)
   - Carpeta de mods → selecciona tu carpeta `Workshop\`
4. **Clic en "Aplicar al Launcher"**
5. **Abre el WeeDayZ Launcher** — el servidor aparece en la lista
6. **Clic en Play** — todo el flujo oficial

### Para compartir con amigos / Sharing with friends

Tu amigo hace lo mismo pero con **tu IP**. Si usan Hamachi/Radmin, poner la IP de la VPN.

## 🔧 Requisitos / Requirements

- Windows 10 / 11
- WeeDayZ Launcher instalado (https://weedayz.tech)
- PowerShell 5.1+ (viene con Windows)

## ⚙️ Como funciona / How it works

El launcher usa Photino.NET + React. La comunicacion C# ↔ JS usa `window.external`. Esta herramienta intercepta la funcion `receiveMessage` del bridge y modifica el mensaje `serversList` para agregar el servidor LAN. Como el launcher recibe el server como si fuera uno oficial, usa todo su flujo normal de lanzamiento.

```
window.external.receiveMessage(handler)
    ↓  interceptamos
wrappedHandler(msg)
    ↓  si es serversList → injectamos nuestro server
    →  llamamos al handler original de React
```

## 🛠️ Solucion de problemas / Troubleshooting

| Problema | Solucion |
|----------|----------|
| "No se encuentra WeeDayZ" | El launcher no esta instalado |
| El servidor no aparece | Re-aplicar la herramienta (el launcher se actualiza y resetea el index) |
| Error de PowerShell | Ejecutar `powershell -ExecutionPolicy Bypass -File WeeDayZ-LAN-Injector.ps1` |
| Error al iniciar DayZ | Verificar que los mods esten instalados y el server este online |

## 📝 Notas / Notes

- Si el launcher se actualiza, el `index.html` se resetea. Solo re-aplicar la herramienta.
- Los mods deben ser los mismos en todas las PCs.
- El servidor DayZ debe estar corriendo y accesible.

## 📄 Licencia / License

MIT — Hace lo que quieras.
