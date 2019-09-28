//
//  TimelineView.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/20.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class TimelineView: UIView {
    
    // MARK:- Public Properties

    /// The events shown in the Timeline
    open var timelineField: [TimelineField] {
        didSet {
            setupContent()
        }
    }

    /// The color of the bullets and the lines connecting them.
    open var lineColor: UIColor = UIColor.lightGray {
        didSet {
            setupContent()
        }
    }

    /// Configures the date labels in the timeline.
    open var configureDateLabel: ((UILabel) -> Void) = { label in
        label.font = UIFont(name: "ArialMT", size: 20)
        label.textColor = UIColor(red: 0 / 255, green: 180 / 255, blue: 160 / 255, alpha: 1)
    } {
        didSet {
            setupContent()
        }
    }

    /// Configures the date labels in the timeline.
    open var configureTextLabel: ((UILabel) -> Void) = { label in
        label.font = UIFont(name: "ArialMT", size: 16)
        label.textColor = UIColor(red: 110 / 255, green: 110 / 255, blue: 110 / 255, alpha: 1)
    } {
        didSet {
            setupContent()
        }
    }

    /// The width and height of the bullets
    open var timelinePointRadius: CGFloat = 18 {
        didSet {
            setupContent()
        }
    }
    

    // MARK:- Public Methods

    /// Initializes the timeline with all information needed for a complete setup.
    ///
    /// - Parameter timeFrames: A list of TimeFrame
    public init(timeFrames: [TimelineField]) {
        timelineField = timeFrames
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        setupContent()
    }

    public required init?(coder aDecoder: NSCoder) {
        timelineField = []
        super.init(coder: aDecoder)
    }

    // MARK:- Private Methods

    private func setupContent() {
        for v in subviews {
            v.removeFromSuperview()
        }

        let viewFromAbove = setupGuideView()

        setupTimeline(viewFromAbove: viewFromAbove)
    }

    private func setupTimelinePoint(_ width: CGFloat) -> UIView {
        // draw timeline point

        let shapeLayer = drawCirclePoint(pointRadius: width)

        let timePointView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))

        timePointView.translatesAutoresizingMaskIntoConstraints = false
        timePointView.addConstraints([
            NSLayoutConstraint(item: timePointView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width),
            NSLayoutConstraint(item: timePointView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width),
        ])
        timePointView.layer.addSublayer(shapeLayer)
        return timePointView
    }

    fileprivate func blockForTimeFrame(_ element: TimelineField,
                                       isFirst: Bool = false,
                                       isLast: Bool = false) -> UIView {
        let blockView = UIView()
        blockView.translatesAutoresizingMaskIntoConstraints = false
        blockView.addConstraint(NSLayoutConstraint(item: blockView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: timelinePointRadius))

        // bullet
        let timelinePoint = setupTimePointInBlockView(blockView: blockView)

        //top line, if necessary
        if !isFirst {
            setupTopLineView(blockView: blockView, timelinePoint: timelinePoint)
        }
        
        
        // date label
        let dateLabel = setupDateLabel(blockView: blockView, timelinePoint: timelinePoint, element: element)

        // lastView
        var lastView: UIView = dateLabel
        if let content = element.content {
            let textLabel = setupTextContentView(blockView: blockView, dateLabel: dateLabel, content: content)
            lastView = textLabel
        }
        
        // imageContent
        if let image = element.image {
            let backgroundViewForImage = setupBackgroundImageView(blockView: blockView, lastView: lastView, dateLabel: dateLabel)

            setupImageContentView(blockView: blockView, backgroundViewForImage: backgroundViewForImage, image: image)

            setupButton(blockView: blockView, element: element, image: image)
            
        } else {
            blockView.addConstraint(NSLayoutConstraint(item: lastView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: blockView, attribute: .bottom, multiplier: 1.0, constant: -20))
        }

        // draw the bottom line between the bullets
        let line = setupTimelineBottom(blockView: blockView, timelinePoint: timelinePoint)
        
        if isLast {
            let extraSpace: CGFloat = 2000
            blockView.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: blockView, attribute: .height, multiplier: 1.0, constant: extraSpace))
        } else {
            blockView.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: blockView, attribute: .height, multiplier: 1.0, constant: -timelinePointRadius))
        }

        blockView.addConstraint(NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: timelinePoint, attribute: .centerX, multiplier: 1.0, constant: 0))

        return blockView
    }
    
    // MARK:- Set Up Detail
    private func setupGuideView() -> UIView {
        let guideView = UIView()
        guideView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(guideView)
        addConstraints([
            NSLayoutConstraint(item: guideView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 24),
            NSLayoutConstraint(item: guideView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: guideView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: guideView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0),
        ])
        return guideView
    }

    private func setupTimeline(viewFromAbove: UIView) {
        var viewFromAbove = viewFromAbove
        for (index, element) in timelineField.enumerated() {
            let v = blockForTimeFrame(element, isFirst: index == 0, isLast: index == timelineField.count - 1)
            addSubview(v)
            addConstraints([
                NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: viewFromAbove, attribute: .bottom, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: v, attribute: .width, relatedBy: .equal, toItem: viewFromAbove, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: viewFromAbove, attribute: .leading, multiplier: 1.0, constant: 0),
            ])
            viewFromAbove = v
        }

        addConstraint(NSLayoutConstraint(item: viewFromAbove, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
    }

    // draw timeline point
    ///
    /// - Parameter pointWidth: timeline point width
    private func drawCirclePoint(pointRadius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(ovalOfSize: pointRadius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.path = path.cgPath

        return shapeLayer
    }

    func setupTimePointInBlockView(blockView : UIView) -> UIView {
        let timelinePoint: UIView = setupTimelinePoint(timelinePointRadius)
        
        blockView.addSubview(timelinePoint)
        blockView.addConstraints([
            NSLayoutConstraint(item: timelinePoint, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: blockView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timelinePoint, attribute: .leading, relatedBy: .equal, toItem: blockView, attribute: .leading, multiplier: 1.0, constant: 8),
        ])
        return timelinePoint
    }

    func setupTopLineView(blockView : UIView, timelinePoint: UIView) {
        let topLine = UIView()
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.backgroundColor = lineColor
        blockView.addSubview(topLine)
        sendSubviewToBack(topLine)
        blockView.addConstraints([
            NSLayoutConstraint(item: topLine, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1),
            NSLayoutConstraint(item: topLine, attribute: .top, relatedBy: .equal, toItem: blockView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: topLine, attribute: .bottom, relatedBy: .equal, toItem: timelinePoint, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: topLine, attribute: .centerX, relatedBy: .equal, toItem: timelinePoint, attribute: .centerX, multiplier: 1.0, constant: 0),
        ])
    }

    func setupDateLabel(blockView: UIView,
                        timelinePoint: UIView,
                        element: TimelineField) -> UILabel{
        
        let dateLabel = UILabel()
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.text = element.date
        dateLabel.numberOfLines = 1
        configureDateLabel(dateLabel)
        blockView.addSubview(dateLabel)
        blockView.addConstraints([
            NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: blockView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .leading, relatedBy: .equal, toItem: timelinePoint, attribute: .trailing, multiplier: 1.0, constant: 8),
            NSLayoutConstraint(item: dateLabel, attribute: .trailing, relatedBy: .equal, toItem: blockView, attribute: .trailing, multiplier: 1.0, constant: -16),
            NSLayoutConstraint(item: dateLabel, attribute: .centerY, relatedBy: .equal, toItem: timelinePoint, attribute: .centerY, multiplier: 1.0, constant: 1),
        ])
        dateLabel.textAlignment = .natural
        
        return dateLabel
    }

    func setupTextContentView(blockView : UIView,
                              dateLabel : UILabel,
                              content : String) -> UILabel{
        
        let textLabel = UILabel()
        
       textLabel.translatesAutoresizingMaskIntoConstraints = false
       textLabel.text = content
       textLabel.numberOfLines = 0
       configureTextLabel(textLabel)
       blockView.addSubview(textLabel)
       blockView.addConstraints([
           NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
           NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: dateLabel, attribute: .bottom, multiplier: 1.0, constant: 6),
           NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .leading, multiplier: 1.0, constant: 0),
       ])
        textLabel.textAlignment = .natural
        
        return textLabel
    }

    func setupBackgroundImageView(blockView: UIView,
                                  lastView: UIView,
                                  dateLabel: UILabel) -> UIView{
        let backgroundViewForImage = UIView()
        backgroundViewForImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundViewForImage.backgroundColor = UIColor.black
        backgroundViewForImage.layer.cornerRadius = 10
        blockView.addSubview(backgroundViewForImage)
        blockView.addConstraints([
            NSLayoutConstraint(item: backgroundViewForImage, attribute: .trailing, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: backgroundViewForImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 130),
            NSLayoutConstraint(item: backgroundViewForImage, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: backgroundViewForImage, attribute: .bottom, relatedBy: .equal, toItem: blockView, attribute: .bottom, multiplier: 1.0, constant: -10),
            NSLayoutConstraint(item: backgroundViewForImage, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .leading, multiplier: 1.0, constant: 0),
        ])
        
        return backgroundViewForImage
    }

    func setupImageContentView(blockView: UIView,
                               backgroundViewForImage: UIView,
                               image: UIImage){
        let imageView = UIImageView(image: image)
                   imageView.layer.cornerRadius = 10
                   imageView.translatesAutoresizingMaskIntoConstraints = false
                   imageView.contentMode = UIView.ContentMode.scaleAspectFit
                   blockView.addSubview(imageView)
                   blockView.addConstraints([
                       NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .left, multiplier: 1.0, constant: 0),
                       NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .right, multiplier: 1.0, constant: 0),
                       NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .top, multiplier: 1.0, constant: 0),
                       NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: backgroundViewForImage, attribute: .bottom, multiplier: 1.0, constant: 0),
                   ])

    }
    
    private func setupButton(blockView: UIView,
                             element: TimelineField,
                             image: UIImage){
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.addTargetClosure {
            element.imageTapped?(image)
        }
        blockView.addSubview(button)
        blockView.addConstraints([
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: blockView, attribute: .width, multiplier: 1.0, constant: -60),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 130),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: blockView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: blockView, attribute: .leading, multiplier: 1.0, constant: 40),
        ])
    }
    
    private func setupTimelineBottom(blockView: UIView,
                                     timelinePoint: UIView) -> UIView{
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = lineColor
        blockView.addSubview(line)
        sendSubviewToBack(line)
        blockView.addConstraints([
            NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1),
            NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: timelinePoint, attribute: .bottom, multiplier: 1.0, constant: 0),
        ])
        return line
    }

}

extension UIBezierPath
{
	convenience init(ovalOfSize width: CGFloat)
	{
		self.init(ovalIn: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width)))
	}
}

private typealias UIButtonTargetClosure = () -> Void

private class ClosureWrapper: NSObject
{
	let closure: UIButtonTargetClosure
	init(_ closure: @escaping UIButtonTargetClosure)
	{
		self.closure = closure
	}
}

private extension UIButton
{
	private struct AssociatedKeys
	{
		static var targetClosure = "targetClosure"
	}

	private var targetClosure: UIButtonTargetClosure?
	{
		get
		{
			guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
			return closureWrapper.closure
		}
		set(newValue)
		{
			guard let newValue = newValue else { return }
			objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	func addTargetClosure(closure: @escaping UIButtonTargetClosure)
	{
		self.targetClosure = closure
		addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
	}

	@objc func closureAction()
	{
		guard let targetClosure = targetClosure else { return }
		targetClosure()
	}
}
