//
//  ViewController.swift
//  colori
//
//  Created by Reza Kashkoul on 16-Esfand-1400 .
//

import UIKit

class ViewController: UIViewController {
     
    @IBOutlet weak var memoryLabel: UILabel!
    
    let numberOfButtonColorsInPaletteList = 10
    let squareSize: Int = 45
    var buttonColors = [UIColor]()
    var undoList = [UILabel]()
    var redoList = [UILabel]()
    var currentButtonIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportMemory()
        setupNavigationBar()
        senseTapsByGestureRecoginzer()
        setupColorPalette()
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = .white
    }
    
    @objc func redoButtonAction() {
        if let subView = redoList.last {
            undoList.append(subView)
            view.addSubview(subView)
            redoList = redoList.dropLast()
        }
        reportMemory()
    }
    
    @objc func undoButtonAction() {
        guard let last = undoList.last else { return }
        for subView in view.subviews {
            if subView == last {
                redoList.append(subView as! UILabel)
                subView.removeFromSuperview()
            }
            reportMemory()
        }
        undoList = undoList.dropLast()
    }
    
    @objc func clearAllAction() {
        for subview in view.subviews as [UIView] {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }
        reportMemory()
    }
    
    @objc func tapScreenAction(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        insertSubView(screenCoordinate: location)
        reportMemory()
    }
    
    func setupNavigationBar() {
        reportMemory()
        let redoButton = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redoButtonAction))
        let undoButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoButtonAction))
        navigationItem.rightBarButtonItems = [undoButton, redoButton]
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearAllAction))
        self.navigationItem.leftBarButtonItem = clearButton
    }
    
    func senseTapsByGestureRecoginzer() {
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapScreenAction))
        view.addGestureRecognizer(touch)
    }
    
    func insertSubView(screenCoordinate: CGPoint) {
        redoList = [] // must be empty
        let size = CGSize(width: squareSize, height: squareSize)
        let position = CGPoint(x: Int(screenCoordinate.x) - (squareSize/2), y: Int(screenCoordinate.y) - (squareSize/2))
        let label = UILabel(frame: CGRect(origin: position, size: size))
        label.textColor = .white
        label.textAlignment = .center
        label.text = view.subviews.filter({$0.backgroundColor == buttonColors[currentButtonIndex]}).count.description
        label.backgroundColor = buttonColors[currentButtonIndex]
        view.addSubview(label)
        undoList.append(label)
    }
    
    func setupColorPalette() {
        let width = UIScreen.main.bounds.width / CGFloat(numberOfButtonColorsInPaletteList)
        let height = width
        for i in 0..<numberOfButtonColorsInPaletteList {
            let position = CGPoint(x: width * CGFloat(i), y: UIScreen.main.bounds.height - (2.5 * height))
            let buttonSize = CGSize(width: width, height: height)
            let buttonColor = UIColor.random
            let button = UIButton(frame: CGRect(origin: position, size: buttonSize))
            button.backgroundColor = buttonColor
            buttonColors.append(buttonColor)
            button.tag = i
            button.addTarget(self, action: #selector(bottomButtonsAction), for: .touchUpInside)
            view.addSubview(button)
        }
        setPaletteButtonsTitle()
    }
    
    func setPaletteButtonsTitle() {
        for subview in self.view.subviews {
            if subview is UIButton {
                let button = subview as! UIButton
                button.setTitle("", for: .normal)
                if button.tag == currentButtonIndex {
                    button.setTitle("✅", for: .normal)
                }
            }
        }
    }
    
    @objc func bottomButtonsAction(sender: UIButton) {
        currentButtonIndex = sender.tag
        setPaletteButtonsTitle()
    }
    
    func reportMemory() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            print("Memory used in bytes: \(taskInfo.resident_size)")
//            memoryLabel.text = "\(taskInfo.resident_size)"
            title  = "\(taskInfo.resident_size)"
        }
        else {
            print("Error with task_info(): " +
                  (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            title = "\(String(describing: mach_error_string(kerr)))"
//            memoryLabel.text = "\(String(describing: mach_error_string(kerr)))"

        }
    }
    
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

