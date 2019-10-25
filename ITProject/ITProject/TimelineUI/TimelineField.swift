//
//  TimelineField.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/20.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

public struct TimelineField
{
	/// The date that the event occured.
	let date: String

	/// A description of the event.
	let content: String?

	/// An optional image to show with the text and the date in the timeline.
	let image: UIImage?
    
    /// An optional action when tap the image
	let imageTapped: ((UIImage) -> Void)?
    
    /// Initializes the timelinefield with all information needed for a complete setup.
    ///
    /// - Parameter date: date
    /// - Parameter content: content information
    /// - Parameter image: image
    /// - Parameter imageTapped: a image tapped action
	public init(date: String,
                content: String? = nil,
                image: UIImage? = nil,
                imageTapped: ((UIImage) -> Void)? = nil)
	{
		self.date = date
		self.content = content
		self.image = image
		self.imageTapped = imageTapped
	}
}
