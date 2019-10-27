//
//  ShowDetailPhotoViewController.swift
//  ITProject
//
//  Created by Zhu Chenghong on 2019/9/10.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

/// This view controller is mainly show the actually size of the selected picture
/// Users can zoom in and zoom out for detail of the picture
class ShowDetailPhotoViewController: UIViewController, UIScrollViewDelegate
{
	// MARK: - Properties
	var selectedImage: UIImage!
	var cumulativeScale: CGFloat = 1.0
	var maxScale: CGFloat = 3.5
	var minScale: CGFloat = 1.1

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var enterText: UITextField!
	@IBOutlet var scrollViewForImage: UIScrollView!

    // MARK: - Methods
	override func viewDidLoad()
	{
		super.viewDidLoad()

		// Setting up the scroll size for each gesture
		self.scrollViewForImage.minimumZoomScale = 1.0
		self.scrollViewForImage.maximumZoomScale = 2.0
		self.scrollViewForImage.contentSize = self.imageView.bounds.size

		// Setting up how the view will be look like after scroll
		self.imageView.image = self.selectedImage
		self.imageView.frame = view.bounds
		self.imageView.backgroundColor = .black
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.isUserInteractionEnabled = true
	}

	/// Zooming for the view
	/// - Parameter scrollView: the view that user selected
	/// - Returns: the view after scroll
	func viewForZooming(in _: UIScrollView) -> UIView?
	{
		return self.imageView
	}

	/// End zooming when release pinch guesture
	/// - Parameters:
	///   - scrollView: the view that user selected
	///   - view: view
	///   - scale: How much the view will be zoomed
	func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale _: CGFloat) {}

	/// Tap the image again to go back the last view controller
	/// - Parameter sender: the image that user selected
	@IBAction func tapBack(_: Any)
	{
		if self.imageView.transform != CGAffineTransform.identity
		{
			self.scrollViewForImage.setZoomScale(1, animated: true)
		}
		else
		{
			dismiss(animated: true)
		}
	}
}
