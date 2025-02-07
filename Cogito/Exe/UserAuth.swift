//
//  UserAuth.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

//import FirebaseAuth
//import FirebaseFirestore
//
//class UserAuth: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var user: User?
//    @Published var errorMessage = ""
//    
//    func signIn(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    self?.isAuthenticated = true
//                    self?.user = result?.user
//                }
//            }
//        }
//    }
//    
//    func signUp(email: String, password: String, username: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    // Create user profile in Firestore
//                    if let userId = result?.user.uid {
//                        let db = Firestore.firestore()
//                        db.collection("users").document(userId).setData([
//                            "username": username,
//                            "email": email,
//                            "createdAt": Date()
//                        ]) { error in
//                            if let error = error {
//                                self?.errorMessage = error.localizedDescription
//                            } else {
//                                self?.isAuthenticated = true
//                                self?.user = result?.user
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//            isAuthenticated = false
//            user = nil
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//}
