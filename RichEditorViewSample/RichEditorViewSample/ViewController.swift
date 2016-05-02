//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView
import Popover


class ViewController: UIViewController {

    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!
    
    var touchPoint:CGPoint?

    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorOptions.Undo, RichEditorOptions.Redo,  RichEditorOptions.Image]
        toolbar.setCustomTintColor(UIColor.greenColor())
        
        return toolbar
    }()
    
    lazy var popover: DYPopoverBar = {
        
        return DYPopoverBar(popoverOptions:[   .Type(.Up)], tintColor:UIColor.greenColor(), launchingToolbar:self.toolbar, showHandler: nil, dismissHandler: nil)
    }()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        


     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar

        toolbar.delegate = self
        toolbar.editor = editorView

        //,
        
        let textDecoItem = RichEditorOptionItem(image: nil, title: "Deco") { (toolbar) in
            
                let point = CGPoint(x: self.popover.xCoords[0], y: self.popover.yCoord!)
  
               self.popover.options = [RichEditorOptions.Bold, RichEditorOptions.Italic, RichEditorOptions.Underline]
                self.popover.show(point)
            

        }
        

        
        let indent = RichEditorOptionItem(image: nil, title: "Indent") { (toolbar) in
            let point = CGPoint(x: self.popover.xCoords[1], y: self.popover.yCoord!)

            self.popover.options = [RichEditorOptions.AlignLeft, RichEditorOptions.AlignCenter, RichEditorOptions.AlignRight,RichEditorOptions.OrderedList, RichEditorOptions.UnorderedList]
            self.popover.show(point)
            
        }
     

        toolbar.options.insert(indent, atIndex: 2)
        
        toolbar.options.append(textDecoItem)

        let decoButton = self.toolbar.toolbar.items!.last
        let decoView  = decoButton!.valueForKey("view") as? UIView
        self.popover.xCoords.append(decoView!.center.x + 10.0)
        
        
        let indentButton = self.toolbar.toolbar.items![2]
        let indenView = indentButton.valueForKey("view") as? UIView
        self.popover.xCoords.append(indenView!.center.x + 10.0)
        
    }
    
    

    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        print("touches began called")
////        if let touch = touches.first {
////            
////            self.touchPoint = touch.locationInView(self.view)
////
////        }
//        
//    }
//    
//    func handleTap(gesture:UITapGestureRecognizer) {
//        print("handle tap called")
//        self.touchPoint = gesture.locationInView(self.view)
//    }
    
//    
    func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        
        popover.yCoord  = self.view.frame.height - keyboardHeight
   
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.popover.dismiss()
    }
    
//    
//    func keyboardDidShow(notification:NSNotification) {
//        print("keyboad did show")
//        let decoButton = self.toolbar.toolbar.items!.last
//        self.launchItemView = decoButton!.valueForKey("view") as? UIView
//        
//    }

}




extension ViewController: RichEditorDelegate {

    func richEditor(editor: RichEditorView, heightDidChange height: Int) { }

    func richEditor(editor: RichEditorView, contentDidChange content: String) {
      
        self.popover.dismiss()
        
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

    func richEditorTookFocus(editor: RichEditorView) { }
    
    func richEditorLostFocus(editor: RichEditorView) { }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }

    func richEditor(editor: RichEditorView, handleCustomAction content: String) { }
    
}

extension ViewController: RichEditorToolbarDelegate {

    private func randomColor() -> UIColor {
        let colors = [
            UIColor.redColor(),
            UIColor.orangeColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
            UIColor.purpleColor()
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}


