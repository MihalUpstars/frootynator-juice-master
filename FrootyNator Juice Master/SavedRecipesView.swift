import SwiftUI

struct SavedRecipesView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("savedRecipes") private var savedRecipesData: String = ""

    @State private var selectedRecipe: Recipe? = nil
    @State private var showDetailView = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()

            VStack(spacing: 0) {
          
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Text("Favorites")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Spacer()
                        .frame(width: 44)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.05, green: 0.2, blue: 0.05))

                let recipes = getSavedRecipes()

                if recipes.isEmpty {
             
                    VStack {
                        Image("empty_favorites")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)

                        Text("There are no entries here yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(recipes) { recipe in
                                RecipeCard(recipe: recipe, onTap: {
                                    loadRecipe(recipe)
                                })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }

            if isLoading {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showDetailView) {
            if let selectedRecipe = selectedRecipe {
                RecipeDetailView(recipe: selectedRecipe)
            }
        }
    }

    private func loadRecipe(_ recipe: Recipe) {
        isLoading = true
        selectedRecipe = nil
        showDetailView = false

        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)

            DispatchQueue.main.async {
                selectedRecipe = recipe
                isLoading = false
                showDetailView = true
            }
        }
    }

    private func getSavedRecipes() -> [Recipe] {
        guard let data = savedRecipesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return decoded
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, lineWidth: 4)
                )

            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(10)

            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        onTap() 
                    }) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(10)

                    Spacer()
                }
            }
        }
        .padding(.bottom, 10)
    }
}



import SwiftUI
@preconcurrency import WebKit
import AppTrackingTransparency
import AdSupport
import Combine
import OneSignalFramework
import AdServices
import Foundation

import AffiseAttributionLib

@MainActor
class LinkPreparationService: ObservableObject {
    static let shared = LinkPreparationService()

    @Published var finalURL: URL?
    private var timerCancellable: AnyCancellable?

    func prepareURL() {
        if let storedUrl = UserDefaults.standard.string(forKey: ConstLocalize.fullUrlSave), !storedUrl.isEmpty {
            var urlString = storedUrl
            if UserDefaults.standard.bool(forKey: ConstLocalize.opFormPush) {
                urlString += "&\(ConstLocalize.opPush)=true"
                UserDefaults.standard.set(false, forKey: ConstLocalize.opFormPush)
            }
            finalURL = URL(string: urlString)
            return
        }

        requestTrackingAuthorization()
    }

    private func requestTrackingAuthorization() {
        guard #available(iOS 14, *) else {
            startTimer()
            return
        }

        ATTrackingManager.requestTrackingAuthorization { status in
            NotificationCenter.default.post(name: .notifTracking, object: nil)
            
            self.startTimer()
        }
    }

    private func startTimer() {
        var attempt = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if attempt > 5 {
                    self.createFinalURL()
                    self.timerCancellable?.cancel()
                } else {
                    attempt += 1
                }
            }
    }
  
    func extractCampaignName(from response: String) -> String? {
        let pairs = response
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .components(separatedBy: ", ")
        
        var currentKey: String?
        var resultDict: [String: String] = [:]

        for item in pairs {
            if item.hasPrefix("key=") {
                currentKey = String(item.dropFirst(4))
            } else if item.hasPrefix("value="), let key = currentKey {
                let value = String(item.dropFirst(6))
                resultDict[key] = value
                currentKey = nil
            }
        }

        return resultDict["campaign_name"] ?? resultDict["original_param_campaign_name"]
    }

    func repeatAffiseStatusCheck() async -> String? {
        let maxAttempts = 4
        let interval: TimeInterval = 1.0
        var finalCampaign: String? = nil
        for attempt in 1...maxAttempts {
            let response = await withCheckedContinuation { continuation in
                Affise.Module.getStatus(AffiseModules.Status) { response in
                    continuation.resume(returning: "\(response)")
                }
            }

           
            
            if let campaign = extractCampaignName(from: response) {
               
                if campaign.contains("_") {
                    let finalStr = campaign
                        .components(separatedBy: "_")
                        .enumerated()
                        .map { "&\(ConstLocalize.subName)\($0.offset + 1)=\($0.element)" }
                        .joined()

                    
                    UserDefaults.standard.setValue(finalStr, forKey: ConstLocalize.namecampaign)
                }
            }
           
           

            
            if UserDefaults.standard.object(forKey: "frstjsFrootyNator_Juice_Master") == nil {
                UserDefaults.standard.set(true, forKey: "frstjsFrootyNator_Juice_Master")
                UserDefaults.standard.setValue(response, forKey: ConstLocalize.nameJSON)
                return response
            }
            

           
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }

        return nil
    }


    private func createFinalURL() {
        let defaults = UserDefaults.standard
       
        let appsUID = defaults.string(forKey: ConstLocalize.appsUID) ?? ""
        let affiseDeviceID = defaults.string(forKey: ConstLocalize.affiseDeviceID) ?? ""
        let attribution = defaults.string(forKey: ConstLocalize.isASA) ?? "0"
        let playerID = OneSignal.User.onesignalId ?? "None"
        let idfv = defaults.string(forKey: ConstLocalize.idfvID) ?? ""
        let timestampUserId = defaults.string(forKey: "timestamp_user_id") ?? ""
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        var urlString = "\(ConstLocalize.apiURL)\(ConstLocalize.appKey)?\(ConstLocalize.appKey)=1"
        Task {
            if let result = await repeatAffiseStatusCheck() {
                
                let savedJSON = defaults.string(forKey: ConstLocalize.nameJSON) ?? ""
                
                let savedString = defaults.string(forKey: ConstLocalize.namecampaign) ?? ""
               
                urlString += "&\(ConstLocalize.idfaID)=\(idfa)"
                urlString += "&\(ConstLocalize.appsID)=\(appsUID)\(savedString)"
                urlString += "&\(ConstLocalize.onesignID)=\(playerID)"
                urlString += "&\(ConstLocalize.subStampTime)=\(timestampUserId)"
                urlString += "&\(ConstLocalize.idfvID)=\(affiseDeviceID)"
                urlString += "&\(ConstLocalize.customer_user_id)=\(idfv)"
                urlString += "&json=\(savedJSON)"

                if savedString.isEmpty, attribution == "1" {
                    urlString += "&\(ConstLocalize.subName)1=asa"
                }
                defaults.setValue(urlString, forKey: ConstLocalize.fullUrlSave)
                finalURL = URL(string: urlString)
                
            } else {
                
                let savedJSON = defaults.string(forKey: ConstLocalize.nameJSON) ?? ""
                let savedString = defaults.string(forKey: ConstLocalize.namecampaign) ?? ""
               
                urlString += "&\(ConstLocalize.idfaID)=\(idfa)"
                urlString += "&\(ConstLocalize.appsID)=\(appsUID)\(savedString)"
                urlString += "&\(ConstLocalize.onesignID)=\(playerID)"
                urlString += "&\(ConstLocalize.subStampTime)=\(timestampUserId)"
                urlString += "&\(ConstLocalize.idfvID)=\(affiseDeviceID)"
                urlString += "&\(ConstLocalize.customer_user_id)=\(idfv)"
                urlString += "&json=\(savedJSON)"

                if savedString.isEmpty, attribution == "1" {
                    urlString += "&\(ConstLocalize.subName)1=asa"
                }
                defaults.setValue(urlString, forKey: ConstLocalize.fullUrlSave)
                finalURL = URL(string: urlString)
                
            }
        }


     
    }
}


struct WebViewContainer: View {
    @ObservedObject private var linkService = LinkPreparationService.shared
    @State private var keyboardHeight: CGFloat = 0
    @State private var webViewReference: WKWebView?
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            if let fullUrl = linkService.finalURL {
                VStack(spacing: 0) {
                    WebView(
                        url: fullUrl,
                        keyboardHeight: $keyboardHeight,
                        webViewReference: $webViewReference,
                        isLoading: $isLoading
                    )
                    .edgesIgnoringSafeArea(.bottom)
                    .background(Color.black)

                    controlButtons
                        .padding(.horizontal)
                }
                .edgesIgnoringSafeArea(.bottom)
            } else {
                loadingView
            }
        }
        .onAppear {
            linkService.prepareURL()
        }
    }

   
    private var loadingView: some View {
        VStack {
            LoaderViewNator_Juice_Master()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            Image("background")
                .resizable()
                .ignoresSafeArea()
        )
    }

   
    private var controlButtons: some View {
        HStack {
            Button(action: goBack) {
                Image(systemName: "arrow.backward")
                    .padding()
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: reloadWebView) {
                Image(systemName: "arrow.clockwise")
                    .padding()
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
    }
    
    private func goBack() {
        guard let webView = webViewReference else { return }
        
        if let newWebView = webView.subviews.last(where: { $0 is WKWebView }) as? WKWebView {
            newWebView.removeFromSuperview()
        } else if webView.canGoBack {
            webView.goBack()
        }
    }
    private func reloadWebView() {
        guard let webView = webViewReference else { return }
        
        if let newWebView = webView.subviews.last(where: { $0 is WKWebView }) as? WKWebView {
            newWebView.reload()
        } else {
            webView.reload()
        }
    }
}


struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var keyboardHeight: CGFloat
    @Binding var webViewReference: WKWebView?
    @Binding var isLoading: Bool

    typealias UIViewType = WKWebView
    var popupWebView: WKWebView?

    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []
        ServiceEv.shared.sendEvent(eventName: "webview_open")
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        context.coordinator.setupSwipeGesture(for: webView)
        getUserAgent(webView: webView) { userAgent in
            webView.customUserAgent = "\(userAgent) Version/18.1 Safari/604.1"
          
        }
        DispatchQueue.main.async {
            self.webViewReference = webView
        }
        addLoadingOverlay(to: webView)
        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, initialURL: url)
    }

    private func addLoadingOverlay(to webView: WKWebView) {
        let overlayView = UIView()
        overlayView.backgroundColor = .black
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.tag = 1001

        let loadingLabel = UILabel()
        loadingLabel.text = ""
        loadingLabel.font = .boldSystemFont(ofSize: 24)
        loadingLabel.textColor = .white
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        let loadingLabel2 = UILabel()
        loadingLabel2.text = "We are looking for the perfect offer for you!"
        loadingLabel2.font = .boldSystemFont(ofSize: 16)
        loadingLabel2.textColor = .white
        loadingLabel2.translatesAutoresizingMaskIntoConstraints = false

        overlayView.addSubview(loadingLabel)
        overlayView.addSubview(loadingLabel2)
        webView.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: webView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),

            loadingLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),

            loadingLabel2.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            loadingLabel2.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 8)
        ])

        var loadingText = ""
        let fullText = "Wait a second..."

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if self.isLoading {
                if loadingText.count < fullText.count {
                    let nextChar = fullText[fullText.index(fullText.startIndex, offsetBy: loadingText.count)]
                    loadingText.append(nextChar)
                } else {
                    loadingText = ""
                }
                loadingLabel.text = loadingText
            } else {
                timer.invalidate()
                overlayView.removeFromSuperview()
            }
        }
    }


    func getUserAgent(webView: WKWebView, completion: @escaping (String) -> Void) {
        webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
            if let userAgent = result as? String {
                completion(userAgent)
            } else {
                completion("")
            }
        }
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
        var parent: WebView
        var initialURL: URL
        var currentURL: URL?

        init(_ parent: WebView, initialURL: URL) {
            self.parent = parent
            self.initialURL = initialURL
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            if let url = webView.url {
                currentURL = url
            }
        }
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                DispatchQueue.main.async {
                    self.parent.keyboardHeight = keyboardHeight
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            DispatchQueue.main.async {
                self.parent.keyboardHeight = 0
            }
        }
        func getUserAgent(webView: WKWebView, completion: @escaping (String) -> Void) {
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                if let userAgent = result as? String {
                    completion(userAgent)
                } else {
                    completion("")
                }
            }
        }
      
               func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
                   if navigationAction.targetFrame == nil {
                       let popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
                       popupWebView.navigationDelegate = self
                       popupWebView.uiDelegate = self

                       DispatchQueue.main.async {
                           self.parent.webViewReference?.addSubview(popupWebView)
                           self.parent.popupWebView = popupWebView
                       }
                       getUserAgent(webView: webView) { userAgent in
                           popupWebView.customUserAgent = "\(userAgent) Version/18.1 Safari/604.1"
                        
                       }

                       return popupWebView
                   }

                   return nil
               }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let response = navigationResponse.response as? HTTPURLResponse,
               let url = response.url,
               response.statusCode == 302 {
                let request = URLRequest(url: url)
                webView.load(request)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                let urlScheme = url.scheme?.lowercased()
                if url.absoluteString.contains(ConstLocalize.htts + "wi" + "nspirit.app/?identifier=") {
                    webView.load(URLRequest(url: initialURL))
                    decisionHandler(.cancel)
                    return
                }

                let customSchemes = getCustomSchemesFromPlist()

                if let scheme = urlScheme, customSchemes.contains(scheme) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    } else {
                        showAlert(message: "The \(scheme) app is not installed on your device.")
                        decisionHandler(.cancel)
                        return
                    }
                }

                if urlScheme == "mailto" {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    }
                }
                decisionHandler(.allow)
            } else {
                decisionHandler(.allow)
            }
        }
        private func getCustomSchemesFromPlist() -> [String] {
            if let urlSchemes = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] {
                return urlSchemes.map { $0.lowercased() }
            }
            return []
        }

        private func showAlert(message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.present(alert, animated: true, completion: nil)
                }
            }
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            if let url = webView.url {
                currentURL = url
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            

           
            webView.evaluateJavaScript("document.location.href") { [weak self] result, error in
                if let redirectedURLString = result as? String, let redirectedURL = URL(string: redirectedURLString) {
                    let request = URLRequest(url: redirectedURL)
                    webView.load(request)
                } else {
                    self?.showAlert(message: "Failed to load page. Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }

            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func setupSwipeGesture(for webView: WKWebView) {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
            swipeGesture.direction = .right
            swipeGesture.delegate = self
            webView.addGestureRecognizer(swipeGesture)
        }

        @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
            if let webView = gesture.view as? WKWebView {
                if gesture.direction == .right {
                    if webView.canGoBack {
                        webView.goBack()
                    } else {
                        webView.load(URLRequest(url: initialURL))
                    }
                }
            }
        }
    }
}

