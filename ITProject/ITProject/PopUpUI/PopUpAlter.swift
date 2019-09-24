//
//  PopUpAlter.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/27.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import SwiftEntryKit

// MARK: Setup

/// PopUp Message class.
class PopUpAlter
{
	static var displayMode = EKAttributes.DisplayMode.inferred
	private var displayMode: EKAttributes.DisplayMode
	{
		return PopUpFromWindow.displayMode
	}

	public static func setupPopupPresets() -> EKAttributes
	{
		var attributes: EKAttributes

		// Preset Center Alter
		attributes = EKAttributes.centerFloat
		attributes.hapticFeedbackType = .error
		attributes.displayDuration = .infinity
		attributes.screenInteraction = .dismiss
		attributes.entryInteraction = .absorbTouches
		attributes.scroll = .enabled(
			swipeable: true,
			pullbackAnimation: .jolt
		)
		attributes.roundCorners = .all(radius: 8)
		attributes.positionConstraints.size = .init(
			width: .offset(value: 20),
			height: .intrinsic
		)
		attributes.positionConstraints.maxSize = .init(
			width: .constant(value: UIScreen.main.minEdge),
			height: .intrinsic
		)
		attributes.statusBar = .dark

		attributes.entryBackground = .gradient(
			gradient: .init(
				colors: [EKColor(rgb: 0xFFFBD5), EKColor(rgb: 0xB20A2C)],
				startPoint: .zero,
				endPoint: CGPoint(x: 1, y: 1)
			)
		)
		attributes.screenBackground = .color(color: .dimmedDarkBackground)
		attributes.shadow = .active(
			with: .init(
				color: .black,
				opacity: 0.3,
				radius: 8
			)
		)
		attributes.entranceAnimation = .init(
			translate: .init(
				duration: 0.7,
				spring: .init(damping: 0.7, initialVelocity: 0)
			),
			scale: .init(
				from: 0.7,
				to: 1,
				duration: 0.4,
				spring: .init(damping: 1, initialVelocity: 0)
			)
		)
		attributes.exitAnimation = .init(
			translate: .init(duration: 0.2)
		)
		attributes.popBehavior = .animated(
			animation: .init(
				translate: .init(duration: 0.35)
			)
		)

		return attributes
	}

	public static func showPopupMessage(attributes: EKAttributes,
	                                    title: String,
	                                    titleColor: EKColor,
	                                    description: String,
	                                    descriptionColor: EKColor,
	                                    buttonTitleColor: EKColor,
	                                    buttonBackgroundColor: EKColor,
	                                    image: UIImage? = nil)
	{
		var themeImage: EKPopUpMessage.ThemeImage?

		if let image = image
		{
			themeImage = EKPopUpMessage.ThemeImage(
				image: EKProperty.ImageContent(
					image: image,
					displayMode: self.displayMode,
					size: CGSize(width: 60, height: 60),
					tint: titleColor,
					contentMode: .scaleAspectFit
				)
			)
		}
		let title = EKProperty.LabelContent(
			text: title,
			style: .init(
				font: MainFont.medium.with(size: 24),
				color: titleColor,
				alignment: .center,
				displayMode: self.displayMode
			)
		)
		let description = EKProperty.LabelContent(
			text: description,
			style: .init(
				font: MainFont.light.with(size: 16),
				color: descriptionColor,
				alignment: .center,
				displayMode: self.displayMode
			)
		)
		let button = EKProperty.ButtonContent(
			label: .init(
				text: "Got it!",
				style: .init(
					font: MainFont.bold.with(size: 16),
					color: buttonTitleColor,
					displayMode: self.displayMode
				)
			),
			backgroundColor: buttonBackgroundColor,
			highlightedBackgroundColor: buttonTitleColor.with(alpha: 0.05),
			displayMode: self.displayMode
		)
		let message = EKPopUpMessage(
			themeImage: themeImage,
			title: title,
			description: description,
			button: button
		)
		{
			SwiftEntryKit.dismiss()
		}
		let contentView = EKPopUpMessageView(with: message)
		SwiftEntryKit.display(entry: contentView, using: attributes)
	}
}
