import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Apri l'app ingrandita a schermo intero per un uso da "monitor informativo".
    // In questo modo la finestra occupa tutta la superficie disponibile.
    if let screen = NSScreen.main {
      setFrame(screen.visibleFrame, display: true, animate: true)
    }
  }
}
