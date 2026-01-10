pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell

Singleton {
    id: root

    function tr(term, context) {
        // Simple translation function - returns term as-is
        // TODO: Implement full translation support
        return term;
    }

    function trContext(context, term) {
        // Simple translation function - returns term as-is
        // TODO: Implement full translation support
        return term;
    }
}
