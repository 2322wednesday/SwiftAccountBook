import SwiftUI
import FirebaseFirestore

struct AddRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDate: Date
    var onComplete: () -> Void  // 새로운 기록이 추가되었을 때 실행될 콜백

    @State private var income = ""
    @State private var expenses = ""

    var body: some View {
        NavigationView {
            Form {
                DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                TextField("수입", text: $income)
                TextField("지출", text: $expenses)
                Button("저장") {
                    // Firestore에 기록 추가
                    addRecordToFirestore(date: selectedDate, income: income, expenses: expenses)
                }
            }
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func addRecordToFirestore(date: Date, income: String, expenses: String) {
        let db = Firestore.firestore()

        // 문자열을 Int로 변환
        guard let incomeValue = Int(income), let expensesValue = Int(expenses) else { return }

        // Firestore에 저장할 데이터
        let data: [String: Any] = [
            "date": Timestamp(date: date),
            "income": incomeValue,
            "expenses": expensesValue
        ]

        // 데이터 추가
        db.collection("financialRecords").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(date)")
                // Document 추가 후 뷰 닫기
                presentationMode.wrappedValue.dismiss()
                onComplete()  // 콜백 실행
            }
        }
    }
}
