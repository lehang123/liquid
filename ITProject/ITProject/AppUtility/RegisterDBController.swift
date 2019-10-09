//
//  Util.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation

/// a class to handle adding new user and joining family in DB with singleton pattern.
class RegisterDBController
{
	/* constant for USERS collections */
	public static let USER_COLLECTION_NAME = "users"
	/// user's name
	public static let USER_DOCUMENT_FIELD_NAME = "name"
	/// user's family reference
	public static let USER_DOCUMENT_FIELD_FAMILY = "family"
	/// user's position in family
	public static let USER_DOCUMENT_FIELD_POSITION = "position"
	/// user's gender
	public static let USER_DOCUMENT_FIELD_GENDER = "gender"
    /// user's date of birth:
    public static let USER_DOCUMENT_FIELD_DATE_OF_BIRTH = "date_of_birth"

	/* constant for FAMILIES collections */
	public static let FAMILY_COLLECTION_NAME = "families"
	/// the family's name
	public static let FAMILY_DOCUMENT_FIELD_NAME = "name"
	/// the members of the family
	public static let FAMILY_DOCUMENT_FIELD_MEMBERS = "family_members"
	/// family's motto
	public static let FAMILY_DOCUMENT_FIELD_MOTTO = "motto"
	/// paths to family profile pict
	public static let FAMILY_DOCUMENT_FIELD_THUMBNAIL = "profile_picture"
	public static let FAMILY_DOCUMENT_FIELD_THUMBNAIL_EXT = "profile_picture_ext"
    
	private static var single: RegisterDBController!

	init() {}

	/// singleton pattern:
	/// - Returns: return an instance of this RegisterDBController.
	public static func getInstance() -> RegisterDBController
	{
		if self.single == nil
		{
			self.single = RegisterDBController()
		}
		return self.single
	}

	/// adds a new user document into "users" collection.
	/// - Parameters:
	///   - familyUID: the familyUID the user is joining into.
	///   - userUID: the user's UID (taken from firebase authorisation).
	///   - username: the username of user.
	public func AddUser(familyUID: String, userUID: String, username: String)
	{
        //TODO: change DATE_OF_BIRTH to something else
		let familyDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID)
		DBController.getInstance().addDocumentToCollectionWithUID(documentUID: userUID, inputData: [
			RegisterDBController.USER_DOCUMENT_FIELD_NAME: username,
			RegisterDBController.USER_DOCUMENT_FIELD_FAMILY: familyDocumentReference,
			RegisterDBController.USER_DOCUMENT_FIELD_POSITION: "",
            RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH: Timestamp(date: Date()),
			RegisterDBController.USER_DOCUMENT_FIELD_GENDER: "",
		], collectionName:
		RegisterDBController.USER_COLLECTION_NAME)
		Util.ChangeUserDisplayName(user: Auth.auth().currentUser!, username: username)
	}

	/// adds a new family document into "families" collection.
	/// - Parameters:
	///   - familyName: the name of the family to be created.
	///   - userUID: the user joining into the family.
	/// - Returns: the DocumentReference instance of the new family.
	public func AddNewFamily(familyName: String, userUID: String) -> DocumentReference
	{
		let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
		// creates  new family
		let familyUID = DBController.getInstance().addDocumentToCollection(inputData:
			[RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME: familyName,
			 RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS: [userDocumentReference],
			 RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO: "",
			 RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL: ""], collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
		return familyUID
	}

	/// adds a user into an existing family document.
	/// - Parameters:
	///   - familyUID: the family UID that's gonna be updated.
	///   - userUID: the user to be added into the family.
	public func AddUserToExistingFamily(familyUID: String, userUID: String)
	{
		let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
		let familyDocumentReference =
			DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID)

		familyDocumentReference.updateData([RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS: FieldValue.arrayUnion([userDocumentReference])])
		{ err in
			if let err = err
			{
               
				print("Error updating document: \(err)")
			}
			else
			{
				print("Document successfully updated")
			}
		}
	}
}
