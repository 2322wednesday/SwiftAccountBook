//
//  EventsCalendarView.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/8/24.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import FirebaseAuth

struct TabBar: View {
    @Binding var shouldShowLogOutOptions: Bool
    var viewModel: EventCalendarViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                // Calendar tab action
                print("캘린더 탭 선택됨")
            }) {
                Image(systemName: "calendar")
            }
            
            Spacer()
            
            Button(action: {
                // Document tab action
                print("문서 탭 선택됨")
            }) {
                Image(systemName: "doc.plaintext")
            }
            
            Spacer()
            
            Button(action: {
                // Bank tab action
                print("자산 탭 선택됨")
            }) {
                Image(systemName: "banknote")
            }
            
            Spacer()
            
            Button(action: {
                print("설정 탭 선택됨")
                shouldShowLogOutOptions.toggle()
            }) {
                Image(systemName: "gear")
            }
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                ActionSheet(
                    title: Text("설정"),
                    message: Text("로그아웃 하시겠습니까?"),
                    buttons: [
                        .destructive(Text("로그아웃"), action: {
                            do {
                                try viewModel.signOut()
                            } catch {
                                print("로그아웃 중 오류 발생 : \(error)")
                            }
                        }),
                        .cancel()
                    ]
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

class EventCalendarViewModel: ObservableObject {
    @Published var records = [FinancialRecord]()
    @Published var isUserCurrentlyLoggedOut = false
    @Published var totalIncomeForMonth = 0
    @Published var totalExpensesForMonth = 0

    func calculateAndStoreTotals() {
        self.totalIncomeForMonth = self.records.reduce(0) { $0 + $1.income }
        self.totalExpensesForMonth = self.records.reduce(0) { $0 + $1.expenses }
    }

    func updateTotalsForMonth() {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        totalIncomeForMonth = records.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
                                     .reduce(0) { $0 + $1.income }
        totalExpensesForMonth = records.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
                                       .reduce(0) { $0 + $1.expenses }
    }
    
    func signOut() throws {
        isUserCurrentlyLoggedOut.toggle()
        try Auth.auth().signOut()
    }
    
    func deleteRecord(recordId: String) {
        let db = Firestore.firestore()
        db.collection("financialRecords").document(recordId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.fetchRecordsForCurrentMonth() // 삭제 후 기록을 다시 불러옵니다.
            }
        }
    }

    
    func fetchRecords(forDate selectedDate: Date) {
        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("financialRecords")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.records = querySnapshot!.documents.compactMap { document -> FinancialRecord? in
                        try? document.data(as: FinancialRecord.self)
                    }
                }
            }
    }
    
    func fetchRecordsForCurrentMonth() {
        let db = Firestore.firestore()
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        db.collection("financialRecords")
            .whereField("date", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("date", isLessThanOrEqualTo: endOfMonth)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.records = querySnapshot!.documents.compactMap { document -> FinancialRecord? in
                        try? document.data(as: FinancialRecord.self)
                    }
                    self.updateTotalsForMonth()
                }
            }
    }

}

struct FinancialRecord: Codable, Identifiable {
    @DocumentID var id: String?
    var date: Date
    var income: Int
    var expenses: Int
}

struct EventsCalendarView: View {
    @State private var selectedDate = Date()
    @State private var shouldShowLogOutOptions = false
    @State private var showingAddRecordView = false
    @ObservedObject var viewModel = EventCalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        Text("이달의 수입")
                        Text("\(viewModel.totalIncomeForMonth)원")
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack {
                        Text("이달의 지출")
                        Text("\(viewModel.totalExpensesForMonth)원")
                            .fontWeight(.bold)
                    }
                }.padding()
                CalendarView(selectedDate: $selectedDate)
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { newValue in
                        viewModel.fetchRecords(forDate: newValue)
                    }

                
                List {
                    ForEach(viewModel.records) { record in
                        VStack(alignment: .leading) {
                            Text("수입: \(record.income)")
                            Text("지출: \(record.expenses)")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                Spacer()
                
                Button(action: {
                    showingAddRecordView = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showingAddRecordView) {
                    AddRecordView(selectedDate: $selectedDate, onComplete: {
                        viewModel.fetchRecordsForCurrentMonth()
                    })
                }

                TabBar(shouldShowLogOutOptions: $shouldShowLogOutOptions, viewModel: viewModel)
            }
            .navigationBarTitle("가계부", displayMode: .inline)
            .onAppear {
                viewModel.fetchRecordsForCurrentMonth()
            }
        }
    }
    
    func totalIncomeForMonth() -> Int {
        viewModel.records.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                         .reduce(0) { $0 + $1.income }
    }
        
    func totalExpensesForMonth() -> Int {
        viewModel.records.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                         .reduce(0) { $0 + $1.expenses }
    }
    
    func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in  // 모든 인덱스에 대해 반복합니다.
            let recordId = viewModel.records[index].id ?? "" // 안전하게 ID를 추출합니다.
            viewModel.deleteRecord(recordId: recordId) // ViewModel을 통해 기록을 삭제합니다.
        }
        viewModel.records.remove(atOffsets: offsets)
    }
    
    var currentRecord: FinancialRecord? {
        viewModel.records.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}



struct EventsCalendarView_Previews : PreviewProvider {
    static var previews: some View {
        EventsCalendarView()
    }
}
