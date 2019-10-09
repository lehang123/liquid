//
//  CacheHandler.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 19/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation
import UIKit

/// Handles caching data for the app.
class CacheHandler: NSObject
{
	private var dataCache: NSCache<NSString, NSData>

	private static var single: CacheHandler!
	override init()
	{
		self.dataCache = NSCache<NSString, NSData>()
		super.init()
	}

	/// singleton pattern implemented
	/// - Returns: return an instance of this CacheHandler.
	public static func getInstance() -> CacheHandler
	{
		if self.single == nil
		{
			self.single = CacheHandler()
		}
		return self.single
	}

	/// stores an object into NSCache's dictionary.
	/// note that if you set object into same key again,
	/// it'll replace the existing object with the new "obj". (i.e. update instead of create).
	/// - Parameters:
	///   - obj: object to be stored
	///   - forKey: key of the object
	public func setCache(obj: Data, forKey: String)
	{
		self.dataCache.setObject(obj as NSData, forKey: forKey as NSString)
		//        CacheHandler.addCacheCounter()
		print("setCache::: caching : \(obj) with key : \(forKey) succeeded.")
	}

    /// gets an object from cache by its key.
    /// - Parameter forKey: key of the object
    /// - Returns: the object associated with the key given
	public func getCache(forKey: String) -> Data?
	{
		if let data = self.dataCache.object(forKey: forKey as NSString)
		{
			return data as Data
		}
		else
		{
			return nil
		}
	}

	/// removes all objects in cache. be mindful of this when working with others,
	/// as the cache is apparently in singleton manner.
	public func cleanCache()
	{
		self.dataCache.removeAllObjects()
	}

	/// removes 1 object with associated key.
	/// - Parameter forKey: key of the object to be removed.
	public func removeFromCache(forKey: String)
	{
		self.dataCache.removeObject(forKey: forKey as NSString)
	}

	
	

   
}
