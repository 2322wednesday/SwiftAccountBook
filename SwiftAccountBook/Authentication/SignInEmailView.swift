//
//  SignInEmailView.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/2/24.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("이미 등록된 이메일이 존재합니다.")
            return
        }
        
        Task{
            do{
                let returnUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Success")
                print(returnUserData)
                showAlert.toggle()
            } catch {
                print("Error : \(error)")
            }
        }
    }
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
    var body: some View {
        VStack{
            TextField("이메일을 입력해주세요.", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("비밀번호를 입력해주세요.", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .keyboardType(.default)
            
            Button{
                viewModel.signIn()
            } label: {
                Text("회원가입")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .alert("회원가입 성공! 로그인 화면으로 돌아가세요.", isPresented: $viewModel.showAlert){
                Button("OK", role: .cancel) {}
            }
            Spacer()
        }
        .padding()
        .navigationTitle("이메일로 회원가입")
    }
}

struct SignInEmailView_Previews : PreviewProvider {
    static var previews: some View{
        NavigationStack{
            SignInEmailView()
        }
    }
}
