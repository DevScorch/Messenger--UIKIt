//
//  DatabaseAPI.swift
//  Messenger- UIKIt
//
//  Created by Johan Sas on 06/01/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseAPI {
    
    // MARK: Database
    static let shared = DatabaseAPI()
    private let database = Database.database(url: "https://messenger-c14c1-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    
    
}

// MARK: Account Management extension

extension DatabaseAPI {
    
    public func checkIfEmailExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var checkedEmail = email.replacingOccurrences(of: ".", with: "-")
        checkedEmail = checkedEmail.replacingOccurrences(of: "@", with: "-")
        database.child(checkedEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Creates a new Database User
    public func postUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.checkedEmail).setValue(
            ["first_name": user.name,
             "last_name": user.lastname
            ],  withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Database write failed")
                    completion(false)
                    return
                }
                
                self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                    if var users = snapshot.value as? [[String: String]] {
                        let newElement = [
                            "name": user.name + " " + user.lastname,
                            "email": user.checkedEmail
                            ]
                        users.append(newElement)
                        
                        self.database.child("users").setValue(newElement, withCompletionBlock: { error, _ in
                            guard error  == nil else {
                                completion(false)
                                return
                                
                            }
                            completion(true)
                        })
                        
                    } else {
                        let newCollection: [[String: String]] = [
                            [
                            "name": user.name + " " + user.lastname,
                            "email": user.checkedEmail
                            ]
                        ]
                        self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error  == nil else {
                                completion(false)
                                return
                                
                            }
                            completion(true)
                        })
                    }
                    //
                })
            })
    }
    
    public func getUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.fetchFailed))
                return
            }
            completion(.success(value))
        })
    }
}

public enum DatabaseErrors: Error {
    case fetchFailed
    
}

// MARK: Application IO

struct User {
    let name: String
    let lastname: String
    let email: String
    
    
    var checkedEmail: String {
        var checkedEmail = email.replacingOccurrences(of: ".", with: "-")
        checkedEmail = checkedEmail.replacingOccurrences(of: "@", with: "-")
        return checkedEmail
    }
    
    var pictureFileName: String {
        return "\(checkedEmail)_profile_picture.png"
    }
    
}
