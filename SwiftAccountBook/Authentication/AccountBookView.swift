import SwiftUI
import UIKit



struct CalendarView : View {
    @Binding var selectedDate: Date
    
    var body: some View {
        // 캘린더 UI 구성
        DatePicker(
            "날짜 선택",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .frame(maxHeight: 400)
        .padding()
        
        
    }
}
