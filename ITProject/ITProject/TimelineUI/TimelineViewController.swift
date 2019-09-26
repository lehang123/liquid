//
//  TimelineViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/20.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController
{
	var scrollView: UIScrollView!
	var timeline: TimelineView!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.scrollView = UIScrollView(frame: view.bounds)
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.scrollView)

		NSLayoutConstraint.activate([
			NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 29),
			NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0),
		])

<<<<<<< HEAD
        timeline = TimelineView(timeFrames: [
            TimelineField(date: "January 1", content: "New Year's Day", image: UIImage(named: "tempProfileImage")),
            TimelineField(date: "February 14", content: "The month of love!", image: UIImage(named: "heartIcon")),
            TimelineField(date: "March", content: "Comes like a lion, leaves like a lamb", image: nil),
            TimelineField(date: "April 1", content: "Dumb stupid pranks.", image: UIImage(named: "eye")),
            TimelineField(date: "No image?", content: "That's right. No image is necessary!"),
            TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
            TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
            TimelineField(date: "That's it!"),
        ])
        timeline.timelinePointRadius = 16
        scrollView.addSubview(timeline)
        scrollView.addConstraints([
            NSLayoutConstraint(item: timeline, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
        ])
=======
		self.timeline = TimelineView(timeFrames: [
			TimelineField(date: "January 1", content: "New Year's Day", image: UIImage(named: "tempProfileImage")),
			TimelineField(date: "February 14", content: "The month of love!", image: UIImage(named: "heartIcon")),
			TimelineField(date: "March", content: "Comes like a lion, leaves like a lamb", image: nil),
			TimelineField(date: "April 1", content: "Dumb stupid pranks.", image: UIImage(named: "eye")),
			TimelineField(date: "No image?", content: "That's right. No image is necessary!"),
			TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
			TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
			TimelineField(date: "That's it!"),
		])
		self.timeline.bulletSize = 16
		self.scrollView.addSubview(self.timeline)
		self.scrollView.addConstraints([
			NSLayoutConstraint(item: timeline, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: timeline, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: timeline, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: timeline, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: timeline, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
		])
>>>>>>> 6ac34471b0bb0e72c0a8d019058571ae055297a5

		view.sendSubviewToBack(self.scrollView)
	}
}
