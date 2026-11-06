import Cocoa
import SwiftUI

class ProxyState: ObservableObject {
    @Published var isWiFiActive: Bool = false
    @Published var isUSBActive: Bool = false
    
    // Configurable Host and Port with UserDefaults persistence
    @Published var proxyIP: String {
        didSet {
            UserDefaults.standard.set(proxyIP, forKey: "Proxy5G_IP")
        }
    }
    @Published var proxyPort: String {
        didSet {
            UserDefaults.standard.set(proxyPort, forKey: "Proxy5G_Port")
        }
    }
    
    let defaultIP = "172.20.10.1"
    let defaultPort = "1082"
    
    init() {
        let savedIP = UserDefaults.standard.string(forKey: "Proxy5G_IP")
        let savedPort = UserDefaults.standard.string(forKey: "Proxy5G_Port")
        
        self.proxyIP = savedIP?.isEmpty == false ? savedIP! : "172.20.10.1"
        self.proxyPort = savedPort?.isEmpty == false ? savedPort! : "1082"
    }
    
    var isActive: Bool {
        return isWiFiActive || isUSBActive
    }
    
    func resetToDefaults() {
        proxyIP = defaultIP
        proxyPort = defaultPort
        if isActive {
            setAll(true)
        }
    }
    
    func refresh() {
        let wifi = runCommand("/usr/sbin/networksetup", ["-getwebproxy", "Wi-Fi"]).contains("Enabled: Yes")
        let usb = runCommand("/usr/sbin/networksetup", ["-getwebproxy", "iPhone USB"]).contains("Enabled: Yes")
        DispatchQueue.main.async {
            self.isWiFiActive = wifi
            self.isUSBActive = usb
        }
    }
    
    func toggleAll() {
        if isActive {
            setAll(false)
        } else {
            setAll(true)
        }
    }
    
    func setAll(_ enable: Bool) {
        let ip = proxyIP.trimmingCharacters(in: .whitespacesAndNewlines)
        let port = proxyPort.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if enable {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxy", "iPhone USB", ip, port])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxy", "iPhone USB", ip, port])
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxy", "Wi-Fi", ip, port])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxy", "Wi-Fi", ip, port])
            sendNotification(title: "Proxy 5G", body: "Connected to iPhone proxy (\(ip):\(port))")
        } else {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxystate", "iPhone USB", "off"])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxystate", "iPhone USB", "off"])
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxystate", "Wi-Fi", "off"])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxystate", "Wi-Fi", "off"])
            sendNotification(title: "Proxy 5G", body: "Proxy disconnected (Reverted to direct network)")
        }
        refresh()
    }
    
    func toggleWiFi() {
        let ip = proxyIP.trimmingCharacters(in: .whitespacesAndNewlines)
        let port = proxyPort.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isWiFiActive {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxystate", "Wi-Fi", "off"])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxystate", "Wi-Fi", "off"])
        } else {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxy", "Wi-Fi", ip, port])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxy", "Wi-Fi", ip, port])
        }
        refresh()
    }
    
    func toggleUSB() {
        let ip = proxyIP.trimmingCharacters(in: .whitespacesAndNewlines)
        let port = proxyPort.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isUSBActive {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxystate", "iPhone USB", "off"])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxystate", "iPhone USB", "off"])
        } else {
            _ = runCommand("/usr/sbin/networksetup", ["-setwebproxy", "iPhone USB", ip, port])
            _ = runCommand("/usr/sbin/networksetup", ["-setsecurewebproxy", "iPhone USB", ip, port])
        }
        refresh()
    }
    
    func applyCustomConfig() {
        if isActive {
            setAll(true)
        }
    }
    
    func runCommand(_ path: String, _ args: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func sendNotification(title: String, body: String) {
        let script = "display notification \"\(body)\" with title \"\(title)\""
        _ = runCommand("/usr/bin/osascript", ["-e", script])
    }
}

struct ProxyPopoverView: View {
    @ObservedObject var state: ProxyState
    @State private var showSettings: Bool = false
    @State private var tempIP: String = ""
    @State private var tempPort: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Card
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 44, height: 44)
                    Image(systemName: "personalhotspot")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Proxy 5G")
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                        
                        // Settings Gear Toggle
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                if !showSettings {
                                    tempIP = state.proxyIP
                                    tempPort = state.proxyPort
                                }
                                showSettings.toggle()
                            }
                        }) {
                            Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(showSettings ? .accentColor : .secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Configure Proxy Server IP and Port")
                    }
                    
                    HStack(spacing: 5) {
                        Circle()
                            .fill(state.isActive ? Color.green : Color.secondary.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text(state.isActive ? "\(state.proxyIP):\(state.proxyPort)" : "Disconnected")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer(minLength: 8)
                
                Toggle("", isOn: Binding(
                    get: { state.isActive },
                    set: { _ in state.toggleAll() }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .labelsHidden()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
            )
            
            // Modern Settings Card (Collapsible)
            if showSettings {
                VStack(spacing: 10) {
                    HStack {
                        Label("SERVER SETTINGS", systemImage: "slider.horizontal.3")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 8) {
                        // IP Address Field
                        HStack(spacing: 6) {
                            Image(systemName: "network")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            TextField("172.20.10.1", text: $tempIP)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.textBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.secondary.opacity(0.25), lineWidth: 0.8)
                                )
                        )
                        
                        // Port Field
                        HStack(spacing: 4) {
                            Image(systemName: "number")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            TextField("1082", text: $tempPort)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        .frame(width: 76)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.textBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.secondary.opacity(0.25), lineWidth: 0.8)
                                )
                        )
                    }
                    
                    HStack {
                        Button(action: {
                            tempIP = state.defaultIP
                            tempPort = state.defaultPort
                            state.resetToDefaults()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Default")
                            }
                            .font(.system(size: 10))
                        }
                        .buttonStyle(.link)
                        
                        Spacer()
                        
                        Button(action: {
                            state.proxyIP = tempIP.trimmingCharacters(in: .whitespacesAndNewlines)
                            state.proxyPort = tempPort.trimmingCharacters(in: .whitespacesAndNewlines)
                            state.applyCustomConfig()
                            withAnimation(.spring(response: 0.25)) {
                                showSettings = false
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                Text("Save & Apply")
                            }
                            .font(.system(size: 11, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Interfaces List Card
            VStack(spacing: 8) {
                // Wi-Fi Row
                HStack {
                    Label("Wi-Fi", systemImage: "wifi")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text(state.isWiFiActive ? "Connected" : "Off")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Button(action: { state.toggleWiFi() }) {
                        Image(systemName: state.isWiFiActive ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 15))
                            .foregroundColor(state.isWiFiActive ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                // iPhone USB Row
                HStack {
                    Label("iPhone USB", systemImage: "cable.connector")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text(state.isUSBActive ? "Connected" : "Off")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Button(action: { state.toggleUSB() }) {
                        Image(systemName: state.isUSBActive ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 15))
                            .foregroundColor(state.isUSBActive ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor).opacity(0.6))
            )
            
            // Quick Action Buttons
            HStack(spacing: 8) {
                Button(action: { state.setAll(true) }) {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                        Text("Turn On All")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(action: { state.setAll(false) }) {
                    HStack(spacing: 5) {
                        Image(systemName: "power")
                        Text("Turn Off All")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
            }
            
            // Footer
            HStack {
                Text("Proxy 5G v1.0.0")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { NSApp.terminate(nil) }) {
                    Text("Quit")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 320)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    let state = ProxyState()
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ProxyPopoverView(state: state))
        
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        state.refresh()
        updateMenuBarIcon()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.state.refresh()
            self?.updateMenuBarIcon()
        }
    }
    
    func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }
        let active = state.isActive
        
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: active ? .semibold : .regular)
        let symbol = NSImage(systemSymbolName: "personalhotspot", accessibilityDescription: "Proxy5G")?.withSymbolConfiguration(config)
        symbol?.isTemplate = true
        button.image = symbol
        
        if active {
            button.attributedTitle = NSAttributedString(string: " 5G", attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 12, weight: .semibold)
            ])
        } else {
            button.attributedTitle = NSAttributedString(string: " 5G", attributes: [
                .foregroundColor: NSColor.secondaryLabelColor,
                .font: NSFont.systemFont(ofSize: 12, weight: .regular)
            ])
        }
        button.imagePosition = .imageLeft
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            state.refresh()
            updateMenuBarIcon()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
