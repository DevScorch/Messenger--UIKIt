//
//  StorageManager.swift
//  Messenger- UIKIt
//
//  Created by Johan Sas on 19/01/2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    public typealias UploadCompletion = (Result<String, Error>) -> Void
    
    public func uploadPicture(with data: Data, fileName: String, completion: @escaping UploadCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //
                print("uploading image failed")
                completion(.failure(StorageErrors.uploadFailed))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Retrieving URL failed")
                    completion(.failure(StorageErrors.urlFailed))
                    return
                }
                let urlString = url.absoluteString
                print("URL is returned \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case uploadFailed
        case urlFailed
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.urlFailed))
                return
            }
            completion(.success(url))
        })
    }
}
