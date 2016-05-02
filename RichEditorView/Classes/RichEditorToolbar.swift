//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import Popover
/**
    RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
    Used to receive actions that need extra work to perform (eg. display some UI)
*/
@objc public protocol RichEditorToolbarDelegate: NSObjectProtocol {

    /**
        Called when the Text Color toolbar item is pressed.
    */
    optional func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar)

    /**
        Called when the Background Color toolbar item is pressed.
    */
    optional func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar)

    /**
        Called when the Insert Image toolbar item is pressed.
    */
    optional func richEditorToolbarInsertImage(toolbar: RichEditorToolbar)

    /**
        Called when the Insert Link toolbar item is pressed.
    */
    optional func richEditorToolbarInsertLink(toolbar: RichEditorToolbar)
}


/**
    RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
*/
public class RichBarButtonItem: UIBarButtonItem {
    public var actionHandler: (Void -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (Void -> Void)? = nil) {
        self.init(image: image, style: .Plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (Void -> Void)? = nil) {
        self.init(title: title, style: .Plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    func buttonWasTapped() {

        actionHandler?()
    }
}




/**
    RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
*/
public class RichEditorToolbar: UIView , UIGestureRecognizerDelegate{

    /**
        The delegate to receive events that cannot be automatically completed
    */
    public weak var delegate: RichEditorToolbarDelegate?

    /**
        A reference to the RichEditorView that it should be performing actions on
    */
    public weak var editor: RichEditorView?

    /**
        The list of options to be displayed on the toolbar
    */
    public var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    private var toolbarScroll: UIScrollView
    public var toolbar: UIToolbar  //db changed
    private var backgroundToolbar: UIToolbar


    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    

    
    private func setup() {

        self.autoresizingMask = .FlexibleWidth

        backgroundToolbar.frame = self.bounds
        backgroundToolbar.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        backgroundToolbar.barTintColor = UIColor.clearColor()
        
        toolbar.autoresizingMask = .FlexibleWidth
       toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
      toolbar.setShadowImage(UIImage(), forToolbarPosition: .Any)

        toolbarScroll.frame = self.bounds
        toolbarScroll.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = UIColor.whiteColor()

        toolbarScroll.addSubview(toolbar)
        

        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    public func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            if let image = option.image() {
                let button = RichBarButtonItem(image: image) { [weak self] in  option.action(self) }
                
                buttons.append(button)
            } else {
                let title = option.title()
                let button = RichBarButtonItem(title: title) { [weak self] in option.action(self) }
                buttons.append(button)
                
            }
            
        }
        toolbar.items = buttons

        let defaultIconWidth: CGFloat = 22
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.valueForKey("view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < self.frame.size.width {
            toolbar.frame.size.width = self.frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
// DB added
    public func setCustomTintColor(color:UIColor) {
        
        toolbar.tintColor = color
    }
    
}

public class DYPopoverBar {
    
    
    public var popover: Popover?
    
    private var popoverOptions:[PopoverOption]
    
    public var options: [RichEditorOption] = [] {
        didSet {
            // update the toolbar
            
            self.updateToolbar()
        }
    }
    
    private var showHandler:(()->())?
    private var dismissHandler:(()->())?
    
    private var launchingToolbar: RichEditorToolbar
    
    private var popoverToolbar:UIToolbar
    //private var backgroundColor: UIColor
    
    public var yCoord:CGFloat?
    public var xCoords = [CGFloat]()
    
    public init(popoverOptions:[PopoverOption], tintColor:UIColor, launchingToolbar:RichEditorToolbar, showHandler: (() -> ())?, dismissHandler: (() -> ())?) {
        
        self.launchingToolbar = launchingToolbar
        self.popoverOptions = popoverOptions
        self.showHandler = showHandler
        self.dismissHandler =  dismissHandler
        
        let rect = CGRectMake(0, 0, 44.0, 44.0)
        self.popoverToolbar = UIToolbar(frame: rect)
        self.popoverToolbar.barStyle = UIBarStyle.Default
        self.popoverToolbar.tintColor = tintColor
        self.popoverToolbar.barTintColor = UIColor.whiteColor()
        
        self.popover = Popover(options: self.popoverOptions, showHandler: self.showHandler, dismissHandler: self.dismissHandler)
    }
    
    
    public func show(point: CGPoint)  {
        
        self.popover?.show(self.popoverToolbar, point: point)
    }
    
    
    
    public func dismiss() {
        
        self.popover?.dismiss()
    }
    
    
    public func updateToolbar() {
        
        var buttons = [UIBarButtonItem]()
        for option in options {
            if let image = option.image() {
                let button = RichBarButtonItem(image: image) { [weak self] in  option.action(self?.launchingToolbar) }
                buttons.append(button)
            } else {
                let title = option.title()
                let button = RichBarButtonItem(title: title) { [weak self] in option.action(self?.launchingToolbar) }
                buttons.append(button)
            }
            
        }
        
        
        popoverToolbar.items = buttons
        
        let defaultIconWidth: CGFloat = 22
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.valueForKey("view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        
        
        print("width: \(width)")
        popoverToolbar.frame.size.width = width
        
        
        
        print("popover toolbar width: \(self.popoverToolbar.frame.size.width)")
        
    }
}

