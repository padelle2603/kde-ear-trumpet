.pragma library

function humanizeBinary(binary) {
    if (!binary || typeof binary !== "string") return ""
    
    // Rimuovi eventuale percorso
    let base = binary.split("/").pop()
    
    // Rimuovi estensioni comuni o suffissi binari
    base = base.replace(/\.(AppImage|bin|desktop)$/i, "")
    base = base.replace(/-(bin|cli|app)$/i, "")
    
    // Sostituisci dash e underscore con spazi
    base = base.replace(/[-_]+/g, " ")
    
    // CamelCase / Capitalize parole
    let words = base.trim().split(/\s+/)
    if (words.length === 0) return ""
    
    return words.map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ")
}

function isBadBinary(bin) {
    if (!bin) return true
    const base = bin.split("/").pop().toLowerCase()
    return /^(pipewire|pulseaudio|systemd|wireplumber|apprun)$/i.test(base)
}

function isGenericBinary(bin) {
    if (!bin) return true
    const base = bin.split("/").pop().toLowerCase()
    return /^(python[0-9.]*|node|nodejs|java|electron[0-9.]*|apprun|bash|sh|zsh|perl|ruby)$/i.test(base)
}

function isBadAppName(name) {
    if (!name || typeof name !== "string") return true
    const bad = /^(WEBRTC|VoiceEngine|cpal.*|pulseaudio.*|SDL.*|GStreamer|OpenAL|ALSA|libav|ffmpeg|playStream|Playback|Wine.*Preloader|wineserver|wine.*)$/i
    return bad.test(name.trim())
}

// Wine/Proton espone sempre lo stesso binario (wine64-preloader, wineserver,
// proton) per ogni gioco: il nome reale va cercato altrove.
function isWineProcess(binary) {
    if (!binary || typeof binary !== "string") return false
    const b = binary.toLowerCase()
    return b.includes("wine") || b.includes("proton")
}

// Estrae "Hollow Knight" da "C:\\Games\\Hollow Knight\\hollow_knight.exe"
// o da "HAPPY PROPAGANDA.exe". Ritorna "" se non è un .exe.
function extractExeName(value) {
    if (!value || typeof value !== "string") return ""
    const base = value.split(/[\\/]/).pop().trim()
    const match = base.match(/^(.+)\.exe$/i)
    if (!match) return ""
    return humanizeBinary(match[1])
}

function resolveName(streamObj, model) {
    if (!streamObj) {
        return (model && model.Name) ? model.Name : "Audio Stream"
    }

    const props = streamObj.properties || {}
    const clientProps = (streamObj.client && streamObj.client.properties) || {}

    // 1. Prova prima con application.process.binary se valido (es. Discord, zen-bin)
    let binary = props["application.process.binary"] || clientProps["application.process.binary"]
    if (binary && isBadBinary(binary)) {
        binary = ""
    }

    // 2. Giochi Wine/Proton: il binario è sempre wine64-preloader & co.,
    //    ma il nome del gioco è nel .exe esposto da PipeWire.
    if (isWineProcess(binary)) {
        const exeName = extractExeName(props["application.name"])
            || extractExeName(clientProps["application.name"])
            || extractExeName(props["node.name"])
            || extractExeName(props["device.description"])
            || extractExeName(streamObj.description)
            || extractExeName(streamObj.name)
        if (exeName) {
            return exeName
        }
        // Nessun .exe esposto: meglio il fallback su application.name che
        // mostrare "Wine64 Preloader" per ogni gioco.
        binary = ""
    }

    // Se il binario è generico (python, node, electron...), application.name ha la precedenza
    if (binary && isGenericBinary(binary)) {
        const appName = props["application.name"] || clientProps["application.name"] || streamObj.name
        if (appName && !isBadAppName(appName)) {
            return extractExeName(appName) || humanizeBinary(appName)
        }
    }

    if (binary) {
        const humanized = humanizeBinary(binary)
        if (humanized.length > 0) {
            return humanized
        }
    }

    // 3. application.name se non corrisponde a pattern rumorosi / interni
    const appName = props["application.name"] || clientProps["application.name"] || streamObj.name
    if (appName) {
        const cleaned = appName.trim()
        const badPatterns = /^(WEBRTC|VoiceEngine|cpal.*|pulseaudio.*|SDL.*|GStreamer|OpenAL|ALSA|libav|ffmpeg|playStream|Playback|Wine.*Preloader|wineserver|wine.*)$/i
        if (cleaned.length > 0 && !badPatterns.test(cleaned)) {
            return extractExeName(cleaned) || cleaned
        }
    }

    // 4. streamObj.description o client.description
    if (streamObj.description && streamObj.description.trim().length > 0) {
        return streamObj.description
    }

    if (streamObj.client && streamObj.client.description && streamObj.client.description.trim().length > 0) {
        return streamObj.client.description
    }

    // 5. Fallback: cerca il PID (dalle proprietà del processo, del client o dal nome tipo cpal-pulseaudio-121412)
    let pid = props["application.process.id"] || clientProps["application.process.id"]
    if (!pid && appName) {
        const match = appName.match(/-(\d+)$/)
        if (match) {
            pid = match[1]
        }
    }

    if (pid) {
        return "Audio Stream (" + pid + ")"
    }

    if (model && model.Name && model.Name.trim().length > 0) {
        return model.Name
    }

    return "Audio Stream"
}

function resolveIcon(streamObj) {
    if (!streamObj) return "application-x-executable"

    const props = streamObj.properties || {}
    const clientProps = (streamObj.client && streamObj.client.properties) || {}

    // 1. Icona esplicita passata da PipeWire / client
    const directIcon = props["application.icon_name"]
        || clientProps["application.icon_name"]
        || streamObj.iconName
        || (streamObj.client && streamObj.client.iconName)
        || props["window.icon_name"]
        || clientProps["window.icon_name"]
        || props["media.icon_name"]
        || clientProps["media.icon_name"]

    if (directIcon && directIcon.trim().length > 0) {
        return directIcon.trim()
    }

    let binary = props["application.process.binary"] || clientProps["application.process.binary"]
    const hasExe = extractExeName(props["application.name"])
        || extractExeName(clientProps["application.name"])
        || extractExeName(props["node.name"])
        || extractExeName(props["device.description"])
        || extractExeName(streamObj.description)
        || extractExeName(streamObj.name)

    // 2. Giochi Wine/Proton: icona di gioco nativa Breeze/Plasma
    if (isWineProcess(binary) || hasExe) {
        return "applications-games"
    }

    // 3. Binario nativo concreto (es. Discord, vlc, mpv, kitty, kate)
    if (binary && !isBadBinary(binary) && !isGenericBinary(binary)) {
        let base = binary.split("/").pop().replace(/\.(AppImage|bin|desktop)$/i, "").toLowerCase()
        if (base.length > 0) {
            return base
        }
    }

    // 4. Per app avviate da interpreti/wrapper (es. python3 Photocraft, electron Spotify)
    const appName = props["application.name"] || clientProps["application.name"] || streamObj.name
    if (appName && !isBadAppName(appName)) {
        let clean = appName.trim().toLowerCase().replace(/\s+/g, "-").replace(/[^a-z0-9._-]/g, "")
        if (clean.length > 0) {
            return clean
        }
    }

    // 5. Fallback sul binario generico (es. python3 o electron) se presente
    if (binary && !isBadBinary(binary)) {
        let base = binary.split("/").pop().replace(/\.(AppImage|bin|desktop)$/i, "").toLowerCase()
        if (base.length > 0) {
            return base
        }
    }

    return "application-x-executable"
}
