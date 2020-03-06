//
// Copyright 2019 KagurazakaHanabi<i@yaerin.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var imageView: UIImageView!
    
    var current: Picture?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        Picture.today(completion: { data in
            self.current = data[Int.random(in: 0..<data.count)]
            let url = URL.init(string: self.current!.url)
            let bin = try! Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: bin)
                completionHandler(.newData)
            }
        })
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: maxSize.width / 0.8)
        } else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: maxSize.width * 1.2)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.current != nil {
            let uri = URL.init(string: "dailypics://p/\(current!.id)")
            self.extensionContext?.open(uri!, completionHandler: nil)
        }
    }
}

struct Picture {
    let id: String
    let url: String

    init?(source: [String: Any]) {
        guard let id = source["PID"] as? String,
            let path = source["nativePath"] as? String
        else {
            return nil
        }

        self.id = id
        self.url = "https://s1.images.dailypics.cn/\(path)!w1080_jpg"
    }

    static func today(completion: @escaping ([Picture]) -> Void) {
        var result: [Picture] = []

        let url = URL.init(string: "https://v2.api.dailypics.cn/today")
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if let data = data,
                let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<Any> {
                for case let item in decoded {
                    if let obj = Picture.init(source: item as! [String : Any]) {
                        result.append(obj)
                    }
                }
                completion(result)
            }
        }.resume()
    }
}
