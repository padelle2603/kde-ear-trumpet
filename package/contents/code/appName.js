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

    if (binary) {
        const humanized = humanizeBinary(binary)
        if (humanized.length > 0) {
            return humanized
        }
    }

    // 2. application.name se non corrisponde a pattern rumorosi / interni
    const appName = props["application.name"] || clientProps["application.name"] || streamObj.name
    if (appName) {
        const cleaned = appName.trim()
        const badPatterns = /^(WEBRTC|VoiceEngine|cpal.*|pulseaudio.*|SDL.*|GStreamer|OpenAL|ALSA|libav|ffmpeg|playStream|Playback)$/i
        if (cleaned.length > 0 && !badPatterns.test(cleaned)) {
            return cleaned
        }
    }

    // 3. streamObj.description o client.description
    if (streamObj.description && streamObj.description.trim().length > 0) {
        return streamObj.description
    }

    if (streamObj.client && streamObj.client.description && streamObj.client.description.trim().length > 0) {
        return streamObj.client.description
    }

    // 4. Fallback: cerca il PID (dalle proprietà del processo, del client o dal nome tipo cpal-pulseaudio-121412)
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

    const directIcon = props["application.icon_name"]
        || clientProps["application.icon_name"]
        || streamObj.iconName
        || (streamObj.client && streamObj.client.iconName)
        || props["window.icon_name"]
        || clientProps["window.icon_name"]
        || props["media.icon_name"]
        || clientProps["media.icon_name"]

    if (directIcon && directIcon.trim().length > 0) {
        return directIcon
    }

    let binary = props["application.process.binary"] || clientProps["application.process.binary"]
    if (binary && !isBadBinary(binary)) {
        let base = binary.split("/").pop().replace(/\.(AppImage|bin|desktop)$/i, "").toLowerCase()
        if (base.length > 0) {
            return base
        }
    }

    return "application-x-executable"
}
