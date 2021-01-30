import SwiftUI
import Quartz

struct QuickLookPreview: NSViewRepresentable {
    typealias NSViewType = QLPreviewView
    
    var url: URL

    func makeNSView(context: Context) -> NSViewType {
        let preview = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = url as QLPreviewItem
        return preview ?? QLPreviewView()
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.previewItem = url as QLPreviewItem
    }
}
