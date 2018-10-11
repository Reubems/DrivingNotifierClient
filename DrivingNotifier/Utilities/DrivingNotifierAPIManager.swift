import Foundation

class DrivingNotifierAPIManager {

    let apiUrlBase: String = "https://drivingnotifierapi20180709102032.azurewebsites.net"

    enum HttpMethod {
        case GET, POST, PUT, DELETE
    }

    func performOperation(parameters: [String: Any]? = [:], route: APIRoutes, method: HttpMethod, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {

        let postData: Data
        do {
            postData =  try JSONSerialization.data(withJSONObject: parameters ?? [:], options: [])
        } catch { return }

        let request = NSMutableURLRequest(
            url: NSURL(string: "\(apiUrlBase)\(route.urlString)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")

        switch method {
        case .POST:
            request.httpMethod = "POST"
            request.httpBody = postData as Data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .PUT:
            request.httpMethod = "PUT"
            request.httpBody = postData as Data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .GET:
            request.httpMethod = "GET"
        case .DELETE:
            request.httpMethod = "DELETE"
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) -> Void in
                completionHandler(data, response, error)})

        dataTask.resume()
    }
}
