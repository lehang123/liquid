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
    public static let USER_DOCUMENT_FIELD_PROFILE_PICTURE = "profile_picture"
    public static let USER_DOCUMENT_FIELD_PROFILE_PICTURE_EXTENSION = "profile_picture_extension"

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
    /// gets the user's family info.
    /// - Returns:  completion : the relevant family's details to be retrieved.
    public func getFamilyInfo(completion: @escaping (_ UID: String?, _ Motto: String?, _ Name: String?, _ profileUID: String?, _ profileExtension: String?, _ error: Error?) -> Void = { _, _, _, _, _, _ in })
    {
        // get user Document Ref:
        let user = Auth.auth().currentUser!.uid

        print("getting family info with uid : " + user)
        let userDocRef = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user)
        print("getting family info with userDocRef : " + userDocRef.documentID)

        Util.ShowActivityIndicator(withStatus: "retrieving user's family information...")
        // get users related family:
        DBController.getInstance().getDB().collection(RegisterDBController.FAMILY_COLLECTION_NAME).whereField(RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS, arrayContains: userDocRef as Any).getDocuments
        { familyQuerySnapshot, error in
            Util.DismissActivityIndicator()
            if let error = error
            {
                print("ERROR GET FAM \(error)")
            }
            else
            {
//                print("come to here with userDocRef : ")
                for doc in familyQuerySnapshot!.documents
                {
//                    print("come to here with userDocRef : with the doc")
                    let data = doc.data()
                    let motto = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO] as? String
                    let name = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME] as? String
                    let profile = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL] as? String
                    let profileExt = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL_EXT] as? String

                    completion(doc.documentID, motto, name, profile, profileExt, error)
                    //we know that the user only related to 1 family, so break afterwards:
                    break;
                }
            }
        }
    
    }
    /// get  current user's info from database.
    ///  - Parameter completion: passes on relation in family, user's gender, user's family reference.
    public func getUserInfo(completion: @escaping (_ relation: String?, _ dateOfBirth: Date?, _ familyIn: DocumentReference?, _ gender : String?, _ name : String?, _ photoPath : String?,_ photoExt : String?, _ error: Error?) -> Void = { _, _, _, _, _,_,_, _ in })
    {
        
        let user = Auth.auth().currentUser!.uid
        
        Util.ShowActivityIndicator(withStatus: "retrieving user information...")
        
        //get from db:
        DBController.getInstance()
            .getDocumentFromCollection(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID: user
            )
        {
            userDocument, error in
            //parse data:
            if let userDocument = userDocument, userDocument.exists
            {
                let data: [String: Any] = userDocument.data()!

                let dobTimestamp :Timestamp = data[RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH] as? Timestamp ?? Timestamp(date: Date())
                print("dobTimestamp: ", dobTimestamp )
                let dob :Date =   dobTimestamp.dateValue()
                print("dob:",dob)
                let position = data[RegisterDBController.USER_DOCUMENT_FIELD_POSITION] as? String
                let familyDocRef: DocumentReference = data[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference
                let gender: String? = data[RegisterDBController.USER_DOCUMENT_FIELD_GENDER] as? String
                let name : String? = data[RegisterDBController.USER_DOCUMENT_FIELD_NAME] as? String
                let photoExt : String? = data[RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE_EXTENSION] as? String
                let photoPath : String? = data[RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE] as? String

                //passes data to next stage:
                completion(position, dob, familyDocRef, gender, name,photoPath,photoExt, error)

                Util.DismissActivityIndicator()
            }
                //handle error:
            else
            {
                print("ERROR LOADING cacheUserAndFam::: ", error as Any)
            }
        }
    }
    
    public func UploadUserProfilePicture (imagePath : String, imageExt : String){
       
        let userUID = Auth.auth().currentUser?.uid
        let userDocRef = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID!)
        
        //todo : delete old photo:
        
        
        //then, add new photo in:
        userDocRef.updateData(
            [RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE  : imagePath,
             RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE_EXTENSION : imageExt])

    }
     public func getFamilyMembersInfo (completion: @escaping (_ familyMember: [FamilyMember], _ error: Error?) -> Void = { _, _ in }){
            // get current user Document Ref:
            let user = Auth.auth().currentUser!.uid
            DBController
                .getInstance()
                .getDocumentFromCollection(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID: user)
                { (docSnapshot, error) in
                if let error = error {
                    print("error at getFamilyMembersInfo:::" , error)
                }else{
                    //get family doc ref:
                    let famDocRef:DocumentReference = docSnapshot?.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY)  as! DocumentReference
                   //query for all members in fam:
                    DBController
                        .getInstance()
                        .getDB()
                        .collection(RegisterDBController.USER_COLLECTION_NAME)
                        .whereField(
                            RegisterDBController.USER_DOCUMENT_FIELD_FAMILY,
                            isEqualTo: famDocRef)
                        .getDocuments {
                            (querySnapshot, error) in
                        if let error = error {
                            print("error at getFamilyMembersInfo:::" , error)
                        }else{
                            var familyMembers : [FamilyMember] =  [FamilyMember]();
                            let familyMembersRef : [ QueryDocumentSnapshot] = querySnapshot!.documents
                            //PARSE DATA:
                            familyMembersRef.forEach({ (queryDocumentSnapshot) in
                                let data : QueryDocumentSnapshot = queryDocumentSnapshot;
    //                            let dobTimestamp : Timestamp =  (data.get(RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH) as? Timestamp) ?? Timestamp(date: Date()) ;
                                let dateFormatter : DateFormatter = DateFormatter();
                                dateFormatter.dateFormat = "dd-MM-yyyy";
    //                            let dobDate : Date = dateFormatter.date(from: dobTimestamp.description) ??  Date()
    //                            print("dobDate:::",dobDate)
                                let dobTimestamp : Timestamp =  (data.get(RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH) as! Timestamp) ;
                        
                                let str =  dobTimestamp.dateValue().description 
                                let dateTimeComp : [String] = (str.components(separatedBy: " "))
                                let separator : String = "-"
                                let yearMonthDate : [String] = dateTimeComp[0].components(separatedBy: separator)
                               
                              
                                print("yearMonthDate:",yearMonthDate[2] +  yearMonthDate[1] +  yearMonthDate[0])
                                let dobString = yearMonthDate[2] + separator +  yearMonthDate[1] + separator + yearMonthDate[0]



                                

                                

                                familyMembers.append(
                                    FamilyMember(
                                        UID: data.documentID,
                                        dateOfBirth: dobString,
                                        name: data.get(RegisterDBController.USER_DOCUMENT_FIELD_NAME) as? String,
                                        relationship: data.get(RegisterDBController.USER_DOCUMENT_FIELD_POSITION) as? String)
                                )
                            })
                            completion(familyMembers, error);
                            

                        }
                    }
                }
                
            }
            
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
