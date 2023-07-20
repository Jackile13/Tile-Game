import SwiftUI
import WebKit

struct GifView: UIViewRepresentable {
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: name, withExtension: "gif")
        
        var gifData: Data
        
        do {
            gifData = try Data(contentsOf: url!)
        } catch {
            print("error loading gif \(name)")
            return webView
        }
        
        webView.load(gifData, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: (url?.deletingLastPathComponent())!)
        webView.scrollView.isScrollEnabled = false
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
    
    typealias UIViewType = WKWebView
}
