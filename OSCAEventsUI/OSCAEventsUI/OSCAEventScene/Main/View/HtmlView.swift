import SwiftUI
import WebKit

struct HtmlView: View {
    var html: String
    var fontSize: CGFloat = 14
    @State var attributedString: AttributedString?
    
    var body: some View {
        return Text(attributedString ?? "").task {
            try? fromHtml(html: html, fontSize: fontSize)
        }
    }
    
    
    func fromHtml(html: String, fontSize: CGFloat) throws {
        
        let data = html.data(using: .utf16)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing =  40.0
        paragraphStyle.lineSpacing = 40.0
        
        let nsAttrStr = try NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
        
        nsAttrStr.enumerateAttribute(
            .font,
            in: NSMakeRange(0, nsAttrStr.length),
            options: .init(rawValue: 0)
        ) {
            (value, range, stop) in
            if let font = value as? UIFont, let newFontDescriptor = font.fontDescriptor
                .withFamily(UIFont.systemFont(ofSize: 0).familyName)
                .withSymbolicTraits(font.fontDescriptor.symbolicTraits) {
                
                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: fontSize
                )
                
                nsAttrStr.addAttribute(.font, value: newFont, range: range)
            }
        }
        self.attributedString = try? AttributedString(nsAttrStr, including: \.uiKit)
    }
    
}
