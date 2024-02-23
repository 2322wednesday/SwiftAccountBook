//
//  AuthenticationView.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/2/24.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class AuthenticationViewModel:ObservableObject {
    @Published var email = ""
    @Published var password = ""
}


struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn: Bool = false
    
    var body: some View {
        if userIsLoggedIn {
            EventsCalendarView()
        } else {
            content
        }
    }
    
    var content: some View {
        VStack{
            TextField("이메일을 입력해주세요.", text: $email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("비밀번호를 입력해주세요.", text: $password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .keyboardType(.default)
            
            Button{
                logIn()
            } label: {
                Text("로그인")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            NavigationLink {
                SignInEmailView()
            } label: {
                Text("등록된 아이디가 없으신가요? 회원가입")
                    .font(.headline)
            }
            .padding()
            Spacer()
        }
        .padding()
        .navigationTitle("Welcome")
    }
    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) {
            authResult, error in
            if authResult != nil {
                print("로그인 성공")
                userIsLoggedIn.toggle()
            } else if error != nil {
                print("로그인 실패")
                print(error.debugDescription)
            }
        }
    }
}

struct AuthenticationView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView()
        }
    }
}
