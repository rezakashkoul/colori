//
//  ViewController.swift
//  colori
//
//  Created by Reza Kashkoul on 16-Esfand-1400 .
//

import UIKit

class ViewController: UIViewController {
    
    var numberOfButtonColorsInPaletteList = 15
    let subViewSize: Int = 50
    var buttonColors = [UIColor]()
    var currentButtonIndex: Int = 1
    var undoList = [UIView]()
    var redoList = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        senseTapsByGestureRecoginzer()
        setupColorPalette()
    }
    
    func setupNavigationBar() {
        let redoButton = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redoButtonAction))
        let undoButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoButtonAction))
        navigationItem.rightBarButtonItems = [undoButton, redoButton]
    }
    
    @objc func redoButtonAction() {
        if let subView = redoList.last {
            undoList.append(subView)
            view.addSubview(subView)
            redoList = redoList.dropLast()
        }
    }
    
    @objc func undoButtonAction() {
        guard let last = undoList.last else { return }
        for subView in view.subviews {
            if subView == last {
                redoList.append(subView as! UILabel)
                subView.removeFromSuperview()
            }
        }
        undoList = undoList.dropLast()
    }
    
    func senseTapsByGestureRecoginzer() {
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapScreenAction))
        view.addGestureRecognizer(touch)
    }
    
    func insertSubView(screenLocation: CGPoint) {
        redoList = []
        let size = CGSize(width: subViewSize, height: subViewSize)
        let position = CGPoint(x: Int(screenLocation.x) - (subViewSize / 2), y: Int(screenLocation.y) - (subViewSize / 2))
        let label = UILabel(frame: CGRect(origin: position, size: size))
        label.backgroundColor = buttonColors[currentButtonIndex]
        label.textColor = .white
        label.textAlignment = .center
        label.text = view.subviews.filter({ subview in
            subview.backgroundColor == buttonColors[currentButtonIndex]}).count.description
        view.addSubview(label)
        undoList.append(label)
    }
    
    @objc func tapScreenAction(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        insertSubView(screenLocation: location)
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

