pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool silent: false
    property var list: []
    property var popupList: []
    property int idOffset: 0
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/nhattVim"
    readonly property string cachePath: cacheDir + "/notifications.json"

    readonly property int count: list.length

    FileView {
        id: notificationStore
        path: ""
    }

    Process {
        id: ensureCacheDir
        command: ["sh", "-c", "mkdir -p '" + root.cacheDir + "' && [ -f '" + root.cachePath + "' ] || printf '[]' > '" + root.cachePath + "'"]
        running: true
        onExited: {
            notificationStore.path = root.cachePath;
            Qt.callLater(root.load);
        }
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: notification => {
            if (!notification || (!notification.summary && !notification.body)) return;

            notification.tracked = true;

            const item = {
                id: notification.id + root.idOffset,
                appName: notification.appName || "Application",
                appIcon: notification.appIcon || "",
                image: notification.image || "",
                summary: notification.summary || "",
                body: stripMarkup(notification.body || ""),
                urgency: notification.urgency,
                time: Date.now(),
                source: notification
            };

            root.list = [item].concat(root.list).slice(0, 40);
            root.save();
            if (!root.silent) {
                root.showPopup(item);
            }
        }
    }

    onSilentChanged: {
        if (silent) {
            popupList = [];
        }
    }

    function toStoredItem(item) {
        return {
            id: item.id,
            appName: item.appName || "Application",
            appIcon: item.appIcon || "",
            image: item.image || "",
            summary: item.summary || "",
            body: item.body || "",
            urgency: item.urgency,
            time: item.time || Date.now()
        };
    }

    function save() {
        if (notificationStore.path === "") return;
        const stored = root.list.map(toStoredItem).slice(0, 40);
        notificationStore.setText(JSON.stringify(stored, null, 2));
    }

    function showPopup(item) {
        popupList = [item].concat(popupList.filter(popup => popup.id !== item.id)).slice(0, 5);
    }

    function timeoutPopup(id) {
        popupList = popupList.filter(item => item.id !== id);
    }

    function load() {
        if (notificationStore.path === "") return;
        try {
            const text = notificationStore.text();
            if (!text || text.trim().length === 0) {
                root.list = [];
                root.idOffset = 0;
                return;
            }

            const stored = JSON.parse(text);
            if (!Array.isArray(stored)) {
                root.list = [];
                root.idOffset = 0;
                return;
            }

            root.list = stored.filter(item => item && (item.summary || item.body)).map(item => ({
                id: item.id,
                appName: item.appName || "Application",
                appIcon: item.appIcon || "",
                image: item.image || "",
                summary: item.summary || "",
                body: item.body || "",
                urgency: item.urgency,
                time: item.time || Date.now(),
                source: null
            })).slice(0, 40);

            let maxId = 0;
            root.list.forEach(item => {
                if (item.id > maxId) maxId = item.id;
            });
            root.idOffset = maxId + 1;
        } catch (e) {
            console.log("[NotificationService] No saved notifications or invalid cache:", e);
            root.list = [];
            root.idOffset = 0;
        }
    }

    function stripMarkup(text) {
        return text.replace(/<[^>]*>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
    }

    function formatTime(time) {
        const date = new Date(time);
        return date.toLocaleTimeString(Qt.locale(), "hh:mm");
    }

    function discard(id) {
        const found = root.list.find(item => item.id === id);
        if (found && found.source) found.source.dismiss();
        root.list = root.list.filter(item => item.id !== id);
        root.timeoutPopup(id);
        root.save();
    }

    function clearAll() {
        root.list.forEach(item => {
            if (item.source) item.source.dismiss();
        });
        root.list = [];
        root.popupList = [];
        root.save();
    }
}
