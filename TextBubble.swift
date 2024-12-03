import Foundation
import SwiftUI

struct TextBubble: View {
    let origin: String
    let textContent: String
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        Text(.init(textContent))
            .foregroundColor(foregroundColor)
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: origin == "user" ? .trailing : .leading)
            .padding(origin == "user" ? .leading : .trailing, 50)

    }
}
