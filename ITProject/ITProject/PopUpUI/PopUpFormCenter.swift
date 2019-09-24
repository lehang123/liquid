//
//  PopUpFormCenter.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/23.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import SwiftEntryKit

// MARK: Setup

class PopUpFromWindow
{
	static var displayMode = EKAttributes.DisplayMode.inferred
	private var displayMode: EKAttributes.DisplayMode
	{
		return PopUpFromWindow.displayMode
	}

	public static func setupFormPresets() -> EKAttributes
	{
		var attributes: EKAttributes

		// Preset Center Form
		attributes = .float
		attributes.displayMode = self.displayMode
		attributes.windowLevel = .normal
		attributes.position = .center
		attributes.displayDuration = .infinity
		attributes.entranceAnimation = .init(
			translate: .init(
				duration: 0.65,
				anchorPosition: .bottom,
				spring: .init(damping: 1, initialVelocity: 0)
			)
		)
		attributes.exitAnimation = .init(
			translate: .init(
				duration: 0.65,
				anchorPosition: .top,
				spring: .init(damping: 1, initialVelocity: 0)
			)
		)
		attributes.popBehavior = .animated(
			animation: .init(
				translate: .init(
					duration: 0.65,
					spring: .init(damping: 1, initialVelocity: 0)
				)
			)
		)
		attributes.entryInteraction = .absorbTouches
		attributes.screenInteraction = .dismiss
		attributes.entryBackground = .color(color: .standardBackground)
		attributes.screenBackground = .color(color: .dimmedDarkBackground)
		attributes.border = .value(
			color: UIColor(white: 0.6, alpha: 1),
			width: 1
		)
		attributes.shadow = .active(
			with: .init(
				color: .black,
				opacity: 0.3,
				radius: 3
			)
		)
		attributes.scroll = .enabled(
			swipeable: false,
			pullbackAnimation: .jolt
		)
		attributes.statusBar = .light
		attributes.positionConstraints.keyboardRelation = .bind(
			offset: .init(
				bottom: 15,
				screenEdgeResistance: 0
			)
		)
		attributes.positionConstraints.maxSize = .init(
			width: .constant(value: UIScreen.main.minEdge),
			height: .intrinsic
		)

		return attributes
	}
}

extension UIScreen
{
	var minEdge: CGFloat
	{
		return UIScreen.main.bounds.minEdge
	}
}

extension CGRect
{
	var minEdge: CGFloat
	{
		return min(width, height)
	}
}
