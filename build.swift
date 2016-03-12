#! /usr/bin/env xcrun swift

/*
	How to build...
	
	```
	$ chmod 755 build.swift
	$ ./build.swift 
	```
	
	...then double click the vbsa app.
*/

import Cocoa

let appName = "vbsa"
let code = appName

print("Extract")
let delim = ("/"+"/"+":")
let me = try! NSString(contentsOfFile: "./build.swift", encoding: NSUTF8StringEncoding)
let scanner = NSScanner(string: me as String)
var appCode: NSString?
scanner.scanUpToString(delim, intoString: nil)
scanner.scanString(delim, intoString: nil)
scanner.scanUpToString(delim, intoString: &appCode)

try! "import Cocoa\n\n\(appCode!)".writeToFile("\(appName).swift", atomically: false, encoding: NSUTF8StringEncoding)

print("Compile")
let compile = NSTask()
compile.launchPath = "/usr/bin/xcrun"
compile.arguments = ["swiftc", "-c", "\(code).swift", "-F", "/System/Library/Frameworks", "-I/usr/include"]
compile.launch()
compile.waitUntilExit()

print("Link")
let link = NSTask()
link.launchPath = "/usr/bin/xcrun"
link.arguments = ["swiftc", "-o", appName, "\(code).o"]
link.launch()
link.waitUntilExit()

print("Build")
let build = NSTask()
build.launchPath = "/bin/mkdir"
build.arguments = ["-p", "\(appName).app/Contents/MacOS"]
build.launch()
build.waitUntilExit()

print("Copy")
let copy = NSTask()
copy.launchPath = "/bin/mv"
copy.arguments = ["\(appName)", "\(appName).app/Contents/MacOS/\(appName)"]
copy.launch()
copy.waitUntilExit()

let plist = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
			"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" +
			"<plist version=\"1.0\">" + 
			"<dict>" +
				"<key>CFBundleDevelopmentRegion</key>" +
				"<string>en_GB</string>" +
				"<key>CFBundleExecutable</key>" +
				"<string>VBSA</string>" +
				"<key>CFBundleIdentifier</key>" +
				"<string>com.empiricalmagic.\(appName)</string>" +
				"<key>CFBundleInfoDictionaryVersion</key>" +
				"<string>6.0</string>" +
				"<key>CFBundlePackageType</key>" +
				"<string>APPL</string>" +
				"<key>CFBundleVersion</key>" +
				"<string>1.0.0</string>" +
				"<key>NSHighResolutionCapable</key>" +
				"<string>True</string>" +
			"</dict>" +
			"</plist>"

try! plist.writeToFile("\(appName).app/Contents/Info.plist", atomically: false, encoding: NSUTF8StringEncoding)

print("Clean")
let clean = NSTask()
clean.launchPath = "/bin/rm"
clean.arguments = ["-f", "\(code).o", "\(code).swift", appName]
clean.launch()
clean.waitUntilExit()

exit(EXIT_SUCCESS)

class EXTRACT {
//:
@objc
class AppController: NSObject {

	let app = NSApplication.sharedApplication()
	let appDelegate = AppDelegate()
	
	override init() {
		
		super.init()
		
		NSLog("Creating AppController...")
		
		app.delegate = appDelegate
		app.setActivationPolicy(.Regular)
		
		app.mainMenu = NSMenu(title: "Menu Bar")
		app.mainMenu?.autoenablesItems = false
		
		// Application Menu
		let applicationMenu = NSMenu(title: "Application")
		
			let aboutItem = NSMenuItem(title: "About Application…", action: #selector(onAbout(_:)), keyEquivalent: "")
			aboutItem.enabled = true
			aboutItem.target = self
			
			let quitItem = NSMenuItem(title: "Quit", action: #selector(onQuit(_:)), keyEquivalent: "q")
			quitItem.enabled = true
			quitItem.target = self
		
		applicationMenu.addItem(aboutItem)	
		applicationMenu.addItem(quitItem)
	
		let applicationMenuItem = NSMenuItem(title: "", action: #selector(nop(_:)), keyEquivalent: "")
		applicationMenuItem.submenu = applicationMenu
		app.mainMenu?.addItem(applicationMenuItem)
	
		// File Menu
		let fileMenu = NSMenu(title: "File")
	
			let newItem = NSMenuItem(title: "New…", action: #selector(onNew(_:)), keyEquivalent: "n")
			newItem.enabled = true
			newItem.target = self
	
		fileMenu.addItem(newItem)
	
		let fileMenuItem = NSMenuItem(title: "", action: #selector(nop(_:)), keyEquivalent: "")
		fileMenuItem.submenu = fileMenu
		app.mainMenu?.addItem(fileMenuItem)
		
		app.run()
    }
    
    @objc
    func onQuit(sender: AnyObject) {
    	app.terminate(nil)
    }
    
	@objc
    func onAbout(sender: AnyObject) {
    
    	NSLog("[\(sender)] About App...\n\tscale: \(NSScreen.mainScreen()?.backingScaleFactor)")
    }
    
	@objc
    func onNew(sender: AnyObject) {
    	NSLog("[\(sender)] New...")
    }
    
	@objc
    func nop(_: AnyObject) {}
}

class AppDelegate: NSObject, NSApplicationDelegate {

	let window = NSWindow()

	let width = 400.0
	let height = 300.0

	func applicationDidFinishLaunching(notification: NSNotification) {
	
		window.makeKeyAndOrderFront(self)
		NSLog("App Did Finish Launching...")
	
		window.setContentSize(NSSize(width: width, height: height))
        window.styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
        window.opaque = false
        window.center()
        window.title = "Very Basic Swift App"
        window.contentView!.wantsLayer = true

        
        window.layoutIfNeeded()
        
        let label = NSTextView(frame: CGRect(x: 0, y: 0, width: width, height: height/2.0))
   		label.drawsBackground = false
    	label.editable = false
    	label.selectable = false
    	
    	let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
    	style.setParagraphStyle(NSParagraphStyle.defaultParagraphStyle())
    	style.alignment = .Center
    	
    	label.textStorage?.setAttributedString(NSAttributedString(string: "Hello World!", attributes: [ NSParagraphStyleAttributeName : style ]))
       	window.contentView!.addSubview(label)
       	
       	window.makeKeyAndOrderFront(self)
       	
       	NSApplication.sharedApplication().activateIgnoringOtherApps(true)
	}
}

private let appController = AppController()
//:
}
