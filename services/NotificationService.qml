pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool silent: false
    property var list: []

    readonly property int count: list.length

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
                id: notification.id,
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
    }

    function clearAll() {
        root.list.forEach(item => {
            if (item.source) item.source.dismiss();
        });
        root.list = [];
    }
}
