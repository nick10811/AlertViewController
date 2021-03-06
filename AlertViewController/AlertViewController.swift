//
//  AlertViewController.swift
//  AlertViewController
//
//  Created by Michael Inger on 26/07/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//
//  Revised by Nick Yang (nick10811) on 08/05/2020.

import UIKit

/// Adds ability to display `UIImage` above the title label of `UIAlertController`.
/// Functionality is achieved by adding “\n” characters to `title`, to make space
/// for `UIImageView` to be added to `UIAlertController.view`. Set `title` as
/// normal but when retrieving value use `originalTitle` property.
class AlertController: UIAlertController {
    /// - Return: value that was set on `title`
    private(set) var originalTitle: String?
    private(set) var originalMessage: String?
    private var spaceAdjustedText: String = ""
    private weak var imageView: UIImageView? = nil
    private var imagePosition: ImagePosition = .top
    private var previousImgViewSize: CGSize = .zero
    
    private var originalTitleHeight: CGFloat {
        get {
            return getDefaultLabel(originalTitle, font: titleFont).frame.height
        }
    }
    
    private var originalMessageHeight: CGFloat {
        get {
            return getDefaultLabel(originalMessage, font: messageFont).frame.height
        }
    }
    
    override var title: String? {
        didSet {
            // Keep track of original title
            if title != spaceAdjustedText {
                originalTitle = title
            }
        }
    }
    
    override var message: String? {
        didSet {
            // Keep track of original message
            if message != spaceAdjustedText {
                originalMessage = message
            }
        }
    }
    
    /// - parameter image: `UIImage` to be displayed about title label
    func setTitleImage(_ image: UIImage?, position: ImagePosition = .top) {
        self.imagePosition = position
        
        guard let imageView = self.imageView else {
            let imageView = UIImageView(image: image)
            self.view.addSubview(imageView)
            self.imageView = imageView
            return
        }
        imageView.image = image
    }
    
    // MARK: -  Layout code
    
    override func viewDidLayoutSubviews() {
        guard let imageView = imageView else {
            super.viewDidLayoutSubviews()
            return
        }
        // Automatically resize `imageView`
        self.resizeImage(for: imageView)
        
        // Adjust title if image size has changed
        if previousImgViewSize != imageView.bounds.size {
            previousImgViewSize = imageView.bounds.size
            adjustText(for: imageView)
        }
        // Position `imageView`
        let linesCount = newLinesCount(for: imageView)
        let padding = Constants.padding(for: preferredStyle)
        imageView.center.x = view.bounds.width / 2.0
        // count height of Text to move the position y of image
        switch imagePosition {
        case .top:
            imageView.center.y = padding + linesCount * lineHeight / 2.0
        case .center:
            imageView.center.y = padding + originalTitleHeight + linesCount * lineHeight / 2.0
        case .bottom:
            imageView.center.y = padding + originalTitleHeight + originalMessageHeight + linesCount * lineHeight / 2.0
        }
        super.viewDidLayoutSubviews()
    }
    
    /// Adds appropriate number of '\n' to text to make space for `imageView`
    private func adjustText(for imageView: UIImageView) {
        let linesCount = Int(newLinesCount(for: imageView))
        let lines = (0..<linesCount).map({ _ in "\n" }).reduce("", +)
        
        switch imagePosition {
        case .top:
            spaceAdjustedText = lines + (originalTitle ?? "")
            title = spaceAdjustedText
        case .center:
            spaceAdjustedText = (originalTitle ?? "") + lines
            title = spaceAdjustedText
        case .bottom:
            spaceAdjustedText = (originalMessage ?? "") + lines
            message = spaceAdjustedText
        }
    }
    
    /// - Resize image
    private func resizeImage(for imageView: UIImageView) {
        let ratio: CGFloat = 0.8
        let originalHeight = imageView.frame.height
        let originalWidth = imageView.frame.width
        let realWidth = self.view.frame.width * ratio
        if originalWidth > realWidth {
            imageView.frame = CGRect(x: 0, y: 0, width: realWidth, height: (originalHeight/originalWidth)*realWidth)
        }
    }
    
    /// - Return: Number new line chars needed to make enough space for `imageView`
    private func newLinesCount(for imageView: UIImageView) -> CGFloat {
        return ceil(imageView.bounds.height / lineHeight)
    }
    
    /// Calculated based on system font line height
    private lazy var lineHeight: CGFloat = {
        switch imagePosition {
        case .top, .center:
            return titleFont.pointSize
        case .bottom:
            return messageFont.pointSize
        }
    }()
    
    /// Default font
    private lazy var titleFont: UIFont = {
        let style: UIFontTextStyle = self.preferredStyle == .alert ? .headline : .callout
        return UIFont.preferredFont(forTextStyle: style)
    }()

    private lazy var messageFont: UIFont = {
        return UIFont.preferredFont(forTextStyle: .subheadline)
    }()
    
    private func getDefaultLabel(_ text: String?, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = font
        label.frame = CGRect(x: 0, y: 0, width: 243, height: 20)
        label.sizeToFit()
        return label
    }
    
    struct Constants {
        static var paddingAlert: CGFloat = 22
        static var paddingSheet: CGFloat = 11
        static func padding(for style: UIAlertControllerStyle) -> CGFloat {
            return style == .alert ? Constants.paddingAlert : Constants.paddingSheet
        }
    }
    
    enum ImagePosition {
        case top, center, bottom
    }
}
