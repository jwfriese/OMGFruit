import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Fruit", bundle: nil)
        let fruitViewController = storyboard.instantiateInitialViewController() as! FruitViewController

        let httpClient = HTTPClient()
        let fruitDeserializer = FruitDeserializer()
        let fruitService = FruitService()
        fruitService.httpClient = httpClient
        fruitService.fruitDeserializer = fruitDeserializer

        fruitViewController.fruitService = fruitService

        window?.rootViewController = fruitViewController
        window?.makeKeyAndVisible()

        return true
    }
}
