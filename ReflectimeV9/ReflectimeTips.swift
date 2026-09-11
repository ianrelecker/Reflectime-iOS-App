import TipKit

struct ComposeTip: Tip {
    var title: Text {
        Text("Write a small one")
    }

    var message: Text {
        Text("A few honest sentences beat waiting for the perfect entry.")
    }

    var image: Image? {
        Image(systemName: "square.and.pencil")
    }
}

struct InsightsTip: Tip {
    var title: Text {
        Text("Look back after three")
    }

    var message: Text {
        Text("Reflect unlocks streak, charts, and filters once you have three reflections.")
    }

    var image: Image? {
        Image(systemName: "sparkles")
    }
}

struct IntelligenceTip: Tip {
    var title: Text {
        Text("Private on-device insights")
    }

    var message: Text {
        Text("On Apple Intelligence devices, open a reflection and summarize it without leaving the phone.")
    }

    var image: Image? {
        Image(systemName: "brain.head.profile")
    }
}
