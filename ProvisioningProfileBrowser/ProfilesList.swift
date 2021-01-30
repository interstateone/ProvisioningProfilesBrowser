import Foundation
import SwiftUI

struct ProfilesList: NSViewRepresentable {
    typealias NSViewType = NSScrollView

    @Binding var data: [ProvisioningProfile]
    @Binding var selection: ProvisioningProfile.ID?
    @EnvironmentObject var profilesManager: ProvisioningProfilesManager
    
    init(data: Binding<[ProvisioningProfile]>, selection: Binding<ProvisioningProfile.ID?>) {
        self._data = data
        self._selection = selection
    }

    func makeNSView(context: Context) -> NSViewType {
        let tableView = TableView()
        tableView.style = .plain
        tableView.usesAlternatingRowBackgroundColors = true

        let columns = [
            configure(NSTableColumn(identifier: .init("icon"))) {
                $0.title = ""
                $0.width = 16
            },
            configure(NSTableColumn(identifier: .init("name"))) {
                $0.title = "Name"
                $0.width = 200
                $0.sortDescriptorPrototype = NSSortDescriptor(
                    keyPath: \ProvisioningProfile.name,
                    ascending: true,
                    comparator: { a, b in (a as! String).localizedStandardCompare(b as! String) }
                )
            },
            configure(NSTableColumn(identifier: .init("team"))) {
                $0.title = "Team Name"
                $0.sortDescriptorPrototype = NSSortDescriptor(
                    keyPath: \ProvisioningProfile.teamName,
                    ascending: true,
                    comparator: { a, b in (a as! String).localizedStandardCompare(b as! String) }
                )
            },
            configure(NSTableColumn(identifier: .init("creation"))) {
                $0.title = "Creation Date"
                $0.sortDescriptorPrototype = NSSortDescriptor(
                    keyPath: \ProvisioningProfile.creationDate,
                    ascending: true,
                    comparator: { a, b in (a as! Date).compare(b as! Date) }
                )
            },
            configure(NSTableColumn(identifier: .init("expiry"))) {
                $0.title = "Expiry Date"
                $0.sortDescriptorPrototype = NSSortDescriptor(
                    keyPath: \ProvisioningProfile.expirationDate,
                    ascending: true,
                    comparator: { a, b in (a as! Date).compare(b as! Date) }
                )
            },
            configure(NSTableColumn(identifier: .init("uuid"))) {
                $0.title = "UUID"
                $0.sortDescriptorPrototype = NSSortDescriptor(
                    keyPath: \ProvisioningProfile.uuid,
                    ascending: true,
                    comparator: { a, b in (a as! String).localizedStandardCompare(b as! String) }
                )
            },
        ]
        columns.forEach(tableView.addTableColumn(_:))
        // Default to sort by name
        tableView.sortDescriptors = [columns.first { $0.identifier.rawValue == "name" }!.sortDescriptorPrototype!]

        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.tableViewDelegate = context.coordinator
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Move to Trash", action: #selector(TableView.tableViewDeleteItemClicked(_:)), keyEquivalent: ""))
        tableView.menu = menu
        
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        
        return scrollView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.parent = self
        let tableView = nsView.subviews[1].subviews[0] as! NSTableView
        
        context.coordinator.sortByDescriptors(tableView.sortDescriptors)
        tableView.reloadData()
        
        if let selectedRow = data.firstIndex(where: { $0.id == selection }) {
            tableView.selectRowIndexes(IndexSet([selectedRow]), byExtendingSelection: false)
        }
    }
    
    // MARK: - Coordinator
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class TableView: NSTableView {
        weak var tableViewDelegate: TableViewDelegate?
        
        @objc func tableViewDeleteItemClicked(_ sender: AnyObject) {
            tableViewDelegate?.moveToTrash(clickedRow)
        }
    }
    
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource, TableViewDelegate {
        var parent: ProfilesList

        init(_ parent: ProfilesList) {
            self.parent = parent
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            parent.data.count
        }
        
        // MARK: - TableViewDelegate
        
        func moveToTrash(_ row: Int) {
            let profile = parent.data[row]
            parent.profilesManager.delete(profile: profile)
        }
        
        // MARK: - NSTableViewDelegate
        // MARK: - NSTableViewDataSource
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let profile = parent.data[row]
            
            guard let tableColumn = tableColumn else { return nil }

            switch tableColumn.identifier.rawValue {
            case "icon":
                let hostingView = NSHostingView(
                    rootView: Image(nsImage: NSWorkspace.shared.icon(forFile: profile.url.path))
                        .resizable()
                        .frame(width: 16, height: 16)
                        .help(profile.url.path)
                        .onDrag { NSItemProvider(contentsOf: profile.url)! }
                        .onTapGesture(count: 2, perform: { NSWorkspace.shared.activateFileViewerSelecting([profile.url]) })
                        .frame(maxWidth: .infinity, alignment: .leading)
                )    
                hostingView.identifier = tableColumn.identifier
                return hostingView
            case "name":
                let textField = NSTextField()
                textField.cell = VerticallyCenteredTextFieldCell()
                textField.isEditable = false
                textField.isSelectable = false
                textField.isBezeled = false
                textField.drawsBackground = false
                textField.stringValue = profile.name
                textField.identifier = tableColumn.identifier
                textField.cell?.truncatesLastVisibleLine = true
                textField.cell?.lineBreakMode = .byTruncatingTail
                return textField
            case "team":
                let textField = NSTextField()
                textField.cell = VerticallyCenteredTextFieldCell()
                textField.isEditable = false
                textField.isSelectable = false
                textField.isBezeled = false
                textField.drawsBackground = false
                textField.stringValue = profile.teamName
                textField.identifier = tableColumn.identifier
                textField.cell?.truncatesLastVisibleLine = true
                textField.cell?.lineBreakMode = .byTruncatingTail
                return textField
            case "creation":
                let textField = NSTextField()
                textField.cell = VerticallyCenteredTextFieldCell()
                textField.isEditable = false
                textField.isSelectable = false
                textField.isBezeled = false
                textField.drawsBackground = false
                textField.stringValue = Self.dateFormatter.string(from: profile.creationDate)
                textField.identifier = tableColumn.identifier
                return textField
            case "expiry":
                let textField = NSTextField()
                textField.cell = VerticallyCenteredTextFieldCell()
                textField.isEditable = false
                textField.isSelectable = false
                textField.isBezeled = false
                textField.drawsBackground = false
                textField.stringValue = Self.dateFormatter.string(from: profile.expirationDate)
                textField.textColor = profile.expirationDate < Date() ? .systemRed : .labelColor
                textField.identifier = tableColumn.identifier
                return textField
            case "uuid":
                let textField = NSTextField()
                textField.cell = VerticallyCenteredTextFieldCell()
                textField.isEditable = false
                textField.isSelectable = false
                textField.isBezeled = false
                textField.drawsBackground = false
                textField.stringValue = profile.uuid
                textField.identifier = tableColumn.identifier
                textField.cell?.truncatesLastVisibleLine = true
                textField.cell?.lineBreakMode = .byTruncatingTail
                return textField
            default:
                fatalError()
            }
        }
        
        func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            sortByDescriptors(tableView.sortDescriptors)
            tableView.reloadData()
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            let row = (notification.object as! NSTableView).selectedRow
            guard row != NSNotFound else { 
                parent.selection = nil
                return
            } 
            let element = parent.data[row]
            
            DispatchQueue.main.async {
                self.parent.selection = element.id
            }
        }
        
        func sortByDescriptors(_ sortDescriptors: [NSSortDescriptor]) {
            let elementsAsMutableArray = NSMutableArray(array: parent.data)
            elementsAsMutableArray.sort(using: sortDescriptors)
            if (elementsAsMutableArray as! [ProvisioningProfile]) != parent.data {
                parent.data = elementsAsMutableArray as! [ProvisioningProfile] 
            }
        }

        static let dateFormatter = configure(DateFormatter()) {
            $0.dateStyle = .medium
        }
    }    
}

class VerticallyCenteredTextFieldCell : NSTextFieldCell {
    override func titleRect(forBounds theRect: NSRect) -> NSRect {
        var titleFrame = super.titleRect(forBounds: theRect)
        let titleSize = self.attributedStringValue.size
        titleFrame.origin.y = theRect.origin.y - 1.0 + (theRect.size.height - titleSize().height) / 2.0
        return titleFrame
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let titleRect = self.titleRect(forBounds: cellFrame)
        self.attributedStringValue.draw(in: titleRect)
    }
}

protocol TableViewDelegate: AnyObject {
    func moveToTrash(_ row: Int)
}
