//
//  FirebaseUtil.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/1/24.
//

import Foundation
import Firebase

class FirebaseUtil: NSObject {
    let auth : Auth
    
    static let shared = FirebaseUtil()
    
    override init(){
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        
        super.init()
    }
}
