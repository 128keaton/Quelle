import Foundation
import Cocoa
protocol DestinationViewDelegate {
    func process(path: String)

}
class DestinationView: NSView {
    private var isHighlighed: Bool! = false
    private var label: NSTextField?
    private var imageView: NSImageView?

    var delegate: DestinationViewDelegate?

    var imageBackground: NSImage? = nil
    var labelText: String? = "drag project folder here"
    var conformanceType: String? = String(kUTTypeFolder)
    override func awakeFromNib() {
        self.register(forDraggedTypes: [NSFilenamesPboardType])

    }
    func isHighlighted() -> Bool! {
        return self.isHighlighed
    }
    func setHighlighted(value: Bool) {
        self.isHighlighed = value
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let path = NSBezierPath(roundedRect: NSInsetRect(bounds, 10, 10), xRadius: 10, yRadius: 10)
        NSColor.white.set()
        path.fill()
        if label == nil {


            label = NSTextField.init(frame: dirtyRect)
            label?.isBordered = false
            label?.isEditable = false
            label?.drawsBackground = false

            label?.alignment = .center
            label?.cell = VerticallyCenteredTextFieldCell()
            label?.cell?.title = self.labelText!
            label?.cell?.alignment = .center
            label?.cell?.drawInterior(withFrame: dirtyRect, in: self)
            label?.textColor = NSColor.gray
            self.addSubview(label!)
        }
        if self.imageBackground != nil && self.imageView == nil{
            imageView = NSImageView.init(frame: CGRect(x: dirtyRect.width / 2 - 30, y: dirtyRect.height / 2 - 30, width: 60, height: 60))
            label?.removeFromSuperview()
            imageView?.image = self.imageBackground
            
            self.addSubview(imageView!)
        }

        if self.isHighlighed == true {
            NSBezierPath.setDefaultLineWidth(6.0)
            NSColor.keyboardFocusIndicatorColor.set()
            NSBezierPath.stroke(dirtyRect)

        }
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteBoard = sender.draggingPasteboard()
        if (pasteBoard.types?.contains(NSFilenamesPboardType))! {
            let paths = pasteBoard.propertyList(forType: NSFilenamesPboardType) as! [String]
            for path in paths {

                let utiType = try! NSWorkspace.shared().type(ofFile: path)


                if !NSWorkspace.shared().type(utiType, conformsToType: (self.conformanceType)!) {
                    self.setHighlighted(value: false)
                    return []
                }

            }
        }
        NSCursor.dragCopy().set()
        self.setHighlighted(value: true)
        return NSDragOperation.every

    }
    override func draggingExited(_ sender: NSDraggingInfo?) {
        NSCursor.arrow().set()
        self.setHighlighted(value: false)
    }
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.setHighlighted(value: false)
        return true
    }
    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        let files = sender?.draggingPasteboard().propertyList(forType: NSFilenamesPboardType)
        Swift.print(files ?? "No files")
        let url = URL(string: (files as! [String])[0])

        self.delegate?.process(path: (url?.path)!)


        self.label?.stringValue = (url?.lastPathComponent)!
    }
}
